import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/import_export/abak_package.dart';
import 'package:abak_desktop_companion/features/import_export/import_resolution_screen.dart';
import 'package:abak_desktop_companion/features/care_episodes/data/care_episode_repository.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

Future<void> settleDatabase(WidgetTester tester) async {
  // SQLite uses real asynchronous work outside the widget test's fake clock.
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

void main() {
  late Directory directory;
  late PathProviderPlatform previous;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('abak_import_episodes_');
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(directory.path);
    final db = await DatabaseService.database;
    for (final id in ['p1', 'p2']) {
      await db.insert('patients', {
        'patient_id': id,
        'last_name': 'Patient',
        'first_name': id,
        'created_at': 1,
      });
      await db.insert('care_episodes', {
        'care_episode_id': 'e$id',
        'patient_id': id,
        'title': 'Prise en charge $id',
        'pathology_label': 'Pathologie $id',
        'created_at': 1,
        'initial_report': 'Bilan initial',
        'final_conclusion': 'Conclusion conservée',
        'treatment_plan': 'Traitement conservé',
      });
    }
  });
  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    await directory.delete(recursive: true);
  });

  Future<void> openImport(
    WidgetTester tester,
    ValueChanged<ImportAssignment?> onResult,
  ) async {
    tester.view.physicalSize = const Size(1700, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr', 'FR'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => onResult(
                await Navigator.of(context).push<ImportAssignment>(
                  MaterialPageRoute(
                    builder: (_) => ImportResolutionScreen(
                      package: AbakPackage.fromJson({
                        'exportedAt': 1,
                        'clinicalEpisode': {
                          'pathology_label': 'Pathologie mobile',
                        },
                      }),
                    ),
                  ),
                ),
              ),
              child: const Text('Importer'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Importer'));
    await settleDatabase(tester);
    await tester.tap(find.text('Patient p1'));
    await settleDatabase(tester);
  }

  testWidgets(
    'Import archives only after confirmation, restores, and selects the restored episode',
    (tester) async {
      ImportAssignment? assignment;
      await openImport(tester, (result) => assignment = result);
      expect(find.text('Prises en charge archivées'), findsOneWidget);
      expect(find.text('Choisir'), findsOneWidget);
      expect(find.textContaining('Pathologie p2'), findsNothing);
      await tester.tap(find.byTooltip('Archiver la prise en charge'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.text('Choisir'), findsOneWidget);
      await tester.tap(find.byTooltip('Archiver la prise en charge'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archiver'));
      await settleDatabase(tester);
      expect(find.text('Choisir'), findsNothing);
      expect(find.text('Restaurer'), findsOneWidget);
      expect(assignment, isNull);
      await tester.tap(find.text('Restaurer'));
      await settleDatabase(tester);
      expect(find.text('Restaurer'), findsNothing);
      expect(find.text('Choisir'), findsOneWidget);
      await tester.tap(find.text('Choisir'));
      await settleDatabase(tester);
      expect(assignment?.patient.patientId, 'p1');
      expect(assignment?.careEpisode.careEpisodeId, 'ep1');
      expect(assignment?.careEpisode.finalConclusion, 'Conclusion conservée');
      expect(assignment?.careEpisode.isArchived, isFalse);
    },
  );

  testWidgets(
    'Shared editing preserves clinical content and creation stays available for explicit selection',
    (tester) async {
      ImportAssignment? assignment;
      await openImport(tester, (result) => assignment = result);
      await tester.tap(find.byTooltip('Modifier'));
      await settleDatabase(tester);
      await tester.enterText(
        find.byType(TextField).first,
        'Pathologie corrigée',
      );
      await tester.tap(
        find.widgetWithText(FilledButton, S.current.patientDetail_save),
      );
      await settleDatabase(tester);
      final updated = await tester.runAsync(
        () => CareEpisodeRepository().getEpisodeById('ep1'),
      );
      expect(updated?.pathologyLabel, 'Pathologie corrigée');
      expect(updated?.finalConclusion, 'Conclusion conservée');
      expect(updated?.treatmentPlan, 'Traitement conservé');
      await tester.tap(find.text('Nouvelle prise en charge'));
      await settleDatabase(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller?.text,
        'Pathologie mobile',
      );
      expect(find.byType(TextField), findsNWidgets(2));
      await tester.enterText(
        find.byType(TextField).at(1),
        'Bilan de la nouvelle prise en charge',
      );
      await tester.tap(
        find.widgetWithText(FilledButton, S.current.patientDetail_create),
      );
      await settleDatabase(tester);
      expect(assignment, isNull);
      expect(find.text('Choisir'), findsNWidgets(2));
      final episodes = await tester.runAsync(
        () => CareEpisodeRepository().getEpisodesForPatient('p1'),
      );
      final created = episodes!.firstWhere((e) => e.careEpisodeId != 'ep1');
      expect(created.pathologyLabel, 'Pathologie mobile');
      expect(created.initialReport, 'Bilan de la nouvelle prise en charge');
      await tester.tap(find.text('Patient p2'));
      await settleDatabase(tester);
      expect(
        find.textContaining('Pathologie : Pathologie mobile'),
        findsNothing,
      );
      expect(find.text('Choisir'), findsOneWidget);
      await tester.tap(find.text('Choisir'));
      await settleDatabase(tester);
      expect(assignment?.patient.patientId, 'p2');
      expect(assignment?.careEpisode.careEpisodeId, 'ep2');
    },
  );
}
