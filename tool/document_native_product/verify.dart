import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/chain_service.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import '../document_chain_product/fakes.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/ports.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/bridge.dart';
import 'package:abak_desktop_companion/features/cps/cps_profile.dart';
import 'package:abak_desktop_companion/features/cps/cps_operation_lease.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';
import 'package:abak_desktop_companion/features/maintenance/services/companion_backup_archive.dart';
import 'package:abak_desktop_companion/features/maintenance/services/document_backup_contents.dart';
import '../document_journal_product/verify.dart' show Paths, Access;
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_journal_service.dart';
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
      for (final id in saved['blocked'] as List) {
        final rows = await db.query(
          'document_chain_steps',
          where: 'version_id=? AND state=?',
          whereArgs: [id, 'blocked'],
        );
        check(
          rows.isNotEmpty &&
              (await db.query(
                'document_attempts',
                where: 'version_id=?',
                whereArgs: [id],
              )).isEmpty,
          'refus avant réservation conservé : $id',
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

    final certificates = Platform.environment['WIRE_CERTIFICATES']!;
    final classes = Platform.environment['NATIVE_CLASSES']!;
    final manifest = jsonDecode(
      File('$certificates/manifest.json').readAsStringSync(),
    );
    int pinCalls = 0, profileCalls = 0, nativeIndex = 0;
    final traces = <String, File>{};
    DocumentDmpNativePorts ports(String scenario) {
      final signKind =
          [
            'expired',
            'future',
            'revoked',
            'wrong',
            'no_usage',
          ].contains(scenario)
          ? scenario
          : 'sign';
      final trustKind = ['stale', 'revoked_auth', 'bad_crl'].contains(scenario)
          ? scenario
          : 'trust';
      final trace = File(
        '${output.path}/native-${++nativeIndex}-$scenario.trace',
      );
      traces[scenario] = trace;
      return DocumentDmpNativePorts(
        configuration: DmpNativeConfiguration(
          wire: const DmpWireConfiguration(
            endpoint: 'https://synthetic.invalid/DocumentRepository',
            sourceId: '2.25.1234567890123456789',
            lpsId: 'SYN-INSTALLATION',
            lpsName: 'ABAK SYNTHETIC',
            lpsVersion: 'SYN-1',
            homologationId: 'SYN-NOT-HOMOLOGATED',
          ),
          td02Endpoint: 'https://synthetic.invalid/td02',
          processingMode: 'T',
          libraryPath: '/NEVER-LOAD-CPS',
          trustPath: '$certificates/$trustKind.pem',
          trustHash: scenario == 'bad_trust_hash'
              ? 'a' * 64
              : manifest[trustKind],
          authenticationHash: manifest['auth'],
          signingHash: manifest[signKind],
          situationNumber: 1,
          situationMode: 1,
          situationStatus: 1,
          situationSector: 'SYN-SECTOR',
        ),
        bridge: DmpProcessBridge(
          executable:
              '/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin/java',
          arguments: [
            '-cp',
            classes,
            'NativeTestBridge',
            certificates,
            repo,
            trace.path,
            scenario,
          ],
        ),
        requestPin: () async {
          pinCalls++;
          return scenario == 'cancelled' ? null : '1234';
        },
        readProfile: (pin, lease) async {
          profileCalls++;
          if (scenario == 'profile_error') {
            throw StateError('SECRET-NEVER-JOURNAL');
          }
          return CpsProfile(
            nationalId: scenario == 'wrong_professional'
                ? '99999999999'
                : '12345678901',
            familyName: 'SYNTHETIQUE',
            givenName: 'Kine',
            professionCode: scenario == 'wrong_profession' ? 10 : 70,
            cardType: 1,
            situations: [
              CpsSituation(
                number: scenario == 'wrong_situation' ? 2 : 1,
                mode: 1,
                status: 1,
                structureId: scenario == 'wrong_structure'
                    ? 'OTHER'
                    : 'SYN-CAB',
                sector: 'SYN-SECTOR',
              ),
            ],
          );
        },
        readPolicy: (snapshot) => Ports(repo, () => clock).policy(snapshot),
        now: () => clock,
      );
    }

    List<String> trace(String scenario) => traces[scenario]!.existsSync()
        ? traces[scenario]!.readAsLinesSync()
        : [];
    final chain = DocumentDmpChain(journal: journal),
        persisted = <String, String>{},
        blocked = <String>[];
    Future<DocumentJournalStatus> execute(
      EpisodeDocumentVersion v,
      DocumentDmpPorts f, {
      DocumentDmpChain? service,
    }) => (service ?? chain).executeSimulated(v, directory: root, ports: f);
    Future<List<Map<String, Object?>>> steps(
      EpisodeDocumentVersion v,
      String phase,
    ) => db.query(
      'document_chain_steps',
      where: 'version_id=? AND phase=?',
      whereArgs: [v.id, phase],
    );
    for (final kind in [
      'wrong_id',
      'duplicate',
      'base64',
      'truncated',
      'secret',
      'oversize',
      'timeout',
    ]) {
      final b = DmpProcessBridge(
        executable:
            '/Users/jeanclaudebrucher/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3',
        arguments: [
          '$repo/tool/document_native_product/protocol_double.py',
          kind,
        ],
        timeout: Duration(seconds: kind == 'timeout' ? 1 : 5),
      );
      try {
        await refuses(
          () => b.call('current', {}),
          'protocole natif $kind refusé',
        );
      } finally {
        await b.close();
      }
      check(true, 'protocole natif $kind : arrêt du processus confirmé');
    }
    final nativeError = DmpNativeFailure('SECRET-MUST-NOT-LEAK');
    check(
      !nativeError.message.contains('SECRET'),
      'code natif inconnu : message fixe sans donnée sensible',
    );
    final held = await fresh();
    check(
      (await execute(held, ports('held'))).held &&
          pinCalls == 0 &&
          !traces['held']!.existsSync(),
      'retenue : ni PIN, ni interface native',
    );

    final pass = await fresh();
    await release(pass);
    final passPorts = ports('accepted');
    final result = await execute(pass, passPorts);
    if (result.state != 'accepted') {
      stdout.writeln(
        jsonEncode(
          await db.query(
            'document_chain_steps',
            where: 'version_id=?',
            whereArgs: [pass.id],
          ),
        ),
      );
    }
    check(
      result.state == 'accepted',
      'chaîne native complète acceptée avec TLS en mémoire et archive corrélée',
    );
    final order = trace('accepted');
    check(
      order.indexOf('tls_td') < order.indexOf('td') &&
          order.indexOf('tls_deposit') < order.indexOf('sign') &&
          order.where((s) => s == 'deposit').length == 1,
      'deux TLS mutuels avant TD0.2 et signature, un seul dépôt fictif',
    );
    check(
      order.contains('td_close') &&
          order.contains('deposit_close') &&
          order.last == 'identity_close',
      'canaux fermés et identité libérée après succès',
    );
    final auth = jsonDecode(
      (await steps(pass, 'authentication')).single['data_json'] as String,
    );
    final pack = jsonDecode(
      (await steps(pass, 'package')).single['data_json'] as String,
    );
    final captured = await journal.prepare(pass);
    DmpWireDraft.verifyArchived(
      pack,
      jsonDecode(captured.receipt['snapshot_json'] as String),
      auth,
    );
    check(
      auth['native']['mutualTls'] == 'true' &&
          auth['native']['tdChannel'] != auth['native']['depositChannel'],
      'preuves natives distinctes liées au paquet et vérification archivistique',
    );
    final beforePin = pinCalls;
    check(
      (await execute(pass, ports('resend'))).state == 'accepted' &&
          pinCalls == beforePin &&
          !traces['resend']!.existsSync(),
      'renvoi bloqué avant authentification',
    );
    persisted[pass.id] = 'accepted';

    final concurrentA = await fresh(), concurrentB = await fresh();
    await release(concurrentA);
    await release(concurrentB);
    final shared = ports('concurrent');
    final concurrent = await Future.wait([
      execute(concurrentA, shared),
      execute(concurrentB, shared),
    ]);
    check(
      concurrent.where((s) => s.state == 'accepted').length == 1 &&
          concurrent.where((s) => s.attempt == null).length == 1,
      'adaptateur partagé : second appel bloqué sans fermer la session du premier',
    );
    check(
      trace('concurrent').where((s) => s == 'deposit').length == 1 &&
          trace('concurrent').last == 'identity_close',
      'concurrence : une seule tentative et fermeture par son propriétaire',
    );
    persisted[(concurrent[0].state == 'accepted' ? concurrentA : concurrentB)
            .id] =
        'accepted';
    final expected = <String, String>{
      'cancelled': 'annulée',
      'profile_error': 'CPS indisponible',
      'wrong_professional': 'différente',
      'wrong_profession': 'différente',
      'wrong_situation': 'différente',
      'wrong_structure': 'différente',
      'bad_trust_hash': 'Configuration',
      'pin_wrong': 'PIN incorrect',
      'pin_blocked': 'PIN bloqué',
      'card_absent': 'CPS absente',
      'expired': 'expiré',
      'future': 'pas encore',
      'revoked': 'révoqué',
      'wrong': 'professionnel',
      'no_usage': 'Certificats CPS',
      'stale': 'révocation périmée',
      'revoked_auth': 'révoqué',
      'bad_crl': 'validé',
      'hostname': 'serveur attendu',
      'tls_timeout': 'dépassé',
      'card_removed': 'CPS absente',
      'td_uncorrelated': 'corrél',
      'td_soap': 'SOAP',
      'td_503': '503',
      'td_redirect': '302',
      'signature_failure': 'CPS absente',
    };
    for (final entry in expected.entries) {
      final v = await fresh();
      await release(v);
      final r = await execute(v, ports(entry.key));
      final events = await db.query(
        'document_chain_steps',
        where: 'version_id=? AND state=?',
        whereArgs: [v.id, 'blocked'],
      );
      final messages = events.map((e) => e['detail']).join('\n');
      check(
        r.attempt == null &&
            events.isNotEmpty &&
            !trace(entry.key).contains('deposit'),
        '${entry.key} : blocage avant réservation, zéro dépôt',
      );
      // Exact wording is asserted for known typed failures; reader messages are archived separately.
      if (![
        'future',
        'wrong',
        'bad_crl',
        'td_uncorrelated',
        'td_soap',
        'td_503',
        'td_redirect',
      ].contains(entry.key)) {
        check(
          messages.contains(entry.value),
          '${entry.key} : message attendu ($messages)',
        );
      }
      final eventsTrace = trace(entry.key);
      if (eventsTrace.contains('tls_deposit') &&
          !['hostname', 'tls_timeout'].contains(entry.key)) {
        check(
          eventsTrace.contains('td_close') &&
              eventsTrace.contains('identity_close'),
          '${entry.key} : fermeture après échec',
        );
      } else if (eventsTrace.contains('current')) {
        check(
          eventsTrace.contains('identity_close'),
          '${entry.key} : identité libérée',
        );
      }
      blocked.add(v.id);
    }
    // A CPS lease held elsewhere blocks this adapter without any PIN prompt.
    final busy = await fresh();
    await release(busy);
    final lease = CpsOperationLease.acquire();
    final pins = pinCalls;
    try {
      check(
        (await execute(busy, ports('busy'))).attempt == null &&
            pinCalls == pins,
        'session concurrente bloquée avant demande du PIN',
      );
    } finally {
      lease.release();
    }

    for (final scenario in [
      'signature_rejected',
      'metadata_rejected',
      'deposit_timeout',
      'deposit_uncorrelated',
    ]) {
      final v = await fresh();
      await release(v);
      final r = await execute(v, ports(scenario));
      final state = scenario.endsWith('rejected')
          ? 'rejected'
          : 'indeterminate';
      check(
        r.state == state &&
            trace(scenario).where((x) => x == 'deposit').length == 1,
        '$scenario : résultat $state conservé',
      );
      final count = pinCalls;
      check(
        (await execute(v, ports('${scenario}_resend'))).state == state &&
            pinCalls == count,
        '$scenario : renvoi bloqué avant toute interface',
      );
      check(
        trace(scenario).last == 'identity_close',
        '$scenario : fermeture même après résultat indéterminé',
      );
      persisted[v.id] = state;
    }
    final interrupted = await fresh();
    await release(interrupted);
    final interruption = DocumentDmpChain(
      journal: journal,
      checkpoint: (phase) async {
        if (phase == 'after_reservation') {
          throw StateError('interruption synthétique');
        }
      },
    );
    check(
      (await execute(
                interrupted,
                ports('interrupted'),
                service: interruption,
              )).state ==
              'indeterminate' &&
          !trace('interrupted').contains('deposit'),
      'interruption après réservation : indéterminé durable sans dépôt',
    );
    persisted[interrupted.id] = 'indeterminate';
    check(
      trace('interrupted').last == 'identity_close',
      'interruption : session libérée',
    );

    final backupDir = Directory('${root.path}/backups')..createSync();
    final access = Access(backupDir.path);
    final backupResult = await LocalDatabaseBackupService(access: access)
        .createBackup(
          chooseBackupFolderTitle: 'Synthétique',
          cancelledMessage: 'Annulé',
          databaseNotFoundMessage: 'Absente',
        );
    check(
      backupResult.success,
      'sauvegarde produit du paquet et des preuves natives',
    );
    final zipPath = backupResult.backupPath!;
    final altered = await const CompanionBackupArchive().prepare(zipPath);
    final alteredDb = await databaseFactoryFfiNoIsolate.openDatabase(
      altered.databasePath,
    );
    await alteredDb.execute('DROP TRIGGER chain_update');
    final authRow = (await alteredDb.query(
      'document_chain_steps',
      where: "phase='authentication' AND state='passed'",
      limit: 1,
    )).single;
    final badAuth = jsonDecode(authRow['data_json'] as String);
    badAuth['native']['tdChannel'] = 'altered';
    await alteredDb.update(
      'document_chain_steps',
      {
        'data_json': medicalCanonical(badAuth),
        'data_hash': medicalHash(badAuth),
      },
      where: 'step_id=?',
      whereArgs: [authRow['step_id']],
    );
    await refuses(
      () => DocumentBackupContents.validate(
        alteredDb,
        altered.directory,
        altered.managed,
      ),
      'preuve TLS altérée même avec hash recalculé : restauration refusée',
    );
    await alteredDb.close();
    await altered.dispose();
    final restore = await LocalDatabaseRestoreService(
      access: access,
    ).restoreDatabase(backupPath: zipPath);
    check(restore.success, 'restauration produit des preuves natives intactes');
    db = await DatabaseService.database;
    final pinsAfterRestore = pinCalls;
    check(
      (await execute(held, ports('restored'))).state == 'restored' &&
          pinCalls == pinsAfterRestore,
      'restauration : verrou avant CPS/TLS',
    );
    persisted[held.id] = 'restored';

    // Actual product backup includes native evidence and verifies the wire replay.
    final receiptJson = medicalCanonical(
      await db.query('document_chain_steps'),
    );
    check(
      !receiptJson.contains('SECRET-NEVER-JOURNAL') &&
          !receiptJson.contains('"pin"') &&
          !receiptJson.contains('PRIVATE KEY'),
      'journal sans PIN ni clé privée ni erreur brute',
    );
    check(
      medicalCanonical(await db.query('patient_fr_health_identity')) ==
          identityBefore,
      'identité INSi synthétique inchangée',
    );
    check(errors.isEmpty, 'aucune erreur Flutter');
    await DatabaseService.closeDatabase();
    File('${output.path}/result.json').writeAsStringSync(
      jsonEncode({
        'root': root.path,
        'count': checks.length,
        'checks': checks,
        'persist': persisted,
        'blocked': blocked,
        'networkCalls': 0,
        'cpsCalls': 0,
        'pinPromptsSimulated': pinCalls,
        'profilesSimulated': profileCalls,
      }),
    );
    exit(0);
  } catch (e, st) {
    stderr.writeln('$e\n$st');
    exit(1);
  }
}
