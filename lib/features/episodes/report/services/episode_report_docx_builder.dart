import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../models/episode_report_view_model.dart';

class EpisodeReportDocxBuilder {
  const EpisodeReportDocxBuilder();

  Future<Uint8List> buildDocx(EpisodeReportViewModel report) async {
    final documentXml = _buildDocumentXml(report);

    final archive = Archive()
      ..addFile(_textFile('[Content_Types].xml', _contentTypesXml))
      ..addFile(_textFile('_rels/.rels', _rootRelsXml))
      ..addFile(_textFile('word/_rels/document.xml.rels', _documentRelsXml))
      ..addFile(_textFile('word/document.xml', documentXml))
      ..addFile(_textFile('word/styles.xml', _stylesXml));

    final encoded = ZipEncoder().encode(archive);

    return Uint8List.fromList(encoded);
  }

  ArchiveFile _textFile(String name, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(name, bytes.length, bytes);
  }

  String _buildDocumentXml(EpisodeReportViewModel report) {
    final buffer = StringBuffer();

    buffer.write('''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
''');

    buffer.write(_paragraph('Rapport clinique', style: 'Title'));

    buffer.write(_paragraph('Patient', style: 'Heading1'));
    buffer.write(
      _table([
        ('Nom', report.patientDisplayName),
        ('Date de naissance', report.birthDate ?? 'Non renseigné'),
        ('Sexe', report.sex ?? 'Non renseigné'),
      ]),
    );

    if (report.episodeTitle?.trim().isNotEmpty == true) {
      buffer.write(_paragraph('Épisode', style: 'Heading1'));
      buffer.write(_paragraph(report.episodeTitle!.trim()));
    }

    buffer.write(_paragraph('Profil patient', style: 'Heading1'));
    buffer.write(
      _table([
        for (final field in report.patientProfileFields)
          if (!field.isEmpty) (field.label, field.value),
      ]),
    );

    buffer.write(_paragraph('Formulaires', style: 'Heading1'));
    for (final form in report.formSections) {
      if (form.isEmpty) continue;

      buffer.write(_paragraph(form.title, style: 'Heading2'));
      buffer.write(
        _table([
          for (final field in form.fields)
            if (!field.isEmpty) (field.label, field.value),
        ]),
      );
      buffer.write(_paragraph(''));
    }

    buffer.write(_paragraph('Résultats ABAK', style: 'Heading1'));
    for (final result in report.resultSections) {
      if (result.isEmpty) continue;

      buffer.write(_paragraph(result.title, style: 'Heading2'));

      final summary = result.summary?.trim();
      if (summary != null && summary.isNotEmpty) {
        buffer.write(_paragraph(summary));
      }

      for (final detail in result.details) {
        final value = detail.trim();
        if (value.isNotEmpty) {
          buffer.write(_paragraph(value));
        }
      }

      buffer.write(_paragraph(''));
    }

    buffer.write(_paragraph('Documents associés', style: 'Heading1'));
    if (report.documents.isEmpty) {
      buffer.write(_paragraph('Aucun document associé.'));
    } else {
      for (final document in report.documents) {
        if (document.isEmpty) continue;

        final mimeType = document.mimeType?.trim();
        final line = mimeType == null || mimeType.isEmpty
            ? document.title
            : '${document.title} · $mimeType';

        buffer.write(_paragraph(line));
      }
    }

    buffer.write(_paragraph('Notes du praticien', style: 'Heading1'));
    if (report.notes.isEmpty) {
      buffer.write(_paragraph('Aucune note associée.'));
    } else {
      for (final note in report.notes) {
        if (note.isEmpty) continue;

        buffer.write(_paragraph(note.title, style: 'Heading2'));
        buffer.write(_paragraph(note.content));
      }
    }

    buffer.write(_paragraph('Conclusion clinique', style: 'Heading1'));
    buffer.write(
      _paragraph(
        report.clinicalConclusion?.trim().isNotEmpty == true
            ? report.clinicalConclusion!.trim()
            : 'Aucune conclusion clinique renseignée.',
      ),
    );

    buffer.write('''
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134" w:header="708" w:footer="708" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>
''');

    return buffer.toString();
  }

  String _table(List<(String, String)> rows) {
    final buffer = StringBuffer();

    if (rows.isEmpty) {
      return _paragraph('Aucune donnée disponible.');
    }

    buffer.write(_tableStart([2600, 6400]));

    for (final row in rows) {
      buffer.write(
        _tableRow([
          _cellText(row.$1, bold: true, width: 2600),
          _cellText(_displayValue(row.$2), width: 6400),
        ]),
      );
    }

    buffer.write(_tableEnd());

    return buffer.toString();
  }

  String _tableStart(List<int> widths) {
    final gridCols = widths.map((w) => '<w:gridCol w:w="$w"/>').join();

    return '''
<w:tbl>
  <w:tblPr>
    <w:tblW w:w="0" w:type="auto"/>
    <w:tblLayout w:type="fixed"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="4" w:space="0" w:color="BFBFBF"/>
      <w:left w:val="single" w:sz="4" w:space="0" w:color="BFBFBF"/>
      <w:bottom w:val="single" w:sz="4" w:space="0" w:color="BFBFBF"/>
      <w:right w:val="single" w:sz="4" w:space="0" w:color="BFBFBF"/>
      <w:insideH w:val="single" w:sz="4" w:space="0" w:color="BFBFBF"/>
      <w:insideV w:val="single" w:sz="4" w:space="0" w:color="BFBFBF"/>
    </w:tblBorders>
  </w:tblPr>
  <w:tblGrid>
    $gridCols
  </w:tblGrid>
''';
  }

  String _tableEnd() {
    return '''
</w:tbl>
''';
  }

  String _tableRow(List<String> cells) {
    return '''
<w:tr>
  ${cells.join()}
</w:tr>
''';
  }

  String _cellText(String text, {bool bold = false, int width = 0}) {
    final widthXml = width > 0
        ? '<w:tcW w:w="$width" w:type="dxa"/>'
        : '<w:tcW w:w="0" w:type="auto"/>';

    return '''
<w:tc>
  <w:tcPr>
    $widthXml
  </w:tcPr>
  ${_paragraph(text, bold: bold)}
</w:tc>
''';
  }

  String _paragraph(String text, {String? style, bool bold = false}) {
    final escaped = _escapeXml(_sanitizeForDocx(text));
    final styleXml = style == null ? '' : '<w:pStyle w:val="$style"/>';
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

  String _displayValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '-' : trimmed;
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

  <w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title"/>
    <w:qFormat/>
    <w:rPr>
      <w:b/>
      <w:sz w:val="32"/>
    </w:rPr>
  </w:style>

  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
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
    <w:rPr>
      <w:b/>
      <w:sz w:val="24"/>
    </w:rPr>
  </w:style>
</w:styles>
''';
