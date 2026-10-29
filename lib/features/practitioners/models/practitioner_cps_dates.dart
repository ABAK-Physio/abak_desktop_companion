import 'dart:convert';

/// Calendar dates supplied by the user, never certificate validity timestamps.
class PractitionerCpsDates {
  PractitionerCpsDates({
    String? issueDate,
    Map<int, String> exerciseStarts = const {},
    this.revision = 0,
  }) : issueDate = optionalDate(issueDate),
       exerciseStarts = Map.unmodifiable({
         for (final entry in exerciseStarts.entries)
           if (optionalDate(entry.value) case final String date)
             entry.key: date,
       });

  final String? issueDate;
  final Map<int, String> exerciseStarts;
  final int revision;
  bool get isEmpty => issueDate == null && exerciseStarts.isEmpty;

  static String? optionalDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final date = value.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      throw const FormatException('Date attendue au format AAAA-MM-JJ.');
    }
    final parsed = DateTime.tryParse(date);
    if (parsed == null ||
        parsed.year < 1 ||
        parsed.toIso8601String().substring(0, 10) != date) {
      throw const FormatException('Date civile invalide.');
    }
    return date;
  }

  void checkSituations(Iterable<int> numbers) {
    if (exerciseStarts.keys.any((number) => !numbers.contains(number))) {
      throw const FormatException(
        'Une date est rattachée à une situation absente de la fiche CPS.',
      );
    }
  }

  String get encodedStarts {
    final numbers = exerciseStarts.keys.toList()..sort();
    return jsonEncode({for (final n in numbers) '$n': exerciseStarts[n]});
  }

  factory PractitionerCpsDates.fromStored(
    Map<String, Object?> row, {
    required String profileHash,
    required int readAt,
    required Iterable<int> situations,
  }) {
    if (row['provenance'] != 'user_declared' ||
        row['profile_hash'] != profileHash ||
        row['read_at'] != readAt ||
        row['revision'] is! int ||
        (row['revision'] as int) < 1) {
      throw const FormatException(
        'Les dates déclarées ne correspondent plus à la fiche CPS enregistrée.',
      );
    }
    final values = jsonDecode(row['exercise_starts_json'] as String) as Map;
    final starts = <int, String>{};
    for (final entry in values.entries) {
      final number = int.tryParse(entry.key.toString());
      if (number == null || '$number' != entry.key || entry.value is! String) {
        throw const FormatException('Dates des situations incohérentes.');
      }
      starts[number] = entry.value as String;
    }
    final result = PractitionerCpsDates(
      issueDate: row['issue_date'] as String?,
      exerciseStarts: starts,
      revision: row['revision'] as int,
    );
    result.checkSituations(situations);
    return result;
  }

  Map<String, String> contextValues(int number) => {
    'cpsIssueDate': issueDate ?? '',
    'cpsDatesRevision': '$revision',
    'validFrom': exerciseStarts[number] ?? '',
  };
}
