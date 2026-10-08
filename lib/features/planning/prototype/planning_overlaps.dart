import 'package:calendar_view/calendar_view.dart';

typedef PlanningOverlap = ({
  CalendarEventData<Object?> event,
  DateTime start,
  DateTime end,
});

/// Timed appointments only; adjacent appointments do not overlap.
List<PlanningOverlap> planningOverlaps(
  CalendarEventData<Object?> event,
  Iterable<CalendarEventData<Object?>> candidates,
) {
  if (event.isFullDayEvent) return [];
  DateTime startOf(CalendarEventData<Object?> item) => DateTime(
    item.date.year,
    item.date.month,
    item.date.day,
    item.startTime!.hour,
    item.startTime!.minute,
  );
  DateTime endOf(CalendarEventData<Object?> item) => DateTime(
    item.endDate.year,
    item.endDate.month,
    item.endDate.day,
    item.endTime!.hour,
    item.endTime!.minute,
  );
  final start = startOf(event);
  final end = endOf(event);
  final overlaps = <PlanningOverlap>[];
  for (final other in candidates) {
    if (identical(event, other) || other.isFullDayEvent) continue;
    final otherStart = startOf(other);
    final otherEnd = endOf(other);
    if (start.isBefore(otherEnd) && otherStart.isBefore(end)) {
      overlaps.add((
        event: other,
        start: start.isAfter(otherStart) ? start : otherStart,
        end: end.isBefore(otherEnd) ? end : otherEnd,
      ));
    }
  }
  return overlaps;
}
