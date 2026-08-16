import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/models/patient_fr_health_identity.dart';

void main() {
  group('resolvePatientFrHealthIdentityStatus', () {
    test('provisional when identity is not validated and INS is not retrieved', () {
      final status = resolvePatientFrHealthIdentityStatus(
        identityValidated: false,
        insRetrieved: false,
      );

      expect(status, PatientFrHealthIdentityStatus.provisional);
    });

    test('retrieved when INS is retrieved but identity is not validated', () {
      final status = resolvePatientFrHealthIdentityStatus(
        identityValidated: false,
        insRetrieved: true,
      );

      expect(status, PatientFrHealthIdentityStatus.retrieved);
    });

    test('validated when identity is validated but INS is not retrieved', () {
      final status = resolvePatientFrHealthIdentityStatus(
        identityValidated: true,
        insRetrieved: false,
      );

      expect(status, PatientFrHealthIdentityStatus.validated);
    });

    test('qualified when identity is validated and INS is retrieved', () {
      final status = resolvePatientFrHealthIdentityStatus(
        identityValidated: true,
        insRetrieved: true,
      );

      expect(status, PatientFrHealthIdentityStatus.qualified);
    });
  });
}