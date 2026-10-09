import 'package:abak_desktop_companion/features/planning/prototype/planning_slot_detector.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_event_drag.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_working_hours_background.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_event_dialog.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_month_cell.dart';
import 'package:abak_desktop_companion/main_planning.dart';
import 'package:abak_desktop_companion/features/planning/data/planning_repository.dart';
import 'package:abak_desktop_companion/features/planning/models/planning_appointment.dart';
import 'package:abak_desktop_companion/features/planning/models/planning_opening_hours.dart';
import 'package:abak_desktop_companion/features/practitioners/models/practitioner.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_practitioner_selector.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const alice = Practitioner(
  practitionerId: 'a',
  displayName: 'Alice Martin',
  isActive: true,
  createdAt: 1,
);
const bob = Practitioner(
  practitionerId: 'b',
  appointmentStepMinutes: 30,
  appointmentDurationMinutes: 30,
  displayName: 'Bob Dupont',
  isActive: true,
  createdAt: 1,
);

class _Repository extends PlanningRepository {
  _Repository() : super(database: () => throw UnimplementedError());
  List<Practitioner> practitioners = [alice, bob];
  final cabinetHours = PlanningOpeningHours({
    for (var day = 1; day <= 7; day++) day: [OpeningPeriod(540, 1080)],
  });
  @override
  Future<List<Practitioner>> getPlanningPractitioners() async => practitioners;
  @override
  Future<PlanningOpeningHours?> loadOpeningHours() async => cabinetHours;
  @override
  Future<List<PlanningAppointment>> listForPractitioner(String id) async {
    final now = DateTime.now();
    return [
      PlanningAppointment(
        id: 'rv-$id',
        practitionerId: id,
        title: 'RV $id',
        date: DateTime(now.year, now.month, now.day),
        startMinute: 540,
        endMinute: 570,
      ),
    ];
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
    PackageStrings.setLocale('fr');
  });
  testWidgets('month follows custom hours, defaults and refreshed practitioner', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = _Repository();
    final custom = PlanningOpeningHours({
      for (var day = 1; day <= 7; day++)
        day: day == 5 ? [] : [OpeningPeriod(540, day == 3 ? 720 : 1020)],
    });
    repo.practitioners = [
      Practitioner(
        practitionerId: 'a',
        displayName: 'Alice Martin',
        isActive: true,
        createdAt: 1,
        workingHours: custom,
        appointmentStepMinutes: 20,
        appointmentDurationMinutes: 20,
      ),
      bob,
    ];
    await tester.pumpWidget(PlanningPrototypeApp(repository: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mois'));
    await tester.pumpAndSettle();
    PlanningMonthCell cell() => tester
        .widgetList<PlanningMonthCell>(find.byType(PlanningMonthCell))
        .first;
    expect(cell().hours, isNull);
    Future<void> select(String name) async {
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
    }

    await select('Alice Martin');
    expect(cell().hours, same(custom));
    expect(cell().individualHours, isTrue);
    expect(find.text('Repos'), findsWidgets);
    for (final view in ['Semaine', 'Jour']) {
      await tester.tap(find.text(view));
      await tester.pumpAndSettle();
      final backgrounds = tester.widgetList<PlanningWorkingHoursBackground>(
        find.byType(PlanningWorkingHoursBackground),
      );
      expect(backgrounds, isNotEmpty);
      expect(backgrounds.every((b) => identical(b.hours, custom)), isTrue);
      expect(
        backgrounds.every((b) => b.leadingWidth == (view == 'Jour' ? 65 : 0)),
        isTrue,
      );
      expect(
        tester
            .widgetList<PlanningSlotDetector>(find.byType(PlanningSlotDetector))
            .every((d) => d.stepMinutes == 20),
        isTrue,
      );
      expect(
        tester
            .widgetList<PlanningEventDrag>(find.byType(PlanningEventDrag))
            .every((d) => d.stepMinutes == 20),
        isTrue,
      );
      final background = find.byType(PlanningWorkingHoursBackground).first;
      // 07:15 lies outside the 09:00 opening; creating an exception must remain possible.
      await tester.tapAt(
        tester.getTopLeft(background) + Offset(view == 'Jour' ? 90 : 30, 20),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PlanningEventDialog), findsOneWidget);
      expect(
        tester
            .widget<PlanningEventDialog>(find.byType(PlanningEventDialog))
            .defaultDurationMinutes,
        20,
      );
      await tester.tap(find.text('Annuler').last);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Mois'));
    await tester.pumpAndSettle();
    await select('Bob Dupont');
    expect(cell().hours, same(repo.cabinetHours));
    expect(cell().individualHours, isFalse);
    await tester.tap(find.text('Semaine'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<PlanningSlotDetector>(find.byType(PlanningSlotDetector))
          .every((d) => d.stepMinutes == 30),
      isTrue,
    );
    expect(
      tester
          .widgetList<PlanningEventDrag>(find.byType(PlanningEventDrag))
          .every((d) => d.stepMinutes == 30),
      isTrue,
    );
    await tester.tap(find.text('Mois'));
    await tester.pumpAndSettle();
    await select('Alice Martin');
    final empty = PlanningOpeningHours({
      for (var day = 1; day <= 7; day++) day: [],
    });
    repo.practitioners = [
      Practitioner(
        practitionerId: 'a',
        displayName: 'Alice Martin',
        isActive: true,
        createdAt: 1,
        workingHours: empty,
      ),
      bob,
    ];
    await tester.tap(find.byTooltip('Recharger les praticiens'));
    await tester.pumpAndSettle();
    expect(cell().hours, same(empty));
    repo.practitioners = [alice, bob];
    await tester.tap(find.byTooltip('Recharger les praticiens'));
    await tester.pumpAndSettle();
    expect(cell().hours, same(repo.cabinetHours));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selection filters appointments in all views', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(PlanningPrototypeApp(repository: _Repository()));
    await tester.pumpAndSettle();
    final controller = tester
        .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
        .controller!;
    expect(controller.allEvents, isEmpty);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bob Dupont').last);
    await tester.pumpAndSettle();
    expect(find.text('Planning — Bob Dupont'), findsOneWidget);
    for (final view in ['Jour', 'Mois', 'Semaine']) {
      await tester.tap(find.text(view));
      await tester.pumpAndSettle();
      expect(find.text('Planning — Bob Dupont'), findsOneWidget);
      expect(controller.allEvents.single.title, 'RV b');
    }
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alice Martin').last);
    await tester.pumpAndSettle();
    expect(controller.allEvents.single.title, 'RV a');
    tester.view.physicalSize = const Size(900, 650);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'single practitioner default, reload rename, archive and load error',
    (tester) async {
      var items = [alice];
      var failed = false;
      Practitioner? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: PlanningPractitionerSelector(
                load: () async {
                  if (failed) throw StateError('read');
                  return items;
                },
                onChanged: (value) => selected = value,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(selected?.practitionerId, 'a');
      failed = true;
      await tester.tap(find.byTooltip('Recharger les praticiens'));
      await tester.pumpAndSettle();
      expect(find.text('Praticiens indisponibles.'), findsOneWidget);
      failed = false;
      items = [];
      await tester.tap(find.byTooltip('Recharger les praticiens'));
      await tester.pumpAndSettle();
      expect(selected, isNull);
      expect(find.textContaining('Aucun praticien actif'), findsOneWidget);
      items = [alice, bob];
      await tester.tap(find.byTooltip('Recharger les praticiens'));
      await tester.pumpAndSettle();
      expect(selected, isNull);
      expect(tester.takeException(), isNull);
    },
  );
  test('planning lists only active, nonarchived practitioners', () async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await db.execute(
      'CREATE TABLE practitioners (practitioner_id TEXT, display_name TEXT, is_active INTEGER, archived_at INTEGER, created_at INTEGER)',
    );
    for (final row in [
      {
        'practitioner_id': 'a',
        'display_name': 'Alice',
        'is_active': 1,
        'archived_at': null,
        'created_at': 1,
      },
      {
        'practitioner_id': 'b',
        'display_name': 'Bob',
        'is_active': 0,
        'archived_at': null,
        'created_at': 1,
      },
      {
        'practitioner_id': 'c',
        'display_name': 'Charlie',
        'is_active': 1,
        'archived_at': 1,
        'created_at': 1,
      },
    ]) {
      await db.insert('practitioners', row);
    }
    final result = await PlanningRepository(
      database: () async => db,
    ).getPlanningPractitioners();
    expect(result.map((p) => p.practitionerId), ['a']);
  });
}
