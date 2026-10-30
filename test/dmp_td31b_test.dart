import 'dv1_consultation_consent_test.dart' show SerializationOnly;
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/access_context.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31b.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';

void main() {
  const soap = 'http://www.w3.org/2003/05/soap-envelope';
  const wsa = 'http://www.w3.org/2005/08/addressing';
  const id = 'urn:uuid:11111111-1111-4111-8111-111111111111';
  const other = 'urn:uuid:22222222-2222-4222-8222-222222222222';
  const request =
      '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa">'
      '<s:Header><w:MessageID>$id</w:MessageID></s:Header><s:Body/></s:Envelope>';
  String response(String objects, {String relates = id, bool success = true}) =>
      '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa"><s:Header>'
      '<w:RelatesTo>$relates</w:RelatesTo>'
      '<w:Action>${DmpNativeTd31b.action}Response</w:Action></s:Header><s:Body>'
      '<AdhocQueryResponse xmlns="${DmpNativeTd31b.query}" '
      'status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:${success ? 'Success' : 'Failure'}">'
      '<RegistryObjectList xmlns="${DmpNativeTd31b.rim}">$objects</RegistryObjectList>'
      '</AdhocQueryResponse></s:Body></s:Envelope>';
  List<String> read(String xml, [int status = 200]) =>
      DmpNativeTd31b.read(request, DmpTd02Reply(status, xml));
  test(
    'builds only GetDocuments ObjectRef with patient context and fresh correlation',
    () {
      final now = DateTime.utc(2026, 10, 27, 12);
      final context = Dv1AccessContext(
        professional: '12345678901',
        structure: '123456789',
        sector: 'SA07',
        ins: '123456789012345',
        patientLabel: 'SYNTHETIQUE',
        source: 'fixture',
        scenario: 'PRE_ALIM_RECH',
        confirmedAt: now,
        birthDate: '1980-01-01',
      );
      final session = DmpSession(
        id: 'TEST',
        professional: context.professional,
        authority: '2.25.123',
        structure: context.structure,
        certificateHash: '',
        contextHash: '',
        issuedAt: now,
        expiresAt: now.add(const Duration(minutes: 2)),
      );
      String build() => DmpNativeTd31b.build(
        context,
        session,
        SerializationOnly(),
        now,
        '2.25.123',
      );
      final first = build();
      final xml = XmlDocument.parse(first);
      expect(
        xml.findAllElements('To', namespaceUri: wsa).single.innerText,
        DmpNativeTd31b.endpoint,
      );
      expect(
        xml.findAllElements('Action', namespaceUri: wsa).single.innerText,
        DmpNativeTd31b.action,
      );
      expect(
        xml
            .findAllElements('ResponseOption', namespaceUri: DmpNativeTd31b.query)
            .single
            .getAttribute('returnType'),
        'ObjectRef',
      );
      expect(
        xml
            .findAllElements('Slot', namespaceUri: DmpNativeTd31b.rim)
            .single
            .getAttribute('name'),
        r'$XDSDocumentEntryUniqueId',
      );
      expect(
        xml
            .findAllElements('Value', namespaceUri: DmpNativeTd31b.rim)
            .single
            .innerText,
        "('2.25.123')",
      );
      expect(first, contains(context.ins));
      expect(first, isNot(contains('setAuthorization')));
      expect(
        xml.findAllElements('MessageID', namespaceUri: wsa).single.innerText,
        isNot(
          XmlDocument.parse(
            build(),
          ).findAllElements('MessageID', namespaceUri: wsa).single.innerText,
        ),
      );
    },
  );
  test('distinguishes absent, unique and ambiguous technical results', () {
    expect(read(response('')), isEmpty);
    expect(read(response('<ObjectRef id="$id"/>')), [id]);
    expect(read(response('<ObjectRef id="$id"/><ObjectRef id="$other"/>')), [
      id,
      other,
    ]);
  });
  test('accepts a correlated SOAP root in a multipart response', () {
    final body =
        '--test\r\nContent-Type: application/soap+xml; charset=UTF-8\r\n'
        'Content-ID: <soap>\r\n\r\n${response('<ObjectRef id="$id"/>')}\r\n--test--\r\n';
    expect(
      DmpNativeTd31b.read(
        request,
        DmpTd02Reply(
          200,
          body,
          headers:
              'Content-Type: multipart/related; boundary="test"; start="<soap>"',
        ),
      ),
      [id],
    );
  });
  test('rejects unrelated response and unsuccessful status', () {
    expect(() => read(response('', relates: other)), throwsStateError);
    expect(() => read(response('', success: false)), throwsStateError);
    expect(() => read(response(''), 500), throwsStateError);
  });
  test('rejects document content, invalid references and duplicates', () {
    for (final objects in [
      '<ExtrinsicObject id="$id"/>',
      '<ObjectRef id="not-a-uuid"/>',
      '<ObjectRef id="$id"><Content/></ObjectRef>',
      '<ObjectRef id="$id"/><ObjectRef id="$id"/>',
    ]) {
      expect(() => read(response(objects)), throwsFormatException);
    }
  });
  test('rejects SOAP fault without presenting it as an empty search', () {
    final xml =
        '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa"><s:Header>'
        '<w:RelatesTo>$id</w:RelatesTo></s:Header><s:Body><s:Fault/>'
        '</s:Body></s:Envelope>';
    expect(() => read(xml, 500), throwsStateError);
  });
}
