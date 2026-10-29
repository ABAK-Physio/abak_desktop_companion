Recette macOS signée — import du PDF depuis un rapport, sans dépôt

Entrée indépendante native_recipe.dart ; jamais appelée par lib/main.dart.
Compiler avec scripts/macos/compile_macos_local_only.sh --report-pdf-recipe,
la version/build courante et un dossier de sortie neuf hors dépôt.
prepare_native.py reçoit --candidate, --output et --references. Il vérifie la
signature source, crée une identité applicative unique, conserve App Sandbox,
retire les droits réseau/CPS/microphone et signe la copie et son service XPC.
Il ne remplace pas l’application installée et ne lance rien.

Lancer l’exécutable de la copie avec --report-pdf-root=<sortie>/synthetic.
Autoriser uniquement ce dossier synthétique et les trois dossiers d’outils
annoncés (Java, veraPDF, références CDA) dans les sélecteurs natifs.
La base et les PDF sont exclusivement créés dans le dossier synthétique neuf.

Le parcours utilise l’écran ReportDocxPdfScreen et les services de production.
Le choix des deux fixtures PDF est injecté ; les actions du bouton sont pilotées
par le programme de recette. Les attestations médicales sont synthétiques.
Les canaux Flutter natifs, les autorisations macOS, le service XPC signé,
veraPDF, le rendu printing macOS et les contrôles CDA sont réels, sans doubles.
Le contrôle après validation conserve ses rapports habituels sous pdfs/controls.
Le précontrôle automatique reste transitoire et ne crée pas de preuve DMP.

Attendus : PDF conforme accepté techniquement ; pas d’approbation implicite ;
préparation DMP bloquée avant validation ; validation médicale, PDF/A et CDA
conformes ; réouverture persistante ; PDF sans XMP refusé comme PDF/A mais
conservé en nouvelle version ; pas d’héritage médical ; aucune tentative DMP.
Aucune méthode de dépôt, lecture CPS ou signature de lot n’est appelée.

Résultats : synthetic/result.json, progress.txt, controls.json et page-*.png.
En cas d’échec : synthetic/failure.txt. Conserver aussi recipe.json et les
manifestes de compilation/signature. Ne pas présenter cette recette comme
un test de Word ou du sélecteur de fichier PDF : elle commence par deux PDF
synthétiques archivés et teste l’import, le rendu et la validation natifs.

Mode complémentaire --native-picker (argument de l’exécutable) :
aucun pickPdf injecté, aucune pression de bouton programmée. Cliquer sur
Choisir le PDF à valider, puis sélectionner un PDF ordinaire synthétique
exporté dans un dossier extérieur à la racine autorisée de la recette.
Le test attend le résultat veraPDF non conforme, vérifie le rattachement au
rapport, l’absence d’approbation implicite et le blocage DMP. Il ne valide
pas médicalement le document. Exporter depuis Pages ne prouve pas un export
Word ; consigner le logiciel effectivement utilisé dans le compte rendu.
