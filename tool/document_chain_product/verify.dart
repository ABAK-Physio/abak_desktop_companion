import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/database/document_chain_schema.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/chain_service.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/transfer_simulation.dart';
import 'package:xml/xml.dart';
import 'fakes.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/archive_deposit_reader.dart';
import 'package:abak_desktop_companion/features/maintenance/services/companion_backup_archive.dart';
import 'package:abak_desktop_companion/features/maintenance/services/document_backup_contents.dart';
import '../document_journal_product/verify.dart' show Paths, Access;
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_journal_service.dart';
import 'package:abak_desktop_companion/features/patients/screens/document_journal_panel.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/maintenance/services/local_database_backup_service.dart';
import 'package:abak_desktop_companion/features/desktop_backup/services/local_database_restore_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import '../document_controls_product/verify.dart'
    show Inspector, Renderer, Runner;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await S.load(const Locale('fr', 'FR'));
  final output = Directory(Platform.environment['CHAIN_TEST_OUTPUT']!)
    ..createSync(recursive: true);
  final repo = Platform.environment['CHAIN_TEST_REPO']!;
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
    var clock = DateTime.utc(2026, 10, 17, 12);

    if (Platform.environment['CHAIN_TEST_PHASE'] == 'reopen') {
      final saved = jsonDecode(
        File('${output.path}/result.json').readAsStringSync(),
      );
      final root = Directory(saved['root']);
      PathProviderPlatform.instance = Paths('${root.path}/support');
      final pdf = FinalPdfDocumentService(inspector: Inspector());
      final medical = DocumentMedicalService(
        pdf: pdf,
        renderer: Renderer(png),
        now: () => clock,
      );
      final journal = DocumentJournalService(
        controls: DocumentControlsService(medical: medical, runner: Runner()),
      );
      final chain = DocumentDmpChain(journal: journal);
      final db = await pdf.database();
      for (final e in (saved['persist'] as Map).entries) {
        final v = EpisodeDocumentVersion(
          (await db.query(
            'episode_document_versions',
            where: 'version_id=?',
            whereArgs: [e.key],
          )).single,
        );
        final f = Ports(repo, () => clock);
        check(
          (await chain.executeSimulated(v, directory: root, ports: f)).state ==
                  e.value &&
              f.order.isEmpty,
          'nouveau processus : ${e.value}, aucune interface appelée',
        );
      }
      check(
        (await db.query('document_chain_steps')).isNotEmpty,
        'preuves accessibles après nouveau processus',
      );
      await DatabaseService.closeDatabase();
      File('${output.path}/restart.json').writeAsStringSync(
        jsonEncode({
          'count': checks.length,
          'checks': checks,
          'networkCalls': 0,
          'cpsCalls': 0,
        }),
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
    final pdf = FinalPdfDocumentService(inspector: Inspector());
    final medical = DocumentMedicalService(
      pdf: pdf,
      renderer: Renderer(png),
      now: () => clock,
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

    final chain = DocumentDmpChain(journal: journal);
    final persisted = <String, String>{};
    Future<DocumentJournalStatus> execute(
      EpisodeDocumentVersion v,
      Ports f, {
      DocumentDmpChain? service,
    }) => (service ?? chain).executeSimulated(v, directory: root, ports: f);
    Future<List<Map<String, Object?>>> steps(EpisodeDocumentVersion v) =>
        db.query(
          'document_chain_steps',
          where: 'version_id=?',
          whereArgs: [v.id],
          orderBy: 'rowid',
        );
    await db.execute('DROP TABLE document_chain_steps');
    await db.setVersion(35);
    await refuses(
      () => db.transaction((tx) async {
        await createDocumentChainTables(tx);
        throw StateError('crash');
      }),
      'migration J5 interrompue annulée',
    );
    check(
      (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE name='document_chain_steps'",
      )).isEmpty,
      'migration sans table partielle',
    );
    await DatabaseService.closeDatabase();
    db = await DatabaseService.database;
    check(await db.getVersion() == 36, 'migration additive 35 vers 36');
    await createDocumentChainTables(db);
    check(
      (await db.query('document_chain_steps')).isEmpty,
      'migration répétée sans preuve inventée',
    );

    final held = await fresh(), fHeld = Ports(repo, () => clock);
    await execute(held, fHeld);
    check(fHeld.order.isEmpty, 'retenue bloque toute interface');
    await release(held);
    await refuses(
      () => chain.executeSimulated(held, directory: output, ports: fHeld),
      'stockage non marqué refusé',
    );
    check(fHeld.order.isEmpty, 'aucune interface avant contrôle du stockage');
    for (final mode in ['missing', 'unchecked']) {
      final v = await fresh(
        approve: mode != 'missing',
        checked: mode != 'unchecked',
      );
      await release(v);
      final f = Ports(repo, () => clock);
      final result = await execute(v, f);
      check(
        result.state == 'chain_blocked' && f.order.isEmpty,
        '$mode : prérequis produit arrêtent toute interface',
      );
    }
    final pass = await fresh();
    await release(pass);
    final fake = Ports(repo, () => clock);
    check(
      (await execute(pass, fake)).state == 'accepted',
      'chaîne complète avec résultat accepté fictif',
    );
    check(
      fake.order.join(',') == 'auth,policy,td02,sign,verify,tls,policy,deposit',
      'ordre des interfaces et second contrôle des droits',
    );
    check(fake.calls == 1, 'un seul appel fictif de dépôt');
    final all = await steps(pass);
    check(
      all.map((e) => e['phase']).join(',') ==
          'preparation,authentication,policy,td02,package,signature,tls,reservation,response',
      'toutes les phases conservées',
    );
    check(
      (await journal.history(
            pass.documentId,
          )).where((e) => (e['kind'] as String).startsWith('chain_')).length ==
          all.length,
      'chaîne dans le même journal métier',
    );
    final sent = fake.sent!, parsed = XmlDocument.parse(sent.request);
    final encoded = parsed.descendants
        .whereType<XmlElement>()
        .singleWhere((e) => e.name.local == 'Document')
        .innerText;
    check(
      FinalPdfDocumentService.hash(base64Decode(encoded)) == sent.cdaHash,
      'CDA exact dans la proposition XDS',
    );
    check(
      sent.snapshotHash ==
          all
              .map((e) => jsonDecode(e['data_json'] as String))
              .first['snapshotHash'],
      'empreinte du contexte médical inchangée',
    );
    check(
      sent.metadata.contains('180019912345601') &&
          sent.vihf.contains('12345678901') &&
          !sent.request.contains('Sylvain') &&
          !sent.request.contains('899700870597') &&
          !sent.request.contains('RPLC'),
      'identité et professionnel provenant du dossier, aucune cible de remplacement',
    );
    check(
      !sent.request.contains('https://') &&
          sent.vihf.contains('simulation-isolee'),
      'aucune destination réseau utilisable',
    );
    final headerId = parsed.descendants
        .whereType<XmlElement>()
        .singleWhere((e) => e.name.local == 'MessageID')
        .innerText;
    check(
      sent.messageId == headerId,
      'identifiant généré identique au message conservé',
    );
    final largePackage = DmpPreparedSubmission(
      request: sent.request + ' ' * 2200000,
      messageId: sent.messageId,
      metadata: sent.metadata,
      vihf: sent.vihf,
      cdaHash: sent.cdaHash,
      snapshotHash: sent.snapshotHash,
      sessionHash: sent.sessionHash,
    );
    final largeResponse = await Ports(repo, () => clock).deposit(
      largePackage,
      const DmpSignature(
        packageHash: '',
        certificateHash: '',
        value: '',
        format: 'simulation',
      ),
      await fake.authenticate(
        jsonDecode(
          (await journal.prepare(pass)).receipt['snapshot_json'] as String,
        ),
      ),
    );
    check(
      ArchiveDepositReader.readForMessageId(
            requestMessageId: largePackage.messageId,
            headers: largeResponse.headers,
            bytes: largeResponse.bytes,
          ).outcome ==
          DepositOutcome.accepted,
      'corrélation sans reparser un grand message contenant le PDF',
    );
    final originalFakeHash = sent.hash;
    final altered = DmpPreparedSubmission(
      request: '${sent.request} ',
      messageId: sent.messageId,
      metadata: sent.metadata,
      vihf: sent.vihf,
      cdaHash: sent.cdaHash,
      snapshotHash: sent.snapshotHash,
      sessionHash: sent.sessionHash,
    );
    check(
      altered.hash != originalFakeHash,
      'modification des octets invalide la signature du contrat',
    );
    await execute(pass, fake);
    check(fake.calls == 1, 'renvoi accepté bloqué');
    persisted[pass.id] = 'accepted';
    // The same PDF under a new record and a new version of an attempted piece stay blocked.
    final duplicate = await fresh(
      exactSource: (await pdf.verifyStoredBytes(pass)).path,
    );
    await release(duplicate).catchError((_) {});
    final noDuplicate = Ports(repo, () => clock);
    await execute(duplicate, noDuplicate);
    check(
      noDuplicate.order.isEmpty,
      'copie identique sous autre pièce bloquée avant interfaces',
    );
    final version2 = await fresh(documentId: pass.documentId);
    final noVersion2 = Ports(repo, () => clock);
    await execute(version2, noVersion2);
    check(
      noVersion2.order.isEmpty,
      'nouvelle version de pièce traitée ne réarme pas le dépôt',
    );

    final modes = [
      'auth_error',
      'wrong_professional',
      'wrong_structure',
      'expired',
      'wrong_policy',
      'catalog',
      'opposition',
      'unknown_rights',
      'rights',
      'author',
      'visibility',
      'codes',
      'uncorrelated_td',
      'wrong_patient',
      'absent',
      'closed',
      'soap',
      'xml',
      '503',
      'signature_error',
      'wrong_payload',
      'wrong_cert',
      'bad_signature',
      'session_changed',
      'policy_changed',
    ];
    EpisodeDocumentVersion? lastBlocked;
    for (final mode in modes) {
      final v = await fresh();
      await release(v);
      final f = Ports(repo, () => clock)..scenario = mode;
      final result = await execute(v, f);
      check(
        result.state == 'chain_blocked' &&
            result.attempt == null &&
            f.calls == 0,
        '$mode : blocage avant tentative',
      );
      final rows = await steps(v);
      check(
        rows.last['state'] == 'blocked' &&
            (rows.last['detail'] as String).isNotEmpty,
        '$mode : motif conservé dans le journal',
      );
      lastBlocked = v;
    }
    check(
      !(await db.query(
        'document_chain_steps',
      )).toString().contains('PIN SECRET'),
      'aucun secret issu des exceptions conservé',
    );
    for (final failure in TlsFailure.values) {
      final v = await fresh();
      await release(v);
      final f = Ports(repo, () => clock)..tls = failure;
      final result = await execute(v, f);
      check(
        result.state == 'chain_blocked' &&
            f.calls == 0 &&
            (await steps(
              v,
            )).last['detail'].toString().contains(failure.message),
        'TLS ${failure.name} : message exact et aucun dépôt',
      );
    }
    final noConsent = await fresh();
    await release(noConsent);
    final consentFake = Ports(repo, () => clock)
      ..scenario = 'consultation_absent';
    check(
      (await execute(noConsent, consentFake)).state == 'accepted',
      'droit de consultation distinct du droit de dépôt',
    );
    persisted[noConsent.id] = 'accepted';
    // New submission must not consume an unchanged historical success.
    for (final scenario in [
      'archive_accepted',
      'archive_signature',
      'archive_metadata',
      'archive_accepted_unchanged',
      'timeout',
      'uncorrelated',
      'malformed',
      'redirect',
    ]) {
      final v = await fresh();
      await release(v);
      final f = Ports(repo, () => clock)..scenario = scenario;
      final result = await execute(v, f);
      final expected = scenario == 'archive_accepted'
          ? 'accepted'
          : ['archive_signature', 'archive_metadata'].contains(scenario)
          ? 'rejected'
          : 'indeterminate';
      check(result.state == expected, '$scenario : issue $expected');
      await execute(v, f);
      check(f.calls == 1, '$scenario : zéro renvoi');
      persisted[v.id] = expected;
    }
    // Race tests re-enter the real product storage, using only synthetic records.
    for (final change in [
      'hold',
      'preparation',
      'stale',
      'clock_back',
      'controls',
    ]) {
      final v = await fresh();
      await release(v);
      final f = Ports(repo, () => clock);
      final custom = DocumentDmpChain(
        journal: journal,
        checkpoint: (point) async {
          if (point != 'before_reservation') return;
          switch (change) {
            case 'hold':
              await journal.hold(v, true, expectedRevision: 1);
            case 'preparation':
              await medical.savePreparation(v, {
                ...draft,
                'title': 'CHANGED',
              }, expectedRevision: 1);
            case 'stale':
              clock = clock.add(const Duration(minutes: 3));
            case 'clock_back':
              clock = clock.subtract(const Duration(seconds: 30));
            case 'controls':
              await controls.run(v);
          }
        },
      );
      final result = await execute(v, f, service: custom);
      check(
        result.state == 'chain_blocked' &&
            f.calls == 0 &&
            result.attempt == null,
        'course $change : aucune tentative',
      );
      clock = DateTime.utc(2026, 10, 17, 12);
    }
    for (final phase in ['after_reservation', 'after_response']) {
      final v = await fresh();
      await release(v);
      final f = Ports(repo, () => clock);
      final custom = DocumentDmpChain(
        journal: journal,
        checkpoint: (point) async {
          if (point == phase) throw StateError('interruption');
        },
      );
      check(
        (await execute(v, f, service: custom)).state == 'indeterminate',
        'interruption $phase conservée',
      );
      final calls = f.calls;
      await execute(v, f);
      check(f.calls == calls, 'interruption $phase : aucun nouvel appel');
      persisted[v.id] = 'indeterminate';
    }
    final concurrent = await fresh();
    await release(concurrent);
    final gate = Completer<void>(), entered = Completer<void>();
    final slow = Ports(repo, () => clock)
      ..atDeposit = () async {
        entered.complete();
        await gate.future;
      };
    final running = execute(concurrent, slow);
    await entered.future;
    final racing = Ports(repo, () => clock);
    await execute(concurrent, racing);
    check(
      racing.order.isEmpty,
      'réservation visible pendant un appel concurrent',
    );
    gate.complete();
    await running;
    check(
      slow.calls == 1 && racing.calls == 0,
      'une seule tentative concurrente',
    );
    persisted[concurrent.id] = 'accepted';
    final row = (await steps(pass)).first;
    await refuses(
      () => db.update(
        'document_chain_steps',
        {'detail': 'forged'},
        where: 'step_id=?',
        whereArgs: [row['step_id']],
      ),
      'preuve immuable',
    );
    await refuses(
      () => db.insert(
        'document_chain_steps',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      ),
      'remplacement de preuve interdit',
    );
    await refuses(
      () => db.delete(
        'document_chain_steps',
        where: 'step_id=?',
        whereArgs: [row['step_id']],
      ),
      'suppression de preuve interdite',
    );

    // Same widget as the product PDF screen, not a new simulation screen.
    final ctl = LiveWidgetController(WidgetsBinding.instance),
        boundary = GlobalKey();
    Future<void> show(EpisodeDocumentVersion v) async {
      runApp(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RepaintBoundary(
                key: boundary,
                child: DocumentJournalPanel(
                  key: ValueKey(v.id),
                  service: journal,
                  version: v,
                  enabled: true,
                ),
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 15; i++) {
        await ctl.pump(const Duration(milliseconds: 30));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }

    await show(lastBlocked!);
    check(
      find.textContaining('Simulation —').evaluate().isNotEmpty,
      'motif de blocage dans le panneau métier',
    );
    check(
      find.textContaining('aucun dépôt sur le DMP').evaluate().isNotEmpty,
      'limite simulation visible',
    );
    final screenshot =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 1);
    File('${output.path}/journal-chaine.png').writeAsBytesSync(
      (await screenshot.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List(),
    );
    screenshot.dispose();
    await show(concurrent);
    check(
      ctl
              .widget<SwitchListTile>(find.byKey(const Key('document-hold')))
              .onChanged ==
          null,
      'retenue verrouillée après résultat dans écran produit',
    );
    runApp(const SizedBox.shrink());
    await ctl.pump();
    var countSteps = (await db.query('document_chain_steps')).length;
    await DatabaseService.closeDatabase();
    db = await DatabaseService.database;
    check(
      (await db.query('document_chain_steps')).length == countSteps,
      'toutes les étapes persistantes après réouverture',
    );
    check(
      (await journal.status(lastBlocked)).state == 'chain_blocked',
      'blocage préliminaire persistant',
    );
    for (final e in persisted.entries) {
      final v = EpisodeDocumentVersion(
        (await db.query(
          'episode_document_versions',
          where: 'version_id=?',
          whereArgs: [e.key],
        )).single,
      );
      final f = Ports(repo, () => clock);
      check(
        (await execute(v, f)).state == e.value && f.calls == 0,
        'réouverture : ${e.value}, aucun nouvel appel',
      );
    }
    check(
      medicalCanonical(await db.query('patient_fr_health_identity')) ==
          identityBefore,
      'identité et INSi inchangés',
    );

    final identityRow = (await db.query('patient_fr_health_identity')).single;
    for (final identityCase in ['nia', 'doubtful', 'incomplete']) {
      final v = await fresh();
      await release(v);
      final f = Ports(repo, () => clock);
      await db.update(
        'patient_fr_health_identity',
        switch (identityCase) {
          'nia' => {'ins_oid': '1.2.250.1.213.1.4.9'},
          'doubtful' => {'identity_doubtful': 1},
          _ => {'birth_place_code': ''},
        },
        where: 'patient_id=?',
        whereArgs: ['SYN-P'],
      );
      check(
        (await execute(v, f)).state == 'chain_blocked' && f.order.isEmpty,
        'identité $identityCase bloque avant authentification',
      );
      await db.update(
        'patient_fr_health_identity',
        identityRow,
        where: 'patient_id=?',
        whereArgs: ['SYN-P'],
      );
    }
    check(
      medicalCanonical(await db.query('patient_fr_health_identity')) ==
          identityBefore,
      'seul le jeu synthétique a été modifié, source rétablie',
    );
    countSteps = (await db.query('document_chain_steps')).length;
    // Backup/restore uses the existing product implementation with isolated paths.
    final backupDir = Directory('${root.path}/backups')..createSync();
    final access = Access(backupDir.path);
    final service = LocalDatabaseBackupService(access: access);
    final backupResult = await service.createBackup(
      chooseBackupFolderTitle: "Synthétique",
      cancelledMessage: "Annulé",
      databaseNotFoundMessage: "Absente",
    );
    check(
      backupResult.success,
      'sauvegarde produit incluant chaîne et preuves',
    );
    final zipPath = backupResult.backupPath!;
    final staged = await const CompanionBackupArchive().prepare(zipPath);
    final stagedDb = await databaseFactoryFfiNoIsolate.openDatabase(
      staged.databasePath,
    );
    await stagedDb.execute('DROP TRIGGER chain_delete');
    final reservedStep = (await stagedDb.query(
      'document_chain_steps',
      where: "state='reserved'",
      limit: 1,
    )).single;
    await stagedDb.delete(
      'document_chain_steps',
      where: "chain_id=? AND phase='package'",
      whereArgs: [reservedStep['chain_id']],
    );
    await refuses(
      () => DocumentBackupContents.validate(
        stagedDb,
        staged.directory,
        staged.managed,
      ),
      'preuve de préparation manquante : restauration refusée',
    );
    await stagedDb.close();
    await staged.dispose();

    final restore = await LocalDatabaseRestoreService(
      access: access,
    ).restoreDatabase(backupPath: zipPath);
    check(
      restore.success,
      'restauration produit des pièces, preuves et journal',
    );
    db = await DatabaseService.database;
    check(
      (await db.query('document_chain_steps')).length == countSteps,
      'preuves J5 intégralement restaurées',
    );
    final restoredFake = Ports(repo, () => clock);
    check(
      (await execute(lastBlocked, restoredFake)).state == 'restored' &&
          restoredFake.order.isEmpty,
      'restauration bloque avant authentification simulée',
    );
    persisted[lastBlocked.id] = 'restored';
    check(errors.isEmpty, 'aucune erreur de widget');
    await DatabaseService.closeDatabase();
    File('${output.path}/result.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'root': root.path,
        'count': checks.length,
        'checks': checks,
        'persist': persisted,
        'networkCalls': 0,
        'cpsCalls': 0,
        'realLotsAccessed': false,
        'installedApplicationLaunched': false,
        'wireProfileValidated': false,
      }),
    );
    exit(0);
  } catch (e, st) {
    stderr.writeln('$e\n$st');
    File('${output.path}/failure.txt').writeAsStringSync('$e\n$st');
    exit(1);
  }
}
