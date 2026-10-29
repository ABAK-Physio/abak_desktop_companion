import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_webps/webps_local.dart';
import 'package:abak_desktop_companion/features/dmp_webps/webps_screen.dart';

const sylvain = WebPsPatient(
  'SYLVAIN BONNEL',
  '187012425258307',
  '1.2.250.1.213.1.4.10',
);
const jean = WebPsPatient(
  'JEAN CONTESTE',
  '153078987658513',
  '1.2.250.1.213.1.4.10',
);

class BrowserDouble implements WebPsBrowserSimulation {
  final calls = <Uri>[];
  Completer<SimulatedWebPsWindow>? pending;
  bool fail = false;
  @override
  Future<SimulatedWebPsWindow> open(Uri uri, String name) async {
    expect(name, 'ABAK_DMP_WEBPS');
    calls.add(uri);
    if (fail) throw StateError('uncertain');
    return pending == null ? SimulatedWebPsWindow() : pending!.future;
  }
}

void main() {
  test('Exact two CPx routes; dashboard ignores patient; no extra fields', () {
    expect(
      WebPsUrl.build(WebPsUrl.dv1, WebPsTarget.dashboard).toString(),
      'https://wps-cps.dev1.dmp.gouv.fr/AccesDirect/TableauDeBord',
    );
    expect(
      WebPsUrl.build(
        '${WebPsUrl.dv1}/',
        WebPsTarget.patient,
        patient: sylvain,
      ).toString(),
      'https://wps-cps.dev1.dmp.gouv.fr/AccesDirect/DossierPatient/187012425258307/1.2.250.1.213.1.4.10',
    );
    expect(
      WebPsUrl.build(
        WebPsUrl.dv1,
        WebPsTarget.dashboard,
        patient: sylvain,
      ).path,
      '/AccesDirect/TableauDeBord',
    );
  });
  test('Reject unsafe bases before any browser call', () async {
    final browser = BrowserDouble();
    final c = WebPsCoordinator(browser);
    for (final base in [
      'http://wps-cps.dev1.dmp.gouv.fr',
      'https://wps-cps.dmp.monespacesante.fr',
      'https://wps-cps.dev1.dmp.gouv.fr.evil.test',
      'https://user@wps-cps.dev1.dmp.gouv.fr',
      '${WebPsUrl.dv1}?INS=123',
      '${WebPsUrl.dv1}#secret',
      '${WebPsUrl.dv1}/other',
      '${WebPsUrl.dv1}:8443',
    ]) {
      await expectLater(
        c.open(base, WebPsTarget.dashboard, null),
        throwsFormatException,
      );
    }
    expect(browser.calls, isEmpty);
    expect(c.busy, false);
    c.dispose();
  });
  test('Patient absent, NIA, bad OID, invalid format and key rejected', () {
    for (final p in <WebPsPatient?>[
      null,
      const WebPsPatient('NIA', '109076322088835', '1.2.250.1.213.1.4.9'),
      const WebPsPatient('wrong', '187012425258307', 'wrong'),
      const WebPsPatient('bad', '187012425258308', '1.2.250.1.213.1.4.10'),
      const WebPsPatient('bad', '../123', '1.2.250.1.213.1.4.10'),
      const WebPsPatient('', '187012425258307', '1.2.250.1.213.1.4.10'),
    ]) {
      expect(
        () => WebPsUrl.build(WebPsUrl.dv1, WebPsTarget.patient, patient: p),
        throwsFormatException,
      );
      expect(
        WebPsUrl.build(
          WebPsUrl.dv1,
          WebPsTarget.dashboard,
          patient: p,
        ).hasQuery,
        false,
      );
    }
  });
  test(
    'Double open blocked while pending, then while window open; context immutable',
    () async {
      final b = BrowserDouble()..pending = Completer<SimulatedWebPsWindow>();
      final c = WebPsCoordinator(b);
      final opening = c.open(WebPsUrl.dv1, WebPsTarget.patient, sylvain);
      expect(await c.open(WebPsUrl.dv1, WebPsTarget.patient, jean), false);
      expect(c.activePatient, sylvain);
      expect(b.calls.length, 1);
      b.pending!.complete(SimulatedWebPsWindow());
      await opening;
      expect(await c.open(WebPsUrl.dv1, WebPsTarget.dashboard, null), false);
      expect(c.activePatient, sylvain);
      c.close();
      await Future<void>.delayed(Duration.zero);
      b.pending = null;
      expect(await c.open(WebPsUrl.dv1, WebPsTarget.patient, jean), true);
      expect(c.activePatient, jean);
      expect(b.calls.length, 2);
      c.close();
      await Future<void>.delayed(Duration.zero);
      c.dispose();
    },
  );
  test('Uncertain opener remains blocked without retry', () async {
    final b = BrowserDouble()..fail = true;
    final c = WebPsCoordinator(b);
    expect(await c.open(WebPsUrl.dv1, WebPsTarget.dashboard, null), false);
    expect(c.busy, true);
    expect(c.canClose, false);
    expect(await c.open(WebPsUrl.dv1, WebPsTarget.dashboard, null), false);
    expect(b.calls.length, 1);
    expect(c.message, contains('non confirmée'));
    c.dispose();
  });
  testWidgets('Both buttons, patient locking, back/reopen and close release', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final browser = BrowserDouble();
    final c = WebPsCoordinator(browser);
    Widget screen() => MaterialApp(home: WebPsScreen(coordinator: c));
    await tester.pumpWidget(screen());
    OutlinedButton button(WebPsTarget t) =>
        tester.widget<OutlinedButton>(find.byKey(ValueKey(t)));
    expect(button(WebPsTarget.dashboard).onPressed, isNotNull);
    expect(button(WebPsTarget.patient).onPressed, isNull);
    final select = tester
        .widget<DropdownButtonFormField<String>>(
          find.byKey(const ValueKey('webps-patient')),
        )
        .onChanged!;
    select('nia');
    await tester.pump();
    expect(button(WebPsTarget.patient).onPressed, isNull);
    expect(button(WebPsTarget.dashboard).onPressed, isNotNull);
    select('invalid');
    await tester.pump();
    expect(find.text('Clé du NIR invalide.'), findsOneWidget);
    select('sylvain');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey(WebPsTarget.patient)));
    await tester.pumpAndSettle();
    for (final t in WebPsTarget.values) {
      expect(button(t).onPressed, isNull);
    }
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byKey(const ValueKey('webps-patient')),
          )
          .onChanged,
      isNull,
    );
    select('jean');
    await tester.pump();
    expect(c.activePatient!.ins, sylvain.ins);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('webps-base')))
          .enabled,
      false,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(screen());
    expect(button(WebPsTarget.dashboard).onPressed, isNull);
    expect(c.activePatient!.ins, sylvain.ins);
    expect(browser.calls.length, 1);
    await tester.tap(find.byKey(const ValueKey('webps-close')));
    await tester.pumpAndSettle();
    expect(button(WebPsTarget.dashboard).onPressed, isNotNull);
    await tester.tap(find.byKey(const ValueKey(WebPsTarget.dashboard)));
    await tester.pumpAndSettle();
    expect(browser.calls.length, 2);
    expect(c.activePatient, isNull);
    expect(c.activeUrl!.path, '/AccesDirect/TableauDeBord');
    await tester.tap(find.byKey(const ValueKey('webps-close')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('webps-base')),
      'https://production.invalid',
    );
    await tester.pump();
    for (final t in WebPsTarget.values) {
      expect(button(t).onPressed, isNull);
    }
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });
}
