import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_minors/minors_simulation.dart';
import 'package:abak_desktop_companion/features/dmp_minors/minors_scenarios.dart';

class NoNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      throw StateError('Réseau interdit');
}

void main() {
  late Directory root;
  setUp(() {
    root = Directory.systemTemp.createTempSync('abak-minors-tests-');
    HttpOverrides.global = NoNetwork();
  });
  tearDown(() {
    HttpOverrides.global = null;
    root.deleteSync(recursive: true);
  });
  for (var n = 1; n <= 23; n++) {
    test('M${n.toString().padLeft(2, '0')} ${minorScenarioTitles[n - 1]}', () {
      final result = runMinorScenario(n, root);
      expect(result.checks, isNotEmpty);
      expect(result.id, 'M${n.toString().padLeft(2, '0')}');
    });
  }
  test('stockage corrompu : refus, fichier inchangé', () {
    final store = MinorSimulationStore(root);
    store.file.writeAsStringSync('{invalide');
    expect(store.read, throwsFormatException);
    expect(
      () =>
          store.save(const SimDocument(id: 'SIM-A', patient: SimPatient.child)),
      throwsFormatException,
    );
    expect(store.file.readAsStringSync(), '{invalide');
  });
  test('une préparation refusée invalide le précédent aperçu', () {
    final s = MinorSession(MinorContext(today: DateTime.utc(2026, 10, 16)))
      ..choose(true);
    final preview = s.prepare(id: 'SIM-A');
    expect(() => s.prepare(id: 'SIM-A', rlVisible: true), throwsStateError);
    expect(s.current(preview), false);
    expect(s.preview, null);
    expect(
      () => s.retain(preview, MinorSimulationStore(root)),
      throwsStateError,
    );
    expect(root.listSync(), isEmpty);
  });
  test(
    'passage visible par remplacement exige confirmation et même identifiant',
    () {
      final s = MinorSession(MinorContext(today: DateTime.utc(2026, 10, 16)))
        ..choose(false);
      const d = SimDocument(id: 'SIM-A', patient: SimPatient.child);
      expect(
        () => s.prepare(id: d.id, replacing: d, rlVisible: true),
        throwsStateError,
      );
      expect(() => s.prepare(id: 'SIM-B', replacing: d), throwsStateError);
      expect(
        s
            .prepare(
              id: d.id,
              replacing: d,
              rlVisible: true,
              confirmedVisibilityChange: true,
            )
            .document
            .rlVisible,
        true,
      );
    },
  );
  test('changement opposition invalide aperçu avant conservation', () {
    final s = MinorSession(MinorContext(today: DateTime.utc(2026, 10, 16)))
      ..choose(false);
    final p = s.prepare(id: 'SIM-A');
    s.setOpposition(true);
    expect(() => s.retain(p, MinorSimulationStore(root)), throwsStateError);
  });
  test('dates civiles, borne anniversaire et année bissextile', () {
    expect(
      MinorContext(
        patient: SimPatient.child,
        today: DateTime.utc(2028, 2, 29),
      ).age,
      13,
    );
    expect(
      MinorContext(
        patient: SimPatient.child,
        today: DateTime.utc(2026, 10, 15, 23),
      ).age,
      11,
    );
    expect(
      MinorContext(
        patient: SimPatient.child,
        today: DateTime.utc(2026, 10, 16),
      ).age,
      12,
    );
  });
}
