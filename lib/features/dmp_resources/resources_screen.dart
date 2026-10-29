import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dmp_resources.dart';
import 'resources_controller.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key, this.controller, this.transport});

  /// Screen owns this controller and disposes it on close.
  final ResourcesController? controller;
  final SimulatedResourceTransport? transport;
  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen>
    with WidgetsBindingObserver {
  ResourcesController? controller;
  SimulatedResourceTransport? transport;
  String? error;
  String scenario = 'normal';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.controller != null) {
      transport = widget.transport;
      attach(widget.controller!);
    } else {
      open();
    }
  }

  void attach(ResourcesController value) {
    controller = value;
    controller!.addListener(changed);
    controller!.start();
  }

  void changed() {
    if (mounted) setState(() {});
  }

  Future<void> open() async {
    try {
      final root = await getApplicationSupportDirectory();
      if (!mounted) return;
      transport = SimulatedResourceTransport();
      var offset = Duration.zero;
      final resources = DmpResources(
        transport: transport!,
        store: FileResourceStore(
          Directory('${root.path}/dmp-resources-simulation-v1'),
        ),
        now: () => DateTime.now().toUtc().add(offset),
        source: Uri.parse('https://parametres.example.invalid/simulation'),
        allowedHosts: {'parametres.example.invalid'},
      );
      attach(
        ResourcesController(
          resources,
          advanceClock: () {
            offset += const Duration(days: 7);
          },
        ),
      );
      changed();
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Stockage des simulations indisponible. Contrôles suspendus.',
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) controller?.check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.removeListener(changed);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller, r = c?.resources, p = r?.parameters;
    return Scaffold(
      appBar: AppBar(
        title: const Text('DMP — paramètres et nomenclatures simulés'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SIMULATION LOCALE — aucun accès réseau, aucune CPS ni fonction INSi.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Stockage réservé aux simulations. Aucun effet sur les lots réels. Les valeurs présentées ne sont pas des paramètres officiels.',
            ),
            const SizedBox(height: 16),
            if (error != null) Text(error!),
            if (c == null && error == null)
              const Text('Ouverture du stockage des simulations…'),
            if (c != null) ...[
              Text('Source : ${r!.source}'),
              Text(
                'Dernière vérification réussie (UTC) : ${r.lastSuccess?.toIso8601String() ?? "aucune"}',
              ),
              Text(
                p == null
                    ? 'Cache des paramètres : absent ou invalide.'
                    : r.due
                    ? 'Cache des paramètres : valide, vérification à renouveler.'
                    : 'Cache des paramètres : valide, échéance de sept jours non atteinte.',
              ),
              Text(
                c.busy ? 'Vérification simulée en cours…' : c.parametersMessage,
              ),
              const Text(
                'Vérification à l’ouverture, à la reprise et chaque minute tant que cet écran est ouvert. Actualisation si échéance de sept jours atteinte. Un échec ne renouvelle pas la date du cache. Si l’échéance est atteinte, un nouvel essai simulé sera effectué à la prochaine vérification ; sinon utilisez Vérifier maintenant.',
              ),
              DropdownButtonFormField<String>(
                initialValue: scenario,
                decoration: const InputDecoration(
                  labelText: 'Réponse du service simulé',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'normal',
                    child: Text('Paramètres valides'),
                  ),
                  DropdownMenuItem(
                    value: 'changed',
                    child: Text('Paramètres modifiés'),
                  ),
                  DropdownMenuItem(
                    value: 'unavailable',
                    child: Text('Service indisponible'),
                  ),
                  DropdownMenuItem(
                    value: 'invalid',
                    child: Text('Fichier invalide'),
                  ),
                ],
                onChanged: c.busy || transport == null
                    ? null
                    : (v) {
                        setState(() {
                          scenario = v!;
                          transport!.scenario = v;
                        });
                      },
              ),
              FilledButton(
                onPressed: c.busy ? null : () => c.check(force: true),
                child: const Text('Vérifier maintenant — simulation'),
              ),
              OutlinedButton(
                onPressed: c.busy || c.advanceClock == null
                    ? null
                    : c.advanceWeek,
                child: const Text('Avancer de sept jours — horloge simulée'),
              ),
              const Divider(),
              if (p == null)
                const Text(
                  'Fonctions dépendantes indisponibles : aucun paramètre valide.',
                ),
              if (p != null) ...[
                Text(
                  'Gestion des mineurs : ${p.minors ? "activée" : "désactivée"}',
                ),
                Text('Âge de majorité simulé : ${p.majority} ans'),
                Text(
                  'Cumul des confidentialités : ${p.cumulative ? "autorisé" : "interdit"}',
                ),
                if (r.due)
                  const Text(
                    'Configuration précédente conservée ; actualité non confirmée.',
                  ),
              ],
              const Divider(),
              Text(
                'Nomenclatures : ${r.catalog?.version ?? "aucune version chargée"}',
              ),
              if (c.catalogueMessage != null) Text(c.catalogueMessage!),
              OutlinedButton(
                onPressed: c.busy ? null : c.installExampleCatalog,
                child: const Text('Charger les nomenclatures fictives'),
              ),
              OutlinedButton(
                onPressed: c.busy
                    ? null
                    : () => c.installExampleCatalog(invalid: true),
                child: const Text('Simuler un catalogue invalide'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
