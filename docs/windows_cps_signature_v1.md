# Signature CPS locale sous Windows — v1

Ce lot reprend le cycle métier macOS déjà présent dans Companion : confirmation
explicite, préparation des certificats, constitution du lot, signature puis
vérification locale et conservation de la preuve. Le service Dart partagé et son
journal ne sont pas réécrits. Aucun dépôt DMP n'est ajouté par ce lot.

## Adaptation native

Le canal abak_dmp_fr prend désormais en charge prepareDmpLotLocal,
signDmpLotLocal et testCpsSignature, en plus de readCpsProfile. Chaque requête passe
par ABAKCpsReader.exe isolé, avec délai maximal de 45 secondes et annulation à la
fermeture de Companion. Le PIN passe uniquement dans le canal anonyme hérité,
jamais dans les arguments du processus, un fichier ou un journal.

La Cryptolib reste celle installée dans System32 : cps3_pkcs11_w64.dll.
CK_ULONG reste sur 32 bits et CK_ATTRIBUTE/CK_MECHANISM sont empaquetés sur un
octet selon l'ABI Windows. Les pointeurs restent sur 64 bits.

Une requête ouvre une session série sans écriture et tente un seul C_Login.
Les données professionnelles sont relues dans la même session, puis les deux
certificats exacts « Certificat de Signature CPS » et
« Certificat d'Authentification CPS ». Les certificats doivent être distincts,
lisibles, RSA, valides à la date courante et porter le CN du signataire attendu.

La préparation ne recherche aucune clé privée et n'appelle jamais C_Sign.
La signature retrouve uniquement CPS_PRIV_SIG, lie son CKA_ID à celui du
certificat de signature et vérifie que le certificat préparé n'a pas changé.
La valeur de la clé privée n'est jamais demandée ni exportée.

Les mécanismes restent identiques à macOS : CKM_SHA256_RSA_PKCS pour le diagnostic,
CKM_SHA1_RSA_PKCS pour le lot local existant SEL-MP-037 A6-2. Cette adaptation ne
change pas le format du lot. Elle ne modifie pas les autres usages cryptographiques.

Crypt32 et CNG vérifient avec la clé publique la signature du message exact,
puis exigent le rejet d'un message altéré. Le service Dart commun garde les
contrôles de profil, situation, usages des certificats, validation médicale,
PDF/A, CDA, actualité du lot et vérification finale du XML signé.
Les dates de certificats et cette vérification locale ne constituent pas un
contrôle de chaîne de confiance ni de révocation : la preuve conserve
trustAndRevocation = not_checked, comme dans le cycle existant.

Logout, fermeture de session et finalisation sont tentés pour les ressources
ouvertes. Un échec de nettoyage empêche de retourner un succès. Les réponses en
échec ne contiennent ni certificat, ni signature, ni données professionnelles.

## Protocole

Les deux côtés utilisent la version 2, avec une opération explicite et des
champs bornés : PIN 16 octets, identifiant national 64 chiffres maximum,
SignedInfo 32 Kio, certificat DER 64 Kio, signature 16 Kio, requête totale 128 Kio,
réponse totale 1,5 Mio. La réponse doit correspondre à l'opération demandée.
L'installateur habituel reconstruit et installe ensemble Companion et son helper.
Un ancien helper est refusé par le protocole.

Les anciens points d'entrée INSi/authentification persistante/transport ne sont
pas activés dans ce lot. Le test de signature ne remplace pas une signature de
lot, et une signature locale ne déclenche aucun envoi.

## Vérifications réalisées avant livraison

- 500 contrôles de lecture de profil avec le fournisseur factice existant.
- 156 contrôles de protocole de réponse ; troncature, tailles et erreurs.
- 3 763 contrôles signature/protocole factices : préparation sans signature,
  identité/certificat/clé incohérents, certificats dupliqués ou absents,
  erreurs PKCS11, tailles, message altéré, nettoyage, requêtes tronquées.
- Le test signature portable passe aussi par CMake/CTest.
- 18 tests Dart de lecture et signature passent avec package:test et un
  adaptateur minimal de MethodChannel ; ce contrôle n'utilise pas le moteur Flutter.
- Les sources de production et les trois cibles de test Windows sont
  compilées pour Windows x64 avec MinGW. Ce n'est pas une exécution sous Windows
  ni une compilation MSVC/Flutter de l'application complète.

Le script tools/test_windows_cps_signature.ps1 exécute sur le PC Windows :
1. les tests PKCS11 factices ;
2. les vecteurs publics RSA connus avec les vraies fonctions Crypt32/CNG ;
3. les échanges avec un worker factice isolé, y compris SignedInfo de 32 Kio
   et requête maximale, certificat changé et annulation.

Ces tests n'utilisent aucune carte et ne demandent aucun PIN. Les certificats
inclus sont synthétiques ; aucune clé privée de test n'est livrée.
Le script ne lance pas l'ancien exécutable cps_profile_tests.exe placé en
quarantaine. Il ne modifie aucun réglage antivirus.

## Vérification sur le poste

Après application, lancer le script de tests dédié puis les tests Flutter décrits
dans LIRE_AVANT_APPLICATION.txt. Une fois les résultats vérifiés, reconstruire avec
scripts/build_windows_installer.bat et installer la version produite.
Ensuite, sur le rapport de recette déjà validé et contrôlé, demander explicitement
la signature locale du lot avec la CPS correspondante. Relever le résultat local.
La consultation ou le dépôt DMP sera une étape distincte.

Références d'implémentation :
- ANS, kit de programmation Cryptolib CPS et spécifications externes PKCS11.
- Microsoft : CertVerifyTimeValidity, CertGetNameString,
  CryptImportPublicKeyInfoEx2, BCryptCreateHash, BCryptVerifySignature.
