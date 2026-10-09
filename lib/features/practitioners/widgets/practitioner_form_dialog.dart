import 'package:flutter/material.dart';
import 'package:abak_shared/abak_shared.dart';
import 'package:uuid/uuid.dart';

import '../../../generated/l10n.dart';
import '../../../core/database/database_service.dart';
import '../../planning/models/planning_opening_hours.dart';
import '../../planning/data/planning_opening_hours_repository.dart';
import '../../planning/prototype/planning_opening_hours_dialog.dart';
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
  ExpertContextInfo _expertInfo(S s) {
    return ExpertContextInfo(
      contextName: s.practitionerNew_newPractitioner,
      sourceFile:
          'lib/features/practitioners/widgets/practitioner_form_dialog.dart',
      arbPrefix: 'practitionerNew',
      comment: s.practitionerNew_cet_ecran_permet,
    );
  }

  final ApplicationSettingsService _applicationSettingsService =
      const ApplicationSettingsService();

  bool _expertModeEnabled = false;
  int _appointmentStepMinutes = 15;
  PlanningOpeningHours? _workingHours;
  PlanningOpeningHours? _customDraft;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _professionalIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _appointmentDurationController;

  bool get _isEditing => widget.initialPractitioner != null;

  @override
  void initState() {
    super.initState();
    _loadExpertMode();

    final p = widget.initialPractitioner;
    _appointmentStepMinutes = p?.appointmentStepMinutes ?? 15;
    _appointmentDurationController = TextEditingController(
      text: (p?.appointmentDurationMinutes ?? 45).toString(),
    );
    _workingHours = p?.workingHours;
    _customDraft = _workingHours;

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
    final expertModeEnabled = await _applicationSettingsService
        .isExpertModeEnabled();

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
    _appointmentDurationController.dispose();
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
      isActive: initial?.isActive ?? true,
      workingHours: _workingHours,
      appointmentStepMinutes: _appointmentStepMinutes,
      appointmentDurationMinutes: int.parse(
        _appointmentDurationController.text.trim(),
      ),
      createdAt: initial?.createdAt ?? now,
      updatedAt: _isEditing ? now : null,
      archivedAt: initial?.archivedAt,
    );

    Navigator.of(context).pop(practitioner);
  }

  Future<void> _editWorkingHours() async {
    PlanningOpeningHours? draft;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => PlanningOpeningHoursDialog(
        title: 'Horaires de travail au cabinet',
        description:
            'Présence habituelle de ce praticien, entre 07:00 et 21:00. Ces modifications seront enregistrées avec la fiche praticien.',
        saveLabel: 'Appliquer à la fiche',
        closedLabel: 'Non travaillé',
        openLabel: 'Travaillé',
        load: () async =>
            _customDraft ??
            await PlanningOpeningHoursRepository(
              database: () => DatabaseService.database,
            ).load(),
        save: (hours) async {
          draft = hours;
        },
      ),
    );
    if (mounted && accepted == true && draft != null) {
      setState(() {
        _workingHours = draft;
        _customDraft = draft;
      });
    }
  }

  String _hoursSummary() {
    String clock(int value) =>
        '${(value ~/ 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}';
    return [
      for (var day = 1; day <= 7; day++)
        '${PlanningOpeningHours.dayNames[day - 1]} : ${_workingHours!.days[day]!.isEmpty ? 'non travaillé' : _workingHours!.days[day]!.map((p) => '${clock(p.start)}–${clock(p.end)}').join(', ')}',
    ].join('\n');
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              _isEditing
                  ? s.practitionerNew_editPractitioner
                  : s.practitionerNew_newPractitioner,
            ),
          ),
          ContextHelpButton(
            technicalInformationLabel: S.of(context).g_helpTooltip,
            title: _isEditing
                ? s.practitionerNew_editPractitioner
                : s.practitionerNew_newPractitioner,
            content: s.practitionerNew_help,
          ),
          if (_expertModeEnabled) ExpertInfoButton(info: _expertInfo(s)),
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
                  decoration: InputDecoration(
                    labelText: s.practitionerNew_displayName,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return s.practitionerNew_displayNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: s.practitionerNew_firstName,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: s.practitionerNew_lastName,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _professionalIdController,
                  decoration: InputDecoration(
                    labelText: s.practitionerNew_professionalId,
                    hintText: s.practitionerNew_professionalIdHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: s.practitionerNew_email,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: s.practitionerNew_phone,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  key: const ValueKey('practitioner-appointment-step'),
                  initialValue: _appointmentStepMinutes,
                  decoration: const InputDecoration(
                    labelText: 'Pas des rendez-vous',
                    helperText:
                        'Placement et ajustement dans le planning. La durée reste libre.',
                    helperMaxLines: 2,
                  ),
                  items: [
                    for (final step in Practitioner.appointmentSteps)
                      DropdownMenuItem(
                        value: step,
                        child: Text('$step minutes'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _appointmentStepMinutes = value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: const ValueKey('practitioner-appointment-duration'),
                  controller: _appointmentDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Durée habituelle d’un rendez-vous',
                    suffixText: 'minutes',
                    helperText:
                        'Calcule la fin des nouveaux rendez-vous, indépendamment du pas.',
                    helperMaxLines: 2,
                  ),
                  validator: (value) {
                    final minutes = int.tryParse(value?.trim() ?? '');
                    return minutes == null || minutes < 1 || minutes > 840
                        ? 'Saisissez une durée entière de 1 à 840 minutes.'
                        : null;
                  },
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Horaires de travail au cabinet',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Suivre les horaires du cabinet'),
                  subtitle: const Text(
                    'Les changements d’ouverture du cabinet seront repris automatiquement.',
                  ),
                  value: _workingHours == null,
                  onChanged: (inherit) {
                    if (inherit) {
                      setState(() => _workingHours = null);
                    } else {
                      _editWorkingHours();
                    }
                  },
                ),
                if (_workingHours != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_hoursSummary()),
                  ),
                TextButton.icon(
                  onPressed: _editWorkingHours,
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    _workingHours == null
                        ? 'Définir des horaires individuels'
                        : 'Modifier les horaires individuels',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(s.practitionerNew_cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            _isEditing ? s.practitionerNew_save : s.practitionerNew_create,
          ),
        ),
      ],
    );
  }
}
