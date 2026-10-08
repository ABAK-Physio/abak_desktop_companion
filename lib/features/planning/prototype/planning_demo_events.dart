import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

/// Synthetic fixtures, rebuilt at launch and never saved.
List<CalendarEventData<Object?>> planningDemoEvents(DateTime anchor) {
  final today = DateTime(anchor.year, anchor.month, anchor.day);
  final events = <CalendarEventData<Object?>>[];
  for (var offset = -7; offset <= 14; offset++) {
    final day = DateTime(today.year, today.month, today.day + offset);
    events.addAll([
      CalendarEventData(
        date: day,
        title: 'Séance fictive A',
        description: 'Rendez-vous de démonstration — 45 minutes.',
        startTime: DateTime(day.year, day.month, day.day, 9),
        endTime: DateTime(day.year, day.month, day.day, 9, 45),
        color: Colors.teal.shade100,
      ),
      CalendarEventData(
        date: day,
        title: 'Séance fictive B',
        description: 'Chevauchement volontaire avec la séance A.',
        startTime: DateTime(day.year, day.month, day.day, 9, 15),
        endTime: DateTime(day.year, day.month, day.day, 10),
        color: Colors.orange.shade100,
      ),
      CalendarEventData(
        date: day,
        title: 'Bilan fictif',
        description: 'Bilan de démonstration — 60 minutes.',
        startTime: DateTime(day.year, day.month, day.day, 14),
        endTime: DateTime(day.year, day.month, day.day, 15),
        color: Colors.blue.shade100,
      ),
    ]);
  }
  events.add(
    CalendarEventData(
      date: today,
      title: 'Journée de démonstration',
      description: 'Exemple d’événement sur toute la journée.',
      color: Colors.purple.shade100,
    ),
  );
  return events;
}
