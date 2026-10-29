J5 — chaîne métier et journal commun, interfaces hors réseau

Exécution : bash tool/document_chain_product/verify_offline.sh /chemin/absolu/preuves
Le lanceur compile puis exécute le banc et un second processus sous sandbox macOS
avec deny network*. Aucun flutter test, serveur VM, pub get ou application utilisateur
n'est lancé. Les frameworks SQLite de l'application installée sont seulement lus.
La base et les pièces sont créées dans un dossier synthétique marqué. Le composant
refuse les bases et copies PDF situées hors de ce dossier.

Raccordement dans lib/features/patients/services/dmp_chain :
- DocumentDmpChain reçoit le DocumentJournalService du parcours métier existant.
- Il capture la validation médicale et les preuves PDF/A/CDA courantes, puis appelle
  les interfaces de contexte authentifié, droits/référentiels, TD0.2, signature,
  vérification de signature, TLS et transport. Aucun adaptateur CPS/réseau installé.
- Les messages et états sont exposés par le panneau de suivi déjà présent dans
  Documents / préparation PDF. Il n'y a pas de nouvel écran de simulation ni de
  bouton permettant d'activer l'envoi.
- La réservation et le résultat utilisent exactement les tables J4. Les étapes J5
  et leurs preuves sont immuables et alimentent le même journal par déclencheur SQL.
- Un échec avant réservation n'invente pas une tentative. Après réservation, même
  une interruption avant appel bloque le renvoi. Pas de relance planifiée.
- Toute nouvelle exécution préliminaire requiert à nouveau les contrôles courants,
  la session, les droits et TD0.2. Aucun succès intermédiaire n'est réutilisé.

Contrats du fournisseur d'interfaces :
- authenticate : session, professionnel, autorité, structure, empreinte du certificat,
  empreinte exacte de la situation et dates. Le profil déclaré ne suffit pas.
- policy : opposition explicitement absente, droits fonctionnels/d'auteur explicites,
  visibilité autorisée, codes contrôlés dans le catalogue de cette préparation,
  empreinte du contexte et échéance. Inconnu/absent bloque. La consultation est séparée.
- td02 : réponse brute HTTP/SOAP ; contrôles de corrélation SOAP, HL7 et patient par
  le lecteur existant. Fenêtre locale de fraîcheur maximale : deux minutes, avec
  recontrôle de l'horloge, de la session et des droits avant réservation.
- sign/verifySignature : contenu exact et certificat de la session. Dans ce banc,
  HMAC de test indépendant des documents métier ; ce n'est PAS une signature CPS.
- connect : erreur TLS typée ; aucun dépôt si la connexion simulée échoue.
- deposit : une seule opération, réponse brute, aucun suivi de redirection ou retry
  dans le double. Résultat interprété par le lecteur d'archives commun.

Archives : les fichiers d'origine ne sont jamais modifiés. Les réponses succès,
rejet de signature et rejet de métadonnées sont testées sur des copies dont seul
RelatesTo est adapté à l'identifiant synthétique. Cette adaptation et l'empreinte
originale sont conservées dans la provenance. Une ancienne réponse inchangée est
indéterminée pour une nouvelle requête. Aucun de ces résultats n'est une preuve de
dépôt du PDF du banc sur DV1.

Limite précise avant transport réel :
ABAK-DMP-PORTS-1 est un contrat local figé. Les XML générés sont des propositions
TD0.2/XDS/VIHF liées au CDA et au contexte courant, jamais copiées d'un ancien lot.
Ils ne sont pas un paquet réseau homologué : complétude des métadonnées, paramètres
LPS/déploiement, assertion VIHF native, XAdES et assemblage MIME/MTOM signés restent
à finaliser et à contrôler avec les références officielles archivées. Le signataire
et TLS de ce banc sont des doubles ; ils ne valident ni la CPS ni les certificats réels.
Aucun adaptateur réel ne doit accepter le format « simulation » ou l'émetteur local.
Le journal conserve exclusivement mode=simulation. Activer un transport réel exige
un travail explicite supplémentaire, ainsi qu'une politique de réconciliation après
restauration. La présente étape n'autorise ni DV1 ni la mise en service.

Régression : J4 journal/backup et J3 contrôles natifs. La migration 35→36, la sauvegarde,
la restauration, les preuves manquantes, les modifications pendant la préparation,
la concurrence et le redémarrage sont contrôlés sur des données synthétiques.
