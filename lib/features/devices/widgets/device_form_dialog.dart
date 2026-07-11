import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../practitioners/data/practitioner_repository.dart';
import '../../practitioners/models/practitioner.dart';
import '../models/paired_device.dart';

class DeviceFormDialog extends StatefulWidget {
  const DeviceFormDialog({super.key});

  @override
  State<DeviceFormDialog> createState() => _DeviceFormDialogState();
}

class _DeviceFormDialogState extends State<DeviceFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _deviceLabelController = TextEditingController();

  final PractitionerRepository _practitionerRepository =
      PractitionerRepository();

  late Future<List<Practitioner>> _practitionersFuture;

  String? _selectedPractitionerId;
  String _platform = 'ios';

  @override
  void initState() {
    super.initState();
    _practitionersFuture = _practitionerRepository.getActivePractitioners();
  }

  @override
  void dispose() {
    _deviceLabelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final device = PairedDevice(
      deviceId: const Uuid().v4(),
      practitionerId: _selectedPractitionerId,
      deviceLabel: _deviceLabelController.text.trim(),
      platform: _platform,
      publicKey: null,
      pairedAt: now,
    );

    Navigator.of(context).pop(device);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvel appareil'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: FutureBuilder<List<Practitioner>>(
            future: _practitionersFuture,
            builder: (context, snapshot) {
              final practitioners = snapshot.data ?? [];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _deviceLabelController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l’appareil',
                      hintText: 'iPhone Claire, Pixel Marc…',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom de l’appareil est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _platform,
                    decoration: const InputDecoration(labelText: 'Plateforme'),
                    items: const [
                      DropdownMenuItem(value: 'ios', child: Text('iOS')),
                      DropdownMenuItem(
                        value: 'android',
                        child: Text('Android'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _platform = value ?? 'ios';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedPractitionerId,
                    decoration: const InputDecoration(
                      labelText: 'Kiné associé',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Aucun / appareil partagé'),
                      ),
                      ...practitioners.map(
                        (p) => DropdownMenuItem<String?>(
                          value: p.practitionerId,
                          child: Text(p.displayName),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPractitionerId = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Créer')),
      ],
    );
  }
}
