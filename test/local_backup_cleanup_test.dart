import 'dart:io';
import 'package:abak_desktop_companion/features/maintenance/services/backup_directory_access.dart';
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

class TestAccess extends BackupDirectoryAccess {
  int acquired = 0, released = 0;
  bool deny = false;
  @override
  Future<BackupDirectoryLease> acquire(String path) async {
    if (deny) throw const FileSystemException('Permission denied');
    acquired++;
    return BackupDirectoryLease(path, () async {
      released++;
    });
  }
}

void main() {
  late TestAccess access;

  late Directory temp;
  late List<DatabaseBackup> backups;
  setUp(() async {
    access = TestAccess();
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
          retentionPolicy: 'automatic',
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
        access: access,
        validateFile: (path) async {
          await File(path).readAsBytes();
        },
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
  test('missing old file is preserved in catalog for diagnosis', () async {
    await File(backups[1].filePath).delete();
    final repo = MemoryBackupRepository([...backups]);
    final result = await LocalBackupCleanupService(
      repository: repo,
      access: access,
      validateFile: (path) async {
        await File(path).readAsBytes();
      },
    ).cleanupOldBackups();
    expect(result.deletedCount, 1);
    expect(result.keptCount, 6);
    expect(result.failedPaths, [backups[1].filePath]);
    expect(repo.rows.map((r) => r.backupId), ['1', '2', '3', '4', '5', '6']);
  });
  test(
    'catalog deletion failure is isolated and counted as incomplete cleanup',
    () async {
      final repo = MemoryBackupRepository([...backups], failDeleting: '1');
      final result = await LocalBackupCleanupService(
        repository: repo,
        access: access,
        validateFile: (path) async {
          await File(path).readAsBytes();
        },
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
      access: access,
      validateFile: (path) async {
        await File(path).readAsBytes();
      },
      deleteFile: (_) async {
        fail('No file should be deleted');
      },
    ).cleanupOldBackups();
    expect(result.deletedCount, 0);
    expect(result.keptCount, 5);
    expect(result.failedPaths, isEmpty);
  });
  test('five missing recent backups never delete older valid files', () async {
    for (final b in backups.skip(2)) {
      await File(b.filePath).delete();
    }
    final repo = MemoryBackupRepository([...backups]);
    final result = await LocalBackupCleanupService(
      repository: repo,
      access: access,
      validateFile: (_) async {},
    ).cleanupOldBackups();
    expect(result.deletedCount, 0);
    expect(repo.rows.length, 7);
    expect(await File(backups.first.filePath).exists(), isTrue);
    expect(result.failedPaths.length, 5);
    expect(access.released, access.acquired);
  });
  test('corrupt replacement suspends all deletion', () async {
    final repo = MemoryBackupRepository([...backups]);
    final result = await LocalBackupCleanupService(
      repository: repo,
      access: access,
      validateFile: (_) async {
        throw const FormatException('Corrupt');
      },
    ).cleanupOldBackups();
    expect(result.deletedCount, 0);
    expect(repo.rows.length, 7);
    expect(access.released, access.acquired);
  });
  test(
    'manual and legacy entries remain protected without requesting access',
    () async {
      final protected = backups.map((b) {
        final map = b.toMap()..remove('retention_policy');
        return DatabaseBackup.fromMap(map);
      }).toList();
      final repo = MemoryBackupRepository(protected);
      final result = await LocalBackupCleanupService(
        repository: repo,
        access: access,
      ).cleanupOldBackups();
      expect(result.deletedCount, 0);
      expect(repo.rows.length, 7);
      expect(access.acquired, 0);
    },
  );
  test('expired authorization preserves files and catalog', () async {
    access.deny = true;
    final repo = MemoryBackupRepository([...backups]);
    final result = await LocalBackupCleanupService(
      repository: repo,
      access: access,
    ).cleanupOldBackups();
    expect(result.deletedCount, 0);
    expect(repo.rows.length, 7);
    expect(result.failedPaths.length, 5);
  });
  test(
    'valid replacements release authorization after successful cleanup',
    () async {
      final repo = MemoryBackupRepository([...backups]);
      final result = await LocalBackupCleanupService(
        repository: repo,
        access: access,
        validateFile: (_) async {},
      ).cleanupOldBackups();
      expect(result.deletedCount, 2);
      expect(access.acquired, 1);
      expect(access.released, 1);
    },
  );
  test(
    'duplicate recent paths do not count as five independent backups',
    () async {
      final rows = backups
          .map(
            (b) => DatabaseBackup.fromMap(
              b.toMap()..['file_path'] = backups.last.filePath,
            ),
          )
          .toList();
      final result = await LocalBackupCleanupService(
        repository: MemoryBackupRepository(rows),
        access: access,
        validateFile: (_) async {},
      ).cleanupOldBackups();
      expect(result.deletedCount, 0);
      expect(await File(backups.last.filePath).exists(), isTrue);
    },
  );
}
