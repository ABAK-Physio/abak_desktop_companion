import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/documents/document_root_migration.dart';
import 'package:abak_desktop_companion/core/documents/document_activity_coordinator.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_native_controls.dart';
import 'document_root_migration_test.dart' show Access;

class Inspector implements FinalPdfInspector {
  @override
  Future<int> inspect(Uint8List bytes) async => 1;
}

class Renderer implements MedicalPdfRenderer {
  @override
  Future<List<MedicalPage>> render(Uint8List bytes) async => [
    MedicalPage(Uint8List.fromList([1]), true),
  ];
}

class Controls implements DocumentControlRunner {
  @override
  Future<Map<String, Object?>> inspect(Map<String, String> paths) async => {
    'paths': paths,
  };
  @override
  Future<NativeControlOutput> execute(
    Map<String, Object?> config,
    Directory job,
  ) async => const NativeControlOutput('conforme', 'conforme', 'synthetic', []);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  test(
    'actual medical re-review on same frozen PDF after migration, full schema',
    () async {
      final created = await Directory.systemTemp.createTemp(
        'abak_m2_medical_synthetic_',
      );
      final temp = Directory(await created.resolveSymbolicLinks());
      final support = await Directory(p.join(temp.path, 'support')).create();
      final source = await Directory(p.join(temp.path, 'source')).create();
      final target = await Directory(p.join(temp.path, 'target')).create();
      final db = await DatabaseService.openDatabaseFile(
        p.join(temp.path, 'synthetic.sqlite'),
        factory: databaseFactoryFfi,
      );
      addTearDown(() async {
        DocumentActivityCoordinator.shared.recoveryRequired = false;
        await db.close();
        await temp.delete(recursive: true);
      });
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
        'title': 'Synthetic',
        'pathology_label': 'Fictif',
        'created_at': 1,
        'initial_report_docx_path': p.join(source.path, 'PAT/Bilan/a.docx'),
      });
      await db.insert('patient_document_folders', {
        'patient_id': 'SYN-P',
        'root_path': source.path,
        'folder_name': 'PAT',
      });
      final docx = File(p.join(source.path, 'PAT/Bilan/a.docx'));
      await docx.parent.create(recursive: true);
      await docx.writeAsString('synthetic DOCX content');
      await db.insert('application_settings', {
        'setting_key': migrationRootKey,
        'setting_value': source.path,
        'updated_at': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
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

      final pdf = FinalPdfDocumentService(
        database: () async => db,
        root: () async =>
            Directory(p.join(support.path, 'episode_document_versions')),
        inspector: Inspector(),
      );
      final medical = DocumentMedicalService(
        pdf: pdf,
        renderer: Renderer(),
        now: () => DateTime.utc(2026, 10, 17, 12),
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

      await db.insert('care_episode_reports', {
        'report_id': 'report',
        'care_episode_id': 'SYN-E',
        'author_practitioner_id': 'AUTHOR',
        'title': 'Synthetic report',
        'content_json': '{}',
        'status': 'saved',
        'report_date': 1,
        'created_at': 1,
        'docx_file_name': 'a.docx',
      });
      final original = File(p.join(temp.path, 'synthetic.pdf'));
      final document = pw.Document()
        ..addPage(pw.Page(build: (_) => pw.Text('Synthetic PDF')));
      await original.writeAsBytes(await document.save());
      final v = await pdf.importPdf(
        episodeId: 'SYN-E',
        sourcePath: original.path,
        title: 'Synthetic report',
        origin: const PdfOrigin('report', id: 'report'),
      );
      await medical.savePreparation(v, draft, expectedRevision: 0);
      Future<MedicalRow> approve() async => medical.approve(
        await medical.review(v),
        reviewedPages: {0},
        clinicalContent: true,
        correctPatient: true,
        actingAsValidator: true,
      );
      final approval = await approve();
      final controls = DocumentControlsService(
        medical: medical,
        runner: Controls(),
      );
      await controls.configure({}, expectedRevision: 0);
      await controls.run(v);
      final oldRuns = await db.query('document_control_runs');
      expect(oldRuns, hasLength(1));
      final frozen = await (await pdf.verifiedFile(v)).readAsBytes();
      final sourceRow = (await db.query('care_episode_reports')).single;
      final service = DocumentRootMigration(
        database: db,
        support: support,
        access: Access(),
      );
      final plan = await service.plan(target.path);
      expect(plan.dmp.approvalIds, [approval['approval_id']]);
      await service.execute(
        plan,
        MigrationConsent(
          planHash: plan.hash,
          invalidations: true,
          unknownSpace: true,
        ),
      );
      expect(await db.query('document_medical_approvals'), hasLength(1));
      expect((await medical.status(v)).state, 'invalidated');
      final renewed = await approve();
      expect(renewed['approval_id'], isNot(approval['approval_id']));
      expect((await medical.status(v)).valid, true);
      await controls.run(v);
      expect(await db.query('document_control_runs'), hasLength(2));
      expect(await db.query('episode_document_versions'), hasLength(1));
      expect(await (await pdf.verifiedFile(v)).readAsBytes(), frozen);
      expect((await db.query('care_episode_reports')).single, sourceRow);
      expect(await db.query('document_attempts'), isEmpty);
      expect(await db.query('document_approval_invalidations'), hasLength(1));
      expect(
        (await db.query(
          'document_medical_approvals',
          where: 'approval_id=?',
          whereArgs: [approval['approval_id']],
        )).single,
        approval,
      );
    },
  );
}
