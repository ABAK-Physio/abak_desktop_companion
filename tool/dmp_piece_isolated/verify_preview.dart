import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_piece_isolated/piece_screen.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final ctl = LiveWidgetController(binding);
  final boundary = GlobalKey();
  final errors = <String>[];
  FlutterError.onError = (e) => errors.add(e.toString());
  runApp(
    RepaintBoundary(
      key: boundary,
      child: MaterialApp(
        home: PieceScreen(root: Directory(Platform.environment['PIECE_ROOT']!)),
      ),
    ),
  );
  for (var i = 0; i < 40; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await ctl.pump(const Duration(milliseconds: 100));
  }
  ctl.widget<OutlinedButton>(find.byKey(const Key('zoom'))).onPressed!();
  for (var i = 0; i < 8; i++) {
    await ctl.pump(const Duration(milliseconds: 100));
  }
  if (find.byType(InteractiveViewer).evaluate().isEmpty || errors.isNotEmpty) {
    throw StateError('Aperçu indisponible');
  }
  final image =
      await (boundary.currentContext!.findRenderObject()
              as RenderRepaintBoundary)
          .toImage();
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(
    Platform.environment['PIECE_PREVIEW']!,
  ).writeAsBytesSync(bytes!.buffer.asUint8List());
  image.dispose();
  stdout.writeln('Aperçu agrandi rendu sans erreur Flutter.');
  exit(0);
}
