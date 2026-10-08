import 'dart:io';

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
    expect(await db.getVersion(), 32);
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
      expect(await db.getVersion(), 32);
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
}
