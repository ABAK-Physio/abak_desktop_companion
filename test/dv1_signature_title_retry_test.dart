import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_retry.dart';

void main() {
  const id = 'urn:uuid:11111111-1111-4111-8111-111111111111';
  const s = 'http://www.w3.org/2003/05/soap-envelope',
      w = 'http://www.w3.org/2005/08/addressing';
  const request =
      '<s:Envelope xmlns:s="$s" xmlns:w="$w" xmlns:r="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0"><s:Header><w:MessageID>$id</w:MessageID><w:To>https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository</w:To><w:Action>urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b</w:Action></s:Header><s:Body><r:ExtrinsicObject id="Document_test"/><r:ExtrinsicObject id="Signature_test"><r:Name><r:LocalizedString value="Signature du lot"/></r:Name><r:Classification classificationScheme="urn:uuid:2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4" nodeRepresentation="1.2.840.10065.1.12.1.14"><r:Name><r:LocalizedString value="Source"/></r:Name></r:Classification></r:ExtrinsicObject><r:RegistryPackage id="Submission_test"/></s:Body></s:Envelope>';
  const error =
      '<r:RegistryError errorCode="XDSRegistryMetadataError" severity="urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error" location="AffinityDomainImpl.checkRequest 46" codeContext="Incohérence entre le titre et le eventCodeListDisplayName de la signature"/>';
  const response =
      '<s:Envelope xmlns:s="$s" xmlns:w="$w" xmlns:r="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0"><s:Header><w:Action>urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-bResponse</w:Action><w:RelatesTo>$id</w:RelatesTo></s:Header><s:Body><r:RegistryResponse status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Failure"><r:RegistryErrorList highestSeverity="urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error">$error</r:RegistryErrorList></r:RegistryResponse></s:Body></s:Envelope>';
  bool check(
    String body, {
    String req = request,
    int status = 200,
    int? length,
  }) {
    final bytes = utf8.encode(body);
    return Dv1Retry.isSignatureTitleRejection(
      request: req,
      headers:
          'HTTP/1.1 $status OK\r\nContent-Type: application/soap+xml\r\nContent-Length: ${length ?? bytes.length}\r\n\r\n',
      bytes: bytes,
      documentEntry: 'Document_test',
      signatureEntry: 'Signature_test',
      submissionEntry: 'Submission_test',
    );
  }

  test(
    'exact title mismatch allows review',
    () => expect(check(response), isTrue),
  );
  for (final pair in [
    ('ResponseStatusType:Failure', 'ResponseStatusType:Success'),
    (id, 'urn:uuid:22222222-2222-4222-8222-222222222222'),
    ('XDSRegistryMetadataError', 'XDSRepositoryError'),
    ('ErrorSeverityType:Error', 'ErrorSeverityType:Warning'),
    ('AffinityDomainImpl.checkRequest 46', 'other'),
    ('ProvideAndRegisterDocumentSet-bResponse', 'UnknownResponse'),
    ('eventCodeListDisplayName', 'other'),
  ]) {
    test(
      'refuse changed ${pair.$1}',
      () => expect(check(response.replaceAll(pair.$1, pair.$2)), isFalse),
    );
  }
  test('missing or duplicate errors remain blocked', () {
    expect(check(response.replaceFirst(error, '')), isFalse);
    expect(check(response.replaceFirst(error, '$error$error')), isFalse);
  });
  test('corrected title or unrelated signature data cannot use this route', () {
    expect(
      check(response, req: request.replaceAll('Signature du lot', 'Source')),
      isFalse,
    );
    expect(
      check(
        response,
        req: request.replaceAll('value="Source"', 'value="Other"'),
      ),
      isFalse,
    );
    expect(
      check(response, req: request.replaceAll('Signature_test', 'other')),
      isFalse,
    );
  });
  test('HTTP failure, truncation and DTD remain blocked', () {
    expect(check(response, status: 500), isFalse);
    expect(check(response, length: 1), isFalse);
    expect(check('<!DOCTYPE x>$response'), isFalse);
  });
}
