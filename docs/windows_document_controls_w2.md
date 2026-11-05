# Contrôles documentaires Windows — W2

Base : fichiers W1 validés sur le PC Windows et commités sous `277f8a6`.
W1 : 8 tests Flutter réussis, 2 tests macOS ignorés sur Windows, compilation Debug
réussie, 20 415 vérifications C++ réussies sans exécuter de validateur.

## Périmètre

W2 ajoute les briques natives de transport Named Pipe et de vérification des
identités. Elles sont compilées dans le runner mais ne sont pas raccordées au
chemin d'exécution de Companion. Le client `Exchange()`, le garde Dart et les
canal/lanceur/exécuteur C++ de W1 restent inchangés et refusent toujours avec
`WINDOWS_ISOLATION_UNAVAILABLE`.

Les seuls échanges actifs de ce lot ont lieu dans l'exécutable de test. Celui-ci
crée des pipes temporaires et utilise ses propres threads : aucun service Windows
n'est installé ou démarré. Il n'utilise ni Java, ni veraPDF, ni document patient,
ni prototype expérimental. Aucun fichier métier DMP ou code macOS n'est modifié.
Il n'existe aucun réglage permettant d'activer les validateurs.

Les ACL de fichiers, dossiers et services existants ainsi que WFP ne sont pas
modifiées. Le test crée uniquement le descripteur de sécurité de son propre pipe
éphémère, supprimé à la fermeture des handles.

## Transport

`document_controls_pipe_transport` fournit ouverture locale, connexion,
lecture/écriture exacte et échange de trames au format W1.

- Noms locaux `\\.\pipe\ABAK.DocumentControls.*` uniquement ; rejet des chemins
  UNC distants et des autres familles de pipes avant tout appel d'ouverture.
- Instance occupée : attente plafonnée à deux secondes, sans retry illimité.
- E/S overlapped, lecture/écriture fragmentée et gestion des transferts partiels.
- Vérification des deux longueurs du préfixe avant allocation du corps.
- Trame incomplète, UTF-8 incorrect, dépassement et déconnexion : aucun résultat
  partiel exploitable n'est retourné.
- Budget monotone : délai global fixe et délai plus court sans progression.
  Recevoir quelques octets supplémentaires ne prolonge pas le délai global.
- À l'expiration, `CancelIoEx` demande l'annulation et le code attend la fin
  effective de l'E/S avant de libérer buffer, événement et structure OVERLAPPED.
  Le test vérifie aussi qu'une lecture annulée ne consomme pas la trame suivante.
- Les handles sont non héritables et gérés par RAII.
- Le client demande les droits élémentaires de lecture/écriture, sans demander
  le droit `FILE_CREATE_PIPE_INSTANCE`. Le test crée son pipe avec
  `PIPE_REJECT_REMOTE_CLIENTS` et `FILE_FLAG_FIRST_PIPE_INSTANCE`.

Les fonctions de transport bas niveau ne constituent pas une autorisation.
Une future intégration ne devra les appeler pour les documents qu'après un
handshake d'identité réussi et une nouvelle vérification du pair.

## Politique d'identité

`document_controls_peer_policy` valide une politique native contenant :

| Champ | Origine requise |
| --- | --- |
| Rôle service ou Companion | Code natif |
| Compte et session autorisés | Installation et contexte Windows autorisé |
| Chemin canonique de l'exécutable | Installation protégée |
| SHA-256 exact de l'exécutable | Manifeste de version approuvé et protégé |
| SHA-256 du certificat signataire | Identité de publication approuvée |
| Nom/SID du service dédié | Installation du futur service |

Une politique vide, incomplète ou sans installation réputée protégée est refusée.
`trusted_installation` est une précondition native, pas une preuve collectée par
W2 : aucune API de ce lot ne qualifie automatiquement les protections de
l'installation. Sa valeur par défaut est `false` et elle ne doit jamais venir
d'un message JSON, de l'environnement ou d'un fichier utilisateur modifiable.

Le futur intégrateur devra établir cette précondition par une installation
protégée et un manifeste authentifié. Aucun tel manifeste n'est distribué ou
accepté automatiquement dans W2. Une réponse serveur ne peut pas le remplacer.

Le service attendu sera un processus dédié `ABAKDocumentControls`, sous
LocalService (`S-1-5-19`), session 0, avec son propre SID activé dans le jeton.
`ABAKDocumentControlsProbe` et LocalSystem ne sont pas des substitutions acceptées.
Le client Companion attendu est lié à un compte et une session interactive
autorisés, ainsi qu'à la version signée approuvée de son exécutable.

## Vérification native et handshake

`document_controls_peer_identity` collecte les informations depuis Windows :

1. Le PID provient de `GetNamedPipeServerProcessId` ou
   `GetNamedPipeClientProcessId`, jamais du JSON du pair.
2. Le handle du processus est conservé. Le compte et la session viennent de son
   jeton ; son image est ouverte en lecture sans partage écriture/suppression.
3. L'image doit être un fichier ordinaire, sans reparse point sur le fichier.
   Son chemin final, son SHA-256 et sa signature Authenticode sont vérifiés.
4. L'empreinte SHA-256 du certificat signataire est extraite de la chaîne validée
   et doit correspondre à l'empreinte approuvée. Une signature valide quelconque
   ou le seul nom de l'éditeur ne suffit pas.
5. Pour le service, le PID doit aussi correspondre à celui du service dédié en
   cours d'exécution, d'après le gestionnaire de services. Le SID du service doit
   être activé et ne pas être présent uniquement comme SID de refus.

Le client authentifie d'abord le service avant d'envoyer quoi que ce soit.
Il envoie ensuite le préambule fixe de huit octets `ABAKIPC1`. Le serveur lit ce
préambule borné, puis vérifie le client, y compris le jeton de la connexion par
impersonation limitée à l'identification. Ce jeton doit être cohérent avec celui
du processus. Il revient à son identité initiale sur tous les retours ; un échec
de restauration provoque un arrêt immédiat du processus au lieu de poursuivre
sous une identité inattendue.

Le serveur n'envoie le même acquittement qu'après cette vérification. Les PID,
handles et rattachement au service sont revérifiés avant de retourner une
`PeerLease`. Celle-ci conserve le processus et l'image ouverts jusqu'à la fin de
l'échange. L'intégration devra également appeler `RecheckPipePeer` avant l'envoi
d'une requête et avant d'accepter son résultat.

Le préambule et son acquittement ne sont pas de nouvelles opérations documentaires
et n'accordent aucun droit d'exécution. Il n'existe toujours que `pdfa`, `version`
et `cda` dans le contrat documentaire. Aucun chemin de document ou d'exécutable,
argument Java ou commande système n'est échangé pendant le handshake.

La vérification Authenticode est sans interface et avec récupération de chaîne
limitée au cache. W2 ne prouve pas une fraîcheur de révocation en ligne. Une
politique de révocation qualifiée et la gestion des rotations de certificats
devront être définies avant l'installation réelle.

## Limites de la vérification

Le SHA-256 est calculé sur l'image ouverte, plafonnée à 64 Mio. Le handle empêche
son écriture/suppression pendant l'échange, mais ne démontre pas l'intégrité du
processus en mémoire ni de ses DLL. Les jonctions des répertoires parents, les
droits de l'installation, la substitution avant inspection, l'injection et la
duplication de handles doivent rester dans le modèle de menace à qualifier.
Le seul compte utilisateur ne doit donc jamais être traité comme une frontière
de confiance entre applications.

Les appels synchrones d'inspection Windows, notamment Authenticode, ne sont pas
préemptés par le budget d'E/S : l'expiration est contrôlée avant les échanges et
après inspection. W2 ne démontre pas une limite dure sur l'authentification.
L'exécution de validateurs exige encore les protections et délais propres au
futur service ; elle n'est pas autorisée par une `PeerLease`.

## Tests

Les tests portables de politique utilisent des **faits synthétiques**. Ils
vérifient acceptation du modèle complet, refus des comptes/sessions/images/
signataires différents, refus de LocalService seul, du prototype et d'une
installation non qualifiée, ainsi que le budget monotone et les débordements.
Ils ne constituent pas un essai d'authentification positive d'un service signé.

Les tests Windows utilisent uniquement un pipe éphémère entre threads du même
exécutable, avec SID et PID obtenus depuis le noyau. Ils couvrent :

- Aller-retour d'une requête de version et de la réponse de refus W1.
- Trame avec corps binaire synthétique, fragmentée en petits morceaux.
- Expiration, annulation puis réutilisation correcte du pipe, et déconnexion.
- Préfixe annonçant un corps excessif : refus avant allocation.
- Politique absente : refus avant inspection.
- Exécutable de test non signé : refus malgré le même utilisateur et une
  empreinte de fichier exacte ; restauration du jeton du thread après refus.
- Préambule invalide, noms distants interdits, collision de première instance,
  instance occupée et libération des handles après vingt connexions.

La signature d'une version installée approuvée et l'authentification positive des
deux côtés restent à tester avec de véritables binaires de release signés et le
futur service. L'accès d'un autre utilisateur et les clients réseau ne sont pas
testés par ces essais locaux. Les flags de rejet ne valent pas qualification.

## Commandes de validation sur Windows

Depuis le terminal PowerShell d'Android Studio :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\test_document_controls_w2.ps1"
flutter test test/document_windows_contract_test.dart test/document_native_launcher_w1_test.dart
flutter build windows --debug
```

Le premier script retrouve automatiquement les outils C++ déjà installés, compile
les tests W2 dans TEMP puis relance le test W1 du véritable exécuteur/lanceur.
Il ne fait aucun commit/push et ne modifie aucun service ou réglage système.

Les tests portables ont été exécutés pendant la préparation sous Linux. Les
nouveaux tests Win32 et la compilation MSVC doivent être exécutés sur le PC
Windows ; ils ne sont pas annoncés comme validés avant leurs résultats.

## Références Microsoft

- https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createnamedpipea
- https://learn.microsoft.com/en-us/windows/win32/api/ioapiset/nf-ioapiset-cancelioex
- https://learn.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-impersonatenamedpipeclient
- https://learn.microsoft.com/en-us/windows/win32/ipc/named-pipe-security-and-access-rights
- https://learn.microsoft.com/en-us/windows/win32/api/wintrust/ns-wintrust-wintrust_data
- https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-wthelperprovdatafromstatedata
- https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-wthelpergetprovsignerfromchain
