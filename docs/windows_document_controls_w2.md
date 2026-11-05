# Contrôles documentaires Windows — W2 révisé sans signature

Base : W1 `277f8a6`, puis W2 `8aa190f`, validés sur le PC Windows.
Cette révision incrémentale remplace l'exigence Authenticode de W2. Elle ne
contient aucun élément du brouillon W3 et n'active aucun contrôle documentaire.

## Décision et portée

ABAK Companion doit fonctionner sans signature payante, abonnement, service
cloud ni certificat à renouveler. Le chemin d'identification Windows ne vérifie
plus Authenticode et ne dépend plus de WinTrust. La signature n'est ni une
condition d'autorisation, ni un mode optionnel avec repli silencieux.
Cette décision remplace les exigences d'identité signée de la section
« Authentification et autorisations » du document W1. Les validations macOS
restent inchangées.

La confiance porte sur une installation locale approuvée : identité Windows,
chemin exact, empreinte de version et permissions effectives des fichiers et de
leurs répertoires parents. Le même compte utilisateur ne suffit jamais.
L'empreinte n'authentifie pas l'éditeur d'un téléchargement.

W2 reste une préparation : ses modules sont compilés dans le runner mais ne sont
pas raccordés au chemin de production. `Exchange()`, le garde Dart, le canal,
le lanceur et l'exécuteur W1 refusent toujours avec
`WINDOWS_ISOLATION_UNAVAILABLE`. Aucun réglage ne permet d'activer les validateurs.

Aucun fichier macOS ou métier DMP n'est modifié. Aucun service n'est installé ou
démarré ; Java, veraPDF et les prototypes ne sont pas lancés. Aucune règle WFP,
ACL de fichier, de dossier, de service ou configuration système n'est modifiée.
Les descripteurs des tests sont construits en mémoire, ou appartiennent à leurs
propres pipes éphémères. Aucun document patient n'est utilisé.

## Transport conservé

- Named Pipes `\\.\pipe\ABAK.DocumentControls.*` uniquement, sans HTTP ni port réseau.
- Rejet des noms UNC distants et des autres familles avant ouverture.
- Attente d'une instance occupée plafonnée à deux secondes.
- E/S overlapped, lectures/écritures fragmentées et transferts partiels.
- Contrôle des longueurs W1 avant allocation, UTF-8 strict et aucun résultat partiel.
- Budget monotone global et délai sans progression : quelques octets ne prolongent
  jamais le délai global.
- Annulation par `CancelIoEx`, suivie de l'attente de fin effective de l'E/S avant
  libération des ressources. Handles non héritables, gérés par RAII.
- Les tests créent des pipes avec `PIPE_REJECT_REMOTE_CLIENTS` et
  `FILE_FLAG_FIRST_PIPE_INSTANCE`. Ces flags devront aussi être utilisés par le
  futur service ; les tests locaux ne valent pas essai depuis un autre poste.

Ces primitives bas niveau ne donnent aucune autorisation d'exécution.

## Politique d'identité révisée

`PeerPolicy`, alimentée exclusivement par du code natif de confiance, conserve :

| Champ | Origine requise |
| --- | --- |
| Rôle Companion ou service | Code natif |
| Compte et session autorisés | Contexte Windows autorisé |
| Chemin canonique exact de l'image | Installation approuvée |
| SHA-256 exact de l'image | Manifeste de version protégé |
| Nom et SID du service dédié | Installation du futur service |

Les champs du certificat et le fait `signature_valid` sont supprimés.
`PeerFacts.installation_protected`, faux par défaut, provient de l'inspection
native du fichier et de ses parents ; il n'est jamais accepté depuis le pair.
Les faits des tests portables sont synthétiques, sans prétention de preuve native.

Le service attendu reste un processus dédié `ABAKDocumentControls`, sous
LocalService (`S-1-5-19`), session 0, avec son SID de service activé et un PID
correspondant au service en cours d'exécution dans le gestionnaire de services.
LocalSystem et le prototype `ABAKDocumentControlsProbe` restent refusés.

## Vérification en lecture seule de l'installation

`document_controls_installation_security` inspecte le fichier déjà ouvert et
chaque répertoire parent jusqu'à la racine du lecteur fixe local :

1. Fichier ordinaire, répertoires ordinaires, aucun reparse point, chemin final
   identique au chemin inspecté ; lecteurs distants ou amovibles refusés.
2. Lecture du propriétaire et de la DACL avec `GetSecurityInfo` : propriétaire
   SYSTEM, groupe Administrateurs ou identité Windows TrustedInstaller seulement.
3. Refus d'une DACL absente/nulle ou d'une ACE effective non prise en charge.
   Les permissions d'écriture, suppression, changement de DACL ou propriétaire
   ne peuvent être accordées qu'à ces trois identités de confiance.
4. Les ACE inherit-only ne s'appliquent pas à l'objet inspecté. Le contrôle est
   conservateur : une ACE de refus n'excuse pas une autorisation d'écriture.
5. À la racine du volume, créer un autre enfant est admis, mais supprimer des
   enfants ou changer les protections est interdit aux autres identités.
   Dans les autres répertoires, créer des fichiers ou sous-répertoires est aussi
   interdit, notamment pour limiter le dépôt de DLL.
6. Les handles des parents sont conservés sans partage de suppression ; ceux de
   l'image interdisent le partage d'écriture/suppression pendant l'échange.
   Les protections sont revérifiées sur les handles conservés.

L'inspection est limitée à 64 ancêtres. Une erreur de lecture, un propriétaire
individuel ou des permissions atypiques provoquent un refus explicite
`PEER_INSTALLATION_REJECTED`, jamais une réparation automatique des ACL.
Le futur installateur devra produire les droits attendus sur ses propres objets,
normalement sous Program Files. Le nom du répertoire seul n'est pas une preuve.

## Origine du manifeste : précondition encore fermée

`trusted_installation` dans la politique reste faux par défaut. Il signifie que
le futur chargeur natif a obtenu les chemins et empreintes depuis un manifeste
approuvé et protégé. Ce lot NE fournit ni ce chargeur, ni un manifeste installable,
ni l'installateur. L'inspection de l'image ne remplace pas cette précondition.

Le futur chargeur devra ouvrir le manifeste en lecture sans partage
écriture/suppression, vérifier son chemin attendu, son propriétaire et ses
permissions et ceux de ses parents AVANT de le parser, puis conserver son handle
pendant la construction de la politique. `VerifyProtectedFile` est réutilisable
pour cette vérification. L'installateur de confiance devra déposer ensemble le
manifeste et la version correspondante, puis les actualiser à chaque mise à jour.
Une préférence, une variable d'environnement, le JSON du pair ou un recalcul des
empreintes d'un dossier utilisateur ne sont jamais une source de confiance.

L'origine du téléchargement et la décision d'exécuter l'installateur restent une
étape de confiance distincte. Ce lot ne la remplace pas par une certification
publique de l'éditeur. Aucune configuration n'est demandée au kiné par l'application.

## Inspection du processus et handshake conservés

Le PID vient de Windows, pas du JSON. Le processus est conservé ouvert, le compte
et la session viennent de son jeton. Le chemin final et le SHA-256 de l'image
ouverte doivent correspondre exactement à la politique. L'image est plafonnée
à 64 Mio. Le client vérifie le service avant d'envoyer le préambule `ABAKIPC1`.
Le serveur lit ce préambule fixe puis vérifie le client et l'identité de la
connexion par impersonation limitée à l'identification. Il restaure toujours son
jeton ; un échec de restauration provoque un arrêt immédiat.

L'acquittement n'est envoyé qu'après autorisation. `PeerLease` conserve processus,
image et parents pendant l'échange. `RecheckPipePeer` revalide PID, processus,
permissions et rattachement au service. Il doit être appelé avant une requête et
avant acceptation d'un résultat lors de la future intégration.
Le contrat conserve uniquement `pdfa`, `version`, `cda` et les limites W1.

## Limites et étapes suivantes

Ni une empreinte disque ni la signature antérieure ne prouvent l'intégrité du
processus en mémoire. L'injection, la duplication de handles et l'intégrité des
DLL ne sont pas qualifiées par ce lot. Un administrateur compromis est hors du
modèle retenu pour cette installation locale. L'exécution réelle nécessitera
encore la qualification de l'isolation réseau/fichiers et du cycle de vie du
validateur. Un service LocalService, à lui seul, n'est pas une sandbox.

Les appels synchrones d'inspection Windows ne sont pas préemptés par le budget
E/S ; le délai est vérifié après inspection. Aucun délai dur d'authentification
n'est annoncé. L'autorisation positive d'un Companion installé communiquant avec
le vrai service n'est pas encore qualifiée.

## Tests et validation

- Politique portable : acceptation d'une installation correspondante sans champ
  de signature ; refus si installation non protégée, manifeste non approuvé,
  compte/session/processus différents, fichier modifié, copie déplacée ou service
  incorrect. Vérifications des délais et du verrou W1 conservées.
- Windows : descripteurs en mémoire pour propriétaires, droits génériques,
  suppressions, DACL, héritage et identité LocalService. Inspection en lecture
  seule de `kernel32.dll` existant et de ses parents pour exercer le parcours natif.
- Pipes Windows : fragmentation, limites, annulation, déconnexion, instances,
  PID et handles conservés. Un exécutable de test dans TEMP, pourtant épinglé par
  son empreinte exacte, est refusé pour installation non protégée ; le jeton est
  restauré. Ce refus n'est plus lié à l'absence de signature.

Préparation sous Linux : les tests portables sont exécutables ici. Les essais
Win32, MSVC, Flutter et la compilation de l'application doivent être confirmés
sur le PC Windows ; ils ne sont pas annoncés comme exécutés sous Linux.

Depuis la racine du dépôt dans le terminal PowerShell d'Android Studio :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\test_document_controls_w2.ps1"
flutter test test/document_windows_contract_test.dart test/document_native_launcher_w1_test.dart
flutter build windows --debug
```

Le script localise Visual C++, compile dans TEMP puis relance les tests W1 du
véritable exécuteur/lanceur. Aucun commit, push ou réglage système n'est effectué.

## Références Microsoft

- https://learn.microsoft.com/en-us/windows/win32/ipc/named-pipe-security-and-access-rights
- https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createnamedpipea
- https://learn.microsoft.com/en-us/windows/win32/api/ioapiset/nf-ioapiset-cancelioex
- https://learn.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-impersonatenamedpipeclient
- https://learn.microsoft.com/en-us/windows/win32/api/aclapi/nf-aclapi-getsecurityinfo
- https://learn.microsoft.com/en-us/windows/win32/fileio/file-security-and-access-rights
- https://learn.microsoft.com/en-us/windows/win32/fileio/reparse-points-and-file-operations
