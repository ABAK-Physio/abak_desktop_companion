import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_message_id_builder.dart';

void main() {
  const builder = PatientFrInsiMessageIdBuilder();

  test('build creates WS-Addressing MessageID', () {
    final xml = builder.build(
      'e451e702-85aa-4c55-a083-7f02da22cc40',
    );

    final root = XmlDocument.parse(xml).rootElement;

    expect(root.name.local, 'MessageID');
    expect(
      root.name.namespaceUri,
      'http://www.w3.org/2005/08/addressing',
    );
    expect(
      root.innerText,
      'e451e702-85aa-4c55-a083-7f02da22cc40',
    );
  });

  test('build trims MessageID', () {
    final xml = builder.build('  test-message-id  ');

    final root = XmlDocument.parse(xml).rootElement;

    expect(root.innerText, 'test-message-id');
  });

  test('build rejects empty MessageID', () {
    expect(
          () => builder.build('   '),
      throwsArgumentError,
    );
  });
}