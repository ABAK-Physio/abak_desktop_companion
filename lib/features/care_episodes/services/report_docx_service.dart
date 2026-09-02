import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../models/report_document_data.dart';


class ReportDocxService {
  Future<Uint8List> buildDocx({
    required List<Uint8List> chartPngBytes,
    required ReportDocumentData data,
    Uint8List? establishmentLogoBytes,
    String? establishmentLogoExtension,
  }) async {
    final hasLogo =
        establishmentLogoBytes != null &&
            establishmentLogoExtension != null;

    final imageOffset = hasLogo ? 1 : 0;

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
            chartImageCount: chartPngBytes.length,
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
      final imageBytes = chartPngBytes[i];

      archive.addFile(
        ArchiveFile(
          'word/media/image${i + 1 + imageOffset}.png',
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

    buffer.write(_paragraph('RAPPORT', style: 'Title'));

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

    buffer.write(
      _paragraph(
        'Informations sur le patient',
        style: 'Heading1',
      ),
    );

    _writeOptionalLine(
      buffer,
      'Côté dominant',
      data.dominantSide,
    );

    _writeOptionalLine(
      buffer,
      'Profession',
      data.profession,
    );

    _writeOptionalLine(
      buffer,
      'Activité sportive',
      data.sport,
    );

    if (_hasValue(data.heightCm)) {
      _writeLine(
        buffer,
        'Taille',
        '${data.heightCm!.trim()} cm',
      );
    }

    if (_hasValue(data.weightKg)) {
      _writeLine(
        buffer,
        'Poids',
        '${data.weightKg!.trim()} kg',
      );
    }

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

    var imageIndex = hasLogo ? 1 : 0;

    if (data.tests.isNotEmpty) {
      buffer.write(
        _paragraph(
          'Résultats des tests sélectionnés',
          style: 'Heading1',
        ),
      );

      for (final test in data.tests) {
        buffer.write(
          _paragraph(
            test.title,
            style: 'Heading2',
          ),
        );

        if (test.testDate != null) {
          _writeLine(
            buffer,
            'Réalisé le',
            _formatDate(test.testDate!),
          );
        }

        final dossierAge = data.patientAgeYears;
        final testAge = test.declaredAgeYears;

        if (testAge != null) {
          if (dossierAge == null || testAge != dossierAge) {
            _writeLine(
              buffer,
              'Âge déclaré lors du test',
              '$testAge ans',
            );
          }
        }

        final dossierPathology = data.pathologyLabel?.trim();
        final testPathology = test.pathologyLabel?.trim();

        if (testPathology != null && testPathology.isNotEmpty) {
          final samePathology =
              dossierPathology != null &&
                  dossierPathology.isNotEmpty &&
                  dossierPathology.toLowerCase() ==
                      testPathology.toLowerCase();

          if (!samePathology) {
            _writeLine(
              buffer,
              'Pathologie lors du test',
              testPathology,
            );

            if (dossierPathology != null &&
                dossierPathology.isNotEmpty) {
              _writeLine(
                buffer,
                'Pathologie lors du rattachement',
                dossierPathology,
              );
            }
          }
        }

        if (_hasValue(test.resultText)) {
          buffer.write(
            _paragraph(test.resultText),
          );
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

    if (data.notes.isNotEmpty) {
      buffer.write(
        _paragraph(
          'Notes de suivi sélectionnées',
          style: 'Heading1',
        ),
      );

      for (final note in data.notes) {
        final titleParts = <String>[];

        if (note.noteDate != null) {
          titleParts.add(
            _formatDate(note.noteDate!),
          );
        }

        if (_hasValue(note.title)) {
          titleParts.add(
            note.title.trim(),
          );
        }

        if (titleParts.isNotEmpty) {
          buffer.write(
            _paragraph(
              titleParts.join(' — '),
              bold: true,
            ),
          );
        }

        if (_hasValue(note.content)) {
          buffer.write(
            _paragraph(note.content),
          );
        }
      }
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
  required int chartImageCount,
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

  var relationshipIndex = 1;

  if (logoExtension != null) {
    buffer.writeln(
      '  <Relationship '
          'Id="rId$relationshipIndex" '
          'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" '
          'Target="media/image1.$logoExtension"/>',
    );

    relationshipIndex++;
  }

  for (var i = 0; i < chartImageCount; i++) {
    final imageIndex =
        i + 1 + (logoExtension != null ? 1 : 0);

    buffer.writeln(
      '  <Relationship '
          'Id="rId$relationshipIndex" '
          'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" '
          'Target="media/image$imageIndex.png"/>',
    );

    relationshipIndex++;
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