import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dossier_demo.dart';
import 'dossier_reader.dart';
import 'isolated_workflow.dart';

class DossierDemoScreen extends StatefulWidget {
  const DossierDemoScreen({super.key, this.simulationRoot});
  final Directory? simulationRoot;
  @override
  State<DossierDemoScreen> createState() => _DossierDemoScreenState();
}

class _DossierDemoScreenState extends State<DossierDemoScreen> {
  DossierDemo? demo;
  Directory? root;
  final text = TextEditingController();
  bool busy = true;
  bool dirty = false;
  String? error;
  String pieceMessage = '';
  String outcome = 'accepted';
  Future<void>? pending;
  @override
  void initState() {
    super.initState();
    pending = open();
  }

  Future<void> open({bool fresh = false}) async {
    try {
      var base =
          widget.simulationRoot ??
          Directory(
            '${(await getApplicationSupportDirectory()).path}/dmp-dossier-demo-v1',
          );
      base.createSync(recursive: true);
      base = Directory(base.resolveSymbolicLinksSync());
      root = base;
      final files = IsolatedFiles(base);
      final pointer = files.checked('${base.path}/exercice.txt');
      final name = fresh
          ? 'simulation-${DateTime.now().microsecondsSinceEpoch}'
          : pointer.existsSync()
          ? pointer.readAsStringSync().trim()
          : 'simulation-initial';
      if (!RegExp(r'^simulation-[a-z0-9-]{1,64}$').hasMatch(name)) {
        throw const IntegrationBlocked('stockage_bloque');
      }
      final dir = Directory(files.checked('${base.path}/$name').path);
      final next = await DossierDemo.open(dir);
      if (!mounted) {
        await next.close();
        return;
      }
      await demo?.close();
      demo = next;
      final temp = files.checked('${base.path}/exercice.tmp');
      temp.writeAsStringSync(name, flush: true);
      temp.renameSync(pointer.path);
      text.text = next.text;
      dirty = false;
      pieceMessage = '';
      outcome = 'accepted';
      error = null;
    } catch (_) {
      error = 'Stockage de démonstration indisponible. Actions suspendues.';
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> act(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    pending = () async {
      try {
        await action();
      } catch (_) {
        error = 'Stockage de démonstration indisponible. Actions suspendues.';
      }
      if (mounted) setState(() => busy = false);
    }();
    await pending;
  }

  Future<void> validate() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Valider médicalement — démonstration'),
        content: const Text(
          'Confirmer cette version fictive ? Le service simulé sera appelé si le document n’est pas retenu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer la validation'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) await act(() => demo!.validate());
  }

  @override
  void dispose() {
    final old = demo;
    unawaited(
      (pending ?? Future<void>.value()).whenComplete(() => old?.close()),
    );
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = demo;
    final enabled = !busy && error == null && d != null;
    final terminal =
        d != null &&
        [
          'deja_accepte',
          'signature_rejetee',
          'metadonnees_rejetees',
          'indetermine',
          'rapprochement_requis',
          'remplacement_a_preparer',
          'modification_a_preparer',
          'accepte_simule',
        ].contains(d.status);
    return Scaffold(
      appBar: AppBar(title: const Text('DMP — dossier et stockage simulés')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'DÉMONSTRATION LOCALE — données entièrement fictives',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Aucun accès réseau métier, aucune CPS ni fonction INSi. Stockage indépendant des dossiers et lots réels.',
            ),
            const SizedBox(height: 16),
            if (error != null) Text(error!, key: const Key('error')),
            if (busy) const LinearProgressIndicator(),
            if (d != null) ...[
              const Text(
                'Patient : TEST FICTIF — rapport et pièce de démonstration.',
              ),
              Text(
                'État : ${d.status == 'pret_simule' ? 'Version validée, prête pour le service fictif.' : integrationMessage(d.status)}',
                key: const Key('status'),
              ),
              Text(
                'Validation de la version courante : ${d.validated ? 'conservée' : 'requise'}.',
              ),
              Text(
                'Appels fictifs depuis cette ouverture : ${d.calls}. Aucun appel réel.',
                key: const Key('calls'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('content'),
                controller: text,
                onChanged: (_) => setState(() => dirty = true),
                enabled: enabled && !terminal,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Contenu clinique fictif',
                ),
              ),
              OutlinedButton(
                key: const Key('save'),
                onPressed: enabled && !terminal
                    ? () => act(() async {
                        await d.saveText(text.text);
                        dirty = false;
                      })
                    : null,
                child: const Text('Enregistrer la modification fictive'),
              ),
              SwitchListTile(
                key: const Key('hold'),
                title: const Text('Retenir le traitement fictif'),
                value: d.held,
                onChanged: enabled && !terminal && !dirty
                    ? (value) => act(() async {
                        await d.setHeld(value);
                        if (!value && d.validated) await d.run();
                      })
                    : null,
              ),
              DropdownButtonFormField<String>(
                key: ValueKey('outcome-$outcome'),
                initialValue: outcome,
                decoration: const InputDecoration(
                  labelText: 'Réponse du service simulé',
                ),
                items: const [
                  DropdownMenuItem(value: 'accepted', child: Text('Accepté')),
                  DropdownMenuItem(
                    value: 'signatureRejected',
                    child: Text('Signature rejetée'),
                  ),
                  DropdownMenuItem(
                    value: 'metadataRejected',
                    child: Text('Métadonnées rejetées'),
                  ),
                  DropdownMenuItem(
                    value: 'indeterminate',
                    child: Text('Résultat indéterminé'),
                  ),
                ],
                onChanged: enabled && !terminal && !dirty
                    ? (value) {
                        setState(() {
                          outcome = value!;
                          d.chooseOutcome(value);
                        });
                      }
                    : null,
              ),
              FilledButton(
                key: const Key('validate'),
                onPressed: enabled && !terminal && !dirty && d.snapshot != null
                    ? validate
                    : null,
                child: const Text('Valider la version fictive'),
              ),
              OutlinedButton(
                key: const Key('process'),
                onPressed:
                    enabled && !terminal && !dirty && d.validated && !d.held
                    ? () => act(d.run)
                    : null,
                child: const Text('Traiter avec le service fictif'),
              ),
              OutlinedButton(
                key: const Key('piece'),
                onPressed: enabled
                    ? () => act(() async {
                        pieceMessage = await d.piece();
                      })
                    : null,
                child: const Text('Lire la pièce fictive'),
              ),
              Text(pieceMessage),
            ],
            const SizedBox(height: 16),
            OutlinedButton(
              key: const Key('new'),
              onPressed: !busy ? () => act(() => open(fresh: true)) : null,
              child: const Text('Créer un nouvel exercice fictif'),
            ),
            const Text(
              'Fermer puis rouvrir cet écran conserve le document, la validation, la retenue et le résultat. Un nouvel exercice conserve les traces du précédent. Ces résultats ne permettent aucun envoi réel.',
            ),
          ],
        ),
      ),
    );
  }
}
