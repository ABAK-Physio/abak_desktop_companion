import 'package:xml/xml.dart';

import '../models/patient_fr_insi_fault.dart';

class PatientFrInsiFaultParser {
  const PatientFrInsiFaultParser();

  PatientFrInsiFault parseXml(String xml) {
    final document = XmlDocument.parse(xml);

    XmlElement? firstElementByLocalName(
        Iterable<XmlNode> nodes,
        String localName,
        ) {
      final elements = nodes
          .whereType<XmlElement>()
          .where((element) => element.name.local == localName)
          .toList();

      if (elements.isEmpty) {
        return null;
      }

      return elements.first;
    }

    String? elementText(XmlElement? element) {
      if (element == null) {
        return null;
      }

      final value = element.innerText.trim();

      return value.isEmpty ? null : value;
    }

    final faultElement = firstElementByLocalName(
      document.descendants,
      'Fault',
    );

    if (faultElement == null) {
      throw const FormatException(
        'SoapFault INSi absent',
      );
    }

    final soapCodeElement = firstElementByLocalName(
      faultElement.children,
      'Code',
    );

    final codeValue = elementText(
      firstElementByLocalName(
        soapCodeElement?.children ?? const [],
        'Value',
      ),
    );

    final subcodeElement = firstElementByLocalName(
      soapCodeElement?.children ?? const [],
      'Subcode',
    );

    final subcode = elementText(
      firstElementByLocalName(
        subcodeElement?.children ?? const [],
        'Value',
      ),
    );

    final detailElement = firstElementByLocalName(
      faultElement.children,
      'Detail',
    );

    final code = elementText(
      firstElementByLocalName(
        detailElement?.children ?? const [],
        'Code',
      ),
    );

    final severity = elementText(
      firstElementByLocalName(
        detailElement?.children ?? const [],
        'Severite',
      ),
    );

    final description = elementText(
      firstElementByLocalName(
        detailElement?.children ?? const [],
        'Descriptif',
      ),
    );

    if (codeValue == null ||
        subcode == null ||
        code == null ||
        severity == null ||
        description == null) {
      throw const FormatException(
        'SoapFault INSi incomplet',
      );
    }

    return PatientFrInsiFault(
      codeValue: codeValue,
      subcode: subcode,
      code: code,
      severity: patientFrInsiFaultSeverityFromValue(severity),
      description: description,
    );
  }
}