import 'package:flutter/material.dart';
import 'licence.dart';
import 'avertissement.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ABAK Desktop Companion',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Version 1.0.0'),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LicenceScreen()),
                );
              },
              child: const Text('Licence'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AvertissementScreen()),
                );
              },
              child: const Text('Avertissement'),
            ),
            const SizedBox(height: 32),
            const Text('© 2024 ABAK'),
          ],
        ),
      ),
    );
  }
}
