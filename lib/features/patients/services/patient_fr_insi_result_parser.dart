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

    String? singleElementText(String localName, [XmlNode? scope]) {
      final elements = (scope ?? document).descendants
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
      throw const FormatException('Réponse INSi invalide : CodeCR absent');
    }

    final status = patientFrInsiStatusFromCodeCr(codeCr);

    final individuElements = document.descendants
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
      return parse(codeCr: codeCr);
    }

    XmlElement one(String name) {
      final elements = individuElements.single.childElements
          .where((e) => e.name.local == name)
          .toList();
      if (elements.length != 1) {
        throw FormatException('Réponse INSi : $name absent ou multiple.');
      }
      return elements.single;
    }

    final active = one('INSACTIF');
    final traits = one('TIQ');
    return parse(
      codeCr: codeCr,
      insNumber: singleElementText('NumIdentifiant', active),
      insKey: singleElementText('Cle', active),
      insOid: singleElementText('OID', active),
      birthLastName: singleElementText('NomNaissance', traits),
      birthFirstNames: singleElementText('ListePrenom', traits),
      birthDate: singleElementText('DateNaissance', traits),
      sexCode: singleElementText('Sexe', traits),
      birthPlaceCode: singleElementText('LieuNaissance', traits),
    );
  }
}
