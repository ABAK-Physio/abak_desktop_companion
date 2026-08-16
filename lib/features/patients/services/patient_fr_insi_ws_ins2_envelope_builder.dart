import 'package:xml/xml.dart';

class PatientFrInsiWsIns2EnvelopeBuilder {
  const PatientFrInsiWsIns2EnvelopeBuilder();

  static const String soapNamespace =
      'http://www.w3.org/2003/05/soap-envelope';

  static const String addressingNamespace =
      'http://www.w3.org/2005/08/addressing';

  static const String action =
      'urn:ServiceIdentiteCertifiee:1.0.0:rechercherInsAvecTraitsIdentite';

  String build({
    required String contexteLpsXml,
    required String messageIdXml,
    required String contexteBamXml,
    required String bodyXml,
  }) {
    final contexteLps = XmlDocument.parse(contexteLpsXml).rootElement;
    final messageId = XmlDocument.parse(messageIdXml).rootElement;
    final contexteBam = XmlDocument.parse(contexteBamXml).rootElement;
    final body = XmlDocument.parse(bodyXml).rootElement;

    final builder = XmlBuilder();

    builder.element(
      'soap:Envelope',
      attributes: {
        'xmlns:soap': soapNamespace,
        'xmlns:add': addressingNamespace,
      },
      nest: () {
        builder.element(
          'soap:Header',
          nest: () {
            builder.xml(contexteBam.toXmlString());

            builder.element(
              'add:Action',
              nest: action,
            );

            builder.xml(contexteLps.toXmlString());
            builder.xml(messageId.toXmlString());
          },
        );

        builder.element(
          'soap:Body',
          nest: () {
            builder.xml(body.toXmlString());
          },
        );
      },
    );

    return builder.buildDocument().toXmlString(
      pretty: true,
      indent: '  ',
    );
  }
}