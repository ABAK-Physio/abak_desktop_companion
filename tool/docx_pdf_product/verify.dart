// Only the user-approved conversion/empty-document/versioning recipe.
// The channel forwards to the actual signed XPC service; no converter verdicts
// or PDF/A results are simulated. The data and medical attestations are synthetic.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: implementation_imports
import 'package:printing/src/interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/patients/data/episode_document_repository.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/screens/episode_documents_screen.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_native_controls.dart';
import 'package:abak_desktop_companion/features/patients/services/document_native_launcher.dart';
import 'package:abak_desktop_companion/features/patients/services/document_journal_service.dart';
import '../document_business_acceptance/seed.dart';
import '../document_business_acceptance/ui.dart';

class RecipeBinding extends WidgetsFlutterBinding
    with TestDefaultBinaryMessengerBinding {}

Future<void> main() async {
  final binding = RecipeBinding();
  final out = Directory(Platform.environment['DOCX_OUTPUT']!);
  final repo = Platform.environment['DOCX_REPO']!;
  final results = <String>[], errors = <String>[];
  var nativeCalls = 0;
  void check(bool ok, String label) {
    if (!ok) throw StateError(label);
    results.add(label);
    stdout.writeln('PASS $label');
  }

  FlutterError.onError = (e) {
    errors.add(e.toString());
    stderr.writeln(e);
  };
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    NativeDocumentLauncher.channel,
    (call) async {
      if (call.method != 'run') {
        throw StateError('Unexpected channel operation');
      }
      final n = ++nativeCalls;
      final request = File('${out.path}/request-$n.json');
      final response = File('${out.path}/response-$n.json');
      await request.writeAsString(jsonEncode(call.arguments));
      final process = await Process.run(
        '${out.path}/DocxRecipe.app/Contents/MacOS/DocxRecipe',
        [request.path, response.path],
      );
      if (process.exitCode != 0) throw StateError('XPC: ${process.stderr}');
      return jsonDecode(await response.readAsString());
    },
  );
  try {
    await S.load(const Locale('fr', 'FR'));
    sqfliteFfiInit();
    final root = Directory('${out.path}/synthetic-product');
    if (root.existsSync()) throw StateError('Fresh synthetic store required');
    await root.create();
    var db = await DatabaseService.openDatabaseFile(
      '${root.path}/test.sqlite',
      factory: databaseFactoryFfiNoIsolate,
    );
    final pdf = FinalPdfDocumentService(
      database: () async => db,
      root: () async => Directory('${root.path}/pdfs'),
    );
    PrintingPlatform.instance = NativeRaster('${out.path}/render');
    final medical = DocumentMedicalService(
      pdf: pdf,
      now: () => DateTime.utc(2026, 10, 18, 12),
    );
    final draft = await seed(db, medical);
    final controls = DocumentControlsService(
      medical: medical,
      runner: LocalDocumentControlRunner(
        helper: () =>
            File('$repo/assets/document_controls/CdaCheck.java').readAsString(),
      ),
    );
    await controls.configure({
      'office': Platform.environment['DOCX_OFFICE']!,
      'java':
          '/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin/java',
      'vera': '/Users/jeanclaudebrucher/verapdf/bin/cli-1.30.3.jar',
      'references': Platform.environment['DOCX_REFERENCES']!,
      'label': 'Recette DOCX synthétique — références archivées',
    }, expectedRevision: 0);
    var selected = '${out.path}/fixtures/rapport.docx';
    final initialHash = FinalPdfDocumentService.hash(
      await File(selected).readAsBytes(),
    );
    final u = BusinessUi();
    runApp(
      MaterialApp(
        locale: const Locale('fr', 'FR'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: RepaintBoundary(
          key: u.boundary,
          child: EpisodeDocumentsScreen(
            caseId: 'SYN-E',
            caseLabel: 'Patient SYNTHETIQUE — recette DOCX',
            repository: EpisodeDocumentRepository(database: () async => db),
            finalPdfService: pdf,
            medicalService: medical,
            controlsService: controls,
            pickDocx: () async => selected,
            showExpertInfo: false,
          ),
        ),
      ),
    );
    await u.pump();
    Future<void> waitConversion() async {
      await u.until(
        () =>
            find.byKey(const Key('convert-docx-pdfa')).evaluate().isNotEmpty &&
            find.byType(LinearProgressIndicator).evaluate().isEmpty &&
            (u.controller
                    .widget<FilledButton>(
                      find.byKey(const Key('convert-docx-pdfa')),
                    )
                    .onPressed !=
                null),
        'conversion complete',
        seconds: 280,
      );
    }

    await u.press('convert-docx-pdfa');
    await u.press('confirm-final-import');
    await waitConversion();
    var rows = await db.query('episode_document_versions');
    check(
      rows.length == 1,
      'Écran Documents : conversion réelle et copie figée créées',
    );
    final first = EpisodeDocumentVersion(rows.single);
    final firstFile = await pdf.verifiedFile(first);
    await firstFile.copy('${out.path}/rapport.pdf');
    check(
      nativeCalls == 2,
      'LibreOffice et veraPDF réellement exécutés par le service signé',
    );
    check(
      FinalPdfDocumentService.hash(await File(selected).readAsBytes()) ==
          initialHash,
      'DOCX source inchangé',
    );
    check(
      !(await medical.status(first)).valid,
      'PDF/A conforme ne vaut pas validation médicale',
    );
    await u.shot('${out.path}/documents-convertis.png');
    final evidence = File('${firstFile.parent.path}/conversion-pdfa.xml');
    await evidence.copy('${out.path}/rapport-pdfa.xml');
    await medical.savePreparation(first, draft, expectedRevision: 0);
    final review = await medical.review(first);
    check(
      review.pages.length == first.pages && review.pages.every((p) => p.hasInk),
      'Aperçus de toutes les pages lisibles',
    );
    for (var i = 0; i < review.pages.length; i++) {
      await File(
        '${out.path}/apercu-${i + 1}.png',
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
      'Validation synthétique liée à la première version',
    );
    await db.close();
    db = await DatabaseService.openDatabaseFile(
      '${root.path}/test.sqlite',
      factory: databaseFactoryFfiNoIsolate,
    );
    check(
      (await medical.status(first)).valid,
      'Validation et preuves conservées après réouverture',
    );

    selected = '${out.path}/fixtures/modifie.docx';
    final menu = u.controller.widget<PopupMenuButton<String>>(
      find.byKey(Key('document-actions-${first.documentId}')),
    );
    menu.onSelected!('new-docx');
    await u.pump();
    await u.press('confirm-final-import');
    await waitConversion();
    final versions = await pdf.versions(first.documentId);
    check(
      versions.length == 2 && versions.first.digest != first.digest,
      'DOCX modifié : nouveau PDF figé distinct',
    );
    final second = versions.first;
    await (await pdf.verifiedFile(second)).copy('${out.path}/modifie.pdf');
    await File(
      '${(await pdf.verifiedFile(second)).parent.path}/conversion-pdfa.xml',
    ).copy('${out.path}/modifie-pdfa.xml');
    check(
      !(await medical.status(second)).valid,
      'Nouvelle version sans héritage de validation médicale',
    );
    check(
      (await DocumentJournalService(controls: controls).status(second)).held,
      'Nouvelle version retenue',
    );
    await db.close();
    db = await DatabaseService.openDatabaseFile(
      '${root.path}/test.sqlite',
      factory: databaseFactoryFfiNoIsolate,
    );
    check(
      !(await medical.status(second)).valid,
      'Après réouverture : nouvelle validation toujours requise',
    );
    await pdf.verifiedFile(first);
    await pdf.verifiedFile(second);

    selected = '${out.path}/fixtures/vide.docx';
    final callsBefore = nativeCalls;
    await u.press('convert-docx-pdfa');
    await u.press('confirm-final-import');
    await waitConversion();
    check(
      nativeCalls == callsBefore &&
          (await db.query('episode_document_versions')).length == 2,
      'DOCX vide refusé avant conversion, sans version ni appel supplémentaire',
    );
    check(
      find.textContaining('ne contient pas de texte').evaluate().isNotEmpty,
      'Message de refus du DOCX vide affiché',
    );
    await u.shot('${out.path}/refus-docx-vide.png');
    check(
      (await db.query('document_attempts')).isEmpty,
      'Aucune tentative DMP créée',
    );
    check(errors.isEmpty, 'Aucune erreur de rendu de l’écran métier');
    await File('${out.path}/result.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'scope': 'contrôle ciblé autorisé uniquement',
        'passed': true,
        'checks': results,
        'nativeCalls': nativeCalls,
        'cpsCalls': 0,
        'dmpAttempts': 0,
        'first': first.id,
        'second': second.id,
        'root': root.path,
      }),
    );
    await db.close();
    exit(0);
  } catch (e, st) {
    await File('${out.path}/failure.txt').writeAsString('$e\n$st');
    stderr.writeln('$e\n$st');
    exit(1);
  }
}
