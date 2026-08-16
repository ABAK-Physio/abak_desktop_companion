import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/models/patient_fr_insi_result.dart';

void main() {
  group('patientFrInsiStatusFromCodeCr', () {
    test('00 maps to success', () {
      expect(
        patientFrInsiStatusFromCodeCr('00'),
        PatientFrInsiResultStatus.success,
      );
    });

    test('01 maps to notFound', () {
      expect(
        patientFrInsiStatusFromCodeCr('01'),
        PatientFrInsiResultStatus.notFound,
      );
    });

    test('02 maps to ambiguous', () {
      expect(
        patientFrInsiStatusFromCodeCr('02'),
        PatientFrInsiResultStatus.ambiguous,
      );
    });

    test('unknown code throws ArgumentError', () {
      expect(
            () => patientFrInsiStatusFromCodeCr('99'),
        throwsArgumentError,
      );
    });
  });
}