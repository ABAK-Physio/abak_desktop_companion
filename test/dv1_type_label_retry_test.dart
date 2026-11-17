import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_retry.dart';

import 'support/dv1_type_label_fixture.dart';

void main() {
  final old = jsonDecode(
    File('test/fixtures/dv1_type_label/legacy_packet.json').readAsStringSync(),
  ) as Map;
  final package = old['package'] as Map;
  final entry = package['wire']['replay']['identifiers']['cdaEntry'] as String;
  final request = package['request'] as String;
  final label =
      jsonDecode(old['snapshot']['preparation']['data_json'])['typeLabel']
          as String;
  final response = TypeLabelFixture.responseXml(
    package['messageId'],
    entry,
    label,
  );
  bool check(String body, {String? req, String? headers, List<int>? bytes}) {
    final data = bytes ?? utf8.encode(body);
    return Dv1Retry.isTypeLabelRejection(
      request: req ?? request,
      headers: headers ?? TypeLabelFixture.headers(data),
      bytes: data,
      documentEntry: entry,
    );
  }

  test('only the exact correlated 11490-0 label rejection permits review', () {
    expect(check(response), true);
  });
  for (final pair in [
    ('ResponseStatusType:Failure', 'ResponseStatusType:Success'),
    ('XDSRegistryMetadataError', 'XDSRepositoryError'),
    ('ErrorSeverityType:Error', 'ErrorSeverityType:Warning'),
    ('AffinityDomainBean.validateXDSDocumentEntry 3', 'other'),
    ('ProvideAndRegisterDocumentSet-bResponse', 'other'),
    ('Lettre de sortie', 'other'),
    ('11490-0', '11506-3'),
    (entry, 'Document_11111111-1111-4111-8111-111111111111'),
    (
      package['messageId'] as String,
      'urn:uuid:11111111-1111-4111-8111-111111111111',
    ),
  ]) {
    test('changed response ${pair.$1} remains blocked', () {
      expect(check(response.replaceAll(pair.$1, pair.$2)), false);
    });
  }
  test('missing, extra or nested errors remain blocked', () {
    final xml = XmlDocument.parse(response);
    final errors = xml
        .findAllElements(
          'RegistryError',
          namespaceUri: 'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0',
        )
        .single;
    final original = errors.toXmlString();
    expect(check(response.replaceFirst(original, '')), false);
    expect(check(response.replaceFirst(original, '$original$original')), false);
    errors.children.add(XmlDocument.parse('<extra/>').rootElement.copy());
    expect(check(xml.toXmlString()), false);
  });
  test('a different request label, code, system, endpoint or duplicate clinical entry blocks', () {
    for (final req in [
      request.replaceAll(label, 'Lettre de sortie'),
      request.replaceAll('11490-0', '11506-3'),
      request.replaceAll('2.16.840.1.113883.6.1', '1.2.3'),
      request.replaceAll('lps.dev1.dmp.gouv.fr', 'lps.dmp.gouv.fr'),
      request.replaceFirst(
        '</rim:RegistryObjectList>',
        '<rim:ExtrinsicObject id="$entry"/></rim:RegistryObjectList>',
      ),
    ]) {
      expect(check(response, req: req), false);
    }
  });
  test('HTTP error, incomplete length, compressed response, redirects and DTD block', () {
    final headers = TypeLabelFixture.headers(utf8.encode(response));
    for (final h in [
      headers.replaceFirst('200 OK', '500 Error'),
      headers.replaceFirst('Content-Length:', 'Other-Length:'),
      headers.replaceFirst('\r\n\r\n', '\r\nContent-Encoding: gzip\r\n\r\n'),
      headers.replaceFirst(
        '\r\n\r\n',
        '\r\nLocation: https://other.invalid/\r\n\r\n',
      ),
    ]) {
      expect(check(response, headers: h), false);
    }
    expect(
      check(
        response,
        bytes: utf8.encode(response).sublist(0, 20),
        headers: headers,
      ),
      false,
    );
    expect(check('<!DOCTYPE x>$response'), false);
  });
}
