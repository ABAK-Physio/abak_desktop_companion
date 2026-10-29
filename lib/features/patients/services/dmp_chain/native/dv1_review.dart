import 'dart:convert';
import '../../../../dmp_resources/dmp_resources.dart';
import '../../document_journal_service.dart';
import '../../document_medical_service.dart';
import '../../cnda_patient_recipe.dart';
import '../contracts.dart';
import 'dv1_configuration.dart';

/// Explicit observations made for the selected PDT case. They are frozen with
/// the approval and cannot be carried to another PDF, identity or configuration.
class Dv1Review {
  Dv1Review({
    required this.prepared,
    required this.configurationHash,
    required this.scenario,
    required this.source,
    required this.observedAt,
    required this.noOpposition,
    required this.functionalRights,
    required this.testIdentity,
    required this.actor,
  });
  final DocumentAttemptPreparation prepared;
  final String configurationHash, scenario, source;
  final DateTime observedAt;
  final bool noOpposition, functionalRights, testIdentity, actor;
  Map<String, Object?> get evidence => {
    'source': 'confirmation manuelle du professionnel pour la recette',
    'scenario': scenario,
    'observation': source,
    'observedAt': observedAt.toIso8601String(),
    'noOpposition': noOpposition,
    'functionalRights': functionalRights,
    'testIdentity': testIdentity,
    'actor': actor,
    'approvalId': prepared.receipt['approval_id'],
    'snapshotHash': prepared.receipt['snapshot_hash'],
    'configurationHash': configurationHash,
  };
  DmpPolicy policy(
    Dv1Configuration config,
    Map<String, dynamic> snapshot,
    DateTime now,
  ) {
    CndaPatientRecipe.checkDestination(snapshot, Dv1Configuration.repository);
    final expiry = observedAt.add(const Duration(minutes: 10));
    if (now.isBefore(observedAt) ||
        !now.isBefore(expiry) ||
        config.hash != configurationHash ||
        scenario.trim().isEmpty ||
        source.trim().isEmpty ||
        source.length > 2000 ||
        scenario.length > 100 ||
        !noOpposition ||
        !functionalRights ||
        !testIdentity ||
        !actor ||
        medicalHash(snapshot) != prepared.receipt['snapshot_hash']) {
      throw const DmpChainBlock(
        'Conditions de recette absentes, périmées ou liées à une autre version.',
      );
    }
    final prep = jsonDecode(snapshot['preparation']['data_json']);
    final practice = jsonDecode(snapshot['practice']['data_json']);
    final parameters = DmpParameters.parse(config.text('parameters'));
    final birth = DateTime.parse(snapshot['identity']['birth_date']);
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return DmpPolicy(
      snapshotHash: medicalHash(snapshot),
      catalogReference: config.fields['reference'],
      expiresAt: expiry,
      opposition: !noOpposition,
      functionalRights: functionalRights,
      authorRights:
          prep['authorId'] == prep['validatorId'] &&
          practice['identifier'] == config.professional,
      visibilityAllowed:
          !birth.isAfter(now) &&
          age >= parameters.majority &&
          prep['patientVisibility'] == 'visible' &&
          prep['professionalVisibility'] == 'visible' &&
          prep['representativesVisibility'] == 'sans objet',
      codesValid: config.codes(snapshot),
    );
  }
}
