import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_signature_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_signed_info_builder.dart';

void main() {
  const signedInfoBuilder = PatientFrInsiPsSignedInfoBuilder();
  const signatureBuilder = PatientFrInsiPsSignatureBuilder();

  test('build creates XMLDsig Signature structure', () {
    final signedInfoXml = signedInfoBuilder.build(
      assertionId: '_e451e702-85aa-4c55-a083-7f02da22cc40',
      digestValue: 'TEST_DIGEST_BASE64',
    );

    final xml = signatureBuilder.build(
      signedInfoXml: signedInfoXml,
      signatureValue: 'TEST_SIGNATURE_BASE64',
      x509Certificate: 'TEST_CERTIFICATE_BASE64',
    );

    final document = XmlDocument.parse(xml);
    final root = document.rootElement;

    XmlElement singleElement(String localName) {
      return document.descendants
          .whereType<XmlElement>()
          .singleWhere(
            (element) => element.name.local == localName,
      );
    }

    expect(root.name.local, 'Signature');
    expect(
      root.name.namespaceUri,
      PatientFrInsiPsSignatureBuilder.xmlDsigNamespace,
    );

    final signedInfo = singleElement('SignedInfo');

    expect(
      signedInfo.name.namespaceUri,
      PatientFrInsiPsSignatureBuilder.xmlDsigNamespace,
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
      singleElement('Reference').getAttribute('URI'),
      '#_e451e702-85aa-4c55-a083-7f02da22cc40',
    );

    expect(
      singleElement('DigestValue').innerText.trim(),
      'TEST_DIGEST_BASE64',
    );
  });
}