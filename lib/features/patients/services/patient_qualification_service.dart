import 'dart:convert';
import 'package:abak_vitale/abak_vitale.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import '../../../core/database/database_service.dart';
import 'patient_insi_retrieval_service.dart';
import 'patient_fr_insi_result_parser.dart';
import 'cnda_patient_recipe.dart';

class PatientIdentityRecord {
  final Map<String, Object?> patient;
  final Map<String, Object?> identity;
  final Map<String, Object?>? vitale;
  final List<Map<String, Object?>> practitioners;
  final List<Map<String, Object?>> events;

  const PatientIdentityRecord({
    required this.patient,
    required this.identity,
    required this.vitale,
    required this.practitioners,
    required this.events,
  });

  String get status => identity['identity_status'] as String? ?? 'provisional';
  String get token => jsonEncode([patient, identity, vitale]);
  Map<String, Object?> get draft => {
    ...identity,
    'used_last_name': identity['used_last_name'] ?? patient['last_name'],
    'used_first_name': identity['used_first_name'] ?? patient['first_name'],
    'birth_date': identity['birth_date'] ?? patient['birth_date'],
    'sex_code': identity['sex_code'] ?? patient['sex_code'],
  };
}

/// Local records only: no card, INSi, CPS or network operations in this service.
class PatientQualificationService {
  final Future<Database> Function() _database;
  PatientQualificationService({Future<Database> Function()? database})
    : _database = database ?? (() => DatabaseService.database);

  static const strictFields = [
    'birth_last_name',
    'birth_first_names',
    'birth_date',
    'sex_code',
    'birth_place_code',
  ];
  static const textFields = [
    ...strictFields,
    'used_last_name',
    'used_first_name',
    'first_birth_name',
    'birth_place_label',
    'beneficiary_number',
    'beneficiary_relationship',
    'beneficiary_quality_code',
  ];
  static const flagFields = [
    'identity_doubtful',
    'identity_homonym',
    'identity_fictitious',
  ];
  static const documentTypes = {
    'cni': 'Carte nationale d’identité',
    'passport': 'Passeport',
    'residence_permit': 'Titre de séjour',
  };
  static const relationships = {
    'insured': 'Assuré lui-même',
    'spouse': 'Conjoint',
    'child': 'Enfant',
    'other': 'Autre lien',
  };
  static String statusLabel(String? status) => switch (status) {
    'retrieved' => 'Récupérée',
    'validated' => 'Validée',
    'qualified' => 'Qualifiée',
    _ => 'Provisoire',
  };

  Future<void> saveCndaRecipe({
    required String patientId,
    required String expectedToken,
    required String testIns,
    required String source,
    required bool confirmed,
    String experimentalBirthPlace = '',
    String experimentalBirthPlaceReason = '',
  }) async {
    if (!confirmed ||
        !RegExp(r'^\d{15}$').hasMatch(testIns.trim()) ||
        source.trim().isEmpty ||
        source.length > 2000) {
      throw StateError(
        'Confirmez le patient fictif et renseignez l’INS de test (15 chiffres) et la référence CNDA.',
      );
    }
    final db = await _database();
    await db.transaction((txn) async {
      final record = await _load(txn, patientId);
      if (record.token != expectedToken) {
        throw StateError(
          'La fiche a changé. Rouvrez-la avant d’enregistrer la recette.',
        );
      }
      final before = record.identity;
      if (before.isEmpty ||
          record.status != 'provisional' ||
          before['ins_retrieved_at'] != null ||
          before['identity_validated_at'] != null ||
          _text(before['ins_number']) != null) {
        throw StateError(
          'Utilisez une fiche de test provisoire, enregistrée sans preuve de qualification ni INS réelle.',
        );
      }
      final after = <String, Object?>{...before, 'identity_fictitious': 1};
      final recipe = {
        'schema': 1,
        'scope': CndaPatientRecipe.scope,
        'testIns': testIns.trim(),
        'source': source.trim(),
        'confirmedAt': DateTime.now().toUtc().toIso8601String(),
        'traitsHash': CndaPatientRecipe.fingerprint(after),
        if (experimentalBirthPlace.trim().isNotEmpty) ...{
          'experimentalBirthPlace': experimentalBirthPlace.trim(),
          'experimentalBirthPlaceReason': experimentalBirthPlaceReason.trim(),
          'originalBirthPlace': after['birth_place_code'],
        },
      };
      CndaPatientRecipe.check(after, recipe);
      after['cnda_recipe_json'] = jsonEncode(recipe);
      after['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      await txn.update(
        'patient_fr_health_identity',
        after,
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );
      await _event(txn, patientId, 'cnda_recipe_declared', before, after);
    });
  }

  Future<PatientIdentityRecord> load(String patientId) async {
    final db = await _database();
    return db.transaction((txn) => _load(txn, patientId));
  }

  static Future<PatientIdentityRecord> _load(
    DatabaseExecutor db,
    String patientId,
  ) async {
    final patients = await db.query(
      'patients',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    if (patients.length != 1) throw StateError('Fiche patient indisponible.');
    final rows = await db.query(
      'patient_fr_health_identity',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    final readings = await db.query(
      'patient_vitale_readings',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'read_at DESC, rowid DESC',
      limit: 1,
    );
    return PatientIdentityRecord(
      patient: patients.single,
      identity: rows.isEmpty ? {} : rows.single,
      vitale: readings.isEmpty ? null : readings.single,
      practitioners: await db.query(
        'practitioners',
        where: 'is_active = 1 AND archived_at IS NULL',
        orderBy: 'display_name COLLATE NOCASE',
      ),
      events: await db.query(
        'patient_identity_events',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'occurred_at DESC, rowid DESC',
        limit: 20,
      ),
    );
  }

  /// A current INS must originate in a previously recorded retrieval, never in
  /// a manual form or in the insured person's NIR from a physical Vitale card.
  static bool hasCurrentIns(Map<String, Object?> row) {
    if (row['ins_traits_current'] == 0) return false;
    if (!['retrieved', 'qualified'].contains(row['identity_status'])) {
      return false;
    }
    return row['ins_retrieved_at'] is int &&
        [
          ...strictFields,
          'ins_number',
          'ins_key',
          'ins_oid',
        ].every((key) => _text(row[key]) != null);
  }

  /// Archive the response even when the user declines to apply it.
  /// The archived XML is data, never a manual source of qualified identities.
  Future<String> retainInsiResponse(
    String patientId,
    String expectedToken,
    InsiRetrievalResponse response,
  ) async {
    final db = await _database();
    final eventId = const Uuid().v4();
    await db.transaction((txn) async {
      await _load(txn, patientId);
      await txn.insert('patient_identity_events', {
        'event_id': eventId,
        'patient_id': patientId,
        'occurred_at': response.receivedAt.millisecondsSinceEpoch,
        'event_kind': 'insi_response',
        'before_json': jsonEncode({'expectedToken': expectedToken}),
        'after_json': jsonEncode({
          'requestId': response.id,
          'requestHash': response.requestHash,
          'professional': response.professional,
          'endpoint': PatientInsiRetrievalService.endpoint,
          'receivedAt': response.receivedAt.millisecondsSinceEpoch,
          'responseXml': response.xml,
          'responseHash': sha256.convert(utf8.encode(response.xml)).toString(),
          'result': response.result.status.name,
        }),
      });
    });
    return eventId;
  }

  Future<PatientIdentityRecord> applyInsiResponse(
    String patientId,
    String eventId,
  ) async {
    final db = await _database();
    await db.transaction((txn) async {
      final current = await _load(txn, patientId);
      final events = await txn.query(
        'patient_identity_events',
        where: 'event_id = ? AND patient_id = ? AND event_kind = ?',
        whereArgs: [eventId, patientId, 'insi_response'],
      );
      if (events.length != 1) {
        throw StateError('Réponse INSi conservée introuvable.');
      }
      final event = events.single;
      final origin = jsonDecode(event['before_json'] as String) as Map;
      final evidence = jsonDecode(event['after_json'] as String) as Map;
      if (current.token != origin['expectedToken']) {
        throw StateError(
          'La fiche ou la lecture Vitale a changé. La réponse est conservée, mais ne peut pas être appliquée à cet état.',
        );
      }
      final before = current.identity;
      if (before['identity_doubtful'] == 1 ||
          before['identity_fictitious'] == 1) {
        throw StateError('Le signalement d’identité interdit la récupération.');
      }
      final xml = evidence['responseXml'] as String;
      if (evidence['endpoint'] != PatientInsiRetrievalService.endpoint ||
          sha256.convert(utf8.encode(xml)).toString() !=
              evidence['responseHash']) {
        throw StateError('La preuve INSi est incohérente.');
      }
      final result = const PatientFrInsiResultParser().parseXml(xml);
      final traits = <String, Object?>{
        'birth_last_name': result.birthLastName,
        'birth_first_names': result.birthFirstNames,
        'birth_date': result.birthDate,
        'sex_code': result.sexCode,
        'birth_place_code': result.birthPlaceCode,
      };
      if (!result.isSuccess ||
          traits.values.any((v) => _text(v) == null) ||
          !RegExp(
            r'^[0-9]{5}([0-9]{2}|2[AB])[0-9]{6}$',
          ).hasMatch(result.insNumber ?? '') ||
          !RegExp(r'^[0-9]{2}$').hasMatch(result.insKey ?? '') ||
          !RegExp(r'^[0-9]+(\.[0-9]+)+$').hasMatch(result.insOid ?? '') ||
          !validBirthDate(result.birthDate ?? '') ||
          !['M', 'F'].contains(result.sexCode) ||
          !RegExp(r'^[0-9]{5}$').hasMatch(result.birthPlaceCode ?? '')) {
        throw StateError(
          'La réponse INSi ne contient pas une identité complète exploitable.',
        );
      }
      final duplicates = await txn.query(
        'patient_fr_health_identity',
        columns: ['patient_id'],
        where:
            'patient_id != ? AND ins_number = ? AND ins_oid = ? '
            'AND (ins_traits_current IS NULL OR ins_traits_current != 0) '
            "AND identity_status IN ('retrieved', 'qualified')",
        whereArgs: [patientId, result.insNumber, result.insOid],
        limit: 1,
      );
      if (duplicates.isNotEmpty) {
        throw StateError(
          'Cette INS est déjà rattachée à une autre fiche. Examinez le doublon avant de poursuivre.',
        );
      }
      String normalized(Object? value) =>
          (_text(value) ?? '').toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
      final proofMatches =
          _hasIdentityCheck(before) &&
          strictFields.every(
            (k) => normalized(before[k]) == normalized(traits[k]),
          );
      final now = DateTime.now().millisecondsSinceEpoch;
      final after = <String, Object?>{
        ...before,
        'patient_id': patientId,
        ...traits,
        'ins_number': result.insNumber,
        'ins_key': result.insKey,
        'ins_oid': result.insOid,
        'ins_traits_current': 1,
        'ins_retrieved_at': evidence['receivedAt'],
        'ins_last_checked_at': null,
        'identity_status': proofMatches ? 'qualified' : 'retrieved',
        'updated_at': now,
        if (!proofMatches) ...{
          'identity_validation_method': null,
          'identity_validated_at': null,
          'identity_validated_by': null,
        },
      };
      // Do not derive a possibly compound first name by splitting ListePrenom.
      final first = normalized(before['first_birth_name']);
      if (first.isNotEmpty &&
          normalized(result.birthFirstNames) != first &&
          !normalized(result.birthFirstNames).startsWith('$first ') &&
          !normalized(result.birthFirstNames).startsWith('$first-')) {
        after['first_birth_name'] = null;
      }
      if (before.isEmpty) {
        await txn.insert('patient_fr_health_identity', after);
      } else {
        await txn.update(
          'patient_fr_health_identity',
          after,
          where: 'patient_id = ?',
          whereArgs: [patientId],
        );
      }
      await txn.update(
        'patients',
        {
          'birth_date': result.birthDate!.substring(5).split('-').contains('00')
              ? null
              : result.birthDate,
          'sex_code': result.sexCode,
          'updated_at': now,
        },
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );
      await _event(txn, patientId, 'insi_applied', before, {
        ...after,
        'responseEventId': eventId,
        'professional': evidence['professional'],
      });
    });
    return load(patientId);
  }

  static bool _hasIdentityCheck(Map<String, Object?> row) =>
      ['validated', 'qualified'].contains(row['identity_status']) &&
      row['identity_validated_at'] is int &&
      _text(row['identity_validation_method']) != null &&
      _text(row['identity_validated_by']) != null;

  /// Allows the explicit unknown day/month codes used by identity systems.
  /// Does not turn them into another civil date using DateTime normalisation.
  static bool validBirthDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return false;
    final year = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final day = int.parse(match[3]!);
    if (year < 1 || year > DateTime.now().year || month > 12 || day > 31) {
      return false;
    }
    if (month == 0) return day == 0;
    if (day == 0) return DateTime(year, month).isBefore(DateTime.now());
    final date = DateTime(year, month, day);
    return date.year == year &&
        date.month == month &&
        date.day == day &&
        !date.isAfter(DateTime.now());
  }

  Future<PatientIdentityRecord> save({
    required String patientId,
    required String expectedToken,
    required Map<String, Object?> values,
    bool attestIdentity = false,
    String? documentType,
    String? practitionerId,
    VitaleIdentity? vitaleIdentity,
    DateTime? vitaleReadAt,
  }) async {
    if ((vitaleIdentity == null) != (vitaleReadAt == null)) {
      throw ArgumentError(
        'La lecture Vitale doit être accompagnée de sa date.',
      );
    }
    final db = await _database();
    await db.transaction((txn) async {
      final current = await _load(txn, patientId);
      if (current.token != expectedToken) {
        throw StateError(
          'La fiche a changé depuis son ouverture. '
          'Vos saisies sont conservées ; rouvrez la fiche avant de les reporter.',
        );
      }
      final before = current.identity;
      final after = <String, Object?>{...before, 'patient_id': patientId};
      for (final key in textFields) {
        after[key] = _text(values[key]);
      }
      for (final key in flagFields) {
        after[key] = values[key] == 1 ? 1 : 0;
      }
      final birthDate = _text(after['birth_date']);
      if (birthDate != null && !validBirthDate(birthDate)) {
        throw ArgumentError(
          'Date de naissance invalide. Utilisez AAAA-MM-JJ '
          '(00 pour un jour ou un mois inconnu, sans inventer de date).',
        );
      }
      final sex = _text(after['sex_code']) ?? 'U';
      if (!['M', 'F', 'U', 'X'].contains(sex)) {
        throw ArgumentError('Sexe non reconnu.');
      }
      after['sex_code'] = sex;
      final place = _text(after['birth_place_code']);
      if (place != null && !RegExp(r'^(\d{5}|2[AB]\d{3})$').hasMatch(place)) {
        throw ArgumentError(
          'Le code INSEE du lieu de naissance comporte 5 caractères (par exemple 13055 ou 2A004).',
        );
      }
      final number = _text(after['beneficiary_number']);
      if (number != null && !RegExp(r'^\d+$').hasMatch(number)) {
        throw ArgumentError(
          'Le numéro d’ordre du bénéficiaire doit être numérique.',
        );
      }
      final relationship = _text(after['beneficiary_relationship']);
      if (relationship != null && !relationships.containsKey(relationship)) {
        throw ArgumentError('Lien avec l’assuré non reconnu.');
      }
      final displayLast =
          _text(after['used_last_name']) ?? _text(after['birth_last_name']);
      final displayFirst =
          _text(after['used_first_name']) ??
          _text(after['first_birth_name']) ??
          _text(after['birth_first_names']);
      if (displayLast == null || displayFirst == null) {
        throw ArgumentError(
          'Renseignez au moins un nom et un prénom pour la fiche patient.',
        );
      }

      final strictChanged = strictFields.any(
        (key) => _text(before[key]) != _text(after[key]),
      );
      final blocked =
          after['identity_doubtful'] == 1 || after['identity_fictitious'] == 1;
      var checked = _hasIdentityCheck(before) && !strictChanged && !blocked;
      final insCurrent = hasCurrentIns(before) && !strictChanged;
      Map<String, Object?>? actor;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (attestIdentity) {
        if (blocked) {
          throw StateError(
            'Une identité douteuse ou fictive ne peut pas être validée.',
          );
        }
        if (!documentTypes.containsKey(documentType)) {
          throw ArgumentError(
            'Sélectionnez le justificatif réellement examiné.',
          );
        }
        if (strictFields.any((key) => _text(after[key]) == null) ||
            !['M', 'F'].contains(after['sex_code'])) {
          throw ArgumentError(
            'Complétez le nom de naissance, tous les prénoms de naissance, '
            'la date, le sexe et le code du lieu de naissance avant de valider l’identité.',
          );
        }
        final actors = current.practitioners
            .where((row) => row['practitioner_id'] == practitionerId)
            .toList();
        if (actors.length != 1) {
          throw ArgumentError(
            'Choisissez le professionnel qui a effectué le contrôle.',
          );
        }
        actor = actors.single;
        after.addAll({
          'identity_validation_method': documentType,
          'identity_validated_at': now,
          'identity_validated_by': practitionerId,
        });
        checked = true;
      } else if (!checked) {
        // Superseded evidence remains in the journal, not as current proof.
        after.addAll({
          'identity_validation_method': null,
          'identity_validated_at': null,
          'identity_validated_by': null,
        });
      }
      after['ins_traits_current'] = insCurrent ? 1 : 0;
      after['identity_status'] = blocked
          ? 'provisional'
          : checked && insCurrent
          ? 'qualified'
          : checked
          ? 'validated'
          : insCurrent
          ? 'retrieved'
          : 'provisional';

      final patientChanges = <String, Object?>{
        'last_name': displayLast, 'first_name': displayFirst,
        // Other screens calculate ages using complete civil dates only.
        'birth_date':
            birthDate != null &&
                !birthDate.substring(5).split('-').contains('00')
            ? birthDate
            : null,
        'sex_code': sex,
      };
      patientChanges.removeWhere((key, value) => current.patient[key] == value);
      final identityChanged = after.entries.any(
        (entry) => before[entry.key] != entry.value,
      );
      if (!identityChanged && patientChanges.isEmpty) {
        if (vitaleIdentity != null) {
          await recordVitaleInTransaction(
            txn,
            patientId: patientId,
            identity: vitaleIdentity,
            readAt: vitaleReadAt!,
          );
        }
        return;
      }
      after['updated_at'] = now;
      if (before.isEmpty) {
        await txn.insert('patient_fr_health_identity', after);
      } else {
        await txn.update(
          'patient_fr_health_identity',
          after,
          where: 'patient_id = ?',
          whereArgs: [patientId],
        );
      }
      if (patientChanges.isNotEmpty) {
        await txn.update(
          'patients',
          {...patientChanges, 'updated_at': now},
          where: 'patient_id = ?',
          whereArgs: [patientId],
        );
      }
      await _event(
        txn,
        patientId,
        attestIdentity
            ? 'identity_checked'
            : strictChanged && before.isNotEmpty
            ? 'identity_changed'
            : 'information_saved',
        before,
        after,
        actor: actor,
      );
      if (vitaleIdentity != null) {
        await recordVitaleInTransaction(
          txn,
          patientId: patientId,
          identity: vitaleIdentity,
          readAt: vitaleReadAt!,
        );
      }
    });
    return load(patientId);
  }

  Future<void> recordVitale(
    String patientId,
    VitaleIdentity identity,
    DateTime readAt,
  ) async {
    final db = await _database();
    await db.transaction(
      (txn) => recordVitaleInTransaction(
        txn,
        patientId: patientId,
        identity: identity,
        readAt: readAt,
      ),
    );
  }

  /// Keep the older, short patient editor consistent with the identity record.
  /// The NIR of an insured person is deliberately not copied to INS fields.
  static Future<void> synchronizePatientEdit(
    DatabaseExecutor db,
    Map<String, Object?> previous,
    Map<String, Object?> updated,
  ) async {
    final patientId = updated['patient_id'] as String;
    final rows = await db.query(
      'patient_fr_health_identity',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    if (rows.isEmpty) return;
    final before = rows.single;
    final after = <String, Object?>{...before};
    for (final entry in const {
      'last_name': 'used_last_name',
      'first_name': 'used_first_name',
      'birth_date': 'birth_date',
      'sex_code': 'sex_code',
    }.entries) {
      if (previous[entry.key] != updated[entry.key]) {
        after[entry.value] = updated[entry.key];
      }
    }
    if (!after.entries.any((entry) => entry.value != before[entry.key])) return;
    final strictChanged = strictFields.any((key) => before[key] != after[key]);
    if (strictChanged) {
      after.addAll({
        'identity_status': 'provisional',
        'ins_traits_current': 0,
        'identity_validation_method': null,
        'identity_validated_at': null,
        'identity_validated_by': null,
      });
    }
    after['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'patient_fr_health_identity',
      after,
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    await _event(
      db,
      patientId,
      strictChanged ? 'identity_changed' : 'information_saved',
      before,
      after,
    );
  }

  /// Called only after the user has selected/associated the beneficiary.
  /// A list index is never persisted as a beneficiary number or relationship.
  static Future<void> recordVitaleInTransaction(
    DatabaseExecutor db, {
    required String patientId,
    required VitaleIdentity identity,
    required DateTime readAt,
  }) async {
    final patients = await db.query(
      'patients',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    if (patients.length != 1) throw StateError('Fiche patient indisponible.');
    final now = DateTime.now().millisecondsSinceEpoch;
    final readingId = const Uuid().v4();
    await db.insert('patient_vitale_readings', {
      'reading_id': readingId,
      'patient_id': patientId,
      'read_at': readAt.millisecondsSinceEpoch,
      'recorded_at': now,
      'source': 'carte_vitale',
      'identity_json': jsonEncode(identity.toMap()),
    });
    // Seed only an absent record, using known patient information. Names
    // exported as nomUsuel/prenomUsuel are never promoted to birth traits.
    final health = await db.query(
      'patient_fr_health_identity',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    if (health.isEmpty) {
      final patient = patients.single;
      await db.insert('patient_fr_health_identity', {
        'patient_id': patientId,
        'used_last_name': patient['last_name'],
        'used_first_name': patient['first_name'],
        'birth_date': patient['birth_date'],
        'sex_code': patient['sex_code'],
        'identity_status': 'provisional',
        'updated_at': now,
      });
    }
    await _event(db, patientId, 'vitale_read', {}, {
      'reading_id': readingId,
      'read_at': readAt.millisecondsSinceEpoch,
      'source': 'carte_vitale',
    });
  }

  static Future<void> _event(
    DatabaseExecutor db,
    String patientId,
    String kind,
    Map<String, Object?> before,
    Map<String, Object?> after, {
    Map<String, Object?>? actor,
  }) => db
      .insert('patient_identity_events', {
        'event_id': const Uuid().v4(),
        'patient_id': patientId,
        'occurred_at': DateTime.now().millisecondsSinceEpoch,
        'event_kind': kind,
        'actor_id': actor?['practitioner_id'],
        'actor_name': actor?['display_name'],
        'before_json': jsonEncode(before),
        'after_json': jsonEncode(after),
      })
      .then((_) {});

  static String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
