import 'assessment_template.dart';
import 'assessment_template_field.dart';
import 'assessment_template_field_type.dart';
import 'assessment_template_section.dart';

class DefaultAssessmentTemplates {
  static const musculoskeletalGeneral = AssessmentTemplate(
    id: 'musculoskeletal_general',
    name: 'Bilan musculo-squelettique général',
    description:
    'Guide de saisie général pour un bilan musculo-squelettique.',
    sections: [
      AssessmentTemplateSection(
        id: 'interview',
        title: 'Entretien',
        fields: [
          AssessmentTemplateField(
            id: 'consultation_reason',
            label: 'Motif de consultation',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'anamnesis',
            label: 'Anamnèse',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'symptom_evolution',
            label: 'Évolution des symptômes',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'patient_expectations',
            label: 'Objectifs / attentes du patient',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'history',
            label: 'Antécédents',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'profession',
            label: 'Profession',
            type: AssessmentTemplateFieldType.abakData,
            abakSource: 'patient.profession',
          ),
          AssessmentTemplateField(
            id: 'sports_activities',
            label: 'Activité sportive / loisirs',
            type: AssessmentTemplateFieldType.abakData,
            abakSource: 'patient.sportsActivities',
          ),
          AssessmentTemplateField(
            id: 'imaging',
            label: 'Imagerie',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'previous_treatments',
            label: 'Traitements antérieurs',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),
      AssessmentTemplateSection(
        id: 'precautions',
        title: 'Précautions',
        fields: [
          AssessmentTemplateField(
            id: 'associated_conditions',
            label: 'Pathologies associées',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'medications',
            label: 'Médicaments',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'red_flags',
            label: 'Red flags',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'other_precautions',
            label: 'Autres précautions',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),
      AssessmentTemplateSection(
        id: 'pain',
        title: 'Douleur',
        fields: [
          AssessmentTemplateField(
            id: 'pain_location',
            label: 'Localisation',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'pain_eva',
            label: 'EVA',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'pain_characteristics',
            label: 'Caractéristiques',
            type: AssessmentTemplateFieldType.multipleChoice,
            options: [
              'Superficielle',
              'Précise',
              'Profonde',
              'Sourde',
              'Diffuse',
              'Élancement',
              'Tiraillement',
              'Pincement',
              'Coup d’aiguille',
              'Compression',
              'Fourmillement',
              'Brûlure',
              'Raideur',
              'Fatigue',
            ],
          ),
          AssessmentTemplateField(
            id: 'pain_temporality',
            label: 'Temporalité',
            type: AssessmentTemplateFieldType.multipleChoice,
            options: [
              'Intermittente',
              'Constante',
              'Variable',
              'Invariable',
            ],
          ),
          AssessmentTemplateField(
            id: 'pain_aggravated_by',
            label: 'Aggravée par',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'pain_relieved_by',
            label: 'Améliorée par',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'pain_rhythm',
            label: 'Rythme',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Mécanique',
              'Inflammatoire',
              'Mixte',
            ],
          ),
          AssessmentTemplateField(
            id: 'pain_type',
            label: 'Type',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Nociceptive',
              'Neuropathique',
              'Nociplastique',
            ],
          ),
          AssessmentTemplateField(
            id: 'pain_source',
            label: 'Source',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Somatique locale',
              'Référée',
              'Neurale',
              'Viscérale',
            ],
          ),
          AssessmentTemplateField(
            id: 'load_tolerance',
            label: 'Chargeabilité',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),
      AssessmentTemplateSection(
        id: 'clinical_exam',
        title: 'Examen clinique',
        fields: [
          AssessmentTemplateField(
            id: 'cutaneous_trophic',
            label: 'Cutané / trophique',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'posture',
            label: 'Morphostatique',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'functional',
            label: 'Fonctionnel',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'postural_stability',
            label: 'Stabilité posturale',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'joint_mobility',
            label: 'Mobilité articulaire',
            type: AssessmentTemplateFieldType.simpleTable,
            tableColumns: [
              'Valeur',
              'Symptôme',
            ],
            tableRows: [
              'Flexion',
              'Extension',
              'Abduction',
              'Rotation interne',
              'Rotation externe',
            ],
          ),
          AssessmentTemplateField(
            id: 'palpation_manual_tests',
            label: 'Palpation / tests manuels',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'clinical_tests',
            label: 'Tests cliniques',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'neurodynamics',
            label: 'Neuro-dynamique',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'cervical_assessment',
            label: 'Évaluation cervicale',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'other_observations',
            label: 'Autres observations',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),
      AssessmentTemplateSection(
        id: 'summary',
        title: 'Synthèse',
        fields: [
          AssessmentTemplateField(
            id: 'clinical_summary',
            label: 'Synthèse clinique',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'care_objectives',
            label: 'Objectifs de prise en charge',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'first_session',
            label: 'Première séance',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),
      AssessmentTemplateSection(
        id: 'follow_up',
        title: 'Suivi / remarques',
        fields: [
          AssessmentTemplateField(
            id: 'additional_notes',
            label: 'Remarques complémentaires',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),
    ],
  );

  static const musculoskeletalUpperLimb = AssessmentTemplate(
    id: 'musculoskeletal_upper_limb',
    name: 'Bilan membre supérieur',
    description:
    'Guide de saisie pour un bilan musculo-squelettique du membre supérieur.',
    sections: [
      AssessmentTemplateSection(
        id: 'interview',
        title: 'Entretien',
        fields: [
          AssessmentTemplateField(
            id: 'consultation_reason',
            label: 'Motif de consultation',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'anamnesis',
            label: 'Anamnèse',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'symptom_evolution',
            label: 'Évolution des symptômes',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'patient_expectations',
            label: 'Objectifs / attentes du patient',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'history',
            label: 'Antécédents',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'profession',
            label: 'Profession',
            type: AssessmentTemplateFieldType.abakData,
            abakSource: 'patient.profession',
          ),
          AssessmentTemplateField(
            id: 'sports_activities',
            label: 'Activité sportive / loisirs',
            type: AssessmentTemplateFieldType.abakData,
            abakSource: 'patient.sportsActivities',
          ),
          AssessmentTemplateField(
            id: 'imaging',
            label: 'Imagerie',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'previous_treatments',
            label: 'Traitements antérieurs',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'precautions',
        title: 'Précautions',
        fields: [
          AssessmentTemplateField(
            id: 'associated_conditions',
            label: 'Pathologies associées',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'medications',
            label: 'Médicaments',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'red_flags',
            label: 'Red flags',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'other_precautions',
            label: 'Autres précautions',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'pain',
        title: 'Douleur',
        fields: [
          AssessmentTemplateField(
            id: 'pain_location',
            label: 'Localisation',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'pain_eva',
            label: 'EVA',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'pain_characteristics',
            label: 'Caractéristiques',
            type: AssessmentTemplateFieldType.multipleChoice,
            options: [
              'Superficielle',
              'Précise',
              'Profonde',
              'Sourde',
              'Diffuse',
              'Élancement',
              'Tiraillement',
              'Pincement',
              'Coup d’aiguille',
              'Compression',
              'Fourmillement',
              'Brûlure',
              'Raideur',
              'Fatigue',
            ],
          ),
          AssessmentTemplateField(
            id: 'pain_temporality',
            label: 'Temporalité',
            type: AssessmentTemplateFieldType.multipleChoice,
            options: [
              'Intermittente',
              'Constante',
              'Variable',
              'Invariable',
            ],
          ),
          AssessmentTemplateField(
            id: 'pain_aggravated_by',
            label: 'Aggravée par',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'pain_relieved_by',
            label: 'Améliorée par',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'pain_rhythm',
            label: 'Rythme',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Mécanique',
              'Inflammatoire',
              'Mixte',
            ],
          ),
          AssessmentTemplateField(
            id: 'pain_type',
            label: 'Type',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Nociceptive',
              'Neuropathique',
              'Nociplastique',
            ],
          ),
          AssessmentTemplateField(
            id: 'pain_source',
            label: 'Source',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Somatique locale',
              'Référée',
              'Neurale',
              'Viscérale',
            ],
          ),
          AssessmentTemplateField(
            id: 'load_tolerance',
            label: 'Chargeabilité',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'clinical_exam',
        title: 'Examen clinique',
        fields: [
          AssessmentTemplateField(
            id: 'posture',
            label: 'Morphostatique',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'cutaneous_trophic',
            label: 'Cutané / trophique',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'functional',
            label: 'Fonctionnel',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'functional_demo',
            label: 'Démonstration fonctionnelle',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'joint_mobility',
            label: 'Mobilité articulaire',
            type: AssessmentTemplateFieldType.simpleTable,
            tableColumns: [
              'A.A',
              'Symptôme',
            ],
            tableRows: [
              'Élévation antérieure',
              'Abduction',
              'RE1',
              'RE2 / RM2 (A)',
              'RE2 / RM2 (P)',
              'Main-dos',
            ],
          ),
          AssessmentTemplateField(
            id: 'clinical_tests',
            label: 'Tests cliniques',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'neurodynamics',
            label: 'Neuro-dynamique',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'cervical_assessment',
            label: 'Évaluation cervicale',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'other_testing',
            label: 'Autre testing',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'summary',
        title: 'Synthèse',
        fields: [
          AssessmentTemplateField(
            id: 'clinical_summary',
            label: 'Synthèse clinique',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'care_objectives',
            label: 'Objectifs de prise en charge',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'first_session',
            label: 'Première séance',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'follow_up',
        title: 'Suivi / remarques',
        fields: [
          AssessmentTemplateField(
            id: 'additional_notes',
            label: 'Remarques complémentaires',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),
    ],
  );
}
