import 'package:xml/xml.dart';

class PatientFrInsiPsSignatureInserter {
  const PatientFrInsiPsSignatureInserter();

  String insert({
    required String assertionXml,
    required String signatureXml,
  }) {
    final assertionDocument = XmlDocument.parse(assertionXml);
    final assertion = assertionDocument.rootElement;

    final issuerElements = assertion.childElements
        .where((element) => element.name.local == 'Issuer')
        .toList();

    if (issuerElements.length != 1) {
      throw const FormatException(
        'Assertion SAML invalide : Issuer absent ou multiple',
      );
    }

    final signatureDocument = XmlDocument.parse(signatureXml);
    final signature = signatureDocument.rootElement.copy();

    final issuer = issuerElements.single;
    final issuerIndex = assertion.children.indexOf(issuer);

    assertion.children.insert(
      issuerIndex + 1,
      signature,
    );

    return assertion.toXmlString(
      pretty: true,
      indent: '  ',
    );
  }
}