import 'dart:io';

import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// This is a synthetic upgrade fixture, not an export of an ASUS/patient database.
// The frozen v28 SQL is independent of today's onCreate helpers. We remove the
// v24 correspondence table (created by the upgrade) and optionally remove four
// additive columns, then declare version 22 to exercise migrations 23 through 26.
const _columns = <String, Map<String, int>>{
  'care_episode_assessments': {'docx_file_name': 1},
  'care_episodes': {'prescribing_correspondent_id': 2},
  'care_episode_reports': {'author_practitioner_id': 4, 'docx_file_name': 8},
};

Future<Map<String, List<Map<String, Object?>>>> _snapshot(Database db) async {
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' "
    "AND name NOT LIKE 'sqlite_%' ORDER BY name",
  );
  return {
    for (final table in tables)
      table['name'] as String: await db.query(table['name'] as String),
  };
}

Future<void> _expectPreserved(
  Database db,
  Map<String, List<Map<String, Object?>>> before,
) async {
  for (final table in before.entries) {
    final after = await db.query(table.key);
    expect(after.length, table.value.length, reason: table.key);
    for (final row in table.value) {
      expect(
        after.any(
          (candidate) => row.entries.every(
            (entry) => candidate[entry.key] == entry.value,
          ),
        ),
        isTrue,
        reason: 'Historical values in ${table.key}',
      );
    }
  }
  for (final table in _columns.entries) {
    final info = await db.rawQuery('PRAGMA table_info(${table.key})');
    for (final column in table.value.keys) {
      expect(
        info.where((item) => item['name'] == column),
        hasLength(1),
        reason: '${table.key}.$column must exist exactly once',
      );
    }
  }
  expect(await db.rawQuery('PRAGMA integrity_check'), [
    {'integrity_check': 'ok'},
  ]);
  expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temporary;
  Database? connection;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('abak_legacy_columns_');
  });
  tearDown(() async {
    final db = connection;
    if (db != null && db.isOpen) await db.close();
    connection = null;
    await temporary.delete(recursive: true);
  });

  // None present, each individual column present, then all four present.
  for (final presentColumns in [0, 1, 2, 4, 8, 15]) {
    test(
      'v22 upgrade preserves data with legacy column mask $presentColumns',
      () async {
        final path = '${temporary.path}/legacy.db';
        final old = await databaseFactoryFfi.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: 22,
            onCreate: (db, version) async {
              final schema = await File(
                'test/fixtures/database_v28.sql',
              ).readAsString();
              for (final statement in schema.split(';')) {
                if (statement.trim().isNotEmpty) await db.execute(statement);
              }
              await db.execute('DROP TABLE external_correspondents');
              for (final table in _columns.entries) {
                for (final column in table.value.entries) {
                  if ((presentColumns & column.value) == 0) {
                    await db.execute(
                      'ALTER TABLE ${table.key} DROP COLUMN ${column.key}',
                    );
                  }
                }
              }
              await db.insert('patients', {
                'patient_id': 'p-old',
                'last_name': 'Synthetique',
                'first_name': 'Patient',
                'created_at': 1,
              });
              await db.insert('practitioners', {
                'practitioner_id': 'pr-old',
                'display_name': 'Praticien de test',
                'created_at': 1,
              });
              await db.insert('care_episodes', {
                'care_episode_id': 'e-old',
                'patient_id': 'p-old',
                'title': 'Episode conserve',
                'pathology_label': 'Test de migration',
                'initial_report': 'Contenu historique du bilan',
                'created_at': 1,
                if ((presentColumns & 2) != 0)
                  'prescribing_correspondent_id': 'prescriber-old',
              });
              await db.insert('care_episode_assessments', {
                'assessment_id': 'a-old',
                'care_episode_id': 'e-old',
                'title': 'Bilan conserve',
                'content_json': '{"historical":"assessment"}',
                'assessment_date': 2,
                'created_at': 2,
                if ((presentColumns & 1) != 0)
                  'docx_file_name': 'bilan-historique.docx',
              });
              await db.insert('care_episode_reports', {
                'report_id': 'r-old',
                'care_episode_id': 'e-old',
                'source_assessment_id': 'a-old',
                'title': 'Rapport conserve',
                'content_json': '{"historical":"report"}',
                'report_date': 3,
                'created_at': 3,
                if ((presentColumns & 4) != 0)
                  'author_practitioner_id': 'pr-old',
                if ((presentColumns & 8) != 0)
                  'docx_file_name': 'rapport-historique.docx',
              });
              await db.insert('application_settings', {
                'setting_key': 'legacy-column-migration',
                'setting_value': 'conserver',
                'updated_at': 1,
              });
            },
          ),
        );
        connection = old;
        expect(await old.getVersion(), 22);
        final before = await _snapshot(old);
        await old.close();
        connection = null;

        final upgraded = await DatabaseService.openDatabaseFile(
          path,
          factory: databaseFactoryFfi,
        );
        connection = upgraded;
        expect(await upgraded.getVersion(), DatabaseService.schemaVersion);
        await _expectPreserved(upgraded, before);

        // Missing columns are added as NULL, without overwriting existing values.
        for (final table in _columns.entries) {
          final row = (await upgraded.query(table.key)).single;
          for (final column in table.value.entries) {
            if ((presentColumns & column.value) == 0) {
              expect(row[column.key], isNull);
            }
          }
        }
        await upgraded.close();
        connection = null;

        final reopened = await DatabaseService.openDatabaseFile(
          path,
          factory: databaseFactoryFfi,
        );
        connection = reopened;
        expect(await reopened.getVersion(), DatabaseService.schemaVersion);
        await _expectPreserved(reopened, before);
      },
    );
  }
}
