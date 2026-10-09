import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../models/planning_appointment.dart';

class PlanningBlockLink {
  const PlanningBlockLink(this.appointmentId);
  final String? appointmentId;
}

bool planningIsUnavailable(Object? payload) => payload is PlanningBlockLink;

class PlanningPatientLink {
  const PlanningPatientLink({
    this.appointmentId,
    required this.patientId,
    required this.label,
  });
  final String? appointmentId;
  final String patientId;
  final String label;
}

String? planningEventId(Object? payload) => payload is PlanningBlockLink
    ? payload.appointmentId
    : payload is PlanningPatientLink
    ? payload.appointmentId
    : payload as String?;
String planningPatientLabel(Object? payload) =>
    payload is PlanningPatientLink ? payload.label : '';

/// Calendar event payload carries the stable database identifier.
CalendarEventData<Object?> planningCalendarEvent(PlanningAppointment item) {
  DateTime at(int minutes) =>
      DateTime(item.date.year, item.date.month, item.date.day, 0, minutes);
  return CalendarEventData<Object?>(
    event: item.isUnavailable
        ? PlanningBlockLink(item.id)
        : item.patientId == null
        ? item.id
        : PlanningPatientLink(
            appointmentId: item.id,
            patientId: item.patientId!,
            label: item.patientLabel ?? 'Patient indisponible',
          ),
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
    isUnavailable: planningIsUnavailable(event.event),
    patientId: event.event is PlanningPatientLink
        ? (event.event as PlanningPatientLink).patientId
        : null,
    patientLabel: event.event is PlanningPatientLink
        ? (event.event as PlanningPatientLink).label
        : null,
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
