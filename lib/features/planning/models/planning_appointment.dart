/// A single local-calendar appointment, independent of Flutter/calendar_view.
/// Times are wall-clock minutes, so a DST change cannot shift an appointment.
class PlanningAppointment {
  PlanningAppointment({
    required this.id,
    required this.title,
    required this.date,
    this.startMinute,
    this.endMinute,
    this.patientId,
    this.patientLabel,
    this.notes = '',
    this.colorArgb = 0xFFB2DFDB,
  }) {
    if (id.trim().isEmpty || title.trim().isEmpty) {
      throw ArgumentError('Identifiant et titre obligatoires.');
    }
    if (date.isUtc ||
        date.year < 1 ||
        date.year > 9999 ||
        date != DateTime(date.year, date.month, date.day)) {
      throw ArgumentError('Une date civile locale sans heure est requise.');
    }
    if ((startMinute == null) != (endMinute == null) ||
        (startMinute != null &&
            (startMinute! < 0 ||
                endMinute! > 1440 ||
                endMinute! <= startMinute!))) {
      throw ArgumentError('Plage horaire invalide.');
    }
    if (colorArgb < 0 || colorArgb > 0xFFFFFFFF) {
      throw ArgumentError('Couleur ARGB invalide.');
    }
  }

  final String? patientId;

  /// Display-only, resolved from the patient record on reading.
  final String? patientLabel;
  final String id;
  final String title;
  final DateTime date;
  final int? startMinute;
  final int? endMinute;
  final String notes;
  final int colorArgb;

  bool get isAllDay => startMinute == null;

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Map<String, Object?> toMap() => {
    'appointment_id': id,
    'patient_id': patientId,
    'title': title,
    'appointment_date': dateKey(date),
    'start_minute': startMinute,
    'end_minute': endMinute,
    'notes': notes,
    'color_argb': colorArgb,
  };

  factory PlanningAppointment.fromMap(Map<String, Object?> row) {
    final key = row['appointment_date'] as String;
    final date = DateTime.parse(key);
    if (dateKey(date) != key) {
      throw FormatException('Date de rendez-vous invalide', key);
    }
    return PlanningAppointment(
      id: row['appointment_id'] as String,
      patientId: row['patient_id'] as String?,
      patientLabel: row['patient_label'] as String?,
      title: row['title'] as String,
      date: date,
      startMinute: row['start_minute'] as int?,
      endMinute: row['end_minute'] as int?,
      notes: row['notes'] as String,
      colorArgb: row['color_argb'] as int,
    );
  }
}
