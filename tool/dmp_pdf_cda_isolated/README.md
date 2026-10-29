# Banc PDF/CDA isolé

Banc de contrôle hors réseau, distinct de l'application utilisateur. Aucun
transport DMP, appel CPS/INSi, accès au dossier patient ou lot réel. Les entrées
utilisées sont les fixtures synthétiques du banc PDF existant. Aucun PDF réel
ne doit être donné à ce lanceur.

## Exécution

Lancer `verify_offline.sh` avec cinq chemins absolus :

1. Répertoire des fixtures synthétiques existantes (`rapport_final.pdf`, etc.).
2. Ressources locales `TestContenuCDA-3-0`.
3. Répertoire de résultats **inexistant**.
4. Répertoire Poppler (`pdfinfo`, `pdftotext`, `pdftoppm`).
5. Python local avec lxml et Pillow.

Le lanceur applique `sandbox-exec` avec `deny network*`, y compris aux processus
Java et aux processus de réouverture. Il ne télécharge aucune dépendance. Les
ressources CDA sont copiées dans le répertoire de résultats ; compilation et
rapports sont écrits uniquement dans cette copie. Ne pas lancer l'ancien
`valider_local.py`, qui cible un ZIP signé historique.

## Ce qui est réellement contrôlé

- Lecture, chiffrement, corruption et rendu des PDF synthétiques avec Poppler.
- Détection de toutes les pages blanches. La présence de contenu **clinique**
  reste une déclaration de revue, pas une conclusion d'extraction de texte.
- Empreintes des copies et des rapports, revue liée aux octets et au contexte,
  décodage strict du PDF CDA et comparaison exacte des octets.
- XSD CDA étendu et cinq schematrons locaux : structuration minimale, IHE,
  modèles de contenus CDA, modèles ANS et terminologies. SVRL et journaux
  complets sont conservés ; toute erreur d'exécution reste non vérifiée.
- Comparaison du contexte et des métadonnées synthétiques : patient, auteur,
  structure, titre, date, confidentialité, type/classe, identifiants/version.
  La comparaison ne remplace pas toutes les règles métier de production.
- Journal atomique, retenue systématique, réouverture dans un processus séparé
  et compteur toujours nul. Le banc n'a aucune fonction d'envoi.

## PDF/A : limite explicite

Le banc recherche `verapdf` dans le PATH. S'il manque, le verdict natif est
`non_verifie`. Les décisions positives et négatives PDF/A sont alors injectées
par le test : `simulated=true` et état `simulation_conforme`, jamais une preuve
de conformité effective. Le parseur de rapports est testé par contrats ; son
interfaçage avec une version installée de veraPDF reste à vérifier.

PDF/A-1b est un profil candidat de ce banc. L'association locale exige PDF/A-1
pour le format choisi ; le niveau exact applicable reste à confirmer. Aucun
PDF n'est converti en PDF/A par ce banc.

## Interpréter les résultats

`Resultats_18.json` distingue la portée native ou simulée de chacun des 18
groupes. `PASS` signifie que les assertions du banc passent ; il **ne signifie
pas** que le PDF ou le CDA est conforme au DMP. `Synthese.json` donne séparément
les verdicts documentaires natifs. Un CDA témoin peut être XSD valide et refusé
par les schematrons : ses écarts restent visibles et bloquants, sans suppression
de règles. Les identifiants SIM sont fictifs et ne prouvent aucune identité
qualifiée. Le champ CDA `signatureCode` n'est pas une signature cryptographique.

La validation médicale, la conformité PDF/A, la conformité CDA, les règles XDS,
la signature et l'acceptation DMP restent des preuves distinctes. Ce banc n'est
pas raccordé à un parcours de dépôt réel ni à l'écran de démonstration.

## Adaptateur veraPDF 1.30.3 — rapports archivés

`verify_archived.py ARCHIVE SORTIE_NEUVE` relit seulement les archives ; à lancer sous `sandbox-exec` avec `deny network*`. Il ne démarre aucun validateur. Le code 1 avec rapport complet de non-conformité produit `refuse`. Les codes 7/8 avec lecture impossible/chiffrement restent `non_verifie`, avec motif distinct. Les codes et rapports contradictoires sont bloquants. La corrélation fichier/profil/bilan/détails est contrôlée ; les empreintes du rapport et du PDF sont conservées. Les contrats positifs fabriqués ne constituent aucune preuve PDF/A.

## Témoin natif et variantes

`fixtures/manifest.json` fixe les empreintes du témoin PDF/A-1b et du CDA synthétiques. `run_native_offline.sh REFERENCES SORTIE_NEUVE VERAPDF POPPLER PYTHON` exécute 15 contrôles supplémentaires, génère les variantes dans la sortie neuve et impose l'interdiction réseau. Dépendances locales : pypdf, lxml, Pillow, Poppler, Java et veraPDF.

La suite historique accepte deux arguments supplémentaires : `verify_offline.sh FIXTURES REFERENCES SORTIE_NEUVE POPPLER PYTHON VERAPDF PDF_POSITIF`. Utiliser le témoin embarqué comme PDF positif et le chemin explicite du veraPDF installé. Les 18 scénarios historiques comportent toujours des réponses simulées : consulter la portée de chaque résultat.

La suite native vérifie métadonnées, couleur, police, action interdite, chiffrement, troncature, blanc/en-tête, nouvelle validation après modification, rapports périmés, intégrité CDA et persistance par processus distinct. Aucun verdict CDA n'est inventé pour les PDF déjà refusés : ils restent bloqués et le contrôle CDA est alors explicitement non évalué. Les PDF blancs/en-têtes peuvent être conformes au format ; la revue clinique reste une condition distincte.
