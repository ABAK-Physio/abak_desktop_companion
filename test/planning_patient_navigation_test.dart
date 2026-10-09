import 'dart:io';

import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/planning/data/planning_repository.dart';
import 'package:abak_desktop_companion/features/planning/models/planning_appointment.dart';
import 'package:abak_desktop_companion/features/patients/patient_detail_screen.dart';
import 'package:abak_desktop_companion/main_planning.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late PathProviderPlatform previous;
  late PlanningRepository repository;
  setUp(() async {
    await initializeDateFormatting('fr_FR');
    PackageStrings.setLocale('fr');
    temp = await Directory.systemTemp.createTemp(
      'planning_patient_navigation_',
    );
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(temp.path);
    final db = await DatabaseService.database;
    await db.insert('patients', {
      'patient_id': 'patient',
      'last_name': 'Martin',
      'first_name': 'Alice',
      'birth_date': '1980-01-01',
      'created_at': 1,
      'archived_at': 1,
    });
    repository = PlanningRepository(database: () => DatabaseService.database);
    await (await DatabaseService.database).insert('practitioners', {
      'practitioner_id': 'a',
      'display_name': 'Alice',
      'is_active': 1,
      'created_at': 1,
    });
    final now = DateTime.now();
    await repository.insert(
      PlanningAppointment(
        practitionerId: 'a',
        id: 'rv',
        title: 'Consultation',
        date: DateTime(now.year, now.month, now.day),
        startMinute: 540,
        endMinute: 585,
        patientId: 'patient',
      ),
    );
  });
  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    await temp.delete(recursive: true);
  });

  Future<void> settle(WidgetTester tester) async {
    // Route animations start new database futures in later frames.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
    }
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );
  }

  for (final deleted in [false, true]) {
    testWidgets(
      deleted
          ? 'deleted patient is handled without opening a stale dossier'
          : 'opens actual archived patient dossier and returns to selected day',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(PlanningPrototypeApp(repository: repository));
        await settle(tester);
        await tester.tap(find.text('Jour'));
        await tester.pumpAndSettle();
        final period = tester
            .widget<Text>(find.byKey(const ValueKey('planning-period')))
            .data;
        await tester.tap(find.textContaining('Consultation ·').first);
        await tester.pumpAndSettle();
        if (deleted) {
          await tester.runAsync(() async {
            final db = await DatabaseService.database;
            await db.delete(
              'patients',
              where: 'patient_id = ?',
              whereArgs: ['patient'],
            );
          });
        }
        await tester.tap(find.text('Ouvrir le dossier patient'));
        await settle(tester);
        if (deleted) {
          expect(find.byType(PatientDetailScreen), findsNothing);
          expect(
            find.text('Ce dossier patient n’est plus disponible.'),
            findsOneWidget,
          );
          await tester.tap(find.text('Consultation').first);
          await tester.pumpAndSettle();
          expect(find.text('Ouvrir le dossier patient'), findsNothing);
        } else {
          final screen = tester.widget<PatientDetailScreen>(
            find.byType(PatientDetailScreen),
          );
          expect(screen.patient.patientId, 'patient');
          expect(screen.patient.isArchived, isTrue);
          expect(find.text('MARTIN Alice'), findsWidgets);
          await tester.tap(find.byType(BackButton));
          await settle(tester);
          expect(find.byType(DayView<Object?>), findsOneWidget);
          expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('planning-period')))
                .data,
            period,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await settle(tester);
      },
    );
  }
}
