import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/transfer_simulation.dart';
import 'package:abak_desktop_companion/features/dmp_transfer/archive_deposit_reader.dart';

/// Test-only, local HMAC, deliberately NOT a CPS/XAdES implementation.
class Ports implements DocumentDmpPorts {
  Ports(this.repo, this.now);
  final String repo;
  final DateTime Function() now;
  String scenario = 'accepted';
  TlsFailure? tls;
  int calls = 0, policyCalls = 0;
  List<String> order = [];
  DmpPreparedSubmission? sent;
  Future<void> Function()? atDeposit, atConnect;
  String fingerprint = 'a' * 64;
  @override
  Future<DmpSession> authenticate(Map<String, dynamic> snapshot) async {
    order.add('auth');
    if (scenario == 'auth_error') throw StateError('PIN SECRET MUST NOT LEAK');
    final c = jsonDecode(snapshot['practice']['data_json']);
    return DmpSession(
      id: 'SYN-SESSION',
      professional: scenario == 'wrong_professional'
          ? 'WRONG'
          : c['identifier'],
      authority: c['authority'],
      structure: scenario == 'wrong_structure' ? 'OTHER' : c['structureId'],
      certificateHash: fingerprint,
      contextHash: medicalHash(snapshot['practice']),
      issuedAt: now().subtract(const Duration(minutes: 1)),
      expiresAt: now().add(Duration(minutes: scenario == 'expired' ? -1 : 10)),
    );
  }

  @override
  Future<bool> sessionCurrent(DmpSession session) async =>
      scenario != 'session_changed';
  @override
  Future<DmpPolicy> policy(Map<String, dynamic> snapshot) async {
    order.add('policy');
    policyCalls++;
    final d = jsonDecode(snapshot['preparation']['data_json']);
    return DmpPolicy(
      snapshotHash: scenario == 'wrong_policy'
          ? 'other'
          : medicalHash(snapshot),
      catalogReference: scenario == 'catalog' ? '' : d['catalogReference'],
      expiresAt: DateTime.utc(2026, 10, 17, 13),
      opposition:
          scenario == 'opposition' ||
          (scenario == 'policy_changed' && policyCalls > 1),
      functionalRights: scenario == 'unknown_rights'
          ? null
          : scenario != 'rights',
      authorRights: scenario != 'author',
      visibilityAllowed: scenario != 'visibility',
      codesValid: scenario != 'codes',
    );
  }

  @override
  Future<DmpTd02Reply> td02(String request, DmpSession s) async {
    order.add('td02');
    final q = XmlDocument.parse(request);
    final query = q.descendants.whereType<XmlElement>().firstWhere(
      (e) => e.name.local == 'queryId',
    );
    final body = q.descendants.whereType<XmlElement>().firstWhere(
      (e) => e.name.local == 'PRPA_IN201307UV02',
    );
    final msg = body.childElements.firstWhere((e) => e.name.local == 'id');
    final value = q.descendants.whereType<XmlElement>().firstWhere(
      (e) => e.name.local == 'value',
    );
    final message = q.descendants
        .whereType<XmlElement>()
        .firstWhere((e) => e.name.local == 'MessageID')
        .innerText;
    var xml =
        '<s:Envelope xmlns:s="${Td02Reader.soap}" xmlns:w="${Td02Reader.wsa}"><s:Header>'
        '<w:Action>urn:hl7-org:v3:PRPA_IN201308UV02</w:Action><w:RelatesTo>${scenario == 'uncorrelated_td' ? 'other' : message}</w:RelatesTo>'
        '</s:Header><s:Body><PRPA_IN201308UV02 xmlns="${Td02Reader.hl7}">'
        '<attentionLine><keyWordText code="AUTORISATION"/><value code="${scenario == 'consultation_absent' ? 'NON_EXISTE' : 'VALIDE'}"/></attentionLine>'
        '<acknowledgement typeCode="AA"><targetMessage>${msg.toXmlString()}</targetMessage></acknowledgement>'
        '<controlActProcess><queryAck>${query.toXmlString()}<queryResponseCode code="${scenario == 'absent' ? 'NF' : 'OK'}"/></queryAck>'
        '${scenario == 'absent' ? '' : '<subject><registrationEvent><subject1><patient><id root="${value.getAttribute('root')}" extension="${scenario == 'wrong_patient' ? 'WRONG' : value.getAttribute('extension')}"/><statusCode code="${scenario == 'closed' ? 'terminated' : 'active'}"/></patient></subject1></registrationEvent></subject>'}'
        '</controlActProcess></PRPA_IN201308UV02></s:Body></s:Envelope>';
    if (scenario == 'soap') {
      xml =
          '<s:Envelope xmlns:s="${Td02Reader.soap}"><s:Body><s:Fault/></s:Body></s:Envelope>';
    }
    if (scenario == 'xml') xml = '<bad';
    return DmpTd02Reply(scenario == '503' ? 503 : 200, xml);
  }

  String mac(DmpPreparedSubmission p) => base64Encode(
    Hmac(
      sha256,
      utf8.encode('SYNTHETIC-TEST-KEY-NOT-CPS'),
    ).convert(p.bytes).bytes,
  );
  @override
  Future<DmpSignature> sign(DmpPreparedSubmission p, DmpSession s) async {
    order.add('sign');
    if (scenario == 'signature_error') throw StateError('CPS FAKE NO CARD');
    return DmpSignature(
      packageHash: scenario == 'wrong_payload' ? 'other' : p.hash,
      certificateHash: scenario == 'wrong_cert' ? 'b' * 64 : s.certificateHash,
      value: scenario == 'bad_signature' ? 'tampered' : mac(p),
      format: 'simulation',
    );
  }

  @override
  Future<bool> verifySignature(
    DmpPreparedSubmission p,
    DmpSignature sig,
    DmpSession s,
  ) async {
    order.add('verify');
    return sig.value == mac(p);
  }

  @override
  Future<TlsFailure?> connect(DmpSession s) async {
    order.add('tls');
    await atConnect?.call();
    return tls;
  }

  @override
  Future<DmpHttpReply> deposit(
    DmpPreparedSubmission p,
    DmpSignature sig,
    DmpSession s,
  ) async {
    order.add('deposit');
    calls++;
    sent = p;
    await atDeposit?.call();
    if (scenario == 'timeout') throw StateError('timeout');
    final message = XmlDocument.parse(p.request).descendants
        .whereType<XmlElement>()
        .firstWhere((e) => e.name.local == 'MessageID')
        .innerText;
    if (scenario.startsWith('archive_')) {
      final kind = scenario.substring(8).split('_').first;
      final base = '$repo/assets/dmp_local/deposit_replay/$kind';
      final original = await File('$base-response.bin').readAsBytes();
      final req = await File('$base-request.xml').readAsString();
      final old = XmlDocument.parse(req).descendants
          .whereType<XmlElement>()
          .firstWhere((e) => e.name.local == 'MessageID')
          .innerText;
      final bytes = scenario.endsWith('_unchanged')
          ? original
          : latin1.encode(latin1.decode(original).replaceAll(old, message));
      return DmpHttpReply(
        await File('$base-headers.txt').readAsString(),
        bytes,
        provenance:
            'Archive $kind SHA256 ${sha256.convert(original)} ; ${scenario.endsWith('_unchanged') ? 'inchangée' : 'copie de test : seul RelatesTo adapté à la requête synthétique'}',
      );
    }
    var response =
        '<s:Envelope xmlns:s="${Td02Reader.soap}" xmlns:w="${Td02Reader.wsa}"><s:Header>'
        '<w:Action>${ArchiveDepositReader.action}</w:Action><w:RelatesTo>${scenario == 'uncorrelated' ? 'wrong' : message}</w:RelatesTo>'
        '</s:Header><s:Body><RegistryResponse xmlns="${ArchiveDepositReader.rs}" status="${ArchiveDepositReader.statusPrefix}Success"/></s:Body></s:Envelope>';
    if (scenario == 'malformed') response = '<invalid';
    return DmpHttpReply(
      'HTTP/1.1 ${scenario == 'redirect' ? '302 Found' : '200 OK'}\r\nContent-Type: application/soap+xml',
      utf8.encode(response),
    );
  }
}
