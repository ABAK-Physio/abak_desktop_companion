// Gestion du flux métier patient - épisode
import 'package:flutter/material.dart';

import '../data/patient_repository.dart';
import '../../smart_card/models/vitale_identity.dart';
import '../../smart_card/screens/vitale_identity_screen.dart';

class PatientCreateScreen extends StatefulWidget {
  const PatientCreateScreen({super.key});

  @override
  State<PatientCreateScreen> createState() => _PatientCreateScreenState();
}

class _PatientCreateScreenState extends State<PatientCreateScreen> {
  final PatientRepository _patientRepository = PatientRepository();

  final _formKey = GlobalKey<FormState>();

  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _birthDateController = TextEditingController();

  String _sexCode = 'U';
  bool _saving = false;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _readVitaleIdentity() async {
    if (_saving) return;

    final identity = await Navigator.of(context).push<VitaleIdentity>(
      MaterialPageRoute(
        builder: (_) => const VitaleIdentityScreen(),
      ),
    );

    if (!mounted || identity == null) return;

    setState(() {
      if (identity.lastName?.trim().isNotEmpty == true) {
        _lastNameController.text = identity.lastName!.trim();
      }

      if (identity.firstName?.trim().isNotEmpty == true) {
        _firstNameController.text = identity.firstName!.trim();
      }

      final birthDate = identity.birthDate;
      if (birthDate != null) {
        _birthDateController.text =
            birthDate.toIso8601String().split('T').first;
      }

      final sexCode = identity.sexCode?.trim().toUpperCase();
      if (sexCode == 'M' || sexCode == 'F') {
        _sexCode = sexCode!;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informations patient préremplies depuis la Carte Vitale.'),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _patientRepository.createPatient(
        lastName: _lastNameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        birthDate: _birthDateController.text.trim().isEmpty
            ? null
            : _birthDateController.text.trim(),
        sexCode: _sexCode,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la création du patient : $e'),
        ),
      );

      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau patient'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Identité du patient',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _saving ? null : _readVitaleIdentity,
                              icon: const Icon(Icons.credit_card_outlined),
                              label: const Text('Lire Carte Vitale'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom est obligatoire';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'Prénom',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le prénom est obligatoire';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _birthDateController,
                          decoration: const InputDecoration(
                            labelText: 'Date de naissance',
                            hintText: 'YYYY-MM-DD',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: _sexCode,
                          decoration: const InputDecoration(
                            labelText: 'Sexe',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'U',
                              child: Text('Non renseigné'),
                            ),
                            DropdownMenuItem(
                              value: 'F',
                              child: Text('Féminin'),
                            ),
                            DropdownMenuItem(
                              value: 'M',
                              child: Text('Masculin'),
                            ),
                            DropdownMenuItem(
                              value: 'X',
                              child: Text('Autre'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _sexCode = value;
                            });
                          },
                        ),

                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _saving
                                  ? null
                                  : () => Navigator.of(context).pop(false),
                              child: const Text('Annuler'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Icon(Icons.check),
                              label: Text(
                                _saving ? 'Création...' : 'Créer le patient',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}