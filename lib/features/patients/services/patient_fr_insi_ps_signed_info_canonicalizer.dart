import 'package:xml/xml.dart';
import 'package:xml_crypto/xml_crypto.dart';

class PatientFrInsiPsSignedInfoCanonicalizer {
  const PatientFrInsiPsSignedInfoCanonicalizer();

  static const String exclusiveCanonicalizationAlgorithm =
      'http://www.w3.org/2001/10/xml-exc-c14n#';

  String canonicalize(String signedInfoXml) {
    final document = XmlDocument.parse(signedInfoXml);
    final signedInfo = document.rootElement;

    final canonicalizer =
    SignedXml.canonicalizationAlgorithms[
    exclusiveCanonicalizationAlgorithm
    ];

    if (canonicalizer == null) {
      throw StateError(
        'Algorithme Exclusive C14N indisponible',
      );
    }

    return canonicalizer.process(
      signedInfo,
    ).toString();
  }
}