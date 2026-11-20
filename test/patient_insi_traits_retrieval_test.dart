import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_retrieval_service.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ws_ins2_request_builder.dart';
import 'package:abak_desktop_companion/features/patients/screens/patient_insi_dialogs.dart';

void main() {
  XmlDocument request() => XmlDocument.parse(
    PatientInsiRetrievalService.buildTraitsRequest(
      const PatientFrInsiWsIns2RequestBuilder().buildBody(
        birthLastName: 'EXEMPLE', firstNames: const ['JEAN CLAUDE'],
        sexCode: 'M', birthDate: '1990-04-14',
      ),
      {'professional': '899700870597', 'authorization': 'TEST',
        'version': '1.0.2', 'instance': 'test-instance'},
      '<Assertion xmlns="urn:oasis:names:tc:SAML:2.0:assertion" ID="PS-test"/>',
      DateTime.utc(2026, 11, 20), 'test-message',
    ),
  );
  Iterable<XmlElement> elements(XmlDocument doc, String name) =>
      doc.descendants.whereType<XmlElement>().where((e) => e.name.local == name);

  test('WS_INS2 envelope uses traits action and one compound given name', () {
    final doc = request();
    expect(elements(doc, 'Action').single.innerText,
      'urn:ServiceIdentiteCertifiee:1.0.0:rechercherInsAvecTraitsIdentite');
    expect(elements(doc, 'RECSANSVITALE').length, 1);
    expect(elements(doc, 'RECVITALE'), isEmpty);
    expect(elements(doc, 'Prenom').single.innerText, 'JEAN CLAUDE');
    expect(elements(doc, 'IDAM').single.getAttribute('R'), '4');
  });

  test('WS_INS2 contains PS assertion with empty coverage and no Vitale assertion', () {
    final doc = request();
    expect(elements(doc, 'COUVERTURE').single.children, isEmpty);
    expect(elements(doc, 'ASSURE'), isEmpty);
    expect(elements(doc, 'BENEFICIAIRE'), isEmpty);
    expect(elements(doc, 'Assertion').single.getAttribute('ID'), 'PS-test');
    expect(elements(doc, 'NameID').where((e) => e.getAttribute('NameQualifier') == 'VITALE'), isEmpty);
  });

  test('invalid traits are refused before platform or network operations', () {
    expect(() => PatientInsiRetrievalService().retrieveWithTraits(
      birthLastName: '', firstName: 'JEAN', sexCode: 'M', birthDate: '1990-04-14',
      pin: 'unused', retainExchange: (_) async {},
    ), throwsArgumentError);
  });

  testWidgets('traits confirmation rejects incomplete data without requesting a PIN', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: PatientInsiTraitsDialog(initial: {}),
    )));
    await tester.tap(find.text('Continuer vers la CPS'));
    await tester.pump();
    expect(find.text('Nom de naissance absent ou incompatible avec le format INSi.'), findsOneWidget);
    expect(find.text('PIN de la CPS'), findsNothing);
  });

  testWidgets('CNDA fictitious traits form keeps the test context explicit', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: PatientInsiTraitsDialog(initial: {}, isFictitiousTest: true),
    )));
    expect(find.textContaining('Patient fictif CNDA — recherche'), findsOneWidget);
    await tester.tap(find.text('Continuer vers la CPS'));
    await tester.pump();
    expect(find.text('Nom de naissance absent ou incompatible avec le format INSi.'), findsOneWidget);
    expect(find.text('PIN de la CPS'), findsNothing);
  });

  testWidgets('CPS confirmation identifies a fictitious test without Vitale', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: PatientInsiPinDialog(patient: 'TEST CNDA', withVitale: false, isFictitiousTest: true),
    )));
    expect(find.textContaining('Patient fictif CNDA — appel'), findsOneWidget);
    expect(find.textContaining('Recherche par traits saisis, sans lecture'), findsOneWidget);
  });

}
