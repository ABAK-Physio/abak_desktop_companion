import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Declared CNDA evidence, never an INSi response or a qualified identity.
class CndaPatientRecipe {
  static const reviewScope = 'CNDA_MEDICAL_REVIEW_ONLY';
  static const scope = 'CNDA_DV1_ALIMENTATION';
  static const repository =
      'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository';
  static const patients =
      'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/patients';

  /// Projection for a frozen test document only; never written as a qualified INS.
  static Map<String, Object?> documentIdentity(Map identity, Map recipe) {
    check(identity, recipe);
    if (recipe['scope'] != scope) return Map<String, Object?>.from(identity);
    final ins = recipe['testIns'] as String;
    return {
      ...Map<String, Object?>.from(identity),
      if (recipe['experimentalBirthPlace'] != null)
        'birth_place_code': recipe['experimentalBirthPlace'],
      'ins_number': ins.substring(0, 13),
      'ins_key': ins.substring(13),
      'ins_oid': '1.2.250.1.213.1.4.10',
    };
  }

  static void checkDocument(Map snapshot) {
    final recipe = snapshot['cndaRecipe'];
    if (recipe == null) return;
    final identity = snapshot['identity'] as Map;
    final declaration = recipe as Map;
    final originalIdentity = Map<String, Object?>.from(identity);
    if (declaration['experimentalBirthPlace'] != null) {
      if (identity['birth_place_code'] !=
          declaration['experimentalBirthPlace']) {
        throw StateError(
          'Le code expérimental diffère de la déclaration de recette.',
        );
      }
      originalIdentity['birth_place_code'] = declaration['originalBirthPlace'];
    }
    check(originalIdentity, declaration);
    final ins = recipe['testIns'] as String;
    if (recipe['scope'] != scope) {
      throw StateError(
        'Rouvrez « Patient de recette CNDA » et confirmez le parcours de dépôt DV1, puis reprenez la validation du PDF.',
      );
    }
    if (identity['ins_number'] != ins.substring(0, 13) ||
        identity['ins_key'] != ins.substring(13) ||
        identity['ins_oid'] != '1.2.250.1.213.1.4.10' ||
        !RegExp(r'^\d{5}$').hasMatch('${identity['birth_place_code'] ?? ''}') ||
        int.parse(ins.substring(13)) !=
            97 - int.parse(ins.substring(0, 13)) % 97) {
      throw StateError(
        'Données CNDA incomplètes ou incohérentes : vérifiez l’INS et le code du lieu de naissance dans la source du patient fictif. Aucune valeur ne sera déduite.',
      );
    }
  }

  static void checkDestination(
    Map snapshot,
    String endpoint, {
    bool accessOnly = false,
  }) {
    if (snapshot['cndaRecipe'] == null) return;
    checkDocument(snapshot);
    if (endpoint != (accessOnly ? patients : repository)) {
      throw StateError(
        'Patient fictif CNDA : destination limitée au serveur DV1.',
      );
    }
  }

  static const traits = [
    'birth_last_name',
    'birth_first_names',
    'birth_date',
    'sex_code',
    'birth_place_code',
    'used_last_name',
    'used_first_name',
  ];

  static String fingerprint(Map identity) => sha256
      .convert(
        utf8.encode(
          jsonEncode([for (final key in traits) identity[key] ?? '']),
        ),
      )
      .toString();

  static Map<String, dynamic>? read(Map? identity) {
    final raw = identity?['cnda_recipe_json'];
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw as String));
    } catch (_) {
      throw StateError(
        'Données de recette CNDA illisibles. Rouvrez leur configuration.',
      );
    }
  }

  static void check(Map identity, Map recipe) {
    if (recipe['experimentalBirthPlace'] != null &&
        (recipe['scope'] != scope ||
            !RegExp(
              r'^\d{5}$',
            ).hasMatch('${recipe['experimentalBirthPlace']}') ||
            '${recipe['experimentalBirthPlaceReason'] ?? ''}'.trim().isEmpty ||
            '${recipe['originalBirthPlace'] ?? ''}'.isNotEmpty ||
            '${identity['birth_place_code'] ?? ''}'.isNotEmpty)) {
      throw StateError(
        'Code expérimental réservé à un lieu de naissance absent, avec un motif explicite, sur DV1 uniquement.',
      );
    }
    if (![scope, reviewScope].contains(recipe['scope']) ||
        recipe['schema'] != 1 ||
        identity['identity_fictitious'] != 1 ||
        identity['identity_doubtful'] == 1 ||
        identity['identity_status'] != 'provisional' ||
        recipe['traitsHash'] != fingerprint(identity)) {
      throw StateError(
        'Recette CNDA à confirmer : les informations du patient ont changé ou son statut est incompatible.',
      );
    }
    if (!RegExp(r'^\d{15}$').hasMatch('${recipe['testIns']}') ||
        (recipe['source'] as String? ?? '').trim().isEmpty ||
        (recipe['confirmedAt'] as String? ?? '').isEmpty ||
        [
          'birth_last_name',
          'birth_first_names',
          'birth_date',
          'sex_code',
        ].any((key) => '${identity[key] ?? ''}'.trim().isEmpty)) {
      throw StateError(
        'Recette CNDA incomplète : renseignez les traits fournis, l’INS de test et sa référence.',
      );
    }
  }
}
