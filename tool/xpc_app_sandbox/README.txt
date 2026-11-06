Préparation de migration XPC vers App Sandbox — branche feat/xpc-app-sandbox

STATUT : PROTOTYPE DE RECETTE, PAS UNE MIGRATION ACTIVÉE.
Le service produit, ses scripts de signature, les applications installées et le
build 26 ne sont pas modifiés. Le fichier AppSandbox.candidate.entitlements
n'est référencé que par cette recette. Les avertissements de dépréciation du
service produit restent donc visibles ; ils ne sont pas masqués.

Motif de la non-activation
App Sandbox autorise les écritures dans son conteneur. La politique produit
actuelle les interdit partout sauf dans un répertoire temporaire précis et
/dev/null. Une bascule limitée au remplacement de sandbox_init par un entitlement
élargirait donc les droits du service et des moteurs enfants. L'exigence de
conserver les restrictions actuelles n'autorise pas cet élargissement.

Contenu préparé
- Entitlements candidats : App Sandbox seul, sans réseau, groupe partagé,
  carte à puce, exception de fichiers ou désactivation de validation de bibliothèque.
- Service XPC signé avec identité neuve par exécution et authentification du
  client par identité et équipe ; aucun remplacement de l'identité produit.
- Enfant signé avec app-sandbox + inherit, pour mesurer les restrictions héritées.
- Entrées de recette strictement limitées à un répertoire synthétique neuf sous
  /private/tmp/abak-xpc-migration-<UUID> ; aucun chemin patient accepté.
- Tests des écritures privées, hors travail, chez l'appelant, de la lecture de
  l'entrée fictive et d'une connexion réseau locale sans données applicatives.
- Comparaison native avec le profil exact extrait du service produit actuel.
- Analyse qui distingue un refus de politique (EPERM/EACCES) d'un fichier absent
  ou d'un port fermé. Un test incomplet n'est jamais une preuve d'isolation.

Exécuter les tests unitaires (aucun certificat nécessaire)
  python3 -m unittest discover -s tool/xpc_app_sandbox -p 'test_*.py' -v

Exécuter la recette native (macOS 13+, Apple Silicon, certificat local)
  python3 tool/xpc_app_sandbox/run_probe.py --identity 'IDENTITÉ DE SIGNATURE' --team IDENTIFIANT_EQUIPE

La recette ne télécharge rien, ne lance jamais Companion ni Java/LibreOffice,
ne soumet rien à Apple et ne modifie pas les certificats. Elle crée un conteneur
macOS propre à l'identité du service de recette ; aucune identité existante
n'est réutilisée. Le contrôle réseau vise seulement 127.0.0.1:9, sans charge
utile. Les mesures sont dans le répertoire affiché : result.json,
production-policy-control.json, assessment.json, sources.json et entitlements
signés. Les fichiers temporaires et conteneurs de recette sont identifiables
par leur préfixe ; aucune suppression de conteneur utilisateur n'est automatisée.

Travail restant avant activation
1. Résoudre la différence de frontière d'écriture. Les API App Sandbox publiques
   ne constituent pas un remplacement équivalent du profil dynamique actuel.
   Une architecture d'exécution plus isolée doit être évaluée si la frontière
   stricte par répertoire reste obligatoire. Ne pas ajouter d'exception globale
   ni retirer une vérification pour obtenir un test vert.
2. Remplacer les chemins reçus par un protocole d'entrées explicites : octets ou
   descripteurs en lecture seule, manifestes bornés pour les références CDA,
   outils signés identifiés. Ne pas transmettre de droit d'écriture sur le dossier
   appelant, de bookmark global ni de racine de documents. Rejeter traversées,
   liens, substitutions et changements après empreinte. Versionner le protocole.
3. Tester séparément le refus d'accès CPS et IOKit. Les mesures présentes ne
   permettent pas de certifier ces deux restrictions.
4. Tester les vrais moteurs Java/veraPDF, CDA et LibreOffice dans la signature
   finale, leurs enfants et sockets Unix, les délais et l'annulation. Préserver
   le profil Office privé et ne pas modifier l'installation Office existante.
5. Ajouter les cas de client XPC non autorisé et d'entrées malveillantes au nouveau
   protocole, puis tester la signature de distribution et la notarisation.
6. Retirer Sandbox.c et les appels obsolètes seulement quand toutes les frontières
   et fonctionnalités sont prouvées. Créer un nouveau build ; ne jamais resigner
   ou remplacer les artefacts notarisés du build 26.

Références Apple
https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox
https://developer.apple.com/documentation/security/protecting-user-data-with-app-sandbox
https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/EnablingAppSandbox.html
