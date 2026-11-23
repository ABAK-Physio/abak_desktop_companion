import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/patient_reassignment_screen.dart';
import 'package:abak_desktop_companion/features/companion_access/patient_reassignment_models.dart';
import 'support/companion_access_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late CompanionAccessService auth;
  late String key;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('reassignment_ui_');
    db = await openAccessTestDatabase('${temp.path}/test.db');
    auth = CompanionAccessService(
      database: () async => db,
      hasher: FastTestCodeHasher(),
    );
    await auth.initializeAdministrator('a', 'admin', '0123');
    key = await auth.generateRecoveryKey(actorId: 'a', actorCode: '0123');
    for (final id in ['p', 'q', 'r']) {
      await db.insert('patients', {
        'patient_id': id,
        'last_name': 'Patient',
        'first_name': id,
        'created_at': 1,
        if (id == 'q') 'archived_at': 2,
      });
      await db.insert('companion_patient_access', {
        'patient_id': id,
        'referring_practitioner_id': 'a',
      });
    }
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 15; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(home: PatientReassignmentScreen(service: auth)),
    );
    await settle(tester);
    await tester.tap(find.byType(DropdownButtonFormField<ReassignmentSource>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kiné A — 3 dossier(s)').last);
    await settle(tester);
  }

  Future<void> target(WidgetTester tester, int row, String name) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(row));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  Future<void> confirm(WidgetTester tester, int count, {String? secret}) async {
    await tester.tap(find.text('Vérifier et réaffecter ($count)'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmer la réaffectation'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), secret ?? key);
    await tester.tap(find.text('Confirmer'));
    await settle(tester);
  }

  testWidgets(
    'bulk preview names every patient; cancelling changes nothing; key required to commit',
    (tester) async {
      await mount(tester);
      await target(tester, 0, 'Kiné B');
      await tester.tap(find.text('Vérifier et réaffecter (3)'));
      await tester.pumpAndSettle();
      expect(find.text('Patient q (dossier archivé) → Kiné B'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(
        (await tester.runAsync(() => auth.reassignmentPatients('a')))!,
        hasLength(3),
      );
      await confirm(tester, 3, secret: '0123');
      expect(find.text('Code incorrect.'), findsOneWidget);
      expect(
        (await tester.runAsync(() => auth.reassignmentPatients('a')))!,
        hasLength(3),
      );
      await confirm(tester, 3);
      expect(find.text('3 dossier(s) réaffecté(s).'), findsOneWidget);
      expect(
        (await tester.runAsync(() => auth.reassignmentPatients('b')))!,
        hasLength(3),
      );
    },
  );
  testWidgets(
    'line mode transfers selected patients to different kinés and skips the other row',
    (tester) async {
      await mount(tester);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      await target(tester, 0, 'Kiné B');
      await target(tester, 1, 'Kiné C');
      await confirm(tester, 2);
      expect(find.text('2 dossier(s) réaffecté(s).'), findsOneWidget);
      final rows = (await tester.runAsync(
        () => db.query('companion_patient_access'),
      ))!;
      final refs = {
        for (final row in rows)
          row['patient_id']: row['referring_practitioner_id'],
      };
      expect(refs, {'p': 'b', 'q': 'c', 'r': 'a'});
    },
  );
  testWidgets(
    'a changed referrer after preview blocks the whole confirmation',
    (tester) async {
      await mount(tester);
      await target(tester, 0, 'Kiné B');
      await tester.runAsync(
        () => db.update('companion_patient_access', {
          'referring_practitioner_id': 'c',
        }, where: "patient_id = 'q'"),
      );
      await confirm(tester, 3);
      expect(
        find.textContaining('Les dossiers ou leur référent ont changé.'),
        findsOneWidget,
      );
      expect(
        (await tester.runAsync(() => auth.reassignmentPatients('b')))!,
        isEmpty,
      );
    },
  );
}
