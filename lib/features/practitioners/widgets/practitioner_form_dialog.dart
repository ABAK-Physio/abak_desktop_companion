import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/practitioner.dart';
import '../../../core/expert/expert_context_info.dart';
import '../../../core/expert/expert_info_button.dart';
import '../../../core/settings/application_settings_service.dart';

class PractitionerFormDialog extends StatefulWidget {
  final Practitioner? initialPractitioner;

  const PractitionerFormDialog({super.key, this.initialPractitioner});

  @override
  State<PractitionerFormDialog> createState() => _PractitionerFormDialogState();
}

class _PractitionerFormDialogState extends State<PractitionerFormDialog> {
  static const ExpertContextInfo _expertInfo = ExpertContextInfo(
    contextName: 'Nouveau praticien',
    sourceFile: 'lib/features/practitioners/widgets/practitioner_form_dialog.dart',
    arbPrefix: 'practitionerNew',
    comment:
    'Cet écran permet de créer un praticien',
  );

  final ApplicationSettingsService _applicationSettingsService =
  const ApplicationSettingsService();

  bool _expertModeEnabled = false;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _professionalIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool get _isEditing => widget.initialPractitioner != null;



  @override
  void initState() {
    super.initState();
    _loadExpertMode();

    final p = widget.initialPractitioner;

    _displayNameController = TextEditingController(text: p?.displayName ?? '');
    _firstNameController = TextEditingController(text: p?.firstName ?? '');
    _lastNameController = TextEditingController(text: p?.lastName ?? '');
    _professionalIdController = TextEditingController(
      text: p?.professionalId ?? '',
    );
    _emailController = TextEditingController(text: p?.email ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
  }

  Future<void> _loadExpertMode() async {
    final expertModeEnabled =
    await _applicationSettingsService.isExpertModeEnabled();

    if (!mounted) return;

    setState(() {
      _expertModeEnabled = expertModeEnabled;
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _professionalIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final initial = widget.initialPractitioner;

    final practitioner = Practitioner(
      practitionerId: initial?.practitionerId ?? const Uuid().v4(),
      displayName: _displayNameController.text.trim(),
      firstName: _emptyToNull(_firstNameController.text),
      lastName: _emptyToNull(_lastNameController.text),
      professionalId: _emptyToNull(_professionalIdController.text),
      email: _emptyToNull(_emailController.text),
      phone: _emptyToNull(_phoneController.text),
      isActive: true,
      createdAt: initial?.createdAt ?? now,
      updatedAt: _isEditing ? now : null,
      archivedAt: initial?.archivedAt,
    );

    Navigator.of(context).pop(practitioner);
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              _isEditing
                  ? 'Modifier le praticien'
                  : 'Nouveau praticien',
            ),
          ),
          if (_expertModeEnabled)
            const ExpertInfoButton(
              info: _expertInfo,
            ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(labelText: 'Nom affiché'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom affiché est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _professionalIdController,
                  decoration: const InputDecoration(
                    labelText: 'Identifiant professionnel',
                    hintText: 'RPPS, ADELI…',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
              ],
            ),
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
