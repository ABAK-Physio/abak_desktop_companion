import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/settings/cabinet_practice_service.dart';
import '../../core/settings/report_prefill_settings.dart';
import '../patients/services/document_medical_service.dart';
import '../patients/services/final_pdf_document_service.dart';
import 'data/practitioner_cps_service.dart';
import 'widgets/practitioner_situation_dialog.dart';

class PractitionerReportSettingsScreen extends StatefulWidget {
  const PractitionerReportSettingsScreen({
    super.key,
    required this.practitionerId,
    required this.name,
    this.service,
  });
  final String practitionerId, name;
  final DocumentMedicalService? service;
  @override
  State<PractitionerReportSettingsScreen> createState() =>
      _PractitionerReportSettingsScreenState();
}

class _PractitionerReportSettingsScreenState
    extends State<PractitionerReportSettingsScreen> {
  late final service =
      widget.service ?? DocumentMedicalService(pdf: FinalPdfDocumentService());
  List<MedicalRow> contexts = [];
  Map<String, String>? previous;
  String contextId = '', selfValidator = '', error = '', message = '';
  bool busy = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final prefs = await ReportPrefillSettings.read(
        await service.pdf.database(),
        'practitioner',
        widget.practitionerId,
      );
      final rows = await service.contexts(widget.practitionerId);
      if (mounted) {
        setState(() {
          previous = prefs;
          contextId = prefs['contextId']!;
          selfValidator = prefs['selfValidator']!;
          contexts = rows;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> edit(MedicalRow? row) async {
    setState(() {
      busy = true;
      error = '';
      message = '';
    });
    try {
      final stored = await service.cpsInformation(widget.practitionerId);
      final reading = stored == null
          ? null
          : PractitionerCpsReading.fromStored(stored);
      final dates = reading == null
          ? null
          : PractitionerCpsService.datesFromStored(
              reading,
              await service.cpsDatesInformation(widget.practitionerId),
            );
      final cabinet = await CabinetPracticeService.forAuthor(
        await service.pdf.database(),
        widget.practitionerId,
      );
      if (!mounted) return;
      final saved = await showDialog<MedicalRow>(
        context: context,
        builder: (_) => PractitionerSituationDialog(
          service: service,
          practitioner: widget.practitionerId,
          initial: row,
          cps: reading,
          dates: dates,
          cabinet: cabinet,
        ),
      );
      if (saved == null) return;
      final rows = await service.contexts(widget.practitionerId);
      if (mounted) {
        setState(() {
          contexts = rows;
          message =
              'Situation enregistrée dans la fiche du kiné et disponible pour ses rapports.';
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    setState(() {
      busy = true;
      error = '';
      message = '';
    });
    try {
      final values = {'contextId': contextId, 'selfValidator': selfValidator};
      await ReportPrefillSettings.save(
        await service.pdf.database(),
        'practitioner',
        widget.practitionerId,
        values,
        previous!,
      );
      if (mounted) {
        setState(() {
          previous = values;
          message =
              'Préférences enregistrées. Aucune validation médicale effectuée.';
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String label(MedicalRow row) {
    final data = jsonDecode(row['data_json'] as String) as Map;
    return 'Situation ${data['situation']} · ${data['structureName']} · ${data['setting']}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${widget.name} — paramètres des rapports')),
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
            const Text(
              'Ces informations appartiennent au kiné. Les données CPS déjà enregistrées et les paramètres du cabinet sont repris sans lire la carte.',
            ),
            const SizedBox(height: 16),
            Text(
              'Situations d’exercice enregistrées',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text(
              'Une situation peut servir à plusieurs rapports. Sa modification rend nécessaire une nouvelle validation des versions qui l’utilisaient.',
            ),
            for (final row in contexts)
              ListTile(
                title: Text(label(row)),
                trailing: IconButton(
                  tooltip: 'Examiner ou compléter la situation',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: busy ? null : () => edit(row),
                ),
              ),
            if (contexts.isEmpty) const Text('Aucune situation complétée.'),
            OutlinedButton(
              onPressed: busy ? null : () => edit(null),
              child: const Text('Ajouter une situation d’exercice'),
            ),
            const Divider(height: 32),
            DropdownButtonFormField<String>(
              key: ValueKey('preferred-context-$contextId-${contexts.length}'),
              initialValue: contextId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Situation habituelle pour les rapports',
              ),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Automatique si une seule situation convient'),
                ),
                if (contextId.isNotEmpty &&
                    !contexts.any((r) => r['context_id'] == contextId))
                  DropdownMenuItem(
                    value: contextId,
                    child: const Text(
                      'Situation enregistrée devenue indisponible',
                    ),
                  ),
                for (final row in contexts)
                  DropdownMenuItem(
                    value: row['context_id'] as String,
                    child: Text(label(row), overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: busy
                  ? null
                  : (v) => setState(() {
                      contextId = v ?? '';
                      message = '';
                    }),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('self-validator-$selfValidator'),
              initialValue: selfValidator,
              decoration: const InputDecoration(
                labelText: 'Validateur proposé pour ses propres rapports',
              ),
              items: const [
                DropdownMenuItem(
                  value: '',
                  child: Text('À choisir dans chaque rapport'),
                ),
                DropdownMenuItem(
                  value: 'yes',
                  child: Text('Proposer ce kiné comme validateur'),
                ),
                DropdownMenuItem(
                  value: 'no',
                  child: Text('Laisser le choix du validateur vide'),
                ),
              ],
              onChanged: busy
                  ? null
                  : (v) => setState(() {
                      selfValidator = v ?? '';
                      message = '';
                    }),
            ),
            const Text(
              'La proposition ne vaut ni validation, ni authentification, ni signature. Le kiné référent du patient n’est pas utilisé à la place du rédacteur.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: busy || previous == null ? null : save,
              child: const Text('Enregistrer les préférences du kiné'),
            ),
            if (message.isNotEmpty) Text(message),
          ],
        ),
      ),
    ),
  );
}
