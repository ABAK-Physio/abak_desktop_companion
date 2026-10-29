import 'package:xml/xml.dart';
import 'package:uuid/uuid.dart';
import '../../../../dmp_td02/td02_result.dart';
import '../contracts.dart';
import '../messages.dart';
import '../wire/package.dart';
import 'access_context.dart';

/// Official TD0.3 message example: WS-Addressing action differs from the old WSDL.
/// SOAP 1.2 with qualified action/output/status.
class DmpNativeTd03 {
  static const ns = 'urn:si-dmp-habilitations';
  static const action =
      'urn:si-dmp-habilitations:HabilitationsEndPoint:setAuthorization';
  static const endpoint =
      'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/habilitations';
  static String build(
    Dv1AccessContext context,
    DmpSession session,
    DmpWireMaterial material,
    DateTime time, {
    required bool add,
  }) {
    context.check(time);
    material.check(session, time);
    final tag = DmpWireDraft.tag, text = DmpWireDraft.text;
    final vihf = DmpWireDraft.buildVihf(
      context.snapshot,
      session,
      material,
      time,
      const Uuid().v4(),
      secretConnection: context.secretConnection,
    );
    return tag(
      's:Envelope',
      tag(
            's:Header',
            text('w:MessageID', DmpChainMessages.id) +
                text('w:To', endpoint) +
                text('w:Action', action) +
                tag(
                  'w:ReplyTo',
                  text(
                    'w:Address',
                    'http://www.w3.org/2005/08/addressing/anonymous',
                  ),
                ) +
                tag('sec:Security', vihf, {
                  'xmlns:sec':
                      'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
                }),
          ) +
          tag(
            's:Body',
            tag(
              'h:setAuthorization',
              text('h:action', add ? 'AJOUT' : 'SUPPRESSION'),
              {'xmlns:h': ns},
            ),
          ),
      {'xmlns:s': DmpChainMessages.soap, 'xmlns:w': DmpChainMessages.wsa},
    );
  }

  static ({String status, String detail}) read(
    String request,
    DmpTd02Reply reply,
  ) {
    if (reply.status != 200 && reply.status != 500) {
      throw StateError(
        'Réponse TD0.3 HTTP ${reply.status}. Modification non confirmée.',
      );
    }
    final response = Td02Reader.parse(reply.xml);
    final header = Td02Reader.one(response, 'Header', Td02Reader.soap);
    final sent = Td02Reader.one(
      Td02Reader.parse(request),
      'Header',
      Td02Reader.soap,
    );
    if (Td02Reader.one(header, 'RelatesTo', Td02Reader.wsa).innerText.trim() !=
        Td02Reader.one(sent, 'MessageID', Td02Reader.wsa).innerText.trim()) {
      throw StateError(
        'Réponse TD0.3 non corrélée. Modification non confirmée.',
      );
    }
    final body = Td02Reader.one(response, 'Body', Td02Reader.soap);
    if (body.childElements.length != 1) {
      throw const FormatException('Corps TD0.3 ambigu');
    }
    final faults = Td02Reader.children(body, 'Fault', Td02Reader.soap);
    if (faults.length == 1) {
      final fault = faults.single;
      final code = Td02Reader.one(fault, 'Code', Td02Reader.soap);
      final subcodes = Td02Reader.children(code, 'Subcode', Td02Reader.soap);
      final value = Td02Reader.one(
        subcodes.isEmpty ? code : subcodes.single,
        'Value',
        Td02Reader.soap,
      ).innerText.trim();
      final reason = Td02Reader.one(fault, 'Reason', Td02Reader.soap);
      final texts = Td02Reader.children(reason, 'Text', Td02Reader.soap);
      return (
        status: value,
        detail: texts.map((e) => e.innerText.trim()).join(' · '),
      );
    }
    if (reply.status != 200) {
      throw StateError(
        'Réponse TD0.3 HTTP ${reply.status}. Modification non confirmée.',
      );
    }
    final output = Td02Reader.one(
      Td02Reader.one(body, 'setAuthorizationResponse', ns),
      'output',
      ns,
    );
    final status = Td02Reader.one(output, 'status', ns).innerText.trim();
    final details = Td02Reader.children(output, 'context', ns);
    if (details.length > 1) {
      throw const FormatException('Contexte TD0.3 dupliqué');
    }
    return (
      status: status,
      detail: details.isEmpty ? '' : details.single.innerText.trim(),
    );
  }
}
