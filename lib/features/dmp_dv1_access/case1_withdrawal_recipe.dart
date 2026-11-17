import 'dart:convert';
import 'dart:io';

import '../dmp_td02/access_identity.dart';
import '../dmp_td02/td02_result.dart';
import 'case1_authorization_recipe.dart';

/// PDT 2.10g, phase 2 row 35; the preceding successful addition is linked.
class Dv1Case1WithdrawalRecipe {
  static const scenario = '0.3-080';
  static const source =
      'PDT_DMP_ABAK DESKTOP COMPANION_20251127_2.10g.xlsx — '
      'Phase 2 Tests, ligne 35, 0.3-080 ; Référentiel Patients, ligne 19, Cas1 — '
      'ANNE-LOUIS GIRODET DE ROUSSY-COEUR.';

  static void checkInputs({
    required String scenario,
    required String patient,
    required String ins,
    required String birth,
    required String professional,
  }) {
    if (scenario != Dv1Case1WithdrawalRecipe.scenario) {
      throw StateError('Préparez le scénario 0.3-080 du Cas1.');
    }
    try {
      Dv1Case1AuthorizationRecipe.checkInputs(
        scenario: Dv1Case1AuthorizationRecipe.scenario,
        patient: patient,
        ins: ins,
        birth: birth,
        professional: professional,
      );
    } on StateError {
      throw StateError(
        '0.3-080 attend le Cas1 — ANNE-LOUIS GIRODET DE ROUSSY-COEUR, '
        'née le 01/01/1987, INS 287019143596041, avec la CPS 899700870597.',
      );
    }
  }

  static void checkOperation({
    String? authorizationIntent,
    bool preparatoryWithdrawal = false,
    bool otherOperation = false,
  }) {
    if (preparatoryWithdrawal ||
        otherOperation ||
        (authorizationIntent != null && authorizationIntent != 'withdraw')) {
      throw StateError(
        '0.3-080 permet uniquement TD0.2 ou le retrait explicite de sa propre autorisation.',
      );
    }
  }

  static bool initialReady(Td02Result result) =>
      Dv1Case1AuthorizationRecipe.withdrawalReady(result);
  static void requireInitial(Td02Result result) {
    if (!initialReady(result)) {
      throw StateError(
        '0.3-080 : retrait non envoyé. Un DMP actif avec autorisation VALIDE est requis. ${result.message}',
      );
    }
  }

  static bool completed(Td02Result initial, String status, Td02Result after) =>
      Dv1Case1AuthorizationRecipe.withdrawalCompleted(initial, status, after);

  static bool isAddition(Map<String, dynamic> record) {
    try {
      final context = record['context'] as Map;
      final identity = context['identity'] as Map;
      final recipe = context['recipe'] as Map;
      final practice = jsonDecode(
        (context['practice'] as Map)['data_json'] as String,
      ) as Map;
      Dv1Case1AuthorizationRecipe.checkInputs(
        scenario: recipe['scenario'] as String,
        patient: recipe['patient'] as String,
        ins: '${identity['ins_number']}${identity['ins_key']}',
        birth: recipe['birthDate'] as String,
        professional: practice['identifier'] as String,
      );
      return record['environment'] == 'DV1' &&
          record['platform'] == 'windows' &&
          identity['ins_oid'] == DmpAccessIdentity.nirOid &&
          record['preparationOnly'] != true &&
          record['testCode'] == Dv1Case1AuthorizationRecipe.scenario &&
          record['testPhase'] == 'authorization_add' &&
          record['testExpectedMatched'] == true &&
          record['state'] == 'authorization_verified' &&
          record['authorizationAction'] == 'add' &&
          record['dmpState'] == 'active' &&
          record['consultationRight'] == 'absent' &&
          record['td03Status'] == 'DMPOk' &&
          record['afterDmpState'] == 'active' &&
          record['afterConsultationRight'] == 'valid' &&
          record['transactionClosed'] == true &&
          record['httpStatus'] == 200 &&
          record['td03HttpStatus'] == 200 &&
          record['afterHttpStatus'] == 200;
    } catch (_) {
      return false;
    }
  }
}

/// Read-only verification of the existing addition, with the application's hash.
class Dv1Case1AdditionArchive {
  Dv1Case1AdditionArchive(this.root, {required this.hash});
  final Directory root;
  final String Function(Object?) hash;
  static const exchanges = {
    'request.xml': 'requestHash',
    'response.xml': 'responseHash',
    'td03-request.xml': 'td03RequestHash',
    'td03-response.xml': 'td03ResponseHash',
    'td02-after-request.xml': 'afterRequestHash',
    'td02-after-response.xml': 'afterResponseHash',
  };

  Future<Map<String, dynamic>> verify(String id) async {
    if (!RegExp(r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$').hasMatch(id)) {
      throw StateError('Identifiant de preuve d’ajout invalide.');
    }
    final directory = Directory.fromUri(root.uri.resolve('$id/'));
    Future<String> read(String name, int limit) async {
      final file = File.fromUri(directory.uri.resolve(name));
      if (await file.length() > limit) {
        throw StateError('Preuve d’ajout trop volumineuse.');
      }
      return file.readAsString();
    }

    try {
      final envelope = jsonDecode(await read('result.json', 512 * 1024)) as Map;
      final record = Map<String, dynamic>.from(envelope['record'] as Map);
      if (record['id'] != id ||
          envelope['sha256'] != hash(record) ||
          !Dv1Case1WithdrawalRecipe.isAddition(record)) {
        throw StateError('Ajout 0.3-010 absent, incomplet ou altéré.');
      }
      for (final exchange in exchanges.entries) {
        if (hash(await read(exchange.key, 4 * 1024 * 1024)) !=
            record[exchange.value]) {
          throw StateError('Échange de l’ajout 0.3-010 absent ou altéré.');
        }
      }
      return {...record, 'additionEvidenceHash': envelope['sha256']};
    } on FileSystemException {
      throw StateError(
        'Preuves de l’ajout 0.3-010 introuvables. Aucun retrait effectué.',
      );
    } on FormatException {
      throw StateError(
        'Preuves de l’ajout 0.3-010 illisibles. Aucun retrait effectué.',
      );
    }
  }
}
