J4 — JOURNAL, RETENUE ET SAUVEGARDE PRODUIT

Ce composant appartient au parcours Documents existant. Il ne crée pas une nouvelle
collection de données de démonstration. La base produit est migrée au schéma 35 lors
d’une ouverture future ; les vérifications de ce jalon n'ouvrent que des bases synthétiques.

Journal SQLite commun
- Reçus médicaux, invalidations, contrôles, retenues, tentatives et résultats sont reliés
  par identifiants de version, d'approbation et de contrôle. Les événements sont ajoutés
  par déclencheurs dans la même transaction que le fait enregistré.
- Les anciennes approbations/contrôles sont indexés dans le journal sans nouvelle
  validation. La migration est réentrante et testée avec interruption.
- Retenue par défaut pour chaque nouvelle version ; modification avec révision attendue.
  Lever la retenue ne lance rien. La levée ne réarme ni résultat terminal ni restauration.
- Réservation unique avant appel : une tentative par pièce, et par empreinte PDF/patient.
  Le changement de version ou la réimportation identique ne contourne pas le blocage.
- Réservation sans résultat après arrêt : indéterminé. Aucun réessai automatique. Le
  journal, les résultats et les barrières ne sont ni modifiables ni supprimables via les
  écritures applicatives, y compris INSERT OR REPLACE.

Services locaux
DocumentJournalService.simulate exige un DocumentLocalSimulation et un répertoire
portant J4-SYNTHETIC-ONLY = ABAK-J4-SYNTHETIC contenant base et copies PDF. Aucun
transport réseau/CPS n'existe dans ce composant. Aucun appel de simulation n'est raccordé
aux boutons métier. Les points d'injection servent seulement aux incidents/concurrences.
Les archives passent par ArchiveDepositReader existant ; requête, en-têtes, réponse brute,
interprétation et empreinte sont gardés dans SQLite. Les résultats restent explicitement
fictifs et ne constituent jamais un dépôt de ce PDF sur le DMP.
Avant réservation : retenue, restauration, absence de tentative, reçu médical courant,
contrôles conformes, configuration courante et intégrité des fichiers sont vérifiés.

Sauvegarde existante étendue
- ZIP version 2 : snapshot SQLite cohérent, dossiers patients externes inchangés,
  managed/episode_documents et managed/episode_document_versions (copies, CDA et rapports).
- Vérification tailles/empreintes, correspondance aux versions et reçus, associations de
  tentative. Liens symboliques refusés. Archives partielles/altérées rejetées ; aucun succès
  dans l'historique lorsqu'une copie ou une preuve manque.
- Répertoires temporaires créés par le programme résolus vers leur chemin canonique sur
  macOS (/var est un alias système) ; les chemins de pièces restent contrôlés contre les liens.
- Restauration préparée avant remplacement, avec copies de sécurité et retour arrière en
  cas d'échec. Aucun fichier figé divergent n'est écrasé. Les fichiers plus récents restent
  conservés ; la base antérieure complète et ses racines sont dans les copies de sécurité.
- Toute restauration (v2, v1 ou .db) pose une barrière durable sur les préparations. Une
  ancienne sauvegarde ne peut attester l'absence de tentative depuis sa création. Une
  réconciliation ultérieure explicite est nécessaire ; J4 ne fournit aucune action de levée.
- Déplacement sur une autre machine : chemins des pièces réassociés, preuves historiques
  préservées, approbations courantes invalidées si le rattachement change. Les exécutables
  Java/veraPDF/références ne sont pas empaquetés ; une configuration valide reste nécessaire.
- Les anciens ZIP/.db restent lisibles mais n'inventent pas leurs pièces absentes. Ils ne
  deviennent pas des sauvegardes complètes des fichiers J1–J3.
- En cas d'arrêt brutal pendant le remplacement des fichiers, les copies de sécurité sont
  conservées pour récupération ; la reprise automatique de cette récupération n'est pas
  revendiquée. Fichiers manquants/altérés et barrière empêchent le traitement.

Vérification reproductible, sans VM service ni réseau
bash tool/document_journal_product/verify_offline.sh /chemin/absolu/vers/preuves-neuves
bash tool/document_journal_product/verify_backup_offline.sh /chemin/absolu/vers/regression-neuve

Les lanceurs compilent puis exécutent flutter_tester sous sandbox-exec deny network*,
avec --disable-vm-service. Le premier lance ensuite un second processus de réouverture.
Le second exécute directement les 18 tests existants de sauvegarde/restauration, avec
leurs mises en place/nettoyages, sans serveur du lanceur flutter test. TMPDIR est isolé.
Les bibliothèques installées sont seulement chargées pour SQLite ; l'application installée
n'est jamais lancée. Variables FLUTTER_ROOT / ABAK_TEST_FRAMEWORKS permettent de préciser
les outils locaux. Aucun téléchargement. Fixtures exclusivement synthétiques/archives locales.

Contrôles observés : 88 + 13 nouveau processus ; 18 régressions sauvegarde ; J1 67,
J2 79 + 3 nouveau processus ; J3 52 + 5 nouveau processus. Voir le bilan du projet pour
les rapports et empreintes des fichiers sources. L'envoi réel reste désactivé (J5/J6 à suivre).
