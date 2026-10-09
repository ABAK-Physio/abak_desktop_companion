# Prototype planning

Depuis la racine du dépôt, lancer le point d’entrée dédié :

```sh
flutter run -d macos -t lib/main_planning.dart
```

L’entrée dédiée utilise maintenant la base SQLite Companion et sa migration v33.
Le menu principal reste inchangé. Une base planning vide affiche un calendrier
vide : aucun événement fictif ni rendez-vous de l’ancienne session en mémoire
n’est importé automatiquement. Les tests sans dépôt injecté gardent la démo.

Après mise à jour, redémarrer complètement le point d’entrée dédié (un simple
rechargement à chaud ne relance pas `main`). Les anciennes données de démo
restent temporaires jusqu’à leur fermeture.

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
- Créer deux séances simultanées à 9 h et 9 h 15 pour vérifier les chevauchements,
  puis un événement sur toute la journée.
- En Jour/Semaine, les rendez-vous qui se chevauchent sont partiellement
  superposés avec un décalage horizontal, en conservant leurs horaires et
  un bord gauche accessible au clic. Ils ont aussi un contour rouge
  et un pictogramme d’alerte. Le survol et les détails indiquent la plage
  commune et l’autre rendez-vous. Deux rendez-vous consécutifs et les
  événements sur toute la journée ne déclenchent pas cette alerte.
- Redimensionner la fenêtre jusqu’à 900 × 650.

Les ajouts, modifications, déplacements, changements de durée, suppressions et
annulations sont enregistrés avant d’être affichés. En cas d’erreur, la saisie
reste dans le formulaire ; les autres actions proposent Réessayer.
Fermer et relancer pour vérifier la conservation des rendez-vous, puis supprimer
le dernier et relancer pour vérifier que le calendrier reste vide.

## Vérification ciblée

```sh
flutter analyze lib/main_planning.dart lib/features/planning/prototype test/planning_prototype_test.dart
flutter test test/planning_prototype_test.dart test/planning_event_drag_test.dart
```

`calendar_view` est fixé à `2.0.0` : son éditeur recommande de figer les versions
2.x, qui peuvent contenir des changements incompatibles.

## Intégration SQLite

Voir [les détails d’intégration SQLite](../SQLITE_INTEGRATION.md).

## Essai de l’association patient

- Créer un rendez-vous, cliquer sur Associer un patient et rechercher un dossier.
- Vérifier la date de naissance avant sélection, puis Enregistrer.
- Vérifier le nom sur les cartes Jour/Semaine et dans les détails des trois vues.
- Modifier le rendez-vous pour changer ou retirer le patient ; Annuler doit
  conserver la valeur précédente.
- Déplacer, redimensionner, supprimer puis Annuler : l’association est conservée.
- Fermer et relancer pour vérifier le lien enregistré. Un créneau sans patient
  reste possible avec son titre habituel (pause, réunion, etc.).

## Ouvrir le dossier patient

Dans les détails d’un rendez-vous lié, utiliser **Ouvrir le dossier patient**.
Le dossier habituel Companion s’ouvre, y compris pour un patient archivé.
La flèche Retour ramène au planning à la même date et dans la même vue ; les
associations et noms sont rechargés. Un créneau sans patient ne propose pas ce
bouton. Si le patient a été supprimé entre-temps, un message l’indique et le
planning est actualisé. Le lancement dédié inclut les traductions Companion
nécessaires à cet écran. Le menu principal reste inchangé.
