import 'package:flutter_test/flutter_test.dart';

import 'package:abak_desktop_companion/features/patients/models/patient_fr_insi_ps_assertion_data.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_assertion_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_digest_service.dart';

void main() {
  const assertionBuilder = PatientFrInsiPsAssertionBuilder();
  const digestService = PatientFrInsiPsDigestService();

  PatientFrInsiPsAssertionData createData({
    String professionalId = '810000000000',
  }) {
    return PatientFrInsiPsAssertionData(
      assertionId: '_e451e702-85aa-4c55-a083-7f02da22cc40',
      issueInstant: DateTime.utc(2026, 8, 15, 14, 0),
      issuer: 'CN=TEST PS,OU=TEST,O=TEST,C=FR',
      professionalId: professionalId,
      billingIdentifier: '999999999',
      activitySector: 'SA07',
    );
  }

  test('computeDigestValue is deterministic', () {
    final assertionXml = assertionBuilder.buildUnsigned(
      createData(),
    );

    final firstDigest = digestService.computeDigestValue(
      assertionXml,
    );

    final secondDigest = digestService.computeDigestValue(
      assertionXml,
    );

    expect(firstDigest, isNotEmpty);
    expect(secondDigest, firstDigest);
  });

  test('computeDigestValue changes when assertion changes', () {
    final firstAssertion = assertionBuilder.buildUnsigned(
      createData(),
    );

    final secondAssertion = assertionBuilder.buildUnsigned(
      createData(
        professionalId: '810000000001',
      ),
    );

    final firstDigest = digestService.computeDigestValue(
      firstAssertion,
    );

    final secondDigest = digestService.computeDigestValue(
      secondAssertion,
    );

    expect(firstDigest, isNot(secondDigest));
  });

  test('computeDigestValue returns SHA-256 Base64 length', () {
    final assertionXml = assertionBuilder.buildUnsigned(
      createData(),
    );

    final digest = digestService.computeDigestValue(
      assertionXml,
    );

    // SHA-256 = 32 octets.
    // Encodé en Base64, le résultat comporte 44 caractères.
    expect(digest, hasLength(44));
  });
  test('computeDigestValue matches official WS_INS2 example', () {
    //noinspection XmlUnboundNsPrefix,XmlPathReference
    const assertionXml = '''
<saml2:Assertion xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion" ID="_65e283f4-2757-4de1-aadb-0abf9302e26b" IssueInstant="2020-11-20T07:29:12.719Z" Version="2.0"><saml2:Issuer Format="urn:oasis:names:tc:SAML:1.1:nameid-format:X509SubjectName">SN2=MAX + OID.2.5.4.4=LIBRE + CN=899900063480, OID.2.5.4.12=Médecin, C=FR</saml2:Issuer><saml2:Subject><saml2:NameID NameQualifier="CPS">899900063480</saml2:NameID></saml2:Subject><saml2:AttributeStatement><saml2:Attribute Name="codeSpecialite"><AttributeValue xmlns="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">SM26</AttributeValue></saml2:Attribute><saml2:Attribute Name="secteurActivite"><AttributeValue xmlns="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">SA07</AttributeValue></saml2:Attribute><saml2:Attribute Name="identifiantFacturation"><AttributeValue xmlns="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">991130972</AttributeValue></saml2:Attribute></saml2:AttributeStatement></saml2:Assertion>
''';

    final digest = digestService.computeDigestValue(
      assertionXml.trim(),
    );

    expect(
      digest,
      'jJYUx60/kK1eNOQr6Jywnjlvj1N+D3dzBYvkENc+acc=',
    );
  });
}