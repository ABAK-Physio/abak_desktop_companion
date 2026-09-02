import 'assessment_document_data.dart';

class ReportDocumentData {
  final String? establishmentName;
  final String? establishmentAddressLine1;
  final String? establishmentAddressLine2;
  final String? establishmentPostalCode;
  final String? establishmentCity;
  final String? establishmentPhone;
  final String? establishmentEmail;
  final String? establishmentLogoPath;

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

  final String? dominantSide;
  final String? profession;
  final String? sport;
  final String? heightCm;
  final String? weightKg;

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

  final List<AssessmentDocumentTest> tests;
  final List<AssessmentDocumentNote> notes;

  const ReportDocumentData({
    required this.establishmentName,
    required this.establishmentAddressLine1,
    required this.establishmentAddressLine2,
    required this.establishmentPostalCode,
    required this.establishmentCity,
    required this.establishmentPhone,
    required this.establishmentEmail,
    required this.establishmentLogoPath,
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
    required this.dominantSide,
    required this.profession,
    required this.sport,
    required this.heightCm,
    required this.weightKg,
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
    required this.tests,
    required this.notes,
  });
}