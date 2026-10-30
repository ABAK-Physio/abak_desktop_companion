import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import '../../../../dmp_td02/td02_result.dart';
import '../contracts.dart';
import 'access_context.dart';
import 'td31a.dart';
import 'td31b.dart';
import 'td33c.dart';

/// ITI-57 metadata update: a new metadata version, never a new document.
class DmpNativeTd33b {
  static const confidentiality =
      'urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f';
  static const invisible = 'INVISIBLE_PATIENT';
  static const system = '1.2.250.1.213.1.1.4.13';
  static String id() => 'urn:uuid:${const Uuid().v4()}';
  static XmlElement entry(
    String query,
    DmpTd02Reply reply,
    String ins,
    String uniqueId,
  ) {
    final docs = DmpNativeTd31a.read(
      query,
      reply,
      ins,
      const Dv1DocumentCriteria(archived: true),
    );
    if (docs.length != 1 || docs.single['uniqueId'] != uniqueId) {
      throw StateError(
        'Document absent, remplacé ou différent. Aucune modification.',
      );
    }
    final e = DmpNativeTd31a.registryObjects(
      query,
      reply,
    ).childElements.single.copy();
    // Preserve namespace bindings when detaching the complete metadata tree.
    e.setAttribute(
      e.name.prefix == null ? 'xmlns' : 'xmlns:${e.name.prefix}',
      DmpNativeTd31b.rim,
    );
    return e;
  }

  static List<XmlElement> hidden(XmlElement e) => e.childElements
      .where(
        (c) =>
            c.name.local == 'Classification' &&
            c.getAttribute('classificationScheme') == confidentiality &&
            c.getAttribute('nodeRepresentation') == invisible,
      )
      .toList();
  static String version(XmlElement e) =>
      e
          .findElements('VersionInfo', namespaceUri: DmpNativeTd31b.rim)
          .single
          .getAttribute('versionName') ??
      '';
  static String logicalId(XmlElement e) =>
      e.getAttribute('lid') ?? e.getAttribute('id')!;
  static void check(XmlElement e) {
    if (hidden(e).length != 1 ||
        !RegExp(r'^[1-9][0-9]*$').hasMatch(version(e))) {
      throw StateError(
        'Document déjà visible ou version des métadonnées absente. Aucune modification.',
      );
    }
    final c = hidden(e).single;
    final coding = c
        .findElements('Slot', namespaceUri: DmpNativeTd31b.rim)
        .where((s) => s.getAttribute('name') == 'codingScheme')
        .single;
    if (coding
            .findAllElements('Value', namespaceUri: DmpNativeTd31b.rim)
            .single
            .innerText !=
        system) {
      throw StateError('Autorité du code de confidentialité inattendue.');
    }
  }

  static String build(
    String envelope,
    XmlElement original,
    Dv1AccessContext context,
    DmpSession session,
    String sourceId,
    DateTime now,
  ) {
    check(original);
    if (context.scenario != 'PRE_CONS_INV' || context.sector != 'SA07') {
      throw StateError(
        'Mise en visibilité réservée au scénario PRE_CONS_INV en cabinet individuel.',
      );
    }
    final e = original.copy(), newId = id(), packId = id();
    final previous = version(original);
    hidden(e).single.parent!.children.remove(hidden(e).single);
    e.setAttribute('id', newId);
    e.setAttribute('lid', logicalId(original));
    e.children.removeWhere(
      (c) => c is XmlElement && c.name.local == 'VersionInfo',
    );
    for (final c in e.descendants.whereType<XmlElement>()) {
      if (c.getAttribute('id') != null) c.setAttribute('id', id());
      for (final attr in ['classifiedObject', 'registryObject']) {
        if (c.getAttribute(attr) == original.getAttribute('id')) {
          c.setAttribute(attr, newId);
        }
      }
    }
    final native = session.evidence['native'] as Map;
    final b = XmlBuilder();
    void slot(String name, String value) => b.element(
      'rim:Slot',
      attributes: {'name': name},
      nest: () => b.element(
        'rim:ValueList',
        nest: () => b.element('rim:Value', nest: value),
      ),
    );
    void name(String value) => b.element(
      'rim:Name',
      nest: () =>
          b.element('rim:LocalizedString', attributes: {'value': value}),
    );
    void external(String scheme, String value, String label) => b.element(
      'rim:ExternalIdentifier',
      attributes: {
        'id': id(),
        'registryObject': packId,
        'identificationScheme': 'urn:uuid:$scheme',
        'value': value,
      },
      nest: () => name(label),
    );
    b.element(
      'lcm:SubmitObjectsRequest',
      attributes: {
        'xmlns:lcm': DmpNativeTd33c.lcm,
        'xmlns:rim': DmpNativeTd31b.rim,
      },
      nest: () => b.element(
        'rim:RegistryObjectList',
        nest: () {
          b.xml(e.toXmlString());
          b.element(
            'rim:RegistryPackage',
            attributes: {'id': packId},
            nest: () {
              slot(
                'submissionTime',
                now
                    .toUtc()
                    .toIso8601String()
                    .substring(0, 19)
                    .replaceAll(RegExp('[-:T]'), ''),
              );
              name('Mise en visibilité au patient');
              b.element(
                'rim:Classification',
                attributes: {
                  'id': id(),
                  'classifiedObject': packId,
                  'classificationScheme':
                      'urn:uuid:a7058bb9-b4e4-4307-ba5b-e3f0ab85e12d',
                  'nodeRepresentation': '',
                },
                nest: () {
                  slot(
                    'authorPerson',
                    '${session.professional}^${native['cpsFamilyName']}^${native['cpsGivenName']}^^^^^^&${session.authority}&ISO^D^^^IDNPS',
                  );
                  // RG_2240: the submitting organisation must be identified.
                  // Its label is optional; never invent a structure name.
                  slot(
                    'authorInstitution',
                    '^^^^^&1.2.250.1.71.4.2.2&ISO^IDNST^^^${context.structure}',
                  );
                  slot(
                    'authorSpecialty',
                    'G15_70^Masseur-Kinésithérapeute^1.2.250.1.213.1.1.4.5',
                  );
                },
              );
              b.element(
                'rim:Classification',
                attributes: {
                  'id': id(),
                  'classifiedObject': packId,
                  'classificationScheme':
                      'urn:uuid:aa543740-bdda-424e-8c96-df4873be8500',
                  'nodeRepresentation': context.sector,
                },
                nest: () {
                  slot('codingScheme', '1.2.250.1.71.4.2.4');
                  name('Cabinet individuel');
                },
              );
              external(
                '6b5aea1a-874d-4603-a4bc-96a0a7b38446',
                DmpNativeTd31a.patientId(context.ins),
                'XDSSubmissionSet.patientId',
              );
              external(
                '554ac39e-e3fe-47fe-b233-965d2a147832',
                sourceId,
                'XDSSubmissionSet.sourceId',
              );
              external(
                '96fdda7c-d067-4183-912e-bf5ee74998a8',
                '2.25.${BigInt.parse(const Uuid().v4().replaceAll('-', ''), radix: 16)}',
                'XDSSubmissionSet.uniqueId',
              );
            },
          );
          b.element(
            'rim:Classification',
            attributes: {
              'id': id(),
              'classifiedObject': packId,
              'classificationNode':
                  'urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd',
            },
          );
          b.element(
            'rim:Association',
            attributes: {
              'id': id(),
              'associationType':
                  'urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember',
              'sourceObject': packId,
              'targetObject': newId,
            },
            nest: () {
              slot('SubmissionSetStatus', 'Original');
              slot('PreviousVersion', previous);
              slot('AssociationPropagation', 'yes');
            },
          );
        },
      ),
    );
    final env = Td02Reader.parse(envelope);
    final h = Td02Reader.one(env, 'Header', Td02Reader.soap);
    Td02Reader.one(h, 'MessageID', Td02Reader.wsa).innerText = id();
    Td02Reader.one(h, 'Action', Td02Reader.wsa).innerText =
        DmpNativeTd33c.action;
    Td02Reader.one(env, 'Body', Td02Reader.soap).children
      ..clear()
      ..add(b.buildDocument().rootElement.copy());
    return env.toXmlString();
  }

  static void verifyAfter(
    XmlElement original,
    XmlElement expected,
    XmlElement actual,
  ) {
    if (actual.getAttribute('id') != expected.getAttribute('id') ||
        logicalId(actual) != logicalId(expected) ||
        hidden(actual).isNotEmpty ||
        int.tryParse(version(actual)) != int.parse(version(original)) + 1 ||
        canonical(expected) != canonical(actual)) {
      throw StateError(
        'Métadonnées après mise en visibilité différentes ou incomplètes.',
      );
    }
  }

  static String canonical(XmlElement element) {
    Object walk(XmlElement e) => [
      e.name.namespaceUri,
      e.name.local,
      {
        for (final a
            in (e.attributes
                .where(
                  (a) =>
                      a.name.prefix != 'xmlns' &&
                      a.name.qualified != 'xmlns' &&
                      a.name.local != 'id',
                )
                .toList()
              ..sort((a, b) => a.name.qualified.compareTo(b.name.qualified))))
          a.name.qualified: a.value,
      },
      for (final n in e.children)
        if (n is XmlElement && n.name.local != 'VersionInfo')
          walk(n)
        else if (n is XmlText && n.value.trim().isNotEmpty)
          n.value,
    ];
    return jsonEncode(walk(element));
  }

  static void read(String request, DmpTd02Reply reply) {
    try {
      DmpNativeTd33c.read(request, reply);
    } catch (_) {
      throw StateError(
        'Mise en visibilité refusée ou non confirmée. Réponse conservée ; renvoi bloqué.',
      );
    }
  }
}
