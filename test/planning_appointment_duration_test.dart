import 'package:abak_desktop_companion/features/planning/prototype/planning_event_dialog.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));
  final start = find.byKey(const ValueKey('planning-start'));
  final end = find.byKey(const ValueKey('planning-end'));
  String value(WidgetTester tester, Finder field) =>
      tester.widget<TextFormField>(field).controller!.text;
  for (final duration in [20, 30]) {
    testWidgets(
      'new appointment uses $duration minutes and retains manually adjusted duration',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PlanningEventDialog(
              date: DateTime(2026, 10, 14, 9),
              defaultDurationMinutes: duration,
            ),
          ),
        );
        expect(value(tester, end), duration == 20 ? '09:20' : '09:30');
        await tester.enterText(start, '10:00');
        expect(value(tester, end), duration == 20 ? '10:20' : '10:30');
        await tester.enterText(start, '1');
        expect(value(tester, end), duration == 20 ? '10:20' : '10:30');
        await tester.enterText(start, '10:00');
        await tester.enterText(end, '11:00');
        await tester.enterText(start, '12:00');
        expect(value(tester, end), '13:00');
      },
    );
  }
  testWidgets(
    'editing existing RV preserves duration instead of replacing with practitioner default',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlanningEventDialog(
            date: DateTime(2026, 10, 14),
            defaultDurationMinutes: 20,
            event: CalendarEventData<Object?>(
              date: DateTime(2026, 10, 14),
              title: 'Long RV',
              startTime: DateTime(2026, 10, 14, 9),
              endTime: DateTime(2026, 10, 14, 10, 15),
            ),
          ),
        ),
      );
      expect(value(tester, end), '10:15');
      await tester.enterText(start, '11:00');
      expect(value(tester, end), '12:15');
    },
  );
  testWidgets('closing boundary never silently shortens usual duration', (
    tester,
  ) async {
    var saved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PlanningEventDialog(
          date: DateTime(2026, 10, 14, 20, 50),
          defaultDurationMinutes: 30,
          onSave: (_) async {
            saved = true;
            return false;
          },
        ),
      ),
    );
    expect(value(tester, start), '20:50');
    expect(value(tester, end), '21:20');
    await tester.enterText(find.byType(TextFormField).first, 'RV');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(saved, isFalse);
    expect(find.text('Entre 07:00 et 21:00.'), findsOneWidget);
    await tester.enterText(end, '21:00');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(saved, isTrue);
  });
}
