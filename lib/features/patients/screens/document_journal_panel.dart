import 'package:flutter/material.dart';
import 'document_dv1_panel.dart';
import 'package:flutter/services.dart';
import '../models/episode_document_version.dart';
import '../services/document_journal_service.dart';
import '../services/document_medical_service.dart';
import '../services/document_reconciliation_service.dart';
import '../services/document_lot_signature_service.dart';

typedef DocumentArchivePicker =
    Future<({String headers, List<int> bytes})?> Function();

class DocumentJournalPanel extends StatefulWidget {
  const DocumentJournalPanel({
    super.key,
    required this.service,
    required this.version,
    required this.enabled,
    this.reconciliation,
    this.pickArchive,
    this.onSigningBusy,
  });
  final DocumentJournalService service;
  final EpisodeDocumentVersion version;
  final bool enabled;
  // Explicit isolated capability. The ordinary product route has no archive
  // write action; the service checks the synthetic database/filesystem scope.
  final DocumentReconciliationService? reconciliation;
  final DocumentArchivePicker? pickArchive;
  final ValueChanged<bool>? onSigningBusy;
  @override
  State<DocumentJournalPanel> createState() => _DocumentJournalPanelState();
}

class _DocumentJournalPanelState extends State<DocumentJournalPanel>
    with WidgetsBindingObserver {
  DocumentJournalStatus? status;
  List<MedicalRow> events = [];
  String error = '';
  bool busy = false;
  DocumentLotSignatureStatus? signatureStatus;
  DocumentLotSignatureService get signatures =>
      DocumentLotSignatureService(widget.service);
  int refreshSequence = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DocumentJournalPanel old) {
    super.didUpdateWidget(old);
    if (old.version.id != widget.version.id || old.enabled != widget.enabled) {
      refresh();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed && !busy) refresh();
  }

  Future<void> refresh() async {
    final sequence = ++refreshSequence;
    final version = widget.version;
    try {
      final signature = await signatures.status(version);
      final s = await widget.service.status(version),
          e = await widget.service.history(version.documentId);
      if (mounted &&
          sequence == refreshSequence &&
          widget.version.id == version.id) {
        setState(() {
          status = s;
          signatureStatus = signature;
          events = e;
          error = '';
        });
      }
    } catch (e) {
      if (mounted && sequence == refreshSequence) {
        setState(() {
          status = null;
          signatureStatus = null;
          error = 'Journal indisponible : $e';
        });
      }
    }
  }

  Future<void> signLot() async {
    final review = signatureStatus?.review;
    if (busy || !widget.enabled || review == null) return;
    final selected = widget.version;
    String? pin;
    setState(() => busy = true);
    widget.onSigningBusy?.call(true);
    try {
      pin = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _LotPinDialog(review: review, version: selected),
      );
      if (pin == null || !mounted || widget.version.id != selected.id) return;
      await signatures.sign(selected, review, pin);
      await refresh();
    } catch (e) {
      await refresh();
      if (mounted) {
        setState(() => error = DocumentLotSignatureService.errorMessage(e));
      }
    } finally {
      pin = null;
      widget.onSigningBusy?.call(false);
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> hold(bool value) async {
    setState(() => busy = true);
    try {
      await widget.service.hold(
        widget.version,
        value,
        expectedRevision: status!.revision,
      );
      await refresh();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> examineArchive() async {
    final selected = widget.version;
    final service = widget.reconciliation;
    if (busy ||
        !widget.enabled ||
        service == null ||
        widget.pickArchive == null) {
      return;
    }
    setState(() => busy = true);
    try {
      final archive = await widget.pickArchive!();
      if (archive == null || !mounted || widget.version.id != selected.id) {
        return;
      }
      final review = await service.preview(
        selected,
        headers: archive.headers,
        bytes: archive.bytes,
      );
      if (!mounted || widget.version.id != selected.id) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Examiner la réponse archivée'),
          content: SingleChildScrollView(
            child: Text(
              'Pièce : ${review.documentId}\nVersion de la tentative : ${review.versionId}\n\n${review.message}\n\nCette confirmation conserve une observation dans le stockage isolé. Elle ne relance aucun traitement.',
              key: const Key('archive-review-message'),
            ),
          ),
          actions: [
            TextButton(
              key: const Key('cancel-archive-review'),
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              key: const Key('confirm-archive-review'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Conserver cet examen'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted || widget.version.id != selected.id) {
        return;
      }
      await service.confirm(review, confirmed: true);
      await refresh();
    } catch (e) {
      if (mounted) {
        setState(() => error = 'Examen de l’archive impossible : $e');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Suivi de la préparation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            status?.message ?? 'Lecture du journal…',
            key: const Key('document-journal-status'),
          ),
          if (status?.reconciliation.isNotEmpty == true)
            Text(
              status!.reconciliation,
              key: const Key('document-reconciliation-status'),
            ),
          if (status?.attempt?['detail'] != null)
            Text('Résultat initial conservé : ${status!.attempt!["detail"]}'),
          SwitchListTile(
            key: const Key('document-hold'),
            title: const Text('Retenir le traitement de cette version'),
            subtitle: const Text(
              'La levée de retenue ne lance aucun envoi. Une nouvelle version est retenue par défaut.',
            ),
            value: status?.held ?? true,
            onChanged: busy || !widget.enabled || status?.canChangeHold != true
                ? null
                : hold,
          ),
          const Text(
            'Les contrôles, signatures et tentatives DV1 figurent dans ce journal. Les résultats des simulations sont identifiés séparément et ne prouvent aucun dépôt.',
          ),
          const SizedBox(height: 12),
          Text(
            'Signature CPS du lot',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            signatureStatus?.message ??
                'Lecture de la préparation de signature…',
            key: const Key('document-lot-signature-status'),
          ),
          OutlinedButton.icon(
            key: const Key('sign-document-lot-cps'),
            onPressed:
                busy || !widget.enabled || signatureStatus?.review == null
                ? null
                : signLot,
            icon: const Icon(Icons.draw_outlined),
            label: const Text('Signer le lot localement avec ma CPS'),
          ),
          if (widget.reconciliation == null)
            DocumentDv1Panel(
              journal: widget.service,
              version: widget.version,
              enabled: widget.enabled && !busy,
              onCompleted: refresh,
              onBusy: (value) {
                if (mounted) setState(() => busy = value);
                widget.onSigningBusy?.call(value);
              },
            ),
          if (error.isNotEmpty)
            Text(error, key: const Key('document-journal-error')),
          if (widget.reconciliation != null && widget.pickArchive != null)
            OutlinedButton(
              key: const Key('examine-document-archive'),
              onPressed: busy || !widget.enabled || status == null
                  ? null
                  : examineArchive,
              child: const Text(
                'Examiner une réponse archivée — stockage isolé',
              ),
            ),
          TextButton(
            key: const Key('document-journal-refresh'),
            onPressed: busy ? null : refresh,
            child: const Text('Actualiser le suivi'),
          ),
          ExpansionTile(
            title: Text('Journal commun (${events.length})'),
            children: [
              for (final e in events)
                ExpansionTile(
                  title: Text(e['detail'] as String),
                  subtitle: Text(
                    '${e['version_number'] != null
                        ? 'PDF version ${e['version_number']}'
                        : e['version_id'] != null
                        ? 'Version PDF non retrouvée'
                        : 'Événement général'} · ${DateTime.fromMillisecondsSinceEpoch(e['created_at'] as int).toLocal()}',
                  ),
                  children: [
                    ListTile(
                      title: const Text('Détails techniques — assistance'),
                      subtitle: SelectableText(
                        'Événement : ${e['event_id']}\n'
                        'Type : ${e['kind']}\n'
                        '${e['version_id'] != null ? 'Identifiant de version : ${e['version_id']}\n' : ''}'
                        '${e['reference_id'] != null ? 'Référence : ${e['reference_id']}' : ''}',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _LotPinDialog extends StatefulWidget {
  const _LotPinDialog({required this.review, required this.version});
  final DocumentLotSignatureReview review;
  final EpisodeDocumentVersion version;
  @override
  State<_LotPinDialog> createState() => _LotPinDialogState();
}

class _LotPinDialogState extends State<_LotPinDialog> {
  final pin = TextEditingController();
  bool confirmed = false;
  @override
  void dispose() {
    pin.clear();
    pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Signer ce lot avec votre CPS ?'),
    content: SizedBox(
      width: 540,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signataire : ${widget.review.professionalName}\nIdentifiant : ${widget.review.professional}\n'
              'Patient du dossier : ${widget.version.values['patient_id']}\n'
              'PDF version ${widget.version.number} · empreinte ${widget.version.digest.substring(0, 12)}\n\n'
              'La CPS sera sollicitée pour signer le lot contenant le CDA et ce PDF validé. '
              'Le PDF figé reste identique. Aucun document ne sera envoyé. '
              'La vérification de confiance et de révocation du certificat reste à effectuer avant un dépôt.',
            ),
            CheckboxListTile(
              value: confirmed,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Je suis ce signataire et je confirme la signature de cette version.',
              ),
              onChanged: (value) => setState(() => confirmed = value == true),
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
              decoration: const InputDecoration(labelText: 'PIN de votre CPS'),
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
        onPressed: confirmed && pin.text.isNotEmpty
            ? () => Navigator.pop(context, pin.text)
            : null,
        child: const Text('Confirmer et signer localement'),
      ),
    ],
  );
}
