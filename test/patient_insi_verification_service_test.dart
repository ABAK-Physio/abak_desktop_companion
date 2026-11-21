import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_verification_response_parser.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ws_ins3_request_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_exchange.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_retrieval_service.dart';

void main() {
  final now = DateTime.utc(2026, 11, 21);
  const professional = '899700870597';
  const soap = 'http://www.w3.org/2003/05/soap-envelope';

  Map<String, String> input() => {
    'insNumber': '1900463220899', 'insKey': '81',
    'insOid': '1.2.250.1.213.1.4.8',
    'birthLastName': "D'ARTAGNAN DE L'HERAULT",
    'givenNames': 'PIERRE-ALAIN BRUCE GORDON',
    'sexCode': 'M', 'birthDate': '1990-04-14',
  };

  String request() => PatientInsiRetrievalService.buildVerificationRequest(
    const PatientFrInsiWsIns3RequestBuilder().buildBody(
      insNumber: '1900463220899', insKey: '81', insOid: '1.2.250.1.213.1.4.8',
      birthLastName: "D'ARTAGNAN DE L'HERAULT",
      givenNames: 'PIERRE-ALAIN BRUCE GORDON', sexCode: 'M', birthDate: '1990-04-14',
    ),
    {'professional': professional, 'authorization': 'TEST-INSi',
      'version': '1.0.2', 'instance': 'test-instance'},
    '<Assertion xmlns="urn:oasis:names:tc:SAML:2.0:assertion" ID="PS-test"/>',
    now, 'verification-message',
  );

  Iterable<XmlElement> elements(XmlDocument doc, String name) =>
    doc.descendants.whereType<XmlElement>().where((e) => e.name.local == name);

  String reply(String code) => '''
<s:Envelope xmlns:s="$soap"><s:Body>
<r:ResultatUnitaire xmlns:r="http://www.cnamts.fr/INSiLot2/REPUnitaire"
    xmlns:c="http://www.cnamts.fr/MRA/CommunLot">
<r:CrUnitaire><c:CR><c:Code>$code</c:Code><c:Libelle>Compte rendu</c:Libelle>
</c:CR></r:CrUnitaire></r:ResultatUnitaire>
</s:Body></s:Envelope>''';

  InsiExchange exchange(String? xml, {int status = 200}) => InsiExchange(
    id: 'verification-message', requestXml: request(), responseXml: xml,
    httpStatus: status, recordedAt: now,
  );

  test('WS_INS3 envelope selects verification and preserves all supplied traits', () {
    final doc = XmlDocument.parse(request());
    expect(elements(doc, 'Action').single.innerText,
      'urn:ServiceVerificationIdentiteCertifiee:1.0.0:verifierInsAvecTraitsIdentite');
    expect(elements(doc, 'RequeteUnitaire').single.name.namespaceUri,
      'http://www.cnamts.fr/INSiLot2/REQueteUnitaire');
    expect(elements(doc, 'ListePrenom').single.innerText, 'PIERRE-ALAIN BRUCE GORDON');
    expect(elements(doc, 'NumIdentifiant').single.innerText, '1900463220899');
    expect(elements(doc, 'Cle').single.innerText, '81');
    expect(elements(doc, 'OID').single.innerText, '1.2.250.1.213.1.4.8');
    expect(elements(doc, 'MessageID').single.innerText, 'verification-message');
    expect(elements(doc, 'IDAM').single.getAttribute('R'), '4');
    expect(elements(doc, 'IDAM').single.innerText, 'TEST-INSi');
    expect(elements(doc, 'RECSANSVITALE'), isEmpty);
    expect(elements(doc, 'RECVITALE'), isEmpty);
  });

  test('verification includes only the PS assertion, with empty BAM coverage', () {
    final doc = XmlDocument.parse(request());
    expect(elements(doc, 'Assertion').single.getAttribute('ID'), 'PS-test');
    expect(elements(doc, 'COUVERTURE').single.children, isEmpty);
    expect(elements(doc, 'ASSURE'), isEmpty);
    expect(elements(doc, 'BENEFICIAIRE'), isEmpty);
    expect(elements(doc, 'NameID').where((e) => e.getAttribute('NameQualifier') == 'VITALE'),
      isEmpty);
  });

  test('incomplete verification fails before configuration, CPS, HTTP or archival', () {
    var retained = false;
    for (final field in input().keys) {
      final data = input()..[field] = '';
      expect(() => PatientInsiRetrievalService().verify(
        insNumber: data['insNumber']!, insKey: data['insKey']!, insOid: data['insOid']!,
        birthLastName: data['birthLastName']!, givenNames: data['givenNames']!,
        sexCode: data['sexCode']!, birthDate: data['birthDate']!,
        pin: 'unused', retainExchange: (_) async { retained = true; },
      ), throwsArgumentError, reason: field);
    }
    expect(retained, isFalse);
  });

  test('00 preserves XML, request digest, professional and reception metadata', () {
    final evidence = exchange(reply('00'));
    final response = PatientInsiRetrievalService.readVerificationResponse(evidence, professional);
    expect(response.result.status, PatientFrInsiVerificationStatus.verified);
    expect(response.id, evidence.id);
    expect(response.xml, evidence.responseXml);
    expect(response.requestHash, InsiExchange.digest(evidence.requestXml));
    expect(response.professional, professional);
    expect(response.receivedAt, now);
    expect(evidence.toMap()['responseHash'], InsiExchange.digest(response.xml));
  });

  test('01 remains a completed unsuccessful verification rather than a transport error', () {
    final response = PatientInsiRetrievalService.readVerificationResponse(
      exchange(reply('01')), professional);
    expect(response.result.status, PatientFrInsiVerificationStatus.notVerified);
    expect(response.result.codeCr, '01');
    expect(response.result.isVerified, isFalse);
    expect(response.result.isFault, isFalse);
  });

  test('HTTP errors cannot turn a 00 or 01 payload into an accepted result', () {
    for (final status in [500, 403, 503]) {
      for (final code in ['00', '01']) {
        expect(() => PatientInsiRetrievalService.readVerificationResponse(
          exchange(reply(code), status: status), professional), throwsStateError);
      }
    }
  });

  test('SOAP faults remain technical errors on both HTTP 200 and HTTP 500', () {
    final xml = '''
<s:Envelope xmlns:s="$soap"><s:Body><s:Fault>
<s:Code><s:Value>s:Receiver</s:Value></s:Code>
<s:Reason><s:Text xml:lang="fr">Service indisponible</s:Text></s:Reason>
</s:Fault></s:Body></s:Envelope>''';
    for (final status in [200, 500]) {
      expect(() => PatientInsiRetrievalService.readVerificationResponse(
        exchange(xml, status: status), professional), throwsStateError);
    }
  });

  test('incomplete or failed exchanges and unrecognized codes are refused', () {
    expect(() => PatientInsiRetrievalService.readVerificationResponse(
      exchange(null), professional), throwsStateError);
    expect(() => PatientInsiRetrievalService.readVerificationResponse(
      exchange(reply('02')), professional), throwsFormatException);
    expect(() => PatientInsiRetrievalService.readVerificationResponse(
      InsiExchange(id: 'failed', requestXml: request(), responseXml: reply('00'),
        httpStatus: 200, failure: 'Échange interrompu', recordedAt: now),
      professional), throwsStateError);
  });
}
