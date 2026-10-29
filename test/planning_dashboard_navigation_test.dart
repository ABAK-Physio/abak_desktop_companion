import 'dart:io';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/dashboard/home_dashboard_screen.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_prototype_screen.dart';
import 'package:abak_desktop_companion/features/planning/data/planning_repository.dart';
import 'package:abak_desktop_companion/features/planning/models/planning_appointment.dart';
import 'package:abak_desktop_companion/features/practitioners/practitioner_list_screen.dart';
import 'package:abak_desktop_companion/features/external_correspondents/screens/external_correspondents_screen.dart';
import 'package:abak_desktop_companion/features/devices/device_list_screen.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:calendar_view/calendar_view.dart';
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
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('dashboard_planning_');
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(temp.path);
    await (await DatabaseService.database).insert('practitioners', {
      'practitioner_id': 'a',
      'display_name': 'Alice',
      'is_active': 1,
      'created_at': 1,
    });
    final day = DateTime.now();
    await PlanningRepository(database: () => DatabaseService.database).insert(
      PlanningAppointment(
        practitionerId: 'a',
        id: 'existing',
        title: 'RV existant',
        date: DateTime(day.year, day.month, day.day),
        startMinute: 540,
        endMinute: 570,
      ),
    );
  });
  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    await temp.delete(recursive: true);
  });
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
    }
    await tester.pump();
  }

  testWidgets(
    'Planning sits after practitioners, loads SQLite and preserves adjacent destinations',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr', 'FR'),
          supportedLocales: const [Locale('fr', 'FR')],
          localizationsDelegates: const [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: HomeDashboardScreen(onLocaleChanged: () {}),
        ),
      );
      await settle(tester);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(
        (rail.destinations[2].label as Text).data,
        S.current.home_practitioners,
      );
      expect((rail.destinations[3].label as Text).data, 'Planning');
      expect(
        (rail.destinations[4].label as Text).data,
        S.current.home_correspondents,
      );
      Future<void> choose(String label) async {
        await tester.tap(
          find
              .descendant(
                of: find.byType(NavigationRail),
                matching: find.text(label),
              )
              .last,
        );
        await settle(tester);
      }

      await choose('Planning');
      expect(find.byType(PlanningPrototypeScreen), findsOneWidget);
      expect(
        tester
            .widget<WeekView<Object?>>(find.byType(WeekView<Object?>))
            .controller!
            .allEvents
            .single
            .title,
        'RV existant',
      );
      await choose(S.current.home_practitioners);
      expect(find.byType(PractitionerListScreen), findsOneWidget);
      await choose(S.current.home_correspondents);
      expect(find.byType(ExternalCorrespondentsScreen), findsOneWidget);
      await choose(S.current.home_devices);
      expect(find.byType(DeviceListScreen), findsOneWidget);
      await choose('Planning');
      tester.view.physicalSize = const Size(900, 650);
      await settle(tester);
      expect(find.byType(PlanningPrototypeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await settle(tester);
    },
  );
}
