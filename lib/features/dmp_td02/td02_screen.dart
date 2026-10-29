import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'td02_result.dart';

class Td02Screen extends StatefulWidget {
  const Td02Screen({super.key});
  @override
  State<Td02Screen> createState() => _Td02ScreenState();
}

class _Td02ScreenState extends State<Td02Screen> {
  static const cases = {
    'inexistant': 'DMP inexistant',
    'ferme-motif-inconnu': 'DMP fermé',
    'actif-VALIDE': 'Consultation autorisée',
    'actif-non-existe': 'Sans autorisation de consultation',
    'actif-EXPIRE': 'Autorisation expirée',
    'actif-INTERDIT': 'Consultation bloquée',
    'nia': 'Identifiant NIA',
    'soap-fault': 'Erreur SOAP',
    'correlation-soap': 'Réponse destinée à une autre requête',
    'http-503': 'Service DMP indisponible',
    'erreur-hl7': 'Erreur applicative DMP',
    'xml-invalide': 'Réponse illisible',
    'autre-patient': 'Réponse pour un autre patient',
  };
  static const labels = {
    DmpAction.deposit: 'Simuler un nouveau dépôt',
    DmpAction.technicalSearch: 'Simuler la recherche technique',
    DmpAction.replace: 'Simuler un remplacement',
    DmpAction.delete: 'Simuler une dépublication',
    DmpAction.consult: 'Simuler une consultation',
  };
  Td02Result? result;
  String? selected, actionMessage;
  bool opposition = false, consent = false, rights = true, author = true;
  int generation = 0;
  Future<void> load(String value) async {
    final token = ++generation;
    setState(() {
      selected = value;
      result = null;
      actionMessage = null;
    });
    try {
      final request = value == 'nia'
          ? ''
          : await rootBundle.loadString('assets/dmp_local/td02/request.xml');
      final response = value == 'nia'
          ? ''
          : await rootBundle.loadString(
              'assets/dmp_local/td02/SYNTHETIQUE-$value.xml',
            );
      final r = Td02Reader.read(
        request: request,
        response: response,
        context: Td02Context(
          ins: value == 'nia' ? '109076322088835' : '187012425258307',
          oid: value == 'nia' ? '1.2.250.1.213.1.4.9' : '1.2.250.1.213.1.4.10',
          professional: value == 'nia' ? '899700870597' : '899700854237',
        ),
        httpStatus: value == 'soap-fault'
            ? 500
            : value == 'http-503'
            ? 503
            : 200,
      );
      if (mounted && token == generation) setState(() => result = r);
    } catch (_) {
      if (mounted && token == generation) {
        setState(
          () => result = const Td02Result(
            DmpState.unknown,
            detail: 'Scénario local indisponible.',
          ),
        );
      }
    }
  }

  bool allowed(DmpAction a) =>
      result?.allows(
        a,
        opposition: opposition,
        functionalRights: rights,
        authorRights: author,
        consultationConsent: consent,
      ) ??
      false;
  void simulate(DmpAction a) {
    if (!allowed(a)) {
      return; // Same guard at invocation, not only on the button.
    }
    setState(
      () => actionMessage =
          'Action permise dans ce scénario. Simulation terminée ; aucun envoi.',
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('DMP — simulations TD0.2')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'SIMULATION LOCALE — aucun accès au DMP',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          selected == 'nia'
              ? 'Jeu de test 103 : MATRICULE PROVISOIRE — NIA 109076322088835. Contexte Michel simulé. Aucune CPS ni fonction INSi utilisée.'
              : 'Jeu de test : Marie / SYLVAIN BONNEL. États fictifs, sans valeur sur DV1. Aucune CPS ni fonction INSi utilisée.',
        ),
        DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Cas à vérifier'),
          items: cases.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) {
            if (v != null) load(v);
          },
        ),
        const SizedBox(height: 16),
        Text(
          result?.message ??
              'Choisissez un cas. Toutes les actions sont suspendues.',
        ),
        if (result?.closureDetails.isNotEmpty ?? false)
          Text(result!.closureDetails),
        if (result?.detail.isNotEmpty ?? false) Text(result!.detail),
        SwitchListTile(
          title: const Text('Opposition aux nouveaux dépôts'),
          value: opposition,
          onChanged: (v) => setState(() {
            opposition = v;
            actionMessage = null;
          }),
        ),
        SwitchListTile(
          title: const Text('Consentement à la consultation'),
          value: consent,
          onChanged: (v) => setState(() {
            consent = v;
            actionMessage = null;
          }),
        ),
        SwitchListTile(
          title: const Text('Droits fonctionnels réunis (simulation)'),
          value: rights,
          onChanged: (v) => setState(() {
            rights = v;
            actionMessage = null;
          }),
        ),
        SwitchListTile(
          title: const Text('Droits d’auteur réunis (simulation)'),
          value: author,
          onChanged: (v) => setState(() {
            author = v;
            actionMessage = null;
          }),
        ),
        const Text(
          'Les droits de consultation sont distincts de l’alimentation. Aucun renouvellement automatique d’autorisation.',
        ),
        for (final e in labels.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OutlinedButton(
              key: ValueKey(e.key),
              onPressed: allowed(e.key) ? () => simulate(e.key) : null,
              child: Text(e.value),
            ),
          ),
        if (actionMessage != null) Text(actionMessage!),
        const Text(
          'Les résultats locaux ne peuvent autoriser aucun envoi réel. Les détails patientPerson ne sont pas affichés.',
        ),
      ],
    ),
  );
}
