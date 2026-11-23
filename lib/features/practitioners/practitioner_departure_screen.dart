import 'package:flutter/material.dart';
import 'data/practitioner_repository.dart';
import 'data/practitioner_departure_patient.dart';
import 'models/practitioner.dart';
import 'services/practitioner_departure_export_service.dart';

class PractitionerDepartureScreen extends StatefulWidget {
  const PractitionerDepartureScreen({
    super.key,
    required this.practitioner,
    required this.repository,
    this.exporter,
  });
  final Practitioner practitioner;
  final PractitionerRepository repository;
  final PractitionerDepartureExportService? exporter;
  @override
  State<PractitionerDepartureScreen> createState() => _DepartureState();
}

class _DepartureState extends State<PractitionerDepartureScreen> {
  List<PractitionerDeparturePatient>? patients;
  final selected = <String>{};
  DateTime departure = DateUtils.dateOnly(DateTime.now());
  bool export = false, busy = false;
  String? error, exportedPath;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final list = await widget.repository.departurePatients(
        widget.practitioner.practitionerId,
      );
      if (!mounted) return;
      setState(() {
        patients = list;
        selected.addAll(list.where((p) => p.active).map((p) => p.id));
      });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  String date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  Future<void> save() async {
    setState(() {
      busy = true;
      error = null;
      exportedPath = null;
    });
    try {
      DepartureExportReceipt? receipt;
      if (export) {
        receipt =
            await (widget.exporter ?? PractitionerDepartureExportService())
                .export(widget.practitioner.practitionerId, selected);
        if (receipt == null) return;
        exportedPath = receipt.path;
      }
      await widget.repository.archivePractitioner(
        widget.practitioner.practitionerId,
        departureDate: departure,
        expectedPatientIds: patients!.map((p) => p.id).toSet(),
        verifyExport: receipt?.verifyDatabase,
      );
      if (!mounted) return;
      final message = exportedPath == null
          ? 'Kiné archivé. Ses dossiers sont désormais non affectés.'
          : 'Kiné archivé. Export conservé dans : $exportedPath';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 10)),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(
          () => error =
              '$e${exportedPath == null ? '' : '\nExport conservé dans : $exportedPath'}',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(
        title: Text('Départ de ${widget.practitioner.displayName}'),
        automaticallyImplyLeading: !busy,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Tous les dossiers dont ce kiné est référent deviendront « Non affectés ». Son nom sera conservé comme ancien référent, avec la date de départ. Aucun patient ni document ne sera supprimé.',
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: busy
                    ? null
                    : () async {
                        final value = await showDatePicker(
                          context: context,
                          initialDate: departure,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (value != null && mounted) {
                          setState(() => departure = value);
                        }
                      },
                child: Text('Date de départ : ${date(departure)}'),
              ),
              if (patients == null && error == null)
                const Center(child: CircularProgressIndicator()),
              if (patients != null) ...[
                Text('${patients!.length} dossier(s) concerné(s).'),
                CheckboxListTile(
                  title: const Text(
                    'Exporter les patients actifs, à la demande du kiné',
                  ),
                  value: export,
                  onChanged: busy ? null : (v) => setState(() => export = v!),
                ),
                if (export) ...[
                  const Text(
                    'Les patients ayant un test, un bilan ou une modification de rapport au cours des trois derniers mois sont présélectionnés. Vérifiez et ajustez la sélection selon leur suivi réel. Une ancienne date de rapport ou de brouillon peut être indicative.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'L’export contient des données de santé en clair. Privilégiez un support externe conservé dans un endroit protégé. Il contient des données JSON et les documents ; ce n’est pas une sauvegarde restaurable dans Companion.',
                  ),
                  const SizedBox(height: 12),
                  Text('${selected.length} patient(s) sélectionné(s)'),
                  for (final patient in patients!)
                    CheckboxListTile(
                      value: selected.contains(patient.id),
                      title: Text(patient.name),
                      subtitle: Text(
                        '${patient.archived ? 'Dossier archivé · ' : ''}${patient.lastActivity == null ? 'Aucune activité datée' : 'Dernière activité : ${date(patient.lastActivity!)}'}${patient.inferred ? ' · date indicative' : ''}',
                      ),
                      onChanged: busy
                          ? null
                          : (v) => setState(() {
                              if (v!) {
                                selected.add(patient.id);
                              } else {
                                selected.remove(patient.id);
                              }
                            }),
                    ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy ? null : save,
                  child: Text(
                    busy
                        ? 'Traitement en cours…'
                        : export
                        ? 'Exporter puis archiver'
                        : 'Archiver sans export',
                  ),
                ),
              ],
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
