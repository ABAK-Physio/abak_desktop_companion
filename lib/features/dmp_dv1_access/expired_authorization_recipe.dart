import '../dmp_td02/td02_result.dart';

/// Test fixture from the personalized PDT, Phase 2 row 30, patient row 27.
/// The CNDA confirmed the expired authorization for this exact professional.
/// This only prepares a test context, never a patient record or an authorization.
class Dv1ExpiredAuthorizationRecipe {
  static const scenario = '0.2-060';
  static const patient = 'SARTRE SIMONE';
  static const ins = '295010948305468';
  static const birth = '1995-01-01';
  static const professional = '899700870597';
  static const source =
      'PDT_DMP_ABAK DESKTOP COMPANION_20251127_2.10g.xlsx — '
      'Phase 2 Tests, ligne 30, 0.2-060 ; Référentiel Patients, ligne 27, Cas7 — '
      'Simone SARTRE ; autorisation expirée positionnée par le CNDA pour 899700870597.';

  static void checkInputs({
    required String scenario,
    required String patient,
    required String ins,
    required String birth,
    required String professional,
  }) {
    final name = patient.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    if (scenario != Dv1ExpiredAuthorizationRecipe.scenario ||
        ![
          Dv1ExpiredAuthorizationRecipe.patient,
          'SIMONE SARTRE',
        ].contains(name) ||
        ins != Dv1ExpiredAuthorizationRecipe.ins ||
        birth != Dv1ExpiredAuthorizationRecipe.birth ||
        professional != Dv1ExpiredAuthorizationRecipe.professional) {
      throw StateError(
        '0.2-060 attend le cas 7 — Simone SARTRE, née le 01/01/1995, '
        'INS 295010948305468, avec la CPS 899700870597. '
        'Préparez ce cas avant la vérification.',
      );
    }
  }

  static bool matches(Td02Result result) =>
      result.state == DmpState.active &&
      result.right == ConsultationRight.expired;
}
