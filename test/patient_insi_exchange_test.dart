import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_exchange.dart';

void main() {
  late Directory directory;
  setUp(() async => directory = await Directory.systemTemp.createTemp('insi_xml_'));
  tearDown(() async => directory.delete(recursive: true));

  Map<String, dynamic> evidence({String? response, String? failure}) =>
      InsiExchange(
        id: 'attempt-1',
        requestXml: '<?xml version="1.0"?><requete>Élodie</requete>',
        responseXml: response,
        failure: failure,
        httpStatus: response == null ? null : 500,
        recordedAt: DateTime.utc(2026, 11, 20),
      ).toMap();

  test('exports exact request and SOAP fault without XML rewriting', () async {
    const fault = '<soap:Fault xmlns:soap="urn:test">échec</soap:Fault>';
    final data = evidence(response: fault, failure: 'Refus SOAP');
    await InsiExchange.export(data, directory.path, 'Test_1.03_cas_1');
    expect(await File('${directory.path}/Test_1.03_cas_1_REQUETE.xml').readAsString(), data['requestXml']);
    expect(await File('${directory.path}/Test_1.03_cas_1_REPONSE.xml').readAsString(), fault);
  });

  test('network failure exports request and diagnostic without invented response', () async {
    await InsiExchange.export(evidence(failure: 'Délai dépassé'), directory.path, 'Test_1.01');
    expect(await File('${directory.path}/Test_1.01_REPONSE.xml').exists(), isFalse);
    expect(await File('${directory.path}/Test_1.01_DIAGNOSTIC.txt').readAsString(), contains('Délai dépassé'));
  });

  test('refuses altered evidence before writing', () async {
    final data = evidence()..['requestXml'] = '<altered/>';
    await expectLater(InsiExchange.export(data, directory.path, 'Test_1.01'), throwsStateError);
    expect(await directory.list().toList(), isEmpty);
  });

  test('refuses overwrite and rolls back only files created by this export', () async {
    final existing = File('${directory.path}/Test_1.01_REPONSE.xml');
    await existing.writeAsString('preuve précédente');
    await expectLater(InsiExchange.export(evidence(response: '<response/>'), directory.path, 'Test_1.01'), throwsStateError);
    expect(await existing.readAsString(), 'preuve précédente');
    expect(await File('${directory.path}/Test_1.01_REQUETE.xml').exists(), isFalse);
  });

  test('refuses path traversal in test labels', () async {
    await expectLater(InsiExchange.export(evidence(), directory.path, '../Test_1.01'), throwsStateError);
    expect(await directory.list().toList(), isEmpty);
  });
}
