import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_integration/dossier_demo_screen.dart';

class NoDemoNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      throw StateError('Réseau interdit');
}

void main() {
  late Directory root;
  setUp(() {
    root = Directory.systemTemp.createTempSync('abak-demo-ui-');
    HttpOverrides.global = NoDemoNetwork();
  });
  tearDown(() {
    HttpOverrides.global = null;
    root.deleteSync(recursive: true);
  });
  Future<void> settle(WidgetTester t) async {
    // SQLite FFI uses real asynchronous work, outside the widget fake clock.
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await t.pump();
    for (
      var i = 0;
      i < 40 && find.byType(LinearProgressIndicator).evaluate().isNotEmpty;
      i++
    ) {
      await t.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await t.pump();
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await t.pumpAndSettle();
  }

  Future<void> open(WidgetTester t) async {
    await t.pumpWidget(
      MaterialApp(home: DossierDemoScreen(simulationRoot: root)),
    );
    await settle(t);
  }

  Future<void> close(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await settle(t);
  }

  Future<void> tap(WidgetTester t, String key) async {
    await t.ensureVisible(find.byKey(Key(key)));
    await t.pumpAndSettle();
    await t.tap(find.byKey(Key(key)));
    await settle(t);
  }

  Future<void> validate(WidgetTester t) async {
    await tap(t, 'validate');
    await t.tap(find.text('Confirmer la validation'));
    await settle(t);
  }

  bool disabled(WidgetTester t, String key) =>
      t.widget<ButtonStyleButton>(find.byKey(Key(key))).onPressed == null;
  testWidgets(
    'Lecture pièce, retenue et validation conservées puis acceptation sans renvoi',
    (t) async {
      await open(t);
      await tap(t, 'piece');
      expect(
        find.textContaining('Rattachement au patient vérifié'),
        findsOneWidget,
      );
      await tap(t, 'hold');
      await validate(t);
      expect(find.textContaining('Document retenu.'), findsOneWidget);
      expect(find.textContaining('cette ouverture : 0.'), findsOneWidget);
      await close(t);
      await open(t);
      expect(
        find.textContaining('Validation de la version courante : conservée'),
        findsOneWidget,
      );
      expect(
        t.widget<SwitchListTile>(find.byKey(const Key('hold'))).value,
        isTrue,
      );
      await tap(t, 'hold');
      expect(find.textContaining('Traitement fictif accepté'), findsOneWidget);
      expect(disabled(t, 'process'), isTrue);
      await close(t);
      await open(t);
      expect(find.textContaining('renvoi bloqué'), findsOneWidget);
      expect(find.textContaining('cette ouverture : 0.'), findsOneWidget);
      expect(disabled(t, 'validate'), isTrue);
      await close(t);
    },
  );
  testWidgets(
    'Modification et vide persistants, validation bloquée avant enregistrement',
    (t) async {
      await open(t);
      await tap(t, 'hold');
      await validate(t);
      await t.enterText(
        find.byKey(const Key('content')),
        'Nouvelle mesure fictive',
      );
      await t.pump();
      expect(disabled(t, 'validate'), isTrue);
      await tap(t, 'save');
      expect(
        find.textContaining('Validation de la version courante : requise'),
        findsOneWidget,
      );
      await t.enterText(find.byKey(const Key('content')), '   ');
      await tap(t, 'save');
      expect(find.textContaining('sans contenu clinique'), findsOneWidget);
      expect(disabled(t, 'validate'), isTrue);
      await close(t);
      await open(t);
      expect(find.textContaining('sans contenu clinique'), findsOneWidget);
      await close(t);
    },
  );
  for (final label in [
    'Signature rejetée',
    'Métadonnées rejetées',
    'Résultat indéterminé',
  ]) {
    testWidgets('$label persiste sans renvoi', (t) async {
      await open(t);
      await t.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await t.tap(find.byType(DropdownButtonFormField<String>));
      await t.pumpAndSettle();
      await t.tap(find.text(label).last);
      await t.pumpAndSettle();
      await validate(t);
      expect(disabled(t, 'process'), isTrue);
      await close(t);
      await open(t);
      expect(disabled(t, 'validate'), isTrue);
      expect(find.textContaining('cette ouverture : 0.'), findsOneWidget);
      final text = t.widget<Text>(find.byKey(const Key('status'))).data!;
      expect(
        text,
        label == 'Résultat indéterminé'
            ? contains('contrôle requis')
            : contains('rejet'),
      );
      await close(t);
    });
  }
  testWidgets(
    'Annulation de validation et nouvel exercice conservent ancien journal',
    (t) async {
      await open(t);
      await tap(t, 'validate');
      await t.tap(find.text('Annuler'));
      await settle(t);
      expect(find.textContaining('cette ouverture : 0.'), findsOneWidget);
      await validate(t);
      final old = File('${root.path}/exercice.txt').readAsStringSync();
      await tap(t, 'new');
      final next = File('${root.path}/exercice.txt').readAsStringSync();
      expect(next, isNot(old));
      expect(File('${root.path}/$old/journal.sqlite').existsSync(), isTrue);
      expect(find.textContaining('Cette version nécessite'), findsOneWidget);
      await close(t);
      await open(t);
      expect(File('${root.path}/exercice.txt').readAsStringSync(), next);
      await close(t);
    },
  );
  testWidgets('Journal manquant bloque la reprise sans recréation', (t) async {
    await open(t);
    await close(t);
    final id = File('${root.path}/exercice.txt').readAsStringSync();
    final journal = File('${root.path}/$id/journal.sqlite');
    journal.deleteSync();
    await open(t);
    expect(find.textContaining('Actions suspendues'), findsOneWidget);
    expect(journal.existsSync(), isFalse);
    await close(t);
  });
}
