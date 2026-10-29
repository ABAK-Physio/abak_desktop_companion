import 'dart:convert';
import 'package:abak_vitale/abak_vitale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../smart_card/widgets/vitale_beneficiary_selector.dart';
import '../services/patient_qualification_service.dart';
import '../services/patient_insi_retrieval_service.dart';
import 'patient_insi_dialogs.dart';
import '../services/cnda_patient_recipe.dart';

class PatientQualificationScreen extends StatefulWidget {
  final String patientId;
  const PatientQualificationScreen({super.key, required this.patientId});
  @override
  State<PatientQualificationScreen> createState() =>
      _PatientQualificationScreenState();
}

class _PatientQualificationScreenState
    extends State<PatientQualificationScreen> {
  final _service = PatientQualificationService();
  final _fields = {
    for (final key in PatientQualificationService.textFields)
      key: TextEditingController(),
  };
  final _flags = <String, bool>{};
  PatientIdentityRecord? _record;
  VitaleIdentity? _pendingVitale;
  DateTime? _pendingVitaleReadAt;
  String? _error, _message, _documentType, _checker;
  bool _busy = true, _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final record = await _service.load(widget.patientId);
      if (!mounted) return;
      setState(() {
        _apply(record);
        _busy = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Impossible de charger la fiche d’identité.';
        });
      }
    }
  }

  void _apply(PatientIdentityRecord record) {
    _record = record;
    final draft = record.draft;
    for (final entry in _fields.entries) {
      entry.value.text = draft[entry.key]?.toString() ?? '';
    }
    for (final key in PatientQualificationService.flagFields) {
      _flags[key] = draft[key] == 1;
    }
    _dirty = false;
    _pendingVitale = null;
    _pendingVitaleReadAt = null;
    _documentType = null;
    if (!record.practitioners.any((p) => p['practitioner_id'] == _checker)) {
      _checker = null;
    }
  }

  void _changed() => setState(() {
    _dirty = true;
    _message = null;
  });

  String _value(String key) => _fields[key]!.text;

  Future<void> _configureCndaRecipe() async {
    final record = _record;
    if (_busy || _dirty || record == null) return;
    Map<String, dynamic>? previous;
    try {
      previous = CndaPatientRecipe.read(record.identity);
    } catch (_) {
      // Allow correction of an unreadable recipe without accepting it.
    }
    final ins = TextEditingController(text: previous?['testIns'] as String?);
    final source = TextEditingController(text: previous?['source'] as String?);
    final experimentalCode = TextEditingController(
      text: previous?['experimentalBirthPlace'] as String?,
    );
    final experimentalReason = TextEditingController(
      text: previous?['experimentalBirthPlaceReason'] as String?,
    );
    bool experimental = previous?['experimentalBirthPlace'] != null;
    bool confirmed = false, saving = false;
    String? error;
    final route = DialogRoute<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => PopScope(
          canPop: !saving,
          child: AlertDialog(
            title: const Text('Patient de recette CNDA'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.patient['last_name']} ${record.patient['first_name']}',
                    ),
                    const Text(
                      'Recopiez les données du jeu d’essai officiel. Elles seront conservées séparément de l’INS issue d’INSi. La fiche restera provisoire et sera marquée fictive. Ce parcours permet la validation de test, les contrôles techniques et la préparation du dépôt sur DV1 uniquement. Chaque signature ou dépôt demande une action distincte.',
                    ),
                    TextField(
                      controller: ins,
                      enabled: !saving,
                      maxLength: 15,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText:
                            'INS de test CNDA (15 chiffres, clé comprise)',
                      ),
                    ),
                    TextField(
                      controller: source,
                      enabled: !saving,
                      maxLength: 2000,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText:
                            'Référence CNDA : fichier, onglet, ligne ou cas',
                      ),
                    ),
                    if ('${record.identity['birth_place_code'] ?? ''}'
                        .isEmpty) ...[
                      SwitchListTile(
                        title: const Text(
                          'Lieu de naissance absent : utiliser une valeur expérimentale sur DV1',
                        ),
                        value: experimental,
                        onChanged: saving
                            ? null
                            : (v) => update(() {
                                experimental = v;
                                confirmed = false;
                              }),
                      ),
                      if (experimental) ...[
                        const Text(
                          'Valeur inventée pour cet essai, non fournie ni approuvée par le CNDA. Elle sera conservée dans les preuves du document, sans modifier les traits de naissance du patient. Le résultat devra mentionner cette réserve.',
                        ),
                        TextField(
                          controller: experimentalCode,
                          enabled: !saving,
                          maxLength: 5,
                          decoration: const InputDecoration(
                            labelText: 'Code expérimental (5 chiffres)',
                          ),
                        ),
                        TextField(
                          controller: experimentalReason,
                          enabled: !saving,
                          maxLength: 1000,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Motif et réserve à joindre au résultat',
                          ),
                        ),
                      ],
                    ],
                    CheckboxListTile(
                      value: confirmed,
                      onChanged: saving
                          ? null
                          : (v) => update(() => confirmed = v == true),
                      title: const Text(
                        'Je confirme les données du patient fictif provenant du jeu CNDA et, si elle est activée, la valeur expérimentale déclarée séparément. Ce parcours est limité à DV1.',
                      ),
                    ),
                    if (error != null)
                      Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.error,
                        ),
                      ),
                    if (saving) const LinearProgressIndicator(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: saving || !confirmed
                    ? null
                    : () async {
                        update(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          await _service.saveCndaRecipe(
                            patientId: widget.patientId,
                            expectedToken: record.token,
                            testIns: ins.text,
                            source: source.text,
                            confirmed: confirmed,
                            experimentalBirthPlace: experimental
                                ? experimentalCode.text
                                : '',
                            experimentalBirthPlaceReason: experimental
                                ? experimentalReason.text
                                : '',
                          );
                          if (ctx.mounted) Navigator.pop(ctx, true);
                        } catch (e) {
                          if (ctx.mounted) {
                            update(() {
                              error = e.toString();
                              saving = false;
                            });
                          }
                        }
                      },
                child: const Text('Enregistrer la recette CNDA'),
              ),
            ],
          ),
        ),
      ),
    );
    final saved = await Navigator.of(context).push(route);
    await route.completed;
    ins.dispose();
    source.dispose();
    experimentalCode.dispose();
    experimentalReason.dispose();
    if (saved == true && mounted) {
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Recette CNDA enregistrée — identité toujours provisoire',
            ),
          ),
        );
      }
    }
  }

  void _select(String key, String? value) {
    _fields[key]!.text = value ?? '';
    _changed();
  }

  Future<void> _save({bool check = false}) async {
    final record = _record;
    if (record == null ||
        _busy ||
        (check &&
            (!PatientQualificationService.documentTypes.containsKey(
                  _documentType,
                ) ||
                _checker == null ||
                _checker!.isEmpty))) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      final updated = await _service.save(
        patientId: widget.patientId,
        expectedToken: record.token,
        values: {
          for (final entry in _fields.entries) entry.key: entry.value.text,
          for (final entry in _flags.entries) entry.key: entry.value ? 1 : 0,
        },
        attestIdentity: check,
        documentType: _documentType,
        practitionerId: _checker,
        vitaleIdentity: _pendingVitale,
        vitaleReadAt: _pendingVitaleReadAt,
      );
      if (!mounted) return;
      setState(() {
        _apply(updated);
        _message = check
            ? 'Contrôle du justificatif enregistré. Identité ${PatientQualificationService.statusLabel(updated.status).toLowerCase()}.'
            : 'Informations enregistrées. Statut : ${PatientQualificationService.statusLabel(updated.status).toLowerCase()}.';
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error =
              '${error is ArgumentError
                  ? error.message
                  : error is StateError
                  ? error.message
                  : 'Enregistrement impossible.'} Vos saisies sont conservées.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _leave() async {
    if (_busy) return;
    if (_dirty) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quitter sans enregistrer ?'),
          content: const Text(
            'Les modifications de cette fiche ne sont pas enregistrées.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Rester'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Quitter'),
            ),
          ],
        ),
      );
      if (leave != true) return;
    }
    if (mounted) Navigator.pop(context, true);
  }

  // Only nomPatronymique may prefill the birth name; never nomUsuel.
  Map<String, String?> _vitaleValues(VitaleIdentity identity) => {
    'used_last_name': identity.lastName,
    'used_first_name': identity.firstName,
    'birth_last_name': identity.birthLastName,
    'birth_date': identity.birthDate == null
        ? null
        : DateFormat('yyyy-MM-dd').format(identity.birthDate!),
    'sex_code': identity.sexCode,
  };

  void _completeFromVitale(VitaleIdentity identity, {DateTime? readAt}) {
    var count = 0;
    setState(() {
      for (final entry in _vitaleValues(identity).entries) {
        final value = entry.value?.trim() ?? '';
        if (_value(entry.key).trim().isEmpty && value.isNotEmpty) {
          _fields[entry.key]!.text = value;
          count++;
        }
      }
      if (readAt != null) {
        _pendingVitale = identity;
        _pendingVitaleReadAt = readAt;
      }
      _dirty = _dirty || count > 0 || readAt != null;
      _error = null;
      _message = count > 0
          ? '$count champ(s) vide(s) complété(s). Enregistrez les informations pour les conserver.'
          : readAt != null
          ? 'Bénéficiaire retenu. Les champs renseignés sont conservés. Enregistrez pour conserver cette lecture.'
          : 'Aucun champ vide à compléter avec cette lecture.';
    });
  }

  Future<void> _readVitale() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      final status = await ApiLecService().getModuleStatus();
      if (!mounted) return;
      if (!status.installed) {
        throw StateError(
          'Le module de lecture Carte Vitale n’est pas installé.',
        );
      }
      final identities = await VitaleIdentityService().readVitaleIdentities();
      final readAt = DateTime.now();
      if (!mounted) return;
      if (identities.isEmpty) {
        throw StateError('Aucun bénéficiaire n’a été lu sur la carte Vitale.');
      }
      final identity = identities.length == 1
          ? identities.single
          : await VitaleBeneficiarySelector.show(context, identities);
      if (!mounted || identity == null) return;
      final values = _vitaleValues(identity);
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Utiliser ce bénéficiaire pour cette fiche ?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fiche ouverte : ${_record!.patient['last_name']} ${_record!.patient['first_name']}',
                ),
                const SizedBox(height: 12),
                for (final entry in const {
                  'used_last_name': 'Nom d’usage',
                  'used_first_name': 'Prénom utilisé',
                  'birth_last_name': 'Nom de naissance',
                  'birth_date': 'Date de naissance',
                  'sex_code': 'Sexe',
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${entry.value}\n'
                      'Fiche : ${_value(entry.key).trim().isEmpty ? 'Non renseigné' : _value(entry.key)}\n'
                      'Carte : ${values[entry.key]?.trim().isNotEmpty == true ? values[entry.key] : 'Non fourni'}',
                    ),
                  ),
                const Text(
                  'Seuls les champs vides seront complétés. Les différences restent à examiner. '
                  'Cette lecture ne valide pas l’identité et ne récupère pas l’INS.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Utiliser pour cette fiche'),
            ),
          ],
        ),
      );
      if (!mounted || accepted != true) return;
      _completeFromVitale(identity, readAt: readAt);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is StateError
            ? error.message.toString()
            : error is PlatformException &&
                  error.code == 'API_INIT_ERROR' &&
                  (error.message?.contains('retour=13') ?? false)
            ? 'Lecteur de carte Vitale non détecté. Vérifiez son branchement.'
            : 'Lecture Vitale impossible. Vérifiez le lecteur, la carte et la configuration du module. Vos saisies sont conservées.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _configureInsi() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final service = PatientInsiRetrievalService();
      final values = await service.configuration();
      final professionals = await service.knownProfessionals();
      if (!mounted) return;
      await showDialog<bool>(
        context: context,
        builder: (_) => PatientInsiConfigurationDialog(
          initial: values,
          professionals: professionals,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible de charger la configuration INSi.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _retrieveInsi() async {
    final record = _record;
    if (_busy || _dirty || record == null || record.vitale == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    String? pin;
    try {
      if (_flags['identity_doubtful'] == true ||
          _flags['identity_fictitious'] == true) {
        throw StateError(
          'Une identité signalée douteuse ou fictive ne permet pas cet appel.',
        );
      }
      final card = VitaleIdentity.fromMap(
        Map<String, dynamic>.from(
          jsonDecode(record.vitale!['identity_json'] as String),
        ),
      );
      PatientInsiRetrievalService.checkCard(card);
      final service = PatientInsiRetrievalService();
      PatientInsiRetrievalService.checkConfiguration(
        await service.configuration(),
      );
      if (!mounted) return;
      pin = await showDialog<String>(
        context: context,
        builder: (_) => PatientInsiPinDialog(
          patient:
              '${record.patient['last_name']} ${record.patient['first_name']}',
        ),
      );
      if (!mounted || pin == null) return;
      final response = await service.retrieve(card: card, pin: pin);
      pin = null;
      final eventId = await _service.retainInsiResponse(
        widget.patientId,
        record.token,
        response,
      );
      if (!mounted) return;
      final result = response.result;
      if (!result.isSuccess) {
        final updated = await _service.load(widget.patientId);
        if (!mounted) return;
        setState(() {
          _apply(updated);
          _message = result.isNotFound
              ? 'INSi : aucune identité trouvée. La fiche est inchangée ; la réponse est conservée.'
              : 'INSi : plusieurs identités possibles. La fiche est inchangée ; la réponse est conservée.';
        });
        return;
      }
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Identité retournée par INSi'),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fiche ouverte : ${record.patient['last_name']} ${record.patient['first_name']}',
                  ),
                  const SizedBox(height: 12),
                  for (final entry in <String, List<String?>>{
                    'Nom de naissance': [
                      _value('birth_last_name'),
                      result.birthLastName,
                    ],
                    'Prénoms de naissance': [
                      _value('birth_first_names'),
                      result.birthFirstNames,
                    ],
                    'Date de naissance': [
                      _value('birth_date'),
                      result.birthDate,
                    ],
                    'Sexe': [_value('sex_code'), result.sexCode],
                    'Code du lieu de naissance': [
                      _value('birth_place_code'),
                      result.birthPlaceCode,
                    ],
                  }.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${entry.key}\nFiche : ${entry.value.first?.isNotEmpty == true ? entry.value.first : 'Non renseigné'}'
                        '\nINSi : ${entry.value.last ?? 'Non fourni'}',
                        style: TextStyle(
                          fontWeight:
                              entry.value.first?.trim().toUpperCase() !=
                                  entry.value.last?.trim().toUpperCase()
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  Text(
                    'Matricule INS : ${result.insNumber ?? 'Absent'} — clé ${result.insKey ?? 'absente'}',
                  ),
                  Text('Autorité : ${result.insOid ?? 'absente'}'),
                  if ([
                    '1.2.250.1.213.1.4.9',
                    '1.2.250.1.213.1.4.11',
                  ].contains(result.insOid))
                    const Text('Matricule NIA : identifiant non définitif.'),
                  const SizedBox(height: 12),
                  const Text(
                    'Vérifiez que cette identité correspond au patient. Les différences sont en gras. '
                    'Les noms d’usage sont conservés. Un changement des traits nécessite un nouveau contrôle du justificatif.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Ne pas appliquer'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Rattacher cette INS au patient'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      final updated = accepted == true
          ? await _service.applyInsiResponse(widget.patientId, eventId)
          : await _service.load(widget.patientId);
      if (!mounted) return;
      setState(() {
        _apply(updated);
        _message = accepted == true
            ? 'INS et traits enregistrés. Identité ${PatientQualificationService.statusLabel(updated.status).toLowerCase()}.'
            : 'Réponse conservée dans l’historique, sans modification de l’identité.';
      });
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is StateError
              ? e.message.toString()
              : e is FormatException
              ? e.message
              : 'Récupération INSi non effectuée. Vérifiez la CPS, la configuration et la connexion. Aucun nouvel appel automatique.',
        );
      }
    } finally {
      pin = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(String key, String label, {String? help}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: _fields[key],
      enabled: !_busy,
      decoration: InputDecoration(
        labelText: label,
        helperText: help,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => _changed(),
    ),
  );

  Widget _section(String title, List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ),
  );

  Widget _choice(
    String label,
    String? value,
    Map<String, String> items,
    ValueChanged<String?> change, {
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      initialValue: items.containsKey(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('Non renseigné')),
        for (final entry in items.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: _busy ? null : change,
    ),
  );

  static String _date(Object? value) => value is int
      ? DateFormat(
          'dd/MM/yyyy à HH:mm',
        ).format(DateTime.fromMillisecondsSinceEpoch(value))
      : 'Non renseignée';

  List<Widget> _vitale(PatientIdentityRecord record) {
    final reading = record.vitale;
    final data =
        _pendingVitale?.toMap() ??
        (reading == null
            ? <String, dynamic>{}
            : jsonDecode(reading['identity_json'] as String)
                  as Map<String, dynamic>);
    return [
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: _busy ? null : _readVitale,
            icon: const Icon(Icons.credit_card),
            label: const Text('Lire la carte Vitale'),
          ),
          if (reading != null || _pendingVitale != null)
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _completeFromVitale(
                      _pendingVitale ?? VitaleIdentity.fromMap(data),
                    ),
              child: const Text('Compléter avec la lecture disponible'),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        _pendingVitale != null
            ? 'Lecture du ${_date(_pendingVitaleReadAt!.millisecondsSinceEpoch)} — à enregistrer.'
            : reading == null
            ? 'Aucune lecture Vitale conservée avec sa provenance. '
                  'Les anciennes lectures ne sont pas reconstituées.'
            : 'Dernière lecture conservée : ${_date(reading['read_at'])}',
      ),
      if (reading != null || _pendingVitale != null) ...[
        SelectableText(
          'Nom et prénom d’usage lus : ${data['lastName'] ?? 'Non fourni'} ${data['firstName'] ?? ''}',
        ),
        SelectableText(
          'Nom de naissance lu : ${data['birthLastName'] ?? 'Non fourni'}',
        ),
        SelectableText(
          'Date de naissance lue : ${(data['birthDate'] as String?)?.split('T').first ?? 'Non fournie'}',
        ),
        SelectableText(
          'Rang de naissance lu : ${data['birthOrder'] ?? 'Non fourni'}',
        ),
        SelectableText('NIR lu sur la carte : ${data['nir'] ?? 'Non fourni'}'),
      ] else if (record.patient['nir'] != null)
        const Text(
          'Un NIR est présent dans l’ancienne fiche, sans trace de lecture exploitable.',
        ),
      const SizedBox(height: 8),
      const Text(
        'Le NIR de la carte peut être celui de l’assuré auquel le bénéficiaire est rattaché. '
        'Il ne devient pas automatiquement l’INS du patient. '
        'Le nom de naissance est proposé uniquement s’il est fourni par la carte. '
        'INSi permet de récupérer la liste des prénoms de naissance et le code du lieu de naissance.',
      ),
      const SizedBox(height: 16),
      _field(
        'beneficiary_number',
        'Numéro d’ordre du bénéficiaire (facultatif)',
        help:
            'Saisie déclarée. Le lecteur actuel ne transmet pas ce champ. '
            'Ce n’est ni la position dans la liste ni le rang de naissance.',
      ),
      _choice(
        'Lien du bénéficiaire avec l’assuré (facultatif)',
        _value('beneficiary_relationship'),
        PatientQualificationService.relationships,
        (value) => _select('beneficiary_relationship', value),
        hint: 'Saisie déclarée, sans déduction à partir du numéro ou du rang.',
      ),
      _field(
        'beneficiary_quality_code',
        'Code qualité du bénéficiaire, si connu (facultatif)',
        help: 'Conserver le code fourni par la source, sans en inventer un.',
      ),
    ];
  }

  List<Widget> _ins(PatientIdentityRecord record) {
    final identity = record.identity;
    final current = PatientQualificationService.hasCurrentIns(identity);
    return [
      Text(
        current
            ? 'INS récupérée et rattachée aux traits enregistrés.'
            : identity['ins_number'] == null
            ? 'Aucune INS récupérée enregistrée.'
            : 'Une ancienne INS est conservée ; sa correspondance avec les traits actuels reste à vérifier.',
      ),
      if (identity['ins_number'] != null) ...[
        SelectableText(
          'Matricule : ${identity['ins_number']} · clé : ${identity['ins_key'] ?? 'absente'}',
        ),
        SelectableText('Autorité (OID) : ${identity['ins_oid'] ?? 'absente'}'),
      ],
      Text('Récupération : ${_date(identity['ins_retrieved_at'])}'),
      Text('Dernière vérification : ${_date(identity['ins_last_checked_at'])}'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          FilledButton(
            onPressed:
                _busy ||
                    _dirty ||
                    record.vitale == null ||
                    _flags['identity_doubtful'] == true ||
                    _flags['identity_fictitious'] == true
                ? null
                : _retrieveInsi,
            child: const Text('Récupérer l’INS avec la lecture Vitale'),
          ),
          OutlinedButton(
            onPressed: _busy ? null : _configureInsi,
            child: const Text('Configurer INSi — test'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (_dirty)
        const Text(
          'Enregistrez les informations de la fiche avant de récupérer l’INS.',
        ),
      const Text(
        'Serveur INSi de test uniquement. La récupération demande votre CPS et son PIN. '
        'Le résultat est présenté avant rattachement à cette fiche. '
        'Aucun appel à l’ouverture de l’écran, aucun dépôt DMP.',
      ),
    ];
  }

  List<Widget> _check(PatientIdentityRecord record) {
    final identity = record.identity;
    final blocked =
        _flags['identity_doubtful'] == true ||
        _flags['identity_fictitious'] == true;
    final actors = {
      for (final p in record.practitioners)
        p['practitioner_id'] as String: p['display_name'] as String,
    };
    return [
      if (identity['identity_validated_at'] != null) ...[
        Text(
          'Contrôle enregistré le ${_date(identity['identity_validated_at'])}',
        ),
        Text(
          'Justificatif : ${PatientQualificationService.documentTypes[identity['identity_validation_method']] ?? identity['identity_validation_method']}',
        ),
        Text(
          'Professionnel : ${actors[identity['identity_validated_by']] ?? identity['identity_validated_by']}',
        ),
        const SizedBox(height: 12),
      ],
      const Text(
        'À renseigner uniquement après comparaison de la personne et de ses traits '
        'avec un justificatif d’identité de haut niveau de confiance recevable. '
        'La carte Vitale physique ne remplace pas ce contrôle. '
        'Ni numéro ni copie du justificatif ne sont demandés ici.',
      ),
      const SizedBox(height: 16),
      const Text('J’ai vérifié l’identité sur présentation de :'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final entry in PatientQualificationService.documentTypes.entries)
            ChoiceChip(
              label: Text(entry.key == 'cni' ? 'CNI' : entry.value),
              selected: _documentType == entry.key,
              onSelected: _busy || blocked
                  ? null
                  : (selected) => setState(() {
                      _documentType = selected ? entry.key : null;
                      _dirty = true;
                      _message = null;
                    }),
            ),
        ],
      ),
      const SizedBox(height: 16),
      _choice(
        'Professionnel ayant vérifié l’identité',
        _checker,
        actors,
        (value) => setState(() {
          _checker = value;
          _dirty = true;
          _message = null;
        }),
      ),
      const Text(
        'En enregistrant, vous attestez la concordance entre la personne, '
        'le justificatif choisi et les informations d’identité renseignées. '
        'La date du contrôle est enregistrée automatiquement.',
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed:
            _busy ||
                blocked ||
                _documentType == null ||
                !actors.containsKey(_checker)
            ? null
            : () => _save(check: true),
        child: const Text('Enregistrer le contrôle d’identité'),
      ),
      const SizedBox(height: 8),
      const Text(
        'Cette action concerne l’identité du patient. Elle ne valide aucun rapport médical '
        'et ne sollicite aucune carte CPS.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identité et qualification du patient'),
        leading: IconButton(
          onPressed: _busy ? null : _leave,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: record == null
          ? Center(
              child: _busy
                  ? const CircularProgressIndicator()
                  : Text(_error ?? 'Fiche indisponible'),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  '${record.patient['last_name']} ${record.patient['first_name']}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                _section(
                  'Statut global enregistré : ${PatientQualificationService.statusLabel(record.status)}',
                  [
                    const Text(
                      'Provisoire : preuves incomplètes. Validée : identité contrôlée sur justificatif. '
                      'Récupérée : INS obtenue, contrôle d’identité restant à faire. '
                      'Qualifiée : contrôle d’identité et INS concordants.',
                    ),
                    if (_dirty)
                      const Text(
                        'Modifications non enregistrées : le statut affiché concerne la version conservée.',
                      ),
                    const Text(
                      'Une modification des traits de naissance impose de reprendre les contrôles concernés.',
                    ),
                  ],
                ),
                _section('Carte Vitale et bénéficiaire', _vitale(record)),
                _section('Recette DMP — patient fictif CNDA', [
                  Text(
                    record.identity['cnda_recipe_json'] == null
                        ? 'Aucune recette CNDA enregistrée. Cette option est réservée aux patients fictifs du jeu d’essai.'
                        : 'Données CNDA enregistrées séparément de l’INS. La fiche reste provisoire. Préparation et dépôt de recette sur DV1 uniquement, après contrôles et confirmation.',
                  ),
                  if (_dirty)
                    const Text(
                      'Enregistrez d’abord les informations sans valider l’identité.',
                    ),
                  OutlinedButton(
                    onPressed: _busy || _dirty ? null : _configureCndaRecipe,
                    child: const Text('Configurer le patient de recette CNDA'),
                  ),
                ]),
                _section('Identité nationale de santé (INS)', _ins(record)),
                _section('Noms d’usage', [
                  _field('used_last_name', 'Nom d’usage'),
                  _field('used_first_name', 'Prénom utilisé'),
                  const Text(
                    'Les noms déjà présents dans la fiche sont proposés ici. '
                    'Ils ne sont pas automatiquement considérés comme les noms de naissance.',
                  ),
                ]),
                _section('Traits de naissance', [
                  _field('birth_last_name', 'Nom de naissance'),
                  _field(
                    'birth_first_names',
                    'Tous les prénoms de naissance, dans leur ordre',
                  ),
                  _field(
                    'first_birth_name',
                    'Premier prénom de naissance (facultatif à la saisie)',
                  ),
                  _field(
                    'birth_date',
                    'Date de naissance (AAAA-MM-JJ)',
                    help:
                        'Ne pas inventer un jour ou un mois inconnu ; utiliser 00. L’âge ne sera alors pas calculé.',
                  ),
                  _choice('Sexe', _value('sex_code'), const {
                    'U': 'Non renseigné',
                    'M': 'Masculin',
                    'F': 'Féminin',
                    'X': 'Autre valeur enregistrée',
                  }, (value) => _select('sex_code', value)),
                  _field(
                    'birth_place_code',
                    'Code INSEE du lieu de naissance',
                    help:
                        'Commune française ou code du pays de naissance à l’étranger ; ce n’est pas un code postal.',
                  ),
                  _field(
                    'birth_place_label',
                    'Commune ou pays de naissance (libellé facultatif)',
                  ),
                ]),
                _section('Points de vigilance', [
                  for (final entry in const {
                    'identity_homonym': 'Homonymie signalée',
                    'identity_doubtful': 'Identité douteuse',
                    'identity_fictitious': 'Identité fictive',
                  }.entries)
                    CheckboxListTile(
                      value: _flags[entry.key] == true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(entry.value),
                      onChanged: _busy
                          ? null
                          : (value) {
                              _flags[entry.key] = value == true;
                              _changed();
                            },
                    ),
                  const Text(
                    'Une identité douteuse ou fictive reste provisoire. '
                    'Lever le signalement ne rétablit pas automatiquement une validation antérieure.',
                  ),
                ]),
                _section('Contrôle du justificatif d’identité', _check(record)),
                _section('Historique de l’identité', [
                  if (record.events.isEmpty)
                    const Text(
                      'Aucun événement enregistré dans cette rubrique.',
                    ),
                  for (final event in record.events)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(switch (event['event_kind']) {
                        'vitale_read' => 'Lecture Vitale rattachée au patient',
                        'insi_response' => 'Réponse INSi reçue et conservée',
                        'insi_applied' =>
                          'INS et traits rattachés après comparaison',
                        'identity_checked' =>
                          'Contrôle du justificatif enregistré',
                        'identity_changed' =>
                          'Traits d’identité modifiés ; preuves antérieures conservées dans l’historique',
                        _ => 'Informations enregistrées',
                      }),
                      subtitle: Text(
                        '${_date(event['occurred_at'])}${event['actor_name'] == null ? '' : ' · ${event['actor_name']}'}',
                      ),
                    ),
                  const Text(
                    'Les 20 derniers événements sont affichés. Les événements plus anciens restent conservés.',
                  ),
                ]),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (_message != null) Text(_message!),
              if (_busy) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _busy || record == null ? null : () => _save(),
                child: const Text(
                  'Enregistrer les informations sans valider l’identité',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
