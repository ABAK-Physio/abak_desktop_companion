import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
// Offline incident regression: read-only source, mutations confined to memory.
// Synthetic signing keys only; no CPS, native transport or network invocation.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/core/database/document_dv1_schema.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/services/document_cda_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_replacement.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_records.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';
import '../tool/document_wire_product/fakes.dart';

void main() {
  test(
    'replacement: signed CDA/XDS linkage, patient guard and durable one-send reservation',
    () async {
      sqfliteFfiInit();
      final source = await databaseFactoryFfi.openDatabase(
        Platform.environment['ABAK_SEARCH_DB']!,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      addTearDown(() async {
        await source.close();
        await db.close();
      });
      for (final table in await source.rawQuery(
        "SELECT name,sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      )) {
        await db.execute(table['sql'] as String);
        for (final row in await source.query(table['name'] as String)) {
          await db.insert(table['name'] as String, row);
        }
      }
      final old = (await db.query(
        'episode_document_versions',
        where: 'version_id=?',
        whereArgs: [Platform.environment['ABAK_SEARCH_VERSION']!],
      )).single;
      final version = EpisodeDocumentVersion({
        ...old,
        'version_id': '11111111-1111-4111-8111-111111111111',
        'sequence_number': (old['sequence_number'] as int) + 1,
        'sha256': 'b' * 64,
        'relative_path': 'synthetic-only.pdf',
      });
      await db.insert('episode_document_versions', version.values);
      final target = await Dv1Replacement.candidate(db, version);
      await expectLater(
        Dv1Replacement.candidate(db, EpisodeDocumentVersion(old)),
        throwsStateError,
      );
      await expectLater(
        Dv1Replacement.candidate(
          db,
          EpisodeDocumentVersion({...version.values, 'sha256': old['sha256']}),
        ),
        throwsStateError,
      );
      await expectLater(
        Dv1Replacement.candidate(
          db,
          EpisodeDocumentVersion({...version.values, 'patient_id': 'other'}),
        ),
        throwsStateError,
      );
      final prep = (await db.query(
        'document_preparations',
        where: 'version_id=?',
        whereArgs: [old['version_id']],
      )).single;
      await db.insert('document_preparations', {
        ...prep,
        'version_id': version.id,
      });
      final oldApproval = (await db.query(
        'document_medical_approvals',
        where: 'snapshot_hash=?',
        whereArgs: [target['snapshotHash']],
      )).first;
      await db.insert('document_medical_approvals', {
        ...oldApproval,
        'approval_id': 'synthetic-review-to-invalidate',
        'version_id': version.id,
      });
      for (final trigger in await source.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='trigger' AND tbl_name='document_preparations'",
      )) {
        await db.execute(trigger['sql'] as String);
      }
      await Dv1Replacement.configure(db, version);
      expect(
        await db.query(
          'document_approval_invalidations',
          where: 'approval_id=?',
          whereArgs: ['synthetic-review-to-invalidate'],
        ),
        hasLength(1),
      );
      expect(await Dv1Replacement.check(db, version), target);

      final approval = (await db.query(
        'document_medical_approvals',
        where: 'snapshot_hash=?',
        whereArgs: [target['snapshotHash']],
      )).first;
      final snapshot =
          jsonDecode(approval['snapshot_json'] as String)
              as Map<String, dynamic>;
      snapshot.remove('cndaRecipe');
      snapshot['identity']['identity_status'] = 'qualified';
      final practice = jsonDecode(snapshot['practice']['data_json']);
      practice['identifier'] = '12345678901';
      snapshot['practice']['data_json'] = medicalCanonical(practice);
      final pdf = Uint8List.fromList(
        utf8.encode('%PDF synthetic replacement content'),
      );
      snapshot['version'] = {
        ...version.values,
        'sha256': FinalPdfDocumentService.hash(pdf),
      };
      final data =
          jsonDecode(prep['data_json'] as String) as Map<String, dynamic>;
      data['clinicalDate'] = '2026-10-16T10:00:00Z';
      data['dv1Replacement'] = medicalCanonical(target);
      snapshot['preparation'] = {
        ...prep,
        'version_id': version.id,
        'data_json': medicalCanonical(data),
      };
      final now = DateTime.utc(2026, 10, 17, 12);
      final cda = DocumentCdaBuilder.build(
        snapshot,
        pdf,
        now.millisecondsSinceEpoch,
      );
      final xml = XmlDocument.parse(utf8.decode(cda));
      final parent = xml.findAllElements('relatedDocument').single;
      expect(parent.getAttribute('typeCode'), 'RPLC');
      final headerOrder = xml.rootElement.childElements
          .map((element) => element.name.local).toList();
      expect(headerOrder.indexOf('relatedDocument'),
          lessThan(headerOrder.indexOf('componentOf')));

      expect(
        parent.findAllElements('id').single.getAttribute('root'),
        target['uniqueId'],
      );
      expect(
        DocumentCdaBuilder.documentId(snapshot),
        isNot(target['uniqueId']),
      );
      final ports = WirePorts(
        '.',
        () => now,
        Platform.environment['ABAK_RPLC_CERTS']!,
      );
      final session = await ports.authenticate(snapshot);
      final material = await ports.wireMaterial(session);
      const entry = 'urn:uuid:22222222-2222-4222-8222-222222222222';
      DmpWireDraft draft({String? uuid = entry}) => DmpWireDraft(
        snapshot,
        session,
        cda,
        material,
        now,
        approvedAt: now.millisecondsSinceEpoch,
        replacementEntryUuid: uuid,
      );
      expect(() => draft(uuid: null), throwsA(anything));
      expect(() => draft(uuid: 'invalid'), throwsA(anything));
      final d = draft();
      final signature = await ports.signCanonicalXml(
        d.signedInfo,
        material.signingHash,
        session,
      );
      final packet = d.finish(signature);
      d.verify(packet, now);
      final submission = DmpPreparedSubmission(
        request: packet.soap,
        messageId: d.messageId,
        metadata: packet.metadata,
        vihf: packet.vihf,
        cdaHash: FinalPdfDocumentService.hash(cda),
        snapshotHash: medicalHash(snapshot),
        sessionHash: medicalHash(session.evidence),
        wire: {
          ...packet.evidence,
          'material': material.evidence,
          'authenticationDer': material.authenticationDer,
          'signingCertificateHash': material.signingHash,
          'signedInfo': d.signedInfo,
          'replay': d.replay,
        },
      );
      DmpWireDraft.verifyArchived(
        submission.evidence,
        snapshot,
        session.evidence,
      );
      final tampered = jsonDecode(jsonEncode(submission.evidence)) as Map;
      tampered['wire']['replay']['replacementEntryUuid'] =
          'urn:uuid:33333333-3333-4333-8333-333333333333';
      expect(
        () => DmpWireDraft.verifyArchived(tampered, snapshot, session.evidence),
        throwsA(anything),
      );
      final rplc = XmlDocument.parse(packet.metadata)
          .findAllElements('Association', namespaceUri: DmpWireDraft.rim)
          .where(
            (e) =>
                e.getAttribute('associationType') ==
                'urn:ihe:iti:2007:AssociationType:RPLC',
          )
          .single;
      expect(rplc.getAttribute('sourceObject'), d.cdaEntry);
      expect(rplc.getAttribute('targetObject'), entry);
      data['dv1Replacement'] = medicalCanonical({
        ...target,
        'patientCx': 'other',
      });
      snapshot['preparation']['data_json'] = medicalCanonical(data);
      expect(draft, throwsA(anything));

      await createDocumentDv1Tables(db);
      Map<String, Object?> reservation(String chain) => {
        'step_id': chain,
        'chain_id': chain,
        'document_id': version.documentId,
        'version_id': version.id,
        'phase': 'dv1_reservation',
        'state': 'reserved',
        'detail': 'synthetic only',
        'created_at': now.millisecondsSinceEpoch,
        'data_json': medicalCanonical({'replacement': target}),
        'data_hash': 'a' * 64,
      };
      // Missing intent cannot bypass the historical duplicate guard.
      await expectLater(
        db.insert('document_chain_steps', {
          ...reservation('missing'),
          'data_json': '{}',
        }),
        throwsA(anything),
      );
      await db.insert('document_chain_steps', reservation('replacement-one'));
      await expectLater(
        db.insert('document_chain_steps', reservation('replacement-two')),
        throwsA(anything),
      );
      await expectLater(Dv1Replacement.check(db, version), throwsA(anything));
      // Historical accepted evidence remains readable after the additive migration.
      final original = (await db.query(
        'document_chain_steps',
        where: 'chain_id=? AND phase=?',
        whereArgs: [target['attemptId'], 'dv1_reservation'],
      )).single;
      expect((await Dv1Records.verify(db, original))['outcome'], 'accepted');
      expect(
        (await source.rawQuery('SELECT total_changes() AS n')).single['n'],
        0,
      );
    },
    skip:
        Platform.environment['ABAK_SEARCH_DB'] == null ||
        Platform.environment['ABAK_RPLC_CERTS'] == null,
  );
}
