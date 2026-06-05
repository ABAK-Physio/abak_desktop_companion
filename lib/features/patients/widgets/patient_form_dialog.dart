import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';

class PatientFormDialog extends StatefulWidget {
  final Patient? initialPatient;

  const PatientFormDialog({
    super.key,
    this.initialPatient,
  });

  @override
  State<PatientFormDialog> createState() => _PatientFormDialogState();
}

class _PatientFormDialogState extends State<PatientFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _lastNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _birthDateController;

  late String _sexCode;

  bool get _isEditing => widget.initialPatient != null;

  @override
  void initState() {
    super.initState();

    final patient = widget.initialPatient;

    _lastNameController = TextEditingController(
      text: patient?.lastName ?? '',
    );
    _firstNameController = TextEditingController(
      text: patient?.firstName ?? '',
    );
    _birthDateController = TextEditingController(
      text: '',
    );

    _sexCode = patient?.sexCode ?? 'U';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_birthDateController.text.isEmpty) {
      _birthDateController.text =
          _formatIsoDateForDisplay(widget.initialPatient?.birthDate);
    }
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final initial = widget.initialPatient;

    final patient = Patient(
      patientId: initial?.patientId ?? const Uuid().v4(),
      lastName: _lastNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      birthDate: _toIsoDate(_birthDateController.text),
      sexCode: _sexCode,
      createdAt: initial?.createdAt ?? now,
    );

    Navigator.of(context).pop(patient);
  }

  String get _localeName {
    final locale = Localizations.localeOf(context);
    return locale.toLanguageTag();
  }

  DateFormat get _displayDateFormat {
    return DateFormat('dd/MM/yyyy');
  }
  String _formatIsoDateForDisplay(String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) return '';

    try {
      final date = DateTime.parse(isoDate);
      return _displayDateFormat.format(date);
    } catch (_) {
      return isoDate;
    }
  }

  String? _toIsoDate(String displayDate) {
    final value = displayDate.trim();
    if (value.isEmpty) return null;

    try {
      final date = _displayDateFormat.parseStrict(value);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    DateTime initialDate = DateTime(now.year - 40, now.month, now.day);

    final existingIso = widget.initialPatient?.birthDate;
    if (existingIso != null && existingIso.isNotEmpty) {
      try {
        initialDate = DateTime.parse(existingIso);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked == null) return;

    _birthDateController.text = _displayDateFormat.format(picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Modifier le patient' : 'Nouveau patient'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prénom est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date de naissance',
                  hintText: 'jj/mm/aaaa',
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                onTap: _pickBirthDate,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _sexCode,
                decoration: const InputDecoration(labelText: 'Sexe'),
                items: const [
                  DropdownMenuItem(value: 'U', child: Text('Non précisé')),
                  DropdownMenuItem(value: 'F', child: Text('Femme')),
                  DropdownMenuItem(value: 'M', child: Text('Homme')),
                  DropdownMenuItem(value: 'X', child: Text('Autre')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sexCode = value ?? 'U';
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Enregistrer' : 'Créer'),
        ),
      ],
    );
  }
}