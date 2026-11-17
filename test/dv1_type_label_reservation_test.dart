import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_retry.dart';

import 'support/dv1_type_label_fixture.dart';

void main() {
  late TypeLabelFixture f;
  setUp(() async {
    f = await TypeLabelFixture.create();
  });
  tearDown(() => f.close());

  test('a complete signed rejected attempt yields a read-only review of the same approved content', () async {
    final before = medicalCanonical(await f.db.query('document_chain_steps'));
    final review = await f.inspect();
    expect(review.typeLabel, true);
    expect(review.evidence['reason'], 'XDS-typeCode-11490-label');
    expect(review.saved['cdaHash'], f.phase('reservation')['cdaHash']);
    review.checkPreparation(
      {
        'approval_id': review.saved['approvalId'],
        'snapshot_hash': review.saved['snapshotHash'],
      },
      {'run_id': review.saved['controlRunId']},
      review.saved['cdaHash'],
    );
    await Dv1Retry.recheck(f.db, f.version, f.root, review);
    expect(medicalCanonical(await f.db.query('document_chain_steps')), before);
  });
  test('SQL permits one linked reservation and consumes it even before a response exists', () async {
    final original = medicalCanonical(f.reservation);
    final review = await f.inspect();
    await f.reserve(review);
    expect(
      (await f.db.query(
        'document_chain_steps',
        where: 'phase=?',
        whereArgs: ['dv1_reservation'],
      )).length,
      2,
    );
    await expectLater(f.inspect(), throwsA(anything));
    await expectLater(
      f.reserve(review, chain: 'third-attempt'),
      throwsA(anything),
    );
    expect(
      medicalCanonical(
        (await f.db.query(
          'document_chain_steps',
          where: 'chain_id=? AND phase=?',
          whereArgs: [review.attemptId, 'dv1_reservation'],
        )).single,
      ),
      original,
    );
  });
  test(
    'a duplicate without the verified correction evidence remains blocked',
    () async {
      await expectLater(
        f.db.insert('document_chain_steps', {
          ...f.reservation,
          'step_id': 'unlinked',
          'chain_id': 'unlinked',
        }),
        throwsA(anything),
      );
    },
  );
  test('a changed approval, snapshot, controls, CDA or unknown profile cannot reserve a retry', () async {
    final review = await f.inspect();
    for (final changes in <Map<String, Object?>>[
      {'approvalId': 'other'},
      {'snapshotHash': 'other'},
      {'controlRunId': 'other'},
      {'cdaHash': 'other'},
      {
        'retry': {...review.evidence, 'correctedTypeLabelProfile': 'other'},
      },
      {
        'retry': {...review.evidence, 'previousAttemptId': 'other'},
      },
    ]) {
      await expectLater(f.reserve(review, changes: changes), throwsA(anything));
    }
  });
  test('success or unknown outcome can never grant this correction', () async {
    final row = f.steps.singleWhere((r) => r['phase'] == 'dv1_response');
    for (final outcome in ['accepted', 'indeterminate']) {
      final data = {...f.phase('response'), 'outcome': outcome};
      await f.db.update(
        'document_chain_steps',
        {'data_json': medicalCanonical(data), 'data_hash': medicalHash(data)},
        where: 'step_id=?',
        whereArgs: [row['step_id']],
      );
      await expectLater(f.inspect(), throwsA(anything));
    }
  });
  test('interruption without a definitive response stays blocked', () async {
    await f.db.delete(
      'document_chain_steps',
      where: 'phase=?',
      whereArgs: ['dv1_response'],
    );
    await expectLater(f.inspect(), throwsA(anything));
  });
  test('restored or simulated attempts remain blocked', () async {
    await f.db.insert('document_restore_barriers', {'id': 'restore'});
    await expectLater(f.inspect(), throwsA(anything));
    await f.db.delete('document_restore_barriers');
    // Model a simulation that predates the DV1 schema installation.
    await f.db.execute('DROP TRIGGER simulation_after_dv1_guard');
    await f.db.insert('document_attempts', {
      'document_id': f.version.documentId,
    });
    await expectLater(f.inspect(), throwsA(anything));
  });
  test(
    'another document with the same patient and PDF cannot use this review',
    () async {
      final v = EpisodeDocumentVersion({
        ...f.version.values,
        'document_id': 'other-document',
      });
      await expectLater(Dv1Retry.inspect(f.db, v, f.root), throwsA(anything));
    },
  );
  test('a changed signed package invalidates the review even if its row hash is recomputed', () async {
    final review = await f.inspect();
    final row = f.steps.singleWhere((r) => r['phase'] == 'dv1_package');
    final data = jsonDecode(row['data_json'] as String) as Map;
    data['metadata'] = (data['metadata'] as String).replaceFirst(
      '11490-0',
      '11506-3',
    );
    await f.db.update(
      'document_chain_steps',
      {'data_json': medicalCanonical(data), 'data_hash': medicalHash(data)},
      where: 'step_id=?',
      whereArgs: [row['step_id']],
    );
    await expectLater(
      Dv1Retry.recheck(f.db, f.version, f.root, review),
      throwsA(anything),
    );
  });
}
