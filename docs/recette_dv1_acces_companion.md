# Accès TD0.2 réel depuis Companion

Entrée : **Assistance → Recette DMP — accès réel DV1 sans dépôt**.

Ce parcours utilise le service CPS natif de Companion, puis le moteur Java embarqué dans ses assets. Aucun lanceur technique externe, serveur local de pilotage ou navigateur n’est requis. Sur macOS, Java 17 est intégré à Companion avec un lanceur dédié signé pour l’accès aux cartes à puce ; la Cryptolib ANS installée reste nécessaire. Le Java du système n’est pas modifié. La configuration DV1 existante est partagée avec le parcours documentaire.

## Préparation et exécution manuelle

1. Recompiler et ouvrir Companion sur macOS.
2. Configurer les identifiants CNDA/LPS, la situation de la CPS choisie, Java, la Cryptolib, les certificats publics de cette carte, les autorités/CRL, les paramètres et nomenclatures officiels. Le moteur CPS intégré est proposé automatiquement. Après mise à jour depuis une configuration utilisant un Java externe, ouvrir puis enregistrer la configuration sans connexion ; les ressources déjà enregistrées sont conservées. Aucun appel CPS ou serveur n’est effectué lors de cet enregistrement.
3. Renseigner la référence du scénario, la source CNDA du patient fictif, son libellé, sa date de naissance exacte (AAAA-MM-JJ), son INS de test avec clé et la structure d’exercice. Ces données de recette ne sont pas enregistrées dans une fiche patient et ne constituent pas une qualification INS.
4. Pour une CPS de remplaçant avec situation mode 4 / statut 1, activer le rattachement temporaire et préciser sa fin avec fuseau. Les éléments présents sur la CPS doivent correspondre ; seuls la structure et le secteur absents peuvent être complétés par ce rattachement. L’association expire avec l’opération et ne modifie pas la fiche du praticien.
5. Préparer l’accès, relire le récapitulatif, confirmer et saisir le PIN. Une lecture fraîche vérifie le professionnel et la situation. Les certificats sont contrôlés et les connexions TLS DV1 établies ; une seule requête TD0.2 est émise. Les services patients et repository font l’objet d’une connexion TLS, mais aucune requête de dépôt n’est envoyée.
6. Examiner le résultat et l’historique. Un DMP actif sans droit de consultation n’est pas un échec d’authentification et ne vaut pas autorisation de consultation. Une réponse inconnue, une interruption ou un échec d’archivage ne doit pas être déclaré conforme.
7. Fermer la session avant de changer de carte. Adapter la configuration et les deux certificats publics à l’autre carte, puis préparer un nouvel essai explicite.

## Preuves

### Connexion secrète — préparation PRE_MODE_CNXSC

Le parcours TD0.2 lit `fonctions-gestion-mineurs` et `age-majorite` dans le fichier officiel conservé dans la configuration DV1. Une date absente, impossible ou future est refusée avant lecture CPS. Pour un mineur lorsque la fonction est active, le dialogue préalable exige un choix normal/secret non précoché. Ce choix n'est jamais repris d'un essai précédent ; il est demandé à nouveau après annulation ou fermeture. Aucun seuil minimum optionnel n'est appliqué.

En mode secret uniquement, le VIHF contient l'attribut `urn:oasis:names:tc:xspa:1.0:resource:patient:hl7:confidentiality-code`, de valeur `INVISIBLE_REPRESENTANTS_LEGAUX^1.2.250.1.213.1.1.4.13` (SEL-MP-037 v2.10, EX_0.1-1100, tableau VIHF CPS pp.161–162). Le purposeOfUse reste normal : le choix secret n'accorde pas d'autorisation de consultation. La date, les paramètres utilisés et le choix sont archivés avec la requête et la réponse. La recette interdit toujours signature de document et dépôt.

Le raccordement porte exclusivement sur cet écran de recette TD0.2, pas sur l'ensemble des transactions documentaires. Les contrôles automatisés de sérialisation sont synthétiques et hors réseau. Ils ne prouvent ni authentification CPS ni acceptation DV1. PRE_MODE_CNXSC reste à réaliser sur DV1 avec le patient mineur du plan CNDA, puis à examiner avant déclaration conforme.

Chaque opération reçoit son propre dossier dans `controls/dv1-access-history`, accessible par le chemin affiché dans l’historique. `result.json` contient le scénario, les paramètres de recette, les versions de l’application/configuration/moteur, les preuves de session, les états et la fermeture. Les fichiers `request.xml`, `response.xml`, `http.txt` conservent les échanges disponibles, y compris les réponses SOAP en erreur. Le PIN est transmis en mémoire, jamais inscrit dans les preuves, arguments de processus ou journaux. Les empreintes permettent de constater une incohérence ; ce ne sont pas des signatures des preuves.

Une interruption laisse une trace de l’étape atteinte. Aucun nouvel essai n’est automatique. Une fermeture native non confirmée maintient le verrou CPS. La capacité de signer/déposer est interdite pour ce parcours dans les ports Dart et dans le moteur Java. Le parcours documentaire conserve ses conditions de validation.

## État de livraison

Analyse statique et compilation du seul source Java possibles sans exécution. Aucun essai CPS, réseau, INSi ou DV1 n’est effectué lors de cette adaptation. L’enregistrement d’un résultat conforme dans le CDT attend l’exécution et l’examen du véritable essai depuis Companion.

La lecture CPS métier est actuellement raccordée sur macOS seulement. Le nouvel écran refuse l’exécution sous Windows avec un message explicite. Le raccordement Windows et sa recette restent à effectuer ; aucun résultat Mac ne couvre Windows.

## Correction du lancement macOS — 26 octobre 2026

L’essai interrompu à 15:06:04 UTC correspond à un plantage du processus Java enfant de Companion dans la communication PC/SC (`com.apple.ctkpcscd`). Le Java externe n’avait pas l’entitlement `com.apple.security.smartcard`. Apple impose cette autorisation aux applications sandboxées utilisant PC/SC : https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.smartcard

Le paquet privé comprend désormais les modules `jdk.crypto.cryptoki` et `jdk.crypto.ec`. Un lanceur distinct `java-cps` reçoit l’autorisation smartcard ; le lanceur PDF conserve ses autorisations précédentes. Le processus reste soumis aux restrictions héritées de Companion. Aucun Java global n’est re-signé, aucune protection de l’application n’est désactivée. Le manifeste inclut le nouveau lanceur signé. Les anciennes configurations exigent un réenregistrement explicite avant l’essai.

Contrôles locaux : analyse Dart, préparation et signature du paquet temporaire, présence de l’autorisation, démarrage Java et liste des modules. Aucune carte ni connexion DV1 sollicitée. La disparition du plantage PC/SC reste à confirmer depuis l’application recompilée ; ces contrôles ne constituent pas une preuve d’homologation.


## Accord du patient et autorisation de consultation TD0.3

Le parcours de recette reprend la question posée au patient : « M’autorisez-vous à
consulter les informations de votre DMP ? ». Aucun choix Oui/Non n’est présélectionné,
même lorsqu’une réponse précédente existe. Le patient et le praticien sont affichés.
Pour la recette, il s’agit d’une réponse jouée pour le patient fictif CNDA.

- **Oui** : enregistrement local uniquement, sans CPS ni appel au DMP. L’utilisateur
  doit ensuite demander explicitement la consultation. Companion vérifie TD0.2 :
  si le DMP est actif et l’autorisation inexistante ou expirée, envoi de TD0.3 AJOUT.
  Une autorisation déjà valide ne provoque pas un nouvel ajout.
- **Non** : enregistrement local durable du refus, puis lancement immédiat du
  parcours de retrait avec confirmation CPS. Après TD0.2, une autorisation valide
  entraîne TD0.3 SUPPRESSION. Si elle est déjà absente ou expirée, aucun TD0.3 inutile.
- L’annulation du PIN, une erreur réseau, une réponse non corrélée ou un retrait
  non confirmé ne rétablissent jamais l’accord. L’état reste « retrait non confirmé » ;
  une reprise explicite est possible. Aucun nouvel accord ne remplace un retrait en attente.
- Un résultat inconnu, un DMP absent/fermé ou une interdiction ne déclenchent pas
  d’ajout d’autorisation. Aucun mode bris de glace n’est introduit.

Après TD0.3, seul un `DMPOk` corrélé à la demande permet une nouvelle vérification
TD0.2. L’état attendu doit être retrouvé avant d’annoncer le succès. Les requêtes,
réponses, codes HTTP et empreintes sont conservés dans l’historique de l’essai.
Chaque session ne permet qu’une mutation et une vérification après mutation,
sans réessai automatique. Les nouvelles connexions utilisent la CPS déjà authentifiée
et le même contexte patient/praticien, avec conservation du choix de connexion secrète.

Les réponses du patient sont conservées séparément dans `dv1-consultation-consents`,
par INS et praticien, avec date, provenance CNDA et versions successives. Elles ne
qualifient pas l’identité du patient et ne modifient aucune fiche patient réelle.
Le refus concerne la consultation, pas les règles distinctes d’alimentation.

Ce raccordement est limité à la **recette DV1 sur macOS**. La demande de consultation
sert ici à tester l’autorisation : aucun document DMP n’est recherché ni ouvert.
Le raccordement Windows et l’intégration au futur parcours de consultation clinique
restent distincts. Les tests unitaires sont synthétiques ; PRE_TD0.3 ne sera déclaré
réussi qu’après l’essai réel depuis Companion et examen des preuves.

Références locales : SEL-MP-037 version 2.10.0 du 09/07/2025, §3.2.3,
EX_0.3-1010, EX_0.3-1030 et EX_0.3-1040 ; annexe Habilitations.wsdl
(namespace `urn:si-dmp-habilitations`, structure SOAP définie par le WSDL).


### Correction de l’action TD0.3 — 27/10/2026

Le premier essai réel (preuve c0ce7522-eb52-42d2-bea9-9e9be5d1e304) a reçu
HTTP 500, SOAP Sender / ActionNotSupported pour `urn:hl7-org:v3:setAuthorization`.
Cette valeur figure dans l’ancien WSDL, mais les exemples officiels de messages
TD0.3 et le code C# HabilitationSoapService utilisent en WS-Addressing :
`urn:si-dmp-habilitations:HabilitationsEndPoint:setAuthorization`.
Le client et le contrôle natif utilisent désormais cette valeur, alignée dans
l’en-tête WS-Addressing et le paramètre action du Content-Type SOAP 1.2.
Aucun réessai automatique. Les SOAP Fault corrélés sont conservés et affichés,
et les statuts HTTP TD0.2 initial, TD0.3 et TD0.2 après modification sont distingués.
Le succès réel reste à établir après recompilation et nouvel essai explicite.


### Vérification après ajout — 27/10/2026

Essai 57c56860-b049-43c0-bb39-f94c73a242f5 : TD0.2 initial HTTP 200,
TD0.3 HTTP 200 / DMPOk / « Autorisation ajoutée ». La commande locale de
vérification utilisait une majuscule interdite par le protocole stdio : elle n’a
pas été envoyée. Nom corrigé en `authorizationrecheck` dans Dart et Java ; test
avec le véritable transport stdio et un correspondant synthétique sans réseau.
Un DMPOk suivi d’un échec de vérification est désormais distingué d’un échec de
la modification. Ne pas relancer aveuglément un ajout : vérifier les droits TD0.2.

### Réutilisation de l’authentification CPS — 27/10/2026

Dans l’écran de recette DV1 sur macOS, un essai TD0.2/TD0.3 réussi peut conserver
l’authentification CPS pour l’essai suivant. Chaque essai demande toujours une
confirmation du patient, du scénario et du mode de connexion. Le PIN n’est ni
stocké ni rejoué ; la session PKCS#11 du moteur natif reste ouverte. La reprise
contrôle de nouveau la carte par une preuve cryptographique, les certificats,
les révocations, la configuration et le praticien du bandeau.

Chaque opération conserve sa limite de deux minutes et reçoit un nouvel identifiant,
de nouveaux canaux TLS et un contexte patient indépendant. Tous les canaux réseau
sont fermés entre les essais. La présence de la carte est contrôlée localement
chaque cinq secondes au repos, sans requête réseau. Une erreur, une carte retirée,
le verrouillage, un changement de praticien, la désactivation du DMP, une modification
de configuration ou une autre utilisation de la CPS met fin à l’authentification
conservée. Une autre fonctionnalité attend cette fermeture avant d’utiliser la carte.
L’authentification a aussi une durée maximale d’une heure depuis la première ouverture,
non prolongée par les reprises ; le verrouillage d’inactivité conserve son propre délai.
La fermeture de Companion termine le moteur, dont la fin du flux ferme la session.

Le journal distingue la fermeture de l’opération et de ses connexions de la
conservation éventuelle de l’authentification CPS **à la fin de l’essai**. Cet état
historique ne prouve pas qu’elle est encore active. Les consentements patient ne
sont pas réutilisés ou modifiés par ce mécanisme. La signature, le dépôt, INSi et
Windows ne bénéficient pas de cette réutilisation ; leurs contrôles restent distincts.

Vérifications locales : tests de cache et d’exclusion mutuelle, invalidation au
verrouillage/changement/désactivation, retrait de carte simulé, expiration, fermeture
échouée, et parcours Dart/Java avec deux patients synthétiques, un seul login et deux
transactions indépendantes. Les tests Java utilisent des certificats synthétiques et
des canaux en mémoire ; le réseau est interdit. Aucun essai réel supplémentaire n’est
à déclarer au CNDA sur cette seule base.

Pour le prochain essai utilisateur après compilation : exécuter un TD0.2 réussi,
puis préparer un deuxième TD0.2 avec le même praticien et la même configuration.
La deuxième confirmation doit afficher « Votre CPS est déjà authentifiée » sans
champ PIN. Après verrouillage puis déverrouillage, la préparation d’un nouvel essai
DMP doit demander à nouveau le PIN. Aucun dépôt n’est nécessaire pour cette vérification.

## TD0.9 — raccordement Firefox Mac, 27/10/2026

Le parcours réel Web-PS utilise maintenant un pont macOS fourni avec Companion,
sans service Node/Playwright ni fichier de connexion manuel. Le choix enregistré
`dmp_webps_browser_macos` est respecté : ce premier raccordement accepte Firefox
uniquement, sans basculer silencieusement vers Chrome ou Safari. Windows reste
à raccorder. Le bouton « Accès Web-PS — recette DV1 » est sous les réglages DMP
activés. Les anciens lanceurs techniques restent des outils historiques, pas le
chemin appelé par cet écran.

Les deux cibles sont le tableau de bord et le DMP d'un patient fictif CNDA dont
l'utilisateur saisit le nom et le NIR de test. L'OID NIR est fixé ; une clé invalide
ou un NIA sont refusés. Aucun rattachement ou changement de statut INS en base.
Le kiné attendu est celui du bandeau. Confirmation explicite avant ouverture ;
aucun PIN transmis par Companion. L'utilisateur doit vérifier le praticien et
le patient effectivement affichés par Web-PS. Une ouverture n'est pas une preuve
d'authentification ou de droits.

Firefox doit être quitté avant l'essai. Une nouvelle instance `--no-remote`
utilise un profil jetable appartenant à Companion, avec le module PKCS#11 ANS
installé dans `/usr/local/lib/libcps3_pkcs11_osx.dylib`, sans copie d'un profil
personnel. La configuration NSS et l'accès CPS dans cette instance restent à
vérifier lors de la recette réelle. Aucun relâchement de la vérification TLS.

Une réservation commune CPS ferme l'accès avant une autre opération carte,
un verrouillage ou un changement de praticien. Un échec de fermeture conserve
le blocage. La fermeture du processus Firefox est vérifiée ; fermer sa dernière
fenêtre ne quitte pas nécessairement l'application sur Mac : utiliser « Fermer
l'accès Web-PS » dans Companion. Un marqueur persistant bloque une réouverture
après interruption incertaine ; quitter Firefox puis fermer l'accès permet la
récupération. Companion ne ferme jamais une instance personnelle préexistante.
L'activité dans Firefox n'alimente pas le délai d'inactivité de Companion.
L'utilisateur doit fermer les autres accès DMP ; la surveillance ne prétend pas
inventorier les pages d'autres navigateurs.

Validation de développement : tests Dart hors réseau (URL, consentement explicite,
contexte du kiné, concurrence, verrouillage pendant ouverture, fermeture refusée,
reprise et libération), analyse Dart et vérification de types Swift. Aucun
navigateur, aucune carte ni requête DV1 lancés par ces contrôles. PRE_TD0.9 demeure
à réaliser dans l'application compilée sur Mac, puis Windows.

### Correction du lancement Firefox depuis la version protégée — 27/10/2026

L'essai utilisateur a ouvert le profil Firefox habituel sur un nouvel onglet.
L'inspection du processus a confirmé l'absence des arguments de lancement.
Apple précise que `NSWorkspace.OpenConfiguration.arguments` est ignoré lorsque
l'appelant est sandboxé :
https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/arguments

Le lancement est désormais confié au service signé intégré
`AbakWebPsBrowser.xpc`, distinct du service de contrôles documentaires hors réseau.
Runner conserve ses protections. Le service accepte uniquement le même utilisateur
et le logiciel hôte signé par l'équipe attendue ; le client vérifie également la
signature du service. Les seules commandes sont état, ouverture et fermeture,
avec Firefox et les deux chemins Web-PS DV1 autorisés. Aucune commande shell,
adresse arbitraire, lecture de carte ou collecte du PIN n'est exposée.

Le service détient l'instance Firefox, le profil dédié et le marqueur de session.
Il vérifie les arguments effectifs du processus retourné (profil, adresse et
`--no-remote`) avant d'en confirmer la prise en charge. En cas d'incertitude,
il conserve le blocage et demande de quitter Firefox manuellement. Une rupture
de la connexion avec Companion demande la fermeture de l'instance détenue.
Le profil de ce service est situé sous Application Support / identifiant de
l'application hôte / ABAK-WebPS-Firefox, séparé du profil personnel de Firefox.

Vérifications hors connexion : vérification de types Swift du client et du service,
compilation du service pour Apple Silicon et Intel, syntaxe des scripts d'intégration,
six contrôles des paramètres (cas nominal, arguments absents ou incomplets,
mauvais profil, mauvaise adresse, absence d'isolement). Aucun navigateur, carte ou
appel DV1 lancé pendant ces vérifications. L'intégration XPC dans l'application
recompilée et l'authentification Firefox/CPS restent à confirmer en essai réel ;
PRE_TD0.9 n'est pas déclaré réussi.

### Fermeture Firefox — correction de l'état périmé, 27/10/2026

L'utilisateur a atteint le tableau de bord Web-PS avec la CPS de MARIE, après
saisie du PIN et sélection du cabinet de remplacement. Après avoir quitté Firefox,
Companion ne confirmait pas sa fermeture. L'inspection a constaté l'absence de
processus Firefox et la présence persistante du service Web-PS et de son profil.

Le service utilisait `RunLoopType=dispatch_main`. Les en-têtes Apple
`NSRunningApplication.h` précisent que `isTerminated` et la liste des applications
ne sont actualisés qu'au passage de la boucle principale NSRunLoop. Le service
est désormais construit avec `RunLoopType=NSRunLoop`, valeur prévue par
`xpcservice.plist(5)`. La fermeture reste conditionnée à l'arrêt du navigateur et
au nettoyage du profil ; aucun marqueur n'est supprimé manuellement pour contourner
ce contrôle. L'écran restitue désormais le message précis du service en cas d'échec.
La confirmation de fermeture et l'ouverture directe du patient restent à vérifier
avec l'application recompilée.

## PRE_ALIM_N1 — raccordement du patient fictif (27 octobre 2026)

Le parcours du rapport accepte désormais une déclaration explicite
`CNDA_DV1_ALIMENTATION`. Les anciennes déclarations
`CNDA_MEDICAL_REVIEW_ONLY` permettent encore la revue, mais bloquent la préparation
technique : ouvrir « Patient de recette CNDA », vérifier la référence et confirmer
le nouveau périmètre, puis reprendre la revue et la validation de la version.

L’INS de test est projetée dans la capture documentaire seulement. La fiche patient
reste fictive et provisoire ; aucun résultat INSi ni preuve de qualification n’est
créé. La capture conserve la référence CNDA, la date de confirmation et l’empreinte
des traits. Un changement de ces données invalide la concordance de la validation.
Le code du lieu de naissance doit être renseigné depuis une source justifiée :
aucune déduction automatique depuis le numéro INS.

Parcours manuel prévu : MICHEL titulaire, rapport fictif BONNEL, auteur et
validateur identiques, exercice ambulatoire, patient majeur, visibilité patient et
professionnels, représentants légaux sans objet. Enregistrer le contexte, examiner
le PDF et valider en mode test, effectuer les contrôles PDF/A et CDA, signer le lot,
configurer DV1, lever la retenue puis confirmer le dépôt. Le scénario PRE_ALIM_N1
et la référence CNDA sont proposés dans la confirmation, sans cocher les accords.
Les contrôles, preuves, correspondance CPS, retenue et confirmation de dépôt restent
requis.

Le paquet de recette est limité à l’adresse exacte repository de DV1 ; TD0.2 est
limité à patients DV1 avec processingMode T. Ce parcours est refusé par l’entrée
de simulation. Les critères du parcours réel avec identité qualifiée restent
inchangés. Une nouvelle confirmation modifie la capture : une validation ancienne
ne peut pas être réutilisée pour ce nouveau parcours.

Vérification de développement : analyse Dart ciblée sans anomalie ; tests locaux
sur données synthétiques pour projection sans mutation, consentement ancien,
destinations interdites, traits modifiés, identité réelle/qualifiée, INS incohérente,
lieu manquant et encapsulation CDA niveau 1. Ces tests ne prouvent ni conformité
ANS du document final ni acceptation DV1. Aucun appel CPS, INSi, DV1 ni dépôt n’a été
effectué lors de cette modification. PRE_ALIM_N1 reste à réaliser dans Companion
sur macOS, puis Windows.


## PRE_ALIM_RECH — préparation depuis un dépôt accepté (29/10/2026)

Le CDT, feuille « Phase 1 Prérequis », ligne PRE_ALIM_RECH, demande de
rechercher l’identifiant technique d’un document à partir de son identifiant
local (TD3.1b), en préparation d’un remplacement ou d’une dépublication.
SEL-MP-037 v2.10 MCO 2, §3.5.1.2, RG_3120/RG_3130 (pages 113–114) impose
GetDocuments avec returnType ObjectRef ; LeafClass est interdit dans ce
parcours. La recherche ne doit pas être automatique après alimentation.

1. Ouvrir le document dont le dépôt DV1 a été accepté, puis « Recette DMP sur DV1 ».
2. Si nécessaire, cliquer « Actualiser la préparation DV1 ».
3. Cliquer « Préparer la recherche du document — PRE_ALIM_RECH ».
   Cette navigation ne lit pas la CPS et ne contacte pas DV1. Les dépôts proposés
   sont limités à la version acceptée ; les preuves sont vérifiées localement.
   Un seul dépôt vérifié est présélectionné ; plusieurs nécessitent un choix.
4. Vérifier le patient fictif, l’identifiant local et le professionnel configuré.
5. Cliquer « Rechercher ce document dans le DMP », puis confirmer le récapitulatif
   et l’usage de la CPS. Le service vérifie TD0.2 puis effectue GetDocuments.
6. Résultat attendu : « Document retrouvé dans le DMP. Identifiant technique
   conservé. » Un seul entryUUID doit être retourné. Aucun résultat ou plusieurs
   résultats ne valident pas le test. Aucun remplacement, archivage ou retrait
   de document n’est déclenché par ce parcours de recette.
7. Conserver la cinématique et les preuves dans dv1-access-history : result.json,
   td31b-request.xml, td31b-response.xml et td31b-http.txt. Le résultat contient
   la cible locale, la tentative de dépôt source, les empreintes et technicalIds.
   Un futur remplacement/retrait devra faire sa propre recherche au moment de
   l’action ; cet essai ne vaut pas autorisation d’utiliser un identifiant périmé.

PRE_ALIM_N3 : option Gestion Documents structurés non retenue par l’éditeur le
29/10/2026, non applicable sur macOS et Windows. PRE_ALIM_RECH reste à valider
sur DV1 ; les vérifications hors ligne ne constituent pas le résultat de recette.


## PRE_ALIM_RPLC — remplacement explicite sur macOS (29/10/2026)

Références : CDT « Phase 1 Prérequis », PRE_ALIM_RPLC (TD2.1b) ;
SEL-MP-037 v2.10 MCO 2 §3.4.1.2, RG_2910 (pages 104–105),
§3.5.1.2 RG_3130. Le nouveau CDA référence l’ancien uniqueId dans
relatedDocument typeCode RPLC / parentDocument / id. Les métadonnées XDS
associent le nouveau document à l’ancien entryUUID avec une association RPLC.
Le serveur rend la nouvelle version courante et l’ancienne obsolète.

Parcours :
1. Dans la même pièce que le dépôt accepté, « Importer une nouvelle version PDF »
   avec un PDF/A effectivement modifié (ou créer la nouvelle version depuis un DOCX).
   Le parcours initial se limite au remplacement par un contenu PDF différent.
2. Enregistrer les informations de préparation de la nouvelle version.
3. « Recette DMP sur DV1 » puis « Préparer le remplacement — PRE_ALIM_RPLC ».
   Confirmer la préparation locale : aucun appel CPS ni réseau à ce stade.
4. Relire le nouveau PDF et enregistrer sa validation médicale de test ; effectuer
   ses contrôles PDF/A et CDA. Le lien de remplacement fait partie du CDA contrôlé.
   Une validation antérieure à cette préparation est invalidée automatiquement.
5. Lever explicitement la retenue, actualiser la préparation DV1 si nécessaire,
   puis « Signer et remplacer sur DV1 — PRE_ALIM_RPLC ».
6. Vérifier l’ancienne cible, la nouvelle version, le patient et le scénario dans
   le dialogue. Confirmer les conditions et l’usage de la CPS.
7. Companion vérifie TD0.2, recherche à nouveau l’entryUUID par GetDocuments
   ObjectRef dans la même opération, exige un résultat unique, signe le nouveau
   lot et réserve la tentative avant de l’envoyer. Le résultat PRE_ALIM_RECH
   précédent n’est pas réutilisé comme autorisation ni comme cible technique.
8. Résultat attendu : XDS Success pour cette tentative de remplacement. Conserver
   la cinématique, le journal, la recherche, le CDA, le lot signé et la réponse.

La migration de schéma 48 conserve les données existantes et adapte le verrou
SQL : une nouvelle version modifiée peut remplacer le dernier dépôt accepté,
avec lien explicite. Même version, cible incertaine, autre patient, restauration,
contenu déjà tenté ou seconde réservation restent bloqués. Aucun renvoi automatique.
Les preuves de recherche et de remplacement sont conservées dans la chaîne DV1 ;
la relecture des archives vérifie la cible initiale, le résultat de recherche et
le paquet signé. Les preuves des dépôts antérieurs restent vérifiables.

À ce stade : préparation logicielle et tests hors ligne seulement. Aucun essai
PRE_ALIM_RPLC réel n’a été effectué par l’assistant ; résultat macOS à établir,
Windows à réaliser ultérieurement.


## PRE_ALIM_SUPPR — macOS (à exécuter)

CDT « Phase 1 Prérequis », ligne 32 : dépublication via TD3.3c, statut Deleted.
Références : SEL-MP-037 v2.10 MCO 2, §3.5.3.2–3.5.3.3.3, RG3410–3430 ;
WSDL DocumentRegistry_UpdateDocumentSet ; IHE MU ITI-57 §3.57.4.1.3.3.2
(https://www.ihe.net/uploadedFiles/Documents/ITI/IHE_ITI_Suppl_XDS_Metadata_Update_Rev1-13_TI_2022-06-17.pdf).

Dans le parcours de recherche des documents déposés, sélectionner le dernier dépôt
accepté (version 4 après PRE_ALIM_RPLC), puis « Dépublier ce document — PRE_ALIM_SUPPR ».
Le scénario est renseigné automatiquement. Le dialogue indique le document et son
identifiant local, exige la confirmation de l’auteur et de la dépublication irréversible.
La copie locale est conservée. Windows reste à réaliser.

Après confirmation et saisie du PIN dans Companion : TD0.2, recherche GetDocuments
ObjectRef unique, puis UpdateDocumentSet avec un nouveau SubmissionSet et une seule
association UpdateAvailabilityStatus (Approved vers urn:asip:ci-sis:2010:StatusType:Deleted).
Aucun nouveau PDF, CDA ou lot signé n’est déposé. Le serveur vérifie les droits d’auteur
et le statut initial ; un conflit doit rester un refus.

Le parcours exclut les archives historiques importées, les dépôts non confirmés,
les anciennes versions remplacées et les auteurs/contextes différents. Une réservation
exclusive est persistée avant TD3.3c. Toute réponse incertaine ou tout arrêt après cette
réservation bloque le renvoi, y compris après redémarrage. Ne pas supprimer ce verrou
pour réessayer ; examiner les preuves et l’état distant par un parcours approprié.
Les requêtes, réponses, codes HTTP et empreintes sont conservés dans l’historique DV1.
Un succès n’est annoncé que pour une réponse HTTP 200 RegistryResponse Success corrélée.

Vérifications hors réseau : dmp_td33c_test.dart, dv1_depublication_integration_test.dart
(opt-in, base locale en lecture seule), DepublicationUnit.java (canaux mémoire).
Le test réel PRE_ALIM_SUPPR n’a pas été exécuté lors de cette adaptation.


## PRE_CONS_RECH — préparation macOS (29 octobre 2026)

Parcours dédié dans Paramètres → Recette DMP / accès réel DV1, bloc
« Rechercher par statut et type — PRE_CONS_RECH ». Le bouton « Préparer le cas 75 »
remplit Corinne DUPRE, INS 148115530271002, naissance 09/11/1948 et le scénario,
sans connexion. L’INS, la naissance et le sexe F ont été fournis explicitement par
l’éditeur le 29/10/2026 ; leur provenance est affichée, sans inventer une référence
à une fiche CNDA non retrouvée. La clé INS 02 est cohérente avec le matricule.
Le sexe n’est pas transmis par cette recherche et n’est pas déduit de l’INS.
Le service refuse une autre identité pour ce cas. Aucune qualification INS ni
fiche patient réelle n’est créée par ce parcours.

La CPS reste celle choisie dans la configuration DV1 et vérifiée par le lecteur.
Enregistrer explicitement l’accord du patient fictif. Si le droit serveur n’est
pas valide, utiliser séparément « Demander la consultation du DMP ». La recherche
ne modifie jamais l’autorisation : elle exige un TD0.2 actif et un droit valide.
Elle utilise FindDocuments / TD3.1, retour LeafClass, patientId CX avec NH,
Approved systématique, Archived et Deprecated sur choix, TypeCode optionnel issu
de la nomenclature locale configurée. Les résultats exposent titre, type, date,
statut et identifiants ; aucun contenu n’est téléchargé.

Les fichiers td31a-request.xml, td31a-response.xml, td31a-http.txt et result.json
conservent critères, patient, CPS, corrélation et métadonnées. Un résultat vide ne
valide pas le prérequis. Réponse d’un autre patient, critères incohérents, doublons,
SOAP Fault ou résultat incomplet sont refusés. Opération native distincte de la
recherche préalable au remplacement/dépublication ; une recherche par session.

Références : CDT ligne 37 ; SEL-MP-037 v2.10 MCO 2 §3.5.1.1 (EX_3.1-1011,
EX_3.1-1030), §3.5.1.3 ; IHE ITI-18 §3.18.4.1.2.3.7.1
https://profiles.ihe.net/ITI/TF/Volume2/ITI-18.html.
Tests synthétiques : test/dmp_td31a_test.dart et
 tool/document_native_product/FindDocumentsUnit.java. Aucun essai réel exécuté
pendant cette adaptation. Windows non raccordé ; CDT non modifié.


## PRE_CONS_SUB — préparation macOS (29 octobre 2026)

CDT « Phase 1 Prérequis », ligne 38 : recherche avec la date de soumission
comme critère, authentification directe par CPS. Aucun patient spécifique n’est
imposé par cette ligne. Le patient fictif Corinne DUPRE déjà configuré peut être
conservé, avec son accord enregistré et son droit de consultation DV1 valide.

Dans « Recette DMP — accès réel DV1 sans dépôt », utiliser le bloc distinct
« Rechercher par date de dépôt — PRE_CONS_SUB ». Renseigner le premier et le dernier
jour (AAAA-MM-JJ), puis vérifier le patient, la CPS et la période dans le dialogue.
Les deux jours sont inclus dans le fuseau du Mac ; les bornes transmises sont UTC,
début inclus, lendemain du dernier jour exclu. Les transitions d’heure saisonnière
utilisent des jours calendaires. La date clinique du document n’est pas utilisée.
Après recompilation, réenregistrer la configuration sans connexion si Companion
signale le changement du moteur Java.

Après confirmation explicite seulement : TD0.2, contrôle du droit valide et de
l’accord local, FindSubmissionSets avec SubmissionTimeFrom/To, GetAssociations,
filtrage HasMember des lots demandés, GetDocuments LeafClass pour les membres
 documentaires. Aucun contenu n’est téléchargé, aucun droit modifié, aucun dépôt
ou signature de lot. Lots, associations et métadonnées sont contrôlés avant affichage :
INS/autorité, corrélation, statut, intervalle de dépôt et lien avec les lots.
Les mises à jour de statut seules et les membres non documentaires sont ignorés.
Les identifiants sont dédupliqués ; les appels sont répartis en groupes de 1000 lots
et 88 documents au maximum (tailles configurables dans DmpSubmissionSearch).
Un membre non retourné donne un résultat incomplet, sans validation du prérequis.
Un résultat vide ne valide pas non plus le test. Aucune reprise automatique après
une erreur ou l’expiration de la session native de deux minutes.

Les preuves locales td31sub-N-stage-request.xml, -response.xml, -http.txt et result.json
conservent la période UTC, les empreintes de chaque échange, les lots, les dates
de soumission, les documents et les éventuels membres non retournés.
États finaux : submission_search_verified, submission_search_empty,
submission_search_incomplete ; toute erreur interrompt le parcours.

Références : SEL-MP-037 v2.10 MCO 2 §3.5.1.1 EX_3.1-1012 et §3.5.1.3 p.116–117 ;
IHE ITI-18 FindSubmissionSets / GetAssociations / GetDocuments :
https://profiles.ihe.net/ITI/TF/Volume2/ITI-18.html.
Vérifications hors réseau : test/dmp_submission_search_test.dart et
 tool/document_native_product/SubmissionSearchUnit.java (canaux mémoire et identités
synthétiques). Le test réel reste à exécuter après recompilation. Windows reste
à réaliser. Le CDT n’est pas marqué conforme par cette adaptation.
