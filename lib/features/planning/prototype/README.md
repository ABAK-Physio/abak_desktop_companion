# Prototype planning

Depuis le lancement habituel de Companion (`lib/main.dart`), ouvrir **Planning**
dans le menu principal, entre **Praticiens** et **Correspondants**. Le planning
utilise les mêmes rendez-vous SQLite et paramètres que l’entrée dédiée.

L’entrée dédiée reste disponible pour les essais isolés :

```sh
flutter run -d macos -t lib/main_planning.dart
```

L’entrée dédiée utilise maintenant la base SQLite Companion et sa migration v34.
Le menu principal propose aussi l’accès direct au planning. Une base planning vide affiche un calendrier
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
  Le pas est celui de la fiche praticien (15, 20 ou 30 minutes ; 15 par défaut).
  Le redimensionnement garde au moins un pas, dans la limite de 21:00.
  Les horaires restent entre 07:00 et 21:00.
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
nécessaires à cet écran. Le menu principal propose aussi l’accès direct au planning.

## Zoom vertical des vues Jour et Semaine

Le réglage **Zoom vertical** propose 100 %, 150 %, 200 %, 250 % et 300 %.
100 % correspond à la hauteur initiale (60 pixels par heure). Chaque vue garde
son propre réglage pendant la session, y compris après un passage dans une autre
vue. La vue Mois ne propose pas de zoom. Le zoom conserve autant que possible
l’heure au sommet de la zone visible, dans les limites du défilement.

Comparer un rendez-vous de 15 minutes à 100 %, 200 % puis 250 % ; utiliser 300 %
si les bordures de chevauchement réduisent la place disponible. En vue Jour,
l’horaire utilise une taille de 12 et apparaît lorsque deux lignes tiennent.
Déplacer et redimensionner à chaque échelle : le pas reste celui du praticien,
indépendamment du nombre de pixels parcourus. Le réglage ne modifie aucune
donnée et revient à 100 % après redémarrage.

En Semaine, vérifier le déplacement vers une autre colonne et le changement de
la durée avec un zoom de 250 %. Faire défiler la grille pour garder le point de
dépôt visible : relâcher hors de la grille annule toujours le geste. Le changement
d’échelle conserve l’heure au sommet de la grille autant que possible.

## Horaires d’ouverture hebdomadaires

Le bouton **Horaires d’ouverture**, dans la barre supérieure du planning avec
SQLite, ouvre les paramètres du lundi au dimanche. Aucune semaine type n’est
supposée au départ. Activer les jours travaillés, saisir une ou plusieurs plages
(par exemple 08:00–12:00 puis 14:00–18:00), puis Enregistrer. Un jour sans plage
est fermé. Une plage continue peut couvrir toute la journée si souhaité.

Les heures doivent être comprises entre 07:00 et 21:00, avec une fin après le
début ; deux plages du même jour ne peuvent pas se chevaucher. Annuler ne change
rien. Les erreurs de lecture bloquent l’enregistrement ; les erreurs d’écriture
conservent la saisie pour réessayer. Fermer et relancer, puis rouvrir ce formulaire
pour vérifier la persistance. Les rendez-vous restent autorisés hors ouverture
(et même un jour fermé), dans la plage de saisie 07:00–21:00.

Ces paramètres servent au calcul des disponibilités mensuelles. Ils ne créent
pas de pauses et ne modifient aucun rendez-vous existant.


## Vue mensuelle : charge et disponibilités

Chaque journée affiche deux lignes : **M** (07:00–12:00) et **A** (12:00–21:00).
Le nombre de RV compte les rendez-vous qui occupent une partie de la demi-journée,
y compris hors ouverture. Un RV traversant midi, ou sur toute la journée, est
compté dans les deux demi-journées ; ne pas additionner ces deux compteurs pour
obtenir le nombre de rendez-vous distincts de la journée.

La disponibilité indique ≥30 min, 20 min (20 à 29), ou <20 min. Il s’agit du plus
grand intervalle continu entièrement libre dans une plage d’ouverture du cabinet,
non du temps libre cumulé. Le survol donne sa durée exacte. Sans ouverture sur
la demi-journée : Fermé ; sans paramètres : À définir. Une erreur de chargement
est indiquée séparément et ne produit aucune disponibilité supposée.

Un clic sur M ou A ouvre la vue Jour sur la période correspondante. Aucun titre
ni action de modification n’apparaît en vue Mois.

Dans le formulaire, choisir **Pause ou indisponibilité** pour un déjeuner, une
réunion ou un congé. Ce type occupe du temps mais n’est pas compté comme RV et
n’est pas associé à un patient. Les événements existants restent des RV après
migration : reclasser explicitement les anciennes pauses. Les pauses sont
persistantes et bénéficient des mêmes gestes, de Supprimer et d’Annuler.

Pour vérifier : définir 09:00–12:00 un jour, créer un RV 09:00–10:00 et une pause
10:00–11:40. La case doit afficher 1 RV le matin et 20 min disponibles. Allonger
la pause jusqu’à midi doit supprimer ce créneau, sans modifier le nombre de RV.
Les disponibilités utilisent les horaires individuels du praticien sélectionné,
ou ceux du cabinet si sa fiche indique de les suivre. Une journée personnalisée
vide est non travaillée ; elle ne reprend pas les horaires du cabinet.

## Choix du praticien — première étape

Le sélecteur Praticien affiche les praticiens actifs et non archivés, avec leur
nom dans le titre du planning. Un seul praticien actif est sélectionné d’office ;
sinon le choix est explicite. La sélection reste pendant le passage entre les
vues ; le bouton de rechargement actualise la liste. Elle n’est pas enregistrée
entre deux ouvertures du planning.

Les nouveaux rendez-vous et pauses appartiennent au praticien sélectionné.
Les trois vues ne chargent que ses événements ; les compteurs et chevauchements
portent donc uniquement sur ce praticien. Sans sélection, la création est désactivée.
Changer de praticien efface les actions Annuler du planning précédent.
Les horaires individuels sont appliqués aux disponibilités mensuelles.
Aucune vue combinée n’est ajoutée.


## Périodes non travaillées

En Jour et Semaine, un fond gris bleuté indique les périodes en dehors des horaires
du praticien (ou du cabinet en mode par défaut), y compris les journées entières
non travaillées et les coupures entre plages. Une légende explique cette couleur.
Le fond suit le zoom et les dates affichées, sans créer d’événements ni modifier
les compteurs. Les rendez-vous restent au premier plan et les gestes de création,
déplacement et redimensionnement restent possibles, y compris hors horaires.
Sans horaires connus, aucune période n’est grisée.


## Pas des rendez-vous

La fiche praticien propose 15, 20 ou 30 minutes. Le réglage s’applique au clic
sur une zone vide, au déplacement et au redimensionnement en Jour et Semaine,
quel que soit le zoom. Le planning indique le pas actif dans son aide.
La saisie manuelle des horaires et de la durée reste libre ; la durée proposée
à la création est celle de la fiche praticien (45 minutes par défaut). Les événements existants ne sont pas arrondis
lors d’un changement de réglage et un déplacement conserve leur durée.


## Durée habituelle des rendez-vous

La fiche praticien permet de saisir une durée entière en minutes, indépendante du
pas de placement (par exemple 20 ou 30 minutes). Elle est sauvegardée avec la fiche.
À la création, la fin vaut le début plus cette durée. Un changement du début
recalcule la fin ; une fin modifiée manuellement redéfinit la durée conservée lors
des changements suivants du début. En modification, c’est la durée du rendez-vous
existant qui est conservée, sans remplacement par la durée habituelle.
Les événements sur toute la journée restent sans horaires. Une fin calculée après
21:00 doit être ajustée avant enregistrement ; aucune réduction silencieuse.
