Composant DMP isolé — paramètres et nomenclatures

DmpResources exige un ResourceTransport injecté ; aucune implémentation réseau n’est fournie. L’horloge et ResourceStore sont également injectés. FileResourceStore écrit uniquement dans le dossier explicitement fourni. Utiliser un seul propriétaire du stockage par processus ; la coordination entre plusieurs processus n’est pas implémentée.

Le futur appelant doit invoquer refreshIfDue au démarrage et périodiquement pendant son fonctionnement. due signale une échéance de sept jours ou un changement de source. Aucun planificateur ni appel de démarrage de l’application n’est activé dans cette intégration isolée. Le programme n’assure pas une mise à jour lorsqu’il est arrêté.

Un échec conserve la dernière configuration valide sans renouveler sa date. hasUsableParameters ne signifie pas que le cache est récent : l’appelant doit afficher due/lastSuccess et définir sa politique de cache périmé avant tout raccordement métier réel. L’absence de paramètres doit bloquer les fonctions qui en dépendent ; ce composant ne commande pas de boutons existants.

Les paramètres sont validés avant sauvegarde. Stockage temporaire puis renommage, état mémoire activé après commit. Après un incident, un fichier .pending isolé n’est jamais pris pour le cache actif. L’intégrité SHA256 détecte une divergence locale ; elle n’authentifie pas un éditeur. Le transport futur devra vérifier TLS et provenance officielle. Les destinations sont des hôtes HTTPS explicitement autorisés.

Les tickets de mise à jour écartent les réponses anciennes arrivées après une demande plus récente. Ils ne comparent pas des versions de nomenclature comme des nombres : un retour volontaire de version demande une nouvelle décision de l’éditeur.

NosImport adapte le format JDV .tabs archivé en catalogue normalisé. Les associations X16 et A12 sont évaluées hors réseau. Le format JSON du catalogue est interne à ABAK, pas un format officiel NOS. Les lignes JDV présentes sont considérées éligibles ; pour une mise à jour de retrait, le paquet normalisé peut porter active=false. Ne jamais réécrire les anciennes métadonnées ou signatures avec les nouveaux libellés.

La collection de tests dmp_resources_test.dart couvre les 31 scénarios préparés, avec dossiers temporaires détruits après chaque test. Les fixtures XML/JSON TEST sont synthétiques. Les trois fichiers NOS copiés sont des instantanés de référence : leur présence n’atteste pas leur fraîcheur en ligne.

Aucun écran ajouté, aucun transport réseau, aucune intégration CPS ou INSi, aucune activation sur des lots réels. Suite proposée : raccordement d’une interface locale affichant état, source, date, échec et cache périmé ; toujours avec services simulés avant tout transport réel.

Raccordement interface et minuteur — 16/10/2026
ResourcesScreen est accessible depuis les réglages via « DMP — paramètres et nomenclatures simulés ». Il construit exclusivement SimulatedResourceTransport, avec un stockage distinct dmp-resources-simulation-v1 sous le support applicatif. Aucun choix de serveur réel n’est exposé.
ResourcesController vérifie à l’ouverture, à la reprise de l’application et chaque minute pendant la vie de cet écran. Si le cache est récent, aucun appel simulé n’est effectué. Une opération en cours bloque les commandes concurrentes. Fermer l’écran détruit le minuteur et invalide les réponses en attente avant toute activation du cache. Le minuteur n’est pas global : aucun traitement DMP ne démarre au lancement général d’ABAK ou lorsque cet écran est fermé.
L’avance de sept jours ne modifie que l’horloge injectée dans la session de simulation. Une date de succès future au prochain lancement est considérée comme nécessitant une nouvelle vérification. Les nomenclatures fictives se chargent par une action explicite ; la cadence hebdomadaire n’est pas appliquée arbitrairement aux JDV.
L’état des paramètres et le diagnostic de catalogue sont présentés séparément. L’interface n’autorise aucun envoi de lot. Les consommateurs métier réels restent hors de ce branchement simulé.

Correction des messages — 16/10/2026
L’écran sépare explicitement l’état du cache (absent/invalide, valide à revérifier, valide avant échéance) du résultat de la dernière tentative. Un refus ne change pas la date du dernier succès et reste affiché jusqu’à une nouvelle tentative. La vérification périodique sans échéance n’efface pas cet échec. Les diagnostics techniques parametersDiagnostic/catalogDiagnostic restent en mémoire et ne sont pas affichés dans les messages utilisateur. Ils sont effacés lors d’un succès de la catégorie correspondante. Les erreurs de paramètres et de catalogue sont indépendantes. Une absence de catalogue ne doit jamais être décrite comme une version précédente conservée.
