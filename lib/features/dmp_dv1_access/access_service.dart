import 'visibility_recipe.dart';
import 'package:xml/xml.dart';
import '../patients/services/dmp_chain/native/td33b.dart';
import 'consulted_document.dart';
import '../patients/services/dmp_chain/native/td32.dart';
import '../patients/services/dmp_chain/native/td31_submission.dart';
import 'consultation_recipe.dart';
import '../patients/services/dmp_chain/native/td31a.dart';
import 'depublication.dart';
import '../patients/services/dmp_chain/native/td33c.dart';
import 'search_targets.dart';
import '../patients/services/dmp_chain/native/td31b.dart';
import '../dmp_session/dmp_work_context.dart';
import '../dmp_setup/dmp_setup_service.dart';
import 'dart:convert';
import 'dart:io';
import 'consultation_consent.dart';
import '../patients/services/dmp_chain/native/td03.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../patients/services/final_pdf_document_service.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../dmp_resources/dmp_resources.dart';
import '../dmp_td02/td02_result.dart';
import '../patients/services/document_journal_service.dart';
import '../patients/services/document_medical_service.dart';
import '../patients/services/dmp_chain/contracts.dart';
import '../patients/services/dmp_chain/messages.dart';
import '../patients/services/dmp_chain/native/access_context.dart';
import '../patients/services/dmp_chain/native/bridge.dart';
import '../patients/services/dmp_chain/native/dv1_configuration.dart';
import '../patients/services/dmp_chain/native/ports.dart';

/// Real application entry, independent of PDF validation and patient tables.
/// No signing, deposit, INSi call or automatic retry is exposed here.
class Dv1AccessService {
  Dv1AccessService(this.journal);
  final DocumentJournalService journal;
  static bool _busy = false;
  Future<Directory> get root async => Directory(
    p.join((await journal.controls.root).path, 'dv1-access-history'),
  );
  Future<ConsultationConsentStore> get consents async =>
      ConsultationConsentStore(
        Directory(
          p.join((await root).parent.path, 'dv1-consultation-consents'),
        ),
      );

  Future<Map<String, dynamic>> recordConsent(
    Dv1AccessContext context,
    bool granted,
  ) async {
    if (_busy) throw StateError('Une opération DMP est déjà en cours.');
    _busy = true;
    try {
      await DmpSetupService.requireEnabled(await journal.database);
      DmpWorkContext.current.requireProfessional(context.professional);
      context.check(journal.medical.now().toUtc());
      if (context.scenario == 'PRE_CONS_INV') {
        Dv1VisibilityRecipe.check(context);
      }
      return await (await consents).save(
        context.professional,
        context.ins,
        patient: context.patientLabel,
        source: context.source,
        granted: granted,
        pendingWithdrawal: !granted,
        now: journal.medical.now(),
      );
    } finally {
      _busy = false;
    }
  }

  Future<Map<String, dynamic>> execute({
    required Dv1Configuration configuration,
    required Dv1AccessContext context,
    required Future<String?> Function() requestPin,
    String? authorizationIntent,
    Dv1SearchTarget? searchTarget,
    bool depublication = false,
    Dv1DocumentCriteria? criteria,
    Dv1SubmissionPeriod? submissionPeriod,
    Map<String, String>? consultationTarget,
    Map<String, String>? visibilityTarget,
    bool visibilityConfirmed = false,
    Future<bool> Function(ConsultedDocument)? displayDocument,
  }) async {
    if (_busy) throw StateError('Une vérification DV1 est déjà en cours.');
    // The CPS business-object bridge is currently implemented on macOS only.
    if (!Platform.isMacOS) {
      throw StateError(
        'Lecture CPS de ce parcours disponible sur macOS. Le raccordement Windows reste à réaliser.',
      );
    }
    _busy = true;
    DocumentDmpNativePorts? ports;
    Directory? directory;
    final record = <String, dynamic>{
      'schema': 1,
      'id': const Uuid().v4(),
      'environment': 'DV1',
      'operation': visibilityTarget != null
          ? 'TD3.3b — visibilité patient PRE_CONS_INV'
          : consultationTarget != null
          ? 'TD3.2 — consultation PRE_CONS_CONS'
          : submissionPeriod != null
          ? 'TD3.1 — recherche par dépôt PRE_CONS_SUB'
          : criteria != null
          ? 'TD3.1 — recherche multicritère ${context.scenario}'
          : depublication
          ? 'TD3.3c — dépublication PRE_ALIM_SUPPR'
          : searchTarget != null
          ? 'TD3.1b — recherche d’identifiant technique'
          : authorizationIntent == null
          ? 'TD0.2 — accès réel depuis Companion, sans dépôt'
          : 'Autorisation de consultation — $authorizationIntent',
      'platform': Platform.operatingSystem,
      'startedAt': journal.medical.now().toUtc().toIso8601String(),
      'configurationHash': configuration.hash,
      'configurationRevision': configuration.revision,
      'software': {
        for (final k in ['lpsName', 'lpsVersion', 'lpsId', 'homologationId'])
          k: configuration.fields[k],
      },
      'state': 'started',
    };
    Future<void> save() async {
      if (directory == null) return;
      final data = medicalCanonical(record);
      final temporary = File(p.join(directory.path, 'result.pending'));
      await temporary.writeAsString(
        jsonEncode({'record': record, 'sha256': medicalHash(jsonDecode(data))}),
        flush: true,
      );
      await temporary.rename(p.join(directory!.path, 'result.json'));
    }

    try {
      await DmpSetupService.requireEnabled(await journal.database);
      DmpWorkContext.current.requireProfessional(context.professional);
      context.check(journal.medical.now().toUtc());
      if (searchTarget != null) {
        if (authorizationIntent != null) {
          throw StateError('Actions incompatibles.');
        }
        searchTarget.checkContext(context);
        await Dv1SearchTargets(journal).verify(searchTarget);
        record['searchTarget'] = searchTarget.data;
      }
      if (criteria != null &&
          criteria.uniqueIds.isNotEmpty &&
          context.scenario != 'PRE_CONS_INV') {
        throw StateError('Recherche du jeu d’essai réservée à PRE_CONS_INV.');
      }
      if (criteria != null || submissionPeriod != null) {
        criteria?.check();
        submissionPeriod?.check();
        if (criteria != null && context.scenario != 'PRE_CONS_INV') {
          Dv1ConsultationRecipe.check(context);
        }
        if (searchTarget != null ||
            depublication ||
            authorizationIntent != null ||
            (criteria != null && submissionPeriod != null) ||
            context.scenario !=
                (submissionPeriod != null
                    ? 'PRE_CONS_SUB'
                    : context.scenario == 'PRE_CONS_INV'
                    ? 'PRE_CONS_INV'
                    : 'PRE_CONS_RECH')) {
          throw StateError(
            'Parcours de recherche incompatible avec cette action.',
          );
        }
        final decision = await (await consents).latest(
          context.professional,
          context.ins,
        );
        requireSearchConsent(decision);
        record['patientDecision'] = decision;
        record['searchCriteria'] = criteria?.data ?? submissionPeriod!.data;
      }
      if (consultationTarget != null) {
        if (searchTarget != null ||
            criteria != null ||
            submissionPeriod != null ||
            depublication ||
            authorizationIntent != null ||
            displayDocument == null ||
            context.scenario != 'PRE_CONS_CONS') {
          throw StateError('Actions de consultation incompatibles.');
        }
        await verifyConsultationTarget(consultationTarget, context);
        requireSearchConsent(
          await (await consents).latest(context.professional, context.ins),
        );
        record['consultationTarget'] = consultationTarget;
      }
      if (visibilityTarget != null) {
        if (!visibilityConfirmed ||
            context.scenario != 'PRE_CONS_INV' ||
            consultationTarget != null ||
            searchTarget != null ||
            criteria != null ||
            submissionPeriod != null ||
            depublication ||
            authorizationIntent != null) {
          throw StateError(
            'Confirmation de mise en visibilité requise ; actions incompatibles.',
          );
        }
        await verifyConsultationTarget(visibilityTarget, context);
        requireSearchConsent(
          await (await consents).latest(context.professional, context.ins),
        );
        final marker = File(
          p.join(
            (await root).parent.path,
            'dv1-visibility-reservations',
            '${medicalHash([context.ins, visibilityTarget['uniqueId']])}.json',
          ),
        );
        if (await marker.exists()) {
          throw StateError(
            'Mise en visibilité déjà réservée ou exécutée. Consultez les preuves ; aucune relance.',
          );
        }
        record['visibilityTarget'] = visibilityTarget;
        record['visibilityConfirmed'] = true;
      }
      String? archivedSubmission;
      if (depublication) {
        if (searchTarget == null || authorizationIntent != null) {
          throw StateError('Cible de dépublication requise.');
        }
        archivedSubmission = await Dv1Depublication(
          journal,
        ).prepare(searchTarget, context);
        record['depublicationConfirmed'] = true;
      }
      Map<String, dynamic>? consent;
      if (authorizationIntent != null) {
        if (!['consult', 'withdraw'].contains(authorizationIntent)) {
          throw StateError('Action inconnue.');
        }
        consent = await (await consents).latest(
          context.professional,
          context.ins,
        );
        if (consent == null ||
            consent['granted'] != (authorizationIntent == 'consult') ||
            (authorizationIntent == 'consult' &&
                consent['pendingWithdrawal'] == true)) {
          throw StateError(
            'Enregistrez la réponse du patient avant cette action.',
          );
        }
        record['patientDecision'] = consent;
      }
      context.ageAt(journal.medical.now().toLocal());
      final parameters = DmpParameters.parse(configuration.text('parameters'));
      if (context.minorsEnabled != parameters.minors ||
          context.majorityAge != parameters.majority) {
        throw StateError(
          'Les paramètres mineurs ont changé. Reprenez le choix de connexion.',
        );
      }
      if (context.professional != configuration.professional ||
          context.sector != configuration.fields['situationSector']) {
        throw StateError(
          'Le professionnel ou secteur diffère de la configuration DV1.',
        );
      }
      final app = await PackageInfo.fromPlatform();
      record['application'] = {
        'name': app.appName,
        'package': app.packageName,
        'version': app.version,
        'build': app.buildNumber,
      };
      final worker = await rootBundle.load(
        'assets/dmp_native/DmpNativeBridge.java',
      );
      record['nativeWorkerSha256'] = FinalPdfDocumentService.hash(
        worker.buffer.asUint8List(worker.offsetInBytes, worker.lengthInBytes),
      );
      final settings = Dv1ConfigurationService(journal);
      await settings.unchanged(configuration);
      record['context'] = context.snapshot;
      directory = Directory(p.join((await root).path, record['id']));
      await directory.create(recursive: true);
      await save(); // Evidence storage must work before any card/network action.
      ports = await settings.ports(
        configuration,
        requestPin,
        (_) async => throw const DmpChainBlock('Aucun dépôt dans ce parcours.'),
        accessContext: context,
        depublicationUniqueId: depublication ? searchTarget!.uniqueId : null,
      );
      final snapshot = context.snapshot;
      await DmpSetupService.requireEnabled(await journal.database);
      final session = await ports.authenticate(snapshot);
      record['session'] = session.evidence;
      record['state'] = 'authenticated';
      await save();
      await settings.unchanged(configuration);
      final request = await ports.prepareTd02(
        snapshot,
        session,
        journal.medical.now().toUtc(),
      );
      await File(
        p.join(directory.path, 'request.xml'),
      ).writeAsString(request, flush: true);
      record['requestHash'] = medicalHash(request);
      record['state'] = 'request_prepared';
      await save();
      await DmpSetupService.requireEnabled(await journal.database);
      final reply = await ports.td02(request, session);
      // Preserve raw SOAP/codeRetour, including faults, before interpretation.
      await File(
        p.join(directory.path, 'response.xml'),
      ).writeAsString(reply.xml, flush: true);
      await File(
        p.join(directory.path, 'http.txt'),
      ).writeAsString(reply.headers ?? 'HTTP ${reply.status}', flush: true);
      record['responseHash'] = medicalHash(reply.xml);
      record['httpStatus'] = reply.status;
      final result = Td02Reader.read(
        request: request,
        response: reply.xml,
        context: DmpChainMessages.context(snapshot, session),
        httpStatus: reply.status,
      );
      record['state'] = result.state == DmpState.unknown
          ? 'unconfirmed'
          : 'response_verified';
      record['dmpState'] = result.state.name;
      record['consultationRight'] = result.right.name;
      record['message'] = result.message;
      record['detail'] = result.detail;
      record['closureDetails'] = result.closureDetails;
      if (consultationTarget != null) {
        requireSearchRight(result);
        requireSearchConsent(
          await (await consents).latest(context.professional, context.ins),
        );
        final envelope = DmpNativeTd31a.build(
          context,
          session,
          await ports.wireMaterial(session),
          journal.medical.now().toUtc(),
          const Dv1DocumentCriteria(),
        );
        final query = DmpSubmissionSearch.query(
          envelope,
          DmpNativeTd31b.getDocuments,
          {
            r'$XDSDocumentEntryEntryUUID': DmpSubmissionSearch.ids([
              consultationTarget['entryUUID']!,
            ]),
          },
        );
        await File(
          p.join(directory.path, 'td32-metadata-request.xml'),
        ).writeAsString(query, flush: true);
        record['metadataRequestHash'] = medicalHash(query);
        await save();
        final metadataReply = await ports.consultationExchange(
          query,
          session,
          retrieve: false,
        );
        final metadataXml = utf8.decode(base64Decode(metadataReply['body']!));
        await File(
          p.join(directory.path, 'td32-metadata-response.xml'),
        ).writeAsString(metadataXml, flush: true);
        record['metadataResponseHash'] = medicalHash(metadataXml);
        final docs = DmpNativeTd31a.read(
          query,
          DmpTd02Reply(
            int.parse(metadataReply['status']!),
            metadataXml,
            headers: metadataReply['headers'],
          ),
          context.ins,
          const Dv1DocumentCriteria(archived: true, deprecated: true),
        );
        if (docs.length != 1 ||
            docs.single['entryUUID'] != consultationTarget['entryUUID'] ||
            docs.single['uniqueId'] != consultationTarget['uniqueId']) {
          throw StateError(
            'Document sélectionné absent ou différent. Aucune récupération.',
          );
        }
        final target = docs.single;
        DmpNativeTd32.checkMetadata(target);
        record['retrievedMetadata'] = target;
        final retrieval = DmpNativeTd32.build(envelope, target);
        await File(
          p.join(directory.path, 'td32-request.xml'),
        ).writeAsString(retrieval, flush: true);
        record['td32RequestHash'] = medicalHash(retrieval);
        record['state'] = 'consultation_requested';
        await save();
        await settings.unchanged(configuration);
        await DmpSetupService.requireEnabled(await journal.database);
        requireSearchConsent(
          await (await consents).latest(context.professional, context.ins),
        );
        final response = await ports.consultationExchange(
          retrieval,
          session,
          retrieve: true,
        );
        final raw = base64Decode(response['body']!);
        Uint8List? content;
        ConsultedDocument? viewed;
        try {
          record['td32HttpStatus'] = int.parse(response['status']!);
          record['td32ResponseSha256'] = FinalPdfDocumentService.hash(raw);
          content = DmpNativeTd32.read(
            retrieval,
            record['td32HttpStatus'],
            response['headers'] ?? '',
            raw,
            target,
          );
          record['documentSha256'] = FinalPdfDocumentService.hash(content);
          viewed = ConsultedDocument.parse(content, target, context.ins);
          record['state'] = 'document_retrieved';
          record['message'] =
              'Document récupéré et vérifié ; affichage à confirmer.';
          await save();
          final displayed = await displayDocument!(viewed);
          record['state'] = displayed
              ? 'consultation_display_verified'
              : 'consultation_display_unconfirmed';
          record['message'] = displayed
              ? 'PRE_CONS_CONS : contenu et en-tête CDA affichés et confirmés. Aucune copie documentaire conservée.'
              : 'Consultation fermée sans confirmation d’affichage. PRE_CONS_CONS non validé.';
          record['displayConfirmedAt'] = displayed
              ? journal.medical.now().toUtc().toIso8601String()
              : null;
        } finally {
          viewed?.dispose();
          content?.fillRange(0, content.length, 0);
          raw.fillRange(0, raw.length, 0);
          response.clear();
          record['documentRetention'] = 'memory_only_released';
        }
      }
      if (visibilityTarget != null) {
        requireSearchRight(result);
        requireSearchConsent(
          await (await consents).latest(context.professional, context.ins),
        );
        final material = await ports.wireMaterial(session);
        final envelope = DmpNativeTd31a.build(
          context,
          session,
          material,
          journal.medical.now().toUtc(),
          const Dv1DocumentCriteria(),
        );
        String queryFor(String id) =>
            DmpSubmissionSearch.query(envelope, DmpNativeTd31b.getDocuments, {
              r'$XDSDocumentEntryEntryUUID': DmpSubmissionSearch.ids([id]),
            });
        Future<DmpTd02Reply> exchange(
          String xml,
          String name, {
          bool update = false,
        }) async {
          await File(
            p.join(directory!.path, '$name-request.xml'),
          ).writeAsString(xml, flush: true);
          record['${name}RequestHash'] = medicalHash(xml);
          await save();
          await settings.unchanged(configuration);
          await DmpSetupService.requireEnabled(await journal.database);
          requireSearchConsent(
            await (await consents).latest(context.professional, context.ins),
          );
          final response = await ports!.visibilityExchange(
            xml,
            session,
            update: update,
          );
          await File(
            p.join(directory!.path, '$name-response.xml'),
          ).writeAsString(response.xml, flush: true);
          await File(p.join(directory!.path, '$name-http.txt')).writeAsString(
            response.headers ?? 'HTTP ${response.status}',
            flush: true,
          );
          record['${name}ResponseHash'] = medicalHash(response.xml);
          record['${name}HttpStatus'] = response.status;
          await save();
          return response;
        }

        final query = queryFor(visibilityTarget['entryUUID']!);
        final before = await exchange(query, 'td33b-before');
        final original = DmpNativeTd33b.entry(
          query,
          before,
          context.ins,
          visibilityTarget['uniqueId']!,
        );
        if (original.getAttribute('id') != visibilityTarget['entryUUID']) {
          throw StateError('Cible différente. Aucune modification.');
        }
        DmpNativeTd33b.check(original);
        final update = DmpNativeTd33b.build(
          envelope,
          original,
          context,
          session,
          material.configuration.sourceId,
          journal.medical.now().toUtc(),
        );
        final marker = File(
          p.join(
            (await root).parent.path,
            'dv1-visibility-reservations',
            '${medicalHash([context.ins, visibilityTarget['uniqueId']])}.json',
          ),
        );
        await Dv1Depublication.reserveFile(marker, {
          'historyId': record['id'],
          'requestHash': medicalHash(update),
          'state': 'reserved',
        });
        record['visibilityReserved'] = true;
        record['state'] = 'visibility_reserved';
        await save();
        final updated = await exchange(update, 'td33b', update: true);
        DmpNativeTd33b.read(update, updated);
        record['visibilityAccepted'] = true;
        record['state'] = 'visibility_accepted';
        await save();
        final expected = Td02Reader.parse(update)
            .findAllElements('ExtrinsicObject', namespaceUri: DmpNativeTd31b.rim)
            .single;
        final afterQuery = queryFor(expected.getAttribute('id')!);
        final after = await exchange(afterQuery, 'td33b-after');
        final finalEntry = DmpNativeTd33b.entry(
          afterQuery,
          after,
          context.ins,
          visibilityTarget['uniqueId']!,
        );
        DmpNativeTd33b.verifyAfter(original, expected, finalEntry);
        record['state'] = 'visibility_verified';
        record['message'] =
            'PRE_CONS_INV : document rendu visible au patient. XDS Success et visibilité relue sur DV1. Aucun contenu modifié ; renvoi bloqué.';
        record['updatedEntryUUID'] = finalEntry.getAttribute('id');
        record['logicalId'] = DmpNativeTd33b.logicalId(finalEntry);
      }
      if (submissionPeriod != null) {
        requireSearchRight(result);
        requireSearchConsent(
          await (await consents).latest(context.professional, context.ins),
        );
        final envelope = DmpNativeTd31a.build(
          context,
          session,
          await ports.wireMaterial(session),
          journal.medical.now().toUtc(),
          const Dv1DocumentCriteria(),
        );
        final exchanges = <Map<String, dynamic>>[];
        record['submissionExchanges'] = exchanges;
        final found = await DmpSubmissionSearch().run(
          envelope: envelope,
          ins: context.ins,
          period: submissionPeriod,
          exchange: (stage, query) async {
            final name = 'td31sub-${exchanges.length + 1}-$stage';
            final entry = <String, dynamic>{
              'stage': stage,
              'files': name,
              'requestHash': medicalHash(query),
            };
            exchanges.add(entry);
            await File(
              p.join(directory!.path, '$name-request.xml'),
            ).writeAsString(query, flush: true);
            record['state'] = 'submission_search_requested';
            record['message'] =
                'Recherche par date de dépôt en cours — résultat non confirmé.';
            await save();
            await settings.unchanged(configuration);
            await DmpSetupService.requireEnabled(await journal.database);
            requireSearchConsent(
              await (await consents).latest(context.professional, context.ins),
            );
            final response = await ports!.searchSubmission(
              query,
              session,
              stage,
            );
            await File(
              p.join(directory!.path, '$name-response.xml'),
            ).writeAsString(response.xml, flush: true);
            await File(p.join(directory!.path, '$name-http.txt')).writeAsString(
              response.headers ?? 'HTTP ${response.status}',
              flush: true,
            );
            entry['responseHash'] = medicalHash(response.xml);
            entry['httpStatus'] = response.status;
            await save();
            return response;
          },
        );
        record.addAll(found);
        final documents = (found['documents'] as List)
            .cast<Map<String, String>>();
        final missing = found['unreturnedDocumentIds'] as List;
        record['state'] = missing.isNotEmpty
            ? 'submission_search_incomplete'
            : documents.isEmpty
            ? 'submission_search_empty'
            : 'submission_search_verified';
        record['message'] = missing.isNotEmpty
            ? 'Recherche incomplète : ${missing.length} membre(s) de lot non retourné(s). PRE_CONS_SUB non validé.'
            : documents.isEmpty
            ? 'Aucun document trouvé dans cette période de dépôt. PRE_CONS_SUB reste à vérifier.'
            : '${documents.length} document(s) trouvé(s) par date de dépôt sur DV1. Métadonnées vérifiées et conservées.';
        record['detail'] = [
          submissionPeriod.label,
          if ((found['omittedSignatureIds'] as List).isNotEmpty)
            '${(found['omittedSignatureIds'] as List).length} signature(s) de lots identifiée(s) par les associations signs, non retournée(s) par DV1. Distinctes des documents recherchés.',
          ...documents.map(
            (d) =>
                "${d['title']} · ${d['typeLabel']}\nDépôt UTC : ${d['submissionTime']} · ${d['status']}\n${d['uniqueId']} · ${d['entryUUID']}",
          ),
        ].join('\n\n');
      }
      if (criteria != null) {
        requireSearchRight(result);
        requireSearchConsent(
          await (await consents).latest(context.professional, context.ins),
        );
        final query = DmpNativeTd31a.build(
          context,
          session,
          await ports.wireMaterial(session),
          journal.medical.now().toUtc(),
          criteria,
        );
        await File(
          p.join(directory.path, 'td31a-request.xml'),
        ).writeAsString(query, flush: true);
        record['td31aRequestHash'] = medicalHash(query);
        record['state'] = 'criteria_search_requested';
        record['message'] =
            'Recherche par critères demandée — résultat non confirmé.';
        await save();
        await settings.unchanged(configuration);
        await DmpSetupService.requireEnabled(await journal.database);
        final response = await ports.findDocuments(query, session);
        await File(
          p.join(directory.path, 'td31a-response.xml'),
        ).writeAsString(response.xml, flush: true);
        await File(p.join(directory.path, 'td31a-http.txt')).writeAsString(
          response.headers ?? 'HTTP ${response.status}',
          flush: true,
        );
        record['td31aResponseHash'] = medicalHash(response.xml);
        record['td31aHttpStatus'] = response.status;
        await save();
        final documents = DmpNativeTd31a.read(
          query,
          response,
          context.ins,
          criteria,
        );
        record['documents'] = documents;
        record['state'] = documents.isEmpty
            ? 'criteria_search_empty'
            : 'criteria_search_verified';
        record['message'] = documents.isEmpty
            ? 'Recherche acceptée par DV1, aucun document trouvé pour ces critères. ${context.scenario} reste à vérifier.'
            : '${documents.length} document(s) trouvé(s) par critères sur DV1. Métadonnées vérifiées et conservées.';
        record['detail'] = [
          criteria.label,
          if (criteria.uniqueIds.isNotEmpty)
            ...criteria.uniqueIds.map(
              (id) =>
                  '$id : ${documents.any((d) => d['uniqueId'] == id) ? 'retrouvé' : 'non trouvé ou non accessible'}',
            ),
          ...documents.map(
            (d) =>
                '${d['title']} · ${d['typeLabel']} (${d['typeCode']})\n${d['status']} · ${d['creationTime']}\n${d['uniqueId']} · ${d['entryUUID']}\nConfidentialité : ${d['confidentiality']}',
          ),
        ].join('\n\n');
      }
      if (searchTarget != null) {
        if (result.state != DmpState.active) {
          throw StateError('DMP non actif : recherche non effectuée.');
        }
        await Dv1SearchTargets(journal).verify(searchTarget);
        final query = DmpNativeTd31b.build(
          context,
          session,
          await ports.wireMaterial(session),
          journal.medical.now().toUtc(),
          searchTarget.uniqueId,
        );
        await File(
          p.join(directory.path, 'td31b-request.xml'),
        ).writeAsString(query, flush: true);
        record['td31bRequestHash'] = medicalHash(query);
        record['state'] = 'search_requested';
        record['message'] = 'Recherche demandée — résultat non confirmé.';
        await save();
        await settings.unchanged(configuration);
        await DmpSetupService.requireEnabled(await journal.database);
        final response = await ports.searchDocument(query, session);
        await File(
          p.join(directory.path, 'td31b-response.xml'),
        ).writeAsString(response.xml, flush: true);
        await File(p.join(directory.path, 'td31b-http.txt')).writeAsString(
          response.headers ?? 'HTTP ${response.status}',
          flush: true,
        );
        record['td31bResponseHash'] = medicalHash(response.xml);
        record['td31bHttpStatus'] = response.status;
        await save();
        final ids = DmpNativeTd31b.read(query, response);
        record['technicalIds'] = ids;
        record['state'] = ids.length == 1
            ? 'document_found'
            : ids.isEmpty
            ? 'document_not_found'
            : 'search_ambiguous';
        record['message'] = ids.length == 1
            ? 'Document retrouvé dans le DMP. Identifiant technique conservé.'
            : ids.isEmpty
            ? 'Aucun document accessible ne correspond à cet identifiant.'
            : 'Plusieurs documents correspondent : résultat ambigu, aucune sélection automatique.';
        record['detail'] =
            'Identifiant local : ${searchTarget.uniqueId}\n${ids.join('\n')}';
        if (depublication) {
          if (ids.length != 1) {
            throw StateError(
              'Cible absente ou ambiguë : aucune dépublication.',
            );
          }
          final update = DmpNativeTd33c.build(
            DmpNativeTd31b.build(
              context,
              session,
              await ports.wireMaterial(session),
              journal.medical.now().toUtc(),
              searchTarget.uniqueId,
            ),
            archivedSubmission!,
            ids.single,
            journal.medical.now().toUtc(),
          );
          await File(
            p.join(directory.path, 'td33c-request.xml'),
          ).writeAsString(update, flush: true);
          record['td33cRequestHash'] = medicalHash(update);
          await settings.unchanged(configuration);
          await DmpSetupService.requireEnabled(await journal.database);
          await Dv1Depublication(
            journal,
          ).reserve(searchTarget, context, record['id'], update);
          record['depublicationReserved'] = true;
          record['state'] = 'depublication_reserved';
          record['message'] =
              'Dépublication réservée ; résultat non confirmé, renvoi bloqué.';
          await save();
          final deletedReply = await ports.depublicate(update, session);
          await File(
            p.join(directory.path, 'td33c-response.xml'),
          ).writeAsString(deletedReply.xml, flush: true);
          await File(p.join(directory.path, 'td33c-http.txt')).writeAsString(
            deletedReply.headers ?? 'HTTP ${deletedReply.status}',
            flush: true,
          );
          record['td33cHttpStatus'] = deletedReply.status;
          record['td33cResponseHash'] = medicalHash(deletedReply.xml);
          await save();
          DmpNativeTd33c.read(update, deletedReply);
          record['state'] = 'document_deleted';
          record['message'] =
              'Dépublication confirmée par DV1 — XDS Success (PRE_ALIM_SUPPR). Renvoi bloqué.';
          record['detail'] =
              'Document ${searchTarget.uniqueId} · identifiant technique ${ids.single} · statut demandé Deleted. Copie locale conservée.';
        }
      }
      if (authorizationIntent != null) {
        final granted = authorizationIntent == 'consult';
        final change = authorizationChange(
          result,
          granted: granted,
          consultationRequested: granted,
        );
        record['authorizationAction'] = change.name;
        if (change != AuthorizationChange.none) {
          final request03 = DmpNativeTd03.build(
            context,
            session,
            await ports.wireMaterial(session),
            journal.medical.now().toUtc(),
            add: change == AuthorizationChange.add,
          );
          await File(
            p.join(directory.path, 'td03-request.xml'),
          ).writeAsString(request03, flush: true);
          record['td03RequestHash'] = medicalHash(request03);
          record['state'] = 'authorization_requested';
          record['message'] = 'Modification demandée — résultat non confirmé.';
          await save(); // Archive before the non-idempotent server mutation.
          await DmpSetupService.requireEnabled(await journal.database);
          final reply03 = await ports.updateAuthorization(request03, session);
          await File(
            p.join(directory.path, 'td03-response.xml'),
          ).writeAsString(reply03.xml, flush: true);
          await File(p.join(directory.path, 'td03-http.txt')).writeAsString(
            reply03.headers ?? 'HTTP ${reply03.status}',
            flush: true,
          );
          record['td03ResponseHash'] = medicalHash(reply03.xml);
          record['td03HttpStatus'] = reply03.status;
          await save();
          final parsed = DmpNativeTd03.read(request03, reply03);
          record['td03Status'] = parsed.status;
          record['td03Detail'] = parsed.detail;
          await save();
          if (parsed.status != 'DMPOk') {
            throw StateError(
              'Modification refusée par le DMP : ${parsed.status}. ${parsed.detail}',
            );
          }
          await DmpSetupService.requireEnabled(await journal.database);
          final after = await ports.recheckAuthorization(session);
          await File(
            p.join(directory.path, 'td02-after-request.xml'),
          ).writeAsString(after.request, flush: true);
          await File(
            p.join(directory.path, 'td02-after-response.xml'),
          ).writeAsString(after.reply.xml, flush: true);
          await File(
            p.join(directory.path, 'td02-after-http.txt'),
          ).writeAsString(
            after.reply.headers ?? 'HTTP ${after.reply.status}',
            flush: true,
          );
          record['afterRequestHash'] = medicalHash(after.request);
          record['afterResponseHash'] = medicalHash(after.reply.xml);
          record['afterHttpStatus'] = after.reply.status;
          final verified = Td02Reader.read(
            request: after.request,
            response: after.reply.xml,
            context: DmpChainMessages.context(snapshot, session),
            httpStatus: after.reply.status,
          );
          record['afterConsultationRight'] = verified.right.name;
          record['afterDmpState'] = verified.state.name;
          await save();
          if (verified.state != DmpState.active ||
              (granted
                  ? verified.right != ConsultationRight.valid
                  : ![
                      ConsultationRight.absent,
                      ConsultationRight.expired,
                    ].contains(verified.right))) {
            throw StateError(
              'TD0.3 accepté, mais nouvel état non confirmé. Aucune consultation.',
            );
          }
        }
        if (!granted) {
          await (await consents).save(
            context.professional,
            context.ins,
            patient: context.patientLabel,
            source: context.source,
            granted: false,
            pendingWithdrawal: false,
            now: journal.medical.now(),
            evidenceId: record['id'],
          );
        }
        record['state'] = 'authorization_verified';
        record['message'] = granted
            ? 'Autorisation de consultation confirmée par le DMP. Aucun document consulté dans cet essai.'
            : 'Refus enregistré — absence d’autorisation confirmée par le DMP.';
      }
    } catch (e) {
      record['state'] = 'interrupted';
      record['message'] = e is DmpChainBlock
          ? e.message
          : e is StateError
          ? e.message.toString()
          : 'Opération interrompue. Configuration, stockage ou service natif indisponible.';
      if (e is DmpNativeFailure) record['errorCode'] = e.code;
      if (record['visibilityReserved'] == true) {
        record['state'] = record['visibilityAccepted'] == true
            ? 'visibility_accepted_verification_failed'
            : 'visibility_unconfirmed';
        record['message'] =
            '${record['message']} Mise en visibilité ${record['visibilityAccepted'] == true ? 'acceptée, vérification finale incomplète' : 'non confirmée'} ; renvoi bloqué.';
      }
      if (record['depublicationReserved'] == true) {
        record['state'] = 'depublication_unconfirmed';
        record['message'] =
            '${record['message']} Dépublication non confirmée ; renvoi bloqué. Consultez les preuves avant toute décision.';
      }
      if (record['td03Status'] == 'DMPOk') {
        record['state'] = 'authorization_applied_verification_failed';
        record['message'] =
            'Le DMP a confirmé la modification : ${record['td03Detail'] ?? 'DMPOk'}. '
            'La vérification finale reste à effectuer.\n${record['message']}';
      }

      if (authorizationIntent == 'withdraw') {
        record['message'] =
            'Refus enregistré — retrait auprès du DMP non confirmé. Consultation bloquée.\n${record['message']}';
      }
    } finally {
      try {
        if (ports != null) {
          ports.retainAuthentication = [
            'criteria_search_verified',
            'criteria_search_empty',
            'submission_search_verified',
            'submission_search_empty',
            'response_verified',
            'authorization_verified',
            'document_found',
            'document_not_found',
            'search_ambiguous',
          ].contains(record['state']);
          await ports.closeSession();
          record['transactionClosed'] = true;
          record['authenticationRetainedAtEnd'] = ports.authenticationRetained;
          record['sessionClosed'] = !ports.authenticationRetained;
        }
      } catch (_) {
        record['sessionClosed'] = false;
        record['state'] = 'closure_failed';
        record['message'] =
            'Fermeture CPS non confirmée. Aucun nouvel essai avant fermeture de Companion.';
      }
      record['finishedAt'] = journal.medical.now().toUtc().toIso8601String();
      try {
        await save();
      } catch (_) {
        record['archiveError'] =
            'Résultat final non enregistré. Conservez cet écran ; ne déclarez pas cet essai conforme.';
      }
      _busy = false;
    }
    return {
      ...record,
      if (directory != null) 'evidenceDirectory': directory.path,
    };
  }

  static void requireSearchConsent(Map<String, dynamic>? decision) {
    if (decision?['granted'] != true ||
        decision?['pendingWithdrawal'] == true) {
      throw StateError(
        'Enregistrez l’accord de consultation du patient fictif avant la recherche.',
      );
    }
  }

  static void requireSearchRight(Td02Result result) {
    if (result.state != DmpState.active ||
        result.right != ConsultationRight.valid) {
      throw StateError(
        'DMP actif et autorisation de consultation valide requis. Utilisez le parcours « Demander la consultation du DMP » avant de rechercher. Aucun droit modifié par cette recherche.',
      );
    }
  }

  /// Selection must originate in an integrity-checked search for the same INS.
  Future<void> verifyConsultationTarget(
    Map<String, String> target,
    Dv1AccessContext context,
  ) async {
    final rows = await history();
    final matching = rows.where(
      (r) =>
          r['id'] == target['evidenceId'] &&
          r['integrity'] == true &&
          [
            'criteria_search_verified',
            'submission_search_verified',
          ].contains(r['state']),
    );
    if (matching.length != 1) {
      throw StateError('Preuve de recherche absente ou altérée.');
    }
    final row = matching.single;
    final identity = (row['context'] as Map)['identity'] as Map;
    if ('${identity['ins_number']}${identity['ins_key']}' != context.ins ||
        identity['ins_oid'] != '1.2.250.1.213.1.4.10') {
      throw StateError(
        'Le document sélectionné appartient à un autre patient.',
      );
    }
    final docs = (row['documents'] as List).where(
      (d) =>
          d['entryUUID'] == target['entryUUID'] &&
          d['uniqueId'] == target['uniqueId'],
    );
    if (docs.length != 1) {
      throw StateError('Document absent ou ambigu dans la recherche.');
    }
  }

  Future<List<Map<String, dynamic>>> history() async {
    final dir = await root;
    if (!await dir.exists()) return [];
    final rows = <Map<String, dynamic>>[];
    await for (final item in dir.list(followLinks: false)) {
      if (item is! Directory) continue;
      try {
        final envelope = jsonDecode(
          await File(p.join(item.path, 'result.json')).readAsString(),
        );
        final record = Map<String, dynamic>.from(envelope['record']);
        rows.add({
          ...record,
          'evidenceDirectory': item.path,
          'integrity': medicalHash(record) == envelope['sha256'],
        });
      } catch (_) {
        rows.add({
          'message': 'Preuve incomplète ou illisible — essai à examiner.',
          'evidenceDirectory': item.path,
          'integrity': false,
        });
      }
    }
    rows.sort((a, b) => '${b['startedAt']}'.compareTo('${a['startedAt']}'));
    return rows;
  }
}
