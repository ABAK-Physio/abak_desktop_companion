import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/expired_authorization_recipe.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/platform_support.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';

const soap = 'http://www.w3.org/2003/05/soap-envelope';
const hl7 = 'urn:hl7-org:v3';
const wsa = 'http://www.w3.org/2005/08/addressing';
const oid = '1.2.250.1.213.1.4.10';
const messageId = 'urn:uuid:00000000-0000-4000-8000-000000000001';

// Synthetic correlated SOAP only: no real server response or authorization.
String request() =>
    '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa" xmlns:h="$hl7" '
    'xmlns:a="urn:oasis:names:tc:SAML:2.0:assertion">'
    '<s:Header><w:Action>urn:hl7-org:v3:PRPA_IN201307UV02</w:Action>'
    '<w:MessageID>$messageId</w:MessageID>'
    '<a:NameID>${Dv1ExpiredAuthorizationRecipe.professional}</a:NameID></s:Header>'
    '<s:Body><h:PRPA_IN201307UV02><h:id root="2.25.1" extension="q1"/>'
    '<h:controlActProcess><h:queryByParameter><h:queryId root="2.25.2" extension="q2"/>'
    '<h:parameterList><h:patientIdentifier>'
    '<h:value root="$oid" extension="${Dv1ExpiredAuthorizationRecipe.ins}"/>'
    '</h:patientIdentifier></h:parameterList></h:queryByParameter>'
    '</h:controlActProcess></h:PRPA_IN201307UV02></s:Body></s:Envelope>';

String response({
  String right = 'EXPIRE',
  String status = 'active',
  String ack = 'AA',
  String relates = messageId,
  String ins = Dv1ExpiredAuthorizationRecipe.ins,
}) =>
    '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa" xmlns:h="$hl7">'
    '<s:Header><w:Action>urn:hl7-org:v3:PRPA_IN201308UV02</w:Action>'
    '<w:RelatesTo>$relates</w:RelatesTo></s:Header><s:Body><h:PRPA_IN201308UV02>'
    '<h:acknowledgement typeCode="$ack"><h:targetMessage>'
    '<h:id root="2.25.1" extension="q1"/></h:targetMessage></h:acknowledgement>'
    '<h:attentionLine><h:keyWordText code="AUTORISATION"/>'
    '<h:value code="$right"/></h:attentionLine><h:controlActProcess>'
    '<h:queryAck><h:queryId root="2.25.2" extension="q2"/>'
    '<h:queryResponseCode code="OK"/></h:queryAck>'
    '<h:subject><h:registrationEvent><h:subject1><h:patient>'
    '<h:id root="$oid" extension="$ins"/><h:statusCode code="$status"/>'
    '</h:patient></h:subject1></h:registrationEvent></h:subject>'
    '</h:controlActProcess></h:PRPA_IN201308UV02></s:Body></s:Envelope>';

Td02Result read(String xml) => Td02Reader.read(
  request: request(),
  response: xml,
  context: const Td02Context(
    ins: Dv1ExpiredAuthorizationRecipe.ins,
    oid: oid,
    professional: Dv1ExpiredAuthorizationRecipe.professional,
  ),
);

void checkInputs({
  String scenario = Dv1ExpiredAuthorizationRecipe.scenario,
  String patient = Dv1ExpiredAuthorizationRecipe.patient,
  String ins = Dv1ExpiredAuthorizationRecipe.ins,
  String birth = Dv1ExpiredAuthorizationRecipe.birth,
  String professional = Dv1ExpiredAuthorizationRecipe.professional,
}) => Dv1ExpiredAuthorizationRecipe.checkInputs(
  scenario: scenario,
  patient: patient,
  ins: ins,
  birth: birth,
  professional: professional,
);

void main() {
  test(
    'accepts CNDA fixture in either name order without creating a patient',
    () {
      checkInputs();
      checkInputs(patient: '  Simone   Sartre  ');
    },
  );
  test(
    'rejects another patient, INS, birth date, professional or test code',
    () {
      for (final action in <void Function()>[
        () => checkInputs(patient: 'BONNEL SYLVAIN'),
        () => checkInputs(ins: '187012425258307'),
        () => checkInputs(birth: '1995-01-02'),
        () => checkInputs(professional: '899700854237'),
        () => checkInputs(scenario: 'PRE_TD0.2'),
      ]) {
        expect(action, throwsStateError);
      }
    },
  );
  test('Windows enables TD0.2 only with an explicit supported operation', () {
    expect(
      dv1AccessPlatformSupported(platform: 'windows', existenceCheck: true),
      isTrue,
    );
    expect(dv1AccessPlatformSupported(platform: 'windows'), isFalse);
    expect(
      dv1AccessPlatformSupported(
        platform: 'windows',
        existenceCheck: true,
        otherAction: true,
      ),
      isFalse,
    );
  });
  test('existing search and macOS behavior remain available', () {
    expect(
      dv1AccessPlatformSupported(platform: 'windows', documentSearch: true),
      isTrue,
    );
    expect(
      dv1AccessPlatformSupported(
        platform: 'windows',
        documentSearch: true,
        otherAction: true,
      ),
      isFalse,
    );
    for (final existence in [true, false]) {
      for (final search in [true, false]) {
        for (final other in [true, false]) {
          expect(
            dv1AccessPlatformSupported(
              platform: 'macos',
              existenceCheck: existence,
              documentSearch: search,
              otherAction: other,
            ),
            isTrue,
          );
          expect(
            dv1AccessPlatformSupported(
              platform: 'linux',
              existenceCheck: existence,
              documentSearch: search,
              otherAction: other,
            ),
            isFalse,
          );
        }
      }
    }
  });
  test('correlated AA + active + EXPIRE matches the requested test', () {
    final result = read(response());
    expect(result.state, DmpState.active);
    expect(result.right, ConsultationRight.expired);
    expect(Dv1ExpiredAuthorizationRecipe.matches(result), isTrue);
    expect(result.message, contains('expirée'));
    expect(result.canSendNetworkRequest, isFalse);
    expect(
      result.allows(
        DmpAction.consult,
        opposition: false,
        functionalRights: true,
        authorRights: true,
        consultationConsent: true,
      ),
      isFalse,
    );
  });
  test('absent, blocked, valid and unknown rights never pass as expired', () {
    for (final right in ['NON_EXISTE', 'INTERDIT', 'VALIDE', 'INCONNU']) {
      expect(
        Dv1ExpiredAuthorizationRecipe.matches(read(response(right: right))),
        isFalse,
      );
    }
  });
  test('closed DMP does not pass with an expired authorization', () {
    expect(
      Dv1ExpiredAuthorizationRecipe.matches(
        read(response(status: 'terminated')),
      ),
      isFalse,
    );
  });
  test('failed HL7 acknowledgement or correlation cannot pass', () {
    for (final xml in [
      response(ack: 'AE'),
      response(relates: 'another-request'),
      response(ins: '187012425258307'),
    ]) {
      final result = read(xml);
      expect(result.state, DmpState.unknown);
      expect(Dv1ExpiredAuthorizationRecipe.matches(result), isFalse);
    }
  });
  test('invalid XML and transport errors never pass', () {
    expect(Dv1ExpiredAuthorizationRecipe.matches(read('<broken')), isFalse);
    final result = Td02Reader.read(
      request: request(),
      response: response(),
      context: const Td02Context(
        ins: Dv1ExpiredAuthorizationRecipe.ins,
        oid: oid,
        professional: Dv1ExpiredAuthorizationRecipe.professional,
      ),
      httpStatus: 503,
    );
    expect(Dv1ExpiredAuthorizationRecipe.matches(result), isFalse);
  });
}
