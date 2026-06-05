import 'package:flutter/material.dart';

import 'data/practitioner_repository.dart';
import 'models/practitioner.dart';
import 'widgets/practitioner_form_dialog.dart';
import '../../core/utils/date_format_utils.dart';

class PractitionerListScreen extends StatefulWidget {
  const PractitionerListScreen({super.key});

  @override
  State<PractitionerListScreen> createState() => _PractitionerListScreenState();
}

class _PractitionerListScreenState extends State<PractitionerListScreen> {
  final PractitionerRepository _repository = PractitionerRepository();

  late Future<List<Practitioner>> _practitionersFuture;

  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _reloadPractitioners();
  }

  Future<void> _reloadPractitioners() async {
    setState(() {
      _practitionersFuture = _showArchived
          ? _repository.getArchivedPractitioners()
          : _repository.getActivePractitioners();
    });
  }

  Future<void> _createPractitioner() async {
    final practitioner = await showDialog<Practitioner>(
      context: context,
      builder: (_) => const PractitionerFormDialog(),
    );

    if (practitioner == null) return;

    await _repository.insertPractitioner(practitioner);
    await _reloadPractitioners();
  }

  Future<void> _editPractitioner(Practitioner practitioner) async {
    final updated = await showDialog<Practitioner>(
      context: context,
      builder: (_) => PractitionerFormDialog(
        initialPractitioner: practitioner,
      ),
    );

    if (updated == null) return;

    await _repository.updatePractitioner(updated);
    await _reloadPractitioners();
  }

  Future<void> _archivePractitioner(Practitioner practitioner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archiver le kiné'),
          content: Text(
            'Voulez-vous vraiment archiver ${practitioner.displayName} ?',
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

    await _repository.archivePractitioner(practitioner.practitionerId);
    await _reloadPractitioners();
  }

  Future<void> _restorePractitioner(Practitioner practitioner) async {
    await _repository.restorePractitioner(practitioner.practitionerId);

    setState(() {
      _showArchived = false;
      _practitionersFuture = _repository.getActivePractitioners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Practitioner>>(
      future: _practitionersFuture,
      builder: (context, snapshot) {
        final practitioners = snapshot.data ?? [];

        return Scaffold(
          body: _buildBody(snapshot, practitioners),
          floatingActionButton: _showArchived
              ? null
              : FloatingActionButton.extended(
            onPressed: _createPractitioner,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Nouveau kiné'),
          ),
        );
      },
    );
  }

  Widget _buildBody(
      AsyncSnapshot<List<Practitioner>> snapshot,
      List<Practitioner> practitioners,
      ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Text('Erreur : ${snapshot.error}'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Actifs'),
                icon: Icon(Icons.medical_services_outlined),
              ),
              ButtonSegment(
                value: true,
                label: Text('Archivés'),
                icon: Icon(Icons.archive_outlined),
              ),
            ],
            selected: {_showArchived},
            onSelectionChanged: (selection) {
              setState(() {
                _showArchived = selection.first;
                _practitionersFuture = _showArchived
                    ? _repository.getArchivedPractitioners()
                    : _repository.getActivePractitioners();
              });
            },
          ),
        ),
        Expanded(
          child: practitioners.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.medical_services_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  _showArchived
                      ? 'Aucun kiné archivé'
                      : 'Aucun kiné enregistré',
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  _showArchived
                      ? 'La corbeille des kinés est vide pour le moment.'
                      : 'Ajoutez les kinés du cabinet pour identifier les tests importés.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: practitioners.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final practitioner = practitioners[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    practitioner.displayName.isNotEmpty
                        ? practitioner.displayName[0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(practitioner.displayName),
                subtitle: Text(
                  _showArchived
                      ? 'Archivé le ${DateFormatUtils.formatTimestampForDisplay(context, practitioner.archivedAt)}'
                      : [
                    if (practitioner.professionalId != null)
                      'ID pro : ${practitioner.professionalId}',
                    if (practitioner.email != null)
                      practitioner.email!,
                    if (practitioner.phone != null)
                      practitioner.phone!,
                  ].join(' · '),
                ),
                trailing: _showArchived
                    ? IconButton(
                  tooltip: 'Restaurer',
                  icon: const Icon(Icons.restore),
                  onPressed: () =>
                      _restorePractitioner(practitioner),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Modifier',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          _editPractitioner(practitioner),
                    ),
                    IconButton(
                      tooltip: 'Archiver',
                      icon: const Icon(Icons.archive_outlined),
                      onPressed: () =>
                          _archivePractitioner(practitioner),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}