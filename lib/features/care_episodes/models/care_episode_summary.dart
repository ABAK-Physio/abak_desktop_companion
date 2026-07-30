import 'care_episode.dart';

class CareEpisodeSummary {
  final CareEpisode episode;
  final int notesCount;

  final String? referringPractitionerDisplayName;
  final bool referringPractitionerArchived;

  const CareEpisodeSummary({
    required this.episode,
    required this.notesCount,
    this.referringPractitionerDisplayName,
    this.referringPractitionerArchived = false,
  });

  factory CareEpisodeSummary.fromMap(Map<String, dynamic> map) {
    return CareEpisodeSummary(
      episode: CareEpisode.fromMap(map),
      notesCount: (map['notes_count'] as num?)?.toInt() ?? 0,
      referringPractitionerDisplayName:
      map['referring_practitioner_display_name']?.toString(),
      referringPractitionerArchived:
      (map['referring_practitioner_archived'] as num?)?.toInt() == 1,
    );
  }

  bool get hasConclusion {
    final conclusion = episode.finalConclusion?.trim();
    return conclusion != null && conclusion.isNotEmpty;
  }
}
