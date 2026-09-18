import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'application_settings_service.dart';
import 'macos_directory_access_service.dart';

/// Maintenir cet objet jusqu’à la fin de l’export et de l’ouverture du document,
/// puis libérer l’accès dans un bloc finally.
class GeneratedDocumentsDirectoryAccess {
  GeneratedDocumentsDirectoryAccess._(this.path, this._macosAccess);

  final String path;
  final MacosDirectoryAccess? _macosAccess;

  Future<void> release() async {
    await _macosAccess?.release();
  }
}

class GeneratedDocumentsDirectoryService {
  const GeneratedDocumentsDirectoryService();

  static const _settings = ApplicationSettingsService();

  /// Choix explicite depuis les préférences : enregistrer le chemin dans
  /// la clé SQLite existante et, sur macOS, mémoriser aussi l’autorisation.
  Future<String?> chooseAndSave() async {
    final access = await _choose('Choisir le dossier des documents générés');
    if (access == null) return null;
    try {
      await _settings.setString(
        ApplicationSettingsService.assessmentDocumentsDirectoryKey,
        access.path,
      );
      return access.path;
    } finally {
      await access.release();
    }
  }

  /// Restaurer l’accès au dossier configuré. Si aucun dossier n’est configuré,
  /// proposer une destination pour cet export, sans modifier les préférences.
  /// Un ancien chemin sans bookmark n’est jamais considéré comme autorisé.
  Future<GeneratedDocumentsDirectoryAccess?> acquireForExport() async {
    final savedPath = await _settings.getString(
      ApplicationSettingsService.assessmentDocumentsDirectoryKey,
    );
    if (savedPath == null || savedPath.trim().isEmpty) {
      return _choose('Choisir le dossier de destination');
    }
    if (!Platform.isMacOS) {
      return GeneratedDocumentsDirectoryAccess._(savedPath, null);
    }
    final access = await const MacosDirectoryAccessService()
        .acquireDirectory(savedPath);
    return GeneratedDocumentsDirectoryAccess._(access.path, access);
  }

  Future<GeneratedDocumentsDirectoryAccess?> _choose(String title) async {
    if (Platform.isMacOS) {
      final access = await const MacosDirectoryAccessService()
          .chooseDirectory(title: title);
      if (access == null) return null;
      return GeneratedDocumentsDirectoryAccess._(access.path, access);
    }
    final path = await FilePicker.platform.getDirectoryPath(dialogTitle: title);
    if (path == null || path.trim().isEmpty) return null;
    return GeneratedDocumentsDirectoryAccess._(path, null);
  }
}
