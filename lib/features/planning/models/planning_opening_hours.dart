import 'dart:convert';

class OpeningPeriod {
  OpeningPeriod(this.start, this.end) {
    if (start < 420 || end > 1260 || end <= start) {
      throw ArgumentError(
        'Chaque plage doit être comprise entre 07:00 et 21:00, avec une fin après le début.',
      );
    }
  }
  final int start;
  final int end;
  Map<String, int> toMap() => {'start': start, 'end': end};
}

/// Weekly civil-time schedule. Empty day = closed; absent setting = unconfigured.
class PlanningOpeningHours {
  PlanningOpeningHours(Map<int, List<OpeningPeriod>> values) {
    if (values.length != 7 ||
        !List.generate(7, (i) => i + 1).every(values.containsKey)) {
      throw ArgumentError('Les sept jours doivent être renseignés.');
    }
    final copy = <int, List<OpeningPeriod>>{};
    for (var day = 1; day <= 7; day++) {
      final periods = [...values[day]!]
        ..sort((a, b) => a.start.compareTo(b.start));
      for (var i = 1; i < periods.length; i++) {
        if (periods[i].start < periods[i - 1].end) {
          throw ArgumentError(
            '${dayNames[day - 1]} : les plages d’ouverture ne doivent pas se chevaucher.',
          );
        }
      }
      copy[day] = List.unmodifiable(periods);
    }
    days = Map.unmodifiable(copy);
  }
  static const dayNames = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  late final Map<int, List<OpeningPeriod>> days;

  String encode() => jsonEncode({
    'version': 1,
    'days': [
      for (var day = 1; day <= 7; day++)
        {'weekday': day, 'periods': days[day]!.map((p) => p.toMap()).toList()},
    ],
  });

  factory PlanningOpeningHours.decode(String value) {
    try {
      final data = jsonDecode(value) as Map<String, dynamic>;
      if (data['version'] != 1) throw const FormatException('Version inconnue');
      final days = <int, List<OpeningPeriod>>{};
      for (final row in data['days'] as List) {
        final day = row['weekday'] as int;
        if (days.containsKey(day)) throw const FormatException('Jour répété');
        days[day] = [
          for (final period in row['periods'] as List)
            OpeningPeriod(period['start'] as int, period['end'] as int),
        ];
      }
      return PlanningOpeningHours(days);
    } catch (_) {
      throw const FormatException(
        'Les horaires enregistrés sont invalides ou d’une version non prise en charge.',
      );
    }
  }
}
