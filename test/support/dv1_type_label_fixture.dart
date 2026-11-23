// Offline, in-memory fixture. Only public synthetic certificates are used.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/core/database/document_dv1_schema.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_retry.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/crypto.dart';

class TypeLabelFixture {
  TypeLabelFixture._(this.db, this.root, this.source);
  final Database db;
  final Directory root;
  final Map<String, dynamic> source;
  EpisodeDocumentVersion get version =>
      EpisodeDocumentVersion(Map<String, Object?>.from(source['version']));
  Map<String, dynamic> get snapshot =>
      jsonDecode(source['approval']['snapshot_json']);
  List<Map<String, Object?>> get steps => (source['steps'] as List)
      .map((r) => Map<String, Object?>.from(r))
      .toList();
  Map<String, Object?> get reservation =>
      steps.singleWhere((r) => r['phase'] == 'dv1_reservation');
  Map<String, dynamic> phase(String name) => jsonDecode(
    steps.singleWhere((r) => r['phase'] == 'dv1_$name')['data_json'] as String,
  );

  static String responseXml(
    String messageId,
    String entry,
    String rejectedLabel,
  ) {
    final b = XmlBuilder();
    b.element(
      's:Envelope',
      attributes: {
        'xmlns:s': 'http://www.w3.org/2003/05/soap-envelope',
        'xmlns:w': 'http://www.w3.org/2005/08/addressing',
        'xmlns:r': 'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0',
      },
      nest: () {
        b.element(
          's:Header',
          nest: () {
            b.element(
              'w:Action',
              nest: 'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-bResponse',
            );
            b.element('w:RelatesTo', nest: messageId);
          },
        );
        b.element(
          's:Body',
          nest: () {
            b.element(
              'r:RegistryResponse',
              attributes: {
                'status': 'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Failure',
              },
              nest: () {
                const severity =
                    'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error';
                b.element(
                  'r:RegistryErrorList',
                  attributes: {'highestSeverity': severity},
                  nest: () {
                    b.element(
                      'r:RegistryError',
                      attributes: {
                        'errorCode': 'XDSRegistryMetadataError',
                        'severity': severity,
                        'location':
                            'AffinityDomainBean.validateXDSDocumentEntry 3',
                        'codeContext':
                            "entryUUID=$entry;Le libellé '$rejectedLabel' ne fait pas partie du domaine d'affinité pour le code : 11490-0 (TYPECODE). La valeur correcte est : 'Lettre de sortie'.",
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
    return b.buildDocument().toXmlString();
  }

  static String headers(List<int> bytes) =>
      'HTTP/1.1 200 OK\r\nContent-Type: application/soap+xml\r\nContent-Length: ${bytes.length}\r\n\r\n';

  static Map<String, dynamic> syntheticData() {
    final old = jsonDecode(
      File('test/fixtures/dv1_type_label/legacy_packet.json')
          .readAsStringSync(),
    ) as Map;
    final snapshot = old['snapshot'] as Map<String, dynamic>;
    final package = old['package'] as Map<String, dynamic>;
    final replay = package['wire']['replay'] as Map;
    final material = replay['material']['configuration'] as Map;
    final trustHash = sha256
        .convert(utf8.encode('Synthetic trust evidence only'))
        .toString();
    final config = {
      'schema': 1,
      'environment': 'DV1',
      'fields': {
        'sourceId': material['sourceId'],
        'lpsId': material['lpsId'],
        'lpsName': material['lpsName'],
        'lpsVersion': material['lpsVersion'],
        'homologationId': material['homologationId'],
        'professionalId': '12345678901',
        'library': 'synthetic-only',
        'situationNumber': '1',
        'situationMode': '0',
        'situationStatus': '1',
        'situationSector': 'SA07',
      },
      'resources': {
        'authentication': {'body': replay['authenticationDer']},
        'signing': {'body': replay['signingDer']},
        'trust': {'sha256': trustHash},
      },
    };
    final authentication = Map<String, dynamic>.from(old['authentication'])
      ..['native'] = {
        'mutualTls': 'true',
        'trustHash': trustHash,
        'tdEndpoint':
            'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/patients',
        'depositEndpoint':
            'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository',
      };
    package['sessionHash'] = medicalHash(authentication);
    const chain = 'fixture-original-attempt',
        runId = 'fixture-run',
        approvalId = 'fixture-approval';
    final saved = {
      'scope': 'dv1',
      'attemptId': chain,
      'approvalId': approvalId,
      'snapshotHash': medicalHash(snapshot),
      'controlRunId': runId,
      'cdaHash': package['cdaHash'],
      'packageHash': medicalHash(package),
      'configurationRevision': 1,
      'configurationHash': medicalHash(config),
    };
    final preparation = {
      ...saved,
      'accessOnly': false,
      'conditions': {'scenario': 'PRE_ALIM_N1'},
    };
    final body = utf8.encode(
      responseXml(
        package['messageId'],
        replay['identifiers']['cdaEntry'],
        jsonDecode(snapshot['preparation']['data_json'])['typeLabel'],
      ),
    );
    final response = {
      'scope': 'dv1',
      'attemptId': chain,
      'outcome': 'rejected',
      'detail': 'Synthetic exact type-label rejection',
      'headers': headers(body),
      'response': base64Encode(body),
      'request': package['request'],
      'packageHash': medicalHash(package),
    };
    Map<String, Object?> row(
      String phase,
      Map data, {
      String state = 'passed',
    }) => {
      'step_id': 'fixture-$phase',
      'chain_id': chain,
      'version_id': snapshot['version']['version_id'],
      'document_id': snapshot['version']['document_id'],
      'phase': 'dv1_$phase',
      'state': state,
      'data_json': medicalCanonical(data),
      'data_hash': medicalHash(data),
    };
    return {
      'steps': [
        row('preparation', preparation),
        row('authentication', authentication),
        row('package', package),
        row('signature', {
          'format': 'XAdES-1.1.1-RSA-SHA1-SEL-MP-037-2.10',
          'certificateHash': package['wire']['signingCertificateHash'],
          'packageHash': medicalHash(package),
          'value': DmpWireCrypto.one(
            DmpWireCrypto.parse(package['wire']['signatureXml']),
            'SignatureValue',
          ).innerText,
        }),
        row('reservation', saved, state: 'reserved'),
        row('response', response, state: 'result'),
      ],
      'approval': {
        'approval_id': approvalId,
        'version_id': snapshot['version']['version_id'],
        'snapshot_json': medicalCanonical(snapshot),
        'snapshot_hash': medicalHash(snapshot),
        'approved_at': replay['approvedAt'],
      },
      'version': snapshot['version'],
      'run': {
        'run_id': runId,
        'version_id': snapshot['version']['version_id'],
        'approval_id': approvalId,
        'directory': runId,
      },
      'configuration': {
        'revision': 1,
        'created_at': 1,
        'data_json': medicalCanonical(config),
        'data_hash': medicalHash(config),
      },
      'controlFiles': {
        'document.xml': {'base64': replay['cda']},
      },
    };
  }

  static Future<TypeLabelFixture> create({
    Map<String, dynamic>? diagnostic,
  }) async {
    final source = diagnostic ?? syntheticData();
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    final root = await Directory.systemTemp.createTemp('abak-type-label-');
    final groups = <String, List<Map<String, Object?>>>{
      'episode_document_versions': [
        Map<String, Object?>.from(source['version']),
      ],
      'document_chain_steps': (source['steps'] as List)
          .map((r) => Map<String, Object?>.from(r))
          .toList(),
      'document_medical_approvals': [
        Map<String, Object?>.from(source['approval']),
      ],
      'document_control_runs': [Map<String, Object?>.from(source['run'])],
      'document_dv1_configurations': [
        Map<String, Object?>.from(source['configuration']),
      ],
    };
    for (final group in groups.entries) {
      final columns = group.value.expand((r) => r.keys).toSet();
      if (columns.any((c) => !RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(c))) {
        throw StateError('Unexpected fixture column');
      }
      await db.execute(
        'CREATE TABLE ${group.key} (${columns.map((c) => '"$c"').join(',')})',
      );
    }
    await db.execute('CREATE TABLE document_restore_barriers(id TEXT)');
    await db.execute(
      'CREATE TABLE document_attempts(document_id TEXT,patient_id TEXT,pdf_hash TEXT)',
    );
    await db.execute(
      'CREATE TABLE document_events(kind TEXT,reference_id TEXT,detail TEXT,created_at INTEGER)',
    );
    await createDocumentDv1Tables(db);
    for (final group in groups.entries) {
      for (final row in group.value) {
        await db.insert(group.key, row);
      }
    }
    final runDir = await Directory('${root.path}/${source['run']['directory']}')
        .create();
    await File('${runDir.path}/document.xml').writeAsBytes(
      base64Decode(source['controlFiles']['document.xml']['base64']),
    );
    return TypeLabelFixture._(db, root, source);
  }

  Future<Dv1RetryReview> inspect() => Dv1Retry.inspect(db, version, root);

  Future<void> reserve(
    Dv1RetryReview review, {
    Map<String, Object?> changes = const {},
    String chain = 'fixture-corrected-attempt',
  }) async {
    final saved = {
      ...phase('reservation'),
      'attemptId': chain,
      'packageHash': 'b' * 64,
      'retry': review.evidence,
      ...changes,
    };
    await db.insert('document_chain_steps', {
      ...reservation,
      'step_id': chain,
      'chain_id': chain,
      'data_json': medicalCanonical(saved),
      'data_hash': medicalHash(saved),
    });
  }

  Future<void> close() async {
    await db.close();
    await root.delete(recursive: true);
  }
}
