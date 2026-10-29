import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Append-only evidence for the common product journal, including explicit DV1 steps.
Future<void> createDocumentChainTables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS document_chain_steps (
    step_id TEXT PRIMARY KEY, chain_id TEXT NOT NULL, document_id TEXT NOT NULL,
    version_id TEXT NOT NULL, phase TEXT NOT NULL,
    state TEXT NOT NULL CHECK(state IN ('passed','blocked','reserved','result')),
    detail TEXT NOT NULL, data_json TEXT NOT NULL, data_hash TEXT NOT NULL,
    created_at INTEGER NOT NULL)''');
  for (final verb in ['UPDATE', 'DELETE']) {
    await db.execute('''CREATE TRIGGER IF NOT EXISTS chain_${verb.toLowerCase()}
      BEFORE $verb ON document_chain_steps BEGIN
      SELECT RAISE(ABORT,'Preuve de chaîne DMP immuable'); END''');
  }
  await db.execute('''CREATE TRIGGER IF NOT EXISTS chain_replace
    BEFORE INSERT ON document_chain_steps WHEN EXISTS(
      SELECT 1 FROM document_chain_steps WHERE step_id=NEW.step_id)
    BEGIN SELECT RAISE(ABORT,'Preuve de chaîne DMP existante'); END''');
  await db.execute('''CREATE TRIGGER IF NOT EXISTS chain_journal
    AFTER INSERT ON document_chain_steps BEGIN INSERT INTO document_events
    (document_id,version_id,kind,reference_id,detail,created_at)
    VALUES(NEW.document_id,NEW.version_id,'chain_' || NEW.state,NEW.step_id,
      NEW.detail,NEW.created_at); END''');
}
