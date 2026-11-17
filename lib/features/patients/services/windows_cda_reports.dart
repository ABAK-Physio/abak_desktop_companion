import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Bounded report-only reply. Paths, Java arguments and reference bytes are
/// never accepted from the caller by the Windows service.
class WindowsCdaReports {
  static const inputLimit = 40 * 1024 * 1024;
  static const limit = 12 * 1024 * 1024;
  static const names = {
    'completed.txt',
    'xsd.xml',
    'xsd-error.txt',
    'profile-0.xml',
    'profile-1.xml',
    'profile-2.xml',
    'profile-3.xml',
    'profile-4.xml',
  };
  static bool hash(Object? value) =>
      value is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(value);

  static String referenceFingerprint(Map<String, String> references) {
    final files = Map<String, String>.from(references)..remove('manifest.json');
    if (files.isEmpty || files.length > 18000) {
      throw StateError('Référentiel CDA vide ou trop volumineux.');
    }
    final keys = files.keys.toList()..sort();
    final text = StringBuffer();
    for (final key in keys) {
      if (key.isEmpty ||
          key.length >= 1024 ||
          key.contains(RegExp(r'[\x00-\x1f\x7f\\:*?"<>|]')) ||
          key
              .split('/')
              .any(
                (part) =>
                    part.isEmpty ||
                    part == '.' ||
                    part == '..' ||
                    part.endsWith('.') ||
                    part.endsWith(' '),
              ) ||
          !hash(files[key])) {
        throw StateError('Empreinte de référence CDA invalide.');
      }
      // Same exclusions as LocalDocumentControlRunner.tree and the service.
      if (key.contains('.bench-') ||
          key.split('/').last.startsWith('abak-') ||
          key == 'unified-configuration.json')
        continue;
      text
        ..write(key)
        ..write('\u0000')
        ..write(files[key])
        ..write('\n');
    }
    if (text.isEmpty)
      throw StateError('Référentiel CDA sans références utilisables.');
    return sha256.convert(utf8.encode(text.toString())).toString();
  }

  static Map<String, String> identity(Map<String, Object?> configuration) {
    final references = Map<String, String>.from(
      configuration['references'] as Map,
    );
    if (!hash(references['manifest.json']) || !hash(configuration['helper'])) {
      throw StateError(
        'Configuration CDA Windows sans empreintes vérifiables.',
      );
    }
    return {
      'referenceManifestHash': references['manifest.json']!,
      'referenceFilesHash': referenceFingerprint(references),
      'helperHash': configuration['helper'] as String,
    };
  }

  static Map<String, Uint8List> decode(Uint8List packet) {
    if (packet.length < 12 ||
        packet.length > limit ||
        ascii.decode(packet.sublist(0, 8), allowInvalid: true) != 'ABAKCDR1') {
      throw StateError('Format des rapports CDA Windows invalide.');
    }
    final view = ByteData.sublistView(packet);
    var position = 8;
    int take() {
      if (position + 4 > packet.length)
        throw StateError('Rapport CDA tronqué.');
      final value = view.getUint32(position, Endian.little);
      position += 4;
      return value;
    }

    final count = take();
    if (count != 7 && count != 8) throw StateError('Rapports CDA incomplets.');
    final files = <String, Uint8List>{};
    for (var i = 0; i < count; i++) {
      final length = take(), size = take();
      if (length == 0 ||
          length > 64 ||
          size == 0 ||
          size > limit ||
          position + length + size > packet.length) {
        throw StateError('Rapport CDA incomplet ou trop volumineux.');
      }
      final name = utf8.decode(packet.sublist(position, position + length));
      position += length;
      if (!names.contains(name) || files.containsKey(name)) {
        throw StateError('Nom de rapport CDA inconnu ou dupliqué.');
      }
      final data = Uint8List.fromList(
        packet.sublist(position, position + size),
      );
      utf8.decode(data); // Reject invalid UTF-8 before creating any evidence.
      files[name] = data;
      position += size;
    }
    if (position != packet.length ||
        names
            .difference({'xsd-error.txt'})
            .difference(files.keys.toSet())
            .isNotEmpty ||
        utf8.decode(files['completed.txt']!) != 'ABAK-CDA-1') {
      throw StateError('Contrôle CDA incomplet ou non terminé.');
    }
    return Map.unmodifiable(files);
  }
}
