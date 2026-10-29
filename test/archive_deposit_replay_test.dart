import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/archive_deposit_reader.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/transfer_screen.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/transfer_simulation.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/simulated_lot_store.dart';

const path = 'assets/dmp_local/deposit_replay';

class FileBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}

void main() {
  for (final pair in {
    'signature': DepositOutcome.signatureRejected,
    'metadata': DepositOutcome.metadataRejected,
    'accepted': DepositOutcome.accepted,
    'truncated': DepositOutcome.indeterminate,
    'uncorrelated': DepositOutcome.indeterminate,
  }.entries) {
    test(
      'Archive ${pair.key}: real bytes -> result -> durable diagnostic -> blocked restart',
      () async {
        final dir = Directory.systemTemp.createTempSync('abak-replay-');
        addTearDown(() => dir.deleteSync(recursive: true));
        final store = SimulatedLotStore(dir);
        final service = ArchiveReplayService(pair.key, bundle: FileBundle());
        final flow = TransferSimulation(
          service,
          store: store,
          lotId: 'simulation-archive-${pair.key}',
        );
        await flow.start();
        expect(store.read(flow.lotId), pair.value.name);
        expect(flow.detail, isNotEmpty);
        if (pair.key == 'metadata') {
          expect(flow.detail, contains('SubmissionSet01'));
          expect(flow.detail, contains('DocumentME2'));
          expect(flow.detail, contains('authorSpecialty'));
        }
        final detail = flow.detail;
        flow.dispose();
        final restored = TransferSimulation(
          ArchiveReplayService('NONEXISTENT', bundle: FileBundle()),
          store: SimulatedLotStore(dir),
          lotId: 'simulation-archive-${pair.key}',
        );
        expect(restored.detail, detail);
        expect(restored.canStart, false);
        await restored.start();
        expect(restored.detail, detail);
        restored.dispose();
      },
    );
  }
  test('Archived results and diagnostics survive a new OS process', () async {
    final dir = Directory.systemTemp.createTempSync('abak-archive-process-');
    addTearDown(() => dir.deleteSync(recursive: true));
    for (final name in ['signature', 'metadata', 'accepted', 'truncated']) {
      final id = 'simulation-archive-$name';
      final flow = TransferSimulation(
        ArchiveReplayService(name, bundle: FileBundle()),
        store: SimulatedLotStore(dir),
        lotId: id,
      );
      await flow.start();
      final process = await Process.run(
        '/Users/jeanclaudebrucher/development/flutter/bin/cache/dart-sdk/bin/dart',
        ['test/support/replay_store_process.dart', dir.path, id],
      );
      expect(process.exitCode, 0, reason: process.stderr.toString());
      final result = jsonDecode(process.stdout.toString()) as Map;
      expect(result['state'], SimulatedLotStore(dir).read(id));
      expect(result['detail'], flow.detail);
      expect(result['canReserve'], false);
      flow.dispose();
    }
  });
  final request = File('$path/accepted-request.xml').readAsStringSync();
  final headers = File('$path/accepted-headers.txt').readAsStringSync();
  final bytes = File('$path/accepted-response.bin').readAsBytesSync();
  final xml = ArchiveDepositReader.extract(headers, bytes);
  final variants = <String, ({String h, List<int> b, String q})>{
    'HTTP503 Success': (
      h: 'HTTP/1.1 503 Unavailable',
      b: utf8.encode(xml),
      q: request,
    ),
    'redirect': (h: 'HTTP/1.1 302 Found', b: bytes, q: request),
    'bad XML': (h: 'HTTP/1.1 200 OK', b: utf8.encode('<bad'), q: request),
    'missing root': (
      h: headers.replaceAll('root.message@cxf.apache.org', 'missing'),
      b: bytes,
      q: request,
    ),
    'bad action': (
      h: 'HTTP/1.1 200 OK',
      b: utf8.encode(xml.replaceAll(ArchiveDepositReader.action, 'urn:wrong')),
      q: request,
    ),
    'unknown state': (
      h: 'HTTP/1.1 200 OK',
      b: utf8.encode(
        xml.replaceAll(
          'ResponseStatusType:Success',
          'ResponseStatusType:Unknown',
        ),
      ),
      q: request,
    ),
    'wrong namespace': (
      h: 'HTTP/1.1 200 OK',
      b: utf8.encode(xml.replaceAll(ArchiveDepositReader.rs, 'urn:wrong')),
      q: request,
    ),
  };
  for (final entry in variants.entries) {
    test('Unsafe ${entry.key} cannot become success or rejection', () {
      final r = ArchiveDepositReader.read(
        request: entry.value.q,
        headers: entry.value.h,
        bytes: entry.value.b,
      );
      expect(r.outcome, DepositOutcome.indeterminate);
      expect(r.detail, isNotEmpty);
    });
  }
  test('Unknown XDS rejection retains code and remains rejection', () {
    final text = ArchiveDepositReader.extract(
      File('$path/signature-headers.txt').readAsStringSync(),
      File('$path/signature-response.bin').readAsBytesSync(),
    ).replaceAll('DMPInvalidSignature', 'UNKNOWN_XDS_ERROR');
    final r = ArchiveDepositReader.read(
      request: File('$path/signature-request.xml').readAsStringSync(),
      headers: 'HTTP/1.1 200 OK',
      bytes: utf8.encode(text),
    );
    expect(r.outcome, DepositOutcome.rejected);
    expect(r.detail, contains('UNKNOWN_XDS_ERROR'));
  });
  for (final key in [
    'signature',
    'metadata',
    'accepted',
    'truncated',
    'uncorrelated',
  ]) {
    testWidgets('Archive $key: UI, storage and reopening in isolation', (
      tester,
    ) async {
      rootBundle.clear();
      final dir = Directory.systemTemp.createTempSync('abak-replay-ui-');
      addTearDown(() => dir.deleteSync(recursive: true));
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Widget screen() =>
          MaterialApp(home: TransferScreen(store: SimulatedLotStore(dir)));
      Future<void> select() async {
        tester
            .widget<DropdownButtonFormField<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .onChanged!('archive-$key');
        await tester.pump();
      }

      await tester.pumpWidget(screen());
      await select();
      await tester.tap(find.byKey(const ValueKey('start')));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('RELECTURE HISTORIQUE HORS RÉSEAU'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('start')))
            .onPressed,
        isNull,
      );
      final detail = tester
          .widget<SelectableText>(find.byType(SelectableText))
          .data!;
      expect(detail, contains('Relecture historique hors réseau'));
      expect(
        tester
                .widget<OutlinedButton>(find.byKey(const ValueKey('correct')))
                .onPressed !=
            null,
        ['signature', 'metadata'].contains(key),
      );
      expect(
        tester
                .widget<OutlinedButton>(find.byKey(const ValueKey('check')))
                .onPressed !=
            null,
        ['truncated', 'uncorrelated'].contains(key),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(screen());
      await select();
      expect(
        find.textContaining('État conservé après réouverture'),
        findsOneWidget,
      );
      expect(
        tester.widget<SelectableText>(find.byType(SelectableText)).data,
        detail,
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
      // The ordinary simulation namespace remains empty.
      expect(SimulatedLotStore(dir).directory.existsSync(), false);
    });
  }
}
