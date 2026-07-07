import 'package:flutter/material.dart';
import 'avertissement.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openLicence() async {
    final uri = Uri.parse(
      'https://abak.care/gnu-general-public-license-version-3/',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

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
            OutlinedButton.icon(
              onPressed: _openLicence,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Consulter la licence'),
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
