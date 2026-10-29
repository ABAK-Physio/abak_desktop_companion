import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import '../../../../dmp_td02/td02_result.dart';
import '../../../../dmp_transfer/archive_deposit_reader.dart';
import '../messages.dart';
import 'td31b.dart';

/// ITI-43 for exactly one explicitly selected, freshly verified document.
/// Binary MTOM is never decoded as UTF-8 or written into evidence archives.
class DmpNativeTd32 {
  static const ns = 'urn:ihe:iti:xds-b:2007';
  static const action = 'urn:ihe:iti:2007:RetrieveDocumentSet';
  static const endpoint =
      'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository';
  static const maximum = 16 * 1024 * 1024;
  static void checkMetadata(Map<String, String> d) {
    for (final key in ['uniqueId', 'repositoryUniqueId']) {
      if (!RegExp(r'^[0-2](\.[0-9]+)+$').hasMatch(d[key] ?? '')) {
        throw StateError(
          'Identifiant de récupération absent ou invalide : $key.',
        );
      }
    }
    if (![
          'text/xml',
          'application/xml',
          'application/xslt+xml',
        ].contains(d['mimeType']) ||
        !RegExp(r'^[a-fA-F0-9]{40}$').hasMatch(d['hash'] ?? '') ||
        (int.tryParse(d['size'] ?? '') ?? 0) <= 0 ||
        int.parse(d['size']!) > maximum) {
      throw StateError(
        'Métadonnées CDA, empreinte ou taille de récupération invalides.',
      );
    }
  }

  static String build(String envelope, Map<String, String> d) {
    checkMetadata(d);
    final doc = Td02Reader.parse(envelope);
    final h = Td02Reader.one(doc, 'Header', Td02Reader.soap);
    Td02Reader.one(h, 'MessageID', Td02Reader.wsa).innerText =
        DmpChainMessages.id;
    Td02Reader.one(h, 'To', Td02Reader.wsa).innerText = endpoint;
    Td02Reader.one(h, 'Action', Td02Reader.wsa).innerText = action;
    final b = XmlBuilder();
    b.element(
      'RetrieveDocumentSetRequest',
      attributes: {'xmlns': ns},
      nest: () {
        b.element(
          'DocumentRequest',
          nest: () {
            b.element('RepositoryUniqueId', nest: d['repositoryUniqueId']);
            b.element('DocumentUniqueId', nest: d['uniqueId']);
          },
        );
      },
    );
    Td02Reader.one(doc, 'Body', Td02Reader.soap).children
      ..clear()
      ..add(b.buildDocument().rootElement.copy());
    return doc.toXmlString();
  }

  static Uint8List decode64(String value) {
    final compact = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(compact) ||
        compact.length % 4 == 1) {
      throw const FormatException('Base64 invalide.');
    }
    return base64Decode(base64.normalize(compact));
  }

  static XmlDocument xml(String text) {
    if (text.length > maximum ||
        RegExp(r'<!\s*(DOCTYPE|ENTITY)', caseSensitive: false).hasMatch(text)) {
      throw const FormatException('XML interdit ou trop volumineux.');
    }
    return XmlDocument.parse(text);
  }

  static Uint8List read(
    String request,
    int status,
    String headers,
    Uint8List bytes,
    Map<String, String> target,
  ) {
    checkMetadata(target);
    if (status != 200 || bytes.length > maximum) {
      throw StateError('Récupération TD3.2 refusée ou trop volumineuse.');
    }
    final mime = multipart(headers, bytes);
    final document = xml(utf8.decode(mime.root)).rootElement;
    if (document.name.local != "Envelope" ||
        document.namespaceUri != Td02Reader.soap) {
      throw StateError("Enveloppe TD3.2 invalide.");
    }
    final h = Td02Reader.one(document, 'Header', Td02Reader.soap);
    if (Td02Reader.one(h, 'Action', Td02Reader.wsa).innerText.trim() !=
            '${action}Response' ||
        Td02Reader.one(h, 'RelatesTo', Td02Reader.wsa).innerText.trim() !=
            Td02Reader.one(
              Td02Reader.one(
                Td02Reader.parse(request),
                'Header',
                Td02Reader.soap,
              ),
              'MessageID',
              Td02Reader.wsa,
            ).innerText.trim()) {
      throw StateError('Réponse TD3.2 non corrélée.');
    }
    final body = Td02Reader.one(document, 'Body', Td02Reader.soap);
    final response = Td02Reader.one(body, 'RetrieveDocumentSetResponse', ns);
    final registry = Td02Reader.one(
      response,
      'RegistryResponse',
      DmpNativeTd31b.rs,
    );
    if (body.childElements.length != 1 ||
        response.childElements.length != 2 ||
        registry.childElements.isNotEmpty ||
        registry.getAttribute('status') !=
            'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success') {
      throw StateError(
        'Récupération refusée ou partielle : aucun document affiché.',
      );
    }
    final item = Td02Reader.one(response, 'DocumentResponse', ns);
    for (final field in {
      'DocumentUniqueId': 'uniqueId',
      'RepositoryUniqueId': 'repositoryUniqueId',
      'mimeType': 'mimeType',
    }.entries) {
      if (Td02Reader.one(item, field.key, ns).innerText.trim() !=
          target[field.value]) {
        throw StateError('Document reçu différent de la sélection.');
      }
    }
    if (item.childElements.length != 4) {
      throw const FormatException('DocumentResponse ambigu.');
    }
    final content = Td02Reader.one(item, 'Document', ns);
    Uint8List data;
    if (content.childElements.isEmpty) {
      data = decode64(content.innerText);
    } else {
      final include = Td02Reader.one(
        content,
        'Include',
        'http://www.w3.org/2004/08/xop/include',
      );
      final href = include.getAttribute('href') ?? '';
      if (content.childElements.length != 1 ||
          !href.startsWith('cid:') ||
          include.childElements.isNotEmpty) {
        throw const FormatException('Référence MTOM invalide.');
      }
      final id = '<${Uri.decodeComponent(href.substring(4))}>';
      data =
          mime.parts[id] ??
          (throw const FormatException('Pièce MTOM absente.'));
    }
    if (data.length != int.parse(target['size']!) ||
        sha1.convert(data).toString() != target['hash']!.toLowerCase()) {
      data.fillRange(0, data.length, 0);
      throw StateError(
        'Taille ou empreinte du document différente des métadonnées.',
      );
    }
    return data;
  }

  static ({Uint8List root, Map<String, Uint8List> parts}) multipart(
    String headers,
    Uint8List bytes,
  ) {
    final type = ArchiveDepositReader.header(headers, 'content-type') ?? '';
    if (!type.toLowerCase().startsWith('multipart/related')) {
      return (root: bytes, parts: {});
    }
    final boundary = ArchiveDepositReader.parameter(type, 'boundary');
    final start = ArchiveDepositReader.parameter(type, 'start');
    if (boundary == null ||
        boundary.isEmpty ||
        boundary.length > 200 ||
        boundary.contains(RegExp(r'[\r\n]'))) {
      throw const FormatException('Frontière MIME invalide.');
    }
    final raw = latin1.decode(bytes), marker = '--$boundary';
    var pos = raw.startsWith(marker) ? 0 : raw.indexOf('\r\n$marker') + 2;
    final parts = <String, Uint8List>{};
    Uint8List? root;
    var count = 0;
    while (true) {
      if (!raw.startsWith(marker, pos)) {
        throw const FormatException('MIME tronqué.');
      }
      pos += marker.length;
      if (raw.startsWith('--', pos)) break;
      if (!raw.startsWith('\r\n', pos) || ++count > 4) {
        throw const FormatException('MIME invalide.');
      }
      pos += 2;
      final end = raw.indexOf('\r\n\r\n', pos),
          next = end < 0 ? -1 : raw.indexOf('\r\n$marker', end + 4);
      if (end < pos || end - pos > 32768 || next < 0) {
        throw const FormatException('MIME tronqué.');
      }
      final h = raw.substring(pos, end);
      final id = ArchiveDepositReader.header(h, 'content-id');
      final encoding =
          (ArchiveDepositReader.header(h, 'content-transfer-encoding') ??
                  'binary')
              .toLowerCase();
      final encoded = Uint8List.fromList(
        latin1.encode(raw.substring(end + 4, next)),
      );
      final data = encoding == 'base64'
          ? decode64(ascii.decode(encoded))
          : encoded;
      if (!['binary', '8bit', '7bit', 'base64'].contains(encoding) ||
          id == null ||
          parts.containsKey(id)) {
        throw const FormatException('Encodage ou identifiant MIME invalide.');
      }
      parts[id] = data;
      if (start == null ? count == 1 : start == id) {
        if (root != null) throw const FormatException('Racine MIME dupliquée.');
        root = data;
      }
      pos = next + 2;
    }
    if (root == null) throw const FormatException('Racine MIME absente.');
    return (root: root, parts: parts);
  }
}
