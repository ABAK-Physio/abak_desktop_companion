import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../models/import_session.dart';
import '../models/import_session_file.dart';

class ImportSessionRepository {
  Future<String> startSession({
    String? sourceLabel,
    String? notes,
  }) async {
    final db = await DatabaseService.database;

    final sessionId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'desktop_import_sessions',
      {
        'import_session_id': sessionId,
        'started_at': now,
        'completed_at': null,
        'processed_files_count': 0,
        'failed_files_count': 0,
        'imported_results_count': 0,
        'skipped_results_count': 0,
        'imported_metrics_count': 0,
        'source_label': sourceLabel,
        'notes': notes,
        'status': 'running',
      },
    );

    return sessionId;
  }

  Future<List<ImportSession>> getSessions() async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_import_sessions',
      orderBy: 'started_at DESC',
    );

    return rows.map(ImportSession.fromMap).toList();
  }

  Future<List<ImportSessionFile>> getFilesForSession(
      String importSessionId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_import_session_files',
      where: 'import_session_id = ?',
      whereArgs: [importSessionId],
      orderBy: '''
        CASE status
          WHEN 'error' THEN 0
          ELSE 1
        END ASC,
      processed_at ASC
    ''',
    );

    return rows.map(ImportSessionFile.fromMap).toList();
  }


  Future<void> addFileLog({
    required String importSessionId,
    required String fileName,
    required int? fileSize,
    required String status,
    required int importedResultsCount,
    required int skippedResultsCount,
    required int importedMetricsCount,
    required int conflictResultsCount,
    String? filePath,
    String? errorMessage,
  }) async {
    final db = await DatabaseService.database;

    await db.insert(
      'desktop_import_session_files',
      {
        'session_file_id': const Uuid().v4(),
        'import_session_id': importSessionId,
        'file_name': fileName,
        'file_path': filePath,
        'file_size': fileSize,
        'processed_at': DateTime.now().millisecondsSinceEpoch,
        'imported_results_count': importedResultsCount,
        'skipped_results_count': skippedResultsCount,
        'imported_metrics_count': importedMetricsCount,
        'conflict_results_count': conflictResultsCount,
        'status': status,
        'error_message': errorMessage,
      },
    );
  }

  Future<void> completeSession({
    required String importSessionId,
    required int processedFilesCount,
    required int failedFilesCount,
    required int importedResultsCount,
    required int skippedResultsCount,
    required int importedMetricsCount,
    required int conflictResultsCount,
    String? status,
  }) async {
    final db = await DatabaseService.database;

    await db.update(
      'desktop_import_sessions',
      {
        'completed_at': DateTime.now().millisecondsSinceEpoch,
        'processed_files_count': processedFilesCount,
        'failed_files_count': failedFilesCount,
        'imported_results_count': importedResultsCount,
        'skipped_results_count': skippedResultsCount,
        'imported_metrics_count': importedMetricsCount,
        'conflict_results_count': conflictResultsCount,
        'status': status ??
            (failedFilesCount > 0 ? 'completed_with_errors' : 'completed'),
      },
      where: 'import_session_id = ?',
      whereArgs: [importSessionId],
    );
  }

  Future<void> recoverInterruptedSessions() async {
    final db = await DatabaseService.database;

    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'desktop_import_sessions',
      {
        'status': 'failed',
        'completed_at': now,
        'notes': 'Import interrompu avant finalisation',
      },
      where: 'status = ?',
      whereArgs: ['running'],
    );
  }

  Future<List<Map<String, dynamic>>> getFilesNeedingResolution() async {
    final db = await DatabaseService.database;

    return db.query(
      'desktop_import_session_files',
      where: "status = ?",
      whereArgs: ['needs_resolution'],
      orderBy: 'processed_at DESC',
    );
  }

  Future<void> markFilesResolvedByPath(String filePath) async {
    final db = await DatabaseService.database;

    await db.update(
      'desktop_import_session_files',
      {
        'status': 'resolved',
        'error_message': null,
      },
      where: "status = ? AND (file_path = ? OR error_message = ?)",
      whereArgs: [
        'needs_resolution',
        filePath,
        filePath,
      ],
    );
  }
}