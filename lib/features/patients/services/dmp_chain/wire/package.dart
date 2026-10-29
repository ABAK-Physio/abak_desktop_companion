import '../native/dv1_replacement.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import '../../document_cda_builder.dart';
import '../../document_medical_service.dart';
import '../contracts.dart';
import '../messages.dart';
import 'crypto.dart';
import '../../cnda_patient_recipe.dart';

/// Configuration is explicit, versioned and sealed with the packet. No real
/// endpoint, installation OID or homologation identifier is supplied by default.
class DmpWireConfiguration {
  const DmpWireConfiguration({
    required this.endpoint,
    required this.sourceId,
    required this.lpsId,
    required this.lpsName,
    required this.lpsVersion,
    required this.homologationId,
  });
  final String endpoint, sourceId, lpsId, lpsName, lpsVersion, homologationId;
  Map<String, Object?> get evidence => {
    'profile': 'SEL-MP-037-2.10-A6-2',
    'endpoint': endpoint,
    'sourceId': sourceId,
    'lpsId': lpsId,
    'lpsName': lpsName,
    'lpsVersion': lpsVersion,
    'homologationId': homologationId,
  };
  void check() {
    final uri = Uri.tryParse(endpoint);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment ||
        uri.hasQuery ||
        uri.path.isEmpty) {
      throw const DmpChainBlock(
        'Adresse du service non définie pour le profil.',
      );
    }
    DocumentCdaBuilder.oid(sourceId);
    for (final v in [
      endpoint,
      sourceId,
      lpsId,
      lpsName,
      lpsVersion,
      homologationId,
    ]) {
      if (v.trim().isEmpty ||
          v.length > 512 ||
          RegExp(r'[\x00-\x1f\x7f]').hasMatch(v)) {
        throw const DmpChainBlock('Configuration LPS incomplète ou invalide.');
      }
    }
  }
}

/// Assessment is a port contract: chain, trust and revocation must already have
/// been checked for THESE two fingerprints and THIS authenticated professional.
/// The isolated adapter uses a synthetic CA and an archived, signed synthetic CRL.
class DmpWireMaterial {
  const DmpWireMaterial({
    required this.configuration,
    required this.authenticationDer,
    required this.signingDer,
    required this.authenticationHash,
    required this.signingHash,
    required this.professional,
    required this.assessmentId,
    required this.assessedAt,
    required this.validUntil,
    required this.trustedAndNotRevoked,
  });
  final DmpWireConfiguration configuration;
  final String authenticationDer,
      signingDer,
      authenticationHash,
      signingHash,
      professional,
      assessmentId;
  final DateTime assessedAt, validUntil;
  final bool trustedAndNotRevoked;
  Map<String, Object?> get evidence => {
    'configuration': configuration.evidence,
    'authenticationCertificateHash': authenticationHash,
    'signingCertificateHash': signingHash,
    'professional': professional,
    'assessmentId': assessmentId,
    'assessedAt': assessedAt.toUtc().toIso8601String(),
    'validUntil': validUntil.toUtc().toIso8601String(),
    'trustedAndNotRevoked': trustedAndNotRevoked,
  };
  void check(DmpSession s, DateTime now) {
    configuration.check();
    final auth = DmpWireCertificate.parse(authenticationDer),
        sign = DmpWireCertificate.parse(signingDer);
    if (!trustedAndNotRevoked ||
        assessmentId.isEmpty ||
        now.isBefore(assessedAt) ||
        !now.isBefore(validUntil) ||
        now.difference(assessedAt) > const Duration(minutes: 2) ||
        professional != s.professional ||
        auth.hash != authenticationHash ||
        sign.hash != signingHash ||
        authenticationHash != s.certificateHash ||
        auth.commonName != s.professional ||
        sign.commonName != s.professional ||
        !auth.digitalSignature ||
        !auth.clientAuthentication ||
        !sign.contentCommitment ||
        auth.hash == sign.hash ||
        [auth, sign].any(
          (c) => now.isBefore(c.validFrom) || !now.isBefore(c.validUntil),
        ) ||
        now.isBefore(s.issuedAt) ||
        !now.isBefore(s.expiresAt) ||
        now.difference(s.issuedAt) > const Duration(minutes: 2)) {
      throw const DmpChainBlock(
        'Certificats, usages, identité, révocation ou fraîcheur non vérifiés.',
      );
    }
  }
}

abstract interface class DocumentDmpWirePorts implements DocumentDmpPorts {
  Future<DmpWireMaterial> wireMaterial(DmpSession session);

  /// Return only RSA signature bytes (base64). No private key enters the product.
  Future<String> signCanonicalXml(
    String signedInfo,
    String certificateHash,
    DmpSession session,
  );
}

class DmpWirePacket {
  DmpWirePacket({
    required this.soap,
    required this.metadata,
    required this.vihf,
    required this.signatureXml,
    required this.contentType,
    required List<int> mime,
  }) : mime = List<int>.unmodifiable(mime);
  final String soap, metadata, vihf, signatureXml, contentType;
  final List<int> mime;
  Map<String, Object?> get evidence => {
    'soap': soap,
    'metadata': metadata,
    'vihf': vihf,
    'signatureXml': signatureXml,
    'contentType': contentType,
    'mime': base64Encode(mime),
    'mimeSha256': sha256.convert(mime).toString(),
    'contentLength': mime.length,
  };
}

/// Pure deterministic assembly from a captured approved version. Fresh IDs are
/// generated once; verification reconstructs the expected packet, not an
/// untrusted XML graph. This rejects wrapping, extra references/parts and rewrites.
class DmpWireDraft {
  DmpWireDraft(
    Map<String, dynamic> snapshot,
    this.session,
    List<int> cda,
    this.material,
    this.time, {
    required this.approvedAt,
    this.replacementEntryUuid,
    Map<String, String>? identifiers,
  }) : _snapshot = medicalCanonical(snapshot),
       cda = List.unmodifiable(cda),
       messageId = identifiers?['messageId'] ?? DmpChainMessages.id,
       lotOid = identifiers?['lotOid'] ?? _oid(),
       signatureOid = identifiers?['signatureOid'] ?? _oid(),
       cdaEntry = identifiers?['cdaEntry'] ?? 'Document_${const Uuid().v4()}',
       signatureEntry =
           identifiers?['signatureEntry'] ?? 'Signature_${const Uuid().v4()}',
       submissionEntry =
           identifiers?['submissionEntry'] ?? 'Submission_${const Uuid().v4()}',
       nonce = identifiers?['nonce'] ?? const Uuid().v4() {
    final replacement = Dv1Replacement.fromPreparation(preparation);
    if ((replacement == null) != (replacementEntryUuid == null) ||
        (replacementEntryUuid != null &&
            !RegExp(
              r'^urn:uuid:[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
            ).hasMatch(replacementEntryUuid!))) {
      throw const DmpChainBlock(
        'Identifiant technique de remplacement absent ou invalide.',
      );
    }
    if (replacement != null &&
        replacement['patientCx'] != DmpChainMessages.patientCx(this.snapshot)) {
      throw const DmpChainBlock(
        'Le patient du remplacement diffère du dépôt initial.',
      );
    }
    if (cda.length > 30 * 1024 * 1024) {
      throw const DmpChainBlock('CDA trop volumineux.');
    }
    material.check(session, time);
    for (final oid in [lotOid, signatureOid]) {
      DocumentCdaBuilder.oid(oid);
    }
    final ids = [cdaEntry, signatureEntry, submissionEntry];
    if (ids.toSet().length != 3 ||
        !ids.every(
          (v) => RegExp(
            r'^(Document|Signature|Submission)_[0-9a-f-]{36}$',
          ).hasMatch(v),
        ) ||
        !RegExp(r'^urn:uuid:[0-9a-f-]{36}$').hasMatch(messageId) ||
        !RegExp(r'^[0-9a-f-]{36}$').hasMatch(nonce)) {
      throw const DmpChainBlock('Identifiants de paquet invalides.');
    }
    CndaPatientRecipe.checkDestination(
      snapshot,
      material.configuration.endpoint,
    );
    final d = preparation, c = practice, i = identity;
    if (session.professional != c['identifier'] ||
        session.authority != c['authority'] ||
        session.structure != c['structureId'] ||
        session.contextHash != medicalHash(this.snapshot['practice']) ||
        c['setting'] != 'Ambulatoire' ||
        c['professionCode'] != 'G15_70' ||
        c['professionSystem'] != '1.2.250.1.213.1.1.4.5' ||
        (c['replacementFor'] ?? '') != '' ||
        d['authorId'] != d['validatorId'] ||
        d['patientVisibility'] != 'visible' ||
        d['professionalVisibility'] != 'visible' ||
        d['representativesVisibility'] != 'sans objet' ||
        i['ins_oid'] != '1.2.250.1.213.1.4.10') {
      throw const DmpChainBlock(
        'Contexte hors du profil direct, adulte, kiné et ambulatoire vérifié.',
      );
    }
    // HL7 separators cannot occur inside components; escaping XML is separate.
    for (final value in [
      c['identifier'],
      c['familyName'],
      c['givenNames'],
      c['structureId'],
      c['structureName'],
      c['professionLabel'],
      i['birth_last_name'],
      i['birth_first_names'],
    ]) {
      if (value == null ||
          value.toString().trim().isEmpty ||
          RegExp(r'[\^~|&\\\r\n]').hasMatch(value.toString())) {
        throw const DmpChainBlock(
          'Composant HL7 absent ou contenant un séparateur.',
        );
      }
    }
    final xml = DmpWireCrypto.parse(utf8.decode(this.cda));
    if (xml.rootElement.name.local != 'ClinicalDocument' ||
        xml.rootElement.namespaceUri != 'urn:hl7-org:v3') {
      throw const DmpChainBlock('CDA attendu.');
    }
    final expected = DocumentCdaBuilder.documentId(this.snapshot);
    if (xml.rootElement.childElements
            .where((e) => e.name.local == 'id')
            .single
            .getAttribute('root') !=
        expected) {
      throw const DmpChainBlock(
        'Identifiant CDA différent de la version validée.',
      );
    }
    documentOid = expected;
    final patient = DmpWireCrypto.one(
      xml,
      'patientRole',
    ).childElements.where((e) => e.name.local == 'id').single;
    final body = DmpWireCrypto.one(
      DmpWireCrypto.one(xml, 'nonXMLBody'),
      'text',
    );
    if (patient.getAttribute('root') != i['ins_oid'] ||
        patient.getAttribute('extension') != ins ||
        body.getAttribute('mediaType') != 'application/pdf' ||
        body.getAttribute('representation') != 'B64' ||
        sha256.convert(base64Decode(body.innerText)).toString() !=
            this.snapshot['version']['sha256']) {
      throw const DmpChainBlock(
        'Patient ou PDF encapsulé différent du contenu validé.',
      );
    }
    final expectedCda = DocumentCdaBuilder.build(
      this.snapshot,
      Uint8List.fromList(base64Decode(body.innerText)),
      approvedAt,
    );
    if (sha256.convert(expectedCda).toString() !=
        sha256.convert(this.cda).toString()) {
      throw const DmpChainBlock(
        'CDA différent du contexte approuvé : relancer les contrôles locaux.',
      );
    }
    _signatureTemplate = _signature();
  }
  // Legacy headers are reconstructed only when verifying an existing archive.
  final String? replacementEntryUuid;
  bool _legacySoapHeaders = false;
  bool _legacyXdsPatientId = false;
  bool _legacyXdsMetadata = false;
  bool _legacySignatureTitle = false;
  Map<String, Object?> get replay => {
    if (replacementEntryUuid != null)
      'replacementEntryUuid': replacementEntryUuid,
    if (!_legacySoapHeaders) 'soapHeaderProfile': 'dv1-20261028',
    if (!_legacyXdsPatientId) 'xdsPatientIdProfile': 'ins-nh-1',
    if (!_legacyXdsMetadata) 'xdsMetadataProfile': 'dv1-labels-signature-1',
    if (!_legacySignatureTitle) 'signatureTitleProfile': 'event-source-1',
    'time': time.toUtc().toIso8601String(),
    'approvedAt': approvedAt,
    'cda': base64Encode(cda),
    'identifiers': {
      'messageId': messageId,
      'lotOid': lotOid,
      'signatureOid': signatureOid,
      'cdaEntry': cdaEntry,
      'signatureEntry': signatureEntry,
      'submissionEntry': submissionEntry,
      'nonce': nonce,
    },
    'authenticationDer': material.authenticationDer,
    'signingDer': material.signingDer,
    'material': material.evidence,
  };
  static void verifyArchived(
    Map package,
    Map<String, dynamic> snapshot,
    Map authentication,
  ) {
    if (package['protocol'] != 'DMP-XDS-XADES-MTOM-2.10') {
      throw const FormatException('Profil inconnu');
    }
    final wire = package['wire'] as Map,
        saved = wire['replay'] as Map,
        m = saved['material'] as Map,
        config = m['configuration'] as Map;
    final session = DmpSession(
      nativeEvidenceJson: authentication['native'] == null
          ? null
          : jsonEncode(authentication['native']),
      id: authentication['id'],
      professional: authentication['professional'],
      authority: authentication['authority'],
      structure: authentication['structure'],
      certificateHash: authentication['certificateHash'],
      contextHash: authentication['contextHash'],
      issuedAt: DateTime.parse(authentication['issuedAt']),
      expiresAt: DateTime.parse(authentication['expiresAt']),
    );
    final material = DmpWireMaterial(
      configuration: DmpWireConfiguration(
        endpoint: config['endpoint'],
        sourceId: config['sourceId'],
        lpsId: config['lpsId'],
        lpsName: config['lpsName'],
        lpsVersion: config['lpsVersion'],
        homologationId: config['homologationId'],
      ),
      authenticationDer: saved['authenticationDer'],
      signingDer: saved['signingDer'],
      authenticationHash: m['authenticationCertificateHash'],
      signingHash: m['signingCertificateHash'],
      professional: m['professional'],
      assessmentId: m['assessmentId'],
      assessedAt: DateTime.parse(m['assessedAt']),
      validUntil: DateTime.parse(m['validUntil']),
      trustedAndNotRevoked: m['trustedAndNotRevoked'],
    );
    if (saved.containsKey('soapHeaderProfile') &&
        saved['soapHeaderProfile'] != 'dv1-20261028') {
      throw const FormatException('Profil des en-têtes SOAP inconnu');
    }
    if (saved.containsKey('xdsPatientIdProfile') &&
        saved['xdsPatientIdProfile'] != 'ins-nh-1') {
      throw const FormatException('Profil patientId XDS inconnu');
    }
    if (saved.containsKey('xdsMetadataProfile') &&
        saved['xdsMetadataProfile'] != 'dv1-labels-signature-1') {
      throw const FormatException('Profil des métadonnées XDS inconnu');
    }
    if (saved.containsKey('signatureTitleProfile') &&
        saved['signatureTitleProfile'] != 'event-source-1') {
      throw const FormatException('Profil du titre de signature inconnu');
    }
    final draft = DmpWireDraft(
      snapshot,
      session,
      base64Decode(saved['cda']),
      material,
      DateTime.parse(saved['time']),
      identifiers: Map<String, String>.from(saved['identifiers']),
      approvedAt: saved['approvedAt'] as int,
      replacementEntryUuid: saved['replacementEntryUuid'] as String?,
    );
    draft._legacySoapHeaders = !saved.containsKey('soapHeaderProfile');
    draft._legacyXdsPatientId = !saved.containsKey('xdsPatientIdProfile');
    draft._legacyXdsMetadata = !saved.containsKey('xdsMetadataProfile');
    draft._legacySignatureTitle = !saved.containsKey('signatureTitleProfile');
    final packet = DmpWirePacket(
      soap: wire['soap'],
      metadata: wire['metadata'],
      vihf: wire['vihf'],
      signatureXml: wire['signatureXml'],
      contentType: wire['contentType'],
      mime: base64Decode(wire['mime']),
    );
    draft.verify(packet, draft.time);
    final expected = <String, Object?>{
      ...packet.evidence,
      'material': material.evidence,
      'authenticationDer': material.authenticationDer,
      'signingCertificateHash': material.signingHash,
      'signedInfo': draft.signedInfo,
      'replay': draft.replay,
    };
    if (medicalCanonical(expected) != medicalCanonical(wire) ||
        package['request'] != packet.soap ||
        package['metadata'] != packet.metadata ||
        package['vihf'] != packet.vihf ||
        package['messageId'] != draft.messageId ||
        package['snapshotHash'] != medicalHash(snapshot) ||
        package['sessionHash'] != medicalHash(session.evidence) ||
        package['cdaHash'] != sha256.convert(draft.cda).toString()) {
      throw const FormatException('Preuve de paquet incohérente');
    }
  }

  static const action = 'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b';
  static const ds = DmpWireCrypto.ds, xades = DmpWireCrypto.xades;
  static const rim = DmpChainMessages.rim, xds = DmpChainMessages.xds;
  static const saml = 'urn:oasis:names:tc:SAML:2.0:assertion';
  final String _snapshot,
      messageId,
      lotOid,
      signatureOid,
      cdaEntry,
      signatureEntry,
      submissionEntry,
      nonce;
  final DmpSession session;
  final DmpWireMaterial material;
  final DateTime time;
  final int approvedAt;
  final List<int> cda;
  late final String documentOid, _signatureTemplate;
  Map<String, dynamic> get snapshot => jsonDecode(_snapshot);
  Map get preparation => jsonDecode(snapshot['preparation']['data_json']);
  Map get practice => jsonDecode(snapshot['practice']['data_json']);
  Map get identity => snapshot['identity'];
  String get ins => '${identity['ins_number']}${identity['ins_key']}';
  String get cx => '$ins^^^&${identity['ins_oid']}&ISO';
  // CI-SIS patientId requires CX.5=NH. Legacy form is archive-only.
  String get xdsPatientId => _legacyXdsPatientId ? cx : '$cx^NH';
  DmpWireCertificate get signing =>
      DmpWireCertificate.parse(material.signingDer);
  static String _oid() =>
      '2.25.${BigInt.parse(const Uuid().v4().replaceAll('-', ''), radix: 16)}';
  static String esc(Object? v) => const HtmlEscape().convert(v.toString());
  static String compact(DateTime v) => v
      .toUtc()
      .toIso8601String()
      .substring(0, 19)
      .replaceAll(RegExp('[-:T]'), '');
  static String tag(
    String n,
    String body, [
    Map<String, Object?> a = const {},
  ]) =>
      '<$n${a.entries.map((e) => ' ${e.key}="${esc(e.value)}"').join()}>$body</$n>';
  static String text(
    String n,
    Object? v, [
    Map<String, Object?> a = const {},
  ]) => tag(n, esc(v), a);
  static String reference(
    String uri,
    String digest, {
    String? type,
    bool transform = false,
  }) => tag(
    'ds:Reference',
    (transform
            ? tag(
                'ds:Transforms',
                tag('ds:Transform', '', {'Algorithm': DmpWireCrypto.c14n}),
              )
            : '') +
        tag('ds:DigestMethod', '', {'Algorithm': '${ds}sha1'}) +
        text('ds:DigestValue', digest),
    {'URI': uri, 'Type': ?type},
  );
  String _signature() => lotSignatureTemplate(
    certificate: signing,
    cda: cda,
    time: time,
    lotOid: lotOid,
    signatureOid: signatureOid,
    documentOid: documentOid,
  );

  /// Pure XAdES construction shared by the local CPS route and the wire route.
  /// No TLS session, VIHF assertion or trust assessment is fabricated here.
  static String lotSignatureTemplate({
    required DmpWireCertificate certificate,
    required List<int> cda,
    required DateTime time,
    required String lotOid,
    required String signatureOid,
    required String documentOid,
  }) {
    for (final oid in [lotOid, signatureOid, documentOid]) {
      DocumentCdaBuilder.oid(oid);
    }
    final cert = certificate;
    final properties = tag(
      'xades:QualifyingProperties',
      tag(
        'xades:SignedProperties',
        tag(
          'xades:SignedSignatureProperties',
          text('xades:SigningTime', time.toUtc().toIso8601String()) +
              tag(
                'xades:SigningCertificate',
                tag(
                  'xades:Cert',
                  tag(
                        'xades:CertDigest',
                        tag('xades:DigestMethod', '', {
                              'Algorithm': '${ds}sha1',
                            }) +
                            text(
                              'xades:DigestValue',
                              DmpWireCrypto.digest(base64Decode(cert.base64)),
                            ),
                      ) +
                      tag(
                        'xades:IssuerSerial',
                        text('ds:X509IssuerName', cert.issuer) +
                            text('ds:X509SerialNumber', cert.serial),
                      ),
                ),
              ) +
              tag(
                'xades:SignaturePolicyIdentifier',
                tag('xades:SignaturePolicyImplied', ''),
              ),
        ),
        {'Id': 'S0-SignedProperties'},
      ),
      {'xmlns:xades': xades, 'Target': '#$signatureOid'},
    );
    final xml = DmpWireCrypto.parse(
      tag(
        'ds:Signature',
        tag(
              'ds:SignedInfo',
              tag('ds:CanonicalizationMethod', '', {
                    'Algorithm': DmpWireCrypto.c14n,
                  }) +
                  tag('ds:SignatureMethod', '', {
                    'Algorithm': DmpWireCrypto.rsa,
                  }) +
                  reference(
                    '#IHEManifest',
                    '',
                    type: '${ds}Manifest',
                    transform: true,
                  ) +
                  reference(
                    '#S0-SignedProperties',
                    '',
                    type: '${xades}SignedProperties',
                    transform: true,
                  ),
            ) +
            tag('ds:SignatureValue', '') +
            tag(
              'ds:KeyInfo',
              tag('ds:X509Data', text('ds:X509Certificate', cert.base64)),
            ) +
            tag(
              'ds:Object',
              tag(
                'ds:SignatureProperties',
                text('ds:SignatureProperty', '1.2.840.10065.1.12.1.14', {
                  'Id': 'purposeOfSignature',
                  'Target': '#$signatureOid',
                }),
              ),
            ) +
            tag(
              'ds:Object',
              tag(
                'ds:Manifest',
                reference('urn:oid:$lotOid', 'AA==') +
                    reference(
                      'urn:oid:$documentOid',
                      DmpWireCrypto.digest(
                        utf8.encode(
                          DmpWireCrypto.canonical(
                            DmpWireCrypto.parse(utf8.decode(cda)).rootElement,
                          ),
                        ),
                      ),
                      transform: true,
                    ),
                {'Id': 'IHEManifest'},
              ),
            ) +
            tag('ds:Object', properties),
        {'xmlns:ds': ds, 'Id': signatureOid},
      ),
    );
    final refs = DmpWireCrypto.one(
      xml,
      'SignedInfo',
    ).childElements.where((e) => e.name.local == 'Reference').toList();
    for (var n = 0; n < 2; n++) {
      DmpWireCrypto.one(
        refs[n],
        'DigestValue',
      ).innerText = DmpWireCrypto.digest(
        utf8.encode(
          DmpWireCrypto.canonical(
            DmpWireCrypto.one(xml, n == 0 ? 'Manifest' : 'SignedProperties'),
          ),
        ),
      );
    }
    return xml.toXmlString();
  }

  String get signedInfo => DmpWireCrypto.canonical(
    DmpWireCrypto.one(DmpWireCrypto.parse(_signatureTemplate), 'SignedInfo'),
  );
  String _vihf() => buildVihf(snapshot, session, material, time, nonce);
  static String buildVihf(
    Map<String, dynamic> snapshot,
    DmpSession session,
    DmpWireMaterial material,
    DateTime time,
    String nonce, {
    bool secretConnection = false,
  }) {
    final c = jsonDecode(snapshot['practice']['data_json']),
        config = material.configuration;
    final cx = DmpChainMessages.patientCx(snapshot);
    final attributes = <String, String>{
      'Identifiant_Structure': session.structure,
      'Secteur_Activite': '${c['facilityCode']}^1.2.250.1.71.4.2.4',
      'VIHF_Version': '3.0',
      'Authentification_Mode': 'DIRECTE',
      'urn:oasis:names:tc:xacml:2.0:resource:resource-id': '$cx^NH',
      'Ressource_URN': 'urn:dmp',
      'LPS_ID': config.lpsId,
      'LPS_Nom': config.lpsName,
      'LPS_Version': config.lpsVersion,
      'LPS_ID_HOMOLOGATION_DMP': config.homologationId,
      if (secretConnection)
        'urn:oasis:names:tc:xspa:1.0:resource:patient:hl7:confidentiality-code':
            'INVISIBLE_REPRESENTANTS_LEGAUX^1.2.250.1.213.1.1.4.13',
    };
    String attr(String name, String value) =>
        tag('saml:Attribute', value, {'Name': name});
    return tag(
      'saml:Assertion',
      text(
            'saml:Issuer',
            DmpWireCertificate.parse(material.authenticationDer).subject,
            {
              'Format':
                  'urn:oasis:names:tc:SAML:1.1:nameid-format:X509SubjectName',
            },
          ) +
          tag('saml:Subject', text('saml:NameID', session.professional)) +
          tag(
            'saml:AuthnStatement',
            tag(
              'saml:AuthnContext',
              text(
                'saml:AuthnContextClassRef',
                'urn:oasis:names:tc:SAML:2.0:ac:classes:SmartcardPKI',
              ),
            ),
            {'AuthnInstant': session.issuedAt.toUtc().toIso8601String()},
          ) +
          tag(
            'saml:AttributeStatement',
            attributes.entries
                    .map(
                      (e) => attr(
                        e.key,
                        text('saml:AttributeValue', e.value, {
                          'xsi:type': 'xs:string',
                        }),
                      ),
                    )
                    .join() +
                attr(
                  'urn:oasis:names:tc:xacml:2.0:subject:role',
                  tag(
                    'saml:AttributeValue',
                    tag('hl7:Role', '', {
                      'code': '70',
                      'codeSystem': '1.2.250.1.71.1.2.7',
                      'displayName': c['professionLabel'],
                      'xsi:type': 'hl7:CE',
                    }),
                  ),
                ) +
                attr(
                  'urn:oasis:names:tc:xspa:1.0:subject:purposeofuse',
                  tag(
                    'saml:AttributeValue',
                    tag('hl7:PurposeOfUse', '', {
                      'code': 'normal',
                      'codeSystem': '1.2.250.1.213.1.1.4.248',
                      'displayName': 'Accès normal',
                      'xsi:type': 'hl7:CE',
                    }),
                  ),
                ),
          ),
      {
        'xmlns:saml': saml,
        'xmlns:hl7': 'urn:hl7-org:v3',
        'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:xs': 'http://www.w3.org/2001/XMLSchema',
        'ID': '_$nonce',
        'Version': '2.0',
        'IssueInstant': time.toUtc().toIso8601String(),
      },
    );
  }

  String _registry(List<int> signature) {
    final c = practice, d = preparation, i = identity;
    // Exact J56 label from the accepted DV1 reference, for the G15_70-only
    // profile checked by the constructor. Do not rewrite the clinical context.
    final specialty = _legacyXdsMetadata
        ? c['professionLabel']
        : 'Masseur-Kinésithérapeute';
    var counter = 0;
    String id() =>
        'Object_${const Uuid().v5(Namespace.url.value, '$nonce:${counter++}')}';
    String name(String s) =>
        tag('rim:Name', tag('rim:LocalizedString', '', {'value': s}));
    String slot(String n, List<String> values) => tag(
      'rim:Slot',
      tag('rim:ValueList', values.map((v) => text('rim:Value', v)).join()),
      {'name': n},
    );
    String classification(
      String obj,
      String scheme,
      String code,
      String system,
      String label,
    ) => tag(
      'rim:Classification',
      slot('codingScheme', [system]) + name(label),
      {
        'id': id(),
        'classifiedObject': obj,
        'classificationScheme': 'urn:uuid:$scheme',
        'nodeRepresentation': code,
      },
    );
    String external(String obj, String scheme, String value, String label) =>
        tag('rim:ExternalIdentifier', name(label), {
          'id': id(),
          'registryObject': obj,
          'identificationScheme': 'urn:uuid:$scheme',
          'value': value,
        });
    final person =
        '${c['identifier']}^${c['familyName']}^${c['givenNames']}^^^^^^&${c['authority']}&ISO^D^^^IDNPS';
    String author(String obj, String scheme) => tag(
      'rim:Classification',
      slot('authorPerson', [person]) +
          slot('authorInstitution', [
            '${c['structureName']}^^^^^&${c['structureAuthority']}&ISO^IDNST^^^${c['structureId']}',
          ]) +
          slot('authorSpecialty', [
            '${c['professionCode']}^$specialty^${c['professionSystem']}',
          ]),
      {
        'id': id(),
        'classifiedObject': obj,
        'classificationScheme': 'urn:uuid:$scheme',
        'nodeRepresentation': '',
      },
    );
    String document(String obj, String oid, List<int> bytes, bool sig) => tag(
      'rim:ExtrinsicObject',
      slot('creationTime', [
            sig ? compact(time) : compact(DateTime.parse(d['clinicalDate'])),
          ]) +
          slot('languageCode', [d['language']]) +
          slot('hash', [sha1.convert(bytes).toString()]) +
          slot('size', ['${bytes.length}']) +
          slot('legalAuthenticator', [person]) +
          slot('serviceStartTime', [
            sig && !_legacyXdsMetadata
                ? compact(time)
                : compact(DateTime.parse(d['clinicalDate'])),
          ]) +
          slot('serviceStopTime', [
            sig && !_legacyXdsMetadata
                ? compact(time)
                : compact(DateTime.parse(d['clinicalDate'])),
          ]) +
          slot('sourcePatientId', ['$cx^NH']) +
          (sig && !_legacyXdsMetadata
              ? ''
              : slot('sourcePatientInfo', [
                  'PID-5|${i['birth_last_name']}^${i['birth_first_names']}^^^^^L',
                  'PID-7|${i['birth_date'].replaceAll('-', '')}',
                  'PID-8|${i['sex_code']}',
                ])) +
          name(
            sig
                ? (_legacySignatureTitle ? 'Signature du lot' : 'Source')
                : d['title'],
          ) +
          author(obj, '93606bcf-9494-43ec-9b4e-a7748d1a838d') +
          classification(
            obj,
            '41a5887f-8865-4c09-adf7-e362475b143a',
            sig ? 'urn:oid:1.3.6.1.4.1.19376.1.2.1.1.1' : d['classCode'],
            sig ? 'URN' : d['classSystem'],
            sig ? 'Digital Signature' : d['classLabel'],
          ) +
          classification(
            obj,
            'f0306f51-975f-434e-a61c-c59651d33983',
            sig ? 'E1762' : d['typeCode'],
            sig ? 'ASTM' : d['typeSystem'],
            sig ? 'Full Document' : d['typeLabel'],
          ) +
          classification(
            obj,
            'f4f85eac-e6cb-4883-b524-f2705394840f',
            'N',
            '2.16.840.1.113883.5.25',
            'Normal',
          ) +
          (sig
              ? classification(
                      obj,
                      'f4f85eac-e6cb-4883-b524-f2705394840f',
                      'MASQUE_PS',
                      '1.2.250.1.213.1.1.4.13',
                      _legacyXdsMetadata
                          ? 'Masqué aux professionnels'
                          : 'Masqué aux professionnels de santé',
                    ) +
                    classification(
                      obj,
                      'f4f85eac-e6cb-4883-b524-f2705394840f',
                      'INVISIBLE_PATIENT',
                      '1.2.250.1.213.1.1.4.13',
                      _legacyXdsMetadata
                          ? 'Invisible au patient'
                          : 'Non visible par le patient',
                    ) +
                    classification(
                      obj,
                      '2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4',
                      '1.2.840.10065.1.12.1.14',
                      '1.2.840.10065.1.12',
                      'Source',
                    )
              : '') +
          classification(
            obj,
            'a09d5840-386c-46f2-b5ad-9c3699a4309d',
            sig ? ds : 'urn:ihe:iti:xds-sd:pdf:2008',
            sig ? 'URN' : '1.3.6.1.4.1.19376.1.2.3',
            sig
                ? (_legacyXdsMetadata
                      ? 'Signature électronique'
                      : 'Default Signature Style')
                : 'Document à corps non structuré en Pdf/A-1',
          ) +
          classification(
            obj,
            'f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1',
            c['facilityCode'],
            '1.2.250.1.71.4.2.4',
            c['facilityLabel'],
          ) +
          classification(
            obj,
            'cccf5598-8b07-4b77-a05e-ae952c785ead',
            'AMBULATOIRE',
            '1.2.250.1.213.1.1.4.9',
            'Ambulatoire',
          ) +
          external(
            obj,
            '58a6f841-87b3-4a3e-92fd-a8ffeff98427',
            xdsPatientId,
            'XDSDocumentEntry.patientId',
          ) +
          external(
            obj,
            '2e82c1f6-a085-4c72-9da3-8640a32e42ab',
            oid,
            'XDSDocumentEntry.uniqueId',
          ),
      {
        'id': obj,
        'mimeType': 'text/xml',
        'objectType': 'urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1',
      },
    );
    String association(String type, String source, String target) =>
        tag('rim:Association', slot('SubmissionSetStatus', ['Original']), {
          'id': id(),
          'associationType': type,
          'sourceObject': source,
          'targetObject': target,
        });
    return tag(
      'rim:RegistryObjectList',
      (replacementEntryUuid == null
              ? ''
              : tag('rim:Association', '', {
                  'id': id(),
                  'associationType': 'urn:ihe:iti:2007:AssociationType:RPLC',
                  'sourceObject': cdaEntry,
                  'targetObject': replacementEntryUuid!,
                })) +
          document(cdaEntry, documentOid, cda, false) +
          document(signatureEntry, signatureOid, signature, true) +
          tag(
            'rim:RegistryPackage',
            slot('submissionTime', [compact(time)]) +
                name(d['title']) +
                author(
                  submissionEntry,
                  'a7058bb9-b4e4-4307-ba5b-e3f0ab85e12d',
                ) +
                classification(
                  submissionEntry,
                  'aa543740-bdda-424e-8c96-df4873be8500',
                  c['facilityCode'],
                  '1.2.250.1.71.4.2.4',
                  c['facilityLabel'],
                ) +
                external(
                  submissionEntry,
                  '6b5aea1a-874d-4603-a4bc-96a0a7b38446',
                  xdsPatientId,
                  'XDSSubmissionSet.patientId',
                ) +
                external(
                  submissionEntry,
                  '554ac39e-e3fe-47fe-b233-965d2a147832',
                  material.configuration.sourceId,
                  'XDSSubmissionSet.sourceId',
                ) +
                external(
                  submissionEntry,
                  '96fdda7c-d067-4183-912e-bf5ee74998a8',
                  lotOid,
                  'XDSSubmissionSet.uniqueId',
                ),
            {'id': submissionEntry},
          ) +
          tag('rim:Classification', '', {
            'id': id(),
            'classifiedObject': submissionEntry,
            'classificationNode':
                'urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd',
          }) +
          association(
            'urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember',
            submissionEntry,
            cdaEntry,
          ) +
          association(
            'urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember',
            submissionEntry,
            signatureEntry,
          ) +
          association(
            'urn:ihe:iti:2007:AssociationType:signs',
            signatureEntry,
            submissionEntry,
          ),
      {'xmlns:rim': rim},
    );
  }

  DmpWirePacket finish(String value) {
    if (!DmpWireCrypto.verify(signedInfo, signing, value)) {
      throw const DmpChainBlock(
        'Signature RSA du lot invalide ou certificat de signature différent.',
      );
    }
    final xml = DmpWireCrypto.parse(_signatureTemplate);
    DmpWireCrypto.one(xml, 'SignatureValue').innerText = value;
    final signature = xml.toXmlString(),
        registry = _registry(utf8.encode(signature)),
        vihf = _vihf();
    final soap = tag(
      's:Envelope',
      tag(
            's:Header',
            text('w:MessageID', messageId) +
                text('w:To', material.configuration.endpoint, {
                  's:mustUnderstand': 'true',
                }) +
                text('w:Action', action, {'s:mustUnderstand': 'true'}) +
                tag(
                  'w:ReplyTo',
                  text('w:Address', '${DmpChainMessages.wsa}/anonymous'),
                  _legacySoapHeaders ? {'s:mustUnderstand': 'true'} : {},
                ) +
                // Match the accepted DV1 exchange: retain VIHF Security but do
                // not require its processing by the SOAP mustUnderstand layer.
                tag(
                  'wsse:Security',
                  vihf,
                  _legacySoapHeaders ? {'s:mustUnderstand': 'true'} : {},
                ),
          ) +
          tag(
            's:Body',
            tag(
              'xds:ProvideAndRegisterDocumentSetRequest',
              tag('lcm:SubmitObjectsRequest', registry) +
                  tag(
                    'xds:Document',
                    tag('xop:Include', '', {'href': 'cid:cda@$nonce'}),
                    {'id': cdaEntry},
                  ) +
                  tag(
                    'xds:Document',
                    tag('xop:Include', '', {'href': 'cid:signature@$nonce'}),
                    {'id': signatureEntry},
                  ),
            ),
          ),
      {
        'xmlns:s': DmpChainMessages.soap,
        'xmlns:w': DmpChainMessages.wsa,
        'xmlns:xds': xds,
        'xmlns:lcm': 'urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0',
        'xmlns:wsse':
            'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
        'xmlns:xop': 'http://www.w3.org/2004/08/xop/include',
      },
    );
    final boundary = 'ABAK_MTOM_$nonce';
    final parts = [utf8.encode(soap), cda, utf8.encode(signature)];
    if (parts.any((p) => latin1.decode(p).contains(boundary))) {
      throw const DmpChainBlock('Collision MIME.');
    }
    final mime = <int>[];
    for (var n = 0; n < 3; n++) {
      final cid = ['soap', 'cda', 'signature'][n];
      final type = n == 0
          ? 'application/xop+xml; charset=UTF-8; type="application/soap+xml"'
          : 'text/xml; charset=UTF-8';
      mime.addAll(
        utf8.encode(
          '--$boundary\r\nContent-Type: $type\r\nContent-Transfer-Encoding: binary\r\nContent-ID: <$cid@$nonce>\r\n\r\n',
        ),
      );
      mime.addAll(parts[n]);
      mime.addAll([13, 10]);
    }
    mime.addAll(utf8.encode('--$boundary--\r\n'));
    return DmpWirePacket(
      soap: soap,
      metadata: registry,
      vihf: vihf,
      signatureXml: signature,
      contentType:
          'multipart/related; boundary="$boundary"; type="application/xop+xml"; start="<soap@$nonce>"; start-info="application/soap+xml; action=\\"$action\\""',
      mime: mime,
    );
  }

  void verify(DmpWirePacket packet, DateTime now) {
    material.check(session, now);
    final value = DmpWireCrypto.one(
      DmpWireCrypto.parse(packet.signatureXml),
      'SignatureValue',
    ).innerText;
    if (medicalCanonical(finish(value).evidence) !=
        medicalCanonical(packet.evidence)) {
      throw const DmpChainBlock(
        'Paquet modifié : XML, métadonnées ou pièces MIME différentes.',
      );
    }
  }
}
