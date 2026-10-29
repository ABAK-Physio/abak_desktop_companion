import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/cps/cps_operation_lease.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'package:abak_desktop_companion/features/dmp_webps/webps_browser_service.dart';
import 'package:abak_desktop_companion/features/dmp_webps/webps_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('abak/webps_browser');
  final context = DmpWorkContext.current;
  late WebPsBrowserService service;
  late List<MethodCall> calls;
  bool active = false, closeFails = false, openFails = false;
  String browser = 'org.mozilla.firefox';
  Completer<void>? opening;
  setUp(() {
    active = false;
    closeFails = false;
    openFails = false;
    opening = null;
    browser = 'org.mozilla.firefox';
    calls = [];
    context.setEnabled(true);
    context.select('899700854237');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'open':
              if (openFails) {
                throw PlatformException(code: 'NOT_INSTALLED');
              }
              active = true;
              await opening?.future;
              return {'active': active, 'opening': false};
            case 'status':
              return {'active': active, 'opening': false};
            case 'close':
              if (closeFails) {
                throw PlatformException(code: 'CLOSE_UNCONFIRMED');
              }
              active = false;
              return {'active': false, 'opening': false};
          }
          throw StateError('Unexpected method');
        });
    service = WebPsBrowserService(
      channel: channel,
      context: context,
      readBrowser: () async => browser,
    );
  });
  tearDown(() async {
    closeFails = false;
    if (opening != null && !opening!.isCompleted) opening!.complete();
    await service.close();
    service.dispose();
    context.setEnabled(false);
    await CpsOperationLease.closeIdle();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  Future<void> launch({bool confirmed = true, WebPsPatient? patient}) =>
      service.open(
        patient == null ? WebPsTarget.dashboard : WebPsTarget.patient,
        patient: patient,
        confirmed: confirmed,
        checkContext: context.bind(context.activeProfessional),
      );
  test(
    'No launch without explicit confirmation; no implicit browser fallback',
    () async {
      await launch(confirmed: false);
      expect(calls, isEmpty);
      browser = 'com.apple.Safari';
      await launch();
      expect(calls, isEmpty);
      expect(service.message, contains('Firefox'));
    },
  );
  test(
    'Patient URL is contextual; second access blocked until closure',
    () async {
      await launch(
        patient: const WebPsPatient(
          'SYNTHETIC',
          '187012425258307',
          '1.2.250.1.213.1.4.10',
        ),
      );
      expect(calls.single.method, 'open');
      expect(
        calls.single.arguments['url'],
        endsWith('/187012425258307/1.2.250.1.213.1.4.10'),
      );
      await launch();
      expect(calls.where((c) => c.method == 'open'), hasLength(1));
      await service.close();
      await launch();
      expect(calls.where((c) => c.method == 'open'), hasLength(2));
    },
  );
  test('Invalid patient does not acquire card or open browser', () async {
    await launch(
      patient: const WebPsPatient('SYNTHETIC', '123', '1.2.250.1.213.1.4.10'),
    );
    expect(calls, isEmpty);
    final lease = CpsOperationLease.acquire();
    lease.release();
  });
  test('Context change after confirmation invalidates operation', () async {
    final check = context.bind(context.activeProfessional);
    context.select('899700870597');
    await service.open(
      WebPsTarget.dashboard,
      confirmed: true,
      checkContext: check,
    );
    expect(calls, isEmpty);
  });
  test('Lock closes owned browser and releases card', () async {
    await launch();
    context.lock();
    await CpsOperationLease.closeIdle();
    expect(active, false);
    expect(service.active, false);
    final lease = CpsOperationLease.acquire();
    lease.release();
  });
  test(
    'Lock during launch never leaves an authenticated browser reusable',
    () async {
      opening = Completer<void>();
      final run = launch();
      while (!active) {
        await Future<void>.delayed(Duration.zero);
      }
      context.lock();
      await CpsOperationLease.closeIdle();
      opening!.complete();
      await run;
      expect(active, false);
      expect(service.active, false);
    },
  );
  test(
    'Unconfirmed close blocks other CPS operations until explicit recovery',
    () async {
      await launch();
      closeFails = true;
      await expectLater(
        CpsOperationLease.acquireAvailable(),
        throwsA(isA<PlatformException>()),
      );
      expect(() => CpsOperationLease.acquire(), throwsStateError);
      closeFails = false;
      await service.close();
      final lease = CpsOperationLease.acquire();
      lease.release();
    },
  );
  test(
    'Rejected launch with native idle status does not trap ownership',
    () async {
      openFails = true;
      await launch();
      expect(service.active, false);
      final lease = CpsOperationLease.acquire();
      lease.release();
    },
  );
  test('Confirmed external termination releases card reservation', () async {
    await launch();
    active = false;
    await service.refresh();
    expect(service.active, false);
    final lease = CpsOperationLease.acquire();
    lease.release();
  });
}
