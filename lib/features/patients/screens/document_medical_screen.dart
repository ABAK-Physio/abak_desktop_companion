import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/episode_document_version.dart';
import '../services/document_medical_service.dart';
import '../services/document_controls_service.dart';
import 'document_controls_panel.dart';
import 'document_journal_panel.dart';
import '../services/document_journal_service.dart';
import '../services/document_reconciliation_service.dart';
import '../../practitioners/data/practitioner_cps_service.dart';
import '../../practitioners/widgets/practitioner_cps_dialog.dart';
import '../../practitioners/widgets/practitioner_situation_dialog.dart';
import '../../documents/services/initial_report_document_service.dart';
import '../../../core/settings/cabinet_practice_service.dart';
import '../../../core/settings/report_prefill_settings.dart';
import '../../organization/cabinet_practice_screen.dart';
import '../../organization/cabinet_report_defaults_dialog.dart';
import '../../practitioners/practitioner_report_settings_screen.dart';

/// Product route, opened from the existing episode Documents screen.
class DocumentMedicalScreen extends StatefulWidget {
  const DocumentMedicalScreen({
    super.key,
    required this.version,
    required this.service,
    this.controls,
    this.reconciliation,
    this.pickArchive,
  });
  final EpisodeDocumentVersion version;
  final DocumentMedicalService service;
  final DocumentControlsService? controls;
  final DocumentReconciliationService? reconciliation;
  final DocumentArchivePicker? pickArchive;
  @override
  State<DocumentMedicalScreen> createState() => _DocumentMedicalScreenState();
}

class _DocumentMedicalScreenState extends State<DocumentMedicalScreen>
    with WidgetsBindingObserver {
  bool busy = true,
      dirty = false,
      clinical = false,
      patient = false,
      actor = false,
      renderError = false;
  bool signingBusy = false;
  bool editClassification = false;
  int? _step = 0;
  late final DocumentControlsService controls =
      widget.controls ?? DocumentControlsService(medical: widget.service);
  late final DocumentJournalService journal = DocumentJournalService(
    controls: controls,
  );
  String message = '';
  int revision = 0, page = 0;
  int formRevision = 0;
  Map<String, String> prefillSources = {};
  List<String> prefillNotes = [];
  Map<String, String> draft = {
    for (final f in DocumentMedicalService.preparationFields) f: '',
  };
  List<MedicalRow> people = [], contexts = [], receipts = [];
  MedicalRow? information;
  PractitionerCpsReading? authorCps;
  MedicalStatus? status;
  MedicalReview? review;
  Set<int> reviewed = {};
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !busy) {
      refreshStatus();
    }
  }

  Future<void> refreshStatus() async {
    try {
      final result = await widget.service.status(widget.version);
      final history = await widget.service.history(widget.version.id);
      final candidate = review;
      final current =
          candidate == null || await widget.service.reviewIsCurrent(candidate);
      if (mounted) {
        setState(() {
          status = result;
          receipts = history;
          if (!current && review == candidate) {
            review = null;
            reviewed = {};
            message =
                'Le contexte a changé : une nouvelle revue est nécessaire.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          status = null;
          message = 'Vérification indisponible : $e';
          review = null;
        });
      }
    }
  }

  Future<void> load() async {
    try {
      final p = await widget.service.practitioners();
      final info = await widget.service.information(widget.version);
      final prep = await widget.service.preparation(widget.version.id);
      var d = prep == null
          ? Map<String, String>.from(draft)
          : Map<String, String>.from(jsonDecode(prep['data_json'] as String));
      MedicalPrefill? proposed;
      if (prep == null && !dirty) {
        proposed = await widget.service.prefill(widget.version, d);
        d = proposed.values;
      }
      final cps = d['authorId']!.isEmpty
          ? null
          : await widget.service.cpsInformation(d['authorId']!);
      final c = d['authorId']!.isEmpty
          ? <MedicalRow>[]
          : await widget.service.contexts(d['authorId']!);
      final st = await widget.service.status(widget.version);
      final h = await widget.service.history(widget.version.id);
      if (mounted) {
        setState(() {
          people = p;
          information = info;
          authorCps = cps == null
              ? null
              : PractitionerCpsReading.fromStored(cps);
          draft = d;
          prefillSources = proposed?.sources ?? {};
          prefillNotes = proposed?.notes ?? [];
          formRevision++;
          contexts = c;
          revision = prep?['revision'] as int? ?? 0;
          status = st;
          receipts = h;
          busy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          busy = false;
          message = e.toString();
        });
      }
    }
  }

  void changed(String key, String value) {
    setState(() {
      draft[key] = value;
      if (ReportPrefillSettings.classificationFields.contains(key)) {
        draft.remove('catalogIdentification');
      }
      prefillSources.remove(key);
      dirty = true;
      review = null;
      reviewed = {};
      clinical = false;
      patient = false;
      actor = false;
    });
  }

  Future<void> completeEmptyFields() => action(_completeEmptyFields);
  Future<void> _completeEmptyFields() async {
    final result = await widget.service.prefill(widget.version, draft);
    final list = result.values['authorId']!.isEmpty
        ? <MedicalRow>[]
        : await widget.service.contexts(result.values['authorId']!);
    final cps = result.values['authorId']!.isEmpty
        ? null
        : await widget.service.cpsInformation(result.values['authorId']!);
    if (!mounted) return;
    setState(() {
      final updated = result.values.entries.any((e) => draft[e.key] != e.value);
      draft = result.values;
      contexts = list;
      authorCps = cps == null ? null : PractitionerCpsReading.fromStored(cps);
      prefillSources.addAll(result.sources);
      prefillNotes = result.notes;
      formRevision++;
      if (updated) {
        dirty = true;
        review = null;
        reviewed = {};
        clinical = false;
        patient = false;
        actor = false;
      }
      message = updated
          ? 'Champs vides complétés. Vérifiez les propositions puis enregistrez le contexte.'
          : 'Aucun champ existant remplacé. Les informations manquantes restent à compléter.';
    });
  }

  Future<void> settings({required bool practitioner}) => action(() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => practitioner
            ? PractitionerReportSettingsScreen(
                practitionerId: draft['authorId']!,
                name:
                    people
                        .where((p) => p['practitioner_id'] == draft['authorId'])
                        .map(personLabel)
                        .firstOrNull ??
                    'Kiné',
                service: widget.service,
              )
            : CabinetPracticeScreen(
                service: CabinetPracticeService(
                  database: widget.service.pdf.database,
                ),
              ),
      ),
    );
    if (!mounted) return;
    final list = draft['authorId']!.isEmpty
        ? <MedicalRow>[]
        : await widget.service.contexts(draft['authorId']!);
    if (!mounted) return;
    setState(() {
      contexts = list;
      message =
          'Paramètres consultés. « Compléter les champs vides » reprend les nouvelles préférences sans remplacer vos saisies.';
    });
    await refreshStatus();
  });

  Future<void> configureClassification() => action(() async {
    final db = await widget.service.pdf.database();
    final cabinetId = await db.transaction(
      ReportPrefillSettings.configuredCabinetId,
    );
    if (cabinetId == null) {
      throw StateError(
        'Enregistrez d’abord le cabinet avec le bouton « Paramètres du cabinet ».',
      );
    }
    if (!mounted) return;
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => CabinetReportDefaultsDialog(
        database: widget.service.pdf.database,
        cabinetId: cabinetId,
      ),
    );
    if (saved == true && mounted) await _completeEmptyFields();
  });

  Future<void> action(Future<void> Function() run) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await run();
    } catch (e) {
      if (mounted) {
        setState(() {
          message = e.toString();
          review = null;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() => action(() async {
    final saved = await widget.service.savePreparation(
      widget.version,
      draft,
      expectedRevision: revision,
    );
    if (mounted) {
      setState(() {
        revision = saved['revision'] as int;
        draft = Map<String, String>.from(
          jsonDecode(saved['data_json'] as String),
        );
        formRevision++;
        dirty = false;
        review = null;
        message = 'Contexte enregistré. Une revue du PDF est nécessaire.';
        _step = 1;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Contexte enregistré')));
    }
    await refreshStatus();
    receipts = await widget.service.history(widget.version.id);
  });
  Future<void> consultPdf() => action(() async {
    final file = await widget.service.pdf.previewFile(widget.version);
    await const InitialReportDocumentService().open(file.path);
    if (mounted) {
      setState(() {
        message =
            'Consultation simple du PDF demandée. La version conservée et les confirmations de validation restent inchangées.';
      });
    }
  });
  Future<void> examine() => action(() async {
    final result = await widget.service.review(widget.version);
    if (mounted) {
      setState(() {
        review = result;
        reviewed = {};
        clinical = false;
        patient = false;
        actor = false;
        page = 0;
        renderError = false;
        message = 'Examinez toutes les pages de cette version.';
        _step = 1;
      });
    }
  });
  Future<void> approve() => action(() async {
    final candidate = review!;
    final isRecipe = candidate.snapshot['cndaRecipe'] != null;
    final name = (candidate.snapshot['validator'] as Map)['display_name'];
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isRecipe
              ? 'Enregistrer une validation médicale de test ?'
              : 'Valider médicalement cette version ?',
        ),
        content: Text(
          '${isRecipe ? 'Patient fictif CNDA — validation de test uniquement, sans qualification INS.\n' : ''}'
          'Validateur déclaré : $name.\nPDF version ${widget.version.number}, ${candidate.pages.length} page(s).\nCette décision concerne le PDF et le contexte examinés. Elle ne signe ni n’envoie le document.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('confirm-medical-approval'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isRecipe
                  ? 'Confirmer la validation médicale de test'
                  : 'Confirmer la validation médicale',
            ),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    await widget.service.approve(
      candidate,
      reviewedPages: reviewed,
      clinicalContent: clinical,
      correctPatient: patient,
      actingAsValidator: actor,
    );
    await refreshStatus();
    receipts = await widget.service.history(widget.version.id);
    if (mounted) {
      setState(() {
        message = isRecipe
            ? 'Validation médicale de test enregistrée — patient fictif CNDA. Le dépôt DV1 nécessite des contrôles conformes et une confirmation distincte.'
            : 'Validation médicale enregistrée pour cette version et ce contexte.';
        review = null;
      });
    }
  });
  Future<void> importAuthorCps() async {
    String? imported;
    await action(() async {
      final reportAuthor =
          (information?['report'] as Map?)?['author_practitioner_id']
              as String?;
      final target =
          reportAuthor ??
          (draft['authorId']!.isEmpty ? null : draft['authorId']);
      if (target != null) {
        await widget.service.checkReportAuthor(
          await widget.service.pdf.database(),
          widget.version,
          target,
        );
      }
      if (!mounted) return;
      imported = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PractitionerCpsDialog(
          service: PractitionerCpsService(
            database: widget.service.pdf.database,
          ),
          targetId: target,
          checkTarget: (db, id) =>
              widget.service.checkReportAuthor(db, widget.version, id),
        ),
      );
      if (imported == null || !mounted) return;
      final p = await widget.service.practitioners();
      final cps = await widget.service.cpsInformation(imported!);
      final c = await widget.service.contexts(imported!);
      if (!mounted) return;
      changed('authorId', imported!);
      changed('contextId', '');
      setState(() {
        people = p;
        contexts = c;
        authorCps = cps == null ? null : PractitionerCpsReading.fromStored(cps);
        message =
            'Fiche du kiné actualisée. Choisissez sa situation et complétez le contexte. Aucune validation médicale effectuée.';
      });
      await refreshStatus();
    });
    if (imported != null && mounted) await editContext(prefillCps: true);
  }

  Future<void> editContext({bool prefillCps = false}) => action(() async {
    final id = draft['contextId'];
    final selected = contexts.where((e) => e['context_id'] == id).firstOrNull;
    final cps = await widget.service.cpsInformation(draft['authorId']!);
    final cabinet = await CabinetPracticeService.forAuthor(
      await widget.service.pdf.database(),
      draft['authorId']!,
    );
    final dates = cps == null
        ? null
        : PractitionerCpsService.datesFromStored(
            PractitionerCpsReading.fromStored(cps),
            await widget.service.cpsDatesInformation(draft['authorId']!),
          );
    if (!mounted) return;
    final row = await showDialog<MedicalRow>(
      context: context,
      builder: (_) => PractitionerSituationDialog(
        service: widget.service,
        practitioner: draft['authorId']!,
        initial: selected,
        cps: cps == null ? null : PractitionerCpsReading.fromStored(cps),
        dates: dates,
        cabinet: cabinet,
        prefillCps: prefillCps,
      ),
    );
    if (row == null || !mounted) return;
    final list = await widget.service.contexts(draft['authorId']!);
    if (mounted) {
      setState(() {
        contexts = list;
        draft['contextId'] = row['context_id'] as String;
        dirty = true;
        review = null;
        message =
            'Contexte professionnel déclaré enregistré. Enregistrez la préparation documentaire.';
      });
    }
    await refreshStatus();
  });
  Widget field(String key, String label, {String? hint}) => KeyedSubtree(
    key: ValueKey('field-$key-$formRevision'),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: Key('medical-$key'),
        initialValue: draft[key],
        enabled: !busy,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: prefillSources[key],
          helperMaxLines: 3,
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) => changed(key, v),
      ),
    ),
  );
  Widget choice(
    String key,
    String label,
    Map<String, String> entries, {
    void Function(String)? after,
  }) => KeyedSubtree(
    key: ValueKey('selection-$key-${draft[key]}'),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        key: Key('medical-$key'),
        initialValue: entries.containsKey(draft[key]) ? draft[key] : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          helperText: prefillSources[key],
          helperMaxLines: 3,
          border: const OutlineInputBorder(),
        ),
        items: entries.entries
            .map(
              (e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: busy
            ? null
            : (v) {
                if (v != null) {
                  changed(key, v);
                  after?.call(v);
                }
              },
      ),
    ),
  );
  String personLabel(MedicalRow row) {
    final name = '${row['first_name'] ?? ''} ${row['last_name'] ?? ''}'.trim();
    final alias = row['display_name'] as String;
    return name.isEmpty || name == alias ? alias : '$name · $alias';
  }

  Future<void> catalogDetails({MedicalRow? receipt}) async {
    String details;
    if (receipt == null) {
      details = ReportPrefillSettings.catalogDetails(draft);
      if (revision == 0 || dirty) {
        details = 'Préparation non enregistrée dans cet état.\n\n$details';
      }
    } else {
      try {
        final snapshot = jsonDecode(receipt['snapshot_json'] as String) as Map;
        final captured =
            jsonDecode(snapshot['preparation']['data_json'] as String) as Map;
        details =
            'Identification figée lors de cette validation.\n\n${ReportPrefillSettings.catalogDetails(captured)}';
      } catch (_) {
        details =
            'L’identification de cette validation est illisible. Les paramètres actuels ne sont pas substitués à l’historique.';
      }
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Référentiels du classement — assistance'),
        content: SizedBox(
          width: 700,
          child: SingleChildScrollView(child: SelectableText(details)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  ExpansionPanel _validationStep(
    int index,
    String title,
    String subtitle,
    List<Widget> children, {
    bool done = false,
  }) => ExpansionPanel(
    isExpanded: _step == index,
    canTapOnHeader: true,
    headerBuilder: (context, expanded) => ListTile(
      leading: CircleAvatar(
        child: done ? const Icon(Icons.check) : Text('${index + 1}'),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    ),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = information?['patient'] as Map?;
    final i = information?['identity'] as Map?;
    final isRecipe = i?['cnda_recipe_json'] != null;
    final classified = ReportPrefillSettings.classificationFields.every(
      (key) => (draft[key] ?? '').trim().isNotEmpty,
    );
    final canApprove =
        !busy &&
        !dirty &&
        !renderError &&
        review != null &&
        reviewed.length == review!.pages.length &&
        clinical &&
        patient &&
        actor;
    return PopScope(
      canPop: !signingBusy,
      child: AbsorbPointer(
        absorbing: signingBusy,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Vérifier et valider le rapport'),
            actions: [
              IconButton(
                key: const Key('medical-refresh'),
                tooltip: 'Vérifier la validité',
                onPressed: busy ? null : refreshStatus,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (busy)
                    const LinearProgressIndicator(key: Key('medical-busy')),
                  Text(
                    'Version ${widget.version.number} · ${widget.version.pages} page(s)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    p == null
                        ? 'Dossier indisponible'
                        : 'Patient : ${p['first_name']} ${p['last_name']} · ${p['birth_date'] ?? 'date de naissance absente'}',
                  ),
                  Text(
                    i == null
                        ? 'Qualification de l’identité : aucune fiche enregistrée. Le nom et la date de naissance seuls ne constituent pas une identité qualifiée.'
                        : 'Statut d’identité : ${{'qualified': 'qualifiée', 'validated': 'validée', 'retrieved': 'récupérée', 'provisional': 'provisoire'}[i['identity_status']] ?? 'inconnu'} · consulté depuis la fiche patient, non modifiable ici',
                  ),
                  Text(
                    dirty
                        ? 'Modifications non enregistrées : revue et validation à reprendre.'
                        : status?.message ?? 'Préparation à compléter.',
                    key: const Key('medical-status'),
                  ),
                  if (isRecipe)
                    const Text(
                      'PATIENT FICTIF CNDA — la fiche reste provisoire. Après validation de test, les contrôles techniques et la signature préparent un dépôt sur DV1 uniquement, avec confirmation explicite.',
                    ),
                  if (message.isNotEmpty)
                    Semantics(
                      liveRegion: true,
                      child: Text(message, key: const Key('medical-message')),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    '1. Vérifier les informations → 2. Relire le PDF → 3. Confirmer',
                  ),
                  const SizedBox(height: 16),
                  ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.zero,
                    expansionCallback: (index, expanded) =>
                        setState(() => _step = expanded ? index : null),
                    children: [
                      _validationStep(
                        0,
                        'Vérifier les informations du rapport',
                        dirty
                            ? 'Modifications à enregistrer'
                            : revision > 0
                            ? 'Contexte enregistré'
                            : 'À compléter et enregistrer',
                        [
                          const SizedBox(height: 12),
                          const Text(
                            'Les champs proposés proviennent du rapport, du cabinet et de la fiche du rédacteur. Vérifiez notamment le titre et la date avec le PDF retouché. Aucune validation n’est automatique.',
                          ),
                          Wrap(
                            spacing: 12,
                            children: [
                              OutlinedButton(
                                onPressed: busy ? null : completeEmptyFields,
                                child: const Text('Compléter les champs vides'),
                              ),
                              TextButton(
                                onPressed: busy
                                    ? null
                                    : () => settings(practitioner: false),
                                child: const Text('Paramètres du cabinet'),
                              ),
                              TextButton(
                                onPressed: busy || draft['authorId']!.isEmpty
                                    ? null
                                    : () => settings(practitioner: true),
                                child: const Text('Paramètres du rédacteur'),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: const Text(
                              'Identité professionnelle et lecture CPS',
                            ),
                            children: [
                              const Text(
                                'Le contexte peut être préparé à partir d’une lecture CPS enregistrée. Celle-ci n’atteste pas une authentification active. Le classement et les compléments restent déclarés. Aucun envoi disponible depuis ce formulaire.',
                              ),
                              OutlinedButton.icon(
                                onPressed: busy ? null : importAuthorCps,
                                icon: const Icon(Icons.badge_outlined),
                                label: const Text(
                                  'Compléter l’auteur depuis sa CPS',
                                ),
                              ),
                              const Text(
                                'Aucune carte n’est lue à l’ouverture. La lecture demande une action explicite et le PIN ; l’enregistrement de la fiche demande confirmation.',
                              ),
                              if (authorCps != null) ...[
                                Text(
                                  'Données CPS locales : ${authorCps!.profile.givenName} ${authorCps!.profile.familyName} · ${authorCps!.profile.nationalId}',
                                ),
                                Text(
                                  'Lecture du ${authorCps!.readAt.toLocal()} · session carte fermée.',
                                ),
                              ],
                            ],
                          ),
                          for (final note in prefillNotes) Text(note),
                          const SizedBox(height: 16),
                          if (people.isEmpty)
                            const Text(
                              'Aucun professionnel actif. Complétez l’annuaire des praticiens avant de préparer cette version.',
                            ),
                          choice(
                            'authorId',
                            'Auteur du document',
                            {
                              for (final r in people)
                                r['practitioner_id'] as String: personLabel(r),
                            },
                            after: (v) => action(() async {
                              changed('contextId', '');
                              changed('validatorId', '');
                              final list = await widget.service.contexts(v);
                              final cps = await widget.service.cpsInformation(
                                v,
                              );
                              if (mounted && draft['authorId'] == v) {
                                setState(() {
                                  contexts = list;
                                  authorCps = cps == null
                                      ? null
                                      : PractitionerCpsReading.fromStored(cps);
                                });
                              }
                              if (mounted && draft['authorId'] == v) {
                                await _completeEmptyFields();
                              }
                            }),
                          ),
                          choice(
                            'validatorId',
                            'Professionnel qui valide médicalement',
                            {
                              for (final r in people)
                                r['practitioner_id'] as String: personLabel(r),
                            },
                          ),
                          choice(
                            'contextId',
                            'Situation d’exercice de l’auteur',
                            {
                              for (final r in contexts)
                                r['context_id'] as String:
                                    '${jsonDecode(r['data_json'] as String)['situation']} · ${jsonDecode(r['data_json'] as String)['structureName']}',
                            },
                          ),
                          Wrap(
                            spacing: 12,
                            children: [
                              OutlinedButton(
                                key: const Key('medical-practice'),
                                onPressed: busy || draft['authorId']!.isEmpty
                                    ? null
                                    : editContext,
                                child: Text(
                                  draft['contextId']!.isEmpty
                                      ? 'Compléter la situation d’exercice'
                                      : 'Examiner ou modifier cette situation',
                                ),
                              ),
                              if (draft['contextId']!.isNotEmpty)
                                TextButton(
                                  onPressed: busy
                                      ? null
                                      : () {
                                          changed('contextId', '');
                                          editContext();
                                        },
                                  child: const Text('Nouvelle situation'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          field('title', 'Titre clinique du document'),
                          field(
                            'clinicalDate',
                            'Date et heure cliniques avec fuseau',
                            hint: 'AAAA-MM-JJThh:mm:ss+02:00',
                          ),
                          field('language', 'Langue', hint: 'fr-FR'),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Classement documentaire déclaré',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const Text(
                                    'Le classement dépend du type de rapport, indépendamment du rédacteur et du signataire. Enregistrez-le une fois dans les paramètres communs du cabinet.',
                                  ),
                                  const SizedBox(height: 8),
                                  if (classified) ...[
                                    Text('Type : ${draft['typeLabel']}'),
                                    Text('Classe : ${draft['classLabel']}'),
                                    Text(
                                      revision > 0 && !dirty
                                          ? 'Classement conservé pour cette version du PDF.'
                                          : 'Classement proposé pour cette version, à enregistrer avec le contexte.',
                                    ),
                                  ] else
                                    const Text(
                                      'Classement incomplet : choisissez le classement habituel dans les paramètres communs.',
                                    ),
                                  TextButton.icon(
                                    onPressed: busy
                                        ? null
                                        : configureClassification,
                                    icon: const Icon(Icons.settings_outlined),
                                    label: const Text(
                                      'Paramètres du classement commun',
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed:
                                        busy ||
                                            (draft['catalogReference'] ?? '')
                                                .isEmpty
                                        ? null
                                        : () => catalogDetails(),
                                    icon: const Icon(Icons.info_outline),
                                    label: const Text(
                                      'Référentiels de cette préparation — assistance',
                                    ),
                                  ),
                                  const Text(
                                    'Les changements des paramètres communs ne remplacent pas les valeurs déjà saisies ou enregistrées dans un rapport.',
                                  ),
                                  ExpansionTile(
                                    title: const Text('Détails du classement'),
                                    children: [
                                      for (final key
                                          in ReportPrefillSettings
                                              .classificationFields)
                                        if (editClassification)
                                          field(
                                            key,
                                            DocumentMedicalService
                                                .fieldLabels[key]!,
                                          )
                                        else
                                          ListTile(
                                            dense: true,
                                            title: Text(
                                              DocumentMedicalService
                                                  .fieldLabels[key]!,
                                            ),
                                            subtitle: SelectableText(
                                              (draft[key] ?? '').isEmpty
                                                  ? 'Non renseigné'
                                                  : draft[key]!,
                                            ),
                                          ),
                                      if (!editClassification)
                                        TextButton(
                                          onPressed: busy
                                              ? null
                                              : () => setState(
                                                  () =>
                                                      editClassification = true,
                                                ),
                                          child: const Text(
                                            'Adapter uniquement pour ce document',
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          choice('patientVisibility', 'Visibilité au patient', {
                            'visible': 'Visible',
                            'invisible': 'Invisible',
                          }),
                          choice(
                            'representativesVisibility',
                            'Visibilité aux représentants légaux',
                            {
                              'visible': 'Visible',
                              'invisible': 'Invisible',
                              'sans objet': 'Sans objet',
                            },
                          ),
                          choice(
                            'professionalVisibility',
                            'Visibilité aux professionnels',
                            {'visible': 'Visible', 'masqué': 'Masqué'},
                          ),
                          const Text(
                            'Les visibilités proposées restent modifiables et doivent être vérifiées pour ce rapport. '
                            'Les choix déjà saisis ou enregistrés sont conservés. '
                            'Ces choix documentaires ne créent aucun droit d’accès ni connexion secrète.',
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Vérifiez les valeurs proposées, puis enregistrez-les pour passer à la relecture du PDF.',
                          ),
                          FilledButton(
                            key: const Key('save-medical-context'),
                            onPressed: busy ? null : save,
                            child: const Text(
                              'Enregistrer le contexte de cette version',
                            ),
                          ),
                        ],
                        done: revision > 0 && !dirty,
                      ),
                      _validationStep(
                        1,
                        'Relire toutes les pages du PDF',
                        review == null
                            ? 'Revue à commencer'
                            : '${reviewed.length} / ${review!.pages.length} page(s) examinée(s)',
                        [
                          OutlinedButton.icon(
                            key: const Key('consult-medical-pdf'),
                            onPressed: busy ? null : consultPdf,
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: const Text(
                              'Consulter le PDF — sans validation',
                            ),
                          ),
                          const Text(
                            'Ouvre une copie de consultation, même si l’identité ou le contexte reste à compléter. Cette consultation ne remplace pas la revue médicale.',
                          ),
                          OutlinedButton(
                            key: const Key('review-medical-pdf'),
                            onPressed:
                                busy ||
                                    dirty ||
                                    revision == 0 ||
                                    status?.canReview != true
                                ? null
                                : examine,
                            child: const Text(
                              'Examiner le PDF avant validation',
                            ),
                          ),
                          if (!busy && !dirty && status?.canReview != true)
                            Text(
                              'Revue médicale indisponible : ${status?.message ?? 'contexte à compléter.'}',
                            ),
                          if (dirty || revision == 0)
                            const Text(
                              'Enregistrez le contexte de cette version avant de commencer la revue médicale.',
                            ),
                          if (review != null) ...[
                            Text(
                              'Page ${page + 1} sur ${review!.pages.length}',
                            ),
                            SizedBox(
                              height: 460,
                              child: Image.memory(
                                review!.pages[page].png,
                                fit: BoxFit.contain,
                                errorBuilder: (_, e, st) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted && !renderError) {
                                      setState(() => renderError = true);
                                    }
                                  });
                                  return const Text(
                                    'Aperçu illisible : validation bloquée.',
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  key: const Key('medical-previous'),
                                  onPressed: busy || page == 0
                                      ? null
                                      : () => setState(() => page--),
                                  child: const Text('Page précédente'),
                                ),
                                TextButton(
                                  key: const Key('medical-next'),
                                  onPressed:
                                      busy || page + 1 >= review!.pages.length
                                      ? null
                                      : () => setState(() => page++),
                                  child: const Text('Page suivante'),
                                ),
                              ],
                            ),
                            CheckboxListTile(
                              key: const Key('medical-page-reviewed'),
                              value: reviewed.contains(page),
                              onChanged: busy || renderError
                                  ? null
                                  : (v) => setState(() {
                                      v == true
                                          ? reviewed.add(page)
                                          : reviewed.remove(page);
                                    }),
                              title: const Text('J’ai examiné cette page'),
                            ),
                          ],
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed:
                                busy ||
                                    dirty ||
                                    renderError ||
                                    review == null ||
                                    reviewed.length != review!.pages.length
                                ? null
                                : () => setState(() => _step = 2),
                            child: const Text(
                              'Continuer vers les confirmations',
                            ),
                          ),
                        ],
                        done:
                            !dirty &&
                            !renderError &&
                            review != null &&
                            reviewed.length == review!.pages.length,
                      ),
                      _validationStep(
                        2,
                        isRecipe
                            ? 'Confirmer la validation de test'
                            : 'Confirmer la validation médicale',
                        !dirty &&
                                (status?.valid == true ||
                                    status?.state == 'test_approved')
                            ? 'Validation enregistrée'
                            : 'Confirmation explicite requise',
                        [
                          const Text(
                            'La validation porte sur cette version du PDF. Elle ne signe pas le document et ne l’envoie pas.',
                          ),
                          if (review == null ||
                              dirty ||
                              renderError ||
                              reviewed.length != review!.pages.length)
                            const Text(
                              'Terminez d’abord la revue des pages à l’étape 2.',
                            ),
                          if (review != null) ...[
                            CheckboxListTile(
                              key: const Key('medical-clinical'),
                              value: clinical,
                              onChanged: busy
                                  ? null
                                  : (v) => setState(() => clinical = v == true),
                              title: const Text(
                                'Le contenu clinique est complet et correct',
                              ),
                            ),
                            CheckboxListTile(
                              key: const Key('medical-patient'),
                              value: patient,
                              onChanged: busy
                                  ? null
                                  : (v) => setState(() => patient = v == true),
                              title: const Text(
                                'Le PDF correspond au patient et à cet épisode',
                              ),
                            ),
                            CheckboxListTile(
                              key: const Key('medical-actor'),
                              value: actor,
                              onChanged: busy
                                  ? null
                                  : (v) => setState(() => actor = v == true),
                              title: const Text(
                                'Je suis le professionnel sélectionné pour cette validation',
                              ),
                            ),
                          ],
                          FilledButton(
                            key: const Key('approve-medical-pdf'),
                            onPressed: canApprove ? approve : null,
                            child: Text(
                              isRecipe
                                  ? 'Valider médicalement cette version — test CNDA'
                                  : 'Valider médicalement cette version',
                            ),
                          ),
                        ],
                        done:
                            !dirty &&
                            (status?.valid == true ||
                                status?.state == 'test_approved'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ExpansionTile(
                    maintainState: true,
                    title: const Text('Contrôles techniques du document'),
                    subtitle: const Text(
                      'Étape distincte de la validation médicale',
                    ),
                    children: [
                      DocumentControlsPanel(
                        service: controls,
                        version: widget.version,
                        enabled:
                            !busy &&
                            !dirty &&
                            (status?.valid == true ||
                                status?.state == 'test_approved'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    maintainState: true,
                    title: const Text('Signature, recette DMP et suivi'),
                    subtitle: const Text(
                      'Actions distinctes, à ouvrir si nécessaire',
                    ),
                    children: [
                      DocumentJournalPanel(
                        service: journal,
                        reconciliation: widget.reconciliation,
                        pickArchive: widget.pickArchive,
                        version: widget.version,
                        enabled: !busy && !dirty,
                        onSigningBusy: (value) {
                          if (mounted) setState(() => signingBusy = value);
                        },
                      ),
                    ],
                  ),
                  if (receipts.isNotEmpty)
                    ExpansionTile(
                      title: const Text('Historique des validations'),
                      children: receipts
                          .map(
                            (r) => ListTile(
                              title: Text(
                                '${(jsonDecode(r['snapshot_json'] as String) as Map)['cndaRecipe'] != null ? 'Validation médicale de test CNDA' : 'Validation'} '
                                '${r['invalidation_reason'] == null ? 'enregistrée' : 'invalidée'}',
                              ),
                              subtitle: Text(
                                '${DateTime.fromMillisecondsSinceEpoch(r['approved_at'] as int).toLocal()} · ${r['invalidation_reason'] ?? 'La validité courante est indiquée en haut de l’écran.'}',
                              ),
                              trailing: IconButton(
                                tooltip:
                                    'Consulter les référentiels conservés lors de cette validation',
                                icon: const Icon(Icons.info_outline),
                                onPressed: busy
                                    ? null
                                    : () => catalogDetails(receipt: r),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
