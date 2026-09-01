import 'package:flutter/material.dart';

import '../models/external_correspondent.dart';

class ExternalCorrespondentDialog extends StatefulWidget {
  final ExternalCorrespondent? correspondent;

  const ExternalCorrespondentDialog({
    super.key,
    this.correspondent,
  });

  @override
  State<ExternalCorrespondentDialog> createState() =>
      _ExternalCorrespondentDialogState();
}

class _ExternalCorrespondentDialogState
    extends State<ExternalCorrespondentDialog> {
  late final TextEditingController _lastNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _professionController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _cityController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    final correspondent = widget.correspondent;

    _lastNameController =
        TextEditingController(text: correspondent?.lastName ?? '');
    _firstNameController =
        TextEditingController(text: correspondent?.firstName ?? '');
    _professionController =
        TextEditingController(text: correspondent?.profession ?? '');
    _specialtyController =
        TextEditingController(text: correspondent?.specialty ?? '');
    _addressLine1Controller =
        TextEditingController(text: correspondent?.addressLine1 ?? '');
    _addressLine2Controller =
        TextEditingController(text: correspondent?.addressLine2 ?? '');
    _postalCodeController =
        TextEditingController(text: correspondent?.postalCode ?? '');
    _cityController =
        TextEditingController(text: correspondent?.city ?? '');
    _emailController =
        TextEditingController(text: correspondent?.email ?? '');
    _phoneController =
        TextEditingController(text: correspondent?.phone ?? '');
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _professionController.dispose();
    _specialtyController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _nullableText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  void _submit() {
    final lastName = _lastNameController.text.trim();

    if (lastName.isEmpty) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = widget.correspondent;

    final correspondent = ExternalCorrespondent(
      correspondentId:
      existing?.correspondentId ?? now.toString(),
      lastName: lastName,
      firstName: _nullableText(_firstNameController),
      profession: _nullableText(_professionController),
      specialty: _nullableText(_specialtyController),
      addressLine1: _nullableText(_addressLine1Controller),
      addressLine2: _nullableText(_addressLine2Controller),
      postalCode: _nullableText(_postalCodeController),
      city: _nullableText(_cityController),
      email: _nullableText(_emailController),
      phone: _nullableText(_phoneController),
      createdAt: existing?.createdAt ?? now,
      updatedAt: existing == null ? null : now,
      archivedAt: existing?.archivedAt,
    );

    Navigator.of(context).pop(correspondent);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.correspondent == null
            ? 'Ajouter un correspondant'
            : 'Modifier le correspondant',
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _professionController,
                decoration: const InputDecoration(
                  labelText: 'Profession',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Spécialité',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressLine1Controller,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressLine2Controller,
                decoration: const InputDecoration(
                  labelText: 'Complément d’adresse',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Code postal',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}