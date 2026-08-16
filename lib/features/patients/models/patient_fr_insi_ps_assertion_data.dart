class PatientFrInsiPsAssertionData {
  const PatientFrInsiPsAssertionData({
    required this.assertionId,
    required this.issueInstant,
    required this.issuer,
    required this.professionalId,
    required this.billingIdentifier,
    required this.activitySector,
  });

  /// Identifiant SAML de l'assertion.
  ///
  /// Format attendu :
  /// _ + UUID
  final String assertionId;

  /// Date et heure de création de l'assertion.
  ///
  /// Elle sera sérialisée en UTC lors de la construction XML.
  final DateTime issueInstant;

  /// Identité X.509 utilisée comme Issuer de l'assertion.
  ///
  /// Cette valeur proviendra du certificat CPS.
  final String issuer;

  /// Identifiant du professionnel porté par la CPS.
  ///
  /// Cette valeur alimentera Subject / NameID.
  final String professionalId;

  /// Identifiant de facturation du professionnel.
  ///
  /// Correspond à l'attribut INSi "identifiantFacturation".
  final String billingIdentifier;

  /// Secteur d'activité utilisé pour l'appel INSi.
  ///
  /// Correspond à l'attribut INSi "secteurActivite".
  final String activitySector;
}