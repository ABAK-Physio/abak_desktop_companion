import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/models/patient_fr_insi_ps_assertion_data.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_assertion_builder.dart';

void main() {
  const builder = PatientFrInsiPsAssertionBuilder();

  test('buildUnsigned creates PS SAML assertion', () {
    final data = PatientFrInsiPsAssertionData(
      assertionId: '_e451e702-85aa-4c55-a083-7f02da22cc40',
      issueInstant: DateTime.utc(2026, 8, 15, 14, 0),
      issuer: 'CN=TEST PS,OU=TEST,O=TEST,C=FR',
      professionalId: '810000000000',
      billingIdentifier: '999999999',
      activitySector: 'SA07',
    );

    final xml = builder.buildUnsigned(data);

    final document = XmlDocument.parse(xml);
    final root = document.rootElement;

    XmlElement singleElement(String localName) {
      return document.descendants
          .whereType<XmlElement>()
          .singleWhere(
            (element) => element.name.local == localName,
      );
    }

    expect(root.name.local, 'Assertion');
    expect(
      root.name.namespaceUri,
      PatientFrInsiPsAssertionBuilder.samlNamespace,
    );

    expect(root.getAttribute('Version'), '2.0');
    expect(
      root.getAttribute('ID'),
      '_e451e702-85aa-4c55-a083-7f02da22cc40',
    );
    expect(
      root.getAttribute('IssueInstant'),
      '2026-08-15T14:00:00.000Z',
    );

    final issuer = singleElement('Issuer');

    expect(
      issuer.getAttribute('Format'),
      PatientFrInsiPsAssertionBuilder.issuerFormat,
    );
    expect(
      issuer.innerText.trim(),
      'CN=TEST PS,OU=TEST,O=TEST,C=FR',
    );

    final nameId = singleElement('NameID');

    expect(
      nameId.getAttribute('NameQualifier'),
      'CPS',
    );
    expect(
      nameId.innerText.trim(),
      '810000000000',
    );

    final attributes = document.descendants
        .whereType<XmlElement>()
        .where(
          (element) => element.name.local == 'Attribute',
    )
        .toList();

    expect(attributes, hasLength(2));

    final billingAttribute = attributes.singleWhere(
          (element) =>
      element.getAttribute('Name') ==
          'identifiantFacturation',
    );

    final billingValue = billingAttribute.descendants
        .whereType<XmlElement>()
        .singleWhere(
          (element) => element.name.local == 'AttributeValue',
    );

    expect(
      billingValue.innerText.trim(),
      '999999999',
    );

    final activityAttribute = attributes.singleWhere(
          (element) =>
      element.getAttribute('Name') ==
          'secteurActivite',
    );

    final activityValue = activityAttribute.descendants
        .whereType<XmlElement>()
        .singleWhere(
          (element) => element.name.local == 'AttributeValue',
    );

    expect(
      activityValue.innerText.trim(),
      'SA07',
    );

    expect(
      document.descendants
          .whereType<XmlElement>()
          .where(
            (element) => element.name.local == 'Signature',
      ),
      isEmpty,
    );
  });
}