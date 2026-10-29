J5 — paquet XDS / VIHF / XAdES / MIME-MTOM, uniquement hors réseau

Produit : lib/features/patients/services/dmp_chain/wire/{crypto,package}.dart.
DocumentDmpChain utilise le profil complet quand le port implémente
DocumentDmpWirePorts. Le port historique ABAK-DMP-PORTS-1 reste exclusivement
un double de contrat et n'est jamais étiqueté paquet réseau vérifié.
Aucun fournisseur réseau/CPS ni bouton d'envoi réel n'est enregistré.

Entrées : reçu médical immuable, contexte, CDA déjà contrôlé, session authentifiée,
configuration LPS explicite, certificats publics d'authentification/signature distincts
et attestation datée de contrôle chaîne/confiance/révocation liée aux empreintes.
Le module contrôle lui-même les sujets, usages et dates X509, la clé RSA et les
empreintes. L'attestation de confiance/révocation reste un contrat du fournisseur ;
elle ne constitue pas une implémentation de validation de certificats CPS réels.
Les clés privées ne sont utilisées que par le double de signature du banc.

Profil local : adulte, kiné G15_70, ambulatoire, auteur=validateur, visibilité normale,
nouveau dépôt. Pas de mineur, secret, remplacement de document ou auteur distinct.
L'identifiant du CDA est désormais un OID 2.25 stable, identique au uniqueId XDS
et à la référence du manifest. Un ancien CDA dont les octets ne correspondent pas
au constructeur courant est refusé : refaire explicitement les contrôles locaux ;
aucune preuve ni pièce existante n'est réécrite automatiquement.

Signature : SEL-MP-037 DMPi 2.10 A6-2, XAdES 1.1.1, RSA-SHA1 et C14N avec commentaires.
Ces algorithmes sont ceux du profil archivé explicitement choisi, sans négociation
ni repli. L'intégrité locale du paquet complet utilise SHA256. Le VIHF DIRECTE est
non signé séparément ; son Issuer provient du certificat d'authentification.
Les métadonnées ne sont pas couvertes directement par le digest XAdES du lot
(hash null AA== imposé par le profil) : le paquet entier est scellé dans le journal.

Exécution reproductible avec dépendances locales déjà présentes :
1. certificates.py <racine-synthétique/certificats> avec le Python local cryptography.
   Produit une CA jetable, clés indépendantes, certificats négatifs et CRL signée ;
   vérifie leurs signatures. Ne jamais importer cette CA dans le trousseau.
2. bash tool/document_wire_product/verify_offline.sh <sortie-absolue> <certificats>.
   Compile et exécute le produit sous sandbox deny network*, VM service désactivé,
   dans des bases synthétiques marquées J4-SYNTHETIC-ONLY. Second processus inclus.
3. independent.py <sortie> <références/IHE-et-ebRS> <repo> sous le même sandbox.
   Vérifie indépendamment avec lxml, cryptography et email : XDS reconstruit depuis
   XOP, RSA, digests, canonisation, MIME, attributs VIHF, codages archivés et OID.
Les trois scripts sont utilisés sans réseau ; aucune installation de dépendances.

Le banc relit les réponses archivées sans modifier les originaux. Les copies corrélées
adaptent uniquement RelatesTo et le signalent. Un ancien succès non corrélé reste
indéterminé. Retenue, interruption, rejet, incertitude, restauration et concurrence
conservent le blocage du renvoi. Paquets et signatures sont revérifiés à la restauration.
L'ancien précontrôle TD0.2 demeure un contrat simulé : son adaptation filaire complète,
le fournisseur TLS/CPS réel et la réconciliation après restauration sont distincts de
la validation de ce paquet de dépôt. Aucun résultat ne vaut acceptation DV1.
