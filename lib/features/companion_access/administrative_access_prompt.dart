import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'administrative_access_service.dart';
import 'companion_access_service.dart';

class AdministrativeAccessPrompt extends StatefulWidget {
  const AdministrativeAccessPrompt({
    super.key,
    required this.state,
    required this.error,
    required this.section,
    required this.service,
    required this.cancel,
    required this.retry,
  });
  final AdministrativeAccessDecision? state;
  final String? error;
  final String section;
  final AdministrativeAccessService service;
  final VoidCallback cancel, retry;
  @override
  State<AdministrativeAccessPrompt> createState() =>
      _AdministrativeAccessPromptState();
}

class _AdministrativeAccessPromptState
    extends State<AdministrativeAccessPrompt> {
  final code = TextEditingController();
  AdministrativeAccessReason? reason;
  bool emergency = false, busy = false;
  String? error;
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final bootstrap =
        widget.state == AdministrativeAccessDecision.bootstrapRequired;
    if (busy || (!bootstrap && reason == null)) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (bootstrap) {
        await widget.service.unlockBootstrap(code.text);
      } else {
        await widget.service.grantException(code: code.text, reason: reason!);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is CompanionAccessException
              ? e.message
              : 'Impossible d’enregistrer cet accès. Réessayez.',
        );
      }
    } finally {
      if (mounted) {
        code.clear();
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bootstrap =
        widget.state == AdministrativeAccessDecision.bootstrapRequired;
    final identify =
        widget.state == AdministrativeAccessDecision.identification;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_outline, size: 36),
        const SizedBox(height: 16),
        Text(
          widget.section,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (widget.error != null) ...[
          Text(widget.error!),
          TextButton(onPressed: widget.retry, child: const Text('Réessayer')),
        ] else if (widget.state == null)
          const Center(child: CircularProgressIndicator())
        else if (identify)
          const Text(
            'Identifiez-vous dans le bandeau pour accéder à cette fonction.',
          )
        else ...[
          Text(
            bootstrap
                ? 'Aucun administrateur n’est enregistré. Saisissez le mot de passe initial.'
                : 'Vous n’êtes pas administrateur.',
          ),
          if (!bootstrap && !emergency)
            FilledButton(
              onPressed: () => setState(() => emergency = true),
              child: const Text('Urgence'),
            ),
          if (bootstrap || emergency) ...[
            const SizedBox(height: 12),
            if (!bootstrap) ...[
              const Text(
                'Cet accès couvre les Paramètres et l’Assistance pour la session en cours. Le motif sera enregistré. Il ne permet pas de modifier les administrateurs ni la clé de récupération.',
              ),
              const SizedBox(height: 12),
              const Text('Motif obligatoire'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in AdministrativeAccessReason.values)
                    ChoiceChip(
                      label: Text(item.label),
                      selected: reason == item,
                      onSelected: busy
                          ? null
                          : (_) => setState(() => reason = item),
                    ),
                ],
              ),
            ],
            TextField(
              controller: code,
              obscureText: true,
              enabled: !busy,
              keyboardType: bootstrap
                  ? TextInputType.text
                  : TextInputType.number,
              maxLength: bootstrap ? null : 4,
              inputFormatters: bootstrap
                  ? []
                  : [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: bootstrap
                    ? 'Mot de passe initial'
                    : 'Code Companion du kiné actif',
              ),
              onSubmitted: (_) => submit(),
            ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            FilledButton(
              onPressed: busy || (!bootstrap && reason == null) ? null : submit,
              child: Text(busy ? 'Vérification…' : 'Autoriser l’accès'),
            ),
          ],
        ],
        TextButton(
          onPressed: busy ? null : widget.cancel,
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
