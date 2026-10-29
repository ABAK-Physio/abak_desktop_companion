import 'package:flutter/material.dart';
import '../services/patient_insi_retrieval_service.dart';

class PatientInsiConfigurationDialog extends StatefulWidget {
  const PatientInsiConfigurationDialog({
    super.key,
    required this.initial,
    required this.professionals,
  });
  final Map<String, String> initial;
  final List<Map<String, String>> professionals;
  @override
  State<PatientInsiConfigurationDialog> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<PatientInsiConfigurationDialog> {
  static const labels = {
    'authorization': 'Numéro d’autorisation INSi de test — CNDA',
    'professional': 'Identifiant national du kiné — porté par sa CPS',
    'billing': 'Identifiant Assurance maladie de facturation du kiné',
    'sector': 'Secteur d’activité — code SAxx',
  };
  late final fields = {
    for (final key in labels.keys)
      key: TextEditingController(text: widget.initial[key] ?? ''),
  };
  String? error;
  bool busy = false;
  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await PatientInsiRetrievalService().saveConfiguration({
        for (final entry in fields.entries) entry.key: entry.value.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e is StateError
              ? e.message.toString()
              : 'Configuration non enregistrée. Vos saisies sont conservées.';
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Configuration INSi — serveur de test'),
    content: SizedBox(
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'À renseigner une fois pour le kiné utilisant sa CPS de test. '
              'L’autorisation est celle fournie pour INSi, distincte de celle du DMP. '
              'Aucun appel ni lecture de carte lors de cet enregistrement.',
            ),
            const SizedBox(height: 16),
            if (widget.professionals.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kiné enregistré — préremplissage',
                ),
                items: [
                  for (final p in widget.professionals)
                    DropdownMenuItem(
                      value: p['professional'],
                      child: Text(p['name']!),
                    ),
                ],
                onChanged: busy
                    ? null
                    : (id) {
                        if (id == null) return;
                        final p = widget.professionals.singleWhere(
                          (p) => p['professional'] == id,
                        );
                        setState(() {
                          if (fields['professional']!.text != id) {
                            fields['billing']!.clear();
                          }
                          fields['professional']!.text = id;
                          fields['sector']!.text = p['sector'] ?? '';
                        });
                      },
              ),
              const SizedBox(height: 16),
            ],
            for (final entry in labels.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: fields[entry.key],
                  enabled: !busy,
                  decoration: InputDecoration(
                    labelText: entry.value,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context, false),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: busy ? null : save,
        child: const Text('Enregistrer'),
      ),
    ],
  );
}

class PatientInsiPinDialog extends StatefulWidget {
  const PatientInsiPinDialog({super.key, required this.patient});
  final String patient;
  @override
  State<PatientInsiPinDialog> createState() => _PinState();
}

class _PinState extends State<PatientInsiPinDialog> {
  final pin = TextEditingController();
  @override
  void dispose() {
    pin.clear();
    pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Récupérer l’INS — serveur de test'),
    content: SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient : ${widget.patient}'),
          const SizedBox(height: 12),
          const Text(
            'Utilisez une carte Vitale de test et la CPS de test du kiné configuré. '
            'Cette action authentifie le kiné et transmet les données du bénéficiaire à INSi. '
            'Aucun dépôt DMP. Le PIN n’est pas enregistré.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pin,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'PIN de la CPS'),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: RegExp(r'^[0-9]{1,16}$').hasMatch(pin.text)
            ? () => Navigator.pop(context, pin.text)
            : null,
        child: const Text('Interroger INSi'),
      ),
    ],
  );
}
