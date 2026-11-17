import 'dart:convert';
import 'dart:io';

import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Map<String, List<Map<String, Object?>>>> snapshot(Database db) async {
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' "
    "AND name NOT LIKE 'sqlite_%' ORDER BY name",
  );
  return {
    for (final table in tables)
      table['name'] as String: await db.query(table['name'] as String),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('ASUS v16 with existing v49 schema upgrades without changing records', () async {
    final directory = await Directory.systemTemp.createTemp('abak_asus_v16_');
    Database? active;
    try {
      final path = '${directory.path}/asus-synthetic.db';
      final fixture = jsonDecode(await File(
        'test/fixtures/database_asus_v16_schema.json',
      ).readAsString()) as Map<String, dynamic>;
      final old = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: fixture['user_version'] as int,
          onCreate: (db, version) async {
            for (final sql in fixture['statements'] as List<dynamic>) {
              await db.execute(sql as String);
            }
            // All records below are synthetic; no ASUS row is distributed.
            await db.insert('patients', {
              'patient_id': 'synthetic-patient',
              'last_name': 'Synthetique',
              'first_name': 'Patient',
              'created_at': 1,
            });
            await db.insert('practitioners', {
              'practitioner_id': 'synthetic-practitioner',
              'display_name': 'Praticien de test',
              'created_at': 1,
            });
            await db.insert('external_correspondents', {
              'correspondent_id': 'synthetic-correspondent',
              'last_name': 'Correspondant de test',
              'created_at': 1,
            });
            await db.insert('care_episodes', {
              'care_episode_id': 'synthetic-episode',
              'patient_id': 'synthetic-patient',
              'title': 'Episode conserve',
              'pathology_label': 'Test',
              'prescribing_correspondent_id': 'synthetic-correspondent',
              'created_at': 1,
            });
            await db.insert('care_episode_assessments', {
              'assessment_id': 'synthetic-assessment',
              'care_episode_id': 'synthetic-episode',
              'title': 'Bilan conserve',
              'content_json': '{"synthetic":"assessment"}',
              'docx_file_name': 'bilan-test.docx',
              'assessment_date': 2,
              'created_at': 2,
            });
            await db.insert('care_episode_reports', {
              'report_id': 'synthetic-report',
              'care_episode_id': 'synthetic-episode',
              'source_assessment_id': 'synthetic-assessment',
              'author_practitioner_id': 'synthetic-practitioner',
              'title': 'Rapport conserve',
              'content_json': '{"synthetic":"report"}',
              'docx_file_name': 'rapport-test.docx',
              'report_date': 3,
              'created_at': 3,
            });
          },
        ),
      );
      active = old;
      expect(await old.getVersion(), 16);
      final before = await snapshot(old);
      final schema = await old.rawQuery(
        'SELECT type,name,tbl_name,sql FROM sqlite_master ORDER BY type,name',
      );
      await old.close();
      active = null;

      // Exercise the actual upgrade, including the pre-existing correspondence
      // table and medical journal triggers, on this disposable database only.
      final upgraded = await DatabaseService.openDatabaseFile(
        path,
        factory: databaseFactoryFfi,
      );
      active = upgraded;
      expect(await upgraded.getVersion(), DatabaseService.schemaVersion);
      expect(await snapshot(upgraded), before);
      // Seule évolution attendue : la politique de rétention des sauvegardes.
      final expectedSchema = schema.map((entry) {
        final expected = Map<String, Object?>.from(entry);
        if (entry['type'] == 'table' &&
            entry['name'] == 'desktop_backups') {
          expected['sql'] = (entry['sql'] as String).replaceFirst(
            RegExp(r'\)\s*$'),
            ", retention_policy TEXT NOT NULL DEFAULT 'protected')",
          );
        }
        return expected;
      }).toList();

      expect(
        await upgraded.rawQuery(
          'SELECT type,name,tbl_name,sql FROM sqlite_master ORDER BY type,name',
        ),
        expectedSchema,
      );

      final backupColumns =
      await upgraded.rawQuery('PRAGMA table_info(desktop_backups)');
      final retentionColumn = backupColumns.singleWhere(
            (column) => column['name'] == 'retention_policy',
      );
      expect(retentionColumn['type'], 'TEXT');
      expect(retentionColumn['notnull'], 1);
      expect(retentionColumn['dflt_value'], "'protected'");
      expect(await upgraded.rawQuery('PRAGMA integrity_check'), [
        {'integrity_check': 'ok'},
      ]);
      expect(await upgraded.rawQuery('PRAGMA foreign_key_check'), isEmpty);
      await upgraded.close();
      active = null;

      final reopened = await DatabaseService.openDatabaseFile(
        path,
        factory: databaseFactoryFfi,
      );
      active = reopened;
      expect(await reopened.getVersion(), DatabaseService.schemaVersion);
      expect(await snapshot(reopened), before);
    } finally {
      if (active != null && active.isOpen) await active.close();
      await directory.delete(recursive: true);
    }
  });
}
