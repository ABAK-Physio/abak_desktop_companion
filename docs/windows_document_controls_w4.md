# Contrôles documentaires Windows — W4 : manifeste protégé

Base : W3 `2ba72f2`, validé sur Windows (socle 41 123, politique 238,
installation 47, pipes 366 et W1 20 415 vérifications ; tests Flutter et build
Debug réussis). Aucun service n'a été démarré lors de ces validations.

## Portée

W4 ajoute le schéma du manifeste, son chargeur natif en lecture seule et les
fabriques de politiques d'identité. Deux sources sont ajoutées au runner.
Le code existant W1/W2bis/W3 reste inchangé. Les gardes Dart, `Exchange()`,
le lanceur/exécuteur et `ServiceStartupGate()` restent fermés.

Le chargeur est compilé mais n'est appelé ni par Flutter ni par l'hôte SCM W3.
Le service, l'installateur et les validateurs ne sont pas activés. Ce lot ne
modifie aucune ACL, règle WFP, configuration système ou prototype, et n'introduit
aucune signature, abonnement, dépendance externe ou commande utilisateur Java.

## Manifeste fermé

Le nom est fixé dans le code : `document_controls_installation.json`, à côté
de l'image courante approuvée. Les fichiers adjacents attendus sont exclusivement
`abak_desktop_companion.exe` et `ABAKDocumentControls.exe`.
Le manifeste ne peut modifier ni ces noms, ni les répertoires ou commandes.

| Membre obligatoire | Valeur ou type |
| --- | --- |
| `manifestVersion` | entier 1 |
| `protocol` | entier 1 |
| `contract` | `ABAK-WINDOWS-CONTROLS-1` |
| `companionSha256` | empreinte SHA-256 exacte, 64 caractères hexadécimaux minuscules |
| `serviceSha256` | empreinte SHA-256 exacte, même syntaxe |
| `allowedUsers` | liste de 1 à 16 SID de comptes, sans doublon |

Le fichier est limité à 8 Kio. Le JSON accepte les espaces, tabulations et fins
de ligne hors chaînes, et tout ordre des membres. BOM, NUL, échappements,
chaînes non ASCII, membres manquants/inconnus/dupliqués, types alternatifs et
entiers avec signe, fraction, exposant, zéro initial superflu ou dépassement
sont refusés. Les chaînes sont bornées à 184 caractères, sans récursion libre.

Les comptes sont représentés par la forme canonique Windows locale/domaine
`S-1-5-21-a-b-c-rid`, ou Entra `S-1-12-1-a-b-c-d`, avec quatre composantes
uint32 sans zéro initial superflu. Les groupes intégrés, Everyone, comptes
système et SID de service ne sont pas des entrées autorisées. La comparaison
porte exactement sur le SID TokenUser du client, jamais sur son appartenance
à un groupe. Le futur installateur devra collecter de vrais SID de comptes ;
le lecteur syntaxique n'effectue pas d'annuaire ni de résolution de noms.

`InstallationManifest` ne contient que des données parsées. Un appel réussi à
`ParseInstallationManifest` ou `ManifestListsUser` ne constitue PAS une
preuve de confiance et ne peut pas créer un `InstalledControls` valide.
Les données de sortie sont réinitialisées sur erreur.

## Chargement natif ancré sur le processus

`LoadInstalledControls` n'accepte aucun chemin, manifeste déjà parsé, empreinte
attendue ou booléen de confiance fourni par l'appelant. Il procède ainsi :

1. Obtenir l'image du processus courant via `QueryFullProcessImageNameW`, ouvrir
   cette image en lecture, résoudre son chemin final et vérifier son nom fixe.
2. Vérifier ses permissions et tous ses parents avec W2bis avant de chercher le
   manifeste. Un binaire simplement renommé dans TEMP reste refusé.
3. Ouvrir le manifeste adjacent attendu, sans partage écriture/suppression ;
   vérifier fichier et parents AVANT de lire et parser son contenu.
4. Ouvrir les deux images adjacentes, vérifier aussi leurs permissions et leurs
   parents, puis comparer leurs SHA-256 aux valeurs du manifeste protégé.
   Les empreintes attendues ne sont jamais recalculées pour approuver les fichiers.
5. Comparer l'identité de fichier de l'image courante à celle de l'image épinglée.
6. Demander à Windows le SID du seul service `NT SERVICE\ABAKDocumentControls`.
   Une résolution indisponible ou une autorité différente entraîne un refus.
   Cette résolution n'installe et ne démarre aucun service ; elle ne démontre
   pas qu'un processus de service est en cours d'exécution.
7. Revalider les protections et retourner un objet propriétaire des handles.

Les règles W2bis sont réutilisées : lecteur fixe local, pas de reparse point,
propriétaire et droits de modification réservés à SYSTEM, Administrateurs ou
TrustedInstaller, inspection des parents, images plafonnées à 64 Mio.
L'absence de fichier, une permission non qualifiée ou une empreinte différente
provoquent un refus ; aucune réparation ou génération automatique n'est tentée.

`InstalledControls` est non copiable, déplaçable, et ne possède aucun setter
public. Seule la fabrique native peut remplir ses données privées. Les objets
vides ou déplacés refusent. Il conserve manifeste, images et parents ouverts,
puis `Recheck()` revalide les protections avant chaque construction de politique.
Les objets doivent être libérés avant une mise à jour de ces fichiers.

## Politiques produites

`ServicePolicy` fixe rôle service, LocalService, session 0, nom dédié, SID résolu
par Windows, chemin et empreinte du service. `CompanionPolicyForPipe` relève le
PID du client sur le pipe serveur, puis compte et session dans le jeton de son
processus. Elle exige un compte listé et une session non nulle, et fixe le chemin
et l'empreinte de Companion. Les sorties sont vidées avant tout échec.

Ces fabriques n'authentifient pas, à elles seules, la connexion. La future
intégration doit encore utiliser `AuthenticatePipePeer` et `RecheckPipePeer`
W2bis : jeton réel du pipe, image du pair, processus retenu ouvert, SID et PID
rattachés au service dans SCM. Une identité déclarée dans du JSON ne les remplace pas.
`trusted_installation=true` ne doit être obtenu en production que par ces
fabriques, après chargement réussi ; les faits synthétiques des tests restent
explicitement des modèles.

## Installation et qualification encore nécessaires

Aucun manifeste utilisable n'est déposé par W4. Le futur installateur de
confiance devra le produire après les builds des deux images, déposer les trois
fichiers avec des protections qualifiées et actualiser leurs empreintes ensemble.
Il devra identifier le compte interactif autorisé, sans confondre ce compte avec
celui éventuellement utilisé pour l'élévation administrative de l'installation.
Le kiné ne configurera ni SID, Java, services, WFP ou ACL à la main.

La protection locale du manifeste ne certifie pas l'éditeur du téléchargement
et ne garantit pas l'intégrité du processus ou des DLL en mémoire. Le modèle
reste celui d'un poste sain, sans administrateur compromis. Les inspections et
résolutions Windows synchrones n'ont pas de délai dur qualifié par W4.

Le chargement positif d'une véritable installation, la production des politiques
avec cette installation et l'authentification d'un service installé restent à
qualifier. Le service et les validateurs ne deviennent pas opérationnels par le
seul ajout du chargeur ; `WINDOWS_ISOLATION_UNAVAILABLE` reste le résultat public.

## Tests et commandes

- Tests portables : schéma complet, variations d'ordre/espaces, limites,
  empreintes, comptes et doublons, chaque membre obligatoire absent ou répété,
  champs d'activation et chemins libres, troncatures et 10 000 entrées hostiles.
  Vérification que les gardes W1/W3 restent fermés.
- Tests Windows : objets non chargés/non copiables, déplacement à vide, absence
  de politique résiduelle après refus et libération des handles après échecs.
  Le binaire DE TEST est compilé sous le nom de Companion dans un dossier TEMP
  privé pour vérifier qu'un nom correct ne suffit pas à établir la confiance.
  Ce binaire n'est ni l'application Flutter ni l'hôte SCM.
- Le script relance ensuite W3/W2bis/W1. L'hôte SCM W3 est compilé mais jamais lancé.

La préparation Linux exécute le lecteur portable avec AddressSanitizer/UBSan.
La détection des fuites est désactivée car l'inspection /proc des tâches est
indisponible ici. Les tests Win32, MSVC et Flutter doivent être confirmés sur le
PC Windows, sans présenter les tests de refus comme une qualification positive.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\test_document_controls_w4.ps1"
flutter test test/document_windows_contract_test.dart test/document_native_launcher_w1_test.dart
flutter build windows --debug
```

## Références Microsoft

- https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-queryfullprocessimagenamew
- https://learn.microsoft.com/en-us/windows/win32/api/winsvc/ns-winsvc-service_sid_info
- https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-lookupaccountnamew
- https://learn.microsoft.com/en-us/windows/win32/api/aclapi/nf-aclapi-getsecurityinfo
