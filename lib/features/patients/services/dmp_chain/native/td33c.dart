import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import '../../../../dmp_td02/td02_result.dart';
import '../../../../dmp_transfer/archive_deposit_reader.dart';
import '../contracts.dart';
import 'td31b.dart';

/// TD3.3c: only Approved -> Deleted, one freshly resolved document.
class DmpNativeTd33c {
  static const action = 'urn:ihe:iti:2010:UpdateDocumentSet';
  static const deleted = 'urn:asip:ci-sis:2010:StatusType:Deleted';
  static const approved = 'urn:oasis:names:tc:ebxml-regrep:StatusType:Approved';
  static const association =
      'urn:ihe:iti:2010:AssociationType:UpdateAvailabilityStatus';
  static const lcm = 'urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0';
  static String build(
    String freshEnvelope,
    String archivedSubmission,
    String entryUuid,
    DateTime now,
  ) {
    if (!RegExp(
      r'^urn:uuid:[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
    ).hasMatch(entryUuid)) {
      throw StateError('Cible de dépublication invalide.');
    }
    final env = Td02Reader.parse(freshEnvelope);
    final header = Td02Reader.one(env, 'Header', Td02Reader.soap);
    Td02Reader.one(header, 'MessageID', Td02Reader.wsa).innerText =
        'urn:uuid:${const Uuid().v4()}';
    Td02Reader.one(header, 'Action', Td02Reader.wsa).innerText = action;
    Td02Reader.one(header, 'To', Td02Reader.wsa).innerText =
        DmpNativeTd31b.endpoint;
    final old = Td02Reader.parse(archivedSubmission);
    final submission = old
        .findAllElements('RegistryPackage', namespace: DmpNativeTd31b.rim)
        .single;
    submission.setAttribute(
      submission.name.prefix == null
          ? 'xmlns'
          : 'xmlns:${submission.name.prefix}',
      DmpNativeTd31b.rim,
    );
    final oldId = submission.getAttribute('id')!;
    final id = 'urn:uuid:${const Uuid().v4()}';
    submission.setAttribute('id', id);
    for (final e in submission.descendants.whereType<XmlElement>()) {
      for (final attr in ['registryObject', 'classifiedObject']) {
        if (e.getAttribute(attr) == oldId) e.setAttribute(attr, id);
      }
      if (e.getAttribute('id') != null) {
        e.setAttribute('id', 'urn:uuid:${const Uuid().v4()}');
      }
      if (e.name.local == 'ExternalIdentifier' &&
          e.getAttribute('identificationScheme') ==
              'urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8') {
        e.setAttribute(
          'value',
          '2.25.${BigInt.parse(const Uuid().v4().replaceAll('-', ''), radix: 16)}',
        );
      }
      if (e.name.local == 'Slot' &&
          e.getAttribute('name') == 'submissionTime') {
        e
            .findAllElements('Value', namespace: DmpNativeTd31b.rim)
            .single
            .innerText = now
            .toUtc()
            .toIso8601String()
            .substring(0, 19)
            .replaceAll(RegExp('[-:T]'), '');
      }
    }
    final b = XmlBuilder();
    b.element(
      'lcm:SubmitObjectsRequest',
      attributes: {'xmlns:lcm': lcm, 'xmlns:rim': DmpNativeTd31b.rim},
      nest: () {
        b.element(
          'rim:RegistryObjectList',
          nest: () {
            b.xml(submission.toXmlString());
            b.element(
              'rim:Classification',
              attributes: {
                'id': 'urn:uuid:${const Uuid().v4()}',
                'classifiedObject': id,
                'classificationNode':
                    'urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd',
              },
            );
            b.element(
              'rim:Association',
              attributes: {
                'id': 'urn:uuid:${const Uuid().v4()}',
                'associationType': association,
                'sourceObject': id,
                'targetObject': entryUuid,
              },
              nest: () {
                for (final value in {
                  'OriginalStatus': approved,
                  'NewStatus': deleted,
                }.entries) {
                  b.element(
                    'rim:Slot',
                    attributes: {'name': value.key},
                    nest: () => b.element(
                      'rim:ValueList',
                      nest: () => b.element('rim:Value', nest: value.value),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
    Td02Reader.one(env, 'Body', Td02Reader.soap).children
      ..clear()
      ..add(b.buildDocument().rootElement.copy());
    return env.toXmlString();
  }

  static void read(String request, DmpTd02Reply reply) {
    final xml = Td02Reader.parse(
      ArchiveDepositReader.extract(reply.headers ?? '', utf8.encode(reply.xml)),
    );
    final header = Td02Reader.one(xml, 'Header', Td02Reader.soap);
    final sent = Td02Reader.one(
      Td02Reader.parse(request),
      'Header',
      Td02Reader.soap,
    );
    if (reply.status != 200 ||
        Td02Reader.one(header, 'RelatesTo', Td02Reader.wsa).innerText !=
            Td02Reader.one(sent, 'MessageID', Td02Reader.wsa).innerText ||
        Td02Reader.one(header, 'Action', Td02Reader.wsa).innerText !=
            '$action-Response') {
      throw StateError(
        'Réponse TD3.3c non confirmée ou non corrélée ; renvoi bloqué.',
      );
    }
    final body = Td02Reader.one(xml, 'Body', Td02Reader.soap);
    final result = Td02Reader.one(body, 'RegistryResponse', DmpNativeTd31b.rs);
    if (body.childElements.length != 1 ||
        result.getAttribute('status') !=
            'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success' ||
        result
            .findAllElements('RegistryError', namespace: DmpNativeTd31b.rs)
            .isNotEmpty) {
      throw StateError(
        'Dépublication refusée ou non confirmée ; réponse conservée, renvoi bloqué.',
      );
    }
  }
}
