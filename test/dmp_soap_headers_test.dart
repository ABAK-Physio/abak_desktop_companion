import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:xml_crypto/xml_crypto.dart';
import 'package:abak_desktop_companion/features/patients/services/document_cda_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/crypto.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';

void main() {
  const soapNs = 'http://www.w3.org/2003/05/soap-envelope';
  const wsa = 'http://www.w3.org/2005/08/addressing';
  const wsse =
      'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
  const fixtures = 'test/fixtures/dmp_soap_headers';
  final snapshot =
      jsonDecode(File('$fixtures/snapshot.json').readAsStringSync())
          as Map<String, dynamic>;
  final pdf = Uint8List.fromList(
    utf8.encode('%PDF-1.4\nSYNTHETIC HEADER TEST ONLY\n%%EOF'),
  );
  snapshot['version']['sha256'] = sha256.convert(pdf).toString();
  final now = DateTime.utc(2026, 10, 17, 12);
  final approvedAt = now
      .subtract(const Duration(minutes: 1))
      .millisecondsSinceEpoch;
  final auth = base64Encode(File('$fixtures/auth.der').readAsBytesSync());
  final sign = base64Encode(File('$fixtures/sign.der').readAsBytesSync());
  final session = DmpSession(
    id: 'synthetic-session',
    professional: '12345678901',
    authority: '2.25.123456789',
    structure: 'SYN-CAB',
    certificateHash: DmpWireCertificate.parse(auth).hash,
    contextHash: medicalHash(snapshot['practice']),
    issuedAt: now,
    expiresAt: now.add(const Duration(minutes: 2)),
  );
  final material = DmpWireMaterial(
    configuration: const DmpWireConfiguration(
      endpoint: 'https://synthetic.invalid/repository',
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
    assessedAt: now,
    validUntil: now.add(const Duration(minutes: 2)),
    trustedAndNotRevoked: true,
  );
  final cda = DocumentCdaBuilder.build(snapshot, pdf, approvedAt);
  final draft = DmpWireDraft(
    snapshot,
    session,
    cda,
    material,
    now,
    approvedAt: approvedAt,
  );
  final signature = SignedXml.signatureAlgorithms[DmpWireCrypto.rsa]!
      .getSignature(
        draft.signedInfo,
        File('$fixtures/sign-key.pem').readAsBytesSync(),
      );
  final packet = draft.finish(signature);
  Map<String, dynamic> evidence(DmpWirePacket p, Map replay) => {
    'protocol': 'DMP-XDS-XADES-MTOM-2.10',
    'request': p.soap,
    'metadata': p.metadata,
    'vihf': p.vihf,
    'messageId': draft.messageId,
    'snapshotHash': medicalHash(snapshot),
    'sessionHash': medicalHash(session.evidence),
    'cdaHash': sha256.convert(cda).toString(),
    'wire': {
      ...p.evidence,
      'material': material.evidence,
      'authenticationDer': auth,
      'signingCertificateHash': material.signingHash,
      'signedInfo': draft.signedInfo,
      'replay': replay,
    },
  };
  DmpWirePacket withSoap(String xml) => DmpWirePacket(
    soap: xml,
    metadata: packet.metadata,
    vihf: packet.vihf,
    signatureXml: packet.signatureXml,
    contentType: packet.contentType,
    mime: utf8.encode(utf8.decode(packet.mime).replaceFirst(packet.soap, xml)),
  );

  test('new deposit matches accepted DV1 header policy and preserves VIHF', () {
    final xml = XmlDocument.parse(packet.soap);
    final header = xml.findAllElements('Header', namespaceUri: soapNs).single;
    final accepted = XmlDocument.parse(
      File(
        'assets/dmp_local/deposit_replay/accepted-request.xml',
      ).readAsStringSync(),
    );
    for (final pair in [
      ('To', wsa),
      ('Action', wsa),
      ('ReplyTo', wsa),
      ('Security', wsse),
    ]) {
      final current = header.findElements(pair.$1, namespaceUri: pair.$2).single;
      final reference = accepted
          .findAllElements(pair.$1, namespaceUri: pair.$2)
          .single;
      expect(
        current.getAttribute('mustUnderstand', namespaceUri: soapNs),
        reference.getAttribute('mustUnderstand', namespaceUri: soapNs),
      );
    }
    final security = header.findElements('Security', namespaceUri: wsse).single;
    expect(
      security.findElements(
        'Assertion',
        namespaceUri: 'urn:oasis:names:tc:SAML:2.0:assertion',
      ),
      hasLength(1),
    );
    expect(packet.soap, contains(packet.vihf));
    expect(utf8.decode(packet.mime), contains(packet.soap));
    draft.verify(packet, now);
    DmpWireDraft.verifyArchived(
      evidence(packet, draft.replay),
      snapshot,
      session.evidence,
    );
  });

  test(
    'old archived headers remain verifiable without being used for new deposits',
    () {
      final oldSoap = packet.soap
          .replaceFirst('<w:ReplyTo>', '<w:ReplyTo s:mustUnderstand="true">')
          .replaceFirst(
            '<wsse:Security>',
            '<wsse:Security s:mustUnderstand="true">',
          );
      expect(oldSoap, isNot(packet.soap));
      final old = withSoap(oldSoap);
      final legacyReplay = Map<String, Object?>.from(draft.replay)
        ..remove('soapHeaderProfile');
      DmpWireDraft.verifyArchived(
        evidence(old, legacyReplay),
        snapshot,
        session.evidence,
      );
      expect(() => draft.verify(old, now), throwsA(isA<DmpChainBlock>()));
      expect(
        () => DmpWireDraft.verifyArchived(
          evidence(old, draft.replay),
          snapshot,
          session.evidence,
        ),
        throwsA(anything),
      );
      expect(
        () => DmpWireDraft.verifyArchived(
          evidence(packet, legacyReplay),
          snapshot,
          session.evidence,
        ),
        throwsA(anything),
      );
    },
  );

  test(
    'all three XDS patient IDs include mandatory NH, consistent with VIHF',
    () {
      const rim = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0';
      final xml = XmlDocument.parse(packet.soap);
      final ids = xml
          .findAllElements('ExternalIdentifier', namespaceUri: rim)
          .where(
            (e) => e
                .findAllElements('LocalizedString', namespaceUri: rim)
                .any(
                  (n) => (n.getAttribute('value') ?? '').endsWith('.patientId'),
                ),
          )
          .toList();
      expect(ids, hasLength(3));
      final identity = snapshot['identity'];
      final expected =
          '${identity['ins_number']}${identity['ins_key']}^^^&${identity['ins_oid']}&ISO^NH';
      for (final id in ids) {
        expect(id.getAttribute('value'), expected);
        expect(id.getAttribute('value')!.split('^'), hasLength(5));
      }
      final vihf = xml
          .findAllElements(
            'Attribute',
            namespaceUri: 'urn:oasis:names:tc:SAML:2.0:assertion',
          )
          .singleWhere(
            (e) =>
                e.getAttribute('Name') ==
                'urn:oasis:names:tc:xacml:2.0:resource:resource-id',
          );
      expect(vihf.innerText, expected);
      expect(packet.soap, isNot(contains('^NH^NH')));
      expect(draft.replay['xdsPatientIdProfile'], 'ins-nh-1');
    },
  );

  test(
    'old patient IDs replay only as archives, with either historical header profile',
    () {
      // Remove CX.5 only from attribute values (the three XDS identifiers),
      // preserving VIHF and sourcePatientId text, signatures and attachments.
      String oldIds(String xml) => xml.replaceAll('&amp;ISO^NH"', '&amp;ISO"');
      for (final oldHeaders in [false, true]) {
        var soap = oldIds(packet.soap);
        if (oldHeaders) {
          soap = soap
              .replaceFirst(
                '<w:ReplyTo>',
                '<w:ReplyTo s:mustUnderstand="true">',
              )
              .replaceFirst(
                '<wsse:Security>',
                '<wsse:Security s:mustUnderstand="true">',
              );
        }
        final old = DmpWirePacket(
          soap: soap,
          metadata: oldIds(packet.metadata),
          vihf: packet.vihf,
          signatureXml: packet.signatureXml,
          contentType: packet.contentType,
          mime: utf8.encode(
            utf8.decode(packet.mime).replaceFirst(packet.soap, soap),
          ),
        );
        final replay = Map<String, Object?>.from(draft.replay)
          ..remove('xdsPatientIdProfile');
        if (oldHeaders) replay.remove('soapHeaderProfile');
        DmpWireDraft.verifyArchived(
          evidence(old, replay),
          snapshot,
          session.evidence,
        );
        expect(() => draft.verify(old, now), throwsA(anything));
        expect(
          () => DmpWireDraft.verifyArchived(
            evidence(old, {...replay, 'xdsPatientIdProfile': 'ins-nh-1'}),
            snapshot,
            session.evidence,
          ),
          throwsA(anything),
        );
      }
      final missing = Map<String, Object?>.from(draft.replay)
        ..remove('xdsPatientIdProfile');
      expect(
        () => DmpWireDraft.verifyArchived(
          evidence(packet, missing),
          snapshot,
          session.evidence,
        ),
        throwsA(anything),
      );
      for (final value in ['unknown', null]) {
        expect(
          () => DmpWireDraft.verifyArchived(
            evidence(packet, {...draft.replay, 'xdsPatientIdProfile': value}),
            snapshot,
            session.evidence,
          ),
          throwsFormatException,
        );
      }
    },
  );

  test(
    'metadata matches accepted labels and signature rules without changing clinical data',
    () {
      const rim = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0';
      final xml = XmlDocument.parse(packet.metadata);
      final accepted = XmlDocument.parse(
        File(
          'assets/dmp_local/deposit_replay/accepted-request.xml',
        ).readAsStringSync(),
      );
      List<String> slots(XmlNode parent, String name) => parent
          .findAllElements('Slot', namespaceUri: rim)
          .where((e) => e.getAttribute('name') == name)
          .expand((e) => e.findAllElements('Value', namespaceUri: rim))
          .map((e) => e.innerText)
          .toList();
      final expectedSpecialty = slots(
        accepted,
        'authorSpecialty',
      ).toSet().single;
      expect(
        expectedSpecialty,
        'G15_70^Masseur-Kinésithérapeute^1.2.250.1.213.1.1.4.5',
      );
      expect(slots(xml, 'authorSpecialty'), List.filled(3, expectedSpecialty));
      final objects = xml
          .findAllElements('ExtrinsicObject', namespaceUri: rim)
          .toList();
      final sig = objects.singleWhere(
        (e) => e.getAttribute('id') == draft.signatureEntry,
      );
      final clinical = objects.singleWhere(
        (e) => e.getAttribute('id') == draft.cdaEntry,
      );
      for (final code in [
        'MASQUE_PS',
        'INVISIBLE_PATIENT',
        'http://www.w3.org/2000/09/xmldsig#',
      ]) {
        XmlElement classification(XmlNode node) => node
            .findAllElements('Classification', namespaceUri: rim)
            .singleWhere((e) => e.getAttribute('nodeRepresentation') == code);
        String label(XmlNode node) => node
            .findAllElements('LocalizedString', namespaceUri: rim)
            .single
            .getAttribute('value')!;
        expect(label(classification(sig)), label(classification(accepted)));
        expect(
          slots(classification(sig), 'codingScheme'),
          slots(classification(accepted), 'codingScheme'),
        );
      }
      expect(
        sig
            .findElements('Slot', namespaceUri: rim)
            .where((e) => e.getAttribute('name') == 'sourcePatientInfo'),
        isEmpty,
      );
      expect(slots(clinical, 'sourcePatientInfo'), hasLength(3));
      expect(slots(sig, 'serviceStartTime'), slots(sig, 'creationTime'));
      expect(slots(sig, 'serviceStopTime'), slots(sig, 'creationTime'));
      expect(
        slots(clinical, 'serviceStartTime'),
        slots(clinical, 'creationTime'),
      );
      expect(
        slots(clinical, 'creationTime'),
        isNot(slots(sig, 'creationTime')),
      );
      final context = jsonDecode(snapshot['practice']['data_json'] as String);
      expect(
        slots(clinical, 'authorInstitution').single,
        contains(context['structureName']),
      );
      expect(packet.soap, contains('urn:ihe:iti:xds-sd:pdf:2008'));
      expect(draft.replay['xdsMetadataProfile'], 'dv1-labels-signature-1');
    },
  );

  test(
    'metadata profile cannot be removed, changed or set to null on corrected packet',
    () {
      for (final profile in ['unknown', null]) {
        expect(
          () => DmpWireDraft.verifyArchived(
            evidence(packet, {...draft.replay, 'xdsMetadataProfile': profile}),
            snapshot,
            session.evidence,
          ),
          throwsFormatException,
        );
      }
      final old = Map<String, Object?>.from(draft.replay)
        ..remove('xdsMetadataProfile');
      expect(
        () => DmpWireDraft.verifyArchived(
          evidence(packet, old),
          snapshot,
          session.evidence,
        ),
        throwsA(anything),
      );
      for (final pair in [
        ('Masseur-Kinésithérapeute', 'Masseur-kinésithérapeute'),
        ('Masqué aux professionnels de santé', 'Masqué aux professionnels'),
        ('Non visible par le patient', 'Invisible au patient'),
        ('Default Signature Style', 'Signature électronique'),
      ]) {
        expect(
          () => draft.verify(
            withSoap(packet.soap.replaceAll(pair.$1, pair.$2)),
            now,
          ),
          throwsA(anything),
        );
      }
    },
  );

  test('signature title equals Source and legacy title is archive-only', () {
    const rim = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0';
    final sig = XmlDocument.parse(packet.metadata)
        .findAllElements('ExtrinsicObject', namespaceUri: rim)
        .singleWhere((e) => e.getAttribute('id') == draft.signatureEntry);
    final name = sig.findElements('Name', namespaceUri: rim).single.toXmlString();
    expect(name, contains('value="Source"'));
    final event = sig
        .findElements('Classification', namespaceUri: rim)
        .singleWhere(
          (e) =>
              e.getAttribute('nodeRepresentation') == '1.2.840.10065.1.12.1.14',
        );
    expect(
      event.findElements('Name', namespaceUri: rim).single.toXmlString(),
      name,
    );
    final oldName = name.replaceAll('Source', 'Signature du lot');
    final oldMetadata = packet.metadata.replaceFirst(name, oldName);
    final oldSoap = packet.soap.replaceFirst(packet.metadata, oldMetadata);
    final old = DmpWirePacket(
      soap: oldSoap,
      metadata: oldMetadata,
      vihf: packet.vihf,
      signatureXml: packet.signatureXml,
      contentType: packet.contentType,
      mime: utf8.encode(
        utf8.decode(packet.mime).replaceFirst(packet.soap, oldSoap),
      ),
    );
    final replay = Map<String, Object?>.from(draft.replay)
      ..remove('signatureTitleProfile');
    DmpWireDraft.verifyArchived(
      evidence(old, replay),
      snapshot,
      session.evidence,
    );
    expect(() => draft.verify(old, now), throwsA(anything));
    expect(
      () => DmpWireDraft.verifyArchived(
        evidence(packet, replay),
        snapshot,
        session.evidence,
      ),
      throwsA(anything),
    );
    for (final value in ['unknown', null]) {
      expect(
        () => DmpWireDraft.verifyArchived(
          evidence(packet, {...draft.replay, 'signatureTitleProfile': value}),
          snapshot,
          session.evidence,
        ),
        throwsFormatException,
      );
    }
  });

  test('unknown or null header profiles and removed Security are rejected', () {
    for (final profile in ['unknown', null]) {
      expect(
        () => DmpWireDraft.verifyArchived(
          evidence(packet, {...draft.replay, 'soapHeaderProfile': profile}),
          snapshot,
          session.evidence,
        ),
        throwsFormatException,
      );
    }
    final xml = XmlDocument.parse(packet.soap);
    xml
        .findAllElements('Security', namespaceUri: wsse)
        .single
        .parent!
        .children
        .removeWhere(
          (node) =>
              node is XmlElement &&
              node.name.local == 'Security' &&
              node.namespaceUri == wsse,
        );
    expect(
      () => draft.verify(withSoap(xml.toXmlString()), now),
      throwsA(isA<DmpChainBlock>()),
    );
  });
}
