import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Schema v1: no floats, nullable fields, or platform-dependent timestamps.
String canonicalSnapshot(Object value) {
  Object sorted(Object v) {
    if (v is Map) {
      final keys = v.keys.cast<String>().toList()..sort();
      return {for (final k in keys) k: sorted(v[k] as Object)};
    }
    if (v is List) return v.map((e) => sorted(e as Object)).toList();
    if (v is String || v is bool || v is int) return v;
    throw ArgumentError('Type de contrat interdit');
  }

  return jsonEncode(sorted(value));
}

String snapshotHash(Object value) =>
    sha256.convert(utf8.encode(canonicalSnapshot(value))).toString();
const cdaFields = {
  'patient',
  'author',
  'structure',
  'title',
  'date',
  'confidentiality',
  'type',
  'class',
  'id',
  'setId',
  'version',
};
void checkCdaContext(Map<String, String> c) {
  if (c.length != cdaFields.length ||
      !c.keys.toSet().containsAll(cdaFields) ||
      c.values.any((v) => v.isEmpty)) {
    throw ArgumentError('Contexte CDA incomplet');
  }
  for (final key in ['patient', 'author', 'structure']) {
    if (!RegExp(r'^SIM-[A-Za-z0-9-]+$').hasMatch(c[key]!)) {
      throw ArgumentError('Contexte synthétique requis');
    }
  }
}
