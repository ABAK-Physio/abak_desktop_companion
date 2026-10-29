import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'webps_native_local.dart';

class LocalBrowserScreen extends StatefulWidget {
  const LocalBrowserScreen({super.key, this.control});
  final LocalBrowserControl? control;
  @override
  State<LocalBrowserScreen> createState() => _LocalBrowserScreenState();
}

class _LocalBrowserScreenState extends State<LocalBrowserScreen> {
  late final LocalBrowserControl c;
  @override
  void initState() {
    super.initState();
    c = widget.control ?? LocalBrowserControl.shared;
    c.addListener(refresh);
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    c.removeListener(refresh);
    super.dispose();
  }

  Future<void> connect() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      final path = picked?.files.single.path;
      if (path != null) await c.connect(await File(path).readAsString());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Connexion locale impossible. Vérifiez le fichier du service de test.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Navigateur réel — pages locales uniquement'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Chrome isolé, réseau du navigateur bloqué. Aucune CPS, aucun accès DV1. Patients entièrement fictifs.',
        ),
        const Text(
          'Démarrez le lanceur « Demarrer controle navigateur local », puis sélectionnez son fichier Connexion_ABAK_locale.json. Gardez le service ouvert pendant le contrôle.',
        ),
        OutlinedButton(
          onPressed: !c.connected && !c.pending ? connect : null,
          child: const Text('Choisir le fichier de connexion locale'),
        ),
        OutlinedButton(
          key: const ValueKey('native-dashboard'),
          onPressed: c.connected && !c.busy && !c.pending
              ? () => c.open(false)
              : null,
          child: const Text('Ouvrir le tableau de bord local'),
        ),
        OutlinedButton(
          key: const ValueKey('native-patient'),
          onPressed: c.connected && !c.busy && !c.pending
              ? () => c.open(true)
              : null,
          child: const Text('Ouvrir le contexte Patient fictif B'),
        ),
        Text(c.message),
        OutlinedButton(
          key: const ValueKey('native-close'),
          onPressed: c.connected && c.busy && !c.pending ? c.close : null,
          child: const Text('Fermer le navigateur de test'),
        ),
        const Text(
          'Quitter cet écran ne libère pas la fenêtre. Après redémarrage, reconnectez le même service : son verrou reste actif. Une interruption non confirmée conserve le blocage et nécessite une analyse. Ce contrôle ne couvre pas les fenêtres ouvertes en dehors du service.',
        ),
      ],
    ),
  );
}
