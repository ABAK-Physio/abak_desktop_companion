import 'dart:io';
import 'package:path/path.dart';
import '../data/database_backup_repository.dart';
import '../../../core/database/database_service.dart';
import 'local_database_backup_service.dart';

class LocalDatabaseResetResult {
  final bool success;
  final String? backupPath;
  final String? error;

  const LocalDatabaseResetResult._({
    required this.success,
    this.backupPath,
    this.error,
  });

  factory LocalDatabaseResetResult.success({required String backupPath}) {
    return LocalDatabaseResetResult._(success: true, backupPath: backupPath);
  }

  factory LocalDatabaseResetResult.failure(String error) {
    return LocalDatabaseResetResult._(success: false, error: error);
  }
}

class LocalDatabaseResetService {
  Future<LocalDatabaseResetResult> resetDatabase() async {
    try {
      final backupResult = await LocalDatabaseBackupService().createBackup();

      if (!backupResult.success) {
        return LocalDatabaseResetResult.failure(
          'Sauvegarde préalable impossible : ${backupResult.error}',
        );
      }

      final dbPath = await DatabaseService.databasePath;

      await DatabaseService.closeDatabase();

      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      await DatabaseService.reopenDatabase();

      await DatabaseBackupRepository().insertBackup(
        fileName: basename(backupResult.backupPath!),
        filePath: backupResult.backupPath!,
        fileSize: await File(backupResult.backupPath!).length(),
      );

      return LocalDatabaseResetResult.success(
        backupPath: backupResult.backupPath ?? '',
      );
    } catch (e) {
      return LocalDatabaseResetResult.failure(e.toString());
    }
  }
}
