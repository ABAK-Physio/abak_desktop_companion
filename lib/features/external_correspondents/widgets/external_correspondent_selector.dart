import 'package:flutter/material.dart';

import '../data/external_correspondent_repository.dart';
import '../models/external_correspondent.dart';

class ExternalCorrespondentSelector extends StatelessWidget {
  final String label;
  final String? selectedCorrespondentId;
  final bool allowEmpty;
  final ValueChanged<String?> onChanged;

  const ExternalCorrespondentSelector({
    super.key,
    required this.label,
    required this.selectedCorrespondentId,
    required this.onChanged,
    this.allowEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final repository = ExternalCorrespondentRepository();

    return FutureBuilder<List<ExternalCorrespondent>>(
      future: repository.getActiveCorrespondents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LinearProgressIndicator();
        }

        final correspondents =
            snapshot.data ?? const <ExternalCorrespondent>[];

        return DropdownButtonFormField<String?>(
          initialValue: selectedCorrespondentId,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: [
            if (allowEmpty)
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Aucun'),
              ),
            ...correspondents.map(
                  (correspondent) => DropdownMenuItem<String?>(
                value: correspondent.correspondentId,
                child: Text(correspondent.displayName),
              ),
            ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}