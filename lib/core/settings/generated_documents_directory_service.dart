import '../documents/document_activity_coordinator.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../generated/l10n.dart';
import 'application_settings_service.dart';
import 'macos_directory_access_service.dart';

/// Keep authorization alive until document operations finish.
class GeneratedDocumentsDirectoryAccess {
  GeneratedDocumentsDirectoryAccess._(this.path, this._macosAccess);
  final String path;
  final MacosDirectoryAccess? _macosAccess;
  Future<void> release() async => _macosAccess?.release();
}

class GeneratedDocumentsDirectoryService {
  const GeneratedDocumentsDirectoryService();
  static const _settings = ApplicationSettingsService();
  static const folderName = 'ABAK_DOCUMENTS';

  Future<bool> needsInitialConfiguration() async {
    final path = await _settings.getString(
      ApplicationSettingsService.assessmentDocumentsDirectoryKey,
    );
    return path == null || path.trim().isEmpty;
  }

  /// Resolve only: never create a folder or persist a suggested location.
  Future<String> documentsPath() async {
    final path = Platform.isMacOS
        ? await const MacosDirectoryAccessService().userDocumentsPath()
        : (await getApplicationDocumentsDirectory()).path;
    if (!p.isAbsolute(path)) throw StateError('Invalid Documents directory');
    return path;
  }

  Future<String> recommendedPath() async =>
      p.join(await documentsPath(), folderName);

  Future<String?>
  useRecommended() => DocumentActivityCoordinator.shared.activity(() async {
    if (!await needsInitialConfiguration()) return reauthorizeConfigured();
    final documents = await documentsPath();
    GeneratedDocumentsDirectoryAccess? access;
    if (Platform.isMacOS) {
      // Authorize Documents explicitly, then create/bookmark only its child.
      final native = await const MacosDirectoryAccessService().chooseDirectory(
        title: S.current.documentsSetup_title,
        initialPath: documents,
        expectedPath: documents,
        createDocumentsChild: true,
        prompt: S.current.documentsSetup_authorize,
        message: S.current.documentsSetup_macosAuthorization,
      );
      if (native == null) return null;
      access = GeneratedDocumentsDirectoryAccess._(native.path, native);
    } else {
      final directory = Directory(p.join(documents, folderName));
      // Do not recreate a missing Documents volume or its ancestors.
      await directory.create();
      access = GeneratedDocumentsDirectoryAccess._(directory.path, null);
    }
    return _validateAndSave(access);
  });

  /// Shared by startup, preferences and attachments; no save before validation.
  Future<String?> chooseAndSave() =>
      DocumentActivityCoordinator.shared.activity(() async {
        if (!await needsInitialConfiguration()) return reauthorizeConfigured();
        final access = await _choose(S.current.documentsSetup_choose);
        if (access == null) return null;
        return _validateAndSave(access);
      });

  /// A secondary entry point can only reauthorize the exact configured root.
  Future<String?> reauthorizeConfigured() =>
      DocumentActivityCoordinator.shared.activity(() async {
        final saved = await _settings.getString(
          ApplicationSettingsService.assessmentDocumentsDirectoryKey,
        );
        if (saved == null || saved.trim().isEmpty) return null;
        if (Platform.isMacOS) {
          final access = await const MacosDirectoryAccessService()
              .chooseDirectory(
                title: S.current.migration_authorize,
                expectedPath: saved,
                initialPath: saved,
                message: S.current.migration_exactRoot,
              );
          if (access == null) return null;
          try {
            if (!p.equals(access.path, saved)) {
              throw DirectoryAuthorizationRequired(saved);
            }
            await validateDirectory(saved);
          } finally {
            await access.release();
          }
        } else {
          await validateDirectory(saved);
        }
        return saved;
      });

  Future<String> _validateAndSave(
    GeneratedDocumentsDirectoryAccess access,
  ) async {
    try {
      await validateDirectory(access.path);
      await _settings.setString(
        ApplicationSettingsService.assessmentDocumentsDirectoryKey,
        access.path,
      );
      return access.path;
    } finally {
      await access.release();
    }
  }

  /// Enumerate without opening patient files; probe only a unique temporary file.
  Future<void> validateDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      throw FileSystemException('Directory unavailable', path);
    }
    await directory.list(followLinks: false).take(1).drain<void>();
    final probe = await directory.createTemp('.abak-access-');
    try {
      final file = File(p.join(probe.path, 'probe'));
      await file.writeAsString('ABAK', flush: true);
      if (await file.readAsString() != 'ABAK') {
        throw FileSystemException('Directory unreadable', path);
      }
    } finally {
      await probe.delete(recursive: true);
    }
  }

  Future<GeneratedDocumentsDirectoryAccess?> acquireForExport() async =>
      await acquireConfigured() ??
      await _choose(S.current.documentsSetup_choose);

  Future<GeneratedDocumentsDirectoryAccess?> acquireConfigured() async {
    final savedPath = await _settings.getString(
      ApplicationSettingsService.assessmentDocumentsDirectoryKey,
    );
    if (savedPath == null || savedPath.trim().isEmpty) return null;
    if (!Platform.isMacOS) {
      return GeneratedDocumentsDirectoryAccess._(savedPath, null);
    }
    final access = await const MacosDirectoryAccessService().acquireDirectory(
      savedPath,
    );
    if (!p.equals(access.path, savedPath)) {
      await access.release();
      throw DirectoryAuthorizationRequired(savedPath);
    }
    return GeneratedDocumentsDirectoryAccess._(access.path, access);
  }

  Future<GeneratedDocumentsDirectoryAccess?> _choose(String title) async {
    // A failed recommendation must not prevent choosing another available disk.
    String? initial;
    try {
      initial = await documentsPath();
    } catch (_) {
      /* Native picker fallback. */
    }
    if (Platform.isMacOS) {
      final access = await const MacosDirectoryAccessService().chooseDirectory(
        title: title,
        initialPath: initial,
        prompt: S.current.documentsSetup_authorize,
      );
      if (access == null) return null;
      return GeneratedDocumentsDirectoryAccess._(access.path, access);
    }
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: title,
      initialDirectory: initial,
    );
    if (path == null || path.trim().isEmpty) return null;
    return GeneratedDocumentsDirectoryAccess._(path, null);
  }
}
