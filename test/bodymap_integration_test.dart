import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode.dart';
import 'package:abak_desktop_companion/features/care_episodes/screens/care_episode_reports_workspace/widgets/episode_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/bodymap/bodymap_repository.dart';
import 'package:abak_desktop_companion/features/bodymap/episode_bodymap_screen.dart';
import 'package:abak_desktop_companion/features/bodymap/body_map_adapter.dart';
import 'package:abak_desktop_companion/features/bodymap/joint_map_adapter.dart';
import 'package:abak_desktop_companion/features/bodymap/pain_record.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

class _MemoryRepository extends BodymapRepository {
  PainRecord? record;
  bool fail = false;
  @override
  Future<PainRecord?> load({
    required String careEpisodeId,
    required String patientId,
  }) async => record;
  @override
  Future<void> save({
    required String careEpisodeId,
    required String patientId,
    required PainRecord record,
  }) async {
    if (fail) throw StateError('Échec simulé');
    this.record = PainRecord.fromJson(record.toJson());
  }
}

class _Picker extends FilePicker {
  _Picker(this.output);
  final String output;
  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async => output;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late PathProviderPlatform previous;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('abak_bodymap_test_');
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(directory.path);
  });
  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    await directory.delete(recursive: true);
  });
  Future<void> seed(Database db) async {
    for (final id in ['p1', 'p2']) {
      await db.insert('patients', {
        'patient_id': id,
        'last_name': 'Test',
        'first_name': id,
        'created_at': 1,
      });
    }
    for (final id in ['e1', 'e2', 'e3']) {
      await db.insert('care_episodes', {
        'care_episode_id': id,
        'patient_id': id == 'e3' ? 'p2' : 'p1',
        'title': id,
        'pathology_label': 'Test',
        'created_at': 1,
      });
    }
  }

  test(
    'Records persist across database reopen and are isolated by episode and patient',
    () async {
      final db = await DatabaseService.database;
      await seed(db);
      final repo = BodymapRepository();
      await repo.save(
        careEpisodeId: 'e1',
        patientId: 'p1',
        record: PainRecord({
          'front-arm-left': PainEntry(intensity: 0, note: 'Droite'),
          'joint:f69': PainEntry(note: 'Rachis'),
        }),
      );
      await DatabaseService.closeDatabase();
      final saved = await repo.load(careEpisodeId: 'e1', patientId: 'p1');
      expect(saved!.entries['front-arm-left']!.intensity, 0);
      expect(saved.entries['joint:f69']!.note, 'Rachis');
      expect(await repo.load(careEpisodeId: 'e2', patientId: 'p1'), isNull);
      expect(await repo.load(careEpisodeId: 'e3', patientId: 'p2'), isNull);
      await expectLater(
        repo.load(careEpisodeId: 'e1', patientId: 'p2'),
        throwsStateError,
      );
      await expectLater(
        repo.save(careEpisodeId: 'e1', patientId: 'p2', record: PainRecord({})),
        throwsStateError,
      );
      expect(
        (await repo.load(careEpisodeId: 'e1', patientId: 'p1'))!.entries.length,
        2,
      );
      await repo.save(
        careEpisodeId: 'e1',
        patientId: 'p1',
        record: PainRecord({}),
      );
      expect(
        (await repo.load(careEpisodeId: 'e1', patientId: 'p1'))!.entries,
        isEmpty,
      );
    },
  );
  test(
    'Migration from version 28 preserves the episode and existing content',
    () async {
      sqfliteFfiInit();
      final path = await DatabaseService.databasePath;
      final old = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 28,
          onCreate: (db, v) async {
            await db.execute(
              'CREATE TABLE care_episodes (care_episode_id TEXT PRIMARY KEY, patient_id TEXT, archived_at INTEGER, initial_report TEXT)',
            );
            await db.insert('care_episodes', {
              'care_episode_id': 'old',
              'patient_id': 'p1',
              'initial_report': 'Bilan conservé',
            });
          },
        ),
      );
      await old.close();
      final current = await DatabaseService.database;
      expect(await current.getVersion(), 29);
      expect(
        (await current.query('care_episodes')).single['initial_report'],
        'Bilan conservé',
      );
      final repo = BodymapRepository();
      await repo.save(
        careEpisodeId: 'old',
        patientId: 'p1',
        record: PainRecord({'front-head': PainEntry()}),
      );
      expect(
        (await repo.load(
          careEpisodeId: 'old',
          patientId: 'p1',
        ))!.entries.length,
        1,
      );
    },
  );
  test(
    'Unknown regions or invalid intensity cannot overwrite a valid map',
    () async {
      await seed(await DatabaseService.database);
      final repo = BodymapRepository();
      await repo.save(
        careEpisodeId: 'e1',
        patientId: 'p1',
        record: PainRecord({'front-head': PainEntry(note: 'Conserver')}),
      );
      await expectLater(
        repo.save(
          careEpisodeId: 'e1',
          patientId: 'p1',
          record: PainRecord({'unknown': PainEntry()}),
        ),
        throwsFormatException,
      );
      await expectLater(
        repo.save(
          careEpisodeId: 'e1',
          patientId: 'p1',
          record: PainRecord({'front-head': PainEntry(intensity: 11)}),
        ),
        throwsFormatException,
      );
      expect(
        (await repo.load(
          careEpisodeId: 'e1',
          patientId: 'p1',
        ))!.entries['front-head']!.note,
        'Conserver',
      );
    },
  );
  testWidgets(
    'Two views retain annotations; failed save prevents closing; successful save reopens',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _MemoryRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EpisodeBodymapScreen(
                      careEpisodeId: 'e1',
                      patientId: 'p1',
                      patientName: 'Patient fictif',
                      episodeLabel: 'Épisode test',
                      repository: repository,
                    ),
                  ),
                ),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      tester.widget<BodyMapAdapter>(find.byType(BodyMapAdapter)).onSelect!(
        'front-arm-left',
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Observation muscle');
      await tester.tap(find.text('Articulations / rachis (0)'));
      await tester.pumpAndSettle();
      tester.widget<JointMapAdapter>(find.byType(JointMapAdapter)).onSelect!(
        'joint:f69',
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Observation rachis');
      repository.fail = true;
      await tester.tap(find.byTooltip('Retour aux bilans et rapports'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer et fermer'));
      await tester.pumpAndSettle();
      expect(find.byType(EpisodeBodymapScreen), findsOneWidget);
      expect(find.textContaining('Échec simulé'), findsOneWidget);
      repository.fail = false;
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Retour aux bilans et rapports'));
      await tester.pumpAndSettle();
      expect(find.text('Ouvrir'), findsOneWidget);
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<BodyMapAdapter>(find.byType(BodyMapAdapter)).selected,
        contains('front-arm-left'),
      );
      expect(
        repository.record!.entries['joint:f69']!.note,
        'Observation rachis',
      );
      expect(
        repository.record!.entries['front-arm-left']!.note,
        'Observation muscle',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Silhouette icon in episode header opens its action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    bool opened = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: EpisodeHeader(
            episode: const CareEpisode(
              careEpisodeId: 'e1',
              patientId: 'p1',
              title: 'Test',
              pathologyLabel: 'Épisode test',
              createdAt: 1,
            ),
            practitionerFuture: Future.value(null),
            prescribingCorrespondentFuture: Future.value(null),
            onEditPractitioner: () {},
            onShowHistory: () {},
            onOpenDocuments: () {},
            onOpenBodymap: () => opened = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.accessibility_new), findsOneWidget);
    await tester.tap(find.byTooltip('Carte des douleurs'));
    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'PNG export contains both charts without saving or losing annotations',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final output = File('${directory.path}/bodymap.png');
      FilePicker.platform = _Picker(output.path);
      final repository = _MemoryRepository()
        ..record = PainRecord({
          'front-arm-left': PainEntry(note: 'Muscle'),
          'joint:f69': PainEntry(note: 'Rachis'),
        });
      await tester.pumpWidget(
        MaterialApp(
          home: EpisodeBodymapScreen(
            careEpisodeId: 'e1',
            patientId: 'p1',
            patientName: 'Patient fictif',
            episodeLabel: 'Épisode test',
            repository: repository,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exporter les deux cartes'));
      for (var i = 0; i < 20; i++) {
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        if (find.textContaining('Deux cartes exportées :').evaluate().isNotEmpty) break;
      }
      await tester.pumpAndSettle();
      expect(output.existsSync(), isTrue);
      final png = output.readAsBytesSync();
      expect(png.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      final data = ByteData.sublistView(png);
      expect(data.getUint32(20), greaterThan(data.getUint32(16) * 2));
      // Optional review artifact, containing fictitious data only.
      final review = Platform.environment['BODYMAP_REVIEW_DIR'];
      if (review != null) {
        Directory(review).createSync(recursive: true);
        File('$review/cartes-integrees.png').writeAsBytesSync(png);
      }
      expect(repository.record!.entries.length, 2);
      expect(find.byType(BodyMapAdapter), findsOneWidget);
      expect(find.byType(JointMapAdapter), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
