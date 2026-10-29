import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_retry.dart';

void main() {
  const soap = 'http://www.w3.org/2003/05/soap-envelope';
  const wsa = 'http://www.w3.org/2005/08/addressing';
  const id = 'urn:uuid:11111111-1111-4111-8111-111111111111';
  const request =
      '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa" xmlns:wsse="${Dv1Retry.wsse}"><s:Header>'
      '<w:MessageID>$id</w:MessageID><w:To>https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository</w:To>'
      '<w:Action>urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b</w:Action>'
      '<wsse:Security s:mustUnderstand="true"/></s:Header><s:Body/></s:Envelope>';
  const response =
      '<soap:Envelope xmlns:soap="$soap" xmlns:w="$wsa"><soap:Header>'
      '<w:Action>${Dv1Retry.faultAction}</w:Action><w:RelatesTo>$id</w:RelatesTo></soap:Header>'
      '<soap:Body><soap:Fault><soap:Code><soap:Value>soap:MustUnderstand</soap:Value></soap:Code>'
      '<soap:Reason><soap:Text xml:lang="en">${Dv1Retry.reason}</soap:Text></soap:Reason>'
      '</soap:Fault></soap:Body></soap:Envelope>';
  bool check(
    String xml, {
    String req = request,
    String status = '500 Internal Server Error',
    String extra = '',
    int? length,
  }) {
    final bytes = utf8.encode(xml);
    return Dv1Retry.isSecurityMustUnderstand(
      request: req,
      headers:
          'HTTP/1.1 $status\r\nContent-Type: application/soap+xml\r\nContent-Length: ${length ?? bytes.length}\r\n$extra\r\n',
      bytes: bytes,
    );
  }

  test(
    'exact correlated Security fault is eligible without network or CPS',
    () {
      expect(check(response), isTrue);
    },
  );
  test('MIME response is accepted only when complete', () {
    final body =
        '\r\n--boundary\r\nContent-Type: application/xop+xml; type="application/soap+xml"\r\nContent-ID: <root>\r\n\r\n$response\r\n--boundary--';
    final bytes = utf8.encode(body);
    final headers =
        'HTTP/1.1 500 Internal Server Error\r\nContent-Type: multipart/related; boundary="boundary"; start="<root>"\r\nContent-Length: ${bytes.length}\r\n\r\n';
    expect(
      Dv1Retry.isSecurityMustUnderstand(
        request: request,
        headers: headers,
        bytes: bytes,
      ),
      isTrue,
    );
    expect(
      Dv1Retry.isSecurityMustUnderstand(
        request: request,
        headers: headers,
        bytes: bytes.sublist(0, bytes.length - 4),
      ),
      isFalse,
    );
  });
  for (final entry in <String, String>{
    'uncorrelated': response.replaceAll(
      id,
      'urn:uuid:22222222-2222-4222-8222-222222222222',
    ),
    'duplicate correlation': response.replaceFirst(
      '</w:RelatesTo>',
      '</w:RelatesTo><w:RelatesTo>$id</w:RelatesTo>',
    ),
    'wrong action': response.replaceFirst(Dv1Retry.faultAction, 'urn:unknown'),
    'generic fault': response.replaceFirst(
      'soap:MustUnderstand',
      'soap:Receiver',
    ),
    'wrong QName namespace': response
        .replaceFirst('<soap:Value>', '<soap:Value xmlns:wrong="urn:wrong">')
        .replaceFirst('soap:MustUnderstand', 'wrong:MustUnderstand'),
    'other header': response.replaceFirst('}Security]', '}Other]'),
    'application detail': response.replaceFirst(
      '</soap:Fault>',
      '<soap:Detail>unknown effect</soap:Detail></soap:Fault>',
    ),
    'subcode': response.replaceFirst(
      '</soap:Code>',
      '<soap:Subcode/></soap:Code>',
    ),
    'additional result': response.replaceFirst(
      '</soap:Body>',
      '<RegistryResponse status="Success"/></soap:Body>',
    ),
    'duplicate fault': response.replaceFirst(
      '</soap:Body>',
      '<soap:Fault/></soap:Body>',
    ),
    'truncated XML': response.substring(0, response.length - 10),
    'DTD': '<!DOCTYPE soap:Envelope [<!ENTITY x "test">]>$response',
  }.entries) {
    test(
      '${entry.key} stays blocked',
      () => expect(check(entry.value), isFalse),
    );
  }
  test('success, redirects and unavailable server never authorize retry', () {
    for (final status in ['200 OK', '302 Found', '503 Service Unavailable']) {
      expect(check(response, status: status), isFalse);
    }
  });
  test(
    'changed endpoint, action or already corrected headers stay blocked',
    () {
      for (final req in [
        request.replaceFirst('lps.dev1', 'lps.production'),
        request.replaceFirst('ProvideAndRegisterDocumentSet-b', 'Other'),
        request.replaceFirst('s:mustUnderstand="true"', ''),
        request.replaceFirst('<w:MessageID>', '<w:MessageID>wrong'),
      ]) {
        expect(check(response, req: req), isFalse);
      }
    },
  );
  test('ambiguous HTTP framing stays blocked', () {
    expect(check(response, length: 1), isFalse);
    for (final extra in [
      'Content-Length: 1\r\n',
      'Transfer-Encoding: chunked\r\n',
      'Content-Encoding: gzip\r\n',
      'Location: https://other.invalid\r\n',
      'HTTP/1.1 200 OK\r\n',
    ]) {
      expect(check(response, extra: extra), isFalse);
    }
  });
}
