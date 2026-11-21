import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ws_ins3_request_builder.dart';

void main() {
  const builder = PatientFrInsiWsIns3RequestBuilder();
  const req = PatientFrInsiWsIns3RequestBuilder.requestNamespace;
  const ins = PatientFrInsiWsIns3RequestBuilder.identityNamespace;

  Map<String, String> sample() => {
    'insNumber': '1900463220899',
    'insKey': '81',
    'insOid': '1.2.250.1.213.1.4.8',
    'birthLastName': "D'ARTAGNAN DE L'HERAULT",
    'givenNames': 'PIERRE-ALAIN BRUCE GORDON',
    'sexCode': 'M',
    'birthDate': '1990-04-14',
    'birthPlaceCode': '63220',
  };

  String build(Map<String, String> values) => builder.buildBody(
    insNumber: values['insNumber']!,
    insKey: values['insKey']!,
    insOid: values['insOid']!,
    birthLastName: values['birthLastName']!,
    givenNames: values['givenNames']!,
    sexCode: values['sexCode']!,
    birthDate: values['birthDate']!,
    birthPlaceCode: values['birthPlaceCode'],
  );

  test('uses the WS_INS3 action from the official WSDL', () {
    expect(PatientFrInsiWsIns3RequestBuilder.action,
      'urn:ServiceVerificationIdentiteCertifiee:1.0.0:verifierInsAvecTraitsIdentite');
  });

  test('CNDA case 1 uses the two namespaces and correct element order', () {
    final root = XmlDocument.parse(build(sample())).rootElement;
    expect(root.name.local, 'RequeteUnitaire');
    expect(root.name.namespaceUri, req);
    final individual = root.findElements('IndividuVerifie', namespaceUri: req).single;
    expect(individual.childElements.map((e) => e.name.local),
      ['INSFourni', 'TraitsIdentiteIndividu']);
    final supplied = individual.findElements('INSFourni', namespaceUri: req).single;
    expect(supplied.childElements.map((e) => e.name.local), ['IdIndividu', 'OID']);
    expect(supplied.childElements.every((e) => e.name.namespaceUri == ins), isTrue);
    final id = supplied.findElements('IdIndividu', namespaceUri: ins).single;
    expect(id.childElements.map((e) => e.name.local), ['NumIdentifiant', 'Cle']);
    expect(id.findElements('NumIdentifiant', namespaceUri: ins).single.innerText,
      '1900463220899');
    expect(id.findElements('Cle', namespaceUri: ins).single.innerText, '81');
    final traits = individual
        .findElements('TraitsIdentiteIndividu', namespaceUri: req).single;
    expect(traits.childElements.map((e) => e.name.local), [
      'NomNaissance', 'ListePrenom', 'Sexe', 'DateNaissance', 'LieuNaissance',
    ]);
    expect(traits.childElements.every((e) => e.name.namespaceUri == ins), isTrue);
    expect(traits.findElements('ListePrenom', namespaceUri: ins).single.innerText,
      'PIERRE-ALAIN BRUCE GORDON');
    expect(traits.findElements('NomNaissance', namespaceUri: ins).single.innerText,
      "D'ARTAGNAN DE L'HERAULT");
    expect(root.descendants.whereType<XmlElement>()
        .where((e) => ['Prenom', 'TypeMatricule'].contains(e.name.local)), isEmpty);
  });

  test('CNDA Corsican cases preserve letters in INS and birthplace', () {
    for (final value in [
      ['160012B020777', '13', '2B020'],
      ['199012A019999', '17', '2A019'],
    ]) {
      final values = sample()
        ..['insNumber'] = value[0]
        ..['insKey'] = value[1]
        ..['birthPlaceCode'] = value[2];
      final doc = XmlDocument.parse(build(values));
      expect(doc.findAllElements('NumIdentifiant', namespaceUri: ins).single.innerText,
        value[0]);
      expect(doc.findAllElements('LieuNaissance', namespaceUri: ins).single.innerText,
        value[2]);
    }
  });

  test('CNDA case 13 omits optional birthplace', () {
    final values = sample()..remove('birthPlaceCode');
    expect(XmlDocument.parse(build(values))
        .findAllElements('LieuNaissance', namespaceUri: ins), isEmpty);
    values['birthPlaceCode'] = '  ';
    expect(XmlDocument.parse(build(values))
        .findAllElements('LieuNaissance', namespaceUri: ins), isEmpty);
  });

  test('CNDA case 14 keeps the NIA OID', () {
    final values = sample()
      ..['insNumber'] = '1090763220888'
      ..['insKey'] = '35'
      ..['insOid'] = '1.2.250.1.213.1.4.9';
    final doc = XmlDocument.parse(build(values));
    expect(doc.findAllElements('OID', namespaceUri: ins).single.innerText,
      '1.2.250.1.213.1.4.9');
  });

  test('blocks every missing mandatory WS_INS3 field before building', () {
    for (final field in sample().keys.where((k) => k != 'birthPlaceCode')) {
      final values = sample()..[field] = '  ';
      expect(() => build(values), throwsArgumentError, reason: field);
    }
  });

  test('rejects malformed identifiers and identity formats', () {
    for (final invalid in <String, List<String>>{
      'insNumber': ['190046322089981', '190046322089', '160012C020777'],
      'insKey': ['8', 'ABC'],
      'insOid': ['1.2.3.4'],
      'sexCode': ['X'],
      'birthDate': ['14/04/1990', '1990-4-14'],
      'birthPlaceCode': ['ABC', '2C019'],
    }.entries) {
      for (final value in invalid.value) {
        final values = sample()..[invalid.key] = value;
        expect(() => build(values), throwsArgumentError,
          reason: '${invalid.key}: $value');
      }
    }
  });

  test('does not repair a wrong key or normalize reference dates', () {
    final values = sample()
      ..['insKey'] = '82'
      ..['birthDate'] = '1990-00-00'
      ..['givenNames'] = 'PIERRE-ALAIN BRUCE';
    final doc = XmlDocument.parse(build(values));
    expect(doc.findAllElements('Cle', namespaceUri: ins).single.innerText, '82');
    expect(doc.findAllElements('DateNaissance', namespaceUri: ins).single.innerText,
      '1990-00-00');
    expect(doc.findAllElements('ListePrenom', namespaceUri: ins).single.innerText,
      'PIERRE-ALAIN BRUCE');
  });

  test('rejects XML markup in identity data before building', () {
    final values = sample()..['birthLastName'] = 'TEST & <INS>';
    expect(() => build(values), throwsArgumentError);
  });

  test('rejects invalid name formats required by CNDA 3.03', () {
    for (final field in ['birthLastName', 'givenNames']) {
      for (final value in [
        'Dupont', 'DUPRÉ', 'D’ARTAGNAN', 'DUPONT/TEST', '-DUPONT',
        'JEAN  PAUL', "D''ARTAGNAN", "D' ARTAGNAN", "JEAN 'PAUL", 'MARTIN---DURAND',
      ]) {
        final values = sample()..[field] = value;
        expect(() => build(values), throwsArgumentError, reason: '$field: $value');
      }
    }
    for (final value in ['JEAN--PAUL', 'JEAN-', "JEAN'", 'JEAN- PAUL', 'JEAN -PAUL']) {
      final values = sample()..['givenNames'] = value;
      expect(() => build(values), throwsArgumentError, reason: value);
    }
  });

  test('preserves valid compound names, leading apostrophe and surname double hyphen', () {
    final values = sample()
      ..['birthLastName'] = 'MARTIN--DURAND'
      ..['givenNames'] = "'ALAIN JEAN-PAUL MARIE CLAUDE";
    final doc = XmlDocument.parse(build(values));
    expect(doc.findAllElements('NomNaissance', namespaceUri: ins).single.innerText,
      'MARTIN--DURAND');
    expect(doc.findAllElements('ListePrenom', namespaceUri: ins).single.innerText,
      "'ALAIN JEAN-PAUL MARIE CLAUDE");
  });
}
