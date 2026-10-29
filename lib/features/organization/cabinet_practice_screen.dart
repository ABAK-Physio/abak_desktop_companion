import 'package:flutter/material.dart';
import '../../core/settings/cabinet_practice_service.dart';
import '../practitioners/data/practitioner_cps_service.dart';
import '../practitioners/widgets/practitioner_cps_dates_dialog.dart';
import 'cabinet_report_defaults_dialog.dart';

class CabinetPracticeScreen extends StatefulWidget {
  const CabinetPracticeScreen({super.key, this.service});
  final CabinetPracticeService? service;
  @override
  State<CabinetPracticeScreen> createState() => _CabinetPracticeScreenState();
}

class _CabinetPracticeScreenState extends State<CabinetPracticeScreen> {
  late final service = widget.service ?? CabinetPracticeService();
  CabinetRow? state;
  bool busy = true, dirty = false;
  bool customFacility = false;
  static const facilities = {
    'SA07': 'Cabinet individuel',
    'SA08': 'Cabinet de groupe',
    'SA09': 'Exercice en société',
  };
  String error = '', message = '';
  final controllers = {
    for (final key in CabinetPracticeService.fields)
      key: TextEditingController(),
  };
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> load() async {
    try {
      final result = await service.load();
      if (!mounted) return;
      for (final e in CabinetPracticeService.data(
        result['cabinet'] as CabinetRow?,
      ).entries) {
        controllers[e.key]!.text = e.value;
      }
      customFacility =
          controllers['facilityCode']!.text.isNotEmpty &&
          facilities[controllers['facilityCode']!.text] !=
              controllers['facilityLabel']!.text;
      setState(() {
        state = result;
        busy = false;
        dirty = false;
        error = '';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          busy = false;
        });
      }
    }
  }

  Future<void> save() async {
    setState(() {
      busy = true;
      error = '';
      message = '';
    });
    try {
      await service.saveCabinet({
        for (final e in controllers.entries) e.key: e.value.text,
      }, (state?['cabinet'] as Map?)?['revision'] as int? ?? 0);
      await load();
      if (mounted) {
        setState(
          () => message =
              'Paramètres communs enregistrés. Les rapports déjà conservés restent inchangés.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          busy = false;
        });
      }
    }
  }

  Future<void> membership(CabinetRow person, CabinetRow? previous) async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      final profile = await PractitionerCpsService.stored(
        await service.database(),
        person['practitioner_id'] as String,
      );
      if (!mounted) return;
      final saved = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _MembershipDialog(
          service: service,
          cabinetId: (state!['cabinet'] as Map)['cabinet_id'] as String,
          person: person,
          initial: previous,
          cps: profile == null
              ? null
              : PractitionerCpsReading.fromStored(profile),
        ),
      );
      if (saved == true) await load();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget field(String key, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controllers[key],
      enabled: !busy,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {
        dirty = true;
        message = '';
      }),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final identity = state?['identity'] as Map? ?? {};
    final people = (state?['practitioners'] as List? ?? []).cast<CabinetRow>();
    final memberships = (state?['memberships'] as List? ?? [])
        .cast<CabinetRow>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cabinet et rattachements des kinés')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (busy) const LinearProgressIndicator(),
              if (error.isNotEmpty)
                Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (state == null && !busy)
                TextButton(onPressed: load, child: const Text('Recharger')),
              if (state != null) ...[
                Text(
                  (identity['cabinet_name'] as String? ?? '').isEmpty
                      ? 'Cabinet configuré dans Companion'
                      : identity['cabinet_name'] as String,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  [
                    identity['cabinet_address_line1'],
                    identity['cabinet_postal_code'],
                    identity['cabinet_city'],
                  ].where((v) => v != null && v != '').join(' · '),
                ),
                const Text(
                  'Le nom et les coordonnées sont ceux de la fiche du cabinet. Plusieurs kinés peuvent y être rattachés, chacun avec sa propre CPS.',
                ),
                const SizedBox(height: 24),
                Text(
                  'Entité juridique liée au cabinet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text(
                  'Ces informations sont indépendantes des cartes CPS. Elles ne désignent pas automatiquement l’émetteur DMP.',
                ),
                const SizedBox(height: 12),
                field('legalName', 'Dénomination juridique (facultative)'),
                field(
                  'legalForm',
                  'Forme juridique, par exemple SCI (facultative)',
                ),
                field(
                  'legalIdentifierType',
                  'Type d’identifiant juridique, par exemple SIREN ou SIRET',
                ),
                field('legalIdentifier', 'Identifiant juridique'),
                const SizedBox(height: 12),
                Text(
                  'Paramètres communs des rapports',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text(
                  'Ils préremplissent le contexte des rapports des kinés rattachés. Les structures mentionnées par leurs CPS restent conservées séparément.',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey('setting-${controllers['setting']!.text}'),
                  initialValue: controllers['setting']!.text.isEmpty
                      ? ''
                      : (controllers['setting']!.text == 'Ambulatoire'
                            ? 'Ambulatoire'
                            : 'autre'),
                  decoration: const InputDecoration(
                    labelText: 'Cadre d’exercice habituel',
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Non renseigné')),
                    DropdownMenuItem(
                      value: 'Ambulatoire',
                      child: Text('Ambulatoire'),
                    ),
                    DropdownMenuItem(
                      value: 'autre',
                      child: Text('Autre cadre à préciser'),
                    ),
                  ],
                  onChanged: busy
                      ? null
                      : (v) => setState(() {
                          controllers['setting']!.text = v ?? '';
                          dirty = true;
                        }),
                ),
                if (controllers['setting']!.text.isNotEmpty &&
                    controllers['setting']!.text != 'Ambulatoire')
                  field('setting', 'Cadre d’exercice'),
                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'facility-${controllers['facilityCode']!.text}-${controllers['facilityLabel']!.text}',
                  ),
                  initialValue: customFacility
                      ? 'autre'
                      : controllers['facilityCode']!.text.isEmpty
                      ? ''
                      : controllers['facilityCode']!.text,
                  decoration: const InputDecoration(
                    labelText: 'Type de lieu de soins',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Non renseigné'),
                    ),
                    for (final entry in facilities.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    const DropdownMenuItem(
                      value: 'autre',
                      child: Text('Autre type — code et libellé à préciser'),
                    ),
                  ],
                  onChanged: busy
                      ? null
                      : (v) => setState(() {
                          customFacility = v == 'autre';
                          controllers['facilityCode']!.text =
                              facilities.containsKey(v) ? v! : '';
                          controllers['facilityLabel']!.text =
                              facilities[v] ?? '';
                          dirty = true;
                        }),
                ),
                if (customFacility) ...[
                  field(
                    'facilityCode',
                    'Code du lieu de soins issu du référentiel local',
                  ),
                  field('facilityLabel', 'Libellé du lieu de soins'),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy ? null : save,
                  child: const Text('Enregistrer les paramètres du cabinet'),
                ),
                if (message.isNotEmpty) Text(message),
                OutlinedButton.icon(
                  icon: const Icon(Icons.description_outlined),
                  label: const Text(
                    'Préremplissage des rapports : langue et classement',
                  ),
                  onPressed: busy || dirty || state?['cabinet'] == null
                      ? null
                      : () async {
                          final saved = await showDialog<bool>(
                            context: context,
                            builder: (_) => CabinetReportDefaultsDialog(
                              database: service.database,
                              cabinetId:
                                  (state!['cabinet'] as Map)['cabinet_id']
                                      as String,
                            ),
                          );
                          if (saved == true && mounted) {
                            setState(
                              () => message =
                                  'Préférences enregistrées pour les prochains préremplissages.',
                            );
                          }
                        },
                ),
                const Divider(height: 40),
                Text(
                  'Kinés exerçant dans ce cabinet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'Le rattachement est déclaré ici. Aucun rapprochement automatique n’est fait à partir d’un numéro de structure CPS.',
                ),
                if (dirty || state!['cabinet'] == null)
                  const Text(
                    'Enregistrez les paramètres du cabinet avant de modifier les rattachements.',
                  ),
                if (people.isEmpty)
                  const Text('Aucun kiné actif dans l’annuaire.'),
                for (final person in people)
                  Builder(
                    builder: (_) {
                      final link = memberships
                          .where(
                            (r) =>
                                r['practitioner_id'] ==
                                person['practitioner_id'],
                          )
                          .firstOrNull;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(person['display_name'] as String),
                        subtitle: Text(
                          link == null
                              ? 'Non rattaché'
                              : '${link['role']} · ${link['active'] == 1 ? 'rattachement actif' : 'rattachement inactif'}',
                        ),
                        trailing: OutlinedButton(
                          onPressed: busy || dirty || state!['cabinet'] == null
                              ? null
                              : () => membership(person, link),
                          child: Text(
                            link == null
                                ? 'Rattacher'
                                : 'Modifier le rattachement',
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MembershipDialog extends StatefulWidget {
  const _MembershipDialog({
    required this.service,
    required this.cabinetId,
    required this.person,
    this.initial,
    this.cps,
  });
  final CabinetPracticeService service;
  final String cabinetId;
  final CabinetRow person;
  final CabinetRow? initial;
  final PractitionerCpsReading? cps;
  @override
  State<_MembershipDialog> createState() => _MembershipDialogState();
}

class _MembershipDialogState extends State<_MembershipDialog> {
  late String? role = widget.initial?['role'] as String?;
  late String? start = widget.initial?['start_date'] as String?,
      end = widget.initial?['end_date'] as String?;
  late int? situation = widget.initial?['cps_situation_number'] as int?;
  late bool active = widget.initial?['active'] != 0;
  bool busy = false;
  String error = '';
  Future<void> save() async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await widget.service.saveMembership(
        cabinetId: widget.cabinetId,
        practitionerId: widget.person['practitioner_id'] as String,
        role: role ?? '',
        startDate: start,
        endDate: end,
        cpsSituation: situation,
        active: active,
        expectedRevision: widget.initial?['revision'] as int? ?? 0,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Rattachement de ${widget.person['display_name']}'),
    content: SizedBox(
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Les dates concernent l’exercice dans ce cabinet. Elles sont indépendantes de la date d’émission de la CPS.',
            ),
            DropdownButtonFormField<String>(
              initialValue: role,
              decoration: const InputDecoration(
                labelText: 'Rôle dans le cabinet',
              ),
              items: [
                for (final r in CabinetPracticeService.roles)
                  DropdownMenuItem(value: r, child: Text(r)),
              ],
              onChanged: busy ? null : (v) => setState(() => role = v),
            ),
            const SizedBox(height: 16),
            OptionalCivilDateField(
              label: 'Début d’exercice dans ce cabinet (facultatif)',
              value: start,
              enabled: !busy,
              onChanged: (v) => setState(() => start = v),
            ),
            const SizedBox(height: 16),
            OptionalCivilDateField(
              label: 'Fin d’exercice dans ce cabinet (facultative)',
              value: end,
              enabled: !busy,
              onChanged: (v) => setState(() => end = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: situation ?? 0,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Situation CPS enregistrée à utiliser (facultative)',
              ),
              items: [
                const DropdownMenuItem(
                  value: 0,
                  child: Text('À choisir dans le rapport'),
                ),
                for (final s in widget.cps?.profile.situations ?? [])
                  DropdownMenuItem(
                    value: s.number,
                    child: Text(
                      'Situation ${s.number} · ${s.structureName ?? 'structure non renseignée'}',
                    ),
                  ),
                if (situation != null &&
                    !(widget.cps?.profile.situations.any(
                          (s) => s.number == situation,
                        ) ??
                        false))
                  DropdownMenuItem(
                    value: situation,
                    child: const Text(
                      'Ancienne situation indisponible — à remplacer',
                    ),
                  ),
              ],
              onChanged: busy
                  ? null
                  : (v) => setState(() => situation = v == 0 ? null : v),
            ),
            const Text(
              'La liste utilise uniquement la fiche CPS déjà enregistrée. Les identifiants de la CPS et de l’entité juridique n’ont pas à être égaux.',
            ),
            SwitchListTile(
              title: const Text('Rattachement actif'),
              value: active,
              onChanged: busy ? null : (v) => setState(() => active = v),
            ),
            if (error.isNotEmpty)
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: busy || role == null ? null : save,
        child: const Text('Enregistrer le rattachement'),
      ),
    ],
  );
}
