import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_contexte_bam_builder.dart';

void main() {
  const builder = PatientFrInsiContexteBamBuilder();

  test('build creates minimal ContexteBAM with required COUVERTURE', () {
    final xml = builder.build(
      id: 'test-bam-id',
      time: DateTime.utc(2026, 8, 15, 14, 0),
    );

    final root = XmlDocument.parse(xml).rootElement;

    expect(root.name.local, 'ContexteBAM');
    expect(root.name.namespaceUri, 'urn:siram:bam:ctxbam');
    expect(root.getAttribute('Version'), '01_02');

    expect(
      root.findElements('Id').single.innerText,
      'test-bam-id',
    );

    expect(
      root.findElements('Temps').single.innerText,
      '2026-08-15T14:00:00.000Z',
    );

    final couverture = root.findElements('COUVERTURE');

    expect(couverture, hasLength(1));
    expect(couverture.single.children, isEmpty);
  });

  test('build includes optional emitter and reference date', () {
    final xml = builder.build(
      id: 'test-bam-id',
      time: DateTime.utc(2026, 8, 15, 14, 0),
      emitter: 'test-emitter',
      referenceDate: DateTime.utc(2026, 8, 15, 12, 30),
    );

    final root = XmlDocument.parse(xml).rootElement;

    expect(
      root.findElements('Emetteur').single.innerText,
      'test-emitter',
    );

    expect(
      root.findElements('DateRef').single.innerText,
      '2026-08-15T12:30:00.000Z',
    );

    expect(
      root.findElements('COUVERTURE'),
      hasLength(1),
    );
  });

  test('build converts times to UTC', () {
    final xml = builder.build(
      id: 'utc-test',
      time: DateTime.parse('2026-08-15T16:00:00+02:00'),
      referenceDate: DateTime.parse(
        '2026-08-15T15:30:00+02:00',
      ),
    );

    final root = XmlDocument.parse(xml).rootElement;

    expect(
      root.findElements('Temps').single.innerText,
      '2026-08-15T14:00:00.000Z',
    );

    expect(
      root.findElements('DateRef').single.innerText,
      '2026-08-15T13:30:00.000Z',
    );
  });
}