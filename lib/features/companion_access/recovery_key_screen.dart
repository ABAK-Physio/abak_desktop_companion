import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'companion_access_service.dart';

class RecoveryKeyScreen extends StatelessWidget {
  const RecoveryKeyScreen({super.key, this.generate = false, this.service});
  final bool generate;
  final CompanionAccessService? service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        generate ? 'Clé de récupération' : 'Récupérer un accès administrateur',
      ),
    ),
    body: RecoveryKeyPanel(
      generate: generate,
      service: service,
      onClose: () => Navigator.pop(context),
    ),
  );
}

/// Also usable above the Navigator on the lock screen. Choices do not require
/// popup routes, so recovery never depends on an already-authenticated page.
class RecoveryKeyPanel extends StatefulWidget {
  const RecoveryKeyPanel({
    super.key,
    required this.onClose,
    this.generate = false,
    this.service,
  });
  final VoidCallback onClose;
  final bool generate;
  final CompanionAccessService? service;
  @override
  State<RecoveryKeyPanel> createState() => _RecoveryKeyPanelState();
}

class _RecoveryKeyPanelState extends State<RecoveryKeyPanel> {
  late final service = widget.service ?? CompanionAccessService();
  final keyInput = TextEditingController(),
      pin = TextEditingController(),
      confirmation = TextEditingController(),
      name = TextEditingController();
  List<AccessPractitioner> people = [];
  String? selected, error, generated;
  bool loading = true,
      busy = false,
      exists = false,
      informed = false,
      saved = false,
      create = false,
      completed = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final list = await service.practitioners();
      final hasKey = await service.hasRecoveryKey();
      if (!mounted) return;
      setState(() {
        people = widget.generate
            ? list.where((p) => p.isAdministrator).toList()
            : list;
        selected = people.length == 1 ? people.single.id : null;
        exists = hasKey;
        loading = false;
        error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Impossible de charger les informations de récupération.';
        });
      }
    }
  }

  @override
  void dispose() {
    for (final field in [keyInput, pin, confirmation, name]) {
      field.clear();
      field.dispose();
    }
    generated = null;
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    if (!CompanionAccessService.validCode(pin.text)) {
      setState(() => error = 'Saisissez un code Companion à quatre chiffres.');
      return;
    }
    if (widget.generate && (!informed || selected == null)) return;
    if (!widget.generate &&
        (pin.text != confirmation.text ||
            (!create && selected == null) ||
            (create && name.text.trim().isEmpty))) {
      setState(
        () => error =
            'Choisissez un kiné ou indiquez son nom, puis confirmez le nouveau code.',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (widget.generate) {
        final value = await service.generateRecoveryKey(
          actorId: selected!,
          actorCode: pin.text,
        );
        if (mounted) setState(() => generated = value);
      } else {
        await service.recoverAdministrator(
          key: keyInput.text,
          newCode: pin.text,
          practitionerId: create ? null : selected,
          newPractitionerName: create ? name.text : null,
        );
        if (mounted) setState(() => completed = true);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is CompanionAccessException
              ? e.message
              : 'L’opération n’a pas pu être enregistrée. Réessayez.',
        );
      }
    } finally {
      if (mounted) {
        pin.clear();
        confirmation.clear();
        keyInput.clear();
        setState(() => busy = false);
      }
    }
  }

  Widget secret(
    TextEditingController controller,
    String label, {
    bool numeric = true,
  }) => TextField(
    controller: controller,
    obscureText: true,
    enabled: !busy,
    autocorrect: false,
    enableSuggestions: false,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    inputFormatters: numeric
        ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ]
        : null,
    decoration: InputDecoration(labelText: label),
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy && (generated == null || saved),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.generate
                    ? 'Clé de récupération du cabinet'
                    : 'Récupérer un accès administrateur',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (generated != null) ...[
                const Text(
                  'Cette clé ne sera plus affichée après fermeture. Conservez-la dans un endroit sûr, séparé de l’ordinateur : coffre-fort de mots de passe ou copie papier protégée.',
                ),
                const SizedBox(height: 16),
                SelectableText(
                  generated!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 19),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: generated!));
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copier la clé'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: saved,
                  onChanged: (value) => setState(() => saved = value ?? false),
                  title: const Text(
                    'J’ai conservé cette clé dans un endroit sûr.',
                  ),
                ),
              ] else if (completed) ...[
                const Text(
                  'L’accès administrateur est rétabli. Identifiez-vous avec le nouveau code Companion. Les sessions précédentes ont été fermées.',
                ),
              ] else ...[
                if (widget.generate) ...[
                  const Text(
                    'Cette clé permet de rétablir un accès administrateur sans connaître les anciens codes. Elle n’assure pas le chiffrement des fichiers.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Seul le cabinet dispose de la clé. ABAK Metrics ne peut ni la retrouver ni la recalculer. Un administrateur qui connaît son code peut en générer une nouvelle. Sans clé ni code administrateur, ce mécanisme ne permet pas de débloquer l’accès.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Une sauvegarde contient l’empreinte de la clé alors en vigueur. Restaurer une ancienne sauvegarde peut donc rétablir une ancienne clé.',
                  ),
                  if (exists)
                    const Text(
                      'Attention : générer une nouvelle clé invalidera immédiatement la précédente dans la base actuelle.',
                    ),
                  if (people.isEmpty)
                    const Text(
                      'Désignez d’abord un administrateur disposant d’un code personnel.',
                    ),
                ] else ...[
                  const Text(
                    'La clé rétablit un accès administrateur. Elle ne récupère pas les anciens codes et ne réaffecte pas les patients. Aucun accès à Internet ni recours à l’assistance n’est nécessaire.',
                  ),
                  if (!exists)
                    const Text(
                      'Aucune clé de récupération n’a été générée pour cette base.',
                    ),
                  secret(keyInput, 'Clé de récupération', numeric: false),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: create,
                    onChanged: busy
                        ? null
                        : (value) => setState(() => create = value ?? false),
                    title: const Text(
                      'Créer la fiche d’un nouveau kiné administrateur',
                    ),
                  ),
                ],
                if (!create) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.generate
                        ? 'Administrateur autorisant la génération'
                        : 'Kiné dont l’accès sera rétabli',
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final p in people)
                        ChoiceChip(
                          label: Text(p.name),
                          selected: selected == p.id,
                          onSelected: busy
                              ? null
                              : (_) => setState(() => selected = p.id),
                        ),
                    ],
                  ),
                ] else
                  TextField(
                    controller: name,
                    enabled: !busy,
                    decoration: const InputDecoration(
                      labelText: 'Nom du nouveau kiné',
                    ),
                  ),
                secret(
                  pin,
                  widget.generate
                      ? 'Code de l’administrateur'
                      : 'Nouveau code Companion',
                ),
                if (!widget.generate)
                  secret(confirmation, 'Confirmer le nouveau code'),
                if (widget.generate)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: informed,
                    onChanged: busy
                        ? null
                        : (value) => setState(() => informed = value ?? false),
                    title: Text(
                      exists
                          ? 'Je comprends que l’ancienne clé sera remplacée.'
                          : 'Je conserverai la clé dans un endroit protégé.',
                    ),
                  ),
                if (error != null)
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                FilledButton(
                  onPressed:
                      busy ||
                          (widget.generate
                              ? !informed || selected == null
                              : !exists)
                      ? null
                      : submit,
                  child: Text(
                    busy
                        ? 'Enregistrement…'
                        : widget.generate
                        ? 'Générer la clé de récupération'
                        : 'Rétablir l’accès administrateur',
                  ),
                ),
              ],
              if (!loading)
                TextButton(
                  onPressed: busy || (generated != null && !saved)
                      ? null
                      : widget.onClose,
                  child: Text(
                    generated != null || completed ? 'Fermer' : 'Annuler',
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
