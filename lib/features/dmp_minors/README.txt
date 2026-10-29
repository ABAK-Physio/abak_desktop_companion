Mineurs et connexion secrète — banc local uniquement

Accès : Paramètres > Configuration > DMP — mineurs et connexion secrète simulés.
Aucun transport, aucune CPS, aucun INS ni accès à la base INSi. Les identités sont un enum fermé de patients fictifs. La date de référence est le 16 octobre 2026 ; les scénarios utilisent aussi la veille et le lendemain.

MinorContext accepte DmpParameters par injection. L'écran fournit des paramètres fictifs ; aucun cache réel ni officiel n'est lu. L'âge est calculé indépendamment de l'activation des fonctions mineurs. Aucun seuil minimum optionnel n'est appliqué.

MinorSession demande un choix normal/secret explicite lorsque le contexte est mineur et la fonction activée. Une modification du contexte ou de l'opposition invalide les aperçus. Le secret impose l'invisibilité aux RL sans modifier les droits de consultation. Aucun jeton VIHF ou document CDA utilisable n'est généré.

Visibilité patient et RL distinctes et irréversibles : rendre visible exige confirmation pour un document existant ; remasquage bloqué, y compris remplacement. Un document déjà visible RL ne peut être remplacé en secret. Le cumul invisible patient/masqué PS suit le paramètre injecté. L'opposition bloque les nouveaux dépôts simulés. Ce banc ne remplace pas les autres contrôles TD0.2 ou droits fonctionnels des parcours réels.

Stockage : support applicatif / dmp-minors-simulation-v1 / interactif / documents-fictifs.json. Ne contient que des documents SIM-, leur patient fictif et visibilité ; jamais le choix de session. Écriture atomique, contrôle des états antérieurs avant sauvegarde. Stockage corrompu : refus sans écrasement. Usage mono-processus du banc, pas un stockage clinique.
Scénarios : nouveaux sous-dossiers dans scenarios à chaque exécution. Les tests automatisés utilisent des dossiers temporaires distincts. Les preuves durables de cette exécution sont dans le dossier de suivi du projet DMP.

Contrôle manuel conseillé : lancer les 23 scénarios ; choisir secret ; constater le contrôle RL désactivé ; préparer/conserver un document fictif ; fermer/réouvrir : document conservé et nouveau choix requis. En connexion normale, rendre visible après confirmation ; un remplacement en secret doit ensuite être refusé. Pour recommencer sur un document vierge, utiliser un autre patient fictif : aucun bouton de remise à zéro de visibilité n'est proposé.

Limites : simulation sémantique, pas de validation du XML VIHF/métadonnées, pas de preuve DV1, pas de validation globale PRE_MODE_CNXSC. L'exception séjour/acte multi-jours et l'option EX_0.1-1115 ne sont pas implémentées.
