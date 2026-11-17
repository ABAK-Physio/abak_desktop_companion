import '../cps/cps_profile.dart';

/// Use the actual selected CPS situation, never an absent DV1 setting or a
/// hard-coded structure. Called only after the operator confirms the PIN.
String tls050CpsStructure(
  CpsProfile profile, {
  required String professional,
  required int situationNumber,
  required int situationMode,
  required int situationStatus,
  required String situationSector,
}) {
  final matches = profile.situations
      .where((s) => s.number == situationNumber)
      .toList();
  if (profile.nationalId != professional ||
      profile.professionCode != 70 ||
      matches.length != 1) {
    throw StateError('CPS ou situation différente du contexte de recette.');
  }
  final situation = matches.single;
  final structure = situation.structureId;
  if (situation.mode != situationMode ||
      situation.status != situationStatus ||
      situation.sector != situationSector ||
      !RegExp(r'^SA\d{2}$').hasMatch(situationSector) ||
      structure == null ||
      !RegExp(r'^\d{1,30}$').hasMatch(structure)) {
    throw StateError('Situation CPS incomplète ou différente de la recette.');
  }
  return structure;
}
