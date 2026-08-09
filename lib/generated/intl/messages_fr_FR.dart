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

  static String m0(error) => "Erreur lors de la sauvegarde : ${error}";

  static String m1(count) => "${count} autre(s) exercice(s)";

  static String m2(count) => "${count} association(s) en attente";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "close": MessageLookupByLibrary.simpleMessage("Fermer"),
        "dashboardTitle": MessageLookupByLibrary.simpleMessage(
            "Station clinique locale ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Adresse"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Port"),
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
            "Cet écran est l\'écran principal d\'ABAK Companion.\nIl est constitué :\n- d\'un bandeau qui vous informe sur le nombre de patients actifs et archivés.\n- du nombe d\'alertes en cours.\nVous pouvez dans les paramètres renseigner le nom de votre établissement et ajouter votre logo.\n\nLa zone Imports récents vous indique les dernier dossier de résultats importés depuis ABAL Mobile.\nEtat système vous indique un éventuel problème et la date de la dernière sauvegarde.\nNouveau résultats ABAK à associer vous montre les résultats qui ont été envoyé mais qui ne sont pas encore attribués à un patient.\nAlerte système vous renseingne sur la nature d\'un problème.\nAction rapide vous permet d\'accéder à l\'historique de tous vos imports et de créer une nouvelle sauvegarde."),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Vous trouvez ici l\'identification de votre patient"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet :\n - La sélection de la langue.\n - La définition de la duré de consevation des dossiers patients archivés.\n - L\'activation du mode expertı\n - L\'accession à l\'écrran Etablissement pour saisir le nom de votre établisement et son logo"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "Cet écran vous permet d\'ajouter un nouveau praticien, de modifier les informations le concernant.\n\nLa mise dans la corbeille ne supprime pas le praticien. Pour des raisons de traçabilité il n\'est pas possible de supprimer un praticien.\n\nL\'affichage du QR Code vous permet de créer atutomatiquement le profil du praticien pour votre établissement dans le téléphone ou la tablette de celui-ci."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Vous trouvez ici les différentes prises en charge de votre patient\\Vous pouvez utiliser un épisode existant\\Vous pouvez en créer un nouveau"),
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
        "home_error_while_saving": m0,
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
        "home_other_exercises": m1,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Chemin"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patient ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patients"),
        "home_pending_association": m2,
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
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Langue enregistrée."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Langue de l\'application"),
        "loading": MessageLookupByLibrary.simpleMessage("Chargement..."),
        "modify": MessageLookupByLibrary.simpleMessage("Modifier"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Aucun dossier défini"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "open": MessageLookupByLibrary.simpleMessage("Ouvrir"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Associer un téléphone"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Associer un téléphone"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scannez ce QR code depuis ABAK Mobile pour configurer automatiquement la connexion au Desktop."),
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Créer un praticien"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Liste des praticiens"),
        "refreshDashboard": MessageLookupByLibrary.simpleMessage(
            "Actualiser le tableau de bord"),
        "reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
        "smartCardDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnostic Carte Vitale"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Paramètres utilisateur"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Paramètres utilisateur")
      };
}
