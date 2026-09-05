import 'package:flutter/material.dart';

import '../../../models/assessment_templates/assessment_template.dart';
import '../../../models/assessment_templates/assessment_template_field.dart';
import '../../../models/assessment_templates/assessment_template_field_type.dart';
import '../../../models/assessment_templates/assessment_template_answers.dart';
import '../../../models/assessment_templates/assessment_template_text_builder.dart';

class AssessmentTemplateGuide extends StatefulWidget {
  final AssessmentTemplate template;
  final Future<bool> Function(String text) onInsertGeneratedText;
  final Map<String, String> initialValues;
  final ValueChanged<AssessmentTemplateAnswers> onAnswersChanged;
  final AssessmentTemplateAnswers? initialAnswers;

  const AssessmentTemplateGuide({
    super.key,
    required this.template,
    required this.onInsertGeneratedText,
    required this.initialValues,
    required this.onAnswersChanged,
    this.initialAnswers,
  });

  @override
  State<AssessmentTemplateGuide> createState() =>
      _AssessmentTemplateGuideState();
}

class _AssessmentTemplateGuideState extends State<AssessmentTemplateGuide> {
  final Map<String, String> _textValues = {};
  final Map<String, String> _singleChoiceValues = {};
  final Map<String, Set<String>> _multipleChoiceValues = {};
  final Map<String, List<Map<String, String>>> _tableValues = {};
  final Map<String, GlobalKey> _sectionKeys = {};
  String? _selectedSectionId;

  AssessmentTemplateAnswers _buildAnswers() {
    final values = <String, dynamic>{};

    values.addAll(_textValues);
    values.addAll(_singleChoiceValues);

    for (final entry in _multipleChoiceValues.entries) {
      values[entry.key] = entry.value.toList();
    }

    for (final entry in _tableValues.entries) {
      values[entry.key] = entry.value;
    }

    return AssessmentTemplateAnswers(
      templateId: widget.template.id,
      values: values,
    );
  }

  @override
  void initState() {
    super.initState();

    _textValues.addAll(widget.initialValues);

    final initialAnswers = widget.initialAnswers;

    if (initialAnswers != null) {
      for (final entry in initialAnswers.values.entries) {
        final value = entry.value;

        if (value is String) {
          _textValues[entry.key] = value;
        } else if (value is List) {
          final isTableValue =
              value.isNotEmpty && value.first is Map;

          if (isTableValue) {
            _tableValues[entry.key] = value
                .whereType<Map>()
                .map(
                  (row) => row.map(
                    (key, value) => MapEntry(
                  key.toString(),
                  value?.toString() ?? '',
                ),
              ),
            )
                .toList();
          } else {
            _multipleChoiceValues[entry.key] = value
                .map((item) => item.toString())
                .toSet();
          }
        }
      }
    }
  }

  GlobalKey _sectionKey(String sectionId) {
    return _sectionKeys.putIfAbsent(
      sectionId,
          () => GlobalKey(),
    );
  }

  Future<void> _scrollToSection(String sectionId) async {
    final sectionContext =
        _sectionKeys[sectionId]?.currentContext;

    if (sectionContext == null) {
      return;
    }

    setState(() {
      _selectedSectionId = sectionId;
    });

    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0,
    );
  }

  void _notifyAnswersChanged() {
    widget.onAnswersChanged(
      _buildAnswers(),
    );
  }

  Future<void> _showPreview() async {
    final answers = _buildAnswers();

    final generatedText = AssessmentTemplateTextBuilder.build(
      template: widget.template,
      answers: answers,
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Aperçu du bilan'),
          content: SizedBox(
            width: 700,
            height: 520,
            child: generatedText.isEmpty
                ? const Center(
              child: Text(
                'Aucune information n’a encore été renseignée.',
              ),
            )
                : SingleChildScrollView(
              child: SelectableText(
                generatedText,
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
            FilledButton(
              onPressed: generatedText.isEmpty
                  ? null
                  : () async {
                final previewNavigator =
                Navigator.of(dialogContext);

                final inserted =
                await widget.onInsertGeneratedText(
                  generatedText,
                );

                if (!mounted || !inserted) {
                  return;
                }

                previewNavigator.pop();

                if (!mounted) return;

                Navigator.of(context).pop();
              },
              child: const Text('Insérer dans le bilan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 200,
          child: _buildSectionNavigation(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _buildGuideContent(),
        ),
      ],
    );
  }

  Widget _buildSectionNavigation() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          widget.template.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        for (final section in widget.template.sections)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            onTap: () => _scrollToSection(section.id),
            leading: _selectedSectionId == section.id
                ? const Icon(
              Icons.chevron_right,
              size: 18,
            )
                : const SizedBox(
              width: 18,
            ),
            minLeadingWidth: 18,
            title: Text(
              section.title,
              style: TextStyle(
                fontWeight: _selectedSectionId == section.id
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGuideContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.template.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (widget.template.description != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.template.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 24),

          for (final section in widget.template.sections) ...[
            Container(
              key: _sectionKey(section.id),
              child: Text(
                section.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            for (final field in section.fields) ...[
              _buildField(field),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _showPreview,
              icon: const Icon(Icons.preview_outlined),
              label: const Text('Prévisualiser le bilan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(AssessmentTemplateField field) {
    switch (field.type) {
      case AssessmentTemplateFieldType.information:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            field.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case AssessmentTemplateFieldType.shortText:
      case AssessmentTemplateFieldType.abakData:
        return TextFormField(
          initialValue: _textValues[field.id],
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            _textValues[field.id] = value;
            _notifyAnswersChanged();
          },
        );

      case AssessmentTemplateFieldType.longText:
        return TextFormField(
          initialValue: _textValues[field.id],
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          minLines: 3,
          maxLines: 6,
          onChanged: (value) {
            _textValues[field.id] = value;
            _notifyAnswersChanged();
          },
        );

      case AssessmentTemplateFieldType.singleChoice:
        return _buildSingleChoiceField(field);

      case AssessmentTemplateFieldType.multipleChoice:
        return _buildMultipleChoiceField(field);

      case AssessmentTemplateFieldType.simpleTable:
        return _buildSimpleTableField(field);
    }
  }
  Widget _buildSingleChoiceField(
      AssessmentTemplateField field,
      ) {
    final selectedValue = _singleChoiceValues[field.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in field.options)
              ChoiceChip(
                label: Text(option),
                selected: selectedValue == option,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _singleChoiceValues[field.id] = option;
                    } else {
                      _singleChoiceValues.remove(field.id);
                    }
                  });

                  _notifyAnswersChanged();
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceField(
      AssessmentTemplateField field,
      ) {
    final selectedValues =
        _multipleChoiceValues[field.id] ?? <String>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in field.options)
              FilterChip(
                label: Text(option),
                selected: selectedValues.contains(option),
                onSelected: (selected) {
                  setState(() {
                    final values =
                    _multipleChoiceValues.putIfAbsent(
                      field.id,
                          () => <String>{},
                    );

                    if (selected) {
                      values.add(option);
                    } else {
                      values.remove(option);
                    }
                  });

                  _notifyAnswersChanged();
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleTableField(
      AssessmentTemplateField field,
      ) {
    final rows = _tableValues.putIfAbsent(
      field.id,
          () => [
        for (final rowLabel in field.tableRows)
          {
            'row': rowLabel,
            for (final column in field.tableColumns)
              column: '',
          },
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Table(
          columnWidths: {
            0: const FlexColumnWidth(2),
            for (var index = 0;
            index < field.tableColumns.length;
            index++)
              index + 1: const FlexColumnWidth(2),
          },
          border: TableBorder.all(
            color: Theme.of(context).dividerColor,
          ),
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(field.tableRowHeader),
                ),
                for (final column in field.tableColumns)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(column),
                  ),
              ],
            ),
            for (final row in rows)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      row['row'] ?? '',
                    ),
                  ),
                  for (final column in field.tableColumns)
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: TextFormField(
                        initialValue: row[column] ?? '',
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          row[column] = value;
                          _notifyAnswersChanged();
                        },
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
