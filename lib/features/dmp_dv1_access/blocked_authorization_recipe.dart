import '../dmp_td02/td02_result.dart';

/// Test fixture from the personalized PDT, Phase 2 row 31, patient row 26.
/// The PDT requests a blocked authorization for the professional used in 0.2-060.
/// This only prepares a test context, never a patient record or an authorization.
class Dv1BlockedAuthorizationRecipe {
  static const scenario = '0.2-070';
  static const patient = 'HUIT HENRI';
  static const ins = '189018157057689';
  static const birth = '1989-01-01';
  static const professional = '899700870597';
  static const source =
      'PDT_DMP_ABAK DESKTOP COMPANION_20251127_2.10g.xlsx — '
      'Phase 2 Tests, ligne 31, 0.2-070 ; Référentiel Patients, ligne 26, Cas6 — '
      'Henri HUIT ; autorisation bloquée attendue pour le professionnel du test 0.2-060.';

  static void checkInputs({
    required String scenario,
    required String patient,
    required String ins,
    required String birth,
    required String professional,
  }) {
    final name = patient.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    if (scenario != Dv1BlockedAuthorizationRecipe.scenario ||
        ![Dv1BlockedAuthorizationRecipe.patient, 'HENRI HUIT'].contains(name) ||
        ins != Dv1BlockedAuthorizationRecipe.ins ||
        birth != Dv1BlockedAuthorizationRecipe.birth ||
        professional != Dv1BlockedAuthorizationRecipe.professional) {
      throw StateError(
        '0.2-070 attend le cas 6 — Henri HUIT, né le 01/01/1989, '
        'INS 189018157057689, avec la CPS 899700870597. '
        'Préparez ce cas avant la vérification.',
      );
    }
  }

  static bool matches(Td02Result result) =>
      result.state == DmpState.active &&
      result.right == ConsultationRight.blocked;
}
