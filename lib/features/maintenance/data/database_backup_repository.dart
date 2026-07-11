import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../models/database_backup.dart';

class DatabaseBackupRepository {
  Future<void> insertBackup({
    required String fileName,
    required String filePath,
    required int fileSize,
    String status = 'completed',
    String? notes,
  }) async {
    final db = await DatabaseService.database;

    await db.insert('desktop_backups', {
      'backup_id': const Uuid().v4(),
      'file_name': fileName,
      'file_path': filePath,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'file_size': fileSize,
      'status': status,
      'notes': notes,
    });
  }

  Future<List<DatabaseBackup>> getBackups() async {
    final db = await DatabaseService.database;

    final rows = await db.query('desktop_backups', orderBy: 'created_at DESC');

    return rows.map(DatabaseBackup.fromMap).toList();
  }

  Future<DatabaseBackup?> getLastBackup() async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'desktop_backups',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return DatabaseBackup.fromMap(rows.first);
  }

  Future<void> deleteBackup(String backupId) async {
    final db = await DatabaseService.database;

    await db.delete(
      'desktop_backups',
      where: 'backup_id = ?',
      whereArgs: [backupId],
    );
  }
}
