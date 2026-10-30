import 'dart:convert';
import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:xml_crypto/xml_crypto.dart';
import '../cps/cps_profile.dart';

/// Offline reproduction of SEL-MP-037 §A6-2 and the supplied TD2.1 example.
/// Deliberately no HTTP client, SOAP envelope or DV1 endpoint.
class DmpLocalLot {
  DmpLocalLot._(
    this.cda,
    this.registry,
    this.signature,
    this.documentOid,
    this.lotOid,
    this.signatureOid,
    this.certificateBase64,
    this.isReplacement,
  );
  final String cda, documentOid, lotOid, signatureOid, certificateBase64;
  final XmlDocument registry, signature;
  final bool isReplacement;
  bool _verified = false;
  bool get verified => _verified;
  static const ds = 'http://www.w3.org/2000/09/xmldsig#';
  static const xades = 'http://uri.etsi.org/01903/v1.1.1#';
  static const c14n =
      'http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments';
  static const rsa = '${ds}rsa-sha1';
  static const digestAlgorithm = '${ds}sha1';
  // PDT personnalisé 2.10g, Référentiel Patients, Cas12 (formation/demo).
  // Local fixture value explicitly approved by the user; not an INSi result.
  // No general-purpose derivation or default is applied to other patients.
  static const fixtureBirthPlaceCode = '24252';
  static const fixtureBirthPlaceName = 'Marcillac-Saint-Quentin';
  static const fixturePatient = '187012425258307';
  static const fixtureGivenName = 'SYLVAIN';
  static const fixtureFamilyName = 'BONNEL';
  static const fixtureBirthDate = '19870101';
  static const fixtureSex = 'M';
  static const patientSource =
      'PDT_DMP_ABAK DESKTOP COMPANION_20251127_2.10g.xlsx, '
      'Référentiel Patients, Cas12';
  static const documentType = '34120-6';
  static const documentTypeLabel = 'Bilan par professionnel de santé';
  static const fixturePatientOid = '1.2.250.1.213.1.4.10';
  static const title = 'Bilan kinésithérapique fictif — Essai DMP DV1 ABAK';
  // Stable source for this ABAK DV1 test installation, not a CNDA-issued identifier.
  static const fixtureSourceOid =
      '2.25.332388109716972519984466347285639594739';
  // Target proven by TD2.1 Success and TD3.1b on 16 October 2026.
  static const replacedUniqueId =
      '2.25.319790098659318552794330109432267023866';
  static const replacedEntryUuid =
      'urn:uuid:b51b8c4e-c93f-11f1-b851-0050569ccd24';
  static const replacedSetId = '2.25.128749800706134114472157044608096058669';
  static const replacementTitle =
      'Bilan kinésithérapique fictif — Essai de remplacement DMP DV1 ABAK';
  static const sourceNotice =
      'SEL-MP-037 v2.10.0, annexe A6-2, p. 239–242 ; '
      'TD2.1-DocumentME2.xml, TD2.1-SignatureXades.xml et TD2.1 - Alimentation_requête.xml '
      '(archive DMP_LPS_Exemple de messages_1.0.1_1 - v02.05.00).';

  static XmlDocument parseXml(String source) {
    if (source.contains('<!DOCTYPE') || source.contains('<!ENTITY')) {
      throw const FormatException(
        'DTD et entités externes interdites dans le lot local',
      );
    }
    // XML 1.0 line-end normalization (the Dart DOM retains literal CR).
    return XmlDocument.parse(
      source.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
    );
  }

  static String compactTime(DateTime time) =>
      '${time.year.toString().padLeft(4, '0')}'
      '${time.month.toString().padLeft(2, '0')}'
      '${time.day.toString().padLeft(2, '0')}'
      '${time.hour.toString().padLeft(2, '0')}'
      '${time.minute.toString().padLeft(2, '0')}'
      '${time.second.toString().padLeft(2, '0')}';

  static String hl7Time(DateTime utc, Duration offset) {
    final minutes = offset.inMinutes.abs();
    return '${compactTime(utc.toUtc().add(offset))}${offset.isNegative ? '-' : '+'}'
        '${(minutes ~/ 60).toString().padLeft(2, '0')}'
        '${(minutes % 60).toString().padLeft(2, '0')}';
  }

  static String oid() =>
      '2.25.${BigInt.parse(const Uuid().v4().replaceAll('-', ''), radix: 16)}';
  static String esc(String text) =>
      const HtmlEscape(HtmlEscapeMode.element).convert(text);
  static String hash(String text) =>
      base64Encode(sha1.convert(utf8.encode(text)).bytes);
  static Iterable<XmlElement> elements(XmlNode n, String name) =>
      n.descendants.whereType<XmlElement>().where((e) => e.name.local == name);
  static XmlElement one(XmlNode n, String name) => elements(n, name).single;
  static String canonical(XmlElement node) {
    // Preserve all in-scope namespaces for inclusive C14N of a subtree.
    final namespaces = <String, String>{};
    final parents = <XmlElement>[];
    XmlNode? cursor = node;
    while (cursor != null) {
      if (cursor is XmlElement) parents.add(cursor);
      cursor = cursor.parent;
    }
    for (final parent in parents.reversed) {
      for (final attr in parent.attributes) {
        if (attr.name.qualified == 'xmlns' || attr.name.prefix == 'xmlns') {
          namespaces[attr.name.qualified] = attr.value;
        }
      }
    }
    final copy = node.copy();
    namespaces.forEach(copy.setAttribute);
    final parsed = parseXml(copy.toXmlString()).rootElement;
    return SignedXml.canonicalizationAlgorithms[c14n]!
        .process(parsed)
        .toString();
  }

  factory DmpLocalLot.prepare({
    required CpsProfile profile,
    required CpsSituation situation,
    required String certificateBase64,
    required String cdaTemplate,
    required String registryTemplate,
    bool replacement = false,
    DateTime? now,
    Duration? localUtcOffset,
  }) {
    if (profile.nationalId != '899700870597' ||
        profile.professionCode != 70 ||
        situation.structureId != '499700870597009' ||
        situation.sector != 'SA07') {
      throw const FormatException(
        'Cet essai est réservé à la CPS et à la situation de Michel déjà vérifiées.',
      );
    }
    final cert = CertificateReference.parse(certificateBase64);
    final time = (now ?? DateTime.now()).toUtc();
    final offset = localUtcOffset ?? time.toLocal().timeZoneOffset;
    final hl7 = hl7Time(time, offset);
    final xdsTime = compactTime(time);
    final docOid = oid(), lotOid = oid(), sigOid = oid();
    final doc = parseXml(cdaTemplate);
    final root = doc.rootElement;
    root.getElement('id')!.setAttribute('root', docOid);
    root.getElement('title')!.innerText = replacement
        ? replacementTitle
        : title;
    root.getElement('code')!
      ..setAttribute('code', documentType)
      ..setAttribute('displayName', documentTypeLabel);
    XmlElement fragment(String xml) => parseXml(
      '<wrapper xmlns="urn:hl7-org:v3">$xml</wrapper>',
    ).rootElement.childElements.single.copy();
    final language = root.getElement('languageCode')!;
    final insertion = root.children.indexOf(language) + 1;
    root.children.insertAll(insertion, [
      fragment('<setId root="${replacement ? replacedSetId : oid()}"/>'),
      fragment('<versionNumber value="${replacement ? 2 : 1}"/>'),
    ]);
    final patientRole = one(doc, 'patientRole');
    patientRole.children
      ..clear()
      ..addAll([
        fragment('<id root="$fixturePatientOid" extension="$fixturePatient"/>'),
        fragment('<addr nullFlavor="NASK"/>'),
        fragment('<telecom nullFlavor="NASK"/>'),
        fragment(
          '<patient><name><given qualifier="BR">$fixtureGivenName</given>'
          '<given>$fixtureGivenName</given><family qualifier="BR">$fixtureFamilyName</family></name>'
          '<administrativeGenderCode code="$fixtureSex" codeSystem="2.16.840.1.113883.5.1"/>'
          '<birthTime value="$fixtureBirthDate"/>'
          '<birthplace><place><addr><county>$fixtureBirthPlaceCode</county><city>$fixtureBirthPlaceName</city></addr></place></birthplace></patient>',
        ),
      ]);

    for (final t in elements(doc, 'time')) {
      t.setAttribute('value', hl7);
    }
    for (final t in elements(doc, 'effectiveTime')) {
      if (t.getAttribute('value') != null) t.setAttribute('value', hl7);
    }
    for (final low in elements(doc, 'low')) {
      low.setAttribute('value', hl7);
    }
    // Replace every author/authenticator identifier, not the fixture patient.
    for (final id in elements(doc, 'id')) {
      if (id.getAttribute('root') == '1.2.250.1.71.4.2.1') {
        id.setAttribute('extension', profile.nationalId);
      }
      if (id.getAttribute('root') == '1.2.250.1.71.4.2.2') {
        id.setAttribute('extension', situation.structureId!);
      }
    }
    for (final person in elements(doc, 'assignedPerson')) {
      one(person, 'given').innerText = profile.givenName;
      one(person, 'family').innerText = profile.familyName;
      for (final prefix in elements(person, 'prefix').toList()) {
        prefix.parent!.children.remove(prefix);
      }
    }
    one(one(doc, 'representedCustodianOrganization'), 'name').innerText =
        situation.structureName!;
    // No invented clinical act: remove the surgical act from the example.
    for (final code in elements(one(doc, 'serviceEvent'), 'code').toList()) {
      code.parent!.children.remove(code);
    }
    final professionalCode =
        '<code code="G15_70" displayName="Masseur-Kinésithérapeute" '
        'codeSystem="1.2.250.1.213.1.1.4.5"/>';
    final organisation =
        '<representedOrganization>'
        '<id root="1.2.250.1.71.4.2.2" extension="${situation.structureId}"/>'
        '<name>${esc(situation.structureName!)}</name>'
        '<standardIndustryClassCode code="AMBULATOIRE" displayName="Ambulatoire" '
        'codeSystem="1.2.250.1.213.1.1.4.9"/></representedOrganization>';
    final author = one(doc, 'assignedAuthor');
    author.children.insert(
      author.children.indexOf(author.getElement('id')!) + 1,
      fragment(professionalCode),
    );
    author.children.add(fragment(organisation));
    final event = one(doc, 'serviceEvent');
    one(event, 'effectiveTime').children.add(fragment('<high value="$hl7"/>'));
    event.children.add(
      fragment(
        '<performer typeCode="PRF"><assignedEntity>'
        '<id root="1.2.250.1.71.4.2.1" extension="${profile.nationalId}"/>'
        '$professionalCode<assignedPerson><name><given>${esc(profile.givenName)}</given>'
        '<family>${esc(profile.familyName)}</family></name></assignedPerson>'
        '$organisation</assignedEntity></performer>',
      ),
    );
    if (replacement) {
      final component = root.getElement('componentOf') ?? root.getElement('component')!;
      root.children.insert(
        root.children.indexOf(component),
        fragment(
          '<relatedDocument typeCode="RPLC"><parentDocument>'
          '<id root="$replacedUniqueId"/>'
          '<versionNumber value="1"/></parentDocument></relatedDocument>',
        ),
      );
    }
    final payload =
        'TEST TECHNIQUE DMP DV1 ABAK — AUCUNE VALEUR CLINIQUE\n'
        'Patient du PDT Cas12 : $fixtureGivenName $fixtureFamilyName.\n'
        'Auteur de test : ${profile.givenName} ${profile.familyName}.\n'
        'Simulation de bilan kinésithérapique pour essai sur DV1. Aucun soin, diagnostic ou prescription réel attesté.';
    one(one(doc, 'nonXMLBody'), 'text').innerText = base64Encode(
      utf8.encode(
        replacement
            ? '$payload\nVersion 2 : complément fictif pour tester le remplacement du bilan initial. Aucune donnée clinique réelle.'
            : payload,
      ),
    );
    final cda = doc.toXmlString();
    final registry = parseXml(registryTemplate);
    final person =
        '${profile.nationalId}^${profile.familyName}^${profile.givenName}^^^^^^&1.2.250.1.71.4.2.1&ISO^D^^^IDNPS';
    final institution =
        '${situation.structureName}^^^^^&1.2.250.1.71.4.2.2&ISO^IDNST^^^${situation.structureId}';
    final patient = '$fixturePatient^^^&$fixturePatientOid&ISO^NH';
    for (final slot in elements(registry, 'Slot')) {
      final name = slot.getAttribute('name');
      final values = elements(slot, 'Value').toList();
      String? replacement;
      switch (name) {
        case 'authorPerson':
        case 'legalAuthenticator':
          replacement = person;
        case 'authorInstitution':
          replacement = institution;
        case 'authorSpecialty':
          replacement = 'G15_70^Masseur-Kinésithérapeute^1.2.250.1.213.1.1.4.5';
        case 'creationTime':
        case 'submissionTime':
        case 'serviceStartTime':
        case 'serviceStopTime':
          replacement = xdsTime;
        case 'languageCode':
          replacement = 'fr-FR';
        case 'sourcePatientId':
          replacement = patient;
      }
      if (replacement != null) {
        for (final v in values) {
          v.innerText = replacement;
        }
      }
      if (name == 'sourcePatientInfo') {
        one(slot, 'ValueList').children
          ..clear()
          ..addAll(
            [
              'PID-5|$fixtureFamilyName^$fixtureGivenName^^^^^L',
              'PID-7|$fixtureBirthDate',
              'PID-8|$fixtureSex',
            ].map((s) => XmlElement(XmlName.parts('Value'), [], [XmlText(s)])),
          );
      }
    }
    for (final id in elements(registry, 'ExternalIdentifier')) {
      final label = one(id, 'LocalizedString').getAttribute('value')!;
      final owner = id.getAttribute('registryObject');
      if (label.endsWith('.patientId')) id.setAttribute('value', patient);
      if (label.endsWith('.sourceId')) {
        id.setAttribute('value', fixtureSourceOid);
      }
      if (label.endsWith('.uniqueId')) {
        id.setAttribute(
          'value',
          owner == 'SubmissionSet01'
              ? lotOid
              : owner == 'DocumentME2'
              ? docOid
              : sigOid,
        );
      }
    }
    for (final classification in elements(registry, 'Classification')) {
      final scheme = classification.getAttribute('classificationScheme');
      if (scheme == 'urn:uuid:aa543740-bdda-424e-8c96-df4873be8500') {
        classification.setAttribute('nodeRepresentation', 'SA07');
        one(
          classification,
          'LocalizedString',
        ).setAttribute('value', 'Cabinet individuel');
        one(classification, 'Value').innerText = '1.2.250.1.71.4.2.4';
      }
      if (scheme == 'urn:uuid:f0306f51-975f-434e-a61c-c59651d33983' &&
          classification.getAttribute('classifiedObject') == 'DocumentME2') {
        classification.setAttribute('nodeRepresentation', documentType);
        one(
          classification,
          'LocalizedString',
        ).setAttribute('value', documentTypeLabel);
      }

      if (classification.getAttribute('classificationScheme') ==
          'urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1') {
        classification.setAttribute('nodeRepresentation', situation.sector!);
        one(
          classification,
          'LocalizedString',
        ).setAttribute('value', 'Cabinet individuel');
      }
      if (classification.getAttribute('classificationScheme') ==
          'urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead') {
        // Fixed context of this cabinet-only local fixture; not inferred from the CPS.
        classification.setAttribute('nodeRepresentation', 'AMBULATOIRE');
        one(
          classification,
          'LocalizedString',
        ).setAttribute('value', 'Ambulatoire');
      }
    }
    for (final obj in elements(registry, 'ExtrinsicObject')) {
      final name = obj.getElement('Name');
      if (name != null && obj.getAttribute('id') == 'DocumentME2') {
        one(
          name,
          'LocalizedString',
        ).setAttribute('value', replacement ? replacementTitle : title);
      }
    }
    if (replacement) {
      registry.rootElement.children.add(
        parseXml(
          '<Association xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" '
          'id="replacementAssociation" associationType="urn:ihe:iti:2007:AssociationType:RPLC" '
          'sourceObject="DocumentME2" targetObject="$replacedEntryUuid"/>',
        ).rootElement.copy(),
      );
    }
    final signature = parseXml(
      '<ds:Signature xmlns:ds="$ds" Id="$sigOid">'
      '<ds:SignedInfo><ds:CanonicalizationMethod Algorithm="$c14n"/>'
      '<ds:SignatureMethod Algorithm="$rsa"/>'
      '${_reference('#IHEManifest', '', type: '${ds}Manifest', transform: true)}'
      '${_reference('#S0-SignedProperties', '', type: '${xades}SignedProperties', transform: true)}'
      '</ds:SignedInfo><ds:SignatureValue/><ds:KeyInfo><ds:X509Data>'
      '<ds:X509Certificate>$certificateBase64</ds:X509Certificate></ds:X509Data></ds:KeyInfo>'
      '<ds:Object><ds:SignatureProperties><ds:SignatureProperty Id="purposeOfSignature" Target="#$sigOid">'
      '1.2.840.10065.1.12.1.14</ds:SignatureProperty></ds:SignatureProperties></ds:Object>'
      '<ds:Object><ds:Manifest Id="IHEManifest">${_reference('urn:oid:$lotOid', 'AA==')}'
      '${_reference('urn:oid:$docOid', hash(canonical(doc.rootElement)), transform: true)}'
      '</ds:Manifest></ds:Object><ds:Object>'
      '<xades:QualifyingProperties xmlns:xades="$xades" Target="#$sigOid">'
      '<xades:SignedProperties Id="S0-SignedProperties"><xades:SignedSignatureProperties>'
      '<xades:SigningTime>${time.toIso8601String()}</xades:SigningTime>'
      '<xades:SigningCertificate><xades:Cert><xades:CertDigest><xades:DigestMethod Algorithm="$digestAlgorithm"/>'
      '<xades:DigestValue>${base64Encode(sha1.convert(base64Decode(certificateBase64)).bytes)}</xades:DigestValue>'
      '</xades:CertDigest><xades:IssuerSerial><ds:X509IssuerName>${esc(cert.issuer)}</ds:X509IssuerName>'
      '<ds:X509SerialNumber>${cert.serial}</ds:X509SerialNumber></xades:IssuerSerial></xades:Cert>'
      '</xades:SigningCertificate><xades:SignaturePolicyIdentifier><xades:SignaturePolicyImplied/>'
      '</xades:SignaturePolicyIdentifier></xades:SignedSignatureProperties></xades:SignedProperties>'
      '</xades:QualifyingProperties></ds:Object></ds:Signature>',
    );
    final refs = elements(one(signature, 'SignedInfo'), 'Reference').toList();
    one(refs[0], 'DigestValue').innerText = hash(
      canonical(one(signature, 'Manifest')),
    );
    one(refs[1], 'DigestValue').innerText = hash(
      canonical(one(signature, 'SignedProperties')),
    );
    final lot = DmpLocalLot._(
      cda,
      registry,
      signature,
      docOid,
      lotOid,
      sigOid,
      certificateBase64,
      replacement,
    );
    lot._updateDocumentMetadata('DocumentME2', utf8.encode(cda));
    lot.verifyDigests();
    return lot;
  }
  static String _reference(
    String uri,
    String digest, {
    String? type,
    bool transform = false,
  }) =>
      '<ds:Reference URI="$uri"${type == null ? '' : ' Type="$type"'}>'
      '${transform ? '<ds:Transforms><ds:Transform Algorithm="$c14n"/></ds:Transforms>' : ''}'
      '<ds:DigestMethod Algorithm="$digestAlgorithm"/><ds:DigestValue>$digest</ds:DigestValue></ds:Reference>';
  String get signedInfo => canonical(one(signature, 'SignedInfo'));
  String get signatureXml => signature.toXmlString();
  String get registryXml => registry.toXmlString();

  void _updateDocumentMetadata(String id, List<int> bytes) {
    final obj = elements(
      registry,
      'ExtrinsicObject',
    ).singleWhere((e) => e.getAttribute('id') == id);
    for (final name in ['hash', 'size']) {
      for (final old
          in obj.childElements
              .where(
                (e) => e.name.local == 'Slot' && e.getAttribute('name') == name,
              )
              .toList()) {
        obj.children.remove(old);
      }
      obj.children.insert(
        0,
        parseXml(
          '<Slot xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" name="$name"><ValueList><Value>${name == 'hash' ? sha1.convert(bytes) : bytes.length}</Value></ValueList></Slot>',
        ).rootElement.copy(),
      );
    }
  }

  /// Verifies the references, not just the RSA SignatureValue. No URI resolver.
  void verifyDigests({String? cdaOverride, String? signatureOverride}) {
    verifyReplacement();
    final sig = parseXml(signatureOverride ?? signatureXml);
    final content = parseXml(cdaOverride ?? cda);
    void require(bool value, String message) {
      if (!value) throw FormatException(message);
    }

    require(
      sig.rootElement.name.namespaceUri == ds &&
          sig.rootElement.getAttribute('Id') == signatureOid,
      'Signature inattendue',
    );
    final ids = sig.descendants
        .whereType<XmlElement>()
        .map((e) => e.getAttribute('Id'))
        .whereType<String>()
        .toList();
    require(ids.toSet().length == ids.length, 'Identifiants XML dupliqués');
    require(
      one(sig, 'SignatureMethod').getAttribute('Algorithm') == rsa,
      'Algorithme de signature inattendu',
    );
    require(
      one(sig, 'CanonicalizationMethod').getAttribute('Algorithm') == c14n,
      'Canonisation inattendue',
    );
    for (final m in elements(sig, 'DigestMethod')) {
      require(
        m.getAttribute('Algorithm') == digestAlgorithm,
        'Algorithme de condensat inattendu',
      );
    }
    final manifest = one(sig, 'Manifest'), props = one(sig, 'SignedProperties');
    void checkReferences(
      XmlElement parent,
      Map<String, String> expected,
      Set<String> transformed,
    ) {
      final refs = parent.childElements
          .where((e) => e.name.local == 'Reference')
          .toList();
      require(refs.length == expected.length, 'Nombre de références incorrect');
      final uris = refs.map((e) => e.getAttribute('URI')).toSet();
      require(
        uris.length == expected.length && uris.containsAll(expected.keys),
        'Référence inconnue ou dupliquée',
      );
      for (final ref in refs) {
        final uri = ref.getAttribute('URI')!;
        require(
          one(ref, 'DigestValue').innerText == expected[uri],
          'Condensat invalide : $uri',
        );
        final transforms = elements(ref, 'Transform').toList();
        require(
          transformed.contains(uri)
              ? transforms.length == 1 &&
                    transforms.single.getAttribute('Algorithm') == c14n
              : transforms.isEmpty,
          'Transformation inattendue',
        );
      }
    }

    checkReferences(
      manifest,
      {
        'urn:oid:$lotOid': 'AA==',
        'urn:oid:$documentOid': hash(canonical(content.rootElement)),
      },
      {'urn:oid:$documentOid'},
    );
    checkReferences(
      one(sig, 'SignedInfo'),
      {
        '#IHEManifest': hash(canonical(manifest)),
        '#S0-SignedProperties': hash(canonical(props)),
      },
      {'#IHEManifest', '#S0-SignedProperties'},
    );
    require(
      one(sig, 'X509Certificate').innerText == certificateBase64,
      'Certificat remplacé',
    );
    final cert = CertificateReference.parse(certificateBase64);
    final certDigest = one(sig, 'CertDigest');
    require(
      certDigest.name.namespaceUri == xades &&
          one(certDigest, 'DigestMethod').name.namespaceUri == xades &&
          one(certDigest, 'DigestValue').name.namespaceUri == xades,
      'Espace de noms du condensat de certificat incompatible avec DMP',
    );
    require(
      one(one(sig, 'CertDigest'), 'DigestValue').innerText ==
          base64Encode(sha1.convert(base64Decode(certificateBase64)).bytes),
      'Condensat du certificat invalide',
    );
    require(
      one(sig, 'X509IssuerName').innerText == cert.issuer &&
          one(sig, 'X509SerialNumber').innerText == cert.serial,
      'Référence de certificat invalide',
    );
    require(
      one(sig, 'SignatureProperty').innerText == '1.2.840.10065.1.12.1.14' &&
          one(sig, 'SignatureProperty').getAttribute('Target') ==
              '#$signatureOid',
      'But de signature invalide',
    );
    require(
      one(sig, 'QualifyingProperties').getAttribute('Target') ==
          '#$signatureOid',
      'Cible XAdES invalide',
    );
    require(
      content.rootElement.getElement('id')!.getAttribute('root') == documentOid,
      'Identifiant CDA incohérent',
    );
    for (final id in elements(registry, 'ExternalIdentifier')) {
      final label = one(id, 'LocalizedString').getAttribute('value')!;
      if (label.endsWith('.uniqueId')) {
        final owner = id.getAttribute('registryObject');
        require(
          id.getAttribute('value') ==
              (owner == 'SubmissionSet01'
                  ? lotOid
                  : owner == 'DocumentME2'
                  ? documentOid
                  : signatureOid),
          'Identifiant XDS incohérent',
        );
      }
    }
  }

  void verifyReplacement() {
    final doc = parseXml(cda);
    final replacements = elements(registry, 'Association')
        .where(
          (e) =>
              e.getAttribute('associationType') ==
              'urn:ihe:iti:2007:AssociationType:RPLC',
        )
        .toList();
    if (!isReplacement) {
      if (replacements.isNotEmpty ||
          elements(doc, 'relatedDocument').isNotEmpty) {
        throw const FormatException('Remplacement inattendu');
      }
      return;
    }
    final related = one(doc, 'relatedDocument');
    final parent = one(related, 'parentDocument');
    if (related.getAttribute('typeCode') != 'RPLC' ||
        one(parent, 'id').getAttribute('root') != replacedUniqueId ||
        doc.rootElement.getElement('setId')!.getAttribute('root') !=
            replacedSetId ||
        doc.rootElement.getElement('versionNumber')!.getAttribute('value') !=
            '2' ||
        documentOid == replacedUniqueId ||
        replacements.length != 1 ||
        replacements.single.getAttribute('sourceObject') != 'DocumentME2' ||
        replacements.single.getAttribute('targetObject') != replacedEntryUuid) {
      throw const FormatException('Références de remplacement incohérentes');
    }
  }

  void attachVerifiedSignature(Map<String, dynamic> result) {
    if (result['verified'] != true ||
        result['tamperedMessageRejected'] != true ||
        result['message'] != signedInfo ||
        result['signingCertificateBase64'] != certificateBase64 ||
        result['signatureBase64'] is! String ||
        (result['signatureBase64'] as String).isEmpty) {
      throw const FormatException(
        'Signature locale non vérifiée ou certificat différent',
      );
    }
    verifyDigests();
    one(signature, 'SignatureValue').innerText =
        result['signatureBase64'] as String;
    _updateDocumentMetadata('Signature01', utf8.encode(signatureXml));
    verifyDigests();
    _verified = true;
  }

  Map<String, String> get files => {
    'document-cda.xml': cda,
    'metadonnees-xds.xml': registryXml,
    verified ? 'signature-xades.xml' : 'signature-xades-NON-SIGNEE.xml':
        signatureXml,
    'signed-info-canonique.xml': signedInfo,
    'certificat-signature.pem':
        '-----BEGIN CERTIFICATE-----\n${certificateBase64.replaceAllMapped(RegExp('.{1,64}'), (m) => '${m[0]}\n')}-----END CERTIFICATE-----\n',
    'rapport-local.json': const JsonEncoder.withIndent('  ').convert({
      'localOnly': true,
      'sentToDv1': false,
      'generatorRevision': 7,
      'operation': isReplacement ? 'TD2.1b' : 'TD2.1',
      if (isReplacement)
        'replacement': {
          'uniqueId': replacedUniqueId,
          'entryUUID': replacedEntryUuid,
          'setId': replacedSetId,
          'previousVersion': 1,
          'newVersion': 2,
          'entryUUIDMustBeRecheckedBeforeSend': true,
        },
      'intendedEnvironment': 'DV1',
      'preparationOnly': true,
      'sourceOid': fixtureSourceOid,
      'readyForDv1': false,
      'patientBirthPlaceKnown': false,
      'patientBirthPlaceCode': fixtureBirthPlaceCode,
      'patientBirthPlaceName': fixtureBirthPlaceName,
      'patientBirthPlaceConfirmed': false,
      'patientBirthPlaceSource':
          'Hypothèse déduite du matricule de test, approuvée par l’utilisateur pour cet essai DV1 ; non confirmée par le CNDA ou INSi.',
      'patientSource': patientSource,
      'patientNationalId': fixturePatient,
      'signatureVerified': verified,
      'algorithm': 'RSA-SHA1 — reproduction du profil du guide fourni',
      'sources': sourceNotice,
      'documentOid': documentOid,
      'lotOid': lotOid,
      'signatureOid': signatureOid,
      'limits': [
        'Identité fictive du PDT Cas12. Lieu de naissance 24252 Marcillac-Saint-Quentin : hypothèse de test approuvée, non confirmée. INS non qualifié par cette préparation.',
        'Type 34120-6, classe 10 : simulation de bilan sans valeur clinique. Nomenclatures NOS contrôlées le 15/10/2026.',
        'sourceId stable pour cette installation de test ABAK DV1, généré localement ; distinct du numéro d’homologation CNDA.',
        'L’écran n’exécute pas la validation CI-SIS ni la vérification de chaîne/révocation : contrôles hors ligne séparés, datés. Aucune homologation DMP.',
        'Aucun SOAP, VIHF, MTOM ou accès réseau. Métadonnées XDS de préparation uniquement.',
      ],
    }),
  };
}

class CertificateReference {
  CertificateReference(this.issuer, this.serial);
  final String issuer, serial;
  factory CertificateReference.parse(String base64) {
    final cert = ASN1Parser(base64Decode(base64)).nextObject() as ASN1Sequence;
    final tbs = cert.elements.first as ASN1Sequence;
    final offset = tbs.elements.first.tag == 0xa0 ? 1 : 0;
    final serial = (tbs.elements[offset] as ASN1Integer).valueAsBigInteger
        .toString();
    final issuer = tbs.elements[offset + 2] as ASN1Sequence;
    const labels = {
      '2.5.4.3': 'CN',
      '2.5.4.6': 'C',
      '2.5.4.7': 'L',
      '2.5.4.8': 'ST',
      '2.5.4.10': 'O',
      '2.5.4.11': 'OU',
    };
    String escape(String value) {
      final out = StringBuffer();
      for (var i = 0; i < value.length; i++) {
        final c = value[i];
        if (',+"\\<>;='.contains(c) ||
            (i == 0 && (c == '#' || c == ' ')) ||
            (i == value.length - 1 && c == ' ')) {
          out.write('\\');
        }
        if (c == '\u0000') {
          out.write('\\00');
        } else {
          out.write(c);
        }
      }
      return out.toString();
    }

    final dn = issuer.elements.reversed
        .map(
          (set) => (set as ASN1Set).elements
              .map((item) {
                final pair = (item as ASN1Sequence).elements;
                final oid = (pair.first as ASN1ObjectIdentifier).identifier!;
                final value = pair[1];
                final text = value is ASN1UTF8String
                    ? value.utf8StringValue
                    : value is ASN1PrintableString
                    ? value.stringValue
                    : null;
                if (text == null || !labels.containsKey(oid)) {
                  return '$oid=#${value.encodedBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
                }
                return '${labels[oid]}=${escape(text)}';
              })
              .join('+'),
        )
        .join(',');
    return CertificateReference(dn, serial);
  }
}
