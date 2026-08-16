import 'package:xml/xml.dart';

class PatientFrInsiMessageIdBuilder {
  const PatientFrInsiMessageIdBuilder();

  String build(String messageId) {
    final value = messageId.trim();

    if (value.isEmpty) {
      throw ArgumentError.value(
        messageId,
        'messageId',
        'Le MessageID INSi ne peut pas être vide',
      );
    }

    final builder = XmlBuilder();

    builder.element(
      'MessageID',
      attributes: {
        'xmlns': 'http://www.w3.org/2005/08/addressing',
      },
      nest: value,
    );

    return builder.buildDocument().rootElement.toXmlString();
  }
}