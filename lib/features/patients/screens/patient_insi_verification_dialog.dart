import 'package:flutter/material.dart';

import '../services/patient_fr_insi_ws_ins3_request_builder.dart';
import '../services/patient_insi_retrieval_service.dart';

/// Explicit CNDA test operation. Opening or editing this form sends nothing.
class PatientInsiVerificationDialog extends StatefulWidget {
  const PatientInsiVerificationDialog({
    super.key,
    required this.initial,
    required this.onVerify,
  });
  final Map<String, String> initial;
  final Future<InsiVerificationResponse> Function(Map<String, String>, String) onVerify;

  @override
  State<PatientInsiVerificationDialog> createState() => _VerificationState();
}

class _VerificationState extends State<PatientInsiVerificationDialog> {
  static const labels = {
    'number': 'Matricule INS sans clé (13 caractères)',
    'key': 'Clé INS (2 chiffres)',
    'oid': 'OID INS',
    'name': 'Nom de naissance',
    'names': 'Tous les prénoms de naissance, séparés par un espace',
    'sex': 'Sexe : M ou F',
    'date': 'Date de naissance : AAAA-MM-JJ',
    'place': 'Code INSEE du lieu de naissance (facultatif)',
  };
  late final fields = {
    for (final key in labels.keys)
      key: TextEditingController(text: widget.initial[key] ?? ''),
  };
  final pin = TextEditingController();
  bool busy = false;
  String? error;
  InsiVerificationResponse? response;

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    pin.clear();
    pin.dispose();
    super.dispose();
  }

  Future<void> verify() async {
    if (busy || response != null) {
      return;
    }
    final values = {for (final e in fields.entries) e.key: e.value.text.trim()};
    try {
      const PatientFrInsiWsIns3RequestBuilder().buildBody(
        insNumber: values['number']!, insKey: values['key']!, insOid: values['oid']!,
        birthLastName: values['name']!, givenNames: values['names']!,
        sexCode: values['sex']!, birthDate: values['date']!, birthPlaceCode: values['place'],
      );
      if (!RegExp(r'^[0-9]{1,16}$').hasMatch(pin.text)) {
        throw ArgumentError('Saisissez le PIN de la CPS de test.');
      }
    } on ArgumentError catch (e) {
      setState(() => error = e.message.toString());
      return;
    }
    String? secret = pin.text;
    pin.clear();
    setState(() { busy = true; error = null; });
    try {
      final result = await widget.onVerify(values, secret);
      if (result.result.isFault) {
        throw StateError('Erreur technique INSi : aucune vérification concluante.');
      }
      if (mounted) {
        setState(() => response = result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e is StateError ? e.message.toString()
          : 'Vérification non terminée. Consultez les échanges conservés dans l’historique. Aucun nouvel appel automatique.');
      }
    } finally {
      secret = null;
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = response;
    return PopScope(
      canPop: !busy,
      child: AlertDialog(
        title: const Text('Vérification unitaire INSi — essai CNDA'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (completed == null) ...[
                  const Text('Recopiez l’INS et tous les traits du jeu d’essai CNDA. '
                    'Ces saisies sont utilisées uniquement pour cet appel et ne remplacent pas la fiche patient.'),
                  const SizedBox(height: 12),
                  const Text('Le bouton « Vérifier l’INS » effectue un seul appel au serveur INSi de test, '
                    'avec la CPS de test du kiné configuré. Aucune lecture Vitale ni dépôt DMP. '
                    'Le PIN n’est pas enregistré. L’identité et son statut restent inchangés.'),
                  for (final entry in labels.entries)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextField(
                        key: ValueKey('verify-${entry.key}'),
                        controller: fields[entry.key], enabled: !busy,
                        decoration: InputDecoration(labelText: entry.value,
                          helperText: entry.key == 'oid'
                            ? 'NIR : 1.2.250.1.213.1.4.8 · NIA : 1.2.250.1.213.1.4.9' : null),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey('verify-pin'),
                    controller: pin, enabled: !busy, obscureText: true,
                    autocorrect: false, enableSuggestions: false,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'PIN de la CPS de test'),
                  ),
                  if (error != null) Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                  if (busy) const LinearProgressIndicator(),
                ] else ...[
                  Text(completed.result.isVerified
                    ? 'INS vérifiée avec succès — code 00'
                    : 'Vérification sans succès — code 01'),
                  if (completed.result.label != null) SelectableText(completed.result.label!),
                  const SizedBox(height: 12),
                  SelectableText('INS testée : ${fields['number']!.text} · clé ${fields['key']!.text}'),
                  SelectableText('Échange : ${completed.id}'),
                  const Text('Échanges XML conservés dans l’historique et exportables. '
                    'Identité et statut inchangés. Aucune qualification effectuée.'),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: busy ? null : () => Navigator.pop(context),
            child: Text(completed == null ? 'Annuler' : 'Fermer')),
          if (completed == null)
            FilledButton(onPressed: busy ? null : verify, child: const Text('Vérifier l’INS')),
        ],
      ),
    );
  }
}
