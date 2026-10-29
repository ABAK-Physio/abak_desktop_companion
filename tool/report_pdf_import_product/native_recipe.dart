// Isolated signed application entry point. Never invoked from lib/main.dart.
// No mocked platform channels, PDF renderer, validator or DMP transport.
import 'dart:async';
import 'package:abak_desktop_companion/features/dmp_setup/dmp_setup_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/settings/macos_directory_access_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/care_episodes/screens/report_docx_pdf_screen.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_tools_access.dart';
import 'package:abak_desktop_companion/features/patients/services/document_journal_service.dart';
import '../document_business_acceptance/seed.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final roots = args.where((a) => a.startsWith('--report-pdf-root=')).toList();
  if (roots.length != 1) exit(78);
  final nativePicker = args.contains('--native-picker');
  final bundledTools = args.contains('--bundled-tools');
  if (bundledTools && !nativePicker) exit(78);
  final root = Directory(roots.single.substring('--report-pdf-root='.length));
  final rootAccess = await const MacosDirectoryAccessService().chooseDirectory(
    title: 'Autoriser uniquement le dossier synthétique de recette PDF',
    initialPath: root.path,
  );
  if (rootAccess == null || rootAccess.path != root.path) exit(78);
  if (await root.resolveSymbolicLinks() != root.path ||
      await File('${root.path}/SYNTHETIC-ONLY').readAsString() !=
          'ABAK-REPORT-PDF-RECIPE-1\n' ||
      File('${root.path}/test.sqlite').existsSync()) {
    exit(78);
  }
  final checks = <String>[];
  final errors = <String>[];
  FlutterError.onError = (e) {
    errors.add(e.toString());
  };
  void check(bool ok, String label) {
    if (!ok) throw StateError(label);
    checks.add(label);
    File(
      '${root.path}/progress.txt',
    ).writeAsStringSync('PASS $label\n', mode: FileMode.append);
  }

  Future<void> until(bool Function() ready) async {
    final end = DateTime.now().add(const Duration(minutes: 8));
    while (!ready()) {
      if (DateTime.now().isAfter(end)) throw StateError('Recipe timeout');
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
  }

  Iterable<Element> elements() sync* {
    final list = <Element>[];
    void visit(Element e) {
      list.add(e);
      e.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    yield* list;
  }

  Future<void> importFromScreen() async {
    await until(
      () => elements().any(
        (e) =>
            e.widget.key == const Key('report-import-pdf') &&
            (e.widget as FilledButton).onPressed != null,
      ),
    );
    (elements()
                .firstWhere(
                  (e) => e.widget.key == const Key('report-import-pdf'),
                )
                .widget
            as FilledButton)
        .onPressed!();
    await until(
      () => elements().any(
        (e) =>
            e.widget is Text &&
            ((e.widget as Text).data ?? '').contains('Version 1 conservée.'),
      ),
    );
  }

  try {
    await windowManager.ensureInitialized();
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Recette PDF synthétique — autorisation des outils locaux',
            ),
          ),
        ),
      ),
    );
    // Window decoration must not stall the isolated acceptance harness.
    await windowManager
        .setSize(const Size(1100, 900))
        .timeout(const Duration(seconds: 3), onTimeout: () {});
    await windowManager
        .setTitle('ABAK — Recette PDF sans dépôt')
        .timeout(const Duration(seconds: 3), onTimeout: () {});
    await windowManager.show().timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );
    final paths = Map<String, String>.from(
      jsonDecode(await File('${root.path}/tools.json').readAsString()),
    );
    final authorized =
        bundledTools ||
        await DocumentToolsAccess.authorize(
          paths,
          onStep: (s) {
            File('${root.path}/stage.txt').writeAsStringSync(s);
          },
        );
    check(
      authorized,
      bundledTools
          ? 'Aucun dossier Java ou veraPDF externe requis'
          : 'Autorisations natives des outils accordées',
    );
    sqfliteFfiInit();
    var db = await DatabaseService.openDatabaseFile(
      '${root.path}/test.sqlite',
      factory: databaseFactoryFfiNoIsolate,
    );
    final pdf = FinalPdfDocumentService(
      database: () async => db,
      root: () async => Directory('${root.path}/pdfs'),
    );
    final medical = DocumentMedicalService(
      pdf: pdf,
      now: () => DateTime.utc(2026, 10, 21, 12),
    );
    final draft = await seed(db, medical);
    await db.insert('care_episode_reports', {
      'report_id': 'SYN-R',
      'care_episode_id': 'SYN-E',
      'author_practitioner_id': 'SYN-A',
      'title': 'Rapport SYNTHETIQUE',
      'content_json': '{}',
      'status': 'saved',
      'report_date': 1,
      'created_at': 1,
    });
    final controls = DocumentControlsService(medical: medical);
    if (bundledTools) {
      final setup = DmpSetupService(database: () async => db);
      await setup.setEnabled(true);
      check(
        await setup.enabled(),
        'Activation DMP après autotests natifs positif et négatif',
      );
    } else {
      await controls.configure(paths, expectedRevision: 0);
    }
    void screen(String selected, String key) => runApp(
      MaterialApp(
        locale: const Locale('fr', 'FR'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: ReportDocxPdfScreen(
          key: ValueKey(key),
          episodeId: 'SYN-E',
          patientId: 'SYN-P',
          patientName: 'Patient SYNTHETIQUE',
          reportId: 'SYN-R',
          reportTitle: 'Rapport SYNTHETIQUE',
          pdfService: pdf,
          controlsService: controls,
          pickPdf: nativePicker ? null : () async => selected,
        ),
      ),
    );
    screen('${root.path}/conforme.pdf', 'first');
    if (nativePicker) {
      File(
        '${root.path}/stage.txt',
      ).writeAsStringSync('WAITING_NATIVE_PDF_PICKER');
      await until(
        () => elements().any(
          (e) =>
              e.widget is Text &&
              ((e.widget as Text).data ?? '').contains('Version 1 conservée.'),
        ),
      );
      check(
        elements().any(
          (e) =>
              e.widget is Text &&
              ((e.widget as Text).data ?? '').contains('PDF non conforme'),
        ),
        'Export PDF ordinaire signalé non conforme par veraPDF réel',
      );
      final version = EpisodeDocumentVersion(
        (await db.query('episode_document_versions')).single,
      );
      check(
        version.sourceKind == 'report' &&
            version.values['source_id'] == 'SYN-R',
        'Import via sélecteur natif rattaché au rapport',
      );
      check(
        (await db.query('document_medical_approvals')).isEmpty &&
            (await db.query('document_control_runs')).isEmpty,
        'Aucune validation médicale ou DMP implicite',
      );
      var blocked = false;
      try {
        await DocumentJournalService(controls: controls).prepare(version);
      } catch (_) {
        blocked = true;
      }
      check(blocked, 'Préparation DMP bloquée');
      check(
        (await db.query('document_attempts')).isEmpty &&
            (await db.query('document_chain_steps')).isEmpty,
        'Aucune signature ni tentative de dépôt',
      );
      check(errors.isEmpty, 'Aucune erreur Flutter');
      await File('${root.path}/result.json').writeAsString(
        jsonEncode({
          'passed': checks.length,
          'checks': checks,
          'nativePicker': true,
          'nativeChannels': 'real',
          'data': 'synthetic',
          'deposit': false,
          'versions': await db.query('episode_document_versions'),
        }),
      );
      await db.close();
      await File('${root.path}/stage.txt').writeAsString('SUCCESS');
      return;
    }
    await importFromScreen();
    check(
      elements().any(
        (e) =>
            e.widget is Text &&
            ((e.widget as Text).data ?? '').contains(
              'Précontrôle PDF/A-1b conforme',
            ),
      ),
      'Import depuis écran Rapport et veraPDF natif conformes',
    );
    final first = EpisodeDocumentVersion(
      (await db.query('episode_document_versions')).single,
    );
    check(
      first.sourceKind == 'report' && first.values['source_id'] == 'SYN-R',
      'PDF rattaché au rapport sans DOCX',
    );
    check(
      (await db.query('document_medical_approvals')).isEmpty &&
          (await db.query('document_control_runs')).isEmpty,
      'Précontrôle ne fabrique ni validation médicale ni contrôle DMP',
    );
    var blocked = false;
    try {
      await DocumentJournalService(controls: controls).prepare(first);
    } catch (_) {
      blocked = true;
    }
    check(blocked, 'Préparation DMP bloquée avant validation médicale et CDA');
    await medical.savePreparation(first, draft, expectedRevision: 0);
    final review = await medical.review(first);
    check(
      review.pages.length == first.pages &&
          review.pages.every((p) => p.png.isNotEmpty),
      'Toutes les pages rendues par le plugin macOS réel',
    );
    for (var i = 0; i < review.pages.length; i++) {
      await File(
        '${root.path}/page-${i + 1}.png',
      ).writeAsBytes(review.pages[i].png);
    }
    await medical.approve(
      review,
      reviewedPages: Set.from(List.generate(first.pages, (i) => i)),
      clinicalContent: true,
      correctPatient: true,
      actingAsValidator: true,
    );
    check(
      (await medical.status(first)).valid,
      'Validation médicale synthétique liée au PDF exact',
    );
    final status = await controls.run(first);
    await File('${root.path}/controls.json').writeAsString(
      jsonEncode({
        'pdfa': status.pdfa,
        'cda': status.cda,
        'message': status.message,
      }),
    );
    check(
      status.pdfa == 'conforme' && status.cda == 'conforme',
      'Contrôles PDF/A et CDA réels conformes après validation médicale',
    );
    await db.close();
    db = await DatabaseService.openDatabaseFile(
      '${root.path}/test.sqlite',
      factory: databaseFactoryFfiNoIsolate,
    );
    check(
      (await medical.status(first)).valid &&
          (await controls.status(first)).cda == 'conforme',
      'Validation et preuves conservées après réouverture de la base',
    );
    // An ordinary PDF must be retained as a new version, never promoted to PDF/A.
    screen('${root.path}/ordinaire.pdf', 'second');
    // runApp schedules a frame: never press a button from the preceding screen.
    await until(
      () => elements().any((e) => e.widget.key == const ValueKey('second')),
    );
    await until(
      () => elements().any(
        (e) =>
            e.widget.key == const Key('report-import-pdf') &&
            (e.widget as FilledButton).onPressed != null,
      ),
    );
    (elements()
                .firstWhere(
                  (e) => e.widget.key == const Key('report-import-pdf'),
                )
                .widget
            as FilledButton)
        .onPressed!();
    await until(
      () => elements().any(
        (e) =>
            e.widget is Text &&
            ((e.widget as Text).data ?? '').contains('Version 2 conservée.'),
      ),
    );
    check(
      elements().any(
        (e) =>
            e.widget is Text &&
            ((e.widget as Text).data ?? '').contains('PDF non conforme'),
      ),
      'PDF ordinaire refusé par veraPDF et conservé sans conformité',
    );
    final versions = await pdf.versions(first.documentId);
    check(
      versions.length == 2 && versions.first.number == 2,
      'Nouvelle version dans la même pièce ; ancienne version conservée',
    );
    check(
      !(await medical.status(versions.first)).valid &&
          !(await medical.status(first)).valid,
      'Nouvelle version sans héritage de validation médicale',
    );
    for (final table in [
      'document_attempts',
      'document_chain_steps',
      'document_dv1_reservations',
    ]) {
      final present = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [table],
      );
      if (present.isNotEmpty) {
        check(
          (await db.query(table)).isEmpty,
          'Aucun dépôt ni signature : $table vide',
        );
      }
    }
    check(errors.isEmpty, 'Aucune erreur Flutter');
    await File('${root.path}/result.json').writeAsString(
      jsonEncode({
        'passed': checks.length,
        'checks': checks,
        'nativeChannels': 'real',
        'renderer': 'printing macOS',
        'data': 'synthetic',
        'deposit': false,
      }),
    );
    await db.close();
    await File('${root.path}/stage.txt').writeAsString('SUCCESS');
  } catch (e, st) {
    await File(
      '${root.path}/failure.txt',
    ).writeAsString('$e\n$st\n${errors.join('\n')}');
    await File('${root.path}/stage.txt').writeAsString('FAILED');
  }
}
