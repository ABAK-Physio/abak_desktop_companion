import 'archive_deposit_reader.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'simulated_lot_store.dart';
import 'package:flutter/material.dart';
import 'transfer_simulation.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, this.serviceFactory, this.store});
  final TransferSimulationService Function(String scenario)? serviceFactory;
  final SimulatedLotStore? store;
  static final scenarios = <String, String>{
    for (final error in TlsFailure.values) 'tls-${error.name}': error.message,
    'accepted': 'Dépôt accepté',
    'signatureRejected': 'Signature rejetée',
    'metadataRejected': 'Métadonnées rejetées',
    'indeterminate': 'Résultat indéterminé après tentative',
    'archive-signature': 'Archive — rejet de signature',
    'archive-metadata': 'Archive — rejet de métadonnées',
    'archive-accepted': 'Archive — dépôt accepté R6',
    'archive-truncated': 'Archive altérée pour test — réponse tronquée',
    'archive-uncorrelated': 'Archive altérée pour test — autre requête',
  };
  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  TransferSimulation? flow;
  String? selected, actionMessage, storageError;
  SimulatedLotStore? store;
  @override
  void initState() {
    super.initState();
    store = widget.store;
    if (store == null) _openStore();
  }

  Future<void> _openStore() async {
    try {
      final Directory support = await getApplicationSupportDirectory();
      if (mounted) setState(() => store = SimulatedLotStore(support));
    } catch (_) {
      if (mounted) {
        setState(
          () => storageError =
              'Stockage des simulations indisponible. Actions bloquées.',
        );
      }
    }
  }

  void choose(String value) {
    if (store == null || flow?.busy == true) return;
    flow?.dispose();
    final service =
        widget.serviceFactory?.call(value) ??
        (value.startsWith('archive-')
            ? ArchiveReplayService(value.substring(8))
            : value.startsWith('tls-')
            ? FixtureTransferService(
                failure: TlsFailure.values.byName(value.substring(4)),
              )
            : FixtureTransferService(
                outcome: DepositOutcome.values.byName(value),
              ));
    final next = TransferSimulation(
      service,
      store: value.startsWith('archive-')
          ? SimulatedLotStore(
              Directory(
                '${store!.directory.parent.path}/abak-archive-replay-tests-v1',
              ),
            )
          : store,
      lotId: 'simulation-$value',
    );
    next.addListener(() {
      if (mounted) setState(() {});
    });
    setState(() {
      selected = value;
      flow = next;
      actionMessage = null;
    });
  }

  @override
  void dispose() {
    flow?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('DMP — simulations TLS et dépôt')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'SIMULATION LOCALE — aucune CPS, aucune connexion DV1',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(
          'Ces résultats sont fictifs. Ils ne modifient ni les dépôts réels, ni leurs verrous, ni INSi.',
        ),
        DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Cas à vérifier'),
          items: TransferScreen.scenarios.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: store == null || flow?.busy == true
              ? null
              : (v) {
                  if (v != null) choose(v);
                },
        ),
        if (store == null) Text(storageError ?? 'Ouverture du stockage local…'),
        if (selected != null) Text('Lot fictif : simulation-$selected'),
        const SizedBox(height: 20),
        Text(
          flow?.message ?? 'Choisissez un scénario. Aucune action disponible.',
        ),
        if (selected?.startsWith('archive-') == true)
          const Text(
            'RELECTURE HISTORIQUE HORS RÉSEAU — copies des réponses de test. Stockage séparé ; aucune action sur le document réel.',
          ),
        if (flow?.detail.isNotEmpty == true) SelectableText(flow!.detail),
        if (flow?.busy == true) const LinearProgressIndicator(),
        const SizedBox(height: 20),
        FilledButton(
          key: const ValueKey('start'),
          onPressed: flow?.canStart == true ? () => flow!.start() : null,
          child: Text(
            selected?.startsWith('archive-') == true
                ? 'Relire cette archive'
                : 'Lancer la simulation',
          ),
        ),
        const OutlinedButton(
          key: ValueKey('resend'),
          onPressed: null,
          child: Text('Renvoyer le même lot — interdit'),
        ),
        OutlinedButton(
          key: const ValueKey('correct'),
          onPressed: flow?.canPrepareCorrection == true
              ? () => setState(() => actionMessage = flow!.prepareCorrection())
              : null,
          child: const Text('Simuler la préparation d’un lot corrigé'),
        ),
        OutlinedButton(
          key: const ValueKey('check'),
          onPressed: flow?.canCheckResult == true
              ? () => setState(() => actionMessage = flow!.checkResult())
              : null,
          child: const Text('Simuler la vérification du résultat'),
        ),
        if (actionMessage != null) Text(actionMessage!),
        const Text(
          'Aucun réessai automatique. Chaque scénario conserve son lot fictif après fermeture ou redémarrage. Revenir à un scénario ne remet pas son état à zéro. Aucun lot réel n’est déverrouillé.',
        ),
      ],
    ),
  );
}
