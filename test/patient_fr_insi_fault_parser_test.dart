import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/models/patient_fr_insi_fault.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_fault_parser.dart';

void main() {
  const parser = PatientFrInsiFaultParser();

  test('parseXml extracts Sender INSi fault', () {
    const xml = '''
<soap:Envelope
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Body>
    <soap:Fault>
      <soap:Code>
        <soap:Value>Sender</soap:Value>
        <soap:Subcode>
          <soap:Value>siram_10</soap:Value>
        </soap:Subcode>
      </soap:Code>
      <soap:Detail>
        <Code>insi_19</Code>
        <Severite>erreur</Severite>
        <Descriptif>Le champ nom de naissance est obligatoire</Descriptif>
      </soap:Detail>
    </soap:Fault>
  </soap:Body>
</soap:Envelope>
''';

    final fault = parser.parseXml(xml);

    expect(fault.codeValue, 'Sender');
    expect(fault.subcode, 'siram_10');
    expect(fault.code, 'insi_19');
    expect(fault.severity, PatientFrInsiFaultSeverity.error);
    expect(
      fault.description,
      'Le champ nom de naissance est obligatoire',
    );
    expect(fault.isSender, isTrue);
    expect(fault.isReceiver, isFalse);
    expect(fault.isFatal, isFalse);
  });

  test('parseXml extracts Receiver fatal INSi fault', () {
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

    final fault = parser.parseXml(xml);

    expect(fault.codeValue, 'Receiver');
    expect(fault.subcode, 'siram_40');
    expect(fault.code, 'insi_111');
    expect(fault.severity, PatientFrInsiFaultSeverity.fatal);
    expect(
      fault.description,
      'Indisponibilité des téléservices',
    );
    expect(fault.isSender, isFalse);
    expect(fault.isReceiver, isTrue);
    expect(fault.isFatal, isTrue);
  });
}