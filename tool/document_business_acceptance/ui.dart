import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';
// ignore: implementation_imports
import 'package:printing/src/interface.dart';

class NativeRaster extends PrintingPlatform {
  NativeRaster(this.executable);
  final String executable;
  int calls = 0;
  @override
  Stream<PdfRaster> raster(
    Uint8List bytes,
    List<int>? pages,
    double dpi,
  ) async* {
    calls++;
    final process = await Process.start(executable, [dpi.toString()]);
    final out = process.stdout.transform(utf8.decoder).join();
    final err = process.stderr.transform(utf8.decoder).join();
    process.stdin.add(bytes);
    await process.stdin.close();
    final code = await process.exitCode;
    final data = await out, error = await err;
    if (code != 0) throw StateError('CoreGraphics $code $error');
    final decoded = jsonDecode(data) as List;
    for (var i = 0; i < decoded.length; i++) {
      if (pages != null && !pages.contains(i)) continue;
      final row = decoded[i];
      yield PdfRaster(row['width'], row['height'], base64Decode(row['rgba']));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class BusinessUi {
  final controller = LiveWidgetController(WidgetsBinding.instance);
  final boundary = GlobalKey();
  Future<void> pump([int n = 5]) async {
    for (var i = 0; i < n; i++) {
      await controller.pump(const Duration(milliseconds: 25));
      await Future<void>.delayed(const Duration(milliseconds: 15));
    }
  }

  Future<void> until(
    bool Function() ready,
    String label, {
    int seconds = 20,
  }) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (!ready()) {
      if (DateTime.now().isAfter(end)) throw StateError('UI timeout: $label');
      await pump(2);
    }
    await pump(2);
  }

  Future<Finder> seek(String key) async {
    final f = find.byKey(Key(key));
    if (f.evaluate().isEmpty) {
      final lists = find.byType(ListView);
      final candidates = lists.evaluate().isEmpty
          ? find.byType(Scrollable)
          : find.descendant(of: lists.last, matching: find.byType(Scrollable));
      final scrolls = candidates
          .evaluate()
          .map((e) => (e as StatefulElement).state)
          .whereType<ScrollableState>()
          .where((s) => s.position.axis == Axis.vertical)
          .toList();
      if (scrolls.isNotEmpty) {
        final p = scrolls.first.position;
        p.jumpTo(p.minScrollExtent);
        await pump(2);
        for (var i = 0; i < 80 && f.evaluate().isEmpty; i++) {
          if (p.pixels >= p.maxScrollExtent) break;
          p.jumpTo(
            (p.pixels + 400).clamp(p.minScrollExtent, p.maxScrollExtent),
          );
          await pump(2);
        }
      }
    }
    if (f.evaluate().isEmpty) {
      await shot(
        '${Platform.environment['ACCEPTANCE_OUTPUT']}/missing-$key.png',
      );
      throw StateError('Missing UI: $key');
    }
    await Scrollable.ensureVisible(f.evaluate().first, alignment: 0.4);
    await pump(2);
    return f;
  }

  Future<void> press(String key) async {
    final f = await seek(key), w = controller.widget<Widget>(f);
    VoidCallback? callback;
    if (w is ButtonStyleButton) callback = w.onPressed;
    if (w is IconButton) callback = w.onPressed;
    if (callback == null) throw StateError('Disabled UI: $key');
    callback();
    await pump();
  }

  Future<void> field(String key, String value) async {
    final f = await seek('medical-$key'), w = controller.widget<Widget>(f);
    if (w is TextFormField) {
      controller.state<FormFieldState<String>>(f).didChange(value);
      w.onChanged!(value);
    } else if (w is DropdownButtonFormField<String>) {
      if (w.onChanged == null) throw StateError('Disabled field');
      controller.state<FormFieldState<String>>(f).didChange(value);
      w.onChanged!(value);
    } else {
      throw StateError('Unknown field $key');
    }
    await pump();
  }

  Future<void> tick(String key) async {
    final w = controller.widget<CheckboxListTile>(await seek(key));
    if (w.onChanged == null) throw StateError('Disabled checkbox $key');
    w.onChanged!(true);
    await pump();
  }

  Future<void> hold(bool value) async {
    final w = controller.widget<SwitchListTile>(await seek('document-hold'));
    if (w.onChanged == null) throw StateError('Disabled hold');
    w.onChanged!(value);
    await pump();
  }

  Future<void> shot(String path) async {
    await pump();
    final b =
        boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 1.5);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    await File(path).writeAsBytes(bytes!.buffer.asUint8List());
    img.dispose();
  }

  String text(String key) =>
      controller.widget<Text>(find.byKey(Key(key))).data ?? '';
}
