import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/src/interface.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_journal_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_reconciliation_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_reconciliation_records.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/chain_service.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/screens/episode_documents_screen.dart';
import 'package:abak_desktop_companion/features/patients/screens/document_medical_screen.dart';
import 'package:abak_desktop_companion/features/maintenance/services/local_database_backup_service.dart';
import 'package:abak_desktop_companion/features/maintenance/services/companion_backup_archive.dart';
import 'package:abak_desktop_companion/features/desktop_backup/services/local_database_restore_service.dart';
import '../document_controls_product/verify.dart' show AlreadySandboxedNative;
import '../document_journal_product/verify.dart' show Paths, Access;
import '../document_chain_product/fakes.dart' show Ports;
import 'seed.dart';
import 'native.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await S.load(const Locale('fr', 'FR'));
  sqfliteFfiInit();
  final output = Directory(Platform.environment['ACCEPTANCE_OUTPUT']!);
  final repo = Platform.environment['CHAIN_TEST_REPO']!;
  final checks = <String>[], errors = <String>[];
  FlutterError.onError = (e) {
    errors.add(e.toString());
    stderr.writeln(e);
  };
  void check(bool ok, String label) {
    if (!ok) throw StateError(label);
    checks.add(label);
    stdout.writeln('PASS $label');
  }

  final u = BusinessUi();
  final raster = NativeRaster('${output.path}/render');
  PrintingPlatform.instance = raster;
  final phase = Platform.environment['ACCEPTANCE_PHASE'];
  final reopen = phase == 'reopen' || phase == 'restore_missing';
  try {
    final saved = reopen
        ? jsonDecode(File('${output.path}/result.json').readAsStringSync())
        : null;
    final root = reopen
        ? Directory(saved['root'])
        : await output.createTemp('synthetic-');
    if (!reopen) {
      File(
        '${root.path}/J4-SYNTHETIC-ONLY',
      ).writeAsStringSync('ABAK-J4-SYNTHETIC');
    }
    if (!root.path.startsWith('${output.path}/synthetic-') ||
        File('${root.path}/J4-SYNTHETIC-ONLY').readAsStringSync() !=
            'ABAK-J4-SYNTHETIC') {
      throw StateError('Scope');
    }
    PathProviderPlatform.instance = Paths('${root.path}/support');
    var db = await DatabaseService.database;
    final pdf = FinalPdfDocumentService();
    final medical = DocumentMedicalService(
      pdf: pdf,
      now: () => DateTime.utc(2026, 10, 17, 12),
    );
    final controls = DocumentControlsService(
      medical: medical,
      runner: AlreadySandboxedNative(
        helper: () =>
            File('$repo/assets/document_controls/CdaCheck.java').readAsString(),
      ),
    );
    final journal = DocumentJournalService(controls: controls);
    final recon = DocumentReconciliationService(
      journal: journal,
      directory: root,
    );
    final chain = DocumentDmpChain(journal: journal);
    final native = NativeSimulation(
      repo,
      output,
      Platform.environment['WIRE_CERTIFICATES']!,
      '${output.path}/classes',
    );
    Future<void> noRetry(EpisodeDocumentVersion v, String label) async {
      final ports = Ports(repo, () => DateTime.utc(2026, 10, 17, 12));
      final status = await chain.executeSimulated(
        v,
        directory: root,
        ports: ports,
      );
      check(
        ports.order.isEmpty && ports.calls == 0 && status.state != 'ready',
        label,
      );
    }

    Future<EpisodeDocumentVersion> byId(String id) async =>
        EpisodeDocumentVersion(
          (await db.query(
            'episode_document_versions',
            where: 'version_id=?',
            whereArgs: [id],
          )).single,
        );
    Future<Map<String, String>> fileHashes() async {
      final files = await (await pdf.root())
          .list(recursive: true, followLinks: false)
          .where((f) => f is File)
          .cast<File>()
          .toList();
      return {
        for (final f in files)
          f.path.substring((await pdf.root()).path.length):
              FinalPdfDocumentService.hash(await f.readAsBytes()),
      };
    }

    if (reopen) {
      if (phase == 'restore_missing') {
        final backupDir = Directory('${root.path}/absent-restore-backups')
          ..createSync();
        final access = Access(backupDir.path);
        final backup = await LocalDatabaseBackupService(access: access)
            .createBackup(
              chooseBackupFolderTitle: 'Synthétique',
              cancelledMessage: 'Annulé',
              databaseNotFoundMessage: 'Absente',
            );
        check(backup.success, 'Sauvegarde actualisée avec quatre examens');
        final pdfDir = await pdf.root();
        final canonical = await pdfDir.resolveSymbolicLinks();
        check(
          canonical.startsWith('${root.path}/support/'),
          'Déplacement limité aux fichiers synthétiques',
        );
        await DatabaseService.closeDatabase();
        await pdfDir.rename('${root.path}/copies-avant-restauration');
        check(
          !pdfDir.existsSync(),
          'PDF et preuves absents de leur emplacement de travail',
        );
        final restoration = await LocalDatabaseRestoreService(
          access: access,
        ).restoreDatabase(backupPath: backup.backupPath!);
        check(
          restoration.success,
          'Pièces et preuves récupérées depuis le ZIP sans copie de travail',
        );
        db = await DatabaseService.database;
      }
      for (final id in saved['versions']) {
        await noRetry(
          await byId(id),
          'Redémarrage : renvoi bloqué sans interface pour $id',
        );
      }
      await DocumentReconciliationRecords.validateAll(db);
      check(
        (await db.query('document_reconciliations')).length == saved['reviews'],
        'Redémarrage : examens des archives conservés',
      );
      check(
        (await db.query('document_attempts')).length == saved['attempts'],
        'Redémarrage : compteur des tentatives conservé',
      );
      check(
        medicalCanonical(await fileHashes()) ==
            medicalCanonical(saved['files']),
        'Redémarrage : PDF et preuves identiques',
      );
      check(
        medicalCanonical(await db.query('patient_fr_health_identity')) ==
            saved['identity'],
        'Identité déjà qualifiée inchangée',
      );
      if (phase == 'restore_missing') {
        final restoredVersion = await byId(saved['versions'][2]);
        final nativeStatus = await controls.status(restoredVersion);
        check(
          nativeStatus.pdfa == 'conforme' && nativeStatus.cda == 'conforme',
          'Restauration sans fichiers : preuves PDF/A et CDA conformes relues sans exécution',
        );
        runApp(
          RepaintBoundary(
            key: u.boundary,
            child: MaterialApp(
              locale: const Locale('fr', 'FR'),
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: DocumentMedicalScreen(
                version: restoredVersion,
                service: medical,
                controls: controls,
              ),
            ),
          ),
        );
        await u.pump(20);
        await u.seek('native-control-status');
        await u.until(
          () =>
              u.text('native-control-status') ==
              'PDF/A : conforme · CDA : conforme',
          'preuves restaurées affichées',
          seconds: 120,
        );
        await u.shot('${output.path}/05-controles-restaures.png');
        await u.seek('document-reconciliation-status');
        await u.shot('${output.path}/06-journal-restaure.png');
        check(
          u.text('document-reconciliation-status').contains('Renvoi bloqué'),
          'Interface après restauration : renvoi bloqué affiché',
        );
        runApp(const SizedBox.shrink());
        await u.pump();
      }
      check(
        native.pinCalls == 0 && native.profileCalls == 0,
        'Redémarrage : aucune sollicitation CPS même simulée',
      );
      await DatabaseService.closeDatabase();
      File(
        '${output.path}/${phase == 'restore_missing' ? 'restore-missing' : 'restart'}.json',
      ).writeAsStringSync(
        jsonEncode({
          'count': checks.length,
          'checks': checks,
          'networkCalls': 0,
          'cpsCalls': 0,
        }),
      );
      exit(0);
    }
    final draft = await seed(db, medical);
    final identityBefore = medicalCanonical(
      await db.query('patient_fr_health_identity'),
    );
    await controls.configure({
      'java':
          '/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin/java',
      'vera': '/Users/jeanclaudebrucher/verapdf/bin/cli-1.30.3.jar',
      'references': Platform.environment['CONTROLS_TEST_REFS']!,
      'label': 'Références locales archivées — recette synthétique',
    }, expectedRevision: 0);
    String picked = '${output.path}/fixtures/rapport.pdf';
    ({String headers, List<int> bytes})? selectedArchive;
    int mounts = 0;
    Future<void> mount() async {
      runApp(
        RepaintBoundary(
          key: u.boundary,
          child: MaterialApp(
            key: ValueKey(++mounts),
            locale: const Locale('fr', 'FR'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: EpisodeDocumentsScreen(
              caseId: 'SYN-E',
              caseLabel: 'Épisode SYN-E — Patient SYNTHETIQUE',
              finalPdfService: pdf,
              medicalService: medical,
              controlsService: controls,
              reconciliationService: recon,
              pickArchive: () async => selectedArchive,
              pickFile: (pdfOnly) async {
                check(pdfOnly, 'Sélection limitée au PDF final');
                return picked;
              },
              openFile: (_) async =>
                  throw StateError('Aucune application externe'),
              showExpertInfo: false,
            ),
          ),
        ),
      );
      await u.pump(10);
      await u.until(
        () => find.byKey(const Key('import-final-pdf')).evaluate().isNotEmpty,
        'documents',
      );
    }

    Future<EpisodeDocumentVersion> imported({
      EpisodeDocumentVersion? previous,
    }) async {
      if (previous == null) {
        await u.press('import-final-pdf');
      } else {
        final f = await u.seek('document-actions-${previous.documentId}');
        u.controller.widget<PopupMenuButton<String>>(f).onSelected!('new');
        await u.pump();
      }
      await u.press('confirm-final-import');
      await u.until(
        () => find.byKey(const Key('pdf-import-busy')).evaluate().isEmpty,
        'import PDF',
      );
      final rows = await db.query(
        'episode_document_versions',
        orderBy: 'captured_at DESC',
      );
      return EpisodeDocumentVersion(rows.first);
    }

    Future<void> openMedical(EpisodeDocumentVersion v) async {
      final f = await u.seek('document-actions-${v.documentId}');
      u.controller.widget<PopupMenuButton<String>>(f).onSelected!('medical');
      await u.until(
        () => find.byType(DocumentMedicalScreen).evaluate().isNotEmpty,
        'route médicale',
      );
      await u.until(
        () => find.byKey(const Key('medical-busy')).evaluate().isEmpty,
        'chargement médical',
      );
      await u.pump(20);
    }

    Future<void> preparationUi() async {
      for (final e in draft.entries) {
        await u.field(e.key, e.value);
      }
      await u.press('save-medical-context');
      await u.until(
        () => find.byKey(const Key('medical-busy')).evaluate().isEmpty,
        'enregistrement contexte',
      );
    }

    Future<void> approveUi() async {
      await u.press('review-medical-pdf');
      await u.until(
        () => find.byKey(const Key('medical-busy')).evaluate().isEmpty,
        'aperçu',
      );
      for (final k in [
        'medical-page-reviewed',
        'medical-clinical',
        'medical-patient',
        'medical-actor',
      ]) {
        await u.tick(k);
      }
      await u.press('approve-medical-pdf');
      await u.press('confirm-medical-approval');
      await u.until(
        () => find.byKey(const Key('medical-busy')).evaluate().isEmpty,
        'validation médicale',
      );
    }

    await mount();
    final v1 = await imported();
    check(
      v1.number == 1 && v1.pages == 1,
      'Import métier : première version PDF figée, une page',
    );
    check(
      (await db.query(
            'episode_documents',
            where: 'document_id=?',
            whereArgs: [v1.documentId],
          )).single['mime_type'] ==
          'application/pdf',
      'MIME PDF correct dans le dossier',
    );
    final originalHash = FinalPdfDocumentService.hash(
      File(picked).readAsBytesSync(),
    );
    check(
      v1.digest == originalHash,
      'Copie figée identique au PDF final sélectionné',
    );
    await openMedical(v1);
    await preparationUi();
    await u.press('review-medical-pdf');
    await u.until(
      () => find.byKey(const Key('medical-busy')).evaluate().isEmpty,
      'aperçu natif',
    );
    await u.seek('medical-page-reviewed');
    await u.shot('${output.path}/01-apercu.png');
    final review = await medical.review(v1);
    await File(
      '${output.path}/apercu-clinique.png',
    ).writeAsBytes(review.pages.single.png);
    check(
      review.pages.single.hasInk,
      'Aperçu natif : contenu présent, patient et auteur synthétiques affichés',
    );
    for (final k in [
      'medical-page-reviewed',
      'medical-clinical',
      'medical-patient',
      'medical-actor',
    ]) {
      await u.tick(k);
    }
    await u.press('approve-medical-pdf');
    await u.press('confirm-medical-approval');
    await u.until(
      () => find.byKey(const Key('medical-busy')).evaluate().isEmpty,
      'validation',
    );
    check(
      (await medical.status(v1)).valid,
      'Validation métier liée au PDF et au contexte exacts',
    );
    check((await journal.status(v1)).held, 'Retenue activée par défaut');
    await mount();
    await openMedical(v1);
    check(
      (await medical.status(v1)).valid && (await journal.status(v1)).held,
      'Réouverture : validation et retenue conservées',
    );
    check(
      (await db.query('document_attempts')).isEmpty,
      'Réouverture : zéro tentative',
    );
    await u.press('run-native-controls');
    await u.until(
      () =>
          find.byKey(const Key('run-native-controls')).evaluate().isNotEmpty &&
          u.controller
                  .widget<FilledButton>(
                    find.byKey(const Key('run-native-controls')),
                  )
                  .onPressed !=
              null,
      'contrôles natifs',
      seconds: 240,
    );
    final control = await controls.status(v1);
    check(
      control.pdfa == 'conforme' && control.cda == 'conforme',
      'Contrôles natifs : veraPDF PDF/A-1b et CDA conformes',
    );
    File('${output.path}/native.json').writeAsStringSync(
      jsonEncode({
        'pdfa': control.pdfa,
        'cda': control.cda,
        'run': control.run,
        'message': control.message,
      }),
    );
    await noRetry(v1, 'Retenue : zéro appel de chaîne avant sa levée');
    await u.seek('document-hold');
    await u.shot('${output.path}/02-controles-retenue.png');
    await u.hold(false);
    await u.pump(10);
    check(
      !(await journal.status(v1)).held &&
          (await db.query('document_attempts')).isEmpty,
      'Levée explicite de retenue : aucun traitement lancé',
    );
    final incident = await chain.executeSimulated(
      v1,
      directory: root,
      ports: native.ports('deposit_timeout'),
    );
    check(
      incident.state == 'indeterminate',
      'Chaîne native simulée : tentative durable et résultat indéterminé',
    );
    check(
      native.pinCalls == 1 && native.profileCalls == 1,
      'Une seule session de carte simulée, aucune CPS réelle',
    );
    final initialResult = medicalCanonical(
      await db.query('document_attempt_results'),
    );
    await noRetry(v1, 'Incident : renvoi bloqué avant toute interface');
    final provenance = <Map<String, Object?>>[];
    Future<({String headers, List<int> bytes})> archive(
      EpisodeDocumentVersion v,
      String kind, {
      bool correlated = true,
    }) async {
      final base = '$repo/assets/dmp_local/deposit_replay/$kind';
      final original = File('$base-response.bin').readAsBytesSync();
      final old =
          XmlDocument.parse(File('$base-request.xml').readAsStringSync())
              .descendants
              .whereType<XmlElement>()
              .firstWhere((e) => e.name.local == 'MessageID')
              .innerText;
      final step = (await db.query(
        'document_chain_steps',
        where: 'version_id=? AND phase=? AND state=?',
        whereArgs: [v.id, 'package', 'passed'],
      )).single;
      final id = jsonDecode(step['data_json'] as String)['messageId'] as String;
      final bytes = correlated
          ? latin1.encode(latin1.decode(original).replaceAll(old, id))
          : original;
      check(
        old.length == id.length && bytes.length == original.length,
        'Archive $kind : longueur du message préservée',
      );
      final name =
          '$kind-${correlated ? 'adaptee' : 'originale'}-${provenance.length}';
      final dir = Directory('${root.path}/archives')..createSync();
      File('${dir.path}/$name.bin').writeAsBytesSync(bytes);
      final headers = File('$base-headers.txt').readAsStringSync();
      File('${dir.path}/$name.headers').writeAsStringSync(headers);
      provenance.add({
        'source': '$base-response.bin',
        'sourceSha256': FinalPdfDocumentService.hash(original),
        'copy': '${dir.path}/$name.bin',
        'copySha256': FinalPdfDocumentService.hash(bytes),
        'adaptation': correlated
            ? 'RelatesTo uniquement, ancienne requête → tentative synthétique'
            : 'Aucune',
        'messageId': id,
      });
      return (headers: headers, bytes: bytes);
    }

    Future<void> examine({bool cancel = false}) async {
      await u.press('examine-document-archive');
      await u.until(
        () => find
            .byKey(const Key('archive-review-message'))
            .evaluate()
            .isNotEmpty,
        'prévisualisation archive',
      );
      await u.press(
        cancel ? 'cancel-archive-review' : 'confirm-archive-review',
      );
      await u.pump(12);
    }

    await u.press('document-journal-refresh');
    await u.pump(10);
    selectedArchive = await archive(v1, 'accepted', correlated: false);
    await examine();
    check(
      (await journal.status(v1)).state == 'indeterminate',
      'Archive non corrélée : aucune conclusion de succès',
    );
    selectedArchive = await archive(v1, 'accepted');
    final n = (await db.query('document_reconciliations')).length;
    await examine(cancel: true);
    check(
      (await db.query('document_reconciliations')).length == n,
      'Annuler l’examen ne conserve aucune conclusion',
    );
    await examine();
    check(
      (await journal.status(v1)).state == 'accepted',
      'Examen explicite : archive de succès corrélée à la tentative exacte',
    );
    check(
      medicalCanonical(await db.query('document_attempt_results')) ==
          initialResult,
      'Résultat initial indéterminé conservé sans réécriture',
    );
    await noRetry(v1, 'Succès archivé : renvoi toujours bloqué');
    await u.seek('document-reconciliation-status');
    await u.shot('${output.path}/03-archive-examinee.png');
    // A second independent piece covers a rejection without changing the first history.
    await mount();
    picked = '${output.path}/fixtures/modifie.pdf';
    final rejected = await imported();
    await openMedical(rejected);
    await preparationUi();
    await approveUi();
    await controls.run(rejected);
    await journal.hold(
      rejected,
      false,
      expectedRevision: (await journal.status(rejected)).revision,
    );
    final s = await chain.executeSimulated(
      rejected,
      directory: root,
      ports: native.ports('deposit_uncorrelated'),
    );
    check(
      s.state == 'indeterminate',
      'Deuxième pièce : réponse simulée non corrélée indéterminée',
    );
    selectedArchive = await archive(rejected, 'metadata');
    await u.press('document-journal-refresh');
    await u.pump(10);
    await examine();
    check(
      (await journal.status(rejected)).state == 'rejected',
      'Archive de rejet de métadonnées : rejet explicite',
    );
    await noRetry(rejected, 'Rejet : renvoi bloqué');
    // New clinical version imported through the same document menu; history stays intact.
    await mount();
    picked = '${output.path}/fixtures/modifie.pdf';
    final v2 = await imported(previous: v1);
    check(
      v2.documentId == v1.documentId &&
          v2.number == 2 &&
          v2.digest != v1.digest,
      'Modification clinique : nouvelle version figée de la même pièce',
    );
    check(
      !(await medical.status(v2)).valid && (await journal.status(v2)).held,
      'Nouvelle version : validation non héritée et retenue',
    );
    await pdf.verifyStoredBytes(v1);
    check(
      v1.digest == originalHash,
      'Version précédente intacte après modification',
    );
    await noRetry(
      v2,
      'Nouvelle version : ancienne tentative ne permet pas un renvoi',
    );
    await openMedical(v2);
    await u.seek('medical-send');
    check(
      u.controller
              .widget<OutlinedButton>(find.byKey(const Key('medical-send')))
              .onPressed ==
          null,
      'Envoi métier toujours grisé',
    );
    // Real blank PDF, no fake ink classifier.
    await mount();
    picked = '${output.path}/fixtures/blanc.pdf';
    final blank = await imported();
    await openMedical(blank);
    await preparationUi();
    await u.press('review-medical-pdf');
    await u.until(
      () => find.byKey(const Key('medical-busy')).evaluate().isEmpty,
      'page blanche',
    );
    await u.seek('approve-medical-pdf');
    check(
      u.controller
              .widget<FilledButton>(
                find.byKey(const Key('approve-medical-pdf')),
              )
              .onPressed ==
          null,
      'Page blanche : revue refusée et validation grisée',
    );
    check(!(await medical.status(blank)).valid, 'Page blanche non validée');
    await noRetry(blank, 'Page blanche : aucun traitement');
    // Unmount UI during database replacement, as with an application restore.
    runApp(const SizedBox.shrink());
    await u.pump(5);
    final beforeFiles = await fileHashes();
    final beforeReviews = medicalCanonical(
      await db.query('document_reconciliations'),
    );
    final beforeAttempts = medicalCanonical(
      await db.query('document_attempts'),
    );
    final backupDir = Directory('${root.path}/backups')..createSync();
    final access = Access(backupDir.path);
    final backup = await LocalDatabaseBackupService(access: access)
        .createBackup(
          chooseBackupFolderTitle: 'Recette synthétique',
          cancelledMessage: 'Annulé',
          databaseNotFoundMessage: 'Absente',
        );
    check(backup.success, 'Sauvegarde métier complète créée');
    final staged = await const CompanionBackupArchive().prepare(
      backup.backupPath!,
    );
    final stagedDb = await databaseFactoryFfiNoIsolate.openDatabase(
      staged.databasePath,
    );
    await DocumentReconciliationRecords.validateAll(stagedDb);
    check(
      (await stagedDb.query('document_reconciliations')).length == 3,
      'Archive de sauvegarde : trois examens présents et preuves valides',
    );
    await stagedDb.close();
    await staged.dispose();
    await DatabaseService.closeDatabase();
    final restored = await LocalDatabaseRestoreService(
      access: access,
    ).restoreDatabase(backupPath: backup.backupPath!);
    check(
      restored.success,
      'Restauration métier effectuée dans le stockage synthétique',
    );
    db = await DatabaseService.database;
    check(
      medicalCanonical(await fileHashes()) == medicalCanonical(beforeFiles),
      'Restauration : toutes les pièces et preuves identiques',
    );
    check(
      medicalCanonical(await db.query('document_reconciliations')) ==
          beforeReviews,
      'Restauration : examens archivés identiques',
    );
    check(
      medicalCanonical(await db.query('document_attempts')) == beforeAttempts,
      'Restauration : compteurs et tentatives identiques',
    );
    check(
      (await db.query('document_restore_barriers')).isNotEmpty,
      'Restauration : barrière durable présente',
    );
    for (final v in [v1, v2, rejected, blank]) {
      await noRetry(
        v,
        'Après restauration : aucun renvoi pour version ${v.id}',
      );
    }
    await mount();
    await openMedical(rejected);
    await u.seek('document-reconciliation-status');
    await u.shot('${output.path}/04-restauration.png');
    selectedArchive = await archive(rejected, 'metadata');
    await examine();
    await noRetry(
      rejected,
      'Nouvel examen après restauration : blocage du renvoi maintenu',
    );
    check(
      native.pinCalls == 2 && native.profileCalls == 2,
      'Deux tentatives simulées seulement sur toute la recette',
    );
    check(
      medicalCanonical(await db.query('patient_fr_health_identity')) ==
          identityBefore,
      'Identité déjà qualifiée intacte du début à la fin',
    );
    check(
      errors.isEmpty,
      'Aucune erreur Flutter de mise en page ou d’exécution',
    );
    File(
      '${output.path}/archives.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(provenance));
    final result = {
      'root': root.path,
      'count': checks.length,
      'checks': checks,
      'versions': [v1.id, v2.id, rejected.id, blank.id],
      'reviews': (await db.query('document_reconciliations')).length,
      'attempts': (await db.query('document_attempts')).length,
      'files': await fileHashes(),
      'identity': identityBefore,
      'backup': backup.backupPath,
      'nativeSimulatedSessions': native.pinCalls,
      'nativeRenderCalls': raster.calls,
      'networkCalls': 0,
      'realCpsCalls': 0,
      'errors': errors,
    };
    File(
      '${output.path}/result.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(result));
    runApp(const SizedBox.shrink());
    await u.pump();
    await DatabaseService.closeDatabase();
    exit(0);
  } catch (e, st) {
    File('${output.path}/failure.json').writeAsStringSync(
      jsonEncode({
        'checks': checks,
        'error': '$e',
        'stack': '$st',
        'uiErrors': errors,
      }),
    );
    stderr.writeln('$e\n$st');
    exit(1);
  }
}
