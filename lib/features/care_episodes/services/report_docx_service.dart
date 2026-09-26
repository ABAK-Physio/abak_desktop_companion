import 'clinical_document_attachments_docx.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../models/report_document_data.dart';


class ReportDocxService {
  Future<Uint8List> buildDocx({
    required ReportDocumentData data,
    required List<Uint8List> chartPngBytes,
    Uint8List? establishmentLogoBytes,
    String? establishmentLogoExtension,
  }) async {
    final hasLogo =
        establishmentLogoBytes != null &&
            establishmentLogoExtension != null;

    final documentXml = _buildDocumentXml(
      data,
      hasLogo: hasLogo,
    );

    final archive = Archive()
      ..addFile(_textFile('[Content_Types].xml', _contentTypesXml))
      ..addFile(_textFile('_rels/.rels', _rootRelsXml))
      ..addFile(
        _textFile(
          'word/_rels/document.xml.rels',
          _buildDocumentRelsXml(
            chartCount: chartPngBytes.length,
            logoExtension: hasLogo
                ? establishmentLogoExtension
                : null,
          ),
        ),
      )
      ..addFile(_textFile('word/document.xml', documentXml))
      ..addFile(_textFile('word/styles.xml', _stylesXml));

    if (hasLogo) {
      archive.addFile(
        ArchiveFile(
          'word/media/image1.$establishmentLogoExtension',
          establishmentLogoBytes.length,
          establishmentLogoBytes,
        ),
      );
    }

    for (var i = 0; i < chartPngBytes.length; i++) {
      final imageIndex = i + 1 + (hasLogo ? 1 : 0);
      final bytes = chartPngBytes[i];
      archive.addFile(ArchiveFile('word/media/image$imageIndex.png', bytes.length, bytes));
    }

    final encoded = ZipEncoder().encode(archive);

    return Uint8List.fromList(encoded);
  }



  ArchiveFile _textFile(String name, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(name, bytes.length, bytes);
  }

  String _buildDocumentXml(
      ReportDocumentData data, {
        required bool hasLogo,
      }) {
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

    buffer.write(
      _buildEstablishmentHeader(
        data,
        hasLogo: hasLogo,
      ),
    );

    final reportCity = _hasValue(data.establishmentCity)
        ? data.establishmentCity!.trim()
        : '';

    final reportDateLabel = _formatDate(data.reportDate);

    if (reportCity.isNotEmpty) {
      buffer.write(
        _paragraph(
          '$reportCity le $reportDateLabel',
        ),
      );
    } else {
      buffer.write(
        _paragraph(
          reportDateLabel,
        ),
      );
    }

    buffer.write(_paragraph(''));

    final patientName = [
      data.patientFirstName.trim(),
      data.patientLastName.trim(),
    ].where((value) => value.isNotEmpty).join(' ');

    final correspondentName =
    _hasValue(data.recipientText)
        ? data.recipientText!.trim()
        : 'Docteur';

    final introduction = StringBuffer()
      ..write(
        'Cher $correspondentName, voici les conclusions du bilan réalisé ce jour',
      );

    if (patientName.isNotEmpty) {
      introduction.write(
        ' avec $patientName',
      );
    }

    introduction.write('.');

    buffer.write(
      _paragraph(
        introduction.toString(),
      ),
    );

    if (_hasValue(data.reportText)) {
      buffer.write(
        _buildStructuredReportText(data.reportText),
      );
    }

    buffer.write(ClinicalDocumentAttachmentsDocx().build(
      tests: data.tests,
      notes: data.notes,
      patientAgeYears: data.patientAgeYears,
      pathologyLabel: data.pathologyLabel,
      firstImageIndex: hasLogo ? 1 : 0,
    ));

    buffer.write(
      _paragraph('Très cordialement'),
    );

    if (_hasValue(data.authorName)) {
      buffer.write(
        _paragraph(
          data.authorName!.trim(),
          bold: true,
        ),
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

  String _buildStructuredReportText(String text) {
    final buffer = StringBuffer();

    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final valueLines = <String>[];
    var inMeasuredValues = false;

    for (final line in lines) {
      if (line == 'VALEURS CHIFFRÉES') {
        inMeasuredValues = true;

        buffer.write(
          _paragraph(
            line,
            bold: true,
          ),
        );

        continue;
      }

      if (inMeasuredValues) {
        valueLines.add(line);
        continue;
      }

      final isSectionTitle =
          line == line.toUpperCase() &&
              !line.contains(':');

      if (isSectionTitle) {
        buffer.write(
          _paragraph(
            line,
            bold: true,
          ),
        );
        continue;
      }

      buffer.write(
        _paragraph(line),
      );
    }

    if (valueLines.isNotEmpty) {
      buffer.write(
        _buildMeasuredValuesTable(valueLines),
      );
    }

    return buffer.toString();
  }

  String _buildMeasuredValuesTable(List<String> lines) {
    final values = <String, String>{};

    for (final line in lines) {
      final separatorIndex = line.indexOf(' : ');

      if (separatorIndex < 0) {
        continue;
      }

      final label = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 3).trim();

      if (label.isNotEmpty && value.isNotEmpty) {
        values[label] = value;
      }
    }

    const rows = [
      (
      'Borg dyspnée lors de l’activité',
      '',
      ),
      (
      'Score Nijmegen',
      'Suspicion de SHV si score > 20',
      ),
      (
      'Apnée max',
      'Score moyen population générale = 30 sec',
      ),
      (
      'MDP',
      '',
      ),
      (
      'THVP',
      'Test Hyperventilation provoqué '
          '(+ si reproduit les symptômes)',
      ),
      (
      'PIM (cmH2O)',
      '',
      ),
      (
      'Contrôle neuro-moteur du m. diaphragme',
      '',
      ),
      (
      'Tolérance à l’effort - TLC3 ou TDM6',
      '',
      ),
    ];

    final buffer = StringBuffer();

    buffer.write('''
<w:tbl>
  <w:tblPr>
    <w:tblW w:w="9400" w:type="dxa"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/>
      <w:left w:val="single" w:sz="4" w:space="0" w:color="000000"/>
      <w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/>
      <w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/>
      <w:insideH w:val="single" w:sz="4" w:space="0" w:color="000000"/>
      <w:insideV w:val="single" w:sz="4" w:space="0" w:color="000000"/>
    </w:tblBorders>
  </w:tblPr>

  <w:tblGrid>
    <w:gridCol w:w="3300"/>
    <w:gridCol w:w="2100"/>
    <w:gridCol w:w="4000"/>
  </w:tblGrid>
''');

    for (final row in rows) {
      final label = row.$1;
      final information = row.$2;
      final value = values[label] ?? '';

      buffer.write('''
  <w:tr>
    ${_tableCell(label, 3300)}
    ${_tableCell(value, 2100)}
    ${_tableCell(information, 4000)}
  </w:tr>
''');
    }

    buffer.write('</w:tbl>');

    return buffer.toString();
  }

  String _tableCell(String text, int width) {
    return '''
<w:tc>
  <w:tcPr>
    <w:tcW w:w="$width" w:type="dxa"/>
    <w:vAlign w:val="top"/>
  </w:tcPr>
  ${_paragraph(text)}
</w:tc>
''';
  }

  String _buildEstablishmentHeader(
      ReportDocumentData data, {
        required bool hasLogo,
      }) {
    final leftCell = StringBuffer();
    final rightCell = StringBuffer();

    if (hasLogo) {
      leftCell.write(
        _imageParagraph(
          relationshipId: 'rId1',
          drawingId: 1,
          widthEmu: 900000,
          heightEmu: 900000,
          name: 'Logo établissement',
        ),
      );
    } else {
      leftCell.write('<w:p/>');
    }

    if (_hasValue(data.establishmentName)) {
      rightCell.write(
        _paragraph(
          data.establishmentName!,
          bold: true,
          fontSize: 28,
        ),
      );
    }

    if (_hasValue(data.establishmentAddressLine1)) {
      rightCell.write(
        _paragraph(data.establishmentAddressLine1!),
      );
    }

    if (_hasValue(data.establishmentAddressLine2)) {
      rightCell.write(
        _paragraph(data.establishmentAddressLine2!),
      );
    }

    final locality = [
      data.establishmentPostalCode,
      data.establishmentCity,
    ]
        .where(
          (value) => value != null && value.trim().isNotEmpty,
    )
        .map((value) => value!.trim())
        .join(' ');

    if (locality.isNotEmpty) {
      rightCell.write(
        _paragraph(locality),
      );
    }

    if (_hasValue(data.establishmentPhone)) {
      rightCell.write(
        _paragraph(
          'Tél. : ${data.establishmentPhone!.trim()}',
        ),
      );
    }

    if (_hasValue(data.establishmentEmail)) {
      rightCell.write(
        _paragraph(data.establishmentEmail!),
      );
    }

    return '''
<w:tbl>
  <w:tblPr>
    <w:tblW w:w="0" w:type="auto"/>
    <w:tblBorders>
      <w:top w:val="nil"/>
      <w:left w:val="nil"/>
      <w:bottom w:val="nil"/>
      <w:right w:val="nil"/>
      <w:insideH w:val="nil"/>
      <w:insideV w:val="nil"/>
    </w:tblBorders>
  </w:tblPr>

  <w:tblGrid>
    <w:gridCol w:w="3400"/>
    <w:gridCol w:w="6200"/>
  </w:tblGrid>

  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="3400" w:type="dxa"/>
        <w:vAlign w:val="top"/>
      </w:tcPr>
      ${leftCell.toString()}
    </w:tc>

    <w:tc>
      <w:tcPr>
        <w:tcW w:w="6200" w:type="dxa"/>
        <w:vAlign w:val="top"/>
      </w:tcPr>
      ${rightCell.toString()}
    </w:tc>
  </w:tr>
</w:tbl>
''';
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _imageParagraph({
    required String relationshipId,
    required int drawingId,
    required int widthEmu,
    required int heightEmu,
    String name = 'Graphique',
  }) {
    return '''
<w:p>
  <w:r>
    <w:drawing>
      <wp:inline distT="0" distB="0" distL="0" distR="0">
        <wp:extent cx="$widthEmu" cy="$heightEmu"/>
        <wp:docPr id="$drawingId" name="$name"/>
        <wp:cNvGraphicFramePr>
          <a:graphicFrameLocks noChangeAspect="1"/>
        </wp:cNvGraphicFramePr>
        <a:graphic>
          <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:pic>
              <pic:nvPicPr>
                <pic:cNvPr id="0" name="$name"/>
                <pic:cNvPicPr/>
              </pic:nvPicPr>
              <pic:blipFill>
                <a:blip r:embed="$relationshipId"/>
                <a:stretch>
                  <a:fillRect/>
                </a:stretch>
              </pic:blipFill>
              <pic:spPr>
                <a:xfrm>
                  <a:off x="0" y="0"/>
                  <a:ext cx="$widthEmu" cy="$heightEmu"/>
                </a:xfrm>
                <a:prstGeom prst="rect">
                  <a:avLst/>
                </a:prstGeom>
              </pic:spPr>
            </pic:pic>
          </a:graphicData>
        </a:graphic>
      </wp:inline>
    </w:drawing>
  </w:r>
</w:p>
''';
  }

  String _paragraph(
      String text, {
        String? style,
        bool bold = false,
        int? fontSize,
      }) {
    final escaped = _escapeXml(
      _sanitizeForDocx(text),
    );

    final styleXml =
        '<w:pStyle w:val="${style ?? 'Normal'}"/>';

    final boldXml = bold ? '<w:b/>' : '';
    final fontSizeXml =
    fontSize != null ? '<w:sz w:val="$fontSize"/>' : '';

    return '''
  <w:p>
    <w:pPr>$styleXml</w:pPr>
    <w:r>
      <w:rPr>$boldXml$fontSizeXml</w:rPr>
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
<Default Extension="jpg" ContentType="image/jpeg"/>
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

String _buildDocumentRelsXml({
  required int chartCount,
  String? logoExtension,
}) {
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

  const relationshipIndex = 1;

  if (logoExtension != null) {
    buffer.writeln(
      '  <Relationship '
          'Id="rId$relationshipIndex" '
          'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" '
          'Target="media/image1.$logoExtension"/>',
    );
  }

  for (var i = 0; i < chartCount; i++) {
    final imageIndex = i + 1 + (logoExtension != null ? 1 : 0);
    buffer.writeln(
      '<Relationship Id="rId$imageIndex" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" '
      'Target="media/image$imageIndex.png"/>',
    );
  }

  buffer.writeln('</Relationships>');

  return buffer.toString();
}
const String _stylesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
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