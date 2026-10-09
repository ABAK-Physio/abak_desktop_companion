import 'package:abak_desktop_companion/features/practitioners/models/practitioner.dart';
import 'dart:async';
import 'package:abak_desktop_companion/features/planning/prototype/planning_calendar_adapter.dart';

import 'package:abak_desktop_companion/main_planning.dart';
import 'package:abak_desktop_companion/features/planning/data/planning_repository.dart';
import 'package:abak_desktop_companion/features/planning/models/planning_appointment.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_event_drag.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _Repository extends PlanningRepository {
  _Repository() : super(database: () => throw UnimplementedError());
  final rows = <String, PlanningAppointment>{};
  bool failLoad = false;
  bool failWrite = false;
  Completer<void>? pending;
  @override
  Future<List<Practitioner>> getPlanningPractitioners() async => [
    const Practitioner(
      practitionerId: 'a',
      displayName: 'Alice',
      isActive: true,
      createdAt: 1,
    ),
  ];
  @override
  Future<List<PlanningAppointment>> listForPractitioner(String id) async {
    if (failLoad) throw StateError('load');
    return rows.values.toList();
  }

  Future<void> write() async {
    await pending?.future;
    if (failWrite) throw StateError('write');
  }

  @override
  Future<void> insert(PlanningAppointment item) async {
    await write();
    if (rows.containsKey(item.id)) throw StateError('duplicate');
    rows[item.id] = item;
  }

  @override
  Future<void> update(PlanningAppointment item) async {
    await write();
    if (!rows.containsKey(item.id)) throw StateError('missing');
    rows[item.id] = item;
  }

  @override
  Future<void> delete(String id) async {
    await write();
    rows.remove(id);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
    PackageStrings.setLocale('fr');
  });
  Future<void> open(WidgetTester tester, _Repository repo) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(PlanningPrototypeApp(repository: repo));
    await tester.pumpAndSettle();
  }

  EventController<Object?> controller(WidgetTester tester) => tester
      .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
      .controller!;

  testWidgets(
    'empty DB, create, edit, delete, undo and reload preserve identity',
    (tester) async {
      final repo = _Repository();
      await open(tester, repo);
      expect(controller(tester).allEvents, isEmpty);
      await tester.tap(find.text('Nouveau rendez-vous'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Persistant');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      final id = repo.rows.keys.single;
      expect(controller(tester).allEvents.single.event, id);
      await tester.tap(find.text('Persistant').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Modifié');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(repo.rows.keys.single, id);
      expect(repo.rows[id]!.title, 'Modifié');
      expect(repo.rows[id]!.practitionerId, 'a');
      await tester.tap(find.text('Modifié').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      expect(repo.rows, isEmpty);
      expect(controller(tester).allEvents, isEmpty);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(repo.rows.keys.single, id);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(PlanningPrototypeApp(repository: repo));
      await tester.pumpAndSettle();
      expect(controller(tester).allEvents.single.title, 'Modifié');
      expect(controller(tester).allEvents.single.event, id);
    },
  );

  testWidgets(
    'load failure blocks writes; write failure keeps form and original',
    (tester) async {
      final repo = _Repository()..failLoad = true;
      await open(tester, repo);
      expect(
        find.text('Impossible de charger les rendez-vous.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Nouveau rendez-vous'),
            )
            .onPressed,
        isNull,
      );
      repo.failLoad = false;
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      repo.failWrite = true;
      await tester.tap(find.text('Nouveau rendez-vous'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'À garder');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('À garder'), findsOneWidget);
      expect(repo.rows, isEmpty);
      expect(controller(tester).allEvents, isEmpty);
      repo.failWrite = false;
      repo.pending = Completer<void>();
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      expect(controller(tester).allEvents, isEmpty);
      expect(find.text('Enregistrement…'), findsOneWidget);
      repo.pending!.complete();
      await tester.pumpAndSettle();
      expect(controller(tester).allEvents.single.title, 'À garder');
    },
  );

  testWidgets(
    'drag callback persists only after success and failed undo can retry',
    (tester) async {
      final repo = _Repository();
      final day = DateUtils.dateOnly(DateTime.now());
      repo.rows['stable'] = PlanningAppointment(
        id: 'stable',
        title: 'Déplacer',
        date: day,
        startMinute: 540,
        endMinute: 585,
      );
      await open(tester, repo);
      final initial = controller(tester).allEvents.single;
      final updated = initial.copyWith(
        startTime: DateTime(day.year, day.month, day.day, 10),
        endTime: DateTime(day.year, day.month, day.day, 11),
      );
      repo.failWrite = true;
      tester
          .widget<PlanningEventDrag>(find.byType(PlanningEventDrag).first)
          .onChanged(updated);
      await tester.pumpAndSettle();
      expect(controller(tester).allEvents.single, initial);
      expect(repo.rows['stable']!.startMinute, 540);
      repo.failWrite = false;
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      expect(repo.rows['stable']!.startMinute, 600);
      expect(repo.rows['stable']!.endMinute, 660);
      expect(controller(tester).allEvents.single.event, 'stable');
      await tester.tap(find.text('Déplacer').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      repo.failWrite = true;
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(repo.rows, isEmpty);
      expect(controller(tester).allEvents, isEmpty);
      repo.failWrite = false;
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      expect(repo.rows['stable']!.startMinute, 600);
      expect(controller(tester).allEvents.single.event, 'stable');
    },
  );
  testWidgets('linked patient survives screen move, resize, delete and undo', (
    tester,
  ) async {
    final repo = _Repository();
    final day = DateUtils.dateOnly(DateTime.now());
    repo.rows['linked'] = PlanningAppointment(
      id: 'linked',
      title: 'Consultation',
      date: day,
      startMinute: 540,
      endMinute: 585,
      patientId: 'p1',
      patientLabel: 'Dupont Marie',
    );
    await open(tester, repo);
    var event = controller(tester).allEvents.single;
    tester
        .widget<PlanningEventDrag>(find.byType(PlanningEventDrag).first)
        .onChanged(
          event.copyWith(
            startTime: DateTime(day.year, day.month, day.day, 10),
            endTime: DateTime(day.year, day.month, day.day, 11),
          ),
        );
    await tester.pumpAndSettle();
    expect(repo.rows['linked']!.patientId, 'p1');
    expect(repo.rows['linked']!.endMinute, 660);
    event = controller(tester).allEvents.single;
    expect(planningEventId(event.event), 'linked');
    await tester.tap(find.text('Consultation · Dupont Marie').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Patient : Dupont Marie'), findsOneWidget);
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    expect(repo.rows, isEmpty);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(repo.rows['linked']!.patientId, 'p1');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(PlanningPrototypeApp(repository: repo));
    await tester.pumpAndSettle();
    expect(
      (controller(tester).allEvents.single.event as PlanningPatientLink)
          .patientId,
      'p1',
    );
  });
}
