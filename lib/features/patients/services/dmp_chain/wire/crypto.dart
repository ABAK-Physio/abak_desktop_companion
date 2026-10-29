import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import 'package:xml_crypto/xml_crypto.dart';

/// Wire algorithms are explicitly the archived SEL-MP-037 2.10, A6-2 profile.
/// There is no algorithm negotiation or fallback. SHA256 seals local evidence.
class DmpWireCrypto {
  static const ds = 'http://www.w3.org/2000/09/xmldsig#';
  static const xades = 'http://uri.etsi.org/01903/v1.1.1#';
  static const c14n =
      'http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments';
  static const rsa = '${ds}rsa-sha1';
  static String digest(List<int> bytes) =>
      base64Encode(sha1.convert(bytes).bytes);
  static XmlDocument parse(String xml) {
    if (RegExp(r'<!DOCTYPE|<!ENTITY', caseSensitive: false).hasMatch(xml)) {
      throw const FormatException('Déclaration XML externe interdite.');
    }
    return XmlDocument.parse(
      xml.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
    );
  }

  static XmlElement one(XmlNode n, String local) => n.descendants
      .whereType<XmlElement>()
      .where((e) => e.name.local == local)
      .single;
  static String canonical(XmlElement node) {
    final parents = <XmlElement>[];
    XmlNode? cursor = node;
    while (cursor != null) {
      if (cursor is XmlElement) parents.add(cursor);
      cursor = cursor.parent;
    }
    final copy = node.copy();
    for (final parent in parents.reversed) {
      for (final a in parent.attributes) {
        if (a.name.qualified == 'xmlns' || a.name.prefix == 'xmlns') {
          copy.setAttribute(a.name.qualified, a.value);
        }
      }
    }
    return SignedXml.canonicalizationAlgorithms[c14n]!
        .process(parse(copy.toXmlString()).rootElement)
        .toString();
  }

  static bool verify(
    String canonical,
    DmpWireCertificate certificate,
    String value,
  ) {
    try {
      if (base64Decode(value).length != certificate.modulusBytes) return false;
      return SignedXml.signatureAlgorithms[rsa]!.verifySignature(
        canonical,
        Uint8List.fromList(utf8.encode(certificate.publicPem)),
        value,
      );
    } catch (_) {
      return false;
    }
  }
}

/// Public information only. Trust/chain/revocation come from a dated certificate
/// assessment supplied by the authentication adapter, never from CN alone.
class DmpWireCertificate {
  DmpWireCertificate._(
    this.base64,
    this.issuer,
    this.subject,
    this.serial,
    this.commonName,
    this.validFrom,
    this.validUntil,
    this.publicPem,
    this.modulusBytes,
    this.digitalSignature,
    this.contentCommitment,
    this.clientAuthentication,
  );
  final String base64, issuer, subject, serial, commonName, publicPem;
  final DateTime validFrom, validUntil;
  final int modulusBytes;
  final bool digitalSignature, contentCommitment, clientAuthentication;
  String get hash => sha256.convert(base64Decode(base64)).toString();
  factory DmpWireCertificate.parse(String encoded) {
    if (encoded.length > 22000) {
      throw const FormatException('Certificat trop volumineux.');
    }
    final bytes = base64Decode(encoded);
    final parser = ASN1Parser(bytes);
    final cert = parser.nextObject() as ASN1Sequence;
    if (parser.hasNext() || cert.elements.length != 3 || bytes.length > 16384) {
      throw const FormatException('Certificat mal formé.');
    }
    final tbs = cert.elements.first as ASN1Sequence;
    final off = tbs.elements.first.tag == 0xa0 ? 1 : 0;
    final spki = tbs.elements[off + 5] as ASN1Sequence;
    final alg = spki.elements.first as ASN1Sequence;
    if ((alg.elements.first as ASN1ObjectIdentifier).identifier !=
        '1.2.840.113549.1.1.1') {
      throw const FormatException(
        'Certificat RSA requis par le profil archivé.',
      );
    }
    final key =
        ASN1Parser(
              Uint8List.fromList(
                (spki.elements[1] as ASN1BitString).stringValue,
              ),
            ).nextObject()
            as ASN1Sequence;
    final modulus = (key.elements.first as ASN1Integer).valueAsBigInteger;
    if (modulus.bitLength < 2048 || modulus.bitLength > 4096) {
      throw const FormatException('Taille de clé RSA hors profil vérifié.');
    }
    DateTime date(ASN1Object v) => v is ASN1UtcTime
        ? v.dateTimeValue.toUtc()
        : (v as ASN1GeneralizedTime).dateTimeValue.toUtc();
    final validity = tbs.elements[off + 3] as ASN1Sequence;
    final subject = tbs.elements[off + 4] as ASN1Sequence;
    String? cn;
    for (final set in subject.elements.cast<ASN1Set>()) {
      for (final p in set.elements.cast<ASN1Sequence>()) {
        if ((p.elements.first as ASN1ObjectIdentifier).identifier ==
            '2.5.4.3') {
          if (cn != null) throw const FormatException('Sujet ambigu.');
          cn = _text(p.elements[1]);
        }
      }
    }
    bool digital = false, commitment = false, client = false;
    for (final e in tbs.elements.where((e) => e.tag == 0xa3)) {
      final extensions =
          ASN1Parser(e.valueBytes()).nextObject() as ASN1Sequence;
      final seen = <String>{};
      for (final ext in extensions.elements.cast<ASN1Sequence>()) {
        final id = (ext.elements.first as ASN1ObjectIdentifier).identifier!;
        if (!seen.add(id)) throw const FormatException('Extension dupliquée.');
        final v = ASN1Parser(
          (ext.elements.last as ASN1OctetString).valueBytes(),
        ).nextObject();
        if (id == '2.5.29.15') {
          final bits = (v as ASN1BitString).stringValue;
          digital = bits.isNotEmpty && bits.first & 0x80 != 0;
          commitment = bits.isNotEmpty && bits.first & 0x40 != 0;
        }
        if (id == '2.5.29.37') {
          client = (v as ASN1Sequence).elements
              .cast<ASN1ObjectIdentifier>()
              .any((x) => x.identifier == '1.3.6.1.5.5.7.3.2');
        }
      }
    }
    final public = base64Encode(spki.encodedBytes);
    return DmpWireCertificate._(
      base64Encode(bytes),
      _name(tbs.elements[off + 2] as ASN1Sequence),
      _name(subject),
      (tbs.elements[off] as ASN1Integer).valueAsBigInteger.toString(),
      cn ?? '',
      date(validity.elements[0]),
      date(validity.elements[1]),
      '-----BEGIN PUBLIC KEY-----\n$public\n-----END PUBLIC KEY-----',
      (modulus.bitLength + 7) ~/ 8,
      digital,
      commitment,
      client,
    );
  }
  static String? _text(ASN1Object v) => v is ASN1UTF8String
      ? v.utf8StringValue
      : v is ASN1PrintableString
      ? v.stringValue
      : null;
  static String _name(ASN1Sequence seq) {
    const labels = {
      '2.5.4.3': 'CN',
      '2.5.4.6': 'C',
      '2.5.4.7': 'L',
      '2.5.4.8': 'ST',
      '2.5.4.10': 'O',
      '2.5.4.11': 'OU',
    };
    String escape(String v) {
      final b = StringBuffer();
      for (var i = 0; i < v.length; i++) {
        final c = v[i];
        if (c == '\u0000') {
          b.write('\\00');
          continue;
        }
        if (',+"\\<>;='.contains(c) ||
            i == 0 && (c == '#' || c == ' ') ||
            i == v.length - 1 && c == ' ') {
          b.write('\\');
        }
        b.write(c);
      }
      return b.toString();
    }

    return seq.elements.reversed
        .cast<ASN1Set>()
        .map(
          (set) => set.elements
              .cast<ASN1Sequence>()
              .map((p) {
                final oid =
                        (p.elements.first as ASN1ObjectIdentifier).identifier!,
                    v = p.elements[1],
                    text = _text(v);
                return text != null && labels.containsKey(oid)
                    ? '${labels[oid]}=${escape(text)}'
                    : '$oid=#${v.encodedBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
              })
              .join('+'),
        )
        .join(',');
  }
}
