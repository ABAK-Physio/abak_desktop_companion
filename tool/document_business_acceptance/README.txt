RECETTE MÉTIER INTÉGRÉE — BASE EXCLUSIVEMENT SYNTHÉTIQUE

Objet
Parcours continu dans les écrans métier existants et les services produit : import,
contexte, validation médicale, contrôles natifs, retenue, chaîne simulée, examen
explicite d’archives, nouvelle version, sauvegarde/restauration et redémarrage.
Aucune installation, base utilisateur, lot réel, réseau, CPS ou fonction INSi.

Exécution
bash tool/document_business_acceptance/verify_offline.sh /chemin/absolu/preuves /chemin/certificats-synthetiques /chemin/references-CDA
Le dossier de preuves doit être neuf et les dépendances déjà disponibles localement.
Toutes les compilations et exécutions sont sous sandbox-exec deny network*.
Puis exécuter independent.py sous la même interdiction, avec les preuves, les
schémas TD0.2/XDS archivés et la racine du dépôt (Python local avec lxml,
cryptography et pypdf). Aucun téléchargement ni pub get.

Périmètre et limites
- Vraie base SQLite avec migrations produit et vrais services de stockage.
- Les sélecteurs de fichiers/dossier sont injectés ; les boutons, champs,
  confirmations et routes Flutter sont exercés par leurs commandes UI.
- Les moteurs d’import et de revue utilisent le rendu réel CoreGraphics via un
  pont de test. Le canal du plugin Printing installé n’est pas évalué ici.
- veraPDF et les validateurs CDA Java exécutent réellement les contrôles locaux.
- Le contexte professionnel, l’identité déjà qualifiée et les droits sont
  synthétiques. L’adaptateur TD0.2/signature/TLS est celui du produit, mais les
  certificats, la carte et le serveur sont simulés (TLS en mémoire sans socket).
- L’appel de la chaîne simulée et la sauvegarde/restauration passent par les
  services produit. Aucun bouton d’envoi réel n’est ajouté à l’application.
- L’examen d’archive n’apparaît qu’avec une capacité et un sélecteur explicitement
  injectés. Le service exige le marqueur et les chemins du stockage isolé.
- Les réponses sources restent intactes. Une copie corrélée adapte seulement le
  RelatesTo à la tentative synthétique ; elle ne prouve aucun dépôt réel.
- La validation médicale est jouée par le banc sur le contenu synthétique ; elle
  ne constitue pas l’approbation clinique d’un document réel.

Séquence métier
1. Importer rapport.pdf, vérifier application/pdf, copie exacte et version 1.
2. Saisir le contexte, revoir l’aperçu natif, confirmer les attestations et valider.
3. Réouvrir : validation et retenue conservées, zéro tentative.
4. Contrôler PDF/A-1b et CDA ; la retenue bloque tout appel.
5. Lever la retenue sans envoi automatique ; provoquer un délai dépassé simulé.
6. Examiner une archive non corrélée (indéterminée), annuler une confirmation,
   puis conserver l’examen du succès corrélé. Le résultat initial reste intact.
7. Sur une deuxième pièce distincte, examiner le rejet de métadonnées.
8. Importer une nouvelle version de la première pièce : aucune validation héritée,
   retenue, historique conservé et renvoi bloqué. Refuser un PDF entièrement blanc.
9. Sauvegarder puis examiner le ZIP préparé : pièces, reçus et observations.
10. Restaurer en base isolée, comparer toutes les empreintes et les tentatives,
    vérifier la barrière, réexaminer une archive, contrôler le renvoi.
11. Déplacer les copies de travail synthétiques, restaurer à nouveau depuis le ZIP,
    puis redémarrer dans un nouveau processus : mêmes preuves, compteur et blocages.
12. Vérifier indépendamment le paquet, TD0.2 et le PDF encapsulé (lxml/cryptography/pypdf).

Preuves
result.json, restore-missing.json, restart.json, native.json, archives.json ; rapports natifs dans la
copie isolée ; sauvegarde ZIP ; captures 01 à 06 et aperçu clinique ; rapports
independent.json, td02-independent.json, content-independent.json. Les dossiers
execution-* intermédiaires restent diagnostiques ; seul le dernier succès complet
fait foi dans le bilan. Sources de référence jamais modifiées.
