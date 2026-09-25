import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import 'macos_directory_access_service.dart';

class ExchangeDirectoryService {
  static const String _preferenceKey = 'exchange_directory_path';

  /// Fournit un accès à conserver pendant toute l’opération ou la surveillance.
  /// Le demandeur doit toujours appeler release() à la fin de son utilisation.
  Future<ExchangeDirectoryAccess> acquireExchangeDirectory() async {
    final savedPath = await getSavedDirectoryPath();

    if (Platform.isMacOS && savedPath != null && savedPath.isNotEmpty) {
      final access = await const MacosDirectoryAccessService()
          .acquireDirectory(savedPath);
      try {
        final directory = Directory(access.path);
        if (!await directory.exists()) {
          throw DirectoryAuthorizationRequired(savedPath);
        }
        return ExchangeDirectoryAccess._(directory, access);
      } catch (_) {
        await access.release();
        rethrow;
      }
    }

    // Conserver le comportement historique des autres plateformes.
    if (savedPath != null && savedPath.isNotEmpty) {
      final directory = Directory(savedPath);
      if (await directory.exists()) {
        return ExchangeDirectoryAccess._(directory, null);
      }
    }

    // Sur macOS, ce chemin n’est atteint que si aucun dossier externe
    // n’a été choisi. Un dossier externe inaccessible déclenche une erreur.
    final directory = await _getInternalDirectory();
    return ExchangeDirectoryAccess._(directory, null);
  }

  /// Retourne le chemin choisi par l'utilisateur, s'il existe.
  Future<String?> getSavedDirectoryPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferenceKey);
  }

  /// Choisit le dossier et mémorise son autorisation sur macOS.
  Future<String?> chooseDirectory() async {
    if (Platform.isMacOS) {
      final access = await const MacosDirectoryAccessService()
          .chooseDirectory(
        title: S.current.exchangeDirectoryService_choose,
      );

      if (access == null) return null;

      try {
        final prefs = await SharedPreferences.getInstance();
        final saved = await prefs.setString(
          _preferenceKey,
          access.path,
        );

        if (!saved) {
          throw StateError(
            'Impossible de mémoriser le dossier d’échange.',
          );
        }

        return access.path;
      } finally {
        await access.release();
      }
    }

    final selectedPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: S.current.exchangeDirectoryService_choose,
    );

    if (selectedPath == null || selectedPath.isEmpty) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, selectedPath);

    return selectedPath;
  }

  /// Dossier interne utilisé uniquement en l’absence de choix sur macOS.
  Future<Directory> _getInternalDirectory() async {
    final appSupportDirectory = await getApplicationSupportDirectory();

    final fallbackDirectory = Directory(
      '${appSupportDirectory.path}'
          '${Platform.pathSeparator}'
          'ABAK_Echanges',
    );

    if (!await fallbackDirectory.exists()) {
      await fallbackDirectory.create(recursive: true);
    }

    return fallbackDirectory;
  }

  /// Affiche le choix conservé sans prétendre que son accès est autorisé.
  Future<String> getExchangeDirectoryPathLabel() async {
    final savedPath = await getSavedDirectoryPath();
    if (Platform.isMacOS && savedPath != null && savedPath.isNotEmpty) {
      return savedPath;
    }
    final access = await acquireExchangeDirectory();
    try {
      return access.directory.path;
    } finally {
      await access.release();
    }
  }

  /// Vérifie si un dossier utilisateur est configuré.
  Future<bool> hasCustomDirectory() async {
    final savedPath = await getSavedDirectoryPath();
    return savedPath != null && savedPath.isNotEmpty;
  }

  /// Réinitialise le choix utilisateur.
  Future<void> resetDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.remove(_preferenceKey)) {
      throw StateError('Impossible de réinitialiser le dossier d’échange.');
    }
  }
}

/// Un accès indépendant pour chaque utilisateur du dossier : une réception
/// réseau ne doit pas fermer l’accès encore utilisé par la surveillance.
class ExchangeDirectoryAccess {
  ExchangeDirectoryAccess._(this.directory, this._macosAccess);

  final Directory directory;
  final MacosDirectoryAccess? _macosAccess;

  Future<void> release() async {
    await _macosAccess?.release();
  }
}