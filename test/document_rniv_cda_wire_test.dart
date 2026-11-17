// Offline RNIV regression. Synthetic certificates only; no CPS or network.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:xml_crypto/xml_crypto.dart';
import 'package:abak_desktop_companion/features/patients/services/cnda_patient_recipe.dart';
import 'package:abak_desktop_companion/features/patients/services/document_cda_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/crypto.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';

const _fixtures = 'test/fixtures/dmp_soap_headers';
final _pdf = Uint8List.fromList(
  utf8.encode('%PDF synthetic RNIV fixture only'),
);
final _now = DateTime.utc(2026, 10, 17, 12);
final _approvedAt = _now
    .subtract(const Duration(minutes: 1))
    .millisecondsSinceEpoch;

Map<String, dynamic> _snapshot() {
  final s = jsonDecode(
    File('$_fixtures/snapshot.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final identity = Map<String, Object?>.from(s['identity'] as Map)
    ..addAll({
      'birth_last_name': 'NESSI',
      'birth_first_names': 'RUTH ISABELLE',
      'first_birth_name': 'RUTH',
      'used_last_name': 'DE VINCI',
      'used_first_name': 'RUTH',
      'birth_date': '1977-07-14',
      'sex_code': 'F',
      'birth_place_code': '',
      'identity_status': 'provisional',
      'identity_fictitious': 1,
    });
  final recipe = {
    'schema': 1,
    'scope': CndaPatientRecipe.scope,
    'testIns': '277076322082910',
    'source':
        'PDT 2.10g, Référentiel Patients ligne 7, Cas59; test offline RNIV',
    'confirmedAt': '2026-10-17T11:00:00Z',
    'traitsHash': CndaPatientRecipe.fingerprint(identity),
    'experimentalBirthPlace': '69360',
    'originalBirthPlace': '',
    'experimentalBirthPlaceReason': 'Test-only code authorized by CNDA according to the operator; not an official patient birthplace.',
  };
  s['identity'] = CndaPatientRecipe.documentIdentity(identity, recipe);
  s['cndaRecipe'] = recipe;
  s['version']['sha256'] = sha256.convert(_pdf).toString();
  return s;
}

({DmpWireDraft draft, DmpWirePacket packet, DmpSession session}) _packet(
  Map<String, dynamic> snapshot,
) {
  final auth = base64Encode(File('$_fixtures/auth.der').readAsBytesSync());
  final sign = base64Encode(File('$_fixtures/sign.der').readAsBytesSync());
  final session = DmpSession(
    id: 'synthetic-rniv-session',
    professional: '12345678901',
    authority: '2.25.123456789',
    structure: 'SYN-CAB',
    certificateHash: DmpWireCertificate.parse(auth).hash,
    contextHash: medicalHash(snapshot['practice']),
    issuedAt: _now,
    expiresAt: _now.add(const Duration(minutes: 2)),
  );
  final material = DmpWireMaterial(
    configuration: const DmpWireConfiguration(
      endpoint: CndaPatientRecipe.repository,
      sourceId: '2.25.123456789',
      lpsId: 'SYNTHETIC',
      lpsName: 'SYNTHETIC',
      lpsVersion: '1',
      homologationId: 'SYNTHETIC',
    ),
    authenticationDer: auth,
    signingDer: sign,
    authenticationHash: DmpWireCertificate.parse(auth).hash,
    signingHash: DmpWireCertificate.parse(sign).hash,
    professional: '12345678901',
    assessmentId: 'SYNTHETIC-ONLY',
    assessedAt: _now,
    validUntil: _now.add(const Duration(minutes: 2)),
    trustedAndNotRevoked: true,
  );
  final cda = DocumentCdaBuilder.build(snapshot, _pdf, _approvedAt);
  final draft = DmpWireDraft(
    snapshot,
    session,
    cda,
    material,
    _now,
    approvedAt: _approvedAt,
  );
  final signature = SignedXml.signatureAlgorithms[DmpWireCrypto.rsa]!
      .getSignature(
        draft.signedInfo,
        File('$_fixtures/sign-key.pem').readAsBytesSync(),
      );
  return (draft: draft, packet: draft.finish(signature), session: session);
}

Map<String, Object?> _evidence(
  ({DmpWireDraft draft, DmpWirePacket packet, DmpSession session}) p,
  Map<String, dynamic> snapshot,
) => {
  'protocol': 'DMP-XDS-XADES-MTOM-2.10',
  'request': p.packet.soap,
  'metadata': p.packet.metadata,
  'vihf': p.packet.vihf,
  'messageId': p.draft.messageId,
  'snapshotHash': medicalHash(snapshot),
  'sessionHash': medicalHash(p.session.evidence),
  'cdaHash': sha256.convert(p.draft.cda).toString(),
  'wire': {
    ...p.packet.evidence,
    'material': p.draft.material.evidence,
    'authenticationDer': p.draft.material.authenticationDer,
    'signingCertificateHash': p.draft.material.signingHash,
    'signedInfo': p.draft.signedInfo,
    'replay': p.draft.replay,
  },
};

void main() {
  test('CDA encodes first, full birth list and both used names separately', () {
    final s = _snapshot();
    final original = medicalCanonical(s);
    final xml = XmlDocument.parse(
      utf8.decode(DocumentCdaBuilder.build(s, _pdf, _approvedAt)),
    );
    final name = xml
        .findAllElements('patient')
        .single
        .findElements('name')
        .single;
    final given = name.findElements('given').toList();
    expect(
      given.map((e) => [e.getAttribute('qualifier'), e.innerText]).toList(),
      [
        ['BR', 'RUTH'],
        [null, 'RUTH ISABELLE'],
        ['CL', 'RUTH'],
      ],
    );
    expect(
      name
          .findElements('family')
          .map((e) => [e.getAttribute('qualifier'), e.innerText])
          .toList(),
      [
        ['BR', 'NESSI'],
        ['CL', 'DE VINCI'],
      ],
    );
    expect(
      base64Decode(
        xml
            .findAllElements('nonXMLBody')
            .single
            .findElements('text')
            .single
            .innerText,
      ),
      _pdf,
    );
    expect(medicalCanonical(s), original);
  });

  test(
    'XDS legal/used PID-5 values match CDA and carry declared birthplace',
    () {
      final p = _packet(_snapshot());
      final doc = XmlDocument.parse(p.packet.metadata)
          .findAllElements(
            'ExtrinsicObject',
            namespaceUri: 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0',
          )
          .singleWhere((e) => e.getAttribute('id') == p.draft.cdaEntry);
      final slot = doc
          .findElements(
            'Slot',
            namespaceUri: 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0',
          )
          .singleWhere((e) => e.getAttribute('name') == 'sourcePatientInfo');
      expect(
        slot
            .findAllElements(
              'Value',
              namespaceUri: 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0',
            )
            .map((e) => e.innerText)
            .toList(),
        [
          'PID-5|NESSI^RUTH^RUTH ISABELLE^^^^L',
          'PID-5|DE VINCI^RUTH^^^^^D',
          'PID-7|19770714',
          'PID-8|F',
          'PID-11|^^^^^^BDL^^69360',
        ],
      );
      p.draft.verify(p.packet, _now);
    },
  );

  test(
    'CNDA birthplace projection remains separate and does not qualify identity',
    () {
      final s = _snapshot();
      CndaPatientRecipe.checkDocument(s);
      expect(s['identity']['identity_status'], 'provisional');
      expect(s['cndaRecipe']['originalBirthPlace'], '');
      final xml = XmlDocument.parse(
        utf8.decode(DocumentCdaBuilder.build(s, _pdf, _approvedAt)),
      );
      expect(
        xml
            .findAllElements('birthplace')
            .single
            .findAllElements('county')
            .single
            .innerText,
        '69360',
      );
      expect(s['cndaRecipe']['experimentalBirthPlace'], '69360');
    },
  );

  test('signed RNIV packet can be verified later without CPS or network', () {
    final s = _snapshot(), p = _packet(s);
    expect(p.draft.replay['patientNameProfile'], 'rniv-explicit-1');
    DmpWireDraft.verifyArchived(_evidence(p, s), s, p.session.evidence);
  });

  test(
    'missing, unknown or null name profile cannot downgrade a corrected packet',
    () {
      final s = _snapshot(), p = _packet(s);
      for (final value in [null, 'unknown', 'REMOVE']) {
        final archive = jsonDecode(jsonEncode(_evidence(p, s))) as Map;
        final replay = archive['wire']['replay'] as Map;
        if (value == 'REMOVE') {
          replay.remove('patientNameProfile');
        } else {
          replay['patientNameProfile'] = value;
        }
        expect(
          () => DmpWireDraft.verifyArchived(archive, s, p.session.evidence),
          throwsA(anything),
        );
      }
    },
  );

  test('changing approved RNIV identity invalidates archived evidence', () {
    final s = _snapshot(), p = _packet(s);
    final archive = _evidence(p, s);
    for (final key in [
      'first_birth_name',
      'birth_first_names',
      'used_last_name',
      'used_first_name',
    ]) {
      final changed = jsonDecode(jsonEncode(s)) as Map<String, dynamic>;
      changed['identity'][key] = 'OTHER';
      expect(
        () => DmpWireDraft.verifyArchived(archive, changed, p.session.evidence),
        throwsA(anything),
        reason: key,
      );
    }
  });

  test('pre-patch signed archive with used names remains readable, bytes unchanged', () {
    final old = jsonDecode(
      File('test/fixtures/rniv/legacy_packet.json').readAsStringSync(),
    ) as Map;
    final before = medicalCanonical(old);
    DmpWireDraft.verifyArchived(
      old['package'],
      Map<String, dynamic>.from(old['snapshot']),
      old['authentication'],
    );
    expect(medicalCanonical(old), before);
    expect(
      old['package']['wire']['replay'].containsKey('patientNameProfile'),
      false,
    );
  });
}
