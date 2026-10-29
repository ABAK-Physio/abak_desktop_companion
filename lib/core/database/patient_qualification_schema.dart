import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Additive migration only. Existing identities acquire no new proof or status.
Future<void> createPatientQualificationTables(DatabaseExecutor db) async {
  final columns = (await db.rawQuery(
    'PRAGMA table_info(patient_fr_health_identity)',
  )).map((row) => row['name']).toSet();
  const additions = {
    'cnda_recipe_json': 'TEXT NULL',
    'used_last_name': 'TEXT NULL',
    'used_first_name': 'TEXT NULL',
    'first_birth_name': 'TEXT NULL',
    'birth_place_label': 'TEXT NULL',
    'beneficiary_number': 'TEXT NULL',
    'beneficiary_relationship': 'TEXT NULL',
    'beneficiary_quality_code': 'TEXT NULL',
    'identity_homonym': 'INTEGER NOT NULL DEFAULT 0',
    'identity_fictitious': 'INTEGER NOT NULL DEFAULT 0',
    // NULL preserves legacy interpretation. Zero explicitly invalidates a
    // previously retrieved INS after a change of strict identity traits.
    'ins_traits_current': 'INTEGER NULL',
  };
  for (final entry in additions.entries) {
    if (!columns.contains(entry.key)) {
      await db.execute(
        'ALTER TABLE patient_fr_health_identity '
        'ADD COLUMN ${entry.key} ${entry.value}',
      );
    }
  }
  await db.execute('''
    CREATE TABLE IF NOT EXISTS patient_vitale_readings (
      reading_id TEXT PRIMARY KEY,
      patient_id TEXT NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
      read_at INTEGER NOT NULL,
      recorded_at INTEGER NOT NULL,
      source TEXT NOT NULL CHECK(source = 'carte_vitale'),
      identity_json TEXT NOT NULL
    )
  ''');
  await db.execute(
    'CREATE INDEX IF NOT EXISTS patient_vitale_readings_patient '
    'ON patient_vitale_readings(patient_id, read_at)',
  );
  await db.execute('''
    CREATE TABLE IF NOT EXISTS patient_identity_events (
      event_id TEXT PRIMARY KEY,
      patient_id TEXT NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
      occurred_at INTEGER NOT NULL,
      event_kind TEXT NOT NULL,
      actor_id TEXT NULL,
      actor_name TEXT NULL,
      before_json TEXT NOT NULL,
      after_json TEXT NOT NULL
    )
  ''');
  await db.execute(
    'CREATE INDEX IF NOT EXISTS patient_identity_events_patient '
    'ON patient_identity_events(patient_id, occurred_at)',
  );
}
