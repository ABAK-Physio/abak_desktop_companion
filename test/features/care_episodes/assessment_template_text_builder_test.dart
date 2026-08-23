import 'package:flutter_test/flutter_test.dart';

import 'package:abak_desktop_companion/features/care_episodes/models/assessment_templates/assessment_template_answers.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/assessment_templates/assessment_template_text_builder.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/assessment_templates/default_assessment_templates.dart';

void main() {
  test('génère uniquement les informations renseignées', () {
    const template = DefaultAssessmentTemplates.musculoskeletalGeneral;

    const answers = AssessmentTemplateAnswers(
      templateId: 'musculoskeletal_general',
      values: {
        'consultation_reason': 'Douleur du genou droit',
        'profession': '',
        'sports_activities': 'Tennis',
        'pain_eva': '6/10',
        'pain_characteristics': [
          'Profonde',
          'Sourde',
        ],
        'pain_rhythm': 'Mécanique',
        'clinical_summary':
        'Limitation fonctionnelle principalement lors des escaliers.',
      },
    );

    final result = AssessmentTemplateTextBuilder.build(
      template: template,
      answers: answers,
    );

    expect(
      result,
      '''
ENTRETIEN

Motif de consultation : Douleur du genou droit
Activité sportive / loisirs : Tennis

DOULEUR

EVA : 6/10
Caractéristiques : Profonde, Sourde
Rythme : Mécanique

SYNTHÈSE

Synthèse clinique : Limitation fonctionnelle principalement lors des escaliers.''',
    );
  });
}