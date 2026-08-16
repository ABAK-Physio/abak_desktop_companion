import 'package:xml/xml.dart';

class PatientFrInsiPsSignedInfoBuilder {
  const PatientFrInsiPsSignedInfoBuilder();

  static const String xmlDsigNamespace =
      'http://www.w3.org/2000/09/xmldsig#';

  static const String exclusiveCanonicalizationAlgorithm =
      'http://www.w3.org/2001/10/xml-exc-c14n#';

  static const String rsaSha256Algorithm =
      'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256';

  static const String envelopedSignatureAlgorithm =
      'http://www.w3.org/2000/09/xmldsig#enveloped-signature';

  static const String sha256DigestAlgorithm =
      'http://www.w3.org/2001/04/xmlenc#sha256';

  String build({
    required String assertionId,
    required String digestValue,
  }) {
    final builder = XmlBuilder();

    builder.element(
      'ds:SignedInfo',
      attributes: {
        'xmlns:ds': xmlDsigNamespace,
      },
      nest: () {
        builder.element(
          'ds:CanonicalizationMethod',
          attributes: {
            'Algorithm': exclusiveCanonicalizationAlgorithm,
          },
        );

        builder.element(
          'ds:SignatureMethod',
          attributes: {
            'Algorithm': rsaSha256Algorithm,
          },
        );

        builder.element(
          'ds:Reference',
          attributes: {
            'URI': '#$assertionId',
          },
          nest: () {
            builder.element(
              'ds:Transforms',
              nest: () {
                builder.element(
                  'ds:Transform',
                  attributes: {
                    'Algorithm': envelopedSignatureAlgorithm,
                  },
                );

                builder.element(
                  'ds:Transform',
                  attributes: {
                    'Algorithm':
                    exclusiveCanonicalizationAlgorithm,
                  },
                );
              },
            );

            builder.element(
              'ds:DigestMethod',
              attributes: {
                'Algorithm': sha256DigestAlgorithm,
              },
            );

            builder.element(
              'ds:DigestValue',
              nest: digestValue,
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
}