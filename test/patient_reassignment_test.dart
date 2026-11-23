import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_session.dart';
import 'package:abak_desktop_companion/features/companion_access/patient_access_service.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'support/companion_access_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late CompanionAccessService auth;
  late String key;
  late DateTime now;
  final denied = throwsA(isA<CompanionAccessException>());
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('patient_reassignment_');
    db = await openAccessTestDatabase('${temp.path}/test.db');
    now = DateTime.utc(2026, 11, 23);
    auth = CompanionAccessService(
      database: () async => db,
      hasher: FastTestCodeHasher(),
      now: () => now,
    );
    await auth.initializeAdministrator('a', 'admin', '0123');
    await auth.createCode('b', '1234');
    key = await auth.generateRecoveryKey(actorId: 'a', actorCode: '0123');
    for (final id in ['p', 'q', 'r', 'unassigned', 'missing']) {
      await db.insert('patients', {
        'patient_id': id,
        'last_name': 'Patient',
        'first_name': id,
        'created_at': 1,
        if (id == 'q') 'archived_at': 2,
      });
      if (id != 'missing') {
        await db.insert('companion_patient_access', {
          'patient_id': id,
          'referring_practitioner_id': id == 'unassigned' ? null : 'a',
          if (id == 'unassigned') ...{
            'former_practitioner_id': 'c',
            'departure_date': 3,
          },
        });
      }
    }
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });
  Future<int> transfer(
    Map<String, String> changes, {
    String? source = 'a',
    bool all = false,
    String? secret,
  }) => auth.reassignPatientsWithKey(
    key: secret ?? key,
    sourceId: source,
    assignments: changes,
    entireSource: all,
  );
  Future<String?> ref(String id) async =>
      (await db.query(
            'companion_patient_access',
            where: 'patient_id = ?',
            whereArgs: [id],
          )).single['referring_practitioner_id']
          as String?;

  test(
    'bulk transfer includes archived dossiers and preserves clinical rows, authors and DMP history',
    () async {
      await db.insert('care_episodes', {
        'care_episode_id': 'e',
        'patient_id': 'p',
        'title': 'Épisode',
        'pathology_label': 'Test',
        'created_at': 1,
      });
      await db.insert('care_episode_reports', {
        'report_id': 'report',
        'care_episode_id': 'e',
        'author_practitioner_id': 'a',
        'title': 'Rapport',
        'content_json': '{}',
        'report_date': 1,
        'created_at': 1,
      });
      final before = {
        for (final table in [
          'patients',
          'care_episodes',
          'care_episode_reports',
          'document_medical_changes',
        ])
          table: await db.query(table),
      };
      expect(await transfer({'p': 'b', 'q': 'b', 'r': 'b'}, all: true), 3);
      for (final entry in before.entries) {
        expect(await db.query(entry.key), entry.value);
      }
      expect(await ref('q'), 'b');
      final logs = await db.query(
        'companion_access_events',
        where: "action = 'patient_reassigned_with_key'",
      );
      expect(logs, hasLength(3));
      for (final row in logs) {
        expect(row['previous_practitioner_id'], 'a');
        expect(row['target_practitioner_id'], 'b');
        expect(row['actor_practitioner_id'], isNull);
        expect(row['reason'], 'recovery_key');
      }
      expect(logs.toString(), isNot(contains(key)));
    },
  );
  test(
    'individual assignment supports different targets and leaves unselected patients intact',
    () async {
      await transfer({'p': 'b', 'q': 'c'});
      expect(await ref('p'), 'b');
      expect(await ref('q'), 'c');
      expect(await ref('r'), 'a');
    },
  );
  test(
    'administrator PIN is not a recovery key and shares key attempt limit',
    () async {
      for (var i = 0; i < 5; i++) {
        await expectLater(transfer({'p': 'b'}, secret: '0123'), denied);
      }
      await expectLater(transfer({'p': 'b'}), denied);
      expect(await ref('p'), 'a');
      now = now.add(const Duration(seconds: 30));
      await transfer({'p': 'b'});
    },
  );
  test(
    'bulk refuses changed membership rather than silently adding patients',
    () async {
      await expectLater(transfer({'p': 'b', 'q': 'b'}, all: true), denied);
      expect(await ref('p'), 'a');
      await db.update('companion_patient_access', {
        'referring_practitioner_id': 'c',
      }, where: "patient_id = 'q'");
      await expectLater(transfer({'p': 'b', 'q': 'b'}), denied);
      expect(await ref('p'), 'a');
      expect(await ref('q'), 'c');
    },
  );
  test(
    'deleted patient, archived target, identical target and empty request are refused atomically',
    () async {
      await expectLater(transfer({'p': 'b', 'unknown': 'b'}), denied);
      await db.update('practitioners', {
        'archived_at': 4,
      }, where: "practitioner_id = 'c'");
      await expectLater(transfer({'p': 'b', 'q': 'c'}), denied);
      await expectLater(transfer({'p': 'a'}), denied);
      await expectLater(transfer({}), denied);
      expect(await ref('p'), 'a');
    },
  );
  test(
    'unassigned patients retain departure history; missing metadata is inserted',
    () async {
      final listed = await auth.reassignmentPatients(null);
      expect(listed.map((p) => p.id), containsAll(['missing', 'unassigned']));
      expect(
        listed.singleWhere((p) => p.id == 'unassigned').formerReferrer,
        'Kiné C',
      );
      await transfer(
        {'unassigned': 'b', 'missing': 'c'},
        source: null,
        all: true,
      );
      final row = (await db.query(
        'companion_patient_access',
        where: "patient_id = 'unassigned'",
      )).single;
      expect(row['former_practitioner_id'], 'c');
      expect(row['departure_date'], 3);
      expect(await ref('missing'), 'c');
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );
  test(
    'failure on second journal row rolls back all assignments and events',
    () async {
      await db.execute(
        "CREATE TRIGGER reject_second_reassignment BEFORE INSERT ON companion_access_events WHEN NEW.action = 'patient_reassigned_with_key' AND NEW.patient_id = 'q' BEGIN SELECT RAISE(ABORT, 'test'); END",
      );
      await expectLater(
        transfer({'p': 'b', 'q': 'c'}),
        throwsA(isA<DatabaseException>()),
      );
      expect(await ref('p'), 'a');
      expect(await ref('q'), 'a');
      expect(
        await db.query(
          'companion_access_events',
          where: "action = 'patient_reassigned_with_key'",
        ),
        isEmpty,
      );
    },
  );
  test(
    'affected patient grants are revoked immediately, other session grants remain valid',
    () async {
      final session = CompanionSession(
        access: auth,
        dmpContext: DmpWorkContext(),
        loadNationalId: (_) async => null,
        cpsBusy: () => false,
      )..setEnabled(true);
      final access = PatientAccessService(
        database: () async => db,
        session: session,
      );
      try {
        await session.signIn('b', '1234');
        for (final id in ['p', 'q']) {
          await access.grantException(
            patientId: id,
            code: '1234',
            reason: PatientAccessReason.withAgreement,
          );
        }
        var notified = false;
        access.addListener(() => notified = true);
        await transfer({'p': 'c'});
        expect(notified, isTrue);
        expect((await access.inspect('p')).allowed, isFalse);
        expect(
          (await access.inspect('q')).decision,
          PatientAccessDecision.exception,
        );
        expect(session.authenticated, isTrue);
      } finally {
        access.dispose();
        session.dispose();
      }
    },
  );
  test('replaced recovery keys no longer authorize transfers', () async {
    final old = key;
    key = await auth.generateRecoveryKey(actorId: 'a', actorCode: '0123');
    await expectLater(transfer({'p': 'b'}, secret: old), denied);
    await transfer({'p': 'b'});
  });
  test(
    'archived source remains selectable, active targets exclude archived kinés',
    () async {
      await auth.setAdministrator(
        actorId: 'a',
        actorCode: '0123',
        targetId: 'a',
        enabled: false,
      );
      await db.update('practitioners', {
        'archived_at': 4,
      }, where: "practitioner_id = 'a'");
      final source = (await auth.reassignmentSources()).singleWhere(
        (s) => s.id == 'a',
      );
      expect(source.name, contains('archivé'));
      expect(source.patientCount, 3);
      expect((await auth.practitioners()).any((p) => p.id == 'a'), isFalse);
      await transfer({'p': 'b', 'q': 'b', 'r': 'b'}, all: true);
    },
  );
}
