import 'care_episode.dart';

class CareEpisodeSummary {
  final CareEpisode episode;
  final int notesCount;

  const CareEpisodeSummary({
    required this.episode,
    required this.notesCount,
  });

  factory CareEpisodeSummary.fromMap(Map<String, dynamic> map) {
    return CareEpisodeSummary(
      episode: CareEpisode.fromMap(map),
      notesCount: (map['notes_count'] as num?)?.toInt() ?? 0,
    );
  }

  bool get hasConclusion {
    final conclusion = episode.finalConclusion?.trim();
    return conclusion != null && conclusion.isNotEmpty;
  }
}