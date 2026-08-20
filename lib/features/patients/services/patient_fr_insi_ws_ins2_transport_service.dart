import 'package:http/http.dart' as http;

class PatientFrInsiWsIns2TransportService {
  PatientFrInsiWsIns2TransportService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  static final Uri endpoint = Uri.parse(
    'https://qualiflps.services-ps.ameli.fr/lps',
  );

  static const String action =
      'urn:ServiceIdentiteCertifiee:1.0.0:rechercherInsAvecTraitsIdentite';

  final http.Client _client;

  Future<http.Response> send({
    required String envelopeXml,
  }) {
    return _client.post(
      endpoint,
      headers: {
        'Content-Type':
        'application/soap+xml; charset=utf-8; action="$action"',
      },
      body: envelopeXml,
    );
  }

  void close() {
    _client.close();
  }
}