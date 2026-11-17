import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:xml_crypto/xml_crypto.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/crypto.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/dv1_type_label.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';

void main() {
  final old = jsonDecode(
    File('test/fixtures/dv1_type_label/legacy_packet.json').readAsStringSync(),
  ) as Map;
  final snapshot = Map<String, dynamic>.from(old['snapshot']);
  final package = old['package'] as Map,
      authentication = old['authentication'] as Map;
  final replay = package['wire']['replay'] as Map;
  final now = DateTime.parse(replay['time']);
  final session = DmpSession(
    id: authentication['id'],
    professional: authentication['professional'],
    authority: authentication['authority'],
    structure: authentication['structure'],
    certificateHash: authentication['certificateHash'],
    contextHash: authentication['contextHash'],
    issuedAt: DateTime.parse(authentication['issuedAt']),
    expiresAt: DateTime.parse(authentication['expiresAt']),
  );
  final m = replay['material'] as Map, c = m['configuration'] as Map;
  final material = DmpWireMaterial(
    configuration: DmpWireConfiguration(
      endpoint: c['endpoint'],
      sourceId: c['sourceId'],
      lpsId: c['lpsId'],
      lpsName: c['lpsName'],
      lpsVersion: c['lpsVersion'],
      homologationId: c['homologationId'],
    ),
    authenticationDer: replay['authenticationDer'],
    signingDer: replay['signingDer'],
    authenticationHash: m['authenticationCertificateHash'],
    signingHash: m['signingCertificateHash'],
    professional: m['professional'],
    assessmentId: m['assessmentId'],
    assessedAt: DateTime.parse(m['assessedAt']),
    validUntil: DateTime.parse(m['validUntil']),
    trustedAndNotRevoked: m['trustedAndNotRevoked'],
  );
  final cda = Uint8List.fromList(base64Decode(replay['cda']));
  final draft = DmpWireDraft(
    snapshot,
    session,
    cda,
    material,
    now,
    approvedAt: replay['approvedAt'],
  );
  final signature = SignedXml.signatureAlgorithms[DmpWireCrypto.rsa]!
      .getSignature(
        draft.signedInfo,
        File('test/fixtures/dmp_soap_headers/sign-key.pem').readAsBytesSync(),
      );
  final packet = draft.finish(signature);
  Map evidence() => {
    'protocol': 'DMP-XDS-XADES-MTOM-2.10',
    'request': packet.soap,
    'metadata': packet.metadata,
    'vihf': packet.vihf,
    'messageId': draft.messageId,
    'snapshotHash': package['snapshotHash'],
    'sessionHash': package['sessionHash'],
    'cdaHash': package['cdaHash'],
    'wire': {
      ...packet.evidence,
      'material': material.evidence,
      'authenticationDer': material.authenticationDer,
      'signingCertificateHash': material.signingHash,
      'signedInfo': draft.signedInfo,
      'replay': draft.replay,
    },
  };

  test('the new packet corrects only the clinical XDS label, retaining CDA and approved snapshot', () {
    final before = medicalCanonical(snapshot);
    final registry = XmlDocument.parse(packet.metadata);
    final clinical = registry
        .findAllElements('ExtrinsicObject', namespaceUri: DmpWireDraft.rim)
        .singleWhere((e) => e.getAttribute('id') == draft.cdaEntry);
    final type = clinical
        .findElements('Classification', namespaceUri: DmpWireDraft.rim)
        .singleWhere(
          (e) =>
              e.getAttribute('classificationScheme') ==
              'urn:uuid:f0306f51-975f-434e-a61c-c59651d33983',
        );
    expect(type.getAttribute('nodeRepresentation'), '11490-0');
    expect(
      type
          .findAllElements('LocalizedString', namespaceUri: DmpWireDraft.rim)
          .single
          .getAttribute('value'),
      'Lettre de sortie',
    );
    expect(
      XmlDocument.parse(utf8.decode(cda)).rootElement
          .findElements('code')
          .single
          .getAttribute('displayName'),
      'Lettre de liaison à la sortie d’un établissement de soins',
    );
    expect(draft.cda, cda);
    expect(medicalCanonical(snapshot), before);
    expect(draft.replay['typeLabelProfile'], Dv1TypeLabel.profile);
    draft.verify(packet, now);
    DmpWireDraft.verifyArchived(evidence(), snapshot, authentication);
  });
  test('the signed pre-correction packet remains verifiable without rewriting evidence', () {
    final before = medicalCanonical(package);
    DmpWireDraft.verifyArchived(package, snapshot, authentication);
    expect(medicalCanonical(package), before);
  });
  test('the correction is limited to known labels, LOINC 11490-0 and the assigned DV1 endpoint', () {
    final d = jsonDecode(snapshot['preparation']['data_json']) as Map;
    expect(Dv1TypeLabel.applies(d, Dv1TypeLabel.repository), true);
    for (final change in [
      {'typeCode': '11506-3'},
      {'typeSystem': '1.2.3'},
      {'typeLabel': 'Unverified label'},
    ]) {
      expect(
        Dv1TypeLabel.applies({...d, ...change}, Dv1TypeLabel.repository),
        false,
      );
    }
    expect(
      Dv1TypeLabel.applies(
        d,
        'https://lps.dmp.gouv.fr/si-dmp-server/v2/services/repository',
      ),
      false,
    );
  });
  test('corrected packet cannot be downgraded by removing or changing the label profile', () {
    for (final value in [null, 'other', 'REMOVE']) {
      final data = jsonDecode(jsonEncode(evidence())) as Map;
      if (value == 'REMOVE') {
        (data['wire']['replay'] as Map).remove('typeLabelProfile');
      } else {
        data['wire']['replay']['typeLabelProfile'] = value;
      }
      expect(
        () => DmpWireDraft.verifyArchived(data, snapshot, authentication),
        throwsA(anything),
      );
    }
  });
}
