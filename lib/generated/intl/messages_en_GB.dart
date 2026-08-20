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

  static String m0(size) => "${size}";

  static String m1(deviceName) =>
      "Are you sure you want to archive ${deviceName}?";

  static String m2(error) => "Error while saving: ${error}";

  static String m3(count) => "${count} other exercise(s)";

  static String m4(count) => "${count} pending association(s)";

  static String m5(count) => "${count} backups";

  static String m6(size) => "Size: ${size}";

  static String m7(size) => "Total size: ${size}";

  static String m8(version) => "Version ${version}";

  static String m9(patientName) =>
      "Are you sure you want to archive ${patientName}? They will no longer appear in the active list.";

  static String m10(patientName) => "${patientName} has been archived.";

  static String m11(error) => "Error: ${error}";

  static String m12(patientName) =>
      "${patientName} has been restored to the active list.";

  static String m13(practitionerName) =>
      "Are you sure you want to archive ${practitionerName}?";

  static String m14(date) => "Archived on ${date}";

  static String m15(error) => "Error: ${error}";

  static String m16(professionalId) => "ID pro: ${professionalId}";

  static String m17(error) => "Error: ${error}";

  static String m18(error) => "Error during reset: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "backupHistory_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "backupHistory_empty":
            MessageLookupByLibrary.simpleMessage("No backups have been saved."),
        "backupHistory_fileSize": m0,
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Restore"),
        "backupHistory_restoreTitle":
            MessageLookupByLibrary.simpleMessage("Restore this backup?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "This operation will completely replace the current database.\n\nAn automatic backup will be created before restoration.\n\nContinue?"),
        "backupHistory_title":
            MessageLookupByLibrary.simpleMessage("Backup History"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "dashboardTitle":
            MessageLookupByLibrary.simpleMessage("ABAK Local Clinical Center"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Address"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Port"),
        "deviceForm_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Associate Practitioner"),
        "deviceForm_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "deviceForm_contextName":
            MessageLookupByLibrary.simpleMessage("New device"),
        "deviceForm_create": MessageLookupByLibrary.simpleMessage("Create"),
        "deviceForm_deviceName":
            MessageLookupByLibrary.simpleMessage("Device Name"),
        "deviceForm_deviceNameHint": MessageLookupByLibrary.simpleMessage(
            "Claire\'s iPhone, Marc\'s Pixel…"),
        "deviceForm_deviceNameRequired":
            MessageLookupByLibrary.simpleMessage("The device name is required"),
        "deviceForm_editDevice":
            MessageLookupByLibrary.simpleMessage("Change the device"),
        "deviceForm_loadingPractitionersError":
            MessageLookupByLibrary.simpleMessage("Error loading practitioners"),
        "deviceForm_newDevice":
            MessageLookupByLibrary.simpleMessage("New device"),
        "deviceForm_platform": MessageLookupByLibrary.simpleMessage("Platform"),
        "deviceForm_save": MessageLookupByLibrary.simpleMessage("Save"),
        "deviceForm_sharedDevice":
            MessageLookupByLibrary.simpleMessage("None / shared device"),
        "deviceList_active": MessageLookupByLibrary.simpleMessage("Assets"),
        "deviceList_archive": MessageLookupByLibrary.simpleMessage("Archive"),
        "deviceList_archiveConfirmation": m1,
        "deviceList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archive the device"),
        "deviceList_archived": MessageLookupByLibrary.simpleMessage("Archived"),
        "deviceList_archivedDevicesEmpty": MessageLookupByLibrary.simpleMessage(
            "The device trash can is empty right now."),
        "deviceList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archived on"),
        "deviceList_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Associate Practitioner"),
        "deviceList_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "deviceList_contextComment": MessageLookupByLibrary.simpleMessage(
            "This screen displays a list of devices connected to the facility"),
        "deviceList_contextName":
            MessageLookupByLibrary.simpleMessage("List of Devices"),
        "deviceList_edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "deviceList_error": MessageLookupByLibrary.simpleMessage("Error"),
        "deviceList_newDevice":
            MessageLookupByLibrary.simpleMessage("New device"),
        "deviceList_noArchivedDevices":
            MessageLookupByLibrary.simpleMessage("No archived devices"),
        "deviceList_noPairedDevices":
            MessageLookupByLibrary.simpleMessage("No associated devices"),
        "deviceList_pairedDevicesExplanation": MessageLookupByLibrary.simpleMessage(
            "The ABAK devices associated with the institution will appear here."),
        "deviceList_platform": MessageLookupByLibrary.simpleMessage("Platform"),
        "deviceList_restore": MessageLookupByLibrary.simpleMessage("Restore"),
        "deviceList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Display the QR Code"),
        "deviceList_title":
            MessageLookupByLibrary.simpleMessage("List of Devices"),
        "episodeEvolution_evaluation":
            MessageLookupByLibrary.simpleMessage("evaluation"),
        "episodeEvolution_evaluations":
            MessageLookupByLibrary.simpleMessage("reviews"),
        "episodeEvolution_first":
            MessageLookupByLibrary.simpleMessage("Premiere"),
        "episodeEvolution_followedExercises":
            MessageLookupByLibrary.simpleMessage("Exercises Completed"),
        "episodeEvolution_last": MessageLookupByLibrary.simpleMessage("Last"),
        "episodeEvolution_noResults": MessageLookupByLibrary.simpleMessage(
            "No results available for this episode."),
        "episodeEvolution_singleNumericValue":
            MessageLookupByLibrary.simpleMessage(
                "Only one numerical value is available"),
        "episodeEvolution_title":
            MessageLookupByLibrary.simpleMessage("How the Episode Unfolds"),
        "episodeEvolution_viewEvolution":
            MessageLookupByLibrary.simpleMessage("View the trend"),
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
        "g_learn_more": MessageLookupByLibrary.simpleMessage("Learn more"),
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
            "This screen is the main screen of ABAK Companion.\n\nIt consists of:\n\n1) a header bar that provides information on:\n - the number of active and archived patients.\n  - the number of current alerts.\n\nIn the settings, you can enter the name of your facility and add your logo.\n\n2) \"Recent Imports\" shows you the most recent result files imported from ABAK Mobile.\n\n3) \"System Status\" alerts you to any issues and displays the date of the last backup.\n\n4) \"New ABAK Results to Link\" shows you the results that have been sent from ABAK Mobile but have not yet been assigned to a patient in ABAK Companion.\n\n5) \"System Alert\" informs you of the nature of any issues.\n\n6) \"Quick Action\" allows you to access the history of all your imports and create a new backup."),
        "help_home_active_archived_patients_content":
            MessageLookupByLibrary.simpleMessage("Active patients"),
        "help_home_active_archived_patients_title":
            MessageLookupByLibrary.simpleMessage(
                "Active and Archived Patients"),
        "help_home_import_assignment_content":
            MessageLookupByLibrary.simpleMessage(
                "Once you\'ve finished your exercise in ABAK Mobile..."),
        "help_home_import_assignment_title":
            MessageLookupByLibrary.simpleMessage(
                "Retrieving Results and Assigning Them to a Patient"),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Here you will find your patient\'s identification information"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to:\n - Select the language.\n - Set the retention period for archived patient records.\n - Enable expert mode.\n - Access the \"Facility\" screen to enter your facility\'s name and logo"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to add a new practitioner or edit their information.\n\nMoving a practitioner to the trash does not delete them. For traceability purposes, it is not possible to delete a practitioner.\n\nScanning the QR code allows you to automatically create the practitioner’s profile for your facility on their phone or tablet."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Here you\'ll find the various care plans for your patient. You can use an existing care plan, or you can create a new one."),
        "homeImportSummary_conflicts":
            MessageLookupByLibrary.simpleMessage("Conflicts"),
        "homeImportSummary_failedFiles":
            MessageLookupByLibrary.simpleMessage("Files with errors"),
        "homeImportSummary_importDate":
            MessageLookupByLibrary.simpleMessage("Import Data"),
        "homeImportSummary_importedMetrics":
            MessageLookupByLibrary.simpleMessage("Imported Metrics"),
        "homeImportSummary_importedResults":
            MessageLookupByLibrary.simpleMessage("Imported Results"),
        "homeImportSummary_open": MessageLookupByLibrary.simpleMessage("Open"),
        "homeImportSummary_patients":
            MessageLookupByLibrary.simpleMessage("Patients Affected"),
        "homeImportSummary_processedFiles":
            MessageLookupByLibrary.simpleMessage("Processed Files"),
        "homeImportSummary_skippedResults":
            MessageLookupByLibrary.simpleMessage("Ignored results"),
        "homeImportSummary_title":
            MessageLookupByLibrary.simpleMessage("Latest ABAK Import"),
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
        "home_error_while_saving": m2,
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
        "home_other_exercises": m3,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Settings"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Path"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patient ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patients"),
        "home_pending_association": m4,
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
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("file"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("files"),
        "importResolutionAssistant_import":
            MessageLookupByLibrary.simpleMessage("Import"),
        "importResolutionAssistant_importFailed":
            MessageLookupByLibrary.simpleMessage("Import Failed"),
        "importResolutionAssistant_importToComplete":
            MessageLookupByLibrary.simpleMessage("Import not yet complete"),
        "importResolutionAssistant_importToReview":
            MessageLookupByLibrary.simpleMessage("Import to be verified"),
        "importResolutionAssistant_inError":
            MessageLookupByLibrary.simpleMessage("by mistake"),
        "importResolutionAssistant_interventionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Action is required to complete this import."),
        "importResolutionAssistant_loadingError":
            MessageLookupByLibrary.simpleMessage("Unable to load imports"),
        "importResolutionAssistant_noProblem":
            MessageLookupByLibrary.simpleMessage("No import issues detected."),
        "importResolutionAssistant_result":
            MessageLookupByLibrary.simpleMessage("result"),
        "importResolutionAssistant_results":
            MessageLookupByLibrary.simpleMessage("results"),
        "importResolutionAssistant_selectImportInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Select an import to view its details and follow the steps provided."),
        "importResolutionAssistant_title": MessageLookupByLibrary.simpleMessage(
            "Troubleshooting Import Issues"),
        "importResolutionAssistant_toReview":
            MessageLookupByLibrary.simpleMessage("to be verified"),
        "information_backupCount": m5,
        "information_backups": MessageLookupByLibrary.simpleMessage("Backups"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Configured"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "This screen displays general, technical, and legal information about Companion."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Information"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Database"),
        "information_language":
            MessageLookupByLibrary.simpleMessage("Language"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Legal Notice"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Loading..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Local storage"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Not configured"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "information_office": MessageLookupByLibrary.simpleMessage("Office"),
        "information_size": m6,
        "information_system": MessageLookupByLibrary.simpleMessage("System"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Information"),
        "information_totalSize": m7,
        "information_version": m8,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Version..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("View the license"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Language saved."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Application Language"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Disclaimer"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion is software designed to help organize, import, and view clinical results from the ABAK ecosystem.\n\nIt is not a certified medical device and is not a substitute for a healthcare professional’s judgment.\n\nThe results, scores, reports, and indicators displayed must always be interpreted by a qualified professional, taking into account the clinical examination, the patient’s context, and current recommendations.\n\nThe user remains solely responsible for their clinical decisions, for verifying imported data, and for ensuring that its use complies with applicable professional, regulatory, and ethical standards.\n\nABAK Desktop Companion does not make independent diagnoses, prescribe any treatment, or in any way replace a medical or paramedical consultation."),
        "legalNotice_title":
            MessageLookupByLibrary.simpleMessage("Legal Notice"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "localDatabaseBackup_cancelled":
            MessageLookupByLibrary.simpleMessage("Backup canceled."),
        "localDatabaseBackup_chooseBackupFolder":
            MessageLookupByLibrary.simpleMessage(
                "Select the ABAK backup folder"),
        "localDatabaseBackup_databaseNotFound":
            MessageLookupByLibrary.simpleMessage("SQLite database not found."),
        "localDatabaseReset_backupFailed": MessageLookupByLibrary.simpleMessage(
            "Preliminary backup not possible"),
        "main_alreadyRunningMessage": MessageLookupByLibrary.simpleMessage(
            "Only one instance can be open at a time.\n\nUse the Companion window that is already open."),
        "main_alreadyRunningTitle": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion is already open"),
        "main_close": MessageLookupByLibrary.simpleMessage(""),
        "modify": MessageLookupByLibrary.simpleMessage("Edit"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("No folder specified"),
        "ok": MessageLookupByLibrary.simpleMessage("Okay"),
        "open": MessageLookupByLibrary.simpleMessage("Open"),
        "organization_chooseLogo":
            MessageLookupByLibrary.simpleMessage("Choosing a Logo"),
        "organization_identityTitle":
            MessageLookupByLibrary.simpleMessage("School Profile"),
        "organization_logoRemoved": MessageLookupByLibrary.simpleMessage(
            "The institution\'s logo has been removed."),
        "organization_logoSaved": MessageLookupByLibrary.simpleMessage(
            "Logo of the registered institution."),
        "organization_nameLabel":
            MessageLookupByLibrary.simpleMessage("Name of the institution"),
        "organization_nameSaved": MessageLookupByLibrary.simpleMessage(
            "Name of the registered institution."),
        "organization_removeLogo":
            MessageLookupByLibrary.simpleMessage("Remove the logo"),
        "organization_saveName":
            MessageLookupByLibrary.simpleMessage("Save the name"),
        "organization_title":
            MessageLookupByLibrary.simpleMessage("Establishment"),
        "pairPhone": MessageLookupByLibrary.simpleMessage("Pair a phone"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Pair a phone"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scan this QR code using ABAK Mobile to automatically set up the connection to Desktop."),
        "patientList_active": MessageLookupByLibrary.simpleMessage("Assets"),
        "patientList_archive": MessageLookupByLibrary.simpleMessage("Archive"),
        "patientList_archiveConfirmation": m9,
        "patientList_archiveSuccess": m10,
        "patientList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archive the patient"),
        "patientList_archived":
            MessageLookupByLibrary.simpleMessage("Archived"),
        "patientList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archived on"),
        "patientList_archivedPatient":
            MessageLookupByLibrary.simpleMessage("Archived Patient"),
        "patientList_archivedPatientsEmpty":
            MessageLookupByLibrary.simpleMessage(
                "The patient\'s trash can is empty right now."),
        "patientList_bornOn":
            MessageLookupByLibrary.simpleMessage("Neither (e) the"),
        "patientList_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "patientList_contextComment": MessageLookupByLibrary.simpleMessage(
            "You can view the list of active and archived patients"),
        "patientList_contextName":
            MessageLookupByLibrary.simpleMessage("List of Patients"),
        "patientList_edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "patientList_error": m11,
        "patientList_newPatient":
            MessageLookupByLibrary.simpleMessage("New Patient"),
        "patientList_noArchivedPatients":
            MessageLookupByLibrary.simpleMessage("No archived patients"),
        "patientList_noPatientFound":
            MessageLookupByLibrary.simpleMessage("No patients found"),
        "patientList_noRegisteredPatients":
            MessageLookupByLibrary.simpleMessage("No patients registered"),
        "patientList_patientFileEmpty": MessageLookupByLibrary.simpleMessage(
            "The local patient file is currently empty."),
        "patientList_restorableUntil":
            MessageLookupByLibrary.simpleMessage("Can be restored until"),
        "patientList_restore": MessageLookupByLibrary.simpleMessage("Restore"),
        "patientList_restoreSuccess": m12,
        "patientList_searchPatient":
            MessageLookupByLibrary.simpleMessage("Search for a patient"),
        "patientList_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "patientList_title":
            MessageLookupByLibrary.simpleMessage("List of Patients"),
        "practitionerList_active":
            MessageLookupByLibrary.simpleMessage("Assets"),
        "practitionerList_addPractitionersHint":
            MessageLookupByLibrary.simpleMessage(
                "Add the physical therapists from the practice to identify the imported tests."),
        "practitionerList_archive":
            MessageLookupByLibrary.simpleMessage("Archive"),
        "practitionerList_archiveConfirmation": m13,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "The physical therapists\' trash can is empty right now."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage(
                "File away the physical therapist"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archived"),
        "practitionerList_archivedOn": m14,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Create a practitioner"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "This screen displays a list of registered practitioners."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("List of Practitioners"),
        "practitionerList_edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "practitionerList_error": m15,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "No physical therapists on file"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "No physical therapists listed"),
        "practitionerList_professionalId": m16,
        "practitionerList_restore":
            MessageLookupByLibrary.simpleMessage("Restore"),
        "practitionerList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Display the QR Code"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("List of Practitioners"),
        "practitionerNew_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "practitionerNew_cet_ecran_permet":
            MessageLookupByLibrary.simpleMessage(
                "This screen allows you to create a practitioner."),
        "practitionerNew_create":
            MessageLookupByLibrary.simpleMessage("Create"),
        "practitionerNew_displayName":
            MessageLookupByLibrary.simpleMessage("Display Name"),
        "practitionerNew_displayNameRequired":
            MessageLookupByLibrary.simpleMessage("The name field is required"),
        "practitionerNew_editPractitioner":
            MessageLookupByLibrary.simpleMessage("Change the practitioner"),
        "practitionerNew_email": MessageLookupByLibrary.simpleMessage("Email"),
        "practitionerNew_firstName":
            MessageLookupByLibrary.simpleMessage("First Name"),
        "practitionerNew_lastName":
            MessageLookupByLibrary.simpleMessage("Last Name"),
        "practitionerNew_newPractitioner":
            MessageLookupByLibrary.simpleMessage("New Practitioner"),
        "practitionerNew_phone": MessageLookupByLibrary.simpleMessage("Phone"),
        "practitionerNew_professionalId":
            MessageLookupByLibrary.simpleMessage("Professional ID"),
        "practitionerNew_professionalIdHint":
            MessageLookupByLibrary.simpleMessage("RPPS, ADELI…"),
        "practitionerNew_save": MessageLookupByLibrary.simpleMessage("Save"),
        "practitionerQr_close": MessageLookupByLibrary.simpleMessage("Close"),
        "practitionerQr_defaultOrganizationName":
            MessageLookupByLibrary.simpleMessage("Office"),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("ABAK Professional Profile"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Scan this QR code using ABAK Mobile to automatically add this professional profile."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("archived"),
        "practitionerSelector_error": m17,
        "practitionerSelector_noSelection":
            MessageLookupByLibrary.simpleMessage("No selection"),
        "preferences_archivedPatients":
            MessageLookupByLibrary.simpleMessage("Archived Patients"),
        "preferences_contextComment": MessageLookupByLibrary.simpleMessage(
            "This screen centralizes Companion\'s general settings."),
        "preferences_contextName":
            MessageLookupByLibrary.simpleMessage("User Settings"),
        "preferences_days": MessageLookupByLibrary.simpleMessage("days"),
        "preferences_expertMode":
            MessageLookupByLibrary.simpleMessage("Mode Expert"),
        "preferences_expertModeDescription": MessageLookupByLibrary.simpleMessage(
            "Displays technical information for developers and contributors."),
        "preferences_expertModeSaved":
            MessageLookupByLibrary.simpleMessage("Expert mode setting saved."),
        "preferences_languageSaved":
            MessageLookupByLibrary.simpleMessage("Language saved."),
        "preferences_organization":
            MessageLookupByLibrary.simpleMessage("Establishment"),
        "preferences_organizationDescription":
            MessageLookupByLibrary.simpleMessage(
                "Name, logo, and general information."),
        "preferences_retentionDuration":
            MessageLookupByLibrary.simpleMessage("Shelf Life"),
        "preferences_retentionExplanation": MessageLookupByLibrary.simpleMessage(
            "Archived patients can be restored during this period. They will then be automatically deleted."),
        "preferences_retentionSaved":
            MessageLookupByLibrary.simpleMessage("Recorded shelf life."),
        "recentImportCard_conflict":
            MessageLookupByLibrary.simpleMessage("conflict"),
        "recentImportCard_error": MessageLookupByLibrary.simpleMessage("error"),
        "recentImportCard_fichier":
            MessageLookupByLibrary.simpleMessage("file"),
        "recentImportCard_file": MessageLookupByLibrary.simpleMessage("file"),
        "recentImportCard_ignored":
            MessageLookupByLibrary.simpleMessage("ignored"),
        "recentImportCard_no_result_imported":
            MessageLookupByLibrary.simpleMessage("No results imported"),
        "recentImportCard_result":
            MessageLookupByLibrary.simpleMessage("result"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Refresh the dashboard"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Report Archives"),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "resultDetail_addCommentHint":
            MessageLookupByLibrary.simpleMessage("Add a comment..."),
        "resultDetail_archiveConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Do you really want to archive this result?"),
        "resultDetail_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Save the result"),
        "resultDetail_birthDate": MessageLookupByLibrary.simpleMessage("Birth"),
        "resultDetail_cancel": MessageLookupByLibrary.simpleMessage("Device"),
        "resultDetail_clinicalComment":
            MessageLookupByLibrary.simpleMessage("Clinical Comment"),
        "resultDetail_commentSaved":
            MessageLookupByLibrary.simpleMessage("Comment saved"),
        "resultDetail_detailedResult":
            MessageLookupByLibrary.simpleMessage("Detailed Results"),
        "resultDetail_device":
            MessageLookupByLibrary.simpleMessage("Device Details"),
        "resultDetail_exerciseDate":
            MessageLookupByLibrary.simpleMessage("Date of the fiscal year"),
        "resultDetail_generalInformation":
            MessageLookupByLibrary.simpleMessage("General Information"),
        "resultDetail_identityUnverified":
            MessageLookupByLibrary.simpleMessage("Unverified identity"),
        "resultDetail_identityVerified":
            MessageLookupByLibrary.simpleMessage("Verified identity"),
        "resultDetail_import": MessageLookupByLibrary.simpleMessage("Import"),
        "resultDetail_lastModified":
            MessageLookupByLibrary.simpleMessage("Last modified"),
        "resultDetail_metrics": MessageLookupByLibrary.simpleMessage("Metrics"),
        "resultDetail_noMetrics":
            MessageLookupByLibrary.simpleMessage("No metrics recorded."),
        "resultDetail_patient": MessageLookupByLibrary.simpleMessage("Patient"),
        "resultDetail_performedBy":
            MessageLookupByLibrary.simpleMessage("Directed by"),
        "resultDetail_save": MessageLookupByLibrary.simpleMessage("Save"),
        "resultDetail_score": MessageLookupByLibrary.simpleMessage("Score"),
        "resultDetail_syncState":
            MessageLookupByLibrary.simpleMessage("Sync Status"),
        "settings_assistanceWarning": MessageLookupByLibrary.simpleMessage(
            "These functions are intended for installation, diagnostics, and technical support.\n\nUse them only when instructed to do so by a technician or as directed in the ABAK documentation."),
        "settings_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "settings_configuration":
            MessageLookupByLibrary.simpleMessage("Configuration"),
        "settings_confirmationRequired":
            MessageLookupByLibrary.simpleMessage("Confirmation Required"),
        "settings_contextComment": MessageLookupByLibrary.simpleMessage(
            "This screen brings together Companion\'s installation, diagnostic, and maintenance functions."),
        "settings_contextName":
            MessageLookupByLibrary.simpleMessage("Assistance"),
        "settings_continue": MessageLookupByLibrary.simpleMessage("Continue"),
        "settings_databaseResetError": m18,
        "settings_databaseResetSuccess": MessageLookupByLibrary.simpleMessage(
            "Database reset. Automatic backup created."),
        "settings_diagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnosis"),
        "settings_edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "settings_exchangeDirectory":
            MessageLookupByLibrary.simpleMessage("ABAK Exchange File"),
        "settings_exchangeDirectoryReset":
            MessageLookupByLibrary.simpleMessage("Exchange Folder Reset"),
        "settings_exchangeDirectoryUpdated":
            MessageLookupByLibrary.simpleMessage("Updated ABAK Exchange File"),
        "settings_importAbakFile": MessageLookupByLibrary.simpleMessage(
            "Manually import an .abak file"),
        "settings_invalidConfirmation":
            MessageLookupByLibrary.simpleMessage("Invalid confirmation."),
        "settings_loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "settings_maintenance":
            MessageLookupByLibrary.simpleMessage("Maintenance"),
        "settings_manageBackups":
            MessageLookupByLibrary.simpleMessage("Manage Backups"),
        "settings_noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("No folder specified"),
        "settings_open": MessageLookupByLibrary.simpleMessage("Open"),
        "settings_openingExchangeDirectory":
            MessageLookupByLibrary.simpleMessage("Opening the Exchange File"),
        "settings_reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "settings_resetDatabase":
            MessageLookupByLibrary.simpleMessage("Reset the base"),
        "settings_resetDatabaseTitle":
            MessageLookupByLibrary.simpleMessage("Reset the local database?"),
        "settings_resetDatabaseWarning": MessageLookupByLibrary.simpleMessage(
            "This operation will delete all local data (patients, results, imports, and history).\n\nAn automatic backup will be created before the reset.\n\nUse this feature only during a technical support session."),
        "settings_resetKeyword": MessageLookupByLibrary.simpleMessage("RESET"),
        "settings_resetTooltip": MessageLookupByLibrary.simpleMessage("Reset"),
        "settings_resolveImportProblem": MessageLookupByLibrary.simpleMessage(
            "Troubleshooting an Import Issue"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Assistance"),
        "settings_typeResetConfirmation": MessageLookupByLibrary.simpleMessage(
            "Type RESET to confirm permanently."),
        "settings_vitaleDiagnostic":
            MessageLookupByLibrary.simpleMessage("Vitale Card Diagnosis"),
        "smartCardDiagnostic":
            MessageLookupByLibrary.simpleMessage("Vitale Card Diagnosis"),
        "systemOverviewBar_active_patients":
            MessageLookupByLibrary.simpleMessage("Active Patients"),
        "systemOverviewBar_alert":
            MessageLookupByLibrary.simpleMessage("Alerts"),
        "systemOverviewBar_archived_patients":
            MessageLookupByLibrary.simpleMessage("Archived Patients"),
        "systemOverviewBar_loading_system_summary":
            MessageLookupByLibrary.simpleMessage("Loading system summary..."),
        "systemOverviewBar_supervision_error":
            MessageLookupByLibrary.simpleMessage("Supervision error"),
        "systemOverviewBar_supervision_unavailable":
            MessageLookupByLibrary.simpleMessage("Monitoring Unavailable"),
        "systemStatusCard_nome": MessageLookupByLibrary.simpleMessage("None"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("User Settings"),
        "user_settings": MessageLookupByLibrary.simpleMessage("User Settings"),
        "vitaleBeneficiarySelector_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage("Select a beneficiary"),
        "vitaleIdentity_birthDate":
            MessageLookupByLibrary.simpleMessage("Date of Birth"),
        "vitaleIdentity_dataMasked":
            MessageLookupByLibrary.simpleMessage("data hidden"),
        "vitaleIdentity_detected":
            MessageLookupByLibrary.simpleMessage("detected"),
        "vitaleIdentity_female":
            MessageLookupByLibrary.simpleMessage("Feminine"),
        "vitaleIdentity_firstName":
            MessageLookupByLibrary.simpleMessage("First Name"),
        "vitaleIdentity_identityRead":
            MessageLookupByLibrary.simpleMessage("Identity Read"),
        "vitaleIdentity_identityReceivedMasked":
            MessageLookupByLibrary.simpleMessage(
                "Identity provided (personal information redacted)"),
        "vitaleIdentity_identityUnavailable":
            MessageLookupByLibrary.simpleMessage("ID not available"),
        "vitaleIdentity_lastName":
            MessageLookupByLibrary.simpleMessage("Last Name"),
        "vitaleIdentity_male": MessageLookupByLibrary.simpleMessage("Male"),
        "vitaleIdentity_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "vitaleIdentity_noIdentityAvailable":
            MessageLookupByLibrary.simpleMessage(
                "No Carte Vitale ID available"),
        "vitaleIdentity_notProvided":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "vitaleIdentity_other": MessageLookupByLibrary.simpleMessage("Other"),
        "vitaleIdentity_reading":
            MessageLookupByLibrary.simpleMessage("Loading..."),
        "vitaleIdentity_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "vitaleIdentity_source": MessageLookupByLibrary.simpleMessage("Source"),
        "vitaleIdentity_title":
            MessageLookupByLibrary.simpleMessage("Read Carte Vitale ID"),
        "vitaleIdentity_unavailable":
            MessageLookupByLibrary.simpleMessage("not available"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage("Use this to create a patient")
      };
}
