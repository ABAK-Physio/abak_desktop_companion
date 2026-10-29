import 'dart:convert';
import 'package:abak_vitale/abak_vitale.dart';
import 'package:crypto/crypto.dart';
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

/// CNDA package 05.00.01, WS_INS1, CPx level-2 assertion.
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

  Future<InsiRetrievalResponse> retrieve({
    required VitaleIdentity card,
    required String pin,
  }) async {
    checkCard(card);
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
      final id = const Uuid().v4();
      if (DateTime.now().toUtc().difference(now) > const Duration(minutes: 2)) {
        throw StateError(
          'Préparation de la demande expirée. Relancez la récupération.',
        );
      }
      final request = buildRequest(card, cfg, ps, now, id);
      final message = http.Request('POST', Uri.parse(endpoint))
        ..followRedirects = false
        ..headers['Content-Type'] =
            'application/soap+xml; charset=UTF-8; action="$action"'
        ..body = request;
      // One explicit attempt, no retry and no redirect carrying patient data.
      final response = await (() async {
        final stream = await client.send(message);
        final bytes = <int>[];
        await for (final chunk in stream.stream) {
          if (bytes.length + chunk.length > 2 * 1024 * 1024) {
            throw StateError('Réponse INSi trop volumineuse.');
          }
          bytes.addAll(chunk);
        }
        if (stream.statusCode != 200 && stream.statusCode != 500) {
          throw StateError(
            'INSi a répondu HTTP ${stream.statusCode}. La fiche reste inchangée.',
          );
        }
        final xml = utf8.decode(bytes);
        if (xml.contains('<!DOCTYPE') || xml.contains('<!ENTITY')) {
          throw StateError('Réponse INSi non prise en charge.');
        }
        final parsed = const PatientFrInsiResponseParser().parseXml(xml);
        if (parsed.isFault) {
          throw StateError(
            'Le serveur INSi a refusé la demande. La fiche reste inchangée.',
          );
        }
        if (stream.statusCode != 200) {
          throw StateError('Réponse INSi HTTP incohérente.');
        }
        return InsiRetrievalResponse(
          id: id,
          xml: xml,
          requestHash: sha256.convert(utf8.encode(request)).toString(),
          professional: profile.nationalId,
          receivedAt: DateTime.now().toUtc(),
          result: parsed.result!,
        );
      })().timeout(const Duration(seconds: 45));
      return response;
    } finally {
      client.close();
      lease.release();
    }
  }

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
