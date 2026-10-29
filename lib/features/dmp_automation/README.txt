AUTOMATISATION DMP — BANC DE SIMULATION UNIQUEMENT

Accès : Paramètres > Configuration > DMP — automatisation simulée.
Le module n’est raccordé ni aux dossiers réels ni à un transport réseau. AutoFakeService est un type final, en mémoire, sans URL, bibliothèque CPS ou accès INSi. Les contrôles réutilisent Td02Result et MinorSession avec des contextes fictifs. Un résultat de simulation n’autorise aucun envoi réel.

Moteur
- Validation médicale liée au condensat de la version métier exacte ; déclenchement automatique selon règle activée et type de document.
- Retenue durable avant tentative ; levée explicite réévalue les gardes, ne contourne pas une validation périmée.
- Après l’attente du faux TLS : nouvelle lecture du stockage, comparaison de la version, des règles, du contexte et de la date. Une modification invalide la préparation ; aucune ancienne décision n’est réutilisée.
- Réservation exclusive persistante, résultat accepté/rejeté/indéterminé et échec TLS. Une tentative sans résultat reste indéterminée. Aucun réessai automatique.
- Résultat tardif après fermeture conservé ; fermeture avant réservation annule la préparation locale. Après réservation, le contenu transmis est un instantané immuable. « Retenir » trop tard ne prétend pas annuler l’envoi.
- DMP, identité, droits, opposition au nouveau dépôt, confidentialité et choix mineur/secret restent indépendants de la validation médicale.

Comparaison
AutoDocument ne contient que les données métier prises en charge dans ce banc : contenu, titre, type, patient/professionnel/structure fictifs, date clinique et visibilités. Les identifiants d’enveloppe, nonce et dates de signature ne font pas partie de ce modèle. Le vide est déterminé sur le texte clinique ; pas d’adaptateur PDF/CDA/pièces jointes dans ce banc. Une évolution d’un document accepté mène à un parcours de modification/remplacement à préparer, pas à un second dépôt indépendant.

Stockage
Nouveau répertoire dmp-automation-simulation-v1 dans le support applicatif. Chaque exercice interactif et chaque scénario possède son sous-dossier. Aucun autre stockage existant n’est lu ou réinitialisé. Le bouton « Commencer un nouvel exercice fictif » change d’exercice et conserve les traces antérieures ; ce n’est pas un déverrouillage de lot. Les règles, la retenue, le texte fictif, sa validation, l’historique et le résultat sont conservés. Le secret n’est jamais mémorisé.
Les mutations synchrones sont prévues dans l’isolate UI de ce banc ; la réservation exclusive protège des deux consommateurs simulés. Ce stockage n’est pas une base clinique multiprocessus et n’est pas destiné aux lots réels.

Tests
automation_cases.dart conserve le plan des 42 scénarios. Le runner vérifie les états, messages et compteurs attendus et exécute séparément les variantes (52 exécutions). Les tests additionnels couvrent la fermeture pendant préparation/envoi, la version figée, la reprise TLS bloquée et la date clinique. Les tests widget couvrent le banc complet, l’envoi automatique après confirmation de validation, l’annulation, la retenue/persistance, le vide et la corruption.
Outil hors réseau : tool/dmp_automation/run_local_scenarios.dart, avec un répertoire de résultats neuf. Il ne sollicite pas Flutter UI, CPS ou réseau.

Contrôle manuel conseillé
1. Exécuter les 42 scénarios : attendre le bilan de réussite.
2. Sur un nouvel exercice, activer « Retenir l’envoi simulé », puis valider médicalement. Zéro dépôt simulé ; fermer/réouvrir : retenue et validation conservées.
3. Lever la retenue : traitement automatique par le faux service, puis accepté. Réouvrir et valider encore : aucun renvoi.
4. Sur un autre nouvel exercice, vider le texte et valider : blocage vide. Vérifier aussi une modification après validation retenue : lever la retenue doit réclamer une revalidation.
Les cas identité, TD0.2 et confidentialité détaillés sont accessibles par le sélecteur des scénarios. L’écran affiche explicitement que l’ensemble est fictif.

Limites
Ce module ne valide pas la sérialisation officielle, une signature, les formats cliniques génériques ni le raccordement à la validation médicale du dossier métier. Il ne dépose/modifie/supprime aucun document réel. EX_GEN-1060 reste à démontrer dans le parcours produit réel ; aucune homologation revendiquée.
