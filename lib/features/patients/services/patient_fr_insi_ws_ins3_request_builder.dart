import 'package:xml/xml.dart';

/// WS_INS3 body only: no CPS access, network call or patient update.
/// Contract: DESIR_IDIR_EXP_1.0.1, INSi package 05.00.00.
class PatientFrInsiWsIns3RequestBuilder {
  const PatientFrInsiWsIns3RequestBuilder();

  static const action =
      'urn:ServiceVerificationIdentiteCertifiee:1.0.0:verifierInsAvecTraitsIdentite';
  static const requestNamespace =
      'http://www.cnamts.fr/INSiLot2/REQueteUnitaire';
  static const identityNamespace = 'http://www.cnamts.fr/MRA/INSSansDates';

  String buildBody({
    required String insNumber,
    required String insKey,
    required String insOid,
    required String birthLastName,
    required String givenNames,
    required String sexCode,
    required String birthDate,
    String? birthPlaceCode,
  }) {
    final number = insNumber.trim();
    final key = insKey.trim();
    final oid = insOid.trim();
    final name = birthLastName.trim();
    final names = givenNames.trim();
    final sex = sexCode.trim();
    final date = birthDate.trim();
    final place = birthPlaceCode?.trim() ?? '';

    if (!RegExp(r'^(?:[0-9]{13}|[0-9]{5}2[AB][0-9]{6})$')
        .hasMatch(number)) {
      throw ArgumentError('Le matricule INS sans clé doit comporter 13 caractères.');
    }
    // The server checks the INS/traits match, including a deliberately wrong
    // two-digit key in a negative CNDA scenario. Do not repair or recompute it.
    if (!RegExp(r'^[0-9]{2}$').hasMatch(key)) {
      throw ArgumentError('La clé INS doit comporter deux chiffres.');
    }
    if (oid != '1.2.250.1.213.1.4.8' && oid != '1.2.250.1.213.1.4.9') {
      throw ArgumentError('Un OID INS NIR ou NIA est requis.');
    }
    if (name.isEmpty || names.isEmpty) {
      throw ArgumentError('Le nom de naissance et la liste des prénoms sont requis.');
    }
    if (!_validName(name, givenNames: false)) {
      throw ArgumentError('Nom de naissance incompatible avec le format INSi : '
          'majuscules A à Z, espaces, apostrophes droites et tirets uniquement.');
    }
    if (!_validName(names, givenNames: true)) {
      throw ArgumentError('Liste des prénoms incompatible avec le format INSi : '
          'majuscules A à Z, espaces simples, apostrophes droites et tirets simples uniquement.');
    }
    if (sex != 'M' && sex != 'F') {
      throw ArgumentError('Le sexe doit être M ou F.');
    }
    // Verification reuses reference traits. Preserve dates represented by the
    // contract's DateLunaire string type rather than normalizing with DateTime.
    if (!RegExp(r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$').hasMatch(date)) {
      throw ArgumentError('La date de naissance doit être au format AAAA-MM-JJ.');
    }
    if (place.isNotEmpty &&
        !RegExp(r'^(?:[0-9]{5}|2[AB][0-9]{3})$').hasMatch(place)) {
      throw ArgumentError('Le code INSEE doit comporter cinq caractères.');
    }

    final builder = XmlBuilder();
    builder.element('req:RequeteUnitaire', attributes: {
      'xmlns:req': requestNamespace,
      'xmlns:ins': identityNamespace,
    }, nest: () {
      builder.element('req:IndividuVerifie', nest: () {
        builder.element('req:INSFourni', nest: () {
          builder.element('ins:IdIndividu', nest: () {
            builder.element('ins:NumIdentifiant', nest: number);
            builder.element('ins:Cle', nest: key);
          });
          builder.element('ins:OID', nest: oid);
        });
        builder.element('req:TraitsIdentiteIndividu', nest: () {
          builder.element('ins:NomNaissance', nest: name);
          // WS_INS3 sends the whole list, unlike WS_INS2's single Prenom.
          // Prenom and TypeMatricule are unused in the integration guide.
          builder.element('ins:ListePrenom', nest: names);
          builder.element('ins:Sexe', nest: sex);
          builder.element('ins:DateNaissance', nest: date);
          if (place.isNotEmpty) {
            builder.element('ins:LieuNaissance', nest: place);
          }
        });
      });
    });
    return builder.buildDocument().rootElement.toXmlString();
  }

  // CNDA 3.03 / guide SEL-GCONFORM-INSi 1.14, page 32.
  // Validate reference values without silently replacing accents or punctuation.
  static bool _validName(String value, {required bool givenNames}) {
    if (!RegExp(r"^[A-Z'][A-Z' -]*$").hasMatch(value) ||
        value.contains('  ') || value.contains("''") ||
        value.contains(" '") || value.contains("' ") || value.contains('---')) {
      return false;
    }
    if (givenNames) {
      return !value.contains('--') && !value.contains('- ') &&
          !value.contains(' -') && !value.endsWith('-') && !value.endsWith("'");
    }
    return true;
  }
}
