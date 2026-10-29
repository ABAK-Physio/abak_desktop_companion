import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/practitioner_cps_service.dart';
import '../models/practitioner_cps_dates.dart';
import 'practitioner_cps_dates_dialog.dart';

/// No card access on opening, selecting a person or restoring saved data.
class PractitionerCpsDialog extends StatefulWidget {
  const PractitionerCpsDialog({
    super.key,
    required this.service,
    this.targetId,
    this.checkTarget,
  });
  final PractitionerCpsService service;
  final String? targetId;
  final CpsTargetCheck? checkTarget;
  @override
  State<PractitionerCpsDialog> createState() => _PractitionerCpsDialogState();
}

class _PractitionerCpsDialogState extends State<PractitionerCpsDialog>
    with WidgetsBindingObserver {
  final pin = TextEditingController();
  List<Map<String, Object?>> people = [];
  String? target;
  PractitionerCpsReading? reading, saved;
  PractitionerCpsProposal? proposal;
  PractitionerCpsDates dates = PractitionerCpsDates();
  bool busy = true, confirmed = false;
  int generation = 0;
  String error = '';

  @override
  void initState() {
    super.initState();
    target = widget.targetId;
    WidgetsBinding.instance.addObserver(this);
    load();
  }

  Future<void> load() async {
    try {
      final list = await widget.service.practitioners();
      final stored = target == null
          ? null
          : await PractitionerCpsService.stored(
              await widget.service.database(),
              target!,
            );
      if (!mounted) return;
      setState(() {
        people = list;
        saved = stored == null
            ? null
            : PractitionerCpsReading.fromStored(stored);
        if (target != null &&
            !people.any((p) => p['practitioner_id'] == target)) {
          error = 'La fiche du kiné est absente ou inactive.';
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Chargement de la fiche CPS locale impossible.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      generation++;
      pin.clear();
      setState(() {
        reading = null;
        proposal = null;
        confirmed = false;
        dates = PractitionerCpsDates();
      });
    }
  }

  @override
  void dispose() {
    generation++;
    WidgetsBinding.instance.removeObserver(this);
    pin.clear();
    pin.dispose();
    super.dispose();
  }

  String messageFor(Object e) => switch (e) {
    PlatformException() => e.message ?? 'Lecture CPS impossible.',
    StateError() => e.message.toString(),
    FormatException() => e.message,
    _ => 'Opération impossible. Aucune association automatique effectuée.',
  };

  Future<void> read() async {
    if (busy) return;
    var secret = pin.text;
    pin.clear();
    final token = ++generation;
    setState(() {
      busy = true;
      error = '';
      reading = null;
      proposal = null;
      confirmed = false;
      dates = PractitionerCpsDates();
    });
    try {
      final result = await widget.service.read(secret);
      if (!mounted || token != generation) return;
      final suggested =
          widget.targetId ?? await widget.service.matchingPractitioner(result);
      if (!mounted || token != generation) return;
      if (suggested != null &&
          !people.any((p) => p['practitioner_id'] == suggested)) {
        throw StateError(
          'Cette CPS est associée à une fiche absente ou inactive. Association bloquée.',
        );
      }
      setState(() {
        reading = result;
        target = suggested;
      });
      await prepare(token);
    } catch (e) {
      if (mounted && token == generation) setState(() => error = messageFor(e));
    } finally {
      secret = '';
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> prepare(int token) async {
    final current = reading;
    if (current == null) return;
    final result = await widget.service.prepare(current, target);
    if (widget.checkTarget != null) {
      await widget.checkTarget!(
        await widget.service.database(),
        result.practitionerId,
      );
    }
    if (!mounted || token != generation) return;
    setState(() {
      proposal = result;
      confirmed = false;
      error = '';
    });
  }

  Future<void> select(String? value) async {
    if (busy) return;
    final token = ++generation;
    setState(() {
      target = value == '' ? null : value;
      proposal = null;
      confirmed = false;
      busy = true;
      error = '';
    });
    try {
      await prepare(token);
    } catch (e) {
      if (mounted && token == generation) setState(() => error = messageFor(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    final current = proposal;
    if (busy || !confirmed || current == null) return;
    setState(() => busy = true);
    try {
      final id = await widget.service.confirm(
        current,
        checkTarget: widget.checkTarget,
        dates: dates,
      );
      if (mounted) Navigator.pop(context, id);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = messageFor(e);
          proposal = null;
          confirmed = false;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> editSavedDates() async {
    final current = saved;
    final id = target;
    if (busy || current == null || id == null) return;
    setState(() => busy = true);
    try {
      final result = await showPractitionerCpsDatesDialog(
        context: context,
        service: widget.service,
        practitionerId: id,
        reading: current,
      );
      if (result != null && mounted) Navigator.pop(context, id);
    } catch (e) {
      if (mounted) setState(() => error = messageFor(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = reading;
    final displayedTarget = people
        .where((p) => p['practitioner_id'] == target)
        .firstOrNull;
    return PopScope(
      canPop: !busy,
      child: AlertDialog(
        title: const Text('Compléter la fiche du kiné depuis la CPS'),
        content: SizedBox(
          width: 650,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'La lecture récupère les informations professionnelles. Elle ne signe aucun document et ne réalise aucun accès DMP ou INSi.',
                ),
                if (widget.targetId != null)
                  Text(
                    'Fiche à compléter : ${displayedTarget?['display_name'] ?? 'indisponible'}',
                  ),
                if (saved != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Dernière lecture enregistrée : ${saved!.readAt.toLocal()}',
                  ),
                  Text(
                    '${saved!.profile.givenName} ${saved!.profile.familyName} · ${saved!.profile.nationalId}',
                  ),
                  Text(saved!.profile.professionLabel),
                  for (final s in saved!.profile.situations)
                    Text(
                      'Situation ${s.number} · ${s.structureName ?? 'structure non renseignée'} · ${s.structureId ?? 'identifiant absent'}',
                    ),
                  const Text(
                    'Données conservées localement ; aucune authentification active attestée.',
                  ),
                  if (result == null)
                    OutlinedButton.icon(
                      onPressed: busy ? null : editSavedDates,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Compléter les dates sans lire la CPS'),
                    ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: pin,
                  enabled: !busy,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'PIN de la CPS',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: busy ? null : read,
                  icon: const Icon(Icons.badge_outlined),
                  label: const Text('Lire la CPS pour cette fiche'),
                ),
                const Text(
                  'Une lecture par clic. Le PIN n’est jamais enregistré.',
                ),
                if (busy) const LinearProgressIndicator(),
                if (error.isNotEmpty)
                  Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (result != null) ...[
                  const Divider(),
                  Text(
                    '${result.profile.givenName} ${result.profile.familyName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${result.profile.professionLabel} · Identifiant national : ${result.profile.nationalId}',
                  ),
                  for (final s in result.profile.situations)
                    Text(
                      'Situation ${s.number} · ${s.structureName ?? 'structure non renseignée'} · ${s.structureId ?? 'identifiant absent'}',
                    ),
                  const Text(
                    'La session carte est fermée après lecture. Ces données ne permettent pas de signer sans une nouvelle opération CPS.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dates facultatives déclarées : laissez les dates inconnues vides. '
                    'Une nouvelle lecture ne reconduit pas automatiquement les anciennes dates.',
                  ),
                  PractitionerCpsDatesFields(
                    reading: result,
                    value: dates,
                    enabled: !busy,
                    onChanged: (value) => setState(() => dates = value),
                  ),
                  if (widget.targetId == null)
                    DropdownButtonFormField<String>(
                      key: ValueKey(target),
                      initialValue: target ?? '',
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Fiche locale à associer',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Créer une nouvelle fiche depuis la CPS'),
                        ),
                        for (final p in people)
                          DropdownMenuItem(
                            value: p['practitioner_id'] as String,
                            child: Text(p['display_name'] as String),
                          ),
                      ],
                      onChanged: busy ? null : select,
                    ),
                  if (proposal != null) ...[
                    Text(
                      '${proposal!.existing == null ? 'Création' : 'Mise à jour'} de la fiche « ${proposal!.label} ». Noms, identifiant, profession et situations seront conservés avec la date de lecture. Le surnom et les coordonnées existants sont conservés.',
                    ),
                    if (proposal!.existing != null &&
                        (proposal!.existing!['professional_id'] as String? ??
                                '')
                            .trim()
                            .isEmpty)
                      const Text(
                        'Cette fiche n’a pas d’identifiant professionnel : la correspondance ne peut pas être établie automatiquement. Vérifiez la personne avant de confirmer.',
                      ),
                    CheckboxListTile(
                      value: confirmed,
                      onChanged: busy
                          ? null
                          : (v) => setState(() => confirmed = v == true),
                      title: Text(
                        'Je confirme que cette CPS correspond au kiné de la fiche « ${proposal!.label} ».',
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ],
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
            onPressed: busy || !confirmed || proposal == null ? null : save,
            child: const Text('Enregistrer les informations CPS'),
          ),
        ],
      ),
    );
  }
}
