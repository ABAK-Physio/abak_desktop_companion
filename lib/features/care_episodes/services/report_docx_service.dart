import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../models/report_document_data.dart';


class ReportDocxService {
  Future<Uint8List> buildDocx({
    required ReportDocumentData data,
  }) async {
    final documentXml = _buildDocumentXml(data);

    final archive = Archive()
      ..addFile(_textFile('[Content_Types].xml', _contentTypesXml))
      ..addFile(_textFile('_rels/.rels', _rootRelsXml))
      ..addFile(
        _textFile(
          'word/_rels/document.xml.rels',
          _documentRelsXml,
        ),
      )
      ..addFile(_textFile('word/document.xml', documentXml))
      ..addFile(_textFile('word/styles.xml', _stylesXml));

    final encoded = ZipEncoder().encode(archive);

    return Uint8List.fromList(encoded);
  }

  ArchiveFile _textFile(String name, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(name, bytes.length, bytes);
  }

  String _buildDocumentXml(ReportDocumentData data) {
    final buffer = StringBuffer();

    buffer.write('''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
''');

    buffer.write(_paragraph('RAPPORT', style: 'Title'));

    _writeOptionalLine(
      buffer,
      'Établissement',
      data.establishmentName,
    );

    _writeLine(
      buffer,
      'Réalisé le',
      _formatDate(data.reportDate),
    );

    _writeLine(
      buffer,
      'Imprimé le',
      _formatDate(data.printedAt),
    );

    _writeOptionalLine(
      buffer,
      'Rédacteur',
      data.authorName,
    );

    buffer.write(_paragraph('Patient', style: 'Heading1'));

    _writeLine(buffer, 'Nom', data.patientLastName);
    _writeLine(buffer, 'Prénom', data.patientFirstName);

    _writeOptionalLine(buffer, 'Sexe', data.patientSex);

    if (data.patientAgeYears != null) {
      _writeLine(
        buffer,
        'Âge',
        '${data.patientAgeYears} ans',
      );
    }

    _writeOptionalLine(
      buffer,
      'Pathologie',
      data.pathologyLabel,
    );

    if (data.careEpisodeOpenedAt != null) {
      _writeLine(
        buffer,
        'Prise en charge ouverte le',
        _formatDate(data.careEpisodeOpenedAt!),
      );
    }

    _writeOptionalLine(
      buffer,
      'Kiné référent',
      data.referringPractitionerName,
    );

    if (_hasCorrespondent(data)) {
      buffer.write(
        _paragraph(
          'Correspondant externe',
          style: 'Heading1',
        ),
      );

      _writeOptionalLine(
        buffer,
        'Nom',
        data.prescribingCorrespondentName,
      );

      _writeOptionalLine(
        buffer,
        'Profession',
        data.prescribingCorrespondentProfession,
      );

      _writeOptionalLine(
        buffer,
        'Spécialité',
        data.prescribingCorrespondentSpecialty,
      );

      _writeOptionalLine(
        buffer,
        'Adresse',
        data.prescribingCorrespondentAddressLine1,
      );

      _writeOptionalLine(
        buffer,
        'Complément',
        data.prescribingCorrespondentAddressLine2,
      );

      final locality = [
        data.prescribingCorrespondentPostalCode,
        data.prescribingCorrespondentCity,
      ]
          .where(
            (value) => value != null && value.trim().isNotEmpty,
      )
          .map((value) => value!.trim())
          .join(' ');

      if (locality.isNotEmpty) {
        _writeLine(
          buffer,
          'Ville',
          locality,
        );
      }

      _writeOptionalLine(
        buffer,
        'Email',
        data.prescribingCorrespondentEmail,
      );

      _writeOptionalLine(
        buffer,
        'Téléphone',
        data.prescribingCorrespondentPhone,
      );
    }

    buffer.write(
      _paragraph(
        data.reportTitle,
        style: 'Heading1',
      ),
    );

    if (_hasValue(data.reportText)) {
      buffer.write(
        _paragraph(data.reportText),
      );
    }

    buffer.write('''
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar
        w:top="1134"
        w:right="1134"
        w:bottom="1134"
        w:left="1134"
        w:header="708"
        w:footer="708"
        w:gutter="0"
      />
    </w:sectPr>
  </w:body>
</w:document>
''');

    return buffer.toString();
  }

  bool _hasCorrespondent(ReportDocumentData data) {
    return _hasValue(data.prescribingCorrespondentName) ||
        _hasValue(data.prescribingCorrespondentProfession) ||
        _hasValue(data.prescribingCorrespondentSpecialty) ||
        _hasValue(data.prescribingCorrespondentAddressLine1) ||
        _hasValue(data.prescribingCorrespondentAddressLine2) ||
        _hasValue(data.prescribingCorrespondentPostalCode) ||
        _hasValue(data.prescribingCorrespondentCity) ||
        _hasValue(data.prescribingCorrespondentEmail) ||
        _hasValue(data.prescribingCorrespondentPhone);
  }

  void _writeLine(
      StringBuffer buffer,
      String label,
      String value,
      ) {
    buffer.write(
      _paragraph('$label : $value'),
    );
  }

  void _writeOptionalLine(
      StringBuffer buffer,
      String label,
      String? value,
      ) {
    if (!_hasValue(value)) return;

    _writeLine(
      buffer,
      label,
      value!.trim(),
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _paragraph(
      String text, {
        String? style,
        bool bold = false,
      }) {
    final escaped = _escapeXml(
      _sanitizeForDocx(text),
    );

    final styleXml =
        '<w:pStyle w:val="${style ?? 'Normal'}"/>';

    final boldXml = bold ? '<w:b/>' : '';

    return '''
<w:p>
  <w:pPr>$styleXml</w:pPr>
  <w:r>
    <w:rPr>$boldXml</w:rPr>
    <w:t xml:space="preserve">$escaped</w:t>
  </w:r>
</w:p>
''';
  }

  static String _sanitizeForDocx(String value) {
    return value
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('−', '-')
        .replaceAll('×', 'x')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('ʼ', "'")
        .replaceAll('ʹ', "'")
        .replaceAll('＇', "'")
        .replaceAll('´', "'")
        .replaceAll('`', "'")
        .replaceAll('\u00A0', ' ')
        .trim();
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

const String _contentTypesXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
''';

const String _rootRelsXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
''';

const String _documentRelsXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship
    Id="rIdStyles"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"
    Target="styles.xml"/>
</Relationships>
''';

const String _stylesXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:rPr>
      <w:sz w:val="22"/>
    </w:rPr>
  </w:style>

  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:before="240" w:after="120"/>
    </w:pPr>
    <w:rPr>
      <w:b/>
      <w:sz w:val="28"/>
    </w:rPr>
  </w:style>

  <w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:after="240"/>
    </w:pPr>
    <w:rPr>
      <w:b/>
      <w:sz w:val="36"/>
    </w:rPr>
  </w:style>
</w:styles>
''';