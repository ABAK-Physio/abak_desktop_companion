/// Offline adapters for the archived NOS formats. No download or activation.
library;

import 'dart:convert';
import 'dmp_resources.dart';

class NosImport {
  static String jdvTabs(String text) {
    final lines = const LineSplitter().convert(text);
    if (lines.length < 4) throw const FormatException('JDV incomplet.');
    final metadata = lines[1].split(';');
    if (metadata.length < 8 || metadata[1] != 'JDV') {
      throw const FormatException('En-tête JDV invalide.');
    }
    final entries = <Map<String, dynamic>>[];
    for (final line in lines.skip(3)) {
      if (line.trim().isEmpty) continue;
      final fields = line.split(';');
      if (fields.length != 3) {
        throw const FormatException('Ligne JDV invalide.');
      }
      entries.add({
        'system': fields[0],
        'code': fields[1],
        'label': fields[2],
        'active': true,
      });
    }
    final body = jsonEncode({
      'version': metadata[7].trim(),
      'entries': entries,
    });
    ValueCatalog.parse(body);
    return body;
  }

  static bool typeClassMatches(
    String x16,
    String typeSystem,
    String typeCode,
    String classSystem,
    String classCode,
  ) {
    final lines = const LineSplitter().convert(x16);
    if (lines.length < 4 || !lines[1].contains(';ASS;')) {
      throw const FormatException('Association X16 invalide.');
    }
    final systems = lines[2]
        .split(';')
        .map((s) => RegExp(r'^<([^>]+)>').firstMatch(s)?.group(1))
        .toList();
    final left = systems.indexOf(typeSystem),
        right = systems.indexOf(classSystem);
    if (left < 0 || right < 0 || left == right) return false;
    for (final line in lines.skip(3)) {
      if (line.trim().isEmpty) continue;
      final values = line.split(';');
      if (values.length < systems.length) {
        throw const FormatException('Ligne X16 invalide.');
      }
      if (values[left] == typeCode && values[right] == classCode) return true;
    }
    return false;
  }

  static bool mediaFormatMatches(String a12, String media, String format) {
    final map = jsonDecode(a12) as Map<String, dynamic>;
    for (final group in map['group'] as List) {
      // This adapter is intentionally restricted to the A12 mapping.
      if (!(group['source'] as String).endsWith(
            '/TRE-R222-MediaTypeCorpsCDANonStructure',
          ) ||
          !(group['target'] as String).endsWith('/TRE-A11-IheFormatCode')) {
        continue;
      }
      for (final element in group['element'] as List) {
        if (element['code'] == media) {
          for (final target in element['target'] as List) {
            if (target['code'] == format &&
                target['equivalence'] == 'equivalent') {
              return true;
            }
          }
        }
      }
    }
    return false;
  }
}
