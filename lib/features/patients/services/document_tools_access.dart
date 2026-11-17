import 'dart:io';
import 'package:file_picker/file_picker.dart';
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

  static String _root(String key, String value) =>
      rootForPlatform(key, value, windows: Platform.isWindows);

  /// Path validation only, independent of OS permissions and execution.
  /// The explicit platform lets the same rules be checked on Mac and Windows.
  static String rootForPlatform(
    String key,
    String value, {
    required bool windows,
  }) {
    final path = windows ? p.windows : p.posix;
    if (!names.containsKey(key) ||
        !path.isAbsolute(value) ||
        path.normalize(value) != value ||
        value == path.rootPrefix(value)) {
      throw StateError(
        '${names[key] ?? key} : indiquez un chemin local absolu.',
      );
    }
    if (windows && !RegExp(r'^[a-zA-Z]:\\').hasMatch(value)) {
      throw StateError('Sélectionnez une ressource sur un disque local.');
    }
    if (key == 'office' && windows) {
      if (path.basename(value).toLowerCase() != 'soffice.exe' ||
          path.basename(path.dirname(value)).toLowerCase() != 'program') {
        throw StateError('LibreOffice : sélectionnez program/soffice.exe.');
      }
      return path.dirname(value);
    }
    if (key == 'java') {
      final file = windows
          ? path.basename(value).toLowerCase()
          : path.basename(value);
      final bin = windows
          ? path.basename(path.dirname(value)).toLowerCase()
          : path.basename(path.dirname(value));
      if (file != (windows ? 'java.exe' : 'java') || bin != 'bin') {
        throw StateError(
          'Java : sélectionnez le fichier bin/${windows ? 'java.exe' : 'java'} du JDK.',
        );
      }
      final home = path.dirname(path.dirname(value));
      if (home == path.rootPrefix(home)) {
        throw StateError('Dossier Java invalide.');
      }
      return home;
    }
    if (key == 'vera') {
      final file = windows ? value.toLowerCase() : value;
      if (!file.endsWith('.jar') ||
          path.dirname(value) == path.rootPrefix(value)) {
        throw StateError('veraPDF : sélectionnez le fichier CLI .jar.');
      }
      return path.dirname(value);
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
            ? (Platform.isWindows
                  ? p.join(
                      Platform.environment['ProgramFiles'] ??
                          r'C:\Program Files',
                      'LibreOffice',
                      'program',
                      'soffice.exe',
                    )
                  : '/Applications/LibreOffice.app')
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
    if (Platform.isWindows) {
      await _checkWindowsFiles(
        paths,
        includeOffice: (paths['office'] ?? '').isNotEmpty,
      );
    }
    for (final entry in roots.entries) {
      if (await BundledPdfTools.ownsRoot(entry.value)) {
        await BundledPdfTools.load();
        continue;
      }
      if (Platform.isWindows) {
        onStep('Vérification du dossier : ${names[entry.key]}…');
        await _checkWindowsDirectory(entry.value);
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
    if (Platform.isWindows) return _chooseWindows(key, current);
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
    if (Platform.isWindows) {
      await _checkWindowsFiles(paths, includeOffice: includeOffice);
    }
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
        if (Platform.isWindows) {
          await _checkWindowsDirectory(root);
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

  static Future<void> _checkWindowsFiles(
    Map<String, String> paths, {
    required bool includeOffice,
  }) async {
    for (final key in ['java', 'vera', if (includeOffice) 'office']) {
      final value = key == 'office' && (paths[key] ?? '').isEmpty
          ? p.join(
              Platform.environment['ProgramFiles'] ?? r'C:\Program Files',
              'LibreOffice',
              'program',
              'soffice.exe',
            )
          : paths[key] ?? '';
      final root = _root(key, value);
      await _checkWindowsDirectory(root);
      if (await FileSystemEntity.type(value, followLinks: false) !=
          FileSystemEntityType.file) {
        throw StateError('${names[key]} : fichier local indisponible : $value');
      }
      final handle = await File(value).open(mode: FileMode.read);
      await handle.close();
    }
  }

  static Future<void> _checkWindowsDirectory(String root) async {
    var current = root;
    while (true) {
      final type = await FileSystemEntity.type(current, followLinks: false);
      if (type == FileSystemEntityType.link) {
        throw StateError('Lien symbolique interdit : $current');
      }
      if (type != FileSystemEntityType.directory) {
        throw StateError('Dossier local indisponible : $current');
      }
      final parent = p.dirname(current);
      if (parent == current) break;
      current = parent;
    }
    // Enumerating one entry also checks read access to an empty directory.
    await for (final _ in Directory(root).list(followLinks: false)) {
      break;
    }
  }

  static Future<String?> _chooseWindows(String key, String current) async {
    String? initial;
    if (current.isNotEmpty) {
      try {
        initial = _root(key, current);
      } on StateError {
        // Keep the picker available after invalid manual input.
      }
    }
    if (key == 'office') {
      final picked = await FilePicker.platform.pickFiles(
        dialogTitle: 'Choisir LibreOffice : program/soffice.exe',
        type: FileType.custom,
        allowedExtensions: ['exe'],
        allowMultiple: false,
        initialDirectory: initial,
      );
      final path = picked?.files.single.path;
      if (path == null) return null;
      await _checkWindowsDirectory(_root(key, path));
      return path;
    }
    final directory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choisir : ${names[key]}',
      initialDirectory: initial,
    );
    if (directory == null) return null;
    await _checkWindowsDirectory(directory);
    if (key == 'java') return p.join(directory, 'bin', 'java.exe');
    if (key == 'vera') {
      final candidates = await Directory(directory)
          .list(followLinks: false)
          .where(
            (entry) =>
                entry is File &&
                RegExp(
                  r'^cli(?:-[0-9][\w.-]*)?\.jar$',
                  caseSensitive: false,
                ).hasMatch(p.basename(entry.path)),
          )
          .toList();
      if (candidates.length != 1) {
        throw StateError(
          'Choisissez un dossier contenant un seul fichier CLI de veraPDF.',
        );
      }
      return candidates.single.path;
    }
    return directory;
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
