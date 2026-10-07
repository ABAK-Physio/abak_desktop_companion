import 'dart:io';
import 'package:flutter/foundation.dart';

import '../data/database_backup_repository.dart';
import '../models/backup_cleanup_result.dart';
import '../models/database_backup.dart';

class LocalBackupCleanupService {
  static const int minimumBackupsToKeep = 5;

  final DatabaseBackupRepository repository;

  final Future<void> Function(DatabaseBackup) _deleteFile;

  const LocalBackupCleanupService({
    required this.repository,
    Future<void> Function(DatabaseBackup)? deleteFile,
  }) : _deleteFile = deleteFile ?? _deleteBackupFile;

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

    final backupsToDelete = sortedBackups.skip(minimumBackupsToKeep).toList();

    final deletedPaths = <String>[];
    final failedPaths = <String>[];

    for (final backup in backupsToDelete) {
      try {
        await _deleteFile(backup);
        // Keep the catalog entry when deleting the file fails.
        await repository.deleteBackup(backup.backupId);
        deletedPaths.add(backup.filePath);
      } catch (error, stackTrace) {
        failedPaths.add(backup.filePath);
        debugPrint(
          'Nettoyage de sauvegarde ignoré (${backup.filePath}) : $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    return BackupCleanupResult(
      scannedCount: backups.length,
      deletedCount: deletedPaths.length,
      keptCount: backups.length - deletedPaths.length,
      deletedPaths: deletedPaths,
      failedPaths: failedPaths,
    );
  }

  static Future<void> _deleteBackupFile(DatabaseBackup backup) async {
    final file = File(backup.filePath);

    if (await file.exists()) {
      await file.delete();
    }
  }
}
