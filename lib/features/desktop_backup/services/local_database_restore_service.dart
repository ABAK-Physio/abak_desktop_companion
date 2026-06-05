import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../models/restore_result.dart';

class LocalDatabaseRestoreService {
  const LocalDatabaseRestoreService();

  Future<RestoreResult> restoreDatabase({
    required String backupPath,
  }) async {
    final sourceFile = File(backupPath);

    if (!await sourceFile.exists()) {
      return RestoreResult(
        success: false,
        message: 'Le fichier de sauvegarde est introuvable.',
        sourceBackupPath: backupPath,
      );
    }

    final databasePath = await DatabaseService.databasePath;
    final currentDatabaseFile = File(databasePath);

    final safetyBackupPath = await _createSafetyBackupPath();

    try {
      await DatabaseService.closeDatabase();

      if (await currentDatabaseFile.exists()) {
        await currentDatabaseFile.copy(safetyBackupPath);
      }

      await sourceFile.copy(databasePath);

      final db = await DatabaseService.reopenDatabase();

      final integrityResult = await db.rawQuery('PRAGMA integrity_check;');
      final integrityStatus = integrityResult.first.values.first?.toString();

      final success = integrityStatus == 'ok';

      await _insertRestoreHistory(
        restoredAt: DateTime.now().millisecondsSinceEpoch,
        sourceBackupPath: backupPath,
        safetyBackupPath: safetyBackupPath,
        success: success,
        message: success
            ? 'Restauration effectuée avec succès.'
            : 'Restauration effectuée mais integrity_check a retourné : $integrityStatus',
      );

      return RestoreResult(
        success: success,
        message: success
            ? 'Restauration effectuée avec succès.'
            : 'La base restaurée présente une anomalie : $integrityStatus',
        sourceBackupPath: backupPath,
        safetyBackupPath: safetyBackupPath,
      );
    } catch (e) {
      try {
        if (await File(safetyBackupPath).exists()) {
          await File(safetyBackupPath).copy(databasePath);
          await DatabaseService.reopenDatabase();
        }
      } catch (_) {}

      return RestoreResult(
        success: false,
        message: 'Échec de la restauration : $e',
        sourceBackupPath: backupPath,
        safetyBackupPath: safetyBackupPath,
      );
    }
  }

  Future<String> _createSafetyBackupPath() async {
    final databasePath = await DatabaseService.databasePath;
    final databaseDir = Directory(p.dirname(databasePath));

    final now = DateTime.now();
    final timestamp =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';

    return p.join(
      databaseDir.path,
      'abak_desktop_pre_restore_$timestamp.db',
    );
  }

  Future<void> _insertRestoreHistory({
    required int restoredAt,
    required String sourceBackupPath,
    required String safetyBackupPath,
    required bool success,
    required String message,
  }) async {
    final db = await DatabaseService.database;

    await db.insert(
      'desktop_restore_history',
      {
        'restore_id': const Uuid().v4(),
        'restored_at': restoredAt,
        'source_backup_path': sourceBackupPath,
        'safety_backup_path': safetyBackupPath,
        'success': success ? 1 : 0,
        'message': message,
      },
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}