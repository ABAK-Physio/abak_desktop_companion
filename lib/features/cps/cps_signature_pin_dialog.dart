import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cps_profile.dart';

class CpsSignaturePinDialog extends StatefulWidget {
  const CpsSignaturePinDialog({
    super.key,
    required this.profile,
    this.localLot = false,
  });
  final bool localLot;
  final CpsProfile profile;
  @override
  State<CpsSignaturePinDialog> createState() => CpsSignaturePinDialogState();
}

class CpsSignaturePinDialogState extends State<CpsSignaturePinDialog> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.clear();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.localLot
          ? 'Signer le lot TD2.1 local'
          : 'Test local de signature CPS',
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Carte attendue : ${widget.profile.givenName} ${widget.profile.familyName}\n'
          'Identifiant : ${widget.profile.nationalId}\n\n'
          '${widget.localLot ? 'Signez le manifeste du CDA fictif présenté. Aucun envoi DMP ni appel INSi.' : 'Signez uniquement un message technique aléatoire. Aucun document ni appel DMP ou INSi.'}',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          enableSuggestions: false,
          autocorrect: false,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          decoration: const InputDecoration(labelText: 'PIN de la CPS'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text),
        child: const Text('Signer le test'),
      ),
    ],
  );
}
