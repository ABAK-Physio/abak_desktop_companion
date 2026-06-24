import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/database/database_service.dart';
import '../models/desktop_clinical_episode.dart';

class DesktopClinicalEpisodeRepository {
  Future<DesktopClinicalEpisode?> getEpisodeById(
      String episodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_clinical_episodes',
      where: 'episode_id = ?',
      whereArgs: [episodeId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return DesktopClinicalEpisode.fromMap(rows.first);
  }

  Future<List<DesktopClinicalEpisode>> getEpisodesForPatient(
      String patientId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_clinical_episodes',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );

    return rows
        .map(DesktopClinicalEpisode.fromMap)
        .toList();
  }

  Future<List<DesktopClinicalEpisode>> getEpisodesForMobileCase(
      String caseId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_clinical_episodes',
      where: 'mobile_case_id = ?',
      whereArgs: [caseId],
      orderBy: 'created_at DESC',
    );

    return rows
        .map(DesktopClinicalEpisode.fromMap)
        .toList();
  }

  Future<void> upsertEpisode(
      DesktopClinicalEpisode episode,
      ) async {
    final db = await DatabaseService.database;

    await db.insert(
      'desktop_clinical_episodes',
      episode.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteEpisode(
      String episodeId,
      ) async {
    final db = await DatabaseService.database;

    await db.delete(
      'desktop_clinical_episodes',
      where: 'episode_id = ?',
      whereArgs: [episodeId],
    );
  }

  Future<int> countEpisodesForPatient(
      String patientId,
      ) async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM desktop_clinical_episodes
      WHERE patient_id = ?
      ''',
      [patientId],
    );

    return (result.first['total'] as int?) ?? 0;
  }
}