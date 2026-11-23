import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_session.dart';
import 'package:abak_desktop_companion/features/companion_access/patient_access_service.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'support/companion_access_test_support.dart';

class DelayedAccess extends CompanionAccessService {
  DelayedAccess(Database db)
    : super(database: () async => db, hasher: FastTestCodeHasher());
  Completer<void>? gate;
  Completer<void>? verificationStarted;
  @override
  Future<void> verifyCode(String id, String code) async {
    await super.verifyCode(id, code);
    verificationStarted?.complete();
    await gate?.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late DelayedAccess auth;
  late CompanionSession session;
  late PatientAccessService access;
  final denied = throwsA(isA<CompanionAccessException>());
  final now = DateTime.utc(2026, 11, 23);

  Future<void> mode(bool value) async {
    await db.insert('application_settings', {
      'setting_key': 'dmp_enabled',
      'setting_value': '$value',
      'updated_at': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    session.setEnabled(value);
  }

  Future<void> grant({
    String patient = 'p',
    PatientAccessReason reason = PatientAccessReason.withAgreement,
    String code = '1234',
  }) => access.grantException(patientId: patient, code: code, reason: reason);
  Future<List<Map<String, Object?>>> events() => db.query(
    'companion_access_events',
    where: "action = 'patient_exception_granted'",
  );

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('companion_patient_access_');
    db = await openAccessTestDatabase('${temp.path}/synthetic.db');
    auth = DelayedAccess(db);
    await auth.createCode('a', '0123');
    await auth.createCode('b', '1234');
    await auth.createCode('c', '2345');
    session = CompanionSession(
      access: auth,
      dmpContext: DmpWorkContext(),
      loadNationalId: (_) async => null,
      cpsBusy: () => false,
    );
    access = PatientAccessService(
      database: () async => db,
      session: session,
      now: () => now,
    );
    for (final id in ['p', 'q', 'unassigned', 'missing']) {
      await db.insert('patients', {
        'patient_id': id,
        'last_name': 'Synthetic',
        'first_name': id,
        'created_at': 1,
      });
      if (id != 'missing') {
        await db.insert('companion_patient_access', {
          'patient_id': id,
          'referring_practitioner_id': id == 'unassigned' ? null : 'a',
        });
      }
    }
    await mode(true);
  });
  tearDown(() async {
    access.dispose();
    session.dispose();
    await db.close();
    await temp.delete(recursive: true);
  });

  test(
    'patient-level owner only; administration does not grant patient access',
    () async {
      expect(
        (await access.inspect('p')).decision,
        PatientAccessDecision.identification,
      );
      await session.signIn('a', '0123');
      expect(
        (await access.inspect('p')).decision,
        PatientAccessDecision.referrer,
      );
      await session.signIn('b', '1234');
      await auth.initializeAdministrator('b', 'admin', '1234');
      expect((await access.inspect('p')).allowed, isFalse);
      await expectLater(access.inspect('nonexistent'), denied);
    },
  );

  test(
    'startup reads durable DMP setting before the banner initializes',
    () async {
      session.setEnabled(false);
      expect(
        (await access.inspect('p')).decision,
        PatientAccessDecision.identification,
      );
      await mode(false);
      expect(
        (await access.inspect('p')).decision,
        PatientAccessDecision.unrestricted,
      );
      expect((await access.inspect('missing')).allowed, isTrue);
    },
  );

  test(
    'exception requires own code and matching reason, is patient-specific and logged',
    () async {
      await session.signIn('b', '1234');
      await expectLater(grant(reason: PatientAccessReason.continuity), denied);
      await expectLater(grant(code: '0123'), denied);
      expect(await events(), isEmpty);
      await grant();
      expect(
        (await access.inspect('p')).decision,
        PatientAccessDecision.exception,
      );
      expect((await access.inspect('q')).allowed, isFalse);
      final event = (await events()).single;
      expect(event['patient_id'], 'p');
      expect(event['actor_practitioner_id'], 'b');
      expect(event['previous_practitioner_id'], 'a');
      expect(event['session_id'], session.sessionId);
      expect(event['reason'], 'withAgreement');
      expect(event.values, isNot(contains('1234')));
      // Already authorized: no duplicate exception and no extra PIN verification.
      await grant(code: '9999');
      expect(await events(), hasLength(1));
    },
  );

  test(
    'five incorrect codes retain shared failure counts and block correct code',
    () async {
      await session.signIn('b', '1234');
      for (var i = 0; i < 5; i++) {
        await expectLater(grant(code: '9999'), denied);
      }
      await expectLater(grant(), denied);
      expect((await access.inspect('p')).allowed, isFalse);
      expect(await events(), isEmpty);
      expect(
        (await db.query('companion_auth_attempts')).single['blocked_until'],
        greaterThan(0),
      );
    },
  );

  test(
    'unassigned and missing metadata only allow continuity reason',
    () async {
      await session.signIn('b', '1234');
      for (final id in ['unassigned', 'missing']) {
        await expectLater(grant(patient: id), denied);
        await grant(patient: id, reason: PatientAccessReason.continuity);
        expect((await access.inspect(id)).allowed, isTrue);
        await expectLater(
          access.changeReferrer(patientId: id, newReferrerId: 'b'),
          denied,
        );
      }
    },
  );

  test(
    'lock then same-user unlock revokes the exception immediately',
    () async {
      await session.signIn('b', '1234');
      await grant();
      var notified = false;
      access.addListener(() => notified = true);
      session.lock();
      expect(notified, isTrue);
      expect((await access.inspect('p')).allowed, isFalse);
      await session.signIn('b', '1234');
      expect((await access.inspect('p')).allowed, isFalse);
    },
  );

  test(
    'logout, switching, DMP toggle and service recreation never restore grants',
    () async {
      await session.signIn('b', '1234');
      await grant();
      session.signOut();
      await session.signIn('b', '1234');
      expect((await access.inspect('p')).allowed, isFalse);
      await grant();
      await session.signIn('c', '2345');
      await session.signIn('b', '1234');
      expect((await access.inspect('p')).allowed, isFalse);
      await grant();
      await mode(false);
      expect((await access.inspect('p')).allowed, isTrue);
      await mode(true);
      await session.signIn('b', '1234');
      expect((await access.inspect('p')).allowed, isFalse);
      await grant();
      access.dispose();
      access = PatientAccessService(database: () async => db, session: session);
      expect((await access.inspect('p')).allowed, isFalse);
    },
  );

  test('lock during code verification cannot install a late grant', () async {
    await session.signIn('b', '1234');
    final gate = Completer<void>();
    auth.gate = gate;
    auth.verificationStarted = Completer<void>();
    final pending = grant();
    final rejected = expectLater(pending, denied);
    await auth.verificationStarted!.future;
    session.lock();
    gate.complete();
    await rejected;
    auth.gate = null;
    auth.verificationStarted = null;
    await session.signIn('b', '1234');
    expect((await access.inspect('p')).allowed, isFalse);
    expect(await events(), isEmpty);
  });

  test(
    'owner can transfer; exception and administrator cannot, and authors stay untouched',
    () async {
      await session.signIn('b', '1234');
      await grant();
      await auth.initializeAdministrator('b', 'admin', '1234');
      await expectLater(
        access.changeReferrer(patientId: 'p', newReferrerId: 'b'),
        denied,
      );
      final patients = await db.query('patients');
      final reports = await db.query('care_episode_reports');
      final changes = await db.query('document_medical_changes');
      await session.signIn('a', '0123');
      await access.changeReferrer(patientId: 'p', newReferrerId: 'c');
      expect((await access.inspect('p')).allowed, isFalse);
      expect((await access.inspect('q')).allowed, isTrue);
      expect(await db.query('patients'), patients);
      expect(await db.query('care_episode_reports'), reports);
      expect(await db.query('document_medical_changes'), changes);
      final event = (await db.query(
        'companion_access_events',
        where: "action = 'patient_referrer_changed'",
      )).single;
      expect(event['previous_practitioner_id'], 'a');
      expect(event['target_practitioner_id'], 'c');
      await session.signIn('c', '2345');
      expect(
        (await access.inspect('p')).decision,
        PatientAccessDecision.referrer,
      );
    },
  );

  test(
    'DMP off permits ordinary changes, but not unassigned recovery',
    () async {
      await mode(false);
      await access.changeReferrer(patientId: 'p', newReferrerId: 'b');
      expect((await access.inspect('p')).referrerId, 'b');
      await expectLater(
        access.changeReferrer(patientId: 'unassigned', newReferrerId: 'b'),
        denied,
      );
    },
  );

  test(
    'archived target rejected; archived actor cannot use an existing session',
    () async {
      await session.signIn('a', '0123');
      await db.update('practitioners', {
        'archived_at': 2,
      }, where: "practitioner_id = 'b'");
      await expectLater(
        access.changeReferrer(patientId: 'p', newReferrerId: 'b'),
        denied,
      );
      await db.update('practitioners', {
        'archived_at': 2,
      }, where: "practitioner_id = 'a'");
      await expectLater(access.inspect('p'), denied);
    },
  );

  test(
    'grant bound to assignment cannot authorize a subsequently reassigned patient',
    () async {
      await session.signIn('b', '1234');
      await grant();
      await db.update('companion_patient_access', {
        'referring_practitioner_id': 'c',
      }, where: "patient_id = 'p'");
      expect((await access.inspect('p')).allowed, isFalse);
    },
  );

  test(
    'journal failure denies access and retention removes entries older than twelve months',
    () async {
      await session.signIn('b', '1234');
      await db.insert('companion_access_events', {
        'occurred_at': DateTime.utc(2025, 11, 22).millisecondsSinceEpoch,
        'action': 'old',
      });
      await db.insert('companion_access_events', {
        'occurred_at': DateTime.utc(2025, 11, 23).millisecondsSinceEpoch,
        'action': 'boundary',
      });
      await db.execute(
        "CREATE TRIGGER reject_exception BEFORE INSERT ON companion_access_events WHEN NEW.action = 'patient_exception_granted' BEGIN SELECT RAISE(ABORT, 'test'); END",
      );
      await expectLater(grant(), throwsA(isA<DatabaseException>()));
      expect((await access.inspect('p')).allowed, isFalse);
      await db.execute('DROP TRIGGER reject_exception');
      await grant();
      expect(
        await db.query('companion_access_events', where: "action = 'old'"),
        isEmpty,
      );
      expect(
        await db.query('companion_access_events', where: "action = 'boundary'"),
        hasLength(1),
      );
    },
  );

  test(
    'new assignment validates practitioner and cannot overwrite an existing assignment',
    () async {
      await db.transaction(
        (txn) => PatientAccessService.assignNewPatient(txn, 'missing', 'b'),
      );
      await expectLater(
        db.transaction(
          (txn) => PatientAccessService.assignNewPatient(txn, 'p', 'b'),
        ),
        throwsA(isA<DatabaseException>()),
      );
      expect((await access.inspect('p')).referrerId, 'a');
      await expectLater(
        db.transaction(
          (txn) => PatientAccessService.assignNewPatient(txn, 'q', 'unknown'),
        ),
        denied,
      );
    },
  );

  test(
    'referrer change during PIN verification requires a new request',
    () async {
      await session.signIn('b', '1234');
      auth.gate = Completer<void>();
      auth.verificationStarted = Completer<void>();
      final rejected = expectLater(grant(), denied);
      await auth.verificationStarted!.future;
      await db.update('companion_patient_access', {
        'referring_practitioner_id': 'c',
      }, where: "patient_id = 'p'");
      auth.gate!.complete();
      await rejected;
      expect((await access.inspect('p')).allowed, isFalse);
      expect(await events(), isEmpty);
    },
  );

  test('schema 52 upgrade preserves journal and clinical rows', () async {
    final people = await db.query('practitioners');
    final patients = await db.query('patients');
    final assignments = await db.query('companion_patient_access');
    await db.execute('DROP TABLE companion_access_events');
    await db.execute(
      '''CREATE TABLE companion_access_events (
      event_id INTEGER PRIMARY KEY AUTOINCREMENT, occurred_at INTEGER NOT NULL,
      action TEXT NOT NULL, actor_practitioner_id TEXT, target_practitioner_id TEXT, session_id TEXT)''',
    );
    await db.insert('companion_access_events', {
      'occurred_at': 1,
      'action': 'legacy',
      'actor_practitioner_id': 'a',
    });
    await db.setVersion(52);
    await db.close();
    db = await DatabaseService.openDatabaseFile(
      '${temp.path}/synthetic.db',
      factory: databaseFactoryFfi,
    );
    expect(await db.getVersion(), DatabaseService.schemaVersion);
    expect(await db.query('patients'), patients);
    expect(await db.query('practitioners'), people);
    expect(await db.query('companion_patient_access'), assignments);
    final event = (await db.query('companion_access_events')).single;
    expect(event['action'], 'legacy');
    expect(event.containsKey('patient_id'), isTrue);
    expect(event['patient_id'], isNull);
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    expect(await db.rawQuery('PRAGMA integrity_check'), [
      {'integrity_check': 'ok'},
    ]);
  });
}
