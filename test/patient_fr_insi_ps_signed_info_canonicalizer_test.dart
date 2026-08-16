import 'package:flutter_test/flutter_test.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_signed_info_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_signed_info_canonicalizer.dart';

void main() {
  const signedInfoBuilder = PatientFrInsiPsSignedInfoBuilder();
  const canonicalizer = PatientFrInsiPsSignedInfoCanonicalizer();

  test('canonicalize produces deterministic SignedInfo', () {
    final signedInfoXml = signedInfoBuilder.build(
      assertionId: '_e451e702-85aa-4c55-a083-7f02da22cc40',
      digestValue: 'TEST_DIGEST_BASE64',
    );

    final first = canonicalizer.canonicalize(
      signedInfoXml,
    );

    final second = canonicalizer.canonicalize(
      signedInfoXml,
    );

    expect(first, isNotEmpty);
    expect(second, first);

    expect(
      first,
      contains('<ds:SignedInfo'),
    );

    expect(
      first,
      contains(
        'Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"',
      ),
    );

    expect(
      first,
      contains(
        'Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"',
      ),
    );

    expect(
      first,
      contains('TEST_DIGEST_BASE64'),
    );
  });
}