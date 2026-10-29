import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive_io.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/database/document_journal_schema.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_journal_service.dart';
import 'package:abak_desktop_companion/features/patients/screens/document_journal_panel.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/maintenance/services/companion_backup_archive.dart';
import 'package:abak_desktop_companion/features/maintenance/services/local_database_backup_service.dart';
import 'package:abak_desktop_companion/features/maintenance/services/backup_directory_access.dart';
import 'package:abak_desktop_companion/features/desktop_backup/services/local_database_restore_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import '../document_controls_product/verify.dart'
    show Inspector, Renderer, Runner;

class Paths extends PathProviderPlatform {
  Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

class Access extends BackupDirectoryAccess {
  Access(this.path);
  final String path;
  @override
  Future<BackupDirectoryLease?> choose(String title) async =>
      BackupDirectoryLease(path);
  @override
  Future<BackupDirectoryLease> acquire(String path) async =>
      BackupDirectoryLease(path);
  @override
  Future<BackupDirectoryLease> restore(String path) async =>
      BackupDirectoryLease(path);
}

class FailingRestore extends LocalDatabaseRestoreService {
  FailingRestore({required super.access});
  @override
  Future<void> installDatabase(String source, String destination) async {
    await File(source).copy(destination);
    throw StateError('Interruption simulée après remplacement de la base');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await S.load(const Locale('fr', 'FR'));
  final output = Directory(Platform.environment['JOURNAL_TEST_OUTPUT']!)
    ..createSync(recursive: true);
  final repo = Platform.environment['JOURNAL_TEST_REPO']!;
  final checks = <String>[], errors = <String>[];
  FlutterError.onError = (e) => errors.add(e.toString());
  void check(bool ok, String label) {
    if (!ok) throw StateError(label);
    checks.add(label);
    stdout.writeln('PASS $label');
  }

  Future<void> refuses(Future<dynamic> Function() fn, String label) async {
    var caught = false;
    try {
      await fn();
    } catch (_) {
      caught = true;
    }
    check(caught, label);
  }

  final picture = ui.PictureRecorder();
  ui.Canvas(
    picture,
  ).drawRect(const Rect.fromLTWH(0, 0, 10, 10), Paint()..color = Colors.black);
  final image = await picture.endRecording().toImage(10, 10);
  final png = (await image.toByteData(
    format: ui.ImageByteFormat.png,
  ))!.buffer.asUint8List();
  image.dispose();
  sqfliteFfiInit();
  try {
    if (Platform.environment['JOURNAL_TEST_PHASE'] == 'reopen') {
      final saved = jsonDecode(
        File('${output.path}/result.json').readAsStringSync(),
      );
      final root = Directory(saved['root']);
      if (!root.path.startsWith('${output.path}/synthetic-') ||
          File('${root.path}/J4-SYNTHETIC-ONLY').readAsStringSync() !=
              'ABAK-J4-SYNTHETIC') {
        throw StateError('scope');
      }
      PathProviderPlatform.instance = Paths('${root.path}/support');
      final pdf = FinalPdfDocumentService(inspector: Inspector());
      final medical = DocumentMedicalService(
        pdf: pdf,
        renderer: Renderer(png),
        now: () => DateTime.utc(2026, 10, 17, 12),
      );
      final controls = DocumentControlsService(
        medical: medical,
        runner: Runner(),
      );
      final journal = DocumentJournalService(controls: controls);
      final fake = DocumentLocalSimulation(directory: root);
      for (final e in (saved['persist'] as Map).entries) {
        final v = EpisodeDocumentVersion(
          (await (await pdf.database()).query(
            'episode_document_versions',
            where: 'version_id=?',
            whereArgs: [e.key],
          )).single,
        );
        check(
          (await journal.status(v)).state == e.value,
          'état après nouveau processus : ${e.value}',
        );
        await journal.simulate(v, fake);
      }
      check(fake.calls == 0, 'zéro appel après redémarrage et restauration');
      await DatabaseService.closeDatabase();
      File('${output.path}/restart.json').writeAsStringSync(
        jsonEncode({'count': checks.length, 'checks': checks}),
      );
      exit(0);
    }
    final root = await output.createTemp('synthetic-');
    File(
      '${root.path}/J4-SYNTHETIC-ONLY',
    ).writeAsStringSync('ABAK-J4-SYNTHETIC');
    PathProviderPlatform.instance = Paths('${root.path}/support');
    var db = await DatabaseService.database;
    await db.insert('patients', {
      'patient_id': 'SYN-P',
      'last_name': 'SYNTHETIQUE',
      'first_name': 'Patient',
      'birth_date': '1980-01-01',
      'created_at': 1,
    });
    await db.insert('care_episodes', {
      'care_episode_id': 'SYN-E',
      'patient_id': 'SYN-P',
      'title': 'Synthétique',
      'pathology_label': 'Fictif',
      'created_at': 1,
    });
    await db.insert('patient_fr_health_identity', {
      'patient_id': 'SYN-P',
      'ins_number': '1800199123456',
      'ins_key': '01',
      'ins_oid': '1.2.250.1.213.1.4.10',
      'birth_last_name': 'SYNTHETIQUE',
      'birth_first_names': 'Patient',
      'birth_date': '1980-01-01',
      'sex_code': 'M',
      'birth_place_code': '99123',
      'identity_status': 'qualified',
      'identity_doubtful': 0,
      'identity_validation_method': 'synthetic',
      'identity_validated_at': 1,
      'identity_validated_by': 'SYN-A',
      'ins_retrieved_at': 1,
    });
    await db.insert('practitioners', {
      'practitioner_id': 'SYN-A',
      'display_name': 'KINE SYNTHETIQUE',
      'professional_id': '12345678901',
      'is_active': 1,
      'created_at': 1,
    });
    final identityBefore = medicalCanonical(
      await db.query('patient_fr_health_identity'),
    );
    for (final r in await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='trigger' AND name LIKE 'journal_%'",
    )) {
      await db.execute('DROP TRIGGER "${r['name']}"');
    }
    for (final t in [
      'events',
      'attempt_results',
      'attempts',
      'holds',
      'restore_barriers',
    ]) {
      await db.execute('DROP TABLE document_$t');
    }
    await db.setVersion(34);
    await refuses(
      () => db.transaction((tx) async {
        await createDocumentJournalTables(tx);
        throw StateError('crash');
      }),
      'migration interrompue annulée',
    );
    check(
      (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE name='document_events'",
      )).isEmpty,
      'aucun journal partiel après échec de migration',
    );
    await DatabaseService.closeDatabase();
    db = await DatabaseService.database;
    check(
      await db.getVersion() == DatabaseService.schemaVersion,
      'migration additive 34 vers schéma courant',
    );
    check(
      (await db.query('document_attempts')).isEmpty,
      'aucune tentative inventée par migration',
    );
    final pdf = FinalPdfDocumentService(inspector: Inspector());
    final medical = DocumentMedicalService(
      pdf: pdf,
      renderer: Renderer(png),
      now: () => DateTime.utc(2026, 10, 17, 12),
    );
    final context = await medical.saveContext(
      practitionerId: 'SYN-A',
      expectedRevision: 0,
      data: {
        'identifierType': 'RPPS',
        'identifier': '12345678901',
        'authority': '2.25.123456789',
        'professionCode': 'G15_70',
        'professionSystem': '1.2.250.1.213.1.1.4.5',
        'professionLabel': 'Masseur-kinésithérapeute',
        'situation': 'Exercice synthétique',
        'setting': 'Ambulatoire',
        'structureType': 'cabinet',
        'structureId': 'SYN-CAB',
        'structureAuthority': '1.2.250.1.71.4.2.2',
        'structureName': 'CABINET SYNTHETIQUE',
        'validFrom': '2020-01-01T00:00:00Z',
        'validUntil': '2027-01-01T00:00:00Z',
        'replacementFor': '',
        'facilityCode': 'SA07',
        'facilityLabel': 'Cabinet individuel',
        'familyName': 'SYNTHETIQUE',
        'givenNames': 'Kine',
      },
    );
    final draft = {
      'authorId': 'SYN-A',
      'validatorId': 'SYN-A',
      'contextId': context['context_id'] as String,
      'title': 'Rapport clinique SYNTHETIQUE',
      'clinicalDate': '2026-10-16T14:00:00+02:00',
      'language': 'fr-FR',
      'typeCode': '11506-3',
      'typeSystem': '2.16.840.1.113883.6.1',
      'typeLabel': 'CR ou fiche de suivi de soins par auxiliaire médical',
      'classCode': '10',
      'classSystem': '1.2.250.1.213.1.1.4.1',
      'classLabel': 'Compte rendu',
      'catalogReference': 'Référence synthétique',
      'patientVisibility': 'visible',
      'representativesVisibility': 'sans objet',
      'professionalVisibility': 'visible',
    };
    final controls = DocumentControlsService(
      medical: medical,
      runner: Runner(),
    );
    final journal = DocumentJournalService(controls: controls);
    await controls.configure({'label': 'simulation J4'}, expectedRevision: 0);
    var serial = 0;
    Future<EpisodeDocumentVersion> fresh({
      String? documentId,
      bool approve = true,
      bool checked = true,
      String? exactSource,
    }) async {
      final source = File('${root.path}/source-${++serial}.pdf');
      await source.writeAsBytes([
        ...await File(
          '$repo/tool/dmp_pdf_cda_isolated/fixtures/temoin-pdfa1b.pdf',
        ).readAsBytes(),
        ...utf8.encode('\n% J4 synthetique $serial\n%%EOF\n'),
      ]);
      final v = await pdf.importPdf(
        episodeId: 'SYN-E',
        sourcePath: exactSource ?? source.path,
        title: 'Document synthétique $serial',
        documentId: documentId,
      );
      await medical.savePreparation(v, draft, expectedRevision: 0);
      if (approve) {
        await medical.approve(
          await medical.review(v),
          reviewedPages: {0},
          clinicalContent: true,
          correctPatient: true,
          actingAsValidator: true,
        );
      }
      if (approve && checked) await controls.run(v);
      return v;
    }

    Future<void> release(EpisodeDocumentVersion v) async {
      final s = await journal.status(v);
      await journal.hold(v, false, expectedRevision: s.revision);
    }

    final v = await fresh();
    final eventCount = (await db.query('document_events')).length;
    await createDocumentJournalTables(db);
    check(
      (await db.query('document_events')).length == eventCount,
      'reprise de migration sans doublon de journal',
    );

    final fake = DocumentLocalSimulation(directory: root);
    check((await journal.status(v)).held, 'retenue par défaut');
    await journal.simulate(v, fake);
    check(fake.calls == 0, 'retenue bloque le service fictif');
    check(
      (await journal.history(v.documentId))
          .map((e) => e['kind'])
          .toSet()
          .containsAll(['medical_approved', 'controls_recorded']),
      'validation et contrôles dans le journal commun',
    );
    await release(v);
    check(
      !(await journal.status(v)).held && fake.calls == 0,
      'levée de retenue sans appel',
    );
    await refuses(
      () => journal.hold(v, true, expectedRevision: 0),
      'retenue concurrente refusée',
    );
    await journal.hold(v, true, expectedRevision: 1);
    await release(v);
    // Widget uses the same product journal, never a simulation screen.
    final ctl = LiveWidgetController(WidgetsBinding.instance);
    final boundary = GlobalKey();
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: boundary,
              child: DocumentJournalPanel(
                service: journal,
                version: v,
                enabled: true,
              ),
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 12; i++) {
      await ctl.pump(const Duration(milliseconds: 30));
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    check(
      find.textContaining('Retenue levée.').evaluate().isNotEmpty,
      'message du suivi métier',
    );
    final toggle = ctl.widget<SwitchListTile>(
      find.byKey(const Key('document-hold')),
    );
    check(
      toggle.value == false && toggle.onChanged != null,
      'retenue interactive dans écran métier',
    );
    toggle.onChanged!(true);
    for (var i = 0; i < 10; i++) {
      await ctl.pump(const Duration(milliseconds: 30));
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    check(
      (await journal.status(v)).held,
      'écran raccordé à la retenue durable',
    );
    await release(v);
    check(
      (await journal.simulate(v, fake)).state == 'accepted',
      'acceptation fictive enregistrée',
    );
    await journal.simulate(v, fake);
    check(fake.calls == 1, 'renvoi accepté bloqué');
    await refuses(
      () async => journal.hold(
        v,
        false,
        expectedRevision: (await journal.status(v)).revision,
      ),
      'levée retenue ne réarme pas une tentative',
    );
    ctl
        .widget<TextButton>(find.byKey(const Key('document-journal-refresh')))
        .onPressed!
        .call();
    for (var i = 0; i < 10; i++) {
      await ctl.pump(const Duration(milliseconds: 30));
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    check(
      ctl
              .widget<SwitchListTile>(find.byKey(const Key('document-hold')))
              .onChanged ==
          null,
      'retenue verrouillée après tentative',
    );
    final screenshot =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 1);
    File('${output.path}/suivi-metier.png').writeAsBytesSync(
      (await screenshot.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List(),
    );
    screenshot.dispose();
    runApp(const SizedBox.shrink());
    await ctl.pump();
    final held = await fresh();
    final missing = await fresh(approve: false);
    await release(missing);
    await refuses(
      () => journal.simulate(missing, fake),
      'sans validation : appel refusé',
    );
    final unchecked = await fresh(checked: false);
    await release(unchecked);
    await refuses(
      () => journal.simulate(unchecked, fake),
      'sans contrôles : appel refusé',
    );
    for (final verdict in ['refuse', 'non_verifie']) {
      (controls.runner as Runner).pdfa = verdict;
      final blocked = await fresh();
      await release(blocked);
      await refuses(
        () => journal.simulate(blocked, fake),
        'PDF/A $verdict : service bloqué',
      );
    }
    (controls.runner as Runner).pdfa = 'conforme';
    final changed = await fresh();
    await release(changed);
    await medical.savePreparation(changed, {
      ...draft,
      'title': 'Titre modifié',
    }, expectedRevision: 1);
    await refuses(
      () => journal.simulate(changed, fake),
      'contexte modifié : appel refusé',
    );
    final replacement = await fresh(documentId: v.documentId);

    await journal.simulate(replacement, fake);
    check(
      fake.calls == 1,
      'nouvelle version ne contourne pas le renvoi de la pièce',
    );
    final duplicate = await fresh(
      exactSource: (await pdf.verifyStoredBytes(v)).path,
    );

    await journal.simulate(duplicate, fake);
    check(
      fake.calls == 1,
      'copie identique sous une autre pièce : renvoi bloqué',
    );
    final rejected = await fresh();
    await release(rejected);
    final reject = DocumentLocalSimulation(
      directory: root,
      outcome: 'rejected',
    );
    check(
      (await journal.simulate(rejected, reject)).state == 'rejected',
      'rejet conservé',
    );
    await journal.simulate(rejected, reject);
    check(reject.calls == 1, 'rejet sans réessai');
    final uncertain = await fresh();
    await release(uncertain);
    final unknown = DocumentLocalSimulation(
      directory: root,
      beforeResult: () async {
        throw StateError('service interrompu');
      },
    );
    check(
      (await journal.simulate(uncertain, unknown)).state == 'indeterminate',
      'exception classée indéterminée',
    );
    final interrupted = await fresh();
    await release(interrupted);
    final crash = DocumentJournalService(
      controls: controls,
      checkpoint: (point) async {
        if (point == 'after_reservation') throw StateError('crash');
      },
    );
    final noCall = DocumentLocalSimulation(directory: root);
    await refuses(
      () => crash.simulate(interrupted, noCall),
      'incident après réservation conservé',
    );
    check(
      (await journal.status(interrupted)).state == 'indeterminate' &&
          noCall.calls == 0,
      'réservation sans réponse bloque même avant appel',
    );
    await journal.simulate(interrupted, noCall);
    check(noCall.calls == 0, 'reprise sans double appel');
    final afterResponse = await fresh();
    await release(afterResponse);
    final responseCrash = DocumentJournalService(
      controls: controls,
      checkpoint: (point) async {
        if (point == 'after_response') throw StateError('crash');
      },
    );
    await refuses(
      () => responseCrash.simulate(afterResponse, noCall),
      'incident après réponse',
    );
    await journal.simulate(afterResponse, noCall);
    check(noCall.calls == 1, 'réponse non enregistrée ne réarme pas le renvoi');
    final concurrent = await fresh();
    await release(concurrent);
    final gate = Completer<void>();
    final slow = DocumentLocalSimulation(
      directory: root,
      beforeResult: () => gate.future,
    );
    final work = journal.simulate(concurrent, slow);
    while (slow.calls == 0) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await journal.simulate(concurrent, slow);
    gate.complete();
    await work;
    check(slow.calls == 1, 'réservation exclusive entre deux services');
    final race = await fresh();
    await release(race);
    final racing = DocumentJournalService(
      controls: controls,
      checkpoint: (point) async {
        if (point == 'before_reservation') {
          await journal.hold(race, true, expectedRevision: 1);
        }
      },
    );
    await refuses(
      () => racing.simulate(race, noCall),
      'retenue réactivée pendant les contrôles bloque avant réservation',
    );
    final foreign = await fresh();
    await release(foreign);
    await refuses(
      () => journal.simulate(
        foreign,
        DocumentLocalSimulation(directory: Directory('${root.path}/absent')),
      ),
      'service fictif interdit hors stockage balisé',
    );
    final archiveStates = <String, String>{};
    for (final name in [
      'accepted',
      'signature',
      'metadata',
      'truncated',
      'uncorrelated',
    ]) {
      final item = await fresh();
      await release(item);
      final prefix =
          '$repo/assets/dmp_local/deposit_replay/${['truncated', 'uncorrelated'].contains(name) ? 'accepted' : name}';
      var request = File('$prefix-request.xml').readAsStringSync();
      var body = File('$prefix-response.bin').readAsBytesSync();
      if (name == 'truncated') body = body.sublist(0, body.length ~/ 2);
      if (name == 'uncorrelated') {
        request = request.replaceFirst('urn:uuid:', 'urn:uuid:changed-');
      }
      final replay = DocumentLocalSimulation(
        directory: root,
        request: request,
        headers: File('$prefix-headers.txt').readAsStringSync(),
        response: body,
      );
      final result = await journal.simulate(item, replay);
      final expected = name == 'accepted'
          ? 'accepted'
          : ['signature', 'metadata'].contains(name)
          ? 'rejected'
          : 'indeterminate';
      check(result.state == expected, 'réponse archivée $name : $expected');
      await journal.simulate(item, replay);
      check(replay.calls == 1, 'archive $name sans renvoi');
      archiveStates[item.id] = expected;
    }
    for (final table in [
      'document_events',
      'document_attempts',
      'document_attempt_results',
    ]) {
      final row = (await db.query(table, limit: 1)).single;
      await refuses(
        () => db.update(table, row),
        '$table : modification interdite',
      );
      await refuses(() => db.delete(table), '$table : suppression interdite');
      await refuses(
        () =>
            db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace),
        '$table : remplacement interdit',
      );
    }
    final attempt = (await db.query('document_attempts', limit: 1)).single;
    await refuses(
      () => db.insert('document_attempts', {
        ...attempt,
        'attempt_id': 'another',
      }, conflictAlgorithm: ConflictAlgorithm.replace),
      'réservation unique ne peut être remplacée',
    );
    check(
      medicalCanonical(await db.query('patient_fr_health_identity')) ==
          identityBefore,
      'identité et INSi inchangés',
    );
    final access = Access(
      (await Directory('${root.path}/backups').create()).path,
    );
    Future<String> backup() async {
      final r = await LocalDatabaseBackupService(access: access).createBackup(
        databaseNotFoundMessage: 'absente',
        chooseBackupFolderTitle: 'isolé',
        cancelledMessage: 'annulé',
      );
      if (!r.success) throw StateError(r.error!);
      return r.backupPath!;
    }

    final ordinary = File(
      '${root.path}/support/episode_documents/SYN-E/note.pdf',
    );
    await ordinary.parent.create(recursive: true);
    await ordinary.writeAsString('Pièce synthétique conservée');
    await db.insert('episode_documents', {
      'document_id': 'SYN-ORDINARY',
      'case_id': 'SYN-E',
      'title': 'Pièce ordinaire',
      'file_path': ordinary.path,
      'mime_type': 'application/pdf',
      'created_at': 1,
    });
    final external = Directory('${root.path}/patient-documents/Patient');
    await external.create(recursive: true);
    await File(
      '${external.path}/rapport.docx',
    ).writeAsString('DOCX synthétique');
    await db.insert('patient_document_folders', {
      'patient_id': 'SYN-P',
      'root_path': external.parent.path,
      'folder_name': 'Patient',
    });
    final beforeAttempt = await fresh();
    await release(beforeAttempt);
    final backupPath = await backup();
    final prepared = await const CompanionBackupArchive().prepare(backupPath);
    check(
      prepared.managed.length == 2,
      'archive v2 : pièces et versions intégrées',
    );
    check(
      await File(
        '${prepared.directory.path}/managed/episode_document_versions/${held.relativePath}',
      ).exists(),
      'PDF figé présent dans archive',
    );
    check(
      File('${prepared.directory.path}/managed/episode_documents/SYN-E/note.pdf')
              .readAsStringSync() ==
          'Pièce synthétique conservée',
      'pièce ordinaire incluse',
    );
    check(
      File(
            '${prepared.directory.path}/documents/0/rapport.docx',
          ).readAsStringSync() ==
          'DOCX synthétique',
      'dossier externe toujours sauvegardé',
    );
    await prepared.dispose();
    await journal.simulate(
      beforeAttempt,
      DocumentLocalSimulation(directory: root),
    );
    final actualBefore = medicalCanonical(await db.query('document_attempts'));
    final failure = await FailingRestore(
      access: access,
    ).restoreDatabase(backupPath: backupPath);
    check(!failure.success, 'échec installation déclenche retour arrière');
    db = await DatabaseService.database;
    check(
      medicalCanonical(await db.query('document_attempts')) == actualBefore,
      'retour arrière conserve les tentatives récentes',
    );
    check(
      (await journal.status(beforeAttempt)).state == 'accepted',
      'acceptation récente après rollback',
    );
    check(
      await File('${(await pdf.root()).path}/${held.relativePath}').exists(),
      'PDF préservé après rollback',
    );
    final result = await LocalDatabaseRestoreService(
      access: access,
    ).restoreDatabase(backupPath: backupPath);
    check(
      result.success,
      'restauration complète archive v2 : ${result.message}',
    );
    db = await DatabaseService.database;
    check(
      (await journal.status(beforeAttempt)).state == 'restored',
      'ancienne sauvegarde avant tentative : suspension durable',
    );
    check(
      (await journal.status(v)).state == 'accepted',
      'résultat accepté restauré sans perte',
    );
    check(
      (await journal.status(held)).held,
      'retenue conservée par restauration',
    );
    final afterRestore = DocumentLocalSimulation(directory: root);
    await journal.simulate(beforeAttempt, afterRestore);
    check(afterRestore.calls == 0, 'restauration ancienne interdit renvoi');
    await refuses(
      () => journal.hold(beforeAttempt, false, expectedRevision: 1),
      'retenue ne lève pas suspension restauration',
    );
    check(
      (await controls.status(held)).pdfa == 'conforme',
      'rapports techniques restaurés et vérifiables',
    );
    check(
      File(ordinary.path).readAsStringSync() == 'Pièce synthétique conservée',
      'pièce restaurée avec son fichier',
    );
    check(
      medicalCanonical(await db.query('patient_fr_health_identity')) ==
          identityBefore,
      'restauration synthétique sans modification INSi',
    );
    final saved = await DatabaseService.openDatabaseFile(
      result.safetyBackupPath!,
      factory: databaseFactoryFfiNoIsolate,
    );
    check(
      (await saved.query(
            'document_attempts',
            where: 'version_id=?',
            whereArgs: [beforeAttempt.id],
          )).length ==
          1,
      'preuve plus récente conservée dans la copie de sécurité',
    );
    await saved.close();
    // Archive damage, missing PDF and symlink failures must leave active state intact.
    final bad = '${root.path}/corrupt.zip';
    final zip = ZipDecoder().decodeBytes(await File(backupPath).readAsBytes());
    final target = 'managed/episode_document_versions/${held.relativePath}';
    zip.addFile(ArchiveFile(target, 3, [1, 2, 3]));
    await File(bad).writeAsBytes(ZipEncoder().encode(zip));
    await refuses(
      () => const CompanionBackupArchive().prepare(bad),
      'archive altérée refusée avant restauration',
    );
    final retainedHistory = (await db.query('desktop_backups')).length;
    final proofRun = await controls.last(held.id);
    final proofFile = File(
      '${(await controls.root).path}/${proofRun!['directory']}/test-report.txt',
    );
    final proofBytes = await proofFile.readAsBytes();
    await proofFile.delete();
    await refuses(
      backup,
      'rapport natif absent interdit une sauvegarde complète',
    );
    await proofFile.writeAsBytes(proofBytes);
    check(
      (await db.query('desktop_backups')).length == retainedHistory,
      'échec de sauvegarde sans succès dans historique',
    );
    final frozen = File('${(await pdf.root()).path}/${held.relativePath}'),
        original = await frozen.readAsBytes();
    await frozen.writeAsString('corruption');
    await refuses(backup, 'PDF altéré interdit sauvegarde déclarée complète');
    final conflicting = await LocalDatabaseRestoreService(
      access: access,
    ).restoreDatabase(backupPath: backupPath);
    check(
      !conflicting.success && await frozen.readAsString() == 'corruption',
      'conflit de copie figée : aucun écrasement pendant restauration',
    );
    db = await DatabaseService.database;
    await frozen.writeAsBytes(original);
    final link = Link('${root.path}/support/episode_documents/unsafe');
    await link.create(external.path);
    await refuses(backup, 'lien symbolique refusé dans sauvegarde');
    await link.delete();
    // Restore into another support directory: files are rebound, historical proofs
    // are retained, current approvals are invalidated and all sends suspended.
    final oldSupport = '${root.path}/support';
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = Paths('${root.path}/relocated');
    final relocated = await LocalDatabaseRestoreService(
      access: access,
    ).restoreDatabase(backupPath: backupPath);
    check(relocated.success, 'restauration sur nouvel emplacement');
    db = await DatabaseService.database;
    final relocatedPath =
        (await db.query(
              'episode_documents',
              where: 'document_id=?',
              whereArgs: [held.documentId],
            )).single['file_path']
            as String;
    check(
      relocatedPath.startsWith('${root.path}/relocated/') &&
          await File(relocatedPath).exists(),
      'pièce reliée au nouvel emplacement',
    );
    check(
      !(await medical.status(held)).valid,
      'rattachement déplacé invalide confirmation courante',
    );
    check(
      (await db.query('document_control_results')).isNotEmpty,
      'preuves historiques conservées malgré déplacement',
    );
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = Paths(oldSupport);
    db = await DatabaseService.database;
    // Database-only legacy restoration receives the same fail-closed barrier.
    final legacy = '${root.path}/legacy.db';
    await db.execute('VACUUM INTO ?', [legacy]);
    final legacyResult = await LocalDatabaseRestoreService(
      access: access,
    ).restoreDatabase(backupPath: legacy);
    check(
      legacyResult.success,
      'restauration base seule compatible et suspendue',
    );
    db = await DatabaseService.database;
    check(
      (await db.query('document_restore_barriers')).length >= 2,
      'barrières cumulatives conservées',
    );
    await refuses(
      () => db.delete('document_restore_barriers'),
      'suppression de barrière interdite',
    );
    check(errors.isEmpty, 'aucune erreur interface : $errors');
    final persist = {
      v.id: 'accepted',
      rejected.id: 'rejected',
      uncertain.id: 'indeterminate',
      interrupted.id: 'indeterminate',
      afterResponse.id: 'indeterminate',
      held.id: 'restored',
      beforeAttempt.id: 'restored',
      ...archiveStates,
    };
    await DatabaseService.closeDatabase();
    File('${output.path}/result.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'root': root.path,
        'count': checks.length,
        'checks': checks,
        'persist': persist,
        'networkCalls': 0,
        'cpsCalls': 0,
        'installedApplicationLaunched': false,
      }),
    );
    exit(0);
  } catch (e, st) {
    stderr.writeln('$e\n$st');
    File('${output.path}/failure.txt').writeAsStringSync('$e\n$st');
    exit(1);
  }
}
