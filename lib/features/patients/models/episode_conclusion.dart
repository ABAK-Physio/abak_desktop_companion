class EpisodeConclusion {
  final String conclusionId;
  final String caseId;
  final String content;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const EpisodeConclusion({
    required this.conclusionId,
    required this.caseId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory EpisodeConclusion.fromMap(Map<String, dynamic> map) {
    return EpisodeConclusion(
      conclusionId: map['conclusion_id'] as String,
      caseId: map['case_id'] as String,
      content: map['content'] as String,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conclusion_id': conclusionId,
      'case_id': caseId,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }
}
