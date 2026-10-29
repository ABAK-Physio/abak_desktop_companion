import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_retry.dart';

void main() {
  const id = 'urn:uuid:11111111-1111-4111-8111-111111111111';
  const request =
      '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:w="http://www.w3.org/2005/08/addressing" xmlns:r="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0"><s:Header><w:MessageID>$id</w:MessageID><w:To>https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository</w:To><w:Action>urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b</w:Action></s:Header><s:Body><r:ExtrinsicObject id="Document_test"/><r:ExtrinsicObject id="Signature_test"/><r:RegistryPackage id="Submission_test"/></s:Body></s:Envelope>';
  final response = File(
    'test/fixtures/dv1_metadata_retry/response.xml',
  ).readAsStringSync();
  bool check(
    String body, {
    String req = request,
    int status = 200,
    int? length,
    String extra = '',
  }) {
    final bytes = utf8.encode(body);
    return Dv1Retry.isMetadataRejection(
      request: req,
      headers:
          'HTTP/1.1 $status OK\r\nContent-Type: application/soap+xml\r\nContent-Length: ${length ?? bytes.length}\r\n$extra\r\n',
      bytes: bytes,
      documentEntry: 'Document_test',
      signatureEntry: 'Signature_test',
      submissionEntry: 'Submission_test',
    );
  }

  test(
    'exact eight correlated errors are eligible',
    () => expect(check(response), isTrue),
  );
  for (final pair in [
    ('ResponseStatusType:Failure', 'ResponseStatusType:Success'),
    (id, 'urn:uuid:22222222-2222-4222-8222-222222222222'),
    ('XDSRegistryMetadataError', 'XDSRepositoryError'),
    ('ErrorSeverityType:Error', 'ErrorSeverityType:Warning'),
    ('Signature_test', 'Signature_other'),
    ('Submission_test', 'Submission_other'),
    ('Document_test', 'Document_other'),
    ('AffinityDomainImpl.checkRequest 32', 'other'),
    ('ProvideAndRegisterDocumentSet-bResponse', 'UnknownResponse'),
  ]) {
    test(
      'refuse changed ${pair.$1}',
      () => expect(check(response.replaceAll(pair.$1, pair.$2)), isFalse),
    );
  }
  for (var n = 0; n < 8; n++) {
    test('error $n cannot be missing or replaced', () {
      final xml = XmlDocument.parse(response);
      final errors = xml
          .findAllElements(
            'RegistryError',
            namespace: 'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0',
          )
          .toList();
      errors[n].setAttribute('codeContext', 'other metadata error');
      expect(check(xml.toXmlString()), isFalse);
      errors[n].parent!.children.remove(errors[n]);
      expect(check(xml.toXmlString()), isFalse);
    });
  }
  test('duplicate errors cannot hide a missing error', () {
    final xml = XmlDocument.parse(response);
    final errors = xml
        .findAllElements(
          'RegistryError',
          namespace: 'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0',
        )
        .toList();
    errors.last.setAttribute(
      'codeContext',
      errors.first.getAttribute('codeContext')!,
    );
    errors.last.setAttribute(
      'location',
      errors.first.getAttribute('location')!,
    );
    expect(check(xml.toXmlString()), isFalse);
  });
  test(
    'truncation, ambiguous framing, HTTP failure, wrong target and DTD refuse retry',
    () {
      expect(check(response, length: 1), isFalse);
      expect(check(response, status: 500), isFalse);
      expect(
        check(
          response,
          extra: 'Content-Length: ${utf8.encode(response).length}\r\n',
        ),
        isFalse,
      );
      expect(
        check(
          response,
          req: request.replaceFirst('lps.dev1.dmp.gouv.fr', 'other.invalid'),
        ),
        isFalse,
      );
      expect(check('<!DOCTYPE x>$response'), isFalse);
    },
  );
}
