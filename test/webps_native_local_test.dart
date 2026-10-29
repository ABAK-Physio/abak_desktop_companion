import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_webps/webps_native_local.dart';
import 'package:abak_desktop_companion/features/dmp_webps/webps_native_screen.dart';

void main() {
  test('Reject malformed bridge configuration without connecting', () async {
    final c = LocalBrowserControl();
    for (final value in ['{}', '{"port":80,"token":"bad"}']) {
      await expectLater(c.connect(value), throwsA(isA<FormatException>()));
    }
    expect(c.busy, true);
    expect(c.connected, false);
    c.dispose();
  });
  testWidgets('Real isolated Chrome via ABAK controller and screen', (
    tester,
  ) async {
    if (Platform.environment['ABAK_RUN_LOCAL_BROWSER_TEST'] != '1') return;
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = LocalBrowserControl();
    final overrides = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = overrides);
    Process? service;
    Directory? root;
    await tester.runAsync(() async {
      root = await Directory.systemTemp.createTemp('abak-webps-integration-');
      service = await Process.start(
        '/opt/homebrew/bin/node',
        ['tool/webps_local/service.cjs'],
        environment: {'ABAK_WEBPS_TEST_ROOT': root!.path},
      );
      service!.stdout.transform(utf8.decoder).listen((_) {});
      service!.stderr.transform(utf8.decoder).listen(debugPrint);
      final file = File('${root!.path}/Connexion_ABAK_locale.json');
      for (var i = 0; i < 100 && !await file.exists(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      await c.connect(await file.readAsString());
    });
    try {
      expect(c.connected, true);
      expect(c.busy, false);
      await tester.pumpWidget(
        MaterialApp(home: LocalBrowserScreen(control: c)),
      );
      OutlinedButton button(String id) =>
          tester.widget<OutlinedButton>(find.byKey(ValueKey(id)));
      for (final target in ['native-dashboard', 'native-patient']) {
        expect(button(target).onPressed, isNotNull);
        await tester.runAsync(() async {
          await c.open(target == 'native-patient');
        });
        await tester.pump();
        expect(c.message, contains('Fenêtre locale ouverte'));
        expect(c.busy, true);
        expect(button('native-dashboard').onPressed, isNull);
        expect(button('native-patient').onPressed, isNull);
        final before = c.target;
        await tester.runAsync(() async {
          await c.open(target != 'native-patient');
        });
        expect(c.target, before);
        // Navigation away/back retains the shared controller state.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          MaterialApp(home: LocalBrowserScreen(control: c)),
        );
        expect(button('native-dashboard').onPressed, isNull);
        // A second ABAK controller reconnects, like a restart: lock still observed.
        await tester.runAsync(() async {
          final other = LocalBrowserControl();
          await other.connect(
            await File(
              '${root!.path}/Connexion_ABAK_locale.json',
            ).readAsString(),
          );
          expect(other.busy, true);
          expect(other.target, before);
          other.dispose();
          await c.close();
        });
        await tester.pump();
        expect(c.busy, false);
        expect(button('native-dashboard').onPressed, isNotNull);
      }
      await tester.runAsync(() async {
        service!.kill(ProcessSignal.sigterm);
        await service!.exitCode;
        await c.open(false);
        expect(c.busy, true);
        expect(c.message, contains('non confirmé'));
      });
      await tester.pump();
      expect(button('native-dashboard').onPressed, isNull);
    } finally {
      await tester.pumpWidget(const SizedBox());
      c.dispose();
      service?.kill(ProcessSignal.sigterm);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
