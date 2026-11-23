import 'recovery_key_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'companion_access_service.dart';

class CompanionAccessScreen extends StatefulWidget {
  const CompanionAccessScreen({super.key, this.practitionerId, this.service});
  final String? practitionerId;
  final CompanionAccessService? service;
  @override
  State<CompanionAccessScreen> createState() => _CompanionAccessScreenState();
}

class _CompanionAccessScreenState extends State<CompanionAccessScreen> {
  late final service = widget.service ?? CompanionAccessService();
  List<AccessPractitioner> practitioners = [];
  bool loading = true, hasAdministrators = false;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final people = await service.practitioners();
      final admins = await service.hasAdministrators();
      if (!mounted) return;
      setState(() {
        practitioners = people;
        hasAdministrators = admins;
        loading = false;
        error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Impossible de charger les droits. Réessayez.';
        });
      }
    }
  }

  List<AccessPractitioner> get administrators =>
      practitioners.where((p) => p.isAdministrator).toList();

  Future<void> dialog({
    required String title,
    required String explanation,
    required List<_SecretField> fields,
    required Future<void> Function(String?, List<String>) submit,
    bool administrator = false,
    bool confirmLastTwo = false,
  }) async {
    if (administrator && administrators.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucun administrateur ne peut être sélectionné. Il faut d’abord rétablir un accès administrateur.',
          ),
        ),
      );
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SecretDialog(
        title: title,
        explanation: explanation,
        fields: fields,
        administrators: administrator ? administrators : null,
        confirmLastTwo: confirmLastTwo,
        submit: submit,
      ),
    );
    if (!mounted || saved != true) return;
    await load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modification enregistrée.')),
      );
    }
  }

  Future<void> editCode(AccessPractitioner p) => dialog(
    title: '${p.hasCode ? 'Changer' : 'Créer'} le code — ${p.name}',
    explanation:
        'Code personnel Companion à quatre chiffres. Il ne remplace pas le code de votre CPS.',
    fields: [
      if (p.hasCode) const _SecretField('Code actuel'),
      const _SecretField('Nouveau code'),
      const _SecretField('Confirmer le nouveau code'),
    ],
    confirmLastTwo: true,
    submit: (_, values) => p.hasCode
        ? service.changeCode(p.id, values[0], values[1])
        : service.createCode(p.id, values[0]),
  );

  Future<void> changeAdministrator(AccessPractitioner p, bool enabled) {
    if (!hasAdministrators && enabled) {
      return dialog(
        title: 'Premier administrateur — ${p.name}',
        explanation:
            'Aucun administrateur n’est enregistré. Saisissez le mot de passe initial « admin », '
            'puis ${p.hasCode ? 'le code personnel de ce kiné' : 'créez son code personnel'}.',
        fields: [
          const _SecretField('Mot de passe initial', numeric: false),
          _SecretField(p.hasCode ? 'Code personnel' : 'Nouveau code'),
          if (!p.hasCode) const _SecretField('Confirmer le nouveau code'),
        ],
        confirmLastTwo: !p.hasCode,
        submit: (_, values) =>
            service.initializeAdministrator(p.id, values[0], values[1]),
      );
    }
    return dialog(
      title:
          '${enabled ? 'Attribuer' : 'Retirer'} le statut administrateur — ${p.name}',
      explanation:
          'Le code d’un administrateur est obligatoire. Aucun accès dérogatoire n’est autorisé.'
          '${!enabled && administrators.length == 1 ? '\n\nAprès le retrait du dernier administrateur, le mot de passe initial « admin » redevient actif.' : ''}',
      administrator: true,
      fields: const [_SecretField('Code de l’administrateur')],
      submit: (actor, values) => service.setAdministrator(
        actorId: actor!,
        actorCode: values[0],
        targetId: p.id,
        enabled: enabled,
      ),
    );
  }

  Future<void> resetCode(AccessPractitioner p) => dialog(
    title: 'Réinitialiser le code — ${p.name}',
    explanation:
        'L’ancien code ne fonctionnera plus. Le kiné devra créer un nouveau code personnel. '
        'Cette opération est enregistrée dans le journal.',
    administrator: true,
    fields: const [_SecretField('Code de l’administrateur')],
    submit: (actor, values) => service.resetCode(
      actorId: actor!,
      actorCode: values[0],
      targetId: p.id,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final visible = practitioners.where(
      (p) => widget.practitionerId == null || p.id == widget.practitionerId,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Codes personnels et administrateurs')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (error != null) ...[
                      Text(error!),
                      TextButton(
                        onPressed: load,
                        child: const Text('Réessayer'),
                      ),
                    ] else ...[
                      const Text(
                        'Chaque kiné choisit son code personnel Companion. '
                        'Les changements de droits nécessitent le code d’un administrateur, même hors mode DMP.',
                      ),
                      TextButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => RecoveryKeyScreen(service: service))),
                        icon: const Icon(Icons.key), label: const Text('Utiliser la clé de récupération')),
                      const SizedBox(height: 16),
                      if (visible.isEmpty)
                        const Text(
                          'Aucun kiné disponible. Créez d’abord sa fiche dans la liste des kinés.',
                        ),
                      if (!hasAdministrators && visible.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Aucun administrateur n’est enregistré. Cochez « Administrateur » pour désigner le premier.',
                          ),
                        ),
                      for (final p in visible)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Administrateur'),
                                  value: p.isAdministrator,
                                  onChanged: (value) {
                                    if (value != null) {
                                      changeAdministrator(p, value);
                                    }
                                  },
                                ),
                                Text(
                                  p.hasCode
                                      ? 'Code personnel créé.'
                                      : 'Code personnel à créer.',
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => editCode(p),
                                      icon: const Icon(Icons.password),
                                      label: Text(
                                        p.hasCode
                                            ? 'Changer mon code'
                                            : 'Créer mon code',
                                      ),
                                    ),
                                    if (p.hasCode)
                                      TextButton(
                                        onPressed: () => resetCode(p),
                                        child: const Text('Code oublié'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _SecretField {
  const _SecretField(this.label, {this.numeric = true});
  final String label;
  final bool numeric;
}

class _SecretDialog extends StatefulWidget {
  const _SecretDialog({
    required this.title,
    required this.explanation,
    required this.fields,
    required this.submit,
    this.administrators,
    required this.confirmLastTwo,
  });
  final String title, explanation;
  final List<_SecretField> fields;
  final List<AccessPractitioner>? administrators;
  final bool confirmLastTwo;
  final Future<void> Function(String?, List<String>) submit;
  @override
  State<_SecretDialog> createState() => _SecretDialogState();
}

class _SecretDialogState extends State<_SecretDialog> {
  final form = GlobalKey<FormState>();
  late final controllers = widget.fields
      .map((_) => TextEditingController())
      .toList();
  late String? actor = widget.administrators?.first.id;
  bool busy = false;
  String? error;

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.clear();
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
    final values = controllers.map((c) => c.text).toList();
    if (widget.confirmLastTwo &&
        values[values.length - 1] != values[values.length - 2]) {
      setState(() => error = 'Les deux nouveaux codes sont différents.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.submit(actor, values);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is CompanionAccessException
              ? e.message
              : 'Impossible d’enregistrer cette opération. Réessayez.',
        );
      }
    } finally {
      values.fillRange(0, values.length, '');
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.explanation),
                const SizedBox(height: 16),
                if (widget.administrators != null) ...[
                  DropdownButtonFormField<String>(
                    initialValue: actor,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Administrateur',
                    ),
                    items: widget.administrators!
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: busy
                        ? null
                        : (value) => setState(() => actor = value),
                  ),
                  const SizedBox(height: 12),
                ],
                for (var i = 0; i < widget.fields.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: controllers[i],
                      enabled: !busy,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: widget.fields[i].numeric
                          ? TextInputType.number
                          : TextInputType.text,
                      maxLength: widget.fields[i].numeric ? 4 : null,
                      inputFormatters: widget.fields[i].numeric
                          ? [FilteringTextInputFormatter.digitsOnly]
                          : null,
                      decoration: InputDecoration(
                        labelText: widget.fields[i].label,
                        counterText: '',
                      ),
                      validator: (value) => widget.fields[i].numeric
                          ? (CompanionAccessService.validCode(value ?? '')
                                ? null
                                : 'Saisissez quatre chiffres.')
                          : ((value ?? '').isEmpty
                                ? 'Saisissez le mot de passe initial.'
                                : null),
                      onFieldSubmitted: (_) => save(),
                    ),
                  ),
                if (error != null)
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: const Text('Valider'),
        ),
      ],
    ),
  );
}
