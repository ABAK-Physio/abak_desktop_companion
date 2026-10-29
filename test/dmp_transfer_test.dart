import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_transfer/simulated_lot_store.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/transfer_screen.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/transfer_simulation.dart';

class FakeService implements TransferSimulationService {
  TlsFailure? failure;
  DepositOutcome outcome = DepositOutcome.accepted;
  bool throwConnect = false, throwDeposit = false;
  Completer<TlsFailure?>? pendingConnect;
  Completer<DepositOutcome>? pendingDeposit;
  int connections = 0, deposits = 0;
  @override
  Future<TlsFailure?> connect() async {
    connections++;
    if (throwConnect) throw StateError('synthetic');
    return pendingConnect == null ? failure : pendingConnect!.future;
  }

  @override
  Future<DepositOutcome> deposit() async {
    deposits++;
    if (throwDeposit) throw StateError('synthetic');
    return pendingDeposit == null ? outcome : pendingDeposit!.future;
  }
}

void main() {
  for (final error in TlsFailure.values) {
    test(
      'TLS ${error.name}: no deposit, no automatic retry, no correction',
      () async {
        final service = FakeService()..failure = error;
        final flow = TransferSimulation(service);
        await flow.start();
        await flow.start();
        expect(flow.phase, TransferPhase.tlsFailed);
        expect(flow.message, contains(error.message));
        expect(flow.message, contains('Aucune requête DMP envoyée'));
        expect(service.connections, 1);
        expect(service.deposits, 0);
        expect(flow.prepareCorrection(), isNull);
        expect(flow.checkResult(), isNull);
        expect(flow.canSendNetworkRequest, false);
        flow.dispose();
      },
    );
  }
  test(
    'exception before and after sending preserves different uncertainty',
    () async {
      final early = TransferSimulation(FakeService()..throwConnect = true);
      await early.start();
      expect(early.phase, TransferPhase.tlsFailed);
      expect(early.message, contains('Aucune requête DMP envoyée'));
      final late = TransferSimulation(FakeService()..throwDeposit = true);
      await late.start();
      expect(late.phase, TransferPhase.indeterminate);
      expect(late.message, isNot(contains('Aucune requête DMP envoyée')));
      expect(late.message, contains('peut-être été reçu'));
      expect(late.prepareCorrection(), isNull);
      late.checkResult();
      expect(late.phase, TransferPhase.indeterminate);
      early.dispose();
      late.dispose();
    },
  );
  test('double start and disposal while connecting cannot send', () async {
    final s = FakeService()..pendingConnect = Completer<TlsFailure?>();
    final f = TransferSimulation(s);
    final first = f.start();
    await f.start();
    expect(s.connections, 1);
    expect(f.busy, true);
    f.dispose();
    s.pendingConnect!.complete(null);
    await first;
    expect(s.deposits, 0);
  });
  test(
    'pending deposit blocks duplicate calls and all followup actions',
    () async {
      final s = FakeService()..pendingDeposit = Completer<DepositOutcome>();
      final f = TransferSimulation(s);
      final pending = f.start();
      await Future<void>.delayed(Duration.zero);
      expect(f.phase, TransferPhase.sending);
      await f.start();
      expect(s.deposits, 1);
      expect(f.prepareCorrection(), isNull);
      expect(f.checkResult(), isNull);
      s.pendingDeposit!.complete(DepositOutcome.indeterminate);
      await pending;
      expect(f.canStart, false);
      f.dispose();
    },
  );
  for (final entry in TransferScreen.scenarios.entries.where(
    (e) => !e.key.startsWith('archive-'),
  )) {
    testWidgets('Screen ${entry.key}: message and guarded actions', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = FakeService();
      final sandbox = Directory.systemTemp.createTempSync(
        'abak-transfer-widget-',
      );
      addTearDown(() => sandbox.deleteSync(recursive: true));
      if (entry.key.startsWith('tls-')) {
        service.failure = TlsFailure.values.byName(entry.key.substring(4));
      } else {
        service.outcome = DepositOutcome.values.byName(entry.key);
      }
      await tester.pumpWidget(
        MaterialApp(
          home: TransferScreen(
            serviceFactory: (_) => service,
            store: SimulatedLotStore(sandbox),
          ),
        ),
      );
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .onChanged!(entry.key);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('start')));
      await tester.pumpAndSettle();
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
      final correction = tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('correct')))
          .onPressed;
      final check = tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('check')))
          .onPressed;
      final rejected = entry.key.endsWith('Rejected');
      expect(correction != null, rejected);
      expect(check != null, entry.key == 'indeterminate');
      if (service.failure != null) {
        expect(find.textContaining(service.failure!.message), findsWidgets);
        expect(service.deposits, 0);
      } else {
        expect(service.deposits, 1);
        final text = switch (service.outcome) {
          DepositOutcome.accepted => 'Dépôt accepté (simulation)',
          DepositOutcome.signatureRejected => 'Code : DMPInvalidSignature',
          DepositOutcome.metadataRejected => 'Code : XDSRegistryMetadataError',
          DepositOutcome.indeterminate => 'Le document a peut-être été reçu',
          DepositOutcome.rejected => 'Document refusé : erreur XDS',
        };
        expect(find.textContaining(text), findsOneWidget);
      }
      if (correction != null) {
        correction();
        await tester.pump();
        expect(find.textContaining('aucun document créé'), findsOneWidget);
      }
      if (check != null) {
        check();
        await tester.pump();
        expect(
          find.textContaining('résultat toujours indéterminé'),
          findsOneWidget,
        );
      }
      await tester.pump(const Duration(seconds: 5));
      expect(service.connections, 1);
      // A new independent fixture must not retain the previous outcome/actions.
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .onChanged!('tls-trust');
      await tester.pump();
      expect(find.textContaining('aucun document créé'), findsNothing);
      expect(
        find.textContaining('résultat toujours indéterminé'),
        findsNothing,
      );
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('correct')))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('check')))
            .onPressed,
        isNull,
      );
    });
  }
}
