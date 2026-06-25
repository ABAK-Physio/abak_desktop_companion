import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../care_episodes/data/care_episode_repository.dart';
import '../care_episodes/models/care_episode.dart';
import '../patients/data/patient_repository.dart';
import '../patients/models/patient.dart';
import '../smart_card/models/vitale_identity.dart';
import '../smart_card/screens/vitale_identity_screen.dart';
import 'abak_package.dart';

class ImportAssignment {
  final Patient patient;
  final CareEpisode careEpisode;

  const ImportAssignment({
    required this.patient,
    required this.careEpisode,
  });
}

class ImportResolutionScreen extends StatefulWidget {
  final AbakPackage package;

  const ImportResolutionScreen({
    super.key,
    required this.package,
  });

  @override
  State<ImportResolutionScreen> createState() =>
      _ImportResolutionScreenState();
}

class _ImportResolutionScreenState extends State<ImportResolutionScreen> {
  final PatientRepository _patientRepository = PatientRepository();
  final CareEpisodeRepository _careEpisodeRepository =
  CareEpisodeRepository();

  late Future<List<Patient>> _patientsFuture;

  Patient? _selectedPatient;
  Future<List<CareEpisode>>? _careEpisodesFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = _patientRepository.getPatients();
  }

  Future<void> _selectPatient(Patient patient) async {
    setState(() {
      _selectedPatient = patient;
      _careEpisodesFuture =
          _careEpisodeRepository.getEpisodesForPatient(patient.patientId);
    });
  }

  Future<void> _completeWithEpisode(CareEpisode careEpisode) async {
    final patient = _selectedPatient;
    if (patient == null) return;

    Navigator.of(context).pop(
      ImportAssignment(
        patient: patient,
        careEpisode: careEpisode,
      ),
    );
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

    final patient = await showDialog<Patient>(
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
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                      ),
                    ),
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'Sexe',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'U',
                          child: Text('Non renseigné'),
                        ),
                        DropdownMenuItem(
                          value: 'F',
                          child: Text('Féminin'),
                        ),
                        DropdownMenuItem(
                          value: 'M',
                          child: Text('Masculin'),
                        ),
                        DropdownMenuItem(
                          value: 'X',
                          child: Text('Autre'),
                        ),
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

    lastNameController.dispose();
    firstNameController.dispose();
    birthDateController.dispose();

    if (patient == null) return;

    setState(() {
      _patientsFuture = _patientRepository.getPatients();
    });

    await _selectPatient(patient);
  }

  Future<void> _createPatientFromVitale() async {
    final identity = await Navigator.of(context).push<VitaleIdentity>(
      MaterialPageRoute(
        builder: (_) => const VitaleIdentityScreen(),
      ),
    );

    if (!mounted || identity == null) return;

    await _createPatient(
      initialLastName: identity.lastName,
      initialFirstName: identity.firstName,
      initialBirthDate: identity.birthDate?.toIso8601String().split('T').first,
      initialSexCode: identity.sexCode,
    );
  }

  Future<void> _createCareEpisode() async {
    final patient = _selectedPatient;
    if (patient == null) return;

    final suggestedTitle =
        widget.package.clinicalEpisode?.pathologyLabel ??
            widget.package.mobileCase?.caseLabel ??
            'Nouvelle prise en charge';

    final titleController = TextEditingController(text: suggestedTitle);
    final pathologyController = TextEditingController(
      text: widget.package.clinicalEpisode?.pathologyLabel ?? '',
    );

    final careEpisode = await showDialog<CareEpisode>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouvelle prise en charge'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                  ),
                ),
                TextField(
                  controller: pathologyController,
                  decoration: const InputDecoration(
                    labelText: 'Pathologie',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final now = DateTime.now().millisecondsSinceEpoch;

                final episode = CareEpisode(
                  careEpisodeId: const Uuid().v4(),
                  patientId: patient.patientId,
                  title: titleController.text.trim().isEmpty
                      ? 'Nouvelle prise en charge'
                      : titleController.text.trim(),
                  pathologyLabel: pathologyController.text.trim().isEmpty
                      ? 'Non renseignée'
                      : pathologyController.text.trim(),
                  initialReport: null,
                  finalConclusion: null,
                  createdAt: now,
                  updatedAt: now,
                  archivedAt: null,
                );

                await _careEpisodeRepository.insertCareEpisode(episode);

                if (!context.mounted) return;
                Navigator.of(context).pop(episode);
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    pathologyController.dispose();

    if (careEpisode == null) return;

    if (!mounted) return;

    setState(() {
      _careEpisodesFuture =
          _careEpisodeRepository.getEpisodesForPatient(patient.patientId);
    });

    await _completeWithEpisode(careEpisode);
  }

  @override
  Widget build(BuildContext context) {
    final clinicalEpisode = widget.package.clinicalEpisode;
    final mobileCase = widget.package.mobileCase;

    return Scaffold(
      appBar: AppBar(
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
                      leading: const Icon(Icons.description_outlined),
                      title: Text(
                        clinicalEpisode?.label ??
                            clinicalEpisode?.pathologyLabel ??
                            mobileCase?.caseLabel ??
                            'Import ABAK',
                      ),
                      subtitle: Text(
                        [
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
                          separatorBuilder: (_, _) =>
                          const Divider(height: 1),
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
                  'Sélectionne un patient pour afficher ses prises en charge.',
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2. Choisir la prise en charge de ${_selectedPatient!.displayName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _createCareEpisode,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Nouvelle prise en charge'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<CareEpisode>>(
                      future: _careEpisodesFuture,
                      builder: (context, snapshot) {
                        final episodes = snapshot.data ?? [];

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (episodes.isEmpty) {
                          return const Center(
                            child: Text(
                              'Aucune prise en charge pour ce patient.',
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: episodes.length,
                          separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final episode = episodes[index];

                            return ListTile(
                              leading: const Icon(
                                Icons.medical_services_outlined,
                              ),
                              title: Text(episode.title),
                              subtitle: Text(
                                [
                                  'Pathologie : ${episode.pathologyLabel}',
                                  'ID : ${episode.careEpisodeId}',
                                ].join('\n'),
                              ),
                              onTap: () =>
                                  _completeWithEpisode(episode),
                            );
                          },
                        );
                      },
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