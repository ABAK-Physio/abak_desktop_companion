import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'webps_local.dart';
import 'webps_browser_service.dart';

class WebPsDv1Screen extends StatefulWidget {
  const WebPsDv1Screen({super.key, this.control});
  final WebPsBrowserService? control;
  @override
  State<WebPsDv1Screen> createState() => _WebPsDv1ScreenState();
}

class _WebPsDv1ScreenState extends State<WebPsDv1Screen> {
  late final c = widget.control ?? WebPsBrowserService.shared;
  final name = TextEditingController(), ins = TextEditingController();
  bool recipeConfirmed = false;
  @override
  void initState() {
    super.initState();
    c.addListener(refresh);
    if (Platform.isMacOS || widget.control != null) c.refresh();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  void tell(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> close() async {
    try {
      await c.close();
    } on PlatformException catch (error) {
      tell(
        error.message ??
            'Fermeture non confirmée. Quittez Firefox puis réessayez.',
      );
    } catch (_) {
      tell('Fermeture non confirmée. Quittez Firefox puis réessayez.');
    }
  }

  Future<void> open(bool patient) async {
    try {
      final professional = c.professional;
      final check = c.context.bind(professional);
      final target = patient ? WebPsTarget.patient : WebPsTarget.dashboard;
      final identity = patient
          ? WebPsPatient(
              name.text.trim(),
              ins.text.trim(),
              '1.2.250.1.213.1.4.10',
            )
          : null;
      WebPsUrl.build(WebPsUrl.dv1, target, patient: identity);
      if (patient && !recipeConfirmed) {
        tell(
          'Confirmez que les données proviennent du référentiel des patients fictifs CNDA.',
        );
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ouvrir Web-PS sur DV1 ?'),
          content: SingleChildScrollView(
            child: Text(
              'Praticien attendu : $professional.\n${patient ? "Patient fictif : ${identity!.name}\nINS : ${identity.ins}" : "Tableau de bord du praticien."}\n\n'
              'Quittez Firefox et fermez les autres accès DMP avant de continuer. Une instance Firefox réservée au DMP sera ouverte. Sélectionnez le certificat de ce praticien ; saisissez le PIN uniquement dans Firefox.\n\n'
              'Vérifiez le praticien et le patient affichés avant toute consultation. Cet essai porte sur l’ouverture du Web-PS : aucun dépôt ni changement d’autorisation à effectuer.\n\n'
              'Le verrouillage de Companion ou un changement de praticien demandera la fermeture de cette instance Firefox. L’activité dans Firefox ne prolonge pas le délai d’inactivité de Companion.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              key: const ValueKey('dv1-confirm'),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ouvrir sur DV1'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        check();
        await c.open(
          target,
          patient: identity,
          confirmed: true,
          checkContext: check,
        );
      }
    } catch (e) {
      tell(e.toString());
    }
  }

  @override
  void dispose() {
    c.removeListener(refresh);
    name.dispose();
    ins.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available =
        (Platform.isMacOS || widget.control != null) && !c.busy && !c.active;
    return Scaffold(
      appBar: AppBar(title: const Text('Web-PS — recette DV1')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            '1. Tableau de bord',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Utilisez Firefox, sélectionné dans les paramètres DMP. L’accès est lié au praticien du bandeau. Aucun navigateur ne s’ouvre sans votre confirmation.',
          ),
          if (!Platform.isMacOS)
            const Text('Le raccordement Windows reste à réaliser.'),
          OutlinedButton(
            key: const ValueKey('dv1-dashboard'),
            onPressed: available ? () => open(false) : null,
            child: const Text('Ouvrir mon tableau de bord DMP'),
          ),
          const SizedBox(height: 24),
          const Text(
            '2. DMP du patient fictif',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Recopiez les données du référentiel CNDA. Cette saisie ne modifie aucune fiche patient et ne qualifie aucune INS.',
          ),
          TextField(
            controller: name,
            enabled: available,
            decoration: const InputDecoration(
              labelText: 'Nom et prénom du patient fictif',
            ),
            onChanged: (_) => setState(() => recipeConfirmed = false),
          ),
          TextField(
            controller: ins,
            enabled: available,
            maxLength: 15,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'INS de test fourni par le CNDA, clé comprise',
            ),
            onChanged: (_) => setState(() => recipeConfirmed = false),
          ),
          CheckboxListTile(
            value: recipeConfirmed,
            onChanged: available
                ? (v) => setState(() => recipeConfirmed = v ?? false)
                : null,
            title: const Text(
              'Ces données sont celles du patient fictif CNDA à utiliser pour cet essai.',
            ),
          ),
          OutlinedButton(
            key: const ValueKey('dv1-patient'),
            onPressed: available ? () => open(true) : null,
            child: const Text('Ouvrir le DMP de ce patient'),
          ),
          const SizedBox(height: 24),
          const Text(
            '3. Fermer l’accès',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(c.message),
          const Text(
            'Après vérification, fermez l’accès ici avant de changer de patient. Une ouverture réussie ne prouve ni l’authentification ni les droits dans Web-PS.',
          ),
          OutlinedButton(
            onPressed: c.active && !c.busy ? close : null,
            child: const Text('Fermer l’accès Web-PS'),
          ),
        ],
      ),
    );
  }
}
