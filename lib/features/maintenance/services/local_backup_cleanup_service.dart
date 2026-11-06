import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../data/database_backup_repository.dart';
import '../models/backup_cleanup_result.dart';
import '../models/database_backup.dart';
import 'backup_directory_access.dart';
import 'companion_backup_archive.dart';

class LocalBackupCleanupService {
  static const int minimumBackupsToKeep = 5;
  final DatabaseBackupRepository repository;
  final BackupDirectoryAccess access;
  final Future<void> Function(DatabaseBackup) _deleteFile;
  final Future<void> Function(String) _validateFile;

  const LocalBackupCleanupService({
    required this.repository,
    this.access = const BackupDirectoryAccess(),
    Future<void> Function(DatabaseBackup)? deleteFile,
    Future<void> Function(String)? validateFile,
  }) : _deleteFile = deleteFile ?? _deleteBackupFile,
       _validateFile = validateFile ?? _validateBackup;

  Future<BackupCleanupResult>
  cleanupOldBackups() => BackupOperation.run(() async {
    final backups = await repository.getBackups();
    final eligible = backups.where((b) => b.allowsAutomaticDeletion).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final deleted = <String>[];
    final failed = <String>[];
    final leases = <String, BackupDirectoryLease>{};
    Future<String> authorizedPath(DatabaseBackup backup) async {
      final directory = p.dirname(backup.filePath);
      final lease = leases[directory] ??= await access.acquire(directory);
      // Do not silently delete a different path if a bookmark resolves elsewhere.
      if (!p.equals(p.normalize(p.absolute(directory)), lease.path)) {
        throw FileSystemException(
          'Backup directory moved; reauthorization required',
        );
      }
      return p.join(lease.path, p.basename(backup.filePath));
    }

    try {
      if (eligible.length > minimumBackupsToKeep) {
        // Validate ALL five replacements before deleting anything. Missing,
        // corrupt or unauthorized backups suspend retention, preserving history.
        var safe = true;
        final paths = <String>{};
        for (final backup in eligible.take(minimumBackupsToKeep)) {
          try {
            final path = await authorizedPath(backup);
            if (await FileSystemEntity.type(path, followLinks: false) !=
                FileSystemEntityType.file) {
              throw FileSystemException('Backup missing or not a regular file');
            }
            final canonical = await File(path).resolveSymbolicLinks();
            if (!paths.add(canonical)) throw StateError('Duplicate backup');
            await _validateFile(path);
          } catch (error, stack) {
            safe = false;
            failed.add(backup.filePath);
            debugPrint('Backup retention suspended: $error');
            debugPrintStack(stackTrace: stack);
          }
        }
        if (safe) {
          for (final backup in eligible.skip(minimumBackupsToKeep)) {
            try {
              final path = await authorizedPath(backup);
              final type = await FileSystemEntity.type(
                path,
                followLinks: false,
              );
              if (type != FileSystemEntityType.file) {
                throw FileSystemException(
                  'Backup missing or not a regular file',
                );
              }
              if (paths.contains(await File(path).resolveSymbolicLinks())) {
                throw StateError('Backup shares a retained path');
              }
              await _deleteFile(backup);
              await repository.deleteBackup(backup.backupId);
              deleted.add(backup.filePath);
            } catch (error, stack) {
              failed.add(backup.filePath);
              debugPrint('Backup cleanup skipped: $error');
              debugPrintStack(stackTrace: stack);
            }
          }
        }
      }
    } finally {
      for (final lease in leases.values) {
        try {
          await lease.release();
        } catch (error) {
          debugPrint('Backup access release failed: $error');
        }
      }
    }
    return BackupCleanupResult(
      scannedCount: backups.length,
      deletedCount: deleted.length,
      keptCount: backups.length - deleted.length,
      deletedPaths: deleted,
      failedPaths: failed,
    );
  });

  static Future<void> _validateBackup(String path) async {
    final prepared = await const CompanionBackupArchive().prepare(path);
    await prepared.dispose();
  }

  static Future<void> _deleteBackupFile(DatabaseBackup backup) =>
      File(backup.filePath).delete().then((_) {});
}
