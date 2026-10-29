import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../dmp_minors/minors_simulation.dart';
import 'automation_model.dart';
import 'automation_store.dart';
import 'automation_engine.dart';
import 'automation_cases.dart';
import 'automation_scenarios.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({
    super.key,
    this.simulationRoot,
    this.serviceDelay = const Duration(seconds: 1),
  });
  final Directory? simulationRoot;
  final Duration serviceDelay;
  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  Directory? root;
  AutoEngine? engine;
  String? error;
  String report = 'Les résultats restent locaux et fictifs.';
  bool runningCases = false;
  int scenario = 1;
  final content = TextEditingController();
  String exercise = 'simulation-bilan-a';
  @override
  void initState() {
    super.initState();
    open();
  }

  Future<void> open() async {
    try {
      final dir =
          widget.simulationRoot ??
          Directory(
            '${(await getApplicationSupportDirectory()).path}/dmp-automation-simulation-v1',
          );
      dir.createSync(recursive: true);
      final pointer = File('${dir.path}/exercice-actif.txt');
      final id = pointer.existsSync()
          ? pointer.readAsStringSync().trim()
          : exercise;
      if (!RegExp(r'^simulation-[a-z0-9-]{1,80}$').hasMatch(id)) {
        throw const FormatException('Exercice invalide');
      }
      if (!mounted) return;
      root = dir;
      exercise = id;
      attach();
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Stockage simulé indisponible. Actions suspendues.',
        );
      }
    }
  }

  void attach() {
    engine?.close();
    final store = AutoStore(Directory('${root!.path}/interactif/$exercise'));
    final doc = store.read().document;
    engine = AutoEngine(
      store,
      AutoFakeService(delay: widget.serviceDelay),
      context: AutoContext(
        patient: doc.patient,
        professional: doc.professional,
        structure: doc.structure,
      ),
    );
    content.text = doc.content;
    engine!.onChanged = () {
      if (mounted) setState(() {});
    };
    setState(() {});
  }

  Future<void> validate() async {
    final e = engine!, r = e.record;
    if (r == null) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Valider médicalement — simulation'),
        content: Text(
          'Valider cette version fictive et ses visibilités ?\nPatient : ${r.document.patientVisible ? "visible" : "invisible"} ; représentants légaux : ${r.document.rlVisible ? "visible" : "invisible"}.\nLa règle déclenchera le faux service si tous les contrôles sont réunis. Une retenue empêche ce traitement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Valider cette version fictive'),
          ),
        ],
      ),
    );
    if (!mounted || accepted != true) return;
    // Modal prevents editor mutation; engine checks the current version again.
    await e.validateAndRun();
  }

  Future<void> runCases(bool all) async {
    setState(() {
      runningCases = true;
      report = 'Contrôles locaux en cours…';
    });
    try {
      final results = <Map<String, Object>>[];
      for (final n in all ? List.generate(42, (i) => i + 1) : [scenario]) {
        results.add(
          await runAutomationScenario(n, Directory('${root!.path}/scenarios')),
        );
      }
      if (mounted) {
        setState(
          () => report = all
              ? '42/42 scénarios réussis avec leurs variantes. Aucun accès réseau.'
              : '${results.single['id']} : contrôles réussis. ${results.single['titre']}',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => report =
              'Un contrôle local a échoué. Aucun succès global confirmé.',
        );
      }
    } finally {
      if (mounted) setState(() => runningCases = false);
    }
  }

  void newExercise() {
    try {
      exercise = 'simulation-${DateTime.now().microsecondsSinceEpoch}';
      final pointer = File('${root!.path}/exercice-actif.txt');
      final temp = File('${pointer.path}.pending');
      temp.writeAsStringSync(exercise, flush: true);
      temp.renameSync(pointer.path);
      attach();
      report =
          'Nouvel exercice fictif distinct. Les traces précédentes sont conservées.';
    } catch (_) {
      setState(
        () => error = 'Nouvel exercice indisponible. Aucun état ancien effacé.',
      );
    }
  }

  @override
  void dispose() {
    engine?.close();
    content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = engine, r = e?.record;
    final locked = e == null || e.reserved || runningCases;
    return Scaffold(
      appBar: AppBar(title: const Text('DMP — automatisation simulée')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SIMULATION LOCALE — sans réseau, CPS, INSi ni lot réel.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Patients fictifs sans INS. Le faux service ne produit ni CDA signé ni requête DV1. Chaque exercice possède son stockage isolé.',
            ),
            if (error != null) Text(error!),
            if (e == null && error == null)
              const Text('Ouverture du stockage simulé…'),
            if (e != null) ...[
              DropdownButtonFormField<int>(
                initialValue: scenario,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Scénario à vérifier',
                ),
                items: [
                  for (var i = 0; i < 42; i++)
                    DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        '${automationCases[i]['id']} — ${automationCases[i]['titre']}',
                      ),
                    ),
                ],
                onChanged: runningCases
                    ? null
                    : (v) => setState(() => scenario = v!),
              ),
              OutlinedButton(
                onPressed: runningCases || e.busy
                    ? null
                    : () => runCases(false),
                child: const Text('Exécuter ce scénario — simulation'),
              ),
              FilledButton(
                onPressed: runningCases || e.busy ? null : () => runCases(true),
                child: const Text('Exécuter les 42 scénarios — simulation'),
              ),
              Text(report, key: const Key('automation-report')),
              const Divider(),
              Text('Exercice actif : $exercise'),
              Text(
                'État : ${e.status.message}',
                key: const Key('automation-status'),
              ),
              Text(
                'Appels au faux service dans cette ouverture : ${e.service.sent.length}. Appels réseau : 0.',
              ),
              if (r != null) ...[
                Text(
                  r.validated == r.document.version
                      ? 'Version courante validée médicalement (simulation).'
                      : 'Version courante non validée.',
                ),
                SwitchListTile(
                  title: const Text('Règle automatique activée'),
                  value: r.rule.enabled,
                  onChanged: locked
                      ? null
                      : (v) => e.updateRule(
                          AutoRule(
                            enabled: v,
                            type: r.rule.type,
                            minors: r.rule.minors,
                            majority: r.rule.majority,
                            cumulative: r.rule.cumulative,
                          ),
                        ),
                ),
                DropdownButtonFormField<String>(
                  key: ValueKey('rule-$exercise'),
                  initialValue: r.rule.type,
                  decoration: const InputDecoration(
                    labelText: 'Type couvert par la règle',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'bilan-kine-fictif',
                      child: Text('Bilan kiné fictif'),
                    ),
                    DropdownMenuItem(
                      value: 'autre-type-fictif',
                      child: Text('Autre type fictif'),
                    ),
                  ],
                  onChanged: locked
                      ? null
                      : (v) => e.updateRule(
                          AutoRule(
                            enabled: r.rule.enabled,
                            type: v!,
                            minors: r.rule.minors,
                            majority: r.rule.majority,
                            cumulative: r.rule.cumulative,
                          ),
                        ),
                ),
                SwitchListTile(
                  title: const Text('Retenir l’envoi simulé'),
                  value: r.held,
                  onChanged: runningCases
                      ? null
                      : (v) {
                          if (v) {
                            e.hold(true);
                          } else {
                            e.releaseAndRun();
                          }
                        },
                ),
                const Text(
                  'Lever la retenue réévalue la règle. Une tentative déjà engagée ne peut pas être annulée par ce bouton.',
                ),
                DropdownButtonFormField<SimPatient>(
                  key: ValueKey('patient-$exercise'),
                  initialValue: r.document.patient,
                  decoration: const InputDecoration(
                    labelText: 'Patient fictif',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: SimPatient.adult,
                      child: Text('Adulte fictif — 20 ans'),
                    ),
                    DropdownMenuItem(
                      value: SimPatient.child,
                      child: Text('Enfant fictif — 12 ans'),
                    ),
                  ],
                  onChanged: locked
                      ? null
                      : (v) {
                          e.updateDocument(r.document.copy(patient: v!));
                          e.setContext(AutoContext(patient: v));
                        },
                ),
                if (r.document.patient == SimPatient.child) ...[
                  const Text(
                    'Nouveau choix normal/secret requis pour chaque session. Le choix n’est pas mémorisé.',
                  ),
                  OutlinedButton(
                    onPressed: locked
                        ? null
                        : () => e.setContext(e.context.copy(secret: false)),
                    child: const Text('Choisir normal — simulation'),
                  ),
                  OutlinedButton(
                    onPressed: locked
                        ? null
                        : () => e.setContext(e.context.copy(secret: true)),
                    child: const Text('Choisir secret — simulation'),
                  ),
                  Text(
                    e.context.secret == null
                        ? 'Choix de session absent.'
                        : e.context.secret!
                        ? 'CONNEXION SECRÈTE SIMULÉE'
                        : 'Connexion normale simulée.',
                  ),
                ],
                TextField(
                  key: const Key('auto-content'),
                  controller: content,
                  maxLines: 3,
                  enabled: !locked,
                  decoration: const InputDecoration(
                    labelText: 'Contenu clinique fictif',
                  ),
                  onChanged: (v) =>
                      e.updateDocument(r.document.copy(content: v)),
                ),
                SwitchListTile(
                  title: const Text('Document visible au patient'),
                  value: r.document.patientVisible,
                  onChanged: locked
                      ? null
                      : (v) => e.updateDocument(
                          r.document.copy(patientVisible: v),
                        ),
                ),
                SwitchListTile(
                  title: const Text(
                    'Document visible aux représentants légaux',
                  ),
                  value: r.document.rlVisible,
                  onChanged: locked || e.context.secret == true
                      ? null
                      : (v) => e.updateDocument(r.document.copy(rlVisible: v)),
                ),
                SwitchListTile(
                  title: const Text('Opposition au nouveau dépôt'),
                  value: e.context.opposition,
                  onChanged: locked
                      ? null
                      : (v) => e.setContext(e.context.copy(opposition: v)),
                ),
                FilledButton(
                  onPressed: locked || e.busy ? null : validate,
                  child: const Text('Valider médicalement — simulation'),
                ),
                const Text(
                  'La validation déclenche automatiquement les contrôles et le faux service ; aucun bouton d’envoi réel. La modification après un succès reste bloquée ou à préparer dans un parcours distinct.',
                ),
              ],
              OutlinedButton(
                onPressed: e.busy || runningCases || r == null
                    ? null
                    : newExercise,
                child: const Text('Commencer un nouvel exercice fictif'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
