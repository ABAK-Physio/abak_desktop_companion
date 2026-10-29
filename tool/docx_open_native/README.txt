Recette native macOS — ouverture des DOCX

prepare.py --output /private/tmp/<dossier-neuf>
Génère uniquement des documents synthétiques, une application Swift minimale
reprenant le bloc openDocx du code produit et des droits sandbox limités.
Ne lance rien, ne modifie aucun réglage global, ne touche aucun document patient.

Compiler main.swift avec xcrun swiftc vers « ABAK DOCX Test.app/Contents/MacOS/test ».
Signer cette application avec l’identité de développement locale, hardened runtime
et entitlements.plist fourni. Vérifier la signature puis lancer cette copie de test.

Sélectionner Rapport synthétique.docx : vérifier visuellement l’ouverture dans
l’application par défaut. Sélectionner Rapport LibreOffice.docx : vérifier
l’ouverture dans LibreOffice installé dans /Applications.
Vérifier que com.apple.quarantine est toujours présent après ouverture et
qu’aucune alerte de sécurité ni autorisation Automation n’a été nécessaire.
Un succès de lancement seul ne prouve pas que le document est affiché.

Cas négatifs : choisir un fichier non DOCX ou un dossier ; refus attendu.
Les tests Flutter complémentaires vérifient la transmission exacte du chemin
et la propagation des erreurs natives. Cette recette minimale ne remplace pas
la vérification du bouton dans la version Companion installée.
