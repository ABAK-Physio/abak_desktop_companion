import 'package:flutter/material.dart';
import '../dmp_setup/dmp_setup_service.dart';
import 'patient_person.dart';

/// Read-only presentation, separate from the patient's qualified INS identity.
class PatientPersonPanel extends StatefulWidget {
  const PatientPersonPanel({super.key, required this.person, this.settings});
  final DmpPatientPerson? person;
  final DmpSetupService? settings;
  @override
  State<PatientPersonPanel> createState() => _PatientPersonPanelState();
}

class _PatientPersonPanelState extends State<PatientPersonPanel> {
  bool visible = false;
  int generation = 0;
  @override
  void initState() {
    super.initState();
    DmpSetupService.changes.addListener(reload);
    reload();
  }

  void reload() async {
    final ticket = ++generation;
    // Hide synchronously, including when a preference read fails or races.
    if (mounted) setState(() => visible = false);
    try {
      final allowed = await (widget.settings ?? DmpSetupService())
          .showPatientPerson();
      if (mounted && ticket == generation) setState(() => visible = allowed);
    } catch (_) {
      /* Remain hidden. */
    }
  }

  @override
  void dispose() {
    generation++;
    DmpSetupService.changes.removeListener(reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    if (!visible || person == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Identité retournée par le DMP',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Seuls les traits de l’INS font foi. Ces informations ne modifient pas la fiche patient.',
            ),
            for (final trait in person.traits.entries)
              Text('${trait.key} : ${trait.value}'),
          ],
        ),
      ),
    );
  }
}
