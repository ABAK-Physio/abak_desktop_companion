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
            Text(
              'ABAK Desktop Companion est un logiciel d aide a l evaluation clinique. Il ne constitue pas un dispositif médical certifié et ne remplace pas le jugement du professionnel de santé.',
            ),
          ],
        ),
      ),
    );
  }
}
