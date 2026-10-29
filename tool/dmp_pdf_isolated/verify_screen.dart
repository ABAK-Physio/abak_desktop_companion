import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_pdf_isolated/pdf_demo_screen.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final controller = LiveWidgetController(binding);
  final out = Directory(Platform.environment['PDF_SCREEN_OUTPUT']!)
    ..createSync(recursive: true);
  final fixtures = Directory(Platform.environment['PDF_SCREEN_FIXTURES']!);
  final root = Directory('${out.path}/stockage');
  final results = <String>[];
  final errors = <String>[];
  FlutterError.onError = (e) {
    errors.add(e.toString());
  };
  final boundary = GlobalKey();
  void check(bool v, String why) {
    if (!v) throw StateError(why);
  }

  Future<void> settle() async {
    for (var i = 0; i < 6; i++) {
      await controller.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> mount() async {
    runApp(
      MaterialApp(
        home: RepaintBoundary(
          key: boundary,
          child: PdfDemoScreen(
            simulationRoot: root,
            fixtureLoader: (n) async =>
                File('${fixtures.path}/$n').readAsBytesSync(),
          ),
        ),
      ),
    );
    await settle();
  }

  Future<void> reopen() async {
    runApp(const SizedBox.shrink());
    await settle();
    await mount();
  }

  T w<T extends Widget>(String key) =>
      controller.widget<T>(find.byKey(Key(key)));
  bool enabled(String key) => w<FilledButton>(key).onPressed != null;
  Future<void> press(String key) async {
    final button = w<ButtonStyleButton>(key);
    check(button.onPressed != null, 'Bouton désactivé $key');
    button.onPressed!();
    await settle();
  }

  Future<void> select(String name) async {
    w<DropdownButton<String>>('fixture').onChanged!(name);
    await settle();
    await press('import');
  }

  Future<void> tick(String key) async {
    w<CheckboxListTile>(key).onChanged!(true);
    await settle();
  }

  Future<void> approve() async {
    await tick('reviewPage');
    await tick('clinical');
    await tick('patient');
    await press('validate');
    await press('confirm');
  }

  Future<void> screenshot(String name) async {
    await settle();
    final image =
        await (boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary)
            .toImage();
    final b = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${out.path}/$name.png').writeAsBytesSync(b!.buffer.asUint8List());
    image.dispose();
  }

  try {
    await mount();
    check(
      find.text('DMP — PDF final simulé').evaluate().length == 1,
      'Titre absent',
    );
    await press('import');
    check(find.byType(Image).evaluate().length == 1, 'Aperçu absent');
    check(!enabled('validate') && !enabled('process'), 'Validation implicite');
    results.add('Import, aperçu et blocage initial');
    await select('deux_pages.pdf');
    await tick('reviewPage');
    await tick('clinical');
    await tick('patient');
    check(!enabled('validate'), 'Validation avant revue complète');
    await press('next');
    check(find.text('Page 2 sur 2').evaluate().length == 1, 'Page incorrecte');
    await screenshot('Apercu_page_2');
    await tick('reviewPage');
    check(enabled('validate'), 'Validation indisponible');
    await press('validate');
    await press('confirm');
    check(!enabled('process'), 'Retenue absente');
    results.add('Deux pages, revue complète et confirmation explicite');
    await reopen();
    check(
      find.text('Validation conservée pour cette version.').evaluate().length ==
          1,
      'Validation perdue',
    );
    check(w<SwitchListTile>('held').value, 'Retenue perdue');
    check(
      find.text('Appels fictifs cumulés : 0').evaluate().length == 1,
      'Appel inattendu',
    );
    results.add('Validation et retenue après réouverture');
    await controller.ensureVisible(find.byKey(const Key('validate')));
    await screenshot('Validation_retenue');
    w<SwitchListTile>('held').onChanged!(false);
    await settle();
    check(enabled('process'), 'Traitement bloqué');
    await press('process');
    await reopen();
    check(!enabled('process'), 'Renvoi possible');
    check(
      find.text('Appels fictifs cumulés : 1').evaluate().length == 1,
      'Appel supplémentaire',
    );
    results.add('Traitement puis blocage durable du renvoi');
    await press('fresh');
    await select('rapport_final.pdf');
    await approve();
    await select('rapport_modifie.pdf');
    check(!enabled('validate') && !enabled('process'), 'Validation réutilisée');
    check(
      find.text('Cette version nécessite une validation.').evaluate().length ==
          1,
      'Message de version absent',
    );
    await reopen();
    check(!enabled('process'), 'Validation restaurée à tort');
    results.add('Modification : revue et validation perdues, persistance');
    await select('page_blanche.pdf');
    check(
      !enabled('validate'),
      'Validation disponible dès import de la page blanche',
    );
    check(
      w<Text>('validationStatus').data!.contains('Page blanche détectée'),
      'Motif du blocage absent',
    );
    await tick('reviewPage');
    await tick('clinical');
    await tick('patient');
    check(
      !enabled('validate'),
      'Déclarations positives contournant le blocage',
    );
    check(find.byType(AlertDialog).evaluate().isEmpty, 'Confirmation proposée');
    check(!enabled('process'), 'Traitement page blanche');
    await controller.ensureVisible(find.byKey(const Key('validate')));
    await screenshot('Page_blanche_validation_grisee');
    await reopen();
    check(
      !enabled('validate') && !enabled('process'),
      'Blocage perdu à la réouverture',
    );
    check(
      w<Text>('validationStatus').data!.contains('Page blanche détectée'),
      'Motif perdu à la réouverture',
    );
    check(
      find.text('Appels fictifs cumulés : 0').evaluate().length == 1,
      'Appel pour page blanche',
    );
    results.add(
      'Page blanche : blocage immédiat, confirmations sans effet, persistance et zéro appel',
    );
    await select('entete_seul.pdf');
    await tick('reviewPage');
    await tick('patient');
    check(!enabled('validate'), 'En-tête validé sans contenu');
    results.add('Contenu clinique non confirmé : blocage');
    await select('graphique.pdf');
    await approve();
    check(
      find.text('Validation conservée pour cette version.').evaluate().length ==
          1,
      'Image refusée',
    );
    results.add('Image sans texte : aperçu et revue explicite');
    for (final outcome in ['metadataRejected', 'timeout']) {
      await press('fresh');
      await select('rapport_final.pdf');
      await approve();
      w<SwitchListTile>('held').onChanged!(false);
      await settle();
      w<DropdownButton<String>>('outcome').onChanged!(outcome);
      await settle();
      await press('process');
      await reopen();
      check(!enabled('process'), 'Renvoi $outcome');
      check(
        w<Text>(
          'storedOutcome',
        ).data!.contains(outcome == 'timeout' ? 'indéterminé' : 'rejetées'),
        'Issue perdue après réouverture',
      );
      check(
        find.text('Appels fictifs cumulés : 1').evaluate().length == 1,
        'Doublon $outcome',
      );
    }
    results.add('Rejet et indéterminé conservés après réouverture');
    final name = File('${root.path}/exercises/exercice.txt').readAsStringSync();
    final journal = File('${root.path}/exercises/$name/journal.json');
    final c = jsonDecode(journal.readAsStringSync())['current'];
    File(
      '${root.path}/exercises/$name/${c['preview']}/${(c['inspection']['previews'] as Map).keys.first}',
    ).writeAsStringSync('alteration fictive');
    await reopen();
    check(find.byType(Image).evaluate().isEmpty, 'Aperçu altéré affiché');
    results.add('Aperçu altéré refusé à la réouverture');
    await press('fresh');
    await select('deux_pages.pdf');
    await screenshot('Ecran_PDF');
    check(errors.isEmpty, 'Erreurs Flutter : ${errors.join('\n')}');
    File('${out.path}/Resultats_ecran.json').writeAsStringSync(
      jsonEncode({
        'passed': results.length,
        'cases': results,
        'flutterErrors': errors,
      }),
    );
    stdout.writeln('PASS ${results.length} contrôles écran');
    exit(0);
  } catch (e, st) {
    File(
      '${out.path}/Echec.txt',
    ).writeAsStringSync('$e\n$st\n${errors.join('\n')}');
    stderr.writeln(e);
    exit(1);
  }
}
