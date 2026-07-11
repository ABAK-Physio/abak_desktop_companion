class EpisodeForm {
  final String formId;
  final String caseId;
  final String templateId;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const EpisodeForm({
    required this.formId,
    required this.caseId,
    required this.templateId,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory EpisodeForm.fromMap(Map<String, dynamic> map) {
    return EpisodeForm(
      formId: map['form_id'] as String,
      caseId: map['case_id'] as String,
      templateId: map['template_id'] as String,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'form_id': formId,
      'case_id': caseId,
      'template_id': templateId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }
}
