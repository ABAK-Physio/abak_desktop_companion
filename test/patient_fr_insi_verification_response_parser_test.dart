import 'package:flutter_test/flutter_test.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_verification_response_parser.dart';

void main() {
  const parser = PatientFrInsiVerificationResponseParser();
  const soap = 'http://www.w3.org/2003/05/soap-envelope';
  const resultNs = 'http://www.cnamts.fr/INSiLot2/REPUnitaire';
  const common = 'http://www.cnamts.fr/MRA/CommunLot';

  String envelope(String body, {String header = ''}) => '''
<s:Envelope xmlns:s="$soap" xmlns:r="$resultNs" xmlns:c="$common" xmlns:insi="urn:siram">
  $header<s:Body>$body</s:Body>
</s:Envelope>''';

  String result(String code, {String label = '<c:Libelle>OK INS vérifié</c:Libelle>',
      String extra = ''}) => '''
<r:ResultatUnitaire><r:CrUnitaire><c:CR>
<c:Code>$code</c:Code>$label
</c:CR></r:CrUnitaire>$extra</r:ResultatUnitaire>''';

  const faultContent = '''
<s:Code><s:Value>s:Receiver</s:Value>
<s:Subcode><s:Value>insi:indisponible</s:Value></s:Subcode></s:Code>
<s:Reason><s:Text xml:lang="fr">Service temporairement indisponible</s:Text></s:Reason>
''';

  test('reads the official WS_INS3 example without requiring an INDIVIDU', () {
    // Same payload and namespaces as the package 05.00.00 IDIR response example.
    const xml = '''
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
 <env:Body xmlns:env="http://www.w3.org/2003/05/soap-envelope">
  <ns1:ResultatUnitaire xmlns:ns1="http://www.cnamts.fr/INSiLot2/REPUnitaire"
      xmlns:ns4="http://www.cnamts.fr/MRA/CommunLot">
   <ns1:CrUnitaire><ns4:CR><ns4:Code>00</ns4:Code>
    <ns4:Libelle>OK INS vérifié</ns4:Libelle>
   </ns4:CR></ns1:CrUnitaire>
  </ns1:ResultatUnitaire>
 </env:Body>
</soap:Envelope>''';
    final response = parser.parseXml(xml);
    expect(response.status, PatientFrInsiVerificationStatus.verified);
    expect(response.codeCr, '00');
    expect(response.label, 'OK INS vérifié');
    expect(response.isVerified, isTrue);
    expect(response.isFault, isFalse);
  });

  test('01 means verification unsuccessful, never identity not found or success', () {
    final response = parser.parseXml(envelope(result('01',
      label: '<c:Libelle>Vérification sans succès</c:Libelle>')));
    expect(response.status, PatientFrInsiVerificationStatus.notVerified);
    expect(response.codeCr, '01');
    expect(response.label, 'Vérification sans succès');
    expect(response.isVerified, isFalse);
    expect(response.isFault, isFalse);
  });

  test('allows the optional label to be absent or empty', () {
    for (final label in ['', '<c:Libelle/>']) {
      expect(parser.parseXml(envelope(result('00', label: label))).label, isNull);
    }
  });

  test('recognizes a default result namespace independently of prefix spelling', () {
    final response = parser.parseXml(envelope('''
<ResultatUnitaire xmlns="$resultNs"><CrUnitaire>
<CR xmlns="$common"><Code>00</Code></CR>
</CrUnitaire></ResultatUnitaire>'''));
    expect(response.isVerified, isTrue);
  });

  test('preserves a SOAP technical failure without interpreting it as 01', () {
    final response = parser.parseXml(envelope('<s:Fault>$faultContent</s:Fault>'));
    expect(response.status, PatientFrInsiVerificationStatus.technicalError);
    expect(response.isVerified, isFalse);
    expect(response.isFault, isTrue);
    expect(response.codeCr, isNull);
    expect(response.soapCode, 's:Receiver');
    expect(response.soapSubcode, 'insi:indisponible');
    expect(response.label, 'Service temporairement indisponible');
  });

  test('an embedded technical fault takes precedence over a surrounding 00', () {
    final response = parser.parseXml(envelope(result('00', extra:
      '<r:SiSoapFaultUnitaire>$faultContent</r:SiSoapFaultUnitaire>')));
    expect(response.isFault, isTrue);
    expect(response.isVerified, isFalse);
    expect(response.codeCr, isNull);
  });

  test('rejects unknown or missing business codes', () {
    for (final code in ['', '02', '0', 'OK']) {
      expect(() => parser.parseXml(envelope(result(code))), throwsFormatException);
    }
    expect(() => parser.parseXml(envelope(result('00').replaceAll(
      '<c:Code>00</c:Code>', ''))), throwsFormatException);
  });

  test('rejects duplicate business values, reports, results and SOAP bodies', () {
    final valid = result('00');
    for (final body in [
      valid.replaceAll('<c:Code>00</c:Code>', '<c:Code>00</c:Code><c:Code>01</c:Code>'),
      valid.replaceAll('</r:CrUnitaire>', '<c:CR><c:Code>00</c:Code></c:CR></r:CrUnitaire>'),
      '$valid$valid',
      '$valid<s:Fault>$faultContent</s:Fault>',
    ]) {
      expect(() => parser.parseXml(envelope(body)), throwsFormatException);
    }
    expect(() => parser.parseXml(envelope(valid).replaceAll('</s:Body>',
      '</s:Body><s:Body/>')), throwsFormatException);
  });

  test('rejects missing containers and unexpected namespaces', () {
    final valid = envelope(result('00'));
    for (final invalid in [
      envelope(''),
      valid.replaceAll(resultNs, 'urn:other-result'),
      valid.replaceAll(common, 'urn:other-report'),
      valid.replaceAll(soap, 'http://schemas.xmlsoap.org/soap/envelope/'),
      envelope('<r:ResultatUnitaire/>'),
      envelope('<r:ResultatUnitaire><r:CrUnitaire/></r:ResultatUnitaire>'),
      valid.replaceAll('<c:Code>00</c:Code>', '<Code>00</Code>'),
      valid.replaceAll('<c:Code>00</c:Code>', '<c:Code>00</c:Code><Code>01</Code>'),
    ]) {
      expect(() => parser.parseXml(invalid), throwsFormatException);
    }
  });

  test('does not accept search RESULTAT or a result placed only in the header', () {
    expect(() => parser.parseXml(envelope(
      '<RESULTAT xmlns="http://www.cnamts.fr/INSiResultat"><CR><CodeCR>00</CodeCR></CR></RESULTAT>')),
      throwsFormatException);
    expect(() => parser.parseXml(envelope('',
      header: '<s:Header>${result('00')}</s:Header>')), throwsFormatException);
    final response = parser.parseXml(envelope(result('01'),
      header: '<s:Header>${result('00')}</s:Header>'));
    expect(response.isVerified, isFalse);
  });

  test('rejects incomplete faults and XML markup masquerading as a code', () {
    for (final content in [
      '<s:Code><s:Value>s:Receiver</s:Value></s:Code>',
      '<s:Code><s:Value/></s:Code><s:Reason><s:Text>Erreur</s:Text></s:Reason>',
    ]) {
      expect(() => parser.parseXml(envelope('<s:Fault>$content</s:Fault>')),
        throwsFormatException);
    }
    expect(() => parser.parseXml(envelope(result('<c:Other>00</c:Other>'))),
      throwsFormatException);
  });

  test('rejects DTD/entity declarations and malformed XML', () {
    expect(() => parser.parseXml('<!DOCTYPE Envelope>${envelope(result('00'))}'),
      throwsFormatException);
    expect(() => parser.parseXml('<!ENTITY test "00">${envelope(result('00'))}'),
      throwsFormatException);
    expect(() => parser.parseXml('<s:Envelope>'), throwsA(anything));
  });
}
