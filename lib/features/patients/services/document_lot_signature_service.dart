import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../../cps/cps_access_service.dart';
import '../../cps/cps_operation_lease.dart';
import '../models/episode_document_version.dart';
import 'dmp_chain/wire/crypto.dart';
import 'document_journal_service.dart';
import 'dmp_chain/native/dv1_records.dart';
import 'document_lot_signature_records.dart';
import 'document_medical_service.dart';
import '../../practitioners/data/practitioner_cps_service.dart';

class DocumentLotSignatureReview {
  DocumentLotSignatureReview(this.prepared, this.holdRevision);
  final DocumentAttemptPreparation prepared;
  final int holdRevision;
  Map<String, dynamic> get snapshot =>
      jsonDecode(prepared.receipt['snapshot_json'] as String);
  Map get practice => jsonDecode(snapshot['practice']['data_json']);
  String get professional => practice['identifier'] as String;
  String get professionalName =>
      '${practice['givenNames']} ${practice['familyName']}';
  Map<String, Object?> get binding => {
    'approvalId': prepared.receipt['approval_id'],
    'approvedAt': prepared.receipt['approved_at'],
    'controlRunId': prepared.run['run_id'],
    'snapshotHash': prepared.receipt['snapshot_hash'],
    'pdfHash': snapshot['version']['sha256'],
    'cdaHash': prepared.payloadHash,
    'holdRevision': holdRevision,
  };
}

class DocumentLotSignatureStatus {
  const DocumentLotSignatureStatus(this.message, {this.review});
  final String message;
  final DocumentLotSignatureReview? review;
}

/// An explicit local capability. No transport port, TLS worker, DMP URL, PIN
/// persistence or background retry. Existing immutable chain steps also feed
/// the common journal and are included in native database backup/restore.
class DocumentLotSignatureService {
  DocumentLotSignatureService(this.journal);
  final DocumentJournalService journal;
  static const cps = CpsAccessService();
  static const records = DocumentLotSignatureRecords.phases;

  static String errorMessage(Object e) => switch (e) {
    PlatformException() => e.message ?? 'Opération CPS impossible.',
    StateError() => e.message.toString(),
    FormatException() => e.message,
    _ =>
      'Signature locale impossible ; consulter la préparation et les preuves.',
  };

  Future<List<MedicalRow>> _rows(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
  ) => db.query(
    'document_chain_steps',
    where: 'document_id=? AND phase IN (?,?,?,?)',
    whereArgs: [v.documentId, ...records],
    orderBy: 'rowid',
  );

  /// Any interrupted operation blocks even a new version. Only a recorded
  /// failure before the signing request permits an explicit manual retry.
  Future<void> _available(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
    String approval, {
    bool allowCompleted = false,
  }) async {
    final rows = await _rows(db, v);
    for (final begin in rows.where(
      (r) => r['phase'] == DocumentLotSignatureRecords.started,
    )) {
      await DocumentLotSignatureRecords.verifyChain(
        db,
        begin['chain_id'] as String,
        await journal.controls.root,
      );
      final initial = DocumentLotSignatureRecords.data(begin);
      final chain = rows
          .where((r) => r['chain_id'] == begin['chain_id'])
          .toList();
      for (final r in chain) {
        DocumentLotSignatureRecords.data(r);
      }
      final results = chain
          .where((r) => r['phase'] == DocumentLotSignatureRecords.completed)
          .toList();
      final failures = chain
          .where((r) => r['phase'] == DocumentLotSignatureRecords.failed)
          .toList();
      final requested = chain.any(
        (r) => r['phase'] == DocumentLotSignatureRecords.requested,
      );
      if (results.length + failures.length > 1) {
        throw StateError(
          'Journal de signature incohérent : opération bloquée.',
        );
      }
      if (results.isEmpty &&
          (failures.isEmpty ||
              requested ||
              DocumentLotSignatureRecords.data(
                    failures.single,
                  )['signatureRequested'] !=
                  false)) {
        throw StateError(
          'Signature interrompue ou résultat incertain : nouvelle signature bloquée. Examen du journal nécessaire.',
        );
      }
      if (!allowCompleted &&
          results.isNotEmpty &&
          initial['approvalId'] == approval) {
        throw StateError(
          'Un lot est déjà signé pour cette validation. Aucune nouvelle signature automatique.',
        );
      }
    }
  }

  /// A completed local lot is historical evidence; DV1 signs its own fresh lot.
  /// An interrupted local signing operation still requires examination.
  Future<void> checkBeforeDv1(EpisodeDocumentVersion v) async =>
      _available(await journal.database, v, '', allowCompleted: true);

  Future<void> _guard(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
    DocumentLotSignatureReview review,
  ) async {
    final holds = await db.query(
      'document_holds',
      where: 'version_id=?',
      whereArgs: [v.id],
    );
    final attempts = await db.rawQuery(
      '''SELECT 1 FROM document_attempts
      WHERE document_id=? OR (patient_id=? AND pdf_hash=?) LIMIT 1''',
      [v.documentId, v.values['patient_id'], v.digest],
    );
    if (holds.length != 1 ||
        holds.single['held'] != 0 ||
        holds.single['revision'] != review.holdRevision ||
        attempts.isNotEmpty ||
        (await Dv1Records.reservations(db, v)).isNotEmpty ||
        (await db.query('document_restore_barriers', limit: 1)).isNotEmpty) {
      throw StateError(
        'Signature bloquée : retenue, tentative existante, restauration ou préparation modifiée.',
      );
    }
    final approval = await journal.medical.approvedCapture(db, v);
    final latest = await db.query(
      'document_control_runs',
      where: 'version_id=?',
      whereArgs: [v.id],
      orderBy: 'rowid DESC',
      limit: 1,
    );
    final config = await db.query('document_control_config');
    if (approval['approval_id'] != review.prepared.receipt['approval_id'] ||
        approval['snapshot_hash'] != review.prepared.receipt['snapshot_hash'] ||
        latest.length != 1 ||
        latest.single['run_id'] != review.prepared.run['run_id'] ||
        config.length != 1 ||
        config.single['revision'] !=
            review.prepared.run['configuration_revision'] ||
        (await db.query(
          'document_control_invalidations',
          where: 'run_id=?',
          whereArgs: [review.prepared.run['run_id']],
        )).isNotEmpty) {
      throw StateError(
        'Validation médicale ou contrôles modifiés : signature bloquée.',
      );
    }
    await journal.controls.verifyFiles(
      review.prepared.run,
      review.prepared.result,
    );
  }

  Future<void> _fresh(
    EpisodeDocumentVersion v,
    DocumentLotSignatureReview review,
  ) async {
    final fresh = await journal.prepare(v);
    if (medicalHash(
          DocumentLotSignatureReview(fresh, review.holdRevision).binding,
        ) !=
        medicalHash(review.binding)) {
      throw StateError('Contenu ou preuve modifié depuis la confirmation.');
    }
    await (await journal.database).transaction((tx) => _guard(tx, v, review));
  }

  Future<DocumentLotSignatureStatus> status(EpisodeDocumentVersion v) async {
    try {
      final db = await journal.database;
      final rows = await _rows(db, v);
      final successes = rows
          .where(
            (r) =>
                r['phase'] == DocumentLotSignatureRecords.completed &&
                r['version_id'] == v.id,
          )
          .toList();
      final restored = (await db.query(
        'document_restore_barriers',
        limit: 1,
      )).isNotEmpty;
      if (successes.isNotEmpty) {
        final proof = await DocumentLotSignatureRecords.verifyChain(
          db,
          successes.last['chain_id'] as String,
          await journal.controls.root,
        );
        if (restored) {
          return const DocumentLotSignatureStatus(
            'Signature locale conservée après restauration. Réutilisation et envoi bloqués ; examen nécessaire.',
          );
        }
        try {
          final current = await journal.prepare(v);
          final request = proof!['request'] as Map;
          if (current.receipt['approval_id'] == request['approvalId']) {
            if (current.receipt['snapshot_hash'] != request['snapshotHash'] ||
                current.run['run_id'] != request['controlRunId'] ||
                current.payloadHash != request['cdaHash'] ||
                proof['currentAtCompletion'] != true) {
              throw StateError(
                'Préparation modifiée pendant ou après la signature.',
              );
            }
            return const DocumentLotSignatureStatus(
              'Lot signé par la CPS : signature cryptographique vérifiée localement et conservée. Confiance et révocation du certificat non vérifiées. Aucun envoi ; aucune autorisation de dépôt établie.',
            );
          }
        } catch (_) {
          return const DocumentLotSignatureStatus(
            'Signature historique conservée ; validation ou contrôles à reprendre. Cette preuve ne peut pas autoriser le traitement actuel.',
          );
        }
      }
      if (restored) {
        throw StateError('Restauration : signature et traitement suspendus.');
      }
      final prepared = await journal.prepare(v);
      DocumentLotSignatureRecords.context(
        jsonDecode(prepared.receipt['snapshot_json'] as String),
      );
      final state = await journal.status(v);
      final review = DocumentLotSignatureReview(prepared, state.revision);
      await db.transaction((tx) async {
        await _guard(tx, v, review);
        await _available(tx, v, prepared.receipt['approval_id'] as String);
      });
      return DocumentLotSignatureStatus(
        'Version validée et contrôlée. Signature locale possible uniquement sur action explicite avec la CPS du signataire. Aucun envoi.',
        review: review,
      );
    } catch (e) {
      return DocumentLotSignatureStatus(errorMessage(e));
    }
  }

  Future<void> _record(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
    String chain,
    String phase,
    String state,
    String detail,
    Map<String, Object?> data,
  ) async {
    await db.insert('document_chain_steps', {
      'step_id': '$chain:$phase',
      'chain_id': chain,
      'document_id': v.documentId,
      'version_id': v.id,
      'phase': phase,
      'state': state,
      'detail': detail,
      'data_json': medicalCanonical(data),
      'data_hash': medicalHash(data),
      'created_at': journal.medical.now().millisecondsSinceEpoch,
    });
  }

  static String _oid() =>
      '2.25.${BigInt.parse(const Uuid().v4().replaceAll('-', ''), radix: 16)}';

  /// The caller must obtain explicit confirmation of the displayed review and
  /// a PIN in a transient dialog. This method is never invoked by status/load.
  Future<void> sign(
    EpisodeDocumentVersion v,
    DocumentLotSignatureReview review,
    String pin,
  ) async {
    if (!RegExp(r'^[0-9]{1,16}$').hasMatch(pin)) {
      throw const FormatException('PIN numérique requis.');
    }
    final db = await journal.database;
    final lease = await CpsOperationLease.acquireAvailable();
    final chain = const Uuid().v4();
    bool began = false, requested = false, completed = false;
    try {
      await _fresh(v, review);
      final initial = {
        ...review.binding,
        'lotOid': _oid(),
        'signatureOid': _oid(),
      };
      await db.transaction((tx) async {
        await _guard(tx, v, review);
        await _available(
          tx,
          v,
          review.prepared.receipt['approval_id'] as String,
        );
        await _record(
          tx,
          v,
          chain,
          DocumentLotSignatureRecords.started,
          'passed',
          'Signature CPS locale demandée explicitement. Aucun envoi.',
          initial,
        );
      });
      began = true;
      final material = await cps.prepareDmpLotLocal(
        pin,
        review.professional,
        lease: lease,
      );
      final profile = cps.profileFromResult(material);
      if (!PractitionerCpsService.matchesCurrentProfile(
        review.snapshot,
        profile,
      )) {
        throw StateError(
          'Les informations de la CPS ont changé depuis la préparation. Actualisez la fiche et le contexte avant de signer.',
        );
      }
      final situations = profile.situations
          .where((s) => s.structureId == review.practice['structureId'])
          .toList();
      if (profile.nationalId != review.professional ||
          profile.professionCode != 70 ||
          situations.length != 1) {
        throw StateError(
          'La CPS ou sa situation ne correspond pas au signataire et à la structure validés.',
        );
      }
      final certificates = (material['certificates'] as List).cast<Map>();
      if (certificates.length != 2) {
        throw StateError('Certificats CPS incomplets.');
      }
      final signing = DmpWireCertificate.parse(
        certificates.singleWhere(
          (c) => c['role'] == 'signature',
        )['certificateBase64'],
      );
      final authentication = DmpWireCertificate.parse(
        certificates.singleWhere(
          (c) => c['role'] == 'authentification',
        )['certificateBase64'],
      );
      final now = journal.medical.now().toUtc();
      if (authentication.commonName != review.professional ||
          !authentication.digitalSignature ||
          !authentication.clientAuthentication ||
          authentication.hash == signing.hash ||
          now.isBefore(authentication.validFrom) ||
          !now.isBefore(authentication.validUntil)) {
        throw StateError(
          'Certificat d’authentification CPS incohérent ou hors validité.',
        );
      }
      final situation = situations.single;
      final request = <String, Object?>{
        ...initial,
        'certificate': signing.base64,
        'signedAt': now.toIso8601String(),
        'situation': {
          'number': situation.number,
          'mode': situation.mode,
          'status': situation.status,
          'structureId': situation.structureId,
          'sector': situation.sector,
        },
      };
      final template = DocumentLotSignatureRecords.template(
        request,
        review.snapshot,
        review.prepared.payload,
      );
      await _fresh(v, review);
      await db.transaction((tx) async {
        await _guard(tx, v, review);
        await _record(
          tx,
          v,
          chain,
          DocumentLotSignatureRecords.requested,
          'passed',
          'Manifeste du lot figé. Signature CPS locale en cours ; aucun envoi.',
          request,
        );
      });
      requested = true;
      final info = DocumentLotSignatureRecords.signedInfo(template);
      final result = await cps.signDmpLotLocal(
        pin,
        review.professional,
        info,
        signing.base64,
        lease: lease,
      );
      pin = ''; // Never saved in this service, database, journal or proof.
      if (result['verified'] != true ||
          result['nationalId'] != review.professional ||
          result['message'] != info ||
          result['signingCertificateBase64'] != signing.base64 ||
          cps.profileFromResult(result).nationalId != review.professional) {
        throw StateError('Réponse CPS différente du lot préparé.');
      }
      final after = cps.profileFromResult(result);
      final afterSituations = after.situations
          .where(
            (s) =>
                s.number == situation.number &&
                s.mode == situation.mode &&
                s.status == situation.status &&
                s.structureId == situation.structureId &&
                s.sector == situation.sector,
          )
          .toList();
      if (!PractitionerCpsService.matchesCurrentProfile(
            review.snapshot,
            after,
          ) ||
          after.professionCode != 70 ||
          afterSituations.length != 1) {
        throw StateError('Situation CPS modifiée pendant la signature.');
      }
      final value = result['signatureBase64'] as String;
      final signedXml = DocumentLotSignatureRecords.finish(
        template,
        signing.base64,
        value,
      );
      var current = true;
      try {
        await _fresh(v, review);
      } catch (_) {
        current = false;
      }
      await db.transaction((tx) async {
        if (current) {
          try {
            await _guard(tx, v, review);
          } catch (_) {
            current = false;
          }
        }
        await _record(
          tx,
          v,
          chain,
          DocumentLotSignatureRecords.completed,
          'passed',
          current
              ? 'Lot signé par la CPS, vérifié localement et conservé. Aucun envoi. Confiance et révocation non vérifiées.'
              : 'Signature conservée comme preuve historique : préparation modifiée pendant la signature, utilisation bloquée. Aucun envoi.',
          {
            'request': request,
            'signatureValue': value,
            'signatureXml': signedXml,
            'currentAtCompletion': current,
            'trustAndRevocation': 'not_checked',
            'transmitted': false,
          },
        );
      });
      completed = true;
    } catch (e) {
      if (began && !completed) {
        await _record(
          db,
          v,
          chain,
          DocumentLotSignatureRecords.failed,
          'blocked',
          requested
              ? 'Signature CPS demandée, résultat non confirmé. Nouvelle signature bloquée ; examen nécessaire. Aucun envoi.'
              : 'Signature non demandée à la CPS : ${errorMessage(e)} Aucun envoi.',
          {'signatureRequested': requested, 'reason': errorMessage(e)},
        );
      }
      rethrow;
    } finally {
      pin = '';
      lease.release();
    }
  }
}
