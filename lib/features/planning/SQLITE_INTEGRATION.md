# Intégration SQLite

État : activée par `main_planning.dart`, via `DatabaseService.database`.
La migration v32 ajoute `planning_appointments` sans importer les événements
fictifs. Le menu principal reste inchangé.

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
