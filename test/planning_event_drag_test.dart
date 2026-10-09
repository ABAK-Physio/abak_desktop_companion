import 'package:abak_desktop_companion/main_planning.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_event_drag.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  CalendarEventData<Object?> appointment(DateTime date) => CalendarEventData(
    title: 'Rendez-vous mobile',
    date: date,
    startTime: DateTime(date.year, date.month, date.day, 9),
    endTime: DateTime(date.year, date.month, date.day, 9, 45),
    description: 'À conserver',
    color: Colors.teal.shade100,
  );

  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
    PackageStrings.setLocale('fr');
  });

  test('Movement snaps, preserves duration and respects day boundaries', () {
    final event = appointment(DateTime(2026, 10, 25));
    final moved = shiftPlanningEvent(event, minuteDelta: 23, dayDelta: 1);
    expect(moved.date, DateTime(2026, 10, 26));
    expect(moved.startTime, DateTime(2026, 10, 26, 9, 30));
    expect(moved.endTime, DateTime(2026, 10, 26, 10, 15));
    expect(moved.description, event.description);
    final early = shiftPlanningEvent(event, minuteDelta: -1000);
    expect(early.startTime!.hour, 7);
    expect(early.duration.inMinutes, 45);
    final late = shiftPlanningEvent(event, minuteDelta: 1000);
    expect(late.endTime!.hour, 21);
    expect(late.duration.inMinutes, 45);
    final short = shiftPlanningEvent(event, minuteDelta: -1000, resize: true);
    expect(short.startTime, event.startTime);
    expect(short.duration.inMinutes, 15);
    final long = shiftPlanningEvent(event, minuteDelta: 1000, resize: true);
    expect(long.endTime!.hour, 21);
  });

  for (final size in [const Size(1400, 900), const Size(900, 650)]) {
    testWidgets('Mouse move, resize, Escape and week transfer at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const PlanningPrototypeApp());
      await tester.pumpAndSettle();
      final controller = tester
          .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
          .controller!;
      final date = DateUtils.dateOnly(DateTime.now());
      controller.clear();
      controller.add(appointment(date));
      await tester.tap(find.text('Jour'));
      await tester.pumpAndSettle();

      Finder card() => find.byType(PlanningEventDrag);
      Future<TestGesture> drag(Offset origin, Offset offset) async {
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.down(origin);
        await gesture.moveBy(offset / 2);
        await tester.pump();
        await gesture.moveBy(offset / 2);
        await tester.pump();
        return gesture;
      }

      final before = controller.allEvents.single;
      final move = await drag(
        tester.getTopLeft(card()) + const Offset(15, 8),
        const Offset(0, 60),
      );
      expect(controller.allEvents.single, same(before));
      expect(find.textContaining('Échap pour annuler'), findsOneWidget);
      await move.up();
      await tester.pumpAndSettle();
      final moved = controller.allEvents.single;
      expect(moved.startTime!.hour, 10);
      expect(moved.startTime!.minute, 0);
      expect(moved.duration.inMinutes, 45);
      expect(find.byType(AlertDialog), findsNothing);

      final resize = await drag(
        tester.getBottomLeft(card()) + const Offset(12, -3),
        const Offset(0, 30),
      );
      await resize.up();
      await tester.pumpAndSettle();
      final resized = controller.allEvents.single;
      expect(resized.startTime, moved.startTime);
      expect(resized.endTime!.hour, 11);
      expect(resized.endTime!.minute, 15);

      final cancelled = await drag(
        tester.getTopLeft(card()) + const Offset(15, 8),
        const Offset(0, 30),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await cancelled.up();
      await tester.pumpAndSettle();
      expect(controller.allEvents.single, same(resized));
      expect(find.textContaining('Échap pour annuler'), findsNothing);

      final outside = await drag(
        tester.getTopLeft(card()) + const Offset(15, 8),
        const Offset(-1600, 30),
      );
      await outside.up();
      await tester.pumpAndSettle();
      expect(controller.allEvents.single, same(resized));

      await tester.tap(find.text('Semaine'));
      await tester.pumpAndSettle();
      final direction = date.weekday == DateTime.sunday ? -1 : 1;
      final width = (size.width - 32 - 70) / 7;
      final transfer = await drag(
        tester.getTopLeft(card()) + const Offset(15, 8),
        Offset(width * direction, 0),
      );
      await transfer.up();
      await tester.pumpAndSettle();
      expect(
        controller.allEvents.single.date,
        DateTime(date.year, date.month, date.day + direction),
      );
      expect(controller.allEvents.single.startTime!.hour, 10);
      expect(controller.allEvents.single.duration.inMinutes, 75);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
  for (final zoom in [1.5, 2.0, 2.5, 3.0]) {
    testWidgets(
      'Day zoom $zoom scales cards and gestures without changing Week',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(900, 650);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const PlanningPrototypeApp());
        await tester.pumpAndSettle();
        final controller = tester
            .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
            .controller!;
        final day = DateUtils.dateOnly(DateTime.now());
        controller.clear();
        controller.add(
          CalendarEventData<Object?>(
            title: 'Court',
            date: day,
            startTime: DateTime(day.year, day.month, day.day, 7, 30),
            endTime: DateTime(day.year, day.month, day.day, 7, 45),
          ),
        );
        expect(find.byKey(const ValueKey('day-zoom')), findsNothing);
        await tester.tap(find.text('Jour'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('day-zoom')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('${(zoom * 100).round()} %').last);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<DayView<Object?>>(find.byType(DayView<Object?>))
              .heightPerMinute,
          zoom,
        );
        expect(
          tester.getSize(find.byType(PlanningEventDrag)).height,
          closeTo(15 * zoom, 1),
        );
        if (zoom >= 2.5) expect(find.text('07:30 – 07:45'), findsOneWidget);
        Future<void> drag(Offset origin, double distance) async {
          final gesture = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await gesture.down(origin);
          await gesture.moveBy(Offset(0, distance / 2));
          await tester.pump();
          await gesture.moveBy(Offset(0, distance / 2));
          await tester.pump();
          await gesture.up();
          await tester.pumpAndSettle();
        }

        await drag(
          tester.getTopLeft(find.byType(PlanningEventDrag)) +
              const Offset(15, 5),
          30 * zoom,
        );
        expect(controller.allEvents.single.startTime!.hour, 8);
        expect(controller.allEvents.single.startTime!.minute, 0);
        expect(controller.allEvents.single.duration.inMinutes, 15);
        await drag(
          tester.getBottomLeft(find.byType(PlanningEventDrag)) +
              const Offset(12, -3),
          15 * zoom,
        );
        expect(controller.allEvents.single.duration.inMinutes, 30);
        final state = tester.state<DayViewState<Object?>>(
          find.byType(DayView<Object?>),
        );
        state.scrollController.jumpTo(100 * zoom);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('day-zoom')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('100 %').last);
        await tester.pumpAndSettle();
        expect(state.scrollController.offset, closeTo(100, 1));
        await tester.tap(find.byKey(const ValueKey('day-zoom')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('${(zoom * 100).round()} %').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Semaine'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('day-zoom')), findsNothing);
        expect(
          tester
              .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
              .heightPerMinute,
          1,
        );
        await tester.tap(find.text('Mois'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('day-zoom')), findsNothing);
        await tester.tap(find.text('Jour'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<DayView<Object?>>(find.byType(DayView<Object?>))
              .heightPerMinute,
          zoom,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final zoom in [1.5, 2.0, 2.5, 3.0]) {
    testWidgets(
      'Week zoom $zoom preserves transfer, resize and independent Day zoom',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(900, 650);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const PlanningPrototypeApp());
        await tester.pumpAndSettle();
        final controller = tester
            .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
            .controller!;
        final day = DateUtils.dateOnly(DateTime.now());
        controller.clear();
        controller.add(
          CalendarEventData<Object?>(
            title: 'Semaine zoom',
            date: day,
            startTime: DateTime(day.year, day.month, day.day, 7, 30),
            endTime: DateTime(day.year, day.month, day.day, 8),
          ),
        );
        Future<void> setZoom(String key, double value) async {
          await tester.tap(find.byKey(ValueKey(key)));
          await tester.pumpAndSettle();
          await tester.tap(find.text('${(value * 100).round()} %').last);
          await tester.pumpAndSettle();
        }

        await setZoom('week-zoom', zoom);
        expect(
          tester
              .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
              .heightPerMinute,
          zoom,
        );
        expect(
          tester.getSize(find.byType(PlanningEventDrag)).height,
          closeTo(30 * zoom, 1),
        );
        Future<void> drag(Offset origin, Offset delta) async {
          final gesture = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await gesture.down(origin);
          await gesture.moveBy(delta / 2);
          await tester.pump();
          await gesture.moveBy(delta / 2);
          await tester.pump();
          await gesture.up();
          await tester.pumpAndSettle();
        }

        final direction = day.weekday == 7 ? -1 : 1;
        final column = tester
            .widget<PlanningEventDrag>(find.byType(PlanningEventDrag))
            .columnWidth;
        await drag(
          tester.getTopLeft(find.byType(PlanningEventDrag)) +
              const Offset(15, 8),
          Offset(direction * column, 30 * zoom),
        );
        final moved = controller.allEvents.single;
        expect(moved.date, DateTime(day.year, day.month, day.day + direction));
        expect(moved.startTime!.hour, 8);
        expect(moved.startTime!.minute, 0);
        expect(moved.duration.inMinutes, 30);
        // At high zoom on a short window, scroll to keep the resize drop visible.
        tester
            .state<WeekViewState<Object?>>(find.byType(WeekView<Object?>))
            .scrollController
            .jumpTo(60 * zoom);
        await tester.pumpAndSettle();
        await drag(
          tester.getBottomLeft(find.byType(PlanningEventDrag)) +
              const Offset(12, -3),
          Offset(0, 15 * zoom),
        );
        expect(controller.allEvents.single.duration.inMinutes, 45);
        final state = tester.state<WeekViewState<Object?>>(
          find.byType(WeekView<Object?>),
        );
        state.scrollController.jumpTo(100 * zoom);
        await tester.pumpAndSettle();
        await setZoom('week-zoom', 1);
        expect(state.scrollController.offset, closeTo(100, 1));
        await setZoom('week-zoom', zoom);
        await tester.tap(find.text('Jour'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<DayView<Object?>>(find.byType(DayView<Object?>))
              .heightPerMinute,
          1,
        );
        await setZoom('day-zoom', 2.5);
        await tester.tap(find.text('Semaine'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
              .heightPerMinute,
          zoom,
        );
        await tester.tap(find.text('Mois'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('week-zoom')), findsNothing);
        await tester.tap(find.text('Jour'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<DayView<Object?>>(find.byType(DayView<Object?>))
              .heightPerMinute,
          2.5,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
