import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:printing/printing.dart';
import 'package:printing/src/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/database/document_medical_schema.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/screens/document_medical_screen.dart';
import 'package:abak_desktop_companion/features/patients/screens/episode_documents_screen.dart';
import 'package:abak_desktop_companion/features/patients/data/episode_document_repository.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/practitioners/data/practitioner_repository.dart';

class Inspector implements FinalPdfInspector {
  @override
  Future<int> inspect(Uint8List bytes) async => 2;
}

class Renderer implements MedicalPdfRenderer {
  bool blank = false, broken = false;
  int pages = 2;
  late Uint8List png;
  @override
  Future<List<MedicalPage>> render(Uint8List bytes) async {
    if (broken) throw StateError('renderer unavailable');
    return List.generate(pages, (_) => MedicalPage(png, !blank));
  }
}

class RasterPlatform extends PrintingPlatform {
  bool white = false, broken = false;
  @override
  Stream<PdfRaster> raster(
    Uint8List bytes,
    List<int>? pages,
    double dpi,
  ) async* {
    if (broken) throw StateError('synthetic renderer failure');
    final pixels = Uint8List.fromList(
      List.generate(16, (i) => white || i % 4 == 3 ? 255 : 0),
    );
    yield PdfRaster(2, 2, pixels);
    yield PdfRaster(2, 2, pixels);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final ctl = LiveWidgetController(binding);
  final output = Directory(Platform.environment['MEDICAL_TEST_OUTPUT']!)
    ..createSync(recursive: true);
  final checks = <String>[], errors = <String>[];
  FlutterError.onError = (e) => errors.add(e.toString());
  void check(bool ok, String label) {
    if (!ok) throw StateError(label);
    checks.add(label);
    stdout.writeln('PASS $label');
  }

  Future<void> refuses(Future<dynamic> Function() run, String label) async {
    var rejected = false;
    try {
      await run();
    } catch (_) {
      rejected = true;
    }
    check(rejected, label);
  }

  sqfliteFfiInit();
  final factory = databaseFactoryFfiNoIsolate;
  final renderer = Renderer();
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, 400, 500),
    ui.Paint()..color = const ui.Color(0xFFFFFFFF),
  );
  final painter = TextPainter(
    text: const TextSpan(
      text: 'DOCUMENT SYNTHÉTIQUE\n\nRevue des deux pages',
      style: TextStyle(color: Colors.black, fontSize: 24),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: 360);
  painter.paint(canvas, const ui.Offset(20, 50));
  final img = await recorder.endRecording().toImage(400, 500);
  renderer.png = (await img.toByteData(
    format: ui.ImageByteFormat.png,
  ))!.buffer.asUint8List();
  img.dispose();
  final platform = RasterPlatform();
  PrintingPlatform.instance = platform;
  var date = DateTime.utc(2026, 10, 17, 12);
  try {
    if (Platform.environment['MEDICAL_TEST_PHASE'] == 'reopen') {
      final proof = jsonDecode(
        File('${output.path}/result.json').readAsStringSync(),
      );
      final root = Directory(proof['root']);
      if (!root.path.startsWith('${output.path}/synthetic-') ||
          File('${root.path}/scope').readAsStringSync() !=
              'ABAK-J2-SYNTHETIC') {
        throw StateError('wrong scope');
      }
      final db = await DatabaseService.openDatabaseFile(
        '${root.path}/test.sqlite',
        factory: factory,
      );
      final pdf = FinalPdfDocumentService(
        database: () async => db,
        root: () async => Directory('${root.path}/pdfs'),
        inspector: Inspector(),
      );
      final medical = DocumentMedicalService(
        pdf: pdf,
        renderer: renderer,
        now: () => date,
      );
      final before = await db.query('document_medical_approvals');
      for (final kind in ['approved', 'invalidated']) {
        final row = (await db.query(
          'episode_document_versions',
          where: 'version_id=?',
          whereArgs: [proof[kind]],
        )).single;
        check(
          (await medical.status(EpisodeDocumentVersion(row))).state == kind,
          'nouveau processus conserve état $kind',
        );
      }
      check(
        (await db.query('document_medical_approvals')).length == before.length,
        'redémarrage sans nouvelle approbation',
      );
      await db.close();
      await File(
        '${output.path}/restart.json',
      ).writeAsString(jsonEncode({'passed': checks.length, 'checks': checks}));
      exit(0);
    }
    final realAdapter = PrintingMedicalRenderer();
    check(
      (await realAdapter.render(
        Uint8List(0),
      )).every((p) => p.hasInk && p.png.isNotEmpty),
      'adaptateur rendu produit génère les aperçus',
    );
    platform.white = true;
    check(
      (await realAdapter.render(Uint8List(0))).every((p) => !p.hasInk),
      'adaptateur détecte les pages entièrement blanches',
    );
    platform.white = false;
    platform.broken = true;
    await refuses(
      () => realAdapter.render(Uint8List(0)),
      'adaptateur propage erreur lecteur',
    );
    platform.broken = false;
    final root = await output.createTemp('synthetic-');
    await File('${root.path}/scope').writeAsString('ABAK-J2-SYNTHETIC');
    var db = await DatabaseService.openDatabaseFile(
      '${root.path}/test.sqlite',
      factory: factory,
    );
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
      'title': 'Episode synthétique',
      'pathology_label': 'Fictif',
      'created_at': 1,
    });
    final identity = {
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
      'identity_validation_method': 'synthetic proof',
      'identity_validated_at': 1,
      'identity_validated_by': 'SYN-VALIDATOR',
      'ins_retrieved_at': 1,
    };
    await db.insert('patient_fr_health_identity', identity);
    for (final id in ['AUTHOR', 'VALIDATOR', 'INACTIVE', 'ARCHIVED']) {
      await db.insert('practitioners', {
        'practitioner_id': id,
        'display_name': 'Praticien fictif $id',
        'professional_id': id == 'AUTHOR' ? '12345678901' : null,
        'is_active': id == 'INACTIVE' ? 0 : 1,
        'archived_at': id == 'ARCHIVED' ? 1 : null,
        'created_at': 1,
      });
    }
    final originalIdentity = medicalCanonical(
      await db.query('patient_fr_health_identity'),
    );
    final originalPatients = medicalCanonical(await db.query('patients'));
    // Downgrade only a newly constructed synthetic schema to exercise the actual upgrader.
    final triggers = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='trigger' AND (name LIKE 'medical_%' OR name LIKE 'document_medical_%' OR name LIKE 'document_approval_%')",
    );
    for (final r in triggers) {
      await db.execute('DROP TRIGGER "${r['name']}"');
    }
    for (final table in [
      'document_medical_changes',
      'document_approval_invalidations',
      'document_medical_approvals',
      'document_preparations',
      'document_practice_contexts',
    ]) {
      await db.execute('DROP TABLE $table');
    }
    await db.setVersion(32);
    await refuses(
      () => db.transaction((t) async {
        await createDocumentMedicalTables(t);
        throw StateError('interruption');
      }),
      'migration interrompue annulée',
    );
    check(
      (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE name='document_medical_approvals'",
      )).isEmpty,
      'rollback conserve schéma 32',
    );
    await db.close();
    db = await DatabaseService.openDatabaseFile(
      '${root.path}/test.sqlite',
      factory: factory,
    );
    check(
      await db.getVersion() == DatabaseService.schemaVersion,
      'migration 32 vers schéma courant',
    );
    check(
      (await db.query('document_medical_approvals')).isEmpty,
      'migration sans validation fabriquée',
    );
    check(
      medicalCanonical(await db.query('patients')) == originalPatients &&
          medicalCanonical(await db.query('patient_fr_health_identity')) ==
              originalIdentity,
      'migration conserve patients et identité',
    );
    await createDocumentMedicalTables(db);
    final pdf = FinalPdfDocumentService(
      database: () async => db,
      root: () async => Directory('${root.path}/pdfs'),
      inspector: Inspector(),
    );
    DocumentMedicalService service({Future<void> Function(String)? hook}) =>
        DocumentMedicalService(
          pdf: pdf,
          renderer: renderer,
          now: () => date,
          checkpoint: hook,
        );
    final medical = service();
    check(
      (await medical.practitioners()).length == 2,
      'annuaire exclut inactifs et archivés',
    );
    check(
      (await PractitionerRepository(
            database: () async => db,
          ).getActivePractitioners()).length ==
          2,
      'annuaire métier exclut également inactifs et archivés',
    );
    final profile = <String, String>{
      'identifierType': 'RPPS',
      'identifier': '12345678901',
      'authority': 'synthetic-authority',
      'professionCode': 'SYN-KINE',
      'professionSystem': 'synthetic-profession-system',
      'professionLabel': 'Profession fictive',
      'situation': 'Situation synthétique',
      'setting': 'Ambulatoire déclaré',
      'structureType': 'cabinet',
      'structureId': 'SYN-CAB',
      'structureAuthority': 'synthetic-structure-authority',
      'structureName': 'Cabinet fictif',
      'validFrom': '2020-01-01T00:00:00Z',
      'validUntil': '2027-01-01T00:00:00Z',
      'replacementFor': '',
    };
    var context = await medical.saveContext(
      practitionerId: 'AUTHOR',
      data: profile,
      expectedRevision: 0,
    );
    final draft = <String, String>{
      'authorId': 'AUTHOR',
      'validatorId': 'VALIDATOR',
      'contextId': context['context_id'] as String,
      'title': 'Document clinique synthétique',
      'clinicalDate': '2026-10-16T14:00:00+02:00',
      'language': 'fr-FR',
      'typeCode': 'SYN-TYPE',
      'typeSystem': 'synthetic-types',
      'typeLabel': 'Type fictif',
      'classCode': 'SYN-CLASS',
      'classSystem': 'synthetic-classes',
      'classLabel': 'Classe fictive',
      'catalogReference': 'Catalogue synthétique v1',
      'patientVisibility': 'visible',
      'representativesVisibility': 'sans objet',
      'professionalVisibility': 'visible',
    };
    await refuses(
      () => medical.saveContext(
        practitionerId: 'INACTIVE',
        data: profile,
        expectedRevision: 0,
      ),
      'profil professionnel inactif refusé',
    );
    await refuses(
      () => medical.saveContext(
        practitionerId: 'AUTHOR',
        data: {...profile, 'identifier': 'bad'},
        expectedRevision: 0,
      ),
      'identifiant RPPS incomplet refusé',
    );
    await refuses(
      () => medical.saveContext(
        practitionerId: 'AUTHOR',
        data: {...profile, 'replacementFor': 'SYN-OTHER', 'validUntil': ''},
        expectedRevision: 0,
      ),
      'remplacement sans fin refusé',
    );
    await refuses(
      () => medical.saveContext(
        id: context['context_id'] as String,
        practitionerId: 'AUTHOR',
        data: profile,
        expectedRevision: 0,
      ),
      'édition concurrente du contexte refusée',
    );
    final doc = pw.Document()
      ..addPage(pw.Page(build: (_) => pw.Text('SYNTHETIC PDF - page 1')))
      ..addPage(pw.Page(build: (_) => pw.Text('SYNTHETIC PDF - page 2')));
    final source = File('${root.path}/source.pdf');
    await source.writeAsBytes(await doc.save());
    var reportSequence = 0;
    Future<EpisodeDocumentVersion> fresh({bool prepared = true}) async {
      final reportId = 'SYN-MEDICAL-${++reportSequence}';
      await db.insert('care_episode_reports', {
        'report_id': reportId,
        'care_episode_id': 'SYN-E',
        'author_practitioner_id': 'AUTHOR',
        'title': 'Rapport médical synthétique $reportSequence',
        'content_json': '{}',
        'status': 'saved',
        'report_date': 1,
        'created_at': 1,
      });
      final v = await pdf.importPdf(
        episodeId: 'SYN-E',
        sourcePath: source.path,
        title: 'Rapport fictif',
        origin: PdfOrigin('report', id: reportId),
      );
      if (prepared) {
        await medical.savePreparation(v, draft, expectedRevision: 0);
      }
      return v;
    }

    Future<MedicalRow> approve(EpisodeDocumentVersion v) async =>
        medical.approve(
          await medical.review(v),
          reviewedPages: {0, 1},
          clinicalContent: true,
          correctPatient: true,
          actingAsValidator: true,
        );
    // Ordinary external PDFs remain importable but must not enter medical/DMP preparation.
    final external = await pdf.importPdf(
      episodeId: 'SYN-E',
      sourcePath: source.path,
      title: 'Pièce externe synthétique',
    );
    await refuses(
      () => medical.savePreparation(external, draft, expectedRevision: 0),
      'pièce externe sans rapport refusée pour préparation médicale',
    );
    await db.insert('care_episode_assessments', {
      'assessment_id': 'SYN-BILAN',
      'care_episode_id': 'SYN-E',
      'title': 'Bilan synthétique interne',
      'content_json': '{}',
      'status': 'saved',
      'assessment_date': 1,
      'created_at': 1,
    });
    final assessment = await pdf.importPdf(
      episodeId: 'SYN-E',
      sourcePath: source.path,
      title: 'Bilan interne',
      origin: const PdfOrigin('assessment', id: 'SYN-BILAN'),
    );
    await refuses(
      () => medical.savePreparation(assessment, draft, expectedRevision: 0),
      'bilan interne refusé pour préparation médicale DMP',
    );
    final v = await fresh(prepared: false);
    check(
      (await medical.status(v)).state == 'blocked',
      'préparation absente bloque validation',
    );
    for (final key in [
      'title',
      'typeCode',
      'classSystem',
      'catalogReference',
      'language',
    ]) {
      await refuses(
        () => medical.savePreparation(v, {
          ...draft,
          key: '',
        }, expectedRevision: 0),
        'métadonnée $key absente refusée',
      );
    }
    for (final date in [
      '2026-10-16',
      '2026-02-30T00:00:00Z',
      '2030-01-01T00:00:00Z',
    ]) {
      await refuses(
        () => medical.savePreparation(v, {
          ...draft,
          'clinicalDate': date,
        }, expectedRevision: 0),
        'date clinique $date refusée',
      );
    }
    await refuses(
      () => medical.savePreparation(v, {
        ...draft,
        'authorId': 'VALIDATOR',
      }, expectedRevision: 0),
      'contexte autre auteur refusé',
    );
    await medical.savePreparation(v, draft, expectedRevision: 0);
    await refuses(
      () => medical.savePreparation(v, draft, expectedRevision: 0),
      'préparation concurrente refusée',
    );
    final review = await medical.review(v);
    check(review.pages.length == 2, 'revue présente les deux pages');
    check(await medical.reviewIsCurrent(review), 'revue courante reconnue');
    final digest = review.digest;
    review.snapshot['patient'] = 'tampered';
    check(
      review.digest == digest,
      'contrat de revue protégé des mutations externes',
    );
    await refuses(
      () => medical.approve(
        review,
        reviewedPages: {0},
        clinicalContent: true,
        correctPatient: true,
        actingAsValidator: true,
      ),
      'revue partielle bloquée',
    );
    for (final flag in ['clinical', 'patient', 'actor']) {
      await refuses(
        () => medical.approve(
          review,
          reviewedPages: {0, 1},
          clinicalContent: flag != 'clinical',
          correctPatient: flag != 'patient',
          actingAsValidator: flag != 'actor',
        ),
        'attestation $flag requise',
      );
    }
    final receipt = await approve(v);
    check(
      receipt['author_id'] == 'AUTHOR' &&
          receipt['validator_id'] == 'VALIDATOR',
      'auteur et validateur distincts conservés',
    );
    check(
      (await medical.status(v)).valid,
      'validation médicale courante reconnue',
    );
    await approve(v);
    check(
      (await medical.history(v.id)).length == 1,
      'double confirmation ne duplique pas le reçu',
    );
    check(
      medicalCanonical(await db.query('patient_fr_health_identity')) ==
          originalIdentity,
      'validation ne modifie pas identité existante',
    );
    await refuses(
      () => db.update('document_medical_approvals', {'snapshot_hash': 'x'}),
      'reçu non modifiable',
    );
    await refuses(
      () => db.delete('document_medical_approvals'),
      'reçu non supprimable',
    );
    await db.close();
    db = await DatabaseService.openDatabaseFile(
      '${root.path}/test.sqlite',
      factory: factory,
    );
    check(
      (await medical.status(v)).valid,
      'réouverture conserve validation médicale',
    );
    // Replace semantics (used by the identity repository) must invalidate even when reversed.
    await db.insert('patient_fr_health_identity', {
      ...identity,
      'birth_first_names': 'Modifié',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert(
      'patient_fr_health_identity',
      identity,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    check(
      (await medical.status(v)).state == 'invalidated',
      'identité remplacée puis rétablie ne ressuscite pas validation',
    );
    await refuses(
      () => medical.approve(
        review,
        reviewedPages: {0, 1},
        clinicalContent: true,
        correctPatient: true,
        actingAsValidator: true,
      ),
      'ancienne revue non réutilisable après changement rétabli',
    );
    await approve(v);
    check(
      (await medical.history(v.id)).length == 2,
      'nouvelle revue crée nouveau reçu après invalidation',
    );
    for (final mode in ['doubtful', 'nia', 'missing']) {
      await approve(v);
      await db.update(
        'patient_fr_health_identity',
        mode == 'doubtful'
            ? {'identity_doubtful': 1}
            : mode == 'nia'
            ? {'ins_oid': '1.2.250.1.213.1.4.9'}
            : {'birth_place_code': null},
      );
      await refuses(() => medical.review(v), 'identité $mode bloque revue');
      await db.insert(
        'patient_fr_health_identity',
        identity,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      check(
        !(await medical.status(v)).valid,
        'invalidation $mode persistante après rétablissement',
      );
    }
    await approve(v);
    await db.update(
      'practitioners',
      {'is_active': 0},
      where: 'practitioner_id=?',
      whereArgs: ['VALIDATOR'],
    );
    check(
      !(await medical.status(v)).valid,
      'validateur devenu inactif invalide reçu',
    );
    await db.update(
      'practitioners',
      {'is_active': 1},
      where: 'practitioner_id=?',
      whereArgs: ['VALIDATOR'],
    );
    await approve(v);
    context = await medical.saveContext(
      id: context['context_id'] as String,
      practitionerId: 'AUTHOR',
      data: {...profile, 'structureName': 'Nouveau cabinet fictif'},
      expectedRevision: 1,
    );
    check(
      !(await medical.status(v)).valid,
      'modification exercice invalide reçu',
    );
    await approve(v);
    await medical.savePreparation(v, {
      ...draft,
      'title': 'Titre clinique modifié',
    }, expectedRevision: 1);
    check(
      !(await medical.status(v)).valid,
      'modification documentaire invalide reçu',
    );
    await approve(v);
    date = DateTime.utc(2028, 1, 1);
    check(
      (await medical.status(v)).state == 'invalidated',
      'expiration temporelle invalide même sans écriture source',
    );
    date = DateTime.utc(2026, 10, 17, 12);
    check(
      !(await medical.status(v)).valid,
      'retour horloge simulée ne réactive pas reçu',
    );
    await approve(v);
    final frozen = await pdf.verifiedFile(v);
    final saved = await frozen.readAsBytes();
    await frozen.writeAsString('damaged');
    check(
      (await medical.status(v)).state == 'invalidated',
      'PDF altéré invalide validation',
    );
    await frozen.writeAsBytes(saved);
    check(
      !(await medical.status(v)).valid,
      'restauration PDF ne réactive pas reçu invalidé',
    );
    await approve(v);
    await db.update(
      'episode_documents',
      {'case_id': 'OTHER'},
      where: 'document_id=?',
      whereArgs: [v.documentId],
    );
    await refuses(() => medical.review(v), 'rattachement changé bloque revue');
    await db.update(
      'episode_documents',
      {'case_id': 'SYN-E'},
      where: 'document_id=?',
      whereArgs: [v.documentId],
    );
    check(
      !(await medical.status(v)).valid,
      'rattachement rétabli reste invalidé',
    );
    await approve(v);
    final next = await pdf.importPdf(
      episodeId: 'SYN-E',
      documentId: v.documentId,
      sourcePath: source.path,
      title: 'Nouvelle version',
      origin: PdfOrigin('report', id: v.values['source_id'] as String),
    );
    check(
      !(await medical.status(v)).valid &&
          (await medical.preparation(next.id)) == null,
      'nouvelle version sans héritage de validation ou préparation',
    );
    final negative = await fresh();
    renderer.blank = true;
    await refuses(
      () => medical.review(negative),
      'PDF entièrement blanc refusé',
    );
    renderer.blank = false;
    renderer.broken = true;
    await refuses(
      () => medical.review(negative),
      'lecteur indisponible refuse revue',
    );
    renderer.broken = false;
    renderer.pages = 1;
    await refuses(
      () => medical.review(negative),
      'aperçu partiel refuse revue',
    );
    renderer.pages = 2;
    await refuses(
      () => service(
        hook: (stage) async {
          if (stage == 'rendered') {
            await db.update('patients', {'updated_at': 100});
          }
        },
      ).review(negative),
      'changement pendant rendu invalide revue',
    );
    final candidateFile = await pdf.verifiedFile(negative),
        candidateBytes = await (await pdf.verifiedFile(negative)).readAsBytes();
    final fileReview = await medical.review(negative);
    await refuses(
      () =>
          service(
            hook: (stage) async {
              if (stage == 'beforeApproval') {
                await candidateFile.writeAsString('modified after review');
              }
            },
          ).approve(
            fileReview,
            reviewedPages: {0, 1},
            clinicalContent: true,
            correctPatient: true,
            actingAsValidator: true,
          ),
      'PDF changé juste avant validation refusé',
    );
    await candidateFile.writeAsBytes(candidateBytes);
    final stale = await medical.review(negative);
    await refuses(
      () =>
          service(
            hook: (stage) async {
              if (stage == 'beforeApproval') {
                await db.update('patients', {'updated_at': 101});
              }
            },
          ).approve(
            stale,
            reviewedPages: {0, 1},
            clinicalContent: true,
            correctPatient: true,
            actingAsValidator: true,
          ),
      'changement juste avant engagement refuse validation',
    );
    final record = (await db.query(
      'episode_documents',
      where: 'document_id=?',
      whereArgs: [negative.documentId],
    )).single;
    await db.update(
      'episode_documents',
      {'file_path': source.path},
      where: 'document_id=?',
      whereArgs: [negative.documentId],
    );
    await refuses(
      () => medical.review(negative),
      'pointeur de fichier modifié bloque revue',
    );
    await db.update(
      'episode_documents',
      {'file_path': record['file_path']},
      where: 'document_id=?',
      whereArgs: [negative.documentId],
    );
    // Clinical source provenance is checked, not inferred from the file name.
    await db.insert('care_episode_reports', {
      'report_id': 'SYN-R',
      'care_episode_id': 'SYN-E',
      'author_practitioner_id': 'AUTHOR',
      'title': 'Rapport fictif',
      'content_json': '{}',
      'report_date': 1,
      'created_at': 1,
    });
    final report = await pdf.importPdf(
      episodeId: 'SYN-E',
      sourcePath: source.path,
      title: 'Rapport final',
      origin: const PdfOrigin('report', id: 'SYN-R'),
    );
    await medical.savePreparation(report, draft, expectedRevision: 0);
    await approve(report);
    await db.update(
      'care_episode_reports',
      {'content_json': '{"changed":true}'},
      where: 'report_id=?',
      whereArgs: ['SYN-R'],
    );
    await refuses(
      () => medical.review(report),
      'source clinique modifiée exige réimport PDF',
    );
    check(
      (await medical.status(report)).state == 'invalidated',
      'reçu lié au rapport invalidé',
    );
    Future<void> pump() async {
      for (var j = 0; j < 6; j++) {
        await Future<void>.delayed(const Duration(milliseconds: 70));
        await ctl.pump();
      }
    }

    Future<Finder> locate(String key) async {
      final f = find.byKey(Key(key));
      ctl
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await pump();
      await ctl.scrollUntilVisible(
        f,
        450,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 35,
      );
      await pump();
      return f;
    }

    Future<void> button(String key) async {
      final f = await locate(key);
      final w = ctl.widget(f);
      if (w is FilledButton) {
        w.onPressed!();
      } else if (w is OutlinedButton) {
        w.onPressed!();
      } else if (w is TextButton) {
        w.onPressed!();
      }
      await pump();
    }

    final uiVersion = await fresh();
    final boundary = GlobalKey();
    void app(Widget child) => runApp(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: RepaintBoundary(key: boundary, child: child),
      ),
    );
    app(
      EpisodeDocumentsScreen(
        caseId: 'SYN-E',
        caseLabel: 'Episode synthétique',
        repository: EpisodeDocumentRepository(database: () async => db),
        finalPdfService: pdf,
        medicalService: medical,
        showExpertInfo: false,
      ),
    );
    await pump();
    final menu = await locate('document-actions-${uiVersion.documentId}');
    ctl.widget<PopupMenuButton<String>>(menu).onSelected!('medical');
    await pump();
    await pump();
    check(
      find.byType(DocumentMedicalScreen).evaluate().length == 1,
      'parcours ouvert depuis écran Documents existant',
    );
    final disabled = await locate('approve-medical-pdf');
    check(
      ctl.widget<FilledButton>(disabled).onPressed == null,
      'validation UI grisée avant revue',
    );
    await button('review-medical-pdf');
    for (final key in [
      'medical-page-reviewed',
      'medical-clinical',
      'medical-patient',
      'medical-actor',
    ]) {
      final f = await locate(key);
      ctl.widget<CheckboxListTile>(f).onChanged!(true);
      await pump();
    }
    check(
      ctl.widget<FilledButton>(await locate('approve-medical-pdf')).onPressed ==
          null,
      'première page seule ne permet pas validation',
    );
    await button('medical-next');
    ctl
        .widget<CheckboxListTile>(await locate('medical-page-reviewed'))
        .onChanged!(true);
    await pump();
    check(
      ctl.widget<FilledButton>(await locate('approve-medical-pdf')).onPressed !=
          null,
      'deux pages et attestations autorisent validation',
    );
    await button('approve-medical-pdf');
    ctl
        .widget<FilledButton>(find.byKey(const Key('confirm-medical-approval')))
        .onPressed!();
    await pump();
    await pump();
    check(
      (await medical.status(uiVersion)).valid,
      'validation depuis écran métier persistée',
    );
    check(
      (await db.query('document_attempts')).isEmpty &&
          (await db.query('document_chain_steps')).isEmpty,
      'validation médicale sans signature ni tentative de dépôt',
    );
    runApp(const SizedBox.shrink());
    await pump();
    app(DocumentMedicalScreen(version: uiVersion, service: medical));
    await pump();
    check(
      ctl
          .widget<Text>(find.byKey(const Key('medical-status')))
          .data!
          .contains('Validé médicalement'),
      'réouverture UI affiche validation conservée',
    );
    final image =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage();
    final picture = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      '${output.path}/ecran-validation.png',
    ).writeAsBytes(picture!.buffer.asUint8List());
    image.dispose();
    final title = await locate('medical-title');
    ctl.widget<TextFormField>(title).onChanged!('Titre modifié dans écran');
    await pump();
    check(
      ctl.widget<FilledButton>(await locate('approve-medical-pdf')).onPressed ==
          null,
      'édition UI efface possibilité de valider ancienne revue',
    );
    await button('save-medical-context');
    check(
      (await medical.status(uiVersion)).state == 'invalidated',
      'enregistrement formulaire invalide reçu',
    );
    // UI professional editor uses the same repository and explicit revision.
    await button('medical-practice');
    final field = find.byKey(const Key('practice-identifier'));
    if (field.evaluate().isNotEmpty) {
      ctl.widget<TextFormField>(field).onChanged!('12345678901');
    }
    ctl
        .widget<FilledButton>(find.byKey(const Key('save-practice')))
        .onPressed!();
    await pump();
    await pump();
    check(
      find.byKey(const Key('save-practice')).evaluate().isEmpty,
      'éditeur exercice intégré enregistre contexte déclaré',
    );
    check(errors.isEmpty, 'aucune erreur Flutter : ${errors.join(';')}');
    runApp(const SizedBox.shrink());
    await pump();
    final survivor = await fresh();
    await approve(survivor);
    final invalid = await fresh();
    await approve(invalid);
    await db.update(
      'episode_documents',
      {'title': 'Titre changé'},
      where: 'document_id=?',
      whereArgs: [invalid.documentId],
    );
    check(
      (await medical.status(invalid)).state == 'invalidated' &&
          (await medical.status(survivor)).valid,
      'modification d’une pièce ne touche pas validation d’une autre',
    );
    final result = {
      'passed': checks.length,
      'checks': checks,
      'root': root.path,
      'approved': survivor.id,
      'invalidated': invalid.id,
      'network': 'all network denied by sandbox',
      'native':
          'rendering injected for workflow; printing rendering implementation checked separately',
      'realData': 'none opened',
    };
    await File(
      '${output.path}/result.json',
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(result));
    await db.close();
    stdout.writeln('SUCCESS ${checks.length}');
    exit(0);
  } catch (e, st) {
    stderr.writeln('$e\n$st\n${errors.join('\n')}');
    await File(
      '${output.path}/failure.txt',
    ).writeAsString('$e\n$st\n${errors.join('\n')}');
    exit(1);
  }
}
