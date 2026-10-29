import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import '../../../dmp_td02/td02_result.dart';
import '../document_medical_service.dart';
import '../document_cda_builder.dart';
import 'contracts.dart';

/// Fresh local interface messages; never copies a patient or target from a lot.
/// Draft metadata for a new submission only. Wire XDS/XAdES validation is separate.
class DmpChainMessages {
  static const soap = Td02Reader.soap, wsa = Td02Reader.wsa;
  static const xds = 'urn:ihe:iti:xds-b:2007';
  static const rim = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0';
  static String get id => 'urn:uuid:${const Uuid().v4()}';
  static String element(
    String name,
    Map<String, String> attributes, [
    String? text,
  ]) {
    final b = XmlBuilder()..element(name, attributes: attributes, nest: text);
    return b.buildDocument().toXmlString();
  }

  static String escape(String s) => XmlText(s).toXmlString();
  static String patient(Map snapshot) =>
      '${snapshot['identity']['ins_number']}${snapshot['identity']['ins_key']}';
  static String patientCx(Map snapshot) =>
      '${patient(snapshot)}^^^&${snapshot['identity']['ins_oid']}&ISO';
  static Td02Context context(Map snapshot, DmpSession s) => Td02Context(
    ins: patient(snapshot),
    oid: snapshot['identity']['ins_oid'],
    professional: s.professional,
  );
  static String vihf(Map snapshot, DmpSession s, DateTime time) {
    final c = jsonDecode(snapshot['practice']['data_json']);
    final b = XmlBuilder();
    b.element(
      'Assertion',
      attributes: {
        'xmlns': Td02Reader.saml,
        'ID': '_${const Uuid().v4()}',
        'Version': '2.0',
        'IssueInstant': time.toUtc().toIso8601String(),
      },
      nest: () {
        // Explicitly a local assertion proposal, not a certificate-authenticated VIHF.
        b.element('Issuer', nest: 'urn:abak:local-interface-contract');
        b.element(
          'Subject',
          nest: () => b.element('NameID', nest: s.professional),
        );
        b.element(
          'AuthnStatement',
          attributes: {'AuthnInstant': s.issuedAt.toUtc().toIso8601String()},
          nest: () {
            b.element(
              'AuthnContext',
              nest: () => b.element(
                'AuthnContextClassRef',
                nest: 'urn:oasis:names:tc:SAML:2.0:ac:classes:SmartcardPKI',
              ),
            );
          },
        );
        b.element(
          'AttributeStatement',
          nest: () {
            for (final e in <String, String>{
              'Identifiant_Structure': s.structure,
              'Secteur_Activite': '${c['facilityCode']}^1.2.250.1.71.4.2.4',
              'VIHF_Version': '3.0',
              'Authentification_Mode': 'DIRECTE',
              'urn:oasis:names:tc:xacml:2.0:resource:resource-id':
                  '${patientCx(snapshot)}^NH',
              'Ressource_URN': 'urn:dmp',
              'ABAK_Mode': 'simulation-isolee',
            }.entries) {
              b.element(
                'Attribute',
                attributes: {'Name': e.key},
                nest: () => b.element('AttributeValue', nest: e.value),
              );
            }
          },
        );
      },
    );
    return b.buildDocument().toXmlString();
  }

  static String envelope(
    String messageId,
    String action,
    String assertion,
    String body,
  ) =>
      '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa"><s:Header>'
      '${element('w:MessageID', {}, messageId)}${element('w:Action', {}, action)}'
      '<w:To>urn:abak:simulation:no-network</w:To>'
      '<sec:Security xmlns:sec="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">$assertion</sec:Security>'
      '</s:Header><s:Body>$body</s:Body></s:Envelope>';
  static String td02(Map snapshot, DmpSession s, DateTime now) {
    final root = const Uuid().v4();
    return envelope(
      id,
      'urn:hl7-org:v3:PRPA_IN201307UV02',
      vihf(snapshot, s, now),
      '<PRPA_IN201307UV02 xmlns="${Td02Reader.hl7}" ITSVersion="XML_1.0">'
          '${element('id', {'root': root, 'extension': const Uuid().v4()})}'
          '<controlActProcess classCode="CACT" moodCode="EVN"><queryByParameter>'
          '${element('queryId', {'root': root, 'extension': const Uuid().v4()})}'
          '<parameterList><patientIdentifier>${element('value', {'root': snapshot['identity']['ins_oid'], 'extension': patient(snapshot)})}'
          '</patientIdentifier></parameterList></queryByParameter></controlActProcess></PRPA_IN201307UV02>',
    );
  }

  static DmpPreparedSubmission prepare(
    Map snapshot,
    DmpSession s,
    List<int> cda,
    DateTime now,
  ) {
    final d = jsonDecode(snapshot['preparation']['data_json']);
    final c = jsonDecode(snapshot['practice']['data_json']);
    final b = XmlBuilder(), docId = id, setId = id;
    void slot(String name, String value) => b.element(
      'rim:Slot',
      attributes: {'name': name},
      nest: () => b.element(
        'rim:ValueList',
        nest: () => b.element('rim:Value', nest: value),
      ),
    );
    void identifier(String object, String scheme, String value) => b.element(
      'rim:ExternalIdentifier',
      attributes: {
        'id': id,
        'registryObject': object,
        'identificationScheme': 'urn:uuid:$scheme',
        'value': value,
      },
    );
    void classification(
      String scheme,
      String code,
      String system,
      String label,
    ) => b.element(
      'rim:Classification',
      attributes: {
        'id': id,
        'classifiedObject': docId,
        'classificationScheme': 'urn:uuid:$scheme',
        'nodeRepresentation': code,
      },
      nest: () {
        slot('codingScheme', system);
        b.element(
          'rim:Name',
          nest: () =>
              b.element('rim:LocalizedString', attributes: {'value': label}),
        );
      },
    );
    b.element(
      'rim:RegistryObjectList',
      attributes: {'xmlns:rim': rim},
      nest: () {
        b.element(
          'rim:ExtrinsicObject',
          attributes: {
            'id': docId,
            'mimeType': 'text/xml',
            'objectType': 'urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1',
          },
          nest: () {
            slot('hash', sha1.convert(cda).toString());
            slot('size', '${cda.length}');
            slot('creationTime', DocumentCdaBuilder.date(d['clinicalDate']));
            slot('languageCode', d['language']);
            slot('sourcePatientId', patientCx(snapshot));
            b.element(
              'rim:Name',
              nest: () => b.element(
                'rim:LocalizedString',
                attributes: {'value': d['title']},
              ),
            );
            classification(
              '41a5887f-8865-4c09-adf7-e362475b143a',
              d['classCode'],
              d['classSystem'],
              d['classLabel'],
            );
            classification(
              'f0306f51-975f-434e-a61c-c59651d33983',
              d['typeCode'],
              d['typeSystem'],
              d['typeLabel'],
            );
            classification(
              'f4f85eac-e6cb-4883-b524-f2705394840f',
              'N',
              '2.16.840.1.113883.5.25',
              'Normal',
            );
            b.element(
              'rim:Classification',
              attributes: {
                'id': id,
                'classifiedObject': docId,
                'classificationScheme':
                    'urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d',
              },
              nest: () {
                slot(
                  'authorPerson',
                  '${s.professional}^${c['familyName']}^${c['givenNames']}^^^^^^&${s.authority}&ISO^D^^^IDNPS',
                );
                slot(
                  'authorInstitution',
                  '${c['structureName']}^^^^^&${c['structureAuthority']}&ISO^IDNST^^^${s.structure}',
                );
              },
            );
            identifier(
              docId,
              '58a6f841-87b3-4a3e-92fd-a8ffeff98427',
              patientCx(snapshot),
            );
            identifier(
              docId,
              '2e82c1f6-a085-4c72-9da3-8640a32e42ab',
              DocumentCdaBuilder.stableId(
                '${snapshot['version']['version_id']}:${medicalHash(snapshot)}',
              ),
            );
          },
        );
        b.element(
          'rim:RegistryPackage',
          attributes: {'id': setId},
          nest: () {
            slot(
              'submissionTime',
              DocumentCdaBuilder.date(now.toIso8601String()),
            );
            identifier(
              setId,
              '6b5aea1a-874d-4603-a4bc-96a0a7b38446',
              patientCx(snapshot),
            );
          },
        );
        b.element(
          'rim:Association',
          attributes: {
            'id': id,
            'associationType':
                'urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember',
            'sourceObject': setId,
            'targetObject': docId,
          },
          nest: () => slot('SubmissionSetStatus', 'Original'),
        );
      },
    );
    final metadata = b.buildDocument().toXmlString(),
        assertion = vihf(snapshot, s, now);
    final messageId = id;
    final request = envelope(
      messageId,
      'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b',
      assertion,
      '<xds:ProvideAndRegisterDocumentSetRequest xmlns:xds="$xds">'
          '<lcm:SubmitObjectsRequest xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0">$metadata</lcm:SubmitObjectsRequest>'
          '${element('xds:Document', {'id': docId}, base64Encode(cda))}</xds:ProvideAndRegisterDocumentSetRequest>',
    );
    return DmpPreparedSubmission(
      request: request,
      messageId: messageId,
      metadata: metadata,
      vihf: assertion,
      cdaHash: sha256.convert(cda).toString(),
      snapshotHash: medicalHash(snapshot),
      sessionHash: medicalHash(s.evidence),
    );
  }
}
