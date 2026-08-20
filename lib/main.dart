/*
 * ABAK Desktop Companion
 * Copyright (C) 2026 ABAK Metrics
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xml/xml.dart';

import 'features/patients/models/patient_fr_insi_ps_assertion_data.dart';
import 'features/patients/services/patient_fr_insi_contexte_bam_builder.dart';
import 'features/patients/services/patient_fr_insi_contexte_lps_builder.dart';
import 'features/patients/services/patient_fr_insi_message_id_builder.dart';
import 'features/patients/services/patient_fr_insi_pkcs11_object_service.dart';
import 'features/patients/services/patient_fr_insi_ws_ins2_envelope_builder.dart';
import 'features/patients/services/patient_fr_insi_ws_ins2_request_builder.dart';
import 'generated/l10n.dart';
import 'app.dart';
import 'core/database/database_service.dart';
import 'features/import_export/data/import_session_repository.dart';
import 'features/local_exchange/services/airdrop_import_watcher.dart';
import 'features/local_exchange/services/local_exchange_server.dart';
import 'features/maintenance/data/database_backup_repository.dart';
import 'features/maintenance/services/local_backup_cleanup_service.dart';
import 'features/patients/services/patient_purge_service.dart';
import 'core/ui/app_messenger.dart';
import 'features/patients/services/patient_fr_insi_pkcs11_diagnostic_service.dart';
import 'features/patients/services/patient_fr_insi_pkcs11_login_service.dart';
import 'core/speech/abak_whisper_speech_provider.dart';
import 'core/speech/speech_to_text_provider_registry.dart';
import 'features/patients/services/patient_fr_insi_pkcs11_signing_certificate_service.dart';
import 'features/patients/services/patient_fr_insi_pkcs11_test_signature_service.dart';
import 'features/patients/services/patient_fr_insi_ps_method_channel_signer.dart';
import 'features/patients/services/patient_fr_insi_ps_signed_info_builder.dart';
import 'features/patients/services/patient_fr_insi_ps_signed_info_canonicalizer.dart';
import 'features/patients/services/patient_fr_insi_ps_signature_verification_service.dart';
import 'features/patients/services/patient_fr_insi_ps_assertion_signing_service.dart';
import 'features/patients/services/patient_fr_insi_ws_ins2_transport_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final diagnostic =
    await const PatientFrInsiPkcs11DiagnosticService().diagnose();

    debugPrint(
      '🔐 Diagnostic PKCS#11 : $diagnostic',
    );

    final loginResult =
    await const PatientFrInsiPkcs11LoginService().login(
      pin: '1234',
    );

    debugPrint(
      '🔐 Login PKCS#11 : $loginResult',
    );

    final objects =
    await const PatientFrInsiPkcs11ObjectService().listObjects(
      pin: '1234',
    );

    debugPrint(
      '🔐 Objets PKCS#11 : $objects',
    );

    final certificates =
    (objects['certificates'] as List)
        .cast<Map<dynamic, dynamic>>();

    for (final certificate in certificates) {
      final label = certificate['label'] as String;
      final certificateBase64 =
      certificate['certificateBase64'] as String;

      final fileName = label.contains('Signature')
          ? '/tmp/abak_cps_signature.der'
          : '/tmp/abak_cps_authentication.der';

      await File(fileName).writeAsBytes(
        base64Decode(certificateBase64),
      );

      debugPrint(
        '🔐 Certificat exporté : '
            '$label → $fileName',
      );
    }

    final signingCertificate =
    await const PatientFrInsiPkcs11SigningCertificateService()
        .getCertificate(
      pin: '1234',
    );

    debugPrint(
      '🔐 Certificat signature CPS : '
          '{success: ${signingCertificate['success']}, '
          'label: ${signingCertificate['label']}, '
          'id: ${signingCertificate['id']}, '
          'certificateLength: ${signingCertificate['certificateLength']}}',
    );

    final testSignature =
    await const PatientFrInsiPkcs11TestSignatureService().sign(
      pin: '1234',
    );

    debugPrint(
      '🔐 Signature CPS de test : '
          '{success: ${testSignature['success']}, '
          'step: ${testSignature['step']}, '
          'keyLabel: ${testSignature['keyLabel']}, '
          'mechanism: ${testSignature['mechanism']}, '
          'signatureLength: ${testSignature['signatureLength']}}',
    );

    const signedInfoBuilder =
    PatientFrInsiPsSignedInfoBuilder();

    const signedInfoCanonicalizer =
    PatientFrInsiPsSignedInfoCanonicalizer();

    const psSigner =
    PatientFrInsiPsMethodChannelSigner();

    final signedInfoXml = signedInfoBuilder.build(
      assertionId: '_e451e702-85aa-4c55-a083-7f02da22cc40',
      digestValue: 'TEST_DIGEST_BASE64',
    );

    final canonicalSignedInfo =
    signedInfoCanonicalizer.canonicalize(
      signedInfoXml,
    );

    final signatureValue = await psSigner.sign(
      canonicalSignedInfo: canonicalSignedInfo,
    );

    debugPrint(
      '🔐 Signature INSi réelle : '
          'length=${signatureValue.length}',
    );

    final verification =
    await const PatientFrInsiPsSignatureVerificationService().verify(
      canonicalSignedInfo: canonicalSignedInfo,
      signatureBase64: signatureValue,
      certificateBase64:
      signingCertificate['certificateBase64'] as String,
    );

    debugPrint(
      '🔐 Vérification signature INSi : $verification',
    );

    const realAssertionSigningService =
    PatientFrInsiPsAssertionSigningService();

    final realAssertionData = PatientFrInsiPsAssertionData(
      assertionId: '_abak-test-insi-ps-0001',
      issueInstant: DateTime.now().toUtc(),
      issuer:
      'SN=MASSAGE0087058+CN=899700870589+GN=MICHEL,'
          'title=Masseur-Kinésithérapeute,C=FR',
      professionalId: '899700870589',
      billingIdentifier: '991130972',
      activitySector: 'SA07',
    );

    final signedAssertionXml =
    await realAssertionSigningService.buildSignedAssertion(
      data: realAssertionData,
      x509Certificate:
      signingCertificate['certificateBase64'] as String,
    );

    debugPrint(
      '🔐 Assertion PS signée complète : '
          'length=${signedAssertionXml.length}',
    );

    const contexteBamBuilder =
    PatientFrInsiContexteBamBuilder();
    const contexteLpsBuilder =
    PatientFrInsiContexteLpsBuilder();
    const messageIdBuilder =
    PatientFrInsiMessageIdBuilder();
    const requestBuilder =
    PatientFrInsiWsIns2RequestBuilder();
    const envelopeBuilder =
    PatientFrInsiWsIns2EnvelopeBuilder();

    final now = DateTime.now().toUtc();

    final contexteBamXml = contexteBamBuilder.build(
      id: 'bam-test-cps',
      time: now,
      emitter: '899900063480',
    );

    final contexteLpsXml = contexteLpsBuilder.build(
      id: 'lps-test-cps',
      time: now,
      emitter: '899900063480',
      idam: 'NumAutorisation',
      idamReference: '4',
      lpsVersion: '01.00',
      instance: 'test-instance',
      name: 'ABAK',
    );

    final messageIdXml = messageIdBuilder.build(
      'e451e702-85aa-4c55-a083-7f02da22cc40',
    );

    final bodyXml = requestBuilder.buildBody(
      birthLastName: 'ADRDEUX',
      firstNames: const ['LAURENT'],
      sexCode: 'M',
      birthDate: '1981-01-01',
    );

    final completeEnvelopeXml = envelopeBuilder.build(
      contexteLpsXml: contexteLpsXml,
      messageIdXml: messageIdXml,
      contexteBamXml: contexteBamXml,
      bodyXml: bodyXml,
      psAssertionXml: signedAssertionXml,
    );

    debugPrint(
      '🔐 Enveloppe WS_INS2 avec Assertion CPS : '
          'length=${completeEnvelopeXml.length}',
    );

    final envelopeDocument = XmlDocument.parse(
      completeEnvelopeXml,
    );

    XmlElement singleEnvelopeElement(
        String localName,
        ) {
      return envelopeDocument.descendants
          .whereType<XmlElement>()
          .singleWhere(
            (element) => element.name.local == localName,
      );
    }

    final security = singleEnvelopeElement(
      'Security',
    );

    final assertion = singleEnvelopeElement(
      'Assertion',
    );

    final signatureValueElement = singleEnvelopeElement(
      'SignatureValue',
    );

    final certificateElement = singleEnvelopeElement(
      'X509Certificate',
    );

    final referenceElement = singleEnvelopeElement(
      'Reference',
    );

    final requestElement = singleEnvelopeElement(
      'RECSANSVITALE',
    );

    final assertionId = assertion.getAttribute(
      'ID',
    );

    final referenceUri = referenceElement.getAttribute(
      'URI',
    );

    final envelopeIsValid =
        security.name.namespaceUri ==
            PatientFrInsiWsIns2EnvelopeBuilder.wsSecurityNamespace &&
            assertionId != null &&
            referenceUri == '#$assertionId' &&
            signatureValueElement.innerText.trim().isNotEmpty &&
            certificateElement.innerText.trim().isNotEmpty &&
            requestElement.name.namespaceUri ==
                'http://www.cnamts.fr/INSiRecSans';

    debugPrint(
      '🔐 Contrôle enveloppe WS_INS2 : '
          '{valid: $envelopeIsValid, '
          'assertionId: $assertionId, '
          'referenceUri: $referenceUri, '
          'signatureLength: ${signatureValueElement.innerText.trim().length}, '
          'certificateLength: ${certificateElement.innerText.trim().length}}',
    );

    final finalSignedInfoElement = envelopeDocument.descendants
        .whereType<XmlElement>()
        .singleWhere(
          (element) => element.name.local == 'SignedInfo',
    );

    final finalSignatureValue = envelopeDocument.descendants
        .whereType<XmlElement>()
        .singleWhere(
          (element) => element.name.local == 'SignatureValue',
    )
        .innerText
        .trim();

    final finalCertificateBase64 = envelopeDocument.descendants
        .whereType<XmlElement>()
        .singleWhere(
          (element) => element.name.local == 'X509Certificate',
    )
        .innerText
        .trim();

    final finalCanonicalSignedInfo =
    const PatientFrInsiPsSignedInfoCanonicalizer().canonicalize(
      finalSignedInfoElement.toXmlString(),
    );

    final finalVerification =
    await const PatientFrInsiPsSignatureVerificationService().verify(
      canonicalSignedInfo: finalCanonicalSignedInfo,
      signatureBase64: finalSignatureValue,
      certificateBase64: finalCertificateBase64,
    );

    debugPrint(
      '🔐 Vérification signature extraite enveloppe finale : '
          '$finalVerification',
    );

    if (!envelopeIsValid) {
      throw StateError(
        'Enveloppe WS_INS2 locale invalide',
      );
    }

    final transportService =
    PatientFrInsiWsIns2TransportService();

    try {
      debugPrint(
        '🌐 Envoi WS_INS2 vers environnement de qualification...',
      );

      final response = await transportService.send(
        envelopeXml: completeEnvelopeXml,
      );

      debugPrint(
        '🌐 Réponse WS_INS2 : '
            'statusCode=${response.statusCode}, '
            'bodyLength=${response.body.length}',
      );

      debugPrint(
        '🌐 Content-Type réponse : '
            '${response.headers['content-type']}',
      );

      debugPrint(
        '🌐 Corps réponse WS_INS2 :',
      );

      debugPrint(
        response.body,
        wrapWidth: 1024,
      );
    } finally {
      transportService.close();
    }
  } catch (e) {
    debugPrint(
      '❌ Test PKCS#11 : $e',
    );
  }

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1400, 900),
    minimumSize: Size(1200, 800),
    center: true,
    title: 'ABAK Desktop Companion',
  );

  await DatabaseService.database;

  SpeechToTextProviderRegistry.register(
    AbakWhisperSpeechProvider(),
  );

  try {
    await LocalExchangeServer.instance.start();
  } on LocalExchangeServerAlreadyRunningException {
    runApp(const _AlreadyRunningApp());

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    return;
  }

  AirDropImportWatcher.instance.onImportMessage = (message) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  };

  await AirDropImportWatcher.instance.start();

  debugPrint(
    '📡 serveur local ABAK actif sur le port '
    '${LocalExchangeServer.instance.port}',
  );

  await ImportSessionRepository().recoverInterruptedSessions();

  final purgeResult = await PatientPurgeService().purgeArchivedPatients();

  debugPrint(
    '🧹 purge patients : '
    '${purgeResult.deletedPatients} supprimé(s)',
  );

  final backupCleanupResult = await LocalBackupCleanupService(
    repository: DatabaseBackupRepository(),
  ).cleanupOldBackups();

  debugPrint(
    '🧹 purge sauvegardes SQLite : '
    '${backupCleanupResult.deletedCount} supprimée(s), '
    '${backupCleanupResult.keptCount} conservée(s)',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const AbakDesktopApp());
}

class _AlreadyRunningApp extends StatelessWidget {
  const _AlreadyRunningApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ABAK Desktop Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const _AlreadyRunningScreen(),
    );
  }
}

class _AlreadyRunningScreen extends StatelessWidget {
  const _AlreadyRunningScreen();

  Future<void> _closeApplication() async {
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    s.main_alreadyRunningTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.main_alreadyRunningMessage,
                    textAlign: TextAlign.center,
                  ),
                  FilledButton(
                    onPressed: _closeApplication,
                    child: Text(s.main_close),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}