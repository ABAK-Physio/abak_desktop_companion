class CareEpisodeNote {
  final String noteId;
  final String careEpisodeId;

  final int noteDate;
  final String content;

  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const CareEpisodeNote({
    required this.noteId,
    required this.careEpisodeId,
    required this.noteDate,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory CareEpisodeNote.fromMap(Map<String, dynamic> map) {
    return CareEpisodeNote(
      noteId: map['note_id']?.toString() ?? '',
      careEpisodeId: map['care_episode_id']?.toString() ?? '',
      noteDate: (map['note_date'] as num?)?.toInt() ?? 0,
      content: map['content']?.toString() ?? '',
      createdAt: (map['created_at'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt(),
      archivedAt: (map['archived_at'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'note_id': noteId,
      'care_episode_id': careEpisodeId,
      'note_date': noteDate,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }

  bool get isArchived => archivedAt != null;
}
