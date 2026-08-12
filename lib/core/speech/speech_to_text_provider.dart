abstract class SpeechToTextProvider {
  /// Identifiant technique stable du fournisseur.
  String get id;

  /// Nom affichable du fournisseur.
  String get displayName;

  /// Indique si le traitement est entièrement local.
  bool get isLocal;

  /// Indique si une connexion Internet est nécessaire.
  bool get requiresInternet;

  /// Indique si le fournisseur est actuellement disponible.
  Future<bool> isAvailable();

  /// Transcrit un fichier audio existant.
  ///
  /// Le fournisseur ne devient pas propriétaire du fichier.
  /// ABAK Companion reste responsable de sa suppression.
  Future<String> transcribeFile(String audioFilePath);
}