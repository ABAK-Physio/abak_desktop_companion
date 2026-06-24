import '../../../core/database/database_service.dart';
import '../models/desktop_result.dart';
import '../models/desktop_result_metric.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DesktopResultRepository {
  Future<List<DesktopResult>> getResultsForPatient(
      String patientId, {
        List<String>? syncStates,
      }) async {
    final db = await DatabaseService.database;

    final whereParts = <String>[
      'patient_id = ?',
    ];

    final whereArgs = <Object?>[
      patientId,
    ];

    if (syncStates != null && syncStates.isNotEmpty) {
      final placeholders = List.filled(syncStates.length, '?').join(', ');
      whereParts.add('sync_state IN ($placeholders)');
      whereArgs.addAll(syncStates);
    }

    final rows = await db.query(
      'desktop_results',
      where: whereParts.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
    );

    return rows.map(DesktopResult.fromMap).toList();
  }

  Future<List<DesktopResult>> getResultsByIds(
      List<String> resultIds,
      ) async {
    if (resultIds.isEmpty) {
      return [];
    }

    final db = await DatabaseService.database;
    final placeholders = List.filled(resultIds.length, '?').join(', ');

    final rows = await db.query(
      'desktop_results',
      where: 'result_id IN ($placeholders)',
      whereArgs: resultIds,
      orderBy: 'createdAt DESC',
    );

    return rows.map(DesktopResult.fromMap).toList();
  }

  Future<bool> resultExists(String resultId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_results',
      columns: ['result_id'],
      where: 'result_id = ?',
      whereArgs: [resultId],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<List<DesktopResultMetric>> getMetricsForResult(
      String resultId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_result_metrics',
      where: 'result_id = ?',
      whereArgs: [resultId],
      orderBy: 'metric_key COLLATE NOCASE ASC',
    );

    return rows.map(DesktopResultMetric.fromMap).toList();
  }

  Future<List<DesktopResultMetric>> getMetricsForResultIds(
      List<String> resultIds,
      ) async {
    if (resultIds.isEmpty) {
      return [];
    }

    final db = await DatabaseService.database;
    final placeholders = List.filled(resultIds.length, '?').join(', ');

    final rows = await db.query(
      'desktop_result_metrics',
      where: 'result_id IN ($placeholders)',
      whereArgs: resultIds,
      orderBy: 'result_id COLLATE NOCASE ASC, metric_key COLLATE NOCASE ASC',
    );

    return rows.map(DesktopResultMetric.fromMap).toList();
  }

  Future<void> insertResultWithMetrics({
    required DesktopResult result,
    required List<DesktopResultMetric> metrics,
  }) async {
    final db = await DatabaseService.database;

    await db.transaction((txn) async {
      await txn.insert(
        'desktop_results',
        result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      for (final metric in metrics) {
        await txn.insert(
          'desktop_result_metrics',
          metric.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    });
  }

  Future<void> updateResultComment({
    required String resultId,
    required String? comment,
  }) async {
    final db = await DatabaseService.database;

    await db.update(
      'desktop_results',
      {
        'comment': comment,
        'sync_state': 'modified',
        'last_modified_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'result_id = ?',
      whereArgs: [resultId],
    );
  }

  Future<void> markResultAsModified(String resultId) async {
    final db = await DatabaseService.database;

    await db.update(
      'desktop_results',
      {
        'sync_state': 'modified',
        'last_modified_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'result_id = ?',
      whereArgs: [resultId],
    );
  }

  Future<void> markResultAsSynced(String resultId) async {
    final db = await DatabaseService.database;

    await db.update(
      'desktop_results',
      {
        'sync_state': 'synced',
        'last_modified_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'result_id = ?',
      whereArgs: [resultId],
    );
  }

  Future<void> markResultAsConflict(String resultId) async {
    final db = await DatabaseService.database;

    await db.update(
      'desktop_results',
      {
        'sync_state': 'conflict',
        'last_modified_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'result_id = ?',
      whereArgs: [resultId],
    );
  }

  Future<void> archiveResult(String resultId) async {
    final db = await DatabaseService.database;

    await db.update(
      'desktop_results',
      {
        'archived_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'result_id = ?',
      whereArgs: [resultId],
    );
  }

  Future<String?> getContentHashForResult(String resultId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_results',
      columns: ['content_hash'],
      where: 'result_id = ?',
      whereArgs: [resultId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['content_hash'] as String?;
  }

  Future<Map<String, dynamic>?> getRawResultById(String resultId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_results',
      where: 'result_id = ?',
      whereArgs: [resultId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return rows.first;
  }

  Future<void> saveResultConflict({
    required String resultId,
    required String? existingHash,
    required String incomingHash,
    required String? existingJson,
    required String incomingJson,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'desktop_result_conflicts',
      {
        'conflict_id': 'conflict_${resultId}_$now',
        'result_id': resultId,
        'existing_hash': existingHash,
        'incoming_hash': incomingHash,
        'existing_json': existingJson,
        'incoming_json': incomingJson,
        'detected_at': now,
        'resolution_status': 'pending',
        'resolved_at': null,
        'resolution_note': null,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<DesktopResult>> getResultsForMobileCase(
      String mobileCaseId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_results',
      where: 'mobile_case_id = ? AND archived_at IS NULL',
      whereArgs: [mobileCaseId],
      orderBy: 'createdAt DESC',
    );

    return rows
        .map((row) => DesktopResult.fromMap(row))
        .toList();
  }

  Future<List<DesktopResult>> getResultsForEpisode(
      String episodeId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_results',
      where: 'episode_id = ? AND archived_at IS NULL',
      whereArgs: [episodeId],
      orderBy: 'createdAt ASC',
    );

    return rows
        .map((row) => DesktopResult.fromMap(row))
        .toList();
  }
}