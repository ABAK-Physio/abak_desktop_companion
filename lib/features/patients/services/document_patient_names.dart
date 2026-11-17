/// Explicit RNIV traits shared by the CDA header and XDS sourcePatientInfo.
/// A compound first name is never guessed by splitting a list of given names.
class DocumentPatientNames {
  DocumentPatientNames._(
    this.birthFamily,
    this.birthGiven,
    this.firstBirth,
    this.usedFamily,
    this.usedGiven,
  );

  final String birthFamily, birthGiven, firstBirth;
  final String? usedFamily, usedGiven;

  factory DocumentPatientNames.fromIdentity(Map identity) {
    String? value(String key) {
      final raw = identity[key];
      if (raw == null) return null;
      if (raw is! String || RegExp(r'[\x00-\x1f\x7f]').hasMatch(raw)) {
        throw StateError('Trait d’identité absent ou invalide : $key.');
      }
      final text = raw.trim();
      return text.isEmpty ? null : text;
    }

    final family = value('birth_last_name');
    final given = value('birth_first_names');
    if (family == null || given == null) {
      throw StateError(
        'Nom et liste des prénoms de naissance requis pour le CDA.',
      );
    }
    var first = value('first_birth_name');
    if (first == null) {
      // Preserve the existing unambiguous single-name path only.
      if (RegExp(r'\s|,|;').hasMatch(given)) {
        throw StateError(
          'Renseignez explicitement le premier prénom de naissance dans la fiche patient avant les contrôles CDA.',
        );
      }
      first = given;
    }
    String comparable(String s) =>
        s.replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
    final full = comparable(given), leading = comparable(first);
    if (full != leading && !full.startsWith('$leading ')) {
      throw StateError(
        'Le premier prénom de naissance ne correspond pas au début de la liste des prénoms enregistrée.',
      );
    }
    return DocumentPatientNames._(
      family,
      given,
      first,
      value('used_last_name'),
      value('used_first_name'),
    );
  }

  /// CI-SIS Partage de Documents de Santé 1.16.1, section 3.4.43.8.1.
  List<String> get pid5 {
    for (final text in [
      birthFamily,
      firstBirth,
      birthGiven,
      usedFamily,
      usedGiven,
    ]) {
      if (text != null && RegExp(r'[\^~|&\\]').hasMatch(text)) {
        throw StateError('Un trait d’identité contient un séparateur HL7.');
      }
    }
    return [
      'PID-5|${[birthFamily, firstBirth, birthGiven, '', '', '', 'L'].join('^')}',
      if (usedFamily != null || usedGiven != null)
        'PID-5|${[usedFamily ?? '', usedGiven ?? '', '', '', '', '', 'D'].join('^')}',
    ];
  }
}
