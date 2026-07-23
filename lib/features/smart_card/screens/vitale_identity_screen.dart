import 'package:flutter/material.dart';

import 'package:abak_vitale/abak_vitale.dart';

import '../widgets/vitale_beneficiary_selector.dart';

class VitaleIdentityScreen extends StatefulWidget {
  const VitaleIdentityScreen({super.key});

  @override
  State<VitaleIdentityScreen> createState() =>
      _VitaleIdentityScreenState();
}

class _VitaleIdentityScreenState extends State<VitaleIdentityScreen> {
  final VitaleIdentityService _service = VitaleIdentityService();

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

    final identities = await _service.readVitaleIdentities();


    if (!mounted) return;

    VitaleIdentity? identity;

    if (identities.length == 1) {
      identity = identities.first;
    } else if (identities.length > 1) {
      identity = await VitaleBeneficiarySelector.show(
        context,
        identities,
      );
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
      _identity = identity;
      _diagnostic = identities.isEmpty
          ? {
        'success': false,
        'message': 'Aucune identité Carte Vitale disponible',
        'beneficiaryCount': 0,
      }
          : {
        'success': true,
        'beneficiaryCount': identities.length,
      };
    });
  }

  String _formatBirthDate(DateTime? birthDate) {
    if (birthDate == null) {
      return '';
    }

    return birthDate.toIso8601String().split('T').first;
  }

  String _sexLabel(String? sexCode) {
    switch (sexCode?.trim().toUpperCase()) {
      case 'F':
        return 'Féminin';
      case 'M':
        return 'Masculin';
      case 'X':
        return 'Autre';
      default:
        return 'Non renseigné';
    }
  }

  bool _hasNir(VitaleIdentity identity) {
    return identity.nir?.trim().isNotEmpty == true;
  }

  String _formatDiagnostic(Map<String, dynamic> diagnostic) {
    final lines = <String>[];

    for (final entry in diagnostic.entries) {
      if (entry.key == 'identity') {
        final identityRaw = entry.value;

        if (identityRaw is Map) {
          lines.add(
            'identity : identité reçue '
                '(données personnelles masquées)',
          );
        } else {
          lines.add('identity : non disponible');
        }

        continue;
      }

      if (entry.key.toLowerCase().contains('nir')) {
        lines.add('${entry.key} : donnée masquée');
        continue;
      }

      lines.add('${entry.key} : ${entry.value}');
    }

    return lines.join('\n');
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Nom : ${identity.lastName ?? ''}',
                      ),
                      Text(
                        'Prénom : ${identity.firstName ?? ''}',
                      ),
                      Text(
                        'Date de naissance : '
                            '${_formatBirthDate(identity.birthDate)}',
                      ),
                      Text(
                        'Sexe : ${_sexLabel(identity.sexCode)}',
                      ),
                      Text(
                        'NIR : '
                            '${_hasNir(identity) ? 'détecté' : 'non disponible'}',
                      ),
                      Text(
                        'Source : ${identity.source}',
                      ),

                      const SizedBox(height: 16),

                      FilledButton.icon(
                        onPressed: identity.hasUsableIdentity
                            ? () {
                          Navigator.of(context).pop(identity);
                        }
                            : null,
                        icon: const Icon(
                          Icons.person_add_alt_1_outlined,
                        ),
                        label: const Text(
                          'Utiliser pour créer un patient',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_loading &&
                diagnostic != null &&
                identity == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    diagnostic['error']?.toString() ??
                        diagnostic['message']?.toString() ??
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
                        _formatDiagnostic(diagnostic),
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