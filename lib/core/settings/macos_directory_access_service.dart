import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Accès actif : le conserver pendant les opérations sur le dossier,
/// puis appeler release() dans un bloc finally (ou à l’arrêt du watcher).
class MacosDirectoryAccess {
  MacosDirectoryAccess._(this.path, this._token);

  final String path;
  final String _token;
  Future<void>? _releaseFuture;

  Future<void> release() {
    return _releaseFuture ??= MacosDirectoryAccessService._channel
        .invokeMethod<void>('releaseDirectory', {'token': _token});
  }
}

class DirectoryAuthorizationRequired implements Exception {
  const DirectoryAuthorizationRequired(this.path);

  final String path;

  @override
  String toString() =>
      'Le dossier est indisponible ou doit être autorisé à nouveau : $path';
}

/// Service réservé à macOS. Les autres plateformes gardent leur parcours actuel.
class MacosDirectoryAccessService {
  const MacosDirectoryAccessService();

  static const _channel = MethodChannel('abak/directory_access');
  static const _prefix = 'macos_directory_bookmark_v1_';

  String _key(String path) => '$_prefix${base64Url.encode(utf8.encode(path))}';

  void _requireMacos() {
    if (!Platform.isMacOS) {
      throw UnsupportedError('Ce service est réservé à macOS.');
    }
  }

  /// Sélection explicite et stockage de l’autorisation.
  /// Une annulation ne modifie pas les préférences.
  Future<MacosDirectoryAccess?> chooseDirectory({required String title}) async {
    _requireMacos();
    final value = await _channel.invokeMapMethod<String, dynamic>(
      'chooseDirectory',
      {'title': title},
    );
    if (value == null) return null;
    return _saveAndCreateAccess(value);
  }

  /// Restaure l’autorisation associée au chemin déjà enregistré par l’application.
  /// Un ancien chemin sans bookmark exige une nouvelle sélection explicite.
  Future<MacosDirectoryAccess> acquireDirectory(String savedPath) async {
    _requireMacos();
    final preferences = await SharedPreferences.getInstance();
    final bookmark = preferences.getString(_key(savedPath));
    if (bookmark == null || bookmark.isEmpty) {
      throw DirectoryAuthorizationRequired(savedPath);
    }

    final Map<String, dynamic>? value;
    try {
      value = await _channel.invokeMapMethod<String, dynamic>(
        'restoreDirectory',
        {'bookmark': bookmark},
      );
    } on PlatformException catch (error) {
      if (error.code == 'DIRECTORY_ACCESS_FAILED' ||
          error.code == 'INVALID_BOOKMARK') {
        throw DirectoryAuthorizationRequired(savedPath);
      }
      rethrow;
    }
    if (value == null) {
      throw DirectoryAuthorizationRequired(savedPath);
    }
    return _saveAndCreateAccess(value, savedPath: savedPath);
  }

  /// Oublie seulement le bookmark ; ne supprime aucun dossier ni fichier.
  /// Les accès actifs doivent être libérés séparément par leurs utilisateurs.
  Future<void> forgetDirectory(String savedPath) async {
    _requireMacos();
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.remove(_key(savedPath))) {
      throw StateError('Impossible d’oublier l’autorisation du dossier.');
    }
  }

  Future<MacosDirectoryAccess> _saveAndCreateAccess(
      Map<String, dynamic> value, {
        String? savedPath,
      }) async {
    final token = value['token'];
    final path = value['path'];
    final bookmark = value['bookmark'];
    if (token is! String || token.isEmpty) {
      throw StateError('Réponse macOS invalide : identifiant d’accès absent.');
    }

    try {
      if (path is! String || path.isEmpty ||
          bookmark is! String || bookmark.isEmpty) {
        throw StateError('Réponse macOS invalide : dossier ou autorisation absent.');
      }
      final preferences = await SharedPreferences.getInstance();
      if (!await preferences.setString(_key(path), bookmark)) {
        throw StateError('Impossible de mémoriser l’autorisation du dossier.');
      }
      // Si macOS retrouve un dossier déplacé, conserver aussi l’association
      // avec le chemin historique encore présent dans les réglages existants.
      if (savedPath != null && savedPath != path) {
        if (!await preferences.setString(_key(savedPath), bookmark)) {
          throw StateError('Impossible d’actualiser l’autorisation du dossier.');
        }
      }
      return MacosDirectoryAccess._(path, token);
    } catch (_) {
      // Ne pas laisser un accès actif lorsque sa mémorisation échoue.
      try {
        await _channel.invokeMethod<void>('releaseDirectory', {'token': token});
      } catch (_) {
        // Conserver l’erreur initiale pour l’interface utilisateur.
      }
      rethrow;
    }
  }
}