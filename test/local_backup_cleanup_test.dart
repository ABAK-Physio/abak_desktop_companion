import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/maintenance/data/database_backup_repository.dart';
import 'package:abak_desktop_companion/features/maintenance/models/database_backup.dart';
import 'package:abak_desktop_companion/features/maintenance/services/local_backup_cleanup_service.dart';

class MemoryBackupRepository extends DatabaseBackupRepository {
  final List<DatabaseBackup> rows;
  final String? failDeleting;
  MemoryBackupRepository(this.rows, {this.failDeleting});
  @override
  Future<List<DatabaseBackup>> getBackups() async => [...rows];
  @override
  Future<void> deleteBackup(String backupId) async {
    if (backupId == failDeleting) throw StateError('Database unavailable');
    rows.removeWhere((row) => row.backupId == backupId);
  }
}

void main() {
  late Directory temp;
  late List<DatabaseBackup> backups;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('companion_cleanup_test_');
    backups = [
      for (var i = 0; i < 7; i++)
        DatabaseBackup(
          backupId: '$i',
          fileName: '$i.zip',
          filePath: '${temp.path}/$i.zip',
          createdAt: i,
          fileSize: 1,
          status: 'completed',
          notes: null,
        ),
    ];
    for (final backup in backups) {
      await File(backup.filePath).writeAsString('backup');
    }
  });
  tearDown(() async => temp.delete(recursive: true));

  test(
    'permission failure preserves file and catalog entry and continues cleanup',
    () async {
      final repo = MemoryBackupRepository([...backups]);
      final result = await LocalBackupCleanupService(
        repository: repo,
        deleteFile: (backup) async {
          if (backup.backupId == '1') {
            throw FileSystemException('Permission denied', backup.filePath);
          }
          await File(backup.filePath).delete();
        },
      ).cleanupOldBackups();
      expect(result.deletedCount, 1);
      expect(result.keptCount, 6);
      expect(result.failedPaths, [backups[1].filePath]);
      expect(await File(backups[1].filePath).exists(), isTrue);
      expect(repo.rows.any((r) => r.backupId == '1'), isTrue);
      expect(await File(backups[0].filePath).exists(), isFalse);
      for (final backup in backups.skip(2)) {
        expect(await File(backup.filePath).exists(), isTrue);
      }
    },
  );
  test(
    'missing old file does not block removal of its catalog entry',
    () async {
      await File(backups[1].filePath).delete();
      final repo = MemoryBackupRepository([...backups]);
      final result = await LocalBackupCleanupService(
        repository: repo,
      ).cleanupOldBackups();
      expect(result.deletedCount, 2);
      expect(result.keptCount, 5);
      expect(result.failedPaths, isEmpty);
      expect(repo.rows.map((r) => r.backupId), ['2', '3', '4', '5', '6']);
    },
  );
  test(
    'catalog deletion failure is isolated and counted as incomplete cleanup',
    () async {
      final repo = MemoryBackupRepository([...backups], failDeleting: '1');
      final result = await LocalBackupCleanupService(
        repository: repo,
      ).cleanupOldBackups();
      expect(result.deletedCount, 1);
      expect(result.failedPaths, [backups[1].filePath]);
      expect(repo.rows.any((r) => r.backupId == '1'), isTrue);
      expect(repo.rows.any((r) => r.backupId == '0'), isFalse);
    },
  );
  test('five or fewer backups are never removed', () async {
    final repo = MemoryBackupRepository(backups.take(5).toList());
    final result = await LocalBackupCleanupService(
      repository: repo,
      deleteFile: (_) async {
        fail('No file should be deleted');
      },
    ).cleanupOldBackups();
    expect(result.deletedCount, 0);
    expect(result.keptCount, 5);
    expect(result.failedPaths, isEmpty);
  });
}
