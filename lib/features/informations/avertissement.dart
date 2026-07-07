import 'package:flutter/material.dart';

class AvertissementScreen extends StatelessWidget {
  const AvertissementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avertissement'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Avertissement Légal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            const Text(
              'ABAK Desktop Companion est un logiciel d’aide à l’organisation, '
                  'à l’importation et à la consultation de résultats cliniques issus '
                  'de l’écosystème ABAK.\n\n'
                  'Il ne constitue pas un dispositif médical certifié et ne remplace '
                  'pas le jugement du professionnel de santé.\n\n'
                  'Les résultats, scores, comptes rendus et indicateurs affichés doivent '
                  'toujours être interprétés par un professionnel qualifié, en tenant '
                  'compte de l’examen clinique, du contexte du patient et des '
                  'recommandations en vigueur.\n\n'
                  'L’utilisateur reste seul responsable de ses décisions cliniques, '
                  'de la vérification des données importées et de la conformité de leur '
                  'utilisation avec les règles professionnelles, réglementaires et '
                  'déontologiques applicables.\n\n'
                  'ABAK Desktop Companion ne réalise pas de diagnostic autonome, '
                  'ne prescrit aucun traitement et ne se substitue en aucun cas '
                  'à une consultation médicale ou paramédicale.',
            ),
          ],
        ),
      ),
    );
  }
}
