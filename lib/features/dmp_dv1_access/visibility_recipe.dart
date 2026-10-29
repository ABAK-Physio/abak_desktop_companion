import '../patients/services/dmp_chain/native/access_context.dart';
import '../patients/services/dmp_chain/native/td31a.dart';

/// CNDA developer workbook v.10 (2025-07-11), Referentiel Patients!A24:N24.
/// Recipe only: no patient record, INS qualification or emergency override.
class Dv1VisibilityRecipe {
  // DOCUMENTS!G6:I6, G11:I11, G15:I15, G21:I21 in the same workbook.
  static const searchTypes = {
    '46241-6': 'CR d’admission — document 05 du jeu d’essai',
    '27899-4': 'CR d’acte diagnostique — document 10 du jeu d’essai',
    '47420-5': 'CR de bilan fonctionnel — document 14 du jeu d’essai',
    '11505-5': 'CR d’acte thérapeutique — document 20 du jeu d’essai',
    '': 'Tous les types de documents',
  };
  static Dv1DocumentCriteria criteria(String code) {
    if (!searchTypes.containsKey(code)) {
      throw StateError('Type de recherche PRE_CONS_INV inconnu.');
    }
    return Dv1DocumentCriteria(typeCode: code);
  }

  static const expectedIds = [
    '1.999888777.1.5',
    '1.999888777.1.10',
    '1.999888777.1.14',
    '1.999888777.1.20',
  ];
  static const identifierCriteria = Dv1DocumentCriteria(
    uniqueIds: expectedIds,
    archived: true,
    deprecated: true,
  );
  static const patient = 'SOPHIE PATB-TROIS';
  static const ins = '211066322074514';
  static const birth = '2011-06-07';
  static const sex = 'F';
  static const source =
      'DMP1_LPS_JE_DEV_editeur_20250711_v.10.xlsx — Referentiel Patients, ligne 24, cas 23 Sophie PATB-TROIS — PRE_CONS_INV';
  static const note =
      'Le commentaire CNDA sur les documents masqués en urgence concerne les LPS de régulation médicale. Ce parcours utilise les droits ordinaires de consultation. Les documents 05, 10, 14 et 20 sont indiqués invisibles au patient dans le jeu d’essai ; leur état actuel doit être vérifié sur DV1.';
  static void check(Dv1AccessContext context) {
    final name = context.patientLabel.toUpperCase().replaceAll(
      RegExp(r'[^A-Z]'),
      '',
    );
    if (!['SOPHIEPATBTROIS', 'PATBTROISSOPHIE'].contains(name) ||
        context.ins != ins ||
        context.birthDate != birth) {
      throw StateError(
        'PRE_CONS_INV attend le cas 23 — Sophie PATB-TROIS, née le 07/06/2011, INS 211066322074514. Utilisez le bouton de préparation du cas puis vérifiez les informations.',
      );
    }
  }
}
