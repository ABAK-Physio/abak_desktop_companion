import 'package:xml/xml.dart';

import '../models/patient_fr_insi_result.dart';

class PatientFrInsiResultParser {
  const PatientFrInsiResultParser();

  PatientFrInsiResult parse({
    required String codeCr,
    String? insNumber,
    String? insKey,
    String? insOid,
    String? birthLastName,
    String? birthFirstNames,
    String? birthDate,
    String? sexCode,
    String? birthPlaceCode,
  }) {
    final status = patientFrInsiStatusFromCodeCr(codeCr);

    return PatientFrInsiResult(
      status: status,
      insNumber: insNumber,
      insKey: insKey,
      insOid: insOid,
      birthLastName: birthLastName,
      birthFirstNames: birthFirstNames,
      birthDate: birthDate,
      sexCode: sexCode,
      birthPlaceCode: birthPlaceCode,
    );
  }

  PatientFrInsiResult parseXml(String xml) {
    final document = XmlDocument.parse(xml);

    String? singleElementText(String localName) {
      final elements = document
          .descendants
          .whereType<XmlElement>()
          .where((element) => element.name.local == localName)
          .toList();

      if (elements.isEmpty) {
        return null;
      }

      if (elements.length > 1) {
        throw FormatException(
          'Réponse INSi invalide : élément $localName multiple',
        );
      }

      final value = elements.single.innerText.trim();

      return value.isEmpty ? null : value;
    }

    final codeCr = singleElementText('CodeCR');

    if (codeCr == null) {
      throw const FormatException(
        'Réponse INSi invalide : CodeCR absent',
      );
    }

    final status = patientFrInsiStatusFromCodeCr(codeCr);

    final individuElements = document
        .descendants
        .whereType<XmlElement>()
        .where((element) => element.name.local == 'INDIVIDU')
        .toList();

    if (status == PatientFrInsiResultStatus.success &&
        individuElements.length != 1) {
      throw const FormatException(
        'Réponse INSi invalide : INDIVIDU absent ou multiple pour CodeCR 00',
      );
    }

    if (status != PatientFrInsiResultStatus.success) {
      return parse(
        codeCr: codeCr,
      );
    }

    return parse(
      codeCr: codeCr,
      insNumber: singleElementText('NumIdentifiant'),
      insKey: singleElementText('Cle'),
      insOid: singleElementText('OID'),
      birthLastName: singleElementText('NomNaissance'),
      birthFirstNames: singleElementText('ListePrenom'),
      birthDate: singleElementText('DateNaissance'),
      sexCode: singleElementText('Sexe'),
      birthPlaceCode: singleElementText('LieuNaissance'),
    );
  }
}