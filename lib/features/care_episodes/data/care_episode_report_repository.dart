import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/database_service.dart';
import '../models/care_episode_report.dart';

class CareEpisodeReportRepository {
  Future<CareEpisodeReport?> getReportById(
      String reportId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_reports',
      where: 'report_id = ? AND archived_at IS NULL',
      whereArgs: [reportId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return CareEpisodeReport.fromMap(rows.first);
  }

  Future<CareEpisodeReport?> getDraftForEpisode(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_reports',
      where: '''
        care_episode_id = ?
        AND status = ?
        AND archived_at IS NULL
      ''',
      whereArgs: [careEpisodeId, 'draft'],
      orderBy: 'updated_at DESC, created_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return CareEpisodeReport.fromMap(rows.first);
  }

  Future<List<CareEpisodeReport>> getSavedForEpisode(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_reports',
      where: '''
        care_episode_id = ?
        AND status = ?
        AND archived_at IS NULL
      ''',
      whereArgs: [careEpisodeId, 'saved'],
      orderBy: 'report_date DESC, created_at DESC',
    );

    return rows.map(CareEpisodeReport.fromMap).toList();
  }

  Future<void> insertReport(
      CareEpisodeReport report,
      ) async {
    final db = await DatabaseService.database;

    await db.insert(
      'care_episode_reports',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateReport(
      CareEpisodeReport report,
      ) async {
    final db = await DatabaseService.database;

    await db.update(
      'care_episode_reports',
      report.toMap(),
      where: 'report_id = ?',
      whereArgs: [report.reportId],
    );
  }


  Future<List<CareEpisodeReport>> getArchivedForEpisode(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_reports',
      where: '''
        care_episode_id = ?
        AND archived_at IS NOT NULL
      ''',
      whereArgs: [careEpisodeId],
      orderBy: 'archived_at DESC',
    );

    return rows.map(CareEpisodeReport.fromMap).toList();
  }

  Future<void> restoreReport(String reportId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'care_episode_reports',
      {
        'archived_at': null,
        'updated_at': now,
      },
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
  }

  Future<void> archiveReport(String reportId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'care_episode_reports',
      {
        'archived_at': now,
        'updated_at': now,
      },
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
  }

  Future<int> getSavedCountForEpisode(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM care_episode_reports
      WHERE care_episode_id = ?
        AND status = ?
        AND archived_at IS NULL
      ''',
      [careEpisodeId, 'saved'],
    );

    return (result.first['count'] as int?) ?? 0;
  }
}
