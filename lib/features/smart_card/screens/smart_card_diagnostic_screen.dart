import 'package:flutter/material.dart';

import '../services/smart_card_diagnostic_service.dart';
import 'vitale_identity_screen.dart';
import '../models/vitale_identity.dart';
import '../services/vitale_xml_parser.dart';
import '../../../core/config/developer_features.dart';

class SmartCardDiagnosticScreen extends StatefulWidget {
  const SmartCardDiagnosticScreen({super.key});

  @override
  State<SmartCardDiagnosticScreen> createState() =>
      _SmartCardDiagnosticScreenState();
}

class _SmartCardDiagnosticScreenState extends State<SmartCardDiagnosticScreen> {
  final _service = const SmartCardDiagnosticService();
  VitaleIdentity? _selectedIdentity;
  VitaleIdentity? _parsedIdentity;

  SmartCardDiagnosticResult? _result;
  bool _loading = false;
  SmartCardApduResult? _apduResult;
  bool _testingApdu = false;

  SmartCardVitaleApiResult? _vitaleApiResult;
  bool _checkingVitaleApi = false;

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });

    final result = await _service.readStatus();

    if (!mounted) return;

    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _testApdu() async {
    setState(() {
      _testingApdu = true;
      _apduResult = null;
    });

    final result = await _service.testApdu();

    if (!mounted) return;

    setState(() {
      _apduResult = result;
      _testingApdu = false;
    });
  }

  Future<void> _checkVitaleApi() async {
    setState(() {
      _checkingVitaleApi = true;
      _vitaleApiResult = null;
    });

    final result = await _service.checkVitaleApi();

    VitaleIdentity? parsed;

    if (result.xml != null && result.xml!.isNotEmpty) {
      parsed = VitaleXmlParser.parse(result.xml!);
    }

    if (!mounted) return;

    setState(() {
      _vitaleApiResult = result;
      _parsedIdentity = parsed;
      _checkingVitaleApi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic Carte Vitale'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final result = _result;

    if (result == null) {
      return const Text('Aucune donnée.');
    }

    return ListView(
      children: [
        const Text(
          'État du lecteur et de la carte',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: Icon(
              result.readerDetected ? Icons.check_circle : Icons.error_outline,
            ),
            title: const Text('Lecteur'),
            subtitle: Text(result.readerName ?? 'Aucun lecteur détecté'),
          ),
        ),

        Card(
          child: ListTile(
            leading: Icon(
              result.cardDetected ? Icons.credit_card : Icons.credit_card_off,
            ),
            title: const Text('Carte'),
            subtitle: Text(
              result.cardDetected ? 'Carte détectée' : 'Aucune carte détectée',
            ),
          ),
        ),

        Card(
          child: ListTile(
            title: const Text('ATR'),
            subtitle: Text(result.atr ?? 'Non disponible'),
          ),
        ),

        if (result.error != null)
          Card(
            child: ListTile(
              title: const Text('Erreur'),
              subtitle: Text(result.error!),
            ),
          ),

        const SizedBox(height: 24),

        const Divider(),

        const Text(
          'Lecture identité',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Flux métier principal : lit l’identité puis préremplit le formulaire patient.',
        ),

        const SizedBox(height: 12),

        FilledButton.icon(
          onPressed: () async {
            final identity = await Navigator.of(context).push<VitaleIdentity>(
              MaterialPageRoute(builder: (_) => const VitaleIdentityScreen()),
            );

            if (!mounted || identity == null) return;

            setState(() {
              _selectedIdentity = identity;
            });
          },
          icon: const Icon(Icons.badge_outlined),
          label: const Text('Lire identité Carte Vitale'),
        ),

        if (_selectedIdentity != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Identité sélectionnée'),
              subtitle: SelectableText(
                [
                  'Nom : ${_parsedIdentity!.lastName ?? ''}',
                  'Prénom : ${_parsedIdentity!.firstName ?? ''}',
                  'Naissance : ${_parsedIdentity!.birthDate?.toIso8601String().split('T').first ?? ''}',
                  'Sexe : ${_parsedIdentity!.sexCode ?? ''}',
                  if (DeveloperFeatures.showSensitiveData)
                    'NIR : ${_parsedIdentity!.nir ?? ''}',
                ].join('\n'),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        const Divider(),

        const Text(
          'API officielle de lecture',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Vérifie le chargement de la DLL SESAM-Vitale et la présence des fonctions nécessaires.',
        ),
        const SizedBox(height: 12),

        FilledButton.icon(
          onPressed: _checkingVitaleApi ? null : _checkVitaleApi,
          icon: const Icon(Icons.extension_outlined),
          label: Text(
            _checkingVitaleApi
                ? 'Vérification en cours...'
                : 'Vérifier API de lecture',
          ),
        ),

        if (_vitaleApiResult != null) ...[
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: Icon(
                _vitaleApiResult!.success
                    ? Icons.check_circle
                    : Icons.error_outline,
              ),
              title: Text(
                _vitaleApiResult!.success
                    ? 'API disponible'
                    : 'API indisponible ou incomplète',
              ),
              subtitle: SelectableText(
                [
                  'DLL chargée : ${_vitaleApiResult!.dllLoaded ? 'Oui' : 'Non'}',
                  'Hn_Init : ${_vitaleApiResult!.hnInitFound ? 'Trouvée' : 'Absente'}',
                  'Hn_Init retour : ${_vitaleApiResult!.hnInitReturn ?? '-'}',
                  'Hn_Init mode : ${_vitaleApiResult!.hnInitMode ?? '-'}',
                  'Hn_Init code erreur : ${_vitaleApiResult!.hnInitError ?? '-'}',
                  'Hn_LectureVitaleDonneesIdentification : '
                      '${_vitaleApiResult!.hnReadIdentityFound ? 'Trouvée' : 'Absente'}',
                  'Hn_Lecture retour : '
                      '${_vitaleApiResult!.hnReadReturn}',
                  'Hn_Lecture longueur : '
                      '${_vitaleApiResult!.hnReadLength}',
                  'Taille du buffer C++ : '
                      '${_vitaleApiResult!.hnReadBufferSize}',
                  'État carte : '
                      '${_vitaleApiResult!.hnCardState}',
                  'Hn_Lecture code erreur : '
                      '${_vitaleApiResult!.hnReadError}',
                  'Hn_Finir : '
                      '${_vitaleApiResult!.hnFinishFound ? 'Trouvée' : 'Absente'}',
                  if (_vitaleApiResult!.message != null)
                    'Message : ${_vitaleApiResult!.message}',
                  if (_vitaleApiResult!.windowsError != null)
                    'Erreur Windows : ${_vitaleApiResult!.windowsError}',
                ].join('\n'),
              ),
            ),
          ),

          if (_vitaleApiResult!.xml != null) ...[
            const SizedBox(height: 12),
            if (DeveloperFeatures.showSensitiveData)
              ExpansionTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('XML retourné par l’API'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(_vitaleApiResult!.xml!),
                  ),
                ],
              ),
            if (_parsedIdentity != null) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Identité décodée (parseur Dart)'),
                  subtitle: SelectableText(
                    [
                      'Nom : ${_parsedIdentity!.lastName ?? ''}',
                      'Prénom : ${_parsedIdentity!.firstName ?? ''}',
                      'Naissance : ${_parsedIdentity!.birthDate?.toIso8601String().split('T').first ?? ''}',
                      'Sexe : ${_parsedIdentity!.sexCode ?? ''}',
                      if (DeveloperFeatures.showSensitiveData)
                        'NIR : ${_parsedIdentity!.nir ?? ''}',
                    ].join('\n'),
                  ),
                ),
              ),
            ],
          ],
        ],

        const SizedBox(height: 24),

        const Divider(),

        const Text(
          'Diagnostic APDU avancé',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Outil technique de vérification PC/SC. Non utilisé pour créer un patient.',
        ),
        const SizedBox(height: 12),

        FilledButton.icon(
          onPressed: _testingApdu ? null : _testApdu,
          icon: const Icon(Icons.play_arrow),
          label: Text(_testingApdu ? 'Test APDU en cours...' : 'Tester APDU'),
        ),

        if (_apduResult != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text(
                _apduResult!.success ? 'Réponse APDU reçue' : 'Erreur APDU',
              ),
              subtitle: SelectableText(
                [
                  if (_apduResult!.readerName != null)
                    'Lecteur : ${_apduResult!.readerName}',
                  if (_apduResult!.protocol != null)
                    'Protocole : ${_apduResult!.protocol}',
                  if (_apduResult!.command != null)
                    'Commande : ${_apduResult!.command}',
                  if (_apduResult!.response != null)
                    'Réponse : ${_apduResult!.response}',
                  if (_apduResult!.error != null)
                    'Erreur : ${_apduResult!.error}',
                ].join('\n'),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        const Divider(),

        ExpansionTile(
          title: const Text('Sortie brute'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(result.rawOutput),
            ),
          ],
        ),
      ],
    );
  }
}
