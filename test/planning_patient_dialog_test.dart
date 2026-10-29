import 'package:abak_desktop_companion/features/patients/models/patient.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_event_dialog.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_calendar_adapter.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));
  const patients = [
    Patient(
      patientId: 'p1',
      lastName: 'Dupont',
      firstName: 'Marie',
      birthDate: '1980-01-01',
      sexCode: 'U',
      createdAt: 1,
    ),
    Patient(
      patientId: 'p2',
      lastName: 'Dupont',
      firstName: 'Marie',
      birthDate: '1990-02-02',
      sexCode: 'U',
      createdAt: 1,
    ),
  ];

  testWidgets('select homonym, change, clear and cancel patient association', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 650);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    CalendarEventData<Object?>? saved;
    var fail = true;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr', 'FR'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('fr', 'FR')],
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              child: const Text('Ouvrir'),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => PlanningEventDialog(
                  date: DateTime(2026, 10, 9, 9),
                  event: CalendarEventData<Object?>(
                    date: DateTime(2026, 10, 9),
                    title: 'Séance',
                    event: 'stable',
                  ),
                  searchPatients: (query) async {
                    if (fail) throw StateError('offline');
                    return query == 'absent' ? [] : patients;
                  },
                  onSave: (event) async {
                    saved = event;
                    return true;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Associer un patient'));
    await tester.pumpAndSettle();
    expect(find.text('Impossible de charger les patients.'), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Dupont Marie'), findsNWidgets(2));
    await tester.enterText(
      find.widgetWithText(TextField, 'Rechercher un patient'),
      'absent',
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Aucun patient trouvé.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Rechercher un patient'),
      'Dupont',
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Né(e) le 02/02/1990'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect((saved!.event as PlanningPatientLink).patientId, 'p2');
    expect(planningEventId(saved!.event), 'stable');
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Associer un patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Né(e) le 01/01/1980'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Changer de patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler').last);
    await tester.pumpAndSettle();
    expect(find.text('Patient : Dupont Marie'), findsOneWidget);
    await tester.tap(find.text('Retirer le patient'));
    await tester.pumpAndSettle();
    expect(find.text('Sans patient'), findsOneWidget);
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(saved!.event, 'stable');
    expect(tester.takeException(), isNull);
  });
}
