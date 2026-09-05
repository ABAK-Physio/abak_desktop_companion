import 'assessment_template.dart';
import 'assessment_template_answers.dart';
import 'assessment_template_field_type.dart';

class AssessmentTemplateTextBuilder {
  static String build({
    required AssessmentTemplate template,
    required AssessmentTemplateAnswers answers,
  }) {
    final buffer = StringBuffer();

    for (final section in template.sections) {
      final sectionLines = <String>[];

      for (final field in section.fields) {
        if (!answers.hasValue(field.id)) {
          continue;
        }

        final value = answers.valueFor(field.id);

        switch (field.type) {
          case AssessmentTemplateFieldType.information:
            break;
          case AssessmentTemplateFieldType.shortText:
          case AssessmentTemplateFieldType.longText:
          case AssessmentTemplateFieldType.singleChoice:
          case AssessmentTemplateFieldType.abakData:
            final text = value?.toString().trim() ?? '';

            if (text.isNotEmpty) {
              sectionLines.add(
                '${field.label} : $text',
              );
            }

          case AssessmentTemplateFieldType.multipleChoice:
            if (value is Iterable) {
              final values = value
                  .map((item) => item.toString().trim())
                  .where((item) => item.isNotEmpty)
                  .toList();

              if (values.isNotEmpty) {
                sectionLines.add(
                  '${field.label} : ${values.join(', ')}',
                );
              }
            }

          case AssessmentTemplateFieldType.simpleTable:
            if (value is List) {
              final lines = <String>[];

              for (final item in value) {
                if (item is! Map) {
                  continue;
                }

                final rowLabel =
                    item['row']?.toString().trim() ?? '';

                if (rowLabel.isEmpty) {
                  continue;
                }

                final populatedValues = <String>[];

                for (final column in field.tableColumns) {
                  final cellValue =
                      item[column]?.toString().trim() ?? '';

                  if (cellValue.isNotEmpty) {
                    populatedValues.add(
                      '$column : $cellValue',
                    );
                  }
                }

                if (populatedValues.isNotEmpty) {
                  lines.add(
                    '- $rowLabel : ${populatedValues.join(' — ')}',
                  );
                }
              }

              if (lines.isNotEmpty) {
                sectionLines.add(
                  '${field.label} :\n${lines.join('\n')}',
                );
              }
            }

            break;
        }
      }

      if (sectionLines.isEmpty) {
        continue;
      }

      if (buffer.isNotEmpty) {
        buffer.writeln();
      }

      buffer.writeln(section.title.toUpperCase());
      buffer.writeln();

      for (final line in sectionLines) {
        buffer.writeln(line);
      }
    }

    return buffer.toString().trim();
  }
}