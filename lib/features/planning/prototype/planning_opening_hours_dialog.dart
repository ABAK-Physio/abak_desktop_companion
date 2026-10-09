import 'package:flutter/material.dart';
import '../models/planning_opening_hours.dart';

class _PeriodFields {
  _PeriodFields({int start = 420, int end = 1260})
    : start = TextEditingController(text: clock(start)),
      end = TextEditingController(text: clock(end));
  final TextEditingController start;
  final TextEditingController end;
  static String clock(int minute) =>
      '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';
  void dispose() {
    start.dispose();
    end.dispose();
  }
}

class PlanningOpeningHoursDialog extends StatefulWidget {
  const PlanningOpeningHoursDialog({
    super.key,
    required this.load,
    required this.save,
    this.title = 'Horaires d’ouverture',
    this.description =
        'Horaires habituels du cabinet. Les rendez-vous restent possibles hors ouverture, entre 07:00 et 21:00.',
    this.saveLabel = 'Enregistrer',
    this.closedLabel = 'Fermé',
    this.openLabel = 'Ouvert',
  });
  final String title, description, saveLabel, closedLabel, openLabel;
  final Future<PlanningOpeningHours?> Function() load;
  final Future<void> Function(PlanningOpeningHours) save;
  @override
  State<PlanningOpeningHoursDialog> createState() =>
      _PlanningOpeningHoursDialogState();
}

class _PlanningOpeningHoursDialogState
    extends State<PlanningOpeningHoursDialog> {
  final _form = GlobalKey<FormState>();
  final _days = List.generate(7, (_) => <_PeriodFields>[]);
  final _retired = <_PeriodFields>[];
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  bool _unconfigured = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final hours = await widget.load();
      if (!mounted) return;
      _unconfigured = hours == null;
      for (var i = 0; i < 7; i++) {
        _retired.addAll(_days[i]);
        _days[i].clear();
        _days[i].addAll(
          (hours?.days[i + 1] ?? []).map(
            (p) => _PeriodFields(start: p.start, end: p.end),
          ),
        );
      }
    } catch (_) {
      if (mounted) _loadFailed = true;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int? _minute(String value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.parse(match[1]!);
    final minute = int.parse(match[2]!);
    if (hour > 23 || minute > 59) return null;
    return hour * 60 + minute;
  }

  String? _validate(String? value) {
    final minute = _minute(value ?? '');
    if (minute == null) return 'Format HH:mm';
    if (minute < 420 || minute > 1260) return 'Entre 07:00 et 21:00';
    return null;
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    PlanningOpeningHours hours;
    try {
      hours = PlanningOpeningHours({
        for (var i = 0; i < 7; i++)
          i + 1: [
            for (final p in _days[i])
              OpeningPeriod(_minute(p.start.text)!, _minute(p.end.text)!),
          ],
      });
    } on ArgumentError catch (error) {
      setState(() => _error = error.message.toString());
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.save(hours);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error =
              'Enregistrement impossible. Votre saisie est conservée. Réessayez.';
        });
      }
    }
  }

  @override
  void dispose() {
    for (final p in [..._days.expand((day) => day), ..._retired]) {
      p.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 620,
        height: 440,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadFailed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Impossible de charger les horaires. Aucune modification n’a été effectuée.',
                  ),
                  TextButton(onPressed: _load, child: const Text('Réessayer')),
                ],
              )
            : AbsorbPointer(
                absorbing: _saving,
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(widget.description),
                      if (_unconfigured)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Aucun horaire enregistré. Activez les jours travaillés et ajustez leurs plages.',
                          ),
                        ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (var day = 0; day < 7; day++) _day(day),
                            ],
                          ),
                        ),
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
          onPressed: _loading || _loadFailed || _saving ? null : _save,
          child: Text(_saving ? 'Enregistrement…' : widget.saveLabel),
        ),
      ],
    ),
  );

  Widget _day(int day) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      children: [
        SwitchListTile(
          key: ValueKey('opening-day-$day'),
          contentPadding: EdgeInsets.zero,
          title: Text(PlanningOpeningHours.dayNames[day]),
          subtitle: Text(
            _days[day].isEmpty ? widget.closedLabel : widget.openLabel,
          ),
          value: _days[day].isNotEmpty,
          onChanged: (open) => setState(() {
            if (open) {
              _days[day].add(_PeriodFields());
            } else {
              _retired.addAll(_days[day]);
              _days[day].clear();
            }
          }),
        ),
        for (final period in _days[day])
          Padding(
            key: ObjectKey(period),
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: period.start,
                    validator: _validate,
                    decoration: const InputDecoration(
                      labelText: 'Ouverture',
                      hintText: 'HH:mm',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: period.end,
                    validator: _validate,
                    decoration: const InputDecoration(
                      labelText: 'Fermeture',
                      hintText: 'HH:mm',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Retirer cette plage',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => setState(() {
                    _days[day].remove(period);
                    _retired.add(period);
                  }),
                ),
              ],
            ),
          ),
        if (_days[day].isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: ValueKey('opening-add-$day'),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une plage'),
              onPressed: () => setState(() => _days[day].add(_PeriodFields())),
            ),
          ),
        const Divider(),
      ],
    ),
  );
}
