class EpisodeNote {
  final String noteId;
  final String caseId;
  final String title;
  final String content;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const EpisodeNote({
    required this.noteId,
    required this.caseId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory EpisodeNote.fromMap(Map<String, dynamic> map) {
    return EpisodeNote(
      noteId: map['note_id'] as String,
      caseId: map['case_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'note_id': noteId,
      'case_id': caseId,
      'title': title,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }
}