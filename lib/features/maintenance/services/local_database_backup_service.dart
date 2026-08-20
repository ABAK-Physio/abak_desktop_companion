import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../data/database_backup_repository.dart';

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
  Future<LocalDatabaseBackupResult> createBackup({
    required String databaseNotFoundMessage,
    required String chooseBackupFolderTitle,
    required String cancelledMessage,
  }) async {
    try {
      final appSupportDir = await getApplicationSupportDirectory();

      final databasePath = join(
        appSupportDir.path,
        'database',
        'abak_desktop.db',
      );

      final databaseFile = File(databasePath);

      if (!await databaseFile.exists()) {
        return LocalDatabaseBackupResult(
          success: false,
          error: databaseNotFoundMessage,
        );
      }

      final DatabaseBackupRepository repository = DatabaseBackupRepository();

      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: chooseBackupFolderTitle,
      );

      if (selectedDirectory == null) {
        return LocalDatabaseBackupResult(
          success: false,
          error: cancelledMessage,
        );
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      final backupFileName = 'abak_backup_$timestamp.db';

      final backupPath = join(selectedDirectory, backupFileName);

      await databaseFile.copy(backupPath);
      final backupFile = File(backupPath);

      await repository.insertBackup(
        fileName: backupFileName,
        filePath: backupPath,
        fileSize: await backupFile.length(),
      );

      return LocalDatabaseBackupResult(success: true, backupPath: backupPath);
    } catch (e) {
      return LocalDatabaseBackupResult(success: false, error: e.toString());
    }
  }
}
