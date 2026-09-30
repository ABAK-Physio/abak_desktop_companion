import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../../core/settings/macos_directory_access_service.dart';
import '../../../generated/l10n.dart';

class BackupDirectoryLease {
  BackupDirectoryLease(String path, [this._onRelease])
    : path = p.normalize(p.absolute(path));
  final String path;
  final Future<void> Function()? _onRelease;
  Future<void> release() async => _onRelease?.call();
}

class BackupDirectoryAccess {
  const BackupDirectoryAccess();

  Future<BackupDirectoryLease?> choose(String title) async {
    if (Platform.isMacOS) {
      final access = await const MacosDirectoryAccessService().chooseDirectory(
        title: title,
      );
      return access == null
          ? null
          : BackupDirectoryLease(access.path, access.release);
    }
    final path = await FilePicker.platform.getDirectoryPath(dialogTitle: title);
    return path == null ? null : BackupDirectoryLease(path);
  }

  Future<BackupDirectoryLease> acquire(String path) async {
    if (Platform.isMacOS) {
      final access = await const MacosDirectoryAccessService().acquireDirectory(
        path,
      );
      return BackupDirectoryLease(access.path, access.release);
    }
    return BackupDirectoryLease(path);
  }

  /// A backup source must never silently become a different folder.
  Future<BackupDirectoryLease> read(String path) async {
    try {
      final lease = await acquire(path);
      if (await Directory(lease.path).exists()) return lease;
      await lease.release();
      throw FileSystemException('Dossier introuvable', path);
    } on DirectoryAuthorizationRequired {
      final lease = await choose(S.current.backupArchive_authorizeFolder(path));
      if (lease == null) {
        throw StateError(S.current.localDatabaseBackup_cancelled);
      }
      if (!p.equals(lease.path, p.normalize(p.absolute(path)))) {
        await lease.release();
        throw FileSystemException('Sélectionnez le dossier demandé', path);
      }
      return lease;
    }
  }

  /// A restore can relocate a source root, e.g. onto a replacement computer.
  Future<BackupDirectoryLease> restore(String path) async {
    try {
      final lease = await acquire(path);
      if (await Directory(lease.path).exists()) return lease;
      await lease.release();
    } on DirectoryAuthorizationRequired {
      // Let the user authorize the old location or select its replacement.
    }
    final lease = await choose(S.current.backupArchive_restoreFolder(path));
    if (lease == null) {
      throw StateError(S.current.localDatabaseBackup_cancelled);
    }
    return lease;
  }
}

class BackupOperation {
  static bool _active = false;

  static Future<T> run<T>(Future<T> Function() action) async {
    if (_active) throw StateError(S.current.backupArchive_busy);
    _active = true;
    try {
      return await action();
    } finally {
      _active = false;
    }
  }
}
