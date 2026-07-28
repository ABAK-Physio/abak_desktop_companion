enum ClinicalDocumentType {
  assessment,
  report,
}

extension ClinicalDocumentTypeExtension on ClinicalDocumentType {
  String get editorTitle {
    switch (this) {
      case ClinicalDocumentType.assessment:
        return 'Modification du bilan';
      case ClinicalDocumentType.report:
        return 'Modification du rapport';
    }
  }

  String get templateLabel {
    switch (this) {
      case ClinicalDocumentType.assessment:
        return 'Modèle de bilan';
      case ClinicalDocumentType.report:
        return 'Modèle de rapport';
    }
  }
}
