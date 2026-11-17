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
  var selected = 'com.microsoft.edge';
  var active = false, openFails = false, closeFails = false;
  setUp(() {
    selected = 'com.microsoft.edge';
    active = false;
    openFails = false;
    closeFails = false;
    calls = [];
    context.setEnabled(true);
    context.select('899700870597');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'open') {
            if (openFails) throw PlatformException(code: 'OPEN_FAILED');
            active = true;
          }
          if (call.method == 'close') {
            if (closeFails) throw PlatformException(code: 'CLOSE_FAILED');
            active = false;
          }
          return {
            'active': active,
            'opening': false,
            'browserPath':
                r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
          };
        });
    service = WebPsBrowserService(
      isWindows: true,
      readBrowser: () async => selected,
    );
  });
  tearDown(() async {
    closeFails = false;
    await service.close();
    service.dispose();
    context.setEnabled(false);
    await CpsOperationLease.closeIdle();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  Future<void> open({bool confirmed = true}) => service.open(
    WebPsTarget.dashboard,
    confirmed: confirmed,
    checkContext: context.bind(context.activeProfessional),
  );

  test('Edge is an explicit Windows choice and is rejected on Mac', () {
    expect(
      WebPsBrowserService.supportsBrowser('com.microsoft.edge', windows: true),
      isTrue,
    );
    expect(
      WebPsBrowserService.supportsBrowser('com.microsoft.edge', windows: false),
      isFalse,
    );
    expect(
      WebPsBrowserService.supportsBrowser(
        'org.mozilla.firefox',
        windows: false,
      ),
      isTrue,
    );
    expect(
      WebPsBrowserService.supportsBrowser('unknown', windows: true),
      isFalse,
    );
  });
  test(
    'selected Edge opens the exact dashboard only after confirmation',
    () async {
      await open(confirmed: false);
      expect(calls, isEmpty);
      await open();
      final call = calls.singleWhere((c) => c.method == 'open');
      expect(call.arguments['browser'], 'com.microsoft.edge');
      expect(
        call.arguments['url'],
        'https://wps-cps.dev1.dmp.gouv.fr/AccesDirect/TableauDeBord',
      );
      expect(service.message, contains('Microsoft Edge lancé'));
      expect(service.message, contains('L’authentification reste à confirmer'));
      expect(service.browserPath, endsWith('msedge.exe'));
    },
  );
  test('unsupported choice never falls back to Edge or Firefox', () async {
    selected = 'unknown';
    await open();
    expect(calls.where((c) => c.method == 'open'), isEmpty);
    CpsOperationLease.acquire().release();
  });
  test('Edge is closed on practitioner context lock', () async {
    await open();
    context.lock();
    await CpsOperationLease.closeIdle();
    expect(service.active, isFalse);
    expect(active, isFalse);
    CpsOperationLease.acquire().release();
  });
  test(
    'failed Edge launch and confirmed idle status release the reservation',
    () async {
      openFails = true;
      await open();
      expect(service.active, isFalse);
      CpsOperationLease.acquire().release();
    },
  );
  test(
    'uncertain Edge closure retains the CPS reservation until recovery',
    () async {
      await open();
      closeFails = true;
      await expectLater(
        CpsOperationLease.acquireAvailable(),
        throwsA(isA<PlatformException>()),
      );
      expect(() => CpsOperationLease.acquire(), throwsStateError);
      closeFails = false;
      await service.close();
      CpsOperationLease.acquire().release();
    },
  );
}
