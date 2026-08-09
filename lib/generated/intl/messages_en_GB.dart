// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_GB locale. All the
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
  String get localeName => 'en_GB';

  static String m0(error) => "Error while saving: ${error}";

  static String m1(count) => "${count} other exercise(s)";

  static String m2(count) => "${count} pending association(s)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "dashboardTitle":
            MessageLookupByLibrary.simpleMessage("ABAK Local Clinical Center"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Address"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Port"),
        "exchangeDirectoryReset":
            MessageLookupByLibrary.simpleMessage("Exchange Folder Reset"),
        "exchangeDirectoryUpdated":
            MessageLookupByLibrary.simpleMessage("Updated ABAK Exchange File"),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("ARB prefix"),
        "g_close": MessageLookupByLibrary.simpleMessage("Close"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Comment"),
        "g_context": MessageLookupByLibrary.simpleMessage("Background"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "g_file": MessageLookupByLibrary.simpleMessage("File"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Technical Information"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Copied technical information"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Archived patients can be restored up to the specified date.\nAfter that date, they are automatically deleted to prevent unused records from being stored indefinitely.\nThe retention period can be changed in the Companion settings."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "You can create, edit, or archive a device.\n\nFor traceability purposes, you cannot delete a device.\nIf necessary, you can restore it.\n\nThe QR code is used to pair a phone or tablet."),
        "help_device_list_title":
            MessageLookupByLibrary.simpleMessage("List of Devices"),
        "help_donnees_cliniques_patient": MessageLookupByLibrary.simpleMessage(
            "Here you will find additional information about your patient"),
        "help_home": MessageLookupByLibrary.simpleMessage(
            "This screen is the main screen of ABAK Companion.\nIt consists of:\n- a banner that shows the number of active and archived patients.\n- the number of active alerts.\nIn the settings, you can enter the name of your facility and add your logo.\n\nThe \"Recent Imports\" section shows you the most recent result files imported from ABAL Mobile.\n\"System Status\" alerts you to any issues and displays the date of the last backup.\n\"New ABAK Results to Assign\" shows you results that have been sent but not yet assigned to a patient.\n\"System Alert\" informs you of the nature of any issues.\n\"Quick Action\" allows you to access the history of all your imports and create a new backup."),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Here you will find your patient\'s identification information"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to:\n - Select the language.\n - Set the retention period for archived patient records.\n - Enable expert mode.\n - Access the \"Facility\" screen to enter your facility\'s name and logo"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to add a new practitioner or edit their information.\n\nMoving a practitioner to the trash does not delete them. For traceability purposes, it is not possible to delete a practitioner.\n\nScanning the QR code allows you to automatically create the practitioner’s profile for your facility on their phone or tablet."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Here you\'ll find the various care plans for your patient. You can use an existing care plan, or you can create a new one."),
        "home_abak_exercice":
            MessageLookupByLibrary.simpleMessage("ABAK Exercise"),
        "home_abak_file": MessageLookupByLibrary.simpleMessage("ABAK File"),
        "home_accueil": MessageLookupByLibrary.simpleMessage("Home"),
        "home_action_required": MessageLookupByLibrary.simpleMessage(
            "Action required: Link this file to a patient."),
        "home_already_imported":
            MessageLookupByLibrary.simpleMessage("Already imported"),
        "home_an_intervention_is_necessary":
            MessageLookupByLibrary.simpleMessage("Action is needed"),
        "home_archives": MessageLookupByLibrary.simpleMessage("Archives"),
        "home_attention": MessageLookupByLibrary.simpleMessage("Attention"),
        "home_backup_successfully_created":
            MessageLookupByLibrary.simpleMessage(
                "Backup created successfully."),
        "home_balance_sheet_date":
            MessageLookupByLibrary.simpleMessage("Balance Sheet Date"),
        "home_conflict_detected":
            MessageLookupByLibrary.simpleMessage("Conflict Detected"),
        "home_create_a_backup":
            MessageLookupByLibrary.simpleMessage("Create a backup"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Date not provided"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Devices"),
        "home_error_while_saving": m0,
        "home_everything_is_working_normally":
            MessageLookupByLibrary.simpleMessage(
                "Everything is working normally"),
        "home_expert_comment": MessageLookupByLibrary.simpleMessage(
            "This screen is the main screen of Companion."),
        "home_failure": MessageLookupByLibrary.simpleMessage("Failure"),
        "home_fermer": MessageLookupByLibrary.simpleMessage("Close"),
        "home_file": MessageLookupByLibrary.simpleMessage("File"),
        "home_historique": MessageLookupByLibrary.simpleMessage("History"),
        "home_home": MessageLookupByLibrary.simpleMessage("Home"),
        "home_import_history":
            MessageLookupByLibrary.simpleMessage("Import History"),
        "home_imports_interrupted_or_in_progress":
            MessageLookupByLibrary.simpleMessage(
                "Imports that have been suspended or are in progress"),
        "home_imports_with_errors":
            MessageLookupByLibrary.simpleMessage("Incorrect imports"),
        "home_information": MessageLookupByLibrary.simpleMessage("About"),
        "home_invalid_file_path":
            MessageLookupByLibrary.simpleMessage("Invalid file path:"),
        "home_ipAddressNotFound":
            MessageLookupByLibrary.simpleMessage("IP address not found"),
        "home_ipAddressNotFoundMessage": MessageLookupByLibrary.simpleMessage(
            "Unable to determine the Desktop\'s local IP address.\n\nVerify that the computer is connected to the local network."),
        "home_large_number_of_archived_patients":
            MessageLookupByLibrary.simpleMessage(
                "A large number of archived patients"),
        "home_large_sqlite_database":
            MessageLookupByLibrary.simpleMessage("Large SQLite database"),
        "home_last_backup": MessageLookupByLibrary.simpleMessage("Last backup"),
        "home_last_old_backup":
            MessageLookupByLibrary.simpleMessage("Last older backup"),
        "home_link_to_a_care_plan":
            MessageLookupByLibrary.simpleMessage("Incorporate into treatment"),
        "home_more_7_days":
            MessageLookupByLibrary.simpleMessage("More than 7 days"),
        "home_new_abak_results_to_be_linked":
            MessageLookupByLibrary.simpleMessage(
                "New ABAK results to be linked to a patient"),
        "home_no_abak_result_to_associate":
            MessageLookupByLibrary.simpleMessage("No ABAK results to display."),
        "home_no_alert_detected":
            MessageLookupByLibrary.simpleMessage("No alerts detected"),
        "home_no_imports_recorded":
            MessageLookupByLibrary.simpleMessage("No imports recorded."),
        "home_no_pending_imports":
            MessageLookupByLibrary.simpleMessage("No pending imports"),
        "home_no_saved_backup":
            MessageLookupByLibrary.simpleMessage("No backups saved"),
        "home_not_specified": MessageLookupByLibrary.simpleMessage("informed"),
        "home_octets": MessageLookupByLibrary.simpleMessage("Octets"),
        "home_other_exercises": m1,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Settings"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Path"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patient ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patients"),
        "home_pending_association": m2,
        "home_practitioners":
            MessageLookupByLibrary.simpleMessage("practitioners"),
        "home_quick_actions":
            MessageLookupByLibrary.simpleMessage("Quick Actions"),
        "home_receents_imports":
            MessageLookupByLibrary.simpleMessage("Recent Imports"),
        "home_recent_restoration_detected":
            MessageLookupByLibrary.simpleMessage("Recent restoration detected"),
        "home_results": MessageLookupByLibrary.simpleMessage("Results"),
        "home_select_qr_code": MessageLookupByLibrary.simpleMessage(
            "Scan this QR code using ABAK Mobile to automatically set up the connection to Desktop."),
        "home_settings": MessageLookupByLibrary.simpleMessage("Assistance"),
        "home_size": MessageLookupByLibrary.simpleMessage("Size"),
        "home_solve": MessageLookupByLibrary.simpleMessage("Solve"),
        "home_success": MessageLookupByLibrary.simpleMessage("Success"),
        "home_system_alert":
            MessageLookupByLibrary.simpleMessage("System Alert"),
        "home_system_status":
            MessageLookupByLibrary.simpleMessage("System Status"),
        "home_technical_information":
            MessageLookupByLibrary.simpleMessage("Technical Information"),
        "home_this_file_had_already_been_imported":
            MessageLookupByLibrary.simpleMessage(
                "This file had already been imported. No data was added."),
        "home_to_be_verified":
            MessageLookupByLibrary.simpleMessage("to be verified"),
        "home_to_do_list": MessageLookupByLibrary.simpleMessage("To Do"),
        "home_unable_to_load_recent_imports":
            MessageLookupByLibrary.simpleMessage(
                "Unable to load recent imports."),
        "home_unreadable_abak_import":
            MessageLookupByLibrary.simpleMessage("Unreadable ABAK import."),
        "home_unsuccessful": MessageLookupByLibrary.simpleMessage("Stalled"),
        "home_verify": MessageLookupByLibrary.simpleMessage("Check"),
        "home_very_large_backups":
            MessageLookupByLibrary.simpleMessage("Very large backups"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Language saved."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Application Language"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "modify": MessageLookupByLibrary.simpleMessage("Edit"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("No folder specified"),
        "ok": MessageLookupByLibrary.simpleMessage("Okay"),
        "open": MessageLookupByLibrary.simpleMessage("Open"),
        "pairPhone": MessageLookupByLibrary.simpleMessage("Pair a phone"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Pair a phone"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scan this QR code using ABAK Mobile to automatically set up the connection to Desktop."),
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Create a practitioner"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("List of Practitioners"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Refresh the dashboard"),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "smartCardDiagnostic":
            MessageLookupByLibrary.simpleMessage("Vitale Card Diagnosis"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("User Settings"),
        "user_settings": MessageLookupByLibrary.simpleMessage("User Settings")
      };
}
