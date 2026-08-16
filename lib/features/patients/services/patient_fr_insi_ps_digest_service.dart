import 'package:xml/xml.dart';
import 'package:xml_crypto/xml_crypto.dart';

class PatientFrInsiPsDigestService {
  const PatientFrInsiPsDigestService();

  static const String exclusiveCanonicalizationAlgorithm =
      'http://www.w3.org/2001/10/xml-exc-c14n#';

  static const String sha256DigestAlgorithm =
      'http://www.w3.org/2001/04/xmlenc#sha256';

  String computeDigestValue(String assertionXml) {
    final document = XmlDocument.parse(assertionXml);
    final assertion = document.rootElement;

    final canonicalizer =
    SignedXml.canonicalizationAlgorithms[
    exclusiveCanonicalizationAlgorithm
    ];

    if (canonicalizer == null) {
      throw StateError(
        'Algorithme Exclusive C14N indisponible',
      );
    }

    final canonicalXml = canonicalizer.process(
      assertion,
    );

    final hashAlgorithm =
    SignedXml.hashAlgorithms[sha256DigestAlgorithm];

    if (hashAlgorithm == null) {
      throw StateError(
        'Algorithme SHA-256 indisponible',
      );
    }

    return hashAlgorithm.getHash(
      canonicalXml.toString(),
    );
  }
}