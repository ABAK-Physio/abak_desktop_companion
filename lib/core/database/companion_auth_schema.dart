import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> createCompanionAuthTables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS companion_personal_codes (
    practitioner_id TEXT PRIMARY KEY NOT NULL REFERENCES practitioners(practitioner_id),
    algorithm TEXT NOT NULL, iterations INTEGER NOT NULL CHECK(iterations > 0),
    salt TEXT NOT NULL, verifier TEXT NOT NULL, updated_at INTEGER NOT NULL
  )''');
  await db.execute('''CREATE TABLE IF NOT EXISTS companion_auth_attempts (
    scope TEXT PRIMARY KEY NOT NULL,
    failures INTEGER NOT NULL DEFAULT 0 CHECK(failures BETWEEN 0 AND 4),
    blocked_until INTEGER NOT NULL DEFAULT 0
  )''');
  // No free-form payload: codes and recovery keys must never enter this log.
  await db.execute('''CREATE TABLE IF NOT EXISTS companion_access_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    occurred_at INTEGER NOT NULL, action TEXT NOT NULL,
    actor_practitioner_id TEXT, target_practitioner_id TEXT,
    session_id TEXT, patient_id TEXT, reason TEXT, previous_practitioner_id TEXT
  )''');
  await db.execute('''CREATE INDEX IF NOT EXISTS companion_access_events_date
    ON companion_access_events(occurred_at)''');
  await db.execute(
    '''CREATE TRIGGER IF NOT EXISTS companion_admin_no_archive
    BEFORE UPDATE OF archived_at ON practitioners
    WHEN NEW.archived_at IS NOT NULL AND EXISTS (
      SELECT 1 FROM companion_practitioner_access
      WHERE practitioner_id = NEW.practitioner_id AND is_administrator = 1)
    BEGIN SELECT RAISE(ABORT, 'Retirez le statut administrateur avant archivage'); END''',
  );
}

/// Upgrade only the journal; no clinical row or document author is changed.
Future<void> migrateCompanionPatientJournal(DatabaseExecutor db) async {
  final columns = (await db.rawQuery(
    'PRAGMA table_info(companion_access_events)',
  )).map((row) => row['name']).toSet();
  for (final name in ['patient_id', 'reason', 'previous_practitioner_id']) {
    if (!columns.contains(name)) {
      await db.execute(
        'ALTER TABLE companion_access_events ADD COLUMN $name TEXT',
      );
    }
  }
}

Future<void> createCompanionRecoveryTable(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS companion_recovery_key (
    singleton INTEGER PRIMARY KEY CHECK(singleton = 1),
    algorithm TEXT NOT NULL, verifier TEXT NOT NULL,
    created_at INTEGER NOT NULL, created_by TEXT NOT NULL
  )''');
}
