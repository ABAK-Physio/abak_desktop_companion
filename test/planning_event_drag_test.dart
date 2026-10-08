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
}
