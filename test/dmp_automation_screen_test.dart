import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_automation/automation_screen.dart';
import 'package:abak_desktop_companion/features/dmp_automation/automation_store.dart';

void main() {
  late Directory root;
  setUp(() => root = Directory.systemTemp.createTempSync('abak-auto-ui-'));
  tearDown(() => root.deleteSync(recursive: true));
  AutoStore store() =>
      AutoStore(Directory('${root.path}/interactif/simulation-bilan-a'));
  Future<void> open(WidgetTester t) async {
    await t.pumpWidget(
      MaterialApp(
        home: AutomationScreen(
          simulationRoot: root,
          serviceDelay: Duration.zero,
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String text) async {
    await t.ensureVisible(find.text(text));
    await t.tap(find.text(text));
    await t.pumpAndSettle();
  }

  Future<void> validate(WidgetTester t) async {
    await tap(t, 'Valider médicalement — simulation');
    await t.tap(find.text('Valider cette version fictive'));
    await t.pumpAndSettle();
  }

  testWidgets('42 scénarios accessibles et indépendants du document interactif', (
    t,
  ) async {
    await open(t);
    await tap(t, 'Exécuter les 42 scénarios — simulation');
    // Disk operations are synchronous; async service gates use microtasks only.
    await t.pumpAndSettle();
    expect(find.textContaining('42/42 scénarios réussis'), findsOneWidget);
    expect(store().file.existsSync(), false);
  });
  testWidgets(
    'validation médicale déclenche automatiquement et résultat persiste',
    (t) async {
      await open(t);
      await validate(t);
      expect(
        find.textContaining('Document accepté par le service simulé'),
        findsOneWidget,
      );
      expect(store().read().outcome, 'accepted');
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      await open(t);
      expect(
        find.textContaining('Lot déjà accepté : renvoi bloqué'),
        findsOneWidget,
      );
      await validate(t);
      expect(find.textContaining('cette ouverture : 0'), findsOneWidget);
    },
  );
  testWidgets('retenue durable, levée et traitement automatique', (t) async {
    await open(t);
    await tap(t, 'Retenir l’envoi simulé');
    await validate(t);
    expect(store().read().held, true);
    expect(store().claim.existsSync(), false);
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
    await open(t);
    expect(
      find.textContaining('Retenue conservée après réouverture'),
      findsOneWidget,
    );
    await tap(t, 'Retenir l’envoi simulé');
    expect(store().read().outcome, 'accepted');
  });
  testWidgets('vide et modification après validation retenue', (t) async {
    await open(t);
    await t.ensureVisible(find.byKey(const Key('auto-content')));
    await t.enterText(find.byKey(const Key('auto-content')), '   ');
    await t.pumpAndSettle();
    await validate(t);
    expect(find.textContaining('Document vide ou gabarit'), findsOneWidget);
    await tap(t, 'Retenir l’envoi simulé');
    await t.ensureVisible(find.byKey(const Key('auto-content')));
    await t.enterText(
      find.byKey(const Key('auto-content')),
      'Bilan fictif révisé.',
    );
    await t.pumpAndSettle();
    await validate(t);
    await t.ensureVisible(find.byKey(const Key('auto-content')));
    await t.enterText(
      find.byKey(const Key('auto-content')),
      'Bilan fictif encore modifié.',
    );
    await t.pumpAndSettle();
    await tap(t, 'Retenir l’envoi simulé');
    expect(
      find.textContaining('Validation médicale de la version courante requise'),
      findsOneWidget,
    );
    expect(store().claim.existsSync(), false);
  });
  testWidgets('annuler validation ne déclenche aucun traitement', (t) async {
    await open(t);
    await tap(t, 'Valider médicalement — simulation');
    await t.tap(find.text('Annuler'));
    await t.pumpAndSettle();
    expect(store().claim.existsSync(), false);
    expect(find.text('Version courante non validée.'), findsOneWidget);
  });
  testWidgets('stockage corrompu bloquant sans écrasement', (t) async {
    store().directory.createSync(recursive: true);
    store().file.writeAsStringSync('{bad');
    await open(t);
    expect(find.textContaining('Stockage simulé indisponible'), findsOneWidget);
    expect(find.text('Valider médicalement — simulation'), findsNothing);
    expect(store().file.readAsStringSync(), '{bad');
  });
}
