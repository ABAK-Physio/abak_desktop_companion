import 'dart:io';
import 'package:abak_desktop_companion/features/planning/prototype/planning_calendar_adapter.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_event_drag.dart';

import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/planning/data/planning_repository.dart';
import 'package:abak_desktop_companion/features/planning/models/planning_appointment.dart';
import 'package:abak_desktop_companion/features/maintenance/services/companion_backup_archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late Directory temp;
  late PathProviderPlatform previous;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('abak_planning_migration_');
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(temp.path);
  });
  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    await temp.delete(recursive: true);
  });

  test(
    'v35 migration adds practitioner attribution without deleting data',
    () async {
      final db = await DatabaseService.database;
      await db.execute('DROP INDEX idx_planning_practitioner');
      await db.execute(
        'ALTER TABLE planning_appointments DROP COLUMN practitioner_id',
      );
      await db.execute(
        "INSERT INTO planning_appointments (appointment_id, title, appointment_date, color_argb) VALUES ('old', 'Ancien RV', '2026-10-09', 0)",
      );
      await db.setVersion(35);
      await DatabaseService.closeDatabase();
      final migrated = await DatabaseService.database;
      expect(await migrated.getVersion(), 38);
      final rows = await migrated.query('planning_appointments');
      expect(rows.single['appointment_id'], 'old');
      expect(rows.single.containsKey('practitioner_id'), isTrue);
      expect(rows.single['practitioner_id'], isNull);
    },
  );

  test('fresh schema, snapshot restore and reset include planning', () async {
    final repository = PlanningRepository(
      database: () => DatabaseService.database,
    );
    expect(await repository.listAll(), isEmpty);
    final item = PlanningAppointment(
      id: 'persisted',
      title: 'Séance',
      date: DateTime(2026, 10, 8),
      startMinute: 540,
      endMinute: 585,
    );
    await repository.insert(item);
    final db = await DatabaseService.database;
    expect(await db.getVersion(), 38);
    final snapshot = '${temp.path}/snapshot.db';
    await db.execute('VACUUM INTO ?', [snapshot]);
    await CompanionBackupArchive.validateDatabase(snapshot);
    final copy = await DatabaseService.openDatabaseFile(snapshot);
    try {
      expect(
        (await PlanningRepository(
          database: () async => copy,
        ).listAll()).single.toMap(),
        item.toMap(),
      );
    } finally {
      await copy.close();
    }
    await DatabaseService.resetUserDatabase();
    expect(await repository.listAll(), isEmpty);
    await repository.insert(item);
    await DatabaseService.reopenDatabase();
    expect((await repository.listAll()).single.toMap(), item.toMap());
  });

  test('v31 upgrade keeps all existing tables and rows intact', () async {
    final path = '${temp.path}/v31.db';
    var db = await DatabaseService.openDatabaseFile(path);
    // v31 differs only by the added planning schema. Reconstruct that fixture.
    await db.execute('DROP TRIGGER unlink_planning_patient');
    await db.execute('DROP TABLE planning_appointments');
    await db.setVersion(31);
    await db.insert('application_settings', {
      'setting_key': 'planning-migration-check',
      'setting_value': 'conserver',
      'updated_at': 123,
    });
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final before = <String, List<Map<String, Object?>>>{};
    for (final row in tables) {
      final name = row['name'] as String;
      before[name] = await db.query(name);
    }
    await db.close();
    db = await DatabaseService.openDatabaseFile(path);
    try {
      expect(await db.getVersion(), 38);
      for (final entry in before.entries) {
        expect(await db.query(entry.key), entry.value, reason: entry.key);
      }
      expect(await db.query('planning_appointments'), isEmpty);
      expect(await db.rawQuery('PRAGMA integrity_check'), [
        {'integrity_check': 'ok'},
      ]);
    } finally {
      await db.close();
    }
  });
  test('v32 migration preserves appointments and patient lifecycle', () async {
    final db = await DatabaseService.database;
    await db.execute('DROP TRIGGER unlink_planning_patient');
    await db.execute('DROP INDEX idx_planning_patient');
    await db.execute(
      'ALTER TABLE planning_appointments DROP COLUMN patient_id',
    );
    await db.setVersion(32);
    await db.insert('planning_appointments', {
      'appointment_id': 'old',
      'title': 'Ancien',
      'appointment_date': '2026-10-09',
      'start_minute': 540,
      'end_minute': 585,
      'notes': 'Conserver',
      'color_argb': 0xFFB2DFDB,
    });
    await DatabaseService.reopenDatabase();
    final repository = PlanningRepository(
      database: () => DatabaseService.database,
    );
    final old = (await repository.listAll()).single;
    expect(old.patientId, isNull);
    expect(old.notes, 'Conserver');
    final migrated = await DatabaseService.database;
    for (final id in ['p1', 'p2']) {
      await migrated.insert('patients', {
        'patient_id': id,
        'last_name': 'Dupont',
        'first_name': 'Élodie',
        'birth_date': id == 'p1' ? '1980-01-01' : '1990-02-02',
        'created_at': 1,
      });
    }
    expect(
      (await repository.searchPatients('dupont 1980')).single.patientId,
      'p1',
    );
    final linked = PlanningAppointment.fromMap({
      ...old.toMap(),
      'patient_id': 'p1',
    });
    await repository.update(linked);
    await DatabaseService.reopenDatabase();
    var loaded = (await repository.listAll()).single;
    expect(loaded.patientId, 'p1');
    expect(loaded.patientLabel, 'Dupont Élodie');
    final event = planningCalendarEvent(loaded);
    final shifted = shiftPlanningEvent(event, minuteDelta: 30, dayDelta: 1);
    final moved = planningAppointmentFromCalendar(
      shifted,
      id: planningEventId(shifted.event)!,
    );
    await repository.update(moved);
    expect((await repository.listAll()).single.patientId, 'p1');
    await repository.delete(moved.id);
    await repository.insert(moved);
    expect((await repository.listAll()).single.patientId, 'p1');
    var activeDb = await DatabaseService.database;
    await activeDb.update(
      'patients',
      {'archived_at': 1},
      where: 'patient_id = ?',
      whereArgs: ['p1'],
    );
    expect((await repository.searchPatients('Dupont')).single.patientId, 'p2');
    expect(
      (await repository.listAll()).single.patientLabel,
      'Dupont Élodie (archivé)',
    );
    await activeDb.execute('PRAGMA foreign_keys = OFF');
    await activeDb.delete(
      'patients',
      where: 'patient_id = ?',
      whereArgs: ['p1'],
    );
    loaded = (await repository.listAll()).single;
    expect(loaded.patientId, isNull);
    expect(loaded.title, 'Ancien');
    await expectLater(repository.update(moved), throwsStateError);
    await repository.update(
      PlanningAppointment.fromMap({...loaded.toMap(), 'patient_id': 'p2'}),
    );
    await repository.update(
      PlanningAppointment.fromMap({...loaded.toMap(), 'patient_id': null}),
    );
    expect((await repository.listAll()).single.patientId, isNull);
    await repository.update(
      PlanningAppointment.fromMap({...loaded.toMap(), 'patient_id': 'p2'}),
    );
    await activeDb.execute('PRAGMA foreign_keys = ON');
    await activeDb.delete(
      'patients',
      where: 'patient_id = ?',
      whereArgs: ['p2'],
    );
    expect((await repository.listAll()).single.patientId, isNull);
  });
  test(
    'v33 migration retains RV and persists pauses through edits and reopen',
    () async {
      final db = await DatabaseService.database;
      await db.execute(
        'ALTER TABLE planning_appointments DROP COLUMN event_kind',
      );
      await db.setVersion(33);
      await db.insert('planning_appointments', {
        'appointment_id': 'old',
        'title': 'Ancien',
        'appointment_date': '2026-10-10',
        'start_minute': 540,
        'end_minute': 585,
        'notes': 'Garder',
        'color_argb': 0xFFB2DFDB,
      });
      await DatabaseService.reopenDatabase();
      final repository = PlanningRepository(
        database: () => DatabaseService.database,
      );
      final old = (await repository.listAll()).single;
      expect(old.isUnavailable, isFalse);
      expect(old.notes, 'Garder');
      final pause = PlanningAppointment(
        id: 'pause',
        title: 'Pause',
        date: old.date,
        startMinute: 720,
        endMinute: 780,
        isUnavailable: true,
      );
      await repository.insert(pause);
      final shifted = shiftPlanningEvent(
        planningCalendarEvent(pause),
        minuteDelta: 30,
      );
      final moved = planningAppointmentFromCalendar(
        shifted,
        id: planningEventId(shifted.event)!,
      );
      await repository.update(moved);
      await repository.delete(moved.id);
      await repository.insert(moved);
      await DatabaseService.reopenDatabase();
      final loaded = (await repository.listAll()).singleWhere(
        (item) => item.id == 'pause',
      );
      expect(loaded.isUnavailable, isTrue);
      expect(loaded.startMinute, 750);
      expect(loaded.patientId, isNull);
    },
  );
}
