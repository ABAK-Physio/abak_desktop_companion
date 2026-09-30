import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../data/database_backup_repository.dart';
import 'backup_directory_access.dart';
import 'companion_backup_archive.dart';

class LocalDatabaseBackupResult {
  final bool success;
  final String? backupPath;
  final String? error;
  const LocalDatabaseBackupResult({
    required this.success,
    this.backupPath,
    this.error,
  });
}

class LocalDatabaseBackupService {
  const LocalDatabaseBackupService({
    this.access = const BackupDirectoryAccess(),
  });
  final BackupDirectoryAccess access;

  Future<LocalDatabaseBackupResult> createBackup({
    required String databaseNotFoundMessage,
    required String chooseBackupFolderTitle,
    required String cancelledMessage,
  }) async {
    try {
      return await BackupOperation.run(() async {
        if (!await File(await DatabaseService.databasePath).exists()) {
          return LocalDatabaseBackupResult(
            success: false,
            error: databaseNotFoundMessage,
          );
        }
        final destination = await access.choose(chooseBackupFolderTitle);
        if (destination == null) {
          return LocalDatabaseBackupResult(
            success: false,
            error: cancelledMessage,
          );
        }
        String? partial;
        try {
          final timestamp = DateTime.now()
              .toIso8601String()
              .replaceAll(RegExp(r'[^0-9]'), '')
              .substring(0, 14);
          final name =
              'abak_backup_${timestamp}_${const Uuid().v4().substring(0, 8)}.zip';
          final path = p.join(destination.path, name);
          partial = '$path.partial';
          await const CompanionBackupArchive().create(
            outputPath: partial,
            access: access,
          );
          final checked = await const CompanionBackupArchive().prepare(partial);
          await checked.dispose();
          await File(partial).rename(path);
          partial = null;
          await DatabaseBackupRepository().insertBackup(
            fileName: name,
            filePath: path,
            fileSize: await File(path).length(),
          );
          return LocalDatabaseBackupResult(success: true, backupPath: path);
        } finally {
          if (partial != null && await File(partial).exists()) {
            await File(partial).delete();
          }
          await destination.release();
        }
      });
    } catch (error) {
      return LocalDatabaseBackupResult(success: false, error: error.toString());
    }
  }
}
