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

  test('rejects multiple given names in one request', () {
    expect(() => builder.buildBody(
      birthLastName: 'DUPONT', firstNames: const ['JEAN', 'PIERRE'],
      sexCode: 'M', birthDate: '1980-01-01',
    ), throwsArgumentError);
  });

  test('keeps compound given name in one element and uppercases input', () {
    final xml = builder.buildBody(
      birthLastName: "D'ARTAGNAN DE L'HERAULT", firstNames: const ['Pierre-Alain'],
      sexCode: 'm', birthDate: '1990-04-14',
    );
    final root = XmlDocument.parse(xml).rootElement;
    expect(root.findElements('Prenom').single.innerText, 'PIERRE-ALAIN');
    expect(root.findElements('Sexe').single.innerText, 'M');
  });

  test('rejects missing required identity fields', () {
    expect(() => builder.buildBody(firstNames: const ['JEAN'], sexCode: 'M', birthDate: '1980-01-01'), throwsArgumentError);
    expect(() => builder.buildBody(birthLastName: 'DUPONT', sexCode: 'M', birthDate: '1980-01-01'), throwsArgumentError);
    expect(() => builder.buildBody(birthLastName: 'DUPONT', firstNames: const ['JEAN'], birthDate: '1980-01-01'), throwsArgumentError);
    expect(() => builder.buildBody(birthLastName: 'DUPONT', firstNames: const ['JEAN'], sexCode: 'M'), throwsArgumentError);
  });

  test('rejects ligatures and incompatible name punctuation', () {
    for (final name in ['D’ÆION', 'DUPONT/TEST', '-DUPONT', "D' ART", "D''ART"]) {
      expect(() => builder.buildBody(birthLastName: name, firstNames: const ['JEAN'], sexCode: 'M', birthDate: '1980-01-01'), throwsArgumentError);
    }
    for (final first in ['Cœur', 'JEAN-', "JEAN'", 'JEAN  PAUL']) {
      expect(() => builder.buildBody(birthLastName: 'DUPONT', firstNames: [first], sexCode: 'M', birthDate: '1980-01-01'), throwsArgumentError);
    }
  });

  test('rejects impossible dates and invalid sex or location format', () {
    for (final date in ['1980-02-30', '1980-13-01', '01/01/1980']) {
      expect(() => builder.buildBody(birthLastName: 'DUPONT', firstNames: const ['JEAN'], sexCode: 'M', birthDate: date), throwsArgumentError);
    }
    expect(() => builder.buildBody(birthLastName: 'DUPONT', firstNames: const ['JEAN'], sexCode: 'X', birthDate: '1980-01-01'), throwsArgumentError);
    expect(() => builder.buildBody(birthLastName: 'DUPONT', firstNames: const ['JEAN'], sexCode: 'M', birthDate: '1980-01-01', birthPlaceCode: 'ABC'), throwsArgumentError);
  });

  test('accepts Corsican location format when explicitly provided', () {
    final xml = builder.buildBody(birthLastName: 'CORSE', firstNames: const ['JOSEPH'], sexCode: 'M', birthDate: '1999-01-01', birthPlaceCode: '2A019');
    expect(XmlDocument.parse(xml).rootElement.findElements('LieuNaissance').single.innerText, '2A019');
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