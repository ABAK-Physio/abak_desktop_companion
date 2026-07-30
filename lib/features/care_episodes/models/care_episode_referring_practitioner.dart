class CareEpisodeReferringPractitioner {
  final String assignmentId;
  final String careEpisodeId;
  final String practitionerId;

  /// Date (ms depuis Epoch) de début de responsabilité.
  final int startedAt;

  /// Null lorsque ce référent est le référent actuel.
  final int? endedAt;

  const CareEpisodeReferringPractitioner({
    required this.assignmentId,
    required this.careEpisodeId,
    required this.practitionerId,
    required this.startedAt,
    this.endedAt,
  });

  factory CareEpisodeReferringPractitioner.fromMap(
      Map<String, dynamic> map,
      ) {
    return CareEpisodeReferringPractitioner(
      assignmentId: map['assignment_id']?.toString() ?? '',
      careEpisodeId: map['care_episode_id']?.toString() ?? '',
      practitionerId: map['practitioner_id']?.toString() ?? '',
      startedAt: (map['started_at'] as num?)?.toInt() ?? 0,
      endedAt: (map['ended_at'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignment_id': assignmentId,
      'care_episode_id': careEpisodeId,
      'practitioner_id': practitionerId,
      'started_at': startedAt,
      'ended_at': endedAt,
    };
  }

  bool get isCurrent => endedAt == null;
}