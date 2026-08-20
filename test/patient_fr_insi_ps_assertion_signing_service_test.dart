import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/models/patient_fr_insi_ps_assertion_data.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_assertion_signing_service.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_signer.dart';

class _FakePatientFrInsiPsSigner implements PatientFrInsiPsSigner {
  const _FakePatientFrInsiPsSigner();

  @override
  Future<String> sign({
    required String canonicalSignedInfo,
  }) async {
    expect(
      canonicalSignedInfo,
      contains('<ds:SignedInfo'),
    );

    expect(
      canonicalSignedInfo,
      contains(
        'Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"',
      ),
    );

    return 'TEST_SIGNATURE_BASE64';
  }
}

void main() {
  const service = PatientFrInsiPsAssertionSigningService(
    signer: _FakePatientFrInsiPsSigner(),
  );

  test('buildSignedAssertion creates complete signed PS assertion', () async {
    final data = PatientFrInsiPsAssertionData(
      assertionId: '_e451e702-85aa-4c55-a083-7f02da22cc40',
      issueInstant: DateTime.utc(2026, 8, 15, 14, 0),
      issuer: 'CN=TEST PS,OU=TEST,O=TEST,C=FR',
      professionalId: '810000000000',
      billingIdentifier: '999999999',
      activitySector: 'SA07',
    );

    final xml = await service.buildSignedAssertion(
      data: data,
      x509Certificate: 'TEST_CERTIFICATE_BASE64',
    );

    final document = XmlDocument.parse(xml);
    final assertion = document.rootElement;

    XmlElement singleElement(String localName) {
      return document.descendants
          .whereType<XmlElement>()
          .singleWhere(
            (element) => element.name.local == localName,
      );
    }

    final childElements = assertion.childElements.toList();

    expect(
      assertion.name.local,
      'Assertion',
    );

    expect(
      assertion.getAttribute('Version'),
      '2.0',
    );

    expect(
      assertion.getAttribute('ID'),
      '_e451e702-85aa-4c55-a083-7f02da22cc40',
    );

    expect(
      assertion.getAttribute('IssueInstant'),
      isNotNull,
    );

    expect(
      childElements.length,
      4,
    );

    expect(childElements[0].name.local, 'Issuer');
    expect(childElements[1].name.local, 'Signature');
    expect(childElements[2].name.local, 'Subject');
    expect(childElements[3].name.local, 'AttributeStatement');

    expect(
      singleElement('Reference').getAttribute('URI'),
      '#_e451e702-85aa-4c55-a083-7f02da22cc40',
    );

    expect(
      singleElement('CanonicalizationMethod')
          .getAttribute('Algorithm'),
      'http://www.w3.org/2001/10/xml-exc-c14n#',
    );

    expect(
      singleElement('SignatureMethod')
          .getAttribute('Algorithm'),
      'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256',
    );

    expect(
      singleElement('DigestMethod')
          .getAttribute('Algorithm'),
      'http://www.w3.org/2001/04/xmlenc#sha256',
    );

    final transforms = document.descendants
        .whereType<XmlElement>()
        .where(
          (element) => element.name.local == 'Transform',
    )
        .toList();

    expect(
      transforms.length,
      2,
    );

    expect(
      transforms[0].getAttribute('Algorithm'),
      'http://www.w3.org/2000/09/xmldsig#enveloped-signature',
    );

    expect(
      transforms[1].getAttribute('Algorithm'),
      'http://www.w3.org/2001/10/xml-exc-c14n#',
    );

    expect(
      singleElement('DigestValue').innerText.trim(),
      isNotEmpty,
    );

    expect(
      singleElement('SignatureValue').innerText.trim(),
      'TEST_SIGNATURE_BASE64',
    );

    expect(
      singleElement('X509Certificate').innerText.trim(),
      'TEST_CERTIFICATE_BASE64',
    );

    expect(
      singleElement('SignatureValue').innerText.trim(),
      isNotEmpty,
    );

    expect(
      singleElement('X509Certificate').innerText.trim(),
      isNotEmpty,
    );

    expect(
      singleElement('NameID').innerText.trim(),
      '810000000000',
    );
  });
}