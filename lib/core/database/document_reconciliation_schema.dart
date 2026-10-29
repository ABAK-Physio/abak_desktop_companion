import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Reconciliation adds observations; it cannot rewrite a result or release a
/// reservation/restore barrier. Historical journal guards remain authoritative.
Future<void> createDocumentReconciliationTables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS document_reconciliations (
    review_id TEXT PRIMARY KEY, target_key TEXT NOT NULL,
    document_id TEXT NOT NULL, version_id TEXT NOT NULL,
    attempt_id TEXT, previous_hash TEXT NOT NULL,
    source_hash TEXT NOT NULL, restore_hash TEXT NOT NULL,
    evidence_json TEXT NOT NULL, evidence_hash TEXT NOT NULL,
    outcome TEXT NOT NULL CHECK(outcome IN ('accepted','rejected','indeterminate')),
    detail TEXT NOT NULL, reviewed_at INTEGER NOT NULL,
    UNIQUE(target_key,source_hash,restore_hash),
    FOREIGN KEY(version_id) REFERENCES episode_document_versions(version_id),
    FOREIGN KEY(attempt_id) REFERENCES document_attempts(attempt_id))''');
  for (final verb in ['UPDATE', 'DELETE']) {
    await db.execute(
      '''CREATE TRIGGER IF NOT EXISTS reconciliation_${verb.toLowerCase()}
      BEFORE $verb ON document_reconciliations BEGIN
      SELECT RAISE(ABORT,'Examen de réconciliation immuable'); END''',
    );
  }
  await db.execute(
    '''CREATE TRIGGER IF NOT EXISTS reconciliation_insert
    BEFORE INSERT ON document_reconciliations WHEN
      EXISTS(SELECT 1 FROM document_reconciliations WHERE review_id=NEW.review_id
        OR (target_key=NEW.target_key AND source_hash=NEW.source_hash AND restore_hash=NEW.restore_hash))
      OR NOT EXISTS(SELECT 1 FROM episode_document_versions
        WHERE version_id=NEW.version_id AND document_id=NEW.document_id)
      OR (NEW.attempt_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM document_attempts
        WHERE attempt_id=NEW.attempt_id AND version_id=NEW.version_id AND document_id=NEW.document_id))
      OR NEW.previous_hash != COALESCE((SELECT evidence_hash FROM document_reconciliations
        WHERE target_key=NEW.target_key ORDER BY rowid DESC LIMIT 1),'')
    BEGIN SELECT RAISE(ABORT,'Réconciliation existante, orpheline ou périmée'); END''',
  );
  await db.execute('''CREATE TRIGGER IF NOT EXISTS reconciliation_journal
    AFTER INSERT ON document_reconciliations BEGIN INSERT INTO document_events
    (document_id,version_id,kind,reference_id,detail,created_at)
    VALUES(NEW.document_id,NEW.version_id,'reconciliation',NEW.review_id,
      NEW.detail,NEW.reviewed_at); END''');
}
