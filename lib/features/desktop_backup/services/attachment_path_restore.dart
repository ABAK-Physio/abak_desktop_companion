import 'dart:io';
import '../../../generated/l10n.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<List<Map<String, Object?>>> snapshotAttachmentPaths(
  DatabaseExecutor db,
) => db.rawQuery(
  "SELECT d.document_id, d.file_path, e.patient_id FROM episode_documents d "
  "JOIN care_episodes e ON e.care_episode_id = d.case_id "
  "WHERE d.source = 'local_copy'",
);

/// Only ordinary attachments in this patient's restored Autre folder are rebased.
Future<void> restoreAttachmentPaths(
  DatabaseExecutor db, {
  required String patientId,
  required String sourceFolder,
  required String destinationFolder,
  required String archivedFolder,
  required List<Map<String, Object?>> originalAttachments,
}) async {
  final sourceOther = p.normalize(p.join(sourceFolder, 'Autre'));
  final rows = originalAttachments.where(
    (row) => row['patient_id'] == patientId,
  );
  for (final row in rows) {
    final original = row['file_path'] as String;
    if (!p.isAbsolute(original) ||
        !p.isWithin(sourceOther, p.normalize(original))) {
      continue;
    }
    final relative = p.relative(
      p.normalize(original),
      from: p.normalize(sourceFolder),
    );
    final staged = File(p.join(archivedFolder, relative));
    if (!await staged.exists()) {
      throw FileSystemException(
        S.current.episodeDocuments_fileNotFound,
        original,
      );
    }
    await db.update(
      'episode_documents',
      {'file_path': p.join(destinationFolder, relative)},
      where: "document_id = ? AND source = 'local_copy'",
      whereArgs: [row['document_id']],
    );
  }
}
