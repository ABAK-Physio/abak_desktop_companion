import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Native local paths only; no drive-relative, UNC, device or config-injection paths.
class DmpRuntimePaths {
  static bool absoluteLocal(String value, {bool? windows}) {
    if (value.isEmpty ||
        value.length > 4096 ||
        RegExp(r'[\x00-\x1f\x7f"{}]').hasMatch(value)) {
      return false;
    }
    if (windows ?? Platform.isWindows) {
      return RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value) &&
          !value
              .split(RegExp(r'[\\/]'))
              .any((part) => part == '.' || part == '..');
    }
    return value.startsWith('/');
  }

  static String cpsJava(String root, {required bool windows}) {
    final context = p.Context(style: windows ? p.Style.windows : p.Style.posix);
    return context.join(root, 'java', 'bin', windows ? 'java.exe' : 'java-cps');
  }

  /// Keep a full SHA-256 binding to both inputs without two nested 64-character
  /// names on Windows. The source launcher may still be limited by MAX_PATH.
  /// macOS keeps its existing layout. No configuration or worker hash is changed.
  static String workerDirectory(
    String controlsRoot,
    String configurationHash,
    String workerHash, {
    required bool windows,
  }) {
    final digest = RegExp(r'^[0-9a-f]{64}$');
    if (!digest.hasMatch(configurationHash) || !digest.hasMatch(workerHash)) {
      throw ArgumentError('Empreinte de configuration ou de moteur invalide.');
    }
    final context = p.Context(style: windows ? p.Style.windows : p.Style.posix);
    if (windows) {
      final key = sha256.convert(utf8.encode('$configurationHash:$workerHash'));
      return context.join(controlsRoot, 'dv1-runtime', key.toString());
    }
    return context.join(
      controlsRoot,
      'dv1-runtime',
      configurationHash,
      workerHash,
    );
  }
}
