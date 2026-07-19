import 'package:xml/xml.dart';

import '../models/vitale_identity.dart';

class VitaleXmlParser {
  const VitaleXmlParser._();

  static VitaleIdentity parse(String xml) {
    try {
      final document = XmlDocument.parse(xml);

      final beneficiary = document
          .findAllElements('T_AsnBeneficiaire')
          .firstOrNull;

      if (beneficiary == null) {
        return const VitaleIdentity();
      }

      final ident = beneficiary.getElement('ident');
      final amo = beneficiary.getElement('amo');

      return VitaleIdentity(
        lastName: _readText(ident, 'nomUsuel'),
        firstName: _readText(ident, 'prenomUsuel'),
        birthDate: _readBirthDate(ident),
        sexCode: null,
        nir: _normalizeNir(_readText(amo, 'nir')),
      );
    } catch (_) {
      return const VitaleIdentity();
    }
  }

  static String? _readText(XmlElement? parent, String tag) {
    final value = parent?.getElement(tag)?.innerText.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  static DateTime? _readBirthDate(XmlElement? ident) {
    final value = _readText(ident, 'dateNaissance');

    if (value == null || value.length != 8) {
      return null;
    }

    final day = int.tryParse(value.substring(0, 2));
    final month = int.tryParse(value.substring(2, 4));
    final year = int.tryParse(value.substring(4, 8));

    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  static String? _normalizeNir(String? nir) {
    if (nir == null) {
      return null;
    }

    final normalized = nir.replaceAll(RegExp(r'\s+'), '');

    return normalized.isEmpty ? null : normalized;
  }
}