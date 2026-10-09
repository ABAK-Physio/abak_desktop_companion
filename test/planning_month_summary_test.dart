import 'package:abak_desktop_companion/features/planning/models/planning_appointment.dart';
import 'package:abak_desktop_companion/features/planning/models/planning_opening_hours.dart';
import 'package:abak_desktop_companion/features/planning/models/planning_half_day_summary.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_month_cell.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_calendar_adapter.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_event_dialog.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final date = DateTime(2026, 10, 10);
  PlanningOpeningHours hours(List<OpeningPeriod> periods) =>
      PlanningOpeningHours({
        for (var day = 1; day <= 7; day++) day: day == 6 ? periods : [],
      });
  PlanningAppointment event(int start, int end, {bool pause = false}) =>
      PlanningAppointment(
        id: '$start-$end',
        title: 'Event',
        date: date,
        startMinute: start,
        endMinute: end,
        isUnavailable: pause,
      );
  PlanningHalfDaySummary summarize(
    List<PlanningAppointment> events,
    PlanningOpeningHours? opening, {
    bool afternoon = false,
  }) => summarizePlanningHalfDay(
    date: date,
    afternoon: afternoon,
    events: events,
    hours: opening,
  );
  setUpAll(() => initializeDateFormatting('fr_FR'));

  test(
    'individual week excludes afternoons off and subtracts appointments and pauses',
    () {
      final wednesday = DateTime(2026, 10, 14);
      final individual = PlanningOpeningHours({
        for (var day = 1; day <= 7; day++)
          day: day == 5 ? [] : [OpeningPeriod(540, day == 3 ? 720 : 1080)],
      });
      PlanningAppointment item(
        String id,
        int start,
        int end, {
        bool pause = false,
      }) => PlanningAppointment(
        id: id,
        title: id,
        date: wednesday,
        startMinute: start,
        endMinute: end,
        isUnavailable: pause,
      );
      final events = [
        item('rv', 540, 600),
        item('pause', 620, 720, pause: true),
        item('exception', 840, 870),
      ];
      final morning = summarizePlanningHalfDay(
        date: wednesday,
        afternoon: false,
        events: events,
        hours: individual,
      );
      expect(morning.count, 1);
      expect(morning.longestFreeMinutes, 20);
      final afternoon = summarizePlanningHalfDay(
        date: wednesday,
        afternoon: true,
        events: events,
        hours: individual,
      );
      expect(afternoon.closed, isTrue);
      expect(afternoon.count, 1);
      expect(afternoon.longestFreeMinutes, 0);
      for (final afternoon in [false, true]) {
        expect(
          summarizePlanningHalfDay(
            date: DateTime(2026, 10, 16),
            afternoon: afternoon,
            events: [],
            hours: individual,
          ).closed,
          isTrue,
        );
      }
    },
  );

  test('overlaps count individually but use the union of occupied times', () {
    final summary = summarize([
      event(480, 540),
      event(510, 570),
      event(555, 600),
    ], hours([OpeningPeriod(480, 630)]));
    expect(summary.count, 3);
    expect(summary.longestFreeMinutes, 30);
  });
  test('pauses block time without adding RV and small gaps are not summed', () {
    final summary = summarize([
      event(495, 600, pause: true),
    ], hours([OpeningPeriod(480, 615)]));
    expect(summary.count, 0);
    expect(summary.longestFreeMinutes, 15);
    expect(
      summarize(
        [],
        hours([OpeningPeriod(480, 495), OpeningPeriod(600, 615)]),
      ).longestFreeMinutes,
      15,
    );
    expect(
      summarize([
        event(480, 600, pause: true),
      ], hours([OpeningPeriod(480, 620)])).longestFreeMinutes,
      20,
    );
  });
  test(
    'noon boundary, closed days, unknown hours and outside appointments',
    () {
      final opening = hours([
        OpeningPeriod(540, 720),
        OpeningPeriod(840, 1080),
      ]);
      final events = [event(420, 450), event(690, 720), event(720, 750)];
      expect(summarize(events, opening).count, 2);
      expect(summarize(events, opening).longestFreeMinutes, 150);
      expect(summarize(events, opening, afternoon: true).count, 1);
      expect(
        summarize(events, opening, afternoon: true).longestFreeMinutes,
        240,
      );
      expect(summarize(events, hours([])).closed, isTrue);
      expect(summarize(events, null).longestFreeMinutes, isNull);
      expect(summarize([event(710, 730)], opening).count, 1);
      expect(summarize([event(710, 730)], opening, afternoon: true).count, 1);
    },
  );
  test('all-day unavailability blocks both halves without RV', () {
    final pause = PlanningAppointment(
      id: 'pause',
      title: 'Congé',
      date: date,
      isUnavailable: true,
    );
    for (final afternoon in [false, true]) {
      final summary = summarize(
        [pause],
        hours([OpeningPeriod(420, 1260)]),
        afternoon: afternoon,
      );
      expect(summary.count, 0);
      expect(summary.longestFreeMinutes, 0);
    }
  });

  testWidgets(
    'compact month cell shows summaries and opens chosen half without titles',
    (tester) async {
      bool? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 120,
              height: 64,
              child: PlanningMonthCell(
                date: date,
                today: false,
                inMonth: true,
                hoursFailed: false,
                hours: hours([OpeningPeriod(480, 630)]),
                events: [planningCalendarEvent(event(480, 600))],
                onOpen: (value) => selected = value,
              ),
            ),
          ),
        ),
      );
      expect(find.text('M · 1 RV'), findsOneWidget);
      expect(find.text('≥30 min'), findsOneWidget);
      expect(find.text('Fermé'), findsOneWidget);
      expect(find.text('Event'), findsNothing);
      await tester.tap(find.byKey(ValueKey(('month-half', date, true))));
      expect(selected, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'pause type is explicit and converting an RV removes its patient',
    (tester) async {
      CalendarEventData<Object?>? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlanningEventDialog(
              date: date,
              event: CalendarEventData<Object?>(
                date: date,
                title: 'Déjeuner',
                event: const PlanningPatientLink(
                  appointmentId: 'id',
                  patientId: 'p1',
                  label: 'Patient',
                ),
              ),
              onSave: (event) async {
                saved = event;
                return false;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<bool>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pause ou indisponibilité').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(planningIsUnavailable(saved!.event), isTrue);
      expect(planningEventId(saved!.event), 'id');
      final record = planningAppointmentFromCalendar(saved!, id: 'id');
      expect(record.patientId, isNull);
      expect(record.isUnavailable, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
