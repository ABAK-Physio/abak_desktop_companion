import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../patients/services/document_journal_service.dart';
import '../patients/services/dmp_chain/native/dv1_configuration.dart';
import 'tls050_recipe.dart';
import 'tls050_preparation_diagnostic.dart';
import '../patients/services/dmp_chain/contracts.dart';
import 'tls050_service.dart';

class Tls050Screen extends StatefulWidget {
  const Tls050Screen({super.key, required this.journal});
  final DocumentJournalService journal;
  @override
  State<Tls050Screen> createState() => _Tls050ScreenState();
}

class _Tls050ScreenState extends State<Tls050Screen> {
  late final service = Tls050Service(widget.journal);
  Dv1Configuration? config;
  Map<String, dynamic>? campaign;
  String message = '', folder = '';
  bool busy = true;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    try {
      final c = await service.settings.current();
      final histories = await service.history();
      final current = campaign ?? (histories.isEmpty ? null : histories.first);
      final path = current == null
          ? ''
          : (await service.directory(current['id'])).path;
      if (mounted) {
        setState(() {
          config = c;
          campaign = current;
          folder = path;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => message = 'Lecture de la recette impossible. Vérifiez la configuration et les preuves locales.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> start() async {
    if (busy || config == null) return;
    setState(() {
      busy = true;
      message = 'Préparation locale de la série…';
    });
    try {
      final record = await service.start(config!);
      final path = (await service.directory(record['id'])).path;
      if (mounted) {
        setState(() {
          campaign = record;
          folder = path;
          message = 'Série préparée. Aucune CPS ni connexion sollicitée. Capturez cet écran avant la première étape.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => message = e is StateError
              ? e.message.toString()
              : 'Préparation impossible. Aucune connexion confirmée.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> run(int step) async {
    if (busy || config == null || campaign == null) return;
    setState(() {
      busy = true;
      message = 'Étape $step : confirmation requise.';
    });
    try {
      final record = await service.execute(
        campaignId: campaign!['id'],
        step: step,
        config: config!,
        requestPin: () => showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _Tls050PinDialog(
            step: step,
            professional: config!.professional,
            trustHash: campaign!['trustHash'],
          ),
        ),
        progress: (value) {
          if (mounted) setState(() => message = value);
        },
      );
      if (mounted) {
        setState(() {
          campaign = record;
          final steps = record['steps'] as List;
          message = steps.length < step
              ? 'Étape annulée, sans connexion.'
              : steps.last['message'] as String;
        });
      }
    } catch (e, stack) {
      if (mounted) {
        setState(
          () => message = e is StateError
              ? e.message.toString()
              : e is DmpChainBlock
              ? e.message
              : tls050PreparationDiagnostic(
                  e,
                  stack,
                  'confirmation de l’étape $step',
                ),
        );
      }
    } finally {
      await refresh();
      if (mounted) setState(() => busy = false);
    }
  }

  bool get configurationMatches =>
      campaign != null &&
      config != null &&
      campaign!['configurationHash'] == config!.hash &&
      campaign!['trustHash'] == config!.resources['trust']['sha256'];
  @override
  Widget build(BuildContext context) {
    final steps = (campaign?['steps'] as List?) ?? [];
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recette 0.1-050 — certificats des serveurs DMP'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Validation de l’autorité de certification et de l’identité des serveurs. '
              'Chaque étape ouvre sa propre session CPS, puis tente un test d’existence TD0.2. '
              'Aucun dépôt, signature de document ou changement d’autorisation.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Les trois étapes utilisent exactement les mêmes autorités et CRL. '
              'Certaines étapes sont volontairement non passantes. Un problème réseau ou carte '
              'ne prouve pas un rejet de certificat. Chaque résultat doit être examiné avec les consignes du PDT.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Patient de recette : ${Tls050Recipe.patient} — Cas1.\n${Tls050Recipe.source}',
            ),
            const SizedBox(height: 12),
            Text(
              config == null
                  ? 'Configurez d’abord la recette DV1 dans l’écran précédent.'
                  : 'Configuration n°${config!.revision} · CPS ${config!.professional}\n'
                        'SHA-256 des autorités et CRL : ${config!.resources['trust']['sha256']}',
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: busy || config == null ? null : start,
              child: const Text('Préparer une nouvelle série — sans connexion'),
            ),
            if (campaign != null) ...[
              const SizedBox(height: 12),
              Text('Série : ${campaign!['id']}'),
              SelectableText('Preuves locales : $folder'),
              TextButton(
                onPressed: busy
                    ? null
                    : () => Clipboard.setData(ClipboardData(text: folder)),
                child: const Text('Copier le chemin des preuves'),
              ),
              if (!configurationMatches)
                const Text(
                  'La configuration a changé. Préparez une nouvelle série. Les preuves précédentes restent conservées.',
                ),
            ],
            if (busy) const LinearProgressIndicator(),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SelectableText(message),
              ),
            for (var step = 1; step <= 3; step++)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Étape $step',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SelectableText(Tls050Recipe.endpoint(step)),
                      const SizedBox(height: 8),
                      Text(
                        steps.length >= step
                            ? steps[step - 1]['message'] as String
                            : 'Non exécutée.',
                      ),
                      if (steps.length >= step)
                        ExpansionTile(
                          title: const Text('Détails de la preuve'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: SelectableText(
                                'Début : ${steps[step - 1]['startedAt']}\nFin : ${steps[step - 1]['finishedAt']}\n'
                                'TLS acceptée : ${steps[step - 1]['tlsAccepted'] ?? 'non confirmé'}\n'
                                'Émission SOAP : ${steps[step - 1]['requestState']}\n'
                                'Code : ${steps[step - 1]['error'] ?? 'aucun'}\n'
                                'Fermeture : ${steps[step - 1]['sessionClosed']}\n'
                                '${steps[step - 1]['diagnostic'] ?? ''}',
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed:
                            busy ||
                                !configurationMatches ||
                                steps.length != step - 1
                            ? null
                            : () => run(step),
                        child: Text(
                          'Préparer la confirmation de l’étape $step',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Pour chaque étape, conservez les captures avant confirmation, pendant le traitement '
              'si visible, puis après le résultat. Les fichiers locaux sont préfixés par le numéro d’étape. '
              'En cas de rejet TLS, le journal indique l’absence d’émission SOAP ; aucune réponse n’est inventée.',
            ),
            const SizedBox(height: 12),
            const Text(
              'LPS2 et variantes CN/AlternativeNames : le contrôle HTTPS et le SNI restent activés. '
              'La déclaration demandée dans S6 et le résultat T6 restent à renseigner après examen des preuves '
              'et du compte rendu des contrôles. Cet écran ne valide pas automatiquement la conformité du test.',
            ),
            if (!Platform.isWindows)
              const Text(
                'Ce lot doit encore être vérifié sur votre installation macOS avant d’y constituer les preuves de certification.',
              ),
          ],
        ),
      ),
    );
  }
}

class _Tls050PinDialog extends StatefulWidget {
  const _Tls050PinDialog({
    required this.step,
    required this.professional,
    required this.trustHash,
  });
  final int step;
  final String professional, trustHash;
  @override
  State<_Tls050PinDialog> createState() => _Tls050PinDialogState();
}

class _Tls050PinDialogState extends State<_Tls050PinDialog> {
  final pin = TextEditingController();
  bool confirmed = false;
  @override
  void dispose() {
    pin.clear();
    pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Lancer l’étape ${widget.step} de 0.1-050 ?'),
    content: SizedBox(
      width: 620,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              'Serveur : ${Tls050Recipe.endpoint(widget.step)}\n'
              'CPS : ${widget.professional}\nPatient : ${Tls050Recipe.patient}\n'
              'Autorités et CRL SHA-256 : ${widget.trustHash}',
            ),
            const SizedBox(height: 12),
            const Text(
              'Une tentative explicite, sans relance automatique. Le moteur vérifie le certificat serveur '
              'avec les autorités conservées, puis envoie uniquement TD0.2 si TLS est acceptée. Aucun dépôt.',
            ),
            CheckboxListTile(
              value: confirmed,
              onChanged: (v) => setState(() => confirmed = v ?? false),
              title: const Text(
                'Je confirme le serveur de cette étape, ma CPS et le Cas1 du PDT pour cet essai.',
              ),
            ),
            TextField(
              controller: pin,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.number,
              maxLength: 16,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'PIN de la CPS — non conservé',
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: !confirmed || pin.text.isEmpty
            ? null
            : () => Navigator.pop(context, pin.text),
        child: Text('Confirmer l’étape ${widget.step}'),
      ),
    ],
  );
}
