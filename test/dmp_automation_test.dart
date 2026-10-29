import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_automation/automation_scenarios.dart';
import 'package:abak_desktop_companion/features/dmp_automation/automation_cases.dart';
import 'package:abak_desktop_companion/features/dmp_automation/automation_model.dart';
import 'package:abak_desktop_companion/features/dmp_automation/automation_engine.dart';
import 'package:abak_desktop_companion/features/dmp_automation/automation_store.dart';

class NoNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      throw StateError('Réseau interdit');
}

void main() {
  late Directory root;
  setUp(() {
    root = Directory.systemTemp.createTempSync('abak-automation-test-');
    HttpOverrides.global = NoNetwork();
  });
  tearDown(() {
    HttpOverrides.global = null;
    root.deleteSync(recursive: true);
  });
  for (var n = 1; n <= 42; n++) {
    test(
      '${automationCases[n - 1]['id']} ${automationCases[n - 1]['titre']}',
      () async {
        final r = await runAutomationScenario(n, root);
        expect(r['statut'], 'REUSSI_LOCALEMENT');
      },
    );
  }
  test('fermer avant réservation ne déclenche aucun dépôt', () async {
    final gate = Completer<void>();
    final service = AutoFakeService(connectionGate: gate.future);
    final e = AutoEngine(AutoStore(root), service);
    final pending = e.validateAndRun();
    e.close();
    gate.complete();
    await pending;
    expect(service.sent, isEmpty);
    expect(e.store.claim.existsSync(), false);
  });
  test('fermer après réservation conserve le résultat tardif', () async {
    final gate = Completer<void>();
    final service = AutoFakeService(resultGate: gate.future);
    final e = AutoEngine(AutoStore(root), service);
    final pending = e.validateAndRun();
    await Future<void>.delayed(Duration.zero);
    expect(e.reserved, true);
    e.close();
    gate.complete();
    await pending;
    final restored = AutoEngine(AutoStore(root), AutoFakeService());
    expect(restored.status.state, 'deja_accepte');
    await restored.validateAndRun();
    expect(restored.service.sent, isEmpty);
  });
  test(
    'version transmise figée malgré modification après réservation',
    () async {
      final gate = Completer<void>();
      final service = AutoFakeService(resultGate: gate.future);
      final e = AutoEngine(AutoStore(root), service);
      final pending = e.validateAndRun();
      await Future<void>.delayed(Duration.zero);
      e.updateDocument(const AutoDocument(content: 'Autre contenu fictif'));
      gate.complete();
      await pending;
      expect(service.sent.single.content, const AutoDocument().content);
      expect(e.store.read().history!.version, service.sent.single.version);
      await e.validateAndRun();
      expect(e.status.state, 'remplacement_a_preparer');
      expect(service.sent.length, 1);
    },
  );
  test(
    'échec avant dépôt conservé et sans réessai après réouverture',
    () async {
      final e = AutoEngine(AutoStore(root), AutoFakeService(tlsOk: false));
      await e.validateAndRun();
      final restored = AutoEngine(AutoStore(root), AutoFakeService());
      await restored.validateAndRun();
      expect(restored.status.state, 'tls_echec');
      expect(restored.service.connections, 0);
    },
  );
  test('changement de date clinique invalide validation et version', () {
    const d = AutoDocument();
    final changed = d.copy(clinicalDate: '2026-10-17');
    expect(changed.version, isNot(d.version));
    expect(changed.sameClinicalContent(d), false);
  });
}
