import '../../../../cps/cps_profile.dart';
import '../../document_medical_service.dart';

/// Explicit CNDA recipe input. Never a patient qualification or a deposit grant.
class Dv1AccessContext {
  Dv1AccessContext({
    required this.professional,
    required this.structure,
    required this.sector,
    required this.ins,
    required this.patientLabel,
    required this.source,
    required this.scenario,
    required this.confirmedAt,
    this.replacementUntil,
    this.birthDate,
    this.minorsEnabled = false,
    this.majorityAge = 18,
    this.secretConnection = false,
  });
  final String professional,
      structure,
      sector,
      ins,
      patientLabel,
      source,
      scenario;
  final DateTime confirmedAt;
  final DateTime? replacementUntil;
  final String? birthDate;
  final bool minorsEnabled, secretConnection;
  final int majorityAge;

  int ageAt(DateTime now) {
    final value = birthDate ?? '';
    final birth = DateTime.tryParse(value);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
        birth == null ||
        birth.toIso8601String().substring(0, 10) != value ||
        birth.isAfter(DateTime(now.year, now.month, now.day))) {
      throw StateError(
        'Indiquez la date de naissance exacte du patient de recette (AAAA-MM-JJ).',
      );
    }
    return now.year -
        birth.year -
        (now.month < birth.month ||
                (now.month == birth.month && now.day < birth.day)
            ? 1
            : 0);
  }

  bool offersSecret(DateTime now) => minorsEnabled && ageAt(now) < majorityAge;

  Dv1AccessContext withSecretConnection(bool secret) => Dv1AccessContext(
    professional: professional,
    structure: structure,
    sector: sector,
    ins: ins,
    patientLabel: patientLabel,
    source: source,
    scenario: scenario,
    confirmedAt: confirmedAt,
    replacementUntil: replacementUntil,
    birthDate: birthDate,
    minorsEnabled: minorsEnabled,
    majorityAge: majorityAge,
    secretConnection: secret,
  );
  static const endpoint =
      'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/patients';
  void check(DateTime now) {
    if (majorityAge < 1 ||
        majorityAge > 120 ||
        (secretConnection && !offersSecret(now.toLocal()))) {
      throw StateError(
        'Connexion secrète indisponible pour ce patient et ces paramètres DMP.',
      );
    }
    if (birthDate != null) ageAt(now.toLocal());
    if (!RegExp(r'^\d{1,30}$').hasMatch(structure)) {
      throw StateError(
        'Complétez l’identifiant de la structure d’exercice pour cet essai, en haut de cet écran.',
      );
    }
    if (!RegExp(r'^\d{8,16}$').hasMatch(professional) ||
        !RegExp(r'^\d{1,30}$').hasMatch(structure) ||
        !RegExp(r'^SA\d{2}$').hasMatch(sector) ||
        !RegExp(r'^\d{15}$').hasMatch(ins) ||
        [
          patientLabel,
          source,
          scenario,
        ].any((v) => v.trim().isEmpty || v.length > 2000) ||
        now.isBefore(confirmedAt) ||
        now.difference(confirmedAt) >= const Duration(minutes: 10) ||
        (replacementUntil != null && !now.isBefore(replacementUntil!))) {
      throw StateError(
        'Complétez le scénario CNDA, le patient fictif et la structure ; vérifiez la fin du remplacement.',
      );
    }
  }

  bool matches(CpsProfile p, CpsSituation s, DateTime now) {
    check(now);
    if (p.nationalId != professional || p.professionCode != 70) return false;
    if (replacementUntil != null) {
      // Only the documented replacement situation may supply missing structure
      // and sector from a user-confirmed, time-limited recipe association.
      return s.mode == 4 &&
          s.status == 1 &&
          (s.structureId == null || s.structureId == structure) &&
          (s.sector == null || s.sector == sector);
    }
    return s.structureId == structure && s.sector == sector;
  }

  Map<String, dynamic> get snapshot => {
    'identity': {
      'ins_number': ins.substring(0, 13),
      'ins_key': ins.substring(13),
      'ins_oid': '1.2.250.1.213.1.4.10',
      'origin': 'CNDA — saisie de recette, non qualifiée par Companion',
    },
    'practice': {
      'data_json': medicalCanonical({
        'identifier': professional,
        'authority': '1.2.250.1.71.4.2.1',
        'structureId': structure,
        'facilityCode': sector,
        'professionCode': 'G15_70',
        'professionLabel': 'Masseur-kinésithérapeute',
        'setting': 'Ambulatoire',
        'replacementFor': '',
      }),
    },
    'recipe': {
      'patient': patientLabel,
      'source': source,
      'scenario': scenario,
      'birthDate': birthDate,
      'minorsEnabled': minorsEnabled,
      'majorityAge': majorityAge,
      'secretConnection': secretConnection,
      'confirmedAt': confirmedAt.toIso8601String(),
      'replacementUntil': replacementUntil?.toIso8601String(),
      'scope': 'TD0.2 réel sur DV1, sans dépôt, sans qualification INS',
    },
  };
}
