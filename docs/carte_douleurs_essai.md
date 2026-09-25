# Carte des douleurs — Companion 1.1.0, build 7

## Accès et essai

1. Ouvrir un patient d’essai et son épisode de soins, puis **Bilans et rapports**.
2. Dans le bandeau de l’épisode, cliquer sur l’icône de silhouette, juste avant
   le trombone. L’infobulle indique **Carte des douleurs**.
3. Dans **Muscles**, sélectionner une région et saisir un commentaire et une
   intensité facultative. Les côtés indiqués sont ceux du patient.
4. Dans **Articulations / rachis**, sélectionner une autre zone. La liste des
   régions permet d’atteindre les petites cibles, notamment les doigts.
5. Cliquer sur **Enregistrer**, revenir aux bilans, puis rouvrir la carte : les
   deux vues retrouvent leurs annotations.
6. Ouvrir un autre épisode ou un autre patient : son relevé est indépendant.
7. **Exporter les deux cartes** produit une image PNG avec les deux vues, les
   annotations et le nom du patient. L’export ne remplace pas l’enregistrement.
8. Tester le retour avec des modifications non enregistrées : continuer la
   saisie, quitter sans enregistrer, ou enregistrer et fermer.

Enregistrer avant de fermer entièrement l’application. La première version
conserve un relevé courant par épisode ; elle ne constitue pas un historique de
séances. Les cartes ne sont pas encore insérées automatiquement dans les DOCX.
Aucune donnée du laboratoire autonome n’est importée.

## Stockage et maintenance

La table locale `care_episode_bodymaps` contient un relevé JSON versionné par
`care_episode_id`. Le patient est vérifié à travers l’épisode avant chaque
lecture ou écriture. La base passe de la version 28 à 29 par ajout d’une table,
sans modification des bilans existants. Les sauvegardes complètes de la base
incluent cette table. Il n’y a pas de synchronisation mobile des cartes.

L’éditeur, la persistance et les deux adaptateurs graphiques sont regroupés dans
`lib/features/bodymap`. Le format conserve les fournisseurs, versions et
identifiants des régions : une autre représentation pourra recevoir un nouvel
adaptateur et une migration explicite, sans interpréter les anciennes clés
comme des identifiants anatomiques universels.

Le composant musculaire est une copie locale MIT de bodyheatmap 1.0.0 avec la
correction de rattachement d’un tracé dorsal. Voir `vendor/bodyheatmap/ABAK_PATCH.md`.
Les libellés utilisent la latéralité du patient, validée dans le laboratoire sur
les 92 tracés à deux tailles (184 clics).

## Périmètre de diffusion

Cette intégration est destinée à l’évaluation. Les droits de redistribution de
l’illustration articulaire Rheumatoid Man restent à confirmer avant de diffuser
le binaire contenant cette image. Son attribution et la licence du module source
sont conservées dans `assets/bodymap` ; cette licence de module ne prouve pas à
elle seule la licence de l’illustration. Aucun envoi aux testeurs n’est effectué.

## Vérifications prévues

Tests sur bases temporaires : migration 28→29, persistance après réouverture,
séparation par épisode et patient, refus des régions et intensités invalides.
Tests d’interface : accès par silhouette, maintien des notes entre onglets,
échec de sauvegarde sans fermeture, réouverture et export PNG des deux vues.
