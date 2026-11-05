# Contrôles documentaires Windows — W5 : session de refus

Base : W4 `c462239`, validé sur Windows avec les régressions W3/W2bis/W1,
les tests Flutter et le build Debug. W5 raccorde les briques dans une session
native, sans ouvrir les gardes ni mettre en route le service.

## Portée

Deux sources sont ajoutées au runner : orchestration portable et adaptateur
Win32. Les sources W1/W2bis/W3/W4, les fichiers DMP/macOS/Flutter et l'hôte SCM
restent inchangés. Aucun manifeste d'installation, service, listener, validateur,
règle WFP ou changement d'ACL de fichiers n'est installé ou activé.
Aucune signature payante ou dépendance externe n'est introduite.

Le nouvel accès natif n'est pas exposé au MethodChannel ni à Dart.
`Exchange()`, le lanceur/exécuteur et `ServiceStartupGate()` restent fermés.
L'hôte SCM W3 continue de s'arrêter avant toute création de pipe ou de worker.

## Une session, une seule requête

`ProcessOneRefusalSession` impose l'ordre suivant :

1. Authentifier le pair et conserver les ressources d'identité.
2. Revérifier le pair avant de lire une requête documentaire.
3. Lire exactement une trame W1 bornée.
4. Construire le refus avec `BuildRefusalReply` W3. Une requête invalide arrête
   immédiatement la session ; aucune ancienne réponse n'est réutilisée.
5. Relâcher les références du workflow au corps de la requête.
6. Revérifier l'identité avant d'envoyer le refus.
7. Écrire exactement cette réponse, puis attendre la fermeture du client.

Chaque erreur interrompt le traitement sans appel aux étapes suivantes. Le
workflow ne dispose d'aucun callback d'exécution ni d'argument permettant de
choisir une réponse libre. Même avec une identité simulée acceptée par un test,
le seul résultat constructible est le refus W1 des trois opérations autorisées.
Le SHA-256 du contenu n'est pas calculé et aucun PDF/XML n'est contrôlé.

`RefusalSessionChannel` est la frontière du workflow. Les doubles d'identité sont
définis uniquement dans les fichiers de TEST, qui ne sont pas liés au runner.
Leur succès n'est jamais une preuve d'identité ou d'installation native.

## Accès Win32 raccordé aux contrôles existants

`ServeInstalledRefusalSession` prend possession d'un handle serveur déjà connecté :

- Vérifier qu'il s'agit du côté serveur d'un pipe en mode octets appartenant au
  processus courant. Un handle invalide, côté client ou de type incompatible
  est refusé et fermé.
- Charger W4 depuis l'image du processus courant, les noms fixes et le manifeste
  protégé. Aucun chemin, politique ou adaptateur alternatif n'est accepté en
  argument et aucun choix ne vient de l'environnement ou du JSON.
- Construire la politique Companion à partir du compte/session du processus
  connecté et de la liste de comptes approuvés dans le manifeste.
- Appeler `AuthenticatePipePeer` W2bis côté serveur : préambule fixe, inspection
  du client et du jeton réel de la connexion, restauration d'impersonation.
- Conserver `PeerLease`, l'installation et tous leurs handles jusqu'à la fin.
  Avant lecture et réponse, revalider installation et pair.
- Employer les primitives de trames W2bis et le constructeur de refus W3.
  Le handle serveur est fermé sur tous les retours, y compris sur erreur.

L'appelant devra avoir créé un pipe LOCAL overlapped avec DACL explicite,
`PIPE_REJECT_REMOTE_CLIENTS` et `FILE_FLAG_FIRST_PIPE_INSTANCE`, puis accepté la
connexion. W5 ne crée pas ce listener et ne remplace pas ses contrôles d'accès.
Un client réel devra toujours authentifier le serveur avec W2bis, notamment son
rattachement SCM et son SID, AVANT d'envoyer le préambule ou un document.
Le chargement de fichiers protégés ne prouve pas, à lui seul, le contexte du
processus de service ; l'hébergement réel sous LocalService et son SID reste à qualifier.

## Limites et fermeture bornée

La session utilise un budget natif global de 15 secondes et le délai W1 sans
progression de 5 secondes. Aucun octet reçu ne prolonge la limite globale ; le
champ `timeoutMs` du client ne modifie pas ce budget. Les tailles W1 restent
64 Kio de métadonnées, 64 Mio d'entrée et les limites de réponse existantes.
Les appels synchrones Windows d'inspection/chargement ne sont pas préemptés :
ces valeurs ne sont donc pas une preuve de délai dur de l'authentification.

Après lecture de la réponse, un client conforme ferme son extrémité du pipe.
`WaitForRefusalClientClose` attend cette fin avec le même budget. Un octet
supplémentaire produit `SESSION_TRAILING_DATA` : il n'est jamais interprété comme
une deuxième requête. Un client qui reste connecté provoque `PIPE_TIMEOUT`.
Aucun `FlushFileBuffers` potentiellement bloquant sans limite n'est utilisé.
La session ne déconnecte pas une instance pour y accepter un nouveau client.

Le succès local signifie que le refus a été écrit et que la connexion s'est
terminée. Ce n'est pas une preuve que le client a affiché/consommé la réponse.
Une erreur après écriture peut survenir alors que le refus a déjà été transmis.
Les requêtes invalides et échecs d'identité ne reçoivent aucune trame de résultat.

Les réponses conservent exactement W1 : `WINDOWS_ISOLATION_UNAVAILABLE`,
`executed:false`, PID 0, code -1, sorties vides, aucun fichier et toutes les
preuves d'isolation fausses. Le succès du handshake n'est pas transformé en
qualification d'isolation ni en autorisation d'exécuter un validateur.

## Tests

Les tests portables couvrent les trois opérations, l'ordre exact des étapes,
les erreurs à chaque frontière, les trames mal formées et les tailles
incohérentes. Ils vérifient qu'aucune lecture/écriture tardive ne suit une erreur,
que les réponses sont celles de W3 et que les gardes W1/SCM restent fermés.

Les tests Windows séparent explicitement deux niveaux :

- **Transport et workflow avec identité simulée** : pipes éphémères locaux,
  trois allers-retours de refus sur données synthétiques, fermeture par le client,
  octet supplémentaire refusé, expiration et annulation. Cela ne teste PAS
  une autorisation native positive.
- **Accès natif réel** : refus des handles invalides/côté client, fermeture des
  handles pris en charge, et refus d'une image de test dans TEMP malgré un nom
  correct. Aucune approbation d'identité ni réponse ne part après cet échec.

Le script compile le test Win32 sous `ABAKDocumentControls.exe` dans son dossier
TEMP privé pour exercer l'ancrage W4. Ce fichier contient le `main` DU TEST ;
`service_main.cpp` n'y est pas lié. Ce n'est pas l'hôte SCM W3. Il n'installe ni ne
démarre un service et n'utilise aucun document patient ou changement d'ACL système.
Les descripteurs d'accès créés appartiennent uniquement aux propres pipes éphémères.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\test_document_controls_w5.ps1"
flutter test test/document_windows_contract_test.dart test/document_native_launcher_w1_test.dart
flutter build windows --debug
```

Le script relance W4/W3/W2bis/W1 ; l'hôte SCM W3 est seulement compilé.
Les tests portables sont exécutés sous Linux avec AddressSanitizer/UBSan,
détection des fuites désactivée faute d'accès à l'inspection /proc des tâches.
Les essais Win32, MSVC et Flutter sont à confirmer sur le PC Windows.

## Étape de qualification restante

W5 ne qualifie pas une installation réelle ni une session authentifiée entre
Companion et le vrai service. Le listener, l'installation automatisée et ces
essais positifs restent nécessaires avant raccordement de la production.
Le refus des validateurs reste maintenu. Le kiné ne devra configurer manuellement
ni service, SID, Java, WFP ou ACL.

## Références Microsoft

- https://learn.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-getnamedpipeinfo
- https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getnamedpipeserverprocessid
- https://learn.microsoft.com/en-us/windows/win32/ipc/named-pipe-operations
- https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-flushfilebuffers
