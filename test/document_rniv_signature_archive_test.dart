import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:xml/xml.dart';
import 'package:xml_crypto/xml_crypto.dart';
import 'package:abak_desktop_companion/features/patients/services/document_cda_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_lot_signature_records.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/crypto.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';

/// Only reads are implemented. Any attempted write fails the test.
class _ReadOnlyDatabase implements DatabaseExecutor {
  _ReadOnlyDatabase(this.rows);
  final Map<String, List<Map<String, Object?>>> rows;
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #query) {
      return Future<List<Map<String, Object?>>>.value(
        rows[invocation.positionalArguments.first]!,
      );
    }
    throw StateError('Unexpected database action: ${invocation.memberName}');
  }
}

void main() {
  test('old local signature is authentic in read-only history, rejected for a new signature', () async {
    final old = jsonDecode(
      File('test/fixtures/rniv/legacy_packet.json').readAsStringSync(),
    ) as Map;
    final snapshot = Map<String, dynamic>.from(old['snapshot']);
    final replay = old['package']['wire']['replay'] as Map;
    final cda = base64Decode(replay['cda']);
    final request = <String, Object?>{
      'approvalId': 'synthetic-approval',
      'controlRunId': 'synthetic-controls',
      'approvedAt': replay['approvedAt'],
      'snapshotHash': medicalHash(snapshot),
      'pdfHash': snapshot['version']['sha256'],
      'cdaHash': sha256.convert(cda).toString(),
      'certificate': replay['signingDer'],
      'signedAt': replay['time'],
      'lotOid': replay['lotOid'] ?? replay['identifiers']['lotOid'],
      'signatureOid':
          replay['signatureOid'] ?? replay['identifiers']['signatureOid'],
    };
    final template = DmpWireDraft.lotSignatureTemplate(
      certificate: DmpWireCertificate.parse(request['certificate'] as String),
      cda: cda,
      time: DateTime.parse(request['signedAt'] as String),
      lotOid: request['lotOid'] as String,
      signatureOid: request['signatureOid'] as String,
      documentOid: DocumentCdaBuilder.documentId(snapshot),
    );
    final signature = SignedXml.signatureAlgorithms[DmpWireCrypto.rsa]!
        .getSignature(
          DocumentLotSignatureRecords.signedInfo(template),
          File('test/fixtures/dmp_soap_headers/sign-key.pem').readAsBytesSync(),
        );
    final result = <String, Object?>{
      'request': request,
      'signatureValue': signature,
      'signatureXml': DocumentLotSignatureRecords.finish(
        template,
        request['certificate'] as String,
        signature,
      ),
      'trustAndRevocation': 'not_checked',
      'transmitted': false,
    };
    Map<String, Object?> row(String phase, Map data) => {
      'version_id': snapshot['version']['version_id'],
      'document_id': snapshot['version']['document_id'],
      'phase': phase,
      'data_json': medicalCanonical(data),
      'data_hash': medicalHash(data),
    };
    final db = _ReadOnlyDatabase({
      'document_chain_steps': [
        row(DocumentLotSignatureRecords.started, request),
        row(DocumentLotSignatureRecords.requested, request),
        row(DocumentLotSignatureRecords.completed, result),
      ],
      'document_medical_approvals': [
        {
          'snapshot_json': medicalCanonical(snapshot),
          'snapshot_hash': medicalHash(snapshot),
          'approved_at': replay['approvedAt'],
        },
      ],
      'document_control_runs': [
        {'directory': 'synthetic-run'},
      ],
    });
    final directory = await Directory.systemTemp.createTemp(
      'abak-rniv-archive-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final run = await Directory('${directory.path}/synthetic-run').create();
    await File('${run.path}/document.xml').writeAsBytes(cda);
    expect(
      await DocumentLotSignatureRecords.verifyChain(
        db,
        'synthetic-chain',
        directory,
      ),
      result,
    );
    // The public preparation path never falls back to the historical encoding.
    expect(
      () => DocumentLotSignatureRecords.template(request, snapshot, cda),
      throwsStateError,
    );
    final newCda = DocumentCdaBuilder.build(
      snapshot,
      Uint8List.fromList(
        base64Decode(
          DmpWireCrypto.one(
            DmpWireCrypto.one(
              DmpWireCrypto.parse(utf8.decode(cda)),
              'nonXMLBody',
            ),
            'text',
          ).innerText,
        ),
      ),
      replay['approvedAt'] as int,
    );
    expect(
      DocumentLotSignatureRecords.template(
        {...request, 'cdaHash': sha256.convert(newCda).toString()},
        snapshot,
        newCda,
      ),
      contains('SignedInfo'),
    );
    await File('${run.path}/document.xml').writeAsBytes([...cda, 32]);
    await expectLater(
      DocumentLotSignatureRecords.verifyChain(db, 'synthetic-chain', directory),
      throwsStateError,
    );
  });
}
