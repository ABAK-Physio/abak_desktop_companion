import 'native/td02.dart';
import 'native/dv1_replacement.dart';
import 'native/td31b.dart';
import 'native/ports.dart';
import '../../../dmp_setup/dmp_setup_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../../../dmp_td02/td02_result.dart';
import '../../../dmp_transfer/archive_deposit_reader.dart';
import '../../../dmp_transfer/transfer_simulation.dart';
import '../../models/episode_document_version.dart';
import '../document_journal_service.dart';
import '../document_medical_service.dart';
import '../cnda_patient_recipe.dart';
import '../document_lot_signature_service.dart';
import 'contracts.dart';
import 'messages.dart';
import 'wire/package.dart';
import 'wire/crypto.dart';
import 'native/dv1_configuration.dart';
import 'native/dv1_review.dart';
import 'native/dv1_retry.dart';

class DocumentDmpChain {
  DocumentDmpChain({required this.journal, this.checkpoint});
  final DocumentJournalService journal;
  final Future<void> Function(String)? checkpoint;
  DateTime get now => journal.medical.now().toUtc();
  static const maxAge = Duration(minutes: 2);

  Future<void> _record(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
    String chain,
    String phase,
    String state,
    String detail,
    Map<String, Object?> data,
  ) => db
      .insert('document_chain_steps', {
        'step_id': const Uuid().v4(),
        'chain_id': chain,
        'document_id': v.documentId,
        'version_id': v.id,
        'phase': phase,
        'state': state,
        'detail':
            '${phase.startsWith('dv1_') ? 'DV1' : 'Simulation'} — $detail',
        'data_json': medicalCanonical(data),
        'data_hash': medicalHash(data),
        'created_at': now.millisecondsSinceEpoch,
      })
      .then((_) {});

  void _require(bool ok, String why) {
    if (!ok) throw DmpChainBlock(why);
  }

  void _session(DmpSession s, Map snapshot) {
    final c = jsonDecode(snapshot['practice']['data_json']);
    _require(
      s.id.isNotEmpty &&
          RegExp(r'^[0-9a-f]{64}$').hasMatch(s.certificateHash) &&
          s.professional == c['identifier'] &&
          s.authority == c['authority'] &&
          s.structure == c['structureId'] &&
          s.contextHash == medicalHash(snapshot['practice']),
      'Contexte authentifié différent du professionnel ou de sa situation.',
    );
    _require(
      !now.isBefore(s.issuedAt) && now.isBefore(s.expiresAt),
      'Session professionnelle expirée ou non encore valide.',
    );
  }

  void _policy(DmpPolicy policy, Map snapshot) {
    final prep = jsonDecode(snapshot['preparation']['data_json']);
    _require(
      policy.snapshotHash == medicalHash(snapshot) &&
          now.isBefore(policy.expiresAt),
      'Droits ou paramètres périmés, inconnus ou associés à une autre version.',
    );
    _require(
      policy.catalogReference.isNotEmpty &&
          policy.catalogReference == prep['catalogReference'] &&
          policy.codesValid == true,
      'Nomenclatures non vérifiées pour cette préparation.',
    );
    _require(
      policy.opposition == false,
      'Opposition au dépôt présente ou non vérifiée.',
    );
    _require(
      policy.functionalRights == true && policy.authorRights == true,
      'Droits de dépôt non réunis ou non vérifiés.',
    );
    _require(
      policy.visibilityAllowed == true &&
          prep['patientVisibility'] == 'visible' &&
          prep['professionalVisibility'] == 'visible' &&
          prep['representativesVisibility'] == 'sans objet',
      'Visibilité ou parcours mineur hors du profil de dépôt vérifié.',
    );
  }

  /// Synthetic execution keeps its explicit storage guard and injected doubles.
  Future<DocumentJournalStatus> executeSimulated(
    EpisodeDocumentVersion v, {
    required Directory directory,
    required DocumentDmpPorts ports,
  }) async {
    final db = await journal.database;
    await DocumentLocalSimulation(
      directory: directory,
    ).checkScope(db, await journal.medical.pdf.root());
    return _execute(v, ports: ports);
  }

  static bool _dv1Busy = false;

  /// Real business entry. Ports are constructed here from the frozen DV1
  /// configuration; the UI cannot pass a simulated transport into this path.
  Future<DocumentJournalStatus> executeDv1(
    EpisodeDocumentVersion v, {
    required Dv1Configuration configuration,
    required Dv1Review review,
    required bool accessOnly,
    required Future<String?> Function() requestPin,
    Dv1RetryReview? retry,
  }) async {
    await DmpSetupService.requireEnabled(await journal.database);
    if (_dv1Busy) {
      throw const DmpChainBlock('Une opération DV1 est déjà en cours.');
    }
    _dv1Busy = true;
    try {
      if (retry != null) {
        _require(
          !accessOnly && review.scenario == 'PRE_ALIM_N1',
          'La reprise concerne uniquement le dépôt PRE_ALIM_N1 confirmé.',
        );
        await Dv1Retry.recheck(
          await journal.database,
          v,
          await journal.controls.root,
          retry,
        );
        retry.checkPreparation(
          review.prepared.receipt,
          review.prepared.run,
          review.prepared.payloadHash,
        );
      }
      final settings = Dv1ConfigurationService(journal);
      await settings.unchanged(configuration);
      await DocumentLotSignatureService(journal).checkBeforeDv1(v);
      final reviewedSnapshot =
          jsonDecode(review.prepared.receipt['snapshot_json'] as String)
              as Map<String, dynamic>;
      _policy(
        review.policy(configuration, reviewedSnapshot, now),
        reviewedSnapshot,
      );
      final replacement = await Dv1Replacement.check(await journal.database, v);
      _require(
        replacement == null ||
            (!accessOnly &&
                retry == null &&
                review.scenario == 'PRE_ALIM_RPLC'),
        'Le remplacement nécessite la confirmation PRE_ALIM_RPLC.',
      );
      final ports = await settings.ports(
        configuration,
        requestPin,
        (snapshot) async => review.policy(configuration, snapshot, now),
      );
      return await _execute(
        v,
        ports: ports,
        configuration: configuration,
        review: review,
        accessOnly: accessOnly,
        retry: retry,
        configurationCurrent: () async {
          await DmpSetupService.requireEnabled(await journal.database);
          await settings.unchanged(configuration);
        },
      );
    } finally {
      _dv1Busy = false;
    }
  }

  Future<DocumentJournalStatus> _execute(
    EpisodeDocumentVersion v, {
    required DocumentDmpPorts ports,
    Dv1Configuration? configuration,
    Dv1Review? review,
    bool accessOnly = false,
    Dv1RetryReview? retry,
    Future<void> Function()? configurationCurrent,
  }) async {
    final db = await journal.database;
    final live = configuration != null;
    String name(String phase) => live ? 'dv1_$phase' : phase;
    final initial = await journal.status(v);
    if ((!accessOnly && initial.held) ||
        (initial.attempt != null && retry == null) ||
        initial.state == 'restored') {
      return initial;
    }
    final chain = const Uuid().v4();
    String phase = 'preparation';
    String? attempt;
    bool sessionAcquired = false;
    Future<void> step(String text, Map<String, Object?> data) =>
        _record(db, v, chain, name(phase), 'passed', text, data);
    try {
      final captured = await journal.prepare(v, retry: retry);
      if (retry != null) {
        _require(live && !accessOnly, 'Reprise réservée au dépôt DV1.');
        await Dv1Retry.recheck(db, v, await journal.controls.root, retry);
        retry.checkPreparation(
          captured.receipt,
          captured.run,
          captured.payloadHash,
        );
      }
      await configurationCurrent?.call();
      if (review != null) {
        _require(
          captured.receipt['approval_id'] ==
                  review.prepared.receipt['approval_id'] &&
              captured.receipt['snapshot_hash'] ==
                  review.prepared.receipt['snapshot_hash'] &&
              captured.run['run_id'] == review.prepared.run['run_id'] &&
              captured.payloadHash == review.prepared.payloadHash,
          'Version, validation ou contrôles modifiés depuis votre confirmation.',
        );
      }
      final snapshot =
          jsonDecode(captured.receipt['snapshot_json'] as String)
              as Map<String, dynamic>;
      if (snapshot['cndaRecipe'] != null) {
        _require(
          live,
          'Le parcours CNDA alimentation est réservé à la recette DV1.',
        );
        CndaPatientRecipe.checkDestination(
          snapshot,
          Dv1Configuration.repository,
        );
      }
      // Freeze the transport inputs independently of mutable database maps.
      await step(
        'Version médicale, identité et contrôles locaux concordants.',
        {
          if (live) ...{
            'scope': 'dv1',
            'accessOnly': accessOnly,
            'configurationRevision': configuration.revision,
            'configurationHash': configuration.hash,
            'conditions': review!.evidence,
            if (retry != null) 'retry': retry.evidence,
          },
          'approvalId': captured.receipt['approval_id'],
          'snapshotHash': captured.receipt['snapshot_hash'],
          'controlRunId': captured.run['run_id'],
          'cdaHash': captured.payloadHash,
        },
      );
      phase = 'authentication';
      final session = await ports.authenticate(
        jsonDecode(jsonEncode(snapshot)),
      );
      sessionAcquired = true;
      _session(session, snapshot);
      await step(
        live
            ? 'CPS et situation professionnelle concordantes ; canaux TLS vérifiés.'
            : 'Contexte professionnel simulé concordant.',
        session.evidence,
      );
      phase = 'policy';
      final policy = await ports.policy(jsonDecode(jsonEncode(snapshot)));
      _policy(policy, snapshot);
      await step(
        live
            ? 'Conditions de dépôt confirmées pour la recette ; visibilité et nomenclatures vérifiées localement.'
            : 'Opposition, droits, visibilité et nomenclatures vérifiés par le double.',
        policy.evidence,
      );
      phase = 'td02';
      final requestedAt = now;
      final tdRequest = ports is DocumentDmpTd02Ports
          ? await (ports as DocumentDmpTd02Ports).prepareTd02(
              snapshot,
              session,
              now,
            )
          : DmpChainMessages.td02(snapshot, session, now);
      final tdReply = await ports.td02(tdRequest, session);
      final td = Td02Reader.read(
        request: tdRequest,
        response: tdReply.xml,
        context: DmpChainMessages.context(snapshot, session),
        httpStatus: tdReply.status,
      );
      final tdEvidence = <String, Object?>{
        'request': tdRequest,
        'response': tdReply.xml,
        'httpStatus': tdReply.status,
        if (tdReply.headers != null) 'headers': tdReply.headers,
        'requestedAt': requestedAt.toIso8601String(),
        'state': td.state.name,
        'consultationRight': td.right.name,
      };
      if (!td.allows(
        DmpAction.deposit,
        opposition: policy.opposition!,
        functionalRights: policy.functionalRights!,
        authorRights: policy.authorRights!,
        consultationConsent: false,
      )) {
        await _record(
          db,
          v,
          chain,
          name(phase),
          'blocked',
          '${td.message} ${td.detail}',
          tdEvidence,
        );
        return await journal.status(v);
      }
      await step(
        'TD0.2 corrélé : DMP actif pour le patient attendu.',
        tdEvidence,
      );
      if (accessOnly) {
        phase = 'access_checked';
        await step(
          'Accès TD0.2 vérifié sur DV1. Aucun document déposé.',
          tdEvidence,
        );
      } else {
        String? replacementEntryUuid;
        final replacement = await Dv1Replacement.check(db, v);
        if (replacement != null) {
          _require(
            live && ports is DocumentDmpNativePorts,
            'Remplacement réservé au transport DV1.',
          );
          _require(
            replacement['patientCx'] == DmpChainMessages.patientCx(snapshot),
            'Le patient diffère du document à remplacer.',
          );
          phase = 'replacement_search';
          final query = DmpNativeTd31b.fromPatientRequest(
            DmpNativeTd02.build(
              snapshot,
              session,
              await (ports as DocumentDmpNativePorts).wireMaterial(session),
              now,
              Dv1Configuration.td02,
              processingMode: 'T',
            ),
            replacement['uniqueId'] as String,
          );
          final response = await ports.searchDocument(query, session);
          // Retain failures too; interpretation must not erase a server reply.
          await step('Recherche fraîche du document à remplacer.', {
            'request': query,
            'response': response.xml,
            'httpStatus': response.status,
            'headers': response.headers,
            'target': replacement,
          });
          final ids = DmpNativeTd31b.read(query, response);
          _require(
            ids.length == 1,
            'Remplacement bloqué : identifiant technique absent ou ambigu.',
          );
          replacementEntryUuid = ids.single;
        }
        phase = 'package';
        late final DmpPreparedSubmission package;
        late final DmpSignature signature;
        DmpWireDraft? wireDraft;
        DmpWirePacket? wirePacket;
        if (ports is DocumentDmpWirePorts) {
          final material = await ports.wireMaterial(session);
          wireDraft = DmpWireDraft(
            snapshot,
            session,
            captured.payload,
            material,
            now,
            approvedAt: captured.receipt['approved_at'] as int,
            replacementEntryUuid: replacementEntryUuid,
          );
          phase = 'signature';
          final value = await ports.signCanonicalXml(
            wireDraft.signedInfo,
            material.signingHash,
            session,
          );
          wirePacket = wireDraft.finish(value);
          wireDraft.verify(wirePacket, now);
          package = DmpPreparedSubmission(
            request: wirePacket.soap,
            messageId: wireDraft.messageId,
            metadata: wirePacket.metadata,
            vihf: wirePacket.vihf,
            cdaHash: captured.payloadHash,
            snapshotHash: medicalHash(snapshot),
            sessionHash: medicalHash(session.evidence),
            wire: {
              ...wirePacket.evidence,
              'material': material.evidence,
              'authenticationDer': material.authenticationDer,
              'signingCertificateHash': material.signingHash,
              'signedInfo': wireDraft.signedInfo,
              'replay': wireDraft.replay,
            },
          );
          signature = DmpSignature(
            packageHash: package.hash,
            certificateHash: material.signingHash,
            value: value,
            format: 'XAdES-1.1.1-RSA-SHA1-SEL-MP-037-2.10',
          );
          phase = 'package';
          await step(
            live
                ? 'Lot XDS/VIHF/XAdES signé avec la CPS et paquet MIME/MTOM vérifié.'
                : 'Paquet XDS/VIHF/XAdES et MIME/MTOM vérifié ; certificats synthétiques.',
            package.evidence,
          );
          phase = 'signature';
          await step(
            'Signature RSA vérifiée avec le certificat de signature ; CDA exact et enveloppe figés.',
            signature.evidence,
          );
        } else {
          package = DmpChainMessages.prepare(
            snapshot,
            session,
            captured.payload,
            now,
          );
          await step(
            'Propositions CDA, XDS et VIHF liées à cette version ; profil réseau non validé.',
            package.evidence,
          );
          phase = 'signature';
          signature = await ports.sign(package, session);
          _require(
            signature.packageHash == package.hash &&
                signature.certificateHash == session.certificateHash &&
                signature.format == 'simulation' &&
                signature.value.isNotEmpty &&
                await ports.verifySignature(package, signature, session),
            'Signature simulée non vérifiée ou contenu/certificat différent.',
          );
          await step(
            'Signature du contrat local vérifiée par le double ; aucune signature CPS.',
            signature.evidence,
          );
        }
        _require(
          package.cdaHash == captured.payloadHash &&
              package.snapshotHash == captured.receipt['snapshot_hash'],
          'Contenu de préparation différent du contenu validé.',
        );
        Future<void> verifyWire() async {
          if (wireDraft == null) return;
          wireDraft.verify(wirePacket!, now);
          final current = await (ports as DocumentDmpWirePorts).wireMaterial(
            session,
          );
          current.check(session, now);
          _require(
            medicalHash(current.evidence) ==
                    medicalHash(wireDraft!.material.evidence) &&
                DmpWireCertificate.parse(current.signingDer).hash ==
                    signature.certificateHash,
            'Configuration ou certificats modifiés pendant la préparation.',
          );
        }

        phase = 'tls';
        final failure = await ports.connect(session);
        _require(
          failure == null,
          failure?.message ?? 'Connexion sécurisée non vérifiée.',
        );
        await step(
          live
              ? 'Canaux TLS DV1 vérifiés et conservés pour cette session.'
              : 'Canal TLS simulé disponible ; aucune connexion réseau.',
          {'sessionHash': medicalHash(session.evidence)},
        );
        phase = 'recheck';
        await checkpoint?.call('before_reservation');
        await configurationCurrent?.call();
        await verifyWire();
        _session(session, snapshot);
        _require(
          await ports.sessionCurrent(session),
          'Session professionnelle modifiée.',
        );
        final currentPolicy = await ports.policy(
          jsonDecode(jsonEncode(snapshot)),
        );
        _policy(currentPolicy, snapshot);
        _require(
          medicalHash(currentPolicy.evidence) == medicalHash(policy.evidence),
          'Droits ou paramètres modifiés pendant la préparation.',
        );
        _require(
          !now.isBefore(requestedAt) && now.difference(requestedAt) <= maxAge,
          'TD0.2 trop ancien. Nouvelle vérification nécessaire avant toute tentative.',
        );
        Future<void> reserveRecord(DatabaseExecutor tx, String id) async {
          _session(session, snapshot);
          _policy(policy, snapshot);
          _require(
            !now.isBefore(requestedAt) && now.difference(requestedAt) <= maxAge,
            'TD0.2 trop ancien avant réservation.',
          );
          if (retry != null) {
            _require(
              package.wire?['replay']['soapHeaderProfile'] == 'dv1-20261028',
              'La reprise exige le profil SOAP corrigé.',
            );
            _require(
              !retry.patientId ||
                  package.wire?['replay']['xdsPatientIdProfile'] == 'ins-nh-1',
              'La reprise exige patientId XDS avec NH.',
            );
            _require(
              !retry.metadata ||
                  package.wire?['replay']['xdsMetadataProfile'] ==
                      'dv1-labels-signature-1',
              'La reprise exige les métadonnées XDS corrigées.',
            );
            _require(
              !retry.signatureTitle ||
                  package.wire?['replay']['signatureTitleProfile'] ==
                      'event-source-1',
              'La reprise exige le titre de signature corrigé.',
            );
          }
          if (live) {
            final latest = (await tx.query(
              'document_dv1_configurations',
              orderBy: 'revision DESC',
              limit: 1,
            )).single;
            _require(
              latest['data_hash'] == configuration.hash &&
                  latest['revision'] == configuration.revision,
              'Configuration DV1 modifiée avant réservation.',
            );
          }
          await _record(
            tx,
            v,
            chain,
            name('reservation'),
            'reserved',
            retry == null
                ? 'Tentative réservée dans le journal commun ; renvoi bloqué.'
                : '${retry.label} réservée ; historique conservé ; renvoi bloqué.',
            {
              'attemptId': id,
              if (retry != null) 'retry': retry.evidence,
              'replacement': ?replacement,
              'packageHash': package.hash,
              'snapshotHash': package.snapshotHash,
              if (live) ...{
                'scope': 'dv1',
                'configurationHash': configuration.hash,
                'configurationRevision': configuration.revision,
                'approvalId': captured.receipt['approval_id'],
                'controlRunId': captured.run['run_id'],
                'cdaHash': captured.payloadHash,
              },
            },
          );
        }

        attempt = live
            ? await journal.reserveDv1(
                v,
                captured,
                chainId: chain,
                retry: retry,
                record: reserveRecord,
              )
            : await journal.reserve(v, captured, record: reserveRecord);
        await checkpoint?.call('after_reservation');
        phase = 'transport';
        await configurationCurrent?.call();
        // A retained reservation survives an interruption or any subsequent failure.
        _session(session, snapshot);
        _policy(policy, snapshot);
        _require(
          await ports.sessionCurrent(session),
          'Session professionnelle modifiée avant traitement.',
        );
        await verifyWire();
        if (live) {
          final fresh = await db.transaction(
            (tx) => retry == null
                ? journal.medical.approvedCapture(tx, v)
                : retry.capture(journal.medical, tx, v),
          );
          _require(
            fresh['approval_id'] == captured.receipt['approval_id'] &&
                fresh['snapshot_hash'] == captured.receipt['snapshot_hash'],
            'Validation modifiée avant transmission ; tentative conservée sans renvoi.',
          );
          final currentControls = await journal.controls.status(
            v,
            retry: retry,
          );
          _require(
            currentControls.pdfa == 'conforme' &&
                currentControls.cda == 'conforme' &&
                currentControls.run?['run_id'] == captured.run['run_id'],
            'Contrôles invalidés avant transmission.',
          );
        }
        if (live) await DmpSetupService.requireEnabled(db);
        final reply = await ports.deposit(package, signature, session);
        final result = ArchiveDepositReader.readForMessageId(
          requestMessageId: package.messageId,
          headers: reply.headers,
          bytes: reply.bytes,
        );
        final outcome = switch (result.outcome) {
          DepositOutcome.accepted => 'accepted',
          DepositOutcome.rejected ||
          DepositOutcome.metadataRejected ||
          DepositOutcome.signatureRejected => 'rejected',
          _ => 'indeterminate',
        };
        await checkpoint?.call('after_response');
        final evidence = <String, Object?>{
          'kind': live ? 'chain_dv1' : 'chain_simulation',
          if (live) 'attemptId': attempt,
          'chainId': chain,
          'outcome': outcome,
          'detail':
              '${result.detail} ${live ? 'Résultat DV1' : 'Simulation uniquement'} ; renvoi bloqué.',
          'packageHash': package.hash,
          'request': package.request,
          'headers': reply.headers,
          'response': base64Encode(reply.bytes),
          'provenance': reply.provenance,
          'scope': live
              ? 'dv1'
              : 'Aucun dépôt réel ; les archives ne prouvent pas un dépôt de ce PDF.',
        };
        if (!live) await journal.complete(attempt, evidence);
        await _record(
          db,
          v,
          chain,
          name('response'),
          'result',
          evidence['detail'] as String,
          live ? evidence : {'attemptId': attempt, 'outcome': outcome},
        );
      }
    } catch (e) {
      final text = e is DmpChainBlock
          ? e.message
          : 'Étape $phase indisponible ou préparation modifiée. Traitement arrêté.';
      // Never journal arbitrary service errors (PIN, tokens or secrets).
      if (attempt != null) {
        final rows = live
            ? await db.query(
                'document_chain_steps',
                where: 'chain_id=? AND phase=?',
                whereArgs: [chain, name('response')],
              )
            : await db.query(
                'document_attempt_results',
                where: 'attempt_id=?',
                whereArgs: [attempt],
              );
        if (rows.isEmpty) {
          final evidence = <String, Object?>{
            'kind': live ? 'chain_dv1' : 'chain_simulation',
            'scope': live ? 'dv1' : 'simulation',
            'chainId': chain,
            'attemptId': attempt,
            'outcome': 'indeterminate',
            'detail': '$text Résultat indéterminé ; renvoi bloqué.',
          };
          if (live) {
            await _record(
              db,
              v,
              chain,
              name('response'),
              'result',
              evidence['detail'] as String,
              evidence,
            );
          } else {
            await journal.complete(attempt, evidence);
          }
        }
      }
      await _record(
        db,
        v,
        chain,
        name(live ? '${phase}_failure' : phase),
        'blocked',
        text,
        {'attemptId': attempt},
      );
    } finally {
      if (sessionAcquired && ports is DocumentDmpSessionLifecycle) {
        try {
          await (ports as DocumentDmpSessionLifecycle).closeSession();
          await _record(
            db,
            v,
            chain,
            name('session_close'),
            'passed',
            'Session native fermée.',
            {},
          );
        } catch (_) {
          await _record(
            db,
            v,
            chain,
            name('session_close'),
            'blocked',
            'Fermeture de session non confirmée ; nouvelle session bloquée.',
            {},
          );
        }
      }
    }
    return await journal.status(v);
  }
}
