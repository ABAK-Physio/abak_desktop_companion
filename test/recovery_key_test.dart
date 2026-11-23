import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_session.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'support/companion_access_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late CompanionAccessService auth;
  late DateTime now;
  final denied = throwsA(isA<CompanionAccessException>());
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('recovery_key_');
    db = await openAccessTestDatabase('${temp.path}/test.db');
    now = DateTime.utc(2026, 11, 23);
    auth = CompanionAccessService(
      database: () async => db,
      hasher: FastTestCodeHasher(),
      now: () => now,
    );
    await auth.initializeAdministrator('a', 'admin', '0123');
    await auth.createCode('b', '1234');
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });
  Future<String> generate() =>
      auth.generateRecoveryKey(actorId: 'a', actorCode: '0123');
  Future<void> recover(String key) =>
      auth.recoverAdministrator(key: key, newCode: '2345', practitionerId: 'b');

  test(
    'generation requires administrator PIN and stores only a verifier',
    () async {
      expect(await auth.hasRecoveryKey(), isFalse);
      await expectLater(
        auth.generateRecoveryKey(actorId: 'b', actorCode: '1234'),
        denied,
      );
      await expectLater(
        auth.generateRecoveryKey(actorId: 'a', actorCode: '9999'),
        denied,
      );
      expect(await auth.hasRecoveryKey(), isFalse);
      final key = await generate();
      expect(RegExp(r'^ABAK(-[0-9A-F]{4}){8}$').hasMatch(key), isTrue);
      final stored = (await db.query('companion_recovery_key')).single;
      expect(stored['verifier'], hasLength(64));
      expect(stored.values, isNot(contains(key)));
      final journal = await db.query('companion_access_events');
      expect(journal.toString(), isNot(contains(key)));
    },
  );
  test(
    'rotation invalidates the old key while failed rotation leaves it valid',
    () async {
      final first = await generate();
      await expectLater(
        auth.generateRecoveryKey(actorId: 'a', actorCode: '9999'),
        denied,
      );
      await recover(first);
      final second = await generate();
      expect(second, isNot(first));
      await expectLater(recover(first), denied);
      await recover(second.toLowerCase().replaceAll('-', ' '));
      await auth.verifyCode('b', '2345');
      await expectLater(auth.verifyCode('b', '1234'), denied);
    },
  );
  test(
    'recovery needs no prior identity, preserves other admins and logs key-based authority',
    () async {
      final key = await generate();
      await recover(key);
      final people = await auth.practitioners();
      expect(
        people.where((p) => p.isAdministrator).map((p) => p.id),
        containsAll(['a', 'b']),
      );
      final event = (await db.query(
        'companion_access_events',
        where: "action = 'administrator_recovered_with_key'",
      )).single;
      expect(event['actor_practitioner_id'], isNull);
      expect(event['target_practitioner_id'], 'b');
      expect(event.toString(), isNot(contains(key)));
    },
  );
  test(
    'successor can create a new administrator without using a departed identity',
    () async {
      final key = await generate();
      await auth.recoverAdministrator(
        key: key,
        newCode: '0007',
        newPractitionerName: 'Successeur',
      );
      final person = (await auth.practitioners()).singleWhere(
        (p) => p.name == 'Successeur',
      );
      expect(person.isAdministrator, isTrue);
      await auth.verifyCode(person.id, '0007');
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );
  test(
    'recovery closes active sessions including same-person sessions',
    () async {
      final session = CompanionSession(
        access: auth,
        dmpContext: DmpWorkContext(),
        loadNationalId: (_) async => null,
        cpsBusy: () => false,
      )..setEnabled(true);
      try {
        await session.signIn('b', '1234');
        final ticket = session.bind();
        await recover(await generate());
        expect(session.authenticated, isFalse);
        expect(session.practitionerId, isNull);
        expect(ticket, denied);
      } finally {
        session.dispose();
      }
    },
  );
  test(
    '5 wrong keys block recovery for 30 seconds across service recreation',
    () async {
      final key = await generate();
      for (var i = 0; i < 5; i++) {
        await expectLater(recover('wrong'), denied);
      }
      auth = CompanionAccessService(
        database: () async => db,
        hasher: FastTestCodeHasher(),
        now: () => now,
      );
      await expectLater(recover(key), denied);
      now = now.add(const Duration(seconds: 30));
      await recover(key);
    },
  );
  test(
    'unknown/archived targets and invalid new codes leave identities unchanged',
    () async {
      final key = await generate();
      final before = await db.query('companion_personal_codes');
      await db.update('practitioners', {
        'archived_at': 1,
      }, where: "practitioner_id = 'b'");
      await expectLater(recover(key), denied);
      await expectLater(
        auth.recoverAdministrator(
          key: key,
          newCode: '123',
          practitionerId: 'a',
        ),
        denied,
      );
      await expectLater(
        auth.recoverAdministrator(
          key: key,
          newCode: '1234',
          practitionerId: 'unknown',
        ),
        denied,
      );
      expect(await db.query('companion_personal_codes'), before);
    },
  );
  test(
    'journal failure rolls back key replacement and administrator recovery',
    () async {
      final first = await generate();
      await db.execute(
        "CREATE TRIGGER reject_recovery BEFORE INSERT ON companion_access_events WHEN NEW.action IN ('recovery_key_generated', 'administrator_recovered_with_key') BEGIN SELECT RAISE(ABORT, 'test'); END",
      );
      await expectLater(generate(), throwsA(isA<DatabaseException>()));
      await expectLater(recover(first), throwsA(isA<DatabaseException>()));
      await auth.verifyCode('b', '1234');
      expect(
        (await auth.practitioners())
            .singleWhere((p) => p.id == 'b')
            .isAdministrator,
        isFalse,
      );
      await db.execute('DROP TRIGGER reject_recovery');
      await recover(first);
    },
  );
  test(
    'no key exists implicitly and cabinet data changes do not derive or invalidate it',
    () async {
      await expectLater(
        recover('ABAK-0000-0000-0000-0000-0000-0000-0000-0000'),
        denied,
      );
      final key = await generate();
      await db.insert('application_settings', {
        'setting_key': 'test_cabinet_name',
        'setting_value': 'Nouveau cabinet',
        'updated_at': 1,
      });
      await recover(key);
    },
  );
  test(
    'schema 53 upgrades without generating a key or changing existing credentials',
    () async {
      final before = await db.query('companion_personal_codes');
      await db.execute('DROP TABLE companion_recovery_key');
      await db.setVersion(53);
      await db.close();
      db = await DatabaseService.openDatabaseFile(
        '${temp.path}/test.db',
        factory: databaseFactoryFfi,
      );
      expect(await db.getVersion(), DatabaseService.schemaVersion);
      expect(await auth.hasRecoveryKey(), isFalse);
      expect(await db.query('companion_personal_codes'), before);
      expect(await db.rawQuery('PRAGMA integrity_check'), [
        {'integrity_check': 'ok'},
      ]);
    },
  );
}
