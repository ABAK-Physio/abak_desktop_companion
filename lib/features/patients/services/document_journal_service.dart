import 'dmp_chain/native/dv1_replacement.dart';
import '../../dmp_setup/dmp_setup_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../../dmp_transfer/archive_deposit_reader.dart';
import '../../dmp_transfer/transfer_simulation.dart';
import '../models/episode_document_version.dart';
import 'document_controls_service.dart';
import 'dmp_chain/native/dv1_records.dart';
import 'dmp_chain/native/dv1_retry.dart';
import 'document_medical_service.dart';
import 'document_reconciliation_records.dart';
import 'final_pdf_document_service.dart';

/// Closed local test double. There is deliberately no URL, CPS or network API.
final class DocumentLocalSimulation {
  DocumentLocalSimulation({
    required this.directory,
    this.outcome = 'accepted',
    this.request,
    this.headers,
    List<int>? response,
    this.beforeResult,
  }) : response = response == null ? null : List<int>.unmodifiable(response);
  final Directory directory;
  final String outcome;
  final String? request, headers;
  final List<int>? response;
  final Future<void> Function()? beforeResult;
  int calls = 0;
  Future<void> checkScope(Database db, Directory pdfRoot) async {
    await File(
      p.join(directory.path, 'J4-SYNTHETIC-ONLY'),
    ).readAsString().then((s) {
      if (s != 'ABAK-J4-SYNTHETIC') throw StateError('Stockage de test requis');
    });
    final root = await directory.resolveSymbolicLinks();
    if (!p.isWithin(root, await File(db.path).resolveSymbolicLinks()) ||
        !p.isWithin(root, await pdfRoot.resolveSymbolicLinks())) {
      throw StateError('Simulation réservée au stockage isolé');
    }
  }

  Future<Map<String, Object?>> execute() async {
    calls++;
    await beforeResult?.call();
    if (response != null) {
      final r = ArchiveDepositReader.read(
        request: request ?? '',
        headers: headers ?? '',
        bytes: response!,
      );
      return {
        'outcome': switch (r.outcome) {
          DepositOutcome.accepted => 'accepted',
          DepositOutcome.rejected ||
          DepositOutcome.signatureRejected ||
          DepositOutcome.metadataRejected => 'rejected',
          _ => 'indeterminate',
        },
        'detail': r.detail,
        'kind': 'archive',
        'request': request,
        'headers': headers,
        'response': base64Encode(response!),
        'scope':
            'Relecture locale ; aucune preuve de dépôt de ce PDF sur le DMP',
      };
    }
    return {
      'outcome': ['accepted', 'rejected', 'indeterminate'].contains(outcome)
          ? outcome
          : 'indeterminate',
      'detail': 'Résultat du service fictif : $outcome',
      'kind': 'simulation',
    };
  }
}

class DocumentJournalStatus {
  const DocumentJournalStatus(
    this.state,
    this.message, {
    this.held = true,
    this.revision = 0,
    this.attempt,
    this.reconciliation = '',
  });
  final String state, message, reconciliation;
  final bool held;
  final int revision;
  final MedicalRow? attempt;
  bool get canChangeHold => attempt == null && state != 'restored';
}

class DocumentAttemptPreparation {
  DocumentAttemptPreparation(
    Map<String, Object?> run,
    Map<String, Object?> result,
    Map<String, Object?> receipt,
    List<int> payload,
    this.payloadHash,
  ) : run = Map.unmodifiable(run),
      result = Map.unmodifiable(result),
      receipt = Map.unmodifiable(receipt),
      payload = List.unmodifiable(payload);
  final MedicalRow run, result, receipt;
  final List<int> payload;
  final String payloadHash;
}

class DocumentJournalService {
  DocumentJournalService({required this.controls, this.checkpoint});
  final DocumentControlsService controls;
  final Future<void> Function(String)? checkpoint;
  DocumentMedicalService get medical => controls.medical;
  Future<Database> get database => medical.pdf.database();
  static Future<void> suspendAfterRestore(
    DatabaseExecutor db,
    String id,
  ) async {
    await db.insert('document_restore_barriers', {
      'barrier_id': id,
      'reason':
          'Restauration : préparations suspendues. Réconciliation nécessaire avant tout traitement ; aucun renvoi automatique.',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<MedicalRow>> history(String documentId) async =>
      (await database).rawQuery(
        '''SELECT e.*, v.sequence_number AS version_number
        FROM document_events e
        LEFT JOIN episode_document_versions v
          ON v.version_id=e.version_id AND v.document_id=e.document_id
        WHERE e.document_id=? OR e.document_id IS NULL
        ORDER BY e.event_id DESC''',
        [documentId],
      );
  Future<DocumentJournalStatus> _state(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
  ) async {
    final held = await db.query(
      'document_holds',
      where: 'version_id=?',
      whereArgs: [v.id],
    );
    final hold = held.isEmpty ? true : held.single['held'] == 1,
        rev = held.isEmpty ? 0 : held.single['revision'] as int;
    final attempts = await db.rawQuery(
      '''SELECT a.*,r.outcome,r.detail,r.evidence_json,r.evidence_hash
      FROM document_attempts a LEFT JOIN document_attempt_results r ON r.attempt_id=a.attempt_id
      WHERE a.document_id=? OR (a.patient_id=? AND a.pdf_hash=?) ORDER BY a.rowid DESC''',
      [v.documentId, v.values['patient_id'], v.digest],
    );
    final restored = (await db.query(
      'document_restore_barriers',
      limit: 1,
    )).isNotEmpty;
    final dv1 = await Dv1Records.reservations(db, v);
    var replacing = false;
    try {
      replacing = await Dv1Replacement.check(db, v) != null;
    } catch (_) {
      // Invalid or stale intent never relaxes the existing deposit barrier.
    }
    if (dv1.isNotEmpty && !replacing) {
      MedicalRow result;
      try {
        result = await Dv1Records.verify(db, dv1.first);
      } catch (_) {
        result = {
          'mode': 'dv1',
          'attempt_id': dv1.first['chain_id'],
          'version_id': dv1.first['version_id'],
          'outcome': 'indeterminate',
          'detail':
              'Preuves DV1 incomplètes ou non vérifiables. Examen nécessaire.',
        };
      }
      final outcome = result['outcome'] as String;
      final label = switch (outcome) {
        'accepted' => 'Dépôt accepté sur DV1',
        'rejected' => 'Dépôt rejeté sur DV1',
        _ => 'Résultat du dépôt DV1 indéterminé',
      };
      return DocumentJournalStatus(
        outcome,
        '${result['version_id'] != v.id ? 'Tentative d’une version antérieure. ' : ''}$label. Renvoi bloqué pour cette pièce et son contenu.${restored ? ' Verrou de restauration conservé.' : ''}',
        held: hold,
        revision: rev,
        attempt: result,
      );
    }
    if (attempts.isNotEmpty) {
      final a = attempts.first;
      final outcome = a['outcome'] as String? ?? 'indeterminate';
      final evidence = a['evidence_json'];
      var valid = evidence == null;
      if (evidence != null) {
        try {
          final decoded = jsonDecode(evidence as String);
          valid =
              medicalHash(decoded) == a['evidence_hash'] &&
              decoded['outcome'] == outcome;
        } catch (_) {
          valid = false;
        }
      }
      final reconciliation = valid
          ? await DocumentReconciliationRecords.summary(
              db,
              a['version_id'] as String,
              a['attempt_id'] as String,
              outcome,
            )
          : <String, Object?>{
              'state': 'indeterminate',
              'message':
                  'Résultat initial non vérifiable. Renvoi bloqué ; examen nécessaire.',
            };
      final state = reconciliation['state'] as String;
      final label = switch (state) {
        'accepted' => 'Accepté en simulation',
        'rejected' => 'Rejeté en simulation',
        'conflict' => 'Résultats contradictoires ; vérification nécessaire',
        _ => 'Résultat indéterminé ; vérification nécessaire',
      };
      return DocumentJournalStatus(
        state,
        '${a['version_id'] != v.id ? 'Résultat de la tentative antérieure. ' : ''}$label. Renvoi bloqué pour cette pièce et son contenu.${restored ? ' Verrou de restauration conservé.' : ''}',
        held: hold,
        revision: rev,
        attempt: a,
        reconciliation: reconciliation['message'] as String,
      );
    }
    if (restored) {
      final reconciliation = await DocumentReconciliationRecords.summary(
        db,
        v.id,
        null,
        'restored',
      );
      return DocumentJournalStatus(
        'restored',
        'Restauration : traitement suspendu, aucun renvoi. L’absence de tentative dans une sauvegarde ne prouve pas l’absence de dépôt.',
        reconciliation: reconciliation['message'] as String,
        held: hold,
        revision: rev,
      );
    }
    final chain = await db.query(
      'document_chain_steps',
      where: 'version_id=?',
      whereArgs: [v.id],
      orderBy: 'rowid DESC',
      limit: 1,
    );
    if (chain.isNotEmpty) {
      final last = chain.single;
      final valid =
          medicalHash(jsonDecode(last['data_json'] as String)) ==
          last['data_hash'];
      final detail = valid
          ? last['detail'] as String
          : 'Preuve de chaîne altérée.';
      if ((last['phase'] as String).startsWith('dv1_')) {
        final failures = await db.query(
          'document_chain_steps',
          where: 'chain_id=? AND state=?',
          whereArgs: [last['chain_id'], 'blocked'],
          orderBy: 'rowid DESC',
          limit: 1,
        );
        final failed = failures.isNotEmpty;
        final dv1Detail = failed ? failures.single['detail'] : detail;
        final access =
            last['phase'] == 'dv1_session_close' &&
            (await db.query(
              'document_chain_steps',
              where: 'chain_id=? AND phase=? AND state=?',
              whereArgs: [last['chain_id'], 'dv1_access_checked', 'passed'],
            )).isNotEmpty;
        return DocumentJournalStatus(
          failed ? 'chain_blocked' : 'dv1_prepared',
          '${hold ? 'Traitement retenu. ' : ''}${access && !failed ? 'Accès TD0.2 vérifié sur DV1 ; aucun document déposé. ' : ''}$dv1Detail',
          held: hold,
          revision: rev,
        );
      }
      if ((last['phase'] as String).startsWith('local_cps_')) {
        return DocumentJournalStatus(
          last['state'] == 'blocked' ? 'chain_blocked' : 'local_signature',
          '${hold ? 'Traitement retenu. ' : ''}$detail Le dépôt exige une action distincte et une session DV1 vérifiée.',
          held: hold,
          revision: rev,
        );
      }
      return DocumentJournalStatus(
        last['state'] == 'blocked' ? 'chain_blocked' : 'chain_pending',
        '${hold ? 'Traitement retenu. ' : ''}$detail ${last['state'] == 'blocked' ? '' : 'Préparation inachevée ; nouveaux contrôles nécessaires. '}Aucun envoi réel. Les étapes préalables ne valent pas autorisation de dépôt.',
        held: hold,
        revision: rev,
      );
    }
    return DocumentJournalStatus(
      hold ? 'held' : 'released',
      hold
          ? 'Traitement retenu. Aucun envoi.'
          : 'Retenue levée. Aucun envoi automatique.',
      held: hold,
      revision: rev,
    );
  }

  Future<DocumentJournalStatus> status(EpisodeDocumentVersion v) async =>
      _state(await database, v);
  Future<void> hold(
    EpisodeDocumentVersion v,
    bool held, {
    required int expectedRevision,
  }) async {
    final db = await database;
    // A retained historical version cannot be released through a stale screen.
    await medical.pdf.verifiedFile(v);
    await db.transaction((tx) async {
      final s = await _state(tx, v);
      if (!s.canChangeHold || s.revision != expectedRevision) {
        throw StateError(
          'État modifié ou renvoi bloqué. Rechargez la préparation.',
        );
      }
      final row = {
        'version_id': v.id,
        'held': held ? 1 : 0,
        'revision': expectedRevision + 1,
        'changed_at': medical.now().millisecondsSinceEpoch,
      };
      if (expectedRevision == 0) {
        await tx.insert('document_holds', row);
      } else {
        await tx.update(
          'document_holds',
          row,
          where: 'version_id=?',
          whereArgs: [v.id],
        );
      }
    });
  }

  /// Captures current medical and technical receipts without reserving a send.
  Future<DocumentAttemptPreparation> prepare(
    EpisodeDocumentVersion v, {
    Dv1RetryReview? retry,
  }) async {
    final db = await database;
    await DmpSetupService.requireNotDisabled(db);
    await Dv1Replacement.check(db, v);
    final checks = await controls.status(v, retry: retry);
    if (checks.pdfa != 'conforme' ||
        checks.cda != 'conforme' ||
        checks.run == null) {
      throw StateError(
        'Contrôles conformes et validation courante requis. ${checks.message}',
      );
    }
    final run = checks.run!;
    final payload = File(
      p.join(
        (await controls.root).path,
        run['directory'] as String,
        'document.xml',
      ),
    );
    final payloadHash = FinalPdfDocumentService.hash(
      await payload.readAsBytes(),
    );
    final receipt = await db.transaction(
      (tx) => retry == null
          ? medical.approvedCapture(tx, v)
          : retry.capture(medical, tx, v),
    );
    if (receipt['approval_id'] != run['approval_id']) {
      throw StateError('Validation remplacée pendant la préparation.');
    }
    return DocumentAttemptPreparation(
      run,
      Map<String, Object?>.from(checks.result!),
      receipt,
      await payload.readAsBytes(),
      payloadHash,
    );
  }

  Future<String> reserve(
    EpisodeDocumentVersion v,
    DocumentAttemptPreparation prepared, {
    Future<void> Function(DatabaseExecutor, String)? record,
  }) => _reserve(v, prepared, record: record);

  Future<String> reserveDv1(
    EpisodeDocumentVersion v,
    DocumentAttemptPreparation prepared, {
    required String chainId,
    Dv1RetryReview? retry,
    required Future<void> Function(DatabaseExecutor, String) record,
  }) =>
      _reserve(v, prepared, record: record, dv1ChainId: chainId, retry: retry);

  Future<String> _reserve(
    EpisodeDocumentVersion v,
    DocumentAttemptPreparation prepared, {
    Future<void> Function(DatabaseExecutor, String)? record,
    String? dv1ChainId,
    Dv1RetryReview? retry,
  }) async {
    final db = await database;
    final run = prepared.run;
    final payloadHash = prepared.payloadHash;
    final id = dv1ChainId ?? const Uuid().v4();
    await checkpoint?.call('before_reservation');
    await db.transaction((tx) async {
      final state = await _state(tx, v);
      if (state.held ||
          (state.attempt != null && retry == null) ||
          state.state == 'restored') {
        throw StateError('Traitement bloqué avant réservation.');
      }
      final replacement = await Dv1Replacement.check(tx, v);
      if (replacement != null && dv1ChainId == null) {
        throw StateError('Remplacement réservé au parcours DV1 explicite.');
      }
      if (retry != null) {
        if (dv1ChainId == null) {
          throw StateError('Reprise interdite en simulation.');
        }
        await Dv1Retry.recheck(tx, v, await controls.root, retry);
        retry.checkPreparation(
          prepared.receipt,
          prepared.run,
          prepared.payloadHash,
        );
      }
      final receipt = await (retry == null
          ? medical.approvedCapture(tx, v)
          : retry.capture(medical, tx, v));
      final latest = (await tx.query(
        'document_control_runs',
        where: 'version_id=?',
        whereArgs: [v.id],
        orderBy: 'rowid DESC',
        limit: 1,
      )).single;
      final config = (await tx.query('document_control_config')).single;
      final invalidations = await tx.query(
        'document_control_invalidations',
        where: 'run_id=?',
        whereArgs: [run['run_id']],
      );
      if (latest['run_id'] != run['run_id'] ||
          receipt['approval_id'] != run['approval_id'] ||
          receipt['snapshot_hash'] != prepared.receipt['snapshot_hash'] ||
          config['revision'] != run['configuration_revision'] ||
          (invalidations.isNotEmpty &&
              !(retry?.allowsControlInvalidations(
                    run['run_id'] as String,
                    invalidations,
                  ) ??
                  false))) {
        throw StateError('Preuves remplacées ou invalidées.');
      }
      await controls.verifyFiles(run, prepared.result);
      if (FinalPdfDocumentService.hash(prepared.payload) != payloadHash ||
          FinalPdfDocumentService.hash(
                await File(
                  p.join(
                    (await controls.root).path,
                    run['directory'] as String,
                    'document.xml',
                  ),
                ).readAsBytes(),
              ) !=
              payloadHash) {
        throw StateError('Contenu CDA modifié avant réservation.');
      }
      if (dv1ChainId == null) {
        await tx.insert('document_attempts', {
          'attempt_id': id,
          'document_id': v.documentId,
          'version_id': v.id,
          'patient_id': v.values['patient_id'],
          'pdf_hash': v.digest,
          'approval_id': receipt['approval_id'],
          'control_run_id': run['run_id'],
          'snapshot_hash': receipt['snapshot_hash'],
          'payload_hash': payloadHash,
          'mode': 'simulation',
          'started_at': medical.now().millisecondsSinceEpoch,
        });
      }
      await record?.call(tx, id);
      if (dv1ChainId != null &&
          (await tx.query(
                'document_chain_steps',
                where: 'chain_id=? AND phase=? AND version_id=?',
                whereArgs: [dv1ChainId, 'dv1_reservation', v.id],
              )).length !=
              1) {
        throw StateError('Réservation DV1 non conservée.');
      }
    });
    return id;
  }

  Future<void> complete(String id, Map<String, Object?> evidence) async {
    final db = await database;
    await db.insert('document_attempt_results', {
      'attempt_id': id,
      'outcome': evidence['outcome'],
      'detail': evidence['detail'],
      'evidence_json': medicalCanonical(evidence),
      'evidence_hash': medicalHash(evidence),
      'completed_at': medical.now().millisecondsSinceEpoch,
    });
  }

  /// Used only by an explicitly isolated harness. Product UI never calls it.
  /// Reservation precedes the call; any interruption leaves an irreversible guard.
  Future<DocumentJournalStatus> simulate(
    EpisodeDocumentVersion v,
    DocumentLocalSimulation simulation,
  ) async {
    final db = await database;
    await simulation.checkScope(db, await medical.pdf.root());
    var initial = await _state(db, v);
    if (initial.attempt != null ||
        initial.state == 'restored' ||
        initial.held) {
      return initial;
    }
    final prepared = await prepare(v);
    final id = await reserve(v, prepared);
    await checkpoint?.call('after_reservation');
    Map<String, Object?> evidence;
    try {
      evidence = await simulation.execute();
    } catch (e) {
      evidence = {
        'outcome': 'indeterminate',
        'detail': 'Résultat indisponible : $e',
        'kind': 'simulation',
      };
    }
    await checkpoint?.call('after_response');
    await complete(id, evidence);
    return status(v);
  }
}
