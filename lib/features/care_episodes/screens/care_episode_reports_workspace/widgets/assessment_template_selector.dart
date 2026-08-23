import 'package:flutter/material.dart';

import '../../../models/assessment_templates/assessment_template.dart';

class AssessmentTemplateSelector extends StatelessWidget {
  final List<AssessmentTemplate> templates;

  const AssessmentTemplateSelector({
    super.key,
    required this.templates,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choisir un modèle de bilan',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Fermer',
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sélectionnez le modèle qui servira de guide '
                    'pour la saisie du bilan.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: templates.length,
                  separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final template = templates[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.assignment_outlined,
                        ),
                        title: Text(template.name),
                        subtitle: template.description == null
                            ? null
                            : Text(template.description!),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () {
                          Navigator.of(context).pop(template);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}