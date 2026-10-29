PIÈCE PDF / IDENTITÉ QUALIFIÉE / PARCOURS PDF-CDA — BANC SYNTHÉTIQUE

Entrée : une racine synthétique explicite marquée, une SQLite de fixtures, un
patient, un épisode et une pièce SIM-. Aucun chemin de base métier par défaut.
PieceReader lit episode_documents.case_id -> care_episodes.care_episode_id ->
patient_id. La branche rapport historique reste distincte. Les contrôles
existants de qualification sont réutilisés ; ils ne qualifient aucune identité
et ne valident aucun INS officiel. Autorité et clé de contrôle fictives seulement.

SQLite mode=ro, query_only, transaction. La ligne entière de pièce (y compris
les valeurs nulles), les parents et l'identité participent à la révision. Le PDF
est lu par des descripteurs sans suivi de liens, sous la racine injectée. Limite
explicite : 20 MiB. Deux lectures source/base doivent être identiques ; toute
mutation détectée abandonne la capture sans réessai automatique.

PieceImport passe les octets capturés au véritable FinalPdfBench Dart : copie
figée, inspection Poppler, aperçus, puis revue clinique explicite. Auteur,
structure, type, classe, date et confidentialité sont des entrées explicites,
jamais déduites du titre, de la source ou du nom du fichier. Page blanche :
blocage automatique. En-tête seul : contenu clinique à refuser par le relecteur,
sans prétendre à une reconnaissance clinique automatique.

La confirmation lie la sélection, le PDF, son contexte et l'identité. La source
est relue avant les contrôles, à leur retour et à la réouverture. Les preuves
natives sont reliées aux octets exacts encapsulés et aux traits de la capture.
La réouverture ne lance aucun validateur. L'état en cours interrompu bloque ;
les preuves historiques restent consultables. Aucun reçu ancien ne confère
une confirmation à cette branche pièce.

Le stockage est neuf et la retenue permanente ; calls vaut toujours zéro.
Le composant ne comporte aucun transport, accès CPS ou appel INSi. Les seules
écritures dans les sources synthétiques sont des injections du harnais de test.
Le lanceur impose l'interdiction réseau au niveau système, y compris loopback.
Les références natives sont copiées dans la sortie neuve, les outils installés
sont lus seulement. Aucun écran ni lot réel n'est raccordé par ce banc.

Exécution : verify_offline.sh CONFIGURATION_JSON PYTHON_LOCAL
La configuration fournit out (inexistant), repo, dart, poppler, java, validator,
references, assets, snapshot témoin et template. Les rapports incrémentaux sont
Resultats_28.json, Synthese.json et Mutations_du_harnais.json. Les erreurs de
configuration interrompent l'exécution : un résultat incomplet n'est pas un
succès. Le PDF/A-1b est le profil du témoin synthétique, sans homologation déduite.

Écran de démonstration
lib/features/dmp_piece_isolated/piece_screen.dart est accessible depuis les
Réglages sous « DMP — pièce PDF et identité simulées ». piece_demo.dart échange
les commandes et résultats par fichiers avec demo_service.py ; marqueur propre
ABAK-PIECE-DEMO-1. Le dossier est choisi explicitement et son pointeur est séparé
des autres démonstrations. Aucun serveur réseau ni accès direct à SQLite côté UI.

Les aperçus proviennent de la capture réelle du banc, sont vérifiés par empreinte
et peuvent être agrandis. Chaque page doit être revue ; contenu clinique, patient,
épisode et contexte sont confirmés pour le binding courant. Changer de pièce
annule la revue, même à PDF identique. Le service vérifie la génération avant
confirmation et délègue au véritable PieceImport.confirm. Aucune confirmation
n’est déduite des cases restaurées : la confirmation persistante est affichée
séparément, les cases restent décochées à la réouverture.

Treize scénarios synthétiques : deux pièces au même PDF, rattachement incorrect,
archive, NIA, indisponibilité, blanc/en-tête, modifications du PDF/de l’identité/
du rattachement, CDA différent. Les injections se limitent aux nouvelles sources
créées par le service. Les pièces ne proviennent jamais d’une base métier.
Le cas en-tête est identifié par le scénario connu, pas par un diagnostic clinique.

verify_screen.dart teste le widget réel avec les validateurs locaux, sous
sandbox-exec deny network*, flutter_tester --disable-vm-service --run-forever.
Variables : PIECE_ROOT (dossier du service de test), PIECE_OUTPUT (captures/rapport).
verify_preview.dart capture le dialogue agrandi (PIECE_PREVIEW = chemin PNG).
verify_restart.py vérifie le redémarrage après arrêt explicite du service test-final,
la conservation de confirmation/sélection et le non-rejeu d’une commande interrompue.
Le verrou empêche deux services actifs sur le même stockage.
Les lanceur, configuration utilisateur et guide sont dans le projet DMP,
output/interface-piece-pdf-identite. Ne pas utiliser les dossiers de test pour
le contrôle visuel utilisateur. Le service utilisateur n’est pas démarré par les tests.
