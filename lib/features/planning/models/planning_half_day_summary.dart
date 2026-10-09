import 'planning_appointment.dart';
import 'planning_opening_hours.dart';

class PlanningHalfDaySummary {
  const PlanningHalfDaySummary({
    required this.count,
    required this.longestFreeMinutes,
    required this.closed,
  });
  final int count;

  /// Null means hours have not been configured or could not be loaded.
  final int? longestFreeMinutes;
  final bool closed;
}

PlanningHalfDaySummary summarizePlanningHalfDay({
  required DateTime date,
  required bool afternoon,
  required List<PlanningAppointment> events,
  required PlanningOpeningHours? hours,
}) {
  final start = afternoon ? 720 : 420;
  final end = afternoon ? 1260 : 720;
  final occupied = <({int start, int end})>[];
  var count = 0;
  for (final event in events) {
    if (event.date.year != date.year ||
        event.date.month != date.month ||
        event.date.day != date.day) {
      continue;
    }
    final eventStart = event.startMinute ?? 420;
    final eventEnd = event.endMinute ?? 1260;
    if (eventStart >= end || eventEnd <= start) continue;
    if (!event.isUnavailable) count++;
    occupied.add((
      start: eventStart.clamp(start, end),
      end: eventEnd.clamp(start, end),
    ));
  }
  if (hours == null) {
    return PlanningHalfDaySummary(
      count: count,
      longestFreeMinutes: null,
      closed: false,
    );
  }
  final openings = hours.days[date.weekday]!
      .where((p) => p.start < end && p.end > start)
      .toList();
  if (openings.isEmpty) {
    return PlanningHalfDaySummary(
      count: count,
      longestFreeMinutes: 0,
      closed: true,
    );
  }
  occupied.sort((a, b) => a.start.compareTo(b.start));
  var longest = 0;
  for (final opening in openings) {
    final openingStart = opening.start.clamp(start, end);
    final openingEnd = opening.end.clamp(start, end);
    var cursor = openingStart;
    for (final block in occupied) {
      if (block.end <= cursor || block.start >= openingEnd) continue;
      final gap = block.start - cursor;
      if (gap > longest) longest = gap;
      if (block.end > cursor) {
        cursor = block.end.clamp(openingStart, openingEnd);
      }
    }
    if (openingEnd - cursor > longest) longest = openingEnd - cursor;
  }
  return PlanningHalfDaySummary(
    count: count,
    longestFreeMinutes: longest,
    closed: false,
  );
}
