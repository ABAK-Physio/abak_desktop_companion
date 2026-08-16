import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ws_ins2_request_builder.dart';

void main() {
  const builder = PatientFrInsiWsIns2RequestBuilder();

  test('buildBody creates WS_INS2 body with one first name', () {
    final xml = builder.buildBody(
      birthLastName: 'ADRDEUX',
      firstNames: const ['LAURENT'],
      sexCode: 'M',
      birthDate: '1981-01-01',
      birthPlaceCode: '63220',
    );

    final document = XmlDocument.parse(xml);
    final root = document.rootElement;

    expect(root.name.local, 'RECSANSVITALE');
    expect(
      root.name.namespaceUri,
      'http://www.cnamts.fr/INSiRecSans',
    );

    expect(
      root.findElements('NomNaissance').single.innerText,
      'ADRDEUX',
    );

    expect(
      root.findElements('Prenom').single.innerText,
      'LAURENT',
    );

    expect(
      root.findElements('Sexe').single.innerText,
      'M',
    );

    expect(
      root.findElements('DateNaissance').single.innerText,
      '1981-01-01',
    );

    expect(
      root.findElements('LieuNaissance').single.innerText,
      '63220',
    );
  });

  test('buildBody creates one Prenom element for each first name', () {
    final xml = builder.buildBody(
      birthLastName: 'DUPONT',
      firstNames: const [
        'JEAN',
        'PIERRE',
        'PAUL',
      ],
      sexCode: 'M',
      birthDate: '1980-01-01',
    );

    final document = XmlDocument.parse(xml);

    final firstNames = document.rootElement
        .findElements('Prenom')
        .map((element) => element.innerText)
        .toList();

    expect(
      firstNames,
      [
        'JEAN',
        'PIERRE',
        'PAUL',
      ],
    );
  });

  test('buildBody omits birth place when it is not provided', () {
    final xml = builder.buildBody(
      birthLastName: 'ADRDEUX',
      firstNames: const ['LAURENT'],
      sexCode: 'M',
      birthDate: '1981-01-01',
    );

    final document = XmlDocument.parse(xml);

    expect(
      document.rootElement.findElements('LieuNaissance'),
      isEmpty,
    );
  });
}