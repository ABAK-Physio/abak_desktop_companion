import 'package:abak_desktop_companion/features/planning/prototype/planning_event_drag.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_slot_detector.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final step in [15, 20, 30]) {
    test(
      'movement and resize use $step minutes while retaining existing duration',
      () {
        final event = CalendarEventData<Object?>(
          date: DateTime(2026, 10, 14),
          title: 'RV',
          startTime: DateTime(2026, 10, 14, 9),
          endTime: DateTime(2026, 10, 14, 9, 45),
        );
        final moved = shiftPlanningEvent(
          event,
          minuteDelta: step.toDouble(),
          stepMinutes: step,
        );
        expect(moved.startTime, DateTime(2026, 10, 14, 9, step));
        expect(moved.duration.inMinutes, 45);
        final resized = shiftPlanningEvent(
          event,
          minuteDelta: 25,
          resize: true,
          stepMinutes: step,
        );
        expect(
          (resized.endTime!.hour * 60 + resized.endTime!.minute) % step,
          0,
        );
        expect(resized.startTime, event.startTime);
        final late = event.copyWith(
          startTime: DateTime(2026, 10, 14, 20, 50),
          endTime: DateTime(2026, 10, 14, 21),
        );
        expect(
          shiftPlanningEvent(
            late,
            minuteDelta: 15,
            resize: true,
            stepMinutes: step,
          ).endTime,
          late.endTime,
        );
        final otherDay = shiftPlanningEvent(
          late,
          minuteDelta: 0,
          dayDelta: 1,
          stepMinutes: step,
        );
        expect(otherDay.startTime, DateTime(2026, 10, 15, 20, 50));
        expect(otherDay.duration, late.duration);
      },
    );
    for (final zoom in [1.0, 2.5]) {
      testWidgets('tap slots of $step minutes at zoom $zoom', (tester) async {
        DateTime? selected;
        await tester.pumpWidget(
          MaterialApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: PlanningSlotDetector(
                date: DateTime(2026, 10, 14),
                width: 200,
                height: 500,
                heightPerMinute: zoom,
                stepMinutes: step,
                onDateTap: (value) => selected = value,
              ),
            ),
          ),
        );
        final origin = tester.getTopLeft(find.byType(PlanningSlotDetector));
        await tester.tapAt(origin + Offset(40, (step + 2) * zoom));
        expect(selected, DateTime(2026, 10, 14, 7, step));
        await tester.tapAt(origin + Offset(40, (step - 1) * zoom));
        expect(selected, DateTime(2026, 10, 14, 7));
      });
    }
  }
}
