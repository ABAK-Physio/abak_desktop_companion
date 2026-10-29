import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Immutable resources installed with the signed application, never downloaded
/// or executed from an arbitrary user-supplied directory.
class BundledPdfTools {
  const BundledPdfTools(this.java, this.vera, this.fingerprint);
  final String java, vera, fingerprint;

  static String? get root => Platform.isMacOS
      ? p.join(
          p.dirname(p.dirname(Platform.resolvedExecutable)),
          'Resources',
          'DmpTools',
          Abi.current() == Abi.macosArm64 ? 'arm64' : 'x86_64',
        )
      : null;

  static Future<bool> ownsRoot(String path) async {
    final base = root;
    if (base == null ||
        ![p.join(base, 'java'), p.join(base, 'vera')].contains(path)) {
      return false;
    }
    return await Directory(path).resolveSymbolicLinks() == path;
  }

  static Future<BundledPdfTools> load() async {
    final base = root;
    if (base == null) {
      throw StateError(
        'Préparation automatique disponible sur macOS uniquement.',
      );
    }
    final manifest = File(p.join(base, 'manifest.json'));
    if (!await manifest.exists()) {
      throw StateError(
        'Cette version de Companion ne contient pas les outils DMP pour ce Mac. Installez une version complète de Companion.',
      );
    }
    return verify(Directory(base));
  }

  // Public for filesystem tests; production always uses the signed bundle root.
  static Future<BundledPdfTools> verify(Directory directory) async {
    final base = directory.path;
    if (!p.isAbsolute(base) || await directory.resolveSymbolicLinks() != base) {
      throw StateError('Dossier des outils invalide.');
    }
    final manifest = File(p.join(base, 'manifest.json'));
    if (await FileSystemEntity.type(manifest.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw StateError('Manifeste des outils absent.');
    }
    final bytes = await manifest.readAsBytes();
    final data = jsonDecode(utf8.decode(bytes)) as Map;
    if (data['protocol'] != 1 || data['profile'] != 'PDF/A-1b') {
      throw StateError('Version des outils non prise en charge.');
    }
    final files = Map<String, String>.from(data['files'] as Map);
    for (final required in ['java/bin/java', 'vera/cli.jar', 'NOTICE.txt']) {
      if (!files.containsKey(required)) {
        throw StateError('Composant DMP absent : $required');
      }
    }
    final seen = <String>{};
    await for (final entry in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entry is Link) throw StateError('Lien interdit dans les outils DMP.');
      if (entry is! File) continue;
      final relative = p.relative(entry.path, from: base);
      if (relative == 'manifest.json') continue;
      seen.add(relative);
      if (files[relative] !=
          (await sha256.bind(entry.openRead()).first).toString()) {
        throw StateError(
          'Outils DMP incomplets ou modifiés. Réinstallez Companion.',
        );
      }
    }
    if (seen.length != files.length || !seen.containsAll(files.keys)) {
      throw StateError('Outils DMP incomplets. Réinstallez Companion.');
    }
    return BundledPdfTools(
      p.join(base, 'java/bin/java'),
      p.join(base, 'vera/cli.jar'),
      sha256.convert(bytes).toString(),
    );
  }
}
