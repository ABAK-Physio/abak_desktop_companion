class CareEpisodeAssessment {
  final String assessmentId;
  final String careEpisodeId;

  final String title;
  final String contentJson;
  final String status;

  final String? authorPractitionerId;
  final String? recipientText;
  final String? docxFileName;

  final int assessmentDate;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const CareEpisodeAssessment({
    required this.assessmentId,
    required this.careEpisodeId,
    required this.title,
    required this.contentJson,
    required this.status,
    this.authorPractitionerId,
    this.recipientText,
    this.docxFileName,
    required this.assessmentDate,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory CareEpisodeAssessment.fromMap(Map<String, dynamic> map) {
    return CareEpisodeAssessment(
      assessmentId: map['assessment_id']?.toString() ?? '',
      careEpisodeId: map['care_episode_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      contentJson: map['content_json']?.toString() ?? '',
      status: map['status']?.toString() ?? 'draft',
      authorPractitionerId: map['author_practitioner_id']?.toString(),
      recipientText: map['recipient_text']?.toString(),
      docxFileName: map['docx_file_name']?.toString(),
      assessmentDate: (map['assessment_date'] as num?)?.toInt() ?? 0,
      createdAt: (map['created_at'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt(),
      archivedAt: (map['archived_at'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assessment_id': assessmentId,
      'care_episode_id': careEpisodeId,
      'title': title,
      'content_json': contentJson,
      'status': status,
      'author_practitioner_id': authorPractitionerId,
      'recipient_text': recipientText,
      'docx_file_name': docxFileName,
      'assessment_date': assessmentDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }

  bool get isDraft => status == 'draft';

  bool get isSaved => status == 'saved';

  bool get isArchived => archivedAt != null;
}
