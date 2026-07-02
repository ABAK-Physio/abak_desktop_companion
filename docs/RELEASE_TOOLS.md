# RELEASE_TOOLS.md

# Outils de publication d'ABAK Desktop Companion

## Objet

Ce document regroupe les commandes utiles à la préparation, à la fabrication, à la validation et à la publication des releases d'ABAK Desktop Companion.

Il complète le document **RELEASE_PROCESS.md**, qui décrit la procédure officielle de publication.

Les commandes présentées dans ce document constituent une aide opérationnelle. Elles ne remplacent pas la procédure décrite dans **RELEASE_PROCESS.md**.

Chaque commande est présentée selon la structure suivante :

- **Objectif** : pourquoi utiliser cette commande.
- **Commande** : la commande à exécuter.
- **Résultat attendu** : ce que l'on doit obtenir.
- **Points d'attention** : erreurs fréquentes ou situations particulières.
- **Références** : renvoi éventuel vers la procédure officielle.

# 1. Préparation de la release

Cette section regroupe les commandes utilisées avant le lancement de la fabrication d'une nouvelle version.

Elles permettent de vérifier que le dépôt Git est dans un état cohérent et de préparer la publication de la nouvelle version.

## Vérifier l'état du dépôt Git

### Objectif

Vérifier que le dépôt est dans un état cohérent avant de commencer la fabrication d'une release.

### Commande

```bash
git status
```

### Résultat attendu

Le dépôt ne contient aucune modification non validée.

Exemple :

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Le dépôt est prêt pour la fabrication d'une release.

### Points d'attention

Si Git affiche :

```text
Changes not staged for commit
```

ou

```text
Untracked files
```

des modifications locales sont encore présentes.

Vérifier qu'elles sont volontaires avant de poursuivre.

Si nécessaire :

- terminer le développement ;
- effectuer les derniers commits ;
- supprimer les fichiers temporaires qui ne doivent pas être intégrés au dépôt.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **3 – Préparation d'une nouvelle release**.

## Publier les derniers commits

### Objectif

Synchroniser le dépôt GitHub avec le dépôt local avant la création de la release.

Cette commande garantit que les sources utilisées pour fabriquer les exécutables correspondent bien à celles présentes sur le dépôt GitHub.

### Commande

```bash
git push
```

### Résultat attendu

Git indique que tous les commits locaux ont été transférés vers le dépôt distant.

Exemple :

```text
Enumerating objects: ...
Counting objects: ...
Compressing objects: ...
Writing objects: ...
To github.com:ABAK-Physio/abak_desktop_companion.git
```

Le dépôt GitHub est maintenant synchronisé avec le dépôt local.

### Points d'attention

Si Git indique :

```text
Everything up-to-date
```

cela signifie simplement qu'aucun nouveau commit n'était à publier.

C'est un résultat normal si tous les développements ont déjà été synchronisés.

En revanche, si Git signale un refus de publication (`rejected`), il est nécessaire d'identifier la cause avant de poursuivre la procédure de release.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **3 – Préparation d'une nouvelle release**.

## Créer le tag de la release

### Objectif

Créer un identifiant permanent associé à l'état exact des sources qui serviront à fabriquer la nouvelle release.

Le tag permet de retrouver ultérieurement les sources correspondant à une version publiée.

Il constitue le lien entre :

- les sources du projet ;
- les exécutables distribués ;
- la Release GitHub.

### Commande

Exemple pour la version 1.0.0 :

```bash
git tag v1.0.0
```

### Résultat attendu

La commande ne produit généralement aucun message.

Le tag est créé localement et pointe vers le dernier commit du dépôt.

À ce stade, il n'est pas encore présent sur GitHub.

### Points d'attention

Le numéro du tag doit être identique au numéro de version de la release.

Exemple :

```text
Version : 1.0.0

Tag : v1.0.0
```

Le tag doit être créé uniquement lorsque les sources sont stabilisées.

Une fois la release publiée, le tag ne doit plus être déplacé vers un autre commit.

Il constitue une référence permanente permettant de retrouver exactement les sources ayant servi à fabriquer cette version.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **3 – Préparation d'une nouvelle release**.

## Créer le tag de la release

### Objectif

Créer un identifiant permanent associé à l'état exact des sources qui serviront à fabriquer la nouvelle release.

Le tag permet de retrouver ultérieurement les sources correspondant à une version publiée.

Il constitue le lien entre :

- les sources du projet ;
- les exécutables distribués ;
- la Release GitHub.

### Commande

Exemple pour la version 1.0.0 :

```bash
git tag v1.0.0
```

### Résultat attendu

La commande ne produit généralement aucun message.

Le tag est créé localement et pointe vers le dernier commit du dépôt.

À ce stade, il n'est pas encore présent sur GitHub.

### Points d'attention

Le numéro du tag doit être identique au numéro de version de la release.

Exemple :

```text
Version : 1.0.0

Tag : v1.0.0
```

Le tag doit être créé uniquement lorsque les sources sont stabilisées.

Une fois la release publiée, le tag ne doit plus être déplacé vers un autre commit.

Il constitue une référence permanente permettant de retrouver exactement les sources ayant servi à fabriquer cette version.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **3 – Préparation d'une nouvelle release**.

## Vérifier les tags disponibles

### Objectif

Afficher la liste des tags présents dans le dépôt local.

Cette vérification permet de confirmer que le tag de la release a bien été créé.

### Commande

```bash
git tag
```

### Résultat attendu

Git affiche la liste des tags existants.

Exemple :

```text
v0.1.0-beta
v0.1.1-beta
v1.0.0
```

Le tag correspondant à la release en cours doit apparaître dans la liste.

### Points d'attention

Si le tag attendu n'apparaît pas, cela signifie qu'il n'a pas été créé localement.

Dans ce cas, revenir à l'étape **Créer le tag de la release**.

Cette commande vérifie uniquement les tags locaux.  
Pour vérifier la présence du tag sur GitHub, consulter l'onglet **Tags** du dépôt ou la page **Releases**.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **3 – Préparation d'une nouvelle release**.

# 2. Fabrication de la version macOS

Cette section regroupe les outils permettant de fabriquer une version officielle d'ABAK Desktop Companion pour macOS.

La fabrication est entièrement automatisée par le script `build_macos_notarized.sh`, lancé depuis Android Studio.

## Lancer la fabrication d'une release macOS

### Objectif

Construire une version officielle d'ABAK Desktop Companion prête à être distribuée aux utilisateurs macOS.

Le script réalise automatiquement :

- la compilation Flutter en mode Release ;
- l'obfuscation du code Dart ;
- la signature avec le certificat **Developer ID Application** ;
- la notarisation auprès d'Apple ;
- le *Stapling* du ticket de notarisation ;
- la création du fichier ZIP destiné à la distribution.

### Commande

Dans Android Studio :

```
Run
    ↓
Run...
    ↓
Compilation macOS + Notarization
```

ou sélectionner directement la configuration **Compilation macOS + Notarization** dans la liste **Run/Debug Configurations**, puis lancer son exécution.

### Résultat attendu

Le script exécute automatiquement toutes les étapes de fabrication.

La dernière partie de la sortie doit indiquer notamment :

```text
BUILD TERMINÉ

Application :
build/macos/Build/Products/Release/abak_desktop_companion.app

ZIP à distribuer :
build/abak_desktop_companion_1.0.0_macOS.zip
```

Le fichier ZIP distribué est prêt pour les opérations de validation.

### Points d'attention

La durée d'exécution dépend principalement du temps de traitement de la notarisation par Apple.

Si le script s'interrompt avant la fin, consulter le premier message d'erreur affiché.

Les causes les plus fréquentes sont :

- certificat Apple absent ou expiré ;
- profil de notarisation invalide ;
- fichier `build_macos.env` absent ou incomplet ;
- erreur de compilation Flutter.

Ne jamais poursuivre la procédure si le script ne s'est pas terminé normalement.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **4 – Fabrication de la version macOS**.

# 3. Validation de la version macOS

Cette section regroupe les commandes permettant de vérifier que la version produite est prête à être distribuée.

Les contrôles réalisés ici sont effectués sur le fichier ZIP généré par le script de fabrication.

---

## Vérifier la présence du fichier ZIP

### Objectif

S'assurer que le script a correctement généré le fichier ZIP destiné à la distribution.

### Commande

Exemple pour la version 1.0.0 :

```bash
ls -lh build/abak_desktop_companion_1.0.0_macOS.zip
```

### Résultat attendu

Git affiche les informations du fichier.

Exemple :

```text
-rw-r--r--  1 jeanclaudebrucher  staff   21M ... build/abak_desktop_companion_1.0.0_macOS.zip
```

Le fichier existe et sa taille est cohérente avec une version Release.

### Points d'attention

Si le message suivant apparaît :

```text
No such file or directory
```

le fichier ZIP n'a pas été créé ou le nom utilisé est incorrect.

Dans ce cas :

- vérifier le message final du script de fabrication ;
- vérifier le numéro de version utilisé dans le nom du fichier.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **5 – Validation de la release macOS**.

## Décompresser le fichier ZIP

### Objectif

Vérifier que le fichier distribué peut être décompressé normalement et contient bien l'application notarizée.

### Commande

Exemple :

```bash
rm -rf ~/Documents/Test_ABAK

mkdir -p ~/Documents/Test_ABAK

ditto -x -k \
build/abak_desktop_companion_1.0.0_macOS.zip \
~/Documents/Test_ABAK
```

### Résultat attendu

La commande se termine sans afficher de message d'erreur.

Le dossier `Test_ABAK` contient notamment :

```text
abak_desktop_companion.app
```

### Points d'attention

Si `ditto` indique :

```text
No such file or directory
```

vérifier :

- le chemin du fichier ZIP ;
- le numéro de version présent dans le nom du fichier.

Si le dossier de destination existe déjà, il est recommandé de le supprimer avant le test afin d'éviter toute confusion avec une version précédente.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **5 – Validation de la release macOS**.

## Lancer l'application de test

### Objectif

Vérifier que l'application distribuée peut être ouverte normalement par macOS.

Cette commande reproduit le comportement d'un utilisateur qui double-clique sur l'application dans le Finder.

Elle permet notamment de vérifier :

- le package de l'application ;
- la signature numérique ;
- la notarisation ;
- le fonctionnement de Gatekeeper.

### Commande

```bash
open ~/Documents/Test_ABAK/abak_desktop_companion.app
```

### Résultat attendu

L'application démarre normalement.

La fenêtre principale d'ABAK Desktop Companion s'affiche sans message d'erreur.

Si l'application est lancée pour la première fois, macOS peut demander une confirmation d'ouverture.

### Points d'attention

Si macOS refuse d'ouvrir l'application, vérifier notamment :

- que la signature est valide ;
- que la notarisation a bien été réalisée ;
- que le ticket de notarisation a été correctement intégré (*Stapling*) ;
- que l'application n'a pas été modifiée après sa signature.

La commande `open` utilise le mécanisme normal de lancement des applications macOS. Elle constitue donc le meilleur moyen de reproduire les conditions réelles d'utilisation.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **5 – Validation de la release**.

## Vérifier la signature numérique

Cette vérification est normalement réalisée automatiquement par le script de fabrication. La commande ci-dessous peut être utilisée pour effectuer un contrôle manuel ou un diagnostic.


### Objectif

Vérifier que l'application est correctement signée et que la signature est toujours valide.

Cette vérification permet de détecter une altération éventuelle du package de l'application avant sa distribution.

### Commande

```bash
codesign \
  --verify \
  --deep \
  --strict \
  --verbose=2 \
  build/macos/Build/Products/Release/abak_desktop_companion.app
```

### Résultat attendu

La commande se termine sans message d'erreur.

La sortie se termine généralement par un message du type :

```text
build/macos/Build/Products/Release/abak_desktop_companion.app: valid on disk
build/macos/Build/Products/Release/abak_desktop_companion.app: satisfies its Designated Requirement
```

La signature est valide et l'application n'a pas été modifiée depuis sa signature.

### Points d'attention

Si la commande affiche un message d'erreur, la signature n'est plus valide.

Les causes les plus fréquentes sont :

- un fichier du package a été modifié après la signature ;
- une bibliothèque ou une ressource est manquante ;
- la signature n'a pas été réalisée correctement.

Dans ce cas, il est inutile de poursuivre la procédure de publication.

Il convient d'identifier la cause, puis de reconstruire et signer à nouveau l'application.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **5 – Validation de la release**.

## Vérifier l'évaluation par Gatekeeper

### Objectif

Vérifier que macOS considère l'application comme autorisée à être exécutée.

Cette commande permet d'obtenir le diagnostic de Gatekeeper avant la diffusion d'une application ou lors d'une recherche de panne.

### Commande

```bash
spctl --assess --type execute --verbose=4 \
build/macos/Build/Products/Release/abak_desktop_companion.app
```

### Résultat attendu

Si l'application est correctement signée et notarizée, Gatekeeper indique notamment :

```text
accepted
source=Notarized Developer ID
```

L'application est reconnue comme provenant d'un développeur identifié et sa notarisation est valide.

### Points d'attention

Si Gatekeeper refuse l'application (`rejected`), les causes les plus fréquentes sont :

- signature invalide ;
- application non notarizée ;
- ticket de notarisation absent ;
- application modifiée après la signature.

Cette commande constitue un excellent outil de diagnostic lorsque l'application ne peut pas être ouverte normalement.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **5 – Validation de la release**.

# 4. Publication de la Release GitHub

Cette section regroupe les manipulations permettant de publier officiellement une nouvelle version d'ABAK Desktop Companion sur GitHub.

---

## Créer une nouvelle Release

### Objectif

Créer la page officielle correspondant à une nouvelle version d'ABAK Desktop Companion.

### Manipulation

Depuis le dépôt GitHub :

```
Releases
    ↓
Draft a new release
```

Sélectionner le **Tag Git** correspondant à la version publiée.

Compléter ensuite :

- le titre de la Release ;
- les notes de version.

### Résultat attendu

La nouvelle Release est créée et associée au Tag Git correspondant.

### Points d'attention

Vérifier que le Tag sélectionné correspond exactement au numéro de version publié.

Une Release doit toujours être associée au Tag ayant servi à fabriquer les exécutables.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **6 – Publication de la release**.

## Ajouter les fichiers distribués

### Objectif

Mettre à disposition des utilisateurs les exécutables officiels.

### Manipulation

Dans la section **Assets** de la Release :

Ajouter :

- l'application macOS notarizée (.zip) ;
- l'installateur Windows (.exe) lorsqu'il est disponible.

### Résultat attendu

Les fichiers apparaissent dans la liste des **Assets**.

Ils sont immédiatement téléchargeables.

### Points d'attention

Vérifier que les fichiers correspondent bien à la version publiée.

Ne jamais remplacer un fichier par un exécutable construit à partir d'un autre Tag Git.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **6 – Publication de la release**.

## Publier la Release

### Objectif

Rendre la nouvelle version accessible aux utilisateurs.

### Manipulation

Après vérification de la Release :

```
Publish release
```

### Résultat attendu

La Release apparaît dans la liste des Releases publiques du dépôt GitHub.

Les utilisateurs peuvent télécharger les exécutables.

### Points d'attention

Vérifier une dernière fois :

- le Tag Git ;
- le titre de la Release ;
- les notes de version ;
- les fichiers présents dans les Assets.

Une Release publiée constitue la version officielle distribuée aux utilisateurs.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **7 – Clôture de la release**.

## Vérifier les téléchargements

### Objectif

Contrôler que les utilisateurs peuvent effectivement télécharger les fichiers publiés.

### Manipulation

Depuis la page publique de la Release :

Télécharger successivement :

- l'application macOS ;
- l'installateur Windows.

Vérifier que les téléchargements se terminent correctement.

### Résultat attendu

Les fichiers téléchargés correspondent aux exécutables publiés.

### Points d'attention

Cette vérification permet de détecter immédiatement :

- un Asset manquant ;
- un mauvais fichier ;
- un problème de publication.

### Références

Voir **RELEASE_PROCESS.md**, chapitre **7 – Clôture de la release**.

## Signature numérique (évolution future)

WIndows

La chaîne de fabrication Windows est actuellement limitée à :

- compilation Flutter ;
- création de l'installateur Inno Setup.

La signature numérique de l'installateur n'est volontairement pas mise en œuvre à ce stade du projet.

Lorsque le contexte de diffusion le justifiera, cette étape pourra être ajoutée sans remettre en cause l'architecture générale de la chaîne de fabrication.