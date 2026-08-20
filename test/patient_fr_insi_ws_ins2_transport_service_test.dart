import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ws_ins2_transport_service.dart';

void main() {
  test('send posts SOAP 1.2 WS_INS2 request to qualification endpoint', () async {
    const envelopeXml = '<soap:Envelope>TEST</soap:Envelope>';

    late http.Request capturedRequest;

    final client = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        '<soap:Envelope>RESPONSE</soap:Envelope>',
        200,
        headers: {
          'content-type': 'application/soap+xml; charset=utf-8',
        },
      );
    });

    final service = PatientFrInsiWsIns2TransportService(
      client: client,
    );

    final response = await service.send(
      envelopeXml: envelopeXml,
    );

    expect(
      capturedRequest.method,
      'POST',
    );

    expect(
      capturedRequest.url,
      PatientFrInsiWsIns2TransportService.endpoint,
    );

    expect(
      capturedRequest.headers['Content-Type'],
      'application/soap+xml; charset=utf-8; '
          'action="${PatientFrInsiWsIns2TransportService.action}"',
    );

    expect(
      capturedRequest.body,
      envelopeXml,
    );

    expect(
      response.statusCode,
      200,
    );

    expect(
      response.body,
      '<soap:Envelope>RESPONSE</soap:Envelope>',
    );

    service.close();
  });
}