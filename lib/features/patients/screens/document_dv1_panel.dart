import '../services/dmp_chain/native/dv1_replacement.dart';
import 'dart:convert';
import '../../dmp_dv1_access/access_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/episode_document_version.dart';
import '../services/document_journal_service.dart';
import '../services/document_lot_signature_service.dart';
import '../services/dmp_chain/chain_service.dart';
import '../services/dmp_chain/contracts.dart';
import '../services/dmp_chain/native/dv1_configuration.dart';
import '../services/dmp_chain/native/dv1_review.dart';
import '../services/dmp_chain/native/dv1_retry.dart';

/// Normal document workflow. Loading/configuring this panel never reads the CPS
/// and never contacts DV1. Only the two explicit, confirmed actions do so.
class DocumentDv1Panel extends StatefulWidget {
  const DocumentDv1Panel({
    super.key,
    required this.journal,
    required this.version,
    required this.enabled,
    required this.onBusy,
    required this.onCompleted,
  });
  final DocumentJournalService journal;
  final EpisodeDocumentVersion version;
  final bool enabled;
  final ValueChanged<bool> onBusy;
  final Future<void> Function() onCompleted;
  @override
  State<DocumentDv1Panel> createState() => _DocumentDv1PanelState();
}

class _DocumentDv1PanelState extends State<DocumentDv1Panel> {
  bool busy = false, ready = false, held = true, retryReady = false;
  String? searchVersionId;
  bool canReplace = false, replacing = false;
  String retryLabel = 'Reprendre après le rejet SOAP';
  Dv1Configuration? config;
  String message = 'Lecture de la configuration…';
  Dv1ConfigurationService get settings =>
      Dv1ConfigurationService(widget.journal);
  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void didUpdateWidget(DocumentDv1Panel old) {
    super.didUpdateWidget(old);
    if (!busy &&
        (old.version.id != widget.version.id ||
            old.enabled != widget.enabled)) {
      refresh();
    }
  }

  Future<void> refresh() async {
    final selected = widget.version;
    var canPrepare = false, retained = true, canRetry = false;
    Dv1Configuration? configuration;
    String label = retryLabel;
    String? acceptedVersion;
    var replacementCandidate = false, replacementConfigured = false;
    String text;
    try {
      final db = await widget.journal.database;
      try {
        replacementConfigured =
            await Dv1Replacement.check(db, selected) != null;
        if (!replacementConfigured) {
          await Dv1Replacement.candidate(db, selected);
          replacementCandidate = true;
        }
      } catch (_) {}
      configuration = await settings.current();
      if (configuration == null) {
        text =
            'Configurez la recette DV1 avec les paramètres et fichiers officiels.';
      } else {
        await settings.unchanged(configuration);
        final status = await widget.journal.status(selected);
        retained = status.held;
        if (status.attempt != null || status.state == 'restored') {
          text = status.message;
          if (status.attempt?['mode'] == 'dv1' &&
              status.attempt?['outcome'] == 'accepted') {
            acceptedVersion = status.attempt!['version_id'] as String;
          } else if (status.attempt != null) {
            try {
              final review = await Dv1Retry.inspect(
                await widget.journal.database,
                selected,
                await widget.journal.controls.root,
              );
              final prepared = await widget.journal.prepare(
                selected,
                retry: review,
              );
              review.checkPreparation(
                prepared.receipt,
                prepared.run,
                prepared.payloadHash,
              );
              canRetry = true;
              label = review.label;
              text +=
                  ' Rejet vérifié : une reprise avec ${review.correction} est possible sur confirmation. Les tentatives précédentes restent conservées.';
            } catch (e) {
              text += e is StateError
                  ? ' Reprise indisponible : ${e.message}'
                  : ' Reprise indisponible : les preuves ne sont pas vérifiables.';
            }
          }
        } else {
          final prepared = await widget.journal.prepare(selected);
          final snapshot = jsonDecode(
            prepared.receipt['snapshot_json'] as String,
          );
          final context = jsonDecode(snapshot['practice']['data_json']);
          if (context['identifier'] != configuration.professional) {
            throw StateError(
              'Le professionnel validé diffère de la configuration CPS.',
            );
          }
          if (!configuration.codes(snapshot)) {
            throw StateError(
              'Les codes du document ne concordent pas avec les nomenclatures importées.',
            );
          }
          await DocumentLotSignatureService(
            widget.journal,
          ).checkBeforeDv1(selected);
          canPrepare = true;
          text =
              'Configuration DV1 n°${configuration.revision}. PDF validé et contrôles locaux conformes. '
              '${retained ? 'Dépôt retenu.' : 'Dépôt soumis à confirmation.'} Aucun appel automatique.';
        }
      }
    } catch (e) {
      text = e is StateError
          ? e.message.toString()
          : 'Configuration ou préparation locale non vérifiable. Vérifiez les fichiers et les contrôles du document.';
    }
    if (mounted && selected.id == widget.version.id) {
      setState(() {
        config = configuration;
        canReplace = replacementCandidate;
        replacing = replacementConfigured;
        searchVersionId = acceptedVersion;
        ready = canPrepare;
        retryReady = canRetry;
        retryLabel = label;
        held = retained;
        message = text;
      });
    }
  }

  Future<void> configureReplacement() async {
    if (busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Préparer le remplacement sur DV1 ?'),
        content: const Text(
          'Cette nouvelle version remplacera le dernier document accepté de cette pièce. Vous devrez relire et valider le PDF, puis refaire les contrôles CDA. Aucun envoi maintenant. Au moment de l’envoi confirmé, une nouvelle recherche vérifiera la cible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Préparer le remplacement'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => busy = true);
    widget.onBusy(true);
    try {
      await Dv1Replacement.configure(
        await widget.journal.database,
        widget.version,
      );
      await refresh();
      await widget.onCompleted();
      if (mounted) {
        setState(
          () => message =
              'Remplacement préparé. Relisez et validez cette nouvelle version PDF, puis lancez les contrôles avant de lever la retenue et confirmer le remplacement.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => message = 'Préparation du remplacement impossible : $e');
      }
    } finally {
      widget.onBusy(false);
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> configure() async {
    if (busy) return;
    setState(() => busy = true);
    widget.onBusy(true);
    try {
      final old = await settings.current();
      if (!mounted) return;
      final saved = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dv1SettingsDialog(service: settings, previous: old),
      );
      if (saved == true) {
        await refresh();
        await widget.onCompleted();
      }
    } finally {
      widget.onBusy(false);
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> run(bool accessOnly, {bool retrying = false}) async {
    if (busy || !widget.enabled) return;
    final version = widget.version;
    String? pin;
    setState(() => busy = true);
    widget.onBusy(true);
    try {
      final configuration = await settings.current();
      if (configuration == null) throw StateError('Configuration DV1 absente.');
      await settings.unchanged(configuration);
      final status = await widget.journal.status(version);
      final retry = retrying && !accessOnly
          ? await Dv1Retry.inspect(
              await widget.journal.database,
              version,
              await widget.journal.controls.root,
            )
          : null;
      final prepared = await widget.journal.prepare(version, retry: retry);
      retry?.checkPreparation(
        prepared.receipt,
        prepared.run,
        prepared.payloadHash,
      );
      if ((status.attempt != null && retry == null) ||
          status.state == 'restored' ||
          (!accessOnly && status.held)) {
        throw StateError(status.message);
      }
      if (!mounted) return;
      final confirmed = await showDialog<_Dv1Consent>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _Dv1Confirm(
          version: version,
          prepared: prepared,
          configuration: configuration,
          accessOnly: accessOnly,
          retry: retry,
        ),
      );
      if (confirmed == null || !mounted || widget.version.id != version.id) {
        return;
      }
      pin = confirmed.pin;
      confirmed.pin = ''; // The secret is neither journalled nor saved.
      final review = Dv1Review(
        prepared: prepared,
        configurationHash: configuration.hash,
        scenario: confirmed.scenario,
        source: confirmed.source,
        observedAt: widget.journal.medical.now().toUtc(),
        noOpposition: true,
        functionalRights: true,
        testIdentity: true,
        actor: true,
      );
      final result = await DocumentDmpChain(journal: widget.journal).executeDv1(
        version,
        configuration: configuration,
        review: review,
        accessOnly: accessOnly,
        retry: retry,
        requestPin: () async {
          final value = pin;
          pin = null;
          return value;
        },
      );
      await refresh();
      await widget.onCompleted();
      if (mounted) setState(() => message = result.message);
    } catch (e) {
      await widget.onCompleted();
      if (mounted) {
        setState(
          () => message = e is DmpChainBlock
              ? e.message
              : e is StateError
              ? e.message.toString()
              : 'Préparation DV1 interrompue. Consultez le journal ; aucun nouvel essai automatique.',
        );
      }
    } finally {
      pin = null;
      widget.onBusy(false);
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Divider(),
      Text(
        'Recette DMP sur DV1',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const Text(
        'Accès réel au serveur de test, avec une CPS et un patient de test. '
        'Profil pris en charge : kiné auteur et validateur, en ambulatoire, patient majeur, document visible. '
        'La vérification d’accès ne dépose rien. Le dépôt crée une tentative conservée dans ce journal.',
      ),
      Text(message, key: const Key('dv1-status')),
      OutlinedButton(
        onPressed: busy || !widget.enabled ? null : configure,
        child: const Text('Configurer la recette DV1'),
      ),
      OutlinedButton(
        onPressed: busy || !widget.enabled || !ready || replacing
            ? null
            : () => run(true),
        child: const Text('Vérifier l’accès DV1 — sans dépôt'),
      ),
      FilledButton(
        onPressed: busy || !widget.enabled || !ready || held
            ? null
            : () => run(false),
        child: Text(
          replacing
              ? 'Signer et remplacer sur DV1 — PRE_ALIM_RPLC'
              : 'Signer et déposer sur DV1',
        ),
      ),
      if (canReplace)
        OutlinedButton(
          onPressed: busy ? null : configureReplacement,
          child: const Text('Préparer le remplacement — PRE_ALIM_RPLC'),
        ),
      if (searchVersionId == widget.version.id)
        const Text(
          'Pour PRE_ALIM_RPLC, importez une nouvelle version PDF modifiée de cette même pièce, puis préparez son remplacement.',
        ),
      if (searchVersionId != null)
        OutlinedButton(
          key: const Key('dv1-prepare-search'),
          onPressed: busy
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        Dv1AccessScreen(searchVersionId: searchVersionId),
                  ),
                ),
          child: const Text(
            'Préparer la recherche du document — PRE_ALIM_RECH',
          ),
        ),
      if (retryReady)
        FilledButton(
          key: const Key('dv1-retry-soap'),
          onPressed: busy || !widget.enabled || held
              ? null
              : () => run(false, retrying: true),
          child: Text(retryLabel),
        ),
      TextButton(
        onPressed: busy ? null : refresh,
        child: const Text('Actualiser la préparation DV1'),
      ),
      if (busy) const LinearProgressIndicator(),
    ],
  );
}

class Dv1SettingsDialog extends StatefulWidget {
  const Dv1SettingsDialog({super.key, required this.service, this.previous});
  final Dv1ConfigurationService service;
  final Dv1Configuration? previous;
  @override
  State<Dv1SettingsDialog> createState() => Dv1SettingsDialogState();
}

class Dv1SettingsDialogState extends State<Dv1SettingsDialog> {
  late final Map<String, TextEditingController> fields;
  final files = <String, String>{};
  bool saving = false;
  String error = '';
  @override
  void initState() {
    super.initState();
    fields = {
      for (final key in Dv1ConfigurationService.labels.keys)
        key: TextEditingController(
          text: widget.previous?.fields[key] as String? ?? '',
        ),
    };
    final bundled = Dv1ConfigurationService.bundledCpsJava;
    if (bundled != null) fields['java']!.text = bundled;
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pick(String key) async {
    final String? path;
    if (key == 'nos') {
      path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Nomenclatures officielles archivées',
      );
    } else {
      path = (await FilePicker.platform.pickFiles(
        dialogTitle: Dv1ConfigurationService.fileLabels[key],
        allowMultiple: false,
      ))?.files.single.path;
    }
    if (mounted && path != null) setState(() => files[key] = path!);
  }

  Future<void> save() async {
    setState(() {
      saving = true;
      error = '';
    });
    try {
      await widget.service.save(
        {for (final e in fields.entries) e.key: e.value.text.trim()},
        files,
        widget.previous?.revision ?? 0,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is StateError
              ? e.message.toString()
              : 'Fichier ou paramètre invalide. Vérifiez le format et les ressources sélectionnées.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Configuration de recette DV1'),
    content: SizedBox(
      width: 680,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ces réglages sont enregistrés sans connexion et sans lecture de la CPS. '
              'Les adresses sont limitées à DV1. Utilisez les identifiants de recette et les ressources officielles ; aucune valeur fictive n’est ajoutée.',
            ),
            for (final e in Dv1ConfigurationService.labels.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: TextField(
                  controller: fields[e.key],
                  enabled: !saving,
                  readOnly:
                      e.key == 'java' &&
                      Dv1ConfigurationService.bundledCpsJava != null,
                  decoration: InputDecoration(
                    labelText:
                        e.key == 'java' &&
                            Dv1ConfigurationService.bundledCpsJava != null
                        ? 'Moteur CPS intégré à Companion'
                        : e.value,
                  ),
                ),
              ),
            for (final e in Dv1ConfigurationService.fileLabels.entries)
              ListTile(
                title: Text(e.value),
                subtitle: Text(
                  files[e.key] ??
                      (widget.previous == null
                          ? 'À sélectionner'
                          : 'Copie enregistrée conservée'),
                ),
                trailing: TextButton(
                  onPressed: saving ? null : () => pick(e.key),
                  child: const Text('Choisir'),
                ),
              ),
            ExpansionTile(
              title: const Text(
                'Fichiers attendus dans le dossier des nomenclatures',
              ),
              children: [
                for (final name in Dv1Configuration.nosFiles.values)
                  SelectableText(name),
              ],
            ),
            if (error.isNotEmpty) Text(error),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context, false),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: saving ? null : save,
        child: const Text('Enregistrer sans connexion'),
      ),
    ],
  );
}

class _Dv1Consent {
  _Dv1Consent(this.pin, this.scenario, this.source);
  String pin;
  final String scenario, source;
}

class _Dv1Confirm extends StatefulWidget {
  const _Dv1Confirm({
    required this.version,
    required this.prepared,
    required this.configuration,
    required this.accessOnly,
    this.retry,
  });
  final EpisodeDocumentVersion version;
  final DocumentAttemptPreparation prepared;
  final Dv1Configuration configuration;
  final bool accessOnly;
  final Dv1RetryReview? retry;
  @override
  State<_Dv1Confirm> createState() => _Dv1ConfirmState();
}

class _Dv1ConfirmState extends State<_Dv1Confirm> {
  @override
  void initState() {
    super.initState();
    final snapshot =
        jsonDecode(widget.prepared.receipt['snapshot_json'] as String) as Map;
    final recipe = snapshot['cndaRecipe'];
    if (recipe is Map) {
      source.text = recipe['source'] as String;
      scenario.text = widget.accessOnly ? 'PRE_TD0.2' : 'PRE_ALIM_N1';
    }
    replacement = Dv1Replacement.fromPreparation(
      jsonDecode(snapshot['preparation']['data_json']),
    );
    if (replacement != null) scenario.text = 'PRE_ALIM_RPLC';
  }

  final pin = TextEditingController(),
      scenario = TextEditingController(),
      source = TextEditingController();
  final checks = [false, false, false, false];
  Map<String, dynamic>? replacement;
  bool retryConfirmed = false;
  @override
  void dispose() {
    pin.clear();
    pin.dispose();
    scenario.dispose();
    source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = jsonDecode(
      widget.prepared.receipt['snapshot_json'] as String,
    );
    final patient = snapshot['identity'];
    final enabled =
        checks.every((b) => b) &&
        (widget.retry?.attemptId == null || retryConfirmed) &&
        pin.text.isNotEmpty &&
        scenario.text.trim().isNotEmpty &&
        source.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(
        widget.accessOnly
            ? 'Vérifier l’accès sur DV1 ?'
            : widget.retry?.attemptId != null
            ? '${widget.retry!.label} ?'
            : replacement != null
            ? 'Remplacer le document sur DV1 ?'
            : 'Signer et déposer ce document sur DV1 ?',
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Patient : ${patient['birth_last_name']} ${patient['birth_first_names']} · ${patient['birth_date']}\n'
                'CPS : ${widget.configuration.professional}\nPDF version ${widget.version.number} · ${widget.version.digest.substring(0, 12)}\n'
                '${widget.accessOnly ? 'La CPS sera sollicitée pour l’accès TD0.2. Aucun dépôt.' : 'La CPS authentifiera la session et signera le lot contenant ce PDF et son CDA. Une seule tentative sera permise.'}',
              ),
              if (widget.retry?.attemptId != null)
                CheckboxListTile(
                  value: retryConfirmed,
                  onChanged: (value) =>
                      setState(() => retryConfirmed = value == true),
                  title: Text(
                    'Je confirme une nouvelle tentative avec ${widget.retry!.correction}.',
                  ),
                  subtitle: Text(
                    'Tentative précédente conservée : ${widget.retry?.attemptId}. ${widget.retry!.signatureTitle
                        ? 'Le serveur a rejeté la cohérence du titre de signature.'
                        : widget.retry!.metadata
                        ? 'Le serveur a rejeté les libellés et métadonnées de signature du dépôt.'
                        : widget.retry!.patientId
                        ? 'Le serveur a rejeté les métadonnées patientId du dépôt.'
                        : 'Le serveur a refusé l’en-tête avant le traitement du dépôt.'} Une seule reprise pour ce rejet ; aucune relance automatique.',
                  ),
                ),
              if (replacement != null)
                SelectableText(
                  'PRE_ALIM_RPLC : la nouvelle version remplacera le document ${replacement!['uniqueId']}. L’ancien document deviendra obsolète. La cible sera recherchée à nouveau avant signature et envoi.',
                ),
              TextField(
                controller: scenario,
                maxLength: 100,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Scénario du PDT personnalisé',
                ),
              ),
              TextField(
                controller: source,
                maxLength: 2000,
                maxLines: 2,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText:
                      'Source du contrôle des conditions et des droits (PDT, constat Web-PS…)',
                ),
              ),
              for (final e in <String>[
                'Ce patient et cette CPS sont ceux prévus pour ce scénario de test DV1.',
                'Je suis le professionnel indiqué et je confirme cette version du document.',
                'L’absence d’opposition au dépôt a été vérifiée pour ce scénario.',
                'Les droits de dépôt applicables à ce professionnel et à ce document ont été vérifiés.',
              ].asMap().entries)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: checks[e.key],
                  title: Text(e.value),
                  onChanged: (v) => setState(() => checks[e.key] = v == true),
                ),
              const Text(
                'Ces confirmations manuelles sont conservées avec la tentative. Le consentement à la consultation ne remplace pas ces conditions.',
              ),
              TextField(
                controller: pin,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                onChanged: (_) => setState(() {}),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: const InputDecoration(
                  labelText: 'PIN de la CPS (non conservé)',
                ),
              ),
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
          onPressed: enabled
              ? () => Navigator.pop(
                  context,
                  _Dv1Consent(
                    pin.text,
                    scenario.text.trim(),
                    source.text.trim(),
                  ),
                )
              : null,
          child: Text(
            widget.accessOnly
                ? 'Confirmer la vérification d’accès'
                : widget.retry?.attemptId != null
                ? 'Confirmer la reprise sur DV1'
                : replacement != null
                ? 'Confirmer le remplacement sur DV1'
                : 'Confirmer la signature et le dépôt DV1',
          ),
        ),
      ],
    );
  }
}
