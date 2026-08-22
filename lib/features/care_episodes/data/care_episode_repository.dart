import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import '../../../core/database/database_service.dart';
import '../models/care_episode.dart';
import '../models/care_episode_note.dart';
import '../models/care_episode_summary.dart';

class CareEpisodeRepository {
  Future<void> insertCareEpisode(CareEpisode episode) async {
    final db = await DatabaseService.database;

    await db.insert(
      'care_episodes',
      episode.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<CareEpisodeNote>> getNotesForEpisode(String careEpisodeId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_notes',
      where: 'care_episode_id = ? AND archived_at IS NULL',
      whereArgs: [careEpisodeId],
      orderBy: 'note_date DESC, created_at DESC',
    );

    return rows.map(CareEpisodeNote.fromMap).toList();
  }

  Future<void> insertNote(CareEpisodeNote note) async {
    final db = await DatabaseService.database;

    final map = note.toMap();


    await db.insert(
      'care_episode_notes',
      map,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    final rows = await db.query(
      'care_episode_notes',
      where: 'note_id = ?',
      whereArgs: [note.noteId],
      limit: 1,
    );

  }

  Future<void> updateNote(CareEpisodeNote note) async {
    final db = await DatabaseService.database;

    await db.update(
      'care_episode_notes',
      note.toMap(),
      where: 'note_id = ?',
      whereArgs: [note.noteId],
    );
  }

  Future<void> updateFinalConclusion({
    required String careEpisodeId,
    required String? finalConclusion,
  }) async {
    final db = await DatabaseService.database;

    await db.update(
      'care_episodes',
      {
        'final_conclusion': finalConclusion,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'care_episode_id = ?',
      whereArgs: [careEpisodeId],
    );
  }

  Future<void> updateCareEpisode(CareEpisode episode) async {
    final db = await DatabaseService.database;

    await db.update(
      'care_episodes',
      episode.toMap(),
      where: 'care_episode_id = ?',
      whereArgs: [episode.careEpisodeId],
    );
  }

  Future<void> archiveCareEpisode(String careEpisodeId) async {
    final db = await DatabaseService.database;

    await db.update(
      'care_episodes',
      {'archived_at': DateTime.now().millisecondsSinceEpoch},
      where: 'care_episode_id = ?',
      whereArgs: [careEpisodeId],
    );
  }

  Future<List<CareEpisode>> getEpisodesForPatient(String patientId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episodes',
      where: 'patient_id = ? AND archived_at IS NULL',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );

    return rows.map(CareEpisode.fromMap).toList();
  }

  Future<CareEpisode?> getEpisodeById(String careEpisodeId) async {
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

  Future<int> getNoteCount(String careEpisodeId) async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery(
      '''
    SELECT COUNT(*) AS count
    FROM care_episode_notes
    WHERE care_episode_id = ?
      AND archived_at IS NULL
    ''',
      [careEpisodeId],
    );

    return (result.first['count'] as int?) ?? 0;
  }

  Future<List<CareEpisodeSummary>> getEpisodeSummariesForPatient(
      String patientId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.rawQuery(
      '''
    SELECT
      ce.*,
      COUNT(DISTINCT cen.note_id) AS notes_count,
      p.display_name AS referring_practitioner_display_name,
      CASE
        WHEN p.archived_at IS NOT NULL THEN 1
        ELSE 0
      END AS referring_practitioner_archived
    FROM care_episodes ce

    LEFT JOIN care_episode_notes cen
      ON cen.care_episode_id = ce.care_episode_id
      AND cen.archived_at IS NULL

    LEFT JOIN care_episode_referring_practitioners cerp
      ON cerp.care_episode_id = ce.care_episode_id
      AND cerp.ended_at IS NULL

    LEFT JOIN practitioners p
      ON p.practitioner_id = cerp.practitioner_id

    WHERE ce.patient_id = ?
      AND ce.archived_at IS NULL

    GROUP BY ce.care_episode_id

    ORDER BY ce.created_at DESC
    ''',
      [patientId],
    );

    return rows.map(CareEpisodeSummary.fromMap).toList();
  }

  Future<void> updateInitialReportDocxPath({
    required String careEpisodeId,
    required String? initialReportDocxPath,
  }) async {
    final db = await DatabaseService.database;

    await db.update(
      'care_episodes',
      {
        'initial_report_docx_path': initialReportDocxPath,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'care_episode_id = ?',
      whereArgs: [careEpisodeId],
    );
  }
}
