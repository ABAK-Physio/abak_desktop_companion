import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../practitioners/data/practitioner_repository.dart';
import '../../practitioners/models/practitioner.dart';
import '../models/paired_device.dart';

import '../../../core/expert/expert_context_info.dart';
import '../../../core/expert/expert_info_button.dart';
import '../../../core/settings/application_settings_service.dart';

class DeviceFormDialog extends StatefulWidget {
  final PairedDevice? initialDevice;

  const DeviceFormDialog({
    super.key,
    this.initialDevice,
  });

  @override
  State<DeviceFormDialog> createState() => _DeviceFormDialogState();
}

class _DeviceFormDialogState extends State<DeviceFormDialog> {
  static const ExpertContextInfo _expertInfo = ExpertContextInfo(
    contextName: 'Nouvel appareil',
    sourceFile: 'lib/features/devices/widgets/device_form_dialog.dart',
    arbPrefix: 'deviceForm',
  );

  final ApplicationSettingsService _applicationSettingsService =
  const ApplicationSettingsService();

  bool _expertModeEnabled = false;
  bool get _isEditing => widget.initialDevice != null;

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
    _loadExpertMode();
    final device = widget.initialDevice;

    _deviceLabelController.text = device?.deviceLabel ?? '';
    _selectedPractitionerId = device?.practitionerId;
    _platform = device?.platform ?? 'ios';

    _practitionersFuture = _loadPractitioners();
  }

  Future<List<Practitioner>> _loadPractitioners() async {
    final practitioners =
    await _practitionerRepository.getActivePractitioners();

    final practitionerId = widget.initialDevice?.practitionerId;

    if (practitionerId == null) {
      return practitioners;
    }

    final alreadyPresent = practitioners.any(
          (practitioner) =>
      practitioner.practitionerId == practitionerId,
    );

    if (alreadyPresent) {
      return practitioners;
    }

    final currentPractitioner =
    await _practitionerRepository.getPractitionerById(
      practitionerId,
    );

    if (currentPractitioner != null) {
      practitioners.add(currentPractitioner);
    }

    return practitioners;
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
    _deviceLabelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final initial = widget.initialDevice;

    final device = PairedDevice(
      deviceId: initial?.deviceId ?? const Uuid().v4(),
      practitionerId: _selectedPractitionerId,
      deviceLabel: _deviceLabelController.text.trim(),
      platform: _platform,
      publicKey: initial?.publicKey,
      pairedAt: initial?.pairedAt ?? now,
    );

    Navigator.of(context).pop(device);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              _isEditing
                  ? 'Modifier l’appareil'
                  : 'Nouvel appareil',
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
          child: FutureBuilder<List<Practitioner>>(
            future: _practitionersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Erreur lors du chargement des praticiens : ${snapshot.error}',
                );
              }

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
                      labelText: 'Praticien associé',
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
        FilledButton(
          onPressed: _submit,
          child: Text(
            _isEditing ? 'Enregistrer' : 'Créer',
          ),
        ),
      ],
    );
  }
}
