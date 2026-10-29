import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_retry.dart';

void main() {
  const s = 'http://www.w3.org/2003/05/soap-envelope',
      w = 'http://www.w3.org/2005/08/addressing',
      r = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0',
      rs = 'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0';
  const id = 'urn:uuid:11111111-1111-4111-8111-111111111111',
      entry = 'Document_test';
  const value = '187012425258307^^^&amp;1.2.250.1.213.1.4.10&amp;ISO';
  final request =
      '<s:Envelope xmlns:s="$s" xmlns:w="$w" xmlns:r="$r"><s:Header><w:MessageID>$id</w:MessageID><w:To>https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository</w:To><w:Action>urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b</w:Action></s:Header><s:Body><r:ExtrinsicObject id="$entry"/>${['58a6f841-87b3-4a3e-92fd-a8ffeff98427', '58a6f841-87b3-4a3e-92fd-a8ffeff98427', '6b5aea1a-874d-4603-a4bc-96a0a7b38446'].map((scheme) => '<r:ExternalIdentifier identificationScheme="urn:uuid:$scheme" value="$value"/>').join()}</s:Body></s:Envelope>';
  const error =
      '<r:RegistryError errorCode="XDSRegistryMetadataError" severity="urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error" location="AffinityDomainBean.checkpatientId 1" codeContext="entryUUID=$entry;Le champs patientId n\'est pas conforme"/>';
  const response =
      '<s:Envelope xmlns:s="$s" xmlns:w="$w" xmlns:r="$rs"><s:Header><w:Action>urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-bResponse</w:Action><w:RelatesTo>$id</w:RelatesTo></s:Header><s:Body><r:RegistryResponse status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Failure"><r:RegistryErrorList highestSeverity="urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error">$error</r:RegistryErrorList></r:RegistryResponse></s:Body></s:Envelope>';
  bool check(
    String body, {
    String? req,
    int status = 200,
    int? length,
    String extra = '',
  }) {
    final bytes = utf8.encode(body);
    return Dv1Retry.isPatientIdRejection(
      request: req ?? request,
      headers:
          'HTTP/1.1 $status OK\r\nContent-Type: application/soap+xml\r\nContent-Length: ${length ?? bytes.length}\r\n$extra\r\n',
      bytes: bytes,
      documentEntry: entry,
    );
  }

  test(
    'complete correlated exact metadata rejection allows review',
    () => expect(check(response), isTrue),
  );
  for (final mutation in <String, String>{
    'success': response.replaceAll(
      'ResponseStatusType:Failure',
      'ResponseStatusType:Success',
    ),
    'uncorrelated': response.replaceAll(
      id,
      'urn:uuid:22222222-2222-4222-8222-222222222222',
    ),
    'other error': response.replaceAll(
      'XDSRegistryMetadataError',
      'XDSRepositoryError',
    ),
    'other location': response.replaceAll('checkpatientId 1', 'unknown'),
    'other document': response.replaceAll(
      'entryUUID=$entry',
      'entryUUID=other',
    ),
    'extra error': response.replaceFirst(error, '$error$error'),
    'duplicate result': response.replaceFirst(
      '</s:Body>',
      '<r:RegistryResponse status="Success"/></s:Body>',
    ),
    'duplicate correlation': response.replaceFirst(
      '</w:RelatesTo>',
      '</w:RelatesTo><w:RelatesTo>$id</w:RelatesTo>',
    ),
    'warning': response.replaceAll(
      'ErrorSeverityType:Error',
      'ErrorSeverityType:Warning',
    ),
    'wrong action': response.replaceAll(
      'ProvideAndRegisterDocumentSet-bResponse',
      'UnknownResponse',
    ),
    'DTD': '<!DOCTYPE x>$response',
  }.entries) {
    test(
      '${mutation.key} remains blocked',
      () => expect(check(mutation.value), isFalse),
    );
  }
  test('already corrected or inconsistent patient IDs remain blocked', () {
    expect(
      check(response, req: request.replaceAll('&amp;ISO', '&amp;ISO^NH')),
      isFalse,
    );
    expect(
      check(
        response,
        req: request.replaceFirst('187012425258307', '187012425258308'),
      ),
      isFalse,
    );
  });
  test(
    'HTTP failure, truncation, duplicate length and redirects remain blocked',
    () {
      expect(check(response, status: 500), isFalse);
      expect(check(response, length: 1), isFalse);
      expect(
        check(
          response,
          extra: 'Content-Length: ${utf8.encode(response).length}\r\n',
        ),
        isFalse,
      );
      expect(
        check(response, extra: 'Location: https://other.invalid\r\n'),
        isFalse,
      );
    },
  );
}
