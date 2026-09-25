import 'regions.dart';

class PainEntry {
  int? intensity;
  String note;
  PainEntry({this.intensity, this.note = ''});
  Map<String, dynamic> toJson() => {'intensity': intensity, 'note': note};
  factory PainEntry.fromJson(Map<String, dynamic> j) {
    final value = j['intensity'];
    if (value != null && (value is! int || value < 0 || value > 10)) {
      throw const FormatException('Intensité invalide');
    }
    return PainEntry(
      intensity: value as int?,
      note: j['note'] as String? ?? '',
    );
  }
}

class PainRecord {
  final Map<String, PainEntry> entries;
  final String date;
  final bool needsLateralityReview;
  PainRecord(this.entries, {String? date, this.needsLateralityReview = false})
    : date = date ?? DateTime.now().toIso8601String();
  Map<String, dynamic> toJson() => {
    'schemaVersion': 3,
    'provider': 'bodyheatmap',
    'jointProvider': 'rheumatoid-man',
    'jointRegionSchema': 'ctsit-77-v1',
    'providerVersion': '1.0.0',
    'regionSchema': muscleLateralitySchema,
    'lateralityConvention': 'patient',
    'lateralityVerified': true,
    'date': date,
    'entries': entries.map((key, value) => MapEntry(key, value.toJson())),
  };
  factory PainRecord.fromJson(Map<String, dynamic> j) {
    if ((j['schemaVersion'] != 1 &&
            j['schemaVersion'] != 2 &&
            j['schemaVersion'] != 3) ||
        j['provider'] != 'bodyheatmap' ||
        j['providerVersion'] != '1.0.0') {
      throw const FormatException('Format ou fournisseur non pris en charge');
    }
    if (j['schemaVersion'] != 1 &&
        (j['jointProvider'] != 'rheumatoid-man' ||
            j['jointRegionSchema'] != 'ctsit-77-v1')) {
      throw const FormatException('Carte articulaire inconnue');
    }
    if (j['schemaVersion'] == 3 &&
        j['regionSchema'] != muscleLateralitySchema) {
      throw const FormatException('Correspondance musculaire inconnue');
    }
    if (j['date'] is! String ||
        DateTime.tryParse(j['date'] as String) == null) {
      throw const FormatException('Date du relevé invalide');
    }
    return PainRecord(
      (j['entries'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, PainEntry.fromJson(value as Map<String, dynamic>)),
      ),
      date: j['date'] as String,
      needsLateralityReview: j['schemaVersion'] != 3,
    );
  }
}
