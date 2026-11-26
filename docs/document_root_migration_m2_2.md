# Service de migration documentaire — M2.2

Ce service est local et ne fournit ni interface de migration (M2.3), ni suppression des sources (M2.4). Il ne transmet rien au DMP.

## Contrat d’intégration

1. `DocumentRootMigration(database: ..., support: ...)` utilise le coordinateur partagé et les bookmarks macOS par défaut. Le dossier support est celui de l’application, jamais la racine patient.
2. `chooseDestination(titreTraduit)` sélectionne et autorise sans enregistrer la racine active. Libérer la lease retournée ; le service réacquiert les deux accès. `authorizeRoot(cheminExact, titreTraduit)` permet une réautorisation macOS sans substitution du chemin.
3. `plan(destination)` exige une destination existante et vide, inventorie les arbres associés et calcule un diagnostic DMP sans écritures SQLite. Le test d’écriture de destination utilise un répertoire temporaire unique immédiatement supprimé.
4. Présenter le plan, ses compteurs, `dmp.data` et les avertissements. Une `MigrationBlocked` peut porter le diagnostic DMP bloquant ; aucune confirmation ne lève ce blocage. Les codes sont techniques et devront être traduits dans M2.3.
5. `execute(plan, MigrationConsent(planHash: plan.hash, ...))` exige les consentements aux invalidations et à l’espace inconnu lorsque nécessaires. Il revalide le plan sous exclusivité. Tout changement impose un nouveau plan et une nouvelle confirmation. La progression donne une phase et des compteurs, jamais des données cliniques.
6. Après succès, rafraîchir les objets de chemins et les écrans. Les sources sont des copies conservées. `diagnostics` contient notamment les éventuels échecs de libération d’autorisations ; ceux-ci ne transforment pas un commit réussi en rollback.
7. Après interruption/erreur ayant commencé le journal, `recover()` est nécessaire avant de reprendre les activités. Il conserve les copies partielles. Un futur nettoyage ne pourra se fonder sur leur seule présence.

## Coordination et démarrage

Les producteurs documentaires, imports, exports, sauvegardes/restaurations, opérations médicales/techniques et entrées de chaîne DMP prennent une activité partagée. Les appels imbriqués sont réentrants uniquement pendant la durée de l’activité parente. La migration refuse une activité en cours ; elle ne l’annule pas. Les nouveaux travaux sont refusés. Le watcher diffère son prochain scan et le serveur retourne 503 pendant la barrière.

La récupération de démarrage intervient après le verrou d’instance et l’ouverture SQLite, avant serveur, watcher et purges. Un diagnostic non résolu empêche le démarrage métier, sans empêcher de quitter l’application. L’interface de résolution détaillée relève de M2.3.

## Persistance et autorité

Journal privé : `ApplicationSupport/document_root_migrations/<UUID>/<séquence>.json`. Chaque enregistrement complet porte une empreinte du payload et du plan. Les fichiers sont écrits et synchronisés avant installation exclusive. Les versions précédentes restent disponibles ; les fichiers temporaires ne sont jamais considérés comme un commit.

La transaction SQLite modifie exclusivement les associations, les chemins effectivement transférés, la racine et un reçu `document_root_migration_receipt_v1_<UUID>`. Les triggers existants participent à la même transaction. Le reçu SQLite tranche une interruption entre commit et finalisation du journal. Une contradiction ou un journal manquant bloque la récupération. Aucun nouveau schéma, aucune suppression automatique, aucune résurrection de validation.

Le journal contient les chemins, identifiants et empreintes nécessaires à la récupération ; il ne recopie pas les dossiers cliniques ni les snapshots DMP. Il est protégé par les permissions du dossier support (0700 appliqué aux dossiers du journal sous macOS). Ne pas le supprimer ni le détacher de sa base ; une restauration de base discordante demande un diagnostic.

## DMP

Les preuves sont vérifiées avec les contrôles d’archive existants, appliqués aux racines privées en place. Les compteurs d’invalidation portent sur les approbations et exécutions non encore invalidées. `acceptedDocuments` / `acceptedVersions` représentent des preuves DV1 acceptées ; les simulations restent dans `acceptedSimulationDocuments`. `remainingDocuments` / `remainingVersions` sont un inventaire d’impact, jamais une file d’envoi ni une autorisation de retransmettre. Un document peut avoir une ancienne version acceptée et une version plus récente non déposée.

Les réservations DV1 sont examinées dans l’ordre historique : un succès ultérieur vérifié ne doit pas être masqué par son ancien rejet ; un rejet d’une version de remplacement ne doit pas être masqué par l’acceptation de l’ancienne version. Une dernière réservation incertaine bloque. Une reprise encore nécessaire bloque dès qu’une modification de dépendance pourrait rompre sa continuité, y compris hors du document directement modifié. Aucune exception aux règles de reprise n’est ajoutée.

Le parcours médical normal peut revoir le même PDF après changement du seul chemin d’épisode. Une source clinique à réécrire, une preuve non vérifiable ou une référence opaque dans le périmètre source bloque la migration. Les racines PDF/contrôles privées ne sont pas déplacées. Le DMP désactivé n’exclut aucune vérification.

## Limites explicites

- Les racines historiques non vides ou inaccessibles ne sont pas consolidées. Les références externes dont la continuité est inconnue sont refusées.
- Une destination avec collisions de casse, noms non portables, liens ou aliases est refusée. Une collision apparue pendant la copie ne doit jamais écraser un fichier.
- L’inventaire/hash des fichiers est exécuté dans un isolate ; la copie est en flux. L’empreinte SQLite est volontairement large et peut invalider un plan après une modification sans rapport direct avec la migration.
- macOS : `statvfs`, `renamex_np(RENAME_EXCL)`, synchronisation des fichiers/répertoires, bookmarks conservés. Windows : Unicode, préfixes longs/UNC pour les appels Win32, `GetDiskFreeSpaceExW`, `MoveFileExW` sans remplacement avec WRITE_THROUGH. Aucun droit administrateur ni entitlement nouveau.
- Les garanties de synchronisation restent celles du système de fichiers et du matériel. Les tests d’arrêt de processus ne simulent pas une panne électrique du support.
- Une application externe comme Word peut encore écrire après le dernier contrôle. Les sources restent conservées ; M2.4 devra revérifier les deux côtés et toutes les dépendances avant le moindre nettoyage.
- La recette Windows et la recette macOS sandboxée/signée restent nécessaires. Les tests automatisés utilisent uniquement des données synthétiques.
