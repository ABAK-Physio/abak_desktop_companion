import 'dart:convert';
import '../../../dmp_transfer/transfer_simulation.dart';
import '../document_medical_service.dart';

/// Contracts for the product chain. Native implementations are explicitly injected.
/// The DV1 business entry constructs native ports; doubles require isolated storage.
class DmpSession {
  const DmpSession({
    required this.id,
    required this.professional,
    required this.authority,
    required this.structure,
    required this.certificateHash,
    required this.contextHash,
    required this.issuedAt,
    required this.expiresAt,
    this.nativeEvidenceJson,
  });
  final String id,
      professional,
      authority,
      structure,
      certificateHash,
      contextHash;
  final DateTime issuedAt, expiresAt;
  final String? nativeEvidenceJson;
  Map<String, Object?> get evidence => {
    if (nativeEvidenceJson != null) 'native': jsonDecode(nativeEvidenceJson!),
    'id': id,
    'professional': professional,
    'authority': authority,
    'structure': structure,
    'certificateHash': certificateHash,
    'contextHash': contextHash,
    'issuedAt': issuedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };
}

class DmpPolicy {
  const DmpPolicy({
    required this.snapshotHash,
    required this.catalogReference,
    required this.expiresAt,
    required this.opposition,
    required this.functionalRights,
    required this.authorRights,
    required this.visibilityAllowed,
    required this.codesValid,
  });
  final String snapshotHash, catalogReference;
  final DateTime expiresAt;
  final bool? opposition,
      functionalRights,
      authorRights,
      visibilityAllowed,
      codesValid;
  Map<String, Object?> get evidence => {
    'snapshotHash': snapshotHash,
    'catalogReference': catalogReference,
    'expiresAt': expiresAt.toIso8601String(),
    'opposition': opposition,
    'functionalRights': functionalRights,
    'authorRights': authorRights,
    'visibilityAllowed': visibilityAllowed,
    'codesValid': codesValid,
  };
}

class DmpHttpReply {
  DmpHttpReply(
    this.headers,
    List<int> bytes, {
    this.provenance = 'service simulé',
  }) : bytes = List.unmodifiable(bytes);
  final String headers, provenance;
  final List<int> bytes;
}

class DmpTd02Reply {
  const DmpTd02Reply(this.status, this.xml, {this.headers});
  final String? headers;
  final int status;
  final String xml;
}

class DmpSignature {
  const DmpSignature({
    required this.packageHash,
    required this.certificateHash,
    required this.value,
    required this.format,
  });
  final String packageHash, certificateHash, value, format;
  Map<String, Object?> get evidence => {
    'packageHash': packageHash,
    'certificateHash': certificateHash,
    'value': value,
    'format': format,
  };
}

/// Frozen inputs and optional complete, verified XDS/XAdES MIME packet.
/// Legacy contract doubles remain explicitly identified as ABAK-DMP-PORTS-1.
class DmpPreparedSubmission {
  DmpPreparedSubmission({
    required this.request,
    required this.messageId,
    required this.metadata,
    required this.vihf,
    required this.cdaHash,
    required this.snapshotHash,
    required this.sessionHash,
    Map<String, Object?>? wire,
  }) : _wire = wire == null ? null : jsonEncode(wire);
  final String? _wire;
  Map<String, dynamic>? get wire =>
      _wire == null ? null : jsonDecode(_wire) as Map<String, dynamic>;
  final String request,
      messageId,
      metadata,
      vihf,
      cdaHash,
      snapshotHash,
      sessionHash;
  Map<String, Object?> get evidence => {
    'protocol': _wire == null ? 'ABAK-DMP-PORTS-1' : 'DMP-XDS-XADES-MTOM-2.10',
    if (_wire != null) 'wire': wire,
    'request': request,
    'messageId': messageId,
    'metadata': metadata,
    'vihf': vihf,
    'cdaHash': cdaHash,
    'snapshotHash': snapshotHash,
    'sessionHash': sessionHash,
  };
  List<int> get bytes => utf8.encode(medicalCanonical(evidence));
  String get hash => medicalHash(evidence);
}

abstract interface class DocumentDmpPorts {
  Future<DmpSession> authenticate(Map<String, dynamic> snapshot);
  Future<bool> sessionCurrent(DmpSession session);
  Future<DmpPolicy> policy(Map<String, dynamic> snapshot);
  Future<DmpTd02Reply> td02(String request, DmpSession session);
  Future<DmpSignature> sign(DmpPreparedSubmission package, DmpSession session);
  Future<bool> verifySignature(
    DmpPreparedSubmission package,
    DmpSignature signature,
    DmpSession session,
  );
  Future<TlsFailure?> connect(DmpSession session);
  Future<DmpHttpReply> deposit(
    DmpPreparedSubmission package,
    DmpSignature signature,
    DmpSession session,
  );
}

class DmpChainBlock implements Exception {
  const DmpChainBlock(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Optional full native TD0.2 assembly; legacy contract doubles stay separate.
abstract interface class DocumentDmpTd02Ports {
  Future<String> prepareTd02(
    Map<String, dynamic> snapshot,
    DmpSession session,
    DateTime time,
  );
}

abstract interface class DocumentDmpSessionLifecycle {
  Future<void> closeSession();
}
