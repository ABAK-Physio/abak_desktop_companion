import 'package:xml/xml.dart';

class PatientFrInsiWsIns2RequestBuilder {
  const PatientFrInsiWsIns2RequestBuilder();

  String buildBody({
    String? birthLastName,
    List<String> firstNames = const [],
    String? sexCode,
    String? birthDate,
    String? birthPlaceCode,
  }) {
    final name = birthLastName?.trim().toUpperCase() ?? '';
    final names = firstNames.map((n) => n.trim().toUpperCase()).toList();
    final sex = sexCode?.trim().toUpperCase() ?? '';
    final date = birthDate?.trim() ?? '';
    final place = birthPlaceCode?.trim().toUpperCase() ?? '';
    if (!_validName(name, firstName: false)) {
      throw ArgumentError('Nom de naissance absent ou incompatible avec le format INSi.');
    }
    // WS_INS2 accepts exactly one Prenom, including a compound given name.
    // The local list and successive attempts are handled by the caller.
    if (names.length != 1 || !_validName(names.single, firstName: true)) {
      throw ArgumentError('Un seul prénom non vide est attendu par requête INSi.');
    }
    if (!['M', 'F'].contains(sex)) {
      throw ArgumentError('Le sexe doit être M ou F.');
    }
    final parsed = DateTime.tryParse(date);
    if (!RegExp(r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$').hasMatch(date) ||
        parsed == null || parsed.year < 1 ||
        parsed.toIso8601String().substring(0, 10) != date) {
      throw ArgumentError('Date de naissance invalide : format AAAA-MM-JJ attendu.');
    }
    if (place.isNotEmpty && !RegExp(r'^(?:[0-9]{5}|2[AB][0-9]{3})$').hasMatch(place)) {
      throw ArgumentError('Le code INSEE doit comporter cinq caractères (code postal exclu).');
    }
    final builder = XmlBuilder();

    builder.element(
      'RECSANSVITALE',
      attributes: {
        'xmlns': 'http://www.cnamts.fr/INSiRecSans',
      },
      nest: () {
        builder.element('NomNaissance', nest: name);
        builder.element('Prenom', nest: names.single);
        builder.element('Sexe', nest: sex);
        builder.element('DateNaissance', nest: date);
        if (place.isNotEmpty) {
          builder.element('LieuNaissance', nest: place);
        }
      },
    );

    return builder.buildDocument().rootElement.toXmlString();
  }

  static bool _validName(String value, {required bool firstName}) {
    if (value.isEmpty || !RegExp(r"^[A-Z' -]+$").hasMatch(value) ||
        value.startsWith('-') || value.contains('  ') || value.contains("''")) {
      return false;
    }
    if (firstName) {
      return !value.endsWith('-') && !value.endsWith("'");
    }
    return !value.contains(" '") && !value.contains("' ");
  }
}
