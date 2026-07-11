import 'package:flutter/material.dart';

import '../data/episode_form_repository.dart';
import '../models/contact_form_field.dart';
import '../models/episode_form_answer.dart';

class EpisodeFormEditorScreen extends StatefulWidget {
  final String formId;

  const EpisodeFormEditorScreen({super.key, required this.formId});

  @override
  State<EpisodeFormEditorScreen> createState() =>
      _EpisodeFormEditorScreenState();
}

class _EpisodeFormEditorScreenState extends State<EpisodeFormEditorScreen> {
  final EpisodeFormRepository _repository = EpisodeFormRepository();

  late Future<Map<ContactFormField, EpisodeFormAnswer?>> _futureData;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _choiceValues = {};

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<Map<ContactFormField, EpisodeFormAnswer?>> _loadData() async {
    final data = await _repository.getFormWithAnswers(formId: widget.formId);

    for (final entry in data.entries) {
      final field = entry.key;
      final answer = entry.value;
      final value = answer?.value ?? '';

      if (field.fieldType == 'single_choice') {
        _choiceValues[field.fieldId] = value.isEmpty ? null : value;
      } else {
        _controllers[field.fieldId] = TextEditingController(text: value);
      }
    }

    return data;
  }

  List<String> _options(ContactFormField field) {
    final raw = field.optionsJson;

    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    return raw
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save(Map<ContactFormField, EpisodeFormAnswer?> data) async {
    for (final field in data.keys) {
      if (!field.required) {
        continue;
      }

      final value = field.fieldType == 'single_choice'
          ? _choiceValues[field.fieldId]
          : _controllers[field.fieldId]?.text.trim();

      if (value == null || value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le champ "${field.label}" est obligatoire.')),
        );

        return;
      }
    }

    setState(() {
      _saving = true;
    });

    for (final field in data.keys) {
      final value = field.fieldType == 'single_choice'
          ? _choiceValues[field.fieldId]
          : _controllers[field.fieldId]?.text.trim();

      await _repository.upsertAnswer(
        formId: widget.formId,
        fieldId: field.fieldId,
        value: value,
      );
    }

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  Widget _buildTextField(ContactFormField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _controllers[field.fieldId],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: field.label,
        ),
      ),
    );
  }

  Widget _buildMultilineTextField(ContactFormField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _controllers[field.fieldId],
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: field.label,
        ),
      ),
    );
  }

  Widget _buildChoiceField(ContactFormField field) {
    final options = _options(field);

    final currentValue = _choiceValues[field.fieldId];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: currentValue,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: field.label,
        ),
        items: options
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _choiceValues[field.fieldId] = value;
          });
        },
      ),
    );
  }

  Widget _buildDateField(ContactFormField field) {
    final controller = _controllers[field.fieldId]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: field.label,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        onTap: () async {
          DateTime initialDate = DateTime.now();

          final currentValue = controller.text.trim();

          if (currentValue.isNotEmpty) {
            try {
              final parts = currentValue.split('/');

              if (parts.length == 3) {
                initialDate = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );
              }
            } catch (_) {
              // ignore et conserve DateTime.now()
            }
          }

          final selectedDate = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );

          if (selectedDate == null) {
            return;
          }

          final day = selectedDate.day.toString().padLeft(2, '0');
          final month = selectedDate.month.toString().padLeft(2, '0');
          final year = selectedDate.year;

          controller.text = '$day/$month/$year';

          setState(() {});
        },
      ),
    );
  }

  Widget _buildField(ContactFormField field) {
    switch (field.fieldType) {
      case 'multiline_text':
        return _buildMultilineTextField(field);
      case 'single_choice':
        return _buildChoiceField(field);
      case 'date':
        return _buildDateField(field);
      case 'text':
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildContent(Map<ContactFormField, EpisodeFormAnswer?> data) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [for (final field in data.keys) _buildField(field)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<ContactFormField, EpisodeFormAnswer?>>(
      future: _futureData,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Modifier le formulaire'),
            actions: [
              TextButton.icon(
                onPressed: data == null || _saving ? null : () => _save(data),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Enregistrer'),
              ),
            ],
          ),
          body: snapshot.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : snapshot.hasError
              ? Center(child: Text('Erreur : ${snapshot.error}'))
              : data == null || data.isEmpty
              ? const Center(child: Text('Aucun champ à afficher.'))
              : _buildContent(data),
        );
      },
    );
  }
}
