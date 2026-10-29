import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_identity_isolated/identity_screen.dart';
import 'package:abak_desktop_companion/features/dmp_identity_isolated/identity_demo.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final ctl = LiveWidgetController(binding);
  final root = Directory(Platform.environment['IDENTITY_ROOT']!);
  final assets = Directory(Platform.environment['IDENTITY_ASSETS']!);
  final out = Directory(Platform.environment['IDENTITY_OUTPUT']!)
    ..createSync(recursive: true);
  final boundary = GlobalKey();
  final errors = <String>[];
  final checks = <String>[];
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
    final deadline = DateTime.now().add(const Duration(minutes: 3));
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
          child: IdentityScreen(
            root: root,
            loader: (n) async => File('${assets.path}/$n').readAsBytesSync(),
          ),
        ),
      ),
    );
    await pump();
    await wait();
  }

  bool enabled(String k) =>
      ctl.widget<FilledButton>(find.byKey(Key(k))).onPressed != null;
  String text(String k) => ctl.widget<Text>(find.byKey(Key(k))).data!;
  Future<void> approve() async {
    ctl.widget<CheckboxListTile>(find.byKey(const Key('confirm'))).onChanged!(
      true,
    );
    await pump();
    ctl.widget<FilledButton>(find.byKey(const Key('approve'))).onPressed!();
    await pump();
    await wait();
  }

  Future<void> run() async {
    ctl.widget<FilledButton>(find.byKey(const Key('run'))).onPressed!();
    await pump();
    check(
      !enabled('run') && !enabled('send'),
      'pendant contrôle : actions bloquées',
    );
    await wait();
  }

  Future<void> select(String mode) async {
    ctl
        .widget<DropdownButton<String>>(find.byKey(const Key('mode')))
        .onChanged!(mode);
    await pump();
    await wait();
  }

  await mount();
  check(
    !enabled('approve') && !enabled('run') && !enabled('send'),
    'confirmation initiale requise',
  );
  await approve();
  check(
    text('approval').contains('conservée') && enabled('run'),
    'confirmation versionnée acceptée',
  );
  await mount();
  check(text('approval').contains('conservée'), 'confirmation persistée');
  await run();
  check(text('status').contains('conforme'), 'contrôles natifs conformes');
  await mount();
  check(
    text('status').contains('conforme') && !enabled('run') && !enabled('send'),
    'succès persisté sans relance',
  );
  final image =
      await (boundary.currentContext!.findRenderObject()
              as RenderRepaintBoundary)
          .toImage();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  File('${out.path}/Ecran.png').writeAsBytesSync(data!.buffer.asUint8List());
  image.dispose();
  for (final mode in ['doubtful', 'nia', 'missing', 'unavailable']) {
    await select(mode);
    check(
      text('status').contains('bloqu') &&
          !enabled('approve') &&
          !enabled('run'),
      'blocage $mode',
    );
    await mount();
    check(
      text('status').contains('bloqu') && !enabled('send'),
      'persistance $mode',
    );
  }
  await select('changed');
  await approve();
  final old = text('version');
  final staleBinding = IdentityDemo(root).state['binding'] as String;
  ctl.widget<OutlinedButton>(find.byKey(const Key('change'))).onPressed!();
  await pump();
  await wait();
  check(
    text('version') != old &&
        text('approval').contains('requise') &&
        !enabled('run'),
    'modification invalide confirmation',
  );
  await mount();
  check(
    !enabled('run') && text('approval').contains('requise'),
    'invalidation persistée',
  );
  final stale = IdentityDemo(root);
  stale.send('approve', binding: staleBinding);
  await mount();
  check(
    text('approval').contains('requise') &&
        find.byKey(const Key('command-error')).evaluate().isNotEmpty,
    'confirmation périmée refusée',
  );
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
  check(errors.isEmpty, 'aucune erreur Flutter');
  File('${out.path}/Resultats_ecran.json').writeAsStringSync(
    jsonEncode({
      'passed': checks.length,
      'checks': checks,
      'errors': errors,
      'transportCalls': 0,
    }),
  );
  exit(0);
}
