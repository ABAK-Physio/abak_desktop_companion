import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../models/episode_note.dart';

class EpisodeNoteRepository {
  final Uuid _uuid = const Uuid();

  Future<List<EpisodeNote>> getByCaseId(String caseId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'episode_notes',
      where: 'case_id = ? AND archived_at IS NULL',
      whereArgs: [caseId],
      orderBy: 'updated_at DESC, created_at DESC',
    );

    return rows.map(EpisodeNote.fromMap).toList();
  }

  Future<EpisodeNote?> getById(String noteId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'episode_notes',
      where: 'note_id = ?',
      whereArgs: [noteId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return EpisodeNote.fromMap(rows.first);
  }

  Future<EpisodeNote> create({
    required String caseId,
    required String title,
    required String content,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final note = EpisodeNote(
      noteId: _uuid.v4(),
      caseId: caseId,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      'episode_notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return note;
  }

  Future<void> update({
    required String noteId,
    required String title,
    required String content,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'episode_notes',
      {'title': title, 'content': content, 'updated_at': now},
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }

  Future<void> archive(String noteId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'episode_notes',
      {'archived_at': now, 'updated_at': now},
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }
}
