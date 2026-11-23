import 'package:flutter/material.dart';
import 'companion_access_service.dart';
import 'patient_reassignment_models.dart';

class PatientReassignmentScreen extends StatefulWidget {
  const PatientReassignmentScreen({super.key, this.service});
  final CompanionAccessService? service;
  @override
  State<PatientReassignmentScreen> createState() =>
      _PatientReassignmentScreenState();
}

class _PatientReassignmentScreenState extends State<PatientReassignmentScreen> {
  late final service = widget.service ?? CompanionAccessService();
  List<ReassignmentSource> sources = [];
  List<AccessPractitioner> people = [];
  List<ReassignmentPatient> patients = [];
  ReassignmentSource? source;
  String? target, error, success;
  final choices = <String, String>{};
  bool loading = true, busy = false, all = true;
  int revision = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    revision++;
    super.dispose();
  }

  Future<void> load() async {
    final attempt = ++revision;
    setState(() {
      loading = true;
      error = null;
      source = null;
      patients = [];
      choices.clear();
      target = null;
    });
    try {
      final values = await service.reassignmentSources();
      final practitioners = await service.practitioners();
      if (!mounted || revision != attempt) return;
      setState(() {
        sources = values;
        people = practitioners;
        loading = false;
      });
    } catch (_) {
      if (mounted && revision == attempt) {
        setState(() {
          loading = false;
          error = 'Impossible de charger les affectations. Réessayez.';
        });
      }
    }
  }

  Future<void> chooseSource(ReassignmentSource? value) async {
    final attempt = ++revision;
    setState(() {
      source = value;
      patients = [];
      target = null;
      choices.clear();
      error = success = null;
      loading = true;
    });
    try {
      final values = value == null
          ? <ReassignmentPatient>[]
          : await service.reassignmentPatients(value.id);
      if (!mounted || revision != attempt) return;
      setState(() {
        patients = values;
        loading = false;
      });
    } catch (_) {
      if (mounted && revision == attempt) {
        setState(() {
          loading = false;
          error = 'Impossible de charger les dossiers. Rechargez la liste.';
        });
      }
    }
  }

  List<AccessPractitioner> get targets =>
      people.where((p) => p.id != source?.id).toList();
  Map<String, String> get assignments => all
      ? {
          if (target != null)
            for (final patient in patients) patient.id: target!,
        }
      : Map.of(choices);
  Future<void> save() async {
    final selected = source;
    final changes = assignments;
    if (busy || loading || selected == null || changes.isEmpty) return;
    final full = all;
    final review = [
      for (final patient in patients)
        if (changes.containsKey(patient.id))
          '${patient.name}${patient.archived ? ' (dossier archivé)' : ''} → ${people.singleWhere((p) => p.id == changes[patient.id]).name}',
    ];
    setState(() {
      busy = true;
      error = success = null;
    });
    String? key;
    try {
      key = await showDialog<String>(
        context: context,
        builder: (_) =>
            _ReassignmentConfirmation(source: selected.name, review: review),
      );
      if (key == null || !mounted) return;
      final count = await service.reassignPatientsWithKey(
        key: key,
        sourceId: selected.id,
        assignments: changes,
        entireSource: full,
      );
      if (!mounted) return;
      setState(() => success = '$count dossier(s) réaffecté(s).');
      await load();
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is CompanionAccessException
              ? e.message
              : 'Aucun changement n’a été enregistré. Réessayez.',
        );
      }
    } finally {
      key = null;
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Réaffecter les patients')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Cette opération exceptionnelle nécessite la clé de récupération du cabinet, même pour un administrateur et même hors mode DMP.',
              ),
              const SizedBox(height: 8),
              const Text(
                'Elle change le référent des dossiers patients. Les rédacteurs des documents, les épisodes de soins et les fichiers ne sont pas modifiés.',
              ),
              if (success != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(success!),
                ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReassignmentSource>(
                key: ValueKey(source),
                initialValue: source,
                decoration: const InputDecoration(labelText: 'Référent actuel'),
                isExpanded: true,
                items: sources
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text('${s.name} — ${s.patientCount} dossier(s)'),
                      ),
                    )
                    .toList(),
                onChanged: busy || loading ? null : chooseSource,
              ),
              TextButton(
                onPressed: busy ? null : load,
                child: const Text('Recharger la liste'),
              ),
              if (loading) const LinearProgressIndicator(),
              if (!loading && source != null) ...[
                Text(
                  '${patients.length} dossier(s), dont ${patients.where((p) => p.archived).length} archivé(s).',
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: all,
                  title: const Text('Tous les patients vers un même kiné'),
                  subtitle: const Text(
                    'Désactivez pour choisir patient par patient.',
                  ),
                  onChanged: busy
                      ? null
                      : (value) => setState(() {
                          all = value;
                          choices.clear();
                          target = null;
                        }),
                ),
                if (targets.isEmpty)
                  const Text(
                    'Aucun autre kiné disponible. Créez sa fiche avant de réaffecter les patients.',
                  ),
                if (all)
                  DropdownButtonFormField<String>(
                    key: ValueKey(('target', source, target)),
                    initialValue: target,
                    decoration: const InputDecoration(
                      labelText: 'Nouveau référent',
                    ),
                    isExpanded: true,
                    items: targets
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: busy
                        ? null
                        : (value) => setState(() => target = value),
                  ),
                if (!all)
                  const Text(
                    'Les lignes sans nouveau référent restent inchangées.',
                  ),
                const SizedBox(height: 16),
                for (final patient in patients)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${patient.name}${patient.archived ? ' — dossier archivé' : ''}',
                          ),
                          if (patient.birthDate != null)
                            Text('Date de naissance : ${patient.birthDate}'),
                          if (patient.formerReferrer != null)
                            Text('Ancien référent : ${patient.formerReferrer}'),
                          if (!all)
                            DropdownButtonFormField<String>(
                              key: ValueKey((patient.id, choices[patient.id])),
                              initialValue: choices[patient.id] ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Nouveau référent',
                              ),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('Ne pas modifier'),
                                ),
                                for (final p in targets)
                                  DropdownMenuItem(
                                    value: p.id,
                                    child: Text(p.name),
                                  ),
                              ],
                              onChanged: busy
                                  ? null
                                  : (value) => setState(() {
                                      if (value == null || value.isEmpty) {
                                        choices.remove(patient.id);
                                      } else {
                                        choices[patient.id] = value;
                                      }
                                    }),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy || assignments.isEmpty ? null : save,
                  child: Text(
                    busy
                        ? 'Enregistrement…'
                        : 'Vérifier et réaffecter (${assignments.length})',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _ReassignmentConfirmation extends StatefulWidget {
  const _ReassignmentConfirmation({required this.source, required this.review});
  final String source;
  final List<String> review;
  @override
  State<_ReassignmentConfirmation> createState() =>
      _ReassignmentConfirmationState();
}

class _ReassignmentConfirmationState extends State<_ReassignmentConfirmation> {
  final keyInput = TextEditingController();
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    keyInput.clear();
    keyInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Confirmer la réaffectation'),
    content: SizedBox(
      width: 620,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Référent actuel : ${widget.source}'),
              Text('${widget.review.length} dossier(s) seront réaffectés :'),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: ListView(
                  children: [
                    for (final line in widget.review)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(line),
                      ),
                  ],
                ),
              ),
              TextFormField(
                controller: keyInput,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'Clé de récupération',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Saisissez la clé de récupération.'
                    : null,
              ),
              const Text(
                'Un code administrateur ou un accès Urgence ne remplace pas cette clé.',
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(context, keyInput.text);
          }
        },
        child: const Text('Confirmer'),
      ),
    ],
  );
}
