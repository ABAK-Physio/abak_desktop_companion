import 'dart:convert';
import 'patient_insi_exchange.dart';
import 'patient_insi_exchange_transport.dart';
import 'patient_insi_given_names_search.dart';
import 'patient_fr_insi_ws_ins2_request_builder.dart';
import 'patient_fr_insi_ws_ins3_request_builder.dart';
import 'patient_fr_insi_verification_response_parser.dart';
import 'package:abak_vitale/abak_vitale.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import '../../../core/settings/application_settings_service.dart';
import '../../../core/database/database_service.dart';
import '../../practitioners/data/practitioner_cps_service.dart';
import '../../cps/cps_access_service.dart';
import '../../cps/cps_operation_lease.dart';
import '../models/patient_fr_insi_ps_assertion_data.dart';
import '../models/patient_fr_insi_result.dart';
import 'dmp_chain/wire/crypto.dart';
import 'patient_fr_insi_contexte_bam_builder.dart';
import 'patient_fr_insi_contexte_lps_builder.dart';
import 'patient_fr_insi_message_id_builder.dart';
import 'patient_fr_insi_pkcs11_signing_certificate_service.dart';
import 'patient_fr_insi_ps_assertion_signing_service.dart';
import 'patient_fr_insi_ps_signature_verification_service.dart';
import 'patient_fr_insi_ps_signer.dart';
import 'patient_fr_insi_response_parser.dart';
import 'patient_fr_insi_ws_ins2_envelope_builder.dart';

/// INSi qualification server, WS_INS1/2/3, CPx level-2 assertion.
/// Constructing this service never reads a card or opens a connection.
class PatientInsiRetrievalService {
  static const endpoint = 'https://qualiflps.services-ps.ameli.fr/lps';
  static const action =
      'urn:ServiceIdentiteCertifiee:1.0.0:rechercherInsAvecCarteVitale';
  static const configurationKey = 'insi_cnda_configuration_v1';
  static const settings = ApplicationSettingsService();

  Future<List<Map<String, String>>> knownProfessionals() async {
    final db = await DatabaseService.database;
    final rows = await db.rawQuery(
      'SELECT c.*, p.display_name FROM practitioner_cps_profiles c '
      'JOIN practitioners p ON p.practitioner_id = c.practitioner_id '
      'WHERE p.is_active = 1 AND p.archived_at IS NULL ORDER BY p.display_name',
    );
    return [
      for (final row in rows)
        {
          'name': row['display_name'] as String,
          'professional': PractitionerCpsReading.fromStored(
            row,
          ).profile.nationalId,
          'sector': () {
            final situations = PractitionerCpsReading.fromStored(
              row,
            ).profile.situations;
            final sectors = situations
                .map((s) => s.sector)
                .whereType<String>()
                .toSet();
            return sectors.length == 1 &&
                    RegExp(r'^SA[0-9]{2}$').hasMatch(sectors.single)
                ? sectors.single
                : '';
          }(),
        },
    ];
  }

  Future<Map<String, String>> configuration() async {
    final encoded = await settings.getString(configurationKey);
    return encoded == null ? {} : Map<String, String>.from(jsonDecode(encoded));
  }

  Future<void> saveConfiguration(Map<String, String> fields) async {
    checkConfiguration(fields);
    final old = await configuration();
    await settings.setString(
      configurationKey,
      jsonEncode({...fields, 'instance': old['instance'] ?? const Uuid().v4()}),
    );
  }

  static void checkConfiguration(Map<String, String> fields) {
    if ((fields['authorization'] ?? '').trim().isEmpty ||
        !RegExp(r'^[0-9]{8,16}$').hasMatch(fields['professional'] ?? '') ||
        !RegExp(r'^[0-9]{9,14}$').hasMatch(fields['billing'] ?? '') ||
        !RegExp(r'^SA[0-9]{2}$').hasMatch(fields['sector'] ?? '')) {
      throw StateError(
        'Renseignez l’autorisation INSi de test fournie par le CNDA, '
        'l’identifiant national du professionnel, son identifiant de facturation '
        'et son secteur d’activité (code SAxx).',
      );
    }
  }

  /// API Lecture encodes NIR + space + key. Neither key nor insurance NIR is
  /// silently promoted to the beneficiary's INS.
  static String? matricule(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final text = raw.replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (!RegExp(
      r'^[0-9]{5}([0-9]{2}|2[AB])[0-9]{6}([0-9]{2})?$',
    ).hasMatch(text)) {
      throw StateError('Matricule de la lecture Vitale inexploitable.');
    }
    return text.substring(0, 13);
  }

  static String cardDate(VitaleIdentity card) {
    final raw = card.birthDateRaw;
    if (raw != null && RegExp(r'^[0-9]{8}$').hasMatch(raw)) {
      // API Lecture stores dates as DDMMYYYY, including unknown day/month.
      return '${raw.substring(4)}-${raw.substring(2, 4)}-${raw.substring(0, 2)}';
    }
    final date = card.birthDate;
    if (date == null) {
      throw StateError('Date de naissance absente de la lecture Vitale.');
    }
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static void checkCard(VitaleIdentity card) {
    if (matricule(card.nir) == null ||
        card.birthOrder == null ||
        card.birthOrder! < 1 ||
        card.birthOrder! > 9 ||
        !RegExp(r'^[0-9]{1,12}$').hasMatch(card.cardSerial ?? '')) {
      throw StateError(
        'Cette lecture ne contient pas toutes les données nécessaires à INSi. '
        'Relisez la carte Vitale avec cette version de Companion, puis enregistrez la fiche.',
      );
    }
    matricule(card.certifiedNir);
    cardDate(card);
  }

  /// Must use a fresh hardware read, never the list cached in the patient file.
  static void checkCurrentCard(
    VitaleIdentity selected,
    List<VitaleIdentity> current,
  ) {
    checkCard(selected);
    final matches = current.where((candidate) {
      try {
        checkCard(candidate);
        return candidate.cardSerial == selected.cardSerial &&
            matricule(candidate.nir) == matricule(selected.nir) &&
            matricule(candidate.certifiedNir) == matricule(selected.certifiedNir) &&
            cardDate(candidate) == cardDate(selected) &&
            candidate.birthOrder == selected.birthOrder &&
            candidate.insuredBirthLastName == selected.insuredBirthLastName &&
            candidate.lastName == selected.lastName &&
            candidate.firstName == selected.firstName;
      } on StateError {
        return false;
      }
    }).length;
    if (matches != 1) {
      throw StateError(
        'La carte Vitale ou le bénéficiaire ne correspond plus à la lecture enregistrée. '
        'Relisez la carte, sélectionnez le bénéficiaire et enregistrez la fiche avant de réessayer. '
        'Aucune requête INSi envoyée.',
      );
    }
  }

  Future<InsiRetrievalResponse> retrieve({
    required VitaleIdentity card,
    required String pin,
    required Future<void> Function(InsiExchange) retainExchange,
  }) {
    checkCard(card);
    return _retrieve(card: card, pin: pin, retainExchange: retainExchange);
  }

  Future<InsiRetrievalResponse> retrieveWithTraits({
    required String birthLastName,
    required String firstName,
    required String sexCode,
    required String birthDate,
    String? birthPlaceCode,
    required String pin,
    required Future<void> Function(InsiExchange) retainExchange,
  }) {
    // Validate before reading the CPS or opening a network connection.
    final body = const PatientFrInsiWsIns2RequestBuilder().buildBody(
      birthLastName: birthLastName,
      firstNames: [firstName],
      sexCode: sexCode,
      birthDate: birthDate,
      birthPlaceCode: birthPlaceCode,
    );
    return _retrieve(traitsBody: body, pin: pin, retainExchange: retainExchange);
  }

  Future<InsiRetrievalResponse> retrieveWithGivenNames({
    required String birthLastName,
    required List<String> firstNames,
    required String sexCode,
    required String birthDate,
    String? birthPlaceCode,
    required String pin,
    required Future<void> Function(InsiExchange) retainExchange,
  }) {
    // Validate the complete plan before the first CPS or network operation.
    for (final firstName in PatientInsiGivenNamesSearch.plan(firstNames)) {
      const PatientFrInsiWsIns2RequestBuilder().buildBody(
        birthLastName: birthLastName, firstNames: [firstName],
        sexCode: sexCode, birthDate: birthDate, birthPlaceCode: birthPlaceCode,
      );
    }
    return PatientInsiGivenNamesSearch.run<InsiRetrievalResponse>(
      firstNames: firstNames,
      attempt: (firstName) => retrieveWithTraits(
        birthLastName: birthLastName, firstName: firstName,
        sexCode: sexCode, birthDate: birthDate, birthPlaceCode: birthPlaceCode,
        pin: pin, retainExchange: retainExchange,
      ),
      isSuccess: (response) => response.result.isSuccess,
    );
  }

  Future<InsiVerificationResponse> verify({
    required String insNumber,
    required String insKey,
    required String insOid,
    required String birthLastName,
    required String givenNames,
    required String sexCode,
    required String birthDate,
    String? birthPlaceCode,
    required String pin,
    required Future<void> Function(InsiExchange) retainExchange,
  }) {
    // Validate all inputs before configuration, CPS access or network activity.
    final body = const PatientFrInsiWsIns3RequestBuilder().buildBody(
      insNumber: insNumber, insKey: insKey, insOid: insOid,
      birthLastName: birthLastName, givenNames: givenNames,
      sexCode: sexCode, birthDate: birthDate, birthPlaceCode: birthPlaceCode,
    );
    return _execute<InsiVerificationResponse>(
      traitsBody: body, pin: pin, retainExchange: retainExchange,
      requestAction: PatientFrInsiWsIns3RequestBuilder.action,
      readResponse: readVerificationResponse,
    );
  }

  Future<InsiRetrievalResponse> _retrieve({
    VitaleIdentity? card,
    String? traitsBody,
    required String pin,
    required Future<void> Function(InsiExchange) retainExchange,
  }) => _execute<InsiRetrievalResponse>(
    card: card, traitsBody: traitsBody, pin: pin, retainExchange: retainExchange,
    requestAction: card == null ? PatientFrInsiWsIns2EnvelopeBuilder.action : action,
    readResponse: (exchange, professional) {
      final parsed = const PatientFrInsiResponseParser().parseXml(exchange.responseXml!);
      if (parsed.isFault) {
        throw StateError(
          'Le serveur INSi a refusé la demande. La fiche reste inchangée.',
        );
      }
      if (exchange.httpStatus != 200) {
        throw StateError('Réponse INSi HTTP incohérente.');
      }
      return InsiRetrievalResponse(
        id: exchange.id, xml: exchange.responseXml!,
        requestHash: InsiExchange.digest(exchange.requestXml),
        professional: professional, receivedAt: exchange.recordedAt,
        result: parsed.result!,
      );
    },
  );

  /// Pure interpretation of a completed WS_INS3 exchange, also usable offline.
  /// No patient data is updated here. A SOAP fault remains a technical error.
  static InsiVerificationResponse readVerificationResponse(
    InsiExchange exchange,
    String professional,
  ) {
    final xml = exchange.responseXml;
    if (xml == null || exchange.failure != null) {
      throw StateError('Échange de vérification INSi incomplet ou en échec.');
    }
    final parsed = const PatientFrInsiVerificationResponseParser().parseXml(xml);
    if (parsed.isFault) {
      throw StateError(
        'La vérification INSi a rencontré une faute SOAP. La fiche reste inchangée.',
      );
    }
    if (exchange.httpStatus != 200) {
      throw StateError('Réponse de vérification INSi HTTP incohérente.');
    }
    return InsiVerificationResponse(
      id: exchange.id, xml: xml,
      requestHash: InsiExchange.digest(exchange.requestXml),
      professional: professional, receivedAt: exchange.recordedAt, result: parsed,
    );
  }

  Future<T> _execute<T>({
    VitaleIdentity? card,
    String? traitsBody,
    required String pin,
    required String requestAction,
    required T Function(InsiExchange, String) readResponse,
    required Future<void> Function(InsiExchange) retainExchange,
  }) async {
    final cfg = await configuration();
    checkConfiguration(cfg);
    cfg['version'] = (await PackageInfo.fromPlatform()).version;
    if ((cfg['instance'] ?? '').isEmpty) {
      throw StateError('Enregistrez la configuration INSi.');
    }
    final lease = await CpsOperationLease.acquireAvailable();
    final client = http.Client();
    try {
      final profile = await const CpsAccessService().read(pin, lease: lease);
      if (profile.nationalId != cfg['professional'] ||
          profile.professionCode != 70) {
        throw StateError(
          'La CPS ne correspond pas au kiné configuré pour cet appel INSi.',
        );
      }
      final public = await const PatientFrInsiPkcs11SigningCertificateService()
          .getCertificate(pin: pin);
      if (public['success'] != true || public['certificateBase64'] is! String) {
        throw StateError('Certificat CPS de signature indisponible.');
      }
      final certificate = DmpWireCertificate.parse(
        public['certificateBase64'] as String,
      );
      final now = DateTime.now().toUtc();
      if (certificate.commonName != profile.nationalId ||
          !certificate.contentCommitment ||
          now.isBefore(certificate.validFrom) ||
          !now.isBefore(certificate.validUntil)) {
        throw StateError(
          'Certificat CPS différent du professionnel ou hors période de validité.',
        );
      }
      final ps =
          await PatientFrInsiPsAssertionSigningService(
            signer: _InsiSigner(pin, certificate.base64),
          ).buildSignedAssertion(
            data: PatientFrInsiPsAssertionData(
              assertionId: '_${const Uuid().v4()}',
              issueInstant: now,
              issuer: certificate.subject,
              professionalId: profile.nationalId,
              billingIdentifier: cfg['billing']!,
              activitySector: cfg['sector']!,
            ),
            x509Certificate: certificate.base64,
          );
      if (card != null) {
        List<VitaleIdentity> current;
        try {
          current = await VitaleIdentityService().readVitaleIdentities();
        } catch (_) {
          throw StateError(
            'Impossible de contrôler la carte Vitale présente dans le lecteur. '
            'Vérifiez la carte et le lecteur. Aucune requête INSi envoyée.',
          );
        }
        checkCurrentCard(card, current);
      }
      final id = const Uuid().v4();
      if (DateTime.now().toUtc().difference(now) > const Duration(minutes: 2)) {
        throw StateError(
          'Préparation de la demande expirée. Relancez la récupération.',
        );
      }
      final request = card != null
          ? buildRequest(card, cfg, ps, now, id)
          : requestAction == PatientFrInsiWsIns3RequestBuilder.action
              ? buildVerificationRequest(traitsBody!, cfg, ps, now, id)
              : buildTraitsRequest(traitsBody!, cfg, ps, now, id);
      final message = http.Request('POST', Uri.parse(endpoint))
        ..followRedirects = false
        ..headers['Content-Type'] =
            'application/soap+xml; charset=UTF-8; action="$requestAction"'
        ..body = request;
      return await PatientInsiExchangeTransport(client: client).send<T>(
        id: id, message: message,
        interpret: (exchange) => readResponse(exchange, profile.nationalId),
        retainExchange: retainExchange,
      );
    } finally {
      client.close();
      lease.release();
    }
  }

  static String buildTraitsRequest(
    String body,
    Map<String, String> cfg,
    String ps,
    DateTime now,
    String id,
  ) => _buildNoVitaleRequest(body, cfg, ps, now, id,
    PatientFrInsiWsIns2EnvelopeBuilder.action);

  static String buildVerificationRequest(
    String body,
    Map<String, String> cfg,
    String ps,
    DateTime now,
    String id,
  ) => _buildNoVitaleRequest(body, cfg, ps, now, id,
    PatientFrInsiWsIns3RequestBuilder.action);

  static String _buildNoVitaleRequest(
    String body,
    Map<String, String> cfg,
    String ps,
    DateTime now,
    String id,
    String operationAction,
  ) => const PatientFrInsiWsIns2EnvelopeBuilder().build(
    contexteLpsXml: const PatientFrInsiContexteLpsBuilder().build(
      id: const Uuid().v4(), time: now, emitter: cfg['professional'],
      idam: cfg['authorization'], idamReference: '4',
      lpsVersion: cfg['version'], instance: cfg['instance'], name: 'ABAK Companion',
    ),
    messageIdXml: const PatientFrInsiMessageIdBuilder().build(id),
    contexteBamXml: const PatientFrInsiContexteBamBuilder().build(
      id: const Uuid().v4(), time: now, emitter: cfg['professional'],
    ),
    bodyXml: body,
    psAssertionXml: ps,
    operationAction: operationAction,
    // Neither WS_INS2 nor WS_INS3 uses a Vitale assertion or coverage beneficiary.
  );

  static String buildRequest(
    VitaleIdentity card,
    Map<String, String> cfg,
    String ps,
    DateTime now,
    String id,
  ) {
    final insured = matricule(card.nir)!;
    final individual = matricule(card.certifiedNir);
    final date = cardDate(card);
    final bam = XmlDocument.parse(
      const PatientFrInsiContexteBamBuilder().build(
        id: const Uuid().v4(),
        time: now,
        emitter: cfg['professional'],
      ),
    );
    final coverage = bam.findAllElements('COUVERTURE').single;
    final b = XmlBuilder();
    b.element(
      'ASSURE',
      nest: () => b.element('Id', nest: () => b.element('Num', nest: insured)),
    );
    b.element(
      'BENEFICIAIRE',
      nest: () {
        if (individual != null) {
          b.element('Nir', nest: () => b.element('Num', nest: individual));
        }
        b.element('DateNai', nest: date);
        b.element('Rang', nest: '${card.birthOrder}');
      },
    );
    coverage.children.addAll(b.buildFragment().children.map((e) => e.copy()));
    final body = XmlBuilder();
    body.element(
      'RECVITALE',
      attributes: {'xmlns': 'http://www.cnamts.fr/INSiRecVit'},
      nest: () {
        if (individual != null) {
          body.element(
            'MatriculeIndividu',
            nest: () => body.element('NumIdentifiant', nest: individual),
          );
        }
        body.element(
          'MatriculeOD',
          nest: () => body.element('NumIdentifiant', nest: insured),
        );
        // Optional: only the known card holder's birth name, never that of a dependent.
        final name = card.insuredBirthLastName?.trim().toUpperCase();
        if (name != null && RegExp(r"^[A-Z '\-]+$").hasMatch(name)) {
          body.element('NomNaissance', nest: name);
        }
        body.element('DateNaissance', nest: date);
        body.element('RangNaissance', nest: '${card.birthOrder}');
      },
    );
    final vitale = XmlBuilder();
    vitale.element(
      'Assertion',
      attributes: {
        'xmlns': 'urn:oasis:names:tc:SAML:2.0:assertion',
        'ID': '_${const Uuid().v4()}',
        'IssueInstant': now.toIso8601String(),
        'Version': '2.0',
      },
      nest: () {
        vitale.element(
          'Issuer',
          attributes: {'Format': ''},
          nest: cfg['billing'],
        );
        vitale.element(
          'Subject',
          nest: () => vitale.element(
            'NameID',
            attributes: {'NameQualifier': 'VITALE'},
            nest: card.cardSerial,
          ),
        );
      },
    );
    return const PatientFrInsiWsIns2EnvelopeBuilder().build(
      contexteLpsXml: const PatientFrInsiContexteLpsBuilder().build(
        id: const Uuid().v4(),
        time: now,
        emitter: cfg['professional'],
        idam: cfg['authorization'],
        idamReference: '4',
        lpsVersion: cfg['version'],
        instance: cfg['instance'],
        name: 'ABAK Companion',
      ),
      messageIdXml: const PatientFrInsiMessageIdBuilder().build(id),
      contexteBamXml: bam.toXmlString(),
      bodyXml: body.buildDocument().toXmlString(),
      psAssertionXml: ps,
      operationAction: action,
      vitaleAssertionXml: vitale.buildDocument().toXmlString(),
    );
  }
}

class InsiRetrievalResponse {
  const InsiRetrievalResponse({
    required this.id,
    required this.xml,
    required this.requestHash,
    required this.professional,
    required this.receivedAt,
    required this.result,
  });
  final String id, xml, requestHash, professional;
  final DateTime receivedAt;
  final PatientFrInsiResult result;
}

class InsiVerificationResponse {
  const InsiVerificationResponse({
    required this.id,
    required this.xml,
    required this.requestHash,
    required this.professional,
    required this.receivedAt,
    required this.result,
  });
  final String id, xml, requestHash, professional;
  final DateTime receivedAt;
  final PatientFrInsiVerificationResponse result;
}

class _InsiSigner implements PatientFrInsiPsSigner {
  _InsiSigner(this.pin, this.certificate);
  final String pin, certificate;
  @override
  Future<String> sign({required String canonicalSignedInfo}) async {
    final signature = await const MethodChannel('abak_dmp_fr')
        .invokeMethod<String>('signInsiPsAssertion', {
          'pin': pin,
          'canonicalSignedInfo': canonicalSignedInfo,
        });
    if (signature == null) throw StateError('Signature CPS absente.');
    final check = await const PatientFrInsiPsSignatureVerificationService()
        .verify(
          canonicalSignedInfo: canonicalSignedInfo,
          signatureBase64: signature,
          certificateBase64: certificate,
        );
    if (check['success'] != true || check['verified'] != true) {
      throw StateError('La signature ne correspond pas à la CPS présentée.');
    }
    return signature;
  }
}
