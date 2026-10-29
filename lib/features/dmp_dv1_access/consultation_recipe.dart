import '../patients/services/dmp_chain/native/access_context.dart';

/// CNDA case named by CDT; identity supplied explicitly by the editor 2026-10-29.
/// Recipe-only constants: never written to a real patient record or qualified INS.
class Dv1ConsultationRecipe {
  static const patient = 'DUPRE CORINNE';
  static const ins = '148115530271002';
  static const birth = '1948-11-09';
  static const sex = 'F';
  static const source =
      'CDT DMP 2.10e — PRE_CONS_RECH — cas 75 Corinne DUPRE ; INS, naissance et sexe fournis par l’éditeur le 29/10/2026';
  static void check(Dv1AccessContext context) {
    final name = context.patientLabel.trim().toUpperCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    if (!['CORINNE DUPRE', patient].contains(name) ||
        context.ins != ins ||
        context.birthDate != birth) {
      throw StateError(
        'PRE_CONS_RECH attend le cas 75 — Corinne DUPRE, née le 09/11/1948, INS 148115530271002. Préparez ce cas avant la recherche.',
      );
    }
  }
}
