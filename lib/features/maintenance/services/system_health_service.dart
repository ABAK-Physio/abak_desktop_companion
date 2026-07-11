import 'dart:io';

import '../../../core/database/database_service.dart';
import '../models/system_health_snapshot.dart';

class SystemHealthService {
  const SystemHealthService();

  Future<SystemHealthSnapshot> loadSnapshot() async {
    final db = await DatabaseService.database;
    final databasePath = await DatabaseService.databasePath;

    final databaseFile = File(databasePath);
    final databaseSizeBytes = await databaseFile.exists()
        ? await databaseFile.length()
        : 0;

    final backups = await db.query(
      'desktop_backups',
      columns: ['file_size', 'created_at'],
    );

    final backupsCount = backups.length;
    final backupsTotalSizeBytes = backups.fold<int>(
      0,
      (sum, row) => sum + ((row['file_size'] as int?) ?? 0),
    );

    final lastBackupAt = backups
        .map((row) => row['created_at'] as int?)
        .whereType<int>()
        .fold<int?>(null, (previous, value) {
          if (previous == null || value > previous) return value;
          return previous;
        });

    final activePatientsCount = await _count(
      table: 'patients',
      where: 'archived_at IS NULL',
    );

    final archivedPatientsCount = await _count(
      table: 'patients',
      where: 'archived_at IS NOT NULL',
    );

    final importsCount = await _count(
      table: 'desktop_results',
      where: 'archived_at IS NULL',
    );

    final failedImportsCount = await _count(
      table: 'desktop_import_sessions',
      where: "status = 'failed' OR failed_files_count > 0",
    );

    final runningImportsCount = await _count(
      table: 'desktop_import_sessions',
      where: "status = 'running'",
    );

    final restores = await db.query(
      'desktop_restore_history',
      columns: ['restored_at'],
    );

    final lastRestoreAt = restores
        .map((row) => row['restored_at'] as int?)
        .whereType<int>()
        .fold<int?>(null, (previous, value) {
          if (previous == null || value > previous) return value;
          return previous;
        });

    return SystemHealthSnapshot(
      databaseSizeBytes: databaseSizeBytes,
      backupsCount: backupsCount,
      backupsTotalSizeBytes: backupsTotalSizeBytes,
      activePatientsCount: activePatientsCount,
      archivedPatientsCount: archivedPatientsCount,
      importsCount: importsCount,
      failedImportsCount: failedImportsCount,
      runningImportsCount: runningImportsCount,
      lastBackupAt: lastBackupAt,
      lastRestoreAt: lastRestoreAt,
    );
  }

  Future<int> _count({required String table, String? where}) async {
    final db = await DatabaseService.database;

    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $table'
      '${where == null ? '' : ' WHERE $where'}',
    );

    return (rows.first['count'] as int?) ?? 0;
  }
}
