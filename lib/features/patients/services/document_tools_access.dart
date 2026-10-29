import 'dart:io';
import '../../dmp_setup/bundled_pdf_tools.dart';

import 'package:path/path.dart' as p;

import '../../../core/settings/macos_directory_access_service.dart';

/// Scoped, read-only access to the complete runtime/reference folders. Selecting
/// just java or a JAR does not grant access to its companion libraries.
class DocumentToolsAccess {
  DocumentToolsAccess._(this._active);

  final List<MacosDirectoryAccess> _active;
  static const _directories = MacosDirectoryAccessService();
  static const names = {
    'office': 'LibreOffice',
    'java': 'Java — dossier Home du JDK',
    'vera': 'veraPDF — dossier contenant le fichier CLI .jar',
    'references': 'Références CDA',
  };

  static String _root(String key, String value) {
    if (!p.isAbsolute(value) || p.normalize(value) != value || value == '/') {
      throw StateError('${names[key]} : indiquez un chemin local absolu.');
    }
    if (key == 'java') {
      if (p.basename(value) != 'java' ||
          p.basename(p.dirname(value)) != 'bin') {
        throw StateError('Java : sélectionnez le fichier bin/java du JDK.');
      }
      final home = p.dirname(p.dirname(value));
      if (home == '/') throw StateError('Dossier Java invalide.');
      return home;
    }
    if (key == 'vera') {
      if (!value.endsWith('.jar') || p.dirname(value) == '/') {
        throw StateError('veraPDF : sélectionnez le fichier CLI .jar.');
      }
      return p.dirname(value);
    }
    return value;
  }

  static Map<String, String> _roots(
    Map<String, String> paths, {
    bool includeOffice = false,
  }) => {
    for (final key in ['java', 'vera', 'references'])
      key: _root(key, paths[key] ?? ''),
    if (includeOffice)
      'office': _root(
        'office',
        (paths['office'] ?? '').isEmpty
            ? '/Applications/LibreOffice.app'
            : paths['office']!,
      ),
  };

  /// Called by the configuration dialog only. Never prompts from a conversion
  /// or a background status refresh, and never broadens a typed path to a parent.
  static Future<bool> authorize(
    Map<String, String> paths, {
    required void Function(String) onStep,
  }) async {
    if ((paths['label'] ?? '').trim().isEmpty) {
      throw StateError('Indiquez le nom et la version des références locales.');
    }
    final roots = _roots(
      paths,
      includeOffice: (paths['office'] ?? '').isNotEmpty,
    );
    for (final entry in roots.entries) {
      if (await BundledPdfTools.ownsRoot(entry.value)) {
        await BundledPdfTools.load();
        continue;
      }
      onStep('Autorisation de lecture : ${names[entry.key]}…');
      MacosDirectoryAccess? access;
      try {
        try {
          access = await _directories.acquireDirectory(
            entry.value,
            readOnly: true,
          );
        } on DirectoryAuthorizationRequired {
          access = await _directories.chooseDirectory(
            title: 'Autoriser ${names[entry.key]} en lecture seule',
            readOnly: true,
            expectedPath: entry.value,
          );
          if (access == null) return false;
        }
        _samePath(entry.value, access.path);
      } finally {
        await access?.release();
      }
    }
    return true;
  }

  /// Folder buttons both choose the resource and retain its macOS authorization.
  static Future<String?> choose(String key, String current) async {
    if (!names.containsKey(key)) throw StateError('Outil inconnu.');
    String? initial;
    if (current.isNotEmpty) {
      try {
        initial = _root(key, current);
      } on StateError {
        // An invalid typed path must not prevent choosing a valid resource.
      }
    }
    final access = await _directories.chooseDirectory(
      title: 'Choisir et autoriser : ${names[key]}',
      readOnly: true,
      initialPath: initial,
    );
    if (access == null) return null;
    try {
      if (key == 'java') return p.join(access.path, 'bin', 'java');
      if (key == 'vera') {
        final candidates = await Directory(access.path)
            .list(followLinks: false)
            .where(
              (e) =>
                  e is File &&
                  RegExp(
                    r'^cli(?:-[0-9][\w.-]*)?\.jar$',
                  ).hasMatch(p.basename(e.path)),
            )
            .toList();
        if (candidates.length != 1) {
          throw StateError(
            'Le dossier doit contenir un seul fichier CLI de veraPDF. Vous pouvez aussi coller son chemin exact dans le champ.',
          );
        }
        return candidates.single.path;
      }
      return access.path;
    } finally {
      await access.release();
    }
  }

  /// Restore grants for the whole operation, including copying references and
  /// verifying hashes after a native result. A moved folder needs reconfiguration.
  static Future<DocumentToolsAccess> acquire(
    Map<String, String> paths, {
    bool includeOffice = false,
  }) async {
    final active = <MacosDirectoryAccess>[];
    try {
      for (final root in _roots(
        paths,
        includeOffice: includeOffice,
      ).values.toSet()) {
        if (await BundledPdfTools.ownsRoot(root)) {
          await BundledPdfTools.load();
          continue;
        }
        final access = await _directories.acquireDirectory(
          root,
          readOnly: true,
        );
        active.add(access);
        _samePath(root, access.path);
      }
      return DocumentToolsAccess._(active);
    } catch (_) {
      for (final access in active.reversed) {
        await access.release();
      }
      rethrow;
    }
  }

  static void _samePath(String expected, String actual) {
    if (actual != expected) {
      throw StateError(
        'Le dossier a été déplacé. Actualisez son chemin dans Outils de contrôle locaux : $actual',
      );
    }
  }

  Future<void> release() async {
    for (final access in _active.reversed) {
      await access.release();
    }
  }
}
