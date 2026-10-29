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
import 'fakes.dart';
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
    WirePorts ports() => WirePorts(repo, () => clock, certificates);
    final chain = DocumentDmpChain(journal: journal),
        persisted = <String, String>{};
    Future<DocumentJournalStatus> execute(
      EpisodeDocumentVersion v,
      DocumentDmpPorts f, {
      DocumentDmpChain? service,
    }) => (service ?? chain).executeSimulated(v, directory: root, ports: f);
    Future<Map<String, dynamic>> phase(
      EpisodeDocumentVersion v,
      String name,
    ) async => jsonDecode(
      (await db.query(
            'document_chain_steps',
            where: 'version_id=? AND phase=? AND state=?',
            whereArgs: [v.id, name, 'passed'],
          )).single['data_json']
          as String,
    );
    final pass = await fresh();
    await release(pass);
    final f = ports();
    final first = await execute(pass, f);
    check(
      first.state == 'accepted',
      'paquet signé complet accepté par le service simulé : ${first.message}',
    );
    check(
      f.calls == 1 && f.order.contains('xades') && !f.order.contains('sign'),
      'signature RSA réelle synthétique, aucun HMAC',
    );
    final package = await phase(pass, 'package'),
        auth = await phase(pass, 'authentication'),
        sig = await phase(pass, 'signature');
    final captured = await journal.prepare(pass);
    final snapshot =
        jsonDecode(captured.receipt['snapshot_json'] as String)
            as Map<String, dynamic>;
    DmpWireDraft.verifyArchived(package, snapshot, auth);
    check(
      package['protocol'] == 'DMP-XDS-XADES-MTOM-2.10',
      'relecture complète du paquet scellé',
    );
    final wire = package['wire'];
    check(
      sig['certificateHash'] != auth['certificateHash'],
      'certificats authentification et signature distincts',
    );
    check(
      !medicalCanonical(package).contains('PRIVATE KEY'),
      'aucune clé privée dans le journal',
    );
    File('${output.path}/packet.json').writeAsStringSync(jsonEncode(package));
    File(
      '${output.path}/snapshot.json',
    ).writeAsStringSync(jsonEncode(snapshot));
    File(
      '${output.path}/authentication.json',
    ).writeAsStringSync(jsonEncode(auth));
    File(
      '${output.path}/request.mime',
    ).writeAsBytesSync(base64Decode(wire['mime']));
    File('${output.path}/request.headers').writeAsStringSync(
      'Content-Type: ${wire['contentType']}\r\nContent-Length: ${wire['contentLength']}\r\nMIME-Version: 1.0\r\n',
    );
    File('${output.path}/cda.xml').writeAsBytesSync(captured.payload);
    File(
      '${output.path}/signature.xml',
    ).writeAsStringSync(wire['signatureXml']);
    File(
      '${output.path}/signed-info.xml',
    ).writeAsStringSync(wire['signedInfo']);
    File('${output.path}/soap.xml').writeAsStringSync(wire['soap']);
    persisted[pass.id] = 'accepted';
    for (final which in [
      'mime',
      'soap',
      'metadata',
      'vihf',
      'signatureXml',
      'signedInfo',
      'contentType',
      'mimeSha256',
    ]) {
      final bad = jsonDecode(jsonEncode(package));
      bad['wire'][which] = '${bad['wire'][which]}X';
      await refuses(
        () =>
            Future.sync(() => DmpWireDraft.verifyArchived(bad, snapshot, auth)),
        '$which altéré refusé à la relecture',
      );
    }
    for (final which in ['patient', 'context', 'pdf']) {
      final bad = jsonDecode(jsonEncode(snapshot)) as Map<String, dynamic>;
      if (which == 'patient') bad['identity']['ins_key'] = '99';
      if (which == 'context') bad['practice']['revision'] = 999;
      if (which == 'pdf') bad['version']['sha256'] = 'f' * 64;
      await refuses(
        () =>
            Future.sync(() => DmpWireDraft.verifyArchived(package, bad, auth)),
        '$which différent refusé',
      );
    }
    final mutations = <String, String Function(String)>{
      'algorithme SHA256 non déclaré': (s) =>
          s.replaceAll('rsa-sha1', 'rsa-sha256'),
      'référence externe': (s) =>
          s.replaceAll('#IHEManifest', 'https://malicious.invalid/manifest'),
      'SignatureValue altérée': (s) =>
          s.replaceFirst('<ds:SignatureValue>', '<ds:SignatureValue>AA'),
      'SignedProperties déplacées': (s) =>
          s.replaceAll('S0-SignedProperties', 'WRONG'),
      'digest du certificat altéré': (s) =>
          s.replaceFirst('<xades:DigestValue>', '<xades:DigestValue>AA'),
      'cible de signature altérée': (s) =>
          s.replaceFirst('Target="#', 'Target="#other'),
      'manifest dupliqué': (s) => s.replaceFirst(
        '</ds:Signature>',
        '<ds:Object><ds:Manifest Id="IHEManifest"/></ds:Object></ds:Signature>',
      ),
    };
    for (final m in mutations.entries) {
      final bad = jsonDecode(jsonEncode(package));
      bad['wire']['signatureXml'] = m.value(wire['signatureXml']);
      await refuses(
        () =>
            Future.sync(() => DmpWireDraft.verifyArchived(bad, snapshot, auth)),
        m.key,
      );
    }
    for (final scenario in [
      'wrong',
      'expired',
      'future',
      'no_usage',
      'revoked',
      'untrusted',
      'unbound_certificate',
      'missing_configuration',
      'wrong_key',
      'bad_signature',
      'signature_error',
      'configuration_changed',
    ]) {
      final v = await fresh();
      await release(v);
      final p = ports()..scenario = scenario;
      final result = await execute(v, p);
      check(
        result.state == 'chain_blocked' &&
            result.attempt == null &&
            p.calls == 0,
        '$scenario : blocage avant réservation et zéro transport',
      );
      check(
        !medicalCanonical(
          await db.query(
            'document_chain_steps',
            where: 'version_id=?',
            whereArgs: [v.id],
          ),
        ).contains('TEST SECRET'),
        '$scenario : aucune donnée secrète journalisée',
      );
    }
    for (final scenario in [
      'accepted',
      'archive_accepted',
      'archive_signature',
      'archive_metadata',
      'archive_accepted_unchanged',
      'uncorrelated',
      'malformed',
      'timeout',
    ]) {
      final v = await fresh();
      await release(v);
      final p = ports()..scenario = scenario;
      final result = await execute(v, p);
      final expected = ['accepted', 'archive_accepted'].contains(scenario)
          ? 'accepted'
          : ['archive_signature', 'archive_metadata'].contains(scenario)
          ? 'rejected'
          : 'indeterminate';
      check(
        result.state == expected && p.calls == 1,
        '$scenario : $expected avec paquet signé et réponse corrélée',
      );
      final again = ports();
      await execute(v, again);
      check(
        again.order.isEmpty,
        '$scenario : aucun renvoi et aucune signature supplémentaire',
      );
      persisted[v.id] = expected;
    }
    final lateRevoke = await fresh();
    await release(lateRevoke);
    final latePorts = ports()..scenario = 'revoked_after_reservation';
    final lateResult = await execute(lateRevoke, latePorts);
    check(
      lateResult.state == 'indeterminate' && latePorts.calls == 0,
      'révocation après réservation : zéro transport, renvoi bloqué',
    );
    persisted[lateRevoke.id] = 'indeterminate';
    final stale = await fresh();
    await release(stale);
    final staleResult = await execute(
      stale,
      ports(),
      service: DocumentDmpChain(
        journal: journal,
        checkpoint: (name) async {
          if (name == 'before_reservation') {
            clock = clock.add(const Duration(minutes: 3));
          }
        },
      ),
    );
    check(
      staleResult.state == 'chain_blocked' && staleResult.attempt == null,
      'attestation de certificats périmée : aucune réservation',
    );
    clock = DateTime.utc(2026, 10, 17, 12);
    final interrupted = await fresh();
    await release(interrupted);
    final interruptedPorts = ports();
    final interruptedChain = DocumentDmpChain(
      journal: journal,
      checkpoint: (name) async {
        if (name == 'after_reservation') {
          throw StateError('interruption synthétique');
        }
      },
    );
    final interruptedResult = await execute(
      interrupted,
      interruptedPorts,
      service: interruptedChain,
    );
    check(
      interruptedResult.state == 'indeterminate' && interruptedPorts.calls == 0,
      'interruption après réservation : renvoi bloqué sans transport',
    );
    persisted[interrupted.id] = 'indeterminate';
    final concurrent = await fresh();
    await release(concurrent);
    final a = ports(), b = ports();
    await Future.wait([execute(concurrent, a), execute(concurrent, b)]);
    check(a.calls + b.calls == 1, 'concurrence : un seul paquet traité');
    persisted[concurrent.id] = 'accepted';
    final lastBlocked = await fresh();
    final held = ports();
    await execute(lastBlocked, held);
    check(held.order.isEmpty, 'retenue : aucune signature ni interface');
    var countSteps = (await db.query('document_chain_steps')).length;
    await DatabaseService.closeDatabase();
    db = await DatabaseService.database;
    check(
      (await db.query('document_chain_steps')).length == countSteps,
      'paquets et preuves conservés après réouverture',
    );
    for (final e in persisted.entries) {
      final v = EpisodeDocumentVersion(
        (await db.query(
          'episode_document_versions',
          where: 'version_id=?',
          whereArgs: [e.key],
        )).single,
      );
      final p = ports();
      check(
        (await execute(v, p)).state == e.value && p.order.isEmpty,
        'réouverture ${e.value} : zéro appel',
      );
    }
    check(
      medicalCanonical(await db.query('patient_fr_health_identity')) ==
          identityBefore,
      'identité et INSi inchangés',
    );
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

    final altered=await const CompanionBackupArchive().prepare(zipPath);
    final alteredDb=await databaseFactoryFfiNoIsolate.openDatabase(altered.databasePath);
    await alteredDb.execute('DROP TRIGGER chain_update');
    final signatureRow=(await alteredDb.query('document_chain_steps',where:"phase='signature' AND state='passed'",limit:1)).single;
    final badSignature=jsonDecode(signatureRow['data_json'] as String);
    badSignature['value']='AAAA';
    await alteredDb.update('document_chain_steps',{'data_json':medicalCanonical(badSignature),'data_hash':medicalHash(badSignature)},
      where:'step_id=?',whereArgs:[signatureRow['step_id']]);
    await refuses(()=>DocumentBackupContents.validate(alteredDb,altered.directory,altered.managed),
      'signature de journal altérée avec hash recalculé : restauration refusée');
    await alteredDb.close();await altered.dispose();

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
        'wireProfileValidated': true,
      }),
    );
    exit(0);
  } catch (e, st) {
    stderr.writeln('$e\n$st');
    File('${output.path}/failure.txt').writeAsStringSync('$e\n$st');
    exit(1);
  }
}
