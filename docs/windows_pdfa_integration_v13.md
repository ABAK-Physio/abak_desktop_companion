# Conversion DOCX et vérification PDF/A sous Windows

Ce lot raccorde Companion au moteur LibreOffice essayé sous service Windows
dans les prototypes v11/v12. La version du produit reste `1.0.1+25`.

## Parcours

L'écran « Outils de contrôle locaux » sélectionne LibreOffice Windows et
emploie le Java/veraPDF fourni avec Companion. Les références CDA fournies
sont proposées lorsque la configuration est vide. Les autorisations de
dossiers propres à macOS ne sont pas appelées sous Windows.

Le bouton de conversion inspecte le DOCX avec les règles existantes, transmet
ses octets au service installé, vérifie les empreintes du résultat, puis
fait contrôler ce PDF par veraPDF. Le DOCX original reste intact. Le PDF et
les preuves sont enregistrés avec les mécanismes existants ; la validation
médicale et un éventuel envoi DMP restent des actions distinctes.

Les contrôles CDA Windows restent indisponibles. Leur statut reste
« non vérifié » et les règles DMP existantes continuent à s'appliquer.

## Exécution et installation

Le `.bat` habituel appelle toujours `tools/build_windows_release.ps1`, puis
le script Inno Setup existant. La construction Flutter inclut maintenant
`ABAKDocumentControls.exe` et son outil de configuration. Inno installe,
démarre, arrête avant mise à jour et retire le service avec l'application.
La consultation des documents patients ne demande aucune commande manuelle.

Le service est un processus LocalService dédié, avec quatre filtres WFP
persistants limités à son SID. Le travail LibreOffice/Java utilise le jeton
service+World avec privilèges retirés, un bureau non interactif, un profil
privé, des arguments fixes et un Job Object borné. Les temporaires sont
retirés après l'opération. Les macros et actualisations de liens LibreOffice
reprennent le profil déjà essayé. Il n'existe aucun lancement de secours
sous le compte de l'utilisateur ou en administrateur.

Les deux extrémités du canal local vérifient les exécutables installés et
l'identité du correspondant. Les octets des documents sont transmis, jamais
un chemin utilisateur que le service ouvrirait. Les fichiers Java/veraPDF
sont contrôlés contre le manifeste livré. Les binaires LibreOffice sont
vérifiés et gardés contre remplacement pendant la conversion.

Après réception de la réponse, Companion vérifie encore l'identité du service,
puis envoie l'accusé fixe `ABAKEND1`. Le service attend cet accusé avant de
déconnecter le canal. Cette attente utilise le délai borné des entrées/sorties ;
une fermeture du client l'interrompt. Une réponse d'erreur suit le même parcours.

L'XML original de veraPDF désigne sa copie temporaire privée. L'application
compare ce nom avec la preuve de lancement et lie cette preuve à l'empreinte
du PDF envoyé ; elle ne réécrit pas le rapport pour lui substituer un nom.

Ce profil Windows ne constitue pas un confinement absolu : World autorise
encore les ressources déjà accessibles à Everyone et les restrictions en
écriture ne bornent pas toutes les lectures. Aucun indicateur global
« isolation qualifiée » n'est fabriqué. Les services de prototype historiques
ne sont pas modifiés par l'installation du service de l'application.

## Validation du lot

Effectuée hors Windows : formatage/analyse syntaxique Dart des fichiers
modifiés ; analyse Dart du lanceur et de la vérification des outils avec un
canal simulé ; 30 cas du code Dart réel, dont erreurs de corrélation,
empreintes, protections manquantes, refus PDF/A, conservation des rapports
et non-régression du format de réponse macOS. Les scripts PowerShell sont
analysés et leurs déclarations C# SCM compilées sans appeler les API Windows.

Les tests Flutter du projet complet, la compilation Visual C++, Inno Setup
et le parcours installé n'ont pas été exécutés ici. Ils doivent être vérifiés
sur Windows. Le fonctionnement du prototype v12 ne remplace pas cette
validation du raccordement. Le parcours XPC réel sur Mac reste à essayer.

Après compilation et installation, essayer d'abord le `source.docx` synthétique
du dossier `ABAK_DOCX_Service_Test_20261107_080027_f8e25f40` sur le Bureau,
dans un dossier patient fictif. Vérifier le statut PDF/A et le rendu des pages.
Le fichier d'installation à utiliser est celui nouvellement produit dans
`build/installer`, et non une ancienne copie portant le même nom sur le Bureau.

En cas d'échec de l'installation, le journal est
`document-controls-installation.log` dans le dossier de l'application.
Les erreurs natives récentes sont sous
`ProgramData/ABAK/DocumentControls/work/startup-error.txt` ou
`request-error.txt`, lisibles en administrateur.
