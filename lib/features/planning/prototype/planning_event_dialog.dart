import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../patients/models/patient.dart';
import 'planning_calendar_adapter.dart';
import 'planning_patient_picker.dart';

class PlanningEventDialog extends StatefulWidget {
  const PlanningEventDialog({
    super.key,
    required this.date,
    this.event,
    this.onSave,
    this.persistent = false,
    this.searchPatients,
  });

  final Future<bool> Function(CalendarEventData<Object?>)? onSave;
  final bool persistent;
  final Future<List<Patient>> Function(String)? searchPatients;
  final DateTime date;
  final CalendarEventData<Object?>? event;

  @override
  State<PlanningEventDialog> createState() => _PlanningEventDialogState();
}

class _PlanningEventDialogState extends State<PlanningEventDialog> {
  PlanningPatientLink? _patient;
  bool _saving = false;
  bool _failed = false;
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _start;
  late final TextEditingController _end;
  late DateTime _date;
  late bool _allDay;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _patient = event?.event is PlanningPatientLink
        ? event!.event as PlanningPatientLink
        : null;
    _date = DateUtils.dateOnly(event?.date ?? widget.date);
    _allDay = event?.isFullDayEvent ?? false;
    final minute = (widget.date.hour * 60 + widget.date.minute).clamp(
      420,
      1245,
    );
    String clock(int value) =>
        '${(value ~/ 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}';
    _title = TextEditingController(text: event?.title ?? '');
    _notes = TextEditingController(text: event?.description ?? '');
    _start = TextEditingController(
      text: event?.startTime == null
          ? clock(minute)
          : DateFormat.Hm().format(event!.startTime!),
    );
    _end = TextEditingController(
      text: event?.endTime == null
          ? clock((minute + 45).clamp(420, 1260))
          : DateFormat.Hm().format(event!.endTime!),
    );
  }

  @override
  void dispose() {
    for (final controller in [_title, _notes, _start, _end]) {
      controller.dispose();
    }
    super.dispose();
  }

  int? _minutes(String value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.parse(match[1]!);
    final minute = int.parse(match[2]!);
    if (hour > 23 || minute > 59) return null;
    return hour * 60 + minute;
  }

  String? _validateTime(String? value, {bool end = false}) {
    final minute = _minutes(value ?? '');
    if (minute == null) return 'Utilisez le format HH:mm.';
    if (minute < 420 || minute > 1260) return 'Entre 07:00 et 21:00.';
    if (end && minute <= (_minutes(_start.text) ?? -1)) {
      return 'La fin doit suivre le début.';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_form.currentState!.validate()) return;
    DateTime at(int minute) =>
        DateTime(_date.year, _date.month, _date.day, minute ~/ 60, minute % 60);
    final result = CalendarEventData<Object?>(
      date: _date,
      title: _title.text.trim(),
      description: _notes.text.trim(),
      startTime: _allDay ? null : at(_minutes(_start.text)!),
      endTime: _allDay ? null : at(_minutes(_end.text)!),
      color: widget.event?.color ?? Colors.teal.shade100,
      event: _patient ?? planningEventId(widget.event?.event),
    );
    setState(() {
      _saving = true;
      _failed = false;
    });
    final saved = widget.onSave == null || await widget.onSave!(result);
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context, result);
    } else {
      setState(() {
        _saving = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(
          widget.event == null
              ? 'Nouveau rendez-vous'
              : 'Modifier le rendez-vous',
        ),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_failed)
                    const Text(
                      'Enregistrement impossible. Votre saisie est conservée. Réessayez.',
                      style: TextStyle(color: Colors.red),
                    ),
                  TextFormField(
                    controller: _title,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Titre'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Indiquez un titre.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (widget.searchPatients != null) ...[
                    Text(
                      _patient == null
                          ? 'Sans patient'
                          : 'Patient : ${_patient!.label}',
                    ),
                    Wrap(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.person_search),
                          label: Text(
                            _patient == null
                                ? 'Associer un patient'
                                : 'Changer de patient',
                          ),
                          onPressed: _saving
                              ? null
                              : () async {
                                  final patient = await showDialog<Patient>(
                                    context: context,
                                    builder: (_) => PlanningPatientPicker(
                                      search: widget.searchPatients!,
                                    ),
                                  );
                                  if (!mounted || patient == null) return;
                                  setState(
                                    () => _patient = PlanningPatientLink(
                                      appointmentId: planningEventId(
                                        widget.event?.event,
                                      ),
                                      patientId: patient.patientId,
                                      label: patient.displayName,
                                    ),
                                  );
                                },
                        ),
                        if (_patient != null)
                          TextButton(
                            onPressed: _saving
                                ? null
                                : () => setState(() => _patient = null),
                            child: const Text('Retirer le patient'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat.yMMMMEEEEd('fr_FR').format(_date)),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(1970),
                        lastDate: DateTime(2100, 12, 31),
                      );
                      if (date != null && mounted) setState(() => _date = date);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Toute la journée'),
                    value: _allDay,
                    onChanged: (value) => setState(() => _allDay = value),
                  ),
                  if (!_allDay) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _start,
                            decoration: const InputDecoration(
                              labelText: 'Début',
                              hintText: '09:00',
                            ),
                            validator: _validateTime,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _end,
                            decoration: const InputDecoration(
                              labelText: 'Fin',
                              hintText: '09:45',
                            ),
                            validator: (value) =>
                                _validateTime(value, end: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Horaires du prototype : 07:00–21:00.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notes (facultatif)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.persistent
                        ? 'Enregistré sur cet ordinateur.'
                        : 'Conservé uniquement pendant cette session.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Enregistrement…' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }
}
