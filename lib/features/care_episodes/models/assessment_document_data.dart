class AssessmentDocumentData {
  final String? establishmentName;

  final DateTime assessmentDate;
  final DateTime printedAt;

  final String? authorName;
  final String? recipientText;

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

  final String assessmentText;

  final List<AssessmentDocumentTest> tests;
  final List<AssessmentDocumentNote> notes;

  const AssessmentDocumentData({
    required this.establishmentName,
    required this.assessmentDate,
    required this.printedAt,
    required this.authorName,
    required this.recipientText,
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
    required this.assessmentText,
    required this.tests,
    required this.notes,
  });
}

class AssessmentDocumentTest {
  final String selectionKey;
  final String title;
  final DateTime? testDate;
  final String resultText;

  final int? declaredAgeYears;
  final String? pathologyLabel;
  final List<AssessmentDocumentChartSeries> chartSeries;

  const AssessmentDocumentTest({
    required this.selectionKey,
    required this.title,
    required this.testDate,
    required this.resultText,
    required this.declaredAgeYears,
    required this.pathologyLabel,
    required this.chartSeries,
  });
}

class AssessmentDocumentChartSeries {
  final String label;
  final String? unit;
  final List<AssessmentDocumentChartPoint> points;

  const AssessmentDocumentChartSeries({
    required this.label,
    required this.unit,
    required this.points,
  });
}

class AssessmentDocumentChartPoint {
  final DateTime date;
  final double value;

  const AssessmentDocumentChartPoint({
    required this.date,
    required this.value,
  });
}

class AssessmentDocumentNote {
  final DateTime? noteDate;
  final String title;
  final String content;

  const AssessmentDocumentNote({
    required this.noteDate,
    required this.title,
    required this.content,
  });
}