import 'dart:convert';
import 'package:xml/xml.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../dmp_transfer/archive_deposit_reader.dart';
import '../../dmp_transfer/transfer_simulation.dart';
import 'document_medical_service.dart';
import 'dmp_chain/wire/package.dart';
import 'dmp_chain/wire/crypto.dart';

/// No transport or hardware dependency. The same verifier is used for display,
/// confirmation and backup/restore. A local archive is never a live DMP receipt.
class DocumentReconciliationRecords {
  static String key(String versionId, String? attemptId) =>
      attemptId == null ? 'version:$versionId' : 'attempt:$attemptId';

  static Future<MedicalRow> binding(
    DatabaseExecutor db,
    String versionId,
    String? attemptId,
  ) async {
    final version = (await db.query(
      'episode_document_versions',
      where: 'version_id=?',
      whereArgs: [versionId],
    )).single;
    if (attemptId == null) return {'version': version, 'attempt': null};
    final attempt = (await db.query(
      'document_attempts',
      where: 'attempt_id=?',
      whereArgs: [attemptId],
    )).single;
    if (attempt['version_id'] != versionId ||
        attempt['document_id'] != version['document_id'] ||
        attempt['patient_id'] != version['patient_id'] ||
        attempt['pdf_hash'] != version['sha256'] ||
        attempt['mode'] != 'simulation') {
      throw const FormatException('Tentative et copie figée incohérentes');
    }
    final approvals = await db.query(
      'document_medical_approvals',
      where: 'approval_id=?',
      whereArgs: [attempt['approval_id']],
    );
    final runs = await db.query(
      'document_control_runs',
      where: 'run_id=?',
      whereArgs: [attempt['control_run_id']],
    );
    final steps = await db.query(
      'document_chain_steps',
      where:
          "version_id=? AND (state='reserved' OR (state='passed' AND phase IN ('package','signature','authentication')))",
      whereArgs: [versionId],
      orderBy: 'rowid',
    );
    return {
      'version': version,
      'attempt': attempt,
      'approvals': approvals,
      'runs': runs,
      'steps': steps,
    };
  }

  /// Returns a MessageID only after reconstructing the signed packet and all
  /// its bindings. Never take the request ID from the newly imported archive.
  static String? requestId(MedicalRow binding) {
    final attempt = binding['attempt'] as Map?;
    if (attempt == null) return null;
    final approvals = binding['approvals'] as List,
        runs = binding['runs'] as List;
    if (approvals.length != 1 || runs.length != 1) return null;
    final approval = approvals.single as Map, run = runs.single as Map;
    final snapshot =
        jsonDecode(approval['snapshot_json'] as String) as Map<String, dynamic>;
    if (medicalHash(snapshot) != attempt['snapshot_hash'] ||
        approval['snapshot_hash'] != attempt['snapshot_hash'] ||
        approval['version_id'] != attempt['version_id'] ||
        run['approval_id'] != attempt['approval_id'] ||
        run['version_id'] != attempt['version_id']) {
      throw const FormatException('Validation et tentative incohérentes');
    }
    final steps = (binding['steps'] as List).cast<Map>();
    for (final row in steps) {
      if (medicalHash(jsonDecode(row['data_json'] as String)) !=
          row['data_hash']) {
        throw const FormatException('Preuve de chaîne altérée');
      }
    }
    final reservations = steps
        .where(
          (e) =>
              e['state'] == 'reserved' &&
              jsonDecode(e['data_json'] as String)['attemptId'] ==
                  attempt['attempt_id'],
        )
        .toList();
    if (reservations.length != 1) return null;
    final reservation = reservations.single;
    Map<String, dynamic>? phase(String name) {
      final rows = steps
          .where(
            (s) =>
                s['chain_id'] == reservation['chain_id'] &&
                s['phase'] == name &&
                s['state'] == 'passed',
          )
          .toList();
      return rows.length == 1
          ? jsonDecode(rows.single['data_json'] as String)
          : null;
    }

    final package = phase('package'),
        signature = phase('signature'),
        authentication = phase('authentication');
    if (package == null ||
        signature == null ||
        authentication == null ||
        package['wire'] == null) {
      return null;
    }
    final data = jsonDecode(reservation['data_json'] as String);
    DmpWireDraft.verifyArchived(package, snapshot, authentication);
    if (package['wire']['replay']['approvedAt'] != approval['approved_at'] ||
        medicalHash(package) != data['packageHash'] ||
        signature['packageHash'] != data['packageHash'] ||
        signature['certificateHash'] !=
            package['wire']['signingCertificateHash'] ||
        signature['value'] !=
            DmpWireCrypto.one(
              DmpWireCrypto.parse(package['wire']['signatureXml']),
              'SignatureValue',
            ).innerText ||
        signature['format'] != 'XAdES-1.1.1-RSA-SHA1-SEL-MP-037-2.10' ||
        package['sessionHash'] != medicalHash(authentication) ||
        package['snapshotHash'] != attempt['snapshot_hash'] ||
        package['cdaHash'] != attempt['payload_hash']) {
      throw const FormatException('Paquet signé différent de la tentative');
    }
    return package['messageId'] as String;
  }

  static MedicalRow assess(MedicalRow binding, MedicalRow source) {
    MedicalRow unknown(String detail) => {
      'outcome': 'indeterminate',
      'detail': detail,
    };
    if (binding['attempt'] == null) {
      return unknown(
        'Restauration sans tentative retrouvée : absence de preuve, aucun renvoi autorisé.',
      );
    }
    String? id;
    try {
      id = requestId(binding);
    } catch (_) {
      return unknown(
        'Preuves de la tentative incohérentes : résultat non vérifié.',
      );
    }
    if (id == null) {
      return unknown(
        'Paquet signé de la tentative incomplet : résultat non vérifié.',
      );
    }
    if (source['body'] == null || source['headers'] == null) {
      return unknown(
        'Aucune réponse archivée disponible : résultat indéterminé.',
      );
    }
    try {
      final headers = source['headers'] as String,
          bytes = base64Decode(source['body'] as String);
      // A single final HTTP response with a complete archived body is required.
      // Reject transfer-encoded archives; the export must contain decoded bytes.
      if (headers.length > 32768 ||
          bytes.length > 2 * 1024 * 1024 ||
          !RegExp(
            r'^HTTP/[12](?:\.[01])? [1-5][0-9]{2}(?: [^\r\n]*)?\r?\n',
          ).hasMatch(headers) ||
          RegExp(r'^HTTP/', multiLine: true).allMatches(headers).length != 1 ||
          headers.contains('\u0000') ||
          headers
              .split(RegExp(r'\r?\n'))
              .any((line) => line.startsWith(' ') || line.startsWith('\t')) ||
          ArchiveDepositReader.header(headers, 'transfer-encoding') != null ||
          ArchiveDepositReader.header(headers, 'content-encoding') != null) {
        return unknown(
          'En-têtes archivés ambigus ou incomplets : résultat non vérifié.',
        );
      }
      final length = ArchiveDepositReader.header(headers, 'content-length');
      if (length == null ||
          !RegExp(r'^[0-9]+$').hasMatch(length) ||
          int.parse(length) != bytes.length) {
        return unknown('Réponse archivée tronquée ou longueur non vérifiée.');
      }
      final r = ArchiveDepositReader.readForMessageId(
        requestMessageId: id,
        headers: headers,
        bytes: bytes,
      );
      return switch (r.outcome) {
        DepositOutcome.accepted => {
          'outcome': 'accepted',
          'detail': 'Archive corrélée : dépôt accepté dans le scénario simulé.',
        },
        DepositOutcome.signatureRejected => {
          'outcome': 'rejected',
          'detail':
              'Archive corrélée : signature rejetée dans le scénario simulé.',
        },
        DepositOutcome.metadataRejected => {
          'outcome': 'rejected',
          'detail':
              'Archive corrélée : métadonnées rejetées dans le scénario simulé.',
        },
        DepositOutcome.rejected => {
          'outcome': 'rejected',
          'detail': 'Archive corrélée : dépôt rejeté dans le scénario simulé.',
        },
        _ => unknown(
          'Archive non concluante (corrélation, réponse SOAP ou statut) : résultat indéterminé.',
        ),
      };
    } catch (_) {
      return unknown('Réponse archivée illisible : résultat non vérifié.');
    }
  }

  static Future<List<MedicalRow>> barriers(DatabaseExecutor db) =>
      db.query('document_restore_barriers', orderBy: 'rowid');
  static Future<List<MedicalRow>> rows(DatabaseExecutor db, String target) =>
      db.query(
        'document_reconciliations',
        where: 'target_key=?',
        whereArgs: [target],
        orderBy: 'rowid',
      );

  /// Replay every observation, including its predecessor and restore history.
  /// Hashes alone are insufficient: recompute the decision from the raw bytes.
  static Future<List<MedicalRow>> verifyTarget(
    DatabaseExecutor db,
    String target,
  ) async {
    final records = await rows(db, target), restore = await barriers(db);
    var previous = '';
    for (final row in records) {
      final evidence =
          jsonDecode(row['evidence_json'] as String) as Map<String, dynamic>;
      final baseline = await binding(
        db,
        row['version_id'] as String,
        row['attempt_id'] as String?,
      );
      final savedBarriers = evidence['barriers'] as List;
      final source = Map<String, Object?>.from(evidence['source'] as Map);
      final decision = assess(baseline, source);
      if (evidence['schema'] != 1 ||
          evidence['scope'] != 'isolated-simulation' ||
          evidence['reviewId'] != row['review_id'] ||
          evidence['reviewedAt'] != row['reviewed_at'] ||
          evidence['target'] != target ||
          key(row['version_id'] as String, row['attempt_id'] as String?) !=
              target ||
          (baseline['version'] as Map)['document_id'] != row['document_id'] ||
          evidence['bindingHash'] != medicalHash(baseline) ||
          savedBarriers.length > restore.length ||
          medicalCanonical(savedBarriers) !=
              medicalCanonical(restore.take(savedBarriers.length).toList()) ||
          row['restore_hash'] != medicalHash(savedBarriers) ||
          row['source_hash'] != medicalHash(source) ||
          evidence['previousHash'] != previous ||
          row['previous_hash'] != previous ||
          row['evidence_hash'] != medicalHash(evidence) ||
          medicalCanonical(evidence['decision']) !=
              medicalCanonical(decision) ||
          row['outcome'] != decision['outcome'] ||
          row['detail'] != '${decision['detail']} Renvoi bloqué.' ||
          (row['attempt_id'] == null && savedBarriers.isEmpty)) {
        throw const FormatException(
          'Preuve de réconciliation incohérente ou altérée',
        );
      }
      final events = await db.query(
        'document_events',
        where: "kind='reconciliation' AND reference_id=?",
        whereArgs: [row['review_id']],
      );
      if (events.length != 1 ||
          events.single['document_id'] != row['document_id'] ||
          events.single['version_id'] != row['version_id'] ||
          events.single['detail'] != row['detail'] ||
          events.single['created_at'] != row['reviewed_at']) {
        throw const FormatException('Réconciliation absente du journal commun');
      }
      previous = row['evidence_hash'] as String;
    }
    return records;
  }

  static Future<void> validateAll(DatabaseExecutor db) async {
    for (final row in await db.rawQuery(
      'SELECT DISTINCT target_key FROM document_reconciliations',
    )) {
      await verifyTarget(db, row['target_key'] as String);
    }
    if ((await db.rawQuery(
      "SELECT e.event_id FROM document_events e LEFT JOIN document_reconciliations r ON e.reference_id=r.review_id WHERE e.kind='reconciliation' AND r.review_id IS NULL",
    )).isNotEmpty) {
      throw const FormatException('Observation de réconciliation manquante');
    }
  }

  static Future<MedicalRow> summary(
    DatabaseExecutor db,
    String versionId,
    String? attemptId,
    String initial,
  ) async {
    try {
      final records = await verifyTarget(db, key(versionId, attemptId));
      if (records.isEmpty) return {'state': initial, 'message': ''};
      final archivedOutcomes = records
          .map((r) => r['outcome'])
          .where((o) => o == 'accepted' || o == 'rejected')
          .toSet();
      final outcomes = {
        if (initial == 'accepted' || initial == 'rejected') initial,
        ...archivedOutcomes,
      };
      final state = outcomes.length > 1
          ? 'conflict'
          : outcomes.isEmpty
          ? initial
          : outcomes.single as String;
      final currentRestore =
          medicalHash(await barriers(db)) == records.last['restore_hash'];
      final label =
          archivedOutcomes.isEmpty && {'accepted', 'rejected'}.contains(initial)
          ? 'Réconciliation non concluante : résultat initial ${initial == 'accepted' ? 'accepté' : 'rejeté'} conservé.'
          : switch (state) {
              'accepted' =>
                'Réconciliation locale : acceptation retrouvée dans les archives de simulation.',
              'rejected' =>
                'Réconciliation locale : rejet retrouvé dans les archives de simulation.',
              'conflict' =>
                'Archives contradictoires : résultat en conflit, examen nécessaire.',
              _ =>
                'Réconciliation non concluante : résultat toujours indéterminé.',
            };
      return {
        'state': state,
        'message':
            '$label Renvoi bloqué.${currentRestore ? '' : ' Nouvelle restauration : nouvel examen nécessaire.'} Aucun dépôt réel attesté.',
      };
    } catch (_) {
      return {
        'state': 'indeterminate',
        'message':
            'Preuve de réconciliation non vérifiable. Renvoi bloqué ; examen nécessaire.',
      };
    }
  }
}
