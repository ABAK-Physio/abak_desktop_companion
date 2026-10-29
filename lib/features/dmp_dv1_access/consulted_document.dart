import 'dart:convert';
import 'dart:typed_data';
import 'package:xml/xml.dart';
import '../patients/services/dmp_chain/native/td32.dart';

/// Memory-only CDA. Never execute a stylesheet, script, external reference or URL.
class ConsultedDocument {
  ConsultedDocument._(
    this.cda,
    this.header,
    this.metadata,
    this.payload,
    this.mediaType,
    this.sections,
  );
  XmlElement? cda;
  String header;
  final Map<String, String> metadata;
  Uint8List? payload;
  final String mediaType;
  final List<XmlElement> sections;
  static const ns = 'urn:hl7-org:v3';
  static List<XmlElement> children(XmlElement e, String name) => e.childElements
      .where((v) => v.namespaceUri == ns && v.name.local == name)
      .toList();
  static ConsultedDocument parse(
    Uint8List bytes,
    Map<String, String> metadata,
    String ins,
  ) {
    var root = DmpNativeTd32.xml(utf8.decode(bytes)).rootElement;
    if (metadata['mimeType'] == 'application/xslt+xml' &&
        root.namespaceUri == 'http://www.w3.org/1999/XSL/Transform') {
      final candidates = root.descendants
          .whereType<XmlElement>()
          .where(
            (e) => e.namespaceUri == ns && e.name.local == 'ClinicalDocument',
          )
          .toList();
      if (candidates.length != 1) {
        throw StateError('CDA auto-présentable absent ou ambigu.');
      }
      root = candidates.single; // Never execute the supplied stylesheet.
    }
    if (root.name.local != 'ClinicalDocument' || root.namespaceUri != ns) {
      throw StateError('Document reçu : CDA R2 attendu.');
    }
    final targets = children(root, 'recordTarget');
    if (targets.length != 1) throw StateError('Patient CDA absent ou ambigu.');
    final roles = children(targets.single, 'patientRole');
    if (roles.length != 1) throw StateError('Identité CDA ambiguë.');
    final ids = children(
      roles.single,
      'id',
    ).where((id) => id.getAttribute('root') == '1.2.250.1.213.1.4.10').toList();
    if (ids.length != 1 || ids.single.getAttribute('extension') != ins) {
      throw StateError(
        'INS ou autorité du CDA différents du patient sélectionné.',
      );
    }
    final component = children(root, 'component').single;
    final bodies = component.childElements.toList();
    if (bodies.length != 1 || bodies.single.namespaceUri != ns) {
      throw StateError('Corps CDA ambigu.');
    }
    final body = bodies.single;
    Uint8List? data;
    String media = '';
    final sections = <XmlElement>[];
    if (body.name.local == 'nonXMLBody') {
      final text = children(body, 'text').single;
      media = text.getAttribute('mediaType') ?? '';
      if (text.childElements.isNotEmpty) {
        throw StateError('Référence externe CDA interdite.');
      }
      if (text.getAttribute('representation') == 'B64') {
        data = DmpNativeTd32.decode64(text.innerText);
      } else if (media == 'text/plain' &&
          [null, 'TXT'].contains(text.getAttribute('representation'))) {
        data = Uint8List.fromList(utf8.encode(text.innerText));
      } else {
        throw StateError('Encodage du corps CDA non pris en charge.');
      }
      if (![
        'application/pdf',
        'text/plain',
        'image/jpeg',
        'image/tiff',
        'application/rtf',
        'text/rtf',
      ].contains(media)) {
        throw StateError('Format du corps CDA non pris en charge : $media.');
      }
    } else if (body.name.local == 'structuredBody') {
      sections.addAll(
        body.descendants.whereType<XmlElement>().where(
          (e) => e.namespaceUri == ns && e.name.local == 'section',
        ),
      );
      if (sections.isEmpty) throw StateError('Aucune section narrative CDA.');
      // FR-Document-PDF-copie: use the section code, never an arbitrary title.
      for (final section in sections) {
        if (!children(section, 'code').any(
          (c) =>
              c.getAttribute('code') == '55108-5' &&
              c.getAttribute('codeSystem') == '2.16.840.1.113883.6.1',
        )) {
          continue;
        }
        final values = section.descendants
            .whereType<XmlElement>()
            .where(
              (e) =>
                  e.namespaceUri == ns &&
                  e.name.local == 'value' &&
                  e.parentElement?.name.local == 'observationMedia' &&
                  e.getAttribute('mediaType') == 'application/pdf',
            )
            .toList();
        if (values.length != 1 ||
            values.single.getAttribute('representation') != 'B64' ||
            values.single.childElements.isNotEmpty) {
          throw StateError('Copie PDF du CDA absente ou ambiguë.');
        }
        data = DmpNativeTd32.decode64(values.single.innerText);
        media = 'application/pdf';
        break;
      }
    } else {
      throw StateError('Corps CDA non reconnu.');
    }
    if (data != null && (data.isEmpty || data.length > DmpNativeTd32.maximum)) {
      throw StateError('Contenu vide ou trop volumineux.');
    }
    if (data == null) {
      final texts = sections.expand((s) => children(s, 'text')).toList();
      if (texts.isEmpty || texts.every((t) => t.innerText.trim().isEmpty)) {
        throw StateError('Narratif CDA absent : affichage non confirmé.');
      }
      for (final text in texts) {
        for (final node in text.descendants.whereType<XmlElement>()) {
          if (node.namespaceUri != ns ||
              [
                'script',
                'iframe',
                'renderMultiMedia',
              ].contains(node.name.local)) {
            throw StateError(
              'Ce CDA contient un média narratif non pris en charge par cet afficheur. Aucun succès de consultation déclaré.',
            );
          }
        }
      }
    }
    final header = root.childElements
        .where((e) => e != component)
        .map((e) => describe(e))
        .join('\n\n');
    return ConsultedDocument._(
      root,
      header,
      Map.unmodifiable(metadata),
      data,
      media,
      sections,
    );
  }

  static const labels = {
    'title': 'Titre',
    'id': 'Identifiant',
    'code': 'Type',
    'effectiveTime': 'Date',
    'confidentialityCode': 'Confidentialité',
    'languageCode': 'Langue',
    'versionNumber': 'Version',
    'recordTarget': 'Patient',
    'patientRole': 'Identité patient',
    'patient': 'Patient',
    'name': 'Nom',
    'given': 'Prénom',
    'family': 'Nom de famille',
    'birthTime': 'Naissance',
    'administrativeGenderCode': 'Sexe',
    'author': 'Auteur',
    'assignedAuthor': 'Identité auteur',
    'assignedPerson': 'Personne',
    'representedOrganization': 'Organisation',
    'custodian': 'Responsable de conservation',
    'legalAuthenticator': 'Signataire légal',
    'authenticator': 'Signataire',
    'informationRecipient': 'Destinataire',
    'documentationOf': 'Acte documenté',
    'componentOf': 'Contexte de prise en charge',
    'addr': 'Adresse',
    'telecom': 'Contact',
  };
  static String describe(XmlElement e, [int depth = 0]) {
    if (depth > 30) throw StateError('CDA trop imbriqué.');
    final attrs = e.attributes
        .where((a) => a.name.prefix != 'xmlns' && a.name.local != 'xmlns')
        .map((a) => '${a.name.local}=${a.value}')
        .join(' · ');
    final text = e.children
        .whereType<XmlText>()
        .map((e) => e.value.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    return '${'  ' * depth}${labels[e.name.local] ?? e.name.local}${attrs.isEmpty ? '' : ' : $attrs'}${text.isEmpty ? '' : ' : $text'}${e.childElements.isEmpty ? '' : '\n${e.childElements.map((c) => describe(c, depth + 1)).join('\n')}'}';
  }

  List<String> get warnings => [
    if ((metadata['confidentiality'] ?? '')
        .split('|')
        .contains('INVISIBLE_PATIENT'))
      'Attention, ce document n’est pas visible du patient.',
    if ((metadata['confidentiality'] ?? '')
        .split('|')
        .contains('INVISIBLE_REPRESENTANTS_LEGAUX'))
      'Attention, ce document n’est pas visible des représentants légaux pour préserver le secret du mineur titulaire du DMP.',
  ];
  void dispose() {
    payload?.fillRange(0, payload!.length, 0);
    payload = null;
    cda = null;
    header = '';
    sections.clear();
  }
}
