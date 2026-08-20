// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr_FR locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr_FR';

  static String m0(size) => "${size}";

  static String m1(deviceName) =>
      "Voulez-vous vraiment archiver ${deviceName} ?";

  static String m2(error) => "Erreur lors de la sauvegarde : ${error}";

  static String m3(count) => "${count} autre(s) exercice(s)";

  static String m4(count) => "${count} association(s) en attente";

  static String m5(count) => "${count} sauvegardes";

  static String m6(size) => "Taille : ${size}";

  static String m7(size) => "Taille totale : ${size}";

  static String m8(version) => "Version ${version}";

  static String m9(patientName) =>
      "Voulez-vous vraiment archiver ${patientName} ? Il ne sera plus affiché dans la liste active.";

  static String m10(patientName) => "${patientName} archivé.";

  static String m11(error) => "Erreur : ${error}";

  static String m12(patientName) =>
      "${patientName} restauré dans la liste active.";

  static String m13(practitionerName) =>
      "Voulez-vous vraiment archiver ${practitionerName} ?";

  static String m14(date) => "Archivé le ${date}";

  static String m15(error) => "Erreur : ${error}";

  static String m16(professionalId) => "ID pro : ${professionalId}";

  static String m17(error) => "Erreur : ${error}";

  static String m18(error) => "Erreur lors de la réinitialisation : ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "backupHistory_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "Aucune sauvegarde enregistrée."),
        "backupHistory_fileSize": m0,
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Restaurer"),
        "backupHistory_restoreTitle": MessageLookupByLibrary.simpleMessage(
            "Restaurer cette sauvegarde ?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Cette opération remplacera totalement la base actuelle.\n\nUne sauvegarde automatique de sécurité sera créée avant restauration.\n\nContinuer ?"),
        "backupHistory_title":
            MessageLookupByLibrary.simpleMessage("Historique des sauvegardes"),
        "close": MessageLookupByLibrary.simpleMessage("Fermer"),
        "dashboardTitle": MessageLookupByLibrary.simpleMessage(
            "Station clinique locale ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Adresse"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Port"),
        "deviceForm_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Praticien associé"),
        "deviceForm_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "deviceForm_contextName":
            MessageLookupByLibrary.simpleMessage("Nouvel appareil"),
        "deviceForm_create": MessageLookupByLibrary.simpleMessage("Créer"),
        "deviceForm_deviceName":
            MessageLookupByLibrary.simpleMessage("Nom de l’appareil"),
        "deviceForm_deviceNameHint":
            MessageLookupByLibrary.simpleMessage("iPhone Claire, Pixel Marc…"),
        "deviceForm_deviceNameRequired": MessageLookupByLibrary.simpleMessage(
            "Le nom de l’appareil est obligatoire"),
        "deviceForm_editDevice":
            MessageLookupByLibrary.simpleMessage("Modifier l’appareil"),
        "deviceForm_loadingPractitionersError":
            MessageLookupByLibrary.simpleMessage(
                "Erreur lors du chargement des praticiens"),
        "deviceForm_newDevice":
            MessageLookupByLibrary.simpleMessage("Nouvel appareil"),
        "deviceForm_platform":
            MessageLookupByLibrary.simpleMessage("Plateforme"),
        "deviceForm_save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "deviceForm_sharedDevice":
            MessageLookupByLibrary.simpleMessage("Aucun / appareil partagé"),
        "deviceList_active": MessageLookupByLibrary.simpleMessage("Actifs"),
        "deviceList_archive": MessageLookupByLibrary.simpleMessage("Archiver"),
        "deviceList_archiveConfirmation": m1,
        "deviceList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archiver l’appareil"),
        "deviceList_archived": MessageLookupByLibrary.simpleMessage("Archivés"),
        "deviceList_archivedDevicesEmpty": MessageLookupByLibrary.simpleMessage(
            "La corbeille des appareils est vide pour le moment."),
        "deviceList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archivé le"),
        "deviceList_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Praticien associé"),
        "deviceList_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "deviceList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran montre la liste des appareils connectés à l’établissement"),
        "deviceList_contextName":
            MessageLookupByLibrary.simpleMessage("Liste des appareils"),
        "deviceList_edit": MessageLookupByLibrary.simpleMessage("Modifier"),
        "deviceList_error": MessageLookupByLibrary.simpleMessage("Erreur"),
        "deviceList_newDevice":
            MessageLookupByLibrary.simpleMessage("Nouvel appareil"),
        "deviceList_noArchivedDevices":
            MessageLookupByLibrary.simpleMessage("Aucun appareil archivé"),
        "deviceList_noPairedDevices":
            MessageLookupByLibrary.simpleMessage("Aucun appareil associé"),
        "deviceList_pairedDevicesExplanation":
            MessageLookupByLibrary.simpleMessage(
                "Les appareils ABAK associés à l’établissement apparaîtront ici."),
        "deviceList_platform":
            MessageLookupByLibrary.simpleMessage("Plateforme"),
        "deviceList_restore": MessageLookupByLibrary.simpleMessage("Restaurer"),
        "deviceList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Afficher le QR Code"),
        "deviceList_title":
            MessageLookupByLibrary.simpleMessage("Liste des appareils"),
        "episodeEvolution_evaluation":
            MessageLookupByLibrary.simpleMessage("évaluation"),
        "episodeEvolution_evaluations":
            MessageLookupByLibrary.simpleMessage("évaluations"),
        "episodeEvolution_first":
            MessageLookupByLibrary.simpleMessage("Première"),
        "episodeEvolution_followedExercises":
            MessageLookupByLibrary.simpleMessage("Exercices suivis"),
        "episodeEvolution_last":
            MessageLookupByLibrary.simpleMessage("Dernière"),
        "episodeEvolution_noResults": MessageLookupByLibrary.simpleMessage(
            "Aucun résultat disponible pour cet épisode."),
        "episodeEvolution_singleNumericValue":
            MessageLookupByLibrary.simpleMessage(
                "Une seule valeur chiffrée disponible"),
        "episodeEvolution_title":
            MessageLookupByLibrary.simpleMessage("Évolution de l\'épisode"),
        "episodeEvolution_viewEvolution":
            MessageLookupByLibrary.simpleMessage("Voir l\'évolution"),
        "exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Dossier d\'échange réinitialisé"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Dossier d\'échange ABAK mis à jour"),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Préfix ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Fermer"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Commentaire"),
        "g_context": MessageLookupByLibrary.simpleMessage("Contexte"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Copier"),
        "g_file": MessageLookupByLibrary.simpleMessage("Fichier"),
        "g_learn_more": MessageLookupByLibrary.simpleMessage("En savoir plus"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Informations techniques"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Informations techniques copiées"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Les patients archivés peuvent être restaurés jusqu\'à la date indiquée.\nAprès cette date, ils sont supprimés automatiquement afin de ne pas conserver indéfiniment des dossiers inutilisés.\nLa durée de conservation peut être modifiée dans les paramètres de Companion."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez créer, modifier, archiver un appareil.\n\nPour des raisons de traçabilité il n\'est pas possible de supprimer un appareil\nVous pouvez si nécessaire le restaurer.\n\nLe QR Code est utilisé pour appairer un téléphone ou une tablette."),
        "help_device_list_title":
            MessageLookupByLibrary.simpleMessage("Liste des appareils"),
        "help_donnees_cliniques_patient": MessageLookupByLibrary.simpleMessage(
            "Vous trouvez ici les données complémentaires concernant votre patient"),
        "help_home": MessageLookupByLibrary.simpleMessage(
            "Cet écran est l\'écran principal d\'ABAK Companion.\n\nIl est constitué :\n\n1) d\'un bandeau qui vous informe : \n - sur le nombre de patients actifs et archivés.\n  - du nombre d\'alertes en cours.\n\nVous pouvez dans les paramètres renseigner le nom de votre établissement et ajouter votre logo.\n\n2) \"Imports récents\" vous indique les dernier dossier de résultats importés depuis ABAK Mobile.\n\n3) \"Etat système\" vous indique un éventuel problème et la date de la dernière sauvegarde.\n\n4) \"Nouveau résultats ABAK à associer\", vous montre les résultats qui ont été envoyé depuis ABAK Mobile mais qui ne sont pas encore attribués à un patient dans ABAK Companion.\n\n5) \"Alerte système\" vous renseigne sur la nature d\'un problème.\n\n6) \"Action rapide\", vous permet d\'accéder à l\'historique de tous vos imports et de créer une nouvelle sauvegarde."),
        "help_home_active_archived_patients_content":
            MessageLookupByLibrary.simpleMessage(
                "Les patients actifs sont ceux à qui vous pouvez attribuer un résultat de test ou questionnaire.\n\nLes patients archivés sont des patients dont les informations seront prochainement supprimées de l\'ordinateur.\n\nLa suppression intervient automatiquement aprsès la date indiquée.\n\nVous pouvez :\n  - Gérer le délai de conservation dans Paramètres.\n. -Réactiver un patient archivé pour le rendre actif.\n\nLa durée de conservation est paramètrable entre 30 et 365 jours."),
        "help_home_active_archived_patients_title":
            MessageLookupByLibrary.simpleMessage("Patients actifs et archivés"),
        "help_home_import_assignment_content": MessageLookupByLibrary.simpleMessage(
            "Les tests et exercices sont réalisés sur votre téléphone (ou tablette) avecABAK Mobile.\nUne fois le test terminé, si vous avez enregistré le résultat, l\'option Dossier > Envoyer vers Desktop vous permet de transférer les informations vers ABAK Companion\n\nUn message dans Companion vous informe qu\'un dossier est arrivé et qu\'il faut l\'attribuer à un patient. Cette attribution vous conduit à sélectionner le patient puis à sélectionner l\'épisode de soin.\n\nPourquoi un tel mécanisme ?\nABAK mobile ne gère pas les dossiers patients. Sur ABAK Mobile, vous pouvez identifier le patient par un pseudo et celui ci peut être différent selon le praticien. Ce pseudo vous sert ensuite à attribuer le résultat au bon patient. Ce mécanisme permet de conserver une indépendance de fonctionnemnent entre les deux applications et préserve, autant que possible, l\'anonymat des patients sur le téléphone ou la tablette qui peuvent êtr partagés."),
        "help_home_import_assignment_title":
            MessageLookupByLibrary.simpleMessage(
                "Récupération d\'un résultats et affectation à un patient"),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Vous trouvez ici l\'identification de votre patient"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet :\n - La sélection de la langue.\n - La définition de la duré de consevation des dossiers patients archivés.\n - L\'activation du mode expertı\n - L\'accession à l\'écrran Etablissement pour saisir le nom de votre établisement et son logo"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "Cet écran vous permet d\'ajouter un nouveau praticien, de modifier les informations le concernant.\n\nLa mise dans la corbeille ne supprime pas le praticien. Pour des raisons de traçabilité il n\'est pas possible de supprimer un praticien.\n\nL\'affichage du QR Code vous permet de créer atutomatiquement le profil du praticien pour votre établissement dans le téléphone ou la tablette de celui-ci."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Vous trouvez ici les différentes prises en charge de votre patient\\Vous pouvez utiliser un épisode existant\\Vous pouvez en créer un nouveau"),
        "homeImportSummary_conflicts":
            MessageLookupByLibrary.simpleMessage("Conflits"),
        "homeImportSummary_failedFiles":
            MessageLookupByLibrary.simpleMessage("Fichiers en erreur"),
        "homeImportSummary_importDate":
            MessageLookupByLibrary.simpleMessage("Date import"),
        "homeImportSummary_importedMetrics":
            MessageLookupByLibrary.simpleMessage("Métriques importées"),
        "homeImportSummary_importedResults":
            MessageLookupByLibrary.simpleMessage("Résultats importés"),
        "homeImportSummary_open":
            MessageLookupByLibrary.simpleMessage("Ouvrir"),
        "homeImportSummary_patients":
            MessageLookupByLibrary.simpleMessage("Patients concernés"),
        "homeImportSummary_processedFiles":
            MessageLookupByLibrary.simpleMessage("Fichiers traités"),
        "homeImportSummary_skippedResults":
            MessageLookupByLibrary.simpleMessage("Résultats ignorés"),
        "homeImportSummary_title":
            MessageLookupByLibrary.simpleMessage("Dernier import ABAK"),
        "home_abak_exercice":
            MessageLookupByLibrary.simpleMessage("Exercice ABAK"),
        "home_abak_file": MessageLookupByLibrary.simpleMessage("Fichier ABAK"),
        "home_accueil": MessageLookupByLibrary.simpleMessage("Accueil"),
        "home_action_required": MessageLookupByLibrary.simpleMessage(
            "Action requise : associer ce dossier à un patient."),
        "home_already_imported":
            MessageLookupByLibrary.simpleMessage("Déjà importé"),
        "home_an_intervention_is_necessary":
            MessageLookupByLibrary.simpleMessage(
                "Une intervention est nécessaire"),
        "home_archives": MessageLookupByLibrary.simpleMessage("Archives"),
        "home_attention": MessageLookupByLibrary.simpleMessage("Attention"),
        "home_backup_successfully_created":
            MessageLookupByLibrary.simpleMessage(
                "Sauvegarde créée avec succès."),
        "home_balance_sheet_date":
            MessageLookupByLibrary.simpleMessage("Date du bilan"),
        "home_conflict_detected":
            MessageLookupByLibrary.simpleMessage("Conflit détecté"),
        "home_create_a_backup":
            MessageLookupByLibrary.simpleMessage("Créer une sauvegarde"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Date non renseignée"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Appareils"),
        "home_error_while_saving": m2,
        "home_everything_is_working_normally":
            MessageLookupByLibrary.simpleMessage("Tout fonctionne normalement"),
        "home_expert_comment": MessageLookupByLibrary.simpleMessage(
            "Cet écran est l\'écran principal de Companion."),
        "home_failure": MessageLookupByLibrary.simpleMessage("Échec"),
        "home_fermer": MessageLookupByLibrary.simpleMessage("Fermer"),
        "home_file": MessageLookupByLibrary.simpleMessage("Fichier"),
        "home_historique": MessageLookupByLibrary.simpleMessage("Historique"),
        "home_home": MessageLookupByLibrary.simpleMessage("Accueil"),
        "home_import_history":
            MessageLookupByLibrary.simpleMessage("Historique des imports"),
        "home_imports_interrupted_or_in_progress":
            MessageLookupByLibrary.simpleMessage(
                "Imports interrompus ou en cours"),
        "home_imports_with_errors":
            MessageLookupByLibrary.simpleMessage("Imports en erreur"),
        "home_information": MessageLookupByLibrary.simpleMessage("A propos"),
        "home_invalid_file_path": MessageLookupByLibrary.simpleMessage(
            "Chemin du fichier invalide :"),
        "home_ipAddressNotFound":
            MessageLookupByLibrary.simpleMessage("Adresse IP introuvable"),
        "home_ipAddressNotFoundMessage": MessageLookupByLibrary.simpleMessage(
            "Impossible de déterminer l\'adresse IP locale du Desktop.\n\nVérifiez que l\'ordinateur est connecté au réseau local."),
        "home_large_number_of_archived_patients":
            MessageLookupByLibrary.simpleMessage(
                "Nombre important de patients archivés"),
        "home_large_sqlite_database":
            MessageLookupByLibrary.simpleMessage("Base SQLite volumineuse"),
        "home_last_backup":
            MessageLookupByLibrary.simpleMessage("Dernière sauvegarde"),
        "home_last_old_backup": MessageLookupByLibrary.simpleMessage(
            "Dernière sauvegarde ancienne"),
        "home_link_to_a_care_plan": MessageLookupByLibrary.simpleMessage(
            "Associer à une prise en charge"),
        "home_more_7_days":
            MessageLookupByLibrary.simpleMessage("Plus de 7 jours"),
        "home_new_abak_results_to_be_linked":
            MessageLookupByLibrary.simpleMessage(
                "Nouveaux résultats ABAK à associer à un patient"),
        "home_no_abak_result_to_associate":
            MessageLookupByLibrary.simpleMessage(
                "Aucun résultat ABAK à associer."),
        "home_no_alert_detected":
            MessageLookupByLibrary.simpleMessage("Aucune alerte détectée"),
        "home_no_imports_recorded":
            MessageLookupByLibrary.simpleMessage("Aucun import enregistré."),
        "home_no_pending_imports":
            MessageLookupByLibrary.simpleMessage("Aucun import en attente"),
        "home_no_saved_backup": MessageLookupByLibrary.simpleMessage(
            "Aucune sauvegarde enregistrée"),
        "home_not_specified":
            MessageLookupByLibrary.simpleMessage("renseignée"),
        "home_octets": MessageLookupByLibrary.simpleMessage("Octets"),
        "home_other_exercises": m3,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Chemin"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patient ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patients"),
        "home_pending_association": m4,
        "home_practitioners":
            MessageLookupByLibrary.simpleMessage("praticiens"),
        "home_quick_actions":
            MessageLookupByLibrary.simpleMessage("Actions rapides"),
        "home_receents_imports":
            MessageLookupByLibrary.simpleMessage("Imports récents"),
        "home_recent_restoration_detected":
            MessageLookupByLibrary.simpleMessage(
                "Restauration récente détectée"),
        "home_results": MessageLookupByLibrary.simpleMessage("Résultats"),
        "home_select_qr_code": MessageLookupByLibrary.simpleMessage(
            "Scannez ce QR code depuis ABAK Mobile pour configurer automatiquement la connexion au Desktop."),
        "home_settings": MessageLookupByLibrary.simpleMessage("Assistance"),
        "home_size": MessageLookupByLibrary.simpleMessage("Taille"),
        "home_solve": MessageLookupByLibrary.simpleMessage("Résoudre"),
        "home_success": MessageLookupByLibrary.simpleMessage("Succès"),
        "home_system_alert":
            MessageLookupByLibrary.simpleMessage("Alerte système"),
        "home_system_status":
            MessageLookupByLibrary.simpleMessage("État système"),
        "home_technical_information":
            MessageLookupByLibrary.simpleMessage("Informations techniques"),
        "home_this_file_had_already_been_imported":
            MessageLookupByLibrary.simpleMessage(
                "Ce fichier avait déjà été importé. Aucune donnée n\'a été ajoutée."),
        "home_to_be_verified":
            MessageLookupByLibrary.simpleMessage("à vérifier"),
        "home_to_do_list": MessageLookupByLibrary.simpleMessage("À faire"),
        "home_unable_to_load_recent_imports":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de charger les imports récents."),
        "home_unreadable_abak_import":
            MessageLookupByLibrary.simpleMessage("Import ABAK illisible."),
        "home_unsuccessful": MessageLookupByLibrary.simpleMessage("En échec"),
        "home_verify": MessageLookupByLibrary.simpleMessage("Vérifier"),
        "home_very_large_backups": MessageLookupByLibrary.simpleMessage(
            "Sauvegardes très volumineuses"),
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("fichier"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("fichiers"),
        "importResolutionAssistant_import":
            MessageLookupByLibrary.simpleMessage("Import"),
        "importResolutionAssistant_importFailed":
            MessageLookupByLibrary.simpleMessage("Import en échec"),
        "importResolutionAssistant_importToComplete":
            MessageLookupByLibrary.simpleMessage("Import à terminer"),
        "importResolutionAssistant_importToReview":
            MessageLookupByLibrary.simpleMessage("Import à vérifier"),
        "importResolutionAssistant_inError":
            MessageLookupByLibrary.simpleMessage("en erreur"),
        "importResolutionAssistant_interventionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Une intervention est nécessaire pour terminer cet import."),
        "importResolutionAssistant_loadingError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de charger les imports"),
        "importResolutionAssistant_noProblem":
            MessageLookupByLibrary.simpleMessage(
                "Aucun problème d’import détecté."),
        "importResolutionAssistant_result":
            MessageLookupByLibrary.simpleMessage("résultat"),
        "importResolutionAssistant_results":
            MessageLookupByLibrary.simpleMessage("résultats"),
        "importResolutionAssistant_selectImportInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Sélectionnez un import pour afficher son détail et suivre les étapes proposées."),
        "importResolutionAssistant_title": MessageLookupByLibrary.simpleMessage(
            "Résolution des problèmes d’import"),
        "importResolutionAssistant_toReview":
            MessageLookupByLibrary.simpleMessage("à vérifier"),
        "information_backupCount": m5,
        "information_backups":
            MessageLookupByLibrary.simpleMessage("Sauvegardes"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Configuré"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran affiche les informations générales, techniques et légales de Companion."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Informations"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Base de données"),
        "information_language": MessageLookupByLibrary.simpleMessage("Langue"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Avertissement légal"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Chargement..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Stockage local"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Non configuré"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Non renseigné"),
        "information_office": MessageLookupByLibrary.simpleMessage("Cabinet"),
        "information_size": m6,
        "information_system": MessageLookupByLibrary.simpleMessage("Système"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Informations"),
        "information_totalSize": m7,
        "information_version": m8,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Version..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("Consulter la licence"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Langue enregistrée."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Langue de l\'application"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Avertissement"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion est un logiciel d’aide à l’organisation, à l’importation et à la consultation de résultats cliniques issus de l’écosystème ABAK.\n\nIl ne constitue pas un dispositif médical certifié et ne remplace pas le jugement du professionnel de santé.\n\nLes résultats, scores, comptes rendus et indicateurs affichés doivent toujours être interprétés par un professionnel qualifié, en tenant compte de l’examen clinique, du contexte du patient et des recommandations en vigueur.\n\nL’utilisateur reste seul responsable de ses décisions cliniques, de la vérification des données importées et de la conformité de leur utilisation avec les règles professionnelles, réglementaires et déontologiques applicables.\n\nABAK Desktop Companion ne réalise pas de diagnostic autonome, ne prescrit aucun traitement et ne se substitue en aucun cas à une consultation médicale ou paramédicale."),
        "legalNotice_title":
            MessageLookupByLibrary.simpleMessage("Avertissement Légal"),
        "loading": MessageLookupByLibrary.simpleMessage("Chargement..."),
        "localDatabaseBackup_cancelled":
            MessageLookupByLibrary.simpleMessage("Sauvegarde annulée."),
        "localDatabaseBackup_chooseBackupFolder":
            MessageLookupByLibrary.simpleMessage(
                "Choisir le dossier de sauvegarde ABAK"),
        "localDatabaseBackup_databaseNotFound":
            MessageLookupByLibrary.simpleMessage("Base SQLite introuvable."),
        "localDatabaseReset_backupFailed": MessageLookupByLibrary.simpleMessage(
            "Sauvegarde préalable impossible"),
        "main_alreadyRunningMessage": MessageLookupByLibrary.simpleMessage(
            "Une seule instance peut être ouverte à la fois.\n\nUtilisez la fenêtre Companion déjà ouverte."),
        "main_alreadyRunningTitle": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion est déjà ouvert"),
        "main_close": MessageLookupByLibrary.simpleMessage(""),
        "modify": MessageLookupByLibrary.simpleMessage("Modifier"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Aucun dossier défini"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "open": MessageLookupByLibrary.simpleMessage("Ouvrir"),
        "organization_chooseLogo":
            MessageLookupByLibrary.simpleMessage("Choisir un logo"),
        "organization_identityTitle":
            MessageLookupByLibrary.simpleMessage("Identité de l’établissement"),
        "organization_logoRemoved": MessageLookupByLibrary.simpleMessage(
            "Logo de l’établissement supprimé."),
        "organization_logoSaved": MessageLookupByLibrary.simpleMessage(
            "Logo de l’établissement enregistré."),
        "organization_nameLabel":
            MessageLookupByLibrary.simpleMessage("Nom de l’établissement"),
        "organization_nameSaved": MessageLookupByLibrary.simpleMessage(
            "Nom de l’établissement enregistré."),
        "organization_removeLogo":
            MessageLookupByLibrary.simpleMessage("Supprimer le logo"),
        "organization_saveName":
            MessageLookupByLibrary.simpleMessage("Enregistrer le nom"),
        "organization_title":
            MessageLookupByLibrary.simpleMessage("Établissement"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Associer un téléphone"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Associer un téléphone"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scannez ce QR code depuis ABAK Mobile pour configurer automatiquement la connexion au Desktop."),
        "patientList_active": MessageLookupByLibrary.simpleMessage("Actifs"),
        "patientList_archive": MessageLookupByLibrary.simpleMessage("Archiver"),
        "patientList_archiveConfirmation": m9,
        "patientList_archiveSuccess": m10,
        "patientList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archiver le patient"),
        "patientList_archived":
            MessageLookupByLibrary.simpleMessage("Archivés"),
        "patientList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archivé le"),
        "patientList_archivedPatient":
            MessageLookupByLibrary.simpleMessage("Patient archivé"),
        "patientList_archivedPatientsEmpty":
            MessageLookupByLibrary.simpleMessage(
                "La corbeille des patients est vide pour le moment."),
        "patientList_bornOn": MessageLookupByLibrary.simpleMessage("Né(e) le"),
        "patientList_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "patientList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez afficher la liste des patients actifs et ceux archivés"),
        "patientList_contextName":
            MessageLookupByLibrary.simpleMessage("Liste des patients"),
        "patientList_edit": MessageLookupByLibrary.simpleMessage("Modifier"),
        "patientList_error": m11,
        "patientList_newPatient":
            MessageLookupByLibrary.simpleMessage("Nouveau patient"),
        "patientList_noArchivedPatients":
            MessageLookupByLibrary.simpleMessage("Aucun patient archivé"),
        "patientList_noPatientFound":
            MessageLookupByLibrary.simpleMessage("Aucun patient trouvé"),
        "patientList_noRegisteredPatients":
            MessageLookupByLibrary.simpleMessage("Aucun patient enregistré"),
        "patientList_patientFileEmpty": MessageLookupByLibrary.simpleMessage(
            "Le fichier patient local est vide pour le moment."),
        "patientList_restorableUntil":
            MessageLookupByLibrary.simpleMessage("Restaurable jusqu’au"),
        "patientList_restore":
            MessageLookupByLibrary.simpleMessage("Restaurer"),
        "patientList_restoreSuccess": m12,
        "patientList_searchPatient":
            MessageLookupByLibrary.simpleMessage("Rechercher un patient"),
        "patientList_sex": MessageLookupByLibrary.simpleMessage("Sexe"),
        "patientList_title":
            MessageLookupByLibrary.simpleMessage("Liste des patients"),
        "practitionerList_active":
            MessageLookupByLibrary.simpleMessage("Actifs"),
        "practitionerList_addPractitionersHint":
            MessageLookupByLibrary.simpleMessage(
                "Ajoutez les kinés du cabinet pour identifier les tests importés."),
        "practitionerList_archive":
            MessageLookupByLibrary.simpleMessage("Archiver"),
        "practitionerList_archiveConfirmation": m13,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "La corbeille des kinés est vide pour le moment."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage("Archiver le kiné"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archivés"),
        "practitionerList_archivedOn": m14,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Créer un praticien"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Annuler"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran affiche la liste des praticiens enregistrés."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("Liste des praticiens"),
        "practitionerList_edit":
            MessageLookupByLibrary.simpleMessage("Modifier"),
        "practitionerList_error": m15,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage("Aucun kiné archivé"),
        "practitionerList_noPractitioner":
            MessageLookupByLibrary.simpleMessage("Aucun kiné enregistré"),
        "practitionerList_professionalId": m16,
        "practitionerList_restore":
            MessageLookupByLibrary.simpleMessage("Restaurer"),
        "practitionerList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Afficher le QR Code"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Liste des praticiens"),
        "practitionerNew_cancel":
            MessageLookupByLibrary.simpleMessage("Annuler"),
        "practitionerNew_cet_ecran_permet":
            MessageLookupByLibrary.simpleMessage(
                "Cet écran permet de créer un praticien."),
        "practitionerNew_create": MessageLookupByLibrary.simpleMessage("Créer"),
        "practitionerNew_displayName":
            MessageLookupByLibrary.simpleMessage("Nom affiché"),
        "practitionerNew_displayNameRequired":
            MessageLookupByLibrary.simpleMessage(
                "Le nom affiché est obligatoire"),
        "practitionerNew_editPractitioner":
            MessageLookupByLibrary.simpleMessage("Modifier le praticien"),
        "practitionerNew_email": MessageLookupByLibrary.simpleMessage("Email"),
        "practitionerNew_firstName":
            MessageLookupByLibrary.simpleMessage("Prénom"),
        "practitionerNew_lastName": MessageLookupByLibrary.simpleMessage("Nom"),
        "practitionerNew_newPractitioner":
            MessageLookupByLibrary.simpleMessage("Nouveau praticien"),
        "practitionerNew_phone":
            MessageLookupByLibrary.simpleMessage("Téléphone"),
        "practitionerNew_professionalId":
            MessageLookupByLibrary.simpleMessage("Identifiant professionnel"),
        "practitionerNew_professionalIdHint":
            MessageLookupByLibrary.simpleMessage("RPPS, ADELI…"),
        "practitionerNew_save":
            MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "practitionerQr_close": MessageLookupByLibrary.simpleMessage("Fermer"),
        "practitionerQr_defaultOrganizationName":
            MessageLookupByLibrary.simpleMessage("Cabinet"),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("Profil professionnel ABAK"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Scannez ce QR Code depuis ABAK Mobile afin d\'ajouter automatiquement ce profil professionnel."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("archivé"),
        "practitionerSelector_error": m17,
        "practitionerSelector_noSelection":
            MessageLookupByLibrary.simpleMessage("Aucune sélection"),
        "preferences_archivedPatients":
            MessageLookupByLibrary.simpleMessage("Patients archivés"),
        "preferences_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran centralise les paramètres généraux de Companion."),
        "preferences_contextName":
            MessageLookupByLibrary.simpleMessage("Paramètres utilisateur"),
        "preferences_days": MessageLookupByLibrary.simpleMessage("jours"),
        "preferences_expertMode":
            MessageLookupByLibrary.simpleMessage("Mode Expert"),
        "preferences_expertModeDescription": MessageLookupByLibrary.simpleMessage(
            "Affiche des informations techniques destinées aux développeurs et aux contributeurs."),
        "preferences_expertModeSaved": MessageLookupByLibrary.simpleMessage(
            "Paramètre du mode Expert enregistré."),
        "preferences_languageSaved":
            MessageLookupByLibrary.simpleMessage("Langue enregistrée."),
        "preferences_organization":
            MessageLookupByLibrary.simpleMessage("Établissement"),
        "preferences_organizationDescription":
            MessageLookupByLibrary.simpleMessage(
                "Nom, logo et informations générales."),
        "preferences_retentionDuration":
            MessageLookupByLibrary.simpleMessage("Durée de conservation"),
        "preferences_retentionExplanation": MessageLookupByLibrary.simpleMessage(
            "Les patients archivés peuvent être restaurés pendant cette durée. Ils seront ensuite supprimés automatiquement."),
        "preferences_retentionSaved": MessageLookupByLibrary.simpleMessage(
            "Durée de conservation enregistrée."),
        "recentImportCard_conflict":
            MessageLookupByLibrary.simpleMessage("conflit"),
        "recentImportCard_error":
            MessageLookupByLibrary.simpleMessage("erreur"),
        "recentImportCard_fichier":
            MessageLookupByLibrary.simpleMessage("fichier"),
        "recentImportCard_file":
            MessageLookupByLibrary.simpleMessage("fichier"),
        "recentImportCard_ignored":
            MessageLookupByLibrary.simpleMessage("ignoré"),
        "recentImportCard_no_result_imported":
            MessageLookupByLibrary.simpleMessage("Aucun résultat importé"),
        "recentImportCard_result":
            MessageLookupByLibrary.simpleMessage("résultat"),
        "refreshDashboard": MessageLookupByLibrary.simpleMessage(
            "Actualiser le tableau de bord"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Archives des rapports"),
        "reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
        "resultDetail_addCommentHint":
            MessageLookupByLibrary.simpleMessage("Ajouter un commentaire..."),
        "resultDetail_archiveConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Voulez-vous vraiment archiver ce résultat ?"),
        "resultDetail_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archiver le résultat"),
        "resultDetail_birthDate":
            MessageLookupByLibrary.simpleMessage("Naissance"),
        "resultDetail_cancel": MessageLookupByLibrary.simpleMessage("Appareil"),
        "resultDetail_clinicalComment":
            MessageLookupByLibrary.simpleMessage("Commentaire clinique"),
        "resultDetail_commentSaved":
            MessageLookupByLibrary.simpleMessage("Commentaire enregistré"),
        "resultDetail_detailedResult":
            MessageLookupByLibrary.simpleMessage("Résultat détaillé"),
        "resultDetail_device":
            MessageLookupByLibrary.simpleMessage("Détail de l\'appareil"),
        "resultDetail_exerciseDate":
            MessageLookupByLibrary.simpleMessage("Date de l\'exercice"),
        "resultDetail_generalInformation":
            MessageLookupByLibrary.simpleMessage("Informations générales"),
        "resultDetail_identityUnverified":
            MessageLookupByLibrary.simpleMessage("Identité non vérifiée"),
        "resultDetail_identityVerified":
            MessageLookupByLibrary.simpleMessage("Identité vérifiée"),
        "resultDetail_import": MessageLookupByLibrary.simpleMessage("Import"),
        "resultDetail_lastModified":
            MessageLookupByLibrary.simpleMessage("Dernière modification"),
        "resultDetail_metrics":
            MessageLookupByLibrary.simpleMessage("Métriques"),
        "resultDetail_noMetrics": MessageLookupByLibrary.simpleMessage(
            "Aucune métrique enregistrée."),
        "resultDetail_patient": MessageLookupByLibrary.simpleMessage("Patient"),
        "resultDetail_performedBy":
            MessageLookupByLibrary.simpleMessage("Réalisé par"),
        "resultDetail_save":
            MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "resultDetail_score": MessageLookupByLibrary.simpleMessage("Score"),
        "resultDetail_syncState":
            MessageLookupByLibrary.simpleMessage("État sync"),
        "settings_assistanceWarning": MessageLookupByLibrary.simpleMessage(
            "Ces fonctions sont destinées à l’installation, au diagnostic et aux opérations d’assistance technique.\n\nUtilisez-les uniquement lorsqu’un technicien ou la documentation ABAK vous le demande."),
        "settings_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "settings_configuration":
            MessageLookupByLibrary.simpleMessage("Configuration"),
        "settings_confirmationRequired":
            MessageLookupByLibrary.simpleMessage("Confirmation obligatoire"),
        "settings_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran regroupe les fonctions d’installation, de diagnostic et de maintenance de Companion."),
        "settings_contextName":
            MessageLookupByLibrary.simpleMessage("Assistance"),
        "settings_continue": MessageLookupByLibrary.simpleMessage("Continuer"),
        "settings_databaseResetError": m18,
        "settings_databaseResetSuccess": MessageLookupByLibrary.simpleMessage(
            "Base réinitialisée. Sauvegarde automatique créée."),
        "settings_diagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnostic"),
        "settings_edit": MessageLookupByLibrary.simpleMessage("Modifier"),
        "settings_exchangeDirectory":
            MessageLookupByLibrary.simpleMessage("Dossier d’échange ABAK"),
        "settings_exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Dossier d’échange réinitialisé"),
        "settings_exchangeDirectoryUpdated":
            MessageLookupByLibrary.simpleMessage(
                "Dossier d’échange ABAK mis à jour"),
        "settings_importAbakFile": MessageLookupByLibrary.simpleMessage(
            "Importer manuellement un fichier .abak"),
        "settings_invalidConfirmation":
            MessageLookupByLibrary.simpleMessage("Confirmation invalide."),
        "settings_loading":
            MessageLookupByLibrary.simpleMessage("Chargement..."),
        "settings_maintenance":
            MessageLookupByLibrary.simpleMessage("Maintenance"),
        "settings_manageBackups":
            MessageLookupByLibrary.simpleMessage("Gérer les sauvegardes"),
        "settings_noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Aucun dossier défini"),
        "settings_open": MessageLookupByLibrary.simpleMessage("Ouvrir"),
        "settings_openingExchangeDirectory":
            MessageLookupByLibrary.simpleMessage(
                "Ouverture du dossier d’échange"),
        "settings_reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
        "settings_resetDatabase":
            MessageLookupByLibrary.simpleMessage("Réinitialiser la base"),
        "settings_resetDatabaseTitle": MessageLookupByLibrary.simpleMessage(
            "Réinitialiser la base locale ?"),
        "settings_resetDatabaseWarning": MessageLookupByLibrary.simpleMessage(
            "Cette opération supprimera toutes les données locales (patients, résultats, imports et historiques).\n\nUne sauvegarde automatique sera créée avant la réinitialisation.\n\nUtilisez cette fonction uniquement lors d’une opération d’assistance technique."),
        "settings_resetKeyword": MessageLookupByLibrary.simpleMessage("RESET"),
        "settings_resetTooltip":
            MessageLookupByLibrary.simpleMessage("Réinitialiser"),
        "settings_resolveImportProblem": MessageLookupByLibrary.simpleMessage(
            "Résoudre un problème d’import"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Assistance"),
        "settings_typeResetConfirmation": MessageLookupByLibrary.simpleMessage(
            "Tapez RESET pour confirmer définitivement."),
        "settings_vitaleDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnostic Carte Vitale"),
        "smartCardDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnostic Carte Vitale"),
        "systemOverviewBar_active_patients":
            MessageLookupByLibrary.simpleMessage("Patients actifs"),
        "systemOverviewBar_alert":
            MessageLookupByLibrary.simpleMessage("Alertes"),
        "systemOverviewBar_archived_patients":
            MessageLookupByLibrary.simpleMessage("Patients archivés"),
        "systemOverviewBar_loading_system_summary":
            MessageLookupByLibrary.simpleMessage(
                "Chargement du résumé système..."),
        "systemOverviewBar_supervision_error":
            MessageLookupByLibrary.simpleMessage("Erreur supervision"),
        "systemOverviewBar_supervision_unavailable":
            MessageLookupByLibrary.simpleMessage("Supervision indisponible"),
        "systemStatusCard_nome": MessageLookupByLibrary.simpleMessage("Aucune"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Paramètres utilisateur"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Paramètres utilisateur"),
        "vitaleBeneficiarySelector_cancel":
            MessageLookupByLibrary.simpleMessage("Annuler"),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage(
                "Sélectionnez un bénéficiaire"),
        "vitaleIdentity_birthDate":
            MessageLookupByLibrary.simpleMessage("Date de naissance"),
        "vitaleIdentity_dataMasked":
            MessageLookupByLibrary.simpleMessage("donnée masquée"),
        "vitaleIdentity_detected":
            MessageLookupByLibrary.simpleMessage("détecté"),
        "vitaleIdentity_female":
            MessageLookupByLibrary.simpleMessage("Féminin"),
        "vitaleIdentity_firstName":
            MessageLookupByLibrary.simpleMessage("Prénom"),
        "vitaleIdentity_identityRead":
            MessageLookupByLibrary.simpleMessage("Identité lue"),
        "vitaleIdentity_identityReceivedMasked":
            MessageLookupByLibrary.simpleMessage(
                "identité reçue (données personnelles masquées)"),
        "vitaleIdentity_identityUnavailable":
            MessageLookupByLibrary.simpleMessage("identité non disponible"),
        "vitaleIdentity_lastName": MessageLookupByLibrary.simpleMessage("Nom"),
        "vitaleIdentity_male": MessageLookupByLibrary.simpleMessage("Masculin"),
        "vitaleIdentity_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "vitaleIdentity_noIdentityAvailable":
            MessageLookupByLibrary.simpleMessage(
                "Aucune identité Carte Vitale disponible"),
        "vitaleIdentity_notProvided":
            MessageLookupByLibrary.simpleMessage("Non renseigné"),
        "vitaleIdentity_other": MessageLookupByLibrary.simpleMessage("Autre"),
        "vitaleIdentity_reading":
            MessageLookupByLibrary.simpleMessage("Lecture en cours..."),
        "vitaleIdentity_sex": MessageLookupByLibrary.simpleMessage("Sexe"),
        "vitaleIdentity_source": MessageLookupByLibrary.simpleMessage("Source"),
        "vitaleIdentity_title":
            MessageLookupByLibrary.simpleMessage("Lire identité Carte Vitale"),
        "vitaleIdentity_unavailable":
            MessageLookupByLibrary.simpleMessage("non disponible"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Utiliser pour créer un patient")
      };
}
