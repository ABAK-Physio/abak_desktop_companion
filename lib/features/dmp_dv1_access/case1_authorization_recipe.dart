import '../dmp_td02/td02_result.dart';

/// Personalized PDT 2.10g: phase 2 row 33; patient Cas1 row 19.
/// A successful initial TD0.2 check is not itself a successful TD0.3 test.
class Dv1Case1AuthorizationRecipe {
  static const scenario = '0.3-010';
  static const patient = 'GIRODET DE ROUSSY-COEUR ANNE-LOUIS';
  static const ins = '287019143596041';
  static const birth = '1987-01-01';
  static const professional = '899700870597';
  static const source =
      'PDT_DMP_ABAK DESKTOP COMPANION_20251127_2.10g.xlsx — '
      'Phase 2 Tests, ligne 33, 0.3-010 ; Référentiel Patients, ligne 19, Cas1 — '
      'ANNE-LOUIS GIRODET DE ROUSSY-COEUR.';
  static void checkInputs({
    required String scenario,
    required String patient,
    required String ins,
    required String birth,
    required String professional,
  }) {
    final name = patient.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    if (scenario != Dv1Case1AuthorizationRecipe.scenario ||
        ![
          Dv1Case1AuthorizationRecipe.patient,
          'ANNE-LOUIS GIRODET DE ROUSSY-COEUR',
        ].contains(name) ||
        ins != Dv1Case1AuthorizationRecipe.ins ||
        birth != Dv1Case1AuthorizationRecipe.birth ||
        professional != Dv1Case1AuthorizationRecipe.professional) {
      throw StateError(
        '0.3-010 attend le Cas1 — ANNE-LOUIS GIRODET DE ROUSSY-COEUR, '
        'née le 01/01/1987, INS 287019143596041, avec la CPS 899700870597.',
      );
    }
  }

  static bool initialReady(Td02Result result) =>
      result.state == DmpState.active &&
      result.right == ConsultationRight.absent;

  /// A preparatory withdrawal is never an attempted CNDA addition test.
  static void checkOperation({
    required String scenario,
    String? authorizationIntent,
    bool preparatoryWithdrawal = false,
    bool otherOperation = false,
  }) {
    if (preparatoryWithdrawal &&
        scenario != Dv1Case1AuthorizationRecipe.scenario) {
      throw StateError(
        'Le retrait préparatoire est réservé au Cas1 de 0.3-010.',
      );
    }
    if (scenario != Dv1Case1AuthorizationRecipe.scenario) return;
    if (otherOperation ||
        (preparatoryWithdrawal
            ? authorizationIntent != 'withdraw'
            : authorizationIntent != null &&
                  authorizationIntent != 'consult')) {
      throw StateError(
        'Action Cas1 incompatible : contrôle TD0.2, ajout explicite ou retrait préparatoire confirmé uniquement.',
      );
    }
  }

  static bool withdrawalReady(Td02Result result) =>
      result.state == DmpState.active &&
      result.right == ConsultationRight.valid;

  static void requireWithdrawalInitial(Td02Result result) {
    if (!withdrawalReady(result)) {
      throw StateError(
        'Retrait préparatoire non envoyé : un DMP actif avec une autorisation VALIDE est requis. ${result.message}',
      );
    }
  }

  static bool withdrawalCompleted(
    Td02Result initial,
    String td03Status,
    Td02Result after,
  ) => withdrawalReady(initial) && td03Status == 'DMPOk' && initialReady(after);
  static void requireInitial(Td02Result result) {
    if (!initialReady(result)) {
      throw StateError(
        '0.3-010 requiert un DMP actif sans autorisation préalable (NON_EXISTE). '
        '${result.message} Aucun ajout ni retrait effectué.',
      );
    }
  }

  static bool completed(
    Td02Result initial,
    String td03Status,
    Td02Result after,
  ) =>
      initialReady(initial) &&
      td03Status == 'DMPOk' &&
      after.state == DmpState.active &&
      after.right == ConsultationRight.valid;
}
