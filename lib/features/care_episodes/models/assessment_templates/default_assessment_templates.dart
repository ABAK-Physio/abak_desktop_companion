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
  static const hyperventilation = AssessmentTemplate(
    id: 'hyperventilation',
    name: 'Bilan hyperventilation',
    description:
    'Guide de saisie pour l’évaluation d’un dysfonctionnement respiratoire de type hyperventilation.',
    sections: [
      AssessmentTemplateSection(
        id: 'medical_context',
        title: 'Contexte médical',
        fields: [
          AssessmentTemplateField(
            id: 'general_practitioner',
            label: 'Médecin généraliste',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'pulmonologist',
            label: 'Pneumologue',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'hypocapnia',
            label: 'Hypocapnie',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Oui',
              'Non',
            ],
          ),
          AssessmentTemplateField(
            id: 'pulmonary_function_test',
            label: 'EFR',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Oui',
              'Non',
            ],
          ),
          AssessmentTemplateField(
            id: 'exercise_test',
            label: 'EFXi',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Oui',
              'Non',
            ],
          ),
          AssessmentTemplateField(
            id: 'other_examinations',
            label: 'Autre examen complémentaire',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'professional_activity',
            label:
            'Activité professionnelle, niveau scolaire, mode de vie, sport',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'pulmonary_history',
            label: 'Pathologies pulmonaires et antécédents médicaux',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'interview',
        title: 'Entretien',
        fields: [
          AssessmentTemplateField(
            id: 'patient_understanding',
            label: 'Que savez-vous de ce qui vous arrive ?',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'symptom_duration',
            label: 'Depuis quand êtes-vous gêné ?',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'symptom_onset_context',
            label:
            'Circonstances particulières au moment de l’apparition des symptômes',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'crisis_sensations',
            label: 'Que ressentez-vous lors des crises ?',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'main_discomfort',
            label: 'Quelle est votre gêne principale ?',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'symptom_circumstances',
            label: 'Circonstances de survenue',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'symptom_intensity',
        title: 'Intensité et fréquence',
        fields: [
          AssessmentTemplateField(
            id: 'eva_max',
            label: 'EVA maximale',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'eva_average',
            label: 'EVA moyenne',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'eva_reevaluation',
            label: 'RE-EVAL EVA',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'acute_episode_frequency',
            label: 'Fréquence des épisodes aigus',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Presque tout le temps',
              'Au moins une fois par jour',
              'Quelques fois dans la semaine',
              'Jamais',
            ],
          ),
          AssessmentTemplateField(
            id: 'acute_episode_reevaluation',
            label: 'RE-EVAL épisodes aigus',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'overall_symptom_frequency',
            label: 'Fréquence de l’ensemble des symptômes',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Presque tout le temps',
              'Au moins une fois par jour',
              'Quelques fois dans la semaine',
              'Jamais',
            ],
          ),
          AssessmentTemplateField(
            id: 'overall_symptom_reevaluation',
            label: 'RE-EVAL ensemble des symptômes',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'scores',
        title: 'Scores',
        fields: [
          AssessmentTemplateField(
            id: 'nq_score',
            label: 'Score NQ',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'nq_reevaluation',
            label: 'RE-EVAL NQ',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'had_score',
            label: 'Score HAD',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'had_reevaluation',
            label: 'RE-EVAL HAD',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'other_score_1',
            label: 'Autre score',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'other_score_1_reevaluation',
            label: 'RE-EVAL autre score',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'other_score_2',
            label: 'Autre score',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'other_score_2_reevaluation',
            label: 'RE-EVAL autre score',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'respiratory_exam',
        title: 'Examen respiratoire',
        fields: [
          AssessmentTemplateField(
            id: 'spontaneous_breathing_pattern',
            label: 'Observation des mouvements respiratoires spontanés',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Abdominal (diaphragmatique)',
              'Thoracique',
              'Mixte',
            ],
          ),
          AssessmentTemplateField(
            id: 'respiratory_rate',
            label: 'Fréquence respiratoire',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'respiratory_rate_reevaluation',
            label: 'RE-EVAL fréquence respiratoire',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'max_apnea_time',
            label: 'Temps d’apnée maximal',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'max_apnea_time_reevaluation',
            label: 'RE-EVAL temps d’apnée maximal',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'provoked_hyperventilation',
            label:
            'Une hyperventilation provoquée provoque au moins un des symptômes',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Oui',
              'Non',
            ],
          ),
          AssessmentTemplateField(
            id: 'provoked_hyperventilation_details',
            label: 'Temps et symptômes',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'provoked_hyperventilation_reevaluation',
            label: 'RE-EVAL hyperventilation provoquée',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),
    ],
  );
}
