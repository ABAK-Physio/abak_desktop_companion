import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_signed_info_builder.dart';

void main() {
  const builder = PatientFrInsiPsSignedInfoBuilder();

  test('build creates XMLDsig SignedInfo for PS assertion', () {
    final xml = builder.build(
      assertionId: '_e451e702-85aa-4c55-a083-7f02da22cc40',
      digestValue: 'TEST_DIGEST_BASE64',
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

    expect(root.name.local, 'SignedInfo');
    expect(
      root.name.namespaceUri,
      PatientFrInsiPsSignedInfoBuilder.xmlDsigNamespace,
    );

    final canonicalizationMethod =
    singleElement('CanonicalizationMethod');

    expect(
      canonicalizationMethod.getAttribute('Algorithm'),
      PatientFrInsiPsSignedInfoBuilder
          .exclusiveCanonicalizationAlgorithm,
    );

    final signatureMethod = singleElement('SignatureMethod');

    expect(
      signatureMethod.getAttribute('Algorithm'),
      PatientFrInsiPsSignedInfoBuilder.rsaSha256Algorithm,
    );

    final reference = singleElement('Reference');

    expect(
      reference.getAttribute('URI'),
      '#_e451e702-85aa-4c55-a083-7f02da22cc40',
    );

    final transforms = document.descendants
        .whereType<XmlElement>()
        .where(
          (element) => element.name.local == 'Transform',
    )
        .toList();

    expect(transforms, hasLength(2));

    expect(
      transforms[0].getAttribute('Algorithm'),
      PatientFrInsiPsSignedInfoBuilder
          .envelopedSignatureAlgorithm,
    );

    expect(
      transforms[1].getAttribute('Algorithm'),
      PatientFrInsiPsSignedInfoBuilder
          .exclusiveCanonicalizationAlgorithm,
    );

    final digestMethod = singleElement('DigestMethod');

    expect(
      digestMethod.getAttribute('Algorithm'),
      PatientFrInsiPsSignedInfoBuilder.sha256DigestAlgorithm,
    );

    final digestValue = singleElement('DigestValue');

    expect(
      digestValue.innerText.trim(),
      'TEST_DIGEST_BASE64',
    );
  });
}
