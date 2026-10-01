import 'dart:typed_data';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;
import '../patients/models/patient.dart';
import '../patients/data/patient_repository.dart';
import 'kobus_models.dart';

String cleanKobus(String value) => value.replaceAll(RegExp(r'\s+'), ' ').trim();
bool missingKobus(String value) => {
  '',
  '-',
  '--',
  '—',
  '?',
  'n/a',
  'na',
  'null',
  'inconnu',
  'inconnue',
  'non renseigné',
  'non renseigne',
  'non renseignée',
  'non renseignee',
  'néant',
  'neant',
  'aucun',
  'aucune',
  'sans objet',
  'unknown',
}.contains(cleanKobus(value).toLowerCase());

String? kobusDate(String value) {
  final s = cleanKobus(value);
  Match? m;
  int y, month, day;
  if ((m = RegExp(r'^(\d{4})(?:-|)(\d{2})(?:-|)(\d{2})$').firstMatch(s)) !=
      null) {
    if (s.length != 8 && s.length != 10) return null;
    y = int.parse(m![1]!);
    month = int.parse(m[2]!);
    day = int.parse(m[3]!);
  } else if ((m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(s)) != null) {
    day = int.parse(m![1]!);
    month = int.parse(m[2]!);
    y = int.parse(m[3]!);
  } else {
    return null;
  }
  final date = DateTime(y, month, day);
  if (y < 1 ||
      date.year != y ||
      date.month != month ||
      date.day != day ||
      date.isAfter(DateTime.now())) {
    return null;
  }
  return '${y.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

// Companion has no central checksum validator. Import only full French NIRs.
String? kobusNir(String value) {
  final v = value.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  if (!RegExp(r'^[12]\d{4}(?:\d{2}|2[AB])\d{8}$').hasMatch(v)) return null;
  final number = int.parse(
    v.substring(0, 13).replaceAll('2A', '19').replaceAll('2B', '18'),
  );
  return 97 - number % 97 == int.parse(v.substring(13)) ? v : null;
}

class KobusExcel {
  static Map<String, String> fields(Uint8List bytes) {
    final decoder = ZipDecoder();
    final archive = decoder.decodeBytes(bytes, verify: true);
    if (decoder.directory.fileHeaders.length != archive.length) {
      throw const FormatException(
        'Entrées Excel dupliquées : classeur ambigu.',
      );
    }
    if (archive.length > 10000 ||
        archive.files.fold<int>(0, (n, f) => n + f.size) > 64 * 1024 * 1024) {
      throw const FormatException('Classeur trop volumineux (limite 64 Mio).');
    }
    XmlDocument document(String name) {
      final matches = archive.files.where((f) => f.name == name).toList();
      if (matches.length != 1) {
        throw FormatException('Structure Excel incompatible : $name');
      }
      final entry = matches.single;
      final data = entry.content;
      if (getCrc32(data) != entry.crc32) {
        throw const FormatException('Classeur corrompu (CRC).');
      }
      return XmlDocument.parse(utf8.decode(data));
    }

    final sheets = document('xl/workbook.xml').descendants
        .whereType<XmlElement>()
        .where(
          (e) =>
              e.name.local == 'sheet' &&
              cleanKobus(e.getAttribute('name') ?? '') ==
                  'Informations patient',
        )
        .toList();
    if (sheets.length != 1) {
      throw const FormatException(
        'Feuille Informations patient absente ou ambiguë.',
      );
    }
    final relId = sheets.single.attributes
        .where((a) => a.name.local == 'id')
        .single
        .value;
    final rels = document('xl/_rels/workbook.xml.rels').descendants
        .whereType<XmlElement>()
        .where(
          (e) =>
              e.name.local == 'Relationship' && e.getAttribute('Id') == relId,
        )
        .toList();
    if (rels.length != 1 ||
        rels.single.getAttribute('TargetMode') == 'External') {
      throw const FormatException('Relation Excel incompatible.');
    }
    final target = rels.single.getAttribute('Target')!;
    final sheetPath = target.startsWith('/')
        ? target.substring(1)
        : p.posix.normalize(p.posix.join('xl', target));
    if (!sheetPath.startsWith('xl/')) {
      throw const FormatException('Chemin Excel incompatible.');
    }
    final strings = <String>[];
    if (archive.files.any((f) => f.name == 'xl/sharedStrings.xml')) {
      for (final si in document('xl/sharedStrings.xml').findAllElements('si')) {
        strings.add(si.findAllElements('t').map((t) => t.innerText).join());
      }
    }
    final result = <String, String>{};
    final rows = <String, Map<String, XmlElement>>{};
    for (final c in document(
      sheetPath,
    ).descendants.whereType<XmlElement>().where((e) => e.name.local == 'c')) {
      final m = RegExp(r'^([AB])(\d+)$').firstMatch(c.getAttribute('r') ?? '');
      if (m == null) continue;
      final row = rows.putIfAbsent(m[2]!, () => {});
      if (row.containsKey(m[1])) {
        throw const FormatException('Cellule Excel dupliquée.');
      }
      row[m[1]!] = c;
    }
    String value(XmlElement? c) {
      if (c == null) return '';
      if (c.findElements('f').isNotEmpty || c.getAttribute('t') == 'e') {
        throw const FormatException(
          'Formule ou erreur dans une cellule d’identité.',
        );
      }
      final t = c.getAttribute('t');
      if (t == 'inlineStr') {
        return c.findAllElements('t').map((e) => e.innerText).join();
      }
      final v = c.getElement('v')?.innerText ?? '';
      if (t == 's') return strings[int.parse(v)];
      if (t == null || t == 'n' || t == 'str' || t == 'd') return v;
      throw const FormatException('Type de cellule incompatible.');
    }

    const known = {
      'Nom de famille',
      'Prénom',
      'Date de naissance',
      'Sexe',
      'NIR',
      'Profession',
    };
    for (final row in rows.values) {
      final key = cleanKobus(value(row['A']));
      if (!known.contains(key)) continue;
      if (result.containsKey(key)) {
        throw FormatException('Libellé Excel ambigu : $key');
      }
      try {
        result[key] = cleanKobus(value(row['B']));
      } catch (_) {
        if (!{'Sexe', 'NIR', 'Profession', 'Date de naissance'}.contains(key)) {
          rethrow;
        }
        result[key] = '';
        result['_warning:$key'] = '$key illisible : non repris.';
      }
    }
    return result;
  }

  static KobusIdentity identity(Map<String, String> f) {
    final last = f['Nom de famille'] ?? '', first = f['Prénom'] ?? '';
    if (missingKobus(last) || missingKobus(first)) {
      throw const FormatException('Nom ou prénom absent ou non renseigné.');
    }
    final date = kobusDate(f['Date de naissance'] ?? '');
    final warnings = f.entries
        .where((e) => e.key.startsWith('_warning:'))
        .map((e) => e.value)
        .toList();
    if (date == null) {
      warnings.add(
        missingKobus(f['Date de naissance'] ?? '')
            ? 'Date de naissance non renseignée : fiche créée sans date.'
            : 'Date de naissance invalide : non reprise.',
      );
    }
    final rawSex = (f['Sexe'] ?? '').toUpperCase();
    final sex =
        {'H': 'M', 'M': 'M', 'HOMME': 'M', 'F': 'F', 'FEMME': 'F'}[rawSex] ??
        'U';
    if (sex == 'U') {
      warnings.add('Sexe absent ou non reconnu : conservé inconnu.');
    }
    final rawNir = f['NIR'] ?? '';
    final nir = kobusNir(rawNir);
    if (!missingKobus(rawNir) && nir == null) {
      warnings.add('NIR invalide : non repris.');
    }
    final profession = f['Profession'] ?? '';
    return KobusIdentity(
      last,
      first,
      date,
      sex: sex,
      nir: nir,
      profession: missingKobus(profession) ? null : profession,
      warnings: warnings,
    );
  }
}

String normalizeKobusName(String v) {
  var s = PatientRepository.normalizeIdentityName(v);
  const groups = {
    'ÀÁÂÃÄÅ': 'A',
    'ÈÉÊË': 'E',
    'ÌÍÎÏ': 'I',
    'ÒÓÔÕÖ': 'O',
    'ÙÚÛÜ': 'U',
    'Ç': 'C',
    'Ñ': 'N',
    'ÝŸ': 'Y',
  };
  for (final e in groups.entries) {
    for (final c in e.key.split('')) {
      s = s.replaceAll(c, e.value);
    }
  }
  return s
      .replaceAll('Œ', 'OE')
      .replaceAll('Æ', 'AE')
      .replaceAll(RegExp("['’]"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

// The import rule deliberately uses only the normalized last and first names.
String? kobusMatch(KobusIdentity identity, Patient patient) {
  return normalizeKobusName(identity.lastName) ==
              normalizeKobusName(patient.lastName) &&
          normalizeKobusName(identity.firstName) ==
              normalizeKobusName(patient.firstName)
      ? 'Nom et prénom déjà présents dans Companion.'
      : null;
}
