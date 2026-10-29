import '../../../../cps/cps_operation_lease.dart';
import 'authentication_cache.dart';
import '../../../../dmp_session/dmp_work_context.dart';
import 'dart:convert';
import 'dart:io';
import '../../../../dmp_setup/bundled_pdf_tools.dart';
import '../../../../../core/settings/macos_directory_access_service.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import '../../../../dmp_resources/dmp_resources.dart';
import '../../../../dmp_resources/nos_import.dart';
import '../../document_journal_service.dart';
import '../../document_medical_service.dart';
import '../../document_native_controls.dart';
import '../../final_pdf_document_service.dart';
import '../contracts.dart';
import '../wire/crypto.dart';
import '../wire/package.dart';
import 'bridge.dart';
import 'access_context.dart';
import 'ports.dart';

class Dv1Configuration {
  Dv1Configuration(this.row);
  final MedicalRow row;
  int get revision => row['revision'] as int;
  String get hash => row['data_hash'] as String;
  Map<String, dynamic> get data => jsonDecode(row['data_json'] as String);
  Map get fields => data['fields'];
  Map get resources => data['resources'];
  String get professional => fields['professionalId'];
  static const td02 =
      'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/patients';
  static const repository =
      'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository';
  static const nosFiles = {
    'specialty': 'JDV_J56-AuthorSpecialty-DMP.tabs',
    'type': 'JDV_J66-TypeCode-DMP.tabs',
    'class': 'JDV_J57-ClassCode-DMP.tabs',
    'confidentiality': 'JDV_J58-ConfidentialityCode-DMP.tabs',
    'content': 'JDV_J59-ContentTypeCode-DMP.tabs',
    'format': 'JDV_J60-FormatCode-DMP.tabs',
    'facility': 'JDV_J61-HealthcareFacilityTypeCode-DMP.tabs',
    'practice': 'JDV_J62-PracticeSettingCode-DMP.tabs',
    'typeClass': 'ASS_X16-CorrespondanceType-Classe-DMP.tabs',
    'mediaFormat':
        'ASS_A12-CorresMediaTypeCDANonStructure-XdsFormatCode-CISIS-FHIR.json',
  };
  static DmpWireCertificate certificate(List<int> bytes) {
    final text = utf8.decode(bytes, allowMalformed: true);
    if (text.contains('PRIVATE KEY')) {
      throw const FormatException(
        'Sélectionnez uniquement un certificat public.',
      );
    }
    final pem = RegExp(
      r'-----BEGIN CERTIFICATE-----([\s\S]*?)-----END CERTIFICATE-----',
    ).allMatches(text).toList();
    if (pem.isNotEmpty && pem.length != 1) {
      throw const FormatException('Un seul certificat attendu par fichier.');
    }
    return DmpWireCertificate.parse(
      pem.isEmpty
          ? base64Encode(bytes)
          : pem.single.group(1)!.replaceAll(RegExp(r'\s'), ''),
    );
  }

  void check(DateTime now) {
    if (medicalHash(data) != hash ||
        data['environment'] != 'DV1' ||
        data['schema'] != 1) {
      throw StateError('Configuration DV1 non vérifiable.');
    }
    for (final r in resources.values.cast<Map>()) {
      if (FinalPdfDocumentService.hash(base64Decode(r['body'])) !=
          r['sha256']) {
        throw StateError('Ressource de configuration modifiée.');
      }
    }
    final checked = DateTime.parse(fields['parametersCheckedAt']).toUtc();
    if (checked.isAfter(now) ||
        now.difference(checked) >= const Duration(days: 7)) {
      throw StateError(
        'Paramètres ou nomenclatures à actualiser avant la recette.',
      );
    }
    final auth = certificate(base64Decode(resources['authentication']['body']));
    final sign = certificate(base64Decode(resources['signing']['body']));
    if (auth.commonName != professional ||
        sign.commonName != professional ||
        !auth.digitalSignature ||
        !auth.clientAuthentication ||
        !sign.contentCommitment ||
        auth.hash == sign.hash) {
      throw StateError(
        'Certificats d’authentification et de signature incompatibles avec le professionnel déclaré.',
      );
    }
    for (final cert in [auth, sign]) {
      if (now.isBefore(cert.validFrom) || !now.isBefore(cert.validUntil)) {
        throw StateError('Certificat hors période de validité.');
      }
    }
    // This is only a structural check; the native worker verifies PKIX and all
    // complete CRLs locally before opening TLS. No trust is asserted here.
    final trust = text('trust');
    if (trust.contains('PRIVATE KEY') ||
        !trust.contains('-----BEGIN CERTIFICATE-----') ||
        !trust.contains('-----BEGIN X509 CRL-----')) {
      throw StateError(
        'Le paquet de confiance doit contenir les autorités et leurs CRL complètes.',
      );
    }
    DmpParameters.parse(text('parameters'));
    for (final key in [
      'specialty',
      'type',
      'class',
      'confidentiality',
      'content',
      'format',
      'facility',
      'practice',
    ]) {
      NosImport.jdvTabs(text(key));
    }
    native('/configuration-non-activee/trust.pem').check();
  }

  String text(String key) => utf8.decode(base64Decode(resources[key]['body']));
  DmpNativeConfiguration native(String trustPath) => DmpNativeConfiguration(
    wire: DmpWireConfiguration(
      endpoint: repository,
      sourceId: fields['sourceId'],
      lpsId: fields['lpsId'],
      lpsName: fields['lpsName'],
      lpsVersion: fields['lpsVersion'],
      homologationId: fields['homologationId'],
    ),
    td02Endpoint: td02,
    processingMode: 'T',
    libraryPath: fields['library'],
    trustPath: trustPath,
    trustHash: resources['trust']['sha256'],
    authenticationHash: certificate(
      base64Decode(resources['authentication']['body']),
    ).hash,
    signingHash: certificate(base64Decode(resources['signing']['body'])).hash,
    situationNumber: int.parse(fields['situationNumber']),
    situationMode: int.parse(fields['situationMode']),
    situationStatus: int.parse(fields['situationStatus']),
    situationSector: fields['situationSector'],
  );

  bool codes(Map snapshot) {
    final prep = jsonDecode(snapshot['preparation']['data_json']);
    final context = jsonDecode(snapshot['practice']['data_json']);
    bool has(String key, String system, String code) =>
        ValueCatalog.parse(NosImport.jdvTabs(text(key))).canEmit(system, code);
    return prep['catalogReference'] == fields['reference'] &&
        NosImport.typeClassMatches(
          text('typeClass'),
          prep['typeSystem'],
          prep['typeCode'],
          prep['classSystem'],
          prep['classCode'],
        ) &&
        has('type', prep['typeSystem'], prep['typeCode']) &&
        has('type', 'ASTM', 'E1762') &&
        has('class', 'URN', 'urn:oid:1.3.6.1.4.1.19376.1.2.1.1.1') &&
        has('format', 'URN', 'http://www.w3.org/2000/09/xmldsig#') &&
        has('confidentiality', '1.2.250.1.213.1.1.4.13', 'MASQUE_PS') &&
        has('confidentiality', '1.2.250.1.213.1.1.4.13', 'INVISIBLE_PATIENT') &&
        has('class', prep['classSystem'], prep['classCode']) &&
        has(
          'specialty',
          context['professionSystem'],
          context['professionCode'],
        ) &&
        has('facility', '1.2.250.1.71.4.2.4', context['facilityCode']) &&
        has('practice', '1.2.250.1.213.1.1.4.9', 'AMBULATOIRE') &&
        has('confidentiality', '2.16.840.1.113883.5.25', 'N') &&
        has('content', '1.2.250.1.71.4.2.4', context['facilityCode']) &&
        has(
          'format',
          '1.3.6.1.4.1.19376.1.2.3',
          'urn:ihe:iti:xds-sd:pdf:2008',
        ) &&
        NosImport.mediaFormatMatches(
          text('mediaFormat'),
          'application/pdf',
          'urn:ihe:iti:xds-sd:pdf:2008',
        );
  }
}

/// Configuration used by the normal business screen, not by a simulated bench.
/// Imported public resources are frozen in the database and native backups.
class Dv1ConfigurationService {
  Dv1ConfigurationService(this.journal);
  final DocumentJournalService journal;
  static const labels = {
    'lpsId': 'Identifiant de l’installation LPS',
    'sourceId': 'OID de l’installation (commun TD0.2 et dépôt)',
    'lpsName': 'Nom du logiciel déclaré au CNDA',
    'lpsVersion': 'Version déclarée pour la recette',
    'homologationId': 'Identifiant fourni pour la recette',
    'professionalId': 'Identifiant national de la CPS de test',
    'situationNumber': 'Numéro de situation CPS',
    'situationMode': 'Code du mode d’exercice CPS',
    'situationStatus': 'Code du statut CPS',
    'situationSector': 'Code du secteur CPS',
    'java': 'Exécutable Java 17 ou supérieur',
    'library': 'Bibliothèque Cryptolib',
    'reference': 'Référence des nomenclatures utilisée dans le document',
    'parametersCheckedAt':
        'Paramètres vérifiés le (date ISO, avec heure et fuseau)',
    'sourceNote': 'Provenance et version des fichiers officiels',
  };
  static const fileLabels = {
    'trust': 'Paquet PEM des autorités et CRL',
    'authentication': 'Certificat public d’authentification de la CPS',
    'signing': 'Certificat public de signature de la CPS',
    'parameters': 'Fichier XML des paramètres DMP',
    'nos': 'Dossier des nomenclatures officielles',
  };
  Future<MacosDirectoryAccess?> _javaAccess(
    Map fields, {
    bool authorize = false,
  }) async {
    if (!Platform.isMacOS) return null;
    final bundled = await BundledPdfTools.load();
    final executable = p.join(p.dirname(bundled.java), 'java-cps');
    if (!await File(executable).exists()) {
      throw StateError(
        'Lanceur CPS absent. Recompilez une version complète de Companion.',
      );
    }
    if (fields['java'] != executable) {
      throw StateError(
        'Le moteur CPS a changé. Ouvrez la configuration DV1 et enregistrez-la sans connexion pour utiliser le moteur intégré.',
      );
    }
    if (fields['library'] != '/usr/local/lib/libcps3_pkcs11_osx.dylib') {
      throw StateError(
        'Bibliothèque CPS macOS attendue : /usr/local/lib/libcps3_pkcs11_osx.dylib.',
      );
    }
    return null;
  }

  static String? get bundledCpsJava => BundledPdfTools.root == null
      ? null
      : p.join(BundledPdfTools.root!, 'java', 'bin', 'java-cps');

  Future<Dv1Configuration?> current() async {
    final db = await journal.database;
    if ((await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='document_dv1_configurations'",
    )).isEmpty) {
      return null;
    }
    final rows = await db.query(
      'document_dv1_configurations',
      orderBy: 'revision DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final c = Dv1Configuration(rows.single);
    if (medicalHash(c.data) != c.hash) {
      throw StateError('Configuration DV1 altérée.');
    }
    return c;
  }

  Future<void> save(
    Map<String, String> fields,
    Map<String, String> files,
    int expectedRevision,
  ) async {
    if (CpsOperationLease.inUse) {
      throw StateError(
        'Terminez l’opération CPS avant de modifier la configuration.',
      );
    }
    await CpsOperationLease.closeIdle();
    fields = Map<String, String>.from(fields);
    if (Platform.isMacOS) fields['java'] = bundledCpsJava!;
    if (labels.keys.any((k) => fields[k]?.trim().isNotEmpty != true)) {
      throw StateError('Complétez tous les paramètres de recette.');
    }
    if (fields.values.any((v) => v.length > 4096 || v.contains('\u0000'))) {
      throw StateError('Paramètre invalide.');
    }
    final resources = <String, Object?>{};
    final previous = await current();
    if ((previous?.revision ?? 0) != expectedRevision) {
      throw StateError('Configuration modifiée ailleurs.');
    }
    Future<void> capture(String key, String? path) async {
      if ((path == null || path.isEmpty) && previous != null) {
        resources[key] = previous.resources[key];
        return;
      }
      if (path == null || path.isEmpty) {
        throw StateError('Fichier manquant : $key');
      }
      await LocalDocumentControlRunner.regular(path);
      final f = File(path);
      if (await f.length() > 4 * 1024 * 1024) {
        throw StateError('Fichier trop volumineux : $key');
      }
      final bytes = await f.readAsBytes();
      resources[key] = {
        'body': base64Encode(bytes),
        'sha256': FinalPdfDocumentService.hash(bytes),
        'file': p.basename(path),
      };
    }

    for (final key in ['trust', 'authentication', 'signing', 'parameters']) {
      await capture(key, files[key]);
    }
    for (final entry in Dv1Configuration.nosFiles.entries) {
      await capture(
        entry.key,
        files['nos']?.isNotEmpty == true
            ? p.join(files['nos']!, entry.value)
            : null,
      );
    }
    final access = await _javaAccess(fields, authorize: true);
    try {
      await LocalDocumentControlRunner.regular(fields['java']!);
      await LocalDocumentControlRunner.regular(fields['library']!);
      final data = {
        'schema': 1,
        'environment': 'DV1',
        'fields': fields,
        'libraryHash': FinalPdfDocumentService.hash(
          await File(fields['library']!).readAsBytes(),
        ),
        'javaHash': FinalPdfDocumentService.hash(
          await File(fields['java']!).readAsBytes(),
        ),
        'resources': resources,
      };
      final row = {
        'revision': expectedRevision + 1,
        'data_json': medicalCanonical(data),
        'data_hash': medicalHash(data),
        'created_at': journal.medical.now().millisecondsSinceEpoch,
      };
      Dv1Configuration(row).check(journal.medical.now().toUtc());
      await (await journal.database).insert('document_dv1_configurations', row);
    } finally {
      await access?.release();
    }
  }

  Future<void> unchanged(Dv1Configuration expected) async {
    final c = await current();
    if (c?.hash != expected.hash || c?.revision != expected.revision) {
      throw StateError('Configuration DV1 modifiée ; opération arrêtée.');
    }
    expected.check(journal.medical.now().toUtc());
    final access = await _javaAccess(expected.fields);
    try {
      if (FinalPdfDocumentService.hash(
                await File(expected.fields['java']).readAsBytes(),
              ) !=
              expected.data['javaHash'] ||
          FinalPdfDocumentService.hash(
                await File(expected.fields['library']).readAsBytes(),
              ) !=
              expected.data['libraryHash']) {
        throw StateError(
          'Java ou la Cryptolib a changé depuis la configuration.',
        );
      }
    } finally {
      await access?.release();
    }
  }

  Future<bool> canReuseAuthentication(Dv1Configuration c) async {
    final source = await rootBundle.loadString(
      'assets/dmp_native/DmpNativeBridge.java',
    );
    final key =
        '${c.hash}:${FinalPdfDocumentService.hash(utf8.encode(source))}';
    return CpsAuthenticationCache.shared.canReuse(key, c.professional);
  }

  Future<DocumentDmpNativePorts> ports(
    Dv1Configuration c,
    Future<String?> Function() requestPin,
    Future<DmpPolicy> Function(Map<String, dynamic>) readPolicy, {
    Dv1AccessContext? accessContext,
    String? depublicationUniqueId,
  }) async {
    final checkWorkContext = DmpWorkContext.current.bind(c.professional);
    await unchanged(c);
    checkWorkContext();
    final source = await rootBundle.loadString(
      'assets/dmp_native/DmpNativeBridge.java',
    );
    final workerHash = FinalPdfDocumentService.hash(utf8.encode(source));
    final root = Directory(
      p.join(
        (await journal.controls.root).path,
        'dv1-runtime',
        c.hash,
        workerHash,
      ),
    );
    await root.create(recursive: true);
    await LocalDocumentControlRunner.regular(root.path, directory: true);

    final worker = File(p.join(root.path, 'DmpNativeBridge.java'));
    final trust = File(p.join(root.path, 'trust.pem'));
    Future<void> writeFrozen(File f, List<int> bytes) async {
      if (await f.exists()) {
        await LocalDocumentControlRunner.regular(f.path);
        if (FinalPdfDocumentService.hash(await f.readAsBytes()) !=
            FinalPdfDocumentService.hash(bytes)) {
          throw StateError('Ressource native modifiée.');
        }
      } else {
        await f.writeAsBytes(bytes, flush: true);
      }
    }

    await writeFrozen(worker, utf8.encode(source));
    await writeFrozen(trust, base64Decode(c.resources['trust']['body']));
    final access = await _javaAccess(c.fields);
    try {
      return DocumentDmpNativePorts(
        checkWorkContext: checkWorkContext,
        authenticationCache:
            accessContext == null || depublicationUniqueId != null
            ? null
            : CpsAuthenticationCache.shared,
        authenticationKey:
            accessContext == null || depublicationUniqueId != null
            ? null
            : '${c.hash}:$workerHash',
        releaseResources: () async => access?.release(),
        configuration: c.native(trust.path),
        accessContext: accessContext,
        depublicationUniqueId: depublicationUniqueId,
        bridge: DmpProcessBridge(
          executable: c.fields['java'],
          arguments: [worker.path, '--serve'],
        ),
        requestPin: requestPin,
        readPolicy: readPolicy,
        now: journal.medical.now,
        provenance: 'Réponse native du serveur DV1',
      );
    } catch (_) {
      await access?.release();
      rethrow;
    }
  }
}
