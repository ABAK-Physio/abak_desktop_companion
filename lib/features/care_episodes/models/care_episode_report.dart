class CareEpisodeReport {
  final String reportId;
  final String careEpisodeId;
  final String? sourceAssessmentId;

  final String title;
  final String contentJson;
  final String status;

  final int reportDate;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const CareEpisodeReport({
    required this.reportId,
    required this.careEpisodeId,
    required this.sourceAssessmentId,
    required this.title,
    required this.contentJson,
    required this.status,
    required this.reportDate,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory CareEpisodeReport.fromMap(Map<String, dynamic> map) {
    return CareEpisodeReport(
      reportId: map['report_id']?.toString() ?? '',
      careEpisodeId: map['care_episode_id']?.toString() ?? '',
      sourceAssessmentId: map['source_assessment_id']?.toString(),
      title: map['title']?.toString() ?? '',
      contentJson: map['content_json']?.toString() ?? '',
      status: map['status']?.toString() ?? 'draft',
      reportDate: (map['report_date'] as num?)?.toInt() ?? 0,
      createdAt: (map['created_at'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt(),
      archivedAt: (map['archived_at'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'report_id': reportId,
      'care_episode_id': careEpisodeId,
      'source_assessment_id': sourceAssessmentId,
      'title': title,
      'content_json': contentJson,
      'status': status,
      'report_date': reportDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }

  bool get isDraft => status == 'draft';

  bool get isSaved => status == 'saved';

  bool get isArchived => archivedAt != null;
}
