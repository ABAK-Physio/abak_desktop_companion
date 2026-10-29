import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/simulated_lot_store.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/transfer_simulation.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/transfer_screen.dart';
import 'dmp_transfer_test.dart' show FakeService;

void main() {
  late Directory sandbox;
  late SimulatedLotStore store;
  setUp(() {
    sandbox = Directory.systemTemp.createTempSync('abak-lots-isolated-');
    store = SimulatedLotStore(sandbox);
  });
  tearDown(() => sandbox.deleteSync(recursive: true));
  for (final outcome in DepositOutcome.values) {
    test('Restart preserves $outcome and blocks same lot', () async {
      final first = TransferSimulation(
        FakeService()..outcome = outcome,
        store: store,
        lotId: 'simulation-lot',
      );
      await first.start();
      first.dispose();
      final service = FakeService();
      final restored = TransferSimulation(
        service,
        store: SimulatedLotStore(Directory(sandbox.path)),
        lotId: 'simulation-lot',
      );
      expect(restored.canStart, false);
      expect(restored.message, contains('État conservé'));
      await restored.start();
      expect(service.connections, 0);
      expect(service.deposits, 0);
      expect(store.read('simulation-lot'), outcome.name);
      restored.dispose();
    });
  }
  test('Two controllers: one durable claim, one deposit', () async {
    final a = FakeService()..pendingDeposit = Completer<DepositOutcome>();
    final b = FakeService();
    final first = TransferSimulation(a, store: store, lotId: 'simulation-race');
    final second = TransferSimulation(
      b,
      store: SimulatedLotStore(sandbox),
      lotId: 'simulation-race',
    );
    final waiting = first.start();
    await Future<void>.delayed(Duration.zero);
    await second.start();
    expect(a.deposits, 1);
    expect(b.deposits, 0);
    expect(second.phase, TransferPhase.indeterminate);
    a.pendingDeposit!.complete(DepositOutcome.accepted);
    await waiting;
    first.dispose();
    second.dispose();
  });
  test('Close during deposit retains result when it arrives', () async {
    final service = FakeService()..pendingDeposit = Completer<DepositOutcome>();
    final flow = TransferSimulation(
      service,
      store: store,
      lotId: 'simulation-close',
    );
    final waiting = flow.start();
    await Future<void>.delayed(Duration.zero);
    flow.dispose();
    expect(store.read('simulation-close'), 'indeterminate');
    service.pendingDeposit!.complete(DepositOutcome.accepted);
    await waiting;
    expect(store.read('simulation-close'), 'accepted');
  });
  test('Unreadable receipt fails closed without calling service', () async {
    store.begin('simulation-corrupt');
    File(
      '${store.directory.path}/simulation-corrupt.result.json',
    ).writeAsStringSync('{broken');
    final service = FakeService();
    final flow = TransferSimulation(
      service,
      store: store,
      lotId: 'simulation-corrupt',
    );
    await flow.start();
    expect(service.connections, 0);
    expect(flow.canStart, false);
    expect(flow.message, contains('illisible'));
    flow.dispose();
  });
  test('Storage write failure blocks before deposit', () async {
    File(store.directory.path).writeAsStringSync('not a directory');
    final service = FakeService();
    final flow = TransferSimulation(
      service,
      store: store,
      lotId: 'simulation-storage',
    );
    await flow.start();
    expect(service.deposits, 0);
    expect(flow.canStart, false);
    flow.dispose();
  });
  test('TLS failure is persisted without attempted-deposit marker', () async {
    final flow = TransferSimulation(
      FakeService()..failure = TlsFailure.trust,
      store: store,
      lotId: 'simulation-tls',
    );
    await flow.start();
    flow.dispose();
    expect(store.read('simulation-tls'), 'tlsFailed');
    expect(
      File('${store.directory.path}/simulation-tls.attempt').existsSync(),
      false,
    );
  });
  test('New corrected lot never unlocks old rejected lot', () async {
    store.begin('simulation-old');
    store.finish('simulation-old', 'metadataRejected');
    expect(store.begin('simulation-new'), true);
    expect(store.begin('simulation-old'), false);
    expect(store.read('simulation-old'), 'metadataRejected');
    expect(() => store.begin('../real-lot'), throwsArgumentError);
  });
  test('Fresh OS processes recover interruption then accepted state', () async {
    const dart =
        '/Users/jeanclaudebrucher/development/flutter/bin/cache/dart-sdk/bin/dart';
    Future<String> run(String mode, [String? state]) async {
      final r = await Process.run(dart, [
        'test/support/lot_store_process.dart',
        sandbox.path,
        mode,
        ?state,
      ]);
      expect(r.exitCode, 0, reason: r.stderr.toString());
      return r.stdout.toString().trim();
    }

    expect(await run('attempt'), 'true');
    expect(await run('read'), 'indeterminate\nfalse');
    await run('finish', 'accepted');
    expect(await run('read'), 'accepted\nfalse');
  });
  test('Concurrent processes reserve only one attempt', () async {
    const dart =
        '/Users/jeanclaudebrucher/development/flutter/bin/cache/dart-sdk/bin/dart';
    final runs = await Future.wait(
      List.generate(
        2,
        (_) => Process.run(dart, [
          'test/support/lot_store_process.dart',
          sandbox.path,
          'attempt',
        ]),
      ),
    );
    for (final run in runs) {
      expect(run.exitCode, 0, reason: run.stderr.toString());
    }
    expect(runs.map((r) => r.stdout.toString().trim()).toList()..sort(), [
      'false',
      'true',
    ]);
  });
  test(
    'Empty claim after interruption blocks; orphan receipt blocks too',
    () async {
      store.directory.createSync(recursive: true);
      File('${store.directory.path}/simulation-empty.attempt').createSync();
      expect(store.read('simulation-empty'), 'indeterminate');
      expect(store.begin('simulation-empty'), false);
      File(
        '${store.directory.path}/simulation-orphan.result.json',
      ).writeAsStringSync('{}');
      final service = FakeService();
      final flow = TransferSimulation(
        service,
        store: store,
        lotId: 'simulation-orphan',
      );
      await flow.start();
      expect(service.connections, 0);
      expect(flow.canStart, false);
      flow.dispose();
    },
  );
  test(
    'Failed receipt write preserves claim and blocks after restart',
    () async {
      final service = FakeService()
        ..pendingDeposit = Completer<DepositOutcome>();
      final flow = TransferSimulation(
        service,
        store: store,
        lotId: 'simulation-write',
      );
      final pending = flow.start();
      await Future<void>.delayed(Duration.zero);
      Directory(
        '${store.directory.path}/simulation-write.result.json',
      ).createSync();
      service.pendingDeposit!.complete(DepositOutcome.accepted);
      await pending;
      expect(flow.canStart, false);
      flow.dispose();
      final nextService = FakeService();
      final next = TransferSimulation(
        nextService,
        store: SimulatedLotStore(sandbox),
        lotId: 'simulation-write',
      );
      await next.start();
      expect(nextService.deposits, 0);
      expect(next.canStart, false);
      next.dispose();
    },
  );
  testWidgets('Reopen screen preserves accepted lot and disables start', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var calls = 0;
    Widget screen() => MaterialApp(
      home: TransferScreen(
        store: SimulatedLotStore(sandbox),
        serviceFactory: (_) {
          calls++;
          return FakeService();
        },
      ),
    );
    await tester.pumpWidget(screen());
    tester
        .widget<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>),
        )
        .onChanged!('accepted');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('start')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(screen());
    tester
        .widget<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>),
        )
        .onChanged!('accepted');
    await tester.pump();
    expect(
      find.textContaining('État conservé après réouverture'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('start')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('resend')))
          .onPressed,
      isNull,
    );
    expect(calls, 2); // Factories only; no action on re-opening.
  });
}
