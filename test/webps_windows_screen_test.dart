import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/cps/cps_operation_lease.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'package:abak_desktop_companion/features/dmp_webps/webps_browser_service.dart';
import 'package:abak_desktop_companion/features/dmp_webps/webps_dv1_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('abak/webps_browser');
  final context = DmpWorkContext.current;
  late WebPsBrowserService service;
  late List<MethodCall> calls;
  var active = false;
  setUp(() {
    active = false;
    calls = [];
    context.setEnabled(true);
    context.select('899700870597');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'open') active = true;
          if (call.method == 'close') active = false;
          return {
            'active': active,
            'opening': false,
            'browserPath':
                r'C:\Program Files (x86)\Mozilla Firefox\firefox.exe',
          };
        });
    service = WebPsBrowserService(
      readBrowser: () async => 'org.mozilla.firefox',
    );
  });
  tearDown(() async {
    await service.close();
    service.dispose();
    context.setEnabled(false);
    await CpsOperationLease.closeIdle();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  Future<void> screen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(home: WebPsDv1Screen(control: service)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Cas1 preparation and cancellation never open Firefox', (
    tester,
  ) async {
    await screen(tester);
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Préparer le Cas1 — sans connexion'),
    );
    await tester.pumpAndSettle();
    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].controller!.text, 'GIRODET DE ROUSSY-COEUR ANNE-LOUIS');
    expect(fields[1].controller!.text, '287019143596041');
    expect(calls.where((c) => c.method == 'open'), isEmpty);
    final confirmation = find.byType(CheckboxListTile);
    await tester.ensureVisible(confirmation);
    await tester.tap(confirmation);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('dv1-patient')));
    await tester.tap(find.byKey(const ValueKey('dv1-patient')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
        '/AccesDirect/DossierPatient/287019143596041/1.2.250.1.213.1.4.10',
      ),
      findsOneWidget,
    );
    expect(calls.where((c) => c.method == 'open'), isEmpty);
    await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
    await tester.pumpAndSettle();
    expect(calls.where((c) => c.method == 'open'), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('dashboard confirmation exposes the URL and owned browser path', (
    tester,
  ) async {
    try {
      await screen(tester);
      await tester.tap(find.byKey(const ValueKey('dv1-dashboard')));
      await tester.pumpAndSettle();
      expect(calls.where((c) => c.method == 'open'), isEmpty);
      await tester.tap(find.byKey(const ValueKey('dv1-confirm')));
      await tester.pumpAndSettle();
      final open = calls.singleWhere((c) => c.method == 'open');
      expect(
        open.arguments['url'],
        'https://wps-cps.dev1.dmp.gouv.fr/AccesDirect/TableauDeBord',
      );
      expect(service.lastUrl, open.arguments['url']);
      expect(service.browserPath, contains('Program Files (x86)'));
      expect(service.message, contains('L’authentification reste à confirmer'));
    } finally {
      // Flutter checks pending timers before the outer tearDown runs.
      // Close the owned service while this widget test is still executing.
      await service.close();
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
