import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Public business data only. No PIN, private key or live session is persisted.
Future<void> createPractitionerCpsTables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS practitioner_cps_profiles (
    practitioner_id TEXT PRIMARY KEY REFERENCES practitioners(practitioner_id),
    national_id TEXT NOT NULL UNIQUE,
    profile_json TEXT NOT NULL, profile_hash TEXT NOT NULL,
    read_at INTEGER NOT NULL, revision INTEGER NOT NULL CHECK(revision > 0),
    provenance TEXT NOT NULL CHECK(provenance = 'cps_local_read'))''');
  for (final action in ['INSERT', 'UPDATE', 'DELETE']) {
    final row = action == 'DELETE' ? 'OLD' : 'NEW';
    await db.execute(
      '''CREATE TRIGGER IF NOT EXISTS medical_cps_${action.toLowerCase()}
      AFTER $action ON practitioner_cps_profiles BEGIN
      INSERT INTO document_medical_changes(source_table,source_id)
        VALUES('practitioner_cps_profiles', $row.practitioner_id);
      INSERT OR IGNORE INTO document_approval_invalidations
        SELECT approval_id, 'Données professionnelles CPS actualisées',
        CAST(strftime('%s','now') AS INTEGER)*1000
        FROM document_medical_approvals
        WHERE author_id=$row.practitioner_id OR validator_id=$row.practitioner_id;
      END''',
    );
  }
  await createPractitionerCpsDatesTable(db);
}

/// Complements declared by the user, kept separate from the card reading.
Future<void> createPractitionerCpsDatesTable(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS practitioner_cps_dates (
    practitioner_id TEXT PRIMARY KEY REFERENCES practitioner_cps_profiles(practitioner_id),
    profile_hash TEXT NOT NULL, read_at INTEGER NOT NULL,
    issue_date TEXT, exercise_starts_json TEXT NOT NULL,
    revision INTEGER NOT NULL CHECK(revision > 0), updated_at INTEGER NOT NULL,
    provenance TEXT NOT NULL CHECK(provenance = 'user_declared'))''');
  for (final action in ['INSERT', 'UPDATE', 'DELETE']) {
    final row = action == 'DELETE' ? 'OLD' : 'NEW';
    await db.execute(
      '''CREATE TRIGGER IF NOT EXISTS medical_cps_dates_${action.toLowerCase()}
      AFTER $action ON practitioner_cps_dates BEGIN
      INSERT INTO document_medical_changes(source_table,source_id)
        VALUES('practitioner_cps_dates', $row.practitioner_id);
      INSERT OR IGNORE INTO document_approval_invalidations
        SELECT approval_id, 'Dates professionnelles déclarées actualisées',
        CAST(strftime('%s','now') AS INTEGER)*1000
        FROM document_medical_approvals
        WHERE author_id=$row.practitioner_id OR validator_id=$row.practitioner_id;
      END''',
    );
  }
}
