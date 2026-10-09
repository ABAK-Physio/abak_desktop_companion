import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/planning_half_day_summary.dart';
import '../models/planning_opening_hours.dart';
import 'planning_calendar_adapter.dart';

class PlanningMonthCell extends StatelessWidget {
  const PlanningMonthCell({
    super.key,
    required this.date,
    required this.events,
    required this.today,
    required this.inMonth,
    required this.hours,
    required this.hoursFailed,
    this.individualHours = false,
    required this.onOpen,
  });
  final DateTime date;
  final List<CalendarEventData<Object?>> events;
  final bool today;
  final bool inMonth;
  final PlanningOpeningHours? hours;
  final bool hoursFailed;
  final bool individualHours;
  final ValueChanged<bool> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = events
        .map(
          (event) => planningAppointmentFromCalendar(
            event,
            id: planningEventId(event.event) ?? 'summary',
          ),
        )
        .toList();
    return Material(
      color: inMonth ? Colors.white : Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => onOpen(false),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: today
                      ? Colors.teal.shade800
                      : inMonth
                      ? Colors.black87
                      : Colors.grey,
                ),
              ),
            ),
          ),
          for (final afternoon in [false, true])
            Expanded(
              child: _period(
                context,
                afternoon,
                summarizePlanningHalfDay(
                  date: date,
                  afternoon: afternoon,
                  events: items,
                  hours: hours,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _period(
    BuildContext context,
    bool afternoon,
    PlanningHalfDaySummary summary,
  ) {
    final minutes = summary.longestFreeMinutes;
    final status = hoursFailed
        ? 'Indisp.'
        : minutes == null
        ? 'À définir'
        : summary.closed
        ? (individualHours ? 'Repos' : 'Fermé')
        : minutes >= 30
        ? '≥30 min'
        : minutes >= 20
        ? '20 min'
        : '<20 min';
    final detail = hoursFailed
        ? 'Horaires indisponibles'
        : minutes == null
        ? 'Horaires à définir'
        : summary.closed
        ? (individualHours
              ? 'Praticien absent selon ses horaires de travail'
              : 'Cabinet fermé')
        : 'Plus grand créneau libre : $minutes minutes';
    final label =
        '${DateFormat.yMMMMd('fr_FR').format(date)}, ${afternoon ? 'après-midi' : 'matin'} : ${summary.count} RV. $detail. Ouvrir la journée.';
    final color = minutes == null || summary.closed
        ? Colors.grey.shade100
        : minutes >= 30
        ? Colors.teal.shade50
        : minutes >= 20
        ? Colors.blue.shade50
        : Colors.orange.shade50;
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: true,
        child: InkWell(
          key: ValueKey(('month-half', date, afternoon)),
          onTap: () => onOpen(afternoon),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            color: color,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${afternoon ? 'A' : 'M'} · ${summary.count} RV',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                Text(status, maxLines: 1, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
