import 'td33c.dart';
import 'dv1_replacement.dart';
import 'package:xml/xml.dart';
import 'td31b.dart';
import 'authentication_cache.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import '../../../../cps/cps_access_service.dart';
import '../../../../cps/cps_profile.dart';
import '../../../../cps/cps_operation_lease.dart';
import '../../../../practitioners/data/practitioner_cps_service.dart';
import '../../../../dmp_transfer/transfer_simulation.dart';
import '../../document_medical_service.dart';
import '../contracts.dart';
import '../wire/package.dart';
import '../wire/crypto.dart';
import 'bridge.dart';
import 'access_context.dart';
import 'td02.dart';
import 'td03.dart';

/// Explicit configuration. Only a confirmed business action opens a session.
/// Trust bundle is a PEM concatenation of roots/intermediates/CRLs, pinned by hash.
class DmpNativeConfiguration {
  const DmpNativeConfiguration({
    required this.wire,
    required this.td02Endpoint,
    required this.processingMode,
    required this.libraryPath,
    required this.trustPath,
    required this.trustHash,
    required this.authenticationHash,
    required this.signingHash,
    required this.situationNumber,
    required this.situationMode,
    required this.situationStatus,
    required this.situationSector,
  });
  final DmpWireConfiguration wire;
  final String td02Endpoint,
      processingMode,
      libraryPath,
      trustPath,
      trustHash,
      authenticationHash,
      signingHash,
      situationSector;
  final int situationNumber, situationMode, situationStatus;
  void check() {
    wire.check();
    final u = Uri.tryParse(td02Endpoint);
    if (u == null ||
        u.scheme != 'https' ||
        u.host.isEmpty ||
        u.path.isEmpty ||
        u.hasQuery ||
        u.hasFragment ||
        u.userInfo.isNotEmpty ||
        !['T', 'P'].contains(processingMode) ||
        !libraryPath.startsWith('/') ||
        !trustPath.startsWith('/') ||
        [
          trustHash,
          authenticationHash,
          signingHash,
        ].any((s) => !RegExp(r'^[0-9a-f]{64}$').hasMatch(s)) ||
        authenticationHash == signingHash ||
        situationNumber < 1 ||
        situationNumber > 16 ||
        situationSector.isEmpty) {
      throw DmpNativeFailure('CONFIGURATION');
    }
  }

  Map<String, String> get fields => {
    'tdEndpoint': td02Endpoint,
    'depositEndpoint': wire.endpoint,
    'library': libraryPath,
    'trustPath': trustPath,
    'trustHash': trustHash,
    'authHash': authenticationHash,
    'signHash': signingHash,
  };
}

typedef CpsProfileReader =
    Future<CpsProfile> Function(String pin, CpsOperationLease lease);

class DocumentDmpNativePorts
    implements
        DocumentDmpWirePorts,
        DocumentDmpTd02Ports,
        DocumentDmpSessionLifecycle {
  DocumentDmpNativePorts({
    required this.configuration,
    required this.bridge,
    required this.requestPin,
    required this.readPolicy,
    required this.now,
    this.provenance = 'Interface native ; environnement du banc isolé',
    this.accessContext,
    this.depublicationUniqueId,
    this.releaseResources,
    this.checkWorkContext,
    this.authenticationCache,
    this.authenticationKey,
    CpsProfileReader? readProfile,
  }) : readProfile =
           readProfile ??
           ((pin, lease) => const CpsAccessService().read(pin, lease: lease));
  final Dv1AccessContext? accessContext;
  final String? depublicationUniqueId;
  bool _depublicationUsed = false;
  final void Function()? checkWorkContext;
  void _checkWorkContext() {
    try {
      checkWorkContext?.call();
    } on StateError catch (e) {
      throw DmpChainBlock(e.message.toString());
    }
  }

  Future<void> Function()? releaseResources;
  final CpsAuthenticationCache? authenticationCache;
  final String? authenticationKey;
  bool retainAuthentication = false, authenticationRetained = false;
  CpsProfile? _authenticationProfile;
  DateTime? _authenticationExpires;
  final String provenance;
  final DmpNativeConfiguration configuration;
  DmpNativeBridge bridge;
  final Future<String?> Function() requestPin;
  final Future<DmpPolicy> Function(Map<String, dynamic>) readPolicy;
  final DateTime Function() now;
  final CpsProfileReader readProfile;
  CpsOperationLease? _lease;
  DmpSession? _session;
  DmpWireMaterial? _material;
  String? _snapshot, _tdRequest, _signedInfo, _signature;
  String? _replacementUniqueId;
  bool _closeFailed = false;
  bool _opening = false, _tdUsed = false, _depositUsed = false, _closed = false;
  void _check(DmpSession s) {
    _checkWorkContext();
    if (_closed ||
        _session == null ||
        !_lease!.active ||
        medicalHash(s.evidence) != medicalHash(_session!.evidence) ||
        now().isBefore(s.issuedAt) ||
        !now().isBefore(s.expiresAt)) {
      throw DmpNativeFailure('SESSION');
    }
  }

  @override
  Future<DmpSession> authenticate(Map<String, dynamic> snapshot) async {
    if (_opening || _session != null || _closed) {
      throw DmpNativeFailure('CPS_BUSY');
    }
    _opening = true;
    var stage = 'CONFIGURATION';
    try {
      _checkWorkContext();
      configuration.check();
      if (accessContext != null) {
        accessContext!.check(now().toUtc());
        if (configuration.td02Endpoint != Dv1AccessContext.endpoint ||
            configuration.processingMode != 'T' ||
            medicalCanonical(snapshot) !=
                medicalCanonical(accessContext!.snapshot)) {
          throw DmpNativeFailure('CONFIGURATION');
        }
      }
      if (accessContext == null) {
        final data = jsonDecode(snapshot['preparation']['data_json']) as Map;
        _replacementUniqueId =
            Dv1Replacement.fromPreparation(data)?['uniqueId'] as String?;
      }
      stage = 'CONTEXT';
      final c = jsonDecode(snapshot['practice']['data_json']);
      String? pin = await requestPin();
      if (pin == null) throw DmpNativeFailure('CANCELLED');
      _checkWorkContext();
      RetainedCpsAuthentication? retained;
      if (pin.isEmpty &&
          authenticationCache != null &&
          authenticationKey != null) {
        retained = await authenticationCache!.take(authenticationKey!);
        if (retained == null) throw DmpNativeFailure('AUTHENTICATION_EXPIRED');
        final unusedBridge = bridge;
        final unusedResources = releaseResources;
        bridge = retained.bridge;
        releaseResources = retained.releaseResources;
        _lease = retained.lease;
        await unusedBridge.close();
        await unusedResources?.call();
      } else {
        if (!RegExp(r'^\d{1,16}$').hasMatch(pin)) {
          throw DmpNativeFailure('CPS_PIN');
        }
        try {
          _lease = await CpsOperationLease.acquireAvailable();
        } catch (_) {
          throw DmpNativeFailure('CPS_BUSY');
        }
      }
      _checkWorkContext();
      late CpsProfile profile;
      try {
        profile = retained?.profile ?? await readProfile(pin, _lease!);
      } on DmpNativeFailure {
        rethrow;
      } on PlatformException catch (e) {
        final details = e.details;
        final code = details is Map ? details['nativeReturnCode'] : null;
        throw DmpNativeFailure(switch (code) {
          0xa0 => 'CPS_PIN',
          0xa4 => 'CPS_BLOCKED',
          0xe0 => 'CPS_ABSENT',
          0x100 || 0x191 => 'CPS_BUSY',
          _ => 'CPS_UNAVAILABLE',
        });
      } catch (_) {
        throw DmpNativeFailure('CPS_UNAVAILABLE');
      }
      final matches = profile.situations
          .where(
            (s) =>
                s.number == configuration.situationNumber &&
                s.mode == configuration.situationMode &&
                s.status == configuration.situationStatus &&
                (accessContext != null
                    ? accessContext!.matches(profile, s, now().toUtc())
                    : s.structureId == c['structureId'] &&
                          s.sector == configuration.situationSector),
          )
          .toList();
      if (!PractitionerCpsService.matchesCurrentProfile(snapshot, profile) ||
          profile.nationalId != c['identifier'] ||
          profile.professionCode != 70 ||
          matches.length != 1 ||
          c['professionCode'] != 'G15_70' ||
          c['setting'] != 'Ambulatoire' ||
          c['replacementFor'] != '') {
        throw DmpNativeFailure('CPS_IDENTITY');
      }
      _checkWorkContext();
      final started = now().toUtc();
      stage = 'EXCHANGE';
      final result = await bridge.call(retained == null ? 'open' : 'resume', {
        ...configuration.fields,
        if (accessContext != null) 'accessOnly': 'true',
        'replacementUniqueId': ?_replacementUniqueId,
        'depublicationUniqueId': ?depublicationUniqueId,
        if (authenticationCache != null) 'reuseAuthentication': 'true',
        if (retained == null) 'pin': pin,
        'professional': profile.nationalId,
      });
      pin = null; // No PIN retained on this object, evidence or logs.
      stage = 'RESULT';
      if (authenticationCache != null) {
        _authenticationExpires = DateTime.parse(
          result['authenticationExpiresAt']!,
        ).toUtc();
        if (!_authenticationExpires!.isAfter(now().toUtc()) ||
            _authenticationExpires!.difference(now().toUtc()) >
                const Duration(hours: 1) ||
            (retained != null && _authenticationExpires != retained.expires)) {
          throw DmpNativeFailure('SESSION');
        }
      }
      final issued = DateTime.parse(result['issuedAt']!).toUtc();
      final expires = DateTime.parse(result['expiresAt']!).toUtc();
      if (issued.isBefore(started) ||
          issued.isAfter(now().toUtc()) ||
          !expires.isAfter(issued) ||
          expires.difference(issued) > const Duration(minutes: 2) ||
          result['authHash'] != configuration.authenticationHash ||
          result['signHash'] != configuration.signingHash ||
          result['trustHash'] != configuration.trustHash ||
          result['professional'] != profile.nationalId ||
          result['tdEndpoint'] != configuration.td02Endpoint ||
          result['depositEndpoint'] != configuration.wire.endpoint ||
          result['mutualTls'] != 'true' ||
          result['protocol'] != 'TLSv1.2' ||
          ![
            'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
            'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
          ].contains(result['tdCipher']) ||
          ![
            'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
            'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
          ].contains(result['depositCipher']) ||
          [
            'id',
            'tdChannel',
            'depositChannel',
            'tdPeer',
            'depositPeer',
          ].any((k) => result[k]?.isNotEmpty != true)) {
        throw DmpNativeFailure('SESSION');
      }
      final evidence = {
        for (final k in [
          'id',
          'trustHash',
          'tdEndpoint',
          'depositEndpoint',
          'mutualTls',
          'protocol',
          'tdCipher',
          'depositCipher',
          'tdChannel',
          'depositChannel',
          'tdPeer',
          'depositPeer',
        ])
          k: result[k],
        'authenticationReused': retained != null,
        'cpsFamilyName': profile.familyName,
        'cpsGivenName': profile.givenName,
        'cpsNationalId': profile.nationalId,
        if (accessContext != null) 'recipe': snapshot['recipe'],
        'situationNumber': configuration.situationNumber,
        'situationMode': configuration.situationMode,
        'situationStatus': configuration.situationStatus,
        'situationSector': configuration.situationSector,
      };
      stage = 'SESSION';
      final session = DmpSession(
        id: result['id']!,
        professional: profile.nationalId,
        authority: c['authority'],
        structure: c['structureId'],
        certificateHash: configuration.authenticationHash,
        contextHash: medicalHash(snapshot['practice']),
        issuedAt: issued,
        expiresAt: expires,
        nativeEvidenceJson: jsonEncode(evidence),
      );
      _material = DmpWireMaterial(
        configuration: configuration.wire,
        authenticationDer: result['authDer']!,
        signingDer: result['signDer']!,
        authenticationHash: configuration.authenticationHash,
        signingHash: configuration.signingHash,
        professional: profile.nationalId,
        assessmentId: result['id']!,
        assessedAt: issued,
        validUntil: expires,
        trustedAndNotRevoked: true,
      );
      _material!.check(session, now());
      _snapshot = medicalCanonical(snapshot);
      _session = session;
      _authenticationProfile = profile;
      return session;
    } catch (e) {
      await closeSession();
      if (e is DmpChainBlock) rethrow;
      throw DmpNativeFailure('NATIVE_SESSION_$stage');
    } finally {
      _opening = false;
    }
  }

  @override
  Future<bool> sessionCurrent(DmpSession s) async {
    _check(s);
    final r = await bridge.call('current', {'id': s.id});
    final native = jsonDecode(s.nativeEvidenceJson!);
    return r['id'] == s.id &&
        r['authHash'] == configuration.authenticationHash &&
        r['signHash'] == configuration.signingHash &&
        r['tdChannel'] == native['tdChannel'] &&
        r['depositChannel'] == native['depositChannel'];
  }

  @override
  Future<DmpPolicy> policy(Map<String, dynamic> snapshot) =>
      readPolicy(snapshot);
  @override
  Future<DmpWireMaterial> wireMaterial(DmpSession s) async {
    _check(s);
    if (!await sessionCurrent(s)) throw DmpNativeFailure('SESSION');
    _material!.check(s, now());
    return _material!;
  }

  @override
  Future<String> prepareTd02(
    Map<String, dynamic> snapshot,
    DmpSession s,
    DateTime time,
  ) async {
    _check(s);
    if (_tdRequest != null || medicalCanonical(snapshot) != _snapshot) {
      throw DmpNativeFailure('SESSION');
    }
    return _tdRequest = DmpNativeTd02.build(
      snapshot,
      s,
      await wireMaterial(s),
      time,
      configuration.td02Endpoint,
      processingMode: configuration.processingMode,
      accessContext: accessContext,
    );
  }

  @override
  Future<DmpTd02Reply> td02(String request, DmpSession s) async {
    _check(s);
    if (_tdUsed || request != _tdRequest) throw DmpNativeFailure('SESSION');
    _tdUsed = true;
    final r = await bridge.call('td', {
      'id': s.id,
      'body': base64Encode(utf8.encode(request)),
      'contentType':
          'application/soap+xml; charset=UTF-8; action="${DmpNativeTd02.action}"',
    });
    return DmpTd02Reply(
      int.parse(r['status']!),
      utf8.decode(base64Decode(r['body']!)),
      headers: r['headers'],
    );
  }

  /// One explicit DV1 authorization mutation per authenticated session.
  static const authorizationRecheckOperation = 'authorizationrecheck';
  bool _authorizationUsed = false,
      _authorizationRechecked = false,
      _searchUsed = false;
  int _submissionStage = 0;
  Future<DmpTd02Reply> searchSubmission(
    String request,
    DmpSession session,
    String stage,
  ) async {
    _check(session);
    final next = const {
      'submissions': 1,
      'associations': 2,
      'documents': 3,
    }[stage];
    if (accessContext?.scenario != 'PRE_CONS_SUB' ||
        depublicationUniqueId != null ||
        _replacementUniqueId != null ||
        !_tdUsed ||
        _signedInfo != null ||
        _depositUsed ||
        _authorizationUsed ||
        next == null ||
        (_submissionStage == 0
            ? (_searchUsed || next != 1)
            : (next == 1 ||
                  next < _submissionStage ||
                  next > _submissionStage + 1))) {
      throw DmpNativeFailure('SESSION');
    }
    _searchUsed = true;
    _submissionStage = next;
    final r = await bridge.call('submissionsearch', {
      'id': session.id,
      'stage': stage,
      'body': base64Encode(utf8.encode(request)),
      'contentType':
          'application/soap+xml; charset=UTF-8; action="${DmpNativeTd31b.action}"',
    });
    return DmpTd02Reply(
      int.parse(r['status']!),
      utf8.decode(base64Decode(r['body']!)),
      headers: r['headers'],
    );
  }

  int _visibilityStage = 0;
  Future<DmpTd02Reply> visibilityExchange(
    String request,
    DmpSession session, {
    bool update = false,
  }) async {
    _check(session);
    if (accessContext?.scenario != 'PRE_CONS_INV' ||
        !_tdUsed ||
        _depositUsed ||
        _signedInfo != null ||
        _authorizationUsed ||
        depublicationUniqueId != null ||
        _replacementUniqueId != null ||
        (update ? _visibilityStage != 1 : ![0, 2].contains(_visibilityStage)) ||
        (_visibilityStage == 0 && _searchUsed)) {
      throw DmpNativeFailure('SESSION');
    }
    _searchUsed = true;
    _visibilityStage++;
    final action = update
        ? 'urn:ihe:iti:2010:UpdateDocumentSet'
        : DmpNativeTd31b.action;
    final response = await bridge.call(
      update ? 'visibilityupdate' : 'visibilitymetadata',
      {
        'id': session.id,
        'body': base64Encode(utf8.encode(request)),
        'contentType': 'application/soap+xml; charset=UTF-8; action="$action"',
      },
    );
    return DmpTd02Reply(
      int.parse(response['status']!),
      utf8.decode(base64Decode(response['body']!)),
      headers: response['headers'],
    );
  }

  bool _consultMetadata = false, _retrieved = false;
  Future<Map<String, String>> consultationExchange(
    String request,
    DmpSession session, {
    required bool retrieve,
  }) async {
    _check(session);
    if (accessContext?.scenario != 'PRE_CONS_CONS' ||
        depublicationUniqueId != null ||
        _replacementUniqueId != null ||
        !_tdUsed ||
        _signedInfo != null ||
        _depositUsed ||
        _authorizationUsed ||
        (retrieve ? (!_consultMetadata || _retrieved) : _searchUsed)) {
      throw DmpNativeFailure('SESSION');
    }
    if (retrieve) {
      _retrieved = true;
    } else {
      _searchUsed = true;
    }
    final action = retrieve
        ? 'urn:ihe:iti:2007:RetrieveDocumentSet'
        : DmpNativeTd31b.action;
    final result = await bridge.call(
      retrieve ? 'retrieve' : 'consultmetadata',
      {
        'id': session.id,
        'body': base64Encode(utf8.encode(request)),
        'contentType': 'application/soap+xml; charset=UTF-8; action="$action"',
      },
    );
    if (!retrieve) _consultMetadata = true;
    return result;
  }

  Future<DmpTd02Reply> findDocuments(String request, DmpSession session) async {
    _check(session);
    if (accessContext == null ||
        !['PRE_CONS_RECH', 'PRE_CONS_INV'].contains(accessContext!.scenario) ||
        depublicationUniqueId != null ||
        _replacementUniqueId != null ||
        !_tdUsed ||
        _signedInfo != null ||
        _depositUsed ||
        _authorizationUsed ||
        _searchUsed) {
      throw DmpNativeFailure('SESSION');
    }
    _searchUsed = true;
    final r = await bridge.call('finddocuments', {
      'id': session.id,
      'body': base64Encode(utf8.encode(request)),
      'contentType':
          'application/soap+xml; charset=UTF-8; action="${DmpNativeTd31b.action}"',
    });
    return DmpTd02Reply(
      int.parse(r['status']!),
      utf8.decode(base64Decode(r['body']!)),
      headers: r['headers'],
    );
  }

  Future<DmpTd02Reply> searchDocument(
    String request,
    DmpSession session,
  ) async {
    _check(session);
    if ((accessContext == null && _replacementUniqueId == null) ||
        !_tdUsed ||
        _signedInfo != null ||
        _depositUsed ||
        _authorizationUsed ||
        _searchUsed) {
      throw DmpNativeFailure('SESSION');
    }
    if (_replacementUniqueId != null) {
      final values = XmlDocument.parse(
        request,
      ).findAllElements('Value', namespaceUri: DmpNativeTd31b.rim);
      if (values.length != 1 ||
          values.single.innerText != "('$_replacementUniqueId')") {
        throw DmpNativeFailure('SESSION');
      }
    }
    _searchUsed = true;
    final r = await bridge.call('search', {
      'id': session.id,
      'body': base64Encode(utf8.encode(request)),
      'contentType':
          'application/soap+xml; charset=UTF-8; action="${DmpNativeTd31b.action}"',
    });
    return DmpTd02Reply(
      int.parse(r['status']!),
      utf8.decode(base64Decode(r['body']!)),
      headers: r['headers'],
    );
  }

  Future<DmpTd02Reply> updateAuthorization(
    String request,
    DmpSession session,
  ) async {
    _check(session);
    if (accessContext == null ||
        !_tdUsed ||
        _authorizationUsed ||
        _searchUsed) {
      throw DmpNativeFailure('SESSION');
    }
    _authorizationUsed = true;
    final r = await bridge.call('authorization', {
      'id': session.id,
      'body': base64Encode(utf8.encode(request)),
      'contentType':
          'application/soap+xml; charset=UTF-8; action="${DmpNativeTd03.action}"',
    });
    return DmpTd02Reply(
      int.parse(r['status']!),
      utf8.decode(base64Decode(r['body']!)),
      headers: r['headers'],
    );
  }

  Future<({String request, DmpTd02Reply reply})> recheckAuthorization(
    DmpSession session,
  ) async {
    _check(session);
    if (accessContext == null ||
        !_authorizationUsed ||
        _authorizationRechecked) {
      throw DmpNativeFailure('SESSION');
    }
    _authorizationRechecked = true;
    final request = DmpNativeTd02.build(
      accessContext!.snapshot,
      session,
      await wireMaterial(session),
      now().toUtc(),
      configuration.td02Endpoint,
      processingMode: configuration.processingMode,
      accessContext: accessContext,
    );
    final r = await bridge.call(authorizationRecheckOperation, {
      'id': session.id,
      'body': base64Encode(utf8.encode(request)),
      'contentType':
          'application/soap+xml; charset=UTF-8; action="${DmpNativeTd02.action}"',
    });
    return (
      request: request,
      reply: DmpTd02Reply(
        int.parse(r['status']!),
        utf8.decode(base64Decode(r['body']!)),
        headers: r['headers'],
      ),
    );
  }

  Future<DmpTd02Reply> depublicate(String request, DmpSession session) async {
    _check(session);
    if (depublicationUniqueId == null ||
        accessContext == null ||
        !_tdUsed ||
        !_searchUsed ||
        _authorizationUsed ||
        _depublicationUsed) {
      throw DmpNativeFailure('SESSION');
    }
    _depublicationUsed = true;
    final r = await bridge.call('depublish', {
      'id': session.id,
      'body': base64Encode(utf8.encode(request)),
      'contentType':
          'application/soap+xml; charset=UTF-8; action="${DmpNativeTd33c.action}"',
    });
    return DmpTd02Reply(
      int.parse(r['status']!),
      utf8.decode(base64Decode(r['body']!)),
      headers: r['headers'],
    );
  }

  @override
  Future<String> signCanonicalXml(
    String signedInfo,
    String certificateHash,
    DmpSession s,
  ) async {
    _check(s);
    if (accessContext != null) throw DmpNativeFailure('CONFIGURATION');
    if (!_tdUsed ||
        _signedInfo != null ||
        certificateHash != configuration.signingHash) {
      throw DmpNativeFailure('SESSION');
    }
    final r = await bridge.call('sign', {
      'id': s.id,
      'body': base64Encode(utf8.encode(signedInfo)),
      'signHash': certificateHash,
    });
    if (!DmpWireCrypto.verify(
      signedInfo,
      DmpWireCertificate.parse(_material!.signingDer),
      r['signature']!,
    )) {
      throw DmpNativeFailure('CPS_CERTIFICATE');
    }
    _signedInfo = signedInfo;
    return _signature = r['signature']!;
  }

  @override
  Future<TlsFailure?> connect(DmpSession s) async {
    if (!await sessionCurrent(s)) throw DmpNativeFailure('SESSION');
    return null;
  }

  @override
  Future<DmpHttpReply> deposit(
    DmpPreparedSubmission p,
    DmpSignature signature,
    DmpSession s,
  ) async {
    _check(s);
    if (accessContext != null) throw DmpNativeFailure('CONFIGURATION');
    if (_depositUsed ||
        _signature == null ||
        signature.value != _signature ||
        signature.packageHash != p.hash ||
        p.wire?['signedInfo'] != _signedInfo ||
        signature.certificateHash != configuration.signingHash ||
        p.sessionHash != medicalHash(s.evidence) ||
        p.snapshotHash != medicalHash(jsonDecode(_snapshot!))) {
      throw DmpNativeFailure('SESSION');
    }
    DmpWireDraft.verifyArchived(p.evidence, jsonDecode(_snapshot!), s.evidence);
    final wire = p.wire!, bytes = base64Decode(p.wire!['mime']);
    if (sha256.convert(bytes).toString() != wire['mimeSha256']) {
      throw DmpNativeFailure('SESSION');
    }
    _depositUsed =
        true; // Consumed before native call; no replay on exceptions.
    final r = await bridge.call('deposit', {
      'id': s.id,
      'body': base64Encode(bytes),
      'contentType': wire['contentType'],
    });
    return DmpHttpReply(
      r['headers']!,
      base64Decode(r['body']!),
      provenance: provenance,
    );
  }

  @override
  Future<DmpSignature> sign(DmpPreparedSubmission p, DmpSession s) async =>
      throw DmpNativeFailure('CONFIGURATION');
  @override
  Future<bool> verifySignature(
    DmpPreparedSubmission p,
    DmpSignature sig,
    DmpSession s,
  ) async => false;
  @override
  Future<void> closeSession() async {
    if (_closeFailed) throw DmpNativeFailure('NATIVE');
    if (_closed) return;
    _closed = true;
    // A successful access transaction may leave only the authenticated card open.
    // TLS channels and all patient/transaction state are closed in both cases.
    if (retainAuthentication &&
        accessContext != null &&
        authenticationCache != null &&
        authenticationKey != null &&
        _authenticationProfile != null &&
        _authenticationExpires != null &&
        _session != null &&
        _lease != null &&
        checkWorkContext != null) {
      try {
        _checkWorkContext();
        final result = await bridge.call('park', {'id': _session!.id});
        if (DateTime.parse(result['authenticationExpiresAt']!).toUtc() !=
            _authenticationExpires) {
          throw DmpNativeFailure('SESSION');
        }
        authenticationCache!.retain(
          RetainedCpsAuthentication(
            key: authenticationKey!,
            profile: _authenticationProfile!,
            bridge: bridge,
            lease: _lease!,
            expires: _authenticationExpires!,
            checkContext: checkWorkContext!,
            releaseResources: releaseResources,
          ),
        );
        authenticationRetained = true;
        _lease = null;
        releaseResources = null;
      } catch (_) {
        // Reuse is optional: close the worker completely if parking is refused.
      }
    }
    // Release only after worker exit is confirmed. A close failure keeps lease.
    try {
      if (!authenticationRetained) await bridge.close();
    } catch (_) {
      _closeFailed = true;
      rethrow;
    }
    _lease?.release();
    await releaseResources?.call();
    _session = null;
    _authenticationProfile = null;
    _authenticationExpires = null;
    _tdRequest = null;
    releaseResources = null;
    _snapshot = null;
    _material = null;
    _signature = null;
    _signedInfo = null;
  }
}
