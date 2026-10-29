Contexte professionnel/documentaire — banc synthétique hors réseau

context.py ajoute ContextReader, ContextImport et ContextWorkflow au parcours
PieceReader / FinalPdfBench / IdentityWorkflow / contrôles natifs existants.
Aucun dépôt métier, service CPS, transport ou base par défaut n'est importé.
Le lecteur exige les marqueurs synthétiques de pièce ET de contexte, des identifiants
SIM-, une base explicitement fournie et SQLite mode=ro + query_only.

Les colonnes practitioners correspondent au modèle ABAK. L'autorité, la profession,
la situation et les métadonnées absentes de ce modèle sont fournies explicitement
par synthetic_document_context, table réservée aux fixtures, jamais une migration
ou une nouvelle source de vérité dans la base utilisateur.
Le contexte complet, sa provenance, sa révision, le catalogue et la ligne praticien
entrent dans la version de l'identité/pièce. La confirmation et les preuves natives
sont donc liées à ce contexte. Une autre sélection conserve une génération distincte.
La relecture compare le contexte avant/après la capture et aux frontières du travail.

Profil SIM-CDA-NORMAL-1 uniquement
- Identifiants professionnels synthétiques (autorité 2.25.123456789), profession 70.
- Structures synthétiques, autorité du gabarit 1.2.250.1.71.4.2.2 ; leur valeur reste
  SIM-* et ne constitue ni FINESS validé ni habilitation.
- Exercice ambulatoire, cabinet individuel, document français normal visible.
- Auteur, responsable déclaratif du gabarit et exécutant sont le même auteur explicite.
  L'opérateur est distinct ; aucune authentification ou signature n'en est déduite.
- Dépositaire et structure d'exercice peuvent être distincts et sont contrôlés séparément.
- Type/système/libellé et association type-classe, média-format contrôlés contre un
  catalogue synthétique versionné. Aucun téléchargement ni fraîcheur officielle déduite.
- Classe documentaire comparée aux métadonnées séparées, pas ajoutée au CDA comme
  un classCode arbitraire. Aucun registre XDS, VIHF, lot ou signature n'est produit.
- Profession/mode/statut sont liés au contexte et contrôlent l'éligibilité de ce profil ;
  aucune généralisation authorSpecialty officielle n'est revendiquée.
- Secret et autres visibilités hors mapping sont bloqués, même sémantiquement permis
  par un autre banc : absence de traduction XML démontrée, pas de repli vers N.

Le contexte professionnel latéral professional-context.json est inclus dans le
manifeste de preuves et comparé au contrat après exécution et réouverture conforme.
Les champs CDA mappés sont comparés (autorités, identifiants, noms, structures, secteur,
lieu, dates, code/système/libellé, langue) en plus des contrôles PDF et identité existants.
Les schémas et schematrons locaux demeurent exécutés. Les empreintes sont des contrôles
d'intégrité, pas des signatures. Envoi inexistant, retenue permanente, transport zéro.

verify.py exécute les 32 groupes préparés, dans une racine NEUVE fournie par configuration.
Exécuter uniquement avec sandbox-exec deny network* et le Python local déjà installé.
Le harnais seul crée/mute les fixtures ; l'adaptateur ne les écrit jamais.
Une fonction --reopen recharge dans un processus distinct sans lancer de validateur.
Les erreurs d'outil sont injectées dans un travailleur copié, jamais dans l'installation.
Les résultats détaillés sont archivés dans le projet DMP :
output/raccordement-contexte-professionnel-documentaire/execution-finale.

Résultats : 32 groupes, 187 assertions, 60 bases synthétiques ; régressions pièce 28
et identité 20 réussies. Le mapping et ses références sont dans Mapping.json et
References_mapping.json du dossier de suivi. Les premiers essais sont conservés
séparément ; execution-finale est la preuve de la version publiée dans ce banc.

Pas d'écran, de nouveau service de démonstration ou d'installation dans cette étape.
Suite : raccorder un écran isolé avec contexte affiché, confirmation versionnée,
messages de refus/non-vérifié et contrôles visuels. Tout raccordement métier réel,
profil supplémentaire ou signature nécessitera un contrat et des tests distincts.
