# Prototype planning

Depuis la racine du dépôt, lancer le point d’entrée dédié :

```sh
flutter run -d macos -t lib/main_planning.dart
```

Le lancement habituel avec `lib/main.dart` reste inchangé.
Le prototype ne démarre pas les services métier de Companion et n’utilise ni
SQLite, ni les modèles patients, ni les préférences persistantes. Il partage
cependant le projet Flutter et son exécutable natif : ce n’est pas une nouvelle
application installée avec un identifiant distinct.

## Essai manuel

- Basculer entre Jour, Semaine et Mois : la date sélectionnée est conservée.
- Utiliser les flèches pour changer de période et Aujourd’hui pour revenir.
- En vue Mois, cliquer sur une case pour ouvrir sa journée.
- Cliquer sur un rendez-vous pour afficher ses détails.
- Utiliser Nouveau rendez-vous ou cliquer sur un créneau vide en Jour/Semaine
  pour créer un rendez-vous. La saisie accepte un titre, une date, des horaires
  entre 07:00 et 21:00, des notes et l’option Toute la journée.
- Dans les détails, utiliser Modifier. Enregistrer applique les changements
  aux trois vues et recalcule les chevauchements ; Annuler conserve l’original.
- Dans les détails, Supprimer retire le rendez-vous des trois vues. L’action
  Annuler du message affiché pendant 10 secondes restaure intégralement le
  dernier rendez-vous supprimé, y compris ses horaires et ses notes.
- En Jour/Semaine, glisser une carte pour changer son horaire sans modifier sa
  durée. En Semaine, la déposer dans une autre colonne change aussi son jour.
- Tirer la petite poignée du bord inférieur pour changer l’heure de fin.
  Le pas est de 15 minutes, la durée minimale après redimensionnement de
  15 minutes et les horaires restent entre 07:00 et 21:00.
- L’aperçu indique les horaires proposés. Relâcher applique le changement ;
  Échap ou un relâchement hors de la grille annule. Les chevauchements sont
  recalculés au relâchement. Ces gestes concernent les rendez-vous horaires,
  dans la période visible ; les événements Toute la journée restent modifiables
  par le formulaire. Aucun défilement automatique n’est déclenché au bord.
- Vérifier les deux séances simultanées à 9 h et 9 h 15, le bilan de 14 h
  et l’événement sur toute la journée.
- En Jour/Semaine, les rendez-vous qui se chevauchent sont partiellement
  superposés avec un décalage horizontal, en conservant leurs horaires et
  un bord gauche accessible au clic. Ils ont aussi un contour rouge
  et un pictogramme d’alerte. Le survol et les détails indiquent la plage
  commune et l’autre rendez-vous. Deux rendez-vous consécutifs et les
  événements sur toute la journée ne déclenchent pas cette alerte.
- Redimensionner la fenêtre jusqu’à 900 × 650.

Les événements sont fictifs, générés du jour de lancement moins 7 jours à plus
14 jours inclus. Les autres périodes sont vides. Tout reste en mémoire et est
recréé au lancement. Les rendez-vous créés ou modifiés pendant la session sont
perdus à la fermeture. Les suppressions restent elles aussi limitées à la session.

## Vérification ciblée

```sh
flutter analyze lib/main_planning.dart lib/features/planning/prototype test/planning_prototype_test.dart
flutter test test/planning_prototype_test.dart test/planning_event_drag_test.dart
```

`calendar_view` est fixé à `2.0.0` : son éditeur recommande de figer les versions
2.x, qui peuvent contenir des changements incompatibles.
