import 'dart:convert';
import 'package:flutter/material.dart';
import '../../patients/services/document_medical_service.dart';
import '../data/practitioner_cps_service.dart';
import '../models/practitioner_cps_dates.dart';
import 'practitioner_cps_dates_dialog.dart';
import '../../../core/settings/cabinet_practice_service.dart';
import '../../organization/cabinet_practice_screen.dart';

/// Shared durable exercise situations, managed from the kiné or a report.
class PractitionerSituationDialog extends StatefulWidget {
  const PractitionerSituationDialog({
    super.key,
    required this.service,
    required this.practitioner,
    this.initial,
    this.cps,
    this.dates,
    this.cabinet,
    this.prefillCps = false,
  });
  final DocumentMedicalService service;
  final String practitioner;
  final MedicalRow? initial;
  final PractitionerCpsReading? cps;
  final PractitionerCpsDates? dates;
  final CabinetRow? cabinet;
  final bool prefillCps;
  @override
  State<PractitionerSituationDialog> createState() =>
      _PractitionerSituationDialogState();
}

class _PractitionerSituationDialogState
    extends State<PractitionerSituationDialog> {
  late Map<String, String> data;
  CabinetRow? cabinet;
  bool busy = false;
  String error = '';
  int formRevision = 0;
  int? situation;
  late PractitionerCpsDates declaredDates;
  static const labels = {
    'identifierType': 'Type d’identifiant (RPPS, ADELI, IDNPS ou autre)',
    'identifier': 'Identifiant professionnel',
    'authority': 'Autorité de l’identifiant',
    'professionCode': 'Code profession',
    'professionSystem': 'Système de codage de la profession',
    'professionLabel': 'Profession',
    'familyName': 'Nom professionnel pour le CDA',
    'givenNames': 'Prénom(s) professionnel(s) pour le CDA',
    'situation': 'Situation d’exercice',
    'setting': 'Cadre d’exercice',
    'structureType': 'Type de structure (FINESS, SIRET, cabinet ou autre)',
    'structureId': 'Identifiant de structure de la situation professionnelle',
    'structureAuthority': 'Autorité de cet identifiant',
    'structureName': 'Nom de structure de la situation professionnelle',
    'validFrom': 'Début d’exercice dans cette situation (facultatif)',
    'validUntil': 'Valide jusqu’au (facultatif hors remplacement)',
    'replacementFor': 'Professionnel remplacé (facultatif)',
    'facilityCode': 'Code du lieu de soins (pour le contrôle CDA)',
    'facilityLabel': 'Libellé du lieu de soins (pour le contrôle CDA)',
  };
  @override
  void initState() {
    super.initState();
    declaredDates = widget.dates ?? PractitionerCpsDates();
    cabinet = widget.cabinet;
    data = widget.initial == null
        ? {for (final f in DocumentMedicalService.contextFields) f: ''}
        : Map<String, String>.from(
            jsonDecode(widget.initial!['data_json'] as String),
          );
    data['structureType'] = DocumentMedicalService.normalizeStructureType(
      data['structureType'] ?? '',
    );
    situation = int.tryParse(data['cpsSituationNumber'] ?? '');
    if (widget.prefillCps || widget.initial == null) {
      applyCabinet();
      final linkedSituation =
          (cabinet?['membership'] as Map?)?['cps_situation_number'] as int?;
      if (linkedSituation != null &&
          (widget.cps?.profile.situations.any(
                (s) => s.number == linkedSituation,
              ) ??
              false)) {
        applyCps(linkedSituation);
      } else if (widget.cps?.profile.situations.length == 1) {
        applyCps(widget.cps!.profile.situations.single.number);
      }
    }
  }

  void applyCps(int number) {
    final cps = widget.cps!;
    // Do not carry declared complements from a different card/situation.
    if (data['cpsProfileHash'] != cps.digest || situation != number) {
      data = {for (final f in DocumentMedicalService.contextFields) f: ''};
    }
    data.addAll(cps.contextValues(number));
    data.addAll(declaredDates.contextValues(number));
    applyCabinet();
    situation = number;
    formRevision++;
    error = '';
  }

  void applyCabinet() {
    if (cabinet != null) {
      data.addAll(CabinetPracticeService.contextValues(cabinet!));
    }
  }

  Future<void> editCabinet() async {
    setState(() => busy = true);
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CabinetPracticeScreen(
            service: CabinetPracticeService(
              database: widget.service.pdf.database,
            ),
          ),
        ),
      );
      final source = await CabinetPracticeService.forAuthor(
        await widget.service.pdf.database(),
        widget.practitioner,
      );
      if (mounted) {
        setState(() {
          cabinet = source;
          // Only an explicit prefill updates an existing version's declarations.
          formRevision++;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  bool locked(String field) =>
      (cabinet != null &&
          ['setting', 'facilityCode', 'facilityLabel'].contains(field) &&
          CabinetPracticeService.contextValues(cabinet!).containsKey(field)) ||
      (data['cpsProfileHash'] ?? '').isNotEmpty &&
          (const {
                'identifierType',
                'identifier',
                'authority',
                'professionCode',
                'professionSystem',
                'professionLabel',
                'familyName',
                'givenNames',
                'situation',
              }.contains(field) ||
              widget.cps != null &&
                  situation != null &&
                  widget.cps!.profile.situations.any(
                    (s) => s.number == situation,
                  ) &&
                  widget.cps!.contextValues(situation!).containsKey(field));

  Future<void> editDates() async {
    if (busy || widget.cps == null) return;
    setState(() => busy = true);
    try {
      final result = await showPractitionerCpsDatesDialog(
        context: context,
        service: PractitionerCpsService(database: widget.service.pdf.database),
        practitionerId: widget.practitioner,
        reading: widget.cps!,
      );
      if (result != null && mounted) {
        setState(() {
          declaredDates = result;
          if (situation != null) applyCps(situation!);
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      final row = await widget.service.saveContext(
        id: widget.initial?['context_id'] as String?,
        practitionerId: widget.practitioner,
        data: data,
        expectedRevision: widget.initial?['revision'] as int? ?? 0,
      );
      if (mounted) Navigator.pop(context, row);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Situation d’exercice du kiné'),
    content: SizedBox(
      width: 600,
      height: 520,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              key: ValueKey(formRevision),
              children: [
                const Text(
                  'Les données issues de la CPS sont conservées avec leur provenance. Les champs absents de la carte restent à compléter. Cette préparation ne signe ni ne valide le rapport.',
                ),
                const SizedBox(height: 12),
                Text(
                  'Cabinet du rédacteur',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (cabinet == null)
                  const Text('Aucun rattachement actif au cabinet configuré.')
                else ...[
                  Text(
                    '${(cabinet!['identity'] as Map)['cabinet_name']} · ${(cabinet!['membership'] as Map)['role']}',
                  ),
                  Text(
                    'Début dans ce cabinet : ${OptionalCivilDateField.display((cabinet!['membership'] as Map)['start_date'] as String?)}',
                  ),
                  if (CabinetPracticeService.data(
                    cabinet!['cabinet'] as CabinetRow,
                  )['legalName']!.isNotEmpty)
                    Text(
                      'Entité juridique : ${CabinetPracticeService.data(cabinet!['cabinet'] as CabinetRow)['legalName']}',
                    ),
                  if (CabinetPracticeService.contextValues(
                    cabinet!,
                  ).entries.any((e) => data[e.key] != e.value))
                    const Text(
                      'Les paramètres du cabinet ou le rattachement ont changé. Reprenez-les avant d’enregistrer cette situation.',
                    ),
                  OutlinedButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            applyCabinet();
                            formRevision++;
                          }),
                    child: const Text('Reprendre les paramètres du cabinet'),
                  ),
                ],
                TextButton(
                  onPressed: busy ? null : editCabinet,
                  child: const Text(
                    'Gérer le cabinet et le rattachement du rédacteur',
                  ),
                ),
                const Text(
                  'Le cabinet et son entité juridique sont indépendants de la structure indiquée par la CPS. Le nom et l’identifiant ci-dessous restent ceux de la situation professionnelle enregistrée.',
                ),
                const Divider(),
                if (widget.cps != null) ...[
                  Text(
                    'Lecture CPS enregistrée le ${widget.cps!.readAt.toLocal()} · aucune authentification active attestée.',
                  ),
                  DropdownButtonFormField<int>(
                    initialValue:
                        widget.cps!.profile.situations.any(
                          (s) => s.number == situation,
                        )
                        ? situation
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText:
                          'Préremplir avec une situation de la CPS enregistrée',
                    ),
                    items: [
                      for (final s in widget.cps!.profile.situations)
                        DropdownMenuItem(
                          value: s.number,
                          child: Text(
                            'Situation ${s.number} · ${s.structureName ?? 'structure non renseignée'}',
                          ),
                        ),
                    ],
                    onChanged: busy
                        ? null
                        : (value) {
                            if (value != null) setState(() => applyCps(value));
                          },
                  ),
                  for (final s in widget.cps!.profile.situations.where(
                    (s) => s.number == situation,
                  ))
                    Text(
                      'Données de la carte : mode ${s.mode} · statut ${s.status} · secteur ${s.sector ?? 'absent'}. Cadre d’exercice à confirmer ; dates déclarées facultatives.',
                    ),
                  Text(
                    'Émission de la CPS — date déclarée : ${OptionalCivilDateField.display(data['cpsIssueDate'])}',
                  ),
                  OutlinedButton.icon(
                    onPressed: busy ? null : editDates,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Compléter les dates sans lire la CPS'),
                  ),
                  const Text(
                    'Les dates sont enregistrées dans la fiche du kiné. Une date inconnue peut rester vide. Elles ne remplacent pas les contrôles des certificats CPS.',
                  ),
                  if ((data['cpsProfileHash'] ?? '').isNotEmpty &&
                      data['cpsProfileHash'] != widget.cps!.digest)
                    const Text(
                      'La lecture CPS a changé. Sélectionnez à nouveau une situation pour actualiser ce contexte.',
                    ),
                  if (declaredDates.revision > 0 &&
                      data['cpsDatesRevision'] != '${declaredDates.revision}')
                    const Text(
                      'Les dates déclarées ont changé. Sélectionnez à nouveau la situation pour les reprendre.',
                    ),
                ],
                for (final f in labels.entries)
                  if (f.key == 'validFrom')
                    OptionalCivilDateField(
                      label: f.value,
                      value: (data[f.key] ?? '').isEmpty
                          ? null
                          : data[f.key]!.substring(0, 10),
                      enabled: !busy && widget.cps == null,
                      onChanged: (value) =>
                          setState(() => data[f.key] = value ?? ''),
                    )
                  else if (f.key == 'structureType')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DropdownButtonFormField<String>(
                        key: const Key('practice-structureType'),
                        initialValue:
                            DocumentMedicalService.structureTypeLabels
                                .containsKey(data[f.key])
                            ? data[f.key]
                            : null,
                        decoration: InputDecoration(labelText: f.value),
                        items: [
                          for (final entry
                              in DocumentMedicalService
                                  .structureTypeLabels
                                  .entries)
                            DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                        ],
                        onChanged: busy
                            ? null
                            : (value) => setState(() {
                                data[f.key] = value ?? '';
                                error = '';
                              }),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        key: Key('practice-${f.key}'),
                        initialValue: data[f.key],
                        enabled: !busy && !locked(f.key),
                        decoration: InputDecoration(labelText: f.value),
                        onChanged: (v) => data[f.key] = v,
                      ),
                    ),
              ],
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  error,
                  key: const Key('practice-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        key: const Key('save-practice'),
        onPressed: busy ? null : save,
        child: const Text('Enregistrer la situation'),
      ),
    ],
  );
}
