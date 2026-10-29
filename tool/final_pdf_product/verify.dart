// Runs the product screen and schema against a newly created synthetic store only.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:printing/src/interface.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/database/document_versions_schema.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_mime.dart';
import 'package:abak_desktop_companion/features/patients/services/episode_document_storage_service.dart';
import 'package:abak_desktop_companion/features/patients/data/episode_document_repository.dart';
import 'package:abak_desktop_companion/features/patients/screens/episode_documents_screen.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';

class Reader implements FinalPdfInspector {
  int pages = 1;
  @override
  Future<int> inspect(Uint8List bytes) async => pages;
}

class RasterDouble extends PrintingPlatform {
  int pages = 1;
  bool broken = false;
  @override
  Stream<PdfRaster> raster(
    Uint8List document,
    List<int>? indices,
    double dpi,
  ) async* {
    if (broken) throw StateError('reader unavailable');
    for (var i = 0; i < pages; i++) {
      yield PdfRaster(1, 1, Uint8List(4));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final ctl = LiveWidgetController(binding);
  final checks = <String>[];
  final errors = <String>[];
  FlutterError.onError = (e) => errors.add(e.toString());
  final base = Directory(Platform.environment['PDF_TEST_OUTPUT']!);
  await base.create(recursive: true);
  // Always a fresh directory: no supplied database can be migrated by this harness.
  final root = await base.createTemp('synthetic-');
  void check(bool b, String name) {
    if (!b) throw StateError(name);
    checks.add(name);
    stdout.writeln('PASS $name');
  }

  Future<void> refuses(Future<dynamic> Function() action, String label) async {
    bool rejected = false;
    try {
      await action();
    } catch (_) {
      rejected = true;
    }
    check(rejected, label);
  }

  try {
    final raster = RasterDouble();
    PrintingPlatform.instance = raster;
    final nativeAdapter = PrintingFinalPdfInspector();
    check(
      await nativeAdapter.inspect(Uint8List(0)) == 1,
      'adaptateur printing compte les pages rendues',
    );
    raster.pages = 0;
    await refuses(
      () => nativeAdapter.inspect(Uint8List(0)),
      'adaptateur printing refuse zéro page',
    );
    raster.pages = 41;
    await refuses(
      () => nativeAdapter.inspect(Uint8List(0)),
      'adaptateur printing refuse plus de 40 pages',
    );
    raster.broken = true;
    await refuses(
      () => nativeAdapter.inspect(Uint8List(0)),
      'lecteur indisponible bloque import',
    );
    sqfliteFfiInit();
    final factory = databaseFactoryFfiNoIsolate;
    final dbPath = '${root.path}/synthetic.sqlite';
    var db = await DatabaseService.openDatabaseFile(dbPath, factory: factory);
    await db.insert('patients', {
      'patient_id': 'SIM-P',
      'last_name': 'SYNTHETIQUE',
      'first_name': 'TEST',
      'created_at': 1,
    });
    await db.insert('care_episodes', {
      'care_episode_id': 'SIM-E',
      'patient_id': 'SIM-P',
      'title': 'Episode fictif',
      'pathology_label': 'Fictif',
      'created_at': 1,
    });
    final source = File('${root.path}/source.pdf');
    final synthetic = pw.Document()
      ..addPage(
        pw.Page(build: (_) => pw.Text('SYNTHETIC FINAL PDF - NO REAL PATIENT')),
      );
    final bytes = await synthetic.save();
    await source.writeAsBytes(bytes);
    Future<int> decodeNative(List<int> value) async {
      final process = await Process.start('${base.path}/check-native', []);
      final out = process.stdout.transform(utf8.decoder).join();
      final err = process.stderr.drain<void>();
      process.stdin.add(value);
      await process.stdin.close();
      final code = await process.exitCode;
      await err;
      final result = await out;
      if (code != 0) throw StateError('native decoder rejected PDF');
      return int.parse(result.trim());
    }

    check(
      await decodeNative(bytes) == 1,
      'CoreGraphics décode et rend le PDF synthétique',
    );
    await refuses(
      () => decodeNative(latin1.encode('%PDF-1.4 malformed %%EOF')),
      'CoreGraphics refuse PDF structurellement invalide',
    );
    final repository = EpisodeDocumentRepository(database: () async => db);
    final legacy = await repository.create(
      caseId: 'SIM-E',
      title: 'Ancien PDF',
      filePath: source.path,
      mimeType: 'pdf',
      source: 'local_copy',
    );
    final before = await db.query('episode_documents');
    for (final table in ['patients', 'care_episodes', 'episode_documents']) {
      await db.execute('DROP TRIGGER ${table}_keep_pdf_versions');
    }
    await db.execute('DROP TABLE episode_document_versions');
    await db.setVersion(31);
    await refuses(
      () => db.transaction((txn) async {
        await createDocumentVersionsTable(txn);
        throw StateError('migration interrupted');
      }),
      'migration interrompue annulée',
    );
    check(
      (await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE name='episode_document_versions'",
          )).isEmpty &&
          await db.getVersion() == 31,
      'rollback migration conserve ancien schéma',
    );
    await db.close();
    db = await DatabaseService.openDatabaseFile(dbPath, factory: factory);
    check(await db.getVersion() == DatabaseService.schemaVersion, 'migration 31 vers schéma courant');
    check(
      jsonEncode(before) == jsonEncode(await db.query('episode_documents')),
      'migration conserve pièces et MIME historiques',
    );
    check(
      (await db.query('episode_document_versions')).isEmpty,
      'migration ne fabrique aucune version ni validation',
    );
    await createDocumentVersionsTable(db);
    check(
      (await db.query('patients')).single['patient_id'] == 'SIM-P',
      'migration réentrante conserve patient',
    );
    await db.insert('care_episodes', {
      'care_episode_id': 'SIM-E2',
      'patient_id': 'SIM-P',
      'title': 'Autre episode',
      'pathology_label': 'Fictif',
      'created_at': 1,
    });
    final dir = Directory('${root.path}/versions');
    final reader = Reader();
    FinalPdfDocumentService service({Future<void> Function(String)? hook}) =>
        FinalPdfDocumentService(
          database: () async => db,
          root: () async => dir,
          inspector: reader,
          checkpoint: hook,
        );
    final pdf = service();
    for (final kind in ['report', 'assessment']) {
      final table = kind == 'report'
          ? 'care_episode_reports'
          : 'care_episode_assessments';
      await db.insert(table, {
        '${kind}_id': 'SIM-$kind',
        'care_episode_id': 'SIM-E',
        'title': 'Synthétique $kind',
        'content_json': '{}',
        '${kind}_date': 1,
        'created_at': 1,
      });
      final origin = PdfOrigin(kind, id: 'SIM-$kind');
      final captured = await pdf.importPdf(
        episodeId: 'SIM-E',
        sourcePath: source.path,
        title: 'PDF $kind',
        origin: origin,
      );
      check(
        captured.sourceKind == kind &&
            captured.values['source_revision'] != null,
        'origine $kind et révision figées',
      );
      await refuses(
        () =>
            service(
              hook: (point) async {
                if (point == 'inspected') {
                  await db.update(
                    table,
                    {'content_json': '{"changed":true}'},
                    where: '${kind}_id=?',
                    whereArgs: ['SIM-$kind'],
                  );
                }
              },
            ).importPdf(
              episodeId: 'SIM-E',
              sourcePath: source.path,
              title: 'PDF $kind',
              origin: origin,
            ),
        'modification $kind pendant copie bloque import',
      );
    }
    final v1 = await pdf.importPdf(
      episodeId: 'SIM-E',
      documentId: legacy.documentId,
      sourcePath: source.path,
      title: 'Ancien PDF',
      origin: PdfOrigin('legacy_piece', id: legacy.documentId),
    );
    check(
      v1.number == 1 && v1.sourceKind == 'legacy_piece',
      'figer une pièce existante et mémoriser son origine',
    );
    check(
      (await repository.getById(legacy.documentId))!.mimeType ==
          'application/pdf',
      'MIME corrigé lors du figement',
    );
    check(
      await (await pdf.verifiedFile(v1)).readAsBytes().then(
        (x) => FinalPdfDocumentService.hash(x) == v1.digest,
      ),
      'copie fidèle vérifiée par empreinte',
    );
    await source.writeAsBytes(
      latin1.encode('%PDF-1.4\nchanged synthetic\n%%EOF\n'),
    );
    check(
      (await pdf.verifiedFile(v1)).path != source.path,
      'modification externe laisse ancienne version intacte',
    );
    final preview = await pdf.previewFile(v1);
    await preview.writeAsString('edited in external viewer');
    check(
      await (await pdf.verifiedFile(v1)).exists(),
      'modification de copie de consultation préserve version figée',
    );
    final v2 = await pdf.importPdf(
      episodeId: 'SIM-E',
      documentId: legacy.documentId,
      sourcePath: source.path,
      title: 'Ancien PDF',
    );
    check(
      v2.number == 2 &&
          v2.values['previous_version_id'] == v1.id &&
          v1.digest != v2.digest,
      'version 2 distincte et liée à version 1',
    );
    check(
      (await pdf.versions(legacy.documentId)).length == 2,
      'historique conserve les deux versions',
    );
    await refuses(
      () => db.update('episode_document_versions', {'sha256': '0' * 64}),
      'version SQL non modifiable',
    );
    await refuses(
      () => db.delete('episode_document_versions'),
      'version SQL non supprimable',
    );
    for (final table in ['patients', 'care_episodes', 'episode_documents']) {
      await refuses(
        () => db.delete(table),
        'suppression parent $table bloquée',
      );
    }
    await refuses(
      () => pdf.importPdf(
        episodeId: 'SIM-E2',
        documentId: legacy.documentId,
        sourcePath: source.path,
        title: 'Test',
      ),
      'pièce d’un autre épisode refusée',
    );
    await refuses(
      () => pdf.importPdf(
        episodeId: 'ABSENT',
        sourcePath: source.path,
        title: 'Test',
      ),
      'épisode absent bloqué',
    );
    await refuses(
      () =>
          pdf.importPdf(episodeId: 'SIM-E', sourcePath: source.path, title: ''),
      'titre vide bloqué',
    );
    await refuses(
      () => pdf.importPdf(
        episodeId: 'SIM-E',
        sourcePath: source.path,
        title: 'Test',
        origin: const PdfOrigin('report', id: 'ABSENT'),
      ),
      'origine clinique absente bloquée',
    );
    final invalid = File('${root.path}/invalid.pdf');
    for (final entry in {
      'vide': '',
      'non PDF': 'hello',
      'tronqué': '%PDF-1.4\npartial',
    }.entries) {
      await invalid.writeAsString(entry.value);
      await refuses(
        () => pdf.importPdf(
          episodeId: 'SIM-E',
          sourcePath: invalid.path,
          title: 'Test',
        ),
        '${entry.key} refusé',
      );
    }
    for (final pages in [0, 41]) {
      reader.pages = pages;
      await refuses(
        () => pdf.importPdf(
          episodeId: 'SIM-E',
          sourcePath: source.path,
          title: 'Test',
        ),
        'nombre de pages $pages refusé',
      );
    }
    reader.pages = 1;
    for (final point in ['inspected', 'copied', 'beforeCommit']) {
      await refuses(
        () =>
            service(
              hook: (s) async {
                if (s == point) throw StateError('synthetic fault');
              },
            ).importPdf(
              episodeId: 'SIM-E',
              documentId: legacy.documentId,
              sourcePath: source.path,
              title: 'Test',
            ),
        'interruption $point sans validation',
      );
      check(
        (await pdf.versions(legacy.documentId)).length == 2,
        'rollback $point conserve historique',
      );
      check(
        (await repository.getById(
          legacy.documentId,
        ))!.filePath.endsWith(v2.relativePath),
        'rollback $point conserve pièce courante',
      );
    }
    await refuses(
      () => service(
        hook: (s) async {
          if (s == 'inspected') await source.writeAsBytes(bytes);
        },
      ).importPdf(episodeId: 'SIM-E', sourcePath: source.path, title: 'Test'),
      'source modifiée pendant import refusée',
    );
    final entered = Completer<void>(), release = Completer<void>();
    final pending =
        service(
          hook: (s) async {
            if (s == 'inspected') {
              entered.complete();
              await release.future;
            }
          },
        ).importPdf(
          episodeId: 'SIM-E',
          sourcePath: source.path,
          title: 'Concurrent',
        );
    await entered.future;
    await refuses(
      () => pdf.importPdf(
        episodeId: 'SIM-E',
        sourcePath: source.path,
        title: 'Second',
      ),
      'import concurrent bloqué',
    );
    release.complete();
    await pending;
    final link = Link('${root.path}/link.pdf');
    await link.create(source.path);
    await refuses(
      () => pdf.importPdf(
        episodeId: 'SIM-E',
        sourcePath: link.path,
        title: 'Test',
      ),
      'source symbolique refusée',
    );
    final frozen = await pdf.verifiedFile(v1);
    final saved = await frozen.readAsBytes();
    await frozen.writeAsString('corrupted');
    await refuses(() => pdf.verifiedFile(v1), 'copie altérée bloque ouverture');
    await frozen.writeAsBytes(saved);
    await db.update(
      'episode_documents',
      {'archived_at': 1},
      where: 'document_id=?',
      whereArgs: [legacy.documentId],
    );
    await refuses(
      () => pdf.verifiedFile(v1),
      'pièce archivée bloque ouverture',
    );
    await db.update(
      'episode_documents',
      {'archived_at': null},
      where: 'document_id=?',
      whereArgs: [legacy.documentId],
    );
    final orphan = Directory(
      '${dir.path}/version-00000000-0000-0000-0000-000000000000',
    );
    await orphan.create();
    await File('${orphan.path}/document.pdf').writeAsBytes(bytes);
    check(
      await pdf.recoverOrphans() == 1 && !await orphan.exists(),
      'orphelin mis à l’écart sans effacement',
    );
    check(
      await (await pdf.verifiedFile(v2)).exists(),
      'récupération conserve toutes les versions référencées',
    );
    check(
      DocumentMime.extension('application/pdf', 'x') == 'pdf' &&
          DocumentMime.extension('pdf', 'x') == 'pdf',
      'MIME standard et historique affichés comme PDF',
    );
    check(
      await DocumentMime.forFile(source) == 'application/pdf',
      'MIME PDF détecté sur contenu',
    );
    final docx = File('${root.path}/rapport.docx');
    await docx.writeAsString('synthetic docx');
    check(
      (await DocumentMime.forFile(docx)).contains('wordprocessingml'),
      'MIME DOCX conservé pour pièce ordinaire',
    );
    await db.close();
    db = await DatabaseService.openDatabaseFile(dbPath, factory: factory);
    check(
      (await pdf.versions(legacy.documentId)).length == 2 &&
          await (await pdf.verifiedFile(v1)).exists(),
      'réouverture base conserve versions et fichiers',
    );

    Future<void> pump() async {
      for (var i = 0; i < 8; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await ctl.pump();
      }
    }

    String? selected = source.path;
    final opened = <String>[];
    Future<void> mount() async {
      runApp(const SizedBox.shrink());
      await pump();
      runApp(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: EpisodeDocumentsScreen(
            caseId: 'SIM-E',
            caseLabel: 'Episode synthétique',
            repository: repository,
            storage: EpisodeDocumentStorageService(
              supportDirectory: () async => root,
            ),
            finalPdfService: pdf,
            pickFile: (_) async => selected,
            openFile: (s) async {
              opened.add(s);
            },
            showExpertInfo: false,
          ),
        ),
      );
      await pump();
    }

    await mount();
    check(
      find.byKey(const Key('import-final-pdf')).evaluate().isNotEmpty,
      'écran métier existant propose import PDF final',
    );
    final count = (await db.query('episode_document_versions')).length;
    ctl
        .widget<FilledButton>(find.byKey(const Key('import-final-pdf')))
        .onPressed!();
    await pump();
    check(
      find.byKey(const Key('confirm-final-import')).evaluate().isNotEmpty,
      'dialogue de rattachement avant import',
    );
    ctl
        .widget<FilledButton>(find.byKey(const Key('confirm-final-import')))
        .onPressed!();
    await pump();
    await pump();
    check(
      (await db.query('episode_document_versions')).length == count + 1,
      'import depuis écran crée une version',
    );
    check(
      find
          .textContaining('Validation médicale non effectuée')
          .evaluate()
          .isNotEmpty,
      'message distingue import et validation médicale',
    );
    await mount();
    check(
      find.textContaining('PDF final · version').evaluate().isNotEmpty,
      'écran après réouverture montre versions persistées',
    );
    final current = (await db.query(
      'episode_document_versions',
      orderBy: 'captured_at DESC',
    )).first;
    final currentId = current['document_id'] as String;
    ctl
        .widget<PopupMenuButton<String>>(
          find.byKey(Key('document-actions-$currentId')),
        )
        .onSelected!('new');
    await pump();
    ctl
        .widget<FilledButton>(find.byKey(const Key('confirm-final-import')))
        .onPressed!();
    await pump();
    await pump();
    check(
      (await pdf.versions(currentId)).length == 2,
      'nouvelle version depuis menu métier conserve ancienne version',
    );
    ctl
        .widget<PopupMenuButton<String>>(
          find.byKey(Key('document-actions-$currentId')),
        )
        .onSelected!('history');
    await pump();
    check(
      find.textContaining('Versions —').evaluate().isNotEmpty,
      'historique accessible depuis écran métier',
    );
    Navigator.of(ctl.element(find.byType(AlertDialog))).pop();
    await pump();
    selected = docx.path;
    ctl
        .widget<FilledButton>(find.byKey(const Key('add-ordinary-document')))
        .onPressed!();
    await pump();
    await pump();
    check(
      (await repository.getByCaseId('SIM-E')).any(
        (d) =>
            d.title == 'rapport.docx' &&
            (d.mimeType ?? '').contains('wordprocessingml'),
      ),
      'ajout ordinaire DOCX fonctionne dans écran existant',
    );
    selected = null;
    ctl
        .widget<FilledButton>(find.byKey(const Key('import-final-pdf')))
        .onPressed!();
    await pump();
    check(
      (await db.query('episode_document_versions')).length == count + 2,
      'annulation sélecteur sans nouvelle version',
    );
    check(errors.isEmpty, 'aucune erreur Flutter: ${errors.join(';')}');
    await db.close();
    await File('${base.path}/result.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'passed': checks.length,
        'checks': checks,
        'synthetic_root': root.path,
        'network': 'denied by sandbox',
        'inspector':
            'Injected renderer for fault tests; production Printing adapter checked with platform double; CoreGraphics decoded and rendered a valid synthetic PDF in a separate native probe. Installed app not launched.',
      }),
    );
    stdout.writeln('SUCCESS ${checks.length}');
    exit(0);
  } catch (e, st) {
    stderr.writeln('$e\n$st');
    await File(
      '${base.path}/failure.txt',
    ).writeAsString('$e\n$st\n${errors.join('\n')}');
    exit(1);
  }
}
