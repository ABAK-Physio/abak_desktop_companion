import '../../../generated/l10n.dart';
import '../models/assessment_document_data.dart';

/// Common rendering for the selected clinical material in assessments and reports.
class ClinicalDocumentAttachmentsDocx {
  String build({
    required List<AssessmentDocumentTest> tests,
    required List<AssessmentDocumentNote> notes,
    required int? patientAgeYears,
    required String? pathologyLabel,
    int firstImageIndex = 0,
  }) {
    final buffer = StringBuffer();
    var imageIndex = firstImageIndex;

    if (tests.isNotEmpty) {
      buffer.write(
        _paragraph(S.current.assessmentDocxService_results, style: 'Heading1'),
      );

      for (final test in tests) {
        buffer.write(_paragraph(test.title, style: 'Heading2'));

        if (test.testDate != null) {
          _writeLine(
            buffer,
            S.current.assessmentDocxService_performed,
            _formatDate(test.testDate!),
          );
        }

        final dossierAge = patientAgeYears;
        final testAge = test.declaredAgeYears;

        if (testAge != null) {
          if (dossierAge == null || testAge != dossierAge) {
            _writeLine(
              buffer,
              S.current.assessmentDocxService_declared,
              S.current.assessmentDocxService_years(testAge),
            );
          }
        }

        final dossierPathology = pathologyLabel?.trim();
        final testPathology = test.pathologyLabel?.trim();

        if (testPathology != null && testPathology.isNotEmpty) {
          final samePathology =
              dossierPathology != null &&
              dossierPathology.isNotEmpty &&
              dossierPathology.toLowerCase() == testPathology.toLowerCase();

          if (!samePathology) {
            _writeLine(
              buffer,
              S.current.assessmentDocxService_diagnosis,
              testPathology,
            );

            if (dossierPathology != null && dossierPathology.isNotEmpty) {
              _writeLine(
                buffer,
                S.current.assessmentDocxService_attachment,
                dossierPathology,
              );
            }
          }
        }

        if (_hasValue(test.resultText)) {
          buffer.write(_paragraph(test.resultText));
        }

        if (test.resultRows.isNotEmpty) {
          buffer.write(_resultsTable(test.resultRows));
        }

        for (var i = 0; i < test.chartSeries.length; i++) {
          imageIndex++;

          buffer.write(
            _imageParagraph(
              relationshipId: 'rId$imageIndex',
              drawingId: imageIndex,
              widthEmu: 5486400,
              heightEmu: 2743200,
            ),
          );
        }
      }
    }

    if (notes.isNotEmpty) {
      buffer.write(
        _paragraph(S.current.assessmentDocxService_notes, style: 'Heading1'),
      );

      for (final note in notes) {
        final titleParts = <String>[];

        if (note.noteDate != null) {
          titleParts.add(_formatDate(note.noteDate!));
        }

        if (_hasValue(note.title)) {
          titleParts.add(note.title.trim());
        }

        if (titleParts.isNotEmpty) {
          buffer.write(_paragraph(titleParts.join(' — '), bold: true));
        }

        if (_hasValue(note.content)) {
          buffer.write(_paragraph(note.content));
        }
      }
    }

    return buffer.toString();
  }

  void _writeLine(StringBuffer buffer, String label, String value) {
    buffer.write(_paragraph('$label : $value'));
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _imageParagraph({
    required String relationshipId,
    required int drawingId,
    required int widthEmu,
    required int heightEmu,
  }) {
    return '''
<w:p>
  <w:r>
    <w:drawing>
      <wp:inline distT="0" distB="0" distL="0" distR="0">
        <wp:extent cx="$widthEmu" cy="$heightEmu"/>
        <wp:docPr id="$drawingId" name="${_escapeXml(S.current.assessmentDocxService_chart)}"/>
        <wp:cNvGraphicFramePr>
          <a:graphicFrameLocks noChangeAspect="1"/>
        </wp:cNvGraphicFramePr>
        <a:graphic>
          <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:pic>
              <pic:nvPicPr>
                <pic:cNvPr id="$drawingId" name="image$drawingId.png"/>
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

  String _resultsTable(List<AssessmentDocumentResultRow> rows) {
    final s = S.current;
    final showWalkingAid = rows.any(
      (row) => row.walkingAid?.trim().isNotEmpty == true,
    );
    final widths = showWalkingAid ? [2100, 4500, 3000] : [2100, 7500];
    String cell(String value, int width, {bool header = false}) =>
        '<w:tc><w:tcPr><w:tcW w:w="$width" w:type="dxa"/>'
        '${header ? '<w:shd w:fill="E8EEF3"/>' : ''}</w:tcPr>'
        '${_paragraph(value, bold: header)}</w:tc>';
    final buffer = StringBuffer(
      '<w:tbl><w:tblPr><w:tblW w:w="9600" w:type="dxa"/>'
      '<w:tblBorders>'
      '<w:top w:val="single" w:sz="4" w:color="C8CDD2"/>'
      '<w:left w:val="single" w:sz="4" w:color="C8CDD2"/>'
      '<w:bottom w:val="single" w:sz="4" w:color="C8CDD2"/>'
      '<w:right w:val="single" w:sz="4" w:color="C8CDD2"/>'
      '<w:insideH w:val="single" w:sz="4" w:color="C8CDD2"/>'
      '<w:insideV w:val="single" w:sz="4" w:color="C8CDD2"/>'
      '</w:tblBorders></w:tblPr><w:tblGrid>'
      '${widths.map((width) => '<w:gridCol w:w="$width"/>').join()}'
      '</w:tblGrid><w:tr><w:trPr><w:tblHeader/></w:trPr>',
    );
    final headers = [
      s.careEpisodeReportsWorkspace_date,
      s.careEpisodeReportsWorkspace_result,
      if (showWalkingAid) s.walkingAid_label,
    ];
    for (var i = 0; i < headers.length; i++) {
      buffer.write(cell(headers[i], widths[i], header: true));
    }
    buffer.write('</w:tr>');
    for (final row in rows) {
      final date =
          '${_formatDate(row.date)} '
          '${row.date.hour.toString().padLeft(2, '0')}:'
          '${row.date.minute.toString().padLeft(2, '0')}';
      buffer.write('<w:tr>');
      buffer.write(cell(date, widths[0]));
      buffer.write(cell(row.result, widths[1]));
      if (showWalkingAid) {
        final aid = row.walkingAid?.trim();
        buffer.write(cell(aid == null || aid.isEmpty ? '-' : aid, widths[2]));
      }
      buffer.write('</w:tr>');
    }
    buffer.write('</w:tbl>');
    return buffer.toString();
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
