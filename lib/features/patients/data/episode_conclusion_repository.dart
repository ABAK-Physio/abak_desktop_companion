import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../models/episode_conclusion.dart';

class EpisodeConclusionRepository {
  final Uuid _uuid = const Uuid();

  Future<EpisodeConclusion?> getActiveByCaseId(String caseId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'episode_conclusions',
      where: 'case_id = ? AND archived_at IS NULL',
      whereArgs: [caseId],
      orderBy: 'updated_at DESC, created_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return EpisodeConclusion.fromMap(rows.first);
  }

  Future<EpisodeConclusion> upsertForCase({
    required String caseId,
    required String content,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await getActiveByCaseId(caseId);

    if (existing == null) {
      final conclusion = EpisodeConclusion(
        conclusionId: _uuid.v4(),
        caseId: caseId,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      await db.insert(
        'episode_conclusions',
        conclusion.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      return conclusion;
    }

    final updated = EpisodeConclusion(
      conclusionId: existing.conclusionId,
      caseId: existing.caseId,
      content: content,
      createdAt: existing.createdAt,
      updatedAt: now,
      archivedAt: existing.archivedAt,
    );

    await db.update(
      'episode_conclusions',
      updated.toMap(),
      where: 'conclusion_id = ?',
      whereArgs: [existing.conclusionId],
    );

    return updated;
  }

  Future<void> archive(String conclusionId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'episode_conclusions',
      {'archived_at': now, 'updated_at': now},
      where: 'conclusion_id = ?',
      whereArgs: [conclusionId],
    );
  }
}
