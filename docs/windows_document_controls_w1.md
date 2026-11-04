# Contrôles documentaires Windows — W1

Base examinée : export fourni du commit `e693276062c934a910888b2cc8b68e390a85cedb`.
Les sources exportées sont la référence ; l'export annonce des changements générés
et sept commits locaux supplémentaires par rapport à `origin/main`.

## Périmètre livré

W1 prépare les types, les limites et le cadrage binaire du protocole local.
Le client de production refuse **avant toute ouverture de pipe**. Il ne possède
aucun paramètre, variable d'environnement ou réponse serveur permettant de lever
ce verrou. `ExecuteSecurely()`, `Launch()` et le canal Flutter C++ restent inchangés.
Une garde Windows dans Dart refuse également avant le MethodChannel.

Aucun service, serveur de test, processus Java, règle WFP ou ACL système n'est
créé par ce lot. Les prototypes ne sont ni référencés ni modifiés.
Le code métier DMP, les schémas SQLite, les outils macOS et leurs validations
restent inchangés. Le garde `inspect(): macOS uniquement` reste en place.

Le transport Win32 actif et l'authentification du futur service ne sont pas
implémentés/qualifiés dans ce paquet. W1 ne doit pas être présenté comme une
intégration opérationnelle du service Windows. Les exigences correspondantes
ci-dessous sont obligatoires avant un lot d'activation.

## Protocole local v1

Endpoint réservé : `\\.\pipe\ABAK.DocumentControls.v1`.
Ne jamais utiliser `ABAKDocumentControlsProbe` ni un endpoint expérimental.
Une connexion = une requête + une réponse ; pas de multiplexage ni de reprise
automatique d'une requête dont le résultat est inconnu.

Une trame comporte, dans cet ordre :

| Taille | Contenu |
| --- | --- |
| 4 octets | Longueur de l'en-tête JSON, entier non signé little-endian |
| 8 octets | Longueur du corps binaire, entier non signé little-endian |
| Longueur annoncée | En-tête JSON UTF-8 strict, sans BOM ni NUL |
| Longueur annoncée | Corps binaire |

La longueur du corps est ajoutée au préfixe pour permettre de vérifier ses limites
avant toute allocation. Les longueurs internes du JSON doivent correspondre à ce
préfixe. Le codec C++ vérifie le cadrage et l'UTF-8 ; le consommateur doit ensuite
valider le schéma JSON. La forme compacte réémise par `jsonEncode(jsonDecode(...))`
doit être identique aux octets reçus : pas de clés dupliquées, espaces décoratifs
ou écritures alternatives de nombres/chaînes. L'ordre des propriétés reste libre.
Une trame correctement cadrée n'est jamais une preuve d'autorisation.

### Requête

Champs exacts : `protocol`, `contract`, `operation`, `requestId`, `timeoutMs`, `input`.

- `protocol` : entier `1` ; `contract` : `ABAK-WINDOWS-CONTROLS-1`.
- `operation` : exclusivement `pdfa`, `version`, `cda`, casse exacte.
- `requestId` : UUID en minuscules, unique à chaque tentative.
- `timeoutMs` : délai demandé positif, inférieur au plafond de l'opération.
- `input` : `null` pour `version`, sinon `{name,size,sha256}`.
- Nom logique imposé : `document.pdf` ou `document.xml` suivant l'opération.
- Empreinte SHA-256 : 64 caractères hexadécimaux minuscules.
- Corps : octets du document, taille identique à `input.size`. Le service devra
  recalculer l'empreinte avant tout traitement et utiliser sa copie privée figée.

Les profils sont fixés par l'installation : PDF/A-1b, et les cinq profils CDA
actuels. Aucun chemin Java/JAR/référentiel, argument libre, répertoire de sortie,
variable d'environnement ou réglage d'isolation n'est accepté dans la requête.

### Réponse W1 et compatibilité Flutter

Champs exacts : `protocol`, `contract`, `operation`, `requestId`, `executed`, `pid`,
`exitCode`, `stdoutLength`, `stderrLength`, `files`, `input`, `truncated`, `error`,
`isolation`. Les identifiants et l'opération doivent correspondre à la requête.

En W1 : `executed=false`, `pid=0`, `exitCode=-1`, sorties et corps vides,
`files=[]`, `input=null`, `truncated=false`, erreur structurée
`{code:WINDOWS_ISOLATION_UNAVAILABLE,message:...}`. Les six preuves d'isolation
sont `false`, jamais réputées vérifiées par défaut.

Le décodeur Dart W1 ne construit qu'un `WindowsDocumentControlRefusal`.
Une réponse annonçant un succès ou une isolation qualifiée est rejetée.
Ce format interne est distinct du contrat MethodChannel macOS, conservé tel quel
avec `protocol`, `pid`, `exitCode`, `stdout`, `stderr`, `files`, `isolation`.

Pour le futur lot d'exécution, le corps contiendra stdout, stderr puis les rapports
dans l'ordre du manifeste. Le manifeste `files` décrira nom logique, longueur et
SHA-256 ; chaque nom sera choisi dans la liste actuelle de `cdaFiles`.
Les rapports obligatoires seront `completed.txt`, `xsd.xml`, `profile-0.xml` à
`profile-4.xml`, et facultativement `xsd-error.txt`. Ils seront tous liés au même
document, à la même opération et au même jeu de références.
L'adaptateur fournira ensuite les chaînes stdout/stderr et les fichiers attendus
par Flutter. Ce décodage de succès et son écriture de fichiers restent absents de W1.

Le chemin privé du PDF peut différer du chemin inscrit dans le rapport veraPDF.
Le lot d'exécution devra définir une corrélation Windows fondée sur les octets
figés, la taille et l'empreinte ; il ne devra pas retirer la vérification macOS
existante sur le nom du fichier ou réécrire un rapport pour le faire accepter.

## Authentification et autorisations à intégrer ultérieurement

Le nom du pipe, le compte utilisateur et les propriétés JSON ne constituent pas
une authentification suffisante. Une ACL autorisant le compte est un premier filtre.

1. Le service crée son premier pipe avec `FILE_FLAG_FIRST_PIPE_INSTANCE` et
   `PIPE_REJECT_REMOTE_CLIENTS`, et une DACL explicite. Les clients n'obtiennent
   jamais `FILE_CREATE_PIPE_INSTANCE`, WRITE_DAC, WRITE_OWNER ou des droits
   génériques incluant ces permissions. Refuser anonymes et accès réseau.
2. Companion obtient le PID du serveur via `GetNamedPipeServerProcessId`, le
   compare au PID du service dédié indiqué par `QueryServiceStatusEx`, et vérifie
   le jeton attendu (LocalService + SID propre au service), le binaire installé
   et son identité signée approuvée. Garder un handle au processus et revérifier
   les correspondances pour éviter une réutilisation de PID.
3. Le service identifie le client depuis le pipe avec
   `GetNamedPipeClientProcessId` et le jeton de la connexion ; vérifier utilisateur,
   session autorisée et binaire Companion installé/signé approuvé. Toute erreur
   d'impersonation entraîne un refus, avec retour garanti à l'identité du service.
   Le PID/compte transmis dans une requête ne fait jamais autorité.
4. La signature doit correspondre à l'identité ABAK autorisée et à un manifeste
   d'installation protégé : « signé par quelqu'un » n'est pas suffisant.
   Les binaires et leur chaîne de chargement ne doivent pas être modifiables par
   l'utilisateur standard. Pas de secret partagé stocké dans son profil et réputé
   inaccessible à ses autres processus. Un nom aléatoire ou un nonce ne remplace
   pas cette authentification.
5. Une signature sur disque ne prouve pas l'intégrité d'un processus compromis
   en mémoire. Le modèle de menace et les mesures retenues contre l'injection
   devront être qualifiés. L'IPC n'autorisera que des opérations fermées sur des
   octets non fiables, jamais un accès arbitraire avec les droits du service.

Ces contrôles ne sont pas encore implémentés ; aucune réponse serveur ne les
simule en W1. Le futur installateur prendra en charge le service et ses droits.
L'utilisateur final ne configurera ni Java, ni services, ni WFP, ni ACL.

Références Microsoft :

- https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createnamedpipea
- https://learn.microsoft.com/en-us/windows/win32/ipc/named-pipe-security-and-access-rights
- https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getnamedpipeserverprocessid
- https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getnamedpipeclientprocessid
- https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-winverifytrust

## Limites et erreurs

| Ressource | Limite |
| --- | --- |
| En-tête | 1 à 65 536 octets |
| Document | 1 à 67 108 864 octets ; absent pour `version` |
| Sorties + rapports cumulés | 12 582 912 octets |
| Connexion future | 2 secondes |
| Échange sans progression futur | 5 secondes |
| Exécution future | 10 secondes pour `version`, 240 secondes pour PDF/A/CDA |
| Transaction future | Délai demandé plafonné + 10 secondes, incluant le transfert |
| Concurrence future | Une opération ; refus explicite si occupé |

Les délais sont mesurés sur une horloge monotone et couvrent les lectures/écritures
partielles. Ils ne doivent pas se réinitialiser à chaque fragment reçu. La limite
globale empêche un pair de maintenir indéfiniment une connexion lente.
Le futur transport devra utiliser des E/S overlapped annulables et libérer tous
les handles ; un timeout du client ne prouve pas l'arrêt du validateur. Le service
devra interrompre le Job Object et surveiller les protections pendant l'exécution.

Erreurs W1 : `INVALID_ARGUMENTS`, `INVALID_OPERATION`, `INVALID_REQUEST_ID`,
`INVALID_TIMEOUT`, `INVALID_INPUT`, `PROTOCOL_MISMATCH`, `INVALID_FRAME`,
`INVALID_FRAME_SIZE`, `INVALID_METADATA`, `PAYLOAD_LIMIT_EXCEEDED`, et le refus
`WINDOWS_ISOLATION_UNAVAILABLE`. Toute erreur entraîne l'absence de résultat.

Le lot de transport actif devra ajouter les cas service absent/occupé, identité
refusée, accès refusé, pipe interrompu, délai dépassé et sortie excessive. Une
troncature ne devra jamais devenir un contrôle conforme ou un rapport exploitable.

## Vérifications

Les tests C++ portables couvrent les limites, le little-endian, l'UTF-8, les trames
incomplètes, les octets supplémentaires, 10 000 entrées hostiles déterministes et
le refus du client. Ils produisent une fixture consommée par les tests Dart.

Sous Windows, depuis Developer PowerShell de Visual Studio :

```powershell
.\scripts\test_document_controls_w1.ps1
flutter test test/document_windows_contract_test.dart test/document_native_launcher_w1_test.dart
flutter build windows --debug
```

Le test natif Windows vérifie aussi l'exécuteur et le lanceur réels avec des
requêtes qui sont refusées avant tout lancement. Les tests Flutter simulent le
MethodChannel ; ils n'utilisent ni Java ni documents patients.
Sur macOS, lancer les deux tests Flutter pour exercer les validations XPC simulées.
Ils vérifient les mêmes garanties et le même format de preuve, sans appeler XPC.

La compilation et l'exécution sur Windows, ainsi que les tests Flutter, restent
nécessaires : les outils correspondants sont absents de l'environnement de préparation.
Les tests d'identité, de pipe actif, d'ACL IPC et de perte de protection sont à
ajouter lors de l'intégration réelle ; ils ne sont pas annoncés comme couverts ici.
