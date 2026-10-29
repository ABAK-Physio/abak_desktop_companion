import 'dart:convert';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../models/episode_document_version.dart';
import 'final_pdf_document_service.dart';
import 'cnda_patient_recipe.dart';
import '../../practitioners/data/practitioner_cps_service.dart';
import '../../dmp_resources/dmp_resources.dart';
import '../../../core/settings/cabinet_practice_service.dart';
import '../../../core/settings/report_prefill_settings.dart';

typedef MedicalRow = Map<String, Object?>;

class MedicalPrefill {
  const MedicalPrefill(this.values, this.sources, this.notes);
  final Map<String, String> values, sources;
  final List<String> notes;
}

String medicalCanonical(Object? value) {
  Object? sort(Object? v) {
    if (v is Map) {
      final keys = v.keys.cast<String>().toList()..sort();
      return {for (final k in keys) k: sort(v[k])};
    }
    if (v is List) return v.map(sort).toList();
    return v;
  }

  return jsonEncode(sort(value));
}

String medicalHash(Object? v) =>
    FinalPdfDocumentService.hash(utf8.encode(medicalCanonical(v)));

class MedicalPage {
  const MedicalPage(this.png, this.hasInk);
  final Uint8List png;
  final bool hasInk;
}

abstract interface class MedicalPdfRenderer {
  Future<List<MedicalPage>> render(Uint8List bytes);
}

class PrintingMedicalRenderer implements MedicalPdfRenderer {
  @override
  Future<List<MedicalPage>> render(Uint8List bytes) async {
    final result = <MedicalPage>[];
    await for (final page in Printing.raster(
      bytes,
      dpi: 90,
    ).timeout(const Duration(seconds: 30))) {
      if (result.length >= 40) {
        throw const FinalPdfException('PDF limité à 40 pages.');
      }
      bool ink = false;
      for (var i = 0; i + 3 < page.pixels.length; i += 4) {
        if (page.pixels[i + 3] > 16 &&
            (page.pixels[i] < 245 ||
                page.pixels[i + 1] < 245 ||
                page.pixels[i + 2] < 245)) {
          ink = true;
          break;
        }
      }
      result.add(MedicalPage(await page.toPng(), ink));
    }
    return result;
  }
}

class MedicalReview {
  MedicalReview._(MedicalRow snapshot, this.pages)
    : _json = medicalCanonical(snapshot);
  final String _json;
  MedicalRow get snapshot => jsonDecode(_json) as MedicalRow;
  final List<MedicalPage> pages;
  String get digest => FinalPdfDocumentService.hash(utf8.encode(_json));
  String get versionId => (snapshot['version'] as Map)['version_id'] as String;
}

class MedicalStatus {
  const MedicalStatus(
    this.state,
    this.message, {
    this.approval,
    this.canReview = false,
  });
  final String state, message;
  final MedicalRow? approval;
  final bool canReview;
  bool get valid => state == 'approved';
}

/// Product service: real rows provided by the current database, no fixture defaults.
/// It consumes existing qualified identity. No CPS, transport or INSi dependency.
class DocumentMedicalService {
  static const reportOnlyMessage =
      'La préparation DMP est réservée aux rapports. '
      'Les bilans sont des documents internes ; les autres pièces doivent être rattachées à un rapport.';
  DocumentMedicalService({
    required this.pdf,
    MedicalPdfRenderer? renderer,
    DateTime Function()? now,
    this.checkpoint,
  }) : renderer = renderer ?? PrintingMedicalRenderer(),
       now = now ?? DateTime.now;
  final FinalPdfDocumentService pdf;
  final MedicalPdfRenderer renderer;
  final DateTime Function() now;
  final Future<void> Function(String)? checkpoint;
  static const contextFields = [
    'identifierType',
    'identifier',
    'authority',
    'professionCode',
    'professionSystem',
    'professionLabel',
    'situation',
    'setting',
    'structureType',
    'structureId',
    'structureAuthority',
    'structureName',
    'validFrom',
    'validUntil',
    'replacementFor',
    'facilityCode',
    'facilityLabel',
    'familyName',
    'givenNames',
    'cpsProfileHash',
    'cpsReadAt',
    'cpsSituationNumber',
    'cpsIssueDate',
    'cpsDatesRevision',
    ...CabinetPracticeService.bindingKeys,
  ];
  static const preparationFields = [
    'authorId',
    'validatorId',
    'contextId',
    'title',
    'clinicalDate',
    'language',
    'typeCode',
    'typeSystem',
    'typeLabel',
    'classCode',
    'classSystem',
    'classLabel',
    'catalogReference',
    'patientVisibility',
    'representativesVisibility',
    'professionalVisibility',
  ];
  static void fail(String message) => throw FinalPdfException(message);
  static String text(Map row, String key) => (row[key] ?? '').toString().trim();
  static const fieldLabels = {
    'authorId': 'auteur',
    'validatorId': 'validateur',
    'contextId': 'situation d’exercice',
    'title': 'titre clinique',
    'clinicalDate': 'date clinique',
    'language': 'langue',
    'typeCode': 'code du type',
    'typeSystem': 'système du type',
    'typeLabel': 'libellé du type',
    'classCode': 'code de classe',
    'classSystem': 'système de classe',
    'classLabel': 'libellé de classe',
    'catalogReference': 'référence du référentiel',
    'identifierType': 'type d’identifiant professionnel',
    'identifier': 'identifiant professionnel',
    'authority': 'autorité de l’identifiant',
    'professionCode': 'code profession',
    'professionSystem': 'système de codage de la profession',
    'professionLabel': 'profession',
    'situation': 'situation d’exercice',
    'setting': 'cadre d’exercice',
    'structureType': 'type de structure',
    'structureId': 'identifiant de structure',
    'structureAuthority': 'autorité de structure',
    'structureName': 'nom de structure',
    'validFrom': 'début d’exercice',
    'ins_number': 'matricule INS',
    'ins_key': 'clé INS',
    'ins_oid': 'autorité INS',
    'birth_last_name': 'nom de naissance',
    'birth_first_names': 'prénoms de naissance',
    'birth_date': 'date de naissance',
    'sex_code': 'sexe',
    'birth_place_code': 'lieu de naissance',
    'identity_validation_method': 'preuve de qualification',
    'identity_validated_by': 'auteur de la qualification',
    'patientVisibility': 'visibilité au patient',
    'representativesVisibility': 'visibilité aux représentants',
    'professionalVisibility': 'visibilité aux professionnels',
  };
  static void requiredFields(Map row, Iterable<String> fields) {
    for (final key in fields) {
      if (text(row, key).isEmpty) {
        fail('Donnée requise absente : ${fieldLabels[key] ?? key}.');
      }
    }
  }

  static Map<String, String> normalize(
    Map<String, String> data,
    List<String> fields,
  ) {
    if (data.keys.any((k) => !fields.contains(k))) {
      fail('Champ de préparation non reconnu.');
    }
    return {for (final f in fields) f: (data[f] ?? '').trim()};
  }

  static DateTime parseDate(String value) {
    if (!RegExp(
      r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(Z|[+-]\d{2}:\d{2})$',
    ).hasMatch(value)) {
      fail(
        'Date complète avec fuseau nécessaire (ex. AAAA-MM-JJThh:mm:ss+02:00).',
      );
    }
    final d = DateTime.tryParse(value);
    if (d == null) fail('Date invalide.');
    // DateTime.parse normalizes impossible calendar dates, which are not accepted here.
    final day = int.parse(value.substring(8, 10)),
        month = int.parse(value.substring(5, 7)),
        year = int.parse(value.substring(0, 4));
    if (month < 1 ||
        month > 12 ||
        day < 1 ||
        day > DateTime.utc(year, month + 1, 0).day ||
        int.parse(value.substring(11, 13)) > 23 ||
        int.parse(value.substring(14, 16)) > 59 ||
        int.parse(value.substring(17, 19)) > 59) {
      fail('Date civile invalide.');
    }
    if (!value.endsWith('Z')) {
      final zoneHour = int.parse(value.substring(20, 22)),
          zoneMinute = int.parse(value.substring(23, 25));
      if (zoneHour > 14 ||
          zoneMinute > 59 ||
          zoneHour == 14 && zoneMinute != 0) {
        fail('Décalage horaire invalide.');
      }
    }
    return d!;
  }

  static Future<MedicalRow> one(
    DatabaseExecutor db,
    String table,
    String column,
    String id,
  ) async {
    final rows = await db.query(table, where: '$column = ?', whereArgs: [id]);
    if (rows.length != 1) fail('Source indisponible : $table.');
    return rows.single;
  }

  static Future<MedicalRow> activePractitioner(
    DatabaseExecutor db,
    String id,
  ) async {
    final row = await one(db, 'practitioners', 'practitioner_id', id);
    if (row['is_active'] != 1 ||
        row['archived_at'] != null ||
        text(row, 'display_name').isEmpty) {
      fail('Professionnel inactif, archivé ou incomplet.');
    }
    return row;
  }

  Future<MedicalRow> information(EpisodeDocumentVersion version) async {
    final db = await pdf.database();
    return db.transaction((t) async {
      final rows = await _version(t, version.id);
      final report = await _report(t, rows['version'] as Map);
      final identity = await t.query(
        'patient_fr_health_identity',
        where: 'patient_id = ?',
        whereArgs: [version.values['patient_id']],
      );
      return {
        ...rows,
        'report': report,
        'identity': identity.isEmpty ? null : identity.single,
      };
    });
  }

  Future<MedicalRow?> cpsInformation(String practitionerId) async =>
      PractitionerCpsService.stored(await pdf.database(), practitionerId);

  static String readableFileTitle(String path) {
    if (path.trim().isEmpty) return '';
    final base = p.basenameWithoutExtension(path.trim());
    if (['document', 'source', 'output'].contains(base.toLowerCase()) ||
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f-]{27}$',
          caseSensitive: false,
        ).hasMatch(base)) {
      return '';
    }
    return base;
  }

  /// Civil age from the patient record, not from an INSi lookup. Reject dates
  /// that DateTime would silently normalize (for example 31 February).
  static int? patientAge(String birthDate, DateTime today) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthDate)) return null;
    final birth = DateTime.tryParse(birthDate);
    if (birth == null ||
        birth.year < 1 ||
        birth.toIso8601String().substring(0, 10) != birthDate) {
      return null;
    }
    final date = today.toLocal();
    final day = DateTime(date.year, date.month, date.day);
    if (birth.isAfter(day)) return null;
    return date.year -
        birth.year -
        ((date.month < birth.month ||
                date.month == birth.month && date.day < birth.day)
            ? 1
            : 0);
  }

  /// Read only the locally captured DMP parameters, without activating the
  /// native configuration, certificates, card or transport. An unconfigured
  /// installation uses 18 solely as a form suggestion; deposit policy is still
  /// checked independently. An unusable existing configuration never falls back.
  Future<({int? age, String source})> _visibilityMajority(
    DatabaseExecutor db,
  ) async {
    const preparationDefault = (
      age: 18,
      source: 'seuil de préparation de 18 ans, paramètres DMP non configurés',
    );
    try {
      if ((await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='document_dv1_configurations'",
      )).isEmpty) {
        return preparationDefault;
      }
      final rows = await db.query(
        'document_dv1_configurations',
        orderBy: 'revision DESC',
        limit: 1,
      );
      if (rows.isEmpty) return preparationDefault;
      final row = rows.single;
      final data = jsonDecode(row['data_json'] as String) as Map;
      final resource = data['resources']['parameters'] as Map;
      final bytes = base64Decode(resource['body'] as String);
      final checked = DateTime.parse(
        data['fields']['parametersCheckedAt'] as String,
      ).toUtc();
      final current = now().toUtc();
      if (data['schema'] != 1 ||
          data['environment'] != 'DV1' ||
          medicalHash(data) != row['data_hash'] ||
          FinalPdfDocumentService.hash(bytes) != resource['sha256'] ||
          checked.isAfter(current) ||
          current.difference(checked) >= const Duration(days: 7)) {
        throw const FormatException('Paramètres locaux non utilisables.');
      }
      final age = DmpParameters.parse(utf8.decode(bytes)).majority;
      return (age: age, source: 'seuil des paramètres DMP locaux : $age ans');
    } catch (_) {
      return (
        age: null,
        source:
            'Paramètres DMP locaux périmés ou illisibles : choisissez la visibilité aux représentants légaux.',
      );
    }
  }

  /// Read-only suggestions for empty fields, never an approval or a write.
  /// A saved version is only changed when the user saves its preparation.
  Future<MedicalPrefill> prefill(
    EpisodeDocumentVersion version,
    Map<String, String> draft,
  ) async => (await pdf.database()).transaction((db) async {
    final values = Map<String, String>.from(draft);
    final sources = <String, String>{};
    final notes = <String>[];
    void propose(String key, String value, String source) {
      if ((values[key] ?? '').trim().isEmpty && value.trim().isNotEmpty) {
        values[key] = value.trim();
        sources[key] = source;
      }
    }

    final rows = await _version(db, version.id);
    final report = await _report(db, rows['version'] as Map);
    propose(
      'patientVisibility',
      'visible',
      'Visible par défaut, à confirmer ou modifier pour ce rapport',
    );
    propose(
      'professionalVisibility',
      'visible',
      'Visible par défaut pour les professionnels disposant des droits requis',
    );
    if ((values['representativesVisibility'] ?? '').trim().isEmpty) {
      final birth = text(rows['patient'] as Map, 'birth_date');
      final age = patientAge(birth, now());
      if (age == null) {
        sources['representativesVisibility'] = birth.isEmpty
            ? 'Date de naissance absente de la fiche patient : choix manuel requis'
            : 'Date de naissance invalide ou future dans la fiche patient : choix manuel requis';
      } else {
        final majority = await _visibilityMajority(db);
        if (majority.age == null) {
          sources['representativesVisibility'] = majority.source;
        } else {
          final minor = age < majority.age!;
          propose(
            'representativesVisibility',
            minor ? 'visible' : 'sans objet',
            'Proposition d’après la fiche patient : $age ans aujourd’hui, ${majority.source}. '
                '${minor ? 'Visible en connexion normale, à vérifier selon la confidentialité du rapport.' : 'Sans objet proposé pour un majeur, à adapter si nécessaire.'}',
          );
        }
      }
    }
    propose(
      'authorId',
      text(report, 'author_practitioner_id'),
      'Rédacteur enregistré du rapport',
    );
    final pdfTitle = readableFileTitle(
      text(rows['document'] as Map, 'file_path'),
    );
    final docxTitle = readableFileTitle(text(report, 'docx_file_name'));
    propose(
      'title',
      pdfTitle.isNotEmpty
          ? pdfTitle
          : docxTitle.isNotEmpty
          ? docxTitle
          : text(report, 'title'),
      pdfTitle.isNotEmpty
          ? 'Nom du fichier PDF, sans extension'
          : docxTitle.isNotEmpty
          ? 'Nom du fichier DOCX, sans extension (le PDF conservé porte un nom technique)'
          : 'Titre enregistré du rapport, aucun nom de fichier lisible disponible',
    );
    final reportDate = report['report_date'];
    if (reportDate is int && reportDate > 0) {
      final date = DateTime.fromMillisecondsSinceEpoch(reportDate);
      if (!date.isAfter(now())) {
        final offset = date.timeZoneOffset.inMinutes;
        final zone =
            '${offset < 0 ? '-' : '+'}${(offset.abs() ~/ 60).toString().padLeft(2, '0')}:${(offset.abs() % 60).toString().padLeft(2, '0')}';
        propose(
          'clinicalDate',
          '${date.toIso8601String().substring(0, 19)}$zone',
          'Date enregistrée du rapport ; à corriger si elle diffère de la date clinique du PDF',
        );
      }
    }
    final cabinetId = await ReportPrefillSettings.configuredCabinetId(db);
    if (cabinetId != null) {
      final defaults = await ReportPrefillSettings.read(
        db,
        'cabinet',
        cabinetId,
      );
      propose(
        'language',
        defaults['language']!,
        'Langue habituelle du cabinet',
      );
      // Never mix two different classification tuples.
      if (ReportPrefillSettings.classificationFields.every(
        (key) =>
            (values[key] ?? '').trim().isEmpty ||
            values[key]!.trim() == defaults[key],
      )) {
        for (final key in ReportPrefillSettings.classificationFields) {
          propose(
            key,
            defaults[key]!,
            'Classement habituel du cabinet, à vérifier pour ce rapport',
          );
        }
      }
      if (defaults.values.every((v) => v.isEmpty)) {
        notes.add(
          'La langue et le classement habituels peuvent être enregistrés dans les paramètres du cabinet.',
        );
      }
    }
    final authorId = values['authorId'] ?? '';
    if (authorId.isEmpty) {
      notes.add(
        'Choisissez le rédacteur du rapport pour reprendre ses paramètres.',
      );
      return MedicalPrefill(values, sources, notes);
    }
    if (text(report, 'author_practitioner_id').isNotEmpty &&
        authorId != report['author_practitioner_id']) {
      notes.add(
        'L’auteur sélectionné diffère du rédacteur du rapport : aucun paramètre professionnel repris.',
      );
      return MedicalPrefill(values, sources, notes);
    }
    final author = await activePractitioner(db, authorId);
    final prefs = await ReportPrefillSettings.read(
      db,
      'practitioner',
      authorId,
    );
    if (prefs['selfValidator'] == 'yes') {
      propose(
        'validatorId',
        authorId,
        'Préférence du kiné : valider ses propres rapports',
      );
    }
    if ((values['contextId'] ?? '').isEmpty) {
      final candidates = await db.query(
        'document_practice_contexts',
        where: 'practitioner_id=?',
        whereArgs: [authorId],
      );
      final preferred = prefs['contextId']!;
      final usable = <MedicalRow>[];
      for (final candidate in candidates) {
        if (preferred.isNotEmpty && candidate['context_id'] != preferred) {
          continue;
        }
        try {
          final data = jsonDecode(candidate['data_json'] as String) as Map;
          checkContext(data);
          await PractitionerCpsService.verifyContext(db, author, data);
          final boundCabinet = await CabinetPracticeService.verifyContext(
            db,
            authorId,
            data,
          );
          if (text(author, 'professional_id').isNotEmpty &&
              !PractitionerCpsService.sameIdentifier(
                text(author, 'professional_id'),
                text(data, 'identifier'),
              )) {
            continue;
          }
          final current = now();
          final clinicalText = values['clinicalDate'] ?? '';
          final instants = [
            current,
            if (clinicalText.isNotEmpty) parseDate(clinicalText),
          ];
          final days = [
            current.toLocal().toIso8601String().substring(0, 10),
            if (clinicalText.isNotEmpty) clinicalText.substring(0, 10),
          ];
          final end = text(data, 'validUntil').isEmpty
              ? null
              : parseDate(data['validUntil']);
          var valid = true;
          for (var index = 0; index < instants.length; index++) {
            if (beforeExerciseStart(
                  instants[index],
                  text(data, 'validFrom'),
                  days[index],
                ) ||
                end != null && !instants[index].isBefore(end)) {
              valid = false;
            }
            if (boundCabinet != null) {
              CabinetPracticeService.checkPeriod(boundCabinet, days[index]);
            }
          }
          if (valid) usable.add(candidate);
        } catch (_) {
          // Invalid/obsolete contexts remain available for explicit correction,
          // but are never proposed as the current exercise situation.
        }
      }
      if (usable.length == 1) {
        propose(
          'contextId',
          usable.single['context_id'] as String,
          preferred.isEmpty
              ? 'Seule situation enregistrée correspondant au kiné, au cabinet et aux dates'
              : 'Situation habituelle enregistrée dans la fiche du kiné',
        );
      } else if (preferred.isNotEmpty) {
        notes.add(
          'La situation habituelle doit être actualisée dans la fiche du kiné avant de pouvoir être reprise.',
        );
      } else if (usable.length > 1) {
        notes.add(
          'Plusieurs situations conviennent : choisissez-en une, ou définissez la situation habituelle dans la fiche du kiné.',
        );
      } else {
        notes.add(
          'Complétez ou actualisez la situation d’exercice du kiné ; aucune situation compatible n’a été reprise.',
        );
      }
    }
    return MedicalPrefill(values, sources, notes);
  });

  Future<MedicalRow?> cpsDatesInformation(String practitionerId) async =>
      PractitionerCpsService.storedDates(await pdf.database(), practitionerId);

  Future<MedicalRow> _report(DatabaseExecutor db, Map version) async {
    final report = await one(
      db,
      'care_episode_reports',
      'report_id',
      version['source_id'] as String,
    );
    if (report['care_episode_id'] != version['episode_id'] ||
        report['archived_at'] != null ||
        FinalPdfDocumentService.hash(utf8.encode(jsonEncode(report))) !=
            version['source_revision']) {
      fail(
        'Le rapport a changé depuis la conversion. Créez une nouvelle version du PDF.',
      );
    }
    return report;
  }

  /// Rechecked inside the CPS import transaction; never changes the report author.
  Future<void> checkReportAuthor(
    DatabaseExecutor db,
    EpisodeDocumentVersion version,
    String id,
  ) async {
    final rows = await _version(db, version.id);
    final report = await _report(db, rows['version'] as Map);
    if (report['author_practitioner_id'] != null &&
        report['author_practitioner_id'] != id) {
      fail(
        'Le kiné sélectionné ne correspond pas à l’auteur enregistré du rapport. Aucun remplacement automatique.',
      );
    }
  }

  Future<List<MedicalRow>> practitioners() async =>
      (await pdf.database()).query(
        'practitioners',
        where: 'is_active = 1 AND archived_at IS NULL',
        orderBy: 'display_name',
      );
  Future<List<MedicalRow>> contexts(String practitioner) async =>
      (await pdf.database()).query(
        'document_practice_contexts',
        where: 'practitioner_id = ?',
        whereArgs: [practitioner],
      );
  Future<MedicalRow?> preparation(String versionId) async {
    final rows = await (await pdf.database()).query(
      'document_preparations',
      where: 'version_id = ?',
      whereArgs: [versionId],
    );
    return rows.isEmpty ? null : rows.single;
  }

  static const structureTypeLabels = {
    'FINESS': 'FINESS',
    'SIRET': 'SIRET',
    'cabinet': 'Cabinet',
    'autre': 'Autre',
  };

  static String normalizeStructureType(String value) {
    final trimmed = value.trim();
    return structureTypeLabels.keys
            .where((key) => key.toLowerCase() == trimmed.toLowerCase())
            .firstOrNull ??
        trimmed;
  }

  void checkContext(Map data) {
    requiredFields(data, [
      'identifierType',
      'identifier',
      'authority',
      'professionCode',
      'professionSystem',
      'professionLabel',
      'situation',
      'setting',
      'structureType',
      'structureId',
      'structureAuthority',
      'structureName',
    ]);
    if (!['RPPS', 'ADELI', 'IDNPS', 'autre'].contains(data['identifierType'])) {
      fail('Type d’identifiant professionnel non reconnu.');
    }
    if (!structureTypeLabels.containsKey(data['structureType'])) {
      fail(
        'Type de structure non reconnu : choisissez FINESS, SIRET, Cabinet ou Autre.',
      );
    }
    if (data['identifierType'] == 'RPPS' &&
        !RegExp(r'^\d{11}$').hasMatch(data['identifier'])) {
      fail('Identifiant RPPS : 11 chiffres attendus.');
    }
    if (data['identifierType'] == 'ADELI' &&
        !RegExp(r'^\d{9}$').hasMatch(data['identifier'])) {
      fail('Identifiant ADELI : 9 chiffres attendus.');
    }
    final startText = text(data, 'validFrom');
    final start = startText.isEmpty ? null : parseExerciseDate(startText);
    final end = text(data, 'validUntil').isEmpty
        ? null
        : parseDate(data['validUntil']);
    if (start != null &&
        end != null &&
        (startText.length == 10
            ? text(data, 'validUntil').substring(0, 10).compareTo(startText) < 0
            : !end.isAfter(start))) {
      fail('Période d’exercice incohérente.');
    }
    if (text(data, 'replacementFor').isNotEmpty &&
        (start == null || end == null)) {
      fail('Un remplacement doit avoir une date de début et une date de fin.');
    }
  }

  /// New declarations use a civil day; earlier timestamp contexts remain readable.
  static DateTime parseExerciseDate(String value) {
    if (value.length != 10) return parseDate(value);
    final date = DateTime.tryParse(value);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
        date == null ||
        date.year < 1 ||
        date.toIso8601String().substring(0, 10) != value) {
      fail('Date de début d’exercice invalide (AAAA-MM-JJ).');
    }
    return date!;
  }

  static bool beforeExerciseStart(
    DateTime instant,
    String start,
    String civilDay,
  ) {
    if (start.isEmpty) return false;
    // Compare calendar days without manufacturing a time or UTC offset.
    return start.length == 10
        ? civilDay.compareTo(start) < 0
        : instant.isBefore(parseDate(start));
  }

  Future<MedicalRow> saveContext({
    String? id,
    required String practitionerId,
    required Map<String, String> data,
    required int expectedRevision,
  }) async {
    final normalized = normalize(data, contextFields);
    normalized['structureType'] = normalizeStructureType(
      normalized['structureType']!,
    );
    checkContext(normalized);
    return (await pdf.database()).transaction((txn) async {
      final practitioner = await activePractitioner(txn, practitionerId);
      await PractitionerCpsService.verifyContext(txn, practitioner, normalized);
      await CabinetPracticeService.verifyContext(
        txn,
        practitionerId,
        normalized,
      );
      MedicalRow? old = id == null
          ? null
          : await one(txn, 'document_practice_contexts', 'context_id', id);
      if ((old?['revision'] ?? 0) != expectedRevision ||
          old != null && old['practitioner_id'] != practitionerId) {
        fail('Contexte modifié ailleurs : rechargez-le.');
      }
      if (old != null &&
          medicalCanonical(jsonDecode(old['data_json'] as String)) ==
              medicalCanonical(normalized)) {
        return old;
      }
      final row = <String, Object?>{
        'context_id': id ?? const Uuid().v4(),
        'practitioner_id': practitionerId,
        'revision': expectedRevision + 1,
        'data_json': medicalCanonical(normalized),
        'updated_at': now().millisecondsSinceEpoch,
      };
      if (old == null) {
        await txn.insert('document_practice_contexts', row);
      } else {
        await txn.update(
          'document_practice_contexts',
          row,
          where: 'context_id = ?',
          whereArgs: [id],
        );
      }
      return row;
    });
  }

  void checkPreparation(Map data) {
    requiredFields(data, preparationFields);
    ReportPrefillSettings.checkCatalogIdentification(data);
    final clinical = parseDate(data['clinicalDate']);
    if (clinical.isAfter(now())) {
      fail('La date clinique ne peut pas être future.');
    }
    if (!RegExp(r'^[a-z]{2,3}(-[A-Z]{2})?$').hasMatch(data['language'])) {
      fail('Langue attendue : code, par exemple fr-FR.');
    }
    if (!['visible', 'invisible'].contains(data['patientVisibility']) ||
        ![
          'visible',
          'invisible',
          'sans objet',
        ].contains(data['representativesVisibility']) ||
        !['visible', 'masqué'].contains(data['professionalVisibility'])) {
      fail('Visibilité documentaire non définie.');
    }
  }

  Future<MedicalRow> savePreparation(
    EpisodeDocumentVersion version,
    Map<String, String> data, {
    required int expectedRevision,
  }) async {
    final normalized = normalize(data, [
      ...preparationFields,
      'catalogIdentification',
    ]);
    // Metadata is derived here or preserved from storage, never trusted from
    // editable form fields. Historical snapshots without it are not relabelled.
    normalized.remove('catalogIdentification');
    checkPreparation(normalized);
    await pdf.verifiedFile(version);
    return (await pdf.database()).transaction((txn) async {
      await _version(txn, version.id);
      await checkReportAuthor(txn, version, normalized['authorId']!);
      await activePractitioner(txn, normalized['authorId']!);
      await activePractitioner(txn, normalized['validatorId']!);
      final context = await one(
        txn,
        'document_practice_contexts',
        'context_id',
        normalized['contextId']!,
      );
      if (context['practitioner_id'] != normalized['authorId']) {
        fail('Le contexte d’exercice ne correspond pas à l’auteur.');
      }
      final old = await txn.query(
        'document_preparations',
        where: 'version_id = ?',
        whereArgs: [version.id],
      );
      if ((old.isEmpty ? 0 : old.single['revision']) != expectedRevision) {
        fail('Préparation modifiée ailleurs : rechargez-la.');
      }
      final previous = old.isEmpty
          ? null
          : jsonDecode(old.single['data_json'] as String) as Map;
      if (previous?['dv1Replacement'] != null) {
        normalized['dv1Replacement'] = previous!['dv1Replacement'] as String;
      }
      final sameClassification =
          previous != null &&
          ReportPrefillSettings.classificationFields.every(
            (key) => previous[key] == normalized[key],
          );
      if (sameClassification) {
        if (previous['catalogIdentification'] != null) {
          normalized['catalogIdentification'] =
              previous['catalogIdentification'] as String;
        }
      } else {
        normalized['catalogIdentification'] =
            ReportPrefillSettings.catalogIdentification(normalized);
      }
      ReportPrefillSettings.checkCatalogIdentification(normalized);
      if (previous != null &&
          medicalCanonical(previous) == medicalCanonical(normalized)) {
        return old.single;
      }
      final row = <String, Object?>{
        'version_id': version.id,
        'revision': expectedRevision + 1,
        'data_json': medicalCanonical(normalized),
        'updated_at': now().millisecondsSinceEpoch,
      };
      if (old.isEmpty) {
        await txn.insert('document_preparations', row);
      } else {
        await txn.update(
          'document_preparations',
          row,
          where: 'version_id = ?',
          whereArgs: [version.id],
        );
      }
      return row;
    });
  }

  Future<MedicalRow> _version(DatabaseExecutor db, String id) async {
    final version = await one(
      db,
      'episode_document_versions',
      'version_id',
      id,
    );
    if (version['source_kind'] != 'report' || version['source_id'] == null) {
      fail(reportOnlyMessage);
    }
    final doc = await one(
      db,
      'episode_documents',
      'document_id',
      version['document_id'] as String,
    );
    final episode = await one(
      db,
      'care_episodes',
      'care_episode_id',
      version['episode_id'] as String,
    );
    final patient = await one(
      db,
      'patients',
      'patient_id',
      version['patient_id'] as String,
    );
    if (doc['archived_at'] != null ||
        episode['archived_at'] != null ||
        patient['archived_at'] != null) {
      fail('Pièce, épisode ou patient archivé.');
    }
    if (doc['case_id'] != version['episode_id'] ||
        episode['patient_id'] != version['patient_id']) {
      fail('Rattachement de la pièce modifié.');
    }
    final root = await pdf.root();
    if (p.normalize(text(doc, 'file_path')) !=
        p.normalize(p.join(root.path, version['relative_path'] as String))) {
      fail(
        'La pièce ne référence plus cette copie PDF. Réimportez le PDF final.',
      );
    }
    final latest = await db.query(
      'episode_document_versions',
      where: 'document_id = ?',
      whereArgs: [version['document_id']],
      orderBy: 'sequence_number DESC',
      limit: 1,
    );
    if (latest.single['version_id'] != id) {
      fail('Version remplacée : sélectionner le PDF courant.');
    }
    return {
      'version': version,
      'document': doc,
      'episode': episode,
      'patient': patient,
    };
  }

  Future<MedicalRow> _snapshot(DatabaseExecutor db, String id) async {
    final result = await _version(db, id);
    final version = result['version'] as Map;
    await pdf.verifyConversionEvidence(
      db,
      EpisodeDocumentVersion(Map<String, Object?>.from(version)),
    );
    final preparations = await db.query(
      'document_preparations',
      where: 'version_id=?',
      whereArgs: [id],
    );
    if (preparations.isEmpty) {
      fail(
        'Le contexte professionnel et documentaire de cette version reste à compléter et enregistrer.',
      );
    }
    final prep = preparations.single;
    final data = jsonDecode(prep['data_json'] as String) as Map;
    checkPreparation(data);
    final author = await activePractitioner(db, data['authorId']);
    await checkReportAuthor(
      db,
      EpisodeDocumentVersion(Map<String, Object?>.from(version)),
      data['authorId'],
    );
    final validator = await activePractitioner(db, data['validatorId']);
    final context = await one(
      db,
      'document_practice_contexts',
      'context_id',
      data['contextId'],
    );
    if (context['practitioner_id'] != data['authorId']) {
      fail('Contexte et auteur incohérents.');
    }
    final professional = jsonDecode(context['data_json'] as String) as Map;
    checkContext(professional);
    final cps = await PractitionerCpsService.verifyContext(
      db,
      author,
      professional,
    );
    final cabinet = await CabinetPracticeService.verifyContext(
      db,
      data['authorId'],
      professional,
    );
    if (text(author, 'professional_id').isNotEmpty &&
        !(cps == null
            ? text(author, 'professional_id') ==
                  text(professional, 'identifier')
            : PractitionerCpsService.sameIdentifier(
                text(author, 'professional_id'),
                text(professional, 'identifier'),
              ))) {
      fail(
        'Identifiant déclaré différent de celui de l’auteur dans l’annuaire.',
      );
    }
    final start = text(professional, 'validFrom');
    final end = text(professional, 'validUntil').isEmpty
        ? null
        : parseDate(professional['validUntil']);
    final current = now();
    if (beforeExerciseStart(
          current,
          start,
          current.toLocal().toIso8601String().substring(0, 10),
        ) ||
        end != null && !current.isBefore(end)) {
      fail('Contexte d’exercice expiré ou pas encore valide.');
    }
    final clinical = parseDate(data['clinicalDate']);
    if (cabinet != null) {
      CabinetPracticeService.checkPeriod(
        cabinet,
        current.toLocal().toIso8601String().substring(0, 10),
      );
      CabinetPracticeService.checkPeriod(
        cabinet,
        (data['clinicalDate'] as String).substring(0, 10),
      );
    }
    if (beforeExerciseStart(
          clinical,
          start,
          (data['clinicalDate'] as String).substring(0, 10),
        ) ||
        end != null && !clinical.isBefore(end)) {
      fail('Date clinique hors de la période d’exercice déclarée.');
    }
    final identities = await db.query(
      'patient_fr_health_identity',
      where: 'patient_id = ?',
      whereArgs: [version['patient_id']],
    );
    if (identities.isEmpty) {
      fail(
        'Les informations de qualification de l’identité ne sont pas enregistrées pour ce patient. '
        'Ouvrez sa fiche, rubrique « Identité et qualification », pour les compléter. '
        'Le contexte du rapport peut être enregistré et le PDF consulté séparément. '
        'Dans le parcours actuel de Companion, une identité qualifiée est nécessaire avant la revue et la validation médicale.',
      );
    }
    if (identities.length != 1) {
      fail(
        'Plusieurs fiches d’identité correspondent à ce patient. Faites vérifier le dossier avant de poursuivre.',
      );
    }
    final identity = identities.single;
    final recipe = CndaPatientRecipe.read(identity);
    if (recipe != null) {
      CndaPatientRecipe.check(identity, recipe);
    } else {
      if (identity['identity_status'] != 'qualified' ||
          identity['identity_doubtful'] != 0 ||
          identity['identity_fictitious'] == 1 ||
          identity['ins_traits_current'] == 0) {
        fail(
          'L’identité du patient ne remplit pas les conditions de qualification de ce parcours. '
          'Vérifiez son statut dans la fiche patient, rubrique « Identité et qualification ». '
          'Enregistrer le contexte ne qualifie pas l’identité. La consultation simple du PDF reste disponible.',
        );
      }
      requiredFields(identity, [
        'ins_number',
        'ins_key',
        'ins_oid',
        'birth_last_name',
        'birth_first_names',
        'birth_date',
        'sex_code',
        'birth_place_code',
        'identity_validation_method',
        'identity_validated_by',
      ]);
      if (identity['ins_oid'] != '1.2.250.1.213.1.4.10') {
        fail('Identifiant NIA ou autorité INS non prise en charge.');
      }
      if (identity['identity_validated_at'] == null ||
          identity['ins_retrieved_at'] == null) {
        fail('Provenance de qualification incomplète.');
      }
    }
    // Consume qualification, never claim to perform an INSi check or alter identity.
    MedicalRow? source;
    if (version['source_kind'] == 'report' ||
        version['source_kind'] == 'assessment') {
      final kind = version['source_kind'] as String;
      source = await one(
        db,
        kind == 'report' ? 'care_episode_reports' : 'care_episode_assessments',
        '${kind}_id',
        version['source_id'],
      );
      if (source['care_episode_id'] != version['episode_id'] ||
          source['archived_at'] != null) {
        fail('Origine clinique déplacée ou archivée.');
      }
      if (FinalPdfDocumentService.hash(utf8.encode(jsonEncode(source))) !=
          version['source_revision']) {
        fail(
          'Bilan ou rapport modifié depuis l’import : réimporter le PDF final.',
        );
      }
      if (source['author_practitioner_id'] != null &&
          source['author_practitioner_id'] != data['authorId']) {
        fail('Auteur sélectionné différent de l’auteur du bilan ou rapport.');
      }
    }
    final dependencies = <List<String>>[
      ['patients', version['patient_id']],
      ['patient_fr_health_identity', version['patient_id']],
      ['care_episodes', version['episode_id']],
      ['episode_documents', version['document_id']],
      ['document_preparations', id],
      ['document_practice_contexts', data['contextId']],
      ['practitioners', data['authorId']],
      ['practitioners', data['validatorId']],
      if (cps != null) ['practitioner_cps_profiles', data['authorId']],
      if (cps != null) ['practitioner_cps_dates', data['authorId']],
      if (cabinet != null) ...[
        ['cabinet_practices', professional['cabinetId']],
        ['cabinet_identity', professional['cabinetId']],
        [
          'practitioner_cabinet_memberships',
          professional['cabinetMembershipId'],
        ],
      ],
      if (source != null)
        [
          version['source_kind'] == 'report'
              ? 'care_episode_reports'
              : 'care_episode_assessments',
          version['source_id'],
        ],
    ];
    final epoch = await db.rawQuery(
      'SELECT MAX(change_id) AS epoch FROM document_medical_changes WHERE ${dependencies.map((_) => '(source_table=? AND source_id=?)').join(' OR ')}',
      dependencies.expand((e) => e).toList(),
    );
    return {
      ...result,
      'dependencyEpoch': epoch.single['epoch'] ?? 0,
      'preparation': prep,
      'identity': recipe == null
          ? identity
          : CndaPatientRecipe.documentIdentity(identity, recipe),
      'cndaRecipe': ?recipe,
      'author': author,
      'validator': validator,
      'practice': context,
      'cabinetAffiliation': ?cabinet,
      'clinicalSource': source,
      'professionalProvenance': cps == null
          ? 'declared'
          : 'cps_local_read_cached',
      'professionalCps': ?cps,
      'professionalDeclaredDates': ?(cps == null
          ? null
          : await PractitionerCpsService.storedDates(db, data['authorId'])),
      'technicalChecks': 'not_checked',
    };
  }

  Future<MedicalReview> review(EpisodeDocumentVersion version) async {
    final db = await pdf.database();
    final before = await db.transaction((t) => _snapshot(t, version.id));
    final file = await pdf.verifiedFile(version);
    final bytes = await file.readAsBytes();
    if (FinalPdfDocumentService.hash(bytes) != version.digest) {
      fail('PDF modifié pendant la lecture.');
    }
    final pages = await renderer.render(bytes);
    if (pages.length != version.pages || pages.any((p) => p.png.isEmpty)) {
      fail('Aperçu incomplet : validation bloquée.');
    }
    if (!pages.any((p) => p.hasInk)) {
      fail('PDF entièrement blanc : validation bloquée.');
    }
    await checkpoint?.call('rendered');
    await pdf.verifyStoredBytes(version);
    final after = await db.transaction((t) => _snapshot(t, version.id));
    if (medicalHash(before) != medicalHash(after)) {
      fail('Contexte modifié pendant la revue : recommencez.');
    }
    return MedicalReview._(
      jsonDecode(medicalCanonical(before)) as MedicalRow,
      List.unmodifiable(pages),
    );
  }

  Future<MedicalRow> approve(
    MedicalReview review, {
    required Set<int> reviewedPages,
    required bool clinicalContent,
    required bool correctPatient,
    required bool actingAsValidator,
  }) async {
    if (!clinicalContent ||
        !correctPatient ||
        !actingAsValidator ||
        reviewedPages.length != review.pages.length ||
        !List.generate(
          review.pages.length,
          (i) => i,
        ).every(reviewedPages.contains)) {
      fail('Revue de toutes les pages et attestations explicites requises.');
    }
    final version = EpisodeDocumentVersion(
      Map<String, Object?>.from(review.snapshot['version'] as Map),
    );
    await pdf.verifiedFile(version);
    await checkpoint?.call('beforeApproval');
    final db = await pdf.database();
    return db.transaction((txn) async {
      final current = await _snapshot(txn, review.versionId);
      await pdf.verifyStoredBytes(version);
      if (medicalHash(current) != review.digest) {
        fail('PDF ou contexte modifié : validation refusée.');
      }
      final existing = await txn.rawQuery(
        '''SELECT a.* FROM document_medical_approvals a
        LEFT JOIN document_approval_invalidations i ON i.approval_id=a.approval_id
        WHERE a.version_id=? AND a.snapshot_hash=? AND i.approval_id IS NULL''',
        [version.id, review.digest],
      );
      if (existing.isNotEmpty) return existing.first;
      final prep =
          jsonDecode((current['preparation'] as Map)['data_json']) as Map;
      final row = <String, Object?>{
        'approval_id': const Uuid().v4(),
        'version_id': version.id,
        'document_id': version.documentId,
        'patient_id': version.values['patient_id'],
        'episode_id': version.values['episode_id'],
        'author_id': prep['authorId'],
        'validator_id': prep['validatorId'],
        'context_id': prep['contextId'],
        'source_kind': version.sourceKind,
        'source_id': version.values['source_id'],
        'snapshot_json': medicalCanonical(current),
        'snapshot_hash': review.digest,
        'attestations_json': medicalCanonical({
          'pages': reviewedPages.toList()..sort(),
          'clinical': true,
          'patient': true,
          'validatorDeclaration': true,
        }),
        'approved_at': now().millisecondsSinceEpoch,
      };
      await txn.insert('document_medical_approvals', row);
      return row;
    });
  }

  /// Must run in the caller's transaction; no cached approval can authorize controls.
  Future<MedicalRow> approvedCapture(
    DatabaseExecutor db,
    EpisodeDocumentVersion version,
  ) async {
    final current = await _snapshot(db, version.id);
    CndaPatientRecipe.checkDocument(current);
    await pdf.verifyStoredBytes(
      EpisodeDocumentVersion(
        Map<String, Object?>.from(current['version'] as Map),
      ),
    );
    final rows = await db.rawQuery(
      '''SELECT a.* FROM document_medical_approvals a
      LEFT JOIN document_approval_invalidations i ON i.approval_id=a.approval_id
      WHERE a.version_id=? AND i.approval_id IS NULL ORDER BY a.rowid DESC''',
      [version.id],
    );
    if (rows.isEmpty || rows.first['snapshot_hash'] != medicalHash(current)) {
      fail('Validation médicale courante requise avant les contrôles.');
    }
    return rows.first;
  }

  /// Only used with an independently verified, correlated DV1 retry review.
  /// The historical approval stays invalidated for all ordinary workflows.
  Future<MedicalRow> retryApprovedCapture(
    DatabaseExecutor db,
    EpisodeDocumentVersion version,
    String approvalId,
  ) async {
    final current = await _snapshot(db, version.id);
    CndaPatientRecipe.checkDocument(current);
    await pdf.verifyStoredBytes(
      EpisodeDocumentVersion(
        Map<String, Object?>.from(current['version'] as Map),
      ),
    );
    final rows = await db.rawQuery(
      """SELECT a.*, i.reason AS retry_invalidation FROM document_medical_approvals a
      LEFT JOIN document_approval_invalidations i ON i.approval_id=a.approval_id
      WHERE a.version_id=? ORDER BY a.rowid DESC LIMIT 1""",
      [version.id],
    );
    if (rows.isEmpty || rows.single['approval_id'] != approvalId) {
      fail('Validation remplacée : reprise bloquée.');
    }
    final receipt = Map<String, Object?>.from(rows.single);
    final reason = receipt.remove('retry_invalidation');
    final saved = jsonDecode(receipt['snapshot_json'] as String) as Map;
    if (medicalHash(saved) != receipt['snapshot_hash']) {
      fail('Preuve de validation altérée.');
    }
    if (reason == null && medicalHash(current) == receipt['snapshot_hash']) {
      return receipt;
    }
    if (reason != 'Source modifiée : document_preparations' ||
        !sameRetrySnapshot(saved, current)) {
      fail('Le contenu ou le contexte validé a changé : reprise bloquée.');
    }
    // Fail closed on any intervening change outside this preparation, even
    // when values were subsequently restored. No invalidation is removed.
    final changes = await db.rawQuery(
      'SELECT source_table, source_id FROM document_medical_changes WHERE change_id>?',
      [saved['dependencyEpoch']],
    );
    if (changes.isEmpty ||
        changes.any(
          (r) =>
              r['source_table'] != 'document_preparations' ||
              r['source_id'] != version.id,
        )) {
      fail('Autre source modifiée depuis la validation : reprise bloquée.');
    }
    return receipt;
  }

  /// Ignore only save bookkeeping; every clinical and identity field matches.
  static bool sameRetrySnapshot(Map saved, Map current) {
    final before = Map<String, dynamic>.from(saved);
    final after = Map<String, dynamic>.from(current);
    for (final snapshot in [before, after]) {
      final prep = Map<String, dynamic>.from(snapshot['preparation'] as Map);
      prep.remove('revision');
      prep.remove('updated_at');
      snapshot['preparation'] = prep;
      snapshot.remove('dependencyEpoch');
    }
    return medicalCanonical(before) == medicalCanonical(after);
  }

  Future<List<MedicalRow>> history(String versionId) async =>
      (await pdf.database()).rawQuery(
        '''SELECT a.*, i.reason AS invalidation_reason, i.invalidated_at
    FROM document_medical_approvals a LEFT JOIN document_approval_invalidations i ON i.approval_id=a.approval_id
    WHERE a.version_id=? ORDER BY a.approved_at DESC, a.rowid DESC''',
        [versionId],
      );
  Future<bool> reviewIsCurrent(MedicalReview review) async {
    try {
      return await (await pdf.database()).transaction((txn) async {
        final snapshot = await _snapshot(txn, review.versionId);
        await pdf.verifyStoredBytes(
          EpisodeDocumentVersion(
            Map<String, Object?>.from(snapshot['version'] as Map),
          ),
        );
        return medicalHash(snapshot) == review.digest;
      });
    } catch (_) {
      return false;
    }
  }

  Future<MedicalStatus> status(EpisodeDocumentVersion version) async {
    final db = await pdf.database();
    return db.transaction((txn) async {
      final receipts = await txn.rawQuery(
        '''SELECT a.*, i.reason AS invalidation_reason, i.invalidated_at
        FROM document_medical_approvals a LEFT JOIN document_approval_invalidations i ON i.approval_id=a.approval_id
        WHERE a.version_id=? ORDER BY a.approved_at DESC, a.rowid DESC''',
        [version.id],
      );
      try {
        final current = await _snapshot(txn, version.id);
        await pdf.verifyStoredBytes(
          EpisodeDocumentVersion(
            Map<String, Object?>.from(current['version'] as Map),
          ),
        );
        if (receipts.isEmpty) {
          return MedicalStatus(
            'ready',
            current['cndaRecipe'] != null
                ? 'Recette CNDA : PDF à examiner avant validation médicale de test. Aucune qualification INS, signature ou transmission.'
                : 'À examiner et valider médicalement. Les contrôles PDF/A et CDA après validation sont affichés séparément.',
            canReview: true,
          );
        }
        final last = receipts.first;
        if (last['invalidation_reason'] == null &&
            last['snapshot_hash'] == medicalHash(current)) {
          return MedicalStatus(
            current['cndaRecipe'] != null ? 'test_approved' : 'approved',
            current['cndaRecipe'] != null
                ? 'Validation médicale de test enregistrée — patient fictif CNDA. Identité non qualifiée. Contrôles techniques et signature à effectuer avant un dépôt de recette sur DV1 uniquement.'
                : 'Validé médicalement pour cette version. Les résultats techniques sont affichés séparément.',
            approval: last,
            canReview: true,
          );
        }
        await _invalidate(txn, version.id, 'Le PDF ou le contexte a changé.');
        return MedicalStatus(
          'invalidated',
          'Validation invalidée : ${last['invalidation_reason'] ?? 'contexte modifié'}. Nouvelle revue requise.',
          approval: last,
          canReview: true,
        );
      } catch (e) {
        if (receipts.isNotEmpty) {
          await _invalidate(txn, version.id, e.toString());
        }
        return MedicalStatus(
          receipts.isEmpty ? 'blocked' : 'invalidated',
          '${receipts.isEmpty ? 'Validation bloquée' : 'Validation invalidée'} : $e',
          approval: receipts.isEmpty ? null : receipts.first,
        );
      }
    });
  }

  Future<void> _invalidate(
    DatabaseExecutor db,
    String version,
    String reason,
  ) async {
    await db.rawInsert(
      '''INSERT OR IGNORE INTO document_approval_invalidations
      SELECT approval_id, ?, ? FROM document_medical_approvals WHERE version_id=?''',
      [reason, now().millisecondsSinceEpoch, version],
    );
  }
}
