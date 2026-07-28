import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/database_service.dart';
import '../models/care_episode_assessment.dart';

class CareEpisodeAssessmentRepository {
  Future<CareEpisodeAssessment?> getAssessmentById(
      String assessmentId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_assessments',
      where: 'assessment_id = ? AND archived_at IS NULL',
      whereArgs: [assessmentId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return CareEpisodeAssessment.fromMap(rows.first);
  }


  Future<CareEpisodeAssessment?> getDraftForEpisode(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_assessments',
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

    return CareEpisodeAssessment.fromMap(rows.first);
  }

  Future<List<CareEpisodeAssessment>> getSavedForEpisode(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_assessments',
      where: '''
        care_episode_id = ?
        AND status = ?
        AND archived_at IS NULL
      ''',
      whereArgs: [careEpisodeId, 'saved'],
      orderBy: 'assessment_date DESC, created_at DESC',
    );

    return rows.map(CareEpisodeAssessment.fromMap).toList();
  }

  Future<void> insertAssessment(
      CareEpisodeAssessment assessment,
      ) async {
    final db = await DatabaseService.database;

    await db.insert(
      'care_episode_assessments',
      assessment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateAssessment(
      CareEpisodeAssessment assessment,
      ) async {
    final db = await DatabaseService.database;

    await db.update(
      'care_episode_assessments',
      assessment.toMap(),
      where: 'assessment_id = ?',
      whereArgs: [assessment.assessmentId],
    );
  }

  Future<Set<String>> getSelectedTestExoIds(
      String assessmentId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_assessment_tests',
      columns: ['exo_id'],
      where: 'assessment_id = ?',
      whereArgs: [assessmentId],
    );

    return rows
        .map((row) => row['exo_id']?.toString() ?? '')
        .where((exoId) => exoId.isNotEmpty)
        .toSet();
  }

  Future<void> setTestIncluded({
    required String assessmentId,
    required String exoId,
    required bool included,
  }) async {
    final db = await DatabaseService.database;

    if (included) {
      await db.insert(
        'care_episode_assessment_tests',
        {
          'assessment_id': assessmentId,
          'exo_id': exoId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return;
    }

    await db.delete(
      'care_episode_assessment_tests',
      where: 'assessment_id = ? AND exo_id = ?',
      whereArgs: [assessmentId, exoId],
    );
  }

  Future<void> replaceSelectedTests({
    required String assessmentId,
    required Set<String> exoIds,
  }) async {
    final db = await DatabaseService.database;

    await db.transaction((transaction) async {
      await transaction.delete(
        'care_episode_assessment_tests',
        where: 'assessment_id = ?',
        whereArgs: [assessmentId],
      );

      for (final exoId in exoIds) {
        await transaction.insert(
          'care_episode_assessment_tests',
          {
            'assessment_id': assessmentId,
            'exo_id': exoId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }


  Future<Set<String>> getSelectedNoteIds(
      String assessmentId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_assessment_notes',
      columns: ['note_id'],
      where: 'assessment_id = ?',
      whereArgs: [assessmentId],
    );

    return rows
        .map((row) => row['note_id']?.toString() ?? '')
        .where((noteId) => noteId.isNotEmpty)
        .toSet();
  }

  Future<void> setNoteIncluded({
    required String assessmentId,
    required String noteId,
    required bool included,
  }) async {
    final db = await DatabaseService.database;

    if (included) {
      await db.insert(
        'care_episode_assessment_notes',
        {
          'assessment_id': assessmentId,
          'note_id': noteId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return;
    }

    await db.delete(
      'care_episode_assessment_notes',
      where: 'assessment_id = ? AND note_id = ?',
      whereArgs: [assessmentId, noteId],
    );
  }

  Future<void> replaceSelectedNotes({
    required String assessmentId,
    required Set<String> noteIds,
  }) async {
    final db = await DatabaseService.database;

    await db.transaction((transaction) async {
      await transaction.delete(
        'care_episode_assessment_notes',
        where: 'assessment_id = ?',
        whereArgs: [assessmentId],
      );

      for (final noteId in noteIds) {
        await transaction.insert(
          'care_episode_assessment_notes',
          {
            'assessment_id': assessmentId,
            'note_id': noteId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }


  Future<List<CareEpisodeAssessment>> getArchivedForEpisode(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_assessments',
      where: '''
        care_episode_id = ?
        AND archived_at IS NOT NULL
      ''',
      whereArgs: [careEpisodeId],
      orderBy: 'archived_at DESC',
    );

    return rows.map(CareEpisodeAssessment.fromMap).toList();
  }

  Future<void> restoreAssessment(String assessmentId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'care_episode_assessments',
      {
        'archived_at': null,
        'updated_at': now,
      },
      where: 'assessment_id = ?',
      whereArgs: [assessmentId],
    );
  }

  Future<void> archiveAssessment(String assessmentId) async {
    final db = await DatabaseService.database;

    await db.update(
      'care_episode_assessments',
      {
        'archived_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'assessment_id = ?',
      whereArgs: [assessmentId],
    );
  }

  Future<int> getSavedCountForEpisode(String careEpisodeId) async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM care_episode_assessments
      WHERE care_episode_id = ?
        AND status = ?
        AND archived_at IS NULL
      ''',
      [careEpisodeId, 'saved'],
    );

    return (result.first['count'] as int?) ?? 0;
  }
}
