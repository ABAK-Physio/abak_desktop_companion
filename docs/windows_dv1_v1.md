# Préparation DV1 Windows v1

Ce lot adapte le cycle DV1 existant à Windows. Les contrôles métier, la
confirmation explicite, les signatures, les preuves et les restrictions de
transactions restent ceux du parcours commun. Il ne lance aucune connexion,
lecture CPS, signature ou opération DMP à l'application du correctif.

## Chemins et moteur

Le moteur intégré Windows est data/DmpTools/x64/java/bin/java.exe, contrôlé par
le manifeste Java/veraPDF existant. Le lanceur macOS java-cps reste utilisé sur
Mac. La DLL Cryptolib Windows est déterminée par GetSystemDirectoryW, puis le
nom fixe cps3_pkcs11_w64.dll est ajouté. La requête windowsCpsLibraryPath ne
charge aucune bibliothèque et n'accède pas à la carte. Elle ne reçoit aucun PIN.

La configuration et sa vérification imposent ces moteurs intégrés et leurs
empreintes. Le moteur ne peut donc pas être remplacé par un chemin libre saisi
dans le formulaire Windows. Les règles natives acceptent les chemins Windows
locaux absolus et refusent les chemins relatifs, UNC et de périphérique.

Le fournisseur SunPKCS11 conserve les mécanismes cryptographiques déjà utilisés
par le moteur macOS fourni. Les chemins Windows sont normalisés avec des slashs
et cités entre guillemets dans sa configuration, pour préserver espaces et
accents et éviter l'interprétation des antislashs comme séquences d'échappement.
Les contrôles PKIX, des CRL complètes, des usages et de l'identité CPS, ainsi que
les règles TLS et transactions ne sont pas modifiés. Le paquet de confiance doit
rester complet et à jour ; ce correctif ne remplace pas les ressources officielles.

Le worker Java Windows utilise son dossier dv1-runtime géré, sans changer le
répertoire courant de Companion. Le protocole Dart accepte les lignes LF et
CRLF ; un CR incorporé ailleurs reste une erreur. Le PIN transitoire reste
transmis par l'entrée standard, jamais dans les arguments ni dans un fichier.
Les diagnostics stderr natifs sont toujours éliminés, sans reprise automatique.

## Identifiants et ressources

À la première ouverture d'une configuration Windows non enregistrée, le
formulaire propose une nouvelle identité d'installation :
ABAK-DV1-WINDOWS-<UUID> et un OID 2.25 dérivé du même UUID. Ils sont conservés
lorsque l'utilisateur enregistre et réutilisés ensuite. Annuler avant ce premier
enregistrement ne réserve aucun identifiant. Les identifiants déjà enregistrés
ne sont pas remplacés. L'identité du Mac n'est pas recopiée.

Les valeurs CNDA et CPS fournies par l'utilisateur restent à renseigner :
ABAK DESKTOP COMPANION, version déclarée 1.0.2, ABA-743589-tmp1,
CPS 899700870597, situation 1, mode 0, statut 1, secteur SA07.

Les fichiers publics sont à sélectionner depuis leurs copies Windows : paquet
PEM autorités et CRL, certificats publics d'authentification et de signature,
paramètres XML DMP et nomenclatures officielles. Les chemins du Mac ne sont pas
réutilisés. La référence documentaire doit correspondre à celle retenue dans le
rapport. La date de vérification des paramètres reste une saisie explicite, avec
heure et fuseau ; elle n'est pas renouvelée automatiquement par l'application.

Ce lot ne touche pas pubspec.yaml : l'utilisateur passe lui-même à 1.0.2+25.
La compilation finale reste scripts/build_windows_installer.bat. Elle exécute
maintenant aussi le test Java CPS hors connexion avant la compilation Flutter.
Les tests PDF/A et CDA déjà intégrés sont conservés.

## Vérifications avant livraison

- Java 17 : 35 contrôles hors connexion, comprenant compilation du vrai moteur,
  disponibilité du compilateur source et de SunPKCS11, architecture 64 bits,
  conservation des mécanismes, chemins Windows et Mac, caractères interdits,
  et une trame CLOSE dont les fabriques CPS/TLS échoueraient si elles étaient appelées.
- Dart : 29 tests passent avec package:test et un adaptateur minimal MethodChannel.
  Les vrais helpers de chemin et le vrai pont de processus sont utilisés. Les
  tests de métadonnées utilisent la méthode de production extraite. Le worker
  enfant factice est un vrai processus Dart : LF, CRLF, accents, répertoire privé
  et CR invalide sont vérifiés. Aucun moteur Flutter n'est présent sur cet hôte.
- La modification C++ du canal CPS est compilée pour Windows x64 avec MinGW,
  avec avertissements traités comme erreurs. Elle n'a pas été exécutée sur l'hôte.
- Les contrôles PKIX/CRL, TLS, transactions et usages/identité CPS du Java ont été
  comparés au fichier macOS fourni et sont inchangés.

Le test Java doit encore être exécuté avec le paquet Windows. Les tests Flutter,
la compilation MSVC complète, la DLL CPS réelle, les ressources officielles et
l'accès DV1 doivent encore être validés sur le poste Windows, étape par étape.
Ces tests hors connexion ne prouvent aucune authentification ni transaction DMP.
