# Lecture locale CPS sous Windows — premier lot

Le menu « Importer depuis une CPS » et la fiche CPS d'un praticien peuvent
appeler `readCpsProfile` sous Windows. La réponse conserve les objets binaires
du parcours macOS : le décodeur Dart `CpsProfile` et les règles d'association
de `PractitionerCpsService` sont réutilisés.

## Parcours

Le canal `abak_dmp_fr` valide un PIN numérique, puis traite la demande hors du
thread graphique. Il lance `ABAKCpsReader.exe` à côté de Companion. Le lecteur
charge exclusivement `cps3_pkcs11_w64.dll` dans le répertoire système Windows
64 bits. La Cryptolib reste installée séparément par son MSI officiel.

Le lecteur appelle C_Initialize, recherche exactement une carte présente,
ouvre une session série sans accès RW et tente un seul C_Login. Il recherche
uniquement des objets CKO_DATA avec leurs labels exacts : CPS_ID_CARD,
CPS_NAME_PS, CPS_INFO_PS et CPS_ACTIVITY_01_PS à CPS_ACTIVITY_16_PS.
Les attributs CKA_TOKEN et CKA_PRIVATE suivent le parcours Mac. Les tailles
de CKA_VALUE sont bornées avant la copie et les objets facultatifs absents
ne sont pas inventés. Nom, identité professionnelle et au moins une activité
doivent être présents avant le retour réussi.

Le lecteur tente ensuite C_Logout, C_CloseSession et C_Finalize. Une erreur
de fermeture bloque un résultat qui aurait autrement été réussi. Une erreur
initiale, notamment de PIN, reste prioritaire dans le diagnostic.

## Particularités Windows

Les entiers PKCS#11 de type CK_ULONG font 32 bits sous Windows x64, et
CK_ATTRIBUTE utilise l'alignement d'un octet. Ces caractéristiques ont été
comparées au fichier pkcs11.h du kit de programmation ANS. Elles diffèrent
du Swift UInt 64 bits du parcours Mac.

Le PIN passe par un canal anonyme hérité dédié ; la ligne de commande ne
contient que deux numéros de handles. Les buffers de PIN créés par le code
natif sont effacés après usage. Aucun fichier de PIN ou de données CPS n'est
créé par ce lot. Les sorties standard de la Cryptolib sont dirigées vers NUL,
séparément de la réponse binaire au parent.

Le lecteur a son propre dossier de travail utilisateur sous
`%APPDATA%\ABAK Metrics\ABAK_CPS\work`. Le dossier courant de Companion reste
inchangé. Le job Windows arrête le lecteur si Companion disparaît ; une
annulation ou un délai de 45 secondes arrête également l'échange.

## Périmètre

L'import conserve la date de lecture et la provenance CPS selon les règles
existantes. L'enregistrement sur une fiche demande toujours la confirmation
de l'utilisateur dans le dialogue. La profession de kiné et les correspondances
d'identifiants continuent d'être contrôlées par le service existant.

Ce lot ne porte pas la signature, INSi ou les transactions DMP Windows.
Les méthodes CPS de signature non disponibles répondent explicitement avant
toute lecture ou authentification. Les parcours natifs macOS restent séparés.

## Vérification

`tools/test_windows_cps.ps1` compile les tests avec MSVC et utilise un lecteur
factice. Aucune carte réelle n'est sollicitée. Le fournisseur factice est
lié uniquement aux cibles de test, jamais au lecteur livré dans Companion.

Tests disponibles avant livraison :

- 500 contrôles de lecture PKCS#11 simulée : sélection, session sans RW,
  tentative de PIN unique, objets exacts, limites de tailles et fermetures ;
- 119 contrôles de trames et de réponse, exécutés aussi sous ASan/UBSan
  (détection de fuites désactivée car indisponible dans cet environnement) ;
- compilation croisée Windows x64 du lecteur réel, du client et des tests
  de processus ; raccordement C++ compilé avec les en-têtes Flutter officiels ;
- comparaison des types et offsets PKCS#11 avec les en-têtes ANS ;
- contrôles du service Dart avec un canal natif simulé ; tests Flutter
  complémentaires livrés dans `test/cps_windows_read_errors_test.dart`.

La compilation croisée utilise une déclaration locale de compatibilité pour
WerSetFlags, absente des en-têtes WER MinGW employés. Cette déclaration n'est
pas incluse dans le correctif : MSVC utilise son propre Windows SDK.
La compilation MSVC complète et la lecture réelle restent à vérifier sur le
poste Windows. Les exécutables issus de la compilation croisée ne sont pas
distribués dans cette archive.

## Références

- [Cryptolib CPS et kit de programmation ANS](https://esante.gouv.fr/ens/offre/socle-technique-cps/cryptolib-cps-version-5)
- [Spécifications externes PKCS#11 Cryptolib CPS3](https://esante.gouv.fr/sites/default/files/media/document/ANS_PTS_PSCE_SpecificationsExternes_PKCS11_CryptoLib_CPS3_20121010_v1.0.1.pdf)
- Parcours Mac transmis : `macos/Runner/MainFlutterWindow.swift`, fonction
  `readCpsProfile`, branche de lecture du profil uniquement.
