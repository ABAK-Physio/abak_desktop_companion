import 'package:abak_desktop_companion/features/care_episodes/models/assessment_templates/assessment_template.dart';
import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';

class AssessmentTemplatePrefillResolver {
  Map<String, String> resolve({
    required AssessmentTemplate template,
    required String? profession,
    required String? sportsActivities,
    required List<DesktopResult> episodeResults,
  }) {
    final values = <String, String>{};

    for (final section in template.sections) {
      for (final field in section.fields) {
        final source = field.abakSource;

        if (source == null || source.trim().isEmpty) {
          continue;
        }

        final value = _resolveSource(
          source: source,
          profession: profession,
          sportsActivities: sportsActivities,
          episodeResults: episodeResults,
        );

        if (value != null && value.isNotEmpty) {
          values[field.id] = value;
        }
      }
    }

    return values;
  }

  String? _resolveSource({
    required String source,
    required String? profession,
    required String? sportsActivities,
    required List<DesktopResult> episodeResults,
  }) {
    switch (source) {
      case 'patient.profession':
        return _clean(profession);

      case 'patient.sportsActivities':
        return _clean(sportsActivities);

      case 'result.E53.scoreTotal':
        return _firstScoreTotal(
          episodeResults: episodeResults,
          exoId: 'E53',
        );
    }

    return null;
  }

  String? _firstScoreTotal({
    required List<DesktopResult> episodeResults,
    required String exoId,
  }) {
    final results = episodeResults
        .where(
          (result) =>
      result.exoId == exoId &&
          result.scoreTotal != null,
    )
        .toList()
      ..sort(
            (a, b) => a.createdAt.compareTo(b.createdAt),
      );

    if (results.isEmpty) {
      return null;
    }

    return results.first.scoreTotal!.toStringAsFixed(0);
  }

  String? _clean(String? value) {
    final cleaned = value?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }
}