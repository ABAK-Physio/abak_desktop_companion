import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dmp_chain/wire/crypto.dart';
import 'dmp_chain/wire/package.dart';
import 'document_cda_builder.dart';
import 'cnda_patient_recipe.dart';
import 'document_medical_service.dart';
import 'final_pdf_document_service.dart';

/// Signature of a CDA lot only. No invented authentication session, VIHF,
/// transport authorization or certificate trust/revocation assertion.
class DocumentLotSignatureRecords {
  static const started = 'local_cps_started';
  static const requested = 'local_cps_requested';
  static const completed = 'local_cps_completed';
  static const failed = 'local_cps_failed';
  static const phases = [started, requested, completed, failed];

  static Map<String, dynamic> data(MedicalRow row) {
    final value = jsonDecode(row['data_json'] as String);
    if (value is! Map<String, dynamic> ||
        medicalHash(value) != row['data_hash']) {
      throw const FormatException('Preuve de signature altérée.');
    }
    return value;
  }

  static void context(Map snapshot) {
    CndaPatientRecipe.checkDocument(snapshot);
    final prep = jsonDecode(snapshot['preparation']['data_json']);
    final practice = jsonDecode(snapshot['practice']['data_json']);
    if (prep['authorId'] != prep['validatorId'] ||
        practice['professionCode'] != 'G15_70' ||
        practice['professionSystem'] != '1.2.250.1.213.1.1.4.5' ||
        practice['setting'] != 'Ambulatoire' ||
        (practice['replacementFor'] ?? '') != '' ||
        snapshot['identity']['ins_oid'] != '1.2.250.1.213.1.4.10') {
      throw StateError(
        'Signature locale réservée à l’auteur kiné validateur, en exercice direct ambulatoire, avec identité qualifiée.',
      );
    }
  }

  static String template(Map evidence, Map snapshot, List<int> cda) {
    context(snapshot);
    final cert = DmpWireCertificate.parse(evidence['certificate'] as String);
    final time = DateTime.parse(evidence['signedAt'] as String).toUtc();
    final practice = jsonDecode(snapshot['practice']['data_json']);
    if (time.millisecondsSinceEpoch < (evidence['approvedAt'] as int) ||
        cert.commonName != practice['identifier'] ||
        !cert.contentCommitment ||
        time.isBefore(cert.validFrom) ||
        !time.isBefore(cert.validUntil)) {
      throw StateError(
        'Certificat de signature incompatible avec le signataire ou la date.',
      );
    }
    if (cda.length > 30 * 1024 * 1024 ||
        FinalPdfDocumentService.hash(cda) != evidence['cdaHash'] ||
        snapshot['version']['sha256'] != evidence['pdfHash'] ||
        medicalHash(snapshot) != evidence['snapshotHash']) {
      throw StateError('Le lot ne correspond plus au contenu validé.');
    }
    final xml = DmpWireCrypto.parse(utf8.decode(cda));
    final body = DmpWireCrypto.one(
      DmpWireCrypto.one(xml, 'nonXMLBody'),
      'text',
    );
    final pdf = base64Decode(body.innerText);
    if (FinalPdfDocumentService.hash(pdf) != evidence['pdfHash'] ||
        FinalPdfDocumentService.hash(
              DocumentCdaBuilder.build(
                Map<String, dynamic>.from(snapshot),
                Uint8List.fromList(pdf),
                evidence['approvedAt'] as int,
              ),
            ) !=
            evidence['cdaHash']) {
      throw StateError('Le CDA ou son PDF diffère de la validation médicale.');
    }
    return DmpWireDraft.lotSignatureTemplate(
      certificate: cert,
      cda: cda,
      time: time,
      lotOid: evidence['lotOid'] as String,
      signatureOid: evidence['signatureOid'] as String,
      documentOid: DocumentCdaBuilder.documentId(
        Map<String, dynamic>.from(snapshot),
      ),
    );
  }

  static String signedInfo(String xml) => DmpWireCrypto.canonical(
    DmpWireCrypto.one(DmpWireCrypto.parse(xml), 'SignedInfo'),
  );

  static String finish(String template, String certificate, String value) {
    if (!DmpWireCrypto.verify(
      signedInfo(template),
      DmpWireCertificate.parse(certificate),
      value,
    )) {
      throw StateError('La signature du lot ne peut pas être vérifiée.');
    }
    final xml = DmpWireCrypto.parse(template);
    DmpWireCrypto.one(xml, 'SignatureValue').innerText = value;
    return xml.toXmlString();
  }

  /// Re-read a complete or interrupted operation without contacting the CPS.
  /// Historical approvals may have been invalidated: authenticity of the
  /// archived evidence and usability for a current preparation are separate.
  static Future<Map<String, dynamic>?> verifyChain(
    DatabaseExecutor db,
    String chainId,
    Directory controlsRoot,
  ) async {
    final rows = await db.query(
      'document_chain_steps',
      where: 'chain_id=?',
      whereArgs: [chainId],
      orderBy: 'rowid',
    );
    final begin = rows.where((r) => r['phase'] == started).single;
    final initial = data(begin);
    if (rows.any(
      (r) =>
          !phases.contains(r['phase']) ||
          r['version_id'] != begin['version_id'] ||
          r['document_id'] != begin['document_id'],
    )) {
      throw const FormatException('Journal de signature incohérent.');
    }
    for (final r in rows) {
      data(r);
    }
    final requests = rows.where((r) => r['phase'] == requested).toList();
    final results = rows.where((r) => r['phase'] == completed).toList();
    final failures = rows.where((r) => r['phase'] == failed).toList();
    if (requests.length > 1 ||
        results.length + failures.length > 1 ||
        (results.isNotEmpty && requests.length != 1) ||
        (requests.isNotEmpty && rows.indexOf(requests.single) == 0) ||
        (results.isNotEmpty && rows.last != results.single) ||
        (failures.isNotEmpty && rows.last != failures.single)) {
      throw const FormatException('Séquence de signature incohérente.');
    }
    if (failures.isNotEmpty &&
        data(failures.single)['signatureRequested'] != requests.isNotEmpty) {
      throw const FormatException('État de signature incertain.');
    }
    final approval = (await db.query(
      'document_medical_approvals',
      where: 'approval_id=? AND version_id=?',
      whereArgs: [initial['approvalId'], begin['version_id']],
    )).single;
    final snapshot = jsonDecode(approval['snapshot_json'] as String);
    final run = (await db.query(
      'document_control_runs',
      where: 'run_id=? AND approval_id=? AND version_id=?',
      whereArgs: [
        initial['controlRunId'],
        initial['approvalId'],
        begin['version_id'],
      ],
    )).single;
    if (medicalHash(snapshot) != initial['snapshotHash'] ||
        approval['snapshot_hash'] != initial['snapshotHash'] ||
        approval['approved_at'] != initial['approvedAt'] ||
        snapshot['version']['sha256'] != initial['pdfHash'] ||
        snapshot['version']['document_id'] != begin['document_id']) {
      throw const FormatException('Rattachement de signature incohérent.');
    }
    if (requests.isEmpty) return null;
    final request = data(requests.single);
    if (initial.entries.any((e) => request[e.key] != e.value)) {
      throw const FormatException(
        'Préparation remplacée pendant la signature.',
      );
    }
    final directory = run['directory'] as String;
    if (directory != p.basename(directory) ||
        directory == '.' ||
        directory == '..') {
      throw const FormatException('Dossier de contrôle invalide.');
    }
    final file = File(p.join(controlsRoot.path, directory, 'document.xml'));
    if (!p.isWithin(
      await controlsRoot.resolveSymbolicLinks(),
      await file.resolveSymbolicLinks(),
    )) {
      throw const FormatException('Preuve hors stockage géré.');
    }
    final xml = template(request, snapshot, await file.readAsBytes());
    if (results.isEmpty) return null;
    final result = data(results.single);
    if (medicalHash(result['request']) != medicalHash(request) ||
        finish(xml, request['certificate'], result['signatureValue']) !=
            result['signatureXml'] ||
        result['trustAndRevocation'] != 'not_checked' ||
        result['transmitted'] != false) {
      throw const FormatException('Preuve de signature non vérifiable.');
    }
    return result;
  }
}
