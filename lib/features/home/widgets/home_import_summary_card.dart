import 'package:flutter/material.dart';
import '../../patients/patient_detail_screen.dart';
import '../../patients/data/patient_repository.dart';
import '../../import_export/abak_import_launcher.dart';
import 'package:intl/intl.dart';

class HomeImportSummaryCard extends StatelessWidget {
  final AbakImportLauncherResult result;

  HomeImportSummaryCard({
    super.key,
    required this.result,
  });

  final _patientRepository = PatientRepository();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.hasFailures
                        ? Icons.warning_amber_outlined
                        : Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dernier import ABAK',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ],
              ),
              const Divider(height: 28),

              _InfoLine(
                label: 'Date import',
                value: DateFormat('dd/MM/yyyy HH:mm').format(result.completedAt),
              ),

              _InfoLine(
                label: 'Fichiers traités',
                value: result.processedFiles.toString(),
              ),

              _InfoLine(
                label: 'Fichiers en erreur',
                value: result.failedFiles.toString(),
              ),

              _InfoLine(
                label: 'Résultats importés',
                value: result.importedResults.toString(),
              ),

              _InfoLine(
                label: 'Résultats ignorés',
                value: result.skippedResults.toString(),
              ),

              _InfoLine(
                label: 'Conflits',
                value: result.conflictResults.toString(),
              ),

              _InfoLine(
                label: 'Métriques importées',
                value: result.importedMetrics.toString(),
              ),

              if (result.hasPatients) ...[
                const SizedBox(height: 20),

                Text(
                  'Patients concernés',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall,
                ),

                const SizedBox(height: 20),

                ...List.generate(
                  result.patientLabels.length,
                      (index) {
                    final label = result.patientLabels[index];
                    final patientId = result.patientIds[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 18,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(label),
                          ),

                          TextButton.icon(
                            onPressed: () async {
                              final patient =
                              await _patientRepository.getPatientById(
                                patientId,
                              );

                              if (patient == null || !context.mounted) {
                                return;
                              }

                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailScreen(
                                    patient: patient,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.folder_open_outlined,
                              size: 18,
                            ),
                            label: const Text('Ouvrir'),
                          ),
                        ],
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

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}