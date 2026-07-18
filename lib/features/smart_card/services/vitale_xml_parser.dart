import 'package:xml/xml.dart';

import '../models/vitale_identity.dart';

class VitaleXmlParser {
  const VitaleXmlParser._();

  static VitaleIdentity parse(String xml) {
    final document = XmlDocument.parse(xml);

    final beneficiary = document
        .findAllElements('T_AsnBeneficiaire')
        .cast<XmlElement>()
        .first;

    final ident = beneficiary.getElement('ident');
    final amo = beneficiary.getElement('amo');

    return VitaleIdentity(
      lastName: _text(ident, 'nomUsuel'),
      firstName: _text(ident, 'prenomUsuel'),
      birthDate: _parseDate(_text(ident, 'dateNaissance')),
      sexCode: null, // sera ajouté ultérieurement
      nir: _normalizeNir(_text(amo, 'nir')),
    );
  }

  static String? _text(XmlElement? parent, String name) {
    return parent?.getElement(name)?.innerText.trim();
  }

  static DateTime? _parseDate(String? value) {
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