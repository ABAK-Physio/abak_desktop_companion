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
  static const traumaticAnkle = AssessmentTemplate(
    id: 'traumatic_ankle',
    name: 'BILAN et SUIVI KINÉ – CHEVILLE TRAUMATIQUE',
    description:
    'Guide de saisie fidèle au modèle de bilan et suivi kiné de cheville traumatique.',
    sections: [
      AssessmentTemplateSection(
        id: 'patient_context',
        title: 'Patient',
        fields: [
          AssessmentTemplateField(
            id: 'patient_name',
            label: 'NOM Prénom',
            type: AssessmentTemplateFieldType.abakData,
            abakSource: 'patient_full_name',
          ),
          AssessmentTemplateField(
            id: 'patient_birth_date',
            label: 'Date de naissance',
            type: AssessmentTemplateFieldType.abakData,
            abakSource: 'patient_birth_date',
          ),
          AssessmentTemplateField(
            id: 'patient_age',
            label: 'Âge',
            type: AssessmentTemplateFieldType.abakData,
            abakSource: 'patient_age',
          ),
          AssessmentTemplateField(
            id: 'profession',
            label: 'Profession',
            type: AssessmentTemplateFieldType.abakData,
            abakSource: 'patient.profession',
          ),
          AssessmentTemplateField(
            id: 'sports_leisure',
            label: 'Activités sportives/loisirs',
            type: AssessmentTemplateFieldType.abakData,
            abakSource: 'patient.sportsActivities',
          ),
          AssessmentTemplateField(
            id: 'family_context',
            label: 'Familial',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'interview',
        title: 'Entretien',
        fields: [
          AssessmentTemplateField(
            id: 'consultation_reason',
            label: 'Motif de consultation',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'side',
            label: 'Coté',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Gauche',
              'Droite',
            ],
          ),
          AssessmentTemplateField(
            id: 'laterality',
            label: 'Latéralité',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Gauche',
              'Droite',
            ],
          ),
          AssessmentTemplateField(
            id: 'circumstance',
            label: 'Circonstance',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'date',
            label: 'Date',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'history',
            label: 'Antécédents',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'treatments',
            label: 'Traitements',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'care_pathway',
            label: 'Parcours de soin',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'additional_examinations',
            label: 'Examens complémentaires',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'technical_aids',
            label: 'Aides techniques',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'patient_complaint',
            label: 'Plainte du patient',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'objectives',
            label: 'Objectifs',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'yellow_flags',
            label: 'Drapeaux jaunes',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),
      AssessmentTemplateSection(
        id: 'initial_screening',
        title: 'BILAN INITIAL – On field',
        fields: [
          AssessmentTemplateField(
            id: 'ottawa_2x2_steps',
            label: '2x2 pas',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Positif',
              'Négatif',
            ],
          ),
          AssessmentTemplateField(
            id: 'ottawa_malleoli',
            label: 'palpa pointe malléoles + bord post 6cm',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Positif',
              'Négatif',
            ],
          ),
          AssessmentTemplateField(
            id: 'ottawa_fifth_metatarsal',
            label: 'palpa 5ème métatarsien',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Positif',
              'Négatif',
            ],
          ),
          AssessmentTemplateField(
            id: 'ottawa_navicular',
            label: 'palpa naviculaire',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Positif',
              'Négatif',
            ],
          ),
          AssessmentTemplateField(
            id: 'ottawa_information',
            label:
            'Sensible ++ mais peu spécifique\n'
                'Si au moins 1 critère positif, fait Bernèse\n'
                'Si doute chez -16 ans, passer une radio',
            type: AssessmentTemplateFieldType.information,
          ),

          AssessmentTemplateField(
            id: 'bernese_fibula_constraint',
            label: 'test contrainte directe fibula (squeeze test)',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Positif',
              'Négatif',
            ],
          ),
          AssessmentTemplateField(
            id: 'bernese_medial_malleolus',
            label: 'compression malléole médiale',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Positif',
              'Négatif',
            ],
          ),
          AssessmentTemplateField(
            id: 'bernese_forefoot',
            label: 'compression avant pied dans arrière pied',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Positif',
              'Négatif',
            ],
          ),
          AssessmentTemplateField(
            id: 'bernese_information',
            label: 'Spécifique mais peu sensible, d’où à faire après Ottawa',
            type: AssessmentTemplateFieldType.information,
          ),

          AssessmentTemplateField(
            id: 'neurovascular_hypoesthesia',
            label: 'hypoesthésie/paresthésie',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'neurovascular_pulses',
            label: 'pouls pédieux et tibial post',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'neurovascular_capillary_refill',
            label: 'recoloration capillaire des orteils',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'calcaneal_tendon_thompson',
            label: 'Thompson',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Positif',
              'Négatif',
            ],
          ),
          AssessmentTemplateField(
            id: 'calcaneal_tendon_matles',
            label: 'Matles',
            type: AssessmentTemplateFieldType.singleChoice,
            options: [
              'Positif',
              'Négatif',
            ],
          ),

          AssessmentTemplateField(
            id: 'fibular_retinaculum_subluxation',
            label: 'subluxation tendon fibulaires',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),
      AssessmentTemplateSection(
        id: 'initial_pain',
        title: 'BILAN INITIAL – Douleur',
        fields: [
          AssessmentTemplateField(
            id: 'initial_pain_eva',
            label: 'EVA',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_pain_location',
            label: 'Localisation',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'initial_pain_schedule_aggravating_factors',
            label: 'Horaire/facteurs aggravant',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'initial_cutaneous_trophic_circulatory',
        title: 'BILAN INITIAL – Cutané, trophique et circulatoire',
        fields: [
          AssessmentTemplateField(
            id: 'initial_edema',
            label: 'Oedème (+ mesure en 8)',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_hematoma',
            label: 'Hématome',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'initial_sprain',
        title: 'BILAN INITIAL – Entorse',
        fields: [
          AssessmentTemplateField(
            id: 'initial_ltfa_palpation',
            label: 'palpation LTFA',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_lcf_palpation',
            label: 'palpation LCF',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_anterior_drawer',
            label: 'tiroir ant en FD et FP (LTFA)',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_talar_tilt',
            label: 'talar tilt test (LCF)',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'initial_syndesmosis',
        title: 'BILAN INITIAL – Lésion syndesmose',
        fields: [
          AssessmentTemplateField(
            id: 'initial_syndesmosis_palpation',
            label: 'palpation (Se++)',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_cross_leg_test',
            label: 'cross leg test',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_lunge',
            label: 'fente',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_external_rotation_stress_test',
            label: 'external rotation stress test / Kléber (Spé++)',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_syndesmosis_squeeze_test',
            label: 'squeeze test (spé++)',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'initial_posterior_impingement',
        title: 'BILAN INITIAL – Conflit postérieur',
        fields: [
          AssessmentTemplateField(
            id: 'initial_repeated_hyperextension',
            label: 'hyperextension répétées',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_posterior_impingement_palpation',
            label: 'palpation',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_calcaneal_impaction',
            label: 'impaction calca en flexion plantaire',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'initial_range_of_motion',
        title: 'BILAN INITIAL – Amplitudes articulaires',
        fields: [
          AssessmentTemplateField(
            id: 'initial_global_range_of_motion',
            label: 'globale',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_wblt',
            label: 'WBLT',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'initial_muscle_strength',
        title: 'BILAN INITIAL – Force musculaire',
        fields: [
          AssessmentTemplateField(
            id: 'initial_muscle_strength_table',
            label: 'Force musculaire',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Gauche',
              'Droite',
              'Déficit',
              'Notes',
            ],
            tableRows: [
              'Éverseurs',
              'Abd hanche',
              'Triceps sural (heel raise test)',
            ],
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'initial_static_postural_control',
        title: 'BILAN INITIAL – Contrôle postural statique',
        fields: [
          AssessmentTemplateField(
            id: 'initial_static_postural_control_table',
            label: 'Contrôle postural statique',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Gauche',
              'Droite',
              'Déficit',
              'Notes',
            ],
            tableRows: [
              'SLS (YF 20’’)',
              'SEBT Ant',
              'SEBT postéro-med',
              'SEBT postéro-lat',
              'SEBT moy',
            ],
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'initial_proprioception',
        title: 'BILAN INITIAL – Proprioception',
        fields: [
          AssessmentTemplateField(
            id: 'initial_jps_fd_fp',
            label: 'JPS FD/FP',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'initial_jps_inversion_eversion',
            label: 'JPS inversion/eversion',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'initial_ankle_instability',
        title: 'BILAN INITIAL – Instabilité cheville',
        fields: [
          AssessmentTemplateField(
            id: 'initial_cait',
            label: 'CAIT',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),
      AssessmentTemplateSection(
        id: 'intermediate_information',
        title: 'BILAN INTERMÉDIAIRE – ROAST',
        fields: [
          AssessmentTemplateField(
            id: 'intermediate_information_text',
            label: 'En fonction des déficits retrouvés au bilan initial',
            type: AssessmentTemplateFieldType.information,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'intermediate_pain',
        title: 'BILAN INTERMÉDIAIRE – Douleur',
        fields: [
          AssessmentTemplateField(
            id: 'intermediate_pain_eva',
            label: 'EVA',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'intermediate_pain_location',
            label: 'Localisation',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'intermediate_pain_schedule_aggravating_factors',
            label: 'Horaire/facteurs aggravant',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'intermediate_cutaneous_trophic_circulatory',
        title: 'BILAN INTERMÉDIAIRE – Cutané, trophique et circulatoire',
        fields: [
          AssessmentTemplateField(
            id: 'intermediate_edema',
            label: 'Oedème (+ mesure en 8)',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'intermediate_hematoma',
            label: 'Hématome',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'intermediate_range_of_motion',
        title: 'BILAN INTERMÉDIAIRE – Amplitudes articulaires',
        fields: [
          AssessmentTemplateField(
            id: 'intermediate_global_range_of_motion',
            label: 'globale',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'intermediate_wblt',
            label: 'WBLT',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'intermediate_posterior_talar_glide',
            label: 'posterior talar glide',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'intermediate_muscle_strength',
        title: 'BILAN INTERMÉDIAIRE – Force musculaire',
        fields: [
          AssessmentTemplateField(
            id: 'intermediate_muscle_strength_table',
            label: 'Force musculaire',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Gauche',
              'Droite',
              'Déficit',
              'Notes',
            ],
            tableRows: [
              'Éverseurs',
              'Abd hanche',
              'Triceps sural (heel raise test)',
            ],
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'intermediate_static_postural_control',
        title: 'BILAN INTERMÉDIAIRE – Contrôle postural statique',
        fields: [
          AssessmentTemplateField(
            id: 'intermediate_static_postural_control_table',
            label: 'Contrôle postural statique',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Gauche',
              'Droite',
              'Déficit',
              'Notes',
            ],
            tableRows: [
              'SLS (YF 20’’)',
              'SEBT Ant',
              'SEBT postéro-med',
              'SEBT postéro-lat',
              'SEBT moy',
            ],
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'intermediate_proprioception',
        title: 'BILAN INTERMÉDIAIRE – Proprioception',
        fields: [
          AssessmentTemplateField(
            id: 'intermediate_jps_fd_fp',
            label: 'JPS FD/FP',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'intermediate_jps_inversion_eversion',
            label: 'JPS inversion/eversion',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),
      AssessmentTemplateSection(
        id: 'intermediate_ankle_go',
        title: 'ANKLE GO',
        fields: [
          AssessmentTemplateField(
            id: 'intermediate_ankle_go_information',
            label:
            'M+2 (>19 ok, si <8 faible chance de retour avant M+4)\n'
                'Et retour au sport si besoin',
            type: AssessmentTemplateFieldType.information,
          ),

          AssessmentTemplateField(
            id: 'intermediate_ankle_go_sls_information',
            label:
            'SLS\n'
                '>3 erreurs : 0\n'
                '1–3 erreurs : 1\n'
                '0 erreur : 2\n'
                'Pas d’appréhension : +1',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'intermediate_ankle_go_sls',
            label: 'SLS /3',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'intermediate_ankle_go_sebt_information',
            label:
            'SEBT\n'
                '<90% : 0\n'
                '90–95% : 2\n'
                '>95% : 4\n'
                'Antérieur >60% : +1\n'
                'Postéro-médial >90% : +1\n'
                'Pas d’appréhension : +1',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'intermediate_ankle_go_sebt',
            label: 'SEBT /7',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'intermediate_ankle_go_sht_information',
            label:
            'SHT\n'
                '>13s : 0\n'
                '10–13s : 2\n'
                '<10s : 4\n'
                'Pas d’appréhension : +1',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'intermediate_ankle_go_sht',
            label: 'SHT /5',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'intermediate_ankle_go_f8t_information',
            label:
            'F8T\n'
                '>18s : 0\n'
                '13–18s : 1\n'
                '<13s : 2\n'
                'Pas d’appréhension : +1',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'intermediate_ankle_go_f8t',
            label: 'F8T /3',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'intermediate_ankle_go_faam_avq_information',
            label:
            'FAAM AVQ\n'
                '<90% : 0\n'
                '90–95% : 1\n'
                '>95% : 2',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'intermediate_ankle_go_faam_avq',
            label: 'FAAM AVQ /2',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'intermediate_ankle_go_faam_sport_information',
            label:
            'FAAM Sport\n'
                '<80% : 0\n'
                '80–95% : 1\n'
                '>95% : 2',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'intermediate_ankle_go_faam_sport',
            label: 'FAAM Sport /2',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'intermediate_ankle_go_alr_rsi_information',
            label:
            'ALR RSI\n'
                '<55% : 0\n'
                '55–63% : 1\n'
                '63–76% : 2\n'
                '>76% : 3',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'intermediate_ankle_go_alr_rsi',
            label: 'ALR RSI /3',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'intermediate_ankle_go_total',
            label: 'TOTAL /25',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),
      AssessmentTemplateSection(
        id: 'final_pain',
        title: 'BILAN FINAL – RTP – Douleur',
        fields: [
          AssessmentTemplateField(
            id: 'final_pain_eva',
            label: 'EVA',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'final_pain_location',
            label: 'Localisation',
            type: AssessmentTemplateFieldType.longText,
          ),
          AssessmentTemplateField(
            id: 'final_pain_schedule_aggravating_factors',
            label: 'Horaire/facteurs aggravant',
            type: AssessmentTemplateFieldType.longText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'final_cutaneous_trophic_circulatory',
        title: 'BILAN FINAL – RTP – Cutané, trophique et circulatoire',
        fields: [
          AssessmentTemplateField(
            id: 'final_edema',
            label: 'Oedème (+ mesure en 8)',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'final_hematoma',
            label: 'Hématome',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'final_range_of_motion',
        title: 'BILAN FINAL – RTP – Amplitudes articulaires',
        fields: [
          AssessmentTemplateField(
            id: 'final_global_range_of_motion',
            label: 'globale',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'final_wblt',
            label: 'WBLT',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'final_posterior_talar_glide',
            label: 'posterior talar glide',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'final_muscle_strength',
        title: 'BILAN FINAL – RTP – Force musculaire',
        fields: [
          AssessmentTemplateField(
            id: 'final_muscle_strength_table',
            label: 'Force musculaire',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Gauche',
              'Droite',
              'Déficit',
              'Notes',
            ],
            tableRows: [
              'Éverseurs',
              'Abd hanche',
              'Triceps sural (heel raise test)',
            ],
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'final_static_postural_control',
        title: 'BILAN FINAL – RTP – Contrôle postural statique',
        fields: [
          AssessmentTemplateField(
            id: 'final_static_postural_control_table',
            label: 'Contrôle postural statique',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Gauche',
              'Droite',
              'Déficit',
              'Notes',
            ],
            tableRows: [
              'SLS (YF 20’’)',
              'SEBT Ant',
              'SEBT postéro-med',
              'SEBT postéro-lat',
              'SEBT moy',
            ],
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'final_proprioception',
        title: 'BILAN FINAL – RTP – Proprioception',
        fields: [
          AssessmentTemplateField(
            id: 'final_jps_fd_fp',
            label: 'JPS FD/FP',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'final_jps_inversion_eversion',
            label: 'JPS inversion/eversion',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'final_functional_tests',
        title: 'BILAN FINAL – RTP – Tests fonctionnels',
        fields: [
          AssessmentTemplateField(
            id: 'final_single_hop_test',
            label: 'single hop test',
            type: AssessmentTemplateFieldType.shortText,
          ),
          AssessmentTemplateField(
            id: 'final_side_hop_test_information',
            label:
            'side hop test\n'
                '10 A/R vitesse\n'
                '30s endurance\n'
                '30 ou 40cm ?',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'final_side_hop_test',
            label: 'side hop test',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'final_ankle_go',
        title: 'BILAN FINAL – RTP – ANKLE GO',
        fields: [
          AssessmentTemplateField(
            id: 'final_ankle_go_sls_information',
            label:
            'SLS\n'
                '>3 erreurs : 0\n'
                '1–3 erreurs : 1\n'
                '0 erreur : 2\n'
                'Pas d’appréhension : +1',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'final_ankle_go_sls',
            label: 'SLS /3',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'final_ankle_go_sebt_information',
            label:
            'SEBT\n'
                '<90% : 0\n'
                '90–95% : 2\n'
                '>95% : 4\n'
                'Antérieur >60% : +1\n'
                'Postéro-médial >90% : +1\n'
                'Pas d’appréhension : +1',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'final_ankle_go_sebt',
            label: 'SEBT /7',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'final_ankle_go_sht_information',
            label:
            'SHT\n'
                '>13s : 0\n'
                '10–13s : 2\n'
                '<10s : 4\n'
                'Pas d’appréhension : +1',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'final_ankle_go_sht',
            label: 'SHT /5',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'final_ankle_go_f8t_information',
            label:
            'F8T\n'
                '>18s : 0\n'
                '13–18s : 1\n'
                '<13s : 2\n'
                'Pas d’appréhension : +1',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'final_ankle_go_f8t',
            label: 'F8T /3',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'final_ankle_go_faam_avq_information',
            label:
            'FAAM AVQ\n'
                '<90% : 0\n'
                '90–95% : 1\n'
                '>95% : 2',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'final_ankle_go_faam_avq',
            label: 'FAAM AVQ /2',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'final_ankle_go_faam_sport_information',
            label:
            'FAAM Sport\n'
                '<80% : 0\n'
                '80–95% : 1\n'
                '>95% : 2',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'final_ankle_go_faam_sport',
            label: 'FAAM Sport /2',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'final_ankle_go_alr_rsi_information',
            label:
            'ALR RSI\n'
                '<55% : 0\n'
                '55–63% : 1\n'
                '63–76% : 2\n'
                '>76% : 3',
            type: AssessmentTemplateFieldType.information,
          ),
          AssessmentTemplateField(
            id: 'final_ankle_go_alr_rsi',
            label: 'ALR RSI /3',
            type: AssessmentTemplateFieldType.shortText,
          ),

          AssessmentTemplateField(
            id: 'final_ankle_go_total',
            label: 'TOTAL /25',
            type: AssessmentTemplateFieldType.shortText,
          ),
        ],
      ),

      AssessmentTemplateSection(
        id: 'hertel_evolution',
        title: 'Évolution selon le modèle de Hertel',
        fields: [
          AssessmentTemplateField(
            id: 'hertel_dates',
            label: 'Dates',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Début rééduc',
              'Milieu rééduc',
              'Fin rééduc (RTS)',
              'Postrééduc (RTP)',
            ],
            tableRows: [
              'Date',
            ],
          ),
          AssessmentTemplateField(
            id: 'hertel_pathomechanical',
            label: 'Déficiences patho-mécaniques',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Début rééduc',
              'Milieu rééduc',
              'Fin rééduc (RTS)',
              'Postrééduc (RTP)',
            ],
            tableRows: [
              'Laxité',
              'Restriction',
              'Restriction MSK ou neuro',
              'Lésion tissulaire secondaire',
              'Adaptation tissulaire',
            ],
          ),
          AssessmentTemplateField(
            id: 'hertel_motor',
            label: 'Déficiences motrices',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Début rééduc',
              'Milieu rééduc',
              'Fin rééduc (RTS)',
              'Postrééduc (RTP)',
            ],
            tableRows: [
              'Réflexes altérés',
              'Inhibition neuro-musculaire',
              'Faiblesse musculaire',
              'Déficit d’équilibration',
              'Schéma moteur altéré',
              'Activité physique réduite',
            ],
          ),
          AssessmentTemplateField(
            id: 'hertel_sensory_perceptual',
            label: 'Déficiences sensorielles et perceptives',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Début rééduc',
              'Milieu rééduc',
              'Fin rééduc (RTS)',
              'Postrééduc (RTP)',
            ],
            tableRows: [
              'Douleur',
              'Déficiences somato-sensorielle',
              'Instabilité perçue',
              'Kinésiophobie',
              'Faible fonction auto-rapportée',
              'Qualité de vie diminuée',
            ],
          ),
          AssessmentTemplateField(
            id: 'hertel_individual_environment',
            label: 'Facteurs individuels et environnement',
            type: AssessmentTemplateFieldType.simpleTable,
            tableRowHeader: '',
            tableColumns: [
              'Début rééduc',
              'Milieu rééduc',
              'Fin rééduc (RTS)',
              'Postrééduc (RTP)',
            ],
            tableRows: [
              'Profil psychologique',
              'Caractéristiques physiques',
              'ATCD',
              'Exigences sport/activité',
              'Exigences professionnelles',
              'Environnement social',
              'Accès soin',
            ],
          ),
        ],
      ),
    ],
  );
}
