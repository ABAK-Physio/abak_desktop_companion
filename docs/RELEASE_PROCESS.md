#
# build_macos_notarized.sh
#
# Construit une version Release de ABAK Desktop Companion pour macOS.
#
# Le script réalise automatiquement :
#   - la compilation Flutter Release ;
#   - l'obfuscation du code Dart ;
#   - la signature avec le certificat Developer ID Application ;
#   - la notarisation auprès d'Apple ;
#   - l'intégration du ticket de notarisation (Stapling) ;
#   - la création du fichier ZIP destiné à la distribution.
#
# Ce script est lancé depuis la configuration
# "Build macOS Release Notarized" d'Android Studio.
#

# RELEASE_PROCESS.md

# Procédure officielle de publication d'ABAK Desktop Companion

## 1. Objet

Ce document décrit la procédure officielle de fabrication et de publication d'une nouvelle version d'ABAK Desktop Companion.

Il a pour objectif de garantir que chaque version est :

- construite à partir des sources validées ;
- signée numériquement ;
- vérifiée avant diffusion ;
- distribuée de manière identique sur toutes les plateformes.

Cette procédure est volontairement détaillée afin de garantir une fabrication reproductible des versions et de faciliter la continuité du projet, indépendamment des personnes qui en assurent le développement.

Les procédures décrites dans ce document concernent les versions distribuées publiquement. Elles ne s'appliquent pas aux versions de développement ou aux versions de test locales.

## 2. Prérequis

La fabrication d'une version officielle d'ABAK Desktop Companion nécessite un environnement de développement correctement configuré. Ces opérations sont réalisées une seule fois lors de la préparation du poste de développement.

### 2.1 Environnement de développement

Les éléments suivants doivent être installés et opérationnels :

- Flutter SDK
- Android Studio
- Git
- Xcode (pour la version macOS)

### 2.2 Compte Apple Developer

La publication de la version macOS nécessite un abonnement au programme Apple Developer.

Ce compte permet :

- de signer l'application avec un certificat **Developer ID Application** ;
- de soumettre l'application au service de notarisation d'Apple ;
- de distribuer l'application en dehors du Mac App Store.

### 2.3 Paramètres locaux

Les informations propres au poste de développement sont regroupées dans le fichier :

build_macos.env

situé à la racine du projet abak_desktop_companion

Ce fichier contient notamment :

- l'identifiant de l'équipe Apple Developer (`TEAM_ID`) ;
- l'identité de signature (`SIGN_IDENTITY`) ;
- le profil de notarisation (`KEYCHAIN_PROFILE`).

Ces informations sont spécifiques au développeur et ne doivent jamais être publiées dans le dépôt Git.

Le fichier `build_macos.env` est donc exclu du dépôt grâce au fichier `.gitignore`.

Ce fichier n'est nécessaire que pour les personnes chargées de fabriquer les versions officielles. Les autres contributeurs peuvent développer, compiler et tester ABAK Desktop Companion sans ce fichier.

## 3. Préparation d'une nouvelle release

À partir de cette étape, les sources destinées à la release sont considérées comme stabilisées. Aucune modification fonctionnelle ne doit être apportée avant la fin de la procédure de fabrication et de validation.

Avant de fabriquer une version officielle, effectuer les vérifications suivantes.

### 3.1 Vérifier l'état du dépôt Git

Depuis la racine du projet :

```bash
git status
```

Le dépôt doit être dans un état cohérent.

Les fichiers modifiés doivent être volontairement présents et identifiés. Les fichiers temporaires ou générés automatiquement ne doivent pas être intégrés à la release.

### 3.2 Vérifier la version de l'application

Déterminer le numéro de version (`build name`) et le numéro de build (`build number`) qui seront utilisés pour cette release.

Le numéro de version correspond à la version visible par l'utilisateur.

Le numéro de build permet de distinguer plusieurs compilations d'une même version.

### 3.3 Création du tag Git

Lorsque les sources sont stabilisées et prêtes à être publiées, créer un tag Git correspondant au numéro de version.

Le tag associe définitivement le numéro de version à l'état exact des sources ayant servi à fabriquer les exécutables distribués.

Ce tag sera ensuite utilisé lors de la création de la Release GitHub.

Exemple :


### 3.4 Vérifier les paramètres locaux

Le fichier suivant doit être présent à la racine du projet :

```text
build_macos.env
```

Ce fichier contient les informations nécessaires à la signature et à la notarisation de l'application.

### 3.5 Vérifier les certificats Apple

Avant de lancer une fabrication officielle, vérifier que le certificat **Developer ID Application** est toujours présent dans le Trousseau d'accès et que le profil de notarisation est toujours valide.

Cette vérification évite qu'une fabrication complète échoue uniquement à l'étape de signature ou de notarisation.

## 4. Fabrication de la version macOS

### 4.1 Principe

La fabrication d'une version macOS est entièrement automatisée par un script lancé depuis Android Studio. Ce script constitue la méthode officielle de fabrication des releases macOS du projet.

Ce script assure successivement :

- la compilation de l'application Flutter en mode Release ;
- l'obfuscation du code Dart ;
- la signature de l'application avec le certificat *Developer ID Application* ;
- la soumission de l'application au service de notarisation d'Apple ;
- l'intégration du ticket de notarisation (*stapling*) ;
- la création du fichier ZIP destiné à la distribution.

Aucune intervention manuelle n'est nécessaire pendant cette phase.

---

### 4.2 Lancement de la fabrication

Dans Android Studio, sélectionner la configuration :

```
Dans Android Studio, ouvrir Run/Debug Configurations puis sélectionner la configuration Compilation macOS + Notarization.
```

Puis lancer son exécution.

Le script affiche en temps réel les différentes étapes de la fabrication.

La durée de l'opération dépend principalement du temps de traitement de la notarisation par Apple.

---

### 4.3 Vérification de la fabrication

À la fin de l'exécution, le script doit se terminer sans erreur.

Le message final indique notamment :

- le chemin de l'application générée ;
- le chemin du fichier ZIP destiné à la distribution.

Toute erreur rencontrée pendant la compilation, la signature ou la notarisation doit être corrigée avant de poursuivre.

---

### 4.4 Résultat attendu

La fabrication produit un fichier ZIP contenant l'application notarizée.

Ce fichier constitue l'unique élément destiné à être diffusé aux utilisateurs macOS.

Les fichiers intermédiaires générés pendant la compilation ne doivent pas être publiés.


## 5. Validation de la release macOS

La fabrication d'une release constitue une étape technique. Avant toute publication, il est indispensable de vérifier que la version produite est effectivement distribuable et exploitable par les utilisateurs.

Avant toute publication, une validation minimale doit être réalisée afin de vérifier que l'archive produite est exploitable par les utilisateurs.

### 5.1 Vérification de l'archive

Contrôler que le fichier ZIP annoncé par le script est bien présent dans le dossier `build`.

Le nom du fichier doit correspondre à la version en cours de publication.
Il est possible d'utiliser les instructions proposées dans le fichier RELEASE_TOOLS.md

### 5.2 Vérification de l'installation

Décompresser le fichier ZIP dans un dossier de test.

L'application obtenue doit être identique à celle qui sera téléchargée par les utilisateurs.

### 5.3 Vérification du lancement

Lancer l'application obtenue après décompression.

Vérifier notamment que :

- l'application démarre correctement ;
- aucune erreur de signature ou de notarisation n'est signalée par macOS ;
- la fenêtre principale s'affiche normalement.

### 5.4 Contrôle fonctionnel

Effectuer un contrôle rapide des principales fonctionnalités.

Il ne s'agit pas d'une campagne complète de tests, mais d'une vérification destinée à s'assurer que la version publiée est exploitable.

Le contrôle fonctionnel doit porter au minimum sur les points suivants :

- ouverture de l'application ;
- accès aux principales fenêtres ;
- ouverture de la base de données locale ;
- import d'un fichier `.abak` si une sauvegarde de test est disponible.

### 5.5 Validation de la release

Une release ne peut être publiée qu'après validation complète des étapes précédentes.

## 6. Publication de la release

La publication d'une release consiste à associer une version identifiée par un Tag Git aux fichiers exécutables destinés aux utilisateurs. Cette opération est réalisée à partir de la page Releases du dépôt GitHub.

La publication consiste à mettre à disposition des utilisateurs les fichiers d'installation correspondant à chaque plateforme.

### 6.1 Création ou mise à jour de la release GitHub

La publication est réalisée à partir de la page **Releases** du dépôt GitHub.

Pour une nouvelle version :

- Chaque Release GitHub est associée à un Tag Git. Le Tag identifie l'état exact des sources. La Release ajoute à ce Tag les informations destinées aux utilisateurs : notes de version, exécutables et informations de téléchargement
- compléter le titre et les notes de version ;
- joindre les fichiers d'installation.

Pour une version déjà créée (par exemple lors de la préparation d'une version bêta), modifier la release existante et mettre à jour les fichiers distribués.

### 6.2 Fichiers publiés

Une même release GitHub regroupe l'ensemble des fichiers correspondant à une version donnée.
Une même Release regroupe l'ensemble des plateformes distribuées pour une version donnée.

À terme, une release officielle comportera notamment :

- l'installateur Windows ;
- l'application macOS notarizée.

Tous les fichiers publiés doivent provenir de la procédure officielle de fabrication décrite dans ce document.

### 6.3 Vérification de la publication

Après la mise à jour de la release GitHub, vérifier que :

- les fichiers sont présents dans la section **Assets** ;
- les noms des fichiers correspondent à la version publiée ;
- les téléchargements sont accessibles.

Cette vérification permet de détecter immédiatement une erreur de publication.

### 6.4 Notes de version

Chaque release doit être accompagnée de notes de version décrivant les principales évolutions.

Ces notes permettent aux utilisateurs d'identifier rapidement les nouveautés et les éventuelles corrections apportées.

GitHub génère automatiquement les archives "Source code (zip)" et "Source code (tar.gz)" à partir du Tag Git. Ces archives contiennent uniquement les sources du projet et ne remplacent pas les exécutables distribués dans la section Assets.

## 7. Clôture de la release

La publication d'une release ne s'achève pas avec la mise à jour du dépôt GitHub.

Une fois les fichiers publiés, il convient de vérifier que les utilisateurs disposent bien de toutes les informations nécessaires pour accéder à la nouvelle version.

### 7.1 Mise à jour du site Internet

Mettre à jour la page de téléchargement du site ABAK.

Vérifier notamment :

- la présence des liens de téléchargement ;
- la cohérence des numéros de version affichés ;
- la disponibilité des versions Windows et macOS.

### 7.2 Vérification des téléchargements

Depuis le site Internet, télécharger les fichiers proposés afin de vérifier que les liens sont opérationnels.

Cette vérification permet de détecter immédiatement une erreur de publication ou un lien devenu invalide.

### 7.3 Archivage

Conserver les informations relatives à la release :

- numéro de version ;
- numéro de build ;
- tag Git associé ;
- date de publication.

Ces informations permettent de retrouver rapidement l'origine d'une version distribuée.

### 7.4 Fin de la procédure

La publication d'une release est considérée comme terminée lorsque :

- la version a été validée ;
- les fichiers sont disponibles sur GitHub ;
- le site Internet est à jour ;
- les téléchargements ont été vérifiés.

---

## Conclusion

Cette procédure constitue la méthode officielle de fabrication et de publication des versions d'ABAK Desktop Companion.

Toute évolution de cette procédure devra être documentée dans ce fichier afin de préserver la reproductibilité des publications, la traçabilité des versions et la continuité du projetité du projet.

À ce jour, les versions Windows sont distribuées sans signature numérique. Cette décision est volontaire et tient au fait qu'ABAK Desktop Companion est un logiciel gratuit dont la diffusion reste limitée. La mise en place d'une signature de code sera réévaluée lorsque le contexte de diffusion le justifiera.
