J5 — Réconciliation des tentatives et restaurations, hors réseau

RACCORDEMENT PRODUIT
DocumentReconciliationService s'appuie sur DocumentJournalService et les mêmes
versions PDF, validations médicales, contrôles CDA et paquets signés du produit.
preview prépare un examen sans écriture ; confirm exige une confirmation explicite
et recontrôle l'état courant dans une transaction. Une nouvelle observation ou
restauration survenue entre les deux impose un nouvel examen. Les octets fournis
sont copiés dès la prévisualisation. Les appels de confirmation identiques sont
idempotents, y compris simultanés.

La nouvelle table append-only document_reconciliations (schéma 37) conserve les
en-têtes, le corps original en base64, leurs empreintes, la décision rejouable,
l'empreinte des preuves liées, l'historique des restaurations et le lien vers
l'observation précédente. Un événement est ajouté atomiquement au journal commun.
Les résultats initiaux, tentatives, retenues et barrières ne sont jamais écrasés,
supprimés ou acquittés. Aucune attribution à un professionnel authentifié n'est
inventée : il s'agit d'une confirmation locale d'examen dans le banc isolé.

Le MessageID attendu vient du paquet signé conservé, jamais d'une requête importée
avec la nouvelle réponse. La signature, les certificats synthétiques, XDS/VIHF,
CDA, PDF, patient et validation de ce paquet sont revérifiés. Le profil historique
est évalué à la date enregistrée, sans demander de nouveau certificat, CRL, accès
réseau ou signature. Les réponses SOAP/MTOM doivent avoir une corrélation exacte,
un statut cohérent et une longueur complète ; les archives ambiguës restent non
vérifiées. Une ancienne réservation sans paquet signé reste indéterminée.

Le statut effectif agrège les preuves sans remplacer le résultat initial : succès,
rejet ou indéterminé. Un succès et un rejet concurrents restent en conflit, même
après une troisième observation. Une réponse non concluante n'efface pas un résultat
concluant. Le panneau de suivi métier existant présente séparément la conclusion
et le résultat initial, avec retenue non réarmable. Une nouvelle version de la
pièce ou une copie identique pour le même patient ne contourne pas la tentative.

Une restauration sans tentative retrouvée ne prouve pas l'absence d'envoi ; elle
reste suspendue. Une nouvelle restauration est signalée et exige un nouvel examen.
Même une réconciliation concluante ne libère aucun renvoi ou verrou global. Aucun
mécanisme de reprise automatique, de purge ou de « réinitialisation » n'est ajouté.

SAUVEGARDE
Le ZIP produit conserve la table et les octets des réponses avec les autres preuves.
Le même lecteur rejoue les décisions lors de sa validation : altérations du corps,
hash recalculé, résultat falsifié, cible étrangère, chaînage interrompu, événement
manquant ou registre supprimé sont refusés. Les sauvegardes antérieures au schéma37
restent lisibles et migrent de manière additive ; aucune tentative n'est inventée.
Une empreinte est un contrôle d'intégrité local, pas une attestation externe de
l'origine d'une réponse. Le banc ne prouve aucune acceptation DV1 ni homologation.

SÉPARATION DU BANC
Toute écriture par le service exige un répertoire marqué J4-SYNTHETIC-ONLY contenant
ABAK-J4-SYNTHETIC, avec base et stockage PDF sous cette racine résolue. Les services
sont du code produit ; seules les données, clés, certificats et réponses adaptées
sont synthétiques. Les archives de référence ne sont jamais modifiées : seule une
copie du RelatesTo est liée au MessageID de la tentative fictive. L'archive intacte
sert de cas négatif non corrélé. Les contrôles PDF/CDA du montage sont des doubles,
les paquets/signatures RSA et le journal/sauvegarde/restauration sont réellement
exécutés. Le panneau produit affiche les observations, mais aucune commande de
réconciliation en base utilisateur ni de renvoi réel n'est activée.

EXÉCUTION
bash tool/document_reconciliation_product/verify_offline.sh SORTIE_ABSOLUE CERTIFICATS_SYNTHETIQUES
Le dossier de certificats doit être celui du banc document_wire_product,
avec assessment.json, auth.der, sign.der et leurs clés exclusivement synthétiques.
Le script compile puis exécute le banc et un second processus Flutter sans VM service,
sous sandbox-exec deny network*. Aucun téléchargement, Java/CPS ou socket n'est
nécessaire. Il utilise les frameworks Flutter installés en lecture seule, sans
lancer ABAK. Les données de test et rapports vont uniquement dans SORTIE_ABSOLUE.

SUITE
Recette métier intégrée hors envoi, puis configuration officielle et habilitations
opérationnelles ; recette matérielle CPS/TLS et DV1 seulement dans leur périmètre
explicitement autorisé. L'utilisation en base réelle et une politique de reprise
après rejet/restauration restent des travaux distincts ; ce composant ne les active
pas implicitement.
