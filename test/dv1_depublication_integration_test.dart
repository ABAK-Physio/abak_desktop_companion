// Opt-in read-only regression against a local accepted deposit.
// No CPS, network request, validator or database mutation is performed.
import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_dv1_access/depublication.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/access_context.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td33c.dart';
import 'package:xml/xml.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/search_targets.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_journal_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';

void main() {
  test(
    'depublication prepares latest accepted document offline and rejects another author',
    () async {
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(
        Platform.environment['ABAK_SEARCH_DB']!,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      addTearDown(db.close);
      final journal = DocumentJournalService(
        controls: DocumentControlsService(
          medical: DocumentMedicalService(
            pdf: FinalPdfDocumentService(
              database: () async => db,
              root: () async =>
                  Directory(Platform.environment['ABAK_SEARCH_ROOT']!),
            ),
          ),
        ),
      );
      final targets = Dv1SearchTargets(journal);
      final version = Platform.environment['ABAK_SEARCH_VERSION']!;
      final result = await targets.list(versionId: version);
      expect(result.targets, hasLength(1));
      final target = result.targets.single;
      expect(target.data['versionId'], version);
      expect(target.data['origin'], isNot('reviewed_legacy'));
      expect(target.uniqueId, matches(RegExp(r'^2\.25\.\d+$')));
      await targets.verify(target);
      Dv1AccessContext context(String author) => Dv1AccessContext(
        professional: author,
        structure: target.data['structure']!,
        sector: 'SA07',
        ins: target.data['ins']!,
        patientLabel: target.data['patient']!,
        source: target.data['source']!,
        birthDate: target.data['birth'],
        scenario: 'PRE_ALIM_SUPPR',
        confirmedAt: DateTime.now(),
      );
      final prepare = Dv1Depublication(journal);
      final archived = await prepare.prepare(
        target,
        context(target.data['professional']!),
      );
      await expectLater(
        prepare.prepare(target, context('99999999999')),
        throwsStateError,
      );
      final xml = DmpNativeTd33c.build(
        archived,
        archived,
        'urn:uuid:11111111-2222-3333-4444-555555555555',
        DateTime.utc(2026, 10, 29),
      );
      expect(
        XmlDocument.parse(xml).findAllElements('ExtrinsicObject'),
        isEmpty,
      );
      final output = Platform.environment['ABAK_DELETE_ACTUAL_REQUEST'];
      if (output != null) await File(output).writeAsString(xml);
      final all = await targets.list();
      for (final old in all.targets.where(
        (t) =>
            t.data['documentId'] == target.data['documentId'] &&
            t.id != target.id,
      )) {
        await expectLater(
          prepare.prepare(old, context(target.data['professional']!)),
          throwsStateError,
        );
      }

      final rejected = await db.rawQuery(
        "SELECT count(*) AS n FROM document_chain_steps WHERE phase='dv1_reservation' AND version_id=?",
        [version],
      );
      expect(result.excluded, (rejected.single['n'] as int) - 1);
      expect((await targets.list(versionId: 'absent')).targets, isEmpty);
      expect((await db.rawQuery('SELECT total_changes() AS n')).single['n'], 0);
    },
    skip: Platform.environment['ABAK_SEARCH_DB'] == null,
  );
}
