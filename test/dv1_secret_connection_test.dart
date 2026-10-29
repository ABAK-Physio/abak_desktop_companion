import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/access_context.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td02.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';

// Serialization-only double: does not assert any real certificate/CPS validation.
class SerializationMaterial extends Fake implements DmpWireMaterial {
  SerializationMaterial(this.source);
  final DmpWireMaterial source;
  @override
  DmpWireConfiguration get configuration => source.configuration;
  @override
  String get authenticationDer => source.authenticationDer;
  @override
  void check(DmpSession session, DateTime now) {}
}

void main() {
  final now = DateTime(2026, 10, 26, 12);
  Dv1AccessContext context({String? birth = '2014-10-26', bool enabled = true,
      int majority = 18, bool secret = false}) => Dv1AccessContext(
    professional: '12345678901', structure: '123456789', sector: 'SA07',
    ins: '123456789012345', patientLabel: 'SYNTHETIQUE', source: 'fixture',
    scenario: 'PRE_MODE_CNXSC', confirmedAt: now,
    birthDate: birth, minorsEnabled: enabled, majorityAge: majority,
    secretConnection: secret,
  );

  test('anniversaire et seuil officiel déterminent la proposition', () {
    expect(context(birth: '2008-10-27').offersSecret(now), isTrue);
    expect(context(birth: '2008-10-26').offersSecret(now), isFalse);
    expect(context(birth: '2006-10-26', majority: 21).offersSecret(now), isTrue);
    expect(context(enabled: false).offersSecret(now), isFalse);
  });
  test('dates absentes, impossibles et futures refusées', () {
    for (final birth in [null, '', '2014-02-30', '2027-01-01', '2014-00-00']) {
      expect(() => context(birth: birth).ageAt(now), throwsStateError);
    }
  });
  test('secret interdit pour un majeur ou une fonction désactivée', () {
    expect(() => context(birth: '2000-01-01', secret: true).check(now), throwsStateError);
    expect(() => context(enabled: false, secret: true).check(now), throwsStateError);
    context(secret: true).check(now);
  });
  test('choix propre à la session, archivé sans qualification INS', () {
    final original = context();
    final secret = original.withSecretConnection(true);
    expect(original.secretConnection, isFalse);
    expect(secret.snapshot['recipe']['secretConnection'], isTrue);
    expect(secret.snapshot['identity'].containsKey('identity_status'), isFalse);
    expect(() => secret.check(now.add(const Duration(minutes: 10))), throwsStateError);
  });
  test('VIHF secret exact, absent en normal, droits inchangés', () {
    final certificate = File('test/fixtures/dmp_local_certificate.pem')
        .readAsStringSync().replaceAll(RegExp(r'-----[^\n]+-----|\s'), '');
    final material = DmpWireMaterial(
      configuration: const DmpWireConfiguration(endpoint: 'https://synthetic.invalid/service',
        sourceId: '2.25.123', lpsId: 'TEST', lpsName: 'TEST',
        lpsVersion: 'TEST', homologationId: 'TEST'),
      authenticationDer: certificate, signingDer: certificate,
      authenticationHash: '', signingHash: '', professional: '12345678901',
      assessmentId: 'fixture-only', assessedAt: now, validUntil: now,
      trustedAndNotRevoked: false,
    );
    final session = DmpSession(id: 'TEST', professional: '12345678901',
      authority: '2.25.123', structure: '123456789', certificateHash: '',
      contextHash: '', issuedAt: now, expiresAt: now.add(const Duration(minutes: 10)));
    Map<String, String> attributes(bool secret) {
      final xml = XmlDocument.parse(DmpWireDraft.buildVihf(
        context().snapshot, session, material, now, 'test', secretConnection: secret));
      return {for (final e in xml.descendants.whereType<XmlElement>()
        .where((e) => e.name.local == 'Attribute')) e.getAttribute('Name')!: e.innerXml};
    }
    const key = 'urn:oasis:names:tc:xspa:1.0:resource:patient:hl7:confidentiality-code';
    final normal = attributes(false), secret = attributes(true);
    expect(normal.containsKey(key), isFalse);
    expect(secret.remove(key), contains('INVISIBLE_REPRESENTANTS_LEGAUX^1.2.250.1.213.1.1.4.13'));
    expect(secret, normal);
    final recipe = context(secret: true);
    String request(Dv1AccessContext c, {String? endpoint, Map<String, dynamic>? snapshot}) =>
        DmpNativeTd02.build(snapshot ?? c.snapshot, session,
          SerializationMaterial(material), now, endpoint ?? Dv1AccessContext.endpoint,
          processingMode: 'T', accessContext: c);
    final soap = XmlDocument.parse(request(recipe));
    expect(soap.descendants.whereType<XmlElement>().where((e) =>
        e.name.local == 'Attribute' && e.getAttribute('Name') == key).length, 1);
    expect(request(context()), isNot(contains(key)));
    expect(() => request(recipe, snapshot: context().snapshot), throwsA(isA<DmpChainBlock>()));
    expect(() => request(recipe, endpoint: 'https://synthetic.invalid/production'), throwsA(isA<DmpChainBlock>()));
  });
}
