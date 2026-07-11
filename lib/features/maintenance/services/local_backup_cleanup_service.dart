import 'dart:io';

import '../data/database_backup_repository.dart';
import '../models/backup_cleanup_result.dart';
import '../models/database_backup.dart';

class LocalBackupCleanupService {
  static const int minimumBackupsToKeep = 5;

  final DatabaseBackupRepository repository;

  const LocalBackupCleanupService({required this.repository});

  Future<BackupCleanupResult> cleanupOldBackups() async {
    final backups = await repository.getBackups();

    if (backups.length <= minimumBackupsToKeep) {
      return BackupCleanupResult(
        scannedCount: backups.length,
        deletedCount: 0,
        keptCount: backups.length,
        deletedPaths: const [],
      );
    }

    final sortedBackups = [...backups];

    sortedBackups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final backupsToKeep = sortedBackups.take(minimumBackupsToKeep).toList();

    final backupsToDelete = sortedBackups.skip(minimumBackupsToKeep).toList();

    final deletedPaths = <String>[];

    for (final backup in backupsToDelete) {
      await _deleteBackupFile(backup);

      deletedPaths.add(backup.filePath);

      await repository.deleteBackup(backup.backupId);
    }

    return BackupCleanupResult(
      scannedCount: backups.length,
      deletedCount: backupsToDelete.length,
      keptCount: backupsToKeep.length,
      deletedPaths: deletedPaths,
    );
  }

  Future<void> _deleteBackupFile(DatabaseBackup backup) async {
    final file = File(backup.filePath);

    if (await file.exists()) {
      await file.delete();
    }
  }
}
