import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/practitioners/data/practitioner_repository.dart';
import 'package:abak_desktop_companion/features/practitioners/practitioner_departure_screen.dart';
import 'package:abak_desktop_companion/features/practitioners/services/practitioner_departure_export_service.dart';
import 'package:abak_desktop_companion/features/maintenance/services/backup_directory_access.dart';
import 'support/companion_access_test_support.dart';

class CancelledDestination extends BackupDirectoryAccess {
  @override
  Future<BackupDirectoryLease?> choose(String title) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late PractitionerRepository repo;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('departure_ui_');
    db = await openAccessTestDatabase('${temp.path}/test.db');
    repo = PractitionerRepository(database: () async => db);
    for (final id in ['recent', 'old']) {
      await db.insert('patients', {
        'patient_id': id,
        'last_name': id,
        'first_name': 'Patient',
        'created_at': 1,
      });
      await db.insert('companion_patient_access', {
        'patient_id': id,
        'referring_practitioner_id': 'a',
      });
      await db.insert('care_episodes', {
        'care_episode_id': id,
        'patient_id': id,
        'title': 'Episode',
        'pathology_label': 'Test',
        'created_at': 1,
      });
      await db.insert('care_episode_assessments', {
        'assessment_id': id,
        'care_episode_id': id,
        'title': 'Bilan',
        'content_json': '{}',
        'created_at': 1,
        'assessment_date': id == 'recent'
            ? DateTime.now().millisecondsSinceEpoch
            : 1,
      });
    }
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });
  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 20; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await t.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> mount(WidgetTester t) async {
    t.view.physicalSize = const Size(1200, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final person = await t.runAsync(() => repo.getPractitionerById('a'));
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              child: const Text('Départ'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PractitionerDepartureScreen(
                    practitioner: person!,
                    repository: repo,
                    exporter: PractitionerDepartureExportService(
                      database: () async => db,
                      access: CancelledDestination(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('Départ'));
    await settle(t);
  }

  testWidgets(
    'recent patients preselected, selection adjustable and cancelled export never archives',
    (t) async {
      await mount(t);
      await t.tap(
        find.text('Exporter les patients actifs, à la demande du kiné'),
      );
      await t.pump();
      expect(find.text('1 patient(s) sélectionné(s)'), findsOneWidget);
      await t.tap(find.text('old Patient'));
      await t.pump();
      expect(find.text('2 patient(s) sélectionné(s)'), findsOneWidget);
      await t.tap(find.text('Exporter puis archiver'));
      await settle(t);
      expect(
        (await t.runAsync(() => repo.getPractitionerById('a')))!.archivedAt,
        isNull,
      );
      expect(find.text('Exporter puis archiver'), findsOneWidget);
    },
  );
  testWidgets(
    'archive without export returns to list and unassigns all dossiers',
    (t) async {
      await mount(t);
      await t.tap(find.text('Archiver sans export'));
      await settle(t);
      expect(find.text('Départ'), findsOneWidget);
      final rows = await t.runAsync(() => db.query('companion_patient_access'));
      expect(
        rows!.every(
          (r) =>
              r['referring_practitioner_id'] == null &&
              r['former_practitioner_id'] == 'a',
        ),
        isTrue,
      );
    },
  );
  testWidgets('administrator departure is blocked before presenting export', (
    t,
  ) async {
    await t.runAsync(
      () => db.insert('companion_practitioner_access', {
        'practitioner_id': 'a',
        'is_administrator': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace),
    );
    await mount(t);
    expect(
      find.textContaining('Retirez le statut administrateur'),
      findsOneWidget,
    );
    expect(find.text('Archiver sans export'), findsNothing);
  });
}
