import 'tls050_screen.dart';
import 'case1_withdrawal_recipe.dart';
import 'case1_authorization_recipe.dart';
import 'nia_injection.dart';
import '../dmp_td02/access_identity.dart';
import 'blocked_authorization_recipe.dart';
import 'expired_authorization_recipe.dart';
import 'platform_support.dart';
import 'visibility_recipe.dart';
import '../dmp_td02/patient_person.dart';
import '../dmp_td02/patient_person_panel.dart';
import 'consultation_viewer.dart';
import 'preparation_error.dart';
import '../patients/services/dmp_chain/native/td31_submission.dart';
import 'consultation_recipe.dart';
import '../dmp_resources/nos_import.dart';
import '../patients/services/dmp_chain/native/td31a.dart';
import 'depublication.dart';
import 'package:file_picker/file_picker.dart';
import 'search_targets.dart';
import '../dmp_session/dmp_work_context.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../patients/screens/document_dv1_panel.dart';
import '../patients/services/document_controls_service.dart';
import '../patients/services/document_journal_service.dart';
import '../patients/services/document_medical_service.dart';
import '../patients/services/final_pdf_document_service.dart';
import '../patients/services/dmp_chain/native/access_context.dart';
import '../patients/services/dmp_chain/native/dv1_configuration.dart';
import 'access_service.dart';
import '../dmp_resources/dmp_resources.dart';

class Dv1AccessScreen extends StatefulWidget {
  const Dv1AccessScreen({super.key, this.searchVersionId});

  /// Local navigation only; never starts a CPS session or a query.
  final String? searchVersionId;
  @override
  State<Dv1AccessScreen> createState() => _Dv1AccessScreenState();
}

class _Dv1AccessScreenState extends State<Dv1AccessScreen> {
  late final journal = DocumentJournalService(
    controls: DocumentControlsService(
      medical: DocumentMedicalService(pdf: FinalPdfDocumentService()),
    ),
  );
  late final settings = Dv1ConfigurationService(journal);
  late final service = Dv1AccessService(journal);
  final fields = {
    for (final k in [
      'patient',
      'ins',
      'source',
      'scenario',
      'structure',
      'until',
      'birth',
      'typeCode',
      'typeSystem',
      'submissionFrom',
      'submissionTo',
    ])
      k: TextEditingController(),
  };
  bool _case1InitialReady = false, _case1ConsentRecorded = false;
  bool _case1WithdrawalReady = false;
  bool _case1TestWithdrawalReady = false;
  String? _case1AdditionEvidenceId;
  bool _niaAction = false;
  Dv1NiaEvidence? niaEvidence;
  Dv1Configuration? config;
  bool busy = false, replacement = false;
  String message = '';
  DmpPatientPerson? patientPerson;
  int identityGeneration = 0;

  bool get case1WithdrawalSelected => fields['scenario']!.text.trim() == Dv1Case1WithdrawalRecipe.scenario;

  bool get case1Selected => fields['scenario']!.text.trim() == Dv1Case1AuthorizationRecipe.scenario;

  void invalidateInputs() {
    _case1InitialReady = false;
    _case1ConsentRecorded = false;
    _case1WithdrawalReady = false;
    _case1TestWithdrawalReady = false;
    clearPatientPerson();
  }

  void clearPatientPerson() {
    identityGeneration++;
    if (mounted) setState(() => patientPerson = null);
  }

  Map<String, String>? consultationTarget;
  Map<String, String>? visibilityTarget;
  List<Dv1SearchTarget> searchTargets = [];
  Dv1SearchTarget? searchTarget;
  bool includeArchived = false, includeDeprecated = false;
  bool _autoSelectScopedDeposit = true;
  String visibilityType = '46241-6';
  String searchStatus = '';
  Map<String, dynamic>? patientConsent;
  String consentStatus = 'Aucune réponse sélectionnée.';
  int consentRevision = 0;
  List<Map<String, dynamic>> history = [];
  @override
  void initState() {
    super.initState();
    fields['typeSystem']!.text = '2.16.840.1.113883.6.1';
    for (final field in fields.values) {
      field.addListener(invalidateInputs);
    }
    DmpWorkContext.current.changes.addListener(invalidateInputs);
    refresh();
  }

  @override
  void dispose() {
    DmpWorkContext.current.changes.removeListener(invalidateInputs);
    for (final f in fields.values) {
      f.removeListener(invalidateInputs);
      f.dispose();
    }
    super.dispose();
  }

  Future<void> importNiaResponse() async {
    if (busy) return;
    setState(() { busy = true; _niaAction = true; message = ''; });
    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['xml'],
        dialogTitle: 'Choisir TEST_NIA.xml du package CNDA',
      );
      final path = selection?.files.single.path;
      if (path == null || !mounted) return;
      final file = File(path);
      if (await file.length() > 65536) throw StateError('Fichier d’injection trop volumineux.');
      final evidence = await service.importNiaResponse(await file.readAsBytes());
      if (!mounted) return;
      final injection = evidence.injection;
      setState(() {
        niaEvidence = evidence;
        _autoSelectScopedDeposit = false;
        searchTarget = null; consultationTarget = null; visibilityTarget = null;
        replacement = false;
        fields['until']!.clear();
        fields['scenario']!.text = Dv1NiaInjection.scenario;
        fields['patient']!.text = injection.patient;
        fields['ins']!.text = injection.ins;
        fields['birth']!.text = injection.result.birthDate!;
        fields['source']!.text = Dv1NiaInjection.source;
        message = 'Réponse INSi injectée et conservée : ${injection.patient}, '
            'né le ${injection.result.birthDate}. Type NIA, OID ${injection.result.insOid}. '
            'Aucune CPS ni connexion réseau sollicitée.';
      });
      await refresh();
    } catch (e) {
      if (mounted) {
        setState(() => message = e is StateError
          ? e.message.toString() : 'Injection NIA impossible. Choisissez TEST_NIA.xml original.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> runNia() async {
    if (busy || config == null) return;
    setState(() { busy = true; _niaAction = true; message = ''; });
    try {
      clearPatientPerson();
      final result = await service.execute(
        configuration: config!,
        context: selectedContext(config!, allowBlockedNia: true),
        niaEvidence: niaEvidence,
        requestPin: () async => throw StateError('Aucun PIN pour un accès NIA interdit.'),
      );
      if (mounted) setState(() => message = '${result['message']}');
      await refresh();
    } catch (e) {
      if (mounted) {
        setState(() => message = e is StateError
          ? e.message.toString() : 'Blocage NIA non confirmé. Consultez les preuves locales.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> importHistoricalEvidence() async {
    setState(() => busy = true);
    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Choisir la preuve historique vérifiée',
      );
      final path = selection?.files.single.path;
      if (path == null || !mounted) return;
      final file = File(path);
      if (await file.length() > 1024 * 1024) {
        throw StateError('Archive historique trop volumineuse.');
      }
      final target = Dv1SearchTargets.decodeLegacy(await file.readAsBytes());
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Importer une preuve historique de recette ?'),
          content: Text(
            '${target.label}\n\n'
            'Dépôt accepté le 16/10/2026 via un lanceur technique externe. '
            'Le code du lieu de naissance de cet ancien essai était une hypothèse. '
            'Cette preuve sert uniquement à rechercher le document déjà déposé sur DV1. '
            'Elle ne valide pas le dépôt depuis Companion et ne modifie aucune fiche patient. '
            'L’import ne lance aucune connexion ni lecture de CPS.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Importer pour la recherche'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await Dv1SearchTargets(journal).importLegacy(file);
      await refresh();
      if (mounted) {
        setState(
          () => message =
              'Preuve historique importée. Sélectionnez-la dans les documents à rechercher. Aucun accès DV1 effectué.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => message =
              'Import impossible : sélectionnez le fichier de preuve historique vérifié, sans modification.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> refreshConsent() async {
    final revision = ++consentRevision;
    final professional = config?.professional;
    final ins = fields['ins']!.text.trim();
    if (mounted) {
      setState(() {
        patientConsent = null;
        consentStatus = 'Réponse du patient non renseignée.';
      });
    }
    if (professional == null || !RegExp(r'^\d{15}$').hasMatch(ins)) return;
    try {
      final value = await (await service.consents).latest(professional, ins);
      if (mounted && revision == consentRevision) {
        setState(() {
          patientConsent = value;
          consentStatus = value == null
              ? 'Aucune réponse enregistrée pour ce patient et ce praticien.'
              : '${value['granted'] == true ? 'Accord enregistré' : 'Refus enregistré — consultation bloquée'}'
                    '${value['pendingWithdrawal'] == true ? ' — retrait auprès du DMP non confirmé' : ''}'
                    ' · ${value['recordedAt']}';
        });
      }
    } catch (_) {
      if (mounted && revision == consentRevision) {
        setState(
          () => consentStatus =
              'Réponse enregistrée illisible. Consultation suspendue.',
        );
      }
    }
  }

  Future<void> prepareCase1Withdrawal() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final addition = await service.latestCase1Addition();
      if (!mounted) return;
      setState(() {
        _niaAction = false; niaEvidence = null;
        _autoSelectScopedDeposit = false;
        searchTarget = null; consultationTarget = null; visibilityTarget = null;
        replacement = false; fields['until']!.clear();
        fields['scenario']!.text = Dv1Case1WithdrawalRecipe.scenario;
        fields['patient']!.text = Dv1Case1AuthorizationRecipe.patient;
        fields['birth']!.text = Dv1Case1AuthorizationRecipe.birth;
        fields['ins']!.text = Dv1Case1AuthorizationRecipe.ins;
        fields['source']!.text = Dv1Case1WithdrawalRecipe.source;
        _case1TestWithdrawalReady = false;
        _case1AdditionEvidenceId = addition['id'] as String;
        message = '0.3-080 préparé sans connexion. Ajout 0.3-010 vérifié et relié : ${addition['id']}. Vérifiez la structure puis contrôlez le droit actuel.';
      });
      await refreshConsent();
    } catch (e) {
      if (mounted) {
        setState(() {
        _case1TestWithdrawalReady = false; _case1AdditionEvidenceId = null;
        message = dv1PreparationError(e, 'preuve de l’ajout 0.3-010');
      });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void prepareCase1Authorization() {
    if (busy) return;
    setState(() {
      _case1InitialReady = false; _case1ConsentRecorded = false; _case1WithdrawalReady = false;
      _niaAction = false; niaEvidence = null;
      _autoSelectScopedDeposit = false;
      searchTarget = null; consultationTarget = null; visibilityTarget = null;
      replacement = false; fields['until']!.clear();
      fields['scenario']!.text = Dv1Case1AuthorizationRecipe.scenario;
      fields['patient']!.text = Dv1Case1AuthorizationRecipe.patient;
      fields['birth']!.text = Dv1Case1AuthorizationRecipe.birth;
      fields['ins']!.text = Dv1Case1AuthorizationRecipe.ins;
      fields['source']!.text = Dv1Case1AuthorizationRecipe.source;
      message = 'Cas1 préparé sans connexion. Vérifiez la structure, puis lancez le contrôle initial TD0.2. Aucun droit modifié.';
    });
    refreshConsent();
  }

  void prepareExpiredAuthorizationCase() {
    if (busy) return;
    setState(() {
      _niaAction = false;
      niaEvidence = null;
      _autoSelectScopedDeposit = false;
      searchTarget = null;
      consultationTarget = null;
      visibilityTarget = null;
      replacement = false;
      fields['until']!.clear();
      fields['scenario']!.text = Dv1ExpiredAuthorizationRecipe.scenario;
      fields['patient']!.text = Dv1ExpiredAuthorizationRecipe.patient;
      fields['birth']!.text = Dv1ExpiredAuthorizationRecipe.birth;
      fields['ins']!.text = Dv1ExpiredAuthorizationRecipe.ins;
      fields['source']!.text = Dv1ExpiredAuthorizationRecipe.source;
      message = 'Cas 7 préparé : Simone SARTRE, née le 01/01/1995. '
          'Vérifiez la structure d’exercice ci-dessous. '
          'Aucune lecture CPS ni connexion déclenchée.';
    });
    refreshConsent();
  }

  void prepareBlockedAuthorizationCase() {
    if (busy) return;
    setState(() {
      _niaAction = false;
      niaEvidence = null;
      _autoSelectScopedDeposit = false;
      searchTarget = null;
      consultationTarget = null;
      visibilityTarget = null;
      replacement = false;
      fields['until']!.clear();
      fields['scenario']!.text = Dv1BlockedAuthorizationRecipe.scenario;
      fields['patient']!.text = Dv1BlockedAuthorizationRecipe.patient;
      fields['birth']!.text = Dv1BlockedAuthorizationRecipe.birth;
      fields['ins']!.text = Dv1BlockedAuthorizationRecipe.ins;
      fields['source']!.text = Dv1BlockedAuthorizationRecipe.source;
      message = 'Cas 6 préparé : Henri HUIT, né le 01/01/1989. '
          'Vérifiez la structure d’exercice ci-dessous. '
          'Aucune lecture CPS ni connexion déclenchée.';
    });
    refreshConsent();
  }

  void selectSearchTarget(Dv1SearchTarget target) {
    _niaAction = false;
    niaEvidence = null;
    searchTarget = target;
    fields['patient']!.text = target.data['patient']!;
    fields['ins']!.text = target.data['ins']!;
    fields['birth']!.text = target.data['birth']!;
    fields['source']!.text = target.data['source']!;
    fields['scenario']!.text = 'PRE_ALIM_RECH';
    final structure = target.suggestedStructure(config?.professional ?? '');
    if (!replacement &&
        fields['structure']!.text.trim().isEmpty &&
        structure != null) {
      fields['structure']!.text = structure;
    }
  }

  Future<void> refresh() async {
    try {
      final c = await settings.current();
      final h = await service.history();
      final documents = await Dv1SearchTargets(
        journal,
      ).list(versionId: widget.searchVersionId);
      if (mounted) {
        setState(() {
          if (config?.hash != c?.hash) { _case1InitialReady = false; _case1ConsentRecorded = false; _case1WithdrawalReady = false; _case1TestWithdrawalReady = false; }
          config = c;
          history = h;
          searchTargets = documents.targets;
          if (searchTarget != null &&
              !searchTargets.any((t) => t.id == searchTarget!.id)) {
            searchTarget = null;
          }
          // A scoped document entry may preselect one verified deposit only.
          // Multiple accepted attempts require an explicit choice.
          if (_autoSelectScopedDeposit &&
              widget.searchVersionId != null &&
              searchTarget == null &&
              searchTargets.length == 1) {
            selectSearchTarget(searchTargets.single);
          }
          searchStatus =
              '${documents.targets.length} dépôt(s) DV1 vérifiable(s). ${documents.excluded} tentative(s) non confirmée(s) ou preuve(s) incomplète(s) exclue(s).';
        });
        await refreshConsent();
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => message = 'Configuration ou historique local illisible.',
        );
      }
    }
  }

  Future<void> configure() async {
    invalidateInputs();
    setState(() => busy = true);
    try {
      final previous = await settings.current();
      if (!mounted) return;
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            Dv1SettingsDialog(service: settings, previous: previous),
      );
      await refresh();
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Impossible de charger la configuration DV1.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Dv1AccessContext selectedContext(Dv1Configuration configuration, {bool allowBlockedNia = false}) {
    final until = replacement
        ? DateTime.tryParse(fields['until']!.text.trim())
        : null;
    if (replacement &&
        (until == null ||
            !RegExp(
              r'(Z|[+-]\d{2}:\d{2})$',
            ).hasMatch(fields['until']!.text.trim()))) {
      throw StateError(
        'Indiquez une fin de remplacement avec fuseau, par exemple 2026-10-21T18:00:00+02:00.',
      );
    }
    final parameters = DmpParameters.parse(configuration.text('parameters'));
    final contextData = Dv1AccessContext(
      professional: configuration.professional,
      structure: fields['structure']!.text.trim(),
      sector: configuration.fields['situationSector'],
      ins: fields['ins']!.text.trim(),
      insOid: niaEvidence?.injection.result.insOid ?? DmpAccessIdentity.nirOid,
      patientLabel: fields['patient']!.text.trim(),
      source: fields['source']!.text.trim(),
      scenario: fields['scenario']!.text.trim(),
      confirmedAt: DateTime.now().toUtc(),
      replacementUntil: until?.toUtc(),
      birthDate: fields['birth']!.text.trim(),
      minorsEnabled: parameters.minors,
      majorityAge: parameters.majority,
    );
    if (!allowBlockedNia || contextData.insOid != DmpAccessIdentity.niaOid) {
      contextData.check(DateTime.now().toUtc());
    }
    return contextData;
  }

  Future<void> collectConsent() async {
    if (busy || config == null) return;
    setState(() => busy = true);
    bool withdraw = false;
    try {
      final decisionTicket = identityGeneration;
      final data = selectedContext(config!);
      final previous = await (await service.consents).latest(
        data.professional,
        data.ins,
      );
      if (!mounted) return;
      final answer = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PatientConsultationConsentDialog(
          patient: data.patientLabel,
          professional: data.professional,
          previous: previous,
          refusalWithdraws: data.scenario != Dv1Case1AuthorizationRecipe.scenario,
        ),
      );
      if (answer == null) return;
      await service.recordConsent(data, answer);
      await refreshConsent();
      withdraw = !answer && data.scenario != Dv1Case1AuthorizationRecipe.scenario;
      if (mounted) {
        setState(
          () => message = answer
              ? 'Accord enregistré. Cliquez sur « Demander la consultation du DMP » pour le prendre en compte sur DV1.'
              : 'Refus enregistré. Consultation bloquée. Retrait auprès du DMP à confirmer.',
        );
      }
      if (mounted && data.scenario == Dv1Case1AuthorizationRecipe.scenario) {
        setState(() {
          _case1ConsentRecorded = answer && decisionTicket == identityGeneration && case1Selected;
          message = answer
              ? 'Accord enregistré localement pour 0.3-010. L’ajout sur DV1 nécessite une action et une confirmation distinctes.'
              : 'Refus de l’ajout enregistré. Aucun ajout ni retrait effectué.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => message = e is StateError
              ? e.message.toString()
              : 'Réponse non enregistrée. Vérifiez les informations du patient.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
    // Immediate explicit withdrawal, with CPS confirmation. Cancellation leaves refusal pending.
    if (withdraw && mounted) await run(authorizationIntent: 'withdraw');
  }

  Future<void> run({
    String? authorizationIntent,
    bool search = false,
    bool depublication = false,
    bool preparatoryWithdrawal = false,
    bool criteriaSearch = false,
    bool submissionSearch = false,
    bool consult = false,
    bool visibility = false,
    bool visibilitySearch = false,
    bool visibilityIdentifiers = false,
  }) async {
    if (busy || config == null) return;
    if (niaEvidence != null || fields['scenario']!.text.trim() == Dv1NiaInjection.scenario) {
      await runNia();
      return;
    }
    clearPatientPerson();
    visibilitySearch = visibilitySearch || visibilityIdentifiers;
    setState(() {
      busy = true;
      message = '';
    });
    String? pin;
    var preparationStage = 'contexte du praticien';
    try {
      final configuration = config!;
      final checkWorkContext = DmpWorkContext.current.bind(
        configuration.professional,
      );
      if (search) {
        fields['scenario']!.text = depublication
            ? 'PRE_ALIM_SUPPR'
            : 'PRE_ALIM_RECH';
      }
      if (criteriaSearch) fields['scenario']!.text = 'PRE_CONS_RECH';
      if (submissionSearch) fields['scenario']!.text = 'PRE_CONS_SUB';
      if (consult) fields['scenario']!.text = 'PRE_CONS_CONS';
      if (visibility || visibilitySearch) {
        fields['scenario']!.text = 'PRE_CONS_INV';
      }
      if (visibility && !visibilitySelectionValid) {
        throw StateError('Sélectionnez un document invisible au patient.');
      }
      final consultTarget = consult && consultationSelectionValid
          ? consultationTarget
          : null;
      if (consult && consultTarget == null) {
        throw StateError(
          'Sélectionnez un document issu d’une recherche vérifiée.',
        );
      }
      preparationStage = 'dates et critères de recherche';
      final submissionPeriod = submissionSearch
          ? Dv1SubmissionPeriod.days(
              fields['submissionFrom']!.text.trim(),
              fields['submissionTo']!.text.trim(),
            )
          : null;
      submissionPeriod?.check();
      final criteria = visibilityIdentifiers
          ? Dv1VisibilityRecipe.identifierCriteria
          : visibilitySearch
          ? Dv1VisibilityRecipe.criteria(visibilityType)
          : criteriaSearch
          ? Dv1DocumentCriteria(
              archived: includeArchived,
              deprecated: includeDeprecated,
              typeCode: fields['typeCode']!.text.trim(),
              typeSystem: fields['typeSystem']!.text.trim(),
            )
          : null;
      criteria?.check();
      preparationStage = 'patient et paramètres DMP';
      var contextData = selectedContext(configuration);
      if (contextData.scenario == Dv1ExpiredAuthorizationRecipe.scenario) {
        Dv1ExpiredAuthorizationRecipe.checkInputs(
          scenario: contextData.scenario,
          patient: contextData.patientLabel,
          ins: contextData.ins,
          birth: contextData.birthDate ?? '',
          professional: contextData.professional,
        );
      }
      if (contextData.scenario == Dv1BlockedAuthorizationRecipe.scenario) {
        Dv1BlockedAuthorizationRecipe.checkInputs(
          scenario: contextData.scenario,
          patient: contextData.patientLabel,
          ins: contextData.ins,
          birth: contextData.birthDate ?? '',
          professional: contextData.professional,
        );
      }
      if (contextData.scenario == Dv1Case1AuthorizationRecipe.scenario) {
        Dv1Case1AuthorizationRecipe.checkInputs(
          scenario: contextData.scenario, patient: contextData.patientLabel, ins: contextData.ins,
          birth: contextData.birthDate ?? '', professional: contextData.professional,
        );
      }
      if (contextData.scenario == Dv1Case1WithdrawalRecipe.scenario) {
        Dv1Case1WithdrawalRecipe.checkInputs(
          scenario: contextData.scenario, patient: contextData.patientLabel, ins: contextData.ins,
          birth: contextData.birthDate ?? '', professional: contextData.professional,
        );
        if (_case1AdditionEvidenceId == null) throw StateError('Préparez 0.3-080 depuis la preuve de l’ajout réussi.');
      }
      if (visibility || visibilitySearch) {
        Dv1VisibilityRecipe.check(contextData);
      }
      if (criteria != null && !visibilitySearch) {
        Dv1ConsultationRecipe.check(contextData);
      }
      if (criteria != null ||
          submissionPeriod != null ||
          consult ||
          visibility) {
        preparationStage = 'lecture de l’accord de consultation';
        Dv1AccessService.requireSearchConsent(
          await (await service.consents).latest(
            contextData.professional,
            contextData.ins,
          ),
        );
      }
      if (visibility) {
        await service.verifyConsultationTarget(visibilityTarget!, contextData);
      }
      if (consultTarget != null) {
        await service.verifyConsultationTarget(consultTarget, contextData);
      }
      final target = search ? searchTarget : null;
      if (search && target == null) {
        throw StateError('Sélectionnez un dépôt confirmé.');
      }
      if (target != null) {
        target.checkContext(contextData);
        await Dv1SearchTargets(journal).verify(target);
      }
      preparationStage =
          'vérification de la configuration et des outils intégrés';
      await settings.unchanged(configuration);
      if (depublication) {
        await Dv1Depublication(journal).prepare(target!, contextData);
      }
      preparationStage = 'préparation du moteur et de l’authentification';
      final reuseAuthentication =
          !depublication &&
          await settings.canReuseAuthentication(configuration);
      checkWorkContext();
      if (!mounted) return;
      preparationStage = 'ouverture du dialogue de confirmation';
      final consent = await showDialog<({String pin, bool secret})>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _AccessConsent(
          contextData: contextData,
          reuseAuthentication: reuseAuthentication,
          preparatoryWithdrawal: preparatoryWithdrawal,
          authorizationIntent: authorizationIntent,
          searchTarget: target,
          depublication: depublication,
          criteria: criteria,
          submissionPeriod: submissionPeriod,
          consultationTarget: consultTarget,
          visibilityTarget: visibility ? visibilityTarget : null,
        ),
      );
      if (consent == null) {
        if (mounted && case1WithdrawalSelected) {
          setState(() => message = authorizationIntent == 'withdraw'
              ? 'Retrait 0.3-080 annulé. Aucune demande de retrait envoyée.'
              : 'Contrôle initial 0.3-080 annulé. Aucun droit modifié.');
        }
        if (mounted && preparatoryWithdrawal) {
          setState(() => message = 'Retrait préparatoire annulé. Aucune demande de retrait envoyée.');
        }
        if (mounted && authorizationIntent == 'withdraw' && !preparatoryWithdrawal && !case1WithdrawalSelected) {
          setState(
            () => message =
                'Refus enregistré — retrait auprès du DMP non confirmé. Consultation bloquée.',
          );
        }
        return;
      }
      checkWorkContext();
      pin = consent.pin;
      contextData = contextData.withSecretConnection(consent.secret);
      preparationStage = 'démarrage de l’essai après confirmation';
      final identityTicket = identityGeneration;
      final result = await service.execute(
        configuration: configuration,
        context: contextData,
        onPatientPerson: (person) {
          checkWorkContext();
          if (mounted && identityTicket == identityGeneration) {
            setState(() => patientPerson = person);
          }
        },
        authorizationIntent: authorizationIntent,
        preparatoryWithdrawal: preparatoryWithdrawal,
        additionEvidenceId: contextData.scenario == Dv1Case1WithdrawalRecipe.scenario ? _case1AdditionEvidenceId : null,
        searchTarget: target,
        depublication: depublication,
        criteria: criteria,
        submissionPeriod: submissionPeriod,
        consultationTarget: consultTarget,
        visibilityTarget: visibility ? visibilityTarget : null,
        visibilityConfirmed: visibility,
        displayDocument: (document) async {
          checkWorkContext();
          if (!mounted) return false;
          final confirmed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => DmpConsultationViewer(
                document: document,
                checkContext: checkWorkContext,
              ),
            ),
          );
          checkWorkContext();
          return confirmed == true;
        },
        requestPin: () async {
          checkWorkContext();
          final value = pin;
          pin = null;
          return value;
        },
      );
      if (mounted) {
        setState(
          () {
            message = [result['message'], result['detail'], result['archiveError']]
                .where((v) => v != null && '$v'.isNotEmpty).join('\n');
            if (contextData.scenario == Dv1Case1WithdrawalRecipe.scenario) {
              _case1TestWithdrawalReady = authorizationIntent == null &&
                  identityTicket == identityGeneration && result['state'] == 'response_verified' &&
                  result['archiveError'] == null && result['testWithdrawalReady'] == true;
            }
            if (contextData.scenario == Dv1Case1AuthorizationRecipe.scenario) {
              final readyResult = authorizationIntent == null && identityTicket == identityGeneration &&
                  result['state'] == 'response_verified' && result['archiveError'] == null;
              _case1InitialReady = readyResult && result['testInitialReady'] == true;
              _case1WithdrawalReady = readyResult && result['preparatoryWithdrawalReady'] == true;
              if (authorizationIntent != null) _case1ConsentRecorded = false;
            }
          },
        );
      }
      preparationStage = 'actualisation de l’écran après l’essai';
      await refresh();
    } catch (e) {
      if (mounted) {
        setState(() {
          message = dv1PreparationError(e, preparationStage);
          if (case1Selected || case1WithdrawalSelected) { _case1InitialReady = false; _case1ConsentRecorded = false; _case1WithdrawalReady = false; _case1TestWithdrawalReady = false; }
        });
      }
    } finally {
      pin = null;
      if (mounted) setState(() => busy = false);
    }
  }

  bool get visibilitySelectionValid =>
      visibilityTarget != null &&
      consultationChoices.any(
        (d) =>
            d['evidenceId'] == visibilityTarget!['evidenceId'] &&
            d['entryUUID'] == visibilityTarget!['entryUUID'] &&
            (d['confidentiality'] ?? '')
                .split('|')
                .contains('INVISIBLE_PATIENT') &&
            d['status'] != Dv1DocumentCriteria.deprecatedStatus,
      );

  bool get consultationSelectionValid =>
      consultationTarget != null &&
      consultationChoices.any(
        (d) =>
            d['evidenceId'] == consultationTarget!['evidenceId'] &&
            d['entryUUID'] == consultationTarget!['entryUUID'],
      );

  List<Map<String, String>> get consultationChoices {
    final result = <Map<String, String>>[];
    final seen = <String>{};
    for (final row in history) {
      if (row['integrity'] != true ||
          ![
            'criteria_search_verified',
            'submission_search_verified',
          ].contains(row['state'])) {
        continue;
      }
      final identity = (row['context'] as Map?)?['identity'] as Map?;
      if ('${identity?['ins_number']}${identity?['ins_key']}' !=
          fields['ins']!.text.trim()) {
        continue;
      }
      for (final raw in (row['documents'] as List? ?? [])) {
        final d = Map<String, String>.from(raw);
        if (!seen.add(d['entryUUID']!)) continue;
        result.add({...d, 'evidenceId': row['id'] as String});
      }
    }
    return result;
  }

  List<Map<String, dynamic>> get consultationTypes {
    if (config == null) return [];
    try {
      final entries = ValueCatalog.parse(
        NosImport.jdvTabs(config!.text('type')),
      ).entries.values.toList();
      entries.sort(
        (a, b) => (a['label'] as String).compareTo(b['label'] as String),
      );
      return entries;
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Recette DMP — accès réel DV1 sans dépôt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Vérification des accès et gestion de l’accord de consultation depuis Companion, avec une CPS de test et un patient fictif du CNDA. '
            'Aucun PDF requis, aucune qualification INS, aucun appel INSi, aucune signature de document ni dépôt.',
          ),
          if (Platform.isWindows || Platform.isMacOS)
            OutlinedButton(
              onPressed: busy ? null : () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => Tls050Screen(journal: journal)),
              ),
              child: const Text('0.1-050 — vérifier les certificats des trois serveurs'),
            ),
          if (Platform.isWindows)
            const Text(
              'Sous Windows, cet écran permet les tests TD0.2 0.2-060 et 0.2-070 '
              'et la recherche PRE_ALIM_RECH, le refus local NIA 0.2-080 et les autorisations 0.3-010 / 0.3-080. '
              'Les autres essais de cet écran ne sont pas encore disponibles.',
            )
          else if (!Platform.isMacOS)
            const Text('Ces essais DV1 ne sont pas disponibles sur cette plateforme.'),
          const SizedBox(height: 12),
          Text(
            config == null
                ? 'Configurez les paramètres et certificats de la CPS de test.'
                : 'Configuration n°${config!.revision} · CPS attendue : ${config!.professional} · '
                      'Situation ${config!.fields['situationNumber']} · Secteur ${config!.fields['situationSector']}',
          ),
          OutlinedButton(
            onPressed: busy ? null : configure,
            child: const Text(
              'Configurer la recette et les certificats de la CPS',
            ),
          ),
          const Text(
            'Pour changer de carte, choisissez ses deux certificats publics et sa situation dans la configuration. '
            'La lecture réelle vérifiera leur correspondance avant toute connexion.',
          ),
          Card(
            child: Padding(padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('0.3-080 — Cas1 : suppression de mon autorisation',
                    style: Theme.of(context).textTheme.titleMedium),
                const Text('Le parcours relie les preuves de l’ajout 0.3-010 réussi sur Windows, '
                    'vérifie le droit actuel, puis permet le retrait explicite de votre propre autorisation. '
                    'Aucun document consulté ni déposé.'),
                OutlinedButton(onPressed: busy ? null : prepareCase1Withdrawal,
                    child: const Text('Préparer le retrait du Cas1 — 0.3-080 — sans connexion')),
                if (case1WithdrawalSelected) ...[
                  Text('Ajout 0.3-010 relié : ${_case1AdditionEvidenceId ?? 'à sélectionner par Préparer le retrait'}'),
                  OutlinedButton(onPressed: busy || config == null || _case1AdditionEvidenceId == null
                      ? null : () => run(),
                      child: const Text('1. Vérifier le droit actuel — TD0.2 sans modification')),
                  Text(_case1TestWithdrawalReady ? 'Autorisation VALIDE confirmée ; retrait possible après confirmation.'
                      : 'Autorisation VALIDE à vérifier ; retrait indisponible.'),
                  FilledButton(onPressed: busy || config == null || !_case1TestWithdrawalReady
                      ? null : () => run(authorizationIntent: 'withdraw'),
                      child: const Text('2. Retirer mon autorisation sur DV1 — 0.3-080')),
                  if (busy) const LinearProgressIndicator(),
                  if (message.isNotEmpty) Semantics(liveRegion: true,
                      child: SelectableText('Dernière action : $message')),
                ],
              ]),
            ),
          ),
          Card(
            child: Padding(padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('0.3-010 — Cas1 : ANNE-LOUIS GIRODET DE ROUSSY-COEUR',
                    style: Theme.of(context).textTheme.titleMedium),
                const Text('Contrôle initial TD0.2, puis accord et ajout confirmé par TD0.3. '
                    'L’ajout est permis uniquement si une nouvelle vérification confirme NON_EXISTE. '
                    'Cette action modifiera réellement l’autorisation du Cas1 sur DV1. Aucun document ne sera consulté ni déposé.'),
                OutlinedButton(onPressed: busy ? null : prepareCase1Authorization,
                    child: const Text('Préparer le Cas1 — sans connexion')),
                if (case1Selected) ...[
                  OutlinedButton(onPressed: busy || config == null ? null : () => run(),
                      child: const Text('1. Vérifier l’état initial — TD0.2 sans modification')),
                  Text(_case1InitialReady ? 'Condition initiale NON_EXISTE confirmée.'
                      : _case1WithdrawalReady ? 'Autorisation déjà VALIDE. Ajout indisponible ; retrait préparatoire possible après confirmation.'
                      : 'Condition initiale NON_EXISTE à vérifier ; ajout indisponible.'),
                  OutlinedButton(onPressed: busy || config == null || !_case1WithdrawalReady
                      ? null : () => run(authorizationIntent: 'withdraw', preparatoryWithdrawal: true),
                      child: const Text('Retirer mon autorisation du Cas1 — préparation uniquement')),
                  const Text('Ce retrait volontaire prépare la condition initiale. Il ne valide ni 0.3-010 ni 0.3-080.'),
                  OutlinedButton(onPressed: busy || config == null || !_case1InitialReady
                      ? null : collectConsent,
                      child: const Text('2. Enregistrer l’accord de consultation — localement')),
                  Text(consentStatus),
                  FilledButton(onPressed: busy || config == null || !_case1InitialReady ||
                      !_case1ConsentRecorded || patientConsent?['granted'] != true ||
                      patientConsent?['pendingWithdrawal'] == true
                      ? null : () => run(authorizationIntent: 'consult'),
                      child: const Text('3. Ajouter mon autorisation sur DV1 — 0.3-010')),
                  if (busy) const LinearProgressIndicator(),
                  if (message.isNotEmpty) Semantics(liveRegion: true,
                      child: SelectableText('Dernière action : $message')),
                ],
              ]),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '0.2-070 — Cas 6 : Henri HUIT',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text(
                    'Résultat attendu : réponse AA, DMP actif, autorisation bloquée '
                    'pour 899700870597. Ce test vérifie uniquement TD0.2. '
                    'Il ne renouvelle aucune autorisation et n’ouvre aucun document. '
                    'Pour la cinématique par défaut, désactivez l’option '
                    '« Afficher les traits d’identité retournés par le DMP » dans les paramètres DMP.',
                  ),
                  OutlinedButton(
                    onPressed: busy ? null : prepareBlockedAuthorizationCase,
                    child: const Text('Préparer Henri HUIT — sans connexion'),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '0.2-060 — Cas 7 : Simone SARTRE',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text(
                    'Résultat attendu : réponse AA, DMP actif, autorisation expirée '
                    'pour 899700870597. Ce test vérifie uniquement TD0.2. '
                    'Il ne renouvelle aucune autorisation et n’ouvre aucun document. '
                    'Pour la cinématique par défaut, désactivez l’option '
                    '« Afficher les traits d’identité retournés par le DMP » dans les paramètres DMP.',
                  ),
                  OutlinedButton(
                    onPressed: busy ? null : prepareExpiredAuthorizationCase,
                    child: const Text('Préparer Simone SARTRE — sans connexion'),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('0.2-080 — Patient 103 : MATRICULE PROVISOIRE',
                    style: Theme.of(context).textTheme.titleMedium),
                const Text('Injectez TEST_NIA.xml du package CNDA comme réponse INSi. '
                    'Le type NIA et l’OID sont conservés dans les preuves de recette. '
                    'L’accès DMP doit être refusé avant toute CPS, PIN ou connexion réseau. '
                    'Cette injection ne qualifie aucune identité réelle.'),
                OutlinedButton(onPressed: busy ? null : importNiaResponse,
                    child: const Text('Importer la réponse INSi — TEST_NIA.xml')),
                if (niaEvidence != null) ...[
                  SelectableText('Identité importée : ${niaEvidence!.injection.patient} · '
                      '${niaEvidence!.injection.result.birthDate}\n'
                      'NIA : ${niaEvidence!.injection.ins} · OID : ${niaEvidence!.injection.result.insOid}'),
                  FilledButton(onPressed: busy || config == null ? null : runNia,
                      child: const Text('Vérifier le refus d’accès DMP — 0.2-080')),
                ],
                if (_niaAction && busy) const LinearProgressIndicator(),
                if (_niaAction && message.isNotEmpty) Semantics(liveRegion: true,
                    child: SelectableText('Dernière action : $message')),
              ]),
            ),
          ),
          for (final e in const {
            'scenario':
                'Exigence / scénario CNDA (ex. PRE_DIR_AUX ou PRE_DIR_REMPL)',
            'source':
                'Référence du fichier CNDA et de la ligne du patient fictif',
            'patient': 'Nom et prénom du patient fictif',
            'birth':
                'Date de naissance du patient fictif (AAAA-MM-JJ, source CNDA)',
            'ins': 'INS de test fourni par le CNDA (15 chiffres, clé comprise)',
            'structure':
                'Identifiant de la structure d’exercice pour cet essai',
          }.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: fields[e.key],
                onChanged: (_) => refreshConsent(),
                enabled: !busy,
                maxLength: e.key == 'ins' ? 15 : 2000,
                decoration: InputDecoration(labelText: e.value),
              ),
            ),
          SwitchListTile(
            value: replacement,
            onChanged: busy ? null : (v) => setState(() => replacement = v),
            title: const Text(
              'CPS de remplaçant — rattachement temporaire à cette structure',
            ),
          ),
          if (replacement) ...[
            const Text(
              'Ce rattachement vaut uniquement pour cet essai. Il ne modifie ni la CPS ni la fiche du praticien.',
            ),
            TextField(
              controller: fields['until'],
              enabled: !busy,
              decoration: const InputDecoration(
                labelText: 'Fin du remplacement (date, heure et fuseau)',
                hintText: '2026-10-21T18:00:00+02:00',
              ),
            ),
          ],
          FilledButton(
            onPressed: busy ||
                    config == null ||
                    !dv1AccessPlatformSupported(
                      platform: Platform.operatingSystem,
                      existenceCheck: [
                        Dv1ExpiredAuthorizationRecipe.scenario,
                        Dv1BlockedAuthorizationRecipe.scenario,
                        Dv1Case1AuthorizationRecipe.scenario,
                        Dv1Case1WithdrawalRecipe.scenario,
                      ].contains(fields['scenario']!.text.trim()),
                    )
                ? null
                : run,
            child: const Text('Vérifier l’existence du DMP et les droits — TD0.2'),
          ),
          if ([
            Dv1ExpiredAuthorizationRecipe.scenario,
            Dv1BlockedAuthorizationRecipe.scenario,
          ].contains(fields['scenario']!.text.trim())) ...[
            if (busy) const LinearProgressIndicator(),
            if (message.isNotEmpty)
              Semantics(
                liveRegion: true,
                child: SelectableText('Dernière action DV1 : $message'),
              ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accord du patient pour la consultation',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text(
                    'Recette DV1 : réponse jouée pour le patient fictif et le praticien sélectionnés. '
                    'L’accord ne vaut ni qualification INS ni autorisation de dépôt. '
                    'Cet essai vérifie les droits ; il n’ouvre aucun document du DMP.',
                  ),
                  Text(consentStatus),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: busy || config == null || case1WithdrawalSelected || (case1Selected && !_case1InitialReady)
                            ? null
                            : collectConsent,
                        child: const Text('Enregistrer la réponse Oui / Non'),
                      ),
                      FilledButton(
                        onPressed:
                            busy ||
                                config == null ||
                                case1WithdrawalSelected ||
                                !dv1AccessPlatformSupported(
                                  platform: Platform.operatingSystem, authorizationAdd: case1Selected,
                                ) ||
                                (case1Selected && (!_case1InitialReady || !_case1ConsentRecorded)) ||
                                patientConsent?['granted'] != true ||
                                patientConsent?['pendingWithdrawal'] == true
                            ? null
                            : () => run(authorizationIntent: 'consult'),
                        child: const Text('Demander la consultation du DMP'),
                      ),
                      TextButton(
                        onPressed:
                            busy ||
                                config == null ||
                                !Platform.isMacOS ||
                                case1WithdrawalSelected ||
                                patientConsent?['pendingWithdrawal'] != true
                            ? null
                            : () => run(authorizationIntent: 'withdraw'),
                        child: const Text('Reprendre un retrait non confirmé'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Retrouver un document déposé — PRE_ALIM_RECH',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text(
                    'Sélectionnez un dépôt accepté conservé par Companion ou une preuve historique importée. Le patient et l’identifiant du document sont repris de ses preuves. Ce test doit retrouver un seul identifiant technique. La recherche ne consulte pas le contenu et ne remplace ni ne supprime le document.',
                  ),
                  Text(searchStatus),
                  if (searchTargets.isEmpty)
                    const Text(
                      'Aucun dépôt disponible : terminez d’abord un dépôt DV1 et conservez ses preuves. Les essais provenant de lanceurs externes ne sont pas importés automatiquement.',
                    ),
                  DropdownButtonFormField<String>(
                    key: ValueKey(searchTarget?.id),
                    initialValue: searchTarget?.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Document déposé à rechercher',
                    ),
                    items: [
                      for (final t in searchTargets)
                        DropdownMenuItem(
                          value: t.id,
                          child: Text(t.label, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: busy
                        ? null
                        : (id) {
                            final t = searchTargets.firstWhere(
                              (e) => e.id == id,
                            );
                            setState(() {
                              selectSearchTarget(t);
                            });
                            refreshConsent();
                          },
                  ),
                  if (searchTarget != null)
                    SelectableText(
                      'Identifiant local du document : ${searchTarget!.uniqueId}',
                    ),
                  if (searchTarget?.data['origin'] == 'reviewed_legacy')
                    const Text(
                      'Archive technique externe — recherche uniquement. Le dépôt depuis Companion reste à vérifier. Aucune donnée de naissance n’est importée dans la fiche patient.',
                    ),
                  if (fields['scenario']!.text.trim() == 'PRE_ALIM_RECH') ...[
                    if (busy) const LinearProgressIndicator(),
                    if (message.isNotEmpty)
                      Semantics(
                        liveRegion: true,
                        child: SelectableText('Dernière action DV1 : $message'),
                      ),
                  ],
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: busy || widget.searchVersionId != null
                            ? null
                            : importHistoricalEvidence,
                        child: const Text(
                          'Importer une preuve historique vérifiée',
                        ),
                      ),
                      OutlinedButton(
                        onPressed: busy ? null : refresh,
                        child: const Text('Actualiser les dépôts locaux'),
                      ),
                      FilledButton(
                        onPressed:
                            busy ||
                                config == null ||
                                searchTarget == null ||
                                !dv1AccessPlatformSupported(
                                  platform: Platform.operatingSystem,
                                  documentSearch: true,
                                )
                            ? null
                            : () => run(search: true),
                        child: const Text('Rechercher ce document dans le DMP'),
                      ),
                      OutlinedButton(
                        onPressed:
                            busy ||
                                config == null ||
                                searchTarget == null ||
                                !Platform.isMacOS
                            ? null
                            : () => run(search: true, depublication: true),
                        child: const Text(
                          'Dépublier ce document — PRE_ALIM_SUPPR',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rechercher par statut et type — PRE_CONS_RECH',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text(
                    'Patient prévu : cas 75 — Corinne DUPRE. Les informations CNDA saisies en haut de cet écran seront utilisées. La recherche liste les métadonnées, sans ouvrir les documents ni modifier les droits.',
                  ),
                  OutlinedButton(
                    onPressed: busy
                        ? null
                        : () {
                            setState(() {
                              fields['scenario']!.text = 'PRE_CONS_RECH';
                              fields['patient']!.text =
                                  Dv1ConsultationRecipe.patient;
                              fields['ins']!.text = Dv1ConsultationRecipe.ins;
                              fields['birth']!.text =
                                  Dv1ConsultationRecipe.birth;
                              fields['source']!.text =
                                  Dv1ConsultationRecipe.source;
                              searchTarget = null;
                              message =
                                  'Cas 75 préparé : Corinne DUPRE, née le 09/11/1948, sexe F, INS 148115530271002 (données fournies par l’éditeur). Vérifiez les informations en haut de cet écran, puis enregistrez son accord de consultation.';
                            });
                            refreshConsent();
                          },
                    child: const Text(
                      'Préparer le cas 75 — Corinne DUPRE (sans connexion)',
                    ),
                  ),
                  const Text('Les documents actifs sont toujours inclus.'),
                  CheckboxListTile(
                    value: includeArchived,
                    onChanged: busy
                        ? null
                        : (v) => setState(() => includeArchived = v ?? false),
                    title: const Text('Inclure les documents archivés'),
                  ),
                  CheckboxListTile(
                    value: includeDeprecated,
                    onChanged: busy
                        ? null
                        : (v) => setState(() => includeDeprecated = v ?? false),
                    title: const Text(
                      'Inclure les anciennes versions remplacées',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      'consultation-type-${fields['typeSystem']!.text}-${fields['typeCode']!.text}',
                    ),
                    initialValue: fields['typeCode']!.text.isEmpty
                        ? ''
                        : '${fields['typeSystem']!.text}|${fields['typeCode']!.text}',
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Type de document',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Tous les types de documents'),
                      ),
                      for (final type in consultationTypes)
                        DropdownMenuItem(
                          value: '${type['system']}|${type['code']}',
                          child: Text(
                            '${type['label']} (${type['code']})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: busy
                        ? null
                        : (value) => setState(() {
                            final parts = (value ?? '').split('|');
                            fields['typeCode']!.text = parts.length == 2
                                ? parts[1]
                                : '';
                            fields['typeSystem']!.text = parts.length == 2
                                ? parts[0]
                                : '2.16.840.1.113883.6.1';
                          }),
                  ),
                  if (consultationTypes.isEmpty)
                    const Text(
                      'Liste des types indisponible : vérifiez la nomenclature dans la configuration DV1. La recherche de tous les types reste possible.',
                    ),
                  Text(consentStatus),
                  const Text(
                    'Un accord de consultation enregistré et un droit DV1 valide sont requis. Si nécessaire, utilisez le bloc « Accord du patient pour la consultation » avant la recherche.',
                  ),
                  FilledButton(
                    onPressed: busy || config == null || !Platform.isMacOS
                        ? null
                        : () => run(criteriaSearch: true),
                    child: const Text(
                      'Rechercher par critères — PRE_CONS_RECH',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rechercher par date de dépôt — PRE_CONS_SUB',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Utilise le patient et la CPS renseignés en haut de cet écran. La période concerne le dépôt dans le DMP, et non la date clinique du rapport. Les dates sont incluses, dans le fuseau de ce Mac. Aucun contenu de document n’est ouvert.',
                  ),
                  TextField(
                    controller: fields['submissionFrom'],
                    enabled: !busy,
                    decoration: const InputDecoration(
                      labelText: 'Premier jour de dépôt — AAAA-MM-JJ',
                    ),
                  ),
                  TextField(
                    controller: fields['submissionTo'],
                    enabled: !busy,
                    decoration: const InputDecoration(
                      labelText: 'Dernier jour de dépôt — AAAA-MM-JJ',
                    ),
                  ),
                  Text(consentStatus),
                  const Text(
                    'Accord enregistré et droit de consultation DV1 valide requis. Les requêtes et réponses de chaque étape seront conservées.',
                  ),
                  FilledButton(
                    onPressed: busy || config == null || !Platform.isMacOS
                        ? null
                        : () => run(submissionSearch: true),
                    child: const Text(
                      'Rechercher par date de dépôt — PRE_CONS_SUB',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consulter un document — PRE_CONS_CONS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Choisissez un document d’une recherche conservée pour le patient renseigné. Seul ce document sera récupéré après confirmation. Le contenu et l’en-tête CDA seront affichés temporairement dans Companion.',
                  ),
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      consultationChoices
                          .map((d) => "${d['evidenceId']}:${d['entryUUID']}")
                          .join('|'),
                    ),
                    initialValue: !consultationSelectionValid
                        ? null
                        : '${consultationTarget!['evidenceId']}:${consultationTarget!['entryUUID']}',
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Document à consulter',
                    ),
                    items: consultationChoices
                        .map(
                          (d) => DropdownMenuItem(
                            value: '${d['evidenceId']}:${d['entryUUID']}',
                            child: Text(
                              '${d['title']} · ${d['status']!.split(':').last}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: busy
                        ? null
                        : (v) => setState(
                            () => consultationTarget = consultationChoices
                                .firstWhere(
                                  (d) =>
                                      '${d['evidenceId']}:${d['entryUUID']}' ==
                                      v,
                                ),
                          ),
                  ),
                  if (consultationSelectionValid)
                    Text('Identifiant : ${consultationTarget!['uniqueId']}'),
                  FilledButton(
                    onPressed:
                        busy ||
                            config == null ||
                            !consultationSelectionValid ||
                            !Platform.isMacOS
                        ? null
                        : () => run(consult: true),
                    child: const Text('Consulter ce document — PRE_CONS_CONS'),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rendre visible au patient — PRE_CONS_INV',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Cas 23 — Sophie PATB-TROIS. Vérifiez son identité CNDA en haut de cet écran. Recherchez ses documents, puis sélectionnez un document invisible au patient. Cette action est irréversible ; elle ne modifie ni le contenu ni la visibilité aux professionnels ou aux représentants légaux.',
                  ),
                  OutlinedButton(
                    onPressed: busy
                        ? null
                        : () async {
                            setState(() {
                              fields['scenario']!.text = 'PRE_CONS_INV';
                              fields['patient']!.text =
                                  Dv1VisibilityRecipe.patient;
                              fields['source']!.text =
                                  Dv1VisibilityRecipe.source;
                              fields['ins']!.text = Dv1VisibilityRecipe.ins;
                              fields['birth']!.text = Dv1VisibilityRecipe.birth;
                              visibilityTarget = null;
                              consultationTarget = null;
                              message =
                                  'Cas 23 préparé depuis le référentiel CNDA : Sophie PATB-TROIS, née le 07/06/2011, INS 211066322074514. Vérifiez son identité, la structure et l’accord de consultation. Aucune connexion lancée.';
                            });
                            await refreshConsent();
                          },
                    child: const Text('Préparer le cas 23 — sans connexion'),
                  ),
                  const Text(Dv1VisibilityRecipe.note),
                  OutlinedButton(
                    onPressed: busy || config == null || !Platform.isMacOS
                        ? null
                        : () => run(visibilityIdentifiers: true),
                    child: const Text(
                      'Vérifier les quatre identifiants du jeu d’essai',
                    ),
                  ),
                  const Text(
                    'Recherche les documents 05, 10, 14 et 20 par leur identifiant exact, y compris archivés ou remplacés. Contrôle de l’INS de Sophie et de son autorité. Aucun résultat signifie « non trouvé ou non accessible », pas une preuve d’absence.',
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: visibilityType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Limiter la recherche à un type de document',
                    ),
                    items: Dv1VisibilityRecipe.searchTypes.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: busy
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                visibilityType = value;
                              });
                            }
                          },
                  ),
                  const Text(
                    'Recherche des documents actifs de ce type uniquement. Le numéro du jeu d’essai est un repère : le document et son invisibilité seront vérifiés dans la réponse DV1. Aucun changement de visibilité pendant la recherche.',
                  ),
                  OutlinedButton(
                    onPressed: busy || config == null || !Platform.isMacOS
                        ? null
                        : () => run(visibilitySearch: true),
                    child: const Text(
                      'Rechercher les documents pour PRE_CONS_INV',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      'visibility-${consultationChoices.map((d) => d['entryUUID']).join('|')}',
                    ),
                    initialValue: !visibilitySelectionValid
                        ? null
                        : '${visibilityTarget!['evidenceId']}:${visibilityTarget!['entryUUID']}',
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Document invisible au patient',
                    ),
                    items: consultationChoices
                        .where(
                          (d) =>
                              (d['confidentiality'] ?? '')
                                  .split('|')
                                  .contains('INVISIBLE_PATIENT') &&
                              d['status'] !=
                                  Dv1DocumentCriteria.deprecatedStatus,
                        )
                        .map(
                          (d) => DropdownMenuItem(
                            value: '${d['evidenceId']}:${d['entryUUID']}',
                            child: Text(
                              '${d['title']} — invisible au patient',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: busy
                        ? null
                        : (v) => setState(
                            () => visibilityTarget = consultationChoices
                                .firstWhere(
                                  (d) =>
                                      '${d['evidenceId']}:${d['entryUUID']}' ==
                                      v,
                                ),
                          ),
                  ),
                  if (visibilityTarget != null)
                    Text(
                      'Identifiant : ${visibilityTarget!['uniqueId']}. La visibilité sera relue sur DV1 avant modification.',
                    ),
                  FilledButton(
                    onPressed:
                        busy ||
                            config == null ||
                            !visibilitySelectionValid ||
                            !Platform.isMacOS
                        ? null
                        : () => run(visibility: true),
                    child: const Text(
                      'Rendre visible au patient — PRE_CONS_INV',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (busy) const LinearProgressIndicator(),
          if (message.isNotEmpty) SelectableText(message),
          PatientPersonPanel(person: patientPerson),
          const Divider(),
          const Text(
            'Historique des essais — DV1 et contrôles locaux NIA ; aucune relecture ne relance de connexion',
          ),
          for (final r in history)
            ExpansionTile(
              title: Text(
                '${r['startedAt'] ?? ''} · ${r['message'] ?? r['state']}',
              ),
              subtitle: Text(
                r['testCode'] == Dv1NiaInjection.scenario
                    ? 'Injection CNDA — aucune lecture CPS ni connexion DMP'
                    : 'CPS : ${(r['session'] as Map?)?['professional'] ?? 'authentification non confirmée'}',
              ),
              children: [
                if (r['integrity'] != true)
                  const Text('Intégrité du résultat non confirmée.'),
                if (r['testCode'] == Dv1NiaInjection.scenario)
                  SelectableText('${r['operation']}\nÉtat : ${r['state']}\n'
                      'Type enregistré : NIA · OID : ${(r['injectedIdentity'] as Map?)?['ins_oid']}\n'
                      'CodeCR de la réponse INSi injectée : ${r['injectedCodeCR']}\n'
                      'Lecture CPS : aucune · Session native ouverte : non\n'
                      'Appel TD0.2 : aucun — blocage local avant connexion\n'
                      'Source : ${r['source']}\nSHA-256 : ${r['sourceSha256']}\n'
                      'Preuves : ${r['evidenceDirectory']}')
                else
                SelectableText(
                  '${r['operation'] ?? ''}\nÉtat : ${r['state']}\nHTTP TD0.2 initial : ${r['httpStatus'] ?? 'aucune réponse'}\n'
                  '${r['td33bHttpStatus'] != null ? 'HTTP TD3.3b : ${r['td33bHttpStatus']}\n' : ''}'
                  '${r['td32HttpStatus'] != null ? 'HTTP TD3.2 : ${r['td32HttpStatus']}\n' : ''}'
                  '${r['td31aHttpStatus'] != null ? 'HTTP TD3.1 recherche par critères : ${r['td31aHttpStatus']}\n' : ''}'
                  '${r['td31bHttpStatus'] != null ? 'HTTP TD3.1b : ${r['td31bHttpStatus']}\n' : ''}'
                  '${r['td33cHttpStatus'] != null ? 'HTTP TD3.3c : ${r['td33cHttpStatus']}\n' : ''}'
                  '${r['td03HttpStatus'] != null ? 'HTTP TD0.3 : ${r['td03HttpStatus']}\n' : ''}'
                  '${r['afterHttpStatus'] != null ? 'HTTP TD0.2 après modification : ${r['afterHttpStatus']}\n' : ''}'
                  'Connexion : ${(r['context'] as Map?)?['recipe']?['secretConnection'] == true ? 'secrète — traces invisibles aux représentants légaux' : 'normale'}\n'
                  '${r['detail'] ?? ''}\n'
                  '${r['transactionClosed'] == true ? 'Opération et connexions réseau fermées.\n' : ''}'
                  '${r['authenticationRetainedAtEnd'] == true ? 'Authentification CPS conservée à la fin de cet essai (état historique).\n' : 'Session CPS fermée : ${r['sessionClosed'] ?? 'non ouverte'}\n'}'
                  '${r['td03Status'] != null ? 'TD0.3 : ${r['td03Status']} · ${r['td03Detail'] ?? ''}\n' : ''}'
                  '${r['additionEvidenceId'] != null ? 'Ajout 0.3-010 relié : ${r['additionEvidenceId']}\n' : ''}'
                  'Preuves : ${r['evidenceDirectory']}',
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

class _AccessConsent extends StatefulWidget {
  const _AccessConsent({
    required this.contextData,
    this.authorizationIntent,
    this.searchTarget,
    this.reuseAuthentication = false,
    this.depublication = false,
    this.preparatoryWithdrawal = false,
    this.criteria,
    this.submissionPeriod,
    this.consultationTarget,
    this.visibilityTarget,
  });
  final Map<String, String>? consultationTarget;
  final Map<String, String>? visibilityTarget;
  final Dv1DocumentCriteria? criteria;
  final Dv1SubmissionPeriod? submissionPeriod;
  final bool reuseAuthentication;
  final bool depublication;
  final bool preparatoryWithdrawal;
  final String? authorizationIntent;
  final Dv1SearchTarget? searchTarget;
  final Dv1AccessContext contextData;
  @override
  State<_AccessConsent> createState() => _AccessConsentState();
}

class _AccessConsentState extends State<_AccessConsent> {
  final pin = TextEditingController();
  bool confirmed = false;
  bool deletionConfirmed = false;
  bool preparatoryWithdrawalConfirmed = false;
  bool visibilityConfirmed = false;
  bool? secret;
  @override
  void dispose() {
    pin.clear();
    pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.contextData.scenario == Dv1Case1WithdrawalRecipe.scenario
          ? (widget.authorizationIntent == 'withdraw' ? 'Retirer mon autorisation du Cas1 — 0.3-080 ?'
              : 'Vérifier le droit actuel du Cas1 — 0.3-080 ?')
          : widget.preparatoryWithdrawal
          ? 'Retirer mon autorisation du Cas1 pour préparer le test ?'
          : widget.contextData.scenario == Dv1Case1AuthorizationRecipe.scenario
          ? (widget.authorizationIntent == 'consult'
              ? 'Ajouter mon autorisation sur le DMP du Cas1 ?'
              : 'Vérifier l’état initial du Cas1 sans modification ?')
          : widget.visibilityTarget != null
          ? 'Rendre ce document visible au patient sur DV1 ?'
          : widget.depublication
          ? 'Dépublier définitivement ce document sur DV1 ?'
          : widget.reuseAuthentication
          ? 'Interroger DV1 avec la CPS déjà authentifiée ?'
          : 'Lire la CPS et interroger réellement DV1 ?',
    ),
    content: SizedBox(
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CPS attendue : ${widget.contextData.professional}\nPatient fictif : ${widget.contextData.patientLabel}\n'
              'INS : ${widget.contextData.ins}\nStructure : ${widget.contextData.structure}\n'
              'Scénario : ${widget.contextData.scenario}\n'
              'Naissance : ${widget.contextData.birthDate} · Âge : ${widget.contextData.ageAt(DateTime.now())} ans\n'
              '${widget.contextData.replacementUntil != null ? 'Rattachement temporaire jusqu’au ${widget.contextData.replacementUntil!.toLocal()}.' : ''}\n'
              '${widget.contextData.scenario == Dv1Case1WithdrawalRecipe.scenario && widget.authorizationIntent == 'withdraw'
                  ? '0.3-080 : retrait réel de votre propre autorisation sur DV1. Les preuves de l’ajout antérieur seront vérifiées. Une nouvelle TD0.2 doit confirmer VALIDE avant TD0.3 de suppression ; une relecture doit confirmer NON_EXISTE. Aucun refus du patient n’est ajouté aux accords locaux.'
                  : widget.preparatoryWithdrawal
                  ? 'Préparation uniquement : retrait réel de votre propre autorisation sur DV1. Une nouvelle TD0.2 doit confirmer VALIDE avant TD0.3 RETRAIT, puis une relecture doit confirmer NON_EXISTE. Ce geste ne valide ni 0.3-010 ni 0.3-080 et n’enregistre pas de refus du patient. Aucun ajout automatique.'
                  : widget.depublication
                  ? 'PRE_ALIM_SUPPR : dépublication irréversible de ${widget.searchTarget!.label}, identifiant ${widget.searchTarget!.uniqueId}. La cible sera recherchée à nouveau, puis son statut passera à Deleted. La copie locale reste conservée. Confirmez uniquement si vous êtes l’auteur du document et souhaitez sa dépublication.'
                  : widget.searchTarget != null
                  ? 'Recherche TD3.1b de ${widget.searchTarget!.label} — identifiant ${widget.searchTarget!.uniqueId}. Vérification TD0.2 puis recherche de l’identifiant technique uniquement, sans modification d’autorisation.'
                  : widget.visibilityTarget != null
                  ? 'PRE_CONS_INV : rendre visible au patient ${widget.visibilityTarget!['title']}, identifiant ${widget.visibilityTarget!['uniqueId']}. Mise à jour des métadonnées uniquement, après vérification de l’identité et de la visibilité actuelle. Cette action est irréversible.'
                  : widget.consultationTarget != null
                  ? 'PRE_CONS_CONS : consulter uniquement ${widget.consultationTarget!['title']}, identifiant ${widget.consultationTarget!['uniqueId']}. Vérification des droits et des métadonnées, puis récupération du contenu CDA. Affichage temporaire du contenu et de son en-tête, sans conservation automatique ni modification de droits.'
                  : widget.submissionPeriod != null
                  ? 'PRE_CONS_SUB : ${widget.submissionPeriod!.label}. Recherche des lots déposés dans cette période, puis des métadonnées de leurs documents. TD0.2 et droit de consultation valide requis. Aucun document ouvert, aucun droit modifié.'
                  : widget.criteria != null
                  ? '${widget.contextData.scenario} : ${widget.criteria!.label}. TD0.2 puis recherche des métadonnées si le droit de consultation est valide. Aucun document ouvert, aucun droit modifié.'
                  : widget.contextData.scenario == Dv1Case1AuthorizationRecipe.scenario && widget.authorizationIntent == 'consult'
                  ? '0.3-010 : cette confirmation autorise l’ajout réel de votre autorisation sur DV1. Une nouvelle TD0.2 doit confirmer un DMP actif et NON_EXISTE avant TD0.3 AJOUT. L’état VALIDE sera ensuite vérifié par TD0.2. Aucun retrait automatique.'
                  : widget.authorizationIntent == null
                  ? 'Lecture CPS, authentification TLS et une requête TD0.2.'
                  : widget.authorizationIntent == 'consult'
                  ? 'Demande explicite de consultation : vérification TD0.2 puis ajout de l’autorisation par TD0.3 si nécessaire, suivi d’une vérification. Aucun document ne sera ouvert dans cet essai.'
                  : 'Refus enregistré : vérification TD0.2 et suppression de l’autorisation par TD0.3 si elle existe, suivie d’une vérification. Si vous annulez, le retrait restera non confirmé.'} Aucun dépôt. '
              'Les connexions TLS aux services patients et repository sont vérifiées ; aucune requête de dépôt n’est envoyée.',
            ),
            if (widget.preparatoryWithdrawal ||
                (widget.contextData.scenario == Dv1Case1WithdrawalRecipe.scenario && widget.authorizationIntent == 'withdraw'))
              CheckboxListTile(
                value: preparatoryWithdrawalConfirmed,
                onChanged: (v) => setState(() => preparatoryWithdrawalConfirmed = v == true),
                title: Text(widget.preparatoryWithdrawal
                    ? 'Je confirme le retrait réel de ma propre autorisation pour le Cas1 sur DV1, à titre préparatoire.'
                    : 'Je confirme le retrait réel de ma propre autorisation du Cas1 sur DV1 pour le test 0.3-080.'),
              ),
            if (widget.visibilityTarget != null)
              CheckboxListTile(
                value: visibilityConfirmed,
                onChanged: (v) =>
                    setState(() => visibilityConfirmed = v ?? false),
                title: const Text(
                  'Le patient a reçu l’information préalable par un professionnel. Je confirme la mise en visibilité irréversible de ce document au patient.',
                ),
              ),
            if (widget.depublication)
              CheckboxListTile(
                value: deletionConfirmed,
                onChanged: (value) =>
                    setState(() => deletionConfirmed = value ?? false),
                title: const Text(
                  'Je suis l’auteur de ce document et je confirme sa dépublication irréversible sur DV1. La copie locale sera conservée.',
                ),
              ),
            if (widget.contextData.offersSecret(DateTime.now())) ...[
              const Text(
                'Patient mineur : choisissez le mode de connexion pour cet essai. '
                'La connexion secrète rend les traces de cet accès invisibles aux représentants légaux. '
                'Elle ne donne aucun droit supplémentaire de consultation. '
                'En usage réel, ce choix se fait en concertation avec le patient. '
                'Il sera redemandé à chaque essai.',
              ),
              DropdownButtonFormField<bool>(
                initialValue: secret,
                decoration: const InputDecoration(
                  labelText: 'Mode de connexion — choix requis',
                ),
                items: const [
                  DropdownMenuItem(
                    value: false,
                    child: Text('Connexion normale'),
                  ),
                  DropdownMenuItem(
                    value: true,
                    child: Text('Connexion secrète'),
                  ),
                ],
                onChanged: (value) => setState(() => secret = value),
              ),
            ] else
              Text(
                widget.contextData.minorsEnabled
                    ? 'Patient majeur au seuil DMP de ${widget.contextData.majorityAge} ans : connexion normale.'
                    : 'Gestion des mineurs désactivée dans les paramètres DMP : connexion normale.',
              ),
            CheckboxListTile(
              value: confirmed,
              onChanged: (v) => setState(() => confirmed = v == true),
              title: const Text(
                'Je confirme la CPS et le patient de test du scénario CNDA, ainsi que la structure d’exercice et, le cas échéant, la fin du remplacement.',
              ),
            ),
            if (widget.reuseAuthentication)
              const Text(
                'Votre CPS est déjà authentifiée. Laissez-la dans le lecteur : sa présence sera vérifiée avant cet essai. Le PIN n’est pas conservé.',
              )
            else ...[
              const Text(
                'Après un essai réussi, l’authentification CPS peut être réutilisée pendant votre session de travail, au maximum une heure. Elle prend fin au verrouillage, au changement de praticien ou au retrait de la carte.',
              ),
              TextField(
                controller: pin,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'PIN CPS — non conservé',
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed:
            confirmed &&
                (!(widget.preparatoryWithdrawal || (widget.contextData.scenario == Dv1Case1WithdrawalRecipe.scenario && widget.authorizationIntent == 'withdraw')) || preparatoryWithdrawalConfirmed) &&
                (!widget.depublication || deletionConfirmed) &&
                (widget.visibilityTarget == null || visibilityConfirmed) &&
                (widget.reuseAuthentication || pin.text.isNotEmpty) &&
                (!widget.contextData.offersSecret(DateTime.now()) ||
                    secret != null)
            ? () => Navigator.pop(context, (
                pin: widget.reuseAuthentication ? '' : pin.text,
                secret: secret ?? false,
              ))
            : null,
        child: Text(
          widget.contextData.scenario == Dv1Case1WithdrawalRecipe.scenario && widget.authorizationIntent == 'withdraw'
              ? 'Confirmer le retrait sur DV1 — 0.3-080'
              : widget.preparatoryWithdrawal
              ? 'Confirmer le retrait préparatoire sur DV1'
              : widget.visibilityTarget != null
              ? 'Confirmer la mise en visibilité sur DV1'
              : widget.depublication
              ? 'Confirmer la dépublication irréversible sur DV1'
              : widget.consultationTarget != null
              ? 'Confirmer et consulter sur DV1'
              : widget.searchTarget != null ||
                    widget.criteria != null ||
                    widget.submissionPeriod != null
              ? 'Confirmer et rechercher sur DV1'
              : widget.authorizationIntent == null
              ? (widget.reuseAuthentication
                    ? 'Confirmer et vérifier DV1'
                    : 'Lire la CPS et vérifier DV1')
              : widget.contextData.scenario == Dv1Case1AuthorizationRecipe.scenario && widget.authorizationIntent == 'consult'
              ? 'Confirmer l’ajout de mon autorisation sur DV1'
              : 'Confirmer et transmettre à DV1',
        ),
      ),
    ],
  );
}

class PatientConsultationConsentDialog extends StatefulWidget {
  const PatientConsultationConsentDialog({
    super.key,
    required this.patient,
    required this.professional,
    this.previous,
    this.refusalWithdraws = true,
  });
  final bool refusalWithdraws;
  final String patient, professional;
  final Map<String, dynamic>? previous;
  @override
  State<PatientConsultationConsentDialog> createState() =>
      PatientConsultationConsentDialogState();
}

class PatientConsultationConsentDialogState
    extends State<PatientConsultationConsentDialog> {
  bool? answer;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Réponse du patient'),
    content: SizedBox(
      width: 560,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient fictif : ${widget.patient}\nPraticien : ${widget.professional}',
          ),
          if (widget.previous != null)
            Text(
              'Dernière réponse enregistrée : ${widget.previous!['granted'] == true ? 'Oui' : 'Non'}'
              '${widget.previous!['pendingWithdrawal'] == true ? ' — retrait non confirmé' : ''}',
            ),
          const SizedBox(height: 16),
          const Text(
            '« M’autorisez-vous à consulter les informations de votre DMP ? »',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                label: const Text('Oui'),
                selected: answer == true,
                onSelected: (_) => setState(() => answer = true),
              ),
              ChoiceChip(
                label: const Text('Non'),
                selected: answer == false,
                onSelected: (_) => setState(() => answer = false),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer == false
                ? (widget.refusalWithdraws
                    ? 'Le refus bloque la consultation. Companion demandera la CPS pour retirer une autorisation existante auprès du DMP.'
                    : 'Le refus de l’ajout est enregistré localement. Aucun ajout ni retrait ne sera effectué.')
                : 'L’accord est enregistré sans connexion. L’ajout au DMP attend une demande explicite de consultation.',
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: answer == null ? null : () => Navigator.pop(context, answer),
        child: const Text('Enregistrer la réponse'),
      ),
    ],
  );
}
