import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_piece_isolated/piece_screen.dart';
import 'package:abak_desktop_companion/features/dmp_piece_isolated/piece_demo.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final ctl = LiveWidgetController(binding);
  final root = Directory(Platform.environment['PIECE_ROOT']!);
  final out = Directory(Platform.environment['PIECE_OUTPUT']!)
    ..createSync(recursive: true);
  final boundary = GlobalKey();
  final errors = <String>[], checks = <String>[];
  FlutterError.onError = (e) => errors.add(e.toString());
  void check(bool value, String label) {
    if (!value) throw StateError(label);
    checks.add(label);
    stdout.writeln('PASS $label');
  }

  Future<void> pump() async {
    for (var i = 0; i < 6; i++) {
      await ctl.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> wait() async {
    final deadline = DateTime.now().add(const Duration(minutes: 4));
    do {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await ctl.pump(const Duration(milliseconds: 100));
    } while (find.byKey(const Key('pending')).evaluate().isNotEmpty &&
        DateTime.now().isBefore(deadline));
    check(
      find.byKey(const Key('pending')).evaluate().isEmpty,
      'commande terminée',
    );
  }

  Future<void> mount() async {
    runApp(const SizedBox.shrink());
    await pump();
    runApp(
      MaterialApp(
        home: RepaintBoundary(
          key: boundary,
          child: PieceScreen(root: root),
        ),
      ),
    );
    await pump();
    await wait();
  }

  bool enabled(String k) =>
      ctl.widget<FilledButton>(find.byKey(Key(k))).onPressed != null;
  String text(String k) => ctl.widget<Text>(find.byKey(Key(k))).data!;
  Future<void> toggle(String k) async {
    ctl.widget<CheckboxListTile>(find.byKey(Key(k))).onChanged!(true);
    await pump();
  }

  Future<void> approve() async {
    await toggle('page-review');
    await toggle('clinical');
    await toggle('confirm');
    check(enabled('approve'), 'revue complète autorise la confirmation');
    ctl.widget<FilledButton>(find.byKey(const Key('approve'))).onPressed!();
    await pump();
    await wait();
  }

  Future<void> select(String mode) async {
    ctl
        .widget<DropdownButton<String>>(find.byKey(const Key('mode')))
        .onChanged!(mode);
    await pump();
    await wait();
  }

  Future<void> run() async {
    ctl.widget<FilledButton>(find.byKey(const Key('run'))).onPressed!();
    await pump();
    check(
      !enabled('run') && !enabled('send'),
      'contrôle en cours : actions bloquées',
    );
    await wait();
  }

  Future<void> screen(String name) async {
    final image =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${out.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  }

  await mount();
  check(
    text('piece').contains('SIM-DOC1') && text('identity').contains('SIM-A'),
    'pièce et identité attendues affichées',
  );
  check(
    find.byType(Image).evaluate().isNotEmpty,
    'aperçu de la copie figée affiché',
  );
  check(
    !enabled('approve') && !enabled('run') && !enabled('send'),
    'trois boutons initialement bloqués',
  );
  await toggle('clinical');
  await toggle('confirm');
  check(!enabled('approve'), 'revue de page requise');
  ctl.widget<OutlinedButton>(find.byKey(const Key('zoom'))).onPressed!();
  await pump();
  check(
    find.byType(InteractiveViewer).evaluate().isNotEmpty,
    'aperçu agrandi avec zoom',
  );
  await screen('Apercu_agrandi');
  ctl.widget<TextButton>(find.byKey(const Key('close-preview'))).onPressed!();
  await pump();
  await approve();
  final version = text('version');
  final count = text('native-count');
  check(
    text('approval').contains('conservée') && enabled('run'),
    'confirmation versionnée enregistrée',
  );
  await mount();
  check(
    text('approval').contains('conservée') &&
        text('version') == version &&
        text('native-count') == count,
    'confirmation persistée sans contrôle implicite',
  );
  await run();
  check(text('status').contains('conformes'), 'contrôles natifs conformes');
  final countAfter = text('native-count');
  await mount();
  check(
    text('status').contains('conformes') &&
        !enabled('run') &&
        !enabled('send') &&
        text('native-count') == countAfter,
    'succès persisté sans relance',
  );
  await screen('Conforme');
  final scroll = ctl.state<ScrollableState>(find.byType(Scrollable).first);
  scroll.position.jumpTo(scroll.position.maxScrollExtent);
  await pump();
  await screen('Conforme_controles');

  final old = PieceDemo(root).state['binding'] as String;
  await select('second');
  check(
    text('piece').contains('SIM-DOC2') &&
        text('version') != version &&
        !enabled('run'),
    'autre pièce du même PDF sans héritage',
  );
  check(
    ctl.widget<CheckboxListTile>(find.byKey(const Key('confirm'))).value ==
        false,
    'revue effacée après changement de pièce',
  );
  await mount();
  check(
    text('piece').contains('SIM-DOC2') && text('approval').contains('requise'),
    'sélection persistée',
  );
  final stale = PieceDemo(root);
  stale.send(
    'approve',
    binding: old,
    review: {
      'pages': [1],
      'clinical': true,
      'patient': 'SIM-A',
      'contextConfirmed': true,
    },
  );
  await mount();
  check(
    !enabled('run') &&
        find.byKey(const Key('command-error')).evaluate().isNotEmpty,
    'confirmation d’ancienne pièce refusée',
  );
  await approve();
  check(
    text('approval').contains('conservée'),
    'seconde pièce confirmée explicitement',
  );
  for (final mode in [
    'wrong_patient',
    'wrong_episode',
    'archived',
    'nia',
    'unavailable',
    'blank',
    'header',
  ]) {
    await select(mode);
    check(
      !enabled('approve') && !enabled('run') && !enabled('send'),
      'blocage $mode',
    );
    check(
      ctl
              .widget<CheckboxListTile>(find.byKey(const Key('confirm')))
              .onChanged ==
          null,
      'revue désactivée $mode',
    );
    await mount();
    check(
      !enabled('approve') && !enabled('run') && !enabled('send'),
      'blocage persistant $mode',
    );
  }
  for (final mode in ['changed_pdf', 'changed_identity', 'changed_link']) {
    await select(mode);
    await approve();
    final before = text('version');
    final previous = PieceDemo(root).state['binding'] as String;
    ctl.widget<OutlinedButton>(find.byKey(const Key('change'))).onPressed!();
    await pump();
    await wait();
    check(
      text('version') != before &&
          !enabled('run') &&
          text('approval').contains('requise'),
      'invalidation $mode',
    );
    await mount();
    check(
      !enabled('run') && text('approval').contains('requise'),
      'invalidation persistée $mode',
    );
    if (mode == 'changed_pdf') {
      await screen('PDF_modifie');
      final stale = PieceDemo(root);
      stale.send(
        'approve',
        binding: previous,
        review: {
          'pages': [1],
          'clinical': true,
          'patient': 'SIM-A',
          'contextConfirmed': true,
        },
      );
      await mount();
      check(
        find.byKey(const Key('command-error')).evaluate().isNotEmpty &&
            !enabled('run'),
        'ancienne version de PDF refusée',
      );
      await approve();
      check(
        enabled('run'),
        'PDF modifié nécessite et accepte une nouvelle revue',
      );
    }
  }
  await select('different');
  await approve();
  await run();
  check(
    text('status').contains('bloqu') &&
        text('message').contains('Identité CDA différente'),
    'autre identité CDA refusée',
  );
  await mount();
  check(
    text('status').contains('bloqu') && !enabled('send'),
    'refus CDA persisté',
  );
  await screen('Refus_CDA');
  // Leave a confirmed state for the separate service-restart verification.
  await select('coherent');
  await approve();
  check(errors.isEmpty, 'aucune erreur Flutter');
  File('${out.path}/Resultats_ecran.json').writeAsStringSync(
    jsonEncode({
      'passed': checks.length,
      'checks': checks,
      'errors': errors,
      'transportCalls': 0,
      'nativeJobs': PieceDemo(root).state['nativeJobs'],
    }),
  );
  exit(0);
}
