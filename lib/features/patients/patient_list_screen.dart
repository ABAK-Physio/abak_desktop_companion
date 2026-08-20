import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

import 'data/patient_repository.dart';
import 'models/patient.dart';
import 'patient_detail_screen.dart';
import 'widgets/patient_form_dialog.dart';
import '../../core/utils/date_format_utils.dart';
import 'screens/patient_create_screen.dart';
import 'package:abak_shared/abak_shared.dart';
import 'services/patient_archive_settings_service.dart';

import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';
import '../../core/settings/application_settings_service.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}
class _PatientListScreenState extends State<PatientListScreen> {
ExpertContextInfo _expertInfo(S s) {
  return ExpertContextInfo(
    contextName: s.patientList_contextName,
    sourceFile: 'lib/features/patients/patient_list_screen.dart',
    arbPrefix: 'patientList',
    comment: s.patientList_contextComment,
  );
}
  final ApplicationSettingsService _applicationSettingsService =
  const ApplicationSettingsService();

  final PatientRepository _repository = PatientRepository();

  final PatientArchiveSettingsService _archiveSettingsService =
  PatientArchiveSettingsService();

  String _searchQuery = '';

  Future<List<Patient>> _patientsFuture =
  PatientRepository().getAllPatients();

  bool _showArchived = false;
  bool _expertModeEnabled = false;

  int _activePatientsCount = 0;
  int _archivedPatientsCount = 0;

  int _retentionDays =
      PatientArchiveSettingsService.defaultRetentionDays;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadExpertMode();
    _refreshCounters();
  }

  Future<void> _loadExpertMode() async {
    final expertModeEnabled =
    await _applicationSettingsService.isExpertModeEnabled();

    if (!mounted) return;

    setState(() {
      _expertModeEnabled = expertModeEnabled;
    });
  }

  Future<void> _loadSettings() async {
    final retentionDays =
    await _archiveSettingsService.getRetentionDays();

    if (!mounted) return;

    setState(() {
      _retentionDays = retentionDays;
    });
  }

  Future<void> _restorePatient(Patient patient) async {
    final s = S.of(context);
    await _repository.restorePatient(patient.patientId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.patientList_restoreSuccess(patient.displayName),
        ),
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
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(s.patientList_archiveTitle),
          content: Text(
            s.patientList_archiveConfirmation(patient.displayName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(s.patientList_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(s.patientList_archive),
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
    final s = S.of(context);
    return FutureBuilder<List<Patient>>(
      future: _patientsFuture,
      builder: (context, snapshot) {
        final patients = snapshot.data ?? [];

        return Scaffold(
          body: _buildBody(snapshot, patients),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _createPatient,
            icon: const Icon(Icons.person_add),
            label: Text(s.patientList_newPatient),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<List<Patient>> snapshot,
    List<Patient> patients,
  ) {
    final s = S.of(context);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Text(
            s.patientList_error(snapshot.error.toString())
        ),
      );
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
                  ? s.patientList_noArchivedPatients
                  : s.patientList_noRegisteredPatients,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              _showArchived
                  ? s.patientList_archivedPatientsEmpty
                  : s.patientList_patientFileEmpty,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  s.patientList_title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (_expertModeEnabled)
                ExpertInfoButton(
                  info: _expertInfo(s),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(
                  '${s.patientList_active} ($_activePatientsCount)',
                ),
                icon: Icon(Icons.people_outline),
              ),
              ButtonSegment(
                value: true,
                label: Text(
                  '${s.patientList_archived} ($_archivedPatientsCount)',
                ),
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
            decoration: InputDecoration(
              labelText: s.patientList_searchPatient,
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
              ? Center(
                  child: Text(
                    s.patientList_noPatientFound,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredPatients.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];

                    final archivedAt = patient.archivedAt;

                    final restorableUntil = archivedAt == null
                        ? null
                        : DateTime.fromMillisecondsSinceEpoch(
                      archivedAt,
                    ).add(
                      Duration(
                        days: _retentionDays,
                      ),
                    ).millisecondsSinceEpoch;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          patient.lastName.isNotEmpty
                              ? patient.lastName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(patient.displayName),
                      subtitle: _showArchived
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.patientList_sex} : ${patient.sexCode}',
                          ),
                          if (archivedAt != null)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${s.patientList_archivedOn} '
                                        '${DateFormatUtils.formatTimestampForDisplay(context, archivedAt)}'
                                        '${restorableUntil == null
                                        ? ''
                                        : ' · ${s.patientList_restorableUntil} ${DateFormatUtils.formatTimestampForDisplay(context, restorableUntil)}'}',
                                  ),
                                ),
                                ContextHelpButton(
                                  title: s.patientList_archivedPatient,
                                  content: S.of(context).help_archived_patient,
                                ),
                              ],
                            ),
                        ],
                      )
                          : Text(
                        '${s.patientList_sex} : ${patient.sexCode}'
                            '${patient.birthDate == null
                            ? ''
                            : ' · ${s.patientList_bornOn} ${DateFormatUtils.formatIsoDateForDisplay(context, patient.birthDate)}'}',
                      ),
                      trailing: _showArchived
                          ? IconButton(
                              tooltip: s.patientList_restore,
                              icon: const Icon(Icons.restore),
                              onPressed: () => _restorePatient(patient),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: s.patientList_edit,
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editPatient(patient),
                                ),
                                IconButton(
                                  tooltip: s.patientList_archive,
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
