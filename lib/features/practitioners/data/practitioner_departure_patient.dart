class PractitionerDeparturePatient {
  const PractitionerDeparturePatient({
    required this.id,
    required this.name,
    required this.active,
    required this.inferred,
    required this.archived,
    this.lastActivity,
  });
  final String id, name;
  final bool active, inferred, archived;
  final DateTime? lastActivity;
}

DateTime threeCalendarMonthsBefore(DateTime date) {
  final first = DateTime(date.year, date.month - 3, 1);
  final lastDay = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(
    first.year,
    first.month,
    date.day > lastDay ? lastDay : date.day,
  );
}
