import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'minors_simulation.dart';
import 'minors_scenarios.dart';
import '../dmp_resources/dmp_resources.dart';

class MinorsScreen extends StatefulWidget {
  const MinorsScreen({super.key, this.simulationRoot});
  final Directory? simulationRoot;
  @override
  State<MinorsScreen> createState() => _MinorsScreenState();
}

class _MinorsScreenState extends State<MinorsScreen> {
  Directory? root;
  MinorSimulationStore? store;
  String? storageError;
  String message = 'Choisissez une connexion pour ce patient fictif.';
  int scenario = 1;
  SimPatient patient = SimPatient.child;
  bool enabled = true,
      cumulative = false,
      rlVisible = false,
      patientVisible = false,
      maskedPs = false;
  int majority = 18;
  List<SimDocument> documents = [];
  final session = MinorSession(MinorContext(today: DateTime.utc(2026, 10, 16)));
  String get documentId => 'SIM-INTERACTIF-${patient.name}';
  SimDocument? get existing =>
      documents.where((d) => d.id == documentId).firstOrNull;
  @override
  void initState() {
    super.initState();
    open();
  }

  Future<void> open() async {
    try {
      final directory =
          widget.simulationRoot ??
          Directory(
            '${(await getApplicationSupportDirectory()).path}/dmp-minors-simulation-v1',
          );
      final nextStore = MinorSimulationStore(
        Directory('${directory.path}/interactif'),
      );
      final saved = nextStore.read();
      if (!mounted) return;
      setState(() {
        root = directory;
        store = nextStore;
        documents = saved;
        restoreFlags();
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => storageError =
              'Stockage des simulations invalide ou indisponible. Actions suspendues. Aucun fichier remplacé.',
        );
      }
    }
  }

  void restoreFlags() {
    rlVisible = existing?.rlVisible ?? false;
    patientVisible = existing?.patientVisible ?? false;
    maskedPs = existing?.maskedPs ?? false;
  }

  void contextChanged() {
    session.changeContext(
      MinorContext.fromParameters(
        patient: patient,
        today: DateTime.utc(2026, 10, 16),
        parameters: DmpParameters(enabled, majority, cumulative, []),
      ),
    );
    restoreFlags();
    message =
        'Contexte changé. Nouveau choix de connexion requis pour un mineur.';
  }

  void perform(void Function() action) {
    setState(() {
      try {
        action();
      } on StateError catch (e) {
        message = e.message.toString();
      } catch (_) {
        message =
            'Échec du stockage ou du contrôle local. Aucun succès confirmé.';
        session.invalidate();
      }
    });
  }

  Future<void> reveal(bool representatives) async {
    final original = existing;
    if (original == null) return;
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rendre visible — simulation'),
        content: Text(
          'Rendre ce document fictif visible ${representatives ? "aux représentants légaux" : "au patient"} est irréversible, même lors d’un remplacement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    perform(() {
      if (approved != true) {
        message = 'Passage visible annulé. Document fictif inchangé.';
        return;
      }
      final changed = session.reveal(
        original,
        representatives: representatives,
        confirmed: true,
      );
      store!.save(changed);
      documents = store!.read();
      restoreFlags();
      message =
          'Visibilité conservée dans le stockage fictif. Remasquage désormais interdit.';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('DMP — mineurs et connexion secrète simulés'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'SIMULATION LOCALE — aucun réseau, aucune CPS ni fonction INSi.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Identités sans INS. Stockage réservé aux documents fictifs. Aucun lot réel. Date simulée : 16 octobre 2026. Aucune requête ni VIHF utilisable ne sont produits.',
          ),
          if (storageError != null) Text(storageError!),
          if (store == null && storageError == null)
            const Text('Ouverture du stockage fictif…'),
          if (store != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Banc des 23 scénarios : chaque exécution utilise un nouveau dossier isolé.',
            ),
            DropdownButtonFormField<int>(
              initialValue: scenario,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Scénario à vérifier',
              ),
              items: [
                for (var n = 1; n <= 23; n++)
                  DropdownMenuItem(
                    value: n,
                    child: Text(
                      'M${n.toString().padLeft(2, '0')} — ${minorScenarioTitles[n - 1]}',
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => scenario = v!),
            ),
            FilledButton(
              onPressed: () => perform(() {
                final result = runMinorScenario(
                  scenario,
                  Directory('${root!.path}/scenarios'),
                );
                message =
                    '${result.id} : contrôles locaux réussis.\n${result.checks.join('\n')}';
              }),
              child: const Text('Exécuter le scénario — simulation'),
            ),
            OutlinedButton(
              onPressed: () => perform(() {
                final results = [
                  for (var n = 1; n <= 23; n++)
                    runMinorScenario(n, Directory('${root!.path}/scenarios')),
                ];
                message =
                    '${results.length}/23 scénarios locaux réussis. M21 vérifie l’absence de seuil minimum ; l’option n’est pas implémentée.';
              }),
              child: const Text('Exécuter les 23 scénarios — simulation'),
            ),
            Text(message, key: const Key('minor-message')),
            const Divider(),
            const Text('Essai interactif et persistance des documents fictifs'),
            DropdownButtonFormField<SimPatient>(
              initialValue: patient,
              decoration: const InputDecoration(labelText: 'Patient fictif'),
              items: [
                for (final p in SimPatient.values)
                  DropdownMenuItem(
                    value: p,
                    child: Text(switch (p) {
                      SimPatient.child => 'Enfant — 12 ans',
                      SimPatient.threshold => 'Anniversaire — 18 ans',
                      SimPatient.adult => 'Adulte — 20 ans',
                      SimPatient.unknown => 'Naissance inconnue',
                      SimPatient.future => 'Naissance future',
                    }),
                  ),
              ],
              onChanged: (v) => setState(() {
                patient = v!;
                contextChanged();
              }),
            ),
            DropdownButtonFormField<int>(
              initialValue: majority,
              decoration: const InputDecoration(labelText: 'Majorité simulée'),
              items: [
                for (final age in [18, 21])
                  DropdownMenuItem(value: age, child: Text('$age ans')),
              ],
              onChanged: (v) => setState(() {
                majority = v!;
                contextChanged();
              }),
            ),
            SwitchListTile(
              title: const Text('Fonctions mineurs activées'),
              value: enabled,
              onChanged: (v) => setState(() {
                enabled = v;
                contextChanged();
              }),
            ),
            SwitchListTile(
              title: const Text('Cumul des confidentialités autorisé'),
              value: cumulative,
              onChanged: (v) => setState(() {
                cumulative = v;
                contextChanged();
              }),
            ),
            Text(session.context.message),
            const Text(MinorSession.information),
            const Text(
              'Aucun seuil minimum optionnel. Le choix secret n’est pas mémorisé à la fermeture.',
            ),
            OutlinedButton(
              onPressed: session.context.valid
                  ? () => perform(() {
                      session.choose(false);
                      message = 'Connexion normale sélectionnée.';
                    })
                  : null,
              child: const Text('Choisir une connexion normale'),
            ),
            OutlinedButton(
              onPressed: session.context.secretAvailable
                  ? () => perform(() {
                      session.choose(true);
                      rlVisible = false;
                      message =
                          'Connexion secrète sélectionnée. Invisibilité RL imposée.';
                    })
                  : null,
              child: const Text('Choisir une connexion secrète'),
            ),
            if (session.secretChoice == true)
              const Text(
                'CONNEXION SECRÈTE SIMULÉE — invisible aux représentants légaux',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            SwitchListTile(
              title: const Text('Opposition au nouveau dépôt'),
              value: session.opposition,
              onChanged: (v) => setState(() => session.setOpposition(v)),
            ),
            SwitchListTile(
              title: const Text('Document visible aux représentants légaux'),
              value: rlVisible,
              onChanged:
                  !session.ready ||
                      session.secretChoice == true ||
                      existing != null
                  ? null
                  : (v) => setState(() {
                      rlVisible = v;
                      session.invalidate();
                    }),
            ),
            SwitchListTile(
              title: const Text('Document visible au patient'),
              value: patientVisible,
              onChanged: !session.ready || existing != null
                  ? null
                  : (v) => setState(() {
                      patientVisible = v;
                      session.invalidate();
                    }),
            ),
            SwitchListTile(
              title: const Text('Document masqué aux professionnels'),
              value: maskedPs,
              onChanged: !session.ready
                  ? null
                  : (v) => setState(() {
                      maskedPs = v;
                      session.invalidate();
                    }),
            ),
            Text(
              existing == null
                  ? 'Aucun document fictif conservé pour ce patient.'
                  : 'Document fictif conservé : ${existing!.id}. RL : ${existing!.rlVisible ? "visible" : "invisible"} ; patient : ${existing!.patientVisible ? "visible" : "invisible"}.',
            ),
            FilledButton(
              onPressed:
                  !session.ready || (session.opposition && existing == null)
                  ? null
                  : () => perform(() {
                      session.prepare(
                        id: documentId,
                        rlVisible: rlVisible,
                        patientVisible: patientVisible,
                        maskedPs: maskedPs,
                        replacing: existing,
                      );
                      message = 'Aperçu simulé préparé. Aucun envoi.';
                    }),
              child: Text(
                existing == null
                    ? 'Préparer un aperçu fictif'
                    : 'Préparer le remplacement fictif',
              ),
            ),
            if (session.preview != null) Text(session.preview!.text),
            OutlinedButton(
              onPressed: session.preview == null
                  ? null
                  : () => perform(() {
                      session.retain(session.preview!, store!);
                      documents = store!.read();
                      message =
                          'Document fictif conservé. Vous pouvez fermer puis rouvrir cet écran.';
                    }),
              child: const Text('Conserver le document fictif'),
            ),
            OutlinedButton(
              onPressed:
                  !session.ready ||
                      existing == null ||
                      existing!.rlVisible ||
                      session.secretChoice == true
                  ? null
                  : () => reveal(true),
              child: const Text('Rendre visible aux représentants légaux'),
            ),
            OutlinedButton(
              onPressed:
                  !session.ready || existing == null || existing!.patientVisible
                  ? null
                  : () => reveal(false),
              child: const Text('Rendre visible au patient'),
            ),
            OutlinedButton(
              onPressed: () => setState(() {
                contextChanged();
                message =
                    'Nouvelle session simulée : aucun choix secret reconduit.';
              }),
              child: const Text('Simuler une nouvelle session'),
            ),
          ],
        ],
      ),
    ),
  );
}
