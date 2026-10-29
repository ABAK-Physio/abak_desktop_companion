import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_pdf_cda_unified/unified_screen.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final ctl = LiveWidgetController(binding);
  final root = Directory(Platform.environment['UNIFIED_ROOT']!);
  final assets = Directory(Platform.environment['UNIFIED_ASSETS']!);
  final out = Directory(Platform.environment['UNIFIED_OUTPUT']!)
    ..createSync(recursive: true);
  final results = <String>[];
  final errors = <String>[];
  final boundary = GlobalKey();
  FlutterError.onError = (e) => errors.add(e.toString());
  void check(bool b, String label) {
    if (!b) throw StateError(label);
    results.add(label);
    stdout.writeln('PASS $label');
  }

  Future<void> settle() async {
    for (var i = 0; i < 6; i++) {
      await ctl.pump(const Duration(milliseconds: 80));
    }
  }

  Future<void> mount() async {
    runApp(const SizedBox.shrink());
    await settle();
    runApp(
      MaterialApp(
        home: RepaintBoundary(
          key: boundary,
          child: UnifiedScreen(
            simulationRoot: root,
            loader: (n) async => File('${assets.path}/$n').readAsBytesSync(),
          ),
        ),
      ),
    );
    await settle();
  }

  bool enabled(String k) =>
      ctl.widget<FilledButton>(find.byKey(Key(k))).onPressed != null;
  Future<void> press(String k) async {
    ctl.widget<FilledButton>(find.byKey(Key(k))).onPressed!();
    await settle();
  }

  Future<void> select(String value) async {
    ctl
        .widget<DropdownButton<String>>(find.byKey(const Key('fixture')))
        .onChanged!(value);
    await settle();
  }

  Future<void> mode(String value) async {
    ctl
        .widget<DropdownButton<String>>(find.byKey(const Key('mode')))
        .onChanged!(value);
    await settle();
  }

  String text(String k) => ctl.widget<Text>(find.byKey(Key(k))).data!;
  Future<void> approve() async {
    for (final k in ['review', 'clinical', 'patient', 'context']) {
      ctl.widget<CheckboxListTile>(find.byKey(Key(k))).onChanged!(true);
      await settle();
    }
    await press('approve');
  }

  Future<void> waitResult() async {
    final until = DateTime.now().add(const Duration(minutes: 3));
    while (find.byKey(const Key('pending')).evaluate().isNotEmpty &&
        DateTime.now().isBefore(until)) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await ctl.pump(const Duration(milliseconds: 100));
    }
    check(
      find.byKey(const Key('result')).evaluate().isNotEmpty,
      'résultat reçu',
    );
  }

  await mount();
  check(
    !enabled('run') && !enabled('approve') && !enabled('send'),
    'sans revue : contrôles et envoi bloqués',
  );
  await approve();
  check(enabled('run'), 'version validée : contrôle autorisé');
  await mount();
  check(text('clinical-state').contains('conservée'), 'validation persistée');
  await press('run');
  check(
    !enabled('run') && !enabled('send'),
    'pendant exécution : boutons bloqués',
  );
  await waitResult();
  check(
    text('pdf-status') == 'PDF/A-1b : Conforme' &&
        text('cda-status') == 'CDA : Conforme' &&
        text('content').contains('identique'),
    'résultat natif et identité du contenu',
  );
  await mount();
  check(
    text('result').contains('conformes') && !enabled('run') && !enabled('send'),
    'succès conservé, aucun renvoi',
  );
  final image =
      await (boundary.currentContext!.findRenderObject()
              as RenderRepaintBoundary)
          .toImage(pixelRatio: 1);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(
    '${out.path}/Ecran_conforme.png',
  ).writeAsBytesSync(bytes!.buffer.asUint8List());
  image.dispose();
  await select('contenu_modifie');
  check(
    !enabled('run') && text('clinical-state').contains('nécessite'),
    'modification invalide validation',
  );
  await mount();
  check(!enabled('run'), 'modification non validée persistée');
  for (final value in ['blanc', 'entete']) {
    await select(value);
    check(
      !enabled('approve') &&
          !enabled('run') &&
          find.byKey(const Key('empty')).evaluate().isNotEmpty,
      'blocage clinique $value',
    );
    await mount();
    check(!enabled('run'), 'persistance $value');
  }
  await select('sans_xmp');
  await approve();
  await press('run');
  await waitResult();
  check(
    text('pdf-status').contains('Non conforme'),
    'non-conformité native affichée',
  );
  await mount();
  check(
    text('result').contains('refusée') && !enabled('send'),
    'refus persistant',
  );
  await select('positif');
  await approve();
  await mode('missing');
  await press('run');
  await waitResult();
  check(
    text('result').contains('simulé') &&
        text('pdf-status').contains('Non vérifié'),
    'indisponibilité simulée distincte du refus',
  );
  await mount();
  check(text('result').contains('non vérifiée'), 'indisponibilité persistée');
  await mode('different');
  await press('run');
  await waitResult();
  check(
    text('content').contains('différent') &&
        text('result').contains('différent'),
    'PDF encapsulé différent bloqué',
  );
  await mount();
  check(
    text('content').contains('différent') && !enabled('send'),
    'différence persistée',
  );
  File('${root.path}/ui.json').writeAsStringSync('{}');
  await mount();
  check(
    find.byKey(const Key('error')).evaluate().isNotEmpty && !enabled('send'),
    'journal altéré : écran suspendu',
  );
  check(errors.isEmpty, 'aucune erreur Flutter');
  File('${out.path}/Resultats_ecran.json').writeAsStringSync(
    jsonEncode({
      'passed': results.length,
      'checks': results,
      'errors': errors,
      'transportCalls': 0,
    }),
  );
  exit(0);
}
