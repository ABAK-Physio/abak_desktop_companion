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

  Future<void> deleteReport(String reportId) async {
    final db = await DatabaseService.database;

    await db.delete(
      'care_episode_reports',
      where: 'report_id = ? AND archived_at IS NOT NULL',
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

  Future<Set<String>> getSelectedTestExoIds(
      String reportId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_report_tests',
      columns: ['exo_id'],
      where: 'report_id = ?',
      whereArgs: [reportId],
    );

    return rows
        .map((row) => row['exo_id']?.toString() ?? '')
        .where((exoId) => exoId.isNotEmpty)
        .toSet();
  }

  Future<void> setTestIncluded({
    required String reportId,
    required String exoId,
    required bool included,
  }) async {
    final db = await DatabaseService.database;

    if (included) {
      await db.insert(
        'care_episode_report_tests',
        {
          'report_id': reportId,
          'exo_id': exoId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return;
    }

    await db.delete(
      'care_episode_report_tests',
      where: 'report_id = ? AND exo_id = ?',
      whereArgs: [reportId, exoId],
    );
  }

  Future<void> replaceSelectedTests({
    required String reportId,
    required Set<String> exoIds,
  }) async {
    final db = await DatabaseService.database;

    await db.transaction((transaction) async {
      await transaction.delete(
        'care_episode_report_tests',
        where: 'report_id = ?',
        whereArgs: [reportId],
      );

      for (final exoId in exoIds) {
        await transaction.insert(
          'care_episode_report_tests',
          {
            'report_id': reportId,
            'exo_id': exoId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  Future<Set<String>> getSelectedNoteIds(
      String reportId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_report_notes',
      columns: ['note_id'],
      where: 'report_id = ?',
      whereArgs: [reportId],
    );

    return rows
        .map((row) => row['note_id']?.toString() ?? '')
        .where((noteId) => noteId.isNotEmpty)
        .toSet();
  }

  Future<void> setNoteIncluded({
    required String reportId,
    required String noteId,
    required bool included,
  }) async {
    final db = await DatabaseService.database;

    if (included) {
      await db.insert(
        'care_episode_report_notes',
        {
          'report_id': reportId,
          'note_id': noteId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return;
    }

    await db.delete(
      'care_episode_report_notes',
      where: 'report_id = ? AND note_id = ?',
      whereArgs: [reportId, noteId],
    );
  }

  Future<void> replaceSelectedNotes({
    required String reportId,
    required Set<String> noteIds,
  }) async {
    final db = await DatabaseService.database;

    await db.transaction((transaction) async {
      await transaction.delete(
        'care_episode_report_notes',
        where: 'report_id = ?',
        whereArgs: [reportId],
      );

      for (final noteId in noteIds) {
        await transaction.insert(
          'care_episode_report_notes',
          {
            'report_id': reportId,
            'note_id': noteId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }
}
