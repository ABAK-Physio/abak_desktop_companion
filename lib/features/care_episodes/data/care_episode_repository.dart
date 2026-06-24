import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/database_service.dart';
import '../models/care_episode.dart';

class CareEpisodeRepository {
  Future<void> insertCareEpisode(
      CareEpisode episode,
      ) async {
    final db = await DatabaseService.database;

    await db.insert(
      'care_episodes',
      episode.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateCareEpisode(
      CareEpisode episode,
      ) async {
    final db = await DatabaseService.database;

    await db.update(
      'care_episodes',
      episode.toMap(),
      where: 'care_episode_id = ?',
      whereArgs: [episode.careEpisodeId],
    );
  }

  Future<void> archiveCareEpisode(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    await db.update(
      'care_episodes',
      {
        'archived_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'care_episode_id = ?',
      whereArgs: [careEpisodeId],
    );
  }

  Future<List<CareEpisode>> getEpisodesForPatient(
      String patientId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episodes',
      where: 'patient_id = ? AND archived_at IS NULL',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );

    return rows
        .map(CareEpisode.fromMap)
        .toList();
  }

  Future<CareEpisode?> getEpisodeById(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episodes',
      where: 'care_episode_id = ?',
      whereArgs: [careEpisodeId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return CareEpisode.fromMap(rows.first);
  }
}