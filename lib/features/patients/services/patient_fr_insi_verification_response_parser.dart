import 'package:xml/xml.dart';

enum PatientFrInsiVerificationStatus { verified, notVerified, technicalError }

class PatientFrInsiVerificationResponse {
  final PatientFrInsiVerificationStatus status;
  final String? codeCr;
  final String? label;
  final String? soapCode;
  final String? soapSubcode;

  const PatientFrInsiVerificationResponse._(
    this.status, {
    this.codeCr,
    this.label,
    this.soapCode,
    this.soapSubcode,
  });

  bool get isVerified => status == PatientFrInsiVerificationStatus.verified;
  bool get isFault => status == PatientFrInsiVerificationStatus.technicalError;
}

/// Reads WS_INS3 only. Does not retrieve, attach or qualify an identity.
/// Contract: INSiLot2_RESULTAT_UNITAIRE_V00.01.xsd, package 05.00.00.
class PatientFrInsiVerificationResponseParser {
  const PatientFrInsiVerificationResponseParser();

  static const _soap = 'http://www.w3.org/2003/05/soap-envelope';
  static const _result = 'http://www.cnamts.fr/INSiLot2/REPUnitaire';
  static const _common = 'http://www.cnamts.fr/MRA/CommunLot';

  PatientFrInsiVerificationResponse parseXml(String xml) {
    if (RegExp(r'<!\s*(?:DOCTYPE|ENTITY)\b', caseSensitive: false).hasMatch(xml)) {
      throw const FormatException('Déclaration XML non prise en charge.');
    }
    final root = XmlDocument.parse(xml).rootElement;
    if (root.name.local != 'Envelope' || root.name.namespaceUri != _soap) {
      throw const FormatException('Enveloppe SOAP 1.2 INSi absente.');
    }
    final body = _one(root, 'Body', _soap);
    final payloads = body.childElements.toList();
    if (payloads.length != 1) {
      throw const FormatException('Corps de réponse INSi absent ou multiple.');
    }
    final payload = payloads.single;
    if (payload.name.local == 'Fault' && payload.name.namespaceUri == _soap) {
      return _fault(payload);
    }
    if (payload.name.local != 'ResultatUnitaire' ||
        payload.name.namespaceUri != _result) {
      throw const FormatException('Résultat de vérification unitaire INSi absent.');
    }

    // A technical failure embedded in the result must never become a success,
    // even if the surrounding business report contains 00.
    final fault = _optional(payload, 'SiSoapFaultUnitaire', _result);
    if (fault != null) {
      return _fault(fault);
    }
    final report = _one(_one(payload, 'CrUnitaire', _result), 'CR', _common);
    final code = _text(_one(report, 'Code', _common));
    final label = _text(_optional(report, 'Libelle', _common));
    final status = switch (code) {
      '00' => PatientFrInsiVerificationStatus.verified,
      '01' => PatientFrInsiVerificationStatus.notVerified,
      _ => throw const FormatException('Code de vérification INSi absent ou inconnu.'),
    };
    return PatientFrInsiVerificationResponse._(status, codeCr: code, label: label);
  }

  static PatientFrInsiVerificationResponse _fault(XmlElement fault) {
    final code = _one(fault, 'Code', _soap);
    final value = _text(_one(code, 'Value', _soap));
    if (value == null) {
      throw const FormatException('Code de faute SOAP INSi vide.');
    }
    final subcode = _optional(code, 'Subcode', _soap);
    final reason = _one(fault, 'Reason', _soap);
    final texts = reason.childElements
        .where((e) => e.name.local == 'Text' && e.name.namespaceUri == _soap)
        .map(_text)
        .whereType<String>()
        .toList();
    if (texts.isEmpty) {
      throw const FormatException('Motif de faute SOAP INSi absent.');
    }
    return PatientFrInsiVerificationResponse._(
      PatientFrInsiVerificationStatus.technicalError,
      soapCode: value,
      soapSubcode: subcode == null ? null : _text(_one(subcode, 'Value', _soap)),
      label: texts.first,
    );
  }

  static XmlElement _one(XmlElement parent, String local, String namespace) {
    final element = _optional(parent, local, namespace);
    if (element == null) {
      throw FormatException('Réponse de vérification INSi : $local absent.');
    }
    return element;
  }

  static XmlElement? _optional(XmlElement parent, String local, String namespace) {
    final elements = parent.childElements.where((e) => e.name.local == local).toList();
    if (elements.isEmpty) {
      return null;
    }
    if (elements.length != 1 || elements.single.name.namespaceUri != namespace) {
      throw FormatException('Réponse de vérification INSi : $local ambigu ou invalide.');
    }
    return elements.single;
  }

  static String? _text(XmlElement? element) {
    if (element == null) {
      return null;
    }
    if (element.childElements.isNotEmpty) {
      throw const FormatException('Contenu XML inattendu dans une valeur INSi.');
    }
    final value = element.innerText.trim();
    return value.isEmpty ? null : value;
  }
}
