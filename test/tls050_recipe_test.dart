import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/tls050_recipe.dart';

Map<String, dynamic> campaign() => {
  'schema': 1,
  'test': '0.1-050',
  'id': '12345678-1234-4234-8234-123456789abc',
  'configurationHash': 'a' * 64,
  'trustHash': 'b' * 64,
  'steps': <dynamic>[],
};
Map<String, dynamic> completed(int step) => {
  'step': step,
  'endpoint': Tls050Recipe.endpoint(step),
  'configurationHash': 'a' * 64,
  'trustHash': 'b' * 64,
  'finishedAt': '2026-11-12T10:00:00Z',
};
String request() =>
    '''<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:w="http://www.w3.org/2005/08/addressing"><s:Header><w:To>${Tls050Recipe.endpoint(1)}</w:To><w:Action>urn:hl7-org:v3:PRPA_IN201307UV02</w:Action></s:Header><s:Body><PRPA_IN201307UV02 xmlns="urn:hl7-org:v3"><value root="1.2.250.1.213.1.4.10" extension="287019143596041"/></PRPA_IN201307UV02></s:Body></s:Envelope>''';
void main() {
  test('SOAP Fault is displayed without reclassifying TLS as rejected', () {
    final summary = Tls050Recipe.responseSummary(
      utf8.encode(
        '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"><s:Body><s:Fault>'
        '<s:Code><s:Value>s:Sender</s:Value></s:Code><s:Reason><s:Text>Requête refusée</s:Text></s:Reason>'
        '</s:Fault></s:Body></s:Envelope>',
      ),
    );
    expect(summary, contains('SOAP Fault'));
    expect(summary, contains('s:Sender'));
    expect(summary, contains('Requête refusée'));
    expect(
      Tls050Recipe.describe({
        'outcome': 'http_received',
        'status': '500',
        'responseSummary': summary,
      }),
      contains('TLS acceptée'),
    );
  });
  test(
    'TD0.2 acknowledgement codes and non XML bodies are preserved honestly',
    () {
      final summary = Tls050Recipe.responseSummary(
        utf8.encode(
          '<r><acknowledgement><typeCode code="AA"/></acknowledgement>'
          '<queryAck><queryResponseCode code="OK"/></queryAck></r>',
        ),
      );
      expect(summary, contains('AA'));
      expect(summary, contains('OK'));
      expect(Tls050Recipe.responseSummary([255]), contains('non interprété'));
    },
  );
  test('only the three exact CNDA targets', () {
    expect(
      Tls050Recipe.endpoint(1),
      'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/patients',
    );
    expect(
      Tls050Recipe.endpoint(2),
      'https://dv1-dmp-lps.dmp.gouv.fr/si-dmp-server/v1/services/patients',
    );
    expect(
      Tls050Recipe.endpoint(3),
      'https://lps.dev1fake.dmp.gouv.fr/si-dmp-server/v2/services/patients',
    );
    for (final n in [-1, 0, 4, 999]) {
      expect(() => Tls050Recipe.endpoint(n), throwsStateError);
    }
  });
  test('one sequential pass without skipped or repeated steps', () {
    final c = campaign();
    for (var step = 1; step <= 3; step++) {
      Tls050Recipe.requireNext(c, step, 'a' * 64, 'b' * 64);
      expect(
        () => Tls050Recipe.requireNext(c, step + 1, 'a' * 64, 'b' * 64),
        throwsStateError,
      );
      (c['steps'] as List).add(completed(step));
      expect(
        () => Tls050Recipe.requireNext(c, step, 'a' * 64, 'b' * 64),
        throwsStateError,
      );
    }
    expect(
      () => Tls050Recipe.requireNext(c, 4, 'a' * 64, 'b' * 64),
      throwsStateError,
    );
  });
  for (final field in ['configurationHash', 'trustHash']) {
    test('changing $field forces a new campaign', () {
      final c = campaign();
      c[field] = 'c' * 64;
      expect(
        () => Tls050Recipe.requireNext(c, 1, 'a' * 64, 'b' * 64),
        throwsStateError,
      );
    });
  }
  for (final field in [
    'step',
    'endpoint',
    'configurationHash',
    'trustHash',
    'finishedAt',
  ]) {
    test('modified or unfinished previous $field is refused', () {
      final c = campaign(), s = completed(1);
      s[field] = null;
      (c['steps'] as List).add(s);
      expect(
        () => Tls050Recipe.requireNext(c, 2, 'a' * 64, 'b' * 64),
        throwsStateError,
      );
    });
  }
  test('request stays read-only with only the destination changed', () {
    for (var step = 1; step <= 3; step++) {
      final xml = Tls050Recipe.requestForStep(request(), step);
      expect(xml, contains(Tls050Recipe.endpoint(step)));
      expect(xml, contains('287019143596041'));
      expect(xml, contains('PRPA_IN201307UV02'));
      expect(xml, contains('urn:hl7-org:v3:PRPA_IN201307UV02'));
    }
  });
  for (final bad in [
    request().replaceAll('287019143596041', '277076322082910'),
    request().replaceAll('PRPA_IN201307UV02', 'PRPA_IN201301UV02'),
    request().replaceAll(
      Tls050Recipe.endpoint(1),
      'https://evil.invalid/patients',
    ),
    request().replaceAll('1.2.250.1.213.1.4.10', '1.2.250.1.213.1.4.9'),
    request().replaceFirst(
      '</s:Header>',
      '<w:To>${Tls050Recipe.endpoint(1)}</w:To></s:Header>',
    ),
  ]) {
    test('wrong patient, operation or addressing refused ${bad.hashCode}', () {
      expect(() => Tls050Recipe.requestForStep(bad, 2), throwsStateError);
    });
  }
  test('HTTP error does not claim functional success', () {
    final text = Tls050Recipe.describe({
      'outcome': 'http_received',
      'status': '500',
    });
    expect(text, contains('HTTP 500'));
    expect(text, contains('à examiner'));
    expect(text, isNot(contains('réussi')));
  });
  test(
    'only a native TLS-stage certificate rejection describes no emission',
    () {
      final text = Tls050Recipe.describe({
        'outcome': 'tls_rejected',
        'stage': 'TLS',
        'requestState': 'not_started',
        'error': 'TLS_HOSTNAME',
      });
      expect(text, contains('Aucune requête SOAP émise'));
    },
  );
  test('DNS and HTTP interruptions remain inconclusive', () {
    for (final value in [
      {'outcome': 'not_conclusive', 'stage': 'TLS', 'error': 'TLS_UNAVAILABLE'},
      {
        'outcome': 'not_conclusive',
        'stage': 'EXCHANGE',
        'error': 'HTTP_BODY_TIMEOUT',
        'tlsAccepted': 'true',
      },
    ]) {
      final text = Tls050Recipe.describe(value);
      expect(text, isNot(contains('Connexion TLS refusée')));
      expect(text, isNot(contains('Aucune requête SOAP émise')));
    }
  });
}
