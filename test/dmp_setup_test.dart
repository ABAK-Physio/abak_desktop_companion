import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/dmp_setup/bundled_pdf_tools.dart';
import 'package:abak_desktop_companion/features/dmp_setup/dmp_setup_service.dart';
import 'package:abak_desktop_companion/features/dmp_setup/dmp_setup_tile.dart';

class SettingsDb implements Database {
  String? value;
  String? idle;
  String? patientPerson;
  int writes = 0;
  bool legacyTools = false;
  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (table == 'document_control_config') {
      return legacyTools
          ? [
              {'id': 1},
            ]
          : [];
    }
    expectSync(table, 'application_settings');
    if (whereArgs?.single == DmpSetupService.idleKey) {
      return idle == null
          ? []
          : [
              {'setting_value': idle},
            ];
    }
    if (whereArgs?.single == DmpSetupService.patientPersonKey) {
      return patientPerson == null
          ? []
          : [
              {'setting_value': patientPerson},
            ];
    }
    expectSync(whereArgs, [DmpSetupService.key]);
    return value == null
        ? []
        : [
            {'setting_value': value},
          ];
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    expectSync(table, 'application_settings');
    if (values['setting_key'] == DmpSetupService.idleKey) {
      idle = values['setting_value'] as String;
      return ++writes;
    }
    if (values['setting_key'] == DmpSetupService.patientPersonKey) {
      patientPerson = values['setting_value'] as String;
      return ++writes;
    }
    expectSync(values['setting_key'], DmpSetupService.key);
    value = values['setting_value'] as String;
    return ++writes;
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw StateError('Unexpected access: $i');
}

void main() {
  test('idle delay is bounded, persisted and defaults safely', () async {
    final db = SettingsDb();
    final service = DmpSetupService(database: () async => db);
    expect(await service.idleMinutes(), 15);
    await service.setIdleMinutes(30);
    expect(await DmpSetupService(database: () async => db).idleMinutes(), 30);
    await expectLater(service.setIdleMinutes(0), throwsArgumentError);
    db.idle = 'invalid';
    expect(await service.idleMinutes(), 15);
    expect(db.value, isNull);
  });
  test('DMP requires explicit activation even with legacy tools', () async {
    final db = SettingsDb()..legacyTools = true;
    final service = DmpSetupService(database: () async => db);
    expect(await service.enabled(), false);
    await expectLater(DmpSetupService.requireEnabled(db), throwsStateError);
    db.value = 'true';
    expect(await service.enabled(), true);
    await DmpSetupService.requireEnabled(db);
    db.value = 'false';
    expect(await service.enabled(), false);
    await expectLater(DmpSetupService.requireEnabled(db), throwsStateError);
    expect(db.writes, 0);
  });
  test(
    'activation only commits after successful probes; disabling does not probe',
    () async {
      final db = SettingsDb();
      var probes = 0;
      final service = DmpSetupService(
        database: () async => db,
        tools: () async => const BundledPdfTools('/java', '/vera', 'hash'),
        probe: (_) async {
          probes++;
          expect(db.writes, 0);
        },
      );
      expect(await service.enabled(), false);
      await service.setEnabled(true);
      expect(await service.enabled(), true);
      expect(probes, 1);
      await service.setEnabled(false);
      expect(probes, 1);
      expect(await service.enabled(), false);
      await expectLater(
        DmpSetupService.requireNotDisabled(db),
        throwsStateError,
      );
    },
  );
  for (final failure in ['missing', 'probe', 'changed']) {
    test(
      '$failure refuses activation without writing a false success',
      () async {
        final db = SettingsDb()..value = 'false';
        var reads = 0;
        final service = DmpSetupService(
          database: () async => db,
          tools: () async {
            if (failure == 'missing') throw StateError('absent');
            return BundledPdfTools(
              '/java',
              '/vera',
              failure == 'changed' ? '${reads++}' : 'same',
            );
          },
          probe: (_) async {
            if (failure == 'probe') throw StateError('failed');
          },
        );
        await expectLater(service.setEnabled(true), throwsStateError);
        expect(db.value, 'false');
        expect(db.writes, 0);
      },
    );
  }
  test(
    'bundle integrity rejects changed, additional and missing files',
    () async {
      final temp = await Directory.systemTemp.createTemp('dmp-tools-test-');
      final root = Directory(await temp.resolveSymbolicLinks());
      addTearDown(() => root.delete(recursive: true));
      final files = <String, String>{};
      for (final path in ['java/bin/java', 'vera/cli.jar', 'NOTICE.txt']) {
        final file = File('${root.path}/$path');
        await file.parent.create(recursive: true);
        await file.writeAsString('synthetic');
        files[path] = sha256.convert(await file.readAsBytes()).toString();
      }
      await File('${root.path}/manifest.json').writeAsString(
        jsonEncode({'protocol': 1, 'profile': 'PDF/A-1b', 'files': files}),
      );
      expect(
        (await BundledPdfTools.verify(root)).java,
        '${root.path}/java/bin/java',
      );
      final jar = File('${root.path}/vera/cli.jar');
      await jar.writeAsString('modified');
      await expectLater(BundledPdfTools.verify(root), throwsStateError);
      await jar.writeAsString('synthetic');
      final extra = File('${root.path}/vera/extra.jar');
      await extra.writeAsString('extra');
      await expectLater(BundledPdfTools.verify(root), throwsStateError);
      await extra.delete();
      await jar.delete();
      await expectLater(BundledPdfTools.verify(root), throwsStateError);
    },
  );
  testWidgets('activation failure keeps switch off with actionable error', (
    tester,
  ) async {
    final db = SettingsDb();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DmpSetupTile(
            service: DmpSetupService(
              database: () async => db,
              tools: () async => throw StateError('Outils absents'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      false,
    );
    expect(find.textContaining('Outils absents'), findsOneWidget);
    expect(db.writes, 0);
  });
}
