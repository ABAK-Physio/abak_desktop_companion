import 'package:xml/xml.dart';

class PatientFrInsiPsSignatureBuilder {
  const PatientFrInsiPsSignatureBuilder();

  static const String xmlDsigNamespace =
      'http://www.w3.org/2000/09/xmldsig#';

  String build({
    required String signedInfoXml,
    required String signatureValue,
    required String x509Certificate,
  }) {
    final signedInfo =
        XmlDocument.parse(signedInfoXml).rootElement;

    final builder = XmlBuilder();

    builder.element(
      'ds:Signature',
      attributes: {
        'xmlns:ds': xmlDsigNamespace,
      },
      nest: () {
        builder.xml(
          signedInfo.toXmlString(),
        );

        builder.element(
          'ds:SignatureValue',
          nest: signatureValue.trim(),
        );

        builder.element(
          'ds:KeyInfo',
          nest: () {
            builder.element(
              'ds:X509Data',
              nest: () {
                builder.element(
                  'ds:X509Certificate',
                  nest: x509Certificate.trim(),
                );
              },
            );
          },
        );
      },
    );

    return builder.buildDocument().rootElement.toXmlString();
  }
}