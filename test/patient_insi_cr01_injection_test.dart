import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_exchange.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_cr01_injection.dart';

void main() {
  final fixture = File('test/fixtures/insi_rep_cr01.b64');
  Future<List<int>> originalBytes() async =>
      base64Decode((await fixture.readAsString()).trim());

  test('official CNDA SOAP uses the normal parser and returns no identity', () async {
    final injection = PatientInsiCr01Injection.decode(await originalBytes());
    expect(injection.result.isNotFound, isTrue);
    expect(injection.result.insNumber, isNull);
    expect(injection.result.birthLastName, isNull);
    expect(injection.xml, utf8.decode(await originalBytes()));
  });

  test('refuses a modified official response', () async {
    final bytes = await originalBytes();
    bytes[bytes.length - 1] ^= 1;
    expect(() => PatientInsiCr01Injection.decode(bytes), throwsStateError);
  });

  test('refuses arbitrary or oversized XML before parsing', () {
    expect(() => PatientInsiCr01Injection.decode('<RESULTAT/>'.codeUnits), throwsStateError);
    expect(() => PatientInsiCr01Injection.decode(List.filled(65537, 0)), throwsStateError);
  });

  test('exports injected response exactly and marks simulation without request', () async {
    final directory = await Directory.systemTemp.createTemp('insi_cr01_export_');
    try {
      final bytes = await originalBytes();
      final evidence = <String, dynamic>{
        'simulation': true,
        'networkCall': false,
        'sourceHash': PatientInsiCr01Injection.fileHash,
        'responseXml': utf8.decode(bytes),
        'eventId': 'test-event',
        'recordedAt': '2026-11-20T14:00:00Z',
      };
      await InsiExchange.exportCndaCr01(evidence, directory.path, 'Test_1.07_cas_1');
      final response = File('${directory.path}/Test_1.07_cas_1_REPONSE.xml');
      expect(await response.readAsBytes(), bytes);
      expect(await File('${directory.path}/Test_1.07_cas_1_REQUETE.xml').exists(), isFalse);
      final diagnostic = await File('${directory.path}/Test_1.07_cas_1_DIAGNOSTIC.txt').readAsString();
      expect(diagnostic, contains('SIMULATION CNDA'));
      expect(diagnostic, contains('Aucune requête émise'));
      await expectLater(InsiExchange.exportCndaCr01(evidence, directory.path, 'Test_1.07_cas_1'), throwsStateError);
      expect(await response.readAsBytes(), bytes);
      evidence['responseXml'] = '<modified/>';
      await expectLater(InsiExchange.exportCndaCr01(evidence, directory.path, 'Test_1.07_cas_2'), throwsStateError);
      expect(await File('${directory.path}/Test_1.07_cas_2_REPONSE.xml').exists(), isFalse);
    } finally {
      await directory.delete(recursive: true);
    }
  });

}
