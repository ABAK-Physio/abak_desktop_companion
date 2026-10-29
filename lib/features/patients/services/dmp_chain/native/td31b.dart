import '../messages.dart';
import 'dart:convert';
import '../../../../dmp_transfer/archive_deposit_reader.dart';
import 'package:xml/xml.dart';
import '../../../../dmp_td02/td02_result.dart';
import '../contracts.dart';
import '../wire/package.dart';
import 'td03.dart';
import 'access_context.dart';

/// Read-only GetDocuments query: ObjectRef only, one archived uniqueId.
class DmpNativeTd31b {
  static const endpoint =
      'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/registry';
  static const action = 'urn:ihe:iti:2007:RegistryStoredQuery';
  static const query = 'urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0';
  static const rim = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0';
  static const rs = 'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0';
  static const getDocuments = 'urn:uuid:5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4';
  static String build(
    Dv1AccessContext context,
    DmpSession session,
    DmpWireMaterial material,
    DateTime time,
    String uniqueId,
  ) {
    if (!RegExp(r'^[0-2](\.[0-9]+)+$').hasMatch(uniqueId)) {
      throw StateError('Identifiant du document invalide.');
    }
    // Reuse the same qualified VIHF and fresh WS-Addressing envelope.
    final envelope = Td02Reader.parse(
      DmpNativeTd03.build(context, session, material, time, add: true),
    );
    return fromPatientRequest(envelope.toXmlString(), uniqueId);
  }

  /// Reuse the authenticated patient envelope, with a fresh correlation ID.
  static String fromPatientRequest(String request, String uniqueId) {
    if (!RegExp(r'^[0-2](\.[0-9]+)+$').hasMatch(uniqueId)) {
      throw StateError('Identifiant du document invalide.');
    }
    final envelope = Td02Reader.parse(request);
    final header = Td02Reader.one(envelope, 'Header', Td02Reader.soap);
    Td02Reader.one(header, 'MessageID', Td02Reader.wsa).innerText =
        DmpChainMessages.id;
    Td02Reader.one(header, 'To', Td02Reader.wsa).innerText = endpoint;
    Td02Reader.one(header, 'Action', Td02Reader.wsa).innerText = action;
    final b = XmlBuilder();
    b.element(
      'AdhocQueryRequest',
      attributes: {'xmlns': query},
      nest: () {
        b.element(
          'ResponseOption',
          attributes: {
            'returnType': 'ObjectRef',
            'returnComposedObjects': 'true',
          },
        );
        b.element(
          'rim:AdhocQuery',
          attributes: {'xmlns:rim': rim, 'id': getDocuments},
          nest: () {
            b.element(
              'rim:Slot',
              attributes: {'name': r'$XDSDocumentEntryUniqueId'},
              nest: () {
                b.element(
                  'rim:ValueList',
                  nest: () => b.element('rim:Value', nest: "('$uniqueId')"),
                );
              },
            );
          },
        );
      },
    );
    Td02Reader.one(envelope, 'Body', Td02Reader.soap).children
      ..clear()
      ..add(b.buildDocument().rootElement.copy());
    return envelope.toXmlString();
  }

  static List<String> read(String request, DmpTd02Reply reply) {
    final response = Td02Reader.parse(
      ArchiveDepositReader.extract(reply.headers ?? '', utf8.encode(reply.xml)),
    );
    final header = Td02Reader.one(response, 'Header', Td02Reader.soap);
    final sent = Td02Reader.one(
      Td02Reader.parse(request),
      'Header',
      Td02Reader.soap,
    );
    if (Td02Reader.one(header, 'RelatesTo', Td02Reader.wsa).innerText.trim() !=
        Td02Reader.one(sent, 'MessageID', Td02Reader.wsa).innerText.trim()) {
      throw StateError('Réponse TD3.1b non corrélée. Recherche non confirmée.');
    }
    final body = Td02Reader.one(response, 'Body', Td02Reader.soap);
    if (body.childElements.length != 1) {
      throw const FormatException('Corps TD3.1b ambigu.');
    }
    if (Td02Reader.children(body, 'Fault', Td02Reader.soap).isNotEmpty) {
      throw StateError(
        'Le DMP a retourné une erreur SOAP TD3.1b (HTTP ${reply.status}). Réponse conservée dans les preuves.',
      );
    }
    if (reply.status != 200 ||
        Td02Reader.one(header, 'Action', Td02Reader.wsa).innerText.trim() !=
            '${action}Response') {
      throw StateError('Réponse TD3.1b inattendue (HTTP ${reply.status}).');
    }
    final result = Td02Reader.one(body, 'AdhocQueryResponse', query);
    if (result.getAttribute('status') !=
            'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success' ||
        result.descendants.whereType<XmlElement>().any(
          (e) => e.name.local == 'RegistryError',
        )) {
      throw StateError(
        'Recherche refusée par le DMP. Réponse conservée dans les preuves.',
      );
    }
    if (result.childElements.length != 1) {
      throw const FormatException('Résultat TD3.1b inattendu.');
    }
    final list = Td02Reader.one(result, 'RegistryObjectList', rim);
    final ids = <String>[];
    for (final ref in list.childElements) {
      final id = ref.getAttribute('id') ?? '';
      if (ref.name.local != 'ObjectRef' ||
          ref.namespaceUri != rim ||
          ref.childElements.isNotEmpty ||
          !RegExp(
            r'^urn:uuid:[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
          ).hasMatch(id)) {
        throw const FormatException(
          'Réponse autre que des identifiants techniques.',
        );
      }
      ids.add(id);
    }
    if (ids.map((id) => id.toLowerCase()).toSet().length != ids.length) {
      throw const FormatException('Identifiant technique dupliqué.');
    }
    return List.unmodifiable(ids);
  }
}
