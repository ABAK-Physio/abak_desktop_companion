import 'package:flutter/material.dart';

import '../data/practitioner_cps_service.dart';
import '../models/practitioner_cps_dates.dart';

/// This route only reads the local profile and edits user-declared dates.
Future<PractitionerCpsDates?> showPractitionerCpsDatesDialog({
  required BuildContext context,
  required PractitionerCpsService service,
  required String practitionerId,
  required PractitionerCpsReading reading,
}) async {
  final row = await PractitionerCpsService.storedDates(
    await service.database(),
    practitionerId,
  );
  final initial = PractitionerCpsService.datesFromStored(reading, row);
  if (!context.mounted) return null;
  return showDialog<PractitionerCpsDates>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DatesDialog(
      service: service,
      practitionerId: practitionerId,
      reading: reading,
      initial: initial,
    ),
  );
}

class _DatesDialog extends StatefulWidget {
  const _DatesDialog({
    required this.service,
    required this.practitionerId,
    required this.reading,
    required this.initial,
  });
  final PractitionerCpsService service;
  final String practitionerId;
  final PractitionerCpsReading reading;
  final PractitionerCpsDates initial;
  @override
  State<_DatesDialog> createState() => _DatesDialogState();
}

class _DatesDialogState extends State<_DatesDialog> {
  late PractitionerCpsDates dates = widget.initial;
  bool busy = false;
  String error = '';

  Future<void> save() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final result = await widget.service.saveDates(
        practitionerId: widget.practitionerId,
        reading: widget.reading,
        dates: dates,
        expectedRevision: widget.initial.revision,
      );
      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      if (mounted) {
        setState(
          () => error = switch (e) {
            StateError() => e.message.toString(),
            FormatException() => e.message,
            _ => 'Enregistrement impossible. Vos dates restent affichées.',
          },
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: const Text('Dates de la CPS et des situations d’exercice'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.reading.profile.givenName} ${widget.reading.profile.familyName}',
              ),
              const Text(
                'Informations déclarées, facultatives. Laissez les dates inconnues vides. '
                'Aucune lecture de carte ni validation du rapport.',
              ),
              const SizedBox(height: 16),
              PractitionerCpsDatesFields(
                reading: widget.reading,
                value: dates,
                enabled: !busy,
                onChanged: (value) => setState(() => dates = value),
              ),
              if (error.isNotEmpty)
                Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: const Text('Enregistrer les dates'),
        ),
      ],
    ),
  );
}

class PractitionerCpsDatesFields extends StatelessWidget {
  const PractitionerCpsDatesFields({
    super.key,
    required this.reading,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final PractitionerCpsReading reading;
  final PractitionerCpsDates value;
  final bool enabled;
  final ValueChanged<PractitionerCpsDates> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      OptionalCivilDateField(
        label: 'Date d’émission de la CPS (facultative)',
        value: value.issueDate,
        enabled: enabled,
        onChanged: (date) => onChanged(
          PractitionerCpsDates(
            issueDate: date,
            exerciseStarts: value.exerciseStarts,
            revision: value.revision,
          ),
        ),
      ),
      const Text(
        'La date d’émission de la carte est distincte du début d’exercice dans un cabinet.',
      ),
      for (final situation in reading.profile.situations) ...[
        const SizedBox(height: 16),
        Text(
          'Situation ${situation.number} · ${situation.structureName ?? 'structure non renseignée'} · ${situation.structureId ?? 'identifiant absent'}',
        ),
        OptionalCivilDateField(
          label: 'Début d’exercice dans cette situation (facultatif)',
          value: value.exerciseStarts[situation.number],
          enabled: enabled,
          onChanged: (date) {
            final starts = Map<int, String>.from(value.exerciseStarts);
            if (date == null) {
              starts.remove(situation.number);
            } else {
              starts[situation.number] = date;
            }
            onChanged(
              PractitionerCpsDates(
                issueDate: value.issueDate,
                exerciseStarts: starts,
                revision: value.revision,
              ),
            );
          },
        ),
      ],
    ],
  );
}

/// No default date is committed. Choosing and clearing require an explicit action.
class OptionalCivilDateField extends StatelessWidget {
  const OptionalCivilDateField({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final String label;
  final String? value;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  static String display(String? value) => value == null || value.isEmpty
      ? 'Non renseignée'
      : '${value.substring(8, 10)}/${value.substring(5, 7)}/${value.substring(0, 4)}';

  Future<void> pick(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: value == null ? DateTime.now() : DateTime.parse(value!),
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
      helpText: label,
    );
    if (selected != null && context.mounted) {
      onChanged(selected.toIso8601String().substring(0, 10));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Expanded(child: Text(display(value))),
          IconButton(
            onPressed: enabled ? () => pick(context) : null,
            tooltip: 'Choisir la date',
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          IconButton(
            onPressed: enabled && value != null ? () => onChanged(null) : null,
            tooltip: 'Laisser cette date inconnue',
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
    ),
  );
}
