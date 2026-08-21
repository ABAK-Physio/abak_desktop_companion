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

  static String m2(fieldName) => "The \"${fieldName}\" field is required.";

  static String m3(noteTitle) =>
      "The note \"${noteTitle}\" will no longer be displayed.";

  static String m4(error) => "Error while saving: ${error}";

  static String m5(count) => "${count} other exercise(s)";

  static String m6(count) => "${count} pending association(s)";

  static String m7(count) => "${count} backups";

  static String m8(size) => "Size: ${size}";

  static String m9(size) => "Total size: ${size}";

  static String m10(version) => "Version ${version}";

  static String m11(patientName) =>
      "Are you sure you want to archive ${patientName}? They will no longer appear in the active list.";

  static String m12(patientName) => "${patientName} has been archived.";

  static String m13(error) => "Error: ${error}";

  static String m14(patientName) =>
      "${patientName} has been restored to the active list.";

  static String m15(patientName) =>
      "Vitale Card associated with patient ${patientName}.";

  static String m16(patientName) =>
      "The patient ${patientName} has been restored.";

  static String m17(practitionerName) =>
      "Are you sure you want to archive ${practitionerName}?";

  static String m18(date) => "Archived on ${date}";

  static String m19(error) => "Error: ${error}";

  static String m20(professionalId) => "ID pro: ${professionalId}";

  static String m21(error) => "Error: ${error}";

  static String m22(error) => "Error during reset: ${error}";

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
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origin: ABAK"),
        "careEpisodeDetail_evolution":
            MessageLookupByLibrary.simpleMessage("Evolution"),
        "careEpisodeDetail_noResult": MessageLookupByLibrary.simpleMessage(
            "No related results at this time."),
        "careEpisodeDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Pathology"),
        "careEpisodeDetail_reportsWorkspaceTooltip":
            MessageLookupByLibrary.simpleMessage(
                "New Interface for Financial Statements and Reports"),
        "careEpisodeDetail_results":
            MessageLookupByLibrary.simpleMessage("ABAK Results"),
        "careEpisodeDetail_score":
            MessageLookupByLibrary.simpleMessage("Score"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "contactFormTemplateDiagnostic_category":
            MessageLookupByLibrary.simpleMessage("Category"),
        "contactFormTemplateDiagnostic_defaultTemplate":
            MessageLookupByLibrary.simpleMessage("Default template"),
        "contactFormTemplateDiagnostic_error":
            MessageLookupByLibrary.simpleMessage("Error"),
        "contactFormTemplateDiagnostic_fields":
            MessageLookupByLibrary.simpleMessage("Fields"),
        "contactFormTemplateDiagnostic_no":
            MessageLookupByLibrary.simpleMessage("Not"),
        "contactFormTemplateDiagnostic_noData":
            MessageLookupByLibrary.simpleMessage("No data to display."),
        "contactFormTemplateDiagnostic_noTemplate":
            MessageLookupByLibrary.simpleMessage(
                "No initial maintenance record template was found."),
        "contactFormTemplateDiagnostic_notDefined":
            MessageLookupByLibrary.simpleMessage("Undefined"),
        "contactFormTemplateDiagnostic_order":
            MessageLookupByLibrary.simpleMessage("Order"),
        "contactFormTemplateDiagnostic_practitioner":
            MessageLookupByLibrary.simpleMessage("Practitioner"),
        "contactFormTemplateDiagnostic_refresh":
            MessageLookupByLibrary.simpleMessage("Refresh"),
        "contactFormTemplateDiagnostic_required":
            MessageLookupByLibrary.simpleMessage("Required"),
        "contactFormTemplateDiagnostic_systemTemplate":
            MessageLookupByLibrary.simpleMessage("System Model"),
        "contactFormTemplateDiagnostic_templateId":
            MessageLookupByLibrary.simpleMessage("Model ID"),
        "contactFormTemplateDiagnostic_title":
            MessageLookupByLibrary.simpleMessage(
                "Maintenance Checklist Diagnosis"),
        "contactFormTemplateDiagnostic_type":
            MessageLookupByLibrary.simpleMessage("Type"),
        "contactFormTemplateDiagnostic_yes":
            MessageLookupByLibrary.simpleMessage("Yes"),
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
        "episodeDashboard_documents":
            MessageLookupByLibrary.simpleMessage("Documents"),
        "episodeDashboard_documentsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Documents Related to This Episode"),
        "episodeDashboard_forms": MessageLookupByLibrary.simpleMessage("Forms"),
        "episodeDashboard_formsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Questionnaires specific to this episode"),
        "episodeDashboard_notes": MessageLookupByLibrary.simpleMessage("Notes"),
        "episodeDashboard_notesDescription":
            MessageLookupByLibrary.simpleMessage(
                "Observations and Comments from the Physical Therapist"),
        "episodeDashboard_report":
            MessageLookupByLibrary.simpleMessage("Report"),
        "episodeDashboard_reportDescription":
            MessageLookupByLibrary.simpleMessage("Episode Summary"),
        "episodeDocuments_addDocument":
            MessageLookupByLibrary.simpleMessage("Add a document"),
        "episodeDocuments_addError":
            MessageLookupByLibrary.simpleMessage("Unable to add the document"),
        "episodeDocuments_addedOn":
            MessageLookupByLibrary.simpleMessage("Added on"),
        "episodeDocuments_document":
            MessageLookupByLibrary.simpleMessage("Document"),
        "episodeDocuments_documentAdded": MessageLookupByLibrary.simpleMessage(
            "The document has been added to the support section."),
        "episodeDocuments_emptyDescription": MessageLookupByLibrary.simpleMessage(
            "You can add a text document, a spreadsheet, a PDF, an image, or any other useful file."),
        "episodeDocuments_fileNotFound": MessageLookupByLibrary.simpleMessage(
            "The associated file cannot be found."),
        "episodeDocuments_help": MessageLookupByLibrary.simpleMessage(
            "You can use this feature with documents created using your usual applications: word processors, spreadsheets, PDF readers, or image editing software.\n\nThe files you add are copied to Companion’s storage space. Clicking on a document opens it with the corresponding application installed on that computer."),
        "episodeDocuments_image": MessageLookupByLibrary.simpleMessage("Image"),
        "episodeDocuments_loadError": MessageLookupByLibrary.simpleMessage(
            "Unable to load the related documents."),
        "episodeDocuments_noDocument": MessageLookupByLibrary.simpleMessage(
            "There are no documents associated with this case."),
        "episodeDocuments_openDocument":
            MessageLookupByLibrary.simpleMessage("Open the document"),
        "episodeDocuments_openError":
            MessageLookupByLibrary.simpleMessage("Unable to open the file"),
        "episodeDocuments_pdfDocument":
            MessageLookupByLibrary.simpleMessage("PDF document"),
        "episodeDocuments_platformNotSupported":
            MessageLookupByLibrary.simpleMessage(
                "Opening is not supported on this platform."),
        "episodeDocuments_refresh":
            MessageLookupByLibrary.simpleMessage("Refresh"),
        "episodeDocuments_spreadsheet":
            MessageLookupByLibrary.simpleMessage("Spreadsheet"),
        "episodeDocuments_textDocument":
            MessageLookupByLibrary.simpleMessage("Text document"),
        "episodeDocuments_title":
            MessageLookupByLibrary.simpleMessage("Documents Related to Care"),
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
        "episodeFormEditor_error":
            MessageLookupByLibrary.simpleMessage("Error"),
        "episodeFormEditor_noField":
            MessageLookupByLibrary.simpleMessage("No fields to display."),
        "episodeFormEditor_requiredField": m2,
        "episodeFormEditor_save": MessageLookupByLibrary.simpleMessage("Save"),
        "episodeFormEditor_title":
            MessageLookupByLibrary.simpleMessage("Edit the form"),
        "episodeForms_availableTemplates":
            MessageLookupByLibrary.simpleMessage("Available Models"),
        "episodeForms_category":
            MessageLookupByLibrary.simpleMessage("Category"),
        "episodeForms_completed":
            MessageLookupByLibrary.simpleMessage("completed"),
        "episodeForms_create": MessageLookupByLibrary.simpleMessage("Create"),
        "episodeForms_createdForms":
            MessageLookupByLibrary.simpleMessage("Forms Created"),
        "episodeForms_createdOn":
            MessageLookupByLibrary.simpleMessage("Created on"),
        "episodeForms_customTemplate":
            MessageLookupByLibrary.simpleMessage("Custom Model"),
        "episodeForms_error": MessageLookupByLibrary.simpleMessage("Error"),
        "episodeForms_form": MessageLookupByLibrary.simpleMessage("Form"),
        "episodeForms_inProgress":
            MessageLookupByLibrary.simpleMessage("in progress"),
        "episodeForms_noAvailableTemplate":
            MessageLookupByLibrary.simpleMessage(
                "No form template is available."),
        "episodeForms_noCreatedForm": MessageLookupByLibrary.simpleMessage(
            "No form was created for this episode."),
        "episodeForms_noData":
            MessageLookupByLibrary.simpleMessage("No data to display."),
        "episodeForms_refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "episodeForms_state": MessageLookupByLibrary.simpleMessage("Status"),
        "episodeForms_systemTemplate":
            MessageLookupByLibrary.simpleMessage("System Model"),
        "episodeForms_title": MessageLookupByLibrary.simpleMessage("Forms"),
        "episodeNotes_archive": MessageLookupByLibrary.simpleMessage("Archive"),
        "episodeNotes_archiveConfirmation": m3,
        "episodeNotes_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archive this note?"),
        "episodeNotes_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "episodeNotes_content":
            MessageLookupByLibrary.simpleMessage("Contents"),
        "episodeNotes_editNote":
            MessageLookupByLibrary.simpleMessage("Change the rating"),
        "episodeNotes_error": MessageLookupByLibrary.simpleMessage("Error"),
        "episodeNotes_modifiedOn":
            MessageLookupByLibrary.simpleMessage("Last modified on"),
        "episodeNotes_newNote":
            MessageLookupByLibrary.simpleMessage("New Note"),
        "episodeNotes_noNote": MessageLookupByLibrary.simpleMessage(
            "There are no notes associated with this episode."),
        "episodeNotes_noteTitle": MessageLookupByLibrary.simpleMessage("Title"),
        "episodeNotes_refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "episodeNotes_save": MessageLookupByLibrary.simpleMessage("Save"),
        "episodeNotes_title": MessageLookupByLibrary.simpleMessage("Notes"),
        "episodeNotes_titleRequired":
            MessageLookupByLibrary.simpleMessage("A title is required."),
        "episodeReport_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origin of ABAK"),
        "episodeReport_addConclusion":
            MessageLookupByLibrary.simpleMessage("Add a conclusion"),
        "episodeReport_clinicalConclusion":
            MessageLookupByLibrary.simpleMessage("Clinical Conclusion"),
        "episodeReport_conclusionRequired":
            MessageLookupByLibrary.simpleMessage(
                "The conclusion cannot be empty."),
        "episodeReport_documents":
            MessageLookupByLibrary.simpleMessage("Documents"),
        "episodeReport_dominantSide":
            MessageLookupByLibrary.simpleMessage("Dominant side"),
        "episodeReport_editConclusion":
            MessageLookupByLibrary.simpleMessage("Edit the conclusion"),
        "episodeReport_email": MessageLookupByLibrary.simpleMessage("Email"),
        "episodeReport_error": MessageLookupByLibrary.simpleMessage("Error"),
        "episodeReport_forms": MessageLookupByLibrary.simpleMessage("Forms"),
        "episodeReport_generatedPreview": MessageLookupByLibrary.simpleMessage(
            "Overview of the Generated Report"),
        "episodeReport_generatingPreview": MessageLookupByLibrary.simpleMessage(
            "Generating the text preview..."),
        "episodeReport_name": MessageLookupByLibrary.simpleMessage("Last Name"),
        "episodeReport_noConclusion":
            MessageLookupByLibrary.simpleMessage("No conclusion entered."),
        "episodeReport_noData":
            MessageLookupByLibrary.simpleMessage("No data to display."),
        "episodeReport_noDocument":
            MessageLookupByLibrary.simpleMessage("No related documents"),
        "episodeReport_noForm":
            MessageLookupByLibrary.simpleMessage("No related forms"),
        "episodeReport_noNote":
            MessageLookupByLibrary.simpleMessage("No related notes"),
        "episodeReport_noResult":
            MessageLookupByLibrary.simpleMessage("No related results"),
        "episodeReport_notProvided":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "episodeReport_notes": MessageLookupByLibrary.simpleMessage("Notes"),
        "episodeReport_patient":
            MessageLookupByLibrary.simpleMessage("Patient"),
        "episodeReport_phone": MessageLookupByLibrary.simpleMessage("Phone"),
        "episodeReport_profession":
            MessageLookupByLibrary.simpleMessage("Occupation"),
        "episodeReport_refresh":
            MessageLookupByLibrary.simpleMessage("Refresh"),
        "episodeReport_results":
            MessageLookupByLibrary.simpleMessage("ABAK Results"),
        "episodeReport_save": MessageLookupByLibrary.simpleMessage("Save"),
        "episodeReport_score": MessageLookupByLibrary.simpleMessage("Score"),
        "episodeReport_sportActivity":
            MessageLookupByLibrary.simpleMessage("Sports Activity"),
        "episodeReport_title": MessageLookupByLibrary.simpleMessage("Report"),
        "episodeReport_unknownType":
            MessageLookupByLibrary.simpleMessage("Unknown type"),
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
        "home_error_while_saving": m4,
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
        "home_other_exercises": m5,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Settings"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Path"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patient ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patients"),
        "home_pending_association": m6,
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
        "information_backupCount": m7,
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
        "information_size": m8,
        "information_system": MessageLookupByLibrary.simpleMessage("System"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Information"),
        "information_totalSize": m9,
        "information_version": m10,
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
        "patientClinicalDataEdit_address":
            MessageLookupByLibrary.simpleMessage("Address"),
        "patientClinicalDataEdit_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Administrative Identity"),
        "patientClinicalDataEdit_ambidextrous":
            MessageLookupByLibrary.simpleMessage("Ambidextrous"),
        "patientClinicalDataEdit_centimeters":
            MessageLookupByLibrary.simpleMessage("In centimeters"),
        "patientClinicalDataEdit_dominantSide":
            MessageLookupByLibrary.simpleMessage("Dominant side"),
        "patientClinicalDataEdit_email":
            MessageLookupByLibrary.simpleMessage("Email"),
        "patientClinicalDataEdit_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage(
                "Countries with a Healthcare System"),
        "patientClinicalDataEdit_height":
            MessageLookupByLibrary.simpleMessage("Size"),
        "patientClinicalDataEdit_identitySource":
            MessageLookupByLibrary.simpleMessage("Source of Identity"),
        "patientClinicalDataEdit_kilograms":
            MessageLookupByLibrary.simpleMessage("In kilograms"),
        "patientClinicalDataEdit_left":
            MessageLookupByLibrary.simpleMessage("Left"),
        "patientClinicalDataEdit_manualEntry":
            MessageLookupByLibrary.simpleMessage("Manual entry"),
        "patientClinicalDataEdit_nationalHealthId":
            MessageLookupByLibrary.simpleMessage("National Health ID"),
        "patientClinicalDataEdit_nationalHealthIdHelper":
            MessageLookupByLibrary.simpleMessage(
                "Example from France: Social Security number"),
        "patientClinicalDataEdit_patientProfile":
            MessageLookupByLibrary.simpleMessage("Patient Profile"),
        "patientClinicalDataEdit_phone":
            MessageLookupByLibrary.simpleMessage("Phone"),
        "patientClinicalDataEdit_profession":
            MessageLookupByLibrary.simpleMessage("Occupation"),
        "patientClinicalDataEdit_right":
            MessageLookupByLibrary.simpleMessage("Right"),
        "patientClinicalDataEdit_save":
            MessageLookupByLibrary.simpleMessage("Save"),
        "patientClinicalDataEdit_sportActivity":
            MessageLookupByLibrary.simpleMessage("Usual physical activity"),
        "patientClinicalDataEdit_title":
            MessageLookupByLibrary.simpleMessage("Edit Clinical Data"),
        "patientClinicalDataEdit_unspecified":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "patientClinicalDataEdit_vitaleCard":
            MessageLookupByLibrary.simpleMessage("Vitale Card"),
        "patientClinicalDataEdit_weight":
            MessageLookupByLibrary.simpleMessage("Weight"),
        "patientDetail_address":
            MessageLookupByLibrary.simpleMessage("Address"),
        "patientDetail_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Administrative Identity"),
        "patientDetail_archived":
            MessageLookupByLibrary.simpleMessage("archived"),
        "patientDetail_bornOn":
            MessageLookupByLibrary.simpleMessage("Neither (nor) the"),
        "patientDetail_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "patientDetail_careEpisodeOpenedIn":
            MessageLookupByLibrary.simpleMessage("Open care in"),
        "patientDetail_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Coverage"),
        "patientDetail_create": MessageLookupByLibrary.simpleMessage("Create"),
        "patientDetail_dominantSide":
            MessageLookupByLibrary.simpleMessage("Dominant side"),
        "patientDetail_edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "patientDetail_editCareEpisode":
            MessageLookupByLibrary.simpleMessage("Change Coverage"),
        "patientDetail_editClinicalData":
            MessageLookupByLibrary.simpleMessage("Edit Clinical Data"),
        "patientDetail_email": MessageLookupByLibrary.simpleMessage("Email"),
        "patientDetail_error": MessageLookupByLibrary.simpleMessage("Error"),
        "patientDetail_frHealthIdentity":
            MessageLookupByLibrary.simpleMessage("Health ID — France"),
        "patientDetail_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage("Country Health Care System"),
        "patientDetail_height": MessageLookupByLibrary.simpleMessage("Size"),
        "patientDetail_identitySource":
            MessageLookupByLibrary.simpleMessage("Source Identity"),
        "patientDetail_initialReport":
            MessageLookupByLibrary.simpleMessage("Initial Report"),
        "patientDetail_nationalIdentifier":
            MessageLookupByLibrary.simpleMessage("National ID Number"),
        "patientDetail_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("New Coverage"),
        "patientDetail_noBirthdate":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "patientDetail_noCareEpisode": MessageLookupByLibrary.simpleMessage(
            "No treatment plan has been created for this patient."),
        "patientDetail_notProvided":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "patientDetail_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "patientDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Pathology"),
        "patientDetail_patientInformation":
            MessageLookupByLibrary.simpleMessage("Patient Information"),
        "patientDetail_patientProfile":
            MessageLookupByLibrary.simpleMessage("Patient Profile"),
        "patientDetail_phone": MessageLookupByLibrary.simpleMessage("Phone"),
        "patientDetail_profession":
            MessageLookupByLibrary.simpleMessage("Occupation"),
        "patientDetail_provisional":
            MessageLookupByLibrary.simpleMessage("Draft"),
        "patientDetail_provisionalDescription":
            MessageLookupByLibrary.simpleMessage("Identity to be completed"),
        "patientDetail_qualified":
            MessageLookupByLibrary.simpleMessage("Qualified"),
        "patientDetail_qualifiedDescription":
            MessageLookupByLibrary.simpleMessage("Valid ID"),
        "patientDetail_referringPractitioner":
            MessageLookupByLibrary.simpleMessage("Primary Physical Therapist"),
        "patientDetail_retrieved":
            MessageLookupByLibrary.simpleMessage("Retrieved"),
        "patientDetail_retrievedDescription":
            MessageLookupByLibrary.simpleMessage(
                "INS obtained; identity to be verified"),
        "patientDetail_save": MessageLookupByLibrary.simpleMessage("Save"),
        "patientDetail_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "patientDetail_sportActivity":
            MessageLookupByLibrary.simpleMessage("Sports Activity"),
        "patientDetail_state": MessageLookupByLibrary.simpleMessage("Status"),
        "patientDetail_status": MessageLookupByLibrary.simpleMessage("Status"),
        "patientDetail_validated":
            MessageLookupByLibrary.simpleMessage("Approved"),
        "patientDetail_validatedDescription":
            MessageLookupByLibrary.simpleMessage(
                "Identity verified; INS to be determined"),
        "patientDetail_weight": MessageLookupByLibrary.simpleMessage("Weight"),
        "patientDetail_years": MessageLookupByLibrary.simpleMessage("years"),
        "patientForm_birthDate":
            MessageLookupByLibrary.simpleMessage("Date of Birth"),
        "patientForm_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "patientForm_create": MessageLookupByLibrary.simpleMessage("Create"),
        "patientForm_editPatient":
            MessageLookupByLibrary.simpleMessage("Edit Patient"),
        "patientForm_female": MessageLookupByLibrary.simpleMessage("Woman"),
        "patientForm_firstName":
            MessageLookupByLibrary.simpleMessage("First Name"),
        "patientForm_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("The first name is required"),
        "patientForm_lastName":
            MessageLookupByLibrary.simpleMessage("Last Name"),
        "patientForm_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("The name is required"),
        "patientForm_male": MessageLookupByLibrary.simpleMessage("Man"),
        "patientForm_newPatient":
            MessageLookupByLibrary.simpleMessage("New Patient"),
        "patientForm_other": MessageLookupByLibrary.simpleMessage("Other"),
        "patientForm_save": MessageLookupByLibrary.simpleMessage("Save"),
        "patientForm_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "patientForm_unspecified":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "patientList_active": MessageLookupByLibrary.simpleMessage("Assets"),
        "patientList_archive": MessageLookupByLibrary.simpleMessage("Archive"),
        "patientList_archiveConfirmation": m11,
        "patientList_archiveSuccess": m12,
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
        "patientList_error": m13,
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
        "patientList_restoreSuccess": m14,
        "patientList_searchPatient":
            MessageLookupByLibrary.simpleMessage("Search for a patient"),
        "patientList_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "patientList_title":
            MessageLookupByLibrary.simpleMessage("List of Patients"),
        "patientNew_archivedMatchToReview":
            MessageLookupByLibrary.simpleMessage(
                "Archived correspondence to be reviewed"),
        "patientNew_archivedMatchToReviewMessage":
            MessageLookupByLibrary.simpleMessage(
                "A patient in the archive with the same last name, first name, and date of birth already exists, but their administrative information is different.\n\nNo automatic restoration will be performed. Please verify the records before continuing."),
        "patientNew_archivedPatientFound": MessageLookupByLibrary.simpleMessage(
            "Patient found in the archives"),
        "patientNew_archivedPatientMatch": MessageLookupByLibrary.simpleMessage(
            "This Carte Vitale corresponds to the archived patient:"),
        "patientNew_attach": MessageLookupByLibrary.simpleMessage("Link"),
        "patientNew_attachVitaleError": MessageLookupByLibrary.simpleMessage(
            "Unable to link the Carte Vitale"),
        "patientNew_attachVitaleQuestion": MessageLookupByLibrary.simpleMessage(
            "Would you like to link the Carte Vitale information to this patient?"),
        "patientNew_attachVitaleSuccess": m15,
        "patientNew_backToList":
            MessageLookupByLibrary.simpleMessage("Back to the list"),
        "patientNew_birthDate":
            MessageLookupByLibrary.simpleMessage("Date of Birth"),
        "patientNew_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "patientNew_choosePatient":
            MessageLookupByLibrary.simpleMessage("Select the patient"),
        "patientNew_close": MessageLookupByLibrary.simpleMessage("Close"),
        "patientNew_contextComment": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to create a new patient by entering the information manually or by scanning the Carte Vitale."),
        "patientNew_contextName":
            MessageLookupByLibrary.simpleMessage("New Patient"),
        "patientNew_createError":
            MessageLookupByLibrary.simpleMessage("Error creating the patient"),
        "patientNew_createPatient":
            MessageLookupByLibrary.simpleMessage("Create the patient"),
        "patientNew_creating":
            MessageLookupByLibrary.simpleMessage("Creating..."),
        "patientNew_download": MessageLookupByLibrary.simpleMessage("Download"),
        "patientNew_existingPatientTitle":
            MessageLookupByLibrary.simpleMessage("Already a patient?"),
        "patientNew_female": MessageLookupByLibrary.simpleMessage("Feminine"),
        "patientNew_firstName":
            MessageLookupByLibrary.simpleMessage("First Name"),
        "patientNew_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("The first name is required"),
        "patientNew_lastName":
            MessageLookupByLibrary.simpleMessage("Last Name"),
        "patientNew_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("The name is required"),
        "patientNew_male": MessageLookupByLibrary.simpleMessage("Male"),
        "patientNew_matchToReview": MessageLookupByLibrary.simpleMessage(
            "Correspondence to be verified"),
        "patientNew_matchToReviewMessage": MessageLookupByLibrary.simpleMessage(
            "A patient with the same last name, first name, and date of birth already exists.\n\nThe administrative information does not match completely. Please review the record before continuing."),
        "patientNew_matchingPatientFound": MessageLookupByLibrary.simpleMessage(
            "A matching patient has been found:"),
        "patientNew_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "patientNew_nirDetectedProtected":
            MessageLookupByLibrary.simpleMessage("detected and protected"),
        "patientNew_nirUnavailable":
            MessageLookupByLibrary.simpleMessage("not available"),
        "patientNew_no": MessageLookupByLibrary.simpleMessage("Not"),
        "patientNew_noNewPatientCreated": MessageLookupByLibrary.simpleMessage(
            "No new patients will be added."),
        "patientNew_notProvided":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "patientNew_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("not specified"),
        "patientNew_other": MessageLookupByLibrary.simpleMessage("Other"),
        "patientNew_patientAlreadyRegistered":
            MessageLookupByLibrary.simpleMessage("Patient Already Registered"),
        "patientNew_patientIdentity":
            MessageLookupByLibrary.simpleMessage("Patient Information"),
        "patientNew_readOn":
            MessageLookupByLibrary.simpleMessage("Reading completed on"),
        "patientNew_readVitale":
            MessageLookupByLibrary.simpleMessage("Read Carte Vitale"),
        "patientNew_readerNotDetected": MessageLookupByLibrary.simpleMessage(
            "Vitale Card Reader Not Detected"),
        "patientNew_readerNotDetectedMessage": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion did not detect a Carte Vitale reader.\n\nTo use this feature, you must have:\n\n• a PC/SC-compatible Carte Vitale reader, typically connected via USB;\n• the ABAK Carte Vitale module, provided free of charge. Visit abak.care.\n\nOnce the reader is connected, click “Read Carte Vitale” again."),
        "patientNew_reading":
            MessageLookupByLibrary.simpleMessage("Loading..."),
        "patientNew_restore": MessageLookupByLibrary.simpleMessage("Restore"),
        "patientNew_restoreError": MessageLookupByLibrary.simpleMessage(
            "Unable to resuscitate the patient"),
        "patientNew_restoreInsteadOfCreate": MessageLookupByLibrary.simpleMessage(
            "Would you like to restore this file instead of creating a new patient?"),
        "patientNew_restoreSuccess": m16,
        "patientNew_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "patientNew_vitaleIdentityRead": MessageLookupByLibrary.simpleMessage(
            "Identity retrieved from the Carte Vitale"),
        "patientNew_vitaleMatchesPatient": MessageLookupByLibrary.simpleMessage(
            "This Carte Vitale belongs to the following patient:"),
        "patientNew_vitaleModuleConfigurationError":
            MessageLookupByLibrary.simpleMessage(
                "The Carte Vitale module configuration is missing or incorrect. Reinstall the module and try again."),
        "patientNew_vitaleModuleNotInstalled":
            MessageLookupByLibrary.simpleMessage(
                "Vitale Card Module Not Installed"),
        "patientNew_vitaleModuleNotInstalledMessage":
            MessageLookupByLibrary.simpleMessage(
                "The ABAK Carte Vitale module is not installed on this computer.\n\nYou can download it for free from the ABAK website."),
        "patientNew_vitalePrefilled": MessageLookupByLibrary.simpleMessage(
            "Patient information pre-filled from the Carte Vitale."),
        "patientNew_vitaleReadFailed": MessageLookupByLibrary.simpleMessage(
            "The Carte Vitale could not be read."),
        "practitionerList_active":
            MessageLookupByLibrary.simpleMessage("Assets"),
        "practitionerList_addPractitionersHint":
            MessageLookupByLibrary.simpleMessage(
                "Add the physical therapists from the practice to identify the imported tests."),
        "practitionerList_archive":
            MessageLookupByLibrary.simpleMessage("Archive"),
        "practitionerList_archiveConfirmation": m17,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "The physical therapists\' trash can is empty right now."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage(
                "File away the physical therapist"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archived"),
        "practitionerList_archivedOn": m18,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Create a practitioner"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "This screen displays a list of registered practitioners."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("List of Practitioners"),
        "practitionerList_edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "practitionerList_error": m19,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "No physical therapists on file"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "No physical therapists listed"),
        "practitionerList_professionalId": m20,
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
        "practitionerSelector_error": m21,
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
        "settings_databaseResetError": m22,
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
