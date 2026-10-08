import 'package:abak_desktop_companion/main_planning.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_overlaps.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_stack_arranger.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  test(
    'Stacked appointments share horizontal space without changing times',
    () {
      final date = DateTime(2026, 10, 8);
      CalendarEventData<Object?> event(
        String title,
        int hour,
        int minute,
        int endHour,
        int endMinute,
      ) => CalendarEventData(
        title: title,
        date: date,
        startTime: DateTime(2026, 10, 8, hour, minute),
        endTime: DateTime(2026, 10, 8, endHour, endMinute),
      );
      final a = event('A', 9, 0, 9, 45);
      final b = event('B', 9, 15, 10, 0);
      final c = event('C', 14, 0, 15, 0);
      final cards = const PlanningStackArranger<Object?>().arrange(
        events: [a, b, c],
        height: 1020,
        width: 1000,
        heightPerMinute: 1,
        startHour: 7,
        calendarViewDate: date,
      );
      final first = cards.singleWhere(
        (card) => identical(card.events.single, a),
      );
      final second = cards.singleWhere(
        (card) => identical(card.events.single, b),
      );
      final alone = cards.singleWhere(
        (card) => identical(card.events.single, c),
      );
      expect(first.left, 0);
      expect(second.left, greaterThan(first.left));
      expect(second.left, lessThan(1000 - first.right));
      expect(first.top, 120);
      expect(second.top, 135);
      expect(1020 - first.bottom, 165);
      expect(1020 - second.bottom, 180);
      expect(alone.left, 0);
      expect(alone.right, 0);
      expect(cards.indexOf(second), greaterThan(cards.indexOf(first)));
    },
  );
  test(
    'Overlap is the common interval, excluding adjacent and full-day events',
    () {
      CalendarEventData<Object?> appointment(
        String title,
        int day,
        int startMinute,
        int endMinute,
      ) => CalendarEventData(
        title: title,
        date: DateTime(2026, 10, day),
        startTime: DateTime(2026, 10, day, 9, startMinute),
        endTime: DateTime(2026, 10, day, 9, endMinute),
      );
      final a = appointment('A', 8, 0, 45);
      final b = appointment('B', 8, 15, 60);
      final adjacent = appointment('Adjacent', 8, 45, 60);
      final otherDay = appointment('Other day', 9, 0, 45);
      final allDay = CalendarEventData<Object?>(
        title: 'All day',
        date: DateTime(2026, 10, 8),
      );
      final overlaps = planningOverlaps(a, [a, b, adjacent, otherDay, allDay]);
      expect(overlaps, hasLength(1));
      expect(overlaps.single.event, same(b));
      expect(overlaps.single.start, DateTime(2026, 10, 8, 9, 15));
      expect(overlaps.single.end, DateTime(2026, 10, 8, 9, 45));
      expect(planningOverlaps(b, [a]).single.event, same(a));
      expect(planningOverlaps(allDay, [a, b]), isEmpty);
    },
  );
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
    PackageStrings.setLocale('fr');
  });

  for (final size in [const Size(1400, 900), const Size(900, 650)]) {
    testWidgets('Views, navigation and details at $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const PlanningPrototypeApp());
      await tester.pumpAndSettle();
      expect(find.byType(WeekView<Object?>), findsOneWidget);
      final controller = tester
          .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
          .controller;
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Jour'));
      await tester.pumpAndSettle();
      final day = tester.widget<DayView<Object?>>(
        find.byType(DayView<Object?>),
      );
      expect(day.controller, same(controller));
      expect(find.text('Séance fictive A'), findsWidgets);
      expect(find.text('Séance fictive B'), findsWidgets);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(3));
      await tester.tap(find.text('Séance fictive A').first);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('Chevauchement 09:15 – 09:45 avec Séance fictive B'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('09:00 – 09:45'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Période suivante'));
      await tester.pumpAndSettle();
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      expect(
        find.text(DateFormat.yMMMMEEEEd('fr_FR').format(tomorrow)),
        findsOneWidget,
      );
      await tester.tap(find.text('Mois'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<MonthView<Object?>>(find.byType(MonthView<Object?>))
            .controller,
        same(controller),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Jour'));
      await tester.pumpAndSettle();
      expect(
        find.text(DateFormat.yMMMMEEEEd('fr_FR').format(tomorrow)),
        findsOneWidget,
      );
      await tester.tap(find.text('Aujourd’hui'));
      await tester.pumpAndSettle();
      expect(
        find.text(DateFormat.yMMMMEEEEd('fr_FR').format(now)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  for (final view in ['Jour', 'Semaine', 'Mois']) {
    testWidgets('Delete and undo preserves appointment and overlaps in $view', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1400, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const PlanningPrototypeApp());
      await tester.pumpAndSettle();
      final controller = tester
          .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
          .controller!;
      final date = DateUtils.dateOnly(DateTime.now());
      final a = CalendarEventData<Object?>(
        title: 'À supprimer',
        date: date,
        startTime: DateTime(date.year, date.month, date.day, 9),
        endTime: DateTime(date.year, date.month, date.day, 9, 45),
        description: 'Notes à conserver',
        color: Colors.orange,
      );
      final b = CalendarEventData<Object?>(
        title: 'À conserver',
        date: date,
        startTime: DateTime(date.year, date.month, date.day, 9, 15),
        endTime: DateTime(date.year, date.month, date.day, 10),
      );
      controller.clear();
      controller.addAll([a, b]);
      await tester.tap(find.text(view));
      await tester.pumpAndSettle();
      await tester.tapAt(
        tester.getTopLeft(find.text('À supprimer').first) + const Offset(4, 4),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(controller.allEvents, [b]);
      expect(planningOverlaps(b, controller.allEvents), isEmpty);
      expect(find.text('À supprimer'), findsNothing);
      expect(find.text('« À supprimer » supprimé.'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(controller.allEvents, hasLength(2));
      expect(
        controller.allEvents.singleWhere((e) => e.title == 'À supprimer'),
        same(a),
      );
      expect(planningOverlaps(b, controller.allEvents), hasLength(1));
      expect(find.text('À supprimer'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets('Create, validate, cancel and edit an appointment in memory', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 650);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const PlanningPrototypeApp());
    await tester.pumpAndSettle();
    final controller = tester
        .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
        .controller!;
    final initialCount = controller.allEvents.length;

    Future<void> enter(String label, String value) =>
        tester.enterText(find.widgetWithText(TextFormField, label), value);
    Future<void> save() async {
      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.widgetWithText(FilledButton, 'Nouveau rendez-vous'));
    await tester.pumpAndSettle();
    await save();
    expect(find.text('Indiquez un titre.'), findsOneWidget);
    expect(controller.allEvents.length, initialCount);
    await enter('Titre', 'Essai planning');
    await enter('Début', '09:30');
    await enter('Fin', '09:15');
    await save();
    expect(find.text('La fin doit suivre le début.'), findsOneWidget);
    await enter('Fin', '25:00');
    await save();
    expect(find.text('Utilisez le format HH:mm.'), findsOneWidget);
    await enter('Fin', '10:15');
    await save();
    expect(controller.allEvents.length, initialCount + 1);
    final created = controller.allEvents.singleWhere(
      (event) => event.title == 'Essai planning',
    );
    expect(planningOverlaps(created, controller.allEvents), hasLength(2));

    await tester.tap(find.text('Jour'));
    await tester.pumpAndSettle();
    await tester.tapAt(
      tester.getTopLeft(find.text('Essai planning').first) + const Offset(4, 4),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    await enter('Titre', 'Modification annulée');
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(controller.allEvents.contains(created), isTrue);
    await tester.tapAt(
      tester.getTopLeft(find.text('Essai planning').first) + const Offset(4, 4),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    await enter('Titre', 'Essai modifié');
    await enter('Début', '11:00');
    await enter('Fin', '11:45');
    await enter('Notes (facultatif)', 'Note de test');
    await save();
    expect(controller.allEvents.length, initialCount + 1);
    expect(controller.allEvents.contains(created), isFalse);
    final updated = controller.allEvents.singleWhere(
      (event) => event.title == 'Essai modifié',
    );
    expect(updated.startTime!.hour, 11);
    expect(updated.description, 'Note de test');
    expect(planningOverlaps(updated, controller.allEvents), isEmpty);
    await tester.tap(find.text('Mois'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MonthView<Object?>>(find.byType(MonthView<Object?>))
          .controller!
          .allEvents,
      contains(updated),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
