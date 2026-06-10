import 'package:flutter/material.dart';

import '../patients/data/patient_repository.dart';
import '../patients/models/patient.dart';
import 'abak_package.dart';
import 'data/mobile_case_repository.dart';
import '../smart_card/models/vitale_identity.dart';
import '../smart_card/screens/vitale_identity_screen.dart';

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
  final MobileCaseRepository _mobileCaseRepository = MobileCaseRepository();

  late Future<List<Patient>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = _patientRepository.getPatients();
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
                        DropdownMenuItem(value: 'U', child: Text('Non renseigné')),
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

    lastNameController.dispose();
    firstNameController.dispose();
    birthDateController.dispose();

    if (patient == null) return;

    await _linkToPatient(patient);
  }

  Future<void> _linkToPatient(Patient patient) async {
    final mobileCase = widget.package.mobileCase;

    if (mobileCase == null) {
      Navigator.of(context).pop(patient);
      return;
    }

    await _mobileCaseRepository.linkCaseToPatient(
      caseId: mobileCase.caseId,
      patientId: patient.patientId,
    );

    if (!mounted) return;

    Navigator.of(context).pop(patient);
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

  @override
  Widget build(BuildContext context) {
    final mobileCase = widget.package.mobileCase;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rattacher l’import'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(
                  mobileCase?.caseLabel ?? 'Dossier mobile sans libellé',
                ),
                subtitle: Text(
                  [
                    if (mobileCase?.caseId != null)
                      'Case ID : ${mobileCase!.caseId}',
                    if (mobileCase?.pathologyCode != null)
                      'Pathologie : ${mobileCase!.pathologyCode}',
                  ].join('\n'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choisir le patient Desktop auquel rattacher ce dossier :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
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

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (patients.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucun patient disponible. '
                            'La création depuis cet écran sera ajoutée ensuite.',
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: patients.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final patient = patients[index];

                      return ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(patient.displayName),
                        subtitle: Text(
                          [
                            if (patient.birthDate != null)
                              'Naissance : ${patient.birthDate}',
                            'ID : ${patient.patientId}',
                          ].join('\n'),
                        ),
                        onTap: () => _linkToPatient(patient),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}