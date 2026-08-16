import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/models/patient_fr_insi_result.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_response_parser.dart';

void main() {
  const parser = PatientFrInsiResponseParser();

  test('parseXml returns result for INSi RESULTAT response', () {
    const xml = '''
<soap:Envelope
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
    xmlns:ns2="http://www.cnamts.fr/INSiResultat">
  <soap:Body>
    <ns2:RESULTAT>
      <ns2:CR>
        <ns2:CodeCR>00</ns2:CodeCR>
        <ns2:LibelleCR>OK</ns2:LibelleCR>
      </ns2:CR>
      <ns2:INDIVIDU>
        <ns2:INSACTIF>
          <ns2:IdIndividu>
            <ns2:NumIdentifiant>1810163220751</ns2:NumIdentifiant>
            <ns2:Cle>42</ns2:Cle>
          </ns2:IdIndividu>
          <ns2:OID>1.2.250.1.213.1.4.8</ns2:OID>
        </ns2:INSACTIF>
        <ns2:TIQ>
          <ns2:NomNaissance>ADRDEUX</ns2:NomNaissance>
          <ns2:ListePrenom>LAURENT</ns2:ListePrenom>
          <ns2:Sexe>M</ns2:Sexe>
          <ns2:DateNaissance>1981-01-01</ns2:DateNaissance>
          <ns2:LieuNaissance>75056</ns2:LieuNaissance>
        </ns2:TIQ>
      </ns2:INDIVIDU>
    </ns2:RESULTAT>
  </soap:Body>
</soap:Envelope>
''';

    final response = parser.parseXml(xml);

    expect(response.isResult, isTrue);
    expect(response.isFault, isFalse);
    expect(
      response.result?.status,
      PatientFrInsiResultStatus.success,
    );
    expect(response.result?.insNumber, '1810163220751');
  });

  test('parseXml returns fault for INSi SoapFault response', () {
    const xml = '''
<soap:Envelope
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Body>
    <soap:Fault>
      <soap:Code>
        <soap:Value>Receiver</soap:Value>
        <soap:Subcode>
          <soap:Value>siram_40</soap:Value>
        </soap:Subcode>
      </soap:Code>
      <soap:Detail>
        <Code>insi_111</Code>
        <Severite>fatale</Severite>
        <Descriptif>Indisponibilité des téléservices</Descriptif>
      </soap:Detail>
    </soap:Fault>
  </soap:Body>
</soap:Envelope>
''';

    final response = parser.parseXml(xml);

    expect(response.isResult, isFalse);
    expect(response.isFault, isTrue);
    expect(response.fault?.code, 'insi_111');
    expect(response.fault?.isFatal, isTrue);
  });

  test('parseXml throws when response contains neither RESULTAT nor Fault', () {
    const xml = '''
<soap:Envelope
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Body>
    <UnexpectedResponse />
  </soap:Body>
</soap:Envelope>
''';

    expect(
          () => parser.parseXml(xml),
      throwsFormatException,
    );
  });
}