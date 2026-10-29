J3 — Contrôles techniques du parcours métier

Entrée : Documents de l'épisode > PDF final > Contexte et validation médicale.
Après la revue et la validation J2, la carte « Contrôles techniques locaux » permet
la configuration et le lancement. Aucun serveur local, Terminal, réseau, CPS ou
transport DMP n'est utilisé par ce composant.

Configuration explicite (aucune valeur de développement dans le code produit) :
- exécutable Java 17+ d'un JDK local (le lecteur CDA empaqueté est du Java source) ;
- fichier CLI .jar de l'installation officielle de veraPDF ;
- dossier de références CDA contenant infrastructure/, schematrons/ et jeuxDeValeurs/ ;
- nom/version du paquet, déclaré par l'utilisateur. Les fichiers, le runtime Java,
  les bibliothèques et le lecteur embarqué sont identifiés par SHA-256. Le rapport
  de version veraPDF est conservé. Aucun téléchargement ni remplacement d'outil.

Contrats :
- approvedCapture relit dans la transaction le PDF courant et le contexte J2.
- Le CDA est construit sans modèle patient ni données de fixture. Son PDF B64 est
  la copie exacte validée ; il est comparé octet par octet au résultat attendu.
- Le profil préparatoire actuel est adulte, ambulatoire, visibilité normale,
  auteur également validateur, sans remplacement. Autorités OID explicites,
  profession codée et lieu de soins codé sont requis. Nom et prénoms professionnels
  sont déclarés séparément ; aucune interprétation du nom affiché dans l’annuaire. L'identité existante doit
  être qualifiée et représenter un NIR. Aucune qualification ni interrogation INSi.
- La source d'identité actuelle ne sépare pas le premier prénom des autres prénoms.
  Avec plusieurs prénoms, le CDA reste non vérifié ; aucune découpe arbitraire.
- Type, titre, dates, langue, traits INS, auteur, structure, profession et lieu de
  soins proviennent de la capture. Le classement XDS, la correspondance type/classe,
  les droits et l'authentification professionnelle ne sont pas certifiés ici.
- PDF/A-1b est le profil explicite. Un rapport complet avec sortie 1 et défauts est
  refusé ; erreur d'exécution, rapport ambigu/non corrélé ou autre profil = non vérifié.
- CDA : XSD CDA_extended, Structuration minimale, IHE, modèles de contenus CDA,
  modèles ANS et terminologies. Assertions en échec, y compris warnings, refusées.
  Rapport partiel ou erreur moteur : non vérifié. Cela ne prouve pas à soi seul
  la conformité DMP de la chaîne d'alimentation.

Exécution :
- Le produit lance directement Java via sandbox-exec : réseau interdit, écritures
  limitées au répertoire de travail unique. Environnement Java hérité désactivé,
  sorties limitées à 12 Mio, délai de quatre minutes et arrêt du processus.
- Lecteur CDA empaqueté dans assets/document_controls/CdaCheck.java. Résolution des
  schémas et XSLT limitée aux fichiers du paquet local. DTD rejetée dans tout CDA.
  Les DTD externes des schémas ne sont pas chargées, comme dans l'ancien lecteur.
- Sources de références jamais modifiées : compilation sur des copies privées.
  Ces copies volumineuses sont retirées à la fin. PDF, CDA, rapports, contexte et
  manifeste intégral des empreintes restent conservés sous pdfRoot/controls/<UUID>.
- Un arrêt brutal peut laisser les copies temporaires ; aucun effacement automatique
  de preuve ni reprise silencieuse. L'état sans résultat complet est non vérifié.

Stockage : schéma 34 additif. Configuration révisée ; demandes, résultats et
invalidations immuables. Un changement de configuration ou de validation médicale
invalide durablement les preuves. Les fichiers et outils sont revérifiés à la
lecture et avant/après les contrôles. Changement puis retour à l'ancienne valeur
ne réactive pas un résultat invalidé. L'envoi demeure indisponible.
Toute évolution du protocole de contrôle doit incrémenter sa version de liaison.
La sauvegarde/restauration complète des nouvelles pièces et preuves relève de J4.

Tests : verify_offline.sh SORTIE_ABSOLUE, avec CONTROLS_TEST_REFS pointant vers un
paquet local archivé. Compile sans téléchargement, lance flutter_tester sans service
VM dans un sandbox réseau interdit et n'ouvre qu'une nouvelle base synthétique.
Les moteurs natifs y sont réels. macOS interdisant l'empilement des sandboxes,
le sous-type de test AlreadySandboxedNative omet uniquement le second emballage
sandbox-exec ; le processus parent interdit déjà tout réseau. Le lancement Java
avec le profil produit est aussi contrôlé séparément, dans le même stockage isolé.
Les services simulés testent les erreurs, courses et mutations. Une seconde exécution
du processus vérifie les résultats persistés, sans relancer de validateur.
L'application installée et sa base utilisateur ne sont jamais lancées ou migrées.
