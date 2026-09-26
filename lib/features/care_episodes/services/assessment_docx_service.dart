import 'clinical_document_attachments_docx.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../../generated/l10n.dart';

import '../models/assessment_document_data.dart';

class AssessmentDocxService {
  Future<Uint8List> buildDocx({
    required List<Uint8List> chartPngBytes,
    required AssessmentDocumentData data,
  }) async {
    final documentXml = _buildDocumentXml(data);

    final archive = Archive()
      ..addFile(_textFile('[Content_Types].xml', _contentTypesXml))
      ..addFile(_textFile('_rels/.rels', _rootRelsXml))
      ..addFile(
        _textFile(
          'word/_rels/document.xml.rels',
          _buildDocumentRelsXml(chartPngBytes.length),
        ),
      )
      ..addFile(_textFile('word/document.xml', documentXml))
      ..addFile(_textFile('word/styles.xml', _stylesXml));

    for (var i = 0; i < chartPngBytes.length; i++) {
      final imageBytes = chartPngBytes[i];

      archive.addFile(
        ArchiveFile(
          'word/media/image${i + 1}.png',
          imageBytes.length,
          imageBytes,
        ),
      );
    }

    final encoded = ZipEncoder().encode(archive);

    return Uint8List.fromList(encoded);
  }

  ArchiveFile _textFile(String name, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(name, bytes.length, bytes);
  }

  String _buildDocumentXml(AssessmentDocumentData data) {
    final buffer = StringBuffer();

    buffer.write('''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  <w:body>
''');

    buffer.write(_paragraph(S.current.assessmentDocxService_title, style: 'Title'));

    _writeOptionalLine(buffer, S.current.assessmentDocxService_establishment, data.establishmentName);

    _writeLine(buffer, S.current.assessmentDocxService_performed, _formatDate(data.assessmentDate));

    _writeLine(buffer, S.current.assessmentDocxService_printed, _formatDate(data.printedAt));

    _writeOptionalLine(buffer, S.current.assessmentDocxService_author, data.authorName);

    _writeOptionalLine(buffer, S.current.assessmentDocxService_recipients, data.recipientText);

    buffer.write(_paragraph(S.current.assessmentDocxService_patient, style: 'Heading1'));

    _writeLine(buffer, S.current.assessmentDocxService_surname, data.patientLastName);
    _writeLine(buffer, S.current.assessmentDocxService_firstname, data.patientFirstName);

    _writeOptionalLine(buffer, S.current.assessmentDocxService_sex, data.patientSex);

    if (data.patientAgeYears != null) {
      _writeLine(buffer, S.current.assessmentDocxService_age, S.current.assessmentDocxService_years(data.patientAgeYears!));
    }

    _writeOptionalLine(buffer, S.current.assessmentDocxService_pathology, data.pathologyLabel);

    if (data.careEpisodeOpenedAt != null) {
      _writeLine(
        buffer,
        S.current.assessmentDocxService_opened,
        _formatDate(data.careEpisodeOpenedAt!),
      );
    }

    _writeOptionalLine(buffer, S.current.assessmentDocxService_practitioner, data.referringPractitionerName);

    buffer.write(_paragraph(S.current.assessmentDocxService_information, style: 'Heading1'));

    _writeOptionalLine(buffer, S.current.assessmentDocxService_dominance, data.dominantSide);

    _writeOptionalLine(buffer, S.current.assessmentDocxService_profession, data.profession);

    _writeOptionalLine(buffer, S.current.assessmentDocxService_sport, data.sport);

    if (_hasValue(data.heightCm)) {
      _writeLine(buffer, S.current.assessmentDocxService_height, S.current.assessmentDocxService_centimetres(data.heightCm!.trim()));
    }

    if (_hasValue(data.weightKg)) {
      _writeLine(buffer, S.current.assessmentDocxService_weight, S.current.assessmentDocxService_kilograms(data.weightKg!.trim()));
    }

    buffer.write(_paragraph(S.current.assessmentDocxService_assessment, style: 'Heading1'));

    if (_hasValue(data.assessmentText)) {
      buffer.write(_paragraph(data.assessmentText));
    }

    buffer.write(ClinicalDocumentAttachmentsDocx().build(
      tests: data.tests,
      notes: data.notes,
      patientAgeYears: data.patientAgeYears,
      pathologyLabel: data.pathologyLabel,
    ));

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

  void _writeLine(StringBuffer buffer, String label, String value) {
    buffer.write(_paragraph('$label : $value'));
  }

  void _writeOptionalLine(StringBuffer buffer, String label, String? value) {
    if (!_hasValue(value)) return;

    _writeLine(buffer, label, value!.trim());
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _paragraph(String text, {String? style, bool bold = false}) {
    final escaped = _escapeXml(_sanitizeForDocx(text));

    final styleXml = '<w:pStyle w:val="${style ?? 'Normal'}"/>';

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
  <Default Extension="png" ContentType="image/png"/>
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

String _buildDocumentRelsXml(int imageCount) {
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    ..writeln(
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    );

  buffer.writeln(
    '  <Relationship '
    'Id="rIdStyles" '
    'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" '
    'Target="styles.xml"/>',
  );

  for (var i = 0; i < imageCount; i++) {
    final relationshipId = i + 1;
    final imageIndex = i + 1;

    buffer.writeln(
      '  <Relationship '
      'Id="rId$relationshipId" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" '
      'Target="media/image$imageIndex.png"/>',
    );
  }

  buffer.writeln('</Relationships>');

  return buffer.toString();
}

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

  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:before="180" w:after="80"/>
    </w:pPr>
    <w:rPr>
      <w:b/>
      <w:sz w:val="24"/>
    </w:rPr>
  </w:style>
</w:styles>
''';
