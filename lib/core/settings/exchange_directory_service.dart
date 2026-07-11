import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeDirectoryService {
  static const String _preferenceKey = 'exchange_directory_path';

  /// Retourne le chemin choisi par l'utilisateur, s'il existe.
  Future<String?> getSavedDirectoryPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferenceKey);
  }

  /// Permet au kiné de choisir un dossier d'échange.
  Future<String?> chooseDirectory() async {
    final selectedPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choisir le dossier d’échange ABAK',
    );

    if (selectedPath == null || selectedPath.isEmpty) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, selectedPath);

    return selectedPath;
  }

  /// Retourne le dossier d'échange utilisé par ABAK Companion.
  ///
  /// Fonctionnement :
  ///
  /// - si le kiné a choisi un dossier dans les réglages,
  ///   ce dossier est utilisé ;
  /// - sinon un dossier ABAK_Echanges est créé automatiquement
  ///   dans le dossier support de l'application.
  ///
  /// Le dossier retourné est garanti existant.
  Future<Directory> getExchangeDirectory() async {
    final savedPath = await getSavedDirectoryPath();

    if (savedPath != null && savedPath.isNotEmpty) {
      final savedDirectory = Directory(savedPath);

      if (await savedDirectory.exists()) {
        return savedDirectory;
      }
    }

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

  /// Retourne le chemin du dossier actif sous forme de texte.
  Future<String> getExchangeDirectoryPathLabel() async {
    final directory = await getExchangeDirectory();
    return directory.path;
  }

  /// Vérifie si un dossier utilisateur est configuré.
  Future<bool> hasCustomDirectory() async {
    final savedPath = await getSavedDirectoryPath();
    return savedPath != null && savedPath.isNotEmpty;
  }

  /// Réinitialise le choix utilisateur.
  Future<void> resetDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferenceKey);
  }
}
