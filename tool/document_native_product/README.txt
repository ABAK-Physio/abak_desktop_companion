J5 — raccordement natif TD0.2 / CPS / TLS, vérification hors réseau

CODE PRODUIT
lib/features/patients/services/dmp_chain/native/{ports,bridge,td02}.dart
assets/dmp_native/DmpNativeBridge.java (JDK 17, aucune dépendance téléchargée)
lib/features/cps/cps_operation_lease.dart

DocumentDmpNativePorts implémente les interfaces de la chaîne commune. Il lit le
profil CPS via CpsAccessService (lecteur injectable), compare le professionnel et
la situation configurée au contexte figé, puis demande au worker natif une session
PKCS11 avec certificats authentification/signature distincts. Un propriétaire CPS
unique est conservé dans Companion jusqu'à la fin du worker. Les autres logiciels
ne sont pas contrôlés par ce verrou ; leurs conflits sont des erreurs bloquantes.
La lecture du profil ferme sa session avant la session PKCS11 du worker ; un seul
PIN utilisateur est demandé, sans cache, fichier, argument de commande ni journal.
Les chaînes et CRL locales sont contrôlées avant les deux TLS mutuels. Le VIHF est
émis après les deux handshakes. Les canaux restent associés à la même session ;
ni reconnexion, ni redirection, ni nouvel essai automatique. TD0.2 puis signature
et MIME utilisent les entrées figées. Un résultat après réservation conserve le
verrou du journal, même en cas de perte de connexion ou de réponse non corrélée.
La fermeture de session appartient à l'appel ayant obtenu cette session ; un
second appel concurrent refusé ne ferme pas la session du premier.

CONFIGURATION EXPLICITE, AUCUNE VALEUR DV1 OU PATIENT PAR DÉFAUT
DmpNativeConfiguration : configuration LPS/XDS, endpoint TD0.2, mode T/P,
chemin absolu Cryptolib, bundle PEM local (racines/intermédiaires/CRL complètes)
et son empreinte SHA256, empreintes des deux certificats, numéro/mode/statut/
secteur de la situation CPS. La CRL ne se télécharge jamais automatiquement.
Le fournisseur de politique (opposition/droits/visibilité/catalogue) reste injecté
et doit fournir une décision vérifiée pour le snapshot ; aucune valeur permissive
par défaut. Une situation CPS illisible ou différente n'est pas inventée.
DmpProcessBridge prend un exécutable Java 17 explicite et, pour le worker produit,
les arguments [chemin absolu DmpNativeBridge.java, --serve]. Le source est embarqué
comme asset ; son chemin installé/extrait et les paramètres de déploiement restent
à configurer explicitement avant activation. Aucun worker n'est lancé au démarrage.
Aucun écran ni ordonnanceur n'enregistre ce fournisseur pour des envois réels.
L'entrée de chaîne reste executeSimulated avec stockage marqué J4-SYNTHETIC-ONLY.
Ne pas lui injecter un fournisseur CPS/réseau réel pour une simulation.

BANC ISOLÉ
certificates.py produit uniquement des certificats et clés synthétiques dans le
dossier choisi. NativeTestBridge remplace CardIdentity/SocketChannel par des clés
logicielles et deux moteurs JSSE qui chiffrent/déchiffrent en mémoire ; aucune
socket, aucun chargement de Cryptolib. Le protocole stdio, le runtime, PKIX, TLS,
signature RSA et le raccordement Dart sont effectivement exécutés. Les réponses
de dépôt viennent de copies des archives : seul RelatesTo est adapté au MessageID
synthétique, sauf le scénario non corrélé. Cela ne prouve aucun dépôt du PDF réel.
Les tests de journal utilisent les vrais services produit, une SQLite synthétique,
les sauvegardes/restaurations produit et des doubles pour les contrôles PDF/CDA
(déjà contrôlés nativement dans J3/J5 précédents). Nouveau processus pour la reprise.

EXÉCUTION REPRODUCTIBLE
1. Sous sandbox-exec '(version 1)(allow default)(deny network*)', exécuter
   certificates.py avec le Python local disposant de cryptography.
2. bash tool/document_native_product/verify_offline.sh SORTIE_ABSOLUE CERTIFICATS
   Le script compile le worker et le banc, puis lance Flutter sans VM service,
   sous interdiction réseau. Ne pas lancer flutter test/pub get.
3. Compiler aussi NativeUnit.java et exécuter NativeUnit CERTIFICATS RAPPORT_JSON,
   sous la même interdiction réseau.
4. independent.py SORTIE SCHEMAS_TD02_ARCHIVES REPO (Python lxml/cryptography,
   interdiction réseau) vérifie le TD0.2 et le paquet avec les schémas archivés.

LIMITES DE VALIDATION
SunPKCS11/Cryptolib et SocketChannel sont compilés, mais ne sont pas sollicités
par le banc. Il reste une recette native autorisée, les paramètres officiels de
déploiement avant activation réelle. La réconciliation hors réseau est ajoutée
dans document_reconciliation_product ; elle conserve le blocage du renvoi. Aucun test simulé ne vaut homologation ni validation DV1.
