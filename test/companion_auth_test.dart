import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/personal_code_hasher.dart';
import 'package:abak_desktop_companion/features/practitioners/data/practitioner_repository.dart';
import 'support/companion_access_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late CompanionAccessService service;
  late DateTime now;
  final denied = throwsA(isA<CompanionAccessException>());

  CompanionAccessService newService() => CompanionAccessService(
    database: () async => db,
    hasher: FastTestCodeHasher(),
    now: () => now,
  );
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('companion_auth_');
    db = await openAccessTestDatabase('${temp.path}/synthetic.db');
    now = DateTime.utc(2026, 11, 23, 10);
    service = newService();
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });

  test(
    'upgrade from access-only schema preserves assignments and source rows',
    () async {
      await db.insert('patients', {
        'patient_id': 'patient',
        'last_name': 'Test',
        'first_name': 'Patient',
        'created_at': 1,
      });
      await db.insert('companion_patient_access', {
        'patient_id': 'patient',
        'referring_practitioner_id': 'b',
      });
      final people = await db.query('practitioners');
      final patients = await db.query('patients');
      final assignments = await db.query('companion_patient_access');
      final changes = await db.query('document_medical_changes');
      await db.execute('DROP TRIGGER companion_admin_no_archive');
      for (final table in [
        'companion_personal_codes',
        'companion_auth_attempts',
        'companion_access_events',
      ]) {
        await db.execute('DROP TABLE $table');
      }
      await db.setVersion(51);
      await db.close();
      db = await DatabaseService.openDatabaseFile(
        '${temp.path}/synthetic.db',
        factory: databaseFactoryFfi,
      );
      expect(await db.getVersion(), DatabaseService.schemaVersion);
      expect(await db.query('practitioners'), people);
      expect(await db.query('patients'), patients);
      expect(await db.query('companion_patient_access'), assignments);
      expect(await db.query('document_medical_changes'), changes);
      expect(await db.query('companion_personal_codes'), isEmpty);
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
      expect(await db.rawQuery('PRAGMA integrity_check'), [
        {'integrity_check': 'ok'},
      ]);
    },
  );

  test(
    'exactly four ASCII digits, leading zero preserved, no overwrite by creation',
    () async {
      for (final code in [
        '',
        '123',
        '12345',
        '12a4',
        ' 1234',
        '1234\n',
        '１２３４',
      ]) {
        await expectLater(service.createCode('a', code), denied);
      }
      await service.createCode('a', '0123');
      await service.verifyCode('a', '0123');
      await expectLater(service.verifyCode('a', '1230'), denied);
      await expectLater(service.createCode('a', '9999'), denied);
      await service.verifyCode('a', '0123');
      expect(await service.hasAdministrators(), isFalse);
    },
  );

  test(
    'change requires the current code and invalidates the old one',
    () async {
      await service.createCode('a', '0123');
      await expectLater(service.changeCode('a', '9999', '4321'), denied);
      await service.verifyCode('a', '0123');
      await service.changeCode('a', '0123', '4321');
      await expectLater(service.verifyCode('a', '0123'), denied);
      await service.verifyCode('a', '4321');
    },
  );

  test(
    'five failures block for 30 seconds across services and reopening',
    () async {
      await service.createCode('a', '0123');
      for (var i = 0; i < 5; i++) {
        await expectLater(service.verifyCode('a', '9999'), denied);
      }
      await db.close();
      db = await DatabaseService.openDatabaseFile(
        '${temp.path}/synthetic.db',
        factory: databaseFactoryFfi,
      );
      service = newService();
      await expectLater(service.verifyCode('a', '0123'), denied);
      now = now.add(const Duration(seconds: 29));
      await expectLater(service.verifyCode('a', '0123'), denied);
      now = now.add(const Duration(seconds: 1));
      await service.verifyCode('a', '0123');
      expect(await db.query('companion_auth_attempts'), isEmpty);
    },
  );

  test('concurrent failed requests cannot bypass the counter', () async {
    await service.createCode('a', '0123');
    await Future.wait(
      List.generate(
        5,
        (_) => expectLater(service.verifyCode('a', '9999'), denied),
      ),
    );
    await expectLater(service.verifyCode('a', '0123'), denied);
  });

  test('successful verification clears previous failures', () async {
    await service.createCode('a', '0123');
    for (var i = 0; i < 4; i++) {
      await expectLater(service.verifyCode('a', '9999'), denied);
    }
    await service.verifyCode('a', '0123');
    await expectLater(service.verifyCode('a', '9999'), denied);
    await service.verifyCode('a', '0123');
  });

  test(
    'initial password disabled after first administrator and enabled after last removal',
    () async {
      await expectLater(
        service.initializeAdministrator('a', 'wrong', '0123'),
        denied,
      );
      await service.initializeAdministrator('a', 'admin', '0123');
      expect(await service.hasAdministrators(), isTrue);
      await expectLater(
        service.initializeAdministrator('b', 'admin', '1234'),
        denied,
      );
      await service.setAdministrator(
        actorId: 'a',
        actorCode: '0123',
        targetId: 'a',
        enabled: false,
      );
      expect(await service.hasAdministrators(), isFalse);
      await service.initializeAdministrator('b', 'admin', '1234');
      expect(
        (await service.practitioners())
            .singleWhere((p) => p.id == 'b')
            .isAdministrator,
        isTrue,
      );
    },
  );

  test('bootstrap cannot replace an existing personal code', () async {
    await service.createCode('a', '0123');
    await expectLater(
      service.initializeAdministrator('a', 'admin', '9999'),
      denied,
    );
    expect(await service.hasAdministrators(), isFalse);
    await service.initializeAdministrator('a', 'admin', '0123');
  });

  test('initial password also has a persisted retry delay', () async {
    for (var i = 0; i < 5; i++) {
      await expectLater(
        service.initializeAdministrator('a', 'wrong', '0123'),
        denied,
      );
    }
    await expectLater(
      service.initializeAdministrator('a', 'admin', '0123'),
      denied,
    );
    now = now.add(const Duration(seconds: 30));
    await service.initializeAdministrator('a', 'admin', '0123');
  });

  test(
    'administrator changes require a current administrator code and allow several administrators',
    () async {
      await service.initializeAdministrator('a', 'admin', '0123');
      await service.createCode('b', '1234');
      await expectLater(
        service.setAdministrator(
          actorId: 'b',
          actorCode: '1234',
          targetId: 'b',
          enabled: true,
        ),
        denied,
      );
      await expectLater(
        service.setAdministrator(
          actorId: 'a',
          actorCode: '9999',
          targetId: 'b',
          enabled: true,
        ),
        denied,
      );
      await expectLater(
        service.setAdministrator(
          actorId: 'a',
          actorCode: '0123',
          targetId: 'c',
          enabled: true,
        ),
        denied,
      );
      await service.setAdministrator(
        actorId: 'a',
        actorCode: '0123',
        targetId: 'b',
        enabled: true,
      );
      expect(
        (await service.practitioners()).where((p) => p.isAdministrator),
        hasLength(2),
      );
      await service.setAdministrator(
        actorId: 'b',
        actorCode: '1234',
        targetId: 'a',
        enabled: false,
      );
      await expectLater(
        service.setAdministrator(
          actorId: 'a',
          actorCode: '0123',
          targetId: 'b',
          enabled: false,
        ),
        denied,
      );
    },
  );

  test(
    'reset requires administrator authentication and permits a new personal choice',
    () async {
      await service.initializeAdministrator('a', 'admin', '0123');
      await service.createCode('b', '1234');
      await expectLater(
        service.resetCode(actorId: 'b', actorCode: '1234', targetId: 'a'),
        denied,
      );
      await expectLater(
        service.resetCode(actorId: 'a', actorCode: '9999', targetId: 'b'),
        denied,
      );
      await service.resetCode(actorId: 'a', actorCode: '0123', targetId: 'b');
      await expectLater(service.verifyCode('b', '1234'), denied);
      await service.createCode('b', '4321');
      await service.verifyCode('b', '4321');
      final events = await db.query(
        'companion_access_events',
        where: 'action = ?',
        whereArgs: ['code_reset'],
      );
      expect(events.single['actor_practitioner_id'], 'a');
      expect(events.single['target_practitioner_id'], 'b');
    },
  );

  test(
    'administrator cannot be archived via repository or direct update',
    () async {
      await service.initializeAdministrator('a', 'admin', '0123');
      final repository = PractitionerRepository(database: () async => db);
      await expectLater(repository.archivePractitioner('a'), throwsStateError);
      await expectLater(
        db.update(
          'practitioners',
          {'archived_at': 100},
          where: 'practitioner_id = ?',
          whereArgs: ['a'],
        ),
        throwsA(isA<DatabaseException>()),
      );
      await service.setAdministrator(
        actorId: 'a',
        actorCode: '0123',
        targetId: 'a',
        enabled: false,
      );
      await repository.archivePractitioner('a');
      await expectLater(service.verifyCode('a', '0123'), denied);
    },
  );

  test(
    'archived practitioners cannot create a code or bootstrap administration',
    () async {
      await db.update(
        'practitioners',
        {'archived_at': 100},
        where: 'practitioner_id = ?',
        whereArgs: ['a'],
      );
      await expectLater(service.createCode('a', '0123'), denied);
      await expectLater(
        service.initializeAdministrator('a', 'admin', '0123'),
        denied,
      );
    },
  );

  test('logs omit codes and purge entries older than twelve months', () async {
    await db.insert('companion_access_events', {
      'occurred_at': DateTime.utc(2025, 11, 22).millisecondsSinceEpoch,
      'action': 'old',
    });
    await service.initializeAdministrator('a', 'admin', '0123');
    final events = await db.query('companion_access_events');
    expect(events, hasLength(1));
    expect(events.toString(), isNot(contains('0123')));
    expect(events.single['action'], 'administrator_initialized');
    final codes = await db.query('companion_personal_codes');
    expect(codes.toString(), isNot(contains('0123')));
  });

  test(
    'real PBKDF2 uses random salts, preserves leading zeros and rejects wrong codes',
    () async {
      final hasher = Pbkdf2PersonalCodeHasher();
      final first = await hasher.create('0123');
      final second = await hasher.create('0123');
      expect(first.salt, isNot(second.salt));
      expect(first.verifier, isNot(second.verifier));
      expect(first.iterations, 600000);
      expect(await hasher.verify('0123', first), isTrue);
      expect(await hasher.verify('1230', first), isFalse);
      expect(first.toMap().values, isNot(contains('0123')));
    },
  );
}
