import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MacosLaunchKind {
  firstUse,
  existingInstallation,
  updated,
  unchanged,
  olderVersion,
}

class CompanionVersion {
  const CompanionVersion(this.version, this.build);

  final String version;
  final String build;

  String get label => '$version (build $build)';

  List<int> get _parts {
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
      throw FormatException('Version non reconnue : $version');
    }
    return version.split('.').map(int.parse).toList();
  }

  int get _buildNumber {
    if (!RegExp(r'^[1-9]\d*$').hasMatch(build)) {
      throw FormatException('Numéro de build non reconnu : $build');
    }
    return int.parse(build);
  }

  void validate() {
    _parts;
    _buildNumber;
  }

  /// Les builds distribués doivent être croissants, même si la version change.
  bool isOlderThan(CompanionVersion other) {
    final left = _parts;
    final right = other._parts;
    if (_buildNumber < other._buildNumber) return true;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return left[index] < right[index];
    }
    return false;
  }

  bool sameAs(CompanionVersion other) =>
      version == other.version && build == other.build;
}

class MacosLaunchSnapshot {
  const MacosLaunchSnapshot({
    required this.current,
    required this.previous,
    required this.kind,
  });

  final CompanionVersion current;
  final CompanionVersion? previous;
  final MacosLaunchKind kind;

  bool get shouldShowNotice => kind != MacosLaunchKind.unchanged;

  String get title {
    switch (kind) {
      case MacosLaunchKind.firstUse:
        return 'Bienvenue dans ABAK Companion';
      case MacosLaunchKind.existingInstallation:
        return 'Votre installation existante a été retrouvée';
      case MacosLaunchKind.updated:
        return 'Nouvelle version démarrée';
      case MacosLaunchKind.unchanged:
        return 'ABAK Companion';
      case MacosLaunchKind.olderVersion:
        return 'Cette version est plus ancienne';
    }
  }

  String get message {
    switch (kind) {
      case MacosLaunchKind.firstUse:
        return 'Vous utilisez la version ${current.label}. '
            'Ouvrez désormais Companion depuis Applications. '
            'Vous pouvez configurer vos dossiers dans les réglages et les préférences.';
      case MacosLaunchKind.existingInstallation:
        return 'Version ouverte : ${current.label}. '
            'Un stockage ou des préférences étaient déjà présents sur ce compte. '
            'La version précédente n’était pas enregistrée. '
            'Si vous utilisiez un alias vers une copie dans Téléchargements, '
            'recréez-le depuis Applications.';
      case MacosLaunchKind.updated:
        return 'Version ouverte : ${current.label}. '
            'Dernière version démarrée avec succès : ${previous!.label}. '
            'Le démarrage et l’ouverture de la base de données ont réussi. '
            'Un dossier externe peut encore nécessiter une nouvelle autorisation.';
      case MacosLaunchKind.unchanged:
        return 'Version ${current.label}.';
      case MacosLaunchKind.olderVersion:
        return 'Vous tentez d’ouvrir ${current.label}, alors que '
            '${previous!.label} a déjà été utilisée. '
            'Fermez cette copie et ouvrez la version la plus récente depuis Applications. '
            'La base de données n’a pas été ouverte par ce lancement.';
    }
  }
}

class MacosLaunchHistoryService {
  const MacosLaunchHistoryService();

  static const _key = 'macos_last_successful_launch_v1';

  /// Appeler avant toute ouverture/création/migration de la base de données.
  /// Cette méthode ne marque jamais un démarrage comme réussi.
  Future<MacosLaunchSnapshot> inspectBeforeStartup() async {
    final package = await PackageInfo.fromPlatform();
    final current = CompanionVersion(package.version, package.buildNumber);
    current.validate();

    final preferences = await SharedPreferences.getInstance();
    final previousJson = preferences.getString(_key);
    CompanionVersion? previous;
    if (previousJson != null) {
      final decoded = jsonDecode(previousJson);
      if (decoded is! Map<String, dynamic> ||
          decoded['version'] is! String || decoded['build'] is! String) {
        throw const FormatException('Historique de version illisible.');
      }
      previous = CompanionVersion(
        decoded['version'] as String,
        decoded['build'] as String,
      );
      previous.validate();
    }

    final MacosLaunchKind kind;
    if (previous != null) {
      kind = current.isOlderThan(previous)
          ? MacosLaunchKind.olderVersion
          : current.sameAs(previous)
          ? MacosLaunchKind.unchanged
          : MacosLaunchKind.updated;
    } else {
      final support = await getApplicationSupportDirectory();
      final database = File(p.join(support.path, 'database', 'abak_desktop.db'));
      final hasPreferences = preferences.getKeys().any((key) => key != _key);
      final hasDocuments = await Directory(p.join(support.path, 'episode_documents')).exists();
      final hasImports = await Directory(p.join(support.path, 'incoming_abak')).exists();
      final hasExistingStorage = await database.exists() || hasPreferences ||
          hasDocuments || hasImports;
      kind = hasExistingStorage
          ? MacosLaunchKind.existingInstallation
          : MacosLaunchKind.firstUse;
    }
    return MacosLaunchSnapshot(current: current, previous: previous, kind: kind);
  }

  /// Appeler seulement après le démarrage fonctionnel et l’affichage de l’accueil.
  Future<void> markSuccessful(MacosLaunchSnapshot snapshot) async {
    if (snapshot.kind == MacosLaunchKind.olderVersion) {
      throw StateError('Une ancienne version ne doit pas remplacer l’historique.');
    }
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_key, jsonEncode({
      'version': snapshot.current.version,
      'build': snapshot.current.build,
    }));
    if (!saved) {
      throw StateError('Impossible de mémoriser la version démarrée.');
    }
  }
}
