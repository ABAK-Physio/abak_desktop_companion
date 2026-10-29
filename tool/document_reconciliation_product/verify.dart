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
import '../document_wire_product/fakes.dart';
import 'package:abak_desktop_companion/features/patients/services/document_reconciliation_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_reconciliation_records.dart';
import 'package:abak_desktop_companion/core/database/document_reconciliation_schema.dart';
import 'package:abak_desktop_companion/features/patients/screens/document_journal_panel.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
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
      await DocumentReconciliationRecords.validateAll(db);
      check(
        (await db.query('document_reconciliations')).isNotEmpty,
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
    final recon = DocumentReconciliationService(
      journal: journal,
      directory: root,
    );
    Future<EpisodeDocumentVersion> uncertain({bool interrupted = false}) async {
      final v = await fresh();
      await release(v);
      final fake = ports()..scenario = 'timeout';
      final s = await execute(
        v,
        fake,
        service: interrupted
            ? DocumentDmpChain(
                journal: journal,
                checkpoint: (name) async {
                  if (name == 'after_reservation') {
                    throw StateError('interruption synthétique');
                  }
                },
              )
            : null,
      );
      check(
        s.state == 'indeterminate',
        'tentative indéterminée créée en simulation',
      );
      return v;
    }

    Future<({String headers, List<int> bytes})> archive(
      EpisodeDocumentVersion v,
      String kind, {
      bool correlated = true,
    }) async {
      final base = '$repo/assets/dmp_local/deposit_replay/$kind';
      final req = XmlDocument.parse(
        File('$base-request.xml').readAsStringSync(),
      );
      final old = req.descendants
          .whereType<XmlElement>()
          .firstWhere((e) => e.name.local == 'MessageID')
          .innerText;
      final original = File('$base-response.bin').readAsBytesSync();
      final id = (await phase(v, 'package'))['messageId'] as String;
      return (
        headers: File('$base-headers.txt').readAsStringSync(),
        bytes: correlated
            ? latin1.encode(latin1.decode(original).replaceAll(old, id))
            : original,
      );
    }

    Future<void> blocked(
      EpisodeDocumentVersion v,
      String state,
      String label,
    ) async {
      final fake = ports();
      final status = await execute(v, fake);
      check(
        status.state == state &&
            fake.order.isEmpty &&
            fake.calls == 0 &&
            !status.canChangeHold,
        '$label : $state, zéro interface et renvoi bloqué',
      );
      final other = DocumentLocalSimulation(directory: root);
      await journal.simulate(v, other);
      check(
        other.calls == 0,
        '$label : aucun contournement via le service local',
      );
      await refuses(
        () => journal.hold(v, false, expectedRevision: status.revision),
        '$label : retenue non réarmable',
      );
      persisted[v.id] = state;
    }

    final first = await uncertain();
    // Exercise the actual additive upgrade on a populated synthetic v36 DB.
    final beforeMigration = medicalCanonical(
      await db.query('document_attempts'),
    );
    await db.execute('DROP TABLE document_reconciliations');
    await db.execute('PRAGMA user_version=36');
    await refuses(
      () => db.transaction((tx) async {
        await createDocumentReconciliationTables(tx);
        throw StateError('migration interrompue');
      }),
      'migration interrompue annulée atomiquement',
    );
    check(
      (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE name='document_reconciliations'",
      )).isEmpty,
      'aucune table partielle après rollback de migration',
    );
    await DatabaseService.closeDatabase();
    db = await DatabaseService.database;
    check(
      await db.getVersion() == 37 &&
          medicalCanonical(await db.query('document_attempts')) ==
              beforeMigration,
      'migration réelle 36 vers 37 : tentative conservée',
    );
    await createDocumentReconciliationTables(db);
    check(
      (await db.query('document_reconciliations')).isEmpty,
      'migration répétée sans événement fictif',
    );
    final untouched = medicalCanonical(
      await db.query('document_attempt_results'),
    );
    final positive = await archive(first, 'accepted');
    final review = await recon.preview(
      first,
      headers: positive.headers,
      bytes: positive.bytes,
    );
    check(
      review.outcome == 'accepted' && review.message.contains('Renvoi bloqué'),
      'archive de succès liée au paquet exact',
    );
    check(
      (await db.query('document_reconciliations')).isEmpty &&
          (await journal.status(first)).state == 'indeterminate',
      'prévisualisation sans écriture ni levée de blocage',
    );
    await refuses(
      () => recon.confirm(review, confirmed: false),
      'confirmation explicite obligatoire',
    );
    final id = await recon.confirm(review, confirmed: true);
    check(
      medicalCanonical(await db.query('document_attempt_results')) == untouched,
      'résultat initial indéterminé conservé intact',
    );
    check(
      (await journal.status(
        first,
      )).reconciliation.contains('acceptation retrouvée'),
      'message distingue résultat initial et acceptation retrouvée',
    );
    final count = (await db.query('document_reconciliations')).length;
    check(
      await recon.confirm(review, confirmed: true) == id &&
          (await db.query('document_reconciliations')).length == count,
      'double confirmation idempotente',
    );
    await blocked(first, 'accepted', 'succès réconcilié');
    final row = (await db.query('document_reconciliations')).single;
    await refuses(
      () => db.update('document_reconciliations', {'outcome': 'rejected'}),
      'observation non modifiable',
    );
    await refuses(
      () => db.delete('document_reconciliations'),
      'observation non effaçable',
    );
    await refuses(
      () => db.insert(
        'document_reconciliations',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      ),
      'INSERT OR REPLACE interdit',
    );
    await refuses(
      () => db.update('document_attempt_results', {'outcome': 'accepted'}),
      'résultat initial non réécrit',
    );
    final originalAttempt = (await db.query('document_attempts')).single;
    await refuses(
      () => db.insert('document_attempts', {
        ...originalAttempt,
        'attempt_id': 'forbidden-resend',
      }),
      'garde SQL contre renvoi direct',
    );
    final pending = await fresh();
    await refuses(
      () => recon.preview(pending),
      'préparation sans incident ni restauration non réconciliable',
    );
    await refuses(
      () => DocumentReconciliationService(
        journal: journal,
        directory: Directory('${root.path}/other'),
      ).preview(first),
      'hors stockage isolé refusé',
    );
    await refuses(
      () => recon.preview(first, headers: 'X' * 32769, bytes: []),
      'en-têtes surdimensionnés refusés',
    );
    await refuses(
      () => recon.preview(
        first,
        headers: 'HTTP/1.1 200 OK\n',
        bytes: List.filled(2 * 1024 * 1024 + 1, 0),
      ),
      'corps surdimensionné refusé',
    );
    await refuses(
      () => recon.preview(first, headers: positive.headers),
      'archive partielle refusée',
    );

    // Changed selection resolves to the immutable historical attempted version.
    final changed = await fresh(documentId: first.documentId);
    final changedReview = await recon.preview(
      changed,
      headers: positive.headers,
      bytes: positive.bytes,
    );
    check(
      changedReview.versionId == first.id,
      'nouveau PDF : examen attaché à la version effectivement tentée',
    );
    await blocked(changed, 'accepted', 'nouvelle version de la même pièce');
    check(
      (await journal.status(changed)).message.contains('tentative antérieure'),
      'nouveau PDF : résultat historique explicitement identifié',
    );
    final duplicate = await fresh(
      exactSource: (await pdf.verifyStoredBytes(first)).path,
    );
    check(
      (await recon.preview(duplicate)).documentId == first.documentId,
      'PDF identique sous autre pièce : cible historique retrouvée',
    );
    await blocked(duplicate, 'accepted', 'PDF identique dans une autre pièce');

    for (final kind in ['signature', 'metadata']) {
      final v = await uncertain();
      final a = await archive(v, kind);
      final r = await recon.preview(v, headers: a.headers, bytes: a.bytes);
      check(
        r.outcome == 'rejected' &&
            r.message.contains(
              kind == 'signature'
                  ? 'signature rejetée'
                  : 'métadonnées rejetées',
            ),
        '$kind : message de rejet précis',
      );
      await recon.confirm(r, confirmed: true);
      await blocked(v, 'rejected', 'archive $kind');
    }
    final negatives = await uncertain();
    final validNegative = await archive(negatives, 'accepted');
    final stale = await recon.preview(
      negatives,
      headers: validNegative.headers,
      bytes: validNegative.bytes,
    );
    final raw = await archive(negatives, 'accepted', correlated: false);
    for (final which in [
      'uncorrelated',
      'truncated',
      '503',
      '302',
      'soap',
      'unknown',
      'success_error',
      'duplicate_relates',
      'duplicate_http',
      'duplicate_length',
      'wrong_length',
      'no_length',
      'transfer',
      'malformed',
    ]) {
      var h = validNegative.headers,
          bytes = List<int>.from(validNegative.bytes);
      if (which == 'uncorrelated') bytes = raw.bytes;
      if (which == 'truncated') bytes = bytes.sublist(0, bytes.length - 30);
      if (which == '503') h = h.replaceFirst('200 OK', '503 Unavailable');
      if (which == '302') h = h.replaceFirst('200 OK', '302 Found');
      if (which == 'duplicate_http') h = '$h\nHTTP/1.1 200 OK\n';
      if (which == 'duplicate_length') {
        h = '$h\nContent-Length: ${bytes.length}\n';
      }
      if (which == 'wrong_length') {
        h = h.replaceFirst(
          RegExp(r'content-length: \d+', caseSensitive: false),
          'Content-Length: 1',
        );
      }
      if (which == 'no_length') {
        h = h.replaceFirst(
          RegExp(r'content-length: \d+\r?\n', caseSensitive: false),
          '',
        );
      }
      if (which == 'transfer') h = '$h\nTransfer-Encoding: chunked\n';
      if ([
        'soap',
        'unknown',
        'success_error',
        'duplicate_relates',
        'malformed',
      ].contains(which)) {
        var body = latin1.decode(bytes);
        if (which == 'soap') {
          body = body.replaceFirst('<soap:Body>', '<soap:Body><soap:Fault/>');
        }
        if (which == 'unknown') {
          body = body.replaceAll(
            'ResponseStatusType:Success',
            'ResponseStatusType:Other',
          );
        }
        if (which == 'success_error') {
          body = body.replaceFirst(
            'ResponseStatusType:Success"/>',
            'ResponseStatusType:Success"><ns2:RegistryError severity="error" errorCode="XDSUnknown"/></ns2:RegistryResponse>',
          );
        }
        if (which == 'duplicate_relates') {
          body = body.replaceFirst(
            '</soap:Header>',
            '<RelatesTo xmlns="http://www.w3.org/2005/08/addressing">other</RelatesTo></soap:Header>',
          );
        }
        if (which == 'malformed') body = '<bad';
        bytes = latin1.encode(body);
        h = h.replaceFirst(
          RegExp(r'content-length: \d+', caseSensitive: false),
          'Content-Length: ${bytes.length}',
        );
      }
      final r = await recon.preview(negatives, headers: h, bytes: bytes);
      check(r.outcome == 'indeterminate', '$which : preuve non concluante');
      await recon.confirm(r, confirmed: true);
      await blocked(negatives, 'indeterminate', which);
    }
    await refuses(
      () => recon.confirm(stale, confirmed: true),
      'examen devenu périmé après autre observation refusé',
    );
    await recon.confirm(await recon.preview(negatives), confirmed: true);
    await blocked(negatives, 'indeterminate', 'absence explicite de réponse');
    final freshPositive = await recon.preview(
      negatives,
      headers: validNegative.headers,
      bytes: validNegative.bytes,
    );
    final concurrent = await Future.wait([
      recon.confirm(freshPositive, confirmed: true),
      recon.confirm(freshPositive, confirmed: true),
    ]);
    check(
      concurrent.toSet().length == 1,
      'confirmations concurrentes : une seule observation',
    );
    await blocked(
      negatives,
      'accepted',
      'succès retrouvé après réponses non concluantes',
    );
    // A subsequent unrelated response cannot erase a conclusive observation.
    await recon.confirm(
      await recon.preview(negatives, headers: raw.headers, bytes: raw.bytes),
      confirmed: true,
    );
    await blocked(negatives, 'accepted', 'archive non corrélée après succès');

    final conflict = await uncertain(interrupted: true);
    final ca = await archive(conflict, 'accepted'),
        cr = await archive(conflict, 'signature');
    await recon.confirm(
      await recon.preview(conflict, headers: ca.headers, bytes: ca.bytes),
      confirmed: true,
    );
    await recon.confirm(
      await recon.preview(conflict, headers: cr.headers, bytes: cr.bytes),
      confirmed: true,
    );
    await blocked(
      conflict,
      'conflict',
      'archives succès et rejet contradictoires',
    );
    await recon.confirm(await recon.preview(conflict), confirmed: true);
    await recon.confirm(
      await recon.preview(conflict, headers: ca.headers, bytes: ca.bytes),
      confirmed: true,
    );
    await blocked(
      conflict,
      'conflict',
      'conflit non effaçable par absence ou relecture du succès',
    );

    // Legacy pending reservation has no complete signed packet: never promote it.
    final legacy = await fresh();
    await release(legacy);
    final legacyAttempt = await journal.reserve(
      legacy,
      await journal.prepare(legacy),
    );
    final legacyReview = await recon.preview(
      legacy,
      headers: positive.headers,
      bytes: positive.bytes,
    );
    check(
      legacyReview.outcome == 'indeterminate' &&
          legacyReview.message.contains('incomplet'),
      'réservation ancienne sans paquet signé : non vérifiable',
    );
    final beforeLate = await recon.preview(legacy);
    await journal.complete(legacyAttempt, {
      'outcome': 'indeterminate',
      'detail': 'Résultat tardif simulé',
      'kind': 'simulation',
    });
    await refuses(
      () => recon.confirm(beforeLate, confirmed: true),
      'résultat arrivé pendant examen : confirmation périmée',
    );
    await recon.confirm(
      await recon.preview(
        legacy,
        headers: positive.headers,
        bytes: positive.bytes,
      ),
      confirmed: true,
    );
    await blocked(legacy, 'indeterminate', 'réservation ancienne');
    final noResult = await fresh();
    await release(noResult);
    await journal.reserve(noResult, await journal.prepare(noResult));
    await recon.confirm(await recon.preview(noResult), confirmed: true);
    await blocked(noResult, 'indeterminate', 'réservation sans résultat');

    final terminal = await fresh();
    await release(terminal);
    await execute(terminal, ports());
    await refuses(
      () => recon.preview(terminal),
      'succès initial non restauré : pas de réconciliation incident',
    );
    final restoredPending = await uncertain();
    final beforeRestore = await recon.preview(restoredPending);
    await DocumentJournalService.suspendAfterRestore(db, 'SYN-RESTORE-1');
    await refuses(
      () => recon.confirm(beforeRestore, confirmed: true),
      'restauration pendant examen : confirmation périmée',
    );
    check(
      (await journal.status(
        first,
      )).reconciliation.contains('Nouvelle restauration'),
      'nouvelle restauration signalée malgré succès retrouvé',
    );
    final restoredAnswer = await archive(restoredPending, 'metadata');
    await recon.confirm(
      await recon.preview(
        restoredPending,
        headers: restoredAnswer.headers,
        bytes: restoredAnswer.bytes,
      ),
      confirmed: true,
    );
    await blocked(restoredPending, 'rejected', 'tentative restaurée');
    final noAttempt = await recon.preview(
      pending,
      headers: positive.headers,
      bytes: positive.bytes,
    );
    check(
      noAttempt.outcome == 'indeterminate' &&
          noAttempt.message.contains('sans tentative'),
      'ancienne sauvegarde sans tentative : archive insuffisante',
    );
    await recon.confirm(noAttempt, confirmed: true);
    await blocked(pending, 'restored', 'restauration sans tentative');
    await refuses(
      () => db.insert('document_attempts', {
        ...originalAttempt,
        'attempt_id': 'restore-bypass',
        'document_id': pending.documentId,
        'version_id': pending.id,
        'pdf_hash': pending.digest,
      }),
      'verrou global SQL maintenu après réconciliation',
    );
    await recon.confirm(await recon.preview(terminal), confirmed: true);
    final withoutAnswer = await journal.status(terminal);
    check(
      withoutAnswer.state == 'accepted' &&
          withoutAnswer.reconciliation.contains('non concluante') &&
          !withoutAnswer.reconciliation.contains('retrouvée'),
      'sans archive concluante : succès initial conservé sans fausse confirmation',
    );
    final opposite = await archive(terminal, 'signature');
    await recon.confirm(
      await recon.preview(
        terminal,
        headers: opposite.headers,
        bytes: opposite.bytes,
      ),
      confirmed: true,
    );
    await blocked(
      terminal,
      'conflict',
      'archive contredit résultat initial restauré',
    );
    check(
      (await db.query('document_restore_barriers')).length == 1,
      'aucune barrière supprimée ni acquittée',
    );
    await DocumentReconciliationRecords.validateAll(db);
    check(true, 'toutes les preuves rejouées depuis leurs octets archivés');

    final ctl = LiveWidgetController(WidgetsBinding.instance),
        boundary = GlobalKey();
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: boundary,
              child: DocumentJournalPanel(
                service: journal,
                version: conflict,
                enabled: true,
              ),
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await ctl.pump(const Duration(milliseconds: 30));
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    check(
      find.textContaining('Archives contradictoires').evaluate().isNotEmpty &&
          find
              .textContaining('Résultat initial conservé')
              .evaluate()
              .isNotEmpty,
      'écran métier : conflit et résultat initial distingués',
    );
    check(
      ctl
              .widget<SwitchListTile>(find.byKey(const Key('document-hold')))
              .onChanged ==
          null,
      'écran métier : retenue non réarmable',
    );
    final image =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 1);
    File('${output.path}/journal-reconciliation.png').writeAsBytesSync(
      (await image.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List(),
    );
    image.dispose();
    runApp(const SizedBox.shrink());
    await ctl.pump();
    final countReviews = (await db.query('document_reconciliations')).length;
    await DatabaseService.closeDatabase();
    db = await DatabaseService.database;
    await DocumentReconciliationRecords.validateAll(db);
    check(
      (await db.query('document_reconciliations')).length == countReviews,
      'observations et preuves conservées après réouverture',
    );
    for (final e in persisted.entries.toList()) {
      final v = EpisodeDocumentVersion(
        (await db.query(
          'episode_document_versions',
          where: 'version_id=?',
          whereArgs: [e.key],
        )).single,
      );
      await blocked(v, e.value, 'réouverture');
    }
    final backupDir = Directory('${root.path}/backups')..createSync();
    final access = Access(backupDir.path);
    final backup = await LocalDatabaseBackupService(access: access)
        .createBackup(
          chooseBackupFolderTitle: 'Synthétique',
          cancelledMessage: 'Annulé',
          databaseNotFoundMessage: 'Absente',
        );
    check(backup.success, 'sauvegarde produit avec preuves de réconciliation');
    final zipPath = backup.backupPath!;
    for (final alteration in [
      'raw',
      'rehash',
      'outcome',
      'missing',
      'predecessor',
      'binding',
      'orphan',
      'event',
      'table',
      'initial',
    ]) {
      final staged = await const CompanionBackupArchive().prepare(zipPath);
      final sdb = await databaseFactoryFfiNoIsolate.openDatabase(
        staged.databasePath,
      );
      await sdb.execute('DROP TRIGGER reconciliation_update');
      await sdb.execute('DROP TRIGGER reconciliation_delete');
      final r = (await sdb.query(
        'document_reconciliations',
        where: "outcome='accepted'",
        limit: 1,
      )).single;
      final evidence = jsonDecode(r['evidence_json'] as String);
      if (alteration == 'table') {
        await sdb.execute('DROP TABLE document_reconciliations');
      } else if (alteration == 'initial') {
        await sdb.execute('DROP TRIGGER journal_attempt_results_update');
        await sdb.update(
          'document_attempt_results',
          {'evidence_json': '<bad'},
          where: 'attempt_id=?',
          whereArgs: [r['attempt_id']],
        );
      } else if (alteration == 'missing') {
        await sdb.delete(
          'document_reconciliations',
          where: 'review_id=?',
          whereArgs: [r['review_id']],
        );
      } else if (alteration == 'event') {
        await sdb.execute('DROP TRIGGER journal_events_delete');
        await sdb.delete(
          'document_events',
          where: "kind='reconciliation' AND reference_id=?",
          whereArgs: [r['review_id']],
        );
      } else {
        final updates = <String, Object?>{};
        if (alteration == 'raw' || alteration == 'rehash') {
          evidence['source']['body'] = base64Encode(utf8.encode('<bad'));
        }
        if (alteration == 'outcome') {
          updates['outcome'] = 'rejected';
          evidence['decision']['outcome'] = 'rejected';
        }
        if (alteration == 'predecessor') {
          updates['previous_hash'] = 'f' * 64;
          evidence['previousHash'] = 'f' * 64;
        }
        if (alteration == 'binding') evidence['bindingHash'] = 'e' * 64;
        if (alteration == 'orphan') updates['version_id'] = pending.id;
        updates['evidence_json'] = medicalCanonical(evidence);
        if (alteration != 'raw') {
          updates['evidence_hash'] = medicalHash(evidence);
        }
        if (alteration == 'rehash') {
          updates['source_hash'] = medicalHash(evidence['source']);
        }
        await sdb.update(
          'document_reconciliations',
          updates,
          where: 'review_id=?',
          whereArgs: [r['review_id']],
        );
      }
      await refuses(
        () => DocumentBackupContents.validate(
          sdb,
          staged.directory,
          staged.managed,
        ),
        '$alteration : sauvegarde altérée refusée',
      );
      await sdb.close();
      await staged.dispose();
    }
    final restore = await LocalDatabaseRestoreService(
      access: access,
    ).restoreDatabase(backupPath: zipPath);
    check(
      restore.success,
      'restauration produit avec observations, pièces et preuves',
    );
    db = await DatabaseService.database;
    check(
      (await db.query('document_reconciliations')).length == countReviews,
      'réconciliation intégralement restaurée',
    );
    await DocumentReconciliationRecords.validateAll(db);
    for (final e in persisted.entries.toList()) {
      final v = EpisodeDocumentVersion(
        (await db.query(
          'episode_document_versions',
          where: 'version_id=?',
          whereArgs: [e.key],
        )).single,
      );
      await blocked(v, e.value, 'restauration produit');
    }
    check(
      (await journal.status(
        first,
      )).reconciliation.contains('Nouvelle restauration'),
      'restauration produit impose un nouvel examen',
    );
    await recon.confirm(
      await recon.preview(
        first,
        headers: positive.headers,
        bytes: positive.bytes,
      ),
      confirmed: true,
    );
    check(
      !(await journal.status(
        first,
      )).reconciliation.contains('Nouvelle restauration'),
      'examen rattaché à la nouvelle restauration',
    );
    await blocked(first, 'accepted', 'nouvel examen après restauration');
    check(
      (await db.query('document_restore_barriers')).length == 2,
      'les deux verrous de restauration restent présents',
    );
    check(
      medicalCanonical(await db.query('patient_fr_health_identity')) ==
          identityBefore,
      'identité et INSi inchangés',
    );
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
        'archiveScope':
            'Copies locales des réponses archivées ; seul RelatesTo adapté aux tentatives synthétiques. Aucune preuve de dépôt réel.',
      }),
    );
    exit(0);
  } catch (e, st) {
    stderr.writeln('$e\n$st');
    File('${output.path}/failure.txt').writeAsStringSync('$e\n$st');
    exit(1);
  }
}
