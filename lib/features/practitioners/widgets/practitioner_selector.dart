import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../data/practitioner_repository.dart';
import '../models/practitioner.dart';

class PractitionerSelector extends StatelessWidget {
  final String label;
  final String? selectedPractitionerId;
  final bool allowEmpty;
  final ValueChanged<String?> onChanged;

  final PractitionerRepository _repository = PractitionerRepository();

  PractitionerSelector({
    super.key,
    required this.label,
    required this.selectedPractitionerId,
    required this.onChanged,
    this.allowEmpty = true,
  });

  Future<List<Practitioner>> _loadPractitioners() async {
    final practitioners = await _repository.getActivePractitioners();
    final selectedId = selectedPractitionerId;

    if (selectedId == null ||
        practitioners.any(
              (practitioner) => practitioner.practitionerId == selectedId,
        )) {
      return practitioners;
    }

    final selectedPractitioner =
    await _repository.getPractitionerById(selectedId);

    if (selectedPractitioner == null) {
      return practitioners;
    }

    return [
      selectedPractitioner,
      ...practitioners,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return FutureBuilder<List<Practitioner>>(
      future: _loadPractitioners(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text(
            s.practitionerSelector_error(snapshot.error.toString()),
          );
        }

        final practitioners = snapshot.data ?? const <Practitioner>[];

        return DropdownButtonFormField<String>(
          initialValue: selectedPractitionerId,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: [
            if (allowEmpty)
              DropdownMenuItem<String>(
                value: null,
                child: Text(s.practitionerSelector_noSelection),
              ),
            ...practitioners.map(
                  (practitioner) => DropdownMenuItem<String>(
                value: practitioner.practitionerId,
                child: Text(
                  practitioner.isArchived
                      ? '${practitioner.displayName} — ${s.practitionerSelector_archived}'
                      : practitioner.displayName,
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}