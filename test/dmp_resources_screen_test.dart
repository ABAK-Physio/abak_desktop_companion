import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_resources/dmp_resources.dart';
import 'package:abak_desktop_companion/features/dmp_resources/resources_controller.dart';
import 'package:abak_desktop_companion/features/dmp_resources/resources_screen.dart';

class MemoryStore implements ResourceStore {
  String? data;
  @override
  String? read() => data;
  @override
  void commit(String value) {
    data = value;
  }
}

class PendingTransport implements ResourceTransport {
  final pending = Completer<ResourceReply>();
  int calls = 0;
  @override
  Future<ResourceReply> get(Uri uri, String? etag) {
    calls++;
    return pending.future;
  }
}

void main() {
  late MemoryStore store;
  late DateTime time;
  late SimulatedResourceTransport transport;
  DmpResources resources(ResourceTransport t) => DmpResources(
    transport: t,
    store: store,
    now: () => time,
    source: Uri.parse('https://parametres.example.invalid/simulation'),
    allowedHosts: {'parametres.example.invalid'},
  );
  ResourcesController controller() => ResourcesController(
    resources(transport),
    interval: const Duration(seconds: 10),
    advanceClock: () => time = time.add(const Duration(days: 7)),
  );
  setUp(() {
    store = MemoryStore();
    time = DateTime.utc(2026, 10, 16);
    transport = SimulatedResourceTransport();
  });
  Future<void> open(WidgetTester t, ResourcesController c) async {
    await t.pumpWidget(
      MaterialApp(
        home: ResourcesScreen(controller: c, transport: transport),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('écran: chargement automatique, source et date', (t) async {
    final c = controller();
    await open(t, c);
    expect(transport.calls, 1);
    expect(find.text('Âge de majorité simulé : 18 ans'), findsOneWidget);
    expect(find.textContaining('2026-10-16T00:00:00.000Z'), findsOneWidget);
    expect(find.textContaining('aucun accès réseau'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('périodique: échéance, échec, conservation et reprise', (
    t,
  ) async {
    final c = controller();
    await open(t, c);
    await t.pump(const Duration(seconds: 10));
    expect(transport.calls, 1);
    time = time.add(const Duration(days: 7));
    transport.scenario = 'unavailable';
    await t.pump(const Duration(seconds: 10));
    await t.pump();
    expect(transport.calls, 2);
    expect(c.resources.due, true);
    expect(find.textContaining('HTTP 503'), findsOneWidget);
    expect(find.text('Âge de majorité simulé : 18 ans'), findsOneWidget);
    transport.scenario = 'changed';
    await t.pump(const Duration(seconds: 10));
    await t.pump();
    expect(find.text('Âge de majorité simulé : 21 ans'), findsOneWidget);
    expect(c.resources.due, false);
    await t.pumpWidget(const SizedBox());
    final calls = transport.calls;
    await t.pump(const Duration(minutes: 2));
    expect(transport.calls, calls);
  });
  testWidgets('horloge simulée et contrôle manuel du fichier invalide', (
    t,
  ) async {
    final c = controller();
    await open(t, c);
    transport.scenario = 'invalid';
    await t.ensureVisible(find.text('Avancer de sept jours — horloge simulée'));
    await t.tap(find.text('Avancer de sept jours — horloge simulée'));
    await t.pumpAndSettle();
    expect(c.resources.due, true);
    expect(
      find.textContaining('Configuration précédente conservée'),
      findsOneWidget,
    );
    transport.scenario = 'normal';
    await t.ensureVisible(find.text('Vérifier maintenant — simulation'));
    await t.tap(find.text('Vérifier maintenant — simulation'));
    await t.pumpAndSettle();
    expect(c.resources.due, false);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('catalogue valide puis refus et persistance à réouverture', (
    t,
  ) async {
    final c = controller();
    await open(t, c);
    await t.ensureVisible(find.text('Charger les nomenclatures fictives'));
    await t.tap(find.text('Charger les nomenclatures fictives'));
    await t.pumpAndSettle();
    expect(find.text('Nomenclatures : SIMULATION-2'), findsOneWidget);
    await t.ensureVisible(find.text('Simuler un catalogue invalide'));
    await t.tap(find.text('Simuler un catalogue invalide'));
    await t.pumpAndSettle();
    expect(
      find.textContaining('Dernière mise à jour des nomenclatures : refusée'),
      findsOneWidget,
    );
    expect(c.resources.catalog!.version, 'SIMULATION-2');
    await t.pumpWidget(const SizedBox());
    final before = transport.calls;
    final next = controller();
    await open(t, next);
    expect(next.resources.catalog!.version, 'SIMULATION-2');
    expect(transport.calls, before);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets(
    'chargement concurrent bloqué et fermeture annule résultat tardif',
    (t) async {
      final pending = PendingTransport();
      final c = ResourcesController(
        resources(pending),
        interval: const Duration(seconds: 10),
      );
      await t.pumpWidget(MaterialApp(home: ResourcesScreen(controller: c)));
      await t.pump();
      expect(c.busy, true);
      expect(
        t
            .widget<FilledButton>(
              find.widgetWithText(
                FilledButton,
                'Vérifier maintenant — simulation',
              ),
            )
            .onPressed,
        isNull,
      );
      await t.pump(const Duration(seconds: 30));
      expect(pending.calls, 1);
      await t.pumpWidget(const SizedBox());
      final response = await transport.get(
        Uri.parse('https://parametres.example.invalid'),
        null,
      );
      pending.pending.complete(response);
      await t.pump();
      expect(store.data, isNull);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('reprise application et absence de cache invalide', (t) async {
    transport.scenario = 'invalid';
    final c = controller();
    await open(t, c);
    expect(
      find.textContaining('Fonctions dépendantes indisponibles :'),
      findsOneWidget,
    );
    transport.scenario = 'normal';
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.pumpAndSettle();
    expect(c.resources.parameters, isNotNull);
    expect(transport.calls, 2);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('cache récent distinct du dernier échec et récupération', (
    t,
  ) async {
    final c = controller();
    await open(t, c);
    final before = c.resources.lastSuccess;
    transport.scenario = 'invalid';
    await c.check(force: true);
    await t.pumpAndSettle();
    expect(
      find.text(
        'Cache des paramètres : valide, échéance de sept jours non atteinte.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Dernière tentative de mise à jour des paramètres : échec.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('XmlTagException'), findsNothing);
    expect(c.resources.parametersDiagnostic, isNotNull);
    expect(c.resources.lastSuccess, before);
    await t.pump(const Duration(seconds: 10));
    await t.pump();
    expect(
      find.textContaining(
        'Dernière tentative de mise à jour des paramètres : échec.',
      ),
      findsOneWidget,
    );
    transport.scenario = 'normal';
    await c.check(force: true);
    await t.pumpAndSettle();
    expect(
      find.textContaining(
        'Dernière tentative de mise à jour des paramètres : échec.',
      ),
      findsNothing,
    );
    expect(c.resources.parametersDiagnostic, isNull);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets(
    'catalogue refusé sans version préalable puis avec version conservée',
    (t) async {
      final c = controller();
      await open(t, c);
      c.installExampleCatalog(invalid: true);
      await t.pumpAndSettle();
      expect(
        find.textContaining('Aucune version valide disponible.'),
        findsOneWidget,
      );
      expect(find.textContaining('FormatException'), findsNothing);
      expect(
        find.textContaining('Version précédente conservée.'),
        findsNothing,
      );
      c.installExampleCatalog();
      await t.pumpAndSettle();
      expect(c.resources.catalogDiagnostic, isNull);
      c.installExampleCatalog(invalid: true);
      await t.pumpAndSettle();
      expect(
        find.textContaining('Version précédente conservée.'),
        findsOneWidget,
      );
      expect(find.textContaining('FormatException'), findsNothing);
      expect(c.resources.catalog!.version, 'SIMULATION-2');
      expect(find.textContaining('Paramètres DMP actualisés.'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    },
  );
}
