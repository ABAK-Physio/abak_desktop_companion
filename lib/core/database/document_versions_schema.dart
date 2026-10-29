import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Additive migration: legacy pieces keep their paths/MIME and receive no approval.
Future<void> createDocumentVersionsTable(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS episode_document_versions (
    version_id TEXT PRIMARY KEY,
    document_id TEXT NOT NULL,
    patient_id TEXT NOT NULL,
    episode_id TEXT NOT NULL,
    sequence_number INTEGER NOT NULL CHECK(sequence_number > 0),
    previous_version_id TEXT NULL,
    relative_path TEXT NOT NULL UNIQUE,
    sha256 TEXT NOT NULL CHECK(length(sha256) = 64),
    byte_size INTEGER NOT NULL CHECK(byte_size > 0),
    mime_type TEXT NOT NULL CHECK(mime_type = 'application/pdf'),
    page_count INTEGER NOT NULL CHECK(page_count > 0),
    source_kind TEXT NOT NULL CHECK(source_kind IN ('external','report','assessment','legacy_piece')),
    source_id TEXT NULL,
    source_revision TEXT NULL,
    captured_at INTEGER NOT NULL,
    UNIQUE(document_id, sequence_number),
    FOREIGN KEY(document_id) REFERENCES episode_documents(document_id) ON DELETE RESTRICT,
    FOREIGN KEY(previous_version_id) REFERENCES episode_document_versions(version_id) ON DELETE RESTRICT
  )''');
  await db.execute(
    '''CREATE TRIGGER IF NOT EXISTS document_versions_no_update
    BEFORE UPDATE ON episode_document_versions BEGIN
    SELECT RAISE(ABORT, 'Une version PDF figee ne peut pas etre modifiee'); END''',
  );
  await db.execute('''CREATE TRIGGER IF NOT EXISTS document_versions_no_delete
    BEFORE DELETE ON episode_document_versions BEGIN
    SELECT RAISE(ABORT, 'Une version PDF doit etre conservee'); END''');
  // Effective even on historical connections with foreign_keys disabled.
  for (final entry in <String, String>{
    'episode_documents': 'document_id',
    'care_episodes': 'care_episode_id',
    'patients': 'patient_id',
  }.entries) {
    final column = entry.key == 'care_episodes' ? 'episode_id' : entry.value;
    await db.execute(
      '''CREATE TRIGGER IF NOT EXISTS ${entry.key}_keep_pdf_versions
      BEFORE DELETE ON ${entry.key}
      WHEN EXISTS (SELECT 1 FROM episode_document_versions WHERE $column = OLD.${entry.value})
      BEGIN SELECT RAISE(ABORT, 'Des versions PDF sont conservees : archiver plutot que supprimer'); END''',
    );
  }
}
