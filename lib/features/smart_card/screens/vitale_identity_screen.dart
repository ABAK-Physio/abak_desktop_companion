import 'package:flutter/material.dart';

import '../models/vitale_identity.dart';
import '../services/vitale_identity_service.dart';

class VitaleIdentityScreen extends StatefulWidget {
  const VitaleIdentityScreen({super.key});

  @override
  State<VitaleIdentityScreen> createState() => _VitaleIdentityScreenState();
}

class _VitaleIdentityScreenState extends State<VitaleIdentityScreen> {
  final VitaleIdentityService _service = const VitaleIdentityService();

  bool _loading = false;
  VitaleIdentity? _identity;
  Map<String, dynamic>? _diagnostic;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readIdentity();
    });
  }

  Future<void> _readIdentity() async {
    setState(() {
      _loading = true;
      _identity = null;
      _diagnostic = null;
    });

    final diagnostic = await _service.readVitaleIdentityDiagnostic();

    if (!mounted) return;

    VitaleIdentity? identity;

    final identityRaw = diagnostic['identity'];
    if (diagnostic['success'] == true && identityRaw is Map) {
      identity = VitaleIdentity.fromMap(identityRaw);
    }

    setState(() {
      _loading = false;
      _identity = identity;
      _diagnostic = diagnostic;
    });
  }

  @override
  Widget build(BuildContext context) {
    final diagnostic = _diagnostic;
    final identity = _identity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lire identité Carte Vitale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _loading ? null : _readIdentity,
              icon: const Icon(Icons.badge_outlined),
              label: Text(
                _loading
                    ? 'Lecture en cours...'
                    : 'Lire identité Carte Vitale',
              ),
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (!_loading && identity != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Identité lue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text('Nom : ${identity.lastName ?? ''}'),
                      Text('Prénom : ${identity.firstName ?? ''}'),
                      Text(
                        'Date de naissance : '
                            '${identity.birthDate?.toIso8601String().split('T').first ?? ''}',
                      ),
                      Text('Sexe : ${identity.sexCode ?? ''}'),
                      Text('Source : ${identity.source}'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: identity.hasUsableIdentity
                            ? () {
                          Navigator.of(context).pop(identity);
                        }
                            : null,
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: const Text('Utiliser pour créer un patient'),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_loading && diagnostic != null && identity == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    diagnostic['error']?.toString() ??
                        'Aucune identité Carte Vitale disponible',
                  ),
                ),
              ),

            const SizedBox(height: 16),

            if (diagnostic != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(
                        diagnostic.entries
                            .map((entry) => '${entry.key} : ${entry.value}')
                            .join('\n'),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}