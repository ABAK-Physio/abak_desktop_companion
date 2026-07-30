import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/database_service.dart';
import '../models/care_episode_referring_practitioner.dart';
import 'package:uuid/uuid.dart';
import '../models/care_episode_referring_practitioner_history_item.dart';

class CareEpisodeReferringPractitionerRepository {
  Future<CareEpisodeReferringPractitioner?>
  getCurrentReferringPractitioner(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_referring_practitioners',
      where: 'care_episode_id = ? AND ended_at IS NULL',
      whereArgs: [careEpisodeId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return CareEpisodeReferringPractitioner.fromMap(rows.first);
  }

  Future<List<CareEpisodeReferringPractitionerHistoryItem>>
  getReferringPractitionerHistoryWithNames(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.rawQuery(
      '''
    SELECT
      cerp.assignment_id,
      cerp.practitioner_id,
      cerp.started_at,
      cerp.ended_at,
      p.display_name,
      p.archived_at
    FROM care_episode_referring_practitioners cerp
    LEFT JOIN practitioners p
      ON p.practitioner_id = cerp.practitioner_id
    WHERE cerp.care_episode_id = ?
    ORDER BY cerp.started_at DESC
    ''',
      [careEpisodeId],
    );

    return rows
        .map(CareEpisodeReferringPractitionerHistoryItem.fromMap)
        .toList();
  }

  Future<List<CareEpisodeReferringPractitioner>>
  getReferringPractitionerHistory(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'care_episode_referring_practitioners',
      where: 'care_episode_id = ?',
      whereArgs: [careEpisodeId],
      orderBy: 'started_at DESC',
    );

    return rows
        .map(CareEpisodeReferringPractitioner.fromMap)
        .toList();
  }

  Future<void> changeReferringPractitioner({
    required String careEpisodeId,
    required String practitionerId,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      final currentRows = await txn.query(
        'care_episode_referring_practitioners',
        columns: ['assignment_id', 'practitioner_id'],
        where: 'care_episode_id = ? AND ended_at IS NULL',
        whereArgs: [careEpisodeId],
        limit: 1,
      );

      if (currentRows.isNotEmpty) {
        final currentPractitionerId =
        currentRows.first['practitioner_id']?.toString();

        if (currentPractitionerId == practitionerId) {
          return;
        }

        await txn.update(
          'care_episode_referring_practitioners',
          {
            'ended_at': now,
          },
          where: 'assignment_id = ?',
          whereArgs: [
            currentRows.first['assignment_id'],
          ],
        );
      }

      await txn.insert(
        'care_episode_referring_practitioners',
        {
          'assignment_id': const Uuid().v4(),
          'care_episode_id': careEpisodeId,
          'practitioner_id': practitionerId,
          'started_at': now,
          'ended_at': null,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<void> clearCurrentReferringPractitioner(
      String careEpisodeId,
      ) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'care_episode_referring_practitioners',
      {
        'ended_at': now,
      },
      where: 'care_episode_id = ? AND ended_at IS NULL',
      whereArgs: [careEpisodeId],
    );
  }
}