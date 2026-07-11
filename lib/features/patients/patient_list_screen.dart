import 'package:flutter/material.dart';

import 'data/patient_repository.dart';
import 'models/patient.dart';
import 'patient_detail_screen.dart';
import 'widgets/patient_form_dialog.dart';
import '../../core/utils/date_format_utils.dart';
import 'screens/patient_create_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final PatientRepository _repository = PatientRepository();
  String _searchQuery = '';
  Future<List<Patient>> _patientsFuture = PatientRepository().getAllPatients();
  bool _showArchived = false;
  int _activePatientsCount = 0;
  int _archivedPatientsCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshCounters();
  }

  Future<void> _restorePatient(Patient patient) async {
    await _repository.restorePatient(patient.patientId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${patient.displayName} restauré dans la liste active.'),
      ),
    );

    setState(() {
      _showArchived = false;
      _patientsFuture = _repository.getAllPatients();
    });

    await _refreshCounters();
  }

  Future<void> _reloadPatients() async {
    setState(() {
      _patientsFuture = _showArchived
          ? _repository.getArchivedPatients()
          : _repository.getAllPatients();
    });

    await _refreshCounters();
  }

  Future<void> _createPatient() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PatientCreateScreen()),
    );

    if (created == true) {
      await _reloadPatients();
    }
  }

  Future<void> _editPatient(Patient patient) async {
    final updatedPatient = await showDialog<Patient>(
      context: context,
      builder: (_) => PatientFormDialog(initialPatient: patient),
    );

    if (updatedPatient == null) return;

    await _repository.updatePatient(updatedPatient);
    await _reloadPatients();
  }

  Future<void> _deletePatient(Patient patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archiver le patient'),
          content: Text(
            'Voulez-vous vraiment archiver ${patient.displayName} ? Il ne sera plus affiché dans la liste active.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archiver'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _repository.archivePatient(patient.patientId);
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${patient.displayName} archivé.')));
    await _reloadPatients();
  }

  Future<void> _refreshCounters() async {
    final active = await _repository.getAllPatients();

    final archived = await _repository.getArchivedPatients();

    if (!mounted) return;

    setState(() {
      _activePatientsCount = active.length;
      _archivedPatientsCount = archived.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Patient>>(
      future: _patientsFuture,
      builder: (context, snapshot) {
        final patients = snapshot.data ?? [];

        return Scaffold(
          body: _buildBody(snapshot, patients),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _createPatient,
            icon: const Icon(Icons.person_add),
            label: const Text('Nouveau patient'),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<List<Patient>> snapshot,
    List<Patient> patients,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Erreur : ${snapshot.error}'));
    }

    if (patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              _showArchived
                  ? 'Aucun patient archivé'
                  : 'Aucun patient enregistré',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              _showArchived
                  ? 'La corbeille des patients est vide pour le moment.'
                  : 'Le fichier patient local est vide pour le moment.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final filteredPatients = patients.where((patient) {
      final query = _searchQuery.toLowerCase().trim();

      if (query.isEmpty) return true;

      return patient.lastName.toLowerCase().contains(query) ||
          patient.firstName.toLowerCase().contains(query) ||
          patient.displayName.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text('Actifs ($_activePatientsCount)'),
                icon: Icon(Icons.people_outline),
              ),
              ButtonSegment(
                value: true,
                label: Text('Archivés ($_archivedPatientsCount)'),
                icon: Icon(Icons.archive_outlined),
              ),
            ],
            selected: {_showArchived},
            onSelectionChanged: (selection) {
              setState(() {
                _showArchived = selection.first;
                _patientsFuture = _showArchived
                    ? _repository.getArchivedPatients()
                    : _repository.getAllPatients();
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Rechercher un patient',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: filteredPatients.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun patient trouvé',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredPatients.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          patient.lastName.isNotEmpty
                              ? patient.lastName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(patient.displayName),
                      subtitle: Text(
                        _showArchived
                            ? 'Sexe : ${patient.sexCode}'
                                  '${patient.archivedAt == null ? '' : ' · Archivé le ${DateFormatUtils.formatTimestamp(context, patient.archivedAt)}'}'
                            : 'Sexe : ${patient.sexCode}'
                                  '${patient.birthDate == null ? '' : ' · Né(e) le ${DateFormatUtils.formatIsoDateForDisplay(context, patient.birthDate)}'}',
                      ),
                      trailing: _showArchived
                          ? IconButton(
                              tooltip: 'Restaurer',
                              icon: const Icon(Icons.restore),
                              onPressed: () => _restorePatient(patient),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Modifier',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editPatient(patient),
                                ),
                                IconButton(
                                  tooltip: 'Archiver',
                                  icon: const Icon(Icons.archive_outlined),
                                  onPressed: () => _deletePatient(patient),
                                ),
                              ],
                            ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PatientDetailScreen(patient: patient),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
