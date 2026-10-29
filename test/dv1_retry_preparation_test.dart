import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/document_dv1_schema.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';

void main() {
  final snapshot = {
    'preparation': {
      'version_id': 'v',
      'revision': 1,
      'updated_at': 100,
      'data_json': '{"title":"Synthetic report"}',
    },
    'dependencyEpoch': 2,
    'identity': {'patient_id': 'synthetic', 'ins_number': 'test-only'},
    'version': {'sha256': 'original'},
    'practice': {'revision': 1},
  };
  Map copy() => jsonDecode(jsonEncode(snapshot)) as Map;
  test('retry ignores only preparation save bookkeeping', () {
    final after = copy();
    after['dependencyEpoch'] = 3;
    after['preparation']['revision'] = 2;
    after['preparation']['updated_at'] = 200;
    expect(DocumentMedicalService.sameRetrySnapshot(snapshot, after), isTrue);
    expect(snapshot['dependencyEpoch'], 2);
    after['preparation']['data_json'] = '{"title":"Changed"}';
    expect(DocumentMedicalService.sameRetrySnapshot(snapshot, after), isFalse);
  });
  for (final field in ['identity', 'version', 'practice']) {
    test('retry rejects changed $field even with matching preparation', () {
      final after = copy();
      after[field]['changed'] = true;
      expect(
        DocumentMedicalService.sameRetrySnapshot(snapshot, after),
        isFalse,
      );
    });
  }
  group('durable retry guard', () {
    late Database db;
    final original = {
      'approvalId': 'a',
      'snapshotHash': 's',
      'controlRunId': 'r',
      'cdaHash': 'c',
    };
    Map<String, Object?> row(String chain, Map data) => {
      'chain_id': chain,
      'data_hash': null,
      'version_id': 'v',
      'document_id': 'd',
      'phase': 'dv1_reservation',
      'state': 'reserved',
      'data_json': jsonEncode(data),
    };
    Map retry() => {
      ...original,
      'retry': {
        'previousAttemptId': 'first',
        'reason': 'SOAP-MustUnderstand-Security',
        'correctedProfile': 'dv1-20261028',
        'evidenceHash': 'a' * 64,
        'preparationPolicy': 'identical-content-preserve-invalidation',
      },
    };
    setUp(() async {
      sqfliteFfiInit();
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      await db.execute(
        'CREATE TABLE episode_document_versions(version_id TEXT, document_id TEXT, patient_id TEXT, sha256 TEXT, sequence_number INTEGER)',
      );
      await db.execute(
        'CREATE TABLE document_chain_steps(chain_id TEXT, version_id TEXT, document_id TEXT, phase TEXT, state TEXT, data_json TEXT, data_hash TEXT)',
      );
      await db.execute('CREATE TABLE document_restore_barriers(id TEXT)');
      await db.execute(
        'CREATE TABLE document_attempts(document_id TEXT,patient_id TEXT,pdf_hash TEXT)',
      );
      await db.execute(
        'CREATE TABLE document_events(kind TEXT,reference_id TEXT,detail TEXT,created_at INTEGER)',
      );
      await db.insert('episode_document_versions', {
        'version_id': 'v',
        'document_id': 'd',
        'patient_id': 'p',
        'sha256': 'h',
      });
      await db.insert('document_chain_steps', row('first', original));
      // Exercise replacement of an existing guard, not just fresh databases.
      await db.execute(
        "CREATE TRIGGER dv1_reservation_guard BEFORE INSERT ON document_chain_steps BEGIN SELECT RAISE(ABORT,'old guard'); END",
      );
      await createDocumentDv1Tables(db);
    });
    tearDown(() async => db.close());
    test(
      'one linked retry; third reservation and simulations remain blocked',
      () async {
        await db.insert('document_chain_steps', row('second', retry()));
        await expectLater(
          db.insert('document_chain_steps', row('third', retry())),
          throwsA(anything),
        );
        await expectLater(
          db.insert('document_attempts', {
            'document_id': 'd',
            'patient_id': 'p',
            'pdf_hash': 'h',
          }),
          throwsA(anything),
        );
        expect(
          await db.query(
            'document_chain_steps',
            where: 'chain_id=?',
            whereArgs: ['first'],
          ),
          [row('first', original)],
        );
      },
    );
    test(
      'ordinary duplicate, null or incomplete retry cannot bypass guard',
      () async {
        for (final data in [
          original,
          {...original, 'retry': null},
          {...original, 'retry': {}},
          <String, Object?>{},
        ]) {
          await expectLater(
            db.insert('document_chain_steps', row('second', data)),
            throwsA(anything),
          );
        }
      },
    );
    for (final key in [
      'approvalId',
      'snapshotHash',
      'controlRunId',
      'cdaHash',
    ]) {
      test('changed $key cannot bypass guard', () async {
        await expectLater(
          db.insert(
            'document_chain_steps',
            row('second', {...retry(), key: 'changed'}),
          ),
          throwsA(anything),
        );
      });
    }
    test('unrelated original attempt cannot authorize retry', () async {
      final data = retry();
      data['retry']['previousAttemptId'] = 'other';
      await expectLater(
        db.insert('document_chain_steps', row('second', data)),
        throwsA(anything),
      );
    });
    Map patientRetry() => {
      ...original,
      'retry': {
        'previousAttemptId': 'second',
        'firstAttemptId': 'first',
        'reason': 'XDS-patientId-missing-NH',
        'correctedProfile': 'dv1-20261028',
        'correctedPatientIdProfile': 'ins-nh-1',
        'evidenceHash': 'b' * 64,
        'preparationPolicy': 'identical-content-preserve-invalidation',
      },
    };
    test(
      'patientId retry permits exactly one third reservation with lineage',
      () async {
        await db.insert('document_chain_steps', row('second', retry()));
        await db.insert('document_chain_steps', row('third', patientRetry()));
        await expectLater(
          db.insert('document_chain_steps', row('fourth', patientRetry())),
          throwsA(anything),
        );
      },
    );
    test('patientId retry requires both original reservations', () async {
      await expectLater(
        db.insert('document_chain_steps', row('third', patientRetry())),
        throwsA(anything),
      );
    });
    for (final key in [
      'firstAttemptId',
      'previousAttemptId',
      'correctedPatientIdProfile',
    ]) {
      test('patientId retry rejects wrong $key', () async {
        await db.insert('document_chain_steps', row('second', retry()));
        final data = patientRetry();
        (data['retry'] as Map)[key] = 'wrong';
        await expectLater(
          db.insert('document_chain_steps', row('third', data)),
          throwsA(anything),
        );
      });
    }
    Map metadataRetry() => {
      ...original,
      'retry': {
        'previousAttemptId': 'third',
        'firstAttemptId': 'first',
        'secondAttemptId': 'second',
        'reason': 'XDS-labels-signature',
        'correctedProfile': 'dv1-20261028',
        'correctedPatientIdProfile': 'ins-nh-1',
        'correctedMetadataProfile': 'dv1-labels-signature-1',
        'evidenceHash': 'c' * 64,
        'preparationPolicy': 'identical-content-preserve-invalidation',
      },
    };
    test(
      'metadata retry permits one fourth reservation and no fifth',
      () async {
        await db.insert('document_chain_steps', row('second', retry()));
        await db.insert('document_chain_steps', row('third', patientRetry()));
        await db.insert('document_chain_steps', row('fourth', metadataRetry()));
        await expectLater(
          db.insert('document_chain_steps', row('fifth', metadataRetry())),
          throwsA(anything),
        );
      },
    );
    for (final key in [
      'firstAttemptId',
      'secondAttemptId',
      'previousAttemptId',
      'correctedMetadataProfile',
      'correctedPatientIdProfile',
    ]) {
      test('metadata retry rejects wrong $key', () async {
        await db.insert('document_chain_steps', row('second', retry()));
        await db.insert('document_chain_steps', row('third', patientRetry()));
        final data = metadataRetry();
        (data['retry'] as Map)[key] = 'wrong';
        await expectLater(
          db.insert('document_chain_steps', row('fourth', data)),
          throwsA(anything),
        );
      });
    }
    test('metadata retry cannot skip the patientId reservation', () async {
      await db.insert('document_chain_steps', row('second', retry()));
      await expectLater(
        db.insert('document_chain_steps', row('fourth', metadataRetry())),
        throwsA(anything),
      );
    });
    Map titleRetry() => {
      ...original,
      'retry': {
        'previousAttemptId': 'fourth',
        'firstAttemptId': 'first',
        'secondAttemptId': 'second',
        'thirdAttemptId': 'third',
        'reason': 'XDS-signature-title',
        'correctedProfile': 'dv1-20261028',
        'correctedPatientIdProfile': 'ins-nh-1',
        'correctedMetadataProfile': 'dv1-labels-signature-1',
        'correctedSignatureTitleProfile': 'event-source-1',
        'evidenceHash': 'd' * 64,
        'preparationPolicy': 'identical-content-preserve-invalidation',
      },
    };
    Future<void> priorFour() async {
      await db.insert('document_chain_steps', row('second', retry()));
      await db.insert('document_chain_steps', row('third', patientRetry()));
      await db.insert('document_chain_steps', row('fourth', metadataRetry()));
    }

    test('title retry allows one fifth reservation and no sixth', () async {
      await priorFour();
      await db.insert('document_chain_steps', row('fifth', titleRetry()));
      await expectLater(
        db.insert('document_chain_steps', row('sixth', titleRetry())),
        throwsA(anything),
      );
    });
    for (final key in [
      'firstAttemptId',
      'secondAttemptId',
      'thirdAttemptId',
      'previousAttemptId',
      'correctedSignatureTitleProfile',
    ]) {
      test('title retry rejects wrong $key', () async {
        await priorFour();
        final data = titleRetry();
        (data['retry'] as Map)[key] = 'wrong';
        await expectLater(
          db.insert('document_chain_steps', row('fifth', data)),
          throwsA(anything),
        );
      });
    }
    test('restore barrier blocks even a linked retry', () async {
      await db.insert('document_restore_barriers', {'id': 'restored'});
      await expectLater(
        db.insert('document_chain_steps', row('second', retry())),
        throwsA(anything),
      );
    });
  });
}
