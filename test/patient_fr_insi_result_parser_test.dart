import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/models/patient_fr_insi_result.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_result_parser.dart';

void main() {
  const parser = PatientFrInsiResultParser();

  test('builds a successful INSi result', () {
    final result = parser.parse(
      codeCr: '00',
      insNumber: '1810163220751',
      insKey: '42',
      insOid: '1.2.250.1.213.1.4.8',
      birthLastName: 'ADRDEUX',
      birthFirstNames: 'LAURENT',
      birthDate: '1981-01-01',
      sexCode: 'M',
      birthPlaceCode: '75056',
    );

    expect(result.status, PatientFrInsiResultStatus.success);
    expect(result.insNumber, '1810163220751');
    expect(result.insKey, '42');
    expect(result.insOid, '1.2.250.1.213.1.4.8');
    expect(result.birthLastName, 'ADRDEUX');
    expect(result.birthFirstNames, 'LAURENT');
    expect(result.birthDate, '1981-01-01');
    expect(result.sexCode, 'M');
    expect(result.birthPlaceCode, '75056');
  });

  test('builds a notFound result without identity', () {
    final result = parser.parse(
      codeCr: '01',
    );

    expect(result.status, PatientFrInsiResultStatus.notFound);
    expect(result.insNumber, isNull);
  });

  test('builds an ambiguous result without identity', () {
    final result = parser.parse(
      codeCr: '02',
    );

    expect(result.status, PatientFrInsiResultStatus.ambiguous);
    expect(result.insNumber, isNull);
  });
  test('parseXml maps CodeCR 00 to success', () {
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

    final result = parser.parseXml(xml);

    expect(result.status, PatientFrInsiResultStatus.success);
  });
  test('parseXml maps CodeCR 01 to notFound', () {
    const xml = '''
<RESULTAT>
  <CR>
    <CodeCR>01</CodeCR>
    <LibelleCR>Aucune INS trouvée</LibelleCR>
  </CR>
</RESULTAT>
''';

    final result = parser.parseXml(xml);

    expect(result.status, PatientFrInsiResultStatus.notFound);
  });

  test('parseXml maps CodeCR 02 to ambiguous', () {
    const xml = '''
<RESULTAT>
  <CR>
    <CodeCR>02</CodeCR>
    <LibelleCR>Plusieurs INS trouvées</LibelleCR>
  </CR>
</RESULTAT>
''';

    final result = parser.parseXml(xml);

    expect(result.status, PatientFrInsiResultStatus.ambiguous);
  });

  test('parseXml throws when CodeCR is missing', () {
    const xml = '''
<RESULTAT>
  <CR>
    <LibelleCR>Réponse invalide</LibelleCR>
  </CR>
</RESULTAT>
''';

    expect(
          () => parser.parseXml(xml),
      throwsFormatException,
    );
  });

  test('parseXml extracts INSACTIF and TIQ from successful response', () {
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
          <ns2:Prenom>LAURENT</ns2:Prenom>
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

    final result = parser.parseXml(xml);

    expect(result.status, PatientFrInsiResultStatus.success);
    expect(result.insNumber, '1810163220751');
    expect(result.insKey, '42');
    expect(result.insOid, '1.2.250.1.213.1.4.8');
    expect(result.birthLastName, 'ADRDEUX');
    expect(result.birthFirstNames, 'LAURENT');
    expect(result.birthDate, '1981-01-01');
    expect(result.sexCode, 'M');
    expect(result.birthPlaceCode, '75056');
  });

  test('parseXml throws when CodeCR 00 has no INDIVIDU', () {
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
    </ns2:RESULTAT>
  </soap:Body>
</soap:Envelope>
''';

    expect(
          () => parser.parseXml(xml),
      throwsFormatException,
    );
  });
}