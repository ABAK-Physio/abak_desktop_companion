import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/database/database_service.dart';

class CareEpisodeDocumentEditDraftRepository {
  Future<String?> getContent({
    required String documentType,
    required String documentId,
  }) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_document_edit_drafts',
      columns: ['content_json'],
      where: 'document_type = ? AND document_id = ?',
      whereArgs: [documentType, documentId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['content_json'] as String;
  }

  Future<void> saveContent({
    required String documentType,
    required String documentId,
    required String contentJson,
  }) async {
    final db = await DatabaseService.database;

    await db.insert(
      'care_episode_document_edit_drafts',
      {
        'document_type': documentType,
        'document_id': documentId,
        'content_json': contentJson,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete({
    required String documentType,
    required String documentId,
  }) async {
    final db = await DatabaseService.database;

    await db.delete(
      'care_episode_document_edit_drafts',
      where: 'document_type = ? AND document_id = ?',
      whereArgs: [documentType, documentId],
    );
  }
}