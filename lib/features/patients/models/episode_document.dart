class EpisodeDocument {
  final String documentId;
  final String caseId;
  final String title;
  final String filePath;
  final String? mimeType;
  final String? source;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const EpisodeDocument({
    required this.documentId,
    required this.caseId,
    required this.title,
    required this.filePath,
    this.mimeType,
    this.source,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory EpisodeDocument.fromMap(Map<String, dynamic> map) {
    return EpisodeDocument(
      documentId: map['document_id'] as String,
      caseId: map['case_id'] as String,
      title: map['title'] as String,
      filePath: map['file_path'] as String,
      mimeType: map['mime_type'] as String?,
      source: map['source'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'document_id': documentId,
      'case_id': caseId,
      'title': title,
      'file_path': filePath,
      'mime_type': mimeType,
      'source': source,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }
}