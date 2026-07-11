class CareEpisode {
  final String careEpisodeId;
  final String patientId;

  final String title;
  final String pathologyLabel;
  final String? initialReport;
  final String? initialReportDocxPath;
  final String? objectiveData;
  final String? assessmentData;
  final String? treatmentPlan;
  final String? finalConclusion;

  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const CareEpisode({
    required this.careEpisodeId,
    required this.patientId,
    required this.title,
    required this.pathologyLabel,
    this.initialReport,
    this.initialReportDocxPath,
    this.objectiveData,
    this.assessmentData,
    this.treatmentPlan,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
    this.finalConclusion,
  });

  factory CareEpisode.fromMap(Map<String, dynamic> map) {
    return CareEpisode(
      careEpisodeId: map['care_episode_id']?.toString() ?? '',
      patientId: map['patient_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      pathologyLabel: map['pathology_label']?.toString() ?? '',
      initialReport: map['initial_report']?.toString(),
      initialReportDocxPath: map['initial_report_docx_path']?.toString(),
      objectiveData: map['objective_data']?.toString(),
      assessmentData: map['assessment_data']?.toString(),
      treatmentPlan: map['treatment_plan']?.toString(),
      createdAt: (map['created_at'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt(),
      archivedAt: (map['archived_at'] as num?)?.toInt(),
      finalConclusion: map['final_conclusion']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'care_episode_id': careEpisodeId,
      'patient_id': patientId,
      'title': title,
      'pathology_label': pathologyLabel,
      'initial_report': initialReport,
      'initial_report_docx_path': initialReportDocxPath,
      'objective_data': objectiveData,
      'assessment_data': assessmentData,
      'treatment_plan': treatmentPlan,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
      'final_conclusion': finalConclusion,
    };
  }

  bool get isArchived => archivedAt != null;

  String get displayTitle {
    final cleanedTitle = title.trim();
    if (cleanedTitle.isNotEmpty) {
      return cleanedTitle;
    }

    final cleanedPathology = pathologyLabel.trim();
    if (cleanedPathology.isNotEmpty) {
      return cleanedPathology;
    }

    return 'Prise en charge';
  }

  String get displayInitialReport {
    final cleaned = initialReport?.trim();
    if (cleaned == null || cleaned.isEmpty) {
      return 'Aucun compte rendu initial.';
    }

    return cleaned;
  }

  String get displayObjectiveData {
    final cleaned = objectiveData?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return 'Aucune évaluation clinique.';
    }

    return cleaned;
  }

  String get displayAssessmentData {
    final cleaned = assessmentData?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return 'Aucune analyse clinique.';
    }

    return cleaned;
  }

  String get displayTreatmentPlan {
    final cleaned = treatmentPlan?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return 'Aucun plan de traitement.';
    }

    return cleaned;
  }
}
