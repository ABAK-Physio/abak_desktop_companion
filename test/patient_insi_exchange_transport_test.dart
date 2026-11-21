import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_insi_exchange.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_exchange_transport.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_retrieval_service.dart';

class _StreamClient extends http.BaseClient {
  _StreamClient(this.body, this.status);
  final Stream<List<int>> body;
  final int status;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
    http.StreamedResponse(body, status);
}

void main() {
  const soap = 'http://www.w3.org/2003/05/soap-envelope';
  const fault = '''
<s:Envelope xmlns:s="$soap"><s:Body><s:Fault>
<s:Code><s:Value>s:Receiver</s:Value></s:Code>
<s:Reason><s:Text xml:lang="fr">Indisponibilité de test</s:Text></s:Reason>
</s:Fault></s:Body></s:Envelope>''';

  String reply(String code) => '''
<s:Envelope xmlns:s="$soap"><s:Body>
<r:ResultatUnitaire xmlns:r="http://www.cnamts.fr/INSiLot2/REPUnitaire"
    xmlns:c="http://www.cnamts.fr/MRA/CommunLot">
<r:CrUnitaire><c:CR><c:Code>$code</c:Code></c:CR></r:CrUnitaire>
</r:ResultatUnitaire></s:Body></s:Envelope>''';

  http.Request message() => http.Request('POST', Uri.parse('https://example.invalid/lps'))
    ..headers['Content-Type'] = 'application/soap+xml; charset=UTF-8'
    ..body = '<requete>Échange de test</requete>';

  InsiVerificationResponse interpret(InsiExchange e) =>
    PatientInsiRetrievalService.readVerificationResponse(e, '899700870597');

  test('a SOAP fault keeps HTTP and exact XML, then exports all three files', () async {
    final captured = <InsiExchange>[];
    final client = MockClient((_) async => http.Response(fault, 500,
      headers: {'content-type': 'application/soap+xml; charset=utf-8'}));
    addTearDown(client.close);
    final request = message();
    await expectLater(PatientInsiExchangeTransport(client: client).send(
      id: 'fault-attempt', message: request, interpret: interpret,
      retainExchange: (e) async { captured.add(e); },
    ), throwsStateError);
    final evidence = captured.single;
    expect(evidence.httpStatus, 500);
    expect(evidence.responseXml, fault);
    expect(evidence.requestXml, request.body);
    expect(evidence.failure, contains('faute SOAP'));
    expect(request.followRedirects, isFalse);
    final directory = await Directory.systemTemp.createTemp('insi_fault_evidence_');
    try {
      await InsiExchange.export(evidence.toMap(), directory.path, 'Test_3.03_cas_1');
      expect(await directory.list().length, 3);
      expect(await File('${directory.path}/Test_3.03_cas_1_REQUETE.xml').readAsString(),
        request.body);
      expect(await File('${directory.path}/Test_3.03_cas_1_REPONSE.xml').readAsString(), fault);
      final diagnostic = await File('${directory.path}/Test_3.03_cas_1_DIAGNOSTIC.txt').readAsString();
      expect(diagnostic, contains('HTTP : 500'));
      expect(diagnostic, contains('Réponse : conservée'));
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('both 00 and 01 return only after their evidence has been retained', () async {
    for (final code in ['00', '01']) {
      final captured = <InsiExchange>[];
      final xml = reply(code);
      final client = MockClient((_) async => http.Response(xml, 200,
        headers: {'content-type': 'application/soap+xml; charset=utf-8'}));
      addTearDown(client.close);
      final result = await PatientInsiExchangeTransport(client: client).send(
        id: 'attempt-$code', message: message(), interpret: interpret,
        retainExchange: (e) async { captured.add(e); },
      );
      expect(result.result.codeCr, code);
      expect(captured.single.httpStatus, 200);
      expect(captured.single.responseXml, xml);
      expect(captured.single.failure, isNull);
    }
  });

  test('an interpretation error still keeps the received status and payload', () async {
    final captured = <InsiExchange>[];
    const invalid = '<not-a-verification-result/>';
    final client = MockClient((_) async => http.Response(invalid, 200));
    addTearDown(client.close);
    await expectLater(PatientInsiExchangeTransport(client: client).send(
      id: 'invalid', message: message(), interpret: interpret,
      retainExchange: (e) async { captured.add(e); },
    ), throwsFormatException);
    expect(captured.single.httpStatus, 200);
    expect(captured.single.responseXml, invalid);
    expect(captured.single.failure, 'Réponse INSi illisible.');
  });

  test('network failure before headers records no invented response or exception secrets', () async {
    final captured = <InsiExchange>[];
    final client = MockClient((_) async { throw http.ClientException('sensitive internals'); });
    addTearDown(client.close);
    await expectLater(PatientInsiExchangeTransport(client: client).send(
      id: 'network', message: message(), interpret: interpret,
      retainExchange: (e) async { captured.add(e); },
    ), throwsA(isA<http.ClientException>()));
    expect(captured.single.httpStatus, isNull);
    expect(captured.single.responseXml, isNull);
    expect(captured.single.failure, isNot(contains('sensitive')));
  });

  test('a timeout during body reception preserves the already received HTTP status', () async {
    final body = StreamController<List<int>>();
    addTearDown(body.close);
    final captured = <InsiExchange>[];
    final client = _StreamClient(body.stream, 500);
    addTearDown(client.close);
    await expectLater(PatientInsiExchangeTransport(client: client,
      timeout: const Duration(milliseconds: 100)).send(
      id: 'partial', message: message(), interpret: interpret,
      retainExchange: (e) async { captured.add(e); },
    ), throwsA(isA<TimeoutException>()));
    expect(captured.single.httpStatus, 500);
    expect(captured.single.responseXml, isNull);
    expect(captured.single.failure, contains('délai dépassé'));
  });

  test('oversized bodies are refused without losing the HTTP status', () async {
    final captured = <InsiExchange>[];
    final client = MockClient((_) async => http.Response('A' * (2 * 1024 * 1024 + 1), 200));
    addTearDown(client.close);
    await expectLater(PatientInsiExchangeTransport(client: client).send(
      id: 'oversized', message: message(), interpret: interpret,
      retainExchange: (e) async { captured.add(e); },
    ), throwsStateError);
    expect(captured.single.httpStatus, 200);
    expect(captured.single.responseXml, isNull);
    expect(captured.single.failure, contains('trop volumineuse'));
  });

  test('failed evidence storage prevents returning a successful verification', () async {
    final client = MockClient((_) async => http.Response(reply('00'), 200));
    addTearDown(client.close);
    await expectLater(PatientInsiExchangeTransport(client: client).send(
      id: 'archive-failure', message: message(), interpret: interpret,
      retainExchange: (_) async { throw StateError('Storage failure'); },
    ), throwsA(isA<StateError>().having((e) => e.message, 'message', contains('preuves'))));
  });
}
