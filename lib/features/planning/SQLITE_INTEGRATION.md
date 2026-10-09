# Intégration SQLite

État : activée par `main_planning.dart`, via `DatabaseService.database`.
La migration v32 ajoute `planning_appointments` sans importer les événements
fictifs. Le menu principal propose maintenant une entrée Planning.

## Couche de données

- `models/planning_appointment.dart` : rendez-vous indépendant de Flutter,
  identifiant stable, titre, date civile locale, début/fin en minutes, notes et
  couleur ARGB. Deux horaires nuls signifient « Toute la journée ».
- `data/planning_schema.dart` : création de `planning_appointments` et d’un index
  date/horaire. Plusieurs rendez-vous peuvent occuper le même créneau.
- `data/planning_repository.dart` : lecture par période [début, fin[, ajout,
  modification, suppression et restauration par réinsertion du même identifiant.
  Le fournisseur de base est injecté et résolu à chaque opération pour respecter
  une éventuelle restauration de la base. Les erreurs remontent à l’appelant.
- `prototype/planning_calendar_adapter.dart` : conversion vers/depuis
  `calendar_view`, avec l’identifiant dans `event`. Aucun objet Flutter en base.

Le modèle accepte les horaires d’une journée jusqu’à minuit ; le formulaire
actuel conserve sa plage 07:00–21:00. Pas de récurrence, rendez-vous multijours,
association praticien, ni statut métier dans cette première préparation.
Les dates/heures sont celles du calendrier local du cabinet, sans conversion UTC.
Un usage dans plusieurs fuseaux horaires nécessiterait une politique dédiée.

## Fonctionnement

- La création, la migration depuis v31 et la réinitialisation incluent le planning.
  Les tables oubliées par l’ancienne réinitialisation sont aussi supprimées avant
  recréation, notamment les correspondants et les brouillons.
- Le démarrage charge tous les rendez-vous. Une base vide reste vide. Le chargement
  échoué bloque les actions et propose Réessayer.
- Un UUID est attribué à l’ajout ; les changements conservent cet identifiant.
- Chaque action attend SQLite avant de modifier le calendrier. Les écritures sont
  bloquées pendant l’opération ; une annulation de suppression attend l’écriture
  en cours. Les erreurs conservent le formulaire ou proposent Réessayer.
- Les sauvegardes complètes et restaurations Companion incluent le planning.
  Les exports métier ne sont pas étendus par ce chantier.

Le chargement complet convient à cette première version. Une lecture par période
est disponible dans le dépôt pour limiter ultérieurement le volume en mémoire.
L’écran ne se recharge pas automatiquement si une autre instance de Companion
restaure ou modifie la base ; relancer le planning dans ce cas.

## Vérification

```sh
flutter test test/planning_repository_test.dart test/planning_migration_test.dart test/planning_persistence_ui_test.dart test/planning_prototype_test.dart test/planning_event_drag_test.dart test/patient_backup_restore_test.dart
flutter analyze lib/main_planning.dart lib/core/database/database_service.dart lib/features/planning test/planning_repository_test.dart test/planning_migration_test.dart test/planning_persistence_ui_test.dart
```

Les tests SQLite utilisent uniquement des fichiers temporaires. Ils couvrent
fermeture/réouverture, migration v31, intégrité des données préexistantes,
réinitialisation et sauvegarde/restauration. Les tests d’interface vérifient
l’identité stable, les écritures retardées, les erreurs, la suppression et Annuler.

## Association patient (v33)

La migration v33 ajoute `patient_id` nullable et un index. Les rendez-vous
existants restent sans patient et conservent leurs autres champs. Le nom du
patient est obtenu par jointure lors du chargement, sans copie persistante.

Le formulaire propose une recherche parmi les patients actifs (nom, prénom,
date de naissance ISO). Les 30 premiers résultats sont affichés, avec la date
pour distinguer les homonymes. Choisir, changer ou retirer le patient ne prend
effet qu’après Enregistrer ; Annuler conserve l’association précédente.
Le titre du rendez-vous reste indépendant du patient.

Les rendez-vous de patients archivés gardent leur lien et portent la mention
« archivé » au prochain chargement. Une suppression définitive du patient
retire le lien sans supprimer le rendez-vous, via un déclencheur SQLite même
lorsque les clés étrangères ne sont pas activées. Les écritures vérifient dans
leur transaction que le patient existe. Si un patient a été supprimé dans une
autre fenêtre, recharger le planning ou retirer le patient du formulaire avant
d’enregistrer. Aucune modification automatique du titre ou des notes.

## Horaires d’ouverture

`PlanningOpeningHoursRepository` stocke le calendrier hebdomadaire sous la clé
`planning_opening_hours_v1` dans `application_settings`, sans migration du schéma.
La valeur JSON versionnée contient exactement sept jours et leurs plages en
minutes locales. Une valeur absente signifie « non configuré », une liste vide
pour un jour signifie « fermé ». L’enregistrement remplace la semaine entière en
une écriture atomique ; aucun autre paramètre n’est modifié. Les sauvegardes et
réinitialisations habituelles de la table des paramètres incluent cette valeur.
Les données invalides ou de version inconnue sont rejetées à la lecture, sans
remplacement automatique. Aucune restriction d’écriture des rendez-vous ne
dépend de ces paramètres. La vue mensuelle utilise ces paramètres, en attendant les horaires individuels
des praticiens.


## Types et synthèse mensuelle (v34)

`event_kind` prend les valeurs `appointment` (défaut) ou `unavailable`.
La migration conserve les événements existants comme rendez-vous. L’adaptateur
transporte le type pendant les modifications, gestes, suppressions et annulations.
La conversion en indisponibilité retire l’association patient.

Le calcul par demi-journée découpe à 12:00, compte les RV qui intersectent la
période et soustrait l’union des plages occupées (RV et indisponibilités) de chaque
plage d’ouverture. Il conserve le plus grand intervalle restant, sans additionner
les petits trous ni traiter une période fermée comme disponible. Un événement
toute la journée occupe les deux demi-journées. L’absence d’horaires et une erreur
de lecture sont affichées sans inventer de disponibilité.

## Horaires individuels des praticiens (v35)

La fiche praticien propose « Suivre les horaires du cabinet » par défaut, ou une
semaine personnalisée avec plusieurs plages par jour (07:00–21:00). Une journée
sans plage est non travaillée. La colonne nullable `practitioners.working_hours_json`
utilise le même format hebdomadaire validé que les horaires du cabinet. `NULL`
signifie suivre les horaires actuels du cabinet, sans copie figée ; une semaine
personnalisée vide signifie explicitement aucune présence. Les praticiens
existants migrent vers le mode par défaut sans changement d’identité ou de statut.

L’éditeur partagé des horaires applique un brouillon à la fiche, sans écriture.
Seule la validation de la fiche renvoie le praticien au dépôt pour enregistrement
avec ses autres champs ; Annuler abandonne les changements. Le premier brouillon
personnalisé est prérempli avec les horaires actuels du cabinet lorsqu’ils existent.
Les horaires du cabinet ne sont jamais modifiés par cette fiche.

Les calculs mensuels utilisent la semaine personnalisée du praticien lorsqu’elle
existe, sinon les horaires du cabinet. « Repos » indique une demi-journée non
travaillée dans sa semaine personnalisée. RV et pauses sont déduits de ces plages ;
les RV exceptionnels hors horaires restent comptés. Aucune restriction de saisie
supplémentaire n’est ajoutée (limites maintenues : 07:00–21:00).


## Accès depuis Companion

L’entrée Planning du menu principal est placée après Praticiens et avant
Correspondants. `PlanningEntryScreen` initialise les formats de date et les
libellés du calendrier avant d’afficher l’écran existant avec le dépôt SQLite.
Aucune seconde application ni base n’est créée. Les autres destinations sont
conservées ; le menu peut défiler verticalement sur une fenêtre basse.


## Rattachement des événements — schéma 36

`planning_appointments.practitioner_id` rattache RV et pauses au praticien choisi.
La requête du planning filtre cet identifiant en SQLite, avec un index par praticien
et date. Création, modification et annulation de suppression conservent ce lien.
Les anciens événements sans praticien restent conservés par la migration, mais
ne figurent pas dans les agendas individuels. La remise à zéro demandée pour les
tests a été faite séparément sur la base locale, sans suppression automatique
au démarrage ni à la restauration d’une sauvegarde.


## Pas individuel — schéma 37

`practitioners.appointment_step_minutes` est obligatoire, vaut 15 par défaut
et accepte uniquement 15, 20 ou 30. La migration ne modifie aucun rendez-vous.
Le réglage est sauvegardé avec la fiche et abandonné si elle est annulée.


## Durée habituelle — schéma 38

`practitioners.appointment_duration_minutes` est obligatoire, vaut 45 par défaut
(comportement précédent) et accepte de 1 à 840 minutes. La migration conserve
les pas choisis et ne modifie aucun rendez-vous existant. La durée est enregistrée
avec la fiche praticien ; son annulation abandonne aussi ce changement.
