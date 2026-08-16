import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/models/patient_fr_insi_ps_assertion_data.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_assertion_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_signature_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_signature_inserter.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_signed_info_builder.dart';

void main() {
  const assertionBuilder = PatientFrInsiPsAssertionBuilder();
  const signedInfoBuilder = PatientFrInsiPsSignedInfoBuilder();
  const signatureBuilder = PatientFrInsiPsSignatureBuilder();
  const inserter = PatientFrInsiPsSignatureInserter();

  test('insert places Signature after Issuer', () {
    final assertionXml = assertionBuilder.buildUnsigned(
      PatientFrInsiPsAssertionData(
        assertionId: '_e451e702-85aa-4c55-a083-7f02da22cc40',
        issueInstant: DateTime.utc(2026, 8, 15, 14, 0),
        issuer: 'CN=TEST PS,OU=TEST,O=TEST,C=FR',
        professionalId: '810000000000',
        billingIdentifier: '999999999',
        activitySector: 'SA07',
      ),
    );

    final signedInfoXml = signedInfoBuilder.build(
      assertionId: '_e451e702-85aa-4c55-a083-7f02da22cc40',
      digestValue: 'TEST_DIGEST_BASE64',
    );

    final signatureXml = signatureBuilder.build(
      signedInfoXml: signedInfoXml,
      signatureValue: 'TEST_SIGNATURE_BASE64',
      x509Certificate: 'TEST_CERTIFICATE_BASE64',
    );

    final xml = inserter.insert(
      assertionXml: assertionXml,
      signatureXml: signatureXml,
    );

    final document = XmlDocument.parse(xml);
    final assertion = document.rootElement;

    final childElements = assertion.childElements.toList();

    expect(childElements[0].name.local, 'Issuer');
    expect(childElements[1].name.local, 'Signature');
    expect(childElements[2].name.local, 'Subject');
    expect(childElements[3].name.local, 'AttributeStatement');

    expect(
      childElements[1].descendants
          .whereType<XmlElement>()
          .singleWhere(
            (element) => element.name.local == 'SignatureValue',
      )
          .innerText
          .trim(),
      'TEST_SIGNATURE_BASE64',
    );

    expect(
      childElements[2].descendants
          .whereType<XmlElement>()
          .singleWhere(
            (element) => element.name.local == 'NameID',
      )
          .innerText
          .trim(),
      '810000000000',
    );
  });
}