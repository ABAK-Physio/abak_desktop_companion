import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// One durable journal for the product pathway. No send is enabled by migration.
Future<void> createDocumentJournalTables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS document_holds (
    version_id TEXT PRIMARY KEY, held INTEGER NOT NULL CHECK(held IN (0,1)),
    revision INTEGER NOT NULL, changed_at INTEGER NOT NULL)''');
  await db.execute('''CREATE TABLE IF NOT EXISTS document_attempts (
    attempt_id TEXT PRIMARY KEY, document_id TEXT NOT NULL UNIQUE,
    version_id TEXT NOT NULL, patient_id TEXT NOT NULL, pdf_hash TEXT NOT NULL,
    approval_id TEXT NOT NULL, control_run_id TEXT NOT NULL,
    snapshot_hash TEXT NOT NULL, payload_hash TEXT NOT NULL,
    mode TEXT NOT NULL CHECK(mode='simulation'), started_at INTEGER NOT NULL,
    UNIQUE(patient_id,pdf_hash))''');
  await db.execute('''CREATE TABLE IF NOT EXISTS document_attempt_results (
    attempt_id TEXT PRIMARY KEY REFERENCES document_attempts(attempt_id),
    outcome TEXT NOT NULL CHECK(outcome IN ('accepted','rejected','indeterminate')),
    detail TEXT NOT NULL, evidence_json TEXT NOT NULL, evidence_hash TEXT NOT NULL,
    completed_at INTEGER NOT NULL)''');
  await db.execute(
    '''CREATE TABLE IF NOT EXISTS document_restore_barriers (
    barrier_id TEXT PRIMARY KEY, reason TEXT NOT NULL, created_at INTEGER NOT NULL)''',
  );
  await db.execute('''CREATE TABLE IF NOT EXISTS document_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT, document_id TEXT,
    version_id TEXT, kind TEXT NOT NULL, reference_id TEXT NOT NULL,
    detail TEXT NOT NULL, created_at INTEGER NOT NULL,
    UNIQUE(kind,reference_id))''');
  for (final table in [
    'attempts',
    'attempt_results',
    'restore_barriers',
    'events',
  ]) {
    for (final verb in ['UPDATE', 'DELETE']) {
      await db.execute(
        '''CREATE TRIGGER IF NOT EXISTS journal_${table}_${verb.toLowerCase()}
        BEFORE $verb ON document_$table BEGIN
        SELECT RAISE(ABORT,'Journal DMP immuable'); END''',
      );
    }
  }
  // INSERT OR REPLACE must not erase a receipt even with recursive_triggers off.
  for (final e in {
    'attempts': 'attempt_id',
    'attempt_results': 'attempt_id',
    'restore_barriers': 'barrier_id',
    'events': 'event_id',
  }.entries) {
    await db.execute('''CREATE TRIGGER IF NOT EXISTS journal_${e.key}_replace
      BEFORE INSERT ON document_${e.key}
      WHEN EXISTS(SELECT 1 FROM document_${e.key} WHERE ${e.value}=NEW.${e.value})
      BEGIN SELECT RAISE(ABORT,'Écriture existante dans le journal'); END''');
  }
  await db.execute(
    '''CREATE TRIGGER IF NOT EXISTS journal_attempt_guard
    BEFORE INSERT ON document_attempts WHEN
      EXISTS(SELECT 1 FROM document_restore_barriers) OR
      EXISTS(SELECT 1 FROM document_attempts WHERE document_id=NEW.document_id
        OR (patient_id=NEW.patient_id AND pdf_hash=NEW.pdf_hash))
    BEGIN SELECT RAISE(ABORT,'Renvoi bloqué : tentative ou restauration'); END''',
  );
  await db.execute('''CREATE TRIGGER IF NOT EXISTS journal_hold_delete
    BEFORE DELETE ON document_holds BEGIN
    SELECT RAISE(ABORT,'La retenue doit être conservée'); END''');
  await db.execute('''CREATE TRIGGER IF NOT EXISTS journal_result_guard
    BEFORE INSERT ON document_attempt_results WHEN
      NOT EXISTS(SELECT 1 FROM document_attempts WHERE attempt_id=NEW.attempt_id)
    BEGIN SELECT RAISE(ABORT,'Tentative absente'); END''');
  await db.execute('''CREATE TRIGGER IF NOT EXISTS journal_hold_revision
    BEFORE UPDATE ON document_holds WHEN NEW.version_id!=OLD.version_id OR NEW.revision!=OLD.revision+1
    BEGIN SELECT RAISE(ABORT,'Révision de retenue invalide'); END''');
  await db.execute('''CREATE TRIGGER IF NOT EXISTS journal_hold_replace
    BEFORE INSERT ON document_holds WHEN EXISTS(SELECT 1 FROM document_holds WHERE version_id=NEW.version_id)
    BEGIN SELECT RAISE(ABORT,'Retenue existante'); END''');
  final sources = <String, List<String>>{
    'document_medical_approvals': [
      'NEW.document_id',
      'NEW.version_id',
      "'medical_approved'",
      'NEW.approval_id',
      "'Validation médicale enregistrée'",
      'NEW.approved_at',
    ],
    'document_approval_invalidations': [
      "(SELECT document_id FROM document_medical_approvals WHERE approval_id=NEW.approval_id)",
      "(SELECT version_id FROM document_medical_approvals WHERE approval_id=NEW.approval_id)",
      "'medical_invalidated'",
      'NEW.approval_id',
      'NEW.reason',
      'NEW.invalidated_at',
    ],
    'document_control_results': [
      "(SELECT v.document_id FROM episode_document_versions v JOIN document_control_runs r ON v.version_id=r.version_id WHERE r.run_id=NEW.run_id)",
      "(SELECT version_id FROM document_control_runs WHERE run_id=NEW.run_id)",
      "'controls_recorded'",
      'NEW.run_id',
      "'Résultats des contrôles locaux conservés'",
      'NEW.completed_at',
    ],
    'document_control_invalidations': [
      "(SELECT v.document_id FROM episode_document_versions v JOIN document_control_runs r ON v.version_id=r.version_id WHERE r.run_id=NEW.run_id)",
      "(SELECT version_id FROM document_control_runs WHERE run_id=NEW.run_id)",
      "'controls_invalidated'",
      'NEW.run_id',
      'NEW.reason',
      'NEW.invalidated_at',
    ],
    'document_attempts': [
      'NEW.document_id',
      'NEW.version_id',
      "'attempt_reserved'",
      'NEW.attempt_id',
      "'Tentative fictive réservée ; tout renvoi est bloqué'",
      'NEW.started_at',
    ],
    'document_attempt_results': [
      "(SELECT document_id FROM document_attempts WHERE attempt_id=NEW.attempt_id)",
      "(SELECT version_id FROM document_attempts WHERE attempt_id=NEW.attempt_id)",
      "'attempt_result'",
      'NEW.attempt_id',
      'NEW.detail',
      'NEW.completed_at',
    ],
    'document_restore_barriers': [
      'NULL',
      'NULL',
      "'restored'",
      'NEW.barrier_id',
      'NEW.reason',
      'NEW.created_at',
    ],
  };
  for (final e in sources.entries) {
    await db.execute('''CREATE TRIGGER IF NOT EXISTS journal_${e.key}
      AFTER INSERT ON ${e.key} BEGIN INSERT INTO document_events
      (document_id,version_id,kind,reference_id,detail,created_at)
      VALUES(${e.value.join(',')}); END''');
    // Backfill historical receipts, without inventing new approvals or attempts.
    await db.execute('''INSERT OR IGNORE INTO document_events
      (document_id,version_id,kind,reference_id,detail,created_at)
      SELECT ${e.value.map((s) => s.replaceAll('NEW.', 'src.')).join(',')}
      FROM ${e.key} src''');
  }
  for (final verb in ['INSERT', 'UPDATE']) {
    await db.execute(
      '''CREATE TRIGGER IF NOT EXISTS journal_hold_${verb.toLowerCase()}
      AFTER $verb ON document_holds BEGIN INSERT INTO document_events
      (document_id,version_id,kind,reference_id,detail,created_at)
      SELECT document_id,NEW.version_id,'hold',NEW.version_id || ':' || NEW.revision,
      CASE WHEN NEW.held=1 THEN 'Traitement retenu' ELSE 'Retenue levée ; aucun envoi déclenché' END,
      NEW.changed_at FROM episode_document_versions WHERE version_id=NEW.version_id; END''',
    );
  }
}
