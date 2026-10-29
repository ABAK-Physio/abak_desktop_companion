import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> createDocumentControlsTables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS document_control_config (
    id INTEGER PRIMARY KEY CHECK(id=1), revision INTEGER NOT NULL,
    data_json TEXT NOT NULL, fingerprint TEXT NOT NULL)''');
  await db.execute('''CREATE TABLE IF NOT EXISTS document_control_runs (
    run_id TEXT PRIMARY KEY, version_id TEXT NOT NULL, approval_id TEXT NOT NULL,
    snapshot_hash TEXT NOT NULL, configuration_hash TEXT NOT NULL,
    configuration_revision INTEGER NOT NULL, directory TEXT NOT NULL,
    started_at INTEGER NOT NULL)''');
  await db.execute(
    '''CREATE TABLE IF NOT EXISTS document_control_results (
    run_id TEXT PRIMARY KEY, data_json TEXT NOT NULL, completed_at INTEGER NOT NULL)''',
  );
  await db.execute(
    '''CREATE TABLE IF NOT EXISTS document_control_invalidations (
    run_id TEXT PRIMARY KEY, reason TEXT NOT NULL, invalidated_at INTEGER NOT NULL)''',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS document_controls_version ON document_control_runs(version_id,started_at)',
  );
  for (final table in ['runs', 'results', 'invalidations']) {
    for (final verb in ['UPDATE', 'DELETE']) {
      await db.execute(
        '''CREATE TRIGGER IF NOT EXISTS controls_${table}_${verb.toLowerCase()}
        BEFORE $verb ON document_control_$table BEGIN
        SELECT RAISE(ABORT, 'Preuve de contrôle immuable'); END''',
      );
    }
  }
  await db.execute('''CREATE TRIGGER IF NOT EXISTS controls_medical_invalidation
    AFTER INSERT ON document_approval_invalidations BEGIN
    INSERT OR IGNORE INTO document_control_invalidations
      SELECT run_id, 'Validation médicale invalidée', NEW.invalidated_at
      FROM document_control_runs WHERE approval_id=NEW.approval_id; END''');
  for (final verb in ['UPDATE', 'DELETE']) {
    await db.execute(
      '''CREATE TRIGGER IF NOT EXISTS controls_config_${verb.toLowerCase()}
      AFTER $verb ON document_control_config BEGIN
      INSERT OR IGNORE INTO document_control_invalidations
        SELECT run_id, 'Configuration des contrôles modifiée',
        CAST(strftime('%s','now') AS INTEGER)*1000 FROM document_control_runs; END''',
    );
  }
}
