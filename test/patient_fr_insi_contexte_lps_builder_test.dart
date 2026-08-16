import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_contexte_lps_builder.dart';

void main() {
  const builder = PatientFrInsiContexteLpsBuilder();

  test('build creates complete ContexteLPS', () {
    final xml = builder.build(
      id: 'test-message-id',
      time: DateTime.utc(2026, 8, 15, 14, 0),
      emitter: 'test-emitter',
      idam: 'test-idam',
      idamReference: '4',
      lpsVersion: '1.0.0',
      instance: 'test-instance',
      name: 'ABAK',
    );

    final document = XmlDocument.parse(xml);
    final root = document.rootElement;

    expect(root.name.local, 'ContexteLPS');
    expect(root.name.namespaceUri, 'urn:siram:lps:ctxlps');
    expect(root.getAttribute('Version'), '01_00');

    expect(root.findElements('Id').single.innerText, 'test-message-id');
    expect(
      root.findElements('Temps').single.innerText,
      '2026-08-15T14:00:00.000Z',
    );
    expect(
      root.findElements('Emetteur').single.innerText,
      'test-emitter',
    );

    final lps = root.findElements('LPS').single;

    final idam = lps.findElements('IDAM').single;
    expect(idam.innerText, 'test-idam');
    expect(idam.getAttribute('R'), '4');

    expect(
      lps.findElements('Version').single.innerText,
      '1.0.0',
    );
    expect(
      lps.findElements('Instance').single.innerText,
      'test-instance',
    );
    expect(
      lps.findElements('Nom').single.innerText,
      'ABAK',
    );
  });

  test('build creates minimal ContexteLPS', () {
    final xml = builder.build(
      id: 'minimal-id',
      time: DateTime.utc(2026, 8, 15, 14, 0),
    );

    final root = XmlDocument.parse(xml).rootElement;

    expect(root.findElements('Id').single.innerText, 'minimal-id');
    expect(root.findElements('Temps'), hasLength(1));

    expect(root.findElements('Emetteur'), isEmpty);
    expect(root.findElements('LPS'), isEmpty);
  });

  test('build converts time to UTC', () {
    final xml = builder.build(
      id: 'utc-test',
      time: DateTime.parse('2026-08-15T16:00:00+02:00'),
    );

    final root = XmlDocument.parse(xml).rootElement;

    expect(
      root.findElements('Temps').single.innerText,
      '2026-08-15T14:00:00.000Z',
    );
  });
}