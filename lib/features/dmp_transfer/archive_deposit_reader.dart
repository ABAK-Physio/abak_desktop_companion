import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'transfer_simulation.dart';

class ArchiveDepositResult {
  const ArchiveDepositResult(this.outcome, this.detail);
  final DepositOutcome outcome;
  final String detail;
}

/// Pure offline interpretation; never opens a socket or calls a launcher.
class ArchiveDepositReader {
  static const soap = 'http://www.w3.org/2003/05/soap-envelope';
  static const wsa = 'http://www.w3.org/2005/08/addressing';
  static const rs = 'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0';
  static const action =
      'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-bResponse';
  static const statusPrefix =
      'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:';
  static XmlElement one(XmlNode parent, String name, String ns) {
    final items = parent.children
        .whereType<XmlElement>()
        .where((e) => e.name.local == name && e.namespaceUri == ns)
        .toList();
    if (items.length != 1) {
      throw FormatException('Champ absent ou dupliqué : $name');
    }
    return items.single;
  }

  static XmlDocument parse(String text) {
    if (text.length > 2 * 1024 * 1024 || text.contains('<!DOCTYPE')) {
      throw const FormatException('XML interdit ou trop volumineux');
    }
    return XmlDocument.parse(text);
  }

  static String? header(String text, String key) {
    final values = text
        .split(RegExp(r'\r?\n'))
        .where(
          (line) =>
              line.contains(':') &&
              line.substring(0, line.indexOf(':')).trim().toLowerCase() == key,
        )
        .map((line) => line.substring(line.indexOf(':') + 1).trim())
        .toList();
    if (values.length > 1) throw FormatException('En-tête dupliqué : $key');
    return values.isEmpty ? null : values.single;
  }

  static String? parameter(String text, String key) {
    final matches = RegExp(
      '(?:^|;)\\s*$key\\s*=\\s*(?:"([^"]*)"|([^;\\s]+))',
      caseSensitive: false,
    ).allMatches(text).toList();
    if (matches.length > 1) {
      throw FormatException('Paramètre MIME dupliqué : $key');
    }
    return matches.isEmpty
        ? null
        : matches.single.group(1) ?? matches.single.group(2);
  }

  static String extract(String headers, List<int> bytes) {
    if (bytes.length > 2 * 1024 * 1024) {
      throw const FormatException('Réponse trop volumineuse');
    }
    final type = header(headers, 'content-type') ?? '';
    if (!type.toLowerCase().startsWith('multipart/related')) {
      return utf8.decode(bytes);
    }
    final boundary = parameter(type, 'boundary'),
        start = parameter(type, 'start');
    if (boundary == null ||
        boundary.isEmpty ||
        boundary.length > 200 ||
        boundary.contains(RegExp(r'[\r\n]'))) {
      throw const FormatException('Frontière MIME invalide');
    }
    final body = latin1.decode(bytes), marker = '--$boundary';
    var pos = body.startsWith(marker) ? 0 : body.indexOf('\r\n$marker') + 2;
    String? root;
    final ids = <String>{};
    var count = 0;
    while (true) {
      if (pos < 0 || !body.startsWith(marker, pos)) {
        throw const FormatException('Frontière MIME absente');
      }
      pos += marker.length;
      if (body.startsWith('--', pos)) break;
      if (!body.startsWith('\r\n', pos) || ++count > 100) {
        throw const FormatException('Partie MIME invalide');
      }
      pos += 2;
      final end = body.indexOf('\r\n\r\n', pos);
      if (end < pos || end - pos > 32768) {
        throw const FormatException('En-têtes MIME invalides');
      }
      final h = body.substring(pos, end),
          next = body.indexOf('\r\n$marker', end + 4);
      if (next < 0) throw const FormatException('Réponse MIME tronquée');
      final id = header(h, 'content-id');
      if (id != null && !ids.add(id)) {
        throw const FormatException('Content-ID dupliqué');
      }
      if (start == null ? count == 1 : start == id) {
        if (root != null) throw const FormatException('Racine SOAP dupliquée');
        final partType = (header(h, 'content-type') ?? '').toLowerCase();
        final encoding = (header(h, 'content-transfer-encoding') ?? 'binary')
            .toLowerCase();
        if (!(partType.startsWith('application/xop+xml') ||
                partType.startsWith('application/soap+xml')) ||
            !{'binary', '8bit', '7bit'}.contains(encoding)) {
          throw const FormatException('Type ou encodage MIME inattendu');
        }
        root = utf8.decode(latin1.encode(body.substring(end + 4, next)));
      }
      pos = next + 2;
    }
    if (root == null) throw const FormatException('Racine SOAP absente');
    return root;
  }

  static ArchiveDepositResult read({
    required String request,
    required String headers,
    required List<int> bytes,
  }) {
    try {
      final q = one(parse(request), 'Envelope', soap);
      final requestId = one(one(q, 'Header', soap), 'MessageID', wsa).innerText;
      if (requestId.isEmpty) {
        throw const FormatException('Identifiant de requête absent');
      }
      return readForMessageId(
        requestMessageId: requestId,
        headers: headers,
        bytes: bytes,
      );
    } catch (e) {
      return const ArchiveDepositResult(
        DepositOutcome.indeterminate,
        'Requête archivée illisible ou identifiant absent.',
      );
    }
  }

  /// The caller retains the exact immutable request and its generated ID.
  /// Avoid parsing a large base64 PDF/CDA just to correlate the response.
  static ArchiveDepositResult readForMessageId({
    required String requestMessageId,
    required String headers,
    required List<int> bytes,
  }) {
    try {
      final statusMatch = RegExp(
        r'^HTTP/\d(?:\.\d)? (\d{3})(?: |\r?$)',
        multiLine: true,
      ).firstMatch(headers);
      if (statusMatch == null) {
        throw const FormatException('Statut HTTP absent');
      }
      final status = int.parse(statusMatch.group(1)!);
      if (status >= 300 && status < 400) {
        throw const FormatException('Redirection HTTP : aucun suivi');
      }
      if (requestMessageId.isEmpty ||
          requestMessageId.length > 256 ||
          requestMessageId.contains(RegExp(r'[\r\n]'))) {
        throw const FormatException('Identifiant de requête invalide');
      }
      final requestId = requestMessageId;
      final d = one(parse(extract(headers, bytes)), 'Envelope', soap),
          h = one(d, 'Header', soap),
          b = one(d, 'Body', soap);
      if (one(h, 'RelatesTo', wsa).innerText != requestId) {
        throw const FormatException('Réponse non corrélée : résultat ignoré');
      }
      if (b.children.whereType<XmlElement>().any(
        (e) => e.name.local == 'Fault' && e.namespaceUri == soap,
      )) {
        throw const FormatException('Erreur SOAP : dépôt non confirmé');
      }
      if (status < 200 || status >= 300) {
        throw FormatException('HTTP $status : dépôt non confirmé');
      }
      if (one(h, 'Action', wsa).innerText != action) {
        throw const FormatException('Action réponse inattendue');
      }
      final reply = one(b, 'RegistryResponse', rs);
      final errors = reply.descendants
          .whereType<XmlElement>()
          .where((e) => e.name.local == 'RegistryError' && e.namespaceUri == rs)
          .toList();
      final detail = errors
          .map(
            (e) =>
                'Code XDS : ${e.getAttribute('errorCode') ?? ''} — ${e.getAttribute('codeContext') ?? ''}',
          )
          .join('\n');
      final hasError = errors.any(
        (e) =>
            e.getAttribute('severity') !=
            'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Warning',
      );
      if (reply.getAttribute('status') == '${statusPrefix}Success' &&
          !hasError) {
        return ArchiveDepositResult(
          DepositOutcome.accepted,
          'XDS Success. $detail',
        );
      }
      if (reply.getAttribute('status') == '${statusPrefix}Failure') {
        final codes = errors.map((e) => e.getAttribute('errorCode')).toSet();
        final outcome = codes.contains('DMPInvalidSignature')
            ? DepositOutcome.signatureRejected
            : codes.contains('XDSRegistryMetadataError')
            ? DepositOutcome.metadataRejected
            : DepositOutcome.rejected;
        return ArchiveDepositResult(outcome, 'XDS Failure. $detail');
      }
      return ArchiveDepositResult(
        DepositOutcome.indeterminate,
        'Statut XDS inconnu ou incohérent. $detail',
      );
    } catch (e) {
      return ArchiveDepositResult(
        DepositOutcome.indeterminate,
        e is FormatException
            ? e.message
            : 'Réponse XML/MTOM illisible ou incohérente.',
      );
    }
  }
}

class ArchiveReplayService
    implements TransferSimulationService, TransferDiagnosticSource {
  ArchiveReplayService(this.scenario, {AssetBundle? bundle})
    : bundle = bundle ?? rootBundle;
  final String scenario;
  final AssetBundle bundle;
  @override
  String detail = '';
  @override
  Future<TlsFailure?> connect() async => null; // No TLS is opened.
  @override
  Future<DepositOutcome> deposit() async {
    final name = scenario == 'truncated' || scenario == 'uncorrelated'
        ? 'accepted'
        : scenario;
    const path = 'assets/dmp_local/deposit_replay';
    var request = await bundle.loadString('$path/$name-request.xml');
    final headers = await bundle.loadString('$path/$name-headers.txt');
    final data = await bundle.load('$path/$name-response.bin');
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    if (scenario == 'truncated') bytes = bytes.sublist(0, bytes.length - 30);
    if (scenario == 'uncorrelated') {
      final q = ArchiveDepositReader.parse(request);
      ArchiveDepositReader.one(
        ArchiveDepositReader.one(
          ArchiveDepositReader.one(q, 'Envelope', ArchiveDepositReader.soap),
          'Header',
          ArchiveDepositReader.soap,
        ),
        'MessageID',
        ArchiveDepositReader.wsa,
      ).innerText = 'urn:uuid:synthetic-other-request';
      request = q.toXmlString();
    }
    final result = ArchiveDepositReader.read(
      request: request,
      headers: headers,
      bytes: bytes,
    );
    detail =
        'Relecture historique hors réseau${scenario == 'truncated' || scenario == 'uncorrelated' ? ' — variante synthétique' : ''}.\n${result.detail}';
    return result.outcome;
  }
}
