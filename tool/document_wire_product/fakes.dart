import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:xml_crypto/xml_crypto.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/crypto.dart';
import '../document_chain_product/fakes.dart';

class WirePorts extends Ports implements DocumentDmpWirePorts {
  WirePorts(super.repo, super.now, this.certificates) {
    fingerprint = DmpWireCertificate.parse(der('auth')).hash;
  }
  final String certificates;
  int materialCalls = 0;
  Map<String, dynamic>? authenticatedSnapshot;
  @override
  Future<DmpSession> authenticate(Map<String, dynamic> snapshot) async {
    authenticatedSnapshot = jsonDecode(jsonEncode(snapshot));
    return super.authenticate(snapshot);
  }

  @override
  Future<DmpHttpReply> deposit(
    DmpPreparedSubmission p,
    DmpSignature signature,
    DmpSession s,
  ) async {
    // Simulated receiver consumes the complete MIME packet. It cannot accept a
    // legacy draft or silently discard the attachment/signature envelope.
    DmpWireDraft.verifyArchived(p.evidence, authenticatedSnapshot!, s.evidence);
    return super.deposit(p, signature, s);
  }

  String der(String name) =>
      base64Encode(File('$certificates/$name.der').readAsBytesSync());
  @override
  Future<DmpWireMaterial> wireMaterial(DmpSession session) async {
    materialCalls++;
    final kind =
        ['wrong', 'expired', 'future', 'no_usage', 'revoked'].contains(scenario)
        ? scenario
        : 'sign';
    final report = jsonDecode(
      File('$certificates/assessment.json').readAsStringSync(),
    );
    return DmpWireMaterial(
      configuration: DmpWireConfiguration(
        endpoint: 'https://synthetic.invalid/DocumentRepository',
        sourceId: '2.25.1234567890123456789',
        lpsId: 'SYN-INSTALLATION',
        lpsName: 'ABAK SYNTHETIC',
        lpsVersion: scenario == 'configuration_changed' && materialCalls > 1
            ? 'changed'
            : 'SYN-1',
        homologationId: scenario == 'missing_configuration'
            ? ''
            : 'SYN-NOT-HOMOLOGATED',
      ),
      authenticationDer: der('auth'),
      signingDer: der(kind),
      authenticationHash: fingerprint,
      signingHash: scenario == 'unbound_certificate'
          ? 'b' * 64
          : report[kind]['sha256'],
      professional: '12345678901',
      assessmentId: 'SYNTHETIC-CA-CRL-ASSESSMENT',
      assessedAt: DateTime.utc(2026, 10, 17, 11, 59),
      validUntil: DateTime.utc(2026, 10, 17, 12, 10),
      trustedAndNotRevoked:
          report[kind]['chain'] &&
          !report[kind]['revoked'] &&
          scenario != 'untrusted' &&
          !(scenario == 'revoked_after_reservation' && materialCalls >= 3),
    );
  }

  @override
  Future<String> signCanonicalXml(
    String signedInfo,
    String certificateHash,
    DmpSession session,
  ) async {
    order.add('xades');
    if (scenario == 'signature_error') {
      throw StateError('TEST SECRET MUST NOT LEAK');
    }
    if (scenario == 'bad_signature') return base64Encode(List.filled(256, 0));
    final key = File(
      '$certificates/${scenario == 'wrong_key' ? 'auth' : 'sign'}-key.pem',
    ).readAsBytesSync();
    return SignedXml.signatureAlgorithms[DmpWireCrypto.rsa]!.getSignature(
      signedInfo,
      Uint8List.fromList(key),
    );
  }
}
