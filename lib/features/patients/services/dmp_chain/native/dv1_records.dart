import 'dv1_replacement.dart';
import 'td31b.dart';
import '../contracts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../../dmp_transfer/archive_deposit_reader.dart';
import '../../../../dmp_transfer/transfer_simulation.dart';
import '../../../models/episode_document_version.dart';
import '../../document_medical_service.dart';
import '../../final_pdf_document_service.dart';
import '../wire/package.dart';
import '../wire/crypto.dart';
import 'dv1_configuration.dart';

/// Durable DV1 reservations are separate from synthetic attempts. No method
/// here opens the card, a network session, or retries a request.
class Dv1Records {
  static Future<List<MedicalRow>> reservations(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
  ) => db.rawQuery(
    '''
    SELECT s.* FROM document_chain_steps s JOIN episode_document_versions old ON old.version_id=s.version_id
    WHERE s.phase='dv1_reservation' AND (s.document_id=? OR (old.patient_id=? AND old.sha256=?))
    ORDER BY s.rowid DESC''',
    [v.documentId, v.values['patient_id'], v.digest],
  );

  static String outcome(String messageId, String headers, List<int> bytes) {
    final result = ArchiveDepositReader.readForMessageId(
      requestMessageId: messageId,
      headers: headers,
      bytes: bytes,
    );
    return switch (result.outcome) {
      DepositOutcome.accepted => 'accepted',
      DepositOutcome.rejected ||
      DepositOutcome.metadataRejected ||
      DepositOutcome.signatureRejected => 'rejected',
      _ => 'indeterminate',
    };
  }

  static Map<String, dynamic> data(MedicalRow row) {
    final result =
        jsonDecode(row['data_json'] as String) as Map<String, dynamic>;
    if (medicalHash(result) != row['data_hash']) {
      throw const FormatException('Preuve DV1 altérée.');
    }
    return result;
  }

  /// Recomputes the archived outcome and its bindings, also used during backup.
  /// Historical certificates are checked at the attempt time, not at restore.
  static Future<Map<String, Object?>> verify(
    DatabaseExecutor db,
    MedicalRow reservation, {
    Directory? controlsRoot,
  }) async {
    if (reservation['phase'] != 'dv1_reservation' ||
        reservation['state'] != 'reserved') {
      throw const FormatException('Réservation DV1 invalide.');
    }
    final saved = data(reservation);
    final rows = await db.query(
      'document_chain_steps',
      where: 'chain_id=?',
      whereArgs: [reservation['chain_id']],
      orderBy: 'rowid',
    );
    Future<Map<String, dynamic>> phase(String name) async {
      final matching = rows
          .where((r) => r['phase'] == 'dv1_$name' && r['state'] == 'passed')
          .toList();
      if (matching.length != 1 ||
          matching.single['document_id'] != reservation['document_id'] ||
          matching.single['version_id'] != reservation['version_id']) {
        throw const FormatException('Chaîne DV1 incomplète.');
      }
      return data(matching.single);
    }

    final preparation = await phase('preparation'),
        authentication = await phase('authentication'),
        package = await phase('package'),
        signature = await phase('signature');
    final approval = (await db.query(
      'document_medical_approvals',
      where: 'approval_id=? AND version_id=?',
      whereArgs: [saved['approvalId'], reservation['version_id']],
    )).single;
    final run = (await db.query(
      'document_control_runs',
      where: 'run_id=? AND version_id=?',
      whereArgs: [saved['controlRunId'], reservation['version_id']],
    )).single;
    final config = Dv1Configuration(
      (await db.query(
        'document_dv1_configurations',
        where: 'revision=?',
        whereArgs: [saved['configurationRevision']],
      )).single,
    );
    final native = authentication['native'] as Map;
    final snapshot =
        jsonDecode(approval['snapshot_json'] as String) as Map<String, dynamic>;
    DmpWireDraft.verifyArchived(package, snapshot, authentication);
    final replacement = Dv1Replacement.fromPreparation(
      jsonDecode(snapshot['preparation']['data_json']),
    );
    if (replacement != null) {
      final ancestors = await db.rawQuery(
        "SELECT s.* FROM document_chain_steps s WHERE s.phase='dv1_reservation' AND s.chain_id=? AND s.document_id=? AND s.rowid < (SELECT rowid FROM document_chain_steps WHERE chain_id=? AND phase='dv1_reservation')",
        [
          replacement['attemptId'],
          reservation['document_id'],
          reservation['chain_id'],
        ],
      );
      if (ancestors.length != 1 ||
          ancestors.single['version_id'] != replacement['versionId'] ||
          ancestors.single['data_hash'] != replacement['reservationHash'] ||
          data(ancestors.single)['snapshotHash'] !=
              replacement['snapshotHash'] ||
          (await verify(
                db,
                ancestors.single,
                controlsRoot: controlsRoot,
              ))['outcome'] !=
              'accepted') {
        throw const FormatException(
          'Dépôt initial du remplacement non vérifiable.',
        );
      }
      final search = await phase('replacement_search');
      final ids = DmpNativeTd31b.read(
        search['request'],
        DmpTd02Reply(
          search['httpStatus'],
          search['response'],
          headers: search['headers'],
        ),
      );
      if (medicalHash(search['target']) != medicalHash(replacement) ||
          medicalHash(saved['replacement']) != medicalHash(replacement) ||
          ids.length != 1 ||
          ids.single != package['wire']['replay']['replacementEntryUuid']) {
        throw const FormatException(
          'Recherche et cible de remplacement incohérentes.',
        );
      }
    }
    if (medicalHash(config.data) != config.hash ||
        config.hash != saved['configurationHash'] ||
        preparation['configurationHash'] != config.hash ||
        preparation['scope'] != 'dv1' ||
        preparation['snapshotHash'] != saved['snapshotHash'] ||
        preparation['controlRunId'] != saved['controlRunId'] ||
        approval['snapshot_hash'] != saved['snapshotHash'] ||
        medicalHash(snapshot) != approval['snapshot_hash'] ||
        run['approval_id'] != saved['approvalId'] ||
        preparation['approvalId'] != saved['approvalId'] ||
        saved['attemptId'] != reservation['chain_id'] ||
        package['snapshotHash'] != saved['snapshotHash'] ||
        medicalHash(package) != saved['packageHash'] ||
        package['cdaHash'] != saved['cdaHash'] ||
        package['wire']['replay']['approvedAt'] != approval['approved_at'] ||
        signature['packageHash'] != saved['packageHash'] ||
        signature['certificateHash'] !=
            package['wire']['signingCertificateHash'] ||
        signature['format'] != 'XAdES-1.1.1-RSA-SHA1-SEL-MP-037-2.10' ||
        signature['value'] !=
            DmpWireCrypto.one(
              DmpWireCrypto.parse(package['wire']['signatureXml']),
              'SignatureValue',
            ).innerText ||
        authentication['professional'] != config.professional ||
        native['mutualTls'] != 'true' ||
        native['tdEndpoint'] != Dv1Configuration.td02 ||
        native['depositEndpoint'] != Dv1Configuration.repository ||
        native['trustHash'] != config.resources['trust']['sha256'] ||
        medicalHash(package['wire']['replay']['material']['configuration']) !=
            medicalHash(config.native('/archive/trust.pem').wire.evidence) ||
        authentication['certificateHash'] !=
            config.native('/archive/trust.pem').authenticationHash ||
        signature['certificateHash'] !=
            config.native('/archive/trust.pem').signingHash) {
      throw const FormatException('Liens de la tentative DV1 incohérents.');
    }
    if (controlsRoot != null) {
      final payload = await File(
        p.join(controlsRoot.path, run['directory'] as String, 'document.xml'),
      ).readAsBytes();
      if (FinalPdfDocumentService.hash(payload) != saved['cdaHash']) {
        throw const FormatException('CDA de la tentative modifié.');
      }
    }
    final responses = rows.where((r) => r['phase'] == 'dv1_response').toList();
    var state = 'indeterminate';
    var detail =
        'Tentative réservée sans réponse certaine. Examen nécessaire ; renvoi bloqué.';
    if (responses.length > 1) {
      throw const FormatException('Réponses DV1 multiples.');
    }
    if (responses.isNotEmpty) {
      final response = data(responses.single);
      if (responses.single['state'] != 'result' ||
          responses.single['version_id'] != reservation['version_id'] ||
          response['attemptId'] != saved['attemptId'] ||
          response['scope'] != 'dv1') {
        throw const FormatException('Réponse DV1 non corrélée.');
      }
      if (response['response'] != null) {
        state = outcome(
          package['messageId'],
          response['headers'],
          base64Decode(response['response']),
        );
        if (response['packageHash'] != saved['packageHash'] ||
            response['request'] != package['request']) {
          throw const FormatException('Réponse rattachée à un autre paquet.');
        }
      }
      if (state != response['outcome']) {
        throw const FormatException('Résultat DV1 non vérifiable.');
      }
      detail = response['detail'] as String;
    }
    return {
      'attempt_id': saved['attemptId'],
      'version_id': reservation['version_id'],
      'mode': 'dv1',
      'outcome': state,
      'detail': detail,
    };
  }
}
