import 'package:abak_desktop_companion/features/dmp_dv1_access/visibility_recipe.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td33b.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31a.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31b.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/access_context.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';

void main() {
  test(
    'visibility search is scoped by explicit CNDA type, independent of other searches',
    () {
      final criteria = Dv1VisibilityRecipe.criteria('46241-6');
      expect(criteria.typeCode, '46241-6');
      expect(criteria.typeSystem, '2.16.840.1.113883.6.1');
      expect(criteria.statuses, [Dv1DocumentCriteria.approved]);
      expect(Dv1VisibilityRecipe.criteria('').typeCode, isEmpty);
      expect(() => Dv1VisibilityRecipe.criteria("46241-6'"), throwsStateError);
    },
  );
  test('case 23 identity comes from the CNDA workbook and remains a minor', () {
    Dv1AccessContext recipe(String ins) => Dv1AccessContext(
      professional: '12345678901',
      structure: '123456789',
      sector: 'SA07',
      ins: ins,
      patientLabel: Dv1VisibilityRecipe.patient,
      source: Dv1VisibilityRecipe.source,
      scenario: 'PRE_CONS_INV',
      confirmedAt: DateTime.utc(2026, 10, 29),
      birthDate: Dv1VisibilityRecipe.birth,
      minorsEnabled: true,
    );
    final value = recipe(Dv1VisibilityRecipe.ins);
    Dv1VisibilityRecipe.check(value);
    expect(value.ageAt(DateTime(2026, 10, 29)), 15);
    expect(value.offersSecret(DateTime(2026, 10, 29)), isTrue);
    expect(
      () => Dv1VisibilityRecipe.check(recipe('148115530271002')),
      throwsStateError,
    );
  });

  const rim = DmpNativeTd31b.rim;
  const target = 'urn:uuid:11111111-2222-4333-8444-555555555555';
  const ins = '123456789012345';
  const soap = 'http://www.w3.org/2003/05/soap-envelope';
  const wsa = 'http://www.w3.org/2005/08/addressing';
  const envelope =
      '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa"><s:Header><w:MessageID>old</w:MessageID><w:Action>old</w:Action><w:To>${DmpNativeTd31b.endpoint}</w:To></s:Header><s:Body/></s:Envelope>';
  String slot(String name, String value) =>
      '<rim:Slot name="$name"><rim:ValueList><rim:Value>$value</rim:Value></rim:ValueList></rim:Slot>';
  String conf(String code) =>
      '<rim:Classification id="$code" classifiedObject="$target" classificationScheme="${DmpNativeTd33b.confidentiality}" nodeRepresentation="$code">${slot('codingScheme', DmpNativeTd33b.system)}</rim:Classification>';
  String original() =>
      '<rim:ExtrinsicObject xmlns:rim="$rim" id="$target" lid="$target" status="${Dv1DocumentCriteria.approved}" objectType="urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1" mimeType="text/xml">'
      '<rim:VersionInfo versionName="3"/><rim:Name><rim:LocalizedString value="Document synthétique"/></rim:Name>'
      '${slot('hash', 'abcdef')}${slot('size', '100')}${slot('repositoryUniqueId', '2.25.99')}'
      '<rim:ExternalIdentifier id="patient" registryObject="$target" identificationScheme="${DmpNativeTd31a.patientScheme}" value="$ins^^^&amp;1.2.250.1.213.1.4.10&amp;ISO^NH"/>'
      '<rim:ExternalIdentifier id="unique" registryObject="$target" identificationScheme="${DmpNativeTd31a.uniqueScheme}" value="2.25.123"/>'
      '<rim:Classification id="type" classifiedObject="$target" classificationScheme="${DmpNativeTd31a.typeScheme}" nodeRepresentation="11506-3">${slot('codingScheme', '2.16.840.1.113883.6.1')}</rim:Classification>'
      '${conf('INVISIBLE_PATIENT')}${conf('INVISIBLE_REPRESENTANTS_LEGAUX')}${conf('N')}</rim:ExtrinsicObject>';
  final now = DateTime.utc(2026, 10, 29);
  final context = Dv1AccessContext(
    professional: '12345678901',
    structure: '123456789',
    sector: 'SA07',
    ins: ins,
    patientLabel: 'SYNTHETIQUE',
    source: 'test',
    scenario: 'PRE_CONS_INV',
    confirmedAt: now,
    birthDate: '1980-01-01',
  );
  final session = DmpSession(
    id: 'synthetic',
    professional: '12345678901',
    authority: '1.2.250.1.71.4.2.1',
    structure: '123456789',
    certificateHash: '',
    contextHash: '',
    issuedAt: now,
    expiresAt: now.add(const Duration(minutes: 2)),
    nativeEvidenceJson: '{"cpsFamilyName":"TEST","cpsGivenName":"SYNTHETIQUE"}',
  );
  String build([String? metadata]) => DmpNativeTd33b.build(
    envelope,
    XmlDocument.parse(metadata ?? original()).rootElement,
    context,
    session,
    '2.25.1',
    now,
  );
  test(
    'TD3.3b preserves full metadata except patient invisibility and technical version IDs',
    () {
      final before = XmlDocument.parse(original()).rootElement;
      final request = build();
      final xml = XmlDocument.parse(request);
      final entry = xml
          .findAllElements('ExtrinsicObject', namespace: rim)
          .single;
      expect(request, isNot(contains('INVISIBLE_PATIENT')));
      expect(request, contains('INVISIBLE_REPRESENTANTS_LEGAUX'));
      expect(entry.getAttribute('lid'), target);
      expect(entry.getAttribute('id'), isNot(target));
      expect(request, contains('PreviousVersion'));
      expect(request, isNot(contains('UpdateAvailabilityStatus')));
      expect(request, isNot(contains('Deleted')));
      final after = entry.copy()
        ..children.add(
          XmlElement(XmlName('VersionInfo', 'rim'), [
            XmlAttribute(XmlName('versionName'), '4'),
          ]),
        );
      DmpNativeTd33b.verifyAfter(before, entry, after);
      for (final replacement in [
        'abcdef',
        'text/xml',
        '11506-3',
        'INVISIBLE_REPRESENTANTS_LEGAUX',
      ]) {
        final bad = XmlDocument.parse(
          after.toXmlString().replaceAll(replacement, 'CHANGED'),
        ).rootElement;
        expect(
          () => DmpNativeTd33b.verifyAfter(before, entry, bad),
          throwsStateError,
        );
      }
      final out = Platform.environment['ABAK_VISIBILITY_FIXTURES'];
      if (out != null) {
        Directory(out).createSync(recursive: true);
        File('$out/update.xml').writeAsStringSync(request);
        File('$out/before.xml').writeAsStringSync(
          '<s:Envelope xmlns:s="$soap"><s:Body><AdhocQueryResponse xmlns="${DmpNativeTd31b.query}"><rim:RegistryObjectList xmlns:rim="$rim">${original()}</rim:RegistryObjectList></AdhocQueryResponse></s:Body></s:Envelope>',
        );
      }
    },
  );
  test(
    'already visible, duplicate code, wrong authority and absent version are refused',
    () {
      for (final bad in [
        original().replaceAll(conf('INVISIBLE_PATIENT'), ''),
        original().replaceAll(
          conf('INVISIBLE_PATIENT'),
          conf('INVISIBLE_PATIENT') * 2,
        ),
        original().replaceAll(DmpNativeTd33b.system, '2.25.666'),
        original().replaceAll('versionName="3"', 'versionName=""'),
      ]) {
        expect(() => build(bad), throwsStateError);
      }
    },
  );
  test('patient and authority remain mandatory on fresh metadata', () {
    final query = envelope;
    String response(String doc) =>
        '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa"><s:Header><w:RelatesTo>old</w:RelatesTo><w:Action>${DmpNativeTd31b.action}Response</w:Action></s:Header><s:Body><AdhocQueryResponse xmlns="${DmpNativeTd31b.query}" status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success"><rim:RegistryObjectList xmlns:rim="$rim">$doc</rim:RegistryObjectList></AdhocQueryResponse></s:Body></s:Envelope>';
    DmpNativeTd33b.entry(
      query,
      DmpTd02Reply(200, response(original())),
      ins,
      '2.25.123',
    );
    for (final bad in [
      original().replaceAll(ins, '999999999999999'),
      original().replaceAll('1.2.250.1.213.1.4.10', '1.2.250.1.213.1.4.11'),
    ]) {
      expect(
        () => DmpNativeTd33b.entry(
          query,
          DmpTd02Reply(200, response(bad)),
          ins,
          '2.25.123',
        ),
        throwsStateError,
      );
    }
  });
}
