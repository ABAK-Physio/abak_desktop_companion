import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:xml/xml.dart';
import '../../../../dmp_transfer/archive_deposit_reader.dart';
import '../../../models/episode_document_version.dart';
import '../../document_medical_service.dart';
import 'dv1_records.dart';
import 'dv1_configuration.dart';

/// A review is bound to immutable evidence, never a general journal unlock.
class Dv1RetryReview {
  Dv1RetryReview._(
    this.attemptId,
    this.bindingHash,
    this.saved, {
    this.firstAttemptId,
    this.secondAttemptId,
    this.thirdAttemptId,
  });
  final String? firstAttemptId, secondAttemptId, thirdAttemptId;
  bool get signatureTitle => thirdAttemptId != null;
  bool get metadata => secondAttemptId != null;
  bool get patientId => firstAttemptId != null;
  String get label => signatureTitle
      ? 'Reprendre après le rejet du titre de signature'
      : metadata
      ? 'Reprendre après le rejet des métadonnées'
      : patientId
      ? 'Reprendre après le rejet patientId'
      : 'Reprendre après le rejet SOAP';
  String get correction => signatureTitle
      ? 'le titre de signature corrigé (Source)'
      : metadata
      ? 'les libellés et métadonnées de signature corrigés'
      : patientId
      ? 'l’identifiant patient XDS corrigé (NH)'
      : 'les en-têtes SOAP corrigés';
  final String attemptId, bindingHash;
  final Map<String, dynamic> saved;
  Map<String, Object?> get evidence => {
    'previousAttemptId': attemptId,
    'evidenceHash': bindingHash,
    'reason': signatureTitle
        ? 'XDS-signature-title'
        : metadata
        ? 'XDS-labels-signature'
        : patientId
        ? 'XDS-patientId-missing-NH'
        : 'SOAP-MustUnderstand-Security',
    if (patientId) 'firstAttemptId': firstAttemptId,
    if (metadata) 'secondAttemptId': secondAttemptId,
    if (signatureTitle) 'thirdAttemptId': thirdAttemptId,
    if (signatureTitle) 'correctedSignatureTitleProfile': 'event-source-1',
    if (metadata) 'correctedMetadataProfile': 'dv1-labels-signature-1',
    if (patientId) 'correctedPatientIdProfile': 'ins-nh-1',
    'correctedProfile': 'dv1-20261028',
    'preparationPolicy': 'identical-content-preserve-invalidation',
  };
  Future<MedicalRow> capture(
    DocumentMedicalService medical,
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
  ) => medical.retryApprovedCapture(db, v, saved['approvalId'] as String);

  bool allowsControlInvalidations(String runId, List<Map> rows) =>
      runId == saved['controlRunId'] &&
      rows.every((r) => r['reason'] == 'Validation médicale invalidée');

  void checkPreparation(Map receipt, Map run, String payloadHash) {
    if (receipt['approval_id'] != saved['approvalId'] ||
        receipt['snapshot_hash'] != saved['snapshotHash'] ||
        run['run_id'] != saved['controlRunId'] ||
        payloadHash != saved['cdaHash']) {
      throw StateError(
        'La reprise doit conserver la version, la validation et les contrôles de la tentative examinée.',
      );
    }
  }
}

class Dv1Retry {
  static const wsse =
      'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
  static const faultAction =
      'urn:ihe:iti:xds-b:2007:DocumentRepository_PortType:DocumentRepository_ProvideAndRegisterDocumentSet-b:Fault:SoapFault';
  static const reason =
      'MustUnderstand headers: [{$wsse}Security] are not understood.';

  /// Only the complete, correlated pre-processing fault observed on DV1.
  /// No timeout, generic SOAP fault, XDS failure or success permits a retry.
  static bool isSecurityMustUnderstand({
    required String request,
    required String headers,
    required List<int> bytes,
  }) {
    try {
      const s = ArchiveDepositReader.soap, w = ArchiveDepositReader.wsa;
      final one = ArchiveDepositReader.one;
      if (!_complete(headers, bytes, 500)) return false;
      final q = one(ArchiveDepositReader.parse(request), 'Envelope', s);
      final qh = one(q, 'Header', s);
      if (one(qh, 'To', w).innerText != Dv1Configuration.repository ||
          one(qh, 'Action', w).innerText !=
              'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b' ||
          one(
                qh,
                'Security',
                wsse,
              ).getAttribute('mustUnderstand', namespaceUri: s) !=
              'true') {
        return false;
      }
      final id = one(qh, 'MessageID', w).innerText;
      if (!RegExp(r'^urn:uuid:[0-9a-f-]{36}$').hasMatch(id)) return false;
      final envelope = one(
        ArchiveDepositReader.parse(
          ArchiveDepositReader.extract(headers, bytes),
        ),
        'Envelope',
        s,
      );
      if (envelope.childElements.length != 2) return false;
      final h = one(envelope, 'Header', s), b = one(envelope, 'Body', s);
      if (one(h, 'RelatesTo', w).innerText != id ||
          one(h, 'Action', w).innerText != faultAction ||
          b.childElements.length != 1) {
        return false;
      }
      final fault = one(b, 'Fault', s);
      // No application-level detail, subcode or extra result may be ignored.
      if (fault.childElements.length != 2) return false;
      final code = one(fault, 'Code', s), value = one(code, 'Value', s);
      if (code.childElements.length != 1 || value.childElements.isNotEmpty) {
        return false;
      }
      final parts = value.innerText.trim().split(':');
      if (parts.length != 2 || parts[1] != 'MustUnderstand') return false;
      String? namespace;
      for (XmlNode? n = value; n != null && namespace == null; n = n.parent) {
        if (n is XmlElement) namespace = n.getAttribute('xmlns:${parts[0]}');
      }
      final why = one(fault, 'Reason', s);
      return namespace == s &&
          why.childElements.length == 1 &&
          one(why, 'Text', s).childElements.isEmpty &&
          one(why, 'Text', s).innerText == reason;
    } catch (_) {
      return false;
    }
  }

  static bool _complete(String headers, List<int> bytes, int status) {
    if (!headers.startsWith('HTTP/1.1 $status ') ||
        headers.length > 32768 ||
        bytes.isEmpty ||
        bytes.length > 2 * 1024 * 1024 ||
        ArchiveDepositReader.header(headers, 'content-length') !=
            '${bytes.length}' ||
        ArchiveDepositReader.header(headers, 'transfer-encoding') != null ||
        ArchiveDepositReader.header(headers, 'content-encoding') != null ||
        ArchiveDepositReader.header(headers, 'location') != null ||
        RegExp(r'^HTTP/', multiLine: true).allMatches(headers).length != 1) {
      return false;
    }
    final type = ArchiveDepositReader.header(headers, 'content-type') ?? '';
    if (type.split(';').first.trim().toLowerCase() == 'multipart/related') {
      final boundary = ArchiveDepositReader.parameter(type, 'boundary');
      if (boundary == null || boundary.isEmpty) return false;
      final body = latin1.decode(bytes), marker = '--$boundary';
      if (marker.allMatches(body).length != 2 ||
          !body.trimRight().endsWith('$marker--')) {
        return false;
      }
    } else if (type.split(';').first.trim().toLowerCase() !=
        'application/soap+xml') {
      return false;
    }
    return true;
  }

  /// Only the complete single-error rejection observed for the malformed CX.5.
  static bool isPatientIdRejection({
    required String request,
    required String headers,
    required List<int> bytes,
    required String documentEntry,
  }) {
    try {
      if (!_complete(headers, bytes, 200)) return false;
      const s = ArchiveDepositReader.soap,
          w = ArchiveDepositReader.wsa,
          rs = ArchiveDepositReader.rs,
          rim = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0';
      final one = ArchiveDepositReader.one;
      final q = one(ArchiveDepositReader.parse(request), 'Envelope', s);
      final qh = one(q, 'Header', s);
      if (one(qh, 'To', w).innerText != Dv1Configuration.repository ||
          one(qh, 'Action', w).innerText !=
              'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b') {
        return false;
      }
      final id = one(qh, 'MessageID', w).innerText;
      if (!RegExp(r'^urn:uuid:[0-9a-f-]{36}$').hasMatch(id)) return false;
      final entries = q
          .findAllElements('ExtrinsicObject', namespaceUri: rim)
          .where((e) => e.getAttribute('id') == documentEntry);
      if (entries.length != 1) return false;
      final patientIds = q
          .findAllElements('ExternalIdentifier', namespaceUri: rim)
          .where(
            (e) => [
              'urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427',
              'urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446',
            ].contains(e.getAttribute('identificationScheme')),
          )
          .map((e) => e.getAttribute('value'))
          .toList();
      if (patientIds.length != 3 ||
          patientIds.toSet().length != 1 ||
          !RegExp(
            r'^\d{15}\^\^\^&1\.2\.250\.1\.213\.1\.4\.10&ISO$',
          ).hasMatch(patientIds.first ?? '')) {
        return false;
      }
      final envelope = one(
        ArchiveDepositReader.parse(
          ArchiveDepositReader.extract(headers, bytes),
        ),
        'Envelope',
        s,
      );
      if (envelope.childElements.length != 2) return false;
      final h = one(envelope, 'Header', s), b = one(envelope, 'Body', s);
      if (one(h, 'RelatesTo', w).innerText != id ||
          one(h, 'Action', w).innerText != ArchiveDepositReader.action ||
          b.childElements.length != 1) {
        return false;
      }
      final response = one(b, 'RegistryResponse', rs);
      if (response.getAttribute('status') !=
              '${ArchiveDepositReader.statusPrefix}Failure' ||
          response.childElements.length != 1) {
        return false;
      }
      final errors = one(response, 'RegistryErrorList', rs);
      const severity =
          'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error';
      if (errors.getAttribute('highestSeverity') != severity ||
          errors.childElements.length != 1) {
        return false;
      }
      final error = one(errors, 'RegistryError', rs);
      return error.childElements.isEmpty &&
          error.innerText.trim().isEmpty &&
          error.getAttribute('errorCode') == 'XDSRegistryMetadataError' &&
          error.getAttribute('severity') == severity &&
          error.getAttribute('location') ==
              'AffinityDomainBean.checkpatientId 1' &&
          error.getAttribute('codeContext') ==
              "entryUUID=$documentEntry;Le champs patientId n'est pas conforme";
    } catch (_) {
      return false;
    }
  }

  /// The exact eight errors observed, not a general metadata rejection unlock.
  static bool isMetadataRejection({
    required String request,
    required String headers,
    required List<int> bytes,
    required String documentEntry,
    required String signatureEntry,
    required String submissionEntry,
  }) {
    try {
      if (!_complete(headers, bytes, 200)) return false;
      const s = ArchiveDepositReader.soap,
          w = ArchiveDepositReader.wsa,
          rs = ArchiveDepositReader.rs,
          rim = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0';
      final one = ArchiveDepositReader.one;
      final q = one(ArchiveDepositReader.parse(request), 'Envelope', s);
      final qh = one(q, 'Header', s);
      if (one(qh, 'To', w).innerText != Dv1Configuration.repository ||
          one(qh, 'Action', w).innerText !=
              'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b') {
        return false;
      }
      final id = one(qh, 'MessageID', w).innerText;
      if (!RegExp(r'^urn:uuid:[0-9a-f-]{36}$').hasMatch(id) ||
          {documentEntry, signatureEntry, submissionEntry}.length != 3) {
        return false;
      }
      for (final pair in [
        (documentEntry, 'ExtrinsicObject'),
        (signatureEntry, 'ExtrinsicObject'),
        (submissionEntry, 'RegistryPackage'),
      ]) {
        if (q
                .findAllElements(pair.$2, namespaceUri: rim)
                .where((e) => e.getAttribute('id') == pair.$1)
                .length !=
            1) {
          return false;
        }
      }
      final envelope = one(
        ArchiveDepositReader.parse(
          ArchiveDepositReader.extract(headers, bytes),
        ),
        'Envelope',
        s,
      );
      if (envelope.childElements.length != 2) return false;
      final h = one(envelope, 'Header', s), b = one(envelope, 'Body', s);
      if (one(h, 'RelatesTo', w).innerText != id ||
          one(h, 'Action', w).innerText != ArchiveDepositReader.action ||
          b.childElements.length != 1) {
        return false;
      }
      final response = one(b, 'RegistryResponse', rs);
      if (response.getAttribute('status') !=
              '${ArchiveDepositReader.statusPrefix}Failure' ||
          response.childElements.length != 1) {
        return false;
      }
      final errors = one(response, 'RegistryErrorList', rs);
      const severity =
          'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error';
      if (errors.getAttribute('highestSeverity') != severity ||
          errors.childElements.length != 8) {
        return false;
      }
      final expected = <String, String>{
        for (final entry in [documentEntry, submissionEntry])
          "entryUUID=$entry;La valeur 'G15_70^Masseur-kinésithérapeute^1.2.250.1.213.1.1.4.5' n'est pas conforme (authorSpecialty)":
              'AffinityDomainBean.validateAuthor 2',
        "entryUUID=$signatureEntry;Le libellé 'Masqué aux professionnels' ne fait pas partie du domaine d'affinité pour le code : MASQUE_PS (CONFIDENTIALITYCODE). La valeur correcte est : 'Masqué aux professionnels de santé'.":
            'AffinityDomainBean.validateXDSDocumentEntry 3',
        "entryUUID=$signatureEntry;Le libellé 'Invisible au patient' ne fait pas partie du domaine d'affinité pour le code : INVISIBLE_PATIENT (CONFIDENTIALITYCODE). La valeur correcte est : 'Non visible par le patient'.":
            'AffinityDomainBean.validateXDSDocumentEntry 3',
        "entryUUID=$signatureEntry;Le libellé 'Signature électronique' ne fait pas partie du domaine d'affinité pour le code : http://www.w3.org/2000/09/xmldsig# (FORMATCODE). La valeur correcte est : 'Default Signature Style'.":
            'AffinityDomainBean.validateXDSDocumentEntry 3',
        'entryUUID=$signatureEntry;Le sourcePatientInfo de la signature de lot de soumission doit être vide.':
            'AffinityDomainBean.validateXDSDocumentEntry 13',
        'Date de serviceStartTime et creationTime de la signature inégales':
            'AffinityDomainImpl.checkRequest 30',
        'Date de serviceStopTime et creationTime de la signature inégales':
            'AffinityDomainImpl.checkRequest 32',
      };
      for (final error in errors.childElements) {
        final context = error.getAttribute('codeContext');
        if (error.name.local != 'RegistryError' ||
            error.namespaceUri != rs ||
            error.childElements.isNotEmpty ||
            error.innerText.trim().isNotEmpty ||
            error.getAttribute('errorCode') != 'XDSRegistryMetadataError' ||
            error.getAttribute('severity') != severity ||
            context == null ||
            !expected.containsKey(context) ||
            expected.remove(context) != error.getAttribute('location')) {
          return false;
        }
      }
      return expected.isEmpty;
    } catch (_) {
      return false;
    }
  }

  static bool isSignatureTitleRejection({
    required String request,
    required String headers,
    required List<int> bytes,
    required String documentEntry,
    required String signatureEntry,
    required String submissionEntry,
  }) {
    try {
      if (!_complete(headers, bytes, 200)) return false;
      const s = ArchiveDepositReader.soap,
          w = ArchiveDepositReader.wsa,
          rs = ArchiveDepositReader.rs,
          rim = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0';
      final one = ArchiveDepositReader.one;
      final q = one(ArchiveDepositReader.parse(request), 'Envelope', s);
      final qh = one(q, 'Header', s);
      if (one(qh, 'To', w).innerText != Dv1Configuration.repository ||
          one(qh, 'Action', w).innerText !=
              'urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b') {
        return false;
      }
      final id = one(qh, 'MessageID', w).innerText;
      if (!RegExp(r'^urn:uuid:[0-9a-f-]{36}$').hasMatch(id) ||
          {documentEntry, signatureEntry, submissionEntry}.length != 3) {
        return false;
      }
      for (final pair in [
        (documentEntry, 'ExtrinsicObject'),
        (signatureEntry, 'ExtrinsicObject'),
        (submissionEntry, 'RegistryPackage'),
      ]) {
        if (q
                .findAllElements(pair.$2, namespaceUri: rim)
                .where((e) => e.getAttribute('id') == pair.$1)
                .length !=
            1) {
          return false;
        }
      }
      final envelope = one(
        ArchiveDepositReader.parse(
          ArchiveDepositReader.extract(headers, bytes),
        ),
        'Envelope',
        s,
      );
      if (envelope.childElements.length != 2) return false;
      final h = one(envelope, 'Header', s), b = one(envelope, 'Body', s);
      if (one(h, 'RelatesTo', w).innerText != id ||
          one(h, 'Action', w).innerText != ArchiveDepositReader.action ||
          b.childElements.length != 1) {
        return false;
      }
      final response = one(b, 'RegistryResponse', rs);
      if (response.getAttribute('status') !=
              '${ArchiveDepositReader.statusPrefix}Failure' ||
          response.childElements.length != 1) {
        return false;
      }
      final errors = one(response, 'RegistryErrorList', rs);
      const severity =
          'urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error';
      if (errors.getAttribute('highestSeverity') != severity ||
          errors.childElements.length != 1) {
        return false;
      }
      final signature = q
          .findAllElements('ExtrinsicObject', namespaceUri: rim)
          .singleWhere((e) => e.getAttribute('id') == signatureEntry);
      final name = one(one(signature, 'Name', rim), 'LocalizedString', rim);
      final event = signature
          .findElements('Classification', namespaceUri: rim)
          .singleWhere(
            (e) =>
                e.getAttribute('classificationScheme') ==
                'urn:uuid:2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4',
          );
      if (name.getAttribute('value') != 'Signature du lot' ||
          event.getAttribute('nodeRepresentation') !=
              '1.2.840.10065.1.12.1.14' ||
          one(
                one(event, 'Name', rim),
                'LocalizedString',
                rim,
              ).getAttribute('value') !=
              'Source') {
        return false;
      }
      final error = one(errors, 'RegistryError', rs);
      return error.childElements.isEmpty &&
          error.innerText.trim().isEmpty &&
          error.getAttribute('errorCode') == 'XDSRegistryMetadataError' &&
          error.getAttribute('severity') == severity &&
          error.getAttribute('location') ==
              'AffinityDomainImpl.checkRequest 46' &&
          error.getAttribute('codeContext') ==
              'Incohérence entre le titre et le eventCodeListDisplayName de la signature';
    } catch (_) {
      return false;
    }
  }

  static Future<Dv1RetryReview> inspect(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
    Directory controlsRoot,
  ) async {
    if ((await db.query('document_restore_barriers', limit: 1)).isNotEmpty ||
        (await db.query(
          'document_attempts',
          where: 'document_id=? OR (patient_id=? AND pdf_hash=?)',
          whereArgs: [v.documentId, v.values['patient_id'], v.digest],
        )).isNotEmpty) {
      throw StateError('Restauration ou autre tentative : reprise bloquée.');
    }
    final reservations = await Dv1Records.reservations(db, v);
    // Only the known SOAP -> patientId -> metadata rejection lineage permits
    // the next reservation. A reservation with no result consumes its route as well.
    if (reservations.isEmpty ||
        reservations.length > 4 ||
        reservations.any(
          (r) => r['document_id'] != v.documentId || r['version_id'] != v.id,
        )) {
      throw StateError('Reprise déjà réservée ou tentative différente.');
    }
    final first = await _soapReview(db, reservations.last, controlsRoot);
    if (reservations.length == 1) return first;
    final second = await _patientReview(
      db,
      reservations[reservations.length - 2],
      controlsRoot,
      first,
    );
    if (reservations.length == 2) return second;
    final third = await _metadataReview(
      db,
      reservations[reservations.length - 3],
      controlsRoot,
      second,
    );
    if (reservations.length == 3) return third;
    return _signatureTitleReview(db, reservations.first, controlsRoot, third);
  }

  static Future<Dv1RetryReview> _patientReview(
    DatabaseExecutor db,
    MedicalRow reservation,
    Directory controlsRoot,
    Dv1RetryReview first,
  ) async {
    final verified = await Dv1Records.verify(
      db,
      reservation,
      controlsRoot: controlsRoot,
    );
    final saved = Dv1Records.data(reservation);
    final rows = await db.query(
      'document_chain_steps',
      where: 'chain_id=?',
      whereArgs: [reservation['chain_id']],
    );
    Map<String, dynamic> phase(String name) =>
        Dv1Records.data(rows.where((r) => r['phase'] == 'dv1_$name').single);
    final response = phase('response'),
        package = phase('package'),
        preparation = phase('preparation');
    final replay = package['wire']['replay'] as Map;
    if (verified['outcome'] != 'rejected' ||
        medicalCanonical(saved['retry']) != medicalCanonical(first.evidence) ||
        medicalCanonical(preparation['retry']) !=
            medicalCanonical(first.evidence) ||
        [
          'approvalId',
          'snapshotHash',
          'controlRunId',
          'cdaHash',
        ].any((key) => saved[key] != first.saved[key]) ||
        replay['soapHeaderProfile'] != 'dv1-20261028' ||
        replay.containsKey('xdsPatientIdProfile') ||
        preparation['conditions']['scenario'] != 'PRE_ALIM_N1' ||
        preparation['accessOnly'] != false ||
        !isPatientIdRejection(
          request: response['request'],
          headers: response['headers'],
          bytes: base64Decode(response['response']),
          documentEntry: replay['identifiers']['cdaEntry'],
        )) {
      throw StateError(
        'Aucune preuve de rejet patientId autorisant cette reprise.',
      );
    }
    return Dv1RetryReview._(
      reservation['chain_id'] as String,
      medicalHash({
        'firstEvidenceHash': first.bindingHash,
        'reservation': reservation,
        'response': response,
        'package': package,
      }),
      Map.unmodifiable(saved),
      firstAttemptId: first.attemptId,
    );
  }

  static Future<Dv1RetryReview> _metadataReview(
    DatabaseExecutor db,
    MedicalRow reservation,
    Directory controlsRoot,
    Dv1RetryReview previous,
  ) async {
    final verified = await Dv1Records.verify(
      db,
      reservation,
      controlsRoot: controlsRoot,
    );
    final saved = Dv1Records.data(reservation);
    final rows = await db.query(
      'document_chain_steps',
      where: 'chain_id=?',
      whereArgs: [reservation['chain_id']],
    );
    Map<String, dynamic> phase(String name) =>
        Dv1Records.data(rows.where((r) => r['phase'] == 'dv1_$name').single);
    final response = phase('response'),
        package = phase('package'),
        preparation = phase('preparation');
    final replay = package['wire']['replay'] as Map,
        ids = replay['identifiers'] as Map;
    if (verified['outcome'] != 'rejected' ||
        medicalCanonical(saved['retry']) !=
            medicalCanonical(previous.evidence) ||
        medicalCanonical(preparation['retry']) !=
            medicalCanonical(previous.evidence) ||
        [
          'approvalId',
          'snapshotHash',
          'controlRunId',
          'cdaHash',
        ].any((key) => saved[key] != previous.saved[key]) ||
        replay['soapHeaderProfile'] != 'dv1-20261028' ||
        replay['xdsPatientIdProfile'] != 'ins-nh-1' ||
        replay.containsKey('xdsMetadataProfile') ||
        preparation['conditions']['scenario'] != 'PRE_ALIM_N1' ||
        preparation['accessOnly'] != false ||
        !isMetadataRejection(
          request: response['request'],
          headers: response['headers'],
          bytes: base64Decode(response['response']),
          documentEntry: ids['cdaEntry'],
          signatureEntry: ids['signatureEntry'],
          submissionEntry: ids['submissionEntry'],
        )) {
      throw StateError(
        'Aucune preuve du rejet des huit métadonnées autorisant cette reprise.',
      );
    }
    return Dv1RetryReview._(
      reservation['chain_id'] as String,
      medicalHash({
        'previousEvidenceHash': previous.bindingHash,
        'reservation': reservation,
        'response': response,
        'package': package,
      }),
      Map.unmodifiable(saved),
      firstAttemptId: previous.firstAttemptId,
      secondAttemptId: previous.attemptId,
    );
  }

  static Future<Dv1RetryReview> _signatureTitleReview(
    DatabaseExecutor db,
    MedicalRow reservation,
    Directory controlsRoot,
    Dv1RetryReview previous,
  ) async {
    final verified = await Dv1Records.verify(
      db,
      reservation,
      controlsRoot: controlsRoot,
    );
    final saved = Dv1Records.data(reservation);
    final rows = await db.query(
      'document_chain_steps',
      where: 'chain_id=?',
      whereArgs: [reservation['chain_id']],
    );
    Map<String, dynamic> phase(String name) =>
        Dv1Records.data(rows.where((r) => r['phase'] == 'dv1_$name').single);
    final response = phase('response'),
        package = phase('package'),
        preparation = phase('preparation');
    final replay = package['wire']['replay'] as Map,
        ids = replay['identifiers'] as Map;
    if (verified['outcome'] != 'rejected' ||
        medicalCanonical(saved['retry']) !=
            medicalCanonical(previous.evidence) ||
        medicalCanonical(preparation['retry']) !=
            medicalCanonical(previous.evidence) ||
        [
          'approvalId',
          'snapshotHash',
          'controlRunId',
          'cdaHash',
        ].any((key) => saved[key] != previous.saved[key]) ||
        replay['soapHeaderProfile'] != 'dv1-20261028' ||
        replay['xdsPatientIdProfile'] != 'ins-nh-1' ||
        replay['xdsMetadataProfile'] != 'dv1-labels-signature-1' ||
        replay.containsKey('signatureTitleProfile') ||
        preparation['conditions']['scenario'] != 'PRE_ALIM_N1' ||
        preparation['accessOnly'] != false ||
        !isSignatureTitleRejection(
          request: response['request'],
          headers: response['headers'],
          bytes: base64Decode(response['response']),
          documentEntry: ids['cdaEntry'],
          signatureEntry: ids['signatureEntry'],
          submissionEntry: ids['submissionEntry'],
        )) {
      throw StateError(
        'Aucune preuve du rejet du titre de signature autorisant cette reprise.',
      );
    }
    return Dv1RetryReview._(
      reservation['chain_id'] as String,
      medicalHash({
        'previousEvidenceHash': previous.bindingHash,
        'reservation': reservation,
        'response': response,
        'package': package,
      }),
      Map.unmodifiable(saved),
      firstAttemptId: previous.firstAttemptId,
      secondAttemptId: previous.secondAttemptId,
      thirdAttemptId: previous.attemptId,
    );
  }

  static Future<Dv1RetryReview> _soapReview(
    DatabaseExecutor db,
    MedicalRow reservation,
    Directory controlsRoot,
  ) async {
    final verified = await Dv1Records.verify(
      db,
      reservation,
      controlsRoot: controlsRoot,
    );
    if (verified['outcome'] != 'indeterminate') {
      throw StateError('Ce résultat ne permet pas cette reprise.');
    }
    final rows = await db.query(
      'document_chain_steps',
      where: 'chain_id=?',
      whereArgs: [reservation['chain_id']],
    );
    Map<String, dynamic> phase(String name) =>
        Dv1Records.data(rows.where((r) => r['phase'] == 'dv1_$name').single);
    final response = phase('response'),
        package = phase('package'),
        preparation = phase('preparation');
    if (package['wire']['replay'].containsKey('soapHeaderProfile') ||
        preparation['conditions']['scenario'] != 'PRE_ALIM_N1' ||
        preparation['accessOnly'] != false ||
        !isSecurityMustUnderstand(
          request: response['request'],
          headers: response['headers'],
          bytes: base64Decode(response['response']),
        )) {
      throw StateError(
        'Aucune preuve de rejet SOAP préalable autorisant cette reprise.',
      );
    }
    final saved = Dv1Records.data(reservation);
    return Dv1RetryReview._(
      reservation['chain_id'] as String,
      medicalHash({
        'reservation': reservation,
        'response': response,
        'package': package,
      }),
      Map.unmodifiable(saved),
    );
  }

  static Future<void> recheck(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
    Directory controlsRoot,
    Dv1RetryReview review,
  ) async {
    final current = await inspect(db, v, controlsRoot);
    if (current.attemptId != review.attemptId ||
        current.bindingHash != review.bindingHash) {
      throw StateError(
        'Les preuves ont changé depuis la confirmation de reprise.',
      );
    }
  }
}
