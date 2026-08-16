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
    final builder = XmlBuilder();

    builder.element(
      'RECSANSVITALE',
      attributes: {
        'xmlns': 'http://www.cnamts.fr/INSiRecSans',
      },
      nest: () {
        if (birthLastName != null && birthLastName.trim().isNotEmpty) {
          builder.element(
            'NomNaissance',
            nest: birthLastName.trim(),
          );
        }

        for (final firstName in firstNames) {
          final value = firstName.trim();

          if (value.isEmpty) {
            continue;
          }

          builder.element(
            'Prenom',
            nest: value,
          );
        }

        if (sexCode != null && sexCode.trim().isNotEmpty) {
          builder.element(
            'Sexe',
            nest: sexCode.trim(),
          );
        }

        if (birthDate != null && birthDate.trim().isNotEmpty) {
          builder.element(
            'DateNaissance',
            nest: birthDate.trim(),
          );
        }

        if (birthPlaceCode != null &&
            birthPlaceCode.trim().isNotEmpty) {
          builder.element(
            'LieuNaissance',
            nest: birthPlaceCode.trim(),
          );
        }
      },
    );

    return builder.buildDocument().rootElement.toXmlString();
  }
}