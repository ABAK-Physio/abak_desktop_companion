class ReportDocumentData {
  final String? establishmentName;

  final DateTime reportDate;
  final DateTime printedAt;

  final String? authorName;

  final String patientLastName;
  final String patientFirstName;
  final String? patientSex;
  final int? patientAgeYears;

  final String? pathologyLabel;
  final DateTime? careEpisodeOpenedAt;

  final String? referringPractitionerName;

  final String? prescribingCorrespondentName;
  final String? prescribingCorrespondentProfession;
  final String? prescribingCorrespondentSpecialty;
  final String? prescribingCorrespondentAddressLine1;
  final String? prescribingCorrespondentAddressLine2;
  final String? prescribingCorrespondentPostalCode;
  final String? prescribingCorrespondentCity;
  final String? prescribingCorrespondentEmail;
  final String? prescribingCorrespondentPhone;

  final String reportTitle;
  final String reportText;

  const ReportDocumentData({
    required this.establishmentName,
    required this.reportDate,
    required this.printedAt,
    required this.authorName,
    required this.patientLastName,
    required this.patientFirstName,
    required this.patientSex,
    required this.patientAgeYears,
    required this.pathologyLabel,
    required this.careEpisodeOpenedAt,
    required this.referringPractitionerName,
    required this.prescribingCorrespondentName,
    required this.prescribingCorrespondentProfession,
    required this.prescribingCorrespondentSpecialty,
    required this.prescribingCorrespondentAddressLine1,
    required this.prescribingCorrespondentAddressLine2,
    required this.prescribingCorrespondentPostalCode,
    required this.prescribingCorrespondentCity,
    required this.prescribingCorrespondentEmail,
    required this.prescribingCorrespondentPhone,
    required this.reportTitle,
    required this.reportText,
  });
}