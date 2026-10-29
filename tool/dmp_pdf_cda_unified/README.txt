Raccordement PDF final / contrôles natifs — stockage synthétique exclusivement

Entrée Dart : FinalPdfBench.exportNativeSnapshot(). Vérifie la copie et ses
aperçus sous verrou, ne lance pas simulate(), ne lève jamais la retenue.
Le contexte CDA complet doit être confirmé explicitement en plus de la revue
clinique du PDF. Ce reçu est lié à la version complète, pas à un booléen partagé.
Schéma canonique : lib/features/dmp_pdf_cda_unified/snapshot_contract.dart.

Entrée Python : Coordinator.create(parent, configuration, resources), load(snapshot),
begin(), NativeWorker.execute(...), finish(token), recover().
Le travailleur local produit le CDA avec les mêmes octets, exécute veraPDF 1b,
XSD et cinq profils schematron. Les rapports complets sont conservés. Les
résultats PDF et SVRL sont relus depuis les preuves brutes ; le XSD est revérifié.
Les identifiants d'exécution, versions et configurations sont contrôlés avant
l'écriture. Journal atomique/fsync et verrou interprocessus. Aucun transport.

Les empreintes sont des contrôles de cohérence locale, pas une signature ou une
protection contre un administrateur capable de réécrire toutes les preuves.
Le dépôt réel, la qualification INS et la signature CPS ne sont pas implémentés.
Les identifiants synthétiques doivent commencer par SIM-. Ne jamais brancher
ce banc sur un dossier réel. L'écran de lecture d'archives existant reste inchangé.
L'écran du parcours unifié et sa confirmation de contexte sont une étape ultérieure.

Exécution : verify_offline.sh CONFIGURATION_JSON PYTHON_LOCAL.
Le JSON indique des chemins locaux : out (absent), references, assets (témoins
synthétiques préparés), validator, java et poppler. Les références sont copiées
avant compilation des schematrons. Aucun téléchargement de dépendances.
Le lanceur interdit tout réseau, y compris local, à ses processus descendants.

Les 32 groupes comprennent des exécutions natives et des fautes injectées :
rapports altérés/manquants, interruption, version tardive, stockage hostile.
Le test de délai représente une interruption de travailleur ; les outils natifs
utilisent en plus la limite de durée du banc commun. Les résultats ne constituent
ni une homologation ni la validation du parcours métier réel.
Les 26 scénarios du banc PDF historique sont à conserver en régression.

Écran de démonstration unifié (17/10/2026)
UnifiedScreen + UnifiedDemo réutilisent FinalPdfBench, exportNativeSnapshot et
Coordinator. Le service demo_service.py ne communique que par fichiers dans un
dossier explicitement marqué ABAK-UNIFIED-DEMO-1. Une seule instance du service
est admise par verrou. Chaque démarrage travaille sur ses propres références.
Le lanceur utilisateur est dans output/interface-parcours-unifie du projet DMP.
Il impose sandbox-exec deny network* aux validateurs comme au service.

verify_screen.dart exécute le véritable widget (LiveWidgetController) avec
service natif dans un dossier neuf : 24 assertions, dont persistance à la
réouverture, refus, non-vérifié, modification, identité du PDF et journal altéré.
Variables : UNIFIED_ROOT (dossier initialisé par service), UNIFIED_ASSETS
(assets/dmp_local/pdf_cda_unified), UNIFIED_OUTPUT (résultats). Compiler avec le
frontend Flutter local puis flutter_tester --disable-vm-service --run-forever,
sous sandbox-exec deny network*. Exiger Resultats_ecran.json, pas le seul code
retour. Le dernier test corrompt volontairement ui.json : ne jamais réutiliser
ce dossier pour la démonstration utilisateur.

Les aperçus et inspections cliniques sont des ressources synthétiques épinglées
par SHA256. Le widget n'importe pas de fichier patient arbitraire. La validation
technique est native (veraPDF, XSD et profils CDA) après export de la copie figée.
L'erreur « indisponible » est injectée sans exécution native. Le cas CDA différent
injecte des octets distincts, puis utilise les contrôles natifs. Aucun transport
DMP n'est implémenté. La réouverture lit le résultat sauvegardé sans relancer les
validateurs ; les rapports bruts restent archivés par le coordinateur.
