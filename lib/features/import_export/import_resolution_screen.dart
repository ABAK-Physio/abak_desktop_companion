import 'package:flutter/material.dart';

import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';

import '../care_episodes/widgets/care_episodes_panel.dart';

import '../care_episodes/data/care_episode_repository.dart';
import '../care_episodes/models/care_episode.dart';
import '../patients/data/patient_repository.dart';
import '../patients/models/patient.dart';
import 'package:abak_vitale/abak_vitale.dart';
import '../smart_card/screens/vitale_identity_screen.dart';
import 'abak_package.dart';

class ImportAssignment {
  final Patient patient;
  final CareEpisode careEpisode;

  const ImportAssignment({required this.patient, required this.careEpisode});
}

class ImportResolutionScreen extends StatefulWidget {
  final AbakPackage package;

  const ImportResolutionScreen({super.key, required this.package});

  @override
  State<ImportResolutionScreen> createState() => _ImportResolutionScreenState();
}

class _ImportResolutionScreenState extends State<ImportResolutionScreen> {
  final PatientRepository _patientRepository = PatientRepository();
  final CareEpisodeRepository _careEpisodeRepository = CareEpisodeRepository();

  late Future<List<Patient>> _patientsFuture;

  Patient? _selectedPatient;
  bool _completingAssignment = false;

  @override
  void initState() {
    super.initState();
    _patientsFuture = _patientRepository.getPatients();
  }

  Future<void> _selectPatient(Patient patient) async {
    setState(() {
      _selectedPatient = patient;
    });
  }

  Future<void> _completeWithEpisode(CareEpisode careEpisode) async {
    final patient = _selectedPatient;
    if (_completingAssignment ||
        patient == null ||
        careEpisode.patientId != patient.patientId) {
      return;
    }
    _completingAssignment = true;

    try {
      final current = await _careEpisodeRepository.getEpisodeById(
        careEpisode.careEpisodeId,
      );
      if (!mounted || _selectedPatient?.patientId != patient.patientId) return;
      if (current == null ||
          current.isArchived ||
          current.patientId != patient.patientId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cette prise en charge n’est plus disponible. Choisissez une prise en charge active.',
            ),
          ),
        );
        return;
      }
      Navigator.of(
        context,
      ).pop(ImportAssignment(patient: patient, careEpisode: current));
    } catch (error, stackTrace) {
      debugPrint('Échec du choix de la prise en charge : $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de sélectionner la prise en charge. Veuillez réessayer.',
          ),
        ),
      );
    } finally {
      _completingAssignment = false;
    }
  }

  Future<void> _createPatient({
    String? initialLastName,
    String? initialFirstName,
    String? initialBirthDate,
    String? initialSexCode,
  }) async {
    final lastNameController = TextEditingController(
      text: initialLastName ?? '',
    );
    final firstNameController = TextEditingController(
      text: initialFirstName ?? '',
    );
    final birthDateController = TextEditingController(
      text: initialBirthDate ?? '',
    );

    String sexCode = initialSexCode ?? 'U';

    final dialog = DialogRoute<Patient>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouveau patient'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                    ),
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                    ),
                    TextField(
                      controller: birthDateController,
                      decoration: const InputDecoration(
                        labelText: 'Date de naissance YYYY-MM-DD',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: sexCode,
                      decoration: const InputDecoration(labelText: 'Sexe'),
                      items: const [
                        DropdownMenuItem(
                          value: 'U',
                          child: Text('Non renseigné'),
                        ),
                        DropdownMenuItem(value: 'F', child: Text('Féminin')),
                        DropdownMenuItem(value: 'M', child: Text('Masculin')),
                        DropdownMenuItem(value: 'X', child: Text('Autre')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          sexCode = value;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final patient = await _patientRepository.createPatient(
                  lastName: lastNameController.text.trim(),
                  firstName: firstNameController.text.trim(),
                  birthDate: birthDateController.text.trim().isEmpty
                      ? null
                      : birthDateController.text.trim(),
                  sexCode: sexCode,
                );

                if (!context.mounted) return;
                Navigator.of(context).pop(patient);
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );

    final patient = await Navigator.of(context).push(dialog);
    await dialog.completed;

    lastNameController.dispose();
    firstNameController.dispose();
    birthDateController.dispose();

    if (!mounted || patient == null) return;

    setState(() {
      _patientsFuture = _patientRepository.getPatients();
    });

    await _selectPatient(patient);
  }

  Future<void> _createPatientFromVitale() async {
    final identity = await Navigator.of(context).push<VitaleIdentity>(
      MaterialPageRoute(builder: (_) => const VitaleIdentityScreen()),
    );

    if (!mounted || identity == null) return;

    await _createPatient(
      initialLastName: identity.lastName,
      initialFirstName: identity.firstName,
      initialBirthDate: identity.birthDate?.toIso8601String().split('T').first,
      initialSexCode: identity.sexCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clinicalEpisode = widget.package.clinicalEpisode;
    final mobileCase = widget.package.mobileCase;

    return Scaffold(
      appBar: AppBar(
        actions: [
          ExpertModeInfoButton(
            info: ExpertContextInfo(
              contextName: 'Rattacher l’import',
              sourceFile:
                  'lib/features/import_export/import_resolution_screen.dart',
            ),
          ),
        ],
        title: const Text('Rattacher l’import'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.download_done_outlined),
                      title: const Text('Import reçu'),
                      subtitle: Text(
                        [
                          if (clinicalEpisode?.label != null)
                            'Épisode ABAK : ${clinicalEpisode!.label}',
                          if (clinicalEpisode?.pathologyLabel != null)
                            'Pathologie ABAK : ${clinicalEpisode!.pathologyLabel}',
                          if (clinicalEpisode?.patientLabel != null)
                            'Libellé patient ABAK : ${clinicalEpisode!.patientLabel}',
                          if (mobileCase?.caseLabel != null)
                            'Dossier mobile : ${mobileCase!.caseLabel}',
                        ].join('\n'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '1. Choisir le patient',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _createPatientFromVitale,
                          icon: const Icon(Icons.badge_outlined),
                          label: const Text('Depuis Carte Vitale'),
                        ),
                        FilledButton.icon(
                          onPressed: () => _createPatient(),
                          icon: const Icon(Icons.person_add_outlined),
                          label: const Text('Nouveau patient'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Patient>>(
                      future: _patientsFuture,
                      builder: (context, snapshot) {
                        final patients = snapshot.data ?? [];

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (patients.isEmpty) {
                          return const Center(
                            child: Text('Aucun patient disponible.'),
                          );
                        }

                        return ListView.separated(
                          itemCount: patients.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final patient = patients[index];
                            final selected =
                                patient.patientId ==
                                _selectedPatient?.patientId;

                            return ListTile(
                              selected: selected,
                              leading: const Icon(Icons.person_outline),
                              title: Text(patient.displayName),
                              subtitle: Text(
                                [
                                  if (patient.birthDate != null)
                                    'Naissance : ${patient.birthDate}',
                                  'ID : ${patient.patientId}',
                                ].join('\n'),
                              ),
                              onTap: () => _selectPatient(patient),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _selectedPatient == null
                  ? const Center(
                      child: Text(
                        'Choisis d’abord un patient pour afficher ou créer une prise en charge.',
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '2. Choisir ou créer une prise en charge',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Patient sélectionné : ${_selectedPatient!.displayName}',
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Choisissez une prise en charge active pour rattacher le résultat. '
                          'Une prise en charge archivée doit d’abord être restaurée.',
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: CareEpisodesPanel(
                              key: ValueKey(_selectedPatient!.patientId),
                              patientId: _selectedPatient!.patientId,
                              patientName: _selectedPatient!.displayName,
                              initialPathology: widget
                                  .package
                                  .clinicalEpisode
                                  ?.pathologyLabel,
                              onSelectEpisode: _completeWithEpisode,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
