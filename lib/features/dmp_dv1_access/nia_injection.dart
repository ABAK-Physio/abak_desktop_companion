import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../dmp_td02/access_identity.dart';
import '../patients/models/patient_fr_insi_result.dart';
import '../patients/services/patient_fr_insi_result_parser.dart';

/// CNDA response, processed by the same INSi result parser as retrieval.
/// Only the reviewed TEST_NIA.xml is accepted, never an arbitrary clinical file.
class Dv1NiaInjection {
  Dv1NiaInjection._(this.result);
  static const scenario = '0.2-080';
  static const fileHash =
      'ff374a4383d764afa2e7a6bab75e2a9fe74234cb57c7e4798ed9d44641ee4b4a';
  static const source =
      'CNDA — TEST_NIA.xml et Notice-injection.docx ; '
      'PDT 2.10g, Phase 2 Tests ligne 32, 0.2-080, patient 103 MATRICULE PROVISOIRE.';
  final PatientFrInsiResult result;
  String get ins => '${result.insNumber}${result.insKey}';
  String get patient => '${result.birthLastName} ${result.birthFirstNames}';
  Map<String, String> get identity => {
    'ins_number': result.insNumber!,
    'ins_key': result.insKey!,
    'ins_oid': result.insOid!,
    'identifierType': 'NIA',
    'birth_last_name': result.birthLastName!,
    'birth_first_names': result.birthFirstNames!,
    'birth_date': result.birthDate!,
    'sex_code': result.sexCode!,
    'birth_place_code': result.birthPlaceCode!,
    'origin': 'CNDA_INSI_INJECTION',
  };
  static Dv1NiaInjection decode(List<int> bytes) {
    if (bytes.length > 65536 || sha256.convert(bytes).toString() != fileHash) {
      throw StateError(
        'Choisissez le fichier TEST_NIA.xml original du package CNDA, sans modification.',
      );
    }
    final result = const PatientFrInsiResultParser().parseXml(
      utf8.decode(bytes),
    );
    if (!result.isSuccess ||
        result.insOid != DmpAccessIdentity.niaOid ||
        !RegExp(r'^\d{13}$').hasMatch(result.insNumber ?? '') ||
        !RegExp(r'^\d{2}$').hasMatch(result.insKey ?? '') ||
        [
          result.birthLastName,
          result.birthFirstNames,
          result.birthDate,
          result.sexCode,
          result.birthPlaceCode,
        ].any((v) => v == null || v.isEmpty)) {
      throw StateError(
        'La réponse injectée ne contient pas l’identité NIA attendue.',
      );
    }
    return Dv1NiaInjection._(result);
  }
}

class Dv1NiaEvidence {
  Dv1NiaEvidence(this.id, this.injection);
  final String id;
  final Dv1NiaInjection injection;
}

/// Durable recipe evidence, distinct from real INSi retrieval/qualification.
/// Uses the existing access history envelope/hash, without a database migration.
class Dv1NiaArchive {
  Dv1NiaArchive(this.root, {required this.hash});
  final Directory root;
  final String Function(Object?) hash;
  Directory directory(String id) {
    if (!RegExp(r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$').hasMatch(id)) {
      throw StateError('Identifiant de preuve NIA invalide.');
    }
    return Directory.fromUri(root.uri.resolve('$id/'));
  }

  File file(String id, String name) =>
      File.fromUri(directory(id).uri.resolve(name));
  Future<void> save(String id, Map<String, dynamic> record) async {
    final pending = file(id, 'result.pending');
    await pending.writeAsString(
      jsonEncode({'record': record, 'sha256': hash(record)}),
      flush: true,
    );
    await pending.rename(file(id, 'result.json').path);
  }

  Future<Dv1NiaEvidence> importResponse(List<int> bytes) async {
    final injection = Dv1NiaInjection.decode(bytes);
    final id = const Uuid().v4();
    final now = DateTime.now().toUtc().toIso8601String();
    await directory(id).create(recursive: true);
    await file(id, 'insi-injected.xml').writeAsBytes(bytes, flush: true);
    await save(id, {
      'schema': 1,
      'id': id,
      'environment': 'DV1',
      'testCode': Dv1NiaInjection.scenario,
      'operation': '0.2-080 — injection INSi CNDA et blocage NIA',
      'startedAt': now,
      'importedAt': now,
      'state': 'nia_imported',
      'source': Dv1NiaInjection.source,
      'sourceSha256': Dv1NiaInjection.fileHash,
      'injectedIdentity': injection.identity,
      'injectedCodeCR': '00',
      'cardAccessed': false,
      'networkAccessed': false,
      'nativeSessionOpened': false,
      'message': 'Réponse INSi de recette importée et conservée : identité NIA. Aucun accès CPS ou réseau.',
    });
    return Dv1NiaEvidence(id, injection);
  }

  Future<Map<String, dynamic>> verify(Dv1NiaEvidence evidence) async {
    for (final name in ['result.json', 'insi-injected.xml']) {
      if (await FileSystemEntity.type(
            file(evidence.id, name).path,
            followLinks: false,
          ) !=
          FileSystemEntityType.file) {
        throw StateError(
          'Preuve NIA absente ou redirigée. Importez de nouveau le fichier CNDA.',
        );
      }
    }
    final envelope = jsonDecode(
      await file(evidence.id, 'result.json').readAsString(),
    ) as Map;
    final record = Map<String, dynamic>.from(envelope['record'] as Map);
    final injection = Dv1NiaInjection.decode(
      await file(evidence.id, 'insi-injected.xml').readAsBytes(),
    );
    if (hash(record) != envelope['sha256'] ||
        record['id'] != evidence.id ||
        record['testCode'] != Dv1NiaInjection.scenario ||
        hash(record['injectedIdentity']) != hash(injection.identity) ||
        hash(evidence.injection.identity) != hash(injection.identity)) {
      throw StateError('Intégrité de la preuve NIA non confirmée.');
    }
    return record;
  }

  Future<Map<String, dynamic>> blockAccess(
    Dv1NiaEvidence evidence,
    Map<String, dynamic> snapshot,
  ) async {
    final record = await verify(evidence);
    final identity = snapshot['identity'] as Map;
    final recipe = snapshot['recipe'] as Map;
    final expected = evidence.injection;
    if (identity['ins_number'] != expected.result.insNumber ||
        identity['ins_key'] != expected.result.insKey ||
        identity['ins_oid'] != expected.result.insOid ||
        recipe['scenario'] != Dv1NiaInjection.scenario ||
        recipe['patient'] != expected.patient ||
        recipe['birthDate'] != expected.result.birthDate) {
      throw StateError(
        'Le contexte a changé depuis l’injection NIA. Rechargez TEST_NIA.xml.',
      );
    }
    try {
      DmpAccessIdentity.requireNirOid(identity['ins_oid'] as String?);
      throw StateError('Le refus NIA attendu n’a pas été déclenché.');
    } on DmpNiaBlocked catch (e) {
      record.addAll({
        'state': 'nia_blocked',
        'dmpState': 'nia',
        'testExpectedMatched': true,
        'context': snapshot,
        'finishedAt': DateTime.now().toUtc().toIso8601String(),
        'cardAccessed': false,
        'networkAccessed': false,
        'nativeSessionOpened': false,
        'message': '0.2-080 — Accès DMP refusé avant toute lecture CPS ou connexion : identité NIA.',
        'detail': e.message,
      });
      await save(evidence.id, record);
    }
    return {...record, 'evidenceDirectory': directory(evidence.id).path};
  }
}
