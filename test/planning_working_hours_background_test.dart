import 'package:abak_desktop_companion/features/planning/models/planning_opening_hours.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_working_hours_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'partial hours, full days off, unknown hours, zoom and timeline gutter',
    (tester) async {
      final hours = PlanningOpeningHours({
        for (var day = 1; day <= 7; day++)
          day: day == 5
              ? []
              : [OpeningPeriod(540, 720), OpeningPeriod(840, 1080)],
      });
      Future<void> show(
        DateTime date,
        PlanningOpeningHours? hours,
        double zoom,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 300,
                height: 840 * zoom,
                child: PlanningWorkingHoursBackground(
                  date: date,
                  hours: hours,
                  heightPerMinute: zoom,
                  leadingWidth: 65,
                ),
              ),
            ),
          ),
        );
      }

      List<Positioned> bands() => tester
          .widgetList<Positioned>(
            find.descendant(
              of: find.byType(PlanningWorkingHoursBackground),
              matching: find.byType(Positioned),
            ),
          )
          .toList();
      for (final zoom in [1.0, 2.5]) {
        await show(DateTime(2026, 10, 14), hours, zoom);
        expect(bands().map((b) => b.top), [0, 300 * zoom, 660 * zoom]);
        expect(bands().map((b) => b.height), [
          120 * zoom,
          120 * zoom,
          180 * zoom,
        ]);
        expect(bands().every((b) => b.left == 65), isTrue);
      }
      await show(DateTime(2026, 10, 16), hours, 1);
      expect(bands().single.top, 0);
      expect(bands().single.height, 840);
      await show(DateTime(2026, 10, 16), null, 1);
      expect(bands(), isEmpty);
      await show(
        DateTime(2026, 10, 16),
        PlanningOpeningHours({
          for (var day = 1; day <= 7; day++) day: [OpeningPeriod(420, 1260)],
        }),
        1,
      );
      expect(bands(), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
