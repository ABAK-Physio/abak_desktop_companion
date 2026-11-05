# Contrôles documentaires Windows — W3 : socle du service fermé

Base : W2bis `e0b7022`, enregistré sur main après validation Windows :
238 vérifications de politique, 47 d'installation, 366 de pipes, 20 415 natives
W1, 8 tests Flutter réussis (2 tests macOS ignorés) et compilation Debug réussie.
La correction SDDL du test utilise bien `FILE_DELETE_CHILD = 0x40`.

## Livré et volontairement non activé

W3 ajoute un socle portable de lecture des requêtes et de construction des refus,
un hôte SCM minimal compilable séparément, ses tests et un script de validation.
L'unique modification d'un fichier existant est l'ajout du socle à la liste de
compilation du runner. Les sources W1/W2bis, Flutter, DMP et macOS restent intactes.

Le futur service ne peut pas fonctionner à l'issue de W3. Aucun service n'est
installé ou démarré, aucune ACL ou règle WFP n'est modifiée. Ni Java, ni veraPDF,
ni document patient, ni prototype expérimental ne sont utilisés.
Aucune signature payante, autorité de certification ou dépendance externe n'est
introduite. Le contrat d'installation protégée de W2bis est conservé.

## Socle portable : schéma fermé et refus systématique

`document_controls_service_core` expose trois fonctions natives :

| Fonction | Effet |
| --- | --- |
| `ParseRequestMetadata` | Lit seulement le schéma W1 fermé et retourne une requête typée |
| `BuildRefusalReply` | Vérifie forme/longueur puis construit le refus W1 ; ne lance rien |
| `ServiceStartupGate` | Retourne toujours `SERVICE_INSTALLATION_UNQUALIFIED` |

Le lecteur reconnaît les six membres obligatoires `protocol`, `contract`,
`operation`, `requestId`, `timeoutMs`, `input`. L'entrée documentaire exige
exactement `name`, `size`, `sha256`. Les doublons, champs inconnus, membres
manquants, objets/tableaux supplémentaires et types inattendus sont refusés.
L'ordre des membres peut varier ; il ne constitue pas une preuve d'identité.

Le format accepté est le JSON compact produit par `RequestMetadata` de W1 :
aucun espace hors chaînes, BOM, NUL, échappement ou chaîne arbitraire Unicode.
Les chaînes du contrat sont ASCII, de longueur bornée ; les UUID et SHA-256
restent en hexadécimal minuscule. Le lecteur est non récursif. Les nombres sont
des entiers décimaux positifs ou nuls en syntaxe JSON, sans signe, zéro initial
superflu, fraction, exposant ou dépassement de capacité.

Les limites W1 sont réutilisées : métadonnées 64 Kio, document 64 Mio,
`timeoutMs` de 1 à 10 000 pour `version`, de 1 à 240 000 pour `pdfa` et `cda`.
Les opérations restent exclusivement `version`, `pdfa`, `cda`.
`version` exige `input:null` et un corps vide ; PDF/A et CDA exigent respectivement
`document.pdf` ou `document.xml`, une taille positive et un SHA-256 syntaxiquement
valide. La taille du corps doit correspondre à celle du descripteur.

W3 NE vérifie PAS le SHA-256 du contenu et ne parse ni PDF ni XML : toute demande
est refusée, sans prétendre à une vérification du document. Avant toute future
exécution, l'intégration devra recalculer cette empreinte sur sa copie privée.
Le contrôle de `timeoutMs` n'est pas une preuve d'application d'un délai à un
validateur ; aucun validateur n'est exécuté. Les délais de transport restent
ceux de W2bis et devront être raccordés dans une future intégration.

Une requête mal formée retourne une erreur locale et laisse la sortie vide.
La future couche de connexion devra alors fermer la connexion, sans recycler
une réponse précédente. Requête et réponse doivent être deux trames distinctes ;
l'aliasage est refusé explicitement. Aucune information du pair ne peut activer
l'exécution ni fournir un chemin de programme, argument, environnement ou sortie.

Une demande conforme au schéma produit exactement la réponse de refus W1 :
version de protocole, opération et identifiant corrélés, `executed:false`, PID 0,
code de sortie -1, sorties standard/erreur vides, aucun fichier, toutes les
preuves d'isolation fausses et `WINDOWS_ISOLATION_UNAVAILABLE`.
Le succès de `BuildRefusalReply` signifie seulement « refus construit ».
La réponse `version` est comparée octet pour octet à la fixture Dart existante.

Le socle n'authentifie pas le pair. Sa future utilisation sur un vrai pipe devra
être précédée des vérifications W2bis. Les tests du socle ne simulent pas une
identité de service approuvée et ne constituent pas une qualification d'IPC.

## Hôte Windows séparé et arrêt avant toute activité

`windows/document_controls_service/service_main.cpp` porte le nom dédié
`ABAKDocumentControls`. Son point d'entrée n'accepte aucun argument, mode console,
commande d'installation, sonde Java ou option d'activation.

S'il était lancé ultérieurement par le gestionnaire de services, il enregistrerait
le gestionnaire de contrôle, annoncerait START_PENDING, puis STOPPED avec une
erreur spécifique au service. Il n'annonce jamais RUNNING. Tous ses contrôles
acceptés restent à zéro pendant cette initialisation refusée.

Il ne contient ni création de pipe, ni thread de travail, ni processus enfant,
ni appel à l'exécuteur. Même une modification accidentelle du seul garde de
qualification ne lui donnerait pas de chemin d'exécution ou de listener.
Le scénario SCM lui-même n'est pas exécuté dans ce lot.

Le CMake autonome sert uniquement au développement Windows avec Visual C++.
Il n'est pas inclus par le CMake Flutter et ne comporte aucune règle d'installation.
L'hôte n'est pas copié dans le dossier Release de Companion ni ajouté à
l'installateur. Le script de test le compile dans TEMP et NE le lance PAS.

## Tests

`service_core_test.cpp` couvre notamment :

- les trois requêtes produites par le sérialiseur W1 et les allers-retours de trames ;
- le refus exact, ses corrélations et l'absence de toute preuve d'isolation positive ;
- la fixture Dart inchangée, les membres réordonnés et la taille maximale du descripteur ;
- chaque membre obligatoire absent, chaque doublon avec une valeur pourtant valide ;
- commandes/champs d'activation, noms de fichiers libres et valeurs numériques invalides ;
- erreurs de longueur, dépassement de taille, sorties réinitialisées et aliasage ;
- 10 000 entrées hostiles déterministes et chaque préfixe tronqué d'une vraie requête ;
- le garde de démarrage fermé et le client de production W1 toujours indisponible.

Les tests sont exécutés sous Linux avec AddressSanitizer/UBSan. La détection des
fuites est désactivée dans cet environnement car l'inspection /proc des tâches
n'y est pas disponible. Les essais MSVC et le build Flutter restent à confirmer
sur le PC Windows : les résultats Linux ne sont pas présentés comme une validation SCM.

Depuis le terminal PowerShell d'Android Studio, à la racine du dépôt :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\test_document_controls_w3.ps1"
```

Le script localise Visual C++, compile et exécute les tests du socle, compile
seulement l'hôte SCM puis relance les tests W2bis et W1 existants. Aucun commit,
push, service ou validateur n'est lancé. Ensuite :

```powershell
flutter test test/document_windows_contract_test.dart test/document_native_launcher_w1_test.dart
flutter build windows --debug
```

## Qualification encore nécessaire

Le chargeur du manifeste protégé, l'installateur, l'authentification positive
avec le service installé, son vrai cycle de vie et l'isolation des validateurs
ne sont pas intégrés ici. `trusted_installation` reste une précondition native
fermée par défaut, comme documenté dans W2bis. Le refus de production W1 demeure.
L'utilisateur final ne devra configurer manuellement ni Java, services, WFP ou ACL.

## Références Microsoft

- https://learn.microsoft.com/en-us/windows/win32/services/writing-a-servicemain-function
- https://learn.microsoft.com/en-us/windows/win32/api/winsvc/nf-winsvc-setservicestatus
- https://learn.microsoft.com/en-us/windows/win32/api/winsvc/nf-winsvc-startservicectrldispatcherw
