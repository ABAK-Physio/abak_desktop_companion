import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/patients/services/document_lot_signature_records.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';

// sqflite QueryResultSet/Rows return a new map wrapper for each indexed access.
// Reproduce that behaviour without a database, native calls, a card or a PIN.
class FreshRows extends ListBase<MedicalRow> {
  FreshRows(this.values);
  final List<MedicalRow> values;
  @override
  int get length => values.length;
  @override
  set length(int value) => throw UnsupportedError('read only');
  @override
  MedicalRow operator [](int index) =>
      Map<String, Object?>.unmodifiable(values[index]);
  @override
  void operator []=(int index, MedicalRow value) =>
      throw UnsupportedError('read only');
}

class EvidenceVerificationReached implements Exception {}

class ReadOnlyJournal implements DatabaseExecutor {
  ReadOnlyJournal(this.rows);
  final List<MedicalRow> rows;
  int evidenceReads = 0;
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #query) {
      if (invocation.positionalArguments.single == 'document_chain_steps') {
        return Future<List<MedicalRow>>.value(rows);
      }
      if (invocation.positionalArguments.single ==
          'document_medical_approvals') {
        ++evidenceReads;
        return Future<List<MedicalRow>>.error(EvidenceVerificationReached());
      }
    }
    throw UnsupportedError('Unexpected operation: ${invocation.memberName}');
  }
}

MedicalRow row(String phase, {bool signatureRequested = false}) {
  final proof = <String, Object?>{
    'approvalId': 'synthetic-approval',
    if (phase == DocumentLotSignatureRecords.failed)
      'signatureRequested': signatureRequested,
  };
  return {
    'step_id': 'chain:$phase',
    'chain_id': 'chain',
    'version_id': 'v1',
    'document_id': 'doc1',
    'phase': phase,
    'data_json': jsonEncode(proof),
    'data_hash': medicalHash(proof),
  };
}

void main() {
  const begin = DocumentLotSignatureRecords.started;
  const request = DocumentLotSignatureRecords.requested;
  const complete = DocumentLotSignatureRecords.completed;
  const failure = DocumentLotSignatureRecords.failed;
  final root =
      Directory.systemTemp; // No file is read: stop at the next evidence query.
  Future<void> reread(ReadOnlyJournal db) =>
      DocumentLotSignatureRecords.verifyChain(db, 'chain', root);

  test(
    'completed stored sequence survives fresh sqflite row wrappers',
    () async {
      final rows = FreshRows([row(begin), row(request), row(complete)]);
      expect(identical(rows.last, rows.last), isFalse);
      final db = ReadOnlyJournal(rows);
      await expectLater(
        reread(db),
        throwsA(isA<EvidenceVerificationReached>()),
      );
      expect(db.evidenceReads, 1);
    },
  );
  for (final phases in [
    <String>[begin],
    [begin, request],
    [begin, failure],
    [begin, request, failure],
  ]) {
    test(
      'stored interrupted or failed sequence $phases reaches proof checks',
      () async {
        final db = ReadOnlyJournal(
          FreshRows([
            for (final phase in phases)
              row(phase, signatureRequested: phases.contains(request)),
          ]),
        );
        await expectLater(
          reread(db),
          throwsA(isA<EvidenceVerificationReached>()),
        );
        expect(db.evidenceReads, 1);
      },
    );
  }
  for (final phases in [
    [begin, complete],
    [begin, request, complete, failure],
    [begin, request, complete, complete],
    [begin, request, request, complete],
    [begin, complete, request],
    [begin, failure, request],
  ]) {
    test('incoherent sequence $phases remains blocked', () async {
      final db = ReadOnlyJournal(
        FreshRows([for (final phase in phases) row(phase)]),
      );
      await expectLater(reread(db), throwsFormatException);
      expect(db.evidenceReads, 0);
    });
  }
  test('failure marker inconsistent with request remains blocked', () async {
    final db = ReadOnlyJournal(
      FreshRows([row(begin), row(request), row(failure)]),
    );
    await expectLater(reread(db), throwsFormatException);
    expect(db.evidenceReads, 0);
  });
  test('altered evidence hash remains blocked', () async {
    final changed = {...row(complete), 'data_hash': 'altered'};
    final db = ReadOnlyJournal(FreshRows([row(begin), row(request), changed]));
    await expectLater(reread(db), throwsFormatException);
    expect(db.evidenceReads, 0);
  });
  test('foreign version remains blocked', () async {
    final changed = {...row(complete), 'version_id': 'v2'};
    final db = ReadOnlyJournal(FreshRows([row(begin), row(request), changed]));
    await expectLater(reread(db), throwsFormatException);
    expect(db.evidenceReads, 0);
  });
}
