import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_minors/minors_screen.dart';
import 'package:abak_desktop_companion/features/dmp_minors/minors_simulation.dart';

void main() {
  late Directory root;
  setUp(() => root = Directory.systemTemp.createTempSync('abak-minors-ui-'));
  tearDown(() => root.deleteSync(recursive: true));
  Future<void> open(WidgetTester t) async {
    await t.pumpWidget(MaterialApp(home: MinorsScreen(simulationRoot: root)));
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String text) async {
    await t.ensureVisible(find.text(text));
    await t.tap(find.text(text));
    await t.pumpAndSettle();
  }

  testWidgets('23 scénarios depuis écran et isolation des fichiers', (t) async {
    await open(t);
    await tap(t, 'Exécuter les 23 scénarios — simulation');
    expect(
      find.textContaining('23/23 scénarios locaux réussis'),
      findsOneWidget,
    );
    expect(Directory('${root.path}/scenarios').listSync().length, 23);
    expect(
      File('${root.path}/interactif/documents-fictifs.json').existsSync(),
      false,
    );
  });
  testWidgets('secret, blocage RL, aperçu, conservation et nouvelle session', (
    t,
  ) async {
    await open(t);
    expect(
      t
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Préparer un aperçu fictif'),
          )
          .onPressed,
      isNull,
    );
    await tap(t, 'Choisir une connexion secrète');
    expect(find.textContaining('CONNEXION SECRÈTE SIMULÉE'), findsOneWidget);
    final rl = t.widget<SwitchListTile>(
      find.widgetWithText(
        SwitchListTile,
        'Document visible aux représentants légaux',
      ),
    );
    expect(rl.onChanged, isNull);
    expect(rl.value, false);
    await tap(t, 'Préparer un aperçu fictif');
    expect(
      find.textContaining('SIMULATION — aperçu sémantique'),
      findsOneWidget,
    );
    await tap(t, 'Conserver le document fictif');
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
    await open(t);
    expect(
      find.textContaining('Document fictif conservé : SIM-INTERACTIF-child'),
      findsOneWidget,
    );
    expect(find.textContaining('CONNEXION SECRÈTE SIMULÉE'), findsNothing);
    expect(
      t
          .widget<FilledButton>(
            find.widgetWithText(
              FilledButton,
              'Préparer le remplacement fictif',
            ),
          )
          .onPressed,
      isNull,
    );
  });
  testWidgets('confirmation annulée puis visibilité conservée', (t) async {
    final store = MinorSimulationStore(Directory('${root.path}/interactif'));
    store.save(
      const SimDocument(id: 'SIM-INTERACTIF-child', patient: SimPatient.child),
    );
    await open(t);
    await tap(t, 'Choisir une connexion normale');
    await tap(t, 'Rendre visible aux représentants légaux');
    await t.tap(find.text('Annuler'));
    await t.pumpAndSettle();
    expect(store.read().single.rlVisible, false);
    await tap(t, 'Rendre visible aux représentants légaux');
    await t.tap(find.text('Confirmer'));
    await t.pumpAndSettle();
    expect(store.read().single.rlVisible, true);
    await tap(t, 'Choisir une connexion secrète');
    await tap(t, 'Préparer le remplacement fictif');
    expect(find.textContaining('Conflit :'), findsOneWidget);
    expect(
      t
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Conserver le document fictif'),
          )
          .onPressed,
      isNull,
    );
  });
  testWidgets('opposition bloque le bouton de nouveau dépôt', (t) async {
    await open(t);
    await tap(t, 'Choisir une connexion secrète');
    await tap(t, 'Opposition au nouveau dépôt');
    expect(
      t
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Préparer un aperçu fictif'),
          )
          .onPressed,
      isNull,
    );
  });
  testWidgets('stockage invalide suspend écran et conserve fichier', (t) async {
    final store = MinorSimulationStore(Directory('${root.path}/interactif'));
    store.directory.createSync();
    store.file.writeAsStringSync('bad');
    await open(t);
    expect(find.textContaining('Actions suspendues'), findsOneWidget);
    expect(find.text('Exécuter les 23 scénarios — simulation'), findsNothing);
    expect(store.file.readAsStringSync(), 'bad');
  });
}
