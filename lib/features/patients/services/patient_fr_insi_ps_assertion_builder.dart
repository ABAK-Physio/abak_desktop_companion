import 'package:xml/xml.dart';

import '../models/patient_fr_insi_ps_assertion_data.dart';

class PatientFrInsiPsAssertionBuilder {
  const PatientFrInsiPsAssertionBuilder();

  static const String samlNamespace =
      'urn:oasis:names:tc:SAML:2.0:assertion';

  static const String issuerFormat =
      'urn:oasis:names:tc:SAML:1.1:nameid-format:X509SubjectName';

  String buildUnsigned(
      PatientFrInsiPsAssertionData data,
      ) {
    final builder = XmlBuilder();

    builder.element(
      'saml:Assertion',
      attributes: {
        'xmlns:saml': samlNamespace,
        'Version': '2.0',
        'ID': data.assertionId,
        'IssueInstant': data.issueInstant.toUtc().toIso8601String(),
      },
      nest: () {
        builder.element(
          'saml:Issuer',
          attributes: {
            'Format': issuerFormat,
          },
          nest: data.issuer,
        );

        builder.element(
          'saml:Subject',
          nest: () {
            builder.element(
              'saml:NameID',
              attributes: {
                'NameQualifier': 'CPS',
              },
              nest: data.professionalId,
            );
          },
        );

        builder.element(
          'saml:AttributeStatement',
          nest: () {
            _addAttribute(
              builder,
              name: 'identifiantFacturation',
              value: data.billingIdentifier,
            );

            _addAttribute(
              builder,
              name: 'secteurActivite',
              value: data.activitySector,
            );
          },
        );
      },
    );

    return builder.buildDocument().rootElement.toXmlString(
      pretty: true,
      indent: '  ',
    );
  }

  void _addAttribute(
      XmlBuilder builder, {
        required String name,
        required String value,
      }) {
    builder.element(
      'saml:Attribute',
      attributes: {
        'Name': name,
      },
      nest: () {
        builder.element(
          'saml:AttributeValue',
          nest: value,
        );
      },
    );
  }
}