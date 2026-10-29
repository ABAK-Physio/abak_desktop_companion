import 'cps_signature_pin_dialog.dart';
import '../dmp_local/dmp_local_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cps_access_service.dart';
import 'cps_profile.dart';

class CpsAccessScreen extends StatefulWidget {
  const CpsAccessScreen({super.key});

  @override
  State<CpsAccessScreen> createState() => _CpsAccessScreenState();
}

class _CpsAccessScreenState extends State<CpsAccessScreen>
    with WidgetsBindingObserver {
  final _pin = TextEditingController();
  CpsProfile? _profile;
  int? _selectedSituation;
  String? _error;
  Map<String, dynamic>? _signatureTest;
  bool _busy = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _generation++;
      _pin.clear();
      setState(() {
        _signatureTest = null;
        _profile = null;
        _selectedSituation = null;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pin.clear();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _read() async {
    if (_busy) return;
    var pin = _pin.text;
    _pin.clear();
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _profile = null;
      _selectedSituation = null;
      _error = null;
      _signatureTest = null;
    });
    try {
      final profile = await const CpsAccessService().read(pin);
      if (!mounted || generation != _generation) return;
      setState(() {
        _profile = profile;
        if (profile.situations.length == 1) {
          _selectedSituation = profile.situations.single.number;
        }
      });
    } on PlatformException catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _error = e.message ?? 'Lecture CPS impossible');
      }
    } on FormatException catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _error = e.message);
      }
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(
          () => _error = 'Le service CPS est indisponible sur ce poste.',
        );
      }
    } finally {
      pin = '';
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _testSignature() async {
    final profile = _profile;
    if (_busy || profile == null) return;
    var pin = await showDialog<String>(
      context: context,
      builder: (_) => CpsSignaturePinDialog(profile: profile),
    );
    if (pin == null || !mounted) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
      _signatureTest = null;
    });
    try {
      final result = await const CpsAccessService().testSignature(
        pin,
        profile.nationalId,
      );
      if (!mounted || generation != _generation) return;
      setState(() => _signatureTest = result);
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = e is PlatformException
              ? e.message
              : e is FormatException
              ? e.message
              : 'Test CPS indisponible';
          // A changed card must not leave a selectable stale identity.
          _profile = null;
          _selectedSituation = null;
        });
      }
    } finally {
      pin = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Carte CPS')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Insérez votre CPS de kiné, puis saisissez son PIN. '
                'La lecture récupère votre identité et les situations d’exercice inscrites dans la carte.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pin,
                enabled: !_busy,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: const InputDecoration(
                  labelText: 'PIN de la CPS',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _read(),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _read,
                icon: const Icon(Icons.badge_outlined),
                label: Text(_busy ? 'Lecture en cours…' : 'Lire la CPS'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Une seule tentative par clic. Le PIN n’est pas enregistré. '
                'Cette lecture ne réalise aucun appel INSi ni dépôt DMP.',
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (profile != null) ...[
                const Divider(height: 32),
                Text(
                  '${profile.givenName} ${profile.familyName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(profile.professionLabel),
                Text('Identifiant national : ${profile.nationalId}'),
                Text('Type de carte (code CPS) : ${profile.cardType}'),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _testSignature,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Certificats et test de signature'),
                ),
                if (_signatureTest != null && _selectedSituation != null)
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DmpLocalScreen(
                                profile: profile,
                                situation: profile.situations.singleWhere(
                                  (s) => s.number == _selectedSituation,
                                ),
                                certificateBase64:
                                    _signatureTest!['signingCertificateBase64']
                                        as String,
                              ),
                            ),
                          ),
                    icon: const Icon(Icons.description_outlined),
                    label: const Text(
                      'Préparer le CDA et le lot TD2.1 — local',
                    ),
                  ),
                if (_signatureTest != null) ...[
                  const Text(
                    'Signature vérifiée localement — le message altéré est bien rejeté.',
                  ),
                  Text('Algorithme : ${_signatureTest!['algorithm']}'),
                  for (final cert
                      in _signatureTest!['certificates'] as List) ...[
                    const SizedBox(height: 12),
                    Text('Certificat ${cert['role']} — ${cert['nationalId']}'),
                    Text(
                      'Validité : ${cert['validFrom']} → ${cert['validUntil']}',
                    ),
                    SelectableText('Empreinte SHA-256 : ${cert['sha256']}'),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Les certificats publics ont été récupérés en mémoire. '
                    'La clé privée reste dans la CPS. Ce test ne valide ni la chaîne de confiance, '
                    'ni la révocation des certificats, ni la conformité DMP.',
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _selectedSituation,
                  decoration: const InputDecoration(
                    labelText: 'Situation d’exercice',
                  ),
                  items: profile.situations
                      .map(
                        (s) => DropdownMenuItem(
                          value: s.number,
                          child: Text(
                            'Situation ${s.number} — ${s.structureName ?? 'Structure non renseignée'}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedSituation = value),
                  isExpanded: true,
                ),
                for (final s in profile.situations.where(
                  (s) => s.number == _selectedSituation,
                )) ...[
                  const SizedBox(height: 12),
                  Text('Mode d’exercice : ${s.mode} · Statut : ${s.status}'),
                  Text(
                    'Identifiant de structure : ${s.structureId ?? 'Absent de la carte'}',
                  ),
                  Text(
                    'Secteur d’activité : ${s.sector ?? 'Absent de la carte'}',
                  ),
                  if (s.structureId == null || s.sector == null)
                    const Text(
                      'Le contexte de structure devra être précisé avant un dépôt DMP, '
                      'notamment pour une activité de remplacement. Aucune valeur n’est déduite automatiquement.',
                    ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Résultat de la dernière lecture uniquement : la session carte est fermée. '
                  'Après un changement de carte, relancez la lecture. La sélection reste limitée à cet écran.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
