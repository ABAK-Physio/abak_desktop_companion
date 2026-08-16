import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/models/patient_fr_insi_fault.dart';

void main() {
  group('patientFrInsiFaultSeverityFromValue', () {
    test('erreur maps to error', () {
      expect(
        patientFrInsiFaultSeverityFromValue('erreur'),
        PatientFrInsiFaultSeverity.error,
      );
    });

    test('fatale maps to fatal', () {
      expect(
        patientFrInsiFaultSeverityFromValue('fatale'),
        PatientFrInsiFaultSeverity.fatal,
      );
    });

    test('unknown severity throws ArgumentError', () {
      expect(
            () => patientFrInsiFaultSeverityFromValue('inconnue'),
        throwsArgumentError,
      );
    });
  });
}