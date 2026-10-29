import 'dart:io';
import 'dart:convert';
import 'package:xml/xml.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/cps/cps_profile.dart';
import 'package:abak_desktop_companion/features/dmp_local/dmp_local_lot.dart';

const situation = CpsSituation(
  number: 1,
  mode: 0,
  status: 1,
  structureName: 'CABINET M. MASSEUR0087059',
  structureId: '499700870597009',
  sector: 'SA07',
);
const michel = CpsProfile(
  nationalId: '899700870597',
  familyName: 'MASSAGE0087059',
  givenName: 'MICHEL',
  professionCode: 70,
  cardType: 0,
  situations: [situation],
);
DmpLocalLot prepareLot({bool replacement = false}) => DmpLocalLot.prepare(
  replacement: replacement,
  profile: michel,
  situation: situation,
  certificateBase64: File(
    'test/fixtures/dmp_local_certificate.pem',
  ).readAsStringSync().replaceAll(RegExp(r'-----[^\n]+-----|\s'), ''),
  cdaTemplate: File('assets/dmp_local/cda-example.xml').readAsStringSync(),
  registryTemplate: File(
    'assets/dmp_local/registry-example.xml',
  ).readAsStringSync(),
  now: DateTime.utc(2026, 10, 15, 14, 0),
  localUtcOffset: const Duration(hours: 2),
);
void main() {
  test('replacement links CDA version 2 and RPLC to accepted version 1', () {
    final lot = prepareLot(replacement: true);
    expect(lot.isReplacement, true);
    expect(lot.documentOid, isNot(DmpLocalLot.replacedUniqueId));
    final doc = XmlDocument.parse(lot.cda);
    expect(doc.rootElement.getElement('setId')!.getAttribute('root'), DmpLocalLot.replacedSetId);
    expect(doc.rootElement.getElement('versionNumber')!.getAttribute('value'), '2');
    final related = DmpLocalLot.one(doc, 'relatedDocument');
    expect(related.getAttribute('typeCode'), 'RPLC');
    expect(DmpLocalLot.one(related, 'id').getAttribute('root'), DmpLocalLot.replacedUniqueId);
    lot.verifyDigests();
    final assoc = DmpLocalLot.elements(lot.registry, 'Association').singleWhere((e) => e.getAttribute('associationType')!.endsWith(':RPLC'));
    assoc.setAttribute('targetObject', 'urn:uuid:wrong');
    expect(lot.verifyDigests, throwsFormatException);
  });
  test('ordinary deposit retains version 1 and no replacement association', () {
    final lot = prepareLot();
    expect(lot.isReplacement, false);
    expect(DmpLocalLot.elements(XmlDocument.parse(lot.cda), 'relatedDocument'), isEmpty);
    lot.verifyReplacement();
  });
  test('authorSpecialty matches the official J56 label including case', () {
    final doc = XmlDocument.parse(prepareLot().registryXml);
    final slots = doc.descendants.whereType<XmlElement>().where((e) => e.name.local == 'Slot' && e.getAttribute('name') == 'authorSpecialty').toList();
    expect(slots.length, greaterThanOrEqualTo(2));
    for (final slot in slots) {
      final values = slot.descendants.whereType<XmlElement>().where((e) => e.name.local == 'Value');
      expect(values.map((e) => e.innerText), ['G15_70^Masseur-Kinésithérapeute^1.2.250.1.213.1.1.4.5']);
    }
  });
  test('DMP certificate digest uses the official XAdES namespace', () {
    final lot = prepareLot();
    final signature = XmlDocument.parse(lot.files['signature-xades-NON-SIGNEE.xml']!);
    final digest = signature.descendants.whereType<XmlElement>().singleWhere((e) => e.name.local == 'CertDigest');
    expect(digest.childElements.map((e) => e.name.namespaceUri), everyElement('http://uri.etsi.org/01903/v1.1.1#'));
    expect(digest.childElements.first.getAttribute('Algorithm'), 'http://www.w3.org/2000/09/xmldsig#sha1');
  });
  test(
    'DV1 preparation keeps a stable source and fresh unsigned identifiers',
    () {
      final first = prepareLot();
      final second = prepareLot();
      expect(first.documentOid, isNot(second.documentOid));
      expect(first.lotOid, isNot(second.lotOid));
      expect(first.registryXml, contains(DmpLocalLot.fixtureSourceOid));
      expect(second.registryXml, contains(DmpLocalLot.fixtureSourceOid));
      expect(first.cda, contains(DmpLocalLot.title));
      expect(first.cda, isNot(contains('NE PAS DÉPOSER')));
      expect(
        jsonDecode(first.files['rapport-local.json']!)['intendedEnvironment'],
        'DV1',
      );
      expect(first.verified, false);
    },
  );
  test('canonical XML normalizes literal line endings and rejects DTDs', () {
    final lf = DmpLocalLot.parseXml('<r>a\nb</r>');
    final crlf = DmpLocalLot.parseXml('<r>a\r\nb</r>');
    expect(
      DmpLocalLot.canonical(lf.rootElement),
      DmpLocalLot.canonical(crlf.rootElement),
    );
    expect(
      () => DmpLocalLot.parseXml('<!DOCTYPE r><r/>'),
      throwsFormatException,
    );
  });
  test(
    'prepares coherent local identifiers, author and payload without physician data',
    () {
      final lot = prepareLot();
      lot.verifyDigests();
      expect(lot.cda, contains('899700870597'));
      expect(lot.cda, contains('499700870597009'));
      expect(lot.cda, isNot(contains('BACA008')));
      expect(lot.cda, isNot(contains('899900063480')));
      expect(lot.registryXml, isNot(contains('G15_10')));
      expect(lot.registryXml, contains('G15_70'));
      expect(lot.signedInfo, contains('rsa-sha1'));
      expect(lot.verified, false);
      expect(lot.files.containsKey('signature-xades-NON-SIGNEE.xml'), true);
      expect(lot.files.values.join(), isNot(contains('https://lps.dev1')));
    },
  );
  test(
    'PDT identity uses approved local birthplace without claiming confirmation',
    () {
      final lot = prepareLot();
      final doc = DmpLocalLot.parseXml(lot.cda);
      final patient = DmpLocalLot.one(doc, 'patient');
      expect(DmpLocalLot.elements(patient, 'given').map((e) => e.innerText), [
        'SYLVAIN',
        'SYLVAIN',
      ]);
      expect(
        DmpLocalLot.one(patient, 'family').getAttribute('qualifier'),
        'BR',
      );
      expect(
        DmpLocalLot.one(patient, 'county').getAttribute('nullFlavor'),
        isNull,
      );
      expect(DmpLocalLot.one(patient, 'county').innerText, '24252');
      expect(
        DmpLocalLot.one(patient, 'city').innerText,
        'Marcillac-Saint-Quentin',
      );
      expect(
        DmpLocalLot.elements(
          DmpLocalLot.one(doc, 'patientRole'),
          'id',
        ).single.getAttribute('extension'),
        '187012425258307',
      );
      expect(lot.registryXml, contains('PID-5|BONNEL^SYLVAIN^^^^^L'));
      expect(lot.registryXml, contains('PID-7|19870101'));
      expect(lot.cda, isNot(contains('0456789999')));
      expect(lot.cda, isNot(contains('LAURENCE')));
      final report = jsonDecode(lot.files['rapport-local.json']!);
      expect(report['readyForDv1'], false);
      expect(report['patientBirthPlaceKnown'], false);
      expect(report['patientBirthPlaceCode'], '24252');
      expect(report['patientBirthPlaceConfirmed'], false);
      expect(report['signatureVerified'], false);
    },
  );
  test('CDA version, performer, cabinet and XDS coding match', () {
    final lot = prepareLot();
    final doc = DmpLocalLot.parseXml(lot.cda);
    expect(
      DmpLocalLot.one(doc, 'setId').getAttribute('root'),
      startsWith('2.25.'),
    );
    expect(DmpLocalLot.one(doc, 'versionNumber').getAttribute('value'), '1');
    expect(doc.rootElement.getElement('code')!.getAttribute('code'), '34120-6');
    final performer = DmpLocalLot.one(doc, 'performer');
    expect(
      DmpLocalLot.one(
        performer,
        'standardIndustryClassCode',
      ).getAttribute('code'),
      'AMBULATOIRE',
    );
    expect(
      DmpLocalLot.one(
        performer,
        'assignedEntity',
      ).getElement('id')!.getAttribute('extension'),
      michel.nationalId,
    );
    expect(lot.registryXml, isNot(contains('Hospitalisation de jour')));
    expect(lot.registryXml, isNot(contains('27899-4')));
    expect(lot.registryXml, contains('34120-6'));
  });
  test('local CDA timestamp and UTC XDS represent the same instant', () {
    final lot = prepareLot();
    expect(lot.cda, contains('20261015160000+0200'));
    expect(lot.registryXml, contains('20261015140000'));
    expect(
      DmpLocalLot.hl7Time(
        DateTime.utc(2026, 1, 1, 23, 30),
        const Duration(hours: 1),
      ),
      '20260102003000+0100',
    );
    expect(
      DmpLocalLot.hl7Time(
        DateTime.utc(2026, 1, 1, 1),
        const Duration(hours: -5),
      ),
      '20251231200000-0500',
    );
  });
  test('CDA alteration and signed metadata alteration fail locally', () {
    final lot = prepareLot();
    expect(
      () =>
          lot.verifyDigests(cdaOverride: lot.cda.replaceAll('MICHEL', 'AUTRE')),
      throwsFormatException,
    );
    expect(
      () => lot.verifyDigests(
        signatureOverride: lot.signatureXml.replaceAll(
          '2026-10-15',
          '2026-10-16',
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => lot.verifyDigests(
        signatureOverride: lot.signatureXml.replaceAll('AA==', 'AQ=='),
      ),
      throwsFormatException,
    );
    expect(
      () => lot.verifyDigests(
        signatureOverride: lot.signatureXml.replaceAll(
          'urn:oid:${lot.documentOid}',
          'https://example.invalid/document',
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => lot.verifyDigests(
        signatureOverride: lot.signatureXml.replaceAll(
          '1.12.1.14',
          '1.12.1.15',
        ),
      ),
      throwsFormatException,
    );
  });
  test('cannot mark unsigned or different bytes verified', () {
    final lot = prepareLot();
    expect(
      () => lot.attachVerifiedSignature({'verified': true}),
      throwsFormatException,
    );
    expect(lot.verified, false);
  });
  test('generated OIDs are unique across preparations', () {
    final a = prepareLot(), b = prepareLot();
    expect(
      {
        a.documentOid,
        a.lotOid,
        a.signatureOid,
        b.documentOid,
        b.lotOid,
        b.signatureOid,
      }.length,
      6,
    );
  });
  test('issuer and serial are extracted from the certificate', () {
    final lot = prepareLot();
    final reference = CertificateReference.parse(lot.certificateBase64);
    expect(
      reference.issuer,
      'CN=899700870597,OU=Test only,O=ABAK LOCAL TEST,C=FR',
    );
    expect(BigInt.parse(reference.serial) > BigInt.zero, true);
  });
  test('foreign signer context is rejected', () {
    expect(
      () => DmpLocalLot.prepare(
        profile: const CpsProfile(
          nationalId: 'other',
          familyName: 'Other',
          givenName: 'Other',
          professionCode: 70,
          cardType: 0,
          situations: [situation],
        ),
        situation: situation,
        certificateBase64: '',
        cdaTemplate: '',
        registryTemplate: '',
      ),
      throwsFormatException,
    );
  });
}
