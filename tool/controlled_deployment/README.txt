MISE À JOUR DU 18/10/2026 — PRÉFÉRENCES / SIGNETS NATIFS
Recette native réussie : 69 contrôles dans sept processus, via SharedPreferences,
UserDefaults et le vrai pont AbakDirectoryAccessBridge. Restauration persistante,
accès externe refusé avant réactivation du signet, puis autorisé sans nouvelle
sélection. Archives invalides et autre identité refusées sans mutation ; dossier
déplacé, supprimé, annulation et réautorisation explicite vérifiés.
Les paragraphes historiques ci-dessous gardent les limites de leurs dates ; le
contrôle préférences/signets est désormais acquis uniquement pour la recette.
Le retour d’un bundle complet et les ressources durables restent distincts.

Reproduction sur UNE NOUVELLE identité et des dossiers synthétiques neufs :
1. Compiler avec le lanceur hors réseau, --preferences-recipe, version/build
   explicites et dossier de sortie neuf. Le manifeste marque cette compilation
   comme recette seule : ce n’est PAS une candidate métier à distribuer.
2. Préparer la copie native avec native_recipe.py create, --candidate, --output
   et --preferences-folder. Ce dernier doit être un dossier abak-bookmarks-*,
   hors conteneurs/Applications, marqué SYNTHETIC-ONLY avec exactement
   ABAK-BOOKMARKS-SYNTHETIC-V1 suivi d’un saut de ligne.
3. Utiliser native_recipe.py launch avec --app, --root (racine de maintenance
   synthétique validée par l’outillage) et --preferences-phase. Aucune sélection
   de la racine parente n’est effectuée par cette entrée ; seul le dossier cible
   doit être autorisé par le sélecteur natif. Cela évite de masquer une défaillance
   du signet par une autorisation plus large.
4. Phases successives avec fermeture COMPLÈTE entre elles : seed, mutated,
   restored. seed sauvegarde puis modifie les préférences ; mutated restaure ;
   restored contrôle réellement le nouvel accès et la persistance au redémarrage.
   Puis déplacer le seul dossier cible vers <chemin>-moved et lancer moved.
   Copier/vérifier ses fichiers avant de retirer ce seul dossier synthétique ;
   lancer missing puis cancel (annuler la sélection). Recréer une copie au chemin
   initial et lancer reauthorized, en sélectionnant explicitement ce dossier.
5. Fermer chaque fenêtre par Fermer la recette. Le rapport est écrit dans le
   conteneur propre, sous Application Support/<identité>/native-preferences-recipe.
   Le lire dans l’interface ou l’exporter avec une autorisation dédiée ; ne pas
   contourner les protections macOS pour traverser les conteneurs depuis un outil.
   Les rapports contiennent des signets de recette et ne sont pas destinés à un
   partage public. Les résultats de cette session sont transcrits dans le dossier
   projet output/recette-native-preferences/Observations_interface.json.

run_preferences_phase.py encapsule les phases et archive PID/sortie/journal pour
la disposition candidate-recipe-12/native-1 de cette recette. Il refuse d’écraser
un journal existant. verify_preferences_guards.py vérifie les gardes sans données
utilisateur. La restauration native ne peut cibler un domaine arbitraire : elle
n’est enregistrée qu’avec les marqueurs signés et l’identité de recette.
Aucune copie brute du plist, aucun arrêt de cfprefsd, aucun démarrage métier.
Le contrôle du renvoi DMP reste celui du journal/base cohérents déjà éprouvés ;
les préférences seules ne constituent jamais une restauration métier complète.

OUTILLAGE DE COMPILATION ET RÉPÉTITION SYNTHÉTIQUE

MISE À JOUR DU 18/10/2026 — RECETTE NATIVE
La vraie fenêtre a été vérifiée, avec fermeture/réouverture, refus concurrent et
annulation du sélecteur, dans une copie signée d’identité distincte. App Sandbox
reste actif ; cette copie n’a aucune permission réseau, carte ou microphone.
La sélection du dossier synthétique exact donne accès uniquement à cette recette.
Les fichiers restent identiques, aucun accès au conteneur installé observé.
Les paragraphes initiaux ci-dessous décrivent la recette de la veille.

Le lancement historique sous sandbox-exec est maintenant désactivé (hors --describe).
L’essai natif a établi qu’il échoue dans libsecinit/AppSandbox avant le main.
Ne pas retirer la protection App Sandbox ni lancer l’identité .local avec ses droits
habituels pour contourner cet échec. Préparer la copie restreinte :
  /usr/bin/python3 tool/controlled_deployment/native_recipe.py create \
    --candidate "/chemin/candidate/Companion-candidate.app" \
    --output "/chemin/recette-neuve"
La création/codesign doit s’exécuter sous la sandbox hors réseau de compilation.
Elle exige une candidate récente contenant la garde native de recette, vérifie les
empreintes, conserve le code compilé et change seulement identité/signature/droits.
  /usr/bin/python3 tool/controlled_deployment/native_recipe.py launch \
    --app "/chemin/recette-neuve/ABAK Maintenance Recipe.app" \
    --root "/chemin/abak-maintenance-xxx"
Le lancement repose sur App Sandbox natif (ne pas l’imbriquer dans sandbox-exec).
Choisir exactement le dossier demandé, sinon arrêt sans base de repli.
Sans les arguments maintenance et racine, la copie refuse le démarrage métier.
Son conteneur propre ne contient aucune donnée réelle ; il reste conservé comme
preuve. Aucun signet persistant ni préférence métier n’est écrit par le parcours.
La restauration des préférences/signets et d’un vrai bundle reste un contrôle
distinct à réaliser avant déploiement utilisateur ; cette recette ne la valide pas.

Périmètre initial (17/10/2026)
Compilation réelle d’une candidate signée, non installée et non lancée.
Démarrage du vrai main Dart en maintenance dans flutter_tester, avec fenêtre
macOS simulée ; SQLite, verrou interprocessus, migrations et fichiers réels,
exclusivement synthétiques. Le fonctionnement de la fenêtre native de la
candidate signée et de ses autorisations macOS reste à réceptionner séparément.
Aucun test effectué sur la base, les préférences ou les pièces utilisateur.

1. COMPILATION SEULE
Depuis la racine du dépôt :
  scripts/macos/compile_macos_local_only.sh \
    --output "/chemin/absolu/existant/candidate-neuve" --version 1.1.1 --build 10

Le parent de sortie doit exister ; le dossier final ne doit pas exister.
Le build doit être supérieur à celui du pubspec source et la version non antérieure.
Le SDK, les dépendances, SQLite, Xcode et l’identité de signature doivent déjà
être disponibles localement. Aucun téléchargement, installateur ni lancement.
La sandbox refuse le réseau et les écritures dans Applications/conteneurs.
Le manifeste valide l’identité .local, la signature, la version et les empreintes.
L’option de compilation SQLite provisoire est retirée en sortie, y compris après
un échec ordinaire. En cas d’arrêt brutal du compilateur, examiner pubspec.before
et pubspec.yaml ; ne pas supprimer des hooks ni écraser une modification tierce.

Ne pas utiliser l’ancien build_macos_release_local_offline.sh pour cette tâche :
son --no-launch n’empêche pas l’installation. Il n’est pas appelé ici.
Le pubspec source reste à sa version actuelle : la candidate utilise les options
de build explicites. Les manifestes et empreintes identifient le contenu exact,
pas le seul numéro 1.1.1+10.

2. MAINTENANCE
Le main reconnaît --abak-maintenance avant tout démarrage métier.
SQLite est ouvert en lecture seule, sans migration. Le verrou noyau est pris
avant l’ouverture. Le seul bouton ferme l’application ; il ne reprend pas le métier.
Échanges, imports, récupération métier, purges, CPS et INSi ne sont pas démarrés.
Le démarrage normal prend le même verrou avant sa base. Les anciennes versions
ne connaissent pas ce nouveau verrou : elles doivent être fermées préalablement.
Un WAL/journal non vide fait refuser l’ouverture, sans réparation ni suppression.

Le lanceur ci-dessous n’accepte QUE la candidate hors Applications et une racine
synthétique portant le marqueur exact. L’option --describe vérifie tout sans lancer :
  /usr/bin/python3 tool/controlled_deployment/maintenance_only.py \
    --candidate "/chemin/candidate-neuve/Companion-candidate.app" \
    --root "/chemin/abak-maintenance-xxx" --describe

Le retrait de --describe est désormais refusé : utiliser la copie native de recette
ci-dessus. Le résultat historique de la veille restait limité à une fenêtre simulée.

3. TESTS REPRODUCTIBLES HORS RÉSEAU
  tool/controlled_deployment/verify_offline.sh \
    "/chemin/absolu/verification-neuve" \
    "/chemin/candidate-neuve/Companion-candidate.app"

Crée uniquement des racines abak-maintenance-* dans la sortie. Compile le banc
localement, utilise flutter_tester et les frameworks de la candidate, sans ouvrir
son binaire ni lancer les modules CPS. Résultats, journaux et captures sont gardés.
Pour les gardes de compilation/échec injecté sur faux dépôt jetable :
  /usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)' \
    /usr/bin/python3 tool/controlled_deployment/verify_build_guards.py

4. POINT DE REPLI ET RETOUR ARRIÈRE SYNTHÉTIQUES
La racine absolue/canonique doit commencer par abak-maintenance- et contenir
SYNTHETIC-ONLY avec exactement ABAK-MAINTENANCE-SYNTHETIC-V1 suivi d’un saut de ligne.
active/ contient app/ (substitut), support/database/abak_desktop.db,
support/episode_document_versions/ (PDF et preuves), preferences/ et documents/.
Aucune option ne cible Applications ou les conteneurs. Aucun lien symbolique,
entrée spéciale, marqueur absent, base incohérente ou auxiliaire non vide accepté.

  /usr/bin/python3 tool/controlled_deployment/recovery.py checkpoint \
    --root "/chemin/abak-maintenance-xxx" --name before-upgrade
  /usr/bin/python3 tool/controlled_deployment/recovery.py preview \
    --root "/chemin/abak-maintenance-xxx" --name before-upgrade
  /usr/bin/python3 tool/controlled_deployment/recovery.py rollback \
    --root "/chemin/abak-maintenance-xxx" --name before-upgrade \
    --expected-active "empreinte retournée par preview"

Le retour remplace une génération complète ; il ne rétrograde jamais le schéma SQL.
Toute saisie métier, tentative, retenue ou preuve nouvelle/modifiée, même hors base,
interdit le retour automatique. Toute modification depuis preview le bloque aussi.
Les préférences et l’application sont des fichiers SUBSTITUTS dans la recette :
restaurer cfprefsd, les signets macOS et un vrai bundle n’est pas encore validé.
Les bundles natifs contiennent des liens : ce moteur est volontairement synthétique,
pas un installateur de production pouvant les copier/restaurer.

Chaque copie est vérifiée, les fichiers/journaux sont synchronisés sur disque.
La génération remplacée reste dans preserved-*, sans suppression automatique.
Une interruption laisse rollback.pending.json. Pour récupérer l’état d’avant
la tentative interrompue (pas pour forcer un déclassement) :
  /usr/bin/python3 tool/controlled_deployment/recovery.py recover \
    --root "/chemin/abak-maintenance-xxx"
En cas d’ambiguïté ou d’altération, arrêt en conservant toutes les copies.

5. PROCHAINE ÉTAPE
Réceptionner le démarrage natif en maintenance sur un environnement/copieur
explicitement isolé et les autorisations macOS ; finaliser le conditionnement
des ressources durables. Ensuite seulement, opération distincte autorisée :
sauvegarde utilisateur cohérente incluant préférences et signets, répétition de
la migration depuis son schéma exact sur copie, retour arrière natif contrôlé,
puis éventuelle installation locale avec DMP bloqué. Les acquis métier J1–J5
ne nécessitent pas une nouvelle série générale. Activation réelle DMP séparée.

Recette du bundle complet et des ressources (18/10/2026)
Le module bundle_recovery.py est réservé aux racines SYNTHETIC-ONLY de maintenance.
Il conserve les symlinks internes des frameworks, modes/ACL/xattrs et vérifie les
signatures. snapshot(root,generation,destination) retourne l’empreinte du manifeste ;
restore(root,archive,empreinte,destination) exige une destination neuve. Une copie
interrompue reste sous .bundle-restore-* ; aucune installation ni bascule utilisateur.
Ce module ne restaure pas un domaine UserDefaults utilisateur.

prepare_bundle_recipe.py --project <miroir DMP> assemble la candidate complète 13,
une copie signée avec identité de recette et droits réduits, ainsi que les ressources
locales archivées. Les sources de référence restent intactes. Les anciens produits
*.bench-* et abak-* sont exclus. Après snapshot/restauration, verify_bundle_recipe.py
--output <output/recette-native-bundle> exerce les refus sur des copies synthétiques.
Toutes ces opérations sont à exécuter sous le profil interdisant le réseau.

native_recipe.py create --bundle-resources ajoute le panneau de recette à une copie
signée de l’entrée métier complète ; launch impose maintenance, racine et sélection
native exacte. Les marqueurs et l’identité sont vérifiés avant les services métier.
Le contrôle utilise LocalDocumentControlRunner et le helper embarqué réel.
Ne pas enlever sandbox-exec pour obtenir artificiellement un résultat vert.

Résultat actuel : sauvegarde/restauration et démarrage maintenance acquis. Le lancement
produit de Java depuis App Sandbox échoue : sandbox_apply: Operation not permitted,
code 71. Les résultats doivent rester non vérifiés. verify_restored_resources.py
est un diagnostic CLI DISTINCT, sous un seul sandbox-exec par processus Java ;
son succès ne certifie pas le lancement depuis l’application signée.
Voir output/recette-native-bundle/Bilan.txt dans le miroir DMP pour les preuves et
la prochaine correction ciblée. Aucun déploiement utilisateur autorisé par ce banc.


Retour arrière coordonné — recette synthétique complète (18/10/2026)
coordinated_recovery.py prépare une génération restaurée authentifiée, conserve la génération active et maintient coordinated.pending.json jusqu’à vérification native des préférences, de l’historique et du signet. Empreinte du plan conservée indépendamment ; journal immuable. Une interruption après renommage est récupérée en examinant les inventaires exacts, sans supprimer de génération. La finalisation exige un reçu concordant produit par la copie signée.
run_coordinated_phase.py ne lance que la copie non installée préparée avec native_recipe.create(..., coordinated_folder=...), en maintenance explicite. Phases seed, upgrade, blocked, restore-crash, recover et verify ; restauration des préférences réservée à l’identité de recette, jamais à un domaine utilisateur arbitraire. Aucun démarrage métier, DMP/CPS/INSi ou réseau. L’arrêt 86 est une injection de panne prévue.
verify_coordinated.py vérifie les refus et un arrêt brutal 79 pendant la bascule. verify_coordinated_startup.dart couvre le blocage avant SQLite et le verrou. verify_coordinated_delivery.py examine les preuves finales et l’intégrité des deux générations. Ne pas appliquer ces outils à une installation utilisateur : racines marquées synthétiques uniquement.
La copie par ditto peut rafraîchir le timestamp de quarantaine : copy_verified rétablit l’attribut source intégral seulement si aucun autre champ ni drapeau ne diffère, puis exige une égalité complète. Elle ne retire jamais la quarantaine.
Recette exécutée : candidate complète 1.1.1+19 ; génération20 de mêmes sources avec seules métadonnées/signature modifiées, migration SQL36/37 réelle sur synthétique. Préférences/signets testés sur le même Mac et la même identité de recette.
