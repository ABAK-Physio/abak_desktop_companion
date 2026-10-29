import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../dmp_minors/minors_simulation.dart';
import '../dmp_td02/td02_result.dart';

String digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();

class AutoDocument {
  const AutoDocument({
    this.content = 'Bilan fictif : amplitude du genou mesurée à 90 degrés.',
    this.title = 'Bilan fictif',
    this.type = 'bilan-kine-fictif',
    this.patient = SimPatient.adult,
    this.professional = 'simulation-ps-a',
    this.structure = 'simulation-cabinet-a',
    this.clinicalDate = '2026-10-16',
    this.patientVisible = false,
    this.rlVisible = false,
    this.maskedPs = false,
  });
  final String content, title, type, professional, structure, clinicalDate;
  final SimPatient patient;
  final bool patientVisible, rlVisible, maskedPs;
  String get version => digest(toJson());
  bool get empty => content.trim().isEmpty;
  Map<String, Object> toJson() => {
    'content': content,
    'title': title,
    'type': type,
    'patient': patient.name,
    'professional': professional,
    'structure': structure,
    'clinicalDate': clinicalDate,
    'patientVisible': patientVisible,
    'rlVisible': rlVisible,
    'maskedPs': maskedPs,
  };
  factory AutoDocument.fromJson(Map<String, dynamic> j) {
    for (final k in [
      'content',
      'title',
      'type',
      'professional',
      'structure',
      'clinicalDate',
    ]) {
      if (j[k] is! String) throw const FormatException('Document invalide');
    }
    for (final k in ['patientVisible', 'rlVisible', 'maskedPs']) {
      if (j[k] is! bool) throw const FormatException('Visibilité invalide');
    }
    if (!['simulation-ps-a', 'simulation-ps-b'].contains(j['professional']) ||
        ![
          'simulation-cabinet-a',
          'simulation-cabinet-b',
        ].contains(j['structure'])) {
      throw const FormatException('Contexte fictif requis');
    }
    return AutoDocument(
      content: j['content'],
      title: j['title'],
      type: j['type'],
      patient: SimPatient.values.byName(j['patient']),
      professional: j['professional'],
      structure: j['structure'],
      clinicalDate: j['clinicalDate'],
      patientVisible: j['patientVisible'],
      rlVisible: j['rlVisible'],
      maskedPs: j['maskedPs'],
    );
  }
  AutoDocument copy({
    String? content,
    String? title,
    String? type,
    SimPatient? patient,
    String? professional,
    String? structure,
    String? clinicalDate,
    bool? patientVisible,
    bool? rlVisible,
    bool? maskedPs,
  }) => AutoDocument(
    content: content ?? this.content,
    title: title ?? this.title,
    type: type ?? this.type,
    patient: patient ?? this.patient,
    professional: professional ?? this.professional,
    structure: structure ?? this.structure,
    clinicalDate: clinicalDate ?? this.clinicalDate,
    patientVisible: patientVisible ?? this.patientVisible,
    rlVisible: rlVisible ?? this.rlVisible,
    maskedPs: maskedPs ?? this.maskedPs,
  );
  bool sameClinicalContent(AutoDocument other) =>
      content == other.content &&
      title == other.title &&
      type == other.type &&
      clinicalDate == other.clinicalDate;
}

class AutoRule {
  const AutoRule({
    this.enabled = true,
    this.type = 'bilan-kine-fictif',
    this.minors = true,
    this.majority = 18,
    this.cumulative = false,
  });
  final bool enabled, minors, cumulative;
  final int majority;
  final String type;
  Map<String, Object> toJson() => {
    'enabled': enabled,
    'type': type,
    'minors': minors,
    'majority': majority,
    'cumulative': cumulative,
  };
  factory AutoRule.fromJson(Map<String, dynamic> j) {
    if (j['enabled'] is! bool ||
        j['minors'] is! bool ||
        j['cumulative'] is! bool ||
        j['type'] is! String ||
        j['majority'] is! int ||
        j['majority'] < 1 ||
        j['majority'] > 120) {
      throw const FormatException('Règle invalide');
    }
    return AutoRule(
      enabled: j['enabled'],
      type: j['type'],
      minors: j['minors'],
      majority: j['majority'],
      cumulative: j['cumulative'],
    );
  }
}

enum SimIdentity { qualified, nia, unqualified }

class AutoContext {
  const AutoContext({
    this.patient = SimPatient.adult,
    this.professional = 'simulation-ps-a',
    this.structure = 'simulation-cabinet-a',
    this.identity = SimIdentity.qualified,
    this.dmp = DmpState.active,
    this.right = ConsultationRight.valid,
    this.functionalRights = true,
    this.authorRights = true,
    this.opposition = false,
    this.metadataValid = true,
    this.secret,
  });
  final SimPatient patient;
  final String professional, structure;
  final SimIdentity identity;
  final DmpState dmp;
  final ConsultationRight right;
  final bool functionalRights, authorRights, opposition, metadataValid;
  final bool? secret;
  AutoContext copy({
    SimPatient? patient,
    String? professional,
    String? structure,
    SimIdentity? identity,
    DmpState? dmp,
    ConsultationRight? right,
    bool? functionalRights,
    bool? authorRights,
    bool? opposition,
    bool? metadataValid,
    bool? secret,
  }) => AutoContext(
    patient: patient ?? this.patient,
    professional: professional ?? this.professional,
    structure: structure ?? this.structure,
    identity: identity ?? this.identity,
    dmp: dmp ?? this.dmp,
    right: right ?? this.right,
    functionalRights: functionalRights ?? this.functionalRights,
    authorRights: authorRights ?? this.authorRights,
    opposition: opposition ?? this.opposition,
    metadataValid: metadataValid ?? this.metadataValid,
    secret: secret ?? this.secret,
  );
}

class AutoDecision {
  const AutoDecision(this.state, this.message);
  final String state, message;
  bool get ready => state == 'pret';
}

const autoMessages = <String, String>{
  'metadonnees_bloquees':
      'Métadonnées invalides ou incomplètes : correction requise.',
  'pret': 'Version validée et contrôles réunis : traitement simulé prêt.',
  'attente_validation':
      'Validation médicale de la version courante requise. Aucun envoi simulé.',
  'hors_regle':
      'Automatisation désactivée ou aucune règle applicable à ce document.',
  'retenu':
      'Envoi retenu par le professionnel. Retenue conservée après réouverture.',
  'vide': 'Document vide ou gabarit sans contenu clinique : aucun envoi.',
  'inchange': 'Document et métadonnées inchangés : aucun renvoi.',
  'remplacement_a_preparer':
      'Contenu modifié : préparer le parcours de remplacement, sans nouveau dépôt indépendant.',
  'modification_a_preparer':
      'Attributs modifiés : préparer le parcours de modification, sans doublon.',
  'deja_accepte': 'Lot déjà accepté : renvoi bloqué.',
  'accepte_simule':
      'Document accepté par le service simulé après validation et contrôles.',
  'a_verifier': 'Résultat indéterminé : contrôle requis avant toute reprise.',
  'rejete': 'Lot rejeté : préparer une correction ; aucun réessai automatique.',
  'tls_echec':
      'Connexion simulée impossible. Aucun dépôt simulé ; aucune reprise automatique.',
  'stockage_bloque': 'État durable indisponible. Traitement suspendu.',
  'identite_bloquee':
      'Identité NIA ou non qualifiée : accès DMP indisponible. Aucun appel INSi.',
  'dmp_bloque':
      'DMP absent, fermé ou vérification impossible : envoi indisponible.',
  'contexte_perime': 'Contexte modifié : contrôles et aperçu à renouveler.',
  'opposition': 'Opposition à l’alimentation : nouveau dépôt bloqué.',
  'droits_bloques': 'Droits requis non réunis. Envoi bloqué.',
  'contexte_incomplet':
      'Choisir une connexion normale ou secrète pour cette nouvelle session.',
  'confidentialite_bloquee':
      'Visibilité incompatible : secret, remasquage ou cumul interdit. Aucun envoi.',
  'tentative_en_cours':
      'Tentative déjà engagée : retenue trop tardive ; attendre ou vérifier le résultat.',
  'reevaluation':
      'Règles ou paramètres modifiés : réévaluation complète requise.',
};
AutoDecision decision(String state) =>
    AutoDecision(state, autoMessages[state]!);
