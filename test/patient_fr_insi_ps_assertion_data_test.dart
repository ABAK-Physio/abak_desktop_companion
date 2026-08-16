import 'package:flutter_test/flutter_test.dart';

import 'package:abak_desktop_companion/features/patients/models/patient_fr_insi_ps_assertion_data.dart';

void main() {
  test('stores PS assertion data', () {
    final issueInstant = DateTime.utc(2026, 8, 15, 14, 0);

    final data = PatientFrInsiPsAssertionData(
      assertionId: '_e451e702-85aa-4c55-a083-7f02da22cc40',
      issueInstant: issueInstant,
      issuer: 'CN=TEST PS,OU=TEST,O=TEST,C=FR',
      professionalId: '810000000000',
      billingIdentifier: '999999999',
      activitySector: 'SA07',
    );

    expect(
      data.assertionId,
      '_e451e702-85aa-4c55-a083-7f02da22cc40',
    );
    expect(data.issueInstant, issueInstant);
    expect(
      data.issuer,
      'CN=TEST PS,OU=TEST,O=TEST,C=FR',
    );
    expect(data.professionalId, '810000000000');
    expect(data.billingIdentifier, '999999999');
    expect(data.activitySector, 'SA07');
  });
}