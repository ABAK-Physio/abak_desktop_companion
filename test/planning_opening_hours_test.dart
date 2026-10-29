import 'dart:io';

import 'package:abak_desktop_companion/features/planning/models/planning_opening_hours.dart';
import 'package:abak_desktop_companion/features/planning/data/planning_opening_hours_repository.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_opening_hours_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  Map<int, List<OpeningPeriod>> closed() => {
    for (var day = 1; day <= 7; day++) day: [],
  };
  test(
    'weekly hours validate, sort, distinguish closed days and reject corrupt settings',
    () {
      final hours = PlanningOpeningHours({
        ...closed(),
        1: [OpeningPeriod(840, 1080), OpeningPeriod(480, 720)],
        6: [OpeningPeriod(540, 780)],
      });
      expect(hours.days[1]!.first.start, 480);
      expect(hours.days[7], isEmpty);
      expect(
        PlanningOpeningHours.decode(hours.encode()).encode(),
        hours.encode(),
      );
      expect(() => OpeningPeriod(419, 600), throwsArgumentError);
      expect(() => OpeningPeriod(600, 1261), throwsArgumentError);
      expect(() => OpeningPeriod(600, 600), throwsArgumentError);
      expect(
        () => PlanningOpeningHours({
          ...closed(),
          1: [OpeningPeriod(480, 720), OpeningPeriod(700, 800)],
        }),
        throwsArgumentError,
      );
      expect(() => PlanningOpeningHours({1: []}), throwsArgumentError);
      expect(
        () => PlanningOpeningHours.decode('{"version":2,"days":[]}'),
        throwsFormatException,
      );
      expect(
        () => PlanningOpeningHours.decode('invalid'),
        throwsFormatException,
      );
    },
  );

  test(
    'SQLite persists hours across reopening, without touching other settings',
    () async {
      sqfliteFfiInit();
      final temp = await Directory.systemTemp.createTemp('planning_hours_');
      var db = await databaseFactoryFfi.openDatabase('${temp.path}/test.db');
      addTearDown(() async {
        await db.close();
        await temp.delete(recursive: true);
      });
      await db.execute(
        'CREATE TABLE application_settings(setting_key TEXT PRIMARY KEY, setting_value TEXT NOT NULL, updated_at INTEGER NOT NULL)',
      );
      await db.insert('application_settings', {
        'setting_key': 'other',
        'setting_value': 'keep',
        'updated_at': 1,
      });
      final repository = PlanningOpeningHoursRepository(
        database: () async => db,
      );
      expect(await repository.load(), isNull);
      final hours = PlanningOpeningHours({
        ...closed(),
        1: [OpeningPeriod(480, 720), OpeningPeriod(840, 1080)],
      });
      await repository.save(hours);
      await db.close();
      db = await databaseFactoryFfi.openDatabase('${temp.path}/test.db');
      expect((await repository.load())!.encode(), hours.encode());
      expect(
        (await db.query(
          'application_settings',
          where: 'setting_key = ?',
          whereArgs: ['other'],
        )).single['setting_value'],
        'keep',
      );
      await repository.save(PlanningOpeningHours(closed()));
      expect(
        (await repository.load())!.days.values.every((day) => day.isEmpty),
        isTrue,
      );
      await db.update(
        'application_settings',
        {'setting_value': 'corrupt'},
        where: 'setting_key = ?',
        whereArgs: [PlanningOpeningHoursRepository.settingKey],
      );
      await expectLater(repository.load(), throwsFormatException);
      expect(
        (await db.query(
          'application_settings',
          where: 'setting_key = ?',
          whereArgs: [PlanningOpeningHoursRepository.settingKey],
        )).single['setting_value'],
        'corrupt',
      );
    },
  );

  testWidgets(
    'edit opening periods, validate overlap, retry save, reopen and cancel',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 650);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      PlanningOpeningHours? stored;
      var failSave = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('Configurer'),
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (_) => PlanningOpeningHoursDialog(
                    load: () async => stored,
                    save: (hours) async {
                      if (failSave) throw StateError('disk');
                      stored = hours;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Configurer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Aucun horaire enregistré'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('opening-day-0')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '08:00');
      await tester.enterText(find.byType(TextFormField).at(1), '12:00');
      await tester.ensureVisible(find.byKey(const ValueKey('opening-add-0')));
      await tester.tap(find.byKey(const ValueKey('opening-add-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('ne doivent pas se chevaucher'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.byType(TextFormField).at(2));
      await tester.enterText(find.byType(TextFormField).at(2), '14:00');
      await tester.enterText(find.byType(TextFormField).at(3), '18:00');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Votre saisie est conservée'), findsOneWidget);
      expect(stored, isNull);
      failSave = false;
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(stored!.days[1]!.length, 2);
      expect(stored!.days[2], isEmpty);
      expect(stored!.days[1]!.last.end, 1080);
      final before = stored!.encode();
      await tester.tap(find.text('Configurer'));
      await tester.pumpAndSettle();
      expect(find.text('08:00'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('opening-day-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(stored!.encode(), before);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'load error blocks save and allows retry without invented hours',
    (tester) async {
      var fail = true;
      var saves = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlanningOpeningHoursDialog(
              load: () async {
                if (fail) throw const FormatException();
                return null;
              },
              save: (_) async {
                saves++;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(saves, 0);
      fail = false;
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Aucun horaire enregistré'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
