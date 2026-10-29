import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'cabinet_practice_service.dart';

/// Suggestions only. Copied into a version's preparation on explicit save;
/// changing preferences never rewrites a PDF, a preparation or an approval.
/// Stored in application_settings, already included in the database backup.
class ReportPrefillSettings {
  static const classificationFields = [
    'typeCode',
    'typeSystem',
    'typeLabel',
    'classCode',
    'classSystem',
    'classLabel',
    'catalogReference',
  ];
  static const cabinetFields = ['language', ...classificationFields];
  static const practitionerFields = ['contextId', 'selfValidator'];

  // From archived ANS NOS files, not a claim about the current remote catalog:
  // JDV_J66 + ASS_X16 2024-09-27; JDV_J57 2023-09-22.
  static const followUpReport = <String, String>{
    'typeCode': '11506-3',
    'typeSystem': '2.16.840.1.113883.6.1',
    'typeLabel': 'CR ou fiche de suivi de soins par auxiliaire médical',
    'classCode': '10',
    'classSystem': '1.2.250.1.213.1.1.4.1',
    'classLabel': 'Compte rendu',
    'catalogReference':
        'ANS NOS — JDV_J66 et ASS_X16 du 27/09/2024 ; JDV_J57 du 22/09/2023 — références archivées',
  };
  // Identifiers and update stamps from the headers of the archived ANS NOS
  // files used for this preset. OIDs below identify resources, not code systems.
  // Hashes identify those exact files; they do not assert remote freshness.
  static const followUpCatalogs = <Map<String, String>>[
    {
      'name': 'JDV_J66-TypeCode-DMP',
      'oid': '1.2.250.1.213.1.1.5.7',
      'updatedAt': '20240927120000',
      'sha256':
          'a21aa78fa3d46a7425bf77a600f45624deb71a7dea34227f219dba7b485f9ba1',
      'source': 'https://mos.esante.gouv.fr/NOS/JDV_J66-TypeCode-DMP',
    },
    {
      'name': 'JDV_J57-ClassCode-DMP',
      'oid': '1.2.250.1.213.1.1.5.6',
      'updatedAt': '20230922120000',
      'sha256':
          '51d0aaec48fd1c3904611b143e9af34507935580b5a70b31769e05db700fe756',
      'source': 'https://mos.esante.gouv.fr/NOS/JDV_J57-ClassCode-DMP',
    },
    {
      'name': 'ASS_X16-CorrespondanceType-Classe-DMP',
      'oid': '1.2.250.1.213.1.1.5.587',
      'updatedAt': '20240927120000',
      'sha256':
          'e287ab087e97edf7a55acaccb798c51e6980657fb59df934a77b3187be4c7987',
      'source':
          'https://mos.esante.gouv.fr/NOS/ASS_X16-CorrespondanceType-Classe-DMP',
    },
  ];

  static bool usesArchivedPreset(Map values) =>
      followUpReport.entries.every((e) => values[e.key] == e.value);

  /// Frozen with the preparation, then with the immutable approval snapshot.
  /// An arbitrary custom reference is only recorded as a declaration.
  static String catalogIdentification(Map values) => jsonEncode({
    'schema': 1,
    'classification': {
      for (final key in classificationFields) key: values[key],
    },
    'provenance': usesArchivedPreset(values)
        ? 'ans_archived_preset'
        : 'declared',
    'resources': usesArchivedPreset(values) ? followUpCatalogs : [],
  });

  static void checkCatalogIdentification(Map values) {
    final raw = values['catalogIdentification'];
    if (raw == null || raw == '') return; // Legacy snapshots stay readable.
    final data = jsonDecode(raw as String) as Map;
    final classification = data['classification'];
    final resources = data['resources'];
    if (data['schema'] != 1 ||
        classification is! Map ||
        resources is! List ||
        classificationFields.any((key) => classification[key] != values[key]) ||
        !['ans_archived_preset', 'declared'].contains(data['provenance'])) {
      throw StateError(
        'L’identification des référentiels ne correspond pas au classement enregistré.',
      );
    }
    if (data['provenance'] == 'declared' && resources.isNotEmpty ||
        data['provenance'] == 'ans_archived_preset' && resources.length != 3) {
      throw StateError('Identification des référentiels incomplète.');
    }
    for (final resource in resources) {
      if (resource is! Map ||
          resource['name'] is! String ||
          !RegExp(r'^\d+(\.\d+)+$').hasMatch('${resource['oid']}') ||
          !RegExp(r'^\d{14}$').hasMatch('${resource['updatedAt']}') ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch('${resource['sha256']}') ||
          resource['source'] is! String) {
        throw StateError('Identification d’une ressource ANS illisible.');
      }
    }
  }

  /// Assistance always displays the captured record, never today's preset.
  static String catalogDetails(Map values) {
    final reference = (values['catalogReference'] ?? '').toString();
    final raw = values['catalogIdentification'];
    if (raw == null || raw == '') {
      return 'Référence conservée : $reference\n\nIdentifiants détaillés et empreintes non enregistrés pour cette préparation.';
    }
    try {
      checkCatalogIdentification(values);
      final data = jsonDecode(raw as String) as Map;
      if (data['provenance'] == 'declared') {
        return 'Référence conservée : $reference\n\nRéférence personnalisée déclarée. Les identifiants officiels et fichiers correspondants n’ont pas été identifiés automatiquement.';
      }
      final lines = <String>[
        'Référence conservée : $reference',
        'Identification du classement prédéfini d’après les fichiers ANS archivés. Elle ne prouve pas que ces fichiers sont les plus récents.',
      ];
      for (final resource in data['resources'] as List) {
        final stamp = resource['updatedAt'] as String;
        lines.add(
          '\n${resource['name']}\nOID : ${resource['oid']}\nMise à jour ANS : ${stamp.substring(6, 8)}/${stamp.substring(4, 6)}/${stamp.substring(0, 4)} (identifiant de date : $stamp)\nSource : ${resource['source']}\nEmpreinte SHA-256 : ${resource['sha256']}',
        );
      }
      return lines.join('\n');
    } catch (_) {
      return 'Référence conservée : $reference\n\nIdentification détaillée illisible ou incohérente ; aucune référence actuelle substituée.';
    }
  }

  static String key(String scope, String id) => 'report_prefill_${scope}_$id';

  /// Documentary defaults belong to the configured cabinet, not to a signer.
  /// The author's affiliation is checked separately for the exercise context.
  static Future<String?> configuredCabinetId(DatabaseExecutor db) async {
    if ((await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='cabinet_practices'",
    )).isEmpty) {
      return null;
    }
    final identity = await CabinetPracticeService.identity(db);
    final id = identity['organization_id'] ?? '';
    if (id.isEmpty ||
        (await db.query(
          'cabinet_practices',
          columns: ['cabinet_id'],
          where: 'cabinet_id=?',
          whereArgs: [id],
        )).isEmpty) {
      return null;
    }
    return id;
  }

  static Future<Map<String, String>> read(
    DatabaseExecutor db,
    String scope,
    String id,
  ) async {
    final fields = scope == 'cabinet' ? cabinetFields : practitionerFields;
    final rows = await db.query(
      'application_settings',
      where: 'setting_key=?',
      whereArgs: [key(scope, id)],
    );
    final values = rows.isEmpty
        ? <String, String>{}
        : Map<String, String>.from(
            jsonDecode(rows.single['setting_value'] as String),
          );
    check(scope, values);
    return {for (final field in fields) field: values[field] ?? ''};
  }

  static void check(String scope, Map<String, String> values) {
    final fields = scope == 'cabinet' ? cabinetFields : practitionerFields;
    if (!['cabinet', 'practitioner'].contains(scope) ||
        values.keys.any((k) => !fields.contains(k))) {
      throw StateError('Préférences de rapport non reconnues.');
    }
    if (scope == 'practitioner') {
      if (!['', 'yes', 'no'].contains(values['selfValidator'] ?? '')) {
        throw StateError('Choix du validateur non reconnu.');
      }
      return;
    }
    final language = values['language'] ?? '';
    if (language.isNotEmpty &&
        !RegExp(r'^[a-z]{2,3}(-[A-Z]{2})?$').hasMatch(language)) {
      throw StateError('Indiquez une langue telle que fr-FR.');
    }
    final selected = classificationFields.where(
      (k) => (values[k] ?? '').isNotEmpty,
    );
    if (selected.isNotEmpty && selected.length != classificationFields.length) {
      throw StateError(
        'Complétez le classement et sa référence, ou laissez tout le classement vide.',
      );
    }
  }

  static Future<void> save(
    Database db,
    String scope,
    String id,
    Map<String, String> values,
    Map<String, String> previous,
  ) async {
    final clean = {for (final e in values.entries) e.key: e.value.trim()};
    check(scope, clean);
    await db.transaction((tx) async {
      final current = await read(tx, scope, id);
      if (current.length != previous.length ||
          current.entries.any((e) => previous[e.key] != e.value)) {
        throw StateError(
          'Ces préférences ont changé ailleurs. Rouvrez cet écran.',
        );
      }
      if (scope == 'cabinet') {
        final identity = await CabinetPracticeService.identity(tx);
        if (identity['organization_id'] != id ||
            id.isEmpty ||
            (await tx.query(
              'cabinet_practices',
              where: 'cabinet_id=?',
              whereArgs: [id],
            )).isEmpty) {
          throw StateError(
            'Enregistrez le cabinet avant ses préférences de rapport.',
          );
        }
      } else {
        if ((await tx.query(
          'practitioners',
          where: 'practitioner_id=? AND is_active=1 AND archived_at IS NULL',
          whereArgs: [id],
        )).isEmpty) {
          throw StateError('Kiné indisponible.');
        }
        final contextId = clean['contextId'] ?? '';
        if (contextId.isNotEmpty &&
            (await tx.query(
              'document_practice_contexts',
              where: 'context_id=? AND practitioner_id=?',
              whereArgs: [contextId, id],
            )).isEmpty) {
          throw StateError('La situation doit appartenir à ce kiné.');
        }
      }
      if (current.entries.every((e) => clean[e.key] == e.value)) return;
      await tx.insert('application_settings', {
        'setting_key': key(scope, id),
        'setting_value': jsonEncode(clean),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}
