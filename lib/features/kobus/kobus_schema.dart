import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> createKobusTables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS kobus_runs (
    run_id TEXT PRIMARY KEY, zip_name TEXT NOT NULL, started_at INTEGER NOT NULL,
    finished_at INTEGER, status TEXT NOT NULL, temporary_path TEXT)''');
  await db.execute('''CREATE TABLE IF NOT EXISTS kobus_items (
    item_id TEXT PRIMARY KEY, run_id TEXT NOT NULL, source_path TEXT NOT NULL,
    shared INTEGER NOT NULL, practitioner TEXT, identity_label TEXT NOT NULL,
    status TEXT NOT NULL, reason TEXT NOT NULL, warnings TEXT NOT NULL,
    patient_id TEXT, created_patient INTEGER NOT NULL DEFAULT 0,
    storage_path TEXT, FOREIGN KEY(run_id) REFERENCES kobus_runs(run_id))''');
  // Retain associations on deletion, as for patient_document_folders.
  // Archive deletion/reassignment requires a separate lifecycle feature.
  await db.execute('''CREATE TABLE IF NOT EXISTS kobus_archives (
    archive_id TEXT PRIMARY KEY, patient_id TEXT NOT NULL, run_id TEXT NOT NULL,
    source_path TEXT NOT NULL, shared INTEGER NOT NULL, practitioner TEXT,
    storage_path TEXT NOT NULL UNIQUE, manifest_json TEXT NOT NULL,
    created_at INTEGER NOT NULL)''');
  await db.execute(
    'CREATE INDEX IF NOT EXISTS kobus_patient ON kobus_archives(patient_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS kobus_run_items ON kobus_items(run_id)',
  );
}
