import 'dart:convert';

/// CPS3 IAS objects, ANS « Données métier CPS3 », version 1.0.2, §5.2, §5.4 et §5.5.
/// No identity, profession or practice context is inferred from INSi data.
class CpsProfile {
  const CpsProfile({
    required this.nationalId,
    required this.familyName,
    required this.givenName,
    required this.professionCode,
    required this.cardType,
    required this.situations,
  });

  final String nationalId;
  final String familyName;
  final String givenName;
  final int professionCode;
  final int cardType;
  final List<CpsSituation> situations;

  String get professionLabel => professionCode == 70
      ? 'Masseur-kinésithérapeute'
      : 'Profession CPS : $professionCode';

  factory CpsProfile.fromObjects(Map<String, List<int>> objects) {
    final name = _object(objects, 'CPS_NAME_PS', 0xe4);
    final info = _object(objects, 'CPS_INFO_PS', 0xed);
    final situations = <CpsSituation>[];
    for (var i = 1; i <= 16; i++) {
      final label = 'CPS_ACTIVITY_${i.toString().padLeft(2, '0')}_PS';
      if (!objects.containsKey(label)) continue;
      final fields = _object(objects, label, 0xee);
      final situation = CpsSituation(
        number: _number(fields, 0x83),
        mode: _number(fields, 0x80),
        status: _number(fields, 0x81),
        structureName: _optionalText(fields, 0x84),
        structureId: _optionalText(fields, 0x85),
        sector: _optionalText(fields, 0x86),
      );
      if (situations.any((s) => s.number == situation.number)) {
        throw const FormatException('Numéro de situation CPS dupliqué');
      }
      situations.add(situation);
    }
    if (situations.isEmpty) {
      throw const FormatException(
        'Aucune situation d’exercice lisible dans cette carte',
      );
    }
    return CpsProfile(
      nationalId: _text(info, 0x81),
      familyName: _text(info, 0x84),
      givenName: _text(name, 0x84),
      professionCode: _number(info, 0x82),
      cardType: _number(info, 0x80),
      situations: List.unmodifiable(situations),
    );
  }
}

class CpsSituation {
  const CpsSituation({
    required this.number,
    required this.mode,
    required this.status,
    this.structureName,
    this.structureId,
    this.sector,
  });
  final int number;
  final int mode;
  final int status;
  final String? structureName;
  final String? structureId;
  final String? sector;
}

Map<int, List<int>> _object(
  Map<String, List<int>> objects,
  String label,
  int expectedTag,
) {
  final bytes = objects[label];
  if (bytes == null) throw FormatException('Objet CPS absent : $label');
  try {
    // Cryptolib may return a fixed-size buffer, padded with zero bytes after
    // the complete outer TLV. Never trim values inside the declared object.
    final outer = _tlv(bytes, allowOuterPadding: true);
    if (outer.length != 1 || !outer.containsKey(expectedTag)) {
      throw const FormatException('Format CPS inattendu');
    }
    return _tlv(outer[expectedTag]!);
  } on FormatException catch (error) {
    throw FormatException('${error.message} — $label');
  }
}

Map<int, List<int>> _tlv(List<int> bytes, {bool allowOuterPadding = false}) {
  final fields = <int, List<int>>{};
  var offset = 0;
  while (offset < bytes.length) {
    if (allowOuterPadding &&
        fields.length == 1 &&
        bytes.skip(offset).every((byte) => byte == 0)) {
      break;
    }
    final tag = bytes[offset++];
    if (offset >= bytes.length) throw const FormatException('TLV CPS tronqué');
    var length = bytes[offset++];
    if (length >= 0x80) {
      final size = length & 0x7f;
      if (size == 0 || size > 2 || offset + size > bytes.length) {
        throw const FormatException('Longueur TLV CPS invalide');
      }
      length = 0;
      for (var i = 0; i < size; i++) {
        length = (length << 8) | bytes[offset++];
      }
    }
    if (offset + length > bytes.length || fields.containsKey(tag)) {
      throw const FormatException('Objet CPS tronqué ou champ dupliqué');
    }
    fields[tag] = bytes.sublist(offset, offset + length);
    offset += length;
  }
  return fields;
}

String? _optionalText(Map<int, List<int>> fields, int tag) {
  final value = fields[tag];
  if (value == null) return null;
  final text = latin1.decode(value).trim();
  return text.isEmpty ? null : text;
}

String _text(Map<int, List<int>> fields, int tag) =>
    _optionalText(fields, tag) ??
    (throw const FormatException('Identité CPS incomplète'));

int _number(Map<int, List<int>> fields, int tag) {
  final value = fields[tag];
  if (value == null || value.length != 1) {
    throw const FormatException('Code métier CPS absent ou invalide');
  }
  return value.single;
}
