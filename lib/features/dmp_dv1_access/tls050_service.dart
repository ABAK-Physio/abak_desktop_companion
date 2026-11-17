import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../cps/cps_access_service.dart';
import '../cps/cps_operation_lease.dart';
import '../dmp_session/dmp_work_context.dart';
import '../dmp_setup/dmp_setup_service.dart';
import '../patients/services/document_journal_service.dart';
import '../patients/services/document_medical_service.dart';
import '../patients/services/document_native_controls.dart';
import '../patients/services/final_pdf_document_service.dart';
import '../patients/services/dmp_chain/contracts.dart';
import '../patients/services/dmp_chain/native/access_context.dart';
import '../patients/services/dmp_chain/native/bridge.dart';
import '../patients/services/dmp_chain/native/dv1_configuration.dart';
import '../patients/services/dmp_chain/native/ports.dart';
import '../patients/services/dmp_chain/native/td02.dart';
import '../patients/services/dmp_chain/wire/package.dart';
import 'tls050_recipe.dart';
import 'tls050_preparation_diagnostic.dart';
import 'tls050_cps_practice.dart';

class Tls050Service {
  Tls050Service(this.journal) : settings = Dv1ConfigurationService(journal);
  final DocumentJournalService journal;
  final Dv1ConfigurationService settings;
  static bool _busy = false;
  Future<Directory> get root async => Directory(
    p.join((await journal.controls.root).path, 'dv1-tls-050-history'),
  );

  Future<Directory> directory(String id) async {
    if (!RegExp(r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$').hasMatch(id)) {
      throw StateError('Identifiant de série invalide.');
    }
    final parent = await root;
    await parent.create(recursive: true);
    await LocalDocumentControlRunner.regular(parent.path, directory: true);
    final dir = Directory(p.join(parent.path, id));
    if (await dir.exists()) {
      await LocalDocumentControlRunner.regular(dir.path, directory: true);
    }
    return dir;
  }

  Future<Map<String, dynamic>> load(String id) async {
    final dir = await directory(id);
    final file = File(p.join(dir.path, '00_Serie.json'));
    await LocalDocumentControlRunner.regular(file.path);
    if (await file.length() > 4 * 1024 * 1024) {
      throw StateError('Archive trop volumineuse.');
    }
    final envelope = jsonDecode(await file.readAsString()) as Map;
    final record = Map<String, dynamic>.from(envelope['record'] as Map);
    if (medicalHash(record) != envelope['sha256']) {
      throw StateError('Archive de recette modifiée.');
    }
    Tls050Recipe.requireCampaign(
      record,
      record['configurationHash'] as String,
      record['trustHash'] as String,
    );
    final manifest = File(p.join(dir.path, '99_Inventaire_SHA256.txt'));
    await LocalDocumentControlRunner.regular(manifest.path);
    final expected = <String, String>{};
    for (final line in await manifest.readAsLines()) {
      final match = RegExp(r'^([0-9a-f]{64})  ([A-Za-z0-9_.-]+)$')
          .firstMatch(line);
      if (match == null || expected.containsKey(match.group(2))) {
        throw StateError('Inventaire de preuves invalide.');
      }
      expected[match.group(2)!] = match.group(1)!;
    }
    final observed = <String>{};
    await for (final entity in dir.list(followLinks: false)) {
      final name = p.basename(entity.path);
      if (name == '99_Inventaire_SHA256.txt') continue;
      if (entity is! File) throw StateError('Entrée de preuve inattendue.');
      await LocalDocumentControlRunner.regular(entity.path);
      if (FinalPdfDocumentService.hash(await entity.readAsBytes()) !=
          expected[name]) {
        throw StateError(
          'Fichier de preuve absent de l’inventaire ou modifié.',
        );
      }
      observed.add(name);
    }
    if (observed.length != expected.length ||
        !observed.containsAll(expected.keys)) {
      throw StateError('Preuves locales incomplètes.');
    }
    return record;
  }

  Future<List<Map<String, dynamic>>> history() async {
    final parent = await root;
    if (!await parent.exists()) return [];
    final result = <Map<String, dynamic>>[];
    await for (final entity in parent.list(followLinks: false)) {
      if (entity is! Directory ||
          !RegExp(r'^[0-9a-f-]{36}$').hasMatch(p.basename(entity.path))) {
        continue;
      }
      try {
        result.add(await load(p.basename(entity.path)));
      } catch (_) {
        /* incomplete series is never resumed */
      }
    }
    result.sort(
      (a, b) => (b['startedAt'] as String).compareTo(a['startedAt'] as String),
    );
    return result;
  }

  Future<void> save(Directory dir, Map<String, dynamic> record) async {
    final pending = File(p.join(dir.path, '00_Serie.pending'));
    await pending.writeAsString(
      jsonEncode({'record': record, 'sha256': medicalHash(record)}),
      flush: true,
    );
    await pending.rename(p.join(dir.path, '00_Serie.json'));
    final inventory = <String>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File ||
          p.basename(entity.path) == '99_Inventaire_SHA256.txt') {
        continue;
      }
      await LocalDocumentControlRunner.regular(entity.path);
      inventory.add(
        '${FinalPdfDocumentService.hash(await entity.readAsBytes())}  ${p.basename(entity.path)}',
      );
    }
    inventory.sort();
    await File(p.join(dir.path, '99_Inventaire_SHA256.txt'))
        .writeAsString('${inventory.join('\n')}\n', flush: true);
  }

  Future<Map<String, dynamic>> start(Dv1Configuration config) async {
    if (_busy) throw StateError('Une recette TLS est déjà en cours.');
    _busy = true;
    try {
      await DmpSetupService.requireEnabled(await journal.database);
      DmpWorkContext.current.requireProfessional(config.professional);
      await settings.unchanged(config);
      final record = <String, dynamic>{
        'schema': 1,
        'test': Tls050Recipe.code,
        'id': const Uuid().v4(),
        'platform': Platform.operatingSystem,
        'startedAt': journal.medical.now().toUtc().toIso8601String(),
        'configurationHash': config.hash,
        'configurationRevision': config.revision,
        'workerHash': await settings.workerHash(),
        'trustHash': config.resources['trust']['sha256'],
        'professional': config.professional,
        'source': Tls050Recipe.source,
        'patient': Tls050Recipe.patient,
        'ins': Tls050Recipe.ins,
        'software': {
          for (final k in ['lpsName', 'lpsVersion', 'lpsId', 'homologationId'])
            k: config.fields[k],
        },
        'steps': <dynamic>[],
        'globalResult': 'not_assessed',
      };
      final dir = await directory(record['id']);
      await dir.create();
      await File(p.join(dir.path, '01_Notice.txt')).writeAsString(
        'Recette 0.1-050. Trois étapes explicites, même configuration et même SHA-256 des autorités/CRL.\n'
        'Transaction choisie : TD0.2 TEST_EXST, Cas1. Aucun dépôt ni changement d’autorisation.\n'
        'Les requêtes XML sont celles préparées pour l’envoi. Consulter requestState dans les résultats : completed, started_or_partial, not_started.\n'
        'En cas de rejet TLS avant envoi, aucune réponse SOAP n’est créée. Un échec DNS, réseau, carte ou de configuration ne valide pas un rejet de certificat.\n'
        'Aucune déclaration de conformité globale ni CN/AlternativeNames LPS2 n’est validée automatiquement par cet outil.\n',
        flush: true,
      );
      await save(dir, record);
      return record;
    } finally {
      _busy = false;
    }
  }

  Future<Map<String, dynamic>> execute({
    required String campaignId,
    required int step,
    required Dv1Configuration config,
    required Future<String?> Function() requestPin,
    void Function(String)? progress,
  }) async {
    if (_busy) throw StateError('Une recette TLS est déjà en cours.');
    _busy = true;
    CpsOperationLease? lease;
    DocumentDmpNativePorts? ports;
    Map<String, dynamic>? record;
    Directory? dir;
    Map<String, dynamic>? attempt;
    var stage = 'PREPARATION';
    var preparationStage = 'activation du DMP';
    var confirmationReceived = false;
    var closed = true;
    try {
      await DmpSetupService.requireEnabled(await journal.database);
      preparationStage = 'contexte du praticien';
      final checkContext = DmpWorkContext.current.bind(config.professional);
      checkContext();
      preparationStage = 'vérification de la configuration';
      await settings.unchanged(config);
      preparationStage = 'lecture et contrôle des fichiers de la série';
      record = await load(campaignId);
      preparationStage = 'vérification du moteur de la série';
      if (record['workerHash'] != await settings.workerHash()) {
        throw StateError(
          'Le moteur TLS a changé. Préparez une nouvelle série.',
        );
      }
      preparationStage = 'ordre des étapes';
      Tls050Recipe.requireNext(
        record,
        step,
        config.hash,
        config.resources['trust']['sha256'],
      );
      // Preparing the worker verifies frozen files but opens neither card nor network.
      preparationStage = 'préparation des fichiers du moteur';
      ports = await settings.ports(
        config,
        () async => null,
        (_) async => throw StateError('Aucun dépôt pour 0.1-050.'),
      );
      preparationStage = 'ouverture du dialogue de confirmation';
      var pin = await requestPin();
      if (pin == null) return record;
      confirmationReceived = true;
      if (!RegExp(r'^\d{1,16}$').hasMatch(pin)) {
        throw DmpNativeFailure('CPS_PIN');
      }
      checkContext();
      await settings.unchanged(config);
      lease = await CpsOperationLease.acquireAvailable();
      dir = await directory(campaignId);
      attempt = {
        'step': step,
        'endpoint': Tls050Recipe.endpoint(step),
        'baseUrl': Tls050Recipe.bases[step - 1],
        'configurationHash': config.hash,
        'trustHash': config.resources['trust']['sha256'],
        'startedAt': journal.medical.now().toUtc().toIso8601String(),
        'outcome': 'not_conclusive',
        'requestState': 'not_started',
        'stage': stage,
      };
      (record['steps'] as List).add(attempt);
      await save(dir, record);
      stage = 'CARD';
      progress?.call('Lecture de la CPS et contrôle du signataire…');
      final profile = await const CpsAccessService().read(pin, lease: lease);
      final situationNumber = ports.configuration.situationNumber;
      String structure;
      try {
        structure = tls050CpsStructure(
          profile,
          professional: config.professional,
          situationNumber: situationNumber,
          situationMode: ports.configuration.situationMode,
          situationStatus: ports.configuration.situationStatus,
          situationSector: ports.configuration.situationSector,
        );
      } on StateError {
        throw DmpNativeFailure('CPS_IDENTITY');
      }
      final context = Dv1AccessContext(
        professional: config.professional,
        structure: structure,
        sector: ports.configuration.situationSector,
        ins: Tls050Recipe.ins,
        patientLabel: Tls050Recipe.patient,
        source: Tls050Recipe.source,
        scenario: Tls050Recipe.code,
        confirmedAt: journal.medical.now().toUtc(),
        birthDate: Tls050Recipe.birth,
      );
      final situation = profile.situations.singleWhere(
        (s) => s.number == situationNumber,
      );
      if (!context.matches(profile, situation, journal.medical.now().toUtc())) {
        throw DmpNativeFailure('CPS_IDENTITY');
      }
      checkContext();
      stage = 'TLS';
      progress?.call('Étape $step : vérification TLS du serveur…');
      final native = await ports.bridge.call('tlsrecipeopen', {
        'step': '$step',
        'professional': config.professional,
        'pin': pin,
        for (final k in [
          'library',
          'trustPath',
          'trustHash',
          'authHash',
          'signHash',
        ])
          k: ports.configuration.fields[k]!,
      });
      pin = '';
      attempt.addAll(native);
      // JSON numeric step remains stable even though worker protocol values are strings.
      attempt['step'] = step;
      attempt['nativeTls'] = native;
      if (native['endpoint'] != Tls050Recipe.endpoint(step) ||
          native['trustHash'] != config.resources['trust']['sha256']) {
        throw DmpNativeFailure('NATIVE_PROTOCOL');
      }
      if (native['outcome'] == 'tls_accepted') {
        checkContext();
        await settings.unchanged(config);
        final issued = DateTime.parse(native['issuedAt']!).toUtc(),
            expires = DateTime.parse(native['expiresAt']!).toUtc();
        final time = journal.medical.now().toUtc();
        if (native['professional'] != config.professional ||
            native['authHash'] != ports.configuration.authenticationHash ||
            native['signHash'] != ports.configuration.signingHash ||
            native['mutualTls'] != 'true' ||
            native['protocol'] != 'TLSv1.2' ||
            ![
              'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
              'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
            ].contains(native['cipher']) ||
            issued.isAfter(time) ||
            !expires.isAfter(issued) ||
            expires.difference(issued) > const Duration(minutes: 2)) {
          throw DmpNativeFailure('NATIVE_PROTOCOL');
        }
        final session = DmpSession(
          id: native['id']!,
          professional: config.professional,
          authority: '1.2.250.1.71.4.2.1',
          structure: context.structure,
          certificateHash: native['authHash']!,
          contextHash: medicalHash(context.snapshot),
          issuedAt: issued,
          expiresAt: expires,
        );
        final material = DmpWireMaterial(
          configuration: ports.configuration.wire,
          authenticationDer: native['authDer']!,
          signingDer: native['signDer']!,
          authenticationHash: native['authHash']!,
          signingHash: native['signHash']!,
          professional: config.professional,
          assessmentId: session.id,
          assessedAt: issued,
          validUntil: expires,
          trustedAndNotRevoked: true,
        );
        final normal = DmpNativeTd02.build(
          context.snapshot,
          session,
          material,
          time,
          Dv1AccessContext.endpoint,
          processingMode: 'T',
          accessContext: context,
        );
        final request = Tls050Recipe.requestForStep(normal, step);
        await File(p.join(dir.path, '${step}_REQUETE_LPS.xml'))
            .writeAsString(request, flush: true);
        attempt['requestSha256'] = FinalPdfDocumentService.hash(
          utf8.encode(request),
        );
        stage = 'EXCHANGE';
        progress?.call('TLS acceptée. Envoi du test d’existence TD0.2…');
        checkContext();
        await settings.unchanged(config);
        // Once submitted to the worker, a failed protocol/worker response cannot
        // prove absence of emission. The pending archive preserves that uncertainty.
        attempt['requestState'] = 'started_or_partial';
        await save(dir, record);
        final response = await ports.bridge.call('tlsrecipetd', {
          'id': session.id,
          'body': base64Encode(utf8.encode(request)),
          'contentType':
              'application/soap+xml; charset=UTF-8; action="${DmpNativeTd02.action}"',
        });
        if (response['endpoint'] != Tls050Recipe.endpoint(step) ||
            response['trustHash'] != config.resources['trust']['sha256']) {
          throw DmpNativeFailure('NATIVE_PROTOCOL');
        }
        attempt.addAll(Map<String, String>.from(response)..remove('body'));
        attempt['step'] = step;
        attempt['nativeExchange'] = Map<String, String>.from(response)
          ..remove('body');
        if (response['outcome'] == 'http_received') {
          final bytes = Tls050Recipe.responseBytes(response);
          await File(p.join(dir.path, '${step}_REPONSE_DMP.bin'))
              .writeAsBytes(bytes, flush: true);
          attempt['responseSha256'] = FinalPdfDocumentService.hash(bytes);
          attempt['responseBytes'] = bytes.length;
          attempt['responseSummary'] = Tls050Recipe.responseSummary(bytes);
          final headers = response['headers'] ?? '';
          await File(p.join(dir.path, '${step}_Entetes_HTTP.txt'))
              .writeAsString(headers, flush: true);
          // Preserve exact bytes; only label as XML when parsing succeeds.
          var isXml = false;
          try {
            XmlDocument.parse(utf8.decode(bytes));
            isXml = true;
          } catch (_) {
            /* exact binary response is already retained */
          }
          if (isXml) {
            await File(p.join(dir.path, '${step}_REPONSE_DMP.xml'))
                .writeAsBytes(bytes, flush: true);
          }
        }
      }
    } catch (e, stack) {
      if (attempt == null) {
        if (!confirmationReceived && e is! StateError && e is! DmpChainBlock) {
          throw StateError(
            tls050PreparationDiagnostic(e, stack, preparationStage),
          );
        }
        rethrow;
      }
      attempt['outcome'] = 'not_conclusive';
      attempt['stage'] = stage;
      attempt['error'] = e is DmpNativeFailure
          ? e.code
          : 'LOCAL_PREPARATION_OR_IO';
    } finally {
      try {
        try {
          await ports?.closeSession();
        } catch (_) {
          closed = false;
        }
        // Release only after worker exit is confirmed.
        if (closed) lease?.release();
        if (attempt != null && record != null && dir != null) {
          attempt['sessionClosed'] = closed;
          if (!closed) {
            attempt['outcome'] = 'not_conclusive';
            attempt['error'] = 'CLOSE_NOT_CONFIRMED';
          }
          attempt['finishedAt'] = journal.medical
              .now()
              .toUtc()
              .toIso8601String();
          attempt['message'] = Tls050Recipe.describe(attempt);
          final log =
              'test=0.1-050\nstep=$step\nendpoint=${attempt['endpoint']}\ntrustHash=${attempt['trustHash']}\n'
              'configurationHash=${attempt['configurationHash']}\n'
              'outcome=${attempt['outcome']}\nstage=${attempt['stage']}\nerror=${attempt['error'] ?? ''}\n'
              'requestState=${attempt['requestState']}\nsessionClosed=$closed\n${attempt['diagnostic'] ?? ''}';
          await File(p.join(dir.path, '${step}_Connexion.log'))
              .writeAsString(log, flush: true);
          await File(p.join(dir.path, '${step}_Resultat.json')).writeAsString(
            jsonEncode({'record': attempt, 'sha256': medicalHash(attempt)}),
            flush: true,
          );
          if (attempt['requestState'] == 'not_started') {
            await File(
              p.join(dir.path, '${step}_REQUETE_NON_EMISE.txt'),
            ).writeAsString(
              'Aucun appel SOAP démarré. Voir ${step}_Connexion.log et ${step}_Resultat.json.\n',
              flush: true,
            );
          }
          await save(dir, record);
        }
      } finally {
        _busy = false;
      }
    }
    return record!;
  }
}
