import 'package:flutter/material.dart';
import 'dmp_setup_service.dart';
import '../dmp_webps/webps_browser_settings.dart';
import '../dmp_webps/webps_dv1_screen.dart';

class DmpSetupTile extends StatefulWidget {
  const DmpSetupTile({super.key, this.service});
  final DmpSetupService? service;
  @override
  State<DmpSetupTile> createState() => _DmpSetupTileState();
}

class _DmpSetupTileState extends State<DmpSetupTile> {
  late final service = widget.service ?? DmpSetupService();
  bool enabled = false, busy = true;
  String? message;
  int idleMinutes = 15;
  bool showPatientPerson = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      enabled = await service.enabled();
      idleMinutes = await service.idleMinutes();
      showPatientPerson = await service.showPatientPerson();
    } catch (_) {
      message = 'Impossible de lire la configuration DMP.';
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> change(bool value) async {
    setState(() {
      busy = true;
      message = value ? 'Préparation et vérification du contrôle PDF/A…' : null;
    });
    try {
      await service.setEnabled(value);
      if (mounted) {
        setState(() {
          enabled = value;
          message = value
              ? 'Contrôle PDF/A prêt. veraPDF et Java sont fournis avec Companion. Les références CDA et les conditions d’accès au DMP restent à vérifier.'
              : 'Utilisation du DMP désactivée. Les documents et leurs validations sont conservés.';
        });
      }
    } catch (e) {
      if (mounted) setState(() => message = 'Activation non confirmée : $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> changeDelay(int? value) async {
    if (value == null) return;
    setState(() => busy = true);
    try {
      await service.setIdleMinutes(value);
      if (mounted) {
        setState(() {
          idleMinutes = value;
          message = 'Délai de verrouillage enregistré.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Impossible d’enregistrer le délai.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> changePatientPerson(bool value) async {
    setState(() => busy = true);
    try {
      await service.setShowPatientPerson(value);
      if (mounted) setState(() => showPatientPerson = value);
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Impossible d’enregistrer ce choix.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        SwitchListTile(
          title: const Text('Utiliser le DMP'),
          value: enabled,
          onChanged: busy ? null : change,
          subtitle: const Text(
            'Active les fonctions DMP et prépare le contrôle PDF/A fourni avec Companion. Aucune lecture CPS ni connexion DMP n’est déclenchée par cette activation.',
          ),
        ),
        if (enabled)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text(
                    'Afficher les traits d’identité retournés par le DMP',
                  ),
                  subtitle: const Text(
                    'Désactivé par défaut. Seuls les traits de l’INS font foi. Ce choix ne déclenche aucune lecture CPS ni connexion DMP.',
                  ),
                  value: showPatientPerson,
                  onChanged: busy ? null : changePatientPerson,
                ),
                DropdownButtonFormField<int>(
                  initialValue: idleMinutes,
                  key: ValueKey(idleMinutes),
                  decoration: const InputDecoration(
                    labelText: 'Verrouillage après inactivité',
                  ),
                  items: [
                    for (final minutes in DmpSetupService.idleChoices)
                      DropdownMenuItem(
                        value: minutes,
                        child: Text('$minutes minutes'),
                      ),
                  ],
                  onChanged: busy ? null : changeDelay,
                ),
                const Text(
                  'Sur Mac, après sélection d’un praticien dont la CPS est associée. Les clics, la saisie et les mouvements dans Companion relancent le délai. Déverrouillage avec sa CPS ; aucun appel DMP.',
                ),
                const WebPsBrowserSettings(),
                OutlinedButton.icon(
                  onPressed: busy
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const WebPsDv1Screen(),
                          ),
                        ),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Accès Web-PS — recette DV1'),
                ),
              ],
            ),
          ),
        if (busy) const LinearProgressIndicator(),
        if (message != null)
          Padding(padding: const EdgeInsets.all(12), child: Text(message!)),
        if (enabled && !busy)
          TextButton(
            onPressed: () => change(true),
            child: const Text('Vérifier les outils DMP'),
          ),
      ],
    ),
  );
}
