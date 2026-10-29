import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/practitioners/models/practitioner.dart';
import 'package:abak_desktop_companion/features/practitioners/data/practitioner_repository.dart';
import 'package:abak_desktop_companion/features/practitioners/widgets/practitioner_form_dialog.dart';
import 'package:abak_desktop_companion/features/planning/models/planning_opening_hours.dart';
import 'package:abak_desktop_companion/features/planning/data/planning_opening_hours_repository.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
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
  final repository = PractitionerRepository();
  PlanningOpeningHours week() => PlanningOpeningHours({
    for (var day = 1; day <= 7; day++)
      day: day <= 5 ? [OpeningPeriod(480, 720), OpeningPeriod(840, 1080)] : [],
  });
  Practitioner practitioner({
    PlanningOpeningHours? hours,
    int step = 15,
    int duration = 45,
  }) => Practitioner(
    appointmentStepMinutes: step,
    appointmentDurationMinutes: duration,
    practitionerId: 'p1',
    displayName: 'Kiné test',
    isActive: false,
    createdAt: 123,
    workingHours: hours,
  );
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('practitioner_hours_');
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(temp.path);
    await DatabaseService.database;
  });
  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    await temp.delete(recursive: true);
  });

  test(
    'v37 duration migration defaults to 45 and preserves step and saved duration after restart',
    () async {
      final db = await DatabaseService.database;
      await db.execute(
        'ALTER TABLE practitioners DROP COLUMN appointment_duration_minutes',
      );
      await db.insert('practitioners', {
        'practitioner_id': 'p1',
        'display_name': 'Kiné',
        'created_at': 1,
        'appointment_step_minutes': 20,
      });
      await db.setVersion(37);
      await DatabaseService.reopenDatabase();
      final migrated = (await repository.getPractitionerById('p1'))!;
      expect(migrated.appointmentDurationMinutes, 45);
      expect(migrated.appointmentStepMinutes, 20);
      for (final duration in [20, 30]) {
        await repository.updatePractitioner(
          practitioner(step: 15, duration: duration),
        );
        await DatabaseService.reopenDatabase();
        final loaded = (await repository.getPractitionerById('p1'))!;
        expect(loaded.appointmentDurationMinutes, duration);
        expect(loaded.appointmentStepMinutes, 15);
      }
      await expectLater(
        (await DatabaseService.database).update('practitioners', {
          'appointment_duration_minutes': 0,
        }),
        throwsA(isA<DatabaseException>()),
      );
    },
  );

  test(
    'v36 step migration defaults to 15 and persists independent practitioner choices',
    () async {
      final db = await DatabaseService.database;
      await db.execute(
        'ALTER TABLE practitioners DROP COLUMN appointment_step_minutes',
      );
      await db.insert('practitioners', {
        'practitioner_id': 'p1',
        'display_name': 'Kiné',
        'created_at': 1,
      });
      await db.setVersion(36);
      await DatabaseService.reopenDatabase();
      expect(
        (await repository.getPractitionerById('p1'))!.appointmentStepMinutes,
        15,
      );
      for (final step in [20, 30, 15]) {
        await repository.updatePractitioner(practitioner(step: step));
        await DatabaseService.reopenDatabase();
        expect(
          (await repository.getPractitionerById('p1'))!.appointmentStepMinutes,
          step,
        );
      }
      await expectLater(
        (await DatabaseService.database).update('practitioners', {
          'appointment_step_minutes': 10,
        }),
        throwsA(isA<DatabaseException>()),
      );
    },
  );

  test(
    'v34 migration defaults to inheritance, personal hours persist and archive safely',
    () async {
      final db = await DatabaseService.database;
      await db.execute(
        'ALTER TABLE practitioners DROP COLUMN working_hours_json',
      );
      await db.setVersion(34);
      await db.insert('practitioners', {
        'practitioner_id': 'p1',
        'display_name': 'Kiné test',
        'created_at': 123,
        'is_active': 0,
      });
      await DatabaseService.reopenDatabase();
      var loaded = (await repository.getPractitionerById('p1'))!;
      expect(loaded.workingHours, isNull);
      expect(loaded.isActive, isFalse);
      expect(loaded.createdAt, 123);
      final personal = PlanningOpeningHours({
        ...week().days,
        3: [OpeningPeriod(480, 720)],
        5: [],
      });
      await repository.updatePractitioner(practitioner(hours: personal));
      await DatabaseService.reopenDatabase();
      loaded = (await repository.getPractitionerById('p1'))!;
      expect(loaded.workingHours!.encode(), personal.encode());
      await repository.archivePractitioner('p1');
      await repository.restorePractitioner('p1');
      expect(
        (await repository.getPractitionerById('p1'))!.workingHours!.encode(),
        personal.encode(),
      );
      await repository.updatePractitioner(
        practitioner(
          hours: PlanningOpeningHours({for (var d = 1; d <= 7; d++) d: []}),
        ),
      );
      expect(
        (await repository.getPractitionerById('p1'))!.workingHours,
        isNotNull,
      );
      await repository.updatePractitioner(practitioner());
      expect(
        (await repository.getPractitionerById('p1'))!.workingHours,
        isNull,
      );
    },
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
    }
    await tester.pumpAndSettle();
  }

  for (final mode in ['cancel', 'save', 'inherit']) {
    final cancel = mode == 'cancel';
    testWidgets('individual schedule draft: $mode', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 700);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final initial = practitioner(hours: week());
      await tester.runAsync(() => repository.insertPractitioner(initial));
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr', 'FR'),
          supportedLocales: const [Locale('fr', 'FR')],
          localizationsDelegates: const [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('Fiche'),
                onPressed: () async {
                  final result = await showDialog<Practitioner>(
                    context: context,
                    builder: (_) =>
                        PractitionerFormDialog(initialPractitioner: initial),
                  );
                  if (result != null) {
                    await repository.updatePractitioner(result);
                  }
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Fiche'));
      await settle(tester);
      final stepField = find.byKey(
        const ValueKey('practitioner-appointment-step'),
      );
      await tester.ensureVisible(stepField);
      await tester.tap(stepField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('20 minutes').last);
      await tester.pumpAndSettle();
      final durationField = find.byKey(
        const ValueKey('practitioner-appointment-duration'),
      );
      await tester.ensureVisible(durationField);
      await tester.enterText(durationField, '30');
      await tester.ensureVisible(
        find.text('Modifier les horaires individuels'),
      );
      await tester.tap(find.text('Modifier les horaires individuels'));
      await settle(tester);
      // Wednesday afternoon is the sixth interval in the weekly editor.
      final remove = find.byTooltip('Retirer cette plage').at(5);
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      final friday = find.byKey(const ValueKey('opening-day-4'));
      await tester.ensureVisible(friday);
      await tester.tap(friday);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Appliquer à la fiche'));
      await tester.pumpAndSettle();
      final before = await tester.runAsync(
        () => repository.getPractitionerById('p1'),
      );
      expect(before!.workingHours!.encode(), week().encode());
      expect(find.textContaining('Vendredi : non travaillé'), findsOneWidget);
      if (mode == 'inherit') {
        await tester.ensureVisible(find.byType(SwitchListTile));
        await tester.tap(find.byType(SwitchListTile));
        await tester.pumpAndSettle();
      }
      await tester.tap(
        find.text(cancel ? 'Annuler' : S.current.practitionerNew_save).last,
      );
      await settle(tester);
      final stored = await tester.runAsync(
        () => repository.getPractitionerById('p1'),
      );
      if (mode == 'inherit') {
        expect(stored!.workingHours, isNull);
      } else {
        expect(stored!.workingHours!.days[3]!.length, cancel ? 2 : 1);
        expect(stored.workingHours!.days[5]!.length, cancel ? 2 : 0);
      }
      expect(stored.isActive, isFalse);
      expect(stored.appointmentStepMinutes, cancel ? 15 : 20);
      expect(stored.appointmentDurationMinutes, cancel ? 45 : 30);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await settle(tester);
    });
  }

  test(
    'cabinet changes do not overwrite individual hours or inherited null',
    () async {
      final cabinet = PlanningOpeningHoursRepository(
        database: () => DatabaseService.database,
      );
      await cabinet.save(week());
      await repository.insertPractitioner(practitioner());
      await cabinet.save(
        PlanningOpeningHours({for (var d = 1; d <= 7; d++) d: []}),
      );
      expect(
        (await repository.getPractitionerById('p1'))!.workingHours,
        isNull,
      );
      await repository.updatePractitioner(practitioner(hours: week()));
      expect(
        (await repository.getPractitionerById('p1'))!.workingHours!.encode(),
        week().encode(),
      );
      expect((await cabinet.load())!.days[1], isEmpty);
    },
  );
}
