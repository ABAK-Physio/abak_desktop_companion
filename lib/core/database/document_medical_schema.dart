import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'practitioner_cps_schema.dart';

/// Additive schema. Never writes to identity or clinical source tables.
Future<void> createDocumentMedicalTables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS document_practice_contexts (
    context_id TEXT PRIMARY KEY, practitioner_id TEXT NOT NULL,
    revision INTEGER NOT NULL CHECK(revision > 0), data_json TEXT NOT NULL,
    updated_at INTEGER NOT NULL)''');
  await db.execute('''CREATE TABLE IF NOT EXISTS document_preparations (
    version_id TEXT PRIMARY KEY, revision INTEGER NOT NULL CHECK(revision > 0),
    data_json TEXT NOT NULL, updated_at INTEGER NOT NULL)''');
  await db.execute('''CREATE TABLE IF NOT EXISTS document_medical_approvals (
    approval_id TEXT PRIMARY KEY, version_id TEXT NOT NULL,
    document_id TEXT NOT NULL, patient_id TEXT NOT NULL, episode_id TEXT NOT NULL,
    author_id TEXT NOT NULL, validator_id TEXT NOT NULL, context_id TEXT NOT NULL,
    source_kind TEXT NOT NULL, source_id TEXT,
    snapshot_json TEXT NOT NULL, snapshot_hash TEXT NOT NULL,
    attestations_json TEXT NOT NULL, approved_at INTEGER NOT NULL)''');
  await db.execute('''CREATE INDEX IF NOT EXISTS idx_medical_approval_version
    ON document_medical_approvals(version_id, approved_at)''');
  await db.execute(
    '''CREATE TABLE IF NOT EXISTS document_approval_invalidations (
    approval_id TEXT PRIMARY KEY, reason TEXT NOT NULL, invalidated_at INTEGER NOT NULL)''',
  );
  for (final table in [
    'document_medical_approvals',
    'document_approval_invalidations',
  ]) {
    for (final action in ['UPDATE', 'DELETE']) {
      await db.execute(
        '''CREATE TRIGGER IF NOT EXISTS ${table}_no_${action.toLowerCase()}
        BEFORE $action ON $table BEGIN
        SELECT RAISE(ABORT,'Trace de validation medicale conservee'); END''',
      );
    }
  }
  await db.execute('''CREATE TABLE IF NOT EXISTS document_medical_changes (
    change_id INTEGER PRIMARY KEY AUTOINCREMENT, source_table TEXT NOT NULL,
    source_id TEXT NOT NULL)''');
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_medical_changes_source ON document_medical_changes(source_table, source_id, change_id)',
  );
  // A change followed by a reversal must not resurrect an earlier approval.
  final dependencies = <String, String>{
    'patients': 'a.patient_id = OLD.patient_id',
    'patient_fr_health_identity': 'a.patient_id = OLD.patient_id',
    'care_episodes': 'a.episode_id = OLD.care_episode_id',
    'episode_documents': 'a.document_id = OLD.document_id',
    'practitioners':
        '(a.author_id = OLD.practitioner_id OR a.validator_id = OLD.practitioner_id)',
    'document_practice_contexts': 'a.context_id = OLD.context_id',
    'document_preparations': 'a.version_id = OLD.version_id',
    'care_episode_reports':
        "a.source_kind = 'report' AND a.source_id = OLD.report_id",
    'care_episode_assessments':
        "a.source_kind = 'assessment' AND a.source_id = OLD.assessment_id",
  };
  for (final entry in dependencies.entries) {
    final sourceColumn = <String, String>{
      'patients': 'patient_id',
      'patient_fr_health_identity': 'patient_id',
      'care_episodes': 'care_episode_id',
      'episode_documents': 'document_id',
      'practitioners': 'practitioner_id',
      'document_practice_contexts': 'context_id',
      'document_preparations': 'version_id',
      'care_episode_reports': 'report_id',
      'care_episode_assessments': 'assessment_id',
    }[entry.key]!;
    for (final action in ['INSERT', 'UPDATE', 'DELETE']) {
      final rowAlias = action == 'DELETE' ? 'OLD' : 'NEW';
      final condition = action == 'INSERT'
          ? entry.value.replaceAll('OLD.', 'NEW.')
          : entry.value;
      await db.execute(
        '''CREATE TRIGGER IF NOT EXISTS medical_${entry.key}_${action.toLowerCase()}
        AFTER $action ON ${entry.key} BEGIN
        INSERT INTO document_medical_changes(source_table,source_id) VALUES('${entry.key}', $rowAlias.$sourceColumn);
        INSERT OR IGNORE INTO document_approval_invalidations
        SELECT a.approval_id, 'Source modifiée : ${entry.key}',
          CAST(strftime('%s','now') AS INTEGER)*1000
        FROM document_medical_approvals a WHERE $condition; END''',
      );
    }
  }
  await db.execute(
    '''CREATE TRIGGER IF NOT EXISTS medical_new_pdf_version
    AFTER INSERT ON episode_document_versions BEGIN
    INSERT OR IGNORE INTO document_approval_invalidations
    SELECT approval_id, 'Nouvelle version du PDF', CAST(strftime('%s','now') AS INTEGER)*1000
    FROM document_medical_approvals
    WHERE document_id = NEW.document_id AND version_id <> NEW.version_id; END''',
  );
  await createPractitionerCpsTables(db);
}
