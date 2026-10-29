import 'package:flutter/material.dart';
import 'webps_local.dart';
import 'webps_native_screen.dart';
import 'webps_dv1_screen.dart';

class WebPsScreen extends StatefulWidget {
  const WebPsScreen({super.key, this.coordinator});
  final WebPsCoordinator? coordinator;
  @override
  State<WebPsScreen> createState() => _WebPsScreenState();
}

class _WebPsScreenState extends State<WebPsScreen> {
  static const patients = <String, WebPsPatient?>{
    'none': null,
    'sylvain': WebPsPatient(
      'SYLVAIN BONNEL',
      '187012425258307',
      '1.2.250.1.213.1.4.10',
    ),
    'jean': WebPsPatient(
      'JEAN CONTESTE — contexte seulement, DMP non créé selon nos traces',
      '153078987658513',
      '1.2.250.1.213.1.4.10',
    ),
    'nia': WebPsPatient(
      'MATRICULE PROVISOIRE',
      '109076322088835',
      '1.2.250.1.213.1.4.9',
    ),
    'invalid': WebPsPatient(
      'IDENTITÉ FICTIVE INVALIDE',
      '187012425258308',
      '1.2.250.1.213.1.4.10',
    ),
  };
  late final WebPsCoordinator coordinator;
  final base = TextEditingController(text: WebPsUrl.dv1);
  String selected = 'none';
  String? error;
  @override
  void initState() {
    super.initState();
    coordinator = widget.coordinator ?? WebPsCoordinator.shared;
    coordinator.addListener(refresh);
    if (coordinator.activePatient != null) {
      selected = patients.entries
          .firstWhere((e) => e.value?.ins == coordinator.activePatient!.ins)
          .key;
    }
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  Uri? preview(WebPsTarget target) {
    try {
      return WebPsUrl.build(base.text, target, patient: patients[selected]);
    } catch (_) {
      return null;
    }
  }

  Future<void> open(WebPsTarget target) async {
    if (coordinator.busy) return;
    setState(() => error = null);
    try {
      await coordinator.open(base.text, target, patients[selected]);
    } on FormatException catch (e) {
      if (mounted) setState(() => error = e.message);
    }
  }

  @override
  void dispose() {
    coordinator.removeListener(refresh);
    base.dispose();
    // The shared simulated window remains reserved across navigation.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('DMP — accès Web-PS simulé')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const WebPsDv1Screen()),
          ),
          child: const Text('Préparer les accès Web-PS réels sur DV1'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const LocalBrowserScreen()),
          ),
          child: const Text('Tester le navigateur réel sur une page locale'),
        ),
        const Text(
          'PRÉPARATION TD0.9 HORS CONNEXION',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(
          'Aucun navigateur réel, aucune CPS, aucun accès DV1. Contexte Michel fictif. Le navigateur simulé ne prouve ni l’authentification ni les droits d’accès.',
        ),
        TextField(
          key: const ValueKey('webps-base'),
          controller: base,
          enabled: !coordinator.busy,
          decoration: const InputDecoration(labelText: 'Base Web-PS de test'),
          onChanged: (_) => setState(() => error = null),
        ),
        DropdownButtonFormField<String>(
          key: const ValueKey('webps-patient'),
          initialValue: selected,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Contexte patient de test',
          ),
          items: patients.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value?.name ?? 'Aucun patient'),
                ),
              )
              .toList(),
          onChanged: coordinator.busy
              ? null
              : (v) {
                  if (coordinator.busy) return;
                  if (v != null) {
                    setState(() {
                      selected = v;
                      error = null;
                    });
                  }
                },
        ),
        const SizedBox(height: 16),
        if (preview(WebPsTarget.dashboard) == null)
          const Text('Base DV1 invalide : les deux accès sont bloqués.'),
        if (patients[selected]?.error != null) Text(patients[selected]!.error!),
        if (selected == 'none')
          const Text(
            'Le tableau de bord ne nécessite pas de patient. Sélectionnez un NIR valide pour l’accueil patient.',
          ),
        if (selected == 'jean')
          const Text(
            'Ce scénario vérifie uniquement l’URL et le contexte, pas l’existence du DMP de Jean.',
          ),
        for (final target in WebPsTarget.values) ...[
          if (preview(target) != null)
            SelectableText(preview(target).toString()),
          OutlinedButton(
            key: ValueKey(target),
            onPressed: !coordinator.busy && preview(target) != null
                ? () => open(target)
                : null,
            child: Text(
              target == WebPsTarget.dashboard
                  ? 'Simuler l’accès au tableau de bord'
                  : 'Simuler l’accueil du DMP patient',
            ),
          ),
        ],
        if (error != null) Text(error!),
        Text(coordinator.message),
        if (coordinator.busy)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FENÊTRE WEB-PS SIMULÉE — aucune page distante chargée',
                  ),
                  Text(
                    coordinator.activePatient?.name ??
                        'Tableau de bord — sans contexte patient',
                  ),
                  SelectableText(coordinator.activeUrl.toString()),
                  TextButton(
                    key: const ValueKey('webps-close'),
                    onPressed: coordinator.canClose ? coordinator.close : null,
                    child: const Text('Fermer la fenêtre simulée'),
                  ),
                ],
              ),
            ),
          ),
        const Text(
          'Une seule fenêtre simulée pour ABAK. Quitter cet écran ne ferme pas cette fenêtre. Le contrôle des fenêtres d’un navigateur réel reste à intégrer et vérifier.',
        ),
      ],
    ),
  );
}
