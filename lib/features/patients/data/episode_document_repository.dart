import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../models/episode_document.dart';

class EpisodeDocumentRepository {
  final Uuid _uuid = const Uuid();

  Future<List<EpisodeDocument>> getByCaseId(String caseId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'episode_documents',
      where: 'case_id = ? AND archived_at IS NULL',
      whereArgs: [caseId],
      orderBy: 'created_at DESC',
    );

    return rows.map(EpisodeDocument.fromMap).toList();
  }

  Future<EpisodeDocument?> getById(String documentId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'episode_documents',
      where: 'document_id = ?',
      whereArgs: [documentId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return EpisodeDocument.fromMap(rows.first);
  }

  Future<EpisodeDocument> create({
    required String caseId,
    required String title,
    required String filePath,
    String? mimeType,
    String? source,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final document = EpisodeDocument(
      documentId: _uuid.v4(),
      caseId: caseId,
      title: title,
      filePath: filePath,
      mimeType: mimeType,
      source: source,
      createdAt: now,
    );

    await db.insert(
      'episode_documents',
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return document;
  }

  Future<void> update({
    required String documentId,
    String? title,
    String? filePath,
    String? mimeType,
    String? source,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final values = <String, Object?>{'updated_at': now};

    if (title != null) {
      values['title'] = title;
    }

    if (filePath != null) {
      values['file_path'] = filePath;
    }

    if (mimeType != null) {
      values['mime_type'] = mimeType;
    }

    if (source != null) {
      values['source'] = source;
    }

    await db.update(
      'episode_documents',
      values,
      where: 'document_id = ?',
      whereArgs: [documentId],
    );
  }

  Future<void> archive(String documentId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'episode_documents',
      {'archived_at': now, 'updated_at': now},
      where: 'document_id = ?',
      whereArgs: [documentId],
    );
  }

  Future<void> deletePermanently(String documentId) async {
    final db = await DatabaseService.database;

    await db.delete(
      'episode_documents',
      where: 'document_id = ?',
      whereArgs: [documentId],
    );
  }

  Future<void> archiveByCaseId(String caseId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'episode_documents',
      {'archived_at': now, 'updated_at': now},
      where: 'case_id = ? AND archived_at IS NULL',
      whereArgs: [caseId],
    );
  }
}
