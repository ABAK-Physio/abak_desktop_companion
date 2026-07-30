class CareEpisodeReferringPractitionerHistoryItem {
  final String assignmentId;
  final String practitionerId;
  final String displayName;
  final bool isArchived;
  final int startedAt;
  final int? endedAt;

  const CareEpisodeReferringPractitionerHistoryItem({
    required this.assignmentId,
    required this.practitionerId,
    required this.displayName,
    required this.isArchived,
    required this.startedAt,
    this.endedAt,
  });

  factory CareEpisodeReferringPractitionerHistoryItem.fromMap(
      Map<String, dynamic> map,
      ) {
    return CareEpisodeReferringPractitionerHistoryItem(
      assignmentId: map['assignment_id']?.toString() ?? '',
      practitionerId: map['practitioner_id']?.toString() ?? '',
      displayName: map['display_name']?.toString() ?? 'Kiné inconnu',
      isArchived: map['archived_at'] != null,
      startedAt: (map['started_at'] as num?)?.toInt() ?? 0,
      endedAt: (map['ended_at'] as num?)?.toInt(),
    );
  }

  bool get isCurrent => endedAt == null;
}