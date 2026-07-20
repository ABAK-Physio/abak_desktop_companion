import 'package:flutter/material.dart';

import '../services/smart_card_diagnostic_service.dart';
import '../models/vitale_identity.dart';
import '../services/vitale_xml_parser.dart';
import '../../../core/config/developer_features.dart';
import '../services/smart_card_reader_service.dart';
import '../services/smart_card_configuration_service.dart';

class SmartCardDiagnosticScreen extends StatefulWidget {
  const SmartCardDiagnosticScreen({super.key});

  @override
  State<SmartCardDiagnosticScreen> createState() =>
      _SmartCardDiagnosticScreenState();
}

class _SmartCardDiagnosticScreenState extends State<SmartCardDiagnosticScreen> {
  final _service = const SmartCardDiagnosticService();
  final _readerService = const SmartCardReaderService();
  final _configurationService = const SmartCardConfigurationService();
  VitaleIdentity? _parsedIdentity;

  SmartCardDiagnosticResult? _result;
  bool _loading = false;
  SmartCardApduResult? _apduResult;
  bool _testingApdu = false;
  List<String> _availableReaders = const [];
  bool _loadingReaders = false;
  bool _loadingConfiguration = false;
  bool? _configurationExists;
  String? _configurationContent;
  String? _configurationError;

  String? _selectedReader;
  bool _configuringReader = false;
  String? _readerConfigurationMessage;
  String? _readerConfigurationError;

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

    _refreshAll();
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

  Future<void> _loadAvailableReaders() async {
    setState(() {
      _loadingReaders = true;
      _availableReaders = const [];
    });

    final readers = await _readerService.getAvailableReaders();

    if (!mounted) return;

    setState(() {
      _availableReaders = readers;
      _selectedReader = readers.length == 1 ? readers.first : null;
      _loadingReaders = false;
    });
  }

  Future<void> _configureSelectedReader() async {
    final reader = _selectedReader;

    if (reader == null) {
      return;
    }

    setState(() {
      _configuringReader = true;
      _readerConfigurationMessage = null;
      _readerConfigurationError = null;
    });

    try {
      await _configurationService.configureReader(reader);

      if (!mounted) return;

      setState(() {
        _configuringReader = false;
        _readerConfigurationMessage =
            'Le lecteur a été enregistré dans api_lec.ini.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _configuringReader = false;
        _readerConfigurationError = e.toString();
      });
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _refresh(),
      _loadAvailableReaders(),
      _loadSmartCardConfiguration(),
    ]);
  }

  Future<void> _loadSmartCardConfiguration() async {
    setState(() {
      _loadingConfiguration = true;
      _configurationExists = null;
      _configurationContent = null;
      _configurationError = null;
    });

    try {
      final exists = await _configurationService.configurationFileExists();

      String? content;

      if (exists) {
        content = await _configurationService.readConfiguration();
      }

      if (!mounted) return;

      setState(() {
        _configurationExists = exists;
        _configurationContent = content;
        _loadingConfiguration = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _configurationError = e.toString();
        _loadingConfiguration = false;
      });
    }
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
            onPressed:
            _loading || _loadingReaders || _loadingConfiguration
                ? null
                : _refreshAll,
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
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  result.readerDetected
                      ? Icons.check_circle
                      : Icons.error_outline,
                ),
                title: const Text('Lecteur de Carte Vitale'),
                subtitle: Text(
                  result.readerDetected
                      ? 'Connecté'
                      : 'Non détecté',
                ),
              ),

              const Divider(height: 1),

              ListTile(
                leading: Icon(
                  _configurationExists == true
                      ? Icons.check_circle
                      : Icons.error_outline,
                ),
                title: const Text('Configuration du lecteur'),
                subtitle: Text(
                  _configurationExists == true
                      ? 'Prête'
                      : 'À vérifier',
                ),
              ),

              const Divider(height: 1),

              ListTile(
                leading: Icon(
                  result.cardDetected
                      ? Icons.credit_card
                      : Icons.credit_card_off,
                ),
                title: const Text('Carte Vitale'),
                subtitle: Text(
                  result.cardDetected
                      ? 'Présente'
                      : 'Absente',
                ),
              ),
            ],
          ),
        ),

        if (result.error != null)
          Card(
            child: ListTile(
              title: const Text('Erreur'),
              subtitle: Text(result.error!),
            ),
          ),

        const SizedBox(height: 16),


        ExpansionTile(
          leading: const Icon(Icons.build_outlined),
          title: const Text('Informations techniques'),
          subtitle: const Text(
            'Lecteurs, configuration et données de diagnostic',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('ATR'),
              subtitle: SelectableText(result.atr ?? 'Non disponible'),
            ),

            const Divider(),

            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: _loadingReaders ? null : _loadAvailableReaders,
              icon: const Icon(Icons.usb),
              label: Text(
                _loadingReaders
                    ? 'Recherche des lecteurs...'
                    : 'Actualiser les lecteurs',
              ),
            ),

            if (_availableReaders.isEmpty && !_loadingReaders) ...[
              const SizedBox(height: 12),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text('Aucun lecteur détecté'),
              ),
            ],

            if (_availableReaders.isNotEmpty) ...[
              const SizedBox(height: 12),

              RadioGroup<String>(
                groupValue: _selectedReader,
                onChanged: (value) {
                  if (_configuringReader) return;

                  setState(() {
                    _selectedReader = value;
                    _readerConfigurationMessage = null;
                    _readerConfigurationError = null;
                  });
                },
                child: Column(
                  children: _availableReaders
                      .map(
                        (reader) => RadioListTile<String>(
                          value: reader,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Lecteur détecté'),
                          subtitle: SelectableText(reader),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 12),

              FilledButton.icon(
                onPressed: _selectedReader == null || _configuringReader
                    ? null
                    : _configureSelectedReader,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  _configuringReader
                      ? 'Configuration en cours...'
                      : 'Utiliser ce lecteur',
                ),
              ),

              if (_readerConfigurationMessage != null) ...[
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Configuration enregistrée'),
                  subtitle: Text(_readerConfigurationMessage!),
                ),
              ],

              if (_readerConfigurationError != null) ...[
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.error_outline),
                  title: const Text('Erreur de configuration'),
                  subtitle: SelectableText(_readerConfigurationError!),
                ),
              ],
            ],

            const Divider(height: 32),

            const SizedBox(height: 12),

            SelectableText(
              'Fichier : ${_configurationService.configurationFile.path}',
            ),

            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: _loadingConfiguration
                  ? null
                  : _loadSmartCardConfiguration,
              icon: const Icon(Icons.settings_outlined),
              label: Text(
                _loadingConfiguration
                    ? 'Lecture en cours...'
                    : 'Actualiser la configuration',
              ),
            ),

            if (_configurationExists != null) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _configurationExists!
                      ? Icons.check_circle
                      : Icons.error_outline,
                ),
                title: Text(
                  _configurationExists!
                      ? 'Fichier trouvé'
                      : 'Fichier introuvable',
                ),
              ),
            ],

            if (_configurationError != null) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.error_outline),
                title: const Text('Erreur de lecture'),
                subtitle: SelectableText(_configurationError!),
              ),
            ],

            if (_configurationContent != null) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_outlined),
                title: const Text('Contenu de api_lec.ini'),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SelectableText(_configurationContent!),
                  ),
                ],
              ),
            ],
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
                if (DeveloperFeatures.showSensitiveData) ...[
                  const SizedBox(height: 12),

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
                ],

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
                          'Naissance : '
                              '${_parsedIdentity!.birthDate?.toIso8601String().split('T').first ?? ''}',
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
        ),
      ],
    );
  }
}
