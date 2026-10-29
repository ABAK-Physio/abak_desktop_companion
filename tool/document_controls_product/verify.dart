import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:xml/xml.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/database/document_controls_schema.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_cda_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_native_controls.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/screens/document_medical_screen.dart';

class Inspector implements FinalPdfInspector {
  @override
  Future<int> inspect(Uint8List b) async => 1;
}

class Renderer implements MedicalPdfRenderer {
  Renderer(this.png);
  final Uint8List png;
  @override
  Future<List<MedicalPage>> render(Uint8List b) async => [
    MedicalPage(png, true),
  ];
}

class Runner implements DocumentControlRunner {
  String pdfa = 'conforme', cda = 'conforme';
  int revision = 1, calls = 0;
  bool absent = false, tamper = false, fail = false;
  Future<void> Function()? hook;
  @override
  Future<Map<String, Object?>> inspect(Map<String, String> paths) async {
    if (absent) throw StateError('absent');
    return {'paths': paths, 'testRevision': revision};
  }

  @override
  Future<NativeControlOutput> execute(
    Map<String, Object?> configuration,
    Directory job,
  ) async {
    calls++;
    await hook?.call();
    if (fail) throw StateError('synthetic unavailable');
    if (tamper) {
      await File('${job.path}/document.xml').writeAsString('<wrong/>');
    }
    await File(
      '${job.path}/test-report.txt',
    ).writeAsString('synthetic $pdfa / $cda');
    return NativeControlOutput(pdfa, cda, 'Service simulé', [
      'test-report.txt',
    ]);
  }
}

// The complete test process already runs inside sandbox-exec (deny network*).
// macOS forbids stacking Seatbelt sandboxes. Only this test subclass omits
// the second wrapper; product execution always applies its own sandbox.
class AlreadySandboxedNative extends LocalDocumentControlRunner {
  AlreadySandboxedNative({required super.helper});
  @override
  Future<ProcessResult> process(
    String java,
    List<String> args,
    Directory job,
  ) async {
    return Process.run(
      java,
      ['-Duser.home=${job.path}', '-Djava.io.tmpdir=${job.path}', ...args],
      workingDirectory: job.path,
      includeParentEnvironment: false,
      environment: {'PATH': '/usr/bin:/bin', 'TMPDIR': job.path},
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ctl = LiveWidgetController(WidgetsBinding.instance);
  final output = Directory(Platform.environment['CONTROLS_TEST_OUTPUT']!)
    ..createSync(recursive: true);
  final repo = Platform.environment['CONTROLS_TEST_REPO']!;
  final checks = <String>[], errors = <String>[];
  FlutterError.onError = (e) => errors.add(e.toString());
  void check(bool ok, String name) {
    if (!ok) throw StateError(name);
    checks.add(name);
    stdout.writeln('PASS $name');
  }

  Future<void> refuses(Future<dynamic> Function() fn, String name) async {
    var refused = false;
    try {
      await fn();
    } catch (_) {
      refused = true;
    }
    check(refused, name);
  }

  sqfliteFfiInit();
  final factory = databaseFactoryFfiNoIsolate;
  // Existing fixture filename is resolved below, never a patient document.
  final picture = ui.PictureRecorder();
  final canvas = ui.Canvas(picture);
  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, 10, 10),
    ui.Paint()..color = Colors.black,
  );
  final image = await picture.endRecording().toImage(10, 10);
  final bytes = (await image.toByteData(
    format: ui.ImageByteFormat.png,
  ))!.buffer.asUint8List();
  image.dispose();
  final runner = Runner();
  try {
    if (Platform.environment['CONTROLS_TEST_PHASE'] == 'reopen') {
      final saved = jsonDecode(
        File('${output.path}/result.json').readAsStringSync(),
      );
      final root = Directory(saved['root']);
      if (!root.path.startsWith('${output.path}/synthetic-') ||
          File('${root.path}/scope').readAsStringSync() !=
              'ABAK-J3-SYNTHETIC') {
        throw StateError('scope');
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
        renderer: Renderer(bytes),
        now: () => DateTime.utc(2026, 10, 17, 12),
      );
      final service = DocumentControlsService(medical: medical, runner: runner);
      for (final entry in (saved['persist'] as Map).entries) {
        final row = (await db.query(
          'episode_document_versions',
          where: 'version_id=?',
          whereArgs: [entry.key],
        )).single;
        final s = await service.status(EpisodeDocumentVersion(row));
        check(s.pdfa == entry.value, 'réouverture processus : ${entry.value}');
      }
      check(
        runner.calls == 0,
        'réouverture sans relance native ni appel réseau',
      );
      await db.close();
      File('${output.path}/restart.json').writeAsStringSync(
        jsonEncode({'checks': checks, 'count': checks.length}),
      );
      exit(0);
    }
    final root = await output.createTemp('synthetic-');
    await File('${root.path}/scope').writeAsString('ABAK-J3-SYNTHETIC');
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
      "SELECT name FROM sqlite_master WHERE type='trigger' AND name LIKE 'controls_%'",
    )) {
      await db.execute('DROP TRIGGER "${r['name']}"');
    }
    for (final t in ['invalidations', 'results', 'runs', 'config']) {
      await db.execute('DROP TABLE document_control_$t');
    }
    await db.setVersion(33);
    await refuses(
      () => db.transaction((t) async {
        await createDocumentControlsTables(t);
        throw StateError('crash');
      }),
      'migration interrompue annulée',
    );
    check(
      (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE name='document_control_runs'",
      )).isEmpty,
      'migration rollback sans tables partielles',
    );
    await db.close();
    db = await DatabaseService.openDatabaseFile(
      '${root.path}/test.sqlite',
      factory: factory,
    );
    check(
      await db.getVersion() == DatabaseService.schemaVersion,
      'migration additive depuis 33',
    );
    check(
      (await db.query('document_control_runs')).isEmpty,
      'migration sans preuve fabriquée',
    );
    final pdf = FinalPdfDocumentService(
      database: () async => db,
      root: () async => Directory('${root.path}/pdfs'),
      inspector: Inspector(),
    );
    final medical = DocumentMedicalService(
      pdf: pdf,
      renderer: Renderer(bytes),
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
    Future<MedicalRow> approve(EpisodeDocumentVersion v) async =>
        medical.approve(
          await medical.review(v),
          reviewedPages: {0},
          clinicalContent: true,
          correctPatient: true,
          actingAsValidator: true,
        );
    Future<EpisodeDocumentVersion> fresh({
      bool approved = true,
      String? source,
    }) async {
      final v = await pdf.importPdf(
        episodeId: 'SYN-E',
        sourcePath:
            source ??
            '$repo/tool/dmp_pdf_cda_isolated/fixtures/temoin-pdfa1b.pdf',
        title: 'Synthétique',
      );
      await medical.savePreparation(v, draft, expectedRevision: 0);
      if (approved) await approve(v);
      return v;
    }

    final service = DocumentControlsService(medical: medical, runner: runner);
    final v = await fresh(approved: false);
    await refuses(() => service.run(v), 'contrôle sans configuration bloqué');
    await service.configure({'label': 'Simulé'}, expectedRevision: 0);
    await refuses(
      () => service.configure({'label': 'Simulé'}, expectedRevision: 0),
      'configuration concurrente bloquée',
    );
    await refuses(
      () => service.run(v),
      'contrôle sans validation médicale bloqué',
    );
    check(runner.calls == 0, 'zéro appel avant validation');
    await approve(v);
    var result = await service.run(v);
    check(
      result.pdfa == 'conforme' && result.cda == 'conforme',
      'parcours unifié conforme simulé',
    );
    final proof = Directory(
      '${(await service.root).path}/${result.run!['directory']}',
    );
    final xml = controlXml(
      File('${proof.path}/document.xml').readAsStringSync(),
    );
    check(
      base64Encode(File('${proof.path}/document.pdf').readAsBytesSync()) ==
          xml.findAllElements('text').single.innerText,
      'encapsulation exacte des octets validés',
    );
    check(
      xml
          .findAllElements('id')
          .any((e) => e.getAttribute('extension') == '180019912345601'),
      'matricule qualifié avec clé sans appel INSi',
    );
    check(
      xml
          .findAllElements('code')
          .any((e) => e.getAttribute('code') == 'G15_70'),
      'profession déclarée portée au CDA',
    );
    await refuses(
      () => db.update('document_control_results', {'data_json': '{}'}),
      'résultats immuables',
    );
    await refuses(
      () => db.delete('document_control_runs'),
      'historique immuable',
    );
    final calls = runner.calls;
    check(
      (await service.status(v)).pdfa == 'conforme' && runner.calls == calls,
      'relecture des preuves sans exécution',
    );
    File('${proof.path}/test-report.txt').writeAsStringSync('changed');
    check(
      (await service.status(v)).pdfa == 'invalidated',
      'preuve altérée invalide le résultat',
    );
    File(
      '${proof.path}/test-report.txt',
    ).writeAsStringSync('synthetic conforme / conforme');
    check(
      (await service.status(v)).pdfa == 'invalidated',
      'restaurer une preuve ne restaure pas le verdict',
    );
    final v2 = await fresh();
    await service.run(v2);
    await medical.savePreparation(v2, {
      ...draft,
      'title': 'Titre modifié',
    }, expectedRevision: 1);
    check(
      (await service.status(v2)).pdfa == 'invalidated',
      'contexte modifié invalide immédiatement les contrôles',
    );
    final v3 = await fresh();
    await service.run(v3);
    final next = await pdf.importPdf(
      episodeId: 'SYN-E',
      documentId: v3.documentId,
      sourcePath:
          '$repo/assets/dmp_local/pdf_cda_native/contenu_modifie_pdf.pdf',
      title: 'Modifié',
    );
    check(
      (await service.status(v3)).pdfa == 'invalidated',
      'nouveau PDF invalide ancienne preuve',
    );
    check(
      (await service.status(next)).pdfa == 'non_verifie',
      'nouveau PDF sans héritage',
    );
    final v4 = await fresh();
    runner.tamper = true;
    check(
      (await service.run(v4)).pdfa == 'invalidated',
      'PDF encapsulé différent bloqué',
    );
    runner.tamper = false;
    final v5 = await fresh();
    runner.hook = () async {
      await medical.savePreparation(v5, {
        ...draft,
        'title': 'Pendant contrôle',
      }, expectedRevision: 1);
    };
    check(
      (await service.run(v5)).pdfa == 'invalidated',
      'résultat tardif refusé après modification',
    );
    runner.hook = null;
    final v6 = await fresh();
    final entered = Completer<void>(), release = Completer<void>();
    runner.hook = () async {
      entered.complete();
      await release.future;
    };
    final ongoing = service.run(v6);
    await entered.future;
    await refuses(() => service.run(v6), 'contrôle concurrent bloqué');
    release.complete();
    await ongoing;
    runner.hook = null;
    runner.revision++;
    check(
      (await service.status(v6)).pdfa == 'invalidated',
      'outil changé détecté à la relecture',
    );
    runner.revision = 1;
    final v7 = await fresh();
    runner.fail = true;
    check(
      (await service.run(v7)).pdfa == 'non_verifie',
      'erreur exécution distincte de refus',
    );
    runner.fail = false;
    runner.absent = true;
    final v8 = await fresh();
    check(
      (await service.run(v8)).pdfa == 'non_verifie',
      'outil absent conserve non vérifié',
    );
    runner.absent = false;
    final v9 = await fresh();
    await service.run(v9);
    await service.configure({'label': 'Simulé'}, expectedRevision: 1);
    check(
      (await service.status(v9)).pdfa == 'invalidated',
      'réenregistrement configuration invalide preuves antérieures',
    );
    // Interrupted job is not resumed automatically, even in a fresh service instance.
    final vi = await fresh();
    final ar = await db.transaction((tx) => medical.approvedCapture(tx, vi));
    final cfg = (await service.configuration())!;
    await db.insert('document_control_runs', {
      'run_id': 'interrupted',
      'version_id': vi.id,
      'approval_id': ar['approval_id'],
      'snapshot_hash': ar['snapshot_hash'],
      'configuration_hash': cfg['fingerprint'],
      'configuration_revision': cfg['revision'],
      'directory': 'unused',
      'started_at': 1,
    });
    check(
      (await service.status(vi)).message.contains('interrompu'),
      'interruption sans conformité ni relance',
    );
    // Unsupported data is never silently substituted by fixture values.
    final capture = jsonDecode(ar['snapshot_json'] as String) as Map;
    for (final variant in [
      'multipleGivenNames',
      'minor',
      'visibility',
      'validator',
      'authority',
      'facility',
      'professionalName',
    ]) {
      final copy = jsonDecode(jsonEncode(capture));
      final prep = jsonDecode(copy['preparation']['data_json']),
          practice = jsonDecode(copy['practice']['data_json']);
      switch (variant) {
        case 'multipleGivenNames':
          copy['identity']['birth_first_names'] = 'Jean Claude';
        case 'minor':
          copy['identity']['birth_date'] = '2020-01-01';
        case 'visibility':
          prep['patientVisibility'] = 'invisible';
        case 'validator':
          prep['validatorId'] = 'OTHER';
        case 'authority':
          practice['authority'] = 'bad';
        case 'facility':
          practice.remove('facilityCode');
        case 'professionalName':
          practice.remove('familyName');
      }
      copy['preparation']['data_json'] = jsonEncode(prep);
      copy['practice']['data_json'] = jsonEncode(practice);
      await refuses(
        () async => DocumentCdaBuilder.build(copy, Uint8List(0), 1),
        'mapping incomplet bloqué : $variant',
      );
    }
    // Actual installed native tools, on the synthetic PDF only.
    final native = AlreadySandboxedNative(
      helper: () =>
          File('$repo/assets/document_controls/CdaCheck.java').readAsString(),
    );
    final nativeService = DocumentControlsService(
      medical: medical,
      runner: native,
    );
    final paths = {
      'java':
          '/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin/java',
      'vera': '/Users/jeanclaudebrucher/verapdf/bin/cli-1.30.3.jar',
      'references': Platform.environment['CONTROLS_TEST_REFS']!,
      'label': 'Références locales archivées — essai synthétique',
    };
    await nativeService.configure(paths, expectedRevision: 2);
    final vn = await fresh();
    final ns = await nativeService.run(vn);
    await File('${output.path}/native.json').writeAsString(
      jsonEncode({
        'pdfa': ns.pdfa,
        'cda': ns.cda,
        'message': ns.message,
        'run': ns.run,
      }),
    );
    check(ns.pdfa == 'conforme', 'veraPDF natif : témoin PDF/A-1b conforme');
    check(ns.cda == 'conforme', 'CDA natif : XSD et cinq profils conformes');
    check(
      !Directory(
        '${(await service.root).path}/${ns.run!['directory']}/references',
      ).existsSync(),
      'copies temporaires retirées, preuves conservées',
    );
    check(
      (await nativeService.status(vn)).cda == 'conforme',
      'preuves natives relues sans nouvelle exécution',
    );
    final nativeJob = Directory(
      '${(await service.root).path}/${ns.run!['directory']}',
    );
    final nativeReport = File(
          '${nativeJob.path}/verapdf.xml',
        ).readAsStringSync(),
        nativePdf = File('${nativeJob.path}/document.pdf');
    check(
      pdfaVerdict(nativeReport, 0, nativePdf) == 'conforme',
      'analyse rapport réel conforme',
    );
    check(
      pdfaVerdict(nativeReport, 1, nativePdf) == 'non_verifie',
      'code incohérent non vérifié',
    );
    check(
      pdfaVerdict(
            nativeReport.replaceAll('PDF/A-1b', 'PDF/A-1a'),
            0,
            nativePdf,
          ) ==
          'non_verifie',
      'profil différent non vérifié',
    );
    check(
      pdfaVerdict(
            nativeReport.replaceAll(nativePdf.path, '/unrelated.pdf'),
            0,
            nativePdf,
          ) ==
          'non_verifie',
      'rapport non corrélé refusé',
    );
    check(
      pdfaVerdict('<!DOCTYPE report><report/>', 0, nativePdf) == 'non_verifie',
      'DTD bloquée',
    );
    // Use native runner directly for negative reports; their bytes remain synthetic.
    final negative = Directory('${root.path}/native-negative')..createSync();
    File(
      '$repo/assets/dmp_local/pdf_cda_native/sans_xmp_pdf.pdf',
    ).copySync('${negative.path}/document.pdf');
    File(
      '${negative.path}/document.xml',
    ).writeAsStringSync('<ClinicalDocument xmlns="urn:hl7-org:v3"/>');
    final neg = await native.execute(
      Map<String, Object?>.from(
        jsonDecode((await service.configuration())!['data_json'] as String),
      ),
      negative,
    );
    check(
      neg.pdfa == 'refuse',
      'veraPDF natif : non conformité distincte erreur',
    );
    check(neg.cda == 'refuse', 'CDA natif : structure invalide refusée');
    // Return to explicit fake service for the product UI and second process persistence.
    await service.configure({'label': 'Simulé'}, expectedRevision: 3);
    final persist = <String, String>{v.id: 'invalidated'};
    for (final state in ['conforme', 'refuse', 'non_verifie']) {
      runner.pdfa = state;
      runner.cda = state;
      final item = await fresh();
      await service.run(item);
      persist[item.id] = state;
    }
    runner.pdfa = 'conforme';
    runner.cda = 'conforme';
    final vu = await fresh();
    await service.run(vu);
    runApp(
      MaterialApp(
        home: RepaintBoundary(
          key: const Key('capture'),
          child: DocumentMedicalScreen(
            version: vu,
            service: medical,
            controls: service,
          ),
        ),
      ),
    );
    Future<void> pump() async {
      await ctl.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await ctl.pump();
    }

    for (var n = 0; n < 8; n++) {
      await pump();
    }
    final scroll = find.byType(Scrollable).first;
    await ctl.scrollUntilVisible(
      find.byKey(const Key('run-native-controls')),
      450,
      scrollable: scroll,
      maxScrolls: 35,
    );
    await pump();
    check(
      ctl
              .widget<FilledButton>(
                find.byKey(const Key('run-native-controls')),
              )
              .onPressed !=
          null,
      'écran métier : contrôles disponibles après validation',
    );
    check(
      ctl
              .widget<OutlinedButton>(find.byKey(const Key('medical-send')))
              .onPressed ==
          null,
      'écran métier : envoi toujours grisé',
    );
    check(
      ctl
          .widget<Text>(find.byKey(const Key('native-control-status')))
          .data!
          .contains('conforme'),
      'écran métier : résultat distinct affiché',
    );
    final boundary = ctl.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('capture')),
    );
    final shot = await boundary.toImage();
    await File('${output.path}/ecran-controles.png').writeAsBytes(
      (await shot.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List(),
    );
    shot.dispose();
    runApp(const SizedBox());
    await pump();
    check(errors.isEmpty, 'écran sans erreur Flutter');
    check(
      identityBefore ==
          medicalCanonical(await db.query('patient_fr_health_identity')),
      'identité qualifiée inchangée',
    );
    check(
      (await db.query('document_medical_approvals')).isNotEmpty,
      'validations médicales conservées séparément',
    );
    await db.close();
    await File('${output.path}/result.json').writeAsString(
      jsonEncode({
        'root': root.path,
        'checks': checks,
        'count': checks.length,
        'persist': persist,
        'networkCalls': 0,
      }),
    );
    stdout.writeln('DONE ${checks.length}');
    exit(0);
  } catch (e, st) {
    stderr.writeln('$e\n$st');
    File(
      '${output.path}/failure.txt',
    ).writeAsStringSync('$e\n$st\n${errors.join('\n')}');
    exit(1);
  }
}
