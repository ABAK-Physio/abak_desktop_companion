import 'dart:convert';

import 'package:xml/xml.dart';

/// Only the three PDT 2.10g targets, with the same read-only TD0.2 suffix.
/// This is not an endpoint override for any normal DMP transaction.
class Tls050Recipe {
  static const code = '0.1-050';
  static const patient = 'ANNE-LOUIS GIRODET DE ROUSSY-COEUR';
  static const ins = '287019143596041';
  static const birth = '1987-01-01';
  static const source =
      'PDT DMP ABAK Desktop Companion 2.10g — '
      'Phase 2 Tests, ligne 6, 0.1-050 ; Référentiel Patients, ligne 19, Cas1.';
  static const bases = [
    'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/',
    'https://dv1-dmp-lps.dmp.gouv.fr/si-dmp-server/v1/services/',
    'https://lps.dev1fake.dmp.gouv.fr/si-dmp-server/v2/services/',
  ];
  static String endpoint(int step) {
    if (step < 1 || step > 3) throw StateError('Étape 0.1-050 inconnue.');
    return '${bases[step - 1]}patients';
  }

  static void requireCampaign(
    Map<String, dynamic> record,
    String configurationHash,
    String trustHash,
  ) {
    if (record['schema'] != 1 ||
        record['test'] != code ||
        record['configurationHash'] != configurationHash ||
        record['trustHash'] != trustHash ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(trustHash) ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(configurationHash) ||
        !RegExp(r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$')
            .hasMatch(record['id']?.toString() ?? '')) {
      throw StateError(
        'Série 0.1-050 différente ou configuration modifiée. Préparez une nouvelle série.',
      );
    }
    final steps = record['steps'];
    if (steps is! List || steps.length > 3) {
      throw StateError('Historique 0.1-050 illisible.');
    }
    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];
      if (s is! Map ||
          s['step'] != i + 1 ||
          s['endpoint'] != endpoint(i + 1) ||
          s['trustHash'] != trustHash ||
          s['configurationHash'] != configurationHash ||
          s['finishedAt'] == null) {
        throw StateError(
          'Étape incomplète ou modifiée. Préparez une nouvelle série, sans reprise automatique.',
        );
      }
    }
  }

  static void requireNext(
    Map<String, dynamic> record,
    int step,
    String configurationHash,
    String trustHash,
  ) {
    requireCampaign(record, configurationHash, trustHash);
    if (step != (record['steps'] as List).length + 1 || step > 3) {
      throw StateError('Exécutez chaque étape une seule fois, dans l’ordre.');
    }
  }

  /// Change just the WS-Addressing destination on a request built by the
  /// existing TD0.2 builder after the authenticated TLS handshake.
  static String requestForStep(String normalRequest, int step) {
    final document = XmlDocument.parse(normalRequest);
    final envelope = document.rootElement;
    if (envelope.name.local != 'Envelope' ||
        envelope.name.namespaceUri !=
            'http://www.w3.org/2003/05/soap-envelope') {
      throw StateError('Requête SOAP 0.1-050 invalide.');
    }
    final to = envelope.descendants
        .whereType<XmlElement>()
        .where(
          (e) =>
              e.name.local == 'To' &&
              e.name.namespaceUri == 'http://www.w3.org/2005/08/addressing',
        )
        .toList();
    final bodies = envelope.childElements
        .where((e) => e.name.local == 'Body')
        .toList();
    if (to.length != 1 ||
        to.single.innerText != endpoint(1) ||
        bodies.length != 1 ||
        bodies.single.childElements.length != 1 ||
        bodies.single.childElements.single.name.local != 'PRPA_IN201307UV02') {
      throw StateError('Seul un test d’existence TD0.2 est autorisé.');
    }
    final ids = bodies.single.descendants.whereType<XmlElement>().where(
      (e) =>
          e.name.local == 'value' &&
          e.getAttribute('extension') == ins &&
          e.getAttribute('root') == '1.2.250.1.213.1.4.10',
    );
    if (ids.length != 1) throw StateError('Le Cas1 du PDT est requis.');
    to.single.children
      ..clear()
      ..add(XmlText(endpoint(step)));
    return document.toXmlString();
  }

  static String describe(Map<dynamic, dynamic> result) {
    if (result['outcome'] == 'http_received') {
      final summary = result['responseSummary'];
      return 'TLS acceptée, réponse HTTP ${result['status']} reçue. '
          '${summary is String && summary.isNotEmpty ? '$summary ' : ''}'
          'Résultat à examiner pour le PDT.';
    }
    if (result['outcome'] == 'tls_rejected' &&
        result['stage'] == 'TLS' &&
        result['requestState'] == 'not_started') {
      return 'Connexion TLS refusée (${result['error']}). Aucune requête SOAP émise. Résultat à examiner pour le PDT.';
    }
    if (result['tlsAccepted'] == 'true') {
      return 'TLS acceptée, échange HTTP non confirmé (${result['error'] ?? 'interruption'}).';
    }
    return 'Essai non concluant (${result['stage'] ?? 'préparation'} / ${result['error'] ?? 'interruption'}).';
  }

  static List<int> responseBytes(Map<String, String> result) {
    final bytes = base64Decode(result['body'] ?? '');
    if (bytes.length > 16 * 1024 * 1024) {
      throw StateError('Réponse trop volumineuse.');
    }
    return bytes;
  }

  static String responseSummary(List<int> bytes) {
    String short(String value) {
      final text = value.replaceAll(RegExp(r'\s+'), ' ').trim();
      return text.length > 500 ? '${text.substring(0, 500)}…' : text;
    }

    try {
      final document = XmlDocument.parse(utf8.decode(bytes));
      final faults = document.descendants
          .whereType<XmlElement>()
          .where(
            (e) =>
                e.name.local == 'Fault' &&
                const [
                  'http://www.w3.org/2003/05/soap-envelope',
                  'http://schemas.xmlsoap.org/soap/envelope/',
                ].contains(e.name.namespaceUri),
          )
          .toList();
      if (faults.isNotEmpty) {
        final texts = faults.first.descendants
            .whereType<XmlElement>()
            .where(
              (e) => const [
                'Value',
                'Text',
                'faultcode',
                'faultstring',
              ].contains(e.name.local),
            )
            .map((e) => short(e.innerText))
            .where((s) => s.isNotEmpty)
            .take(4);
        return 'SOAP Fault : ${texts.join(' ; ')}.';
      }
      final codes = <String>[];
      for (final element in document.descendants.whereType<XmlElement>()) {
        if (const [
          'acknowledgement',
          'queryAck',
        ].contains(element.name.local)) {
          for (final child in element.childElements) {
            if (const [
              'typeCode',
              'queryResponseCode',
            ].contains(child.name.local)) {
              final value = child.getAttribute('code');
              if (value != null) {
                codes.add('${child.name.local}=${short(value)}');
              }
            }
          }
        }
      }
      return codes.isEmpty
          ? 'Réponse XML conservée.'
          : 'Réponse SOAP : ${codes.take(4).join(', ')}.';
    } catch (_) {
      return 'Réponse conservée dans son format reçu ; contenu non interprété.';
    }
  }
}
