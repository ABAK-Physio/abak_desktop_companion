IDENTITÉ DÉJÀ QUALIFIÉE — ADAPTATEUR ET LIAISON ISOLÉS

identity.py fournit :
- IdentityReader(root, database, verifier) : connexion SQLite mode=ro et
  query_only, transaction SELECT, aucun accès par défaut au stockage utilisateur.
  Tables et champs reprennent les modèles ABAK patients/care_episodes/
  care_episode_reports/patient_fr_health_identity. Racine marquée synthétique.
- IdentityWorkflow : enveloppe schema=2 séparée, stage/approve/begin/xml/finish/
  recover. La capture PDF clinique v1 est un prérequis mais ne vaut jamais
  confirmation d’identité v2. approve exige la version complète et une nouvelle
  confirmation explicite de correspondance. Ce composant ne réalise pas cette
  confirmation à la place du professionnel ; les tests injectent l’acte fictif.
- Liaison transitive de la version native au PDF, contexte et identité via
  sourceRevision. Le coordinateur natif v1 reste inchangé. Les archives v1 ne sont
  ni réécrites ni migrées. Ce n’est pas une modification globale du protocole v1.
- XML CDA construit avec les valeurs de la capture puis contrôlé strictement au
  retour et à la réouverture d’un succès. Contrôles PDF/A/XSD/Schematron existants
  réutilisés. Les résultats ne sont applicables qu’à la révision source relue.

Limitations intentionnelles
L’adaptateur est pour le banc synthétique du travailleur local, raccordé à un
écran de démonstration distinct, jamais à la base réelle d’ABAK.
Identifiant SIM-*, clé FIXTURE-KEY, autorité synthétique 2.25.123456789, lieu SIM-* :
ce ne sont PAS un NIR/INS réel, une autorité INS officielle ou un lieu INSEE.
Le type fixture-NIR sert uniquement à tester les décisions ; ni checksum ni
récupération INSi. Le nom du lieu CDA reprend le marqueur synthétique ; tout
mapping officiel de code géographique reste hors de cette démonstration.
Le modèle source n’a pas de type NIR/NIA explicite : l’adaptateur le détermine par
son autorité de fixture, rejette fixture:oid:nia et les autres autorités. Aucun
validateur de production n’est fourni ni activé.
L’état qualified est consommé, jamais écrit ou recalculé. La provenance est
exigée par choix prudent du banc, sans règle réglementaire de péremption inventée.
Toutes les dépendances de l’identité/rattachement sont versionnées. Une mutation
concurrente est contrôlée à chaque frontière et avant/après la finalisation ;
aucune promesse de synchronisation atomique avec une base métier n’est faite.
Envoi interdit et retenue permanente, y compris après résultat conforme.

Exécution
verify_offline.sh CONFIGURATION_JSON PYTHON_LOCAL
Configuration : out neuf, references locales, validator veraPDF, java, template
CDA synthétique, snapshot clinique du banc PDF existant. Le lanceur interdit
l’intégralité du réseau, y compris local, à tous les sous-processus.
verify.py crée ses propres bases SQLite fictives ; seules ses fonctions de
fabrication/injection modifient ces bases. L’adaptateur testé reste en lecture seule.
Les réouvertures passent par un processus séparé. Resultats_20.json et Synthese.json
sont nécessaires pour confirmer la fin, le seul code de retour ne suffit pas.

Prochaine intégration
L’écran et le protocole de commande explicite présentent les traits synthétiques
et demandent la confirmation avant approve. Le raccordement aux
pièces EpisodeDocument et à une identité officielle est distinct de ce banc
initial de rapports ; ne pas l’activer par défaut.

Écran de démonstration ajouté
lib/features/dmp_identity_isolated/identity_screen.dart est accessible depuis les
Réglages. identity_demo.dart échange des commandes/résultats par fichiers dans
un dossier marqué ABAK-IDENTITY-DEMO-1 choisi explicitement via le sélecteur macOS.
Aucun serveur réseau ni processus de carte dans Flutter. Un pointeur de dossier
est conservé dans Application Support ; aucune base métier utilisée.

demo_service.py crée sa propre base synthétique et utilise IdentityReader et
IdentityWorkflow. Il maintient un verrou de service unique. La confirmation exige
la même version et le même scénario ; une confirmation périmée est rejetée.
Un redémarrage ne rejoue pas une commande déjà prise en charge (.working).
L’ouverture de l’écran demande seulement recover, jamais une exécution native.
Les cas doute, NIA, donnée manquante, modification et source indisponible sont des
injections limitées aux nouvelles bases de démonstration. Le cas CDA différent
change volontairement un trait avant contrôle natif. Aucun INS officiel validé.

verify_screen.dart utilise le widget réel, son service et les validateurs natifs,
sous sandbox-exec deny network*, avec IDENTITY_ROOT, IDENTITY_ASSETS et
IDENTITY_OUTPUT. Compiler via le frontend Flutter local puis exécuter avec
flutter_tester --disable-vm-service --run-forever. Exiger Resultats_ecran.json.
Le sélecteur macOS n’est pas automatisé : le test injecte le dossier dédié.
Le guide et le lanceur utilisateur sont dans output/interface-identite-qualifiee
au sein du projet DMP. Ce dossier utilisateur est distinct des dossiers de test.
