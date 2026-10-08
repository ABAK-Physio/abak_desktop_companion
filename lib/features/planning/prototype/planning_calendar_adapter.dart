import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../models/planning_appointment.dart';

/// Calendar event payload carries the stable database identifier.
CalendarEventData<Object?> planningCalendarEvent(PlanningAppointment item) {
  DateTime at(int minutes) =>
      DateTime(item.date.year, item.date.month, item.date.day, 0, minutes);
  return CalendarEventData<Object?>(
    event: item.id,
    date: item.date,
    title: item.title,
    description: item.notes,
    color: Color(item.colorArgb),
    startTime: item.isAllDay ? null : at(item.startMinute!),
    endTime: item.isAllDay ? null : at(item.endMinute!),
  );
}

/// Caller supplies a UUID when creating; editing keeps the existing identifier.
PlanningAppointment planningAppointmentFromCalendar(
  CalendarEventData<Object?> event, {
  required String id,
}) {
  if (event.isRecurringEvent ||
      !DateUtils.isSameDay(event.date, event.endDate)) {
    throw ArgumentError(
      'Les rendez-vous récurrents ou sur plusieurs jours ne sont pas pris en charge.',
    );
  }
  int minute(DateTime time) => time.hour * 60 + time.minute;
  final start = event.startTime;
  final end = event.endTime;
  return PlanningAppointment(
    id: id,
    title: event.title,
    date: DateUtils.dateOnly(event.date),
    startMinute: start == null ? null : minute(start),
    endMinute: end == null
        ? null
        : (end.hour == 0 &&
                  end.minute == 0 &&
                  start != null &&
                  end.isAfter(start)
              ? 1440
              : minute(end)),
    notes: event.description ?? '',
    colorArgb: event.color.toARGB32(),
  );
}
