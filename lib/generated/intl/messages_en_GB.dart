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

  static String m0(careEpisodeId) =>
      "No patient found for care episode ${careEpisodeId}.";

  static String m1(height) => "${height} cm";

  static String m2(weight) => "${weight} kg";

  static String m3(age) => "${age} years old";

  static String m4(size) => "${size}";

  static String m5(date) => "Archived on ${date}";

  static String m6(monthYear) => "Opened in ${monthYear}";

  static String m7(title) =>
      "The \"${title}\" statement will no longer be displayed in the history.";

  static String m8(title) =>
      "The report \"${title}\" will be moved to the Recycle Bin. It can be restored later.";

  static String m9(patientName, title) => "Bilan_${patientName}_${title}";

  static String m10(title) => "Copy of ${title}";

  static String m11(title) =>
      "The \"${title}\" statement will be permanently deleted. This action cannot be undone.";

  static String m12(title) =>
      "The report \"${title}\" will be permanently deleted. This action cannot be undone.";

  static String m13(path) =>
      "\"careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": \"Le dossier configuré n’est pas accessible ou son autorisation doit être renouvelée.\n\n${path}\n\nReconnectez son volume si nécessaire, puis sélectionnez ce dossier pour autoriser son accès. Le dossier sélectionné sera enregistré dans vos préférences.\",\n\"@careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": {\n  \"placeholders\": {\n    \"path\": {\n      \"type\": \"String\"\n    }\n  }\n}";

  static String m14(documentLabel) =>
      "A draft already exists for this ${documentLabel} template.";

  static String m15(documentLabel) =>
      "Would you like to add the generated content to the end of the current ${documentLabel} or replace the existing content?";

  static String m16(documentLabel) => "New ${documentLabel}";

  static String m17(patientName, title) => "Rapport_${patientName}_${title}";

  static String m18(path) => "Word document created: ${path}";

  static String m19(error) => "Error creating the Word document: ${error}";

  static String m20(patientName) => "${patientName} — Evaluations and Reports";

  static String m21(deviceName) =>
      "Are you sure you want to archive ${deviceName}?";

  static String m22(fieldName) => "The \"${fieldName}\" field is required.";

  static String m23(noteTitle) =>
      "The note \"${noteTitle}\" will no longer be displayed.";

  static String m24(error) => "Error while saving: ${error}";

  static String m25(count) => "${count} other exercise(s)";

  static String m26(count) => "${count} pending association(s)";

  static String m27(count) => "${count} backups";

  static String m28(size) => "Size: ${size}";

  static String m29(size) => "Total size: ${size}";

  static String m30(version) => "Version ${version}";

  static String m31(integrityStatus) =>
      "The restored database shows an anomaly: ${integrityStatus}";

  static String m32(error) => "Restore failed: ${error}";

  static String m33(integrityStatus) =>
      "Restoration completed, but integrity_check returned: ${integrityStatus}";

  static String m34(patientName) =>
      "Are you sure you want to archive ${patientName}? They will no longer appear in the active list.";

  static String m35(patientName) => "${patientName} has been archived.";

  static String m36(error) => "Error: ${error}";

  static String m37(patientName) =>
      "${patientName} has been restored to the active list.";

  static String m38(patientName) =>
      "Vitale Card associated with patient ${patientName}.";

  static String m39(patientName) =>
      "The patient ${patientName} has been restored.";

  static String m40(practitionerName) =>
      "Are you sure you want to archive ${practitionerName}?";

  static String m41(date) => "Archived on ${date}";

  static String m42(error) => "Error: ${error}";

  static String m43(professionalId) => "ID pro: ${professionalId}";

  static String m44(error) => "Error: ${error}";

  static String m45(name) => "${name} — archived";

  static String m46(start, end) => "You ${start} to ${end}";

  static String m47(error) => "Error loading history: ${error}";

  static String m48(start) => "Since ${start}";

  static String m49(error) => "Error during reset: ${error}";

  static String m50(error) => "Voice dictation failed: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "abakWhisperSpeechProvider_name":
            MessageLookupByLibrary.simpleMessage("ABAK Voice Dictation"),
        "archivedDocuments_help": MessageLookupByLibrary.simpleMessage(
            "This view displays archived assessments and reports. Each row shows the document type, title, and archive date.\n\nThe restore action returns the document to the assessment or report history.\n\nThe \"Permanently Delete\" action removes the document from Companion. Read the confirmation message carefully before confirming: the document can no longer be restored from this list.\n\nClick the X to close the expanded view and return to the Reports/Statements area."),
        "assessmentChartImageService_insufficientPoints":
            MessageLookupByLibrary.simpleMessage(
                "A data set must contain at least two data points."),
        "assessmentChartImageService_pngConversionError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to convert the graph to a PNG image."),
        "assessmentDocumentDataBuilder_female":
            MessageLookupByLibrary.simpleMessage("Feminine"),
        "assessmentDocumentDataBuilder_male":
            MessageLookupByLibrary.simpleMessage("Male"),
        "assessmentDocumentDataBuilder_patient": m0,
        "assessmentDocxService_age":
            MessageLookupByLibrary.simpleMessage("Age"),
        "assessmentDocxService_assessment":
            MessageLookupByLibrary.simpleMessage("with"),
        "assessmentDocxService_attachment":
            MessageLookupByLibrary.simpleMessage(
                "Pathology During Reattachment"),
        "assessmentDocxService_author":
            MessageLookupByLibrary.simpleMessage("Writer"),
        "assessmentDocxService_centimetres": m1,
        "assessmentDocxService_chart":
            MessageLookupByLibrary.simpleMessage("Graph"),
        "assessmentDocxService_declared": MessageLookupByLibrary.simpleMessage(
            "Age reported at the time of the test"),
        "assessmentDocxService_diagnosis": MessageLookupByLibrary.simpleMessage(
            "Abnormal Findings During the Test"),
        "assessmentDocxService_dominance":
            MessageLookupByLibrary.simpleMessage("Dominant side"),
        "assessmentDocxService_establishment":
            MessageLookupByLibrary.simpleMessage("Establishment"),
        "assessmentDocxService_firstname":
            MessageLookupByLibrary.simpleMessage("First Name"),
        "assessmentDocxService_height":
            MessageLookupByLibrary.simpleMessage("Size"),
        "assessmentDocxService_information":
            MessageLookupByLibrary.simpleMessage("Patient Information"),
        "assessmentDocxService_kilograms": m2,
        "assessmentDocxService_notes":
            MessageLookupByLibrary.simpleMessage("Selected Follow-Up Notes"),
        "assessmentDocxService_opened": MessageLookupByLibrary.simpleMessage(
            "Care services available starting on"),
        "assessmentDocxService_pathology":
            MessageLookupByLibrary.simpleMessage("Pathology"),
        "assessmentDocxService_patient":
            MessageLookupByLibrary.simpleMessage("Patient"),
        "assessmentDocxService_performed":
            MessageLookupByLibrary.simpleMessage("Created on"),
        "assessmentDocxService_practitioner":
            MessageLookupByLibrary.simpleMessage("Primary Physical Therapist"),
        "assessmentDocxService_printed":
            MessageLookupByLibrary.simpleMessage("Printed on"),
        "assessmentDocxService_profession":
            MessageLookupByLibrary.simpleMessage("Occupation"),
        "assessmentDocxService_recipients":
            MessageLookupByLibrary.simpleMessage("Recipient(s)"),
        "assessmentDocxService_results":
            MessageLookupByLibrary.simpleMessage("Selected Test Results"),
        "assessmentDocxService_sex":
            MessageLookupByLibrary.simpleMessage("Sex"),
        "assessmentDocxService_sport":
            MessageLookupByLibrary.simpleMessage("Sports Activity"),
        "assessmentDocxService_surname":
            MessageLookupByLibrary.simpleMessage("Last Name"),
        "assessmentDocxService_title":
            MessageLookupByLibrary.simpleMessage("with"),
        "assessmentDocxService_weight":
            MessageLookupByLibrary.simpleMessage("Weight"),
        "assessmentDocxService_years": m3,
        "assessmentDraft_help": MessageLookupByLibrary.simpleMessage(
            "The text displayed is a saved draft. You can keep it, edit it, or delete it before saving your report."),
        "assessmentDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Understanding the Balance Sheet Draft"),
        "assessmentHistory_help": MessageLookupByLibrary.simpleMessage(
            "This view displays the reports saved for case management, along with their titles and dates.\n\nThe actions in each row allow you to edit a report, duplicate it, or move it to the archived documents.\n\nWhen a report is open for editing, use the \"Update\" action to save your changes. The available commands also allow you to undo changes or revert to the draft.\n\nMoving a report to the archived documents does not permanently delete it.\n\nClick the cross to close the expanded view and return to the Reports/Statements area."),
        "backupHistory_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "backupHistory_empty":
            MessageLookupByLibrary.simpleMessage("No backups have been saved."),
        "backupHistory_fileSize": m4,
        "backupHistory_help": MessageLookupByLibrary.simpleMessage(
            "This screen displays the backups saved in Companion. Each row shows the file name, creation date, size, and location.\n\nThe \"Restore\" button replaces the current database with the one from the selected backup. Data added or modified after this backup will therefore not be included in the restored database.\n\nCheck the backup date and read the confirmation message before proceeding. A backup copy of the current database is created before it is replaced.\n\nThe backup file must always be accessible at the specified location. If it has been moved or deleted, the restore cannot be performed.\n\nTo create a new backup, use the “Create a Backup” action on the home page."),
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Restore"),
        "backupHistory_restoreTitle":
            MessageLookupByLibrary.simpleMessage("Restore this backup?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "This operation will completely replace the current database.\n\nAn automatic backup will be created before restoration.\n\nContinue?"),
        "backupHistory_title":
            MessageLookupByLibrary.simpleMessage("Backup History"),
        "bodymap_help": MessageLookupByLibrary.simpleMessage(
            "The pain map helps identify the patient’s painful areas for the current care episode.\n\nChoose a view, then click on an area of the silhouette or select it from the list. You can add a note and, if necessary, rate the intensity on a scale of 0 to 10. Use the trash can icon to remove an area from the record.\n\nClick “Save” to save your assessment in Companion. When you exit the screen with unsaved changes, you’ll be prompted to either save or discard them.\n\n“Export Both Maps” creates a PNG image in the location of your choice on your computer. This export does not replace saving the survey.\n\nThis module is an initial version, intended to evolve based on your feedback. Test it in your practice and let us know what features you’d like to see added or improved."),
        "bodymap_title": MessageLookupByLibrary.simpleMessage("Pain Map"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origin: ABAK"),
        "careEpisodeDetail_detail_de_la_prise_en_charge":
            MessageLookupByLibrary.simpleMessage("Coverage Details"),
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
        "careEpisodePanel_archive":
            MessageLookupByLibrary.simpleMessage("Archive"),
        "careEpisodePanel_archiveCareEpisode":
            MessageLookupByLibrary.simpleMessage("Archive the case"),
        "careEpisodePanel_archiveCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to archive the case. Please try again."),
        "careEpisodePanel_archiveCareEpisodeMessage":
            MessageLookupByLibrary.simpleMessage(
                "This case will be removed from the list. Its data will be retained in the archive."),
        "careEpisodePanel_archiveCareEpisodeTitle":
            MessageLookupByLibrary.simpleMessage("Archive this case?"),
        "careEpisodePanel_archivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage("Archived Cases"),
        "careEpisodePanel_archivedCareEpisodesHelp":
            MessageLookupByLibrary.simpleMessage(
                "Here you\'ll find your archived treatment records."),
        "careEpisodePanel_archivedOn": m5,
        "careEpisodePanel_careEpisodeArchived":
            MessageLookupByLibrary.simpleMessage("Archived support."),
        "careEpisodePanel_careEpisodeOpenedIn": m6,
        "careEpisodePanel_careEpisodeRestored":
            MessageLookupByLibrary.simpleMessage("Support has been restored."),
        "careEpisodePanel_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Coverage"),
        "careEpisodePanel_choose":
            MessageLookupByLibrary.simpleMessage("Choose"),
        "careEpisodePanel_edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "careEpisodePanel_loadCareEpisodesError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to load the support information."),
        "careEpisodePanel_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("New Coverage"),
        "careEpisodePanel_noArchivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage(
                "No archived medical records for this patient."),
        "careEpisodePanel_noCareEpisodes": MessageLookupByLibrary.simpleMessage(
            "No treatment plan has been created for this patient."),
        "careEpisodePanel_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Prescribing physician"),
        "careEpisodePanel_restore":
            MessageLookupByLibrary.simpleMessage("Restore"),
        "careEpisodePanel_restoreCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to restore support. Please try again."),
        "careEpisodeReportsWorkspaceScreen_add":
            MessageLookupByLibrary.simpleMessage("Add"),
        "careEpisodeReportsWorkspaceScreen_append":
            MessageLookupByLibrary.simpleMessage("Add to the list"),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "I can\'t move the balance sheet to the trash."),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentMessage": m7,
        "careEpisodeReportsWorkspaceScreen_archiveReportError":
            MessageLookupByLibrary.simpleMessage(
                "I can\'t move the report to the Recycle Bin."),
        "careEpisodeReportsWorkspaceScreen_archiveReportMessage": m8,
        "careEpisodeReportsWorkspaceScreen_assessmentFileName": m9,
        "careEpisodeReportsWorkspaceScreen_assessmentLabel":
            MessageLookupByLibrary.simpleMessage("with"),
        "careEpisodeReportsWorkspaceScreen_assessmentNotFound":
            MessageLookupByLibrary.simpleMessage("The report cannot be found."),
        "careEpisodeReportsWorkspaceScreen_assessmentReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Your report is ready. The DOCX file will include the information you entered and the items you selected."),
        "careEpisodeReportsWorkspaceScreen_assessmentTitle":
            MessageLookupByLibrary.simpleMessage("Title of the Report"),
        "careEpisodeReportsWorkspaceScreen_assessmentsAndReports":
            MessageLookupByLibrary.simpleMessage(
                "Financial Statements and Reports"),
        "careEpisodeReportsWorkspaceScreen_author":
            MessageLookupByLibrary.simpleMessage("Writer"),
        "careEpisodeReportsWorkspaceScreen_authorizeDirectory":
            MessageLookupByLibrary.simpleMessage("Approve a file"),
        "careEpisodeReportsWorkspaceScreen_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "careEpisodeReportsWorkspaceScreen_cancelChangesError":
            MessageLookupByLibrary.simpleMessage(
                "You cannot undo the changes."),
        "careEpisodeReportsWorkspaceScreen_cancelReportChangesError":
            MessageLookupByLibrary.simpleMessage(
                "It is not possible to undo the changes made to the report."),
        "careEpisodeReportsWorkspaceScreen_close":
            MessageLookupByLibrary.simpleMessage("Close"),
        "careEpisodeReportsWorkspaceScreen_confirm":
            MessageLookupByLibrary.simpleMessage("Confirm"),
        "careEpisodeReportsWorkspaceScreen_copyTitle": m10,
        "careEpisodeReportsWorkspaceScreen_createNew":
            MessageLookupByLibrary.simpleMessage("Create a new one"),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "It is not possible to permanently delete the balance sheet."),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentMessage": m11,
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "Permanently delete the balance sheet?"),
        "careEpisodeReportsWorkspaceScreen_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Permanently delete"),
        "careEpisodeReportsWorkspaceScreen_deleteReportError":
            MessageLookupByLibrary.simpleMessage(
                "I can\'t permanently delete the report."),
        "careEpisodeReportsWorkspaceScreen_deleteReportMessage": m12,
        "careEpisodeReportsWorkspaceScreen_deleteReportTitle":
            MessageLookupByLibrary.simpleMessage(
                "Permanently delete the report?"),
        "careEpisodeReportsWorkspaceScreen_directoryAccessMessage": m13,
        "careEpisodeReportsWorkspaceScreen_duplicate":
            MessageLookupByLibrary.simpleMessage("Duplicate"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessment":
            MessageLookupByLibrary.simpleMessage("Duplicate the balance sheet"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to duplicate the balance sheet."),
        "careEpisodeReportsWorkspaceScreen_duplicateReport":
            MessageLookupByLibrary.simpleMessage("Duplicate the report"),
        "careEpisodeReportsWorkspaceScreen_duplicateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to duplicate the report."),
        "careEpisodeReportsWorkspaceScreen_existingAssessmentDocx":
            MessageLookupByLibrary.simpleMessage(
                "A DOCX file is already associated with this report. Do you want to replace the existing file or create a new one?"),
        "careEpisodeReportsWorkspaceScreen_existingReportDocx":
            MessageLookupByLibrary.simpleMessage(
                "A DOCX file is already associated with this report. Do you want to replace the existing file or create a new one?"),
        "careEpisodeReportsWorkspaceScreen_existingTemplateDraftMessage": m14,
        "careEpisodeReportsWorkspaceScreen_generateDocx":
            MessageLookupByLibrary.simpleMessage("Generate the DOCX file"),
        "careEpisodeReportsWorkspaceScreen_insertTextMessage": m15,
        "careEpisodeReportsWorkspaceScreen_managePractitioners":
            MessageLookupByLibrary.simpleMessage("Manage Physical Therapists"),
        "careEpisodeReportsWorkspaceScreen_managePrescribingDoctors":
            MessageLookupByLibrary.simpleMessage(
                "Manage Prescribing Physicians"),
        "careEpisodeReportsWorkspaceScreen_moveToTrash":
            MessageLookupByLibrary.simpleMessage("Move to the trash"),
        "careEpisodeReportsWorkspaceScreen_newAssessment":
            MessageLookupByLibrary.simpleMessage("New Report"),
        "careEpisodeReportsWorkspaceScreen_newAssessmentTitle":
            MessageLookupByLibrary.simpleMessage("Title of the New Report"),
        "careEpisodeReportsWorkspaceScreen_newDocument": m16,
        "careEpisodeReportsWorkspaceScreen_newReport":
            MessageLookupByLibrary.simpleMessage("New Report"),
        "careEpisodeReportsWorkspaceScreen_newReportTitle":
            MessageLookupByLibrary.simpleMessage("Title of the New Report"),
        "careEpisodeReportsWorkspaceScreen_note":
            MessageLookupByLibrary.simpleMessage("Note"),
        "careEpisodeReportsWorkspaceScreen_openReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "I can\'t open the draft of the report."),
        "careEpisodeReportsWorkspaceScreen_openReportError":
            MessageLookupByLibrary.simpleMessage("I can\'t open the report."),
        "careEpisodeReportsWorkspaceScreen_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Prescribing Physician"),
        "careEpisodeReportsWorkspaceScreen_recipients":
            MessageLookupByLibrary.simpleMessage("Recipient(s)"),
        "careEpisodeReportsWorkspaceScreen_referringPractitioner":
            MessageLookupByLibrary.simpleMessage("Primary Physical Therapist"),
        "careEpisodeReportsWorkspaceScreen_replace":
            MessageLookupByLibrary.simpleMessage("Replace"),
        "careEpisodeReportsWorkspaceScreen_reportFileName": m17,
        "careEpisodeReportsWorkspaceScreen_reportLabel":
            MessageLookupByLibrary.simpleMessage("report"),
        "careEpisodeReportsWorkspaceScreen_reportNotFound":
            MessageLookupByLibrary.simpleMessage("The report cannot be found."),
        "careEpisodeReportsWorkspaceScreen_reportReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Your report is ready. The DOCX file will include information about the patient, the author, and the recipient."),
        "careEpisodeReportsWorkspaceScreen_reportTitle":
            MessageLookupByLibrary.simpleMessage("Report Title"),
        "careEpisodeReportsWorkspaceScreen_restoreAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to restore the balance sheet"),
        "careEpisodeReportsWorkspaceScreen_restoreReportError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to restore the report."),
        "careEpisodeReportsWorkspaceScreen_resumeAssessmentDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "A work-in-progress has already been saved automatically.<br><br>Would you like to resume this draft or start a new assessment?"),
        "careEpisodeReportsWorkspaceScreen_resumeDraft":
            MessageLookupByLibrary.simpleMessage("Resume the draft"),
        "careEpisodeReportsWorkspaceScreen_resumeReportDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "A work-in-progress has already been automatically saved.<br><br>Would you like to resume this draft or start a new report?"),
        "careEpisodeReportsWorkspaceScreen_returnToDraftError":
            MessageLookupByLibrary.simpleMessage(
                "I can\'t go back to the draft."),
        "careEpisodeReportsWorkspaceScreen_returnToReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "I can\'t go back to the draft of the report."),
        "careEpisodeReportsWorkspaceScreen_save":
            MessageLookupByLibrary.simpleMessage("Save"),
        "careEpisodeReportsWorkspaceScreen_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Save the balance sheet"),
        "careEpisodeReportsWorkspaceScreen_saveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to save the balance sheet."),
        "careEpisodeReportsWorkspaceScreen_saveNoteSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to save the note selection."),
        "careEpisodeReportsWorkspaceScreen_saveReport":
            MessageLookupByLibrary.simpleMessage("Save the report"),
        "careEpisodeReportsWorkspaceScreen_saveReportError":
            MessageLookupByLibrary.simpleMessage("Unable to save the report."),
        "careEpisodeReportsWorkspaceScreen_saveTestSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to save the test selection."),
        "careEpisodeReportsWorkspaceScreen_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "SOAP Report Writing Section.<br><br>S — Subjective<br><br>O — Objective<br><br>A — Analysis<br><br>P — Plan"),
        "careEpisodeReportsWorkspaceScreen_title":
            MessageLookupByLibrary.simpleMessage("Title"),
        "careEpisodeReportsWorkspaceScreen_update":
            MessageLookupByLibrary.simpleMessage("Update"),
        "careEpisodeReportsWorkspaceScreen_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Update the balance sheet"),
        "careEpisodeReportsWorkspaceScreen_updateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to update the balance sheet."),
        "careEpisodeReportsWorkspaceScreen_updateReport":
            MessageLookupByLibrary.simpleMessage("Update the report"),
        "careEpisodeReportsWorkspaceScreen_updateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to update the report."),
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreated": m18,
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreationError": m19,
        "careEpisodeReportsWorkspaceScreen_workspaceTitle": m20,
        "careEpisodeReportsWorkspace_addFollowUpNote":
            MessageLookupByLibrary.simpleMessage("Add a follow-up note"),
        "careEpisodeReportsWorkspace_archived":
            MessageLookupByLibrary.simpleMessage("archived"),
        "careEpisodeReportsWorkspace_archivedDocuments":
            MessageLookupByLibrary.simpleMessage("Archived Documents"),
        "careEpisodeReportsWorkspace_archivedDocumentsCount":
            MessageLookupByLibrary.simpleMessage("Archived Documents"),
        "careEpisodeReportsWorkspace_assessment":
            MessageLookupByLibrary.simpleMessage("with"),
        "careEpisodeReportsWorkspace_assessmentCount":
            MessageLookupByLibrary.simpleMessage("Number of balance sheets"),
        "careEpisodeReportsWorkspace_assessmentHistory":
            MessageLookupByLibrary.simpleMessage("Balance Sheet History"),
        "careEpisodeReportsWorkspace_assessmentsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to load the balance sheets."),
        "careEpisodeReportsWorkspace_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "careEpisodeReportsWorkspace_cancelChanges":
            MessageLookupByLibrary.simpleMessage("Discard changes"),
        "careEpisodeReportsWorkspace_createOrResumeAssessment":
            MessageLookupByLibrary.simpleMessage(
                "Create or Import a Balance Sheet"),
        "careEpisodeReportsWorkspace_createOrResumeReport":
            MessageLookupByLibrary.simpleMessage("Create or resume a report"),
        "careEpisodeReportsWorkspace_date":
            MessageLookupByLibrary.simpleMessage("Data"),
        "careEpisodeReportsWorkspace_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Permanently Delete"),
        "careEpisodeReportsWorkspace_duplicate":
            MessageLookupByLibrary.simpleMessage("Duplicate"),
        "careEpisodeReportsWorkspace_edit":
            MessageLookupByLibrary.simpleMessage("Edit"),
        "careEpisodeReportsWorkspace_editReferringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Change the assigned physical therapist"),
        "careEpisodeReportsWorkspace_episodeDocuments":
            MessageLookupByLibrary.simpleMessage(
                "Documents Related to Treatment"),
        "careEpisodeReportsWorkspace_episodeSummary":
            MessageLookupByLibrary.simpleMessage("Episode Summary"),
        "careEpisodeReportsWorkspace_expand":
            MessageLookupByLibrary.simpleMessage("Enlarge"),
        "careEpisodeReportsWorkspace_expandEditor":
            MessageLookupByLibrary.simpleMessage("Expand the editing area"),
        "careEpisodeReportsWorkspace_followUpNoteDefaultTitle":
            MessageLookupByLibrary.simpleMessage("Follow-up Note"),
        "careEpisodeReportsWorkspace_followUpNotes":
            MessageLookupByLibrary.simpleMessage("Follow-up Notes"),
        "careEpisodeReportsWorkspace_followUpNotesLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to load the follow-up notes."),
        "careEpisodeReportsWorkspace_include":
            MessageLookupByLibrary.simpleMessage("Include"),
        "careEpisodeReportsWorkspace_latestTests":
            MessageLookupByLibrary.simpleMessage(
                "Tests Performed (Latest Result)"),
        "careEpisodeReportsWorkspace_loading":
            MessageLookupByLibrary.simpleMessage("Loading…"),
        "careEpisodeReportsWorkspace_moveToTrash":
            MessageLookupByLibrary.simpleMessage("Move to the trash"),
        "careEpisodeReportsWorkspace_name":
            MessageLookupByLibrary.simpleMessage("Last Name"),
        "careEpisodeReportsWorkspace_newAssessment":
            MessageLookupByLibrary.simpleMessage("Summary (new)"),
        "careEpisodeReportsWorkspace_noAssessments":
            MessageLookupByLibrary.simpleMessage("No results found."),
        "careEpisodeReportsWorkspace_noDocument":
            MessageLookupByLibrary.simpleMessage("No documents"),
        "careEpisodeReportsWorkspace_noFollowUpNotes":
            MessageLookupByLibrary.simpleMessage("No follow-up note."),
        "careEpisodeReportsWorkspace_noReports":
            MessageLookupByLibrary.simpleMessage(
                "No reports have been recorded."),
        "careEpisodeReportsWorkspace_noTests":
            MessageLookupByLibrary.simpleMessage(
                "No tests were conducted for this episode."),
        "careEpisodeReportsWorkspace_notProvided":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "careEpisodeReportsWorkspace_note":
            MessageLookupByLibrary.simpleMessage("Note"),
        "careEpisodeReportsWorkspace_pathology":
            MessageLookupByLibrary.simpleMessage("Pathology"),
        "careEpisodeReportsWorkspace_referringPractitioner":
            MessageLookupByLibrary.simpleMessage("Primary Physical Therapist"),
        "careEpisodeReportsWorkspace_referringPractitionerHistory":
            MessageLookupByLibrary.simpleMessage(
                "History of Referring Physical Therapists"),
        "careEpisodeReportsWorkspace_report":
            MessageLookupByLibrary.simpleMessage("Report"),
        "careEpisodeReportsWorkspace_reportCount":
            MessageLookupByLibrary.simpleMessage("Number of reports"),
        "careEpisodeReportsWorkspace_reportHistory":
            MessageLookupByLibrary.simpleMessage("Report History"),
        "careEpisodeReportsWorkspace_reportsLoadError":
            MessageLookupByLibrary.simpleMessage("Unable to load the reports."),
        "careEpisodeReportsWorkspace_restore":
            MessageLookupByLibrary.simpleMessage("Restore"),
        "careEpisodeReportsWorkspace_result":
            MessageLookupByLibrary.simpleMessage("Result"),
        "careEpisodeReportsWorkspace_returnToDraft":
            MessageLookupByLibrary.simpleMessage("Back to Draft"),
        "careEpisodeReportsWorkspace_returnToReportDraft":
            MessageLookupByLibrary.simpleMessage("Back to the draft report"),
        "careEpisodeReportsWorkspace_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Save the balance sheet"),
        "careEpisodeReportsWorkspace_saveReport":
            MessageLookupByLibrary.simpleMessage("Save the report"),
        "careEpisodeReportsWorkspace_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "SOAP Summary Writing Section.\n\nS — Subjective\n\nO — Objective\n\nA — Analysis\n\nP — Plan"),
        "careEpisodeReportsWorkspace_test":
            MessageLookupByLibrary.simpleMessage("Test"),
        "careEpisodeReportsWorkspace_testCount":
            MessageLookupByLibrary.simpleMessage("Number of tests"),
        "careEpisodeReportsWorkspace_testsLoadError":
            MessageLookupByLibrary.simpleMessage("Unable to load the tests."),
        "careEpisodeReportsWorkspace_title":
            MessageLookupByLibrary.simpleMessage("Title"),
        "careEpisodeReportsWorkspace_trashLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Unable to load the Recycle Bin."),
        "careEpisodeReportsWorkspace_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Update the balance sheet"),
        "careEpisodeReportsWorkspace_updateReport":
            MessageLookupByLibrary.simpleMessage("Update the report"),
        "careEpisode_assessment":
            MessageLookupByLibrary.simpleMessage("No clinical analysis."),
        "careEpisode_evaluation":
            MessageLookupByLibrary.simpleMessage("No clinical evaluation."),
        "careEpisode_report":
            MessageLookupByLibrary.simpleMessage("No initial report."),
        "careEpisode_title": MessageLookupByLibrary.simpleMessage("Coverage"),
        "careEpisode_treatment":
            MessageLookupByLibrary.simpleMessage("No treatment plan."),
        "clinicalDocuments_help": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to prepare and save assessments and reports related to patient care.\n\nFor an assessment, you can write the main text, select the test results and follow-up notes to include, and then generate a DOCX document once the assessment has been saved.\n\nDrafts are automatically saved as long as they have not been saved as an assessment or report.\n\nThe history feature allows you to find assessments and reports that have already been saved."),
        "clinicalDocuments_title": MessageLookupByLibrary.simpleMessage(
            "Financial Statements and Reports"),
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
        "deviceForm_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to create or edit a device record in Companion.\n\nEnter a name that makes it easy to identify the phone or tablet. This name is required.\n\nSelect the device’s platform: iOS or Android.\n\nYou can assign the device to a practitioner from the list or choose the “shared device” option to avoid assigning it to a specific practitioner.\n\nClick “Create” to add the device or “Save” to confirm the changes. “Cancel” closes the window without applying the changes.\n\nOpening and closing this help window preserves your entries in the form."),
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
        "deviceList_archiveConfirmation": m21,
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
        "deviceQr_help": MessageLookupByLibrary.simpleMessage(
            "This window displays the device’s identification QR code, along with its name, the practice name, and the platform.\n\nScan this QR code using ABAK Mobile to identify this device at this location. Verify that the displayed name matches the phone or tablet in question.\n\nThis QR code is used to identify the device; displaying it does not trigger a transfer of results.\n\nClose this window to return to the list of devices."),
        "deviceQr_title": MessageLookupByLibrary.simpleMessage("ABAK Device"),
        "documentArchiveConfirm_help": MessageLookupByLibrary.simpleMessage(
            "Moving a document to the Recycle Bin removes the balance sheet or report from its usual history.\n\nThe document remains stored in Companion. You can find it in the archived documents and restore it to make it reappear in the history.\n\nDOCX files that have already been exported to your computer are not deleted by this action.\n\nClick “Move to Trash” to confirm, or “Cancel” to keep the document in the history."),
        "documentArchiveConfirm_title": MessageLookupByLibrary.simpleMessage(
            "Should I move the document to the Recycle Bin?"),
        "documentAuthor_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to select the healthcare provider designated as the author of the current assessment or report.\n\nSelect the healthcare provider from the list, then click “Confirm” to save this association with the document.\n\nThis selection applies to the document’s author; it does not change the referring practitioner for the care episode.\n\n“Cancel” closes the window without changing the author."),
        "documentAuthor_title":
            MessageLookupByLibrary.simpleMessage("Choose a writer"),
        "documentDirectoryAccess_help": MessageLookupByLibrary.simpleMessage(
            "Companion cannot access the folder designated for saving documents, or its access permission needs to be renewed.\n\nIf this folder is located on an external drive or a network location, first verify that it is connected and accessible.\n\nClick “Authorize a Folder,” then select the folder in the window that opens. You can select the usual folder or choose a different destination.\n\nThe selected folder is saved in your preferences for future exports. Files already in the old folder are not moved.\n\n“Cancel” stops the current export without changing your balance sheet or report."),
        "documentDirectoryAccess_title": MessageLookupByLibrary.simpleMessage(
            "Authorize the document folder"),
        "documentDocxExisting_help": MessageLookupByLibrary.simpleMessage(
            "A DOCX file has already been associated with this balance sheet or report.\n\n“Create New” generates a new file with the document’s current content. If a file with that name already exists in the destination folder, a number is added to preserve the previous file. The new file becomes the one associated with the document in Companion.\n\n“Replace” overwrites the file with the name associated with the document in the destination folder. Any changes made directly to this file in Word or LibreOffice will be overwritten.\n\n“Cancel” cancels the export without making any changes to the files."),
        "documentDocxExisting_title":
            MessageLookupByLibrary.simpleMessage("A DOCX file already exists"),
        "documentDraftChoice_help": MessageLookupByLibrary.simpleMessage(
            "A document currently being drafted has already been automatically saved for this document type.\n\n“Resume Draft” allows you to retrieve this document and continue drafting.\n\n“New Summary” or “New Report” clears the title and text from this draft so you can start over. The previous draft is not saved as a separate document. If you want to keep your work, resume it and save it before starting a new document.\n\n“Cancel” closes this window without changing the draft."),
        "documentDraftChoice_title":
            MessageLookupByLibrary.simpleMessage("A draft exists"),
        "documentExpandedEditor_help": MessageLookupByLibrary.simpleMessage(
            "This window provides more space to write or edit the text of the current financial statement or report.\n\nYour changes are updated in real time in the main editing area. Closing the window does not discard them.\n\nClick the X to return to the Reports area, then continue preparing and saving your document.\n\nOpening and closing this help window preserves the text you have entered."),
        "documentExpandedEditor_helpTitle":
            MessageLookupByLibrary.simpleMessage("Write in the zoomed-in view"),
        "documentRecipient_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to enter the recipients of the current report or summary.\n\nEnter the name of the recipient or the names of the various recipients, then click “Submit” to save this information in the document.\n\nTo delete an existing entry, clear the field and then click “Validate.”\n\nThis entry specifies the recipients of the document; it does not trigger any sending.\n\n“Cancel” closes the window without applying the changes. Opening and closing this help window preserves your entries."),
        "documentRecipient_title":
            MessageLookupByLibrary.simpleMessage("Recipient(s)"),
        "documentTemplateDraft_help": MessageLookupByLibrary.simpleMessage(
            "Responses have already been recorded for this guide template in the current care episode.\n\n“Resume Draft” opens the guide with these responses so you can continue or edit your entries.\n\n“New Assessment” or “New Report” clears the saved responses for this template and opens the guide without restoring those responses. This option does not delete any text already present in the document’s text box.\n\n“Cancel” saves the responses and returns to the previous screen without opening the guide."),
        "documentTemplateDraft_title":
            MessageLookupByLibrary.simpleMessage("Existing draft"),
        "documentTemplateGuide_help": MessageLookupByLibrary.simpleMessage(
            "This guide helps you prepare the content for a report or summary using the selected template.\n\nUse the list of headings on the left to navigate to the different sections. Depending on the fields provided, enter text, select answers, or fill out the tables.\n\nThe preview button at the bottom of the form allows you to view the text generated based on your responses.\n\nFrom the preview, you can return to the guide to continue entering information or request that the text be inserted into the assessment or report. Follow any suggestions for additions or replacements displayed by Companion.\n\nInserting the text does not replace the final saving of the assessment or report.\n\nOpening and closing this help window preserves your entries."),
        "documentTemplateGuide_helpTitle":
            MessageLookupByLibrary.simpleMessage("Use the data entry guide"),
        "documentTemplatePreview_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to review the text generated from the answers you entered in the guide.\n\nThe text can be viewed and selected. To edit your answers, click “Close” to return to the guide, then refresh the preview.\n\nClick “Insert into the assessment” or “Insert into the report” to transfer the text to the current document. Follow any suggestions for additions or replacements displayed by Companion.\n\nIf no text has been generated, the insert button remains disabled.\n\nAfter insertion, check the document’s content and save your assessment or report."),
        "documentTemplatePreview_title": MessageLookupByLibrary.simpleMessage(
            "Preview of the Generated Text"),
        "documentTemplate_assessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "Choose a balance sheet template"),
        "documentTemplate_help": MessageLookupByLibrary.simpleMessage(
            "This window displays the templates available for the current document type: balance sheet or report.\n\nClick on a template to open the corresponding data entry guide. Selecting a template does not immediately create a saved document.\n\nIf a draft already exists for this template in the care episode, Companion will ask you whether you want to resume working on it or start a new entry."),
        "documentTemplate_reportTitle":
            MessageLookupByLibrary.simpleMessage("Choose a report template"),
        "documentTests_help": MessageLookupByLibrary.simpleMessage(
            "This expanded view allows you to review the tests performed during the patient’s care and select which ones to include in the current assessment or report.\n\nUse the checkboxes to include or exclude a test from the document. This selection does not delete the results saved in Companion.\n\nThe actions listed allow you to view detailed results. This option is available when an assessment or report is open and has finished loading.\n\nClick the X to return to the Assessments/Reports section."),
        "documentTextInsertion_help": MessageLookupByLibrary.simpleMessage(
            "Your report or document already contains text. Choose how to incorporate the content generated by the text guide.\n\n“Add to the end” keeps the existing text and adds the generated content at the end.\n\n\"Replace\" replaces all the text in the editing area with the generated content. Any text you had entered in this area will therefore also be replaced.\n\n\"Cancel\" discards this insertion and keeps the current text.\n\nYou can review and then close this help window before making your choice."),
        "documentTextInsertion_title":
            MessageLookupByLibrary.simpleMessage("Insert the generated text"),
        "documentTitle_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to enter the title of the financial statement or report.\n\nKeep the suggested title or replace it with a title that makes it easy to identify the document. The title cannot be left blank.\n\nClick the Submit button or press Enter to confirm. “Cancel” closes the window without saving the title.\n\nOpening and closing this help window preserves the text you entered."),
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
        "episodeFormEditor_requiredField": m22,
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
        "episodeNotes_archiveConfirmation": m23,
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
        "episodeReferents_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to select the referring physical therapist and the prescribing physician associated with the treatment plan.\n\nSelect the professionals from the lists. You can also remove an association by selecting the “No professional” option.\n\nThe management buttons to the right of the lists allow you to access the profiles of practitioners and external contacts, particularly to add a missing professional.\n\nClick “Save” to apply the selected associations. Changes to the primary physical therapist are saved in the treatment history.\n\n“Cancel” discards the association changes made in this window. Any records created from the management screens remain saved."),
        "episodeReferents_title":
            MessageLookupByLibrary.simpleMessage("Edit the references"),
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
        "exchangeDirectoryService_choose": MessageLookupByLibrary.simpleMessage(
            "Select the ABAK exchange folder"),
        "exchangeDirectoryUpdated":
            MessageLookupByLibrary.simpleMessage("Updated ABAK Exchange File"),
        "externalCorrespondentForm_addTitle":
            MessageLookupByLibrary.simpleMessage("Add a contact"),
        "externalCorrespondentForm_editTitle":
            MessageLookupByLibrary.simpleMessage("Edit the contact"),
        "externalCorrespondentForm_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to enter information for an external contact.\n\nThe last name is required. You can also enter the first name, occupation, specialty, address, ZIP code, city, email address, and phone number.\n\nClick “Save” to save the record. “Cancel” closes the window without saving your changes.\n\nOpening and closing this help window preserves your entries in the form."),
        "externalCorrespondents_help": MessageLookupByLibrary.simpleMessage(
            "This screen displays the external contacts saved in Companion. Each row shows the contact’s name and, if provided, their profession, specialty, and city.\n\nClick “Add” to create a contact. Enter their name and relevant contact information, then click “Save” to add them to the list. “Cancel” closes the form without creating a contact.\n\nThese contacts can be selected as referring physicians in care episodes, among other uses."),
        "externalCorrespondents_title":
            MessageLookupByLibrary.simpleMessage("External Correspondents"),
        "externalSpeechToTextProvider_empty":
            MessageLookupByLibrary.simpleMessage(
                "The add-on did not return any response."),
        "externalSpeechToTextProvider_failure":
            MessageLookupByLibrary.simpleMessage(
                "The speech recognition add-on failed."),
        "externalSpeechToTextProvider_invalid":
            MessageLookupByLibrary.simpleMessage(
                "Invalid response from the speech recognition add-on."),
        "externalSpeechToTextProvider_noText":
            MessageLookupByLibrary.simpleMessage(
                "The add-on did not return any text."),
        "externalSpeechToTextProvider_transcription":
            MessageLookupByLibrary.simpleMessage("The transcription failed."),
        "followUpNoteForm_createTitle":
            MessageLookupByLibrary.simpleMessage("New Follow-up Note"),
        "followUpNoteForm_editTitle":
            MessageLookupByLibrary.simpleMessage("Edit the follow-up note"),
        "followUpNoteForm_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to create or edit a follow-up note associated with the care episode.\n\nEnter a title and the content of the note. Both of these fields must contain text for the note to be saved.\n\nWhen creating a note, click “Add.” When editing a note, click “Save” to save your changes.\n\n“Cancel” closes the window without saving your changes. You can open and close this help window without losing the text you’re currently typing."),
        "followUpNotes_help": MessageLookupByLibrary.simpleMessage(
            "This view displays care follow-up notes, along with their date, title, and a preview of their content.\n\nThe Add button lets you create a note. The Edit icon lets you open an existing note to view or edit it.\n\nUse the checkboxes to select the notes to include in the current assessment or report. Unchecking a note removes it from this selection without deleting the follow-up note.\n\nThe selection is available when a summary or report is open and has finished loading.\n\nClick the X to close the expanded view and return to the Summaries/Reports area."),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("ARB prefix"),
        "g_close": MessageLookupByLibrary.simpleMessage("Close"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Comment"),
        "g_context": MessageLookupByLibrary.simpleMessage("Background"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "g_file": MessageLookupByLibrary.simpleMessage("File"),
        "g_helpTooltip": MessageLookupByLibrary.simpleMessage("View Help"),
        "g_learn_more": MessageLookupByLibrary.simpleMessage("Learn more"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Technical Information"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Copied technical information"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Archived patients can be restored up to the specified date.\nAfter that date, they are automatically deleted to prevent unused records from being stored indefinitely.\nThe retention period can be changed in the Companion settings."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "These are the devices (phones, tablets) used to perform the tests.\n- A device can be used by different people.\n- A person can own multiple devices.\n\nThis information helps identify the physical source of the data transferred to Companion.\nYou can create, edit, or archive a device.\n\nFor traceability purposes, it is not possible to delete a device.\nIf necessary, you can restore an archived device.\n\nA QR code is used to pair a phone or tablet. Display the QR code on the desktop computer (Device > corresponding device icon) and, on the phone (or tablet), go to Settings > Work Organization > Registered Devices > Add a Device.\n\nHold the device close to the screen to scan the QR code.A message will inform you that the operation was successful."),
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
            "A treatment plan corresponds to an episode of care.\nHere you will find the various active treatment plans for your patient.\nTo link a result, you can use an existing episode or create a new one.\nOnce the episode is complete, you can archive it."),
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
        "home_correspondents":
            MessageLookupByLibrary.simpleMessage("Correspondents"),
        "home_create_a_backup":
            MessageLookupByLibrary.simpleMessage("Create a backup"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Date not provided"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Devices"),
        "home_error_while_saving": m24,
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
        "home_other_exercises": m25,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Settings"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Path"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patient ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patients"),
        "home_pending_association": m26,
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
        "importHistory_help": MessageLookupByLibrary.simpleMessage(
            "This screen displays the history of import sessions saved in Companion.\n\nEach row shows the session date, its status, the number of files processed, and the number of results that were imported, ignored, or in conflict.\n\nThe icon indicates, among other things, an import in progress, a failure, errors, or conflicts that require your attention.\n\nClick on a session to view its details and better understand how the results were processed."),
        "importPatientForm_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to create a patient record to link the results imported from ABAK Mobile to that patient.\n\nEnter the patient’s first and last name. You can enter the patient’s date of birth in the YYYY-MM-DD format and specify their gender, or leave it as “Not specified.”\n\nIf you scanned the Vitale card, verify the pre-filled information and correct it if necessary.\n\nClick “Create” to save the patient and select them. Next, select the treatment to which the results should be linked: simply creating the patient does not complete the linking of the imported data.\n\n“Cancel” closes this window without creating a patient. Opening and then closing this help window saves your entries."),
        "importPatientForm_title":
            MessageLookupByLibrary.simpleMessage("New Patient"),
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("file"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("files"),
        "importResolutionAssistant_help": MessageLookupByLibrary.simpleMessage(
            "This screen lists the imports that require your attention: patient associations that need to be completed, failed imports, errors, ignored results, or conflicts that need to be reviewed.\n\nEach row shows the import date and the information available to identify the relevant record.\n\nClick on an import to open its tracking page, view explanations, and access the recommended actions based on its status.\n\nThe list is updated when you return from the import tracking page. If no imports meet these criteria, a message will indicate that no issues were detected."),
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
        "importResolution_help": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to link the results received from ABAK Mobile to the correct patient and treatment plan in Companion.\n\nReview the information from the imported data, then select the relevant patient from the list. If necessary, create the patient’s record using “New Patient” or “From Carte Vitale” when the card reader is available.\n\nAfter selecting the patient, choose an active treatment plan or create one. An archived treatment plan must be restored before it can be selected.\n\nVerify the patient and the treatment plan before selecting the latter: selecting it confirms the association and allows you to continue the import."),
        "importResolution_title":
            MessageLookupByLibrary.simpleMessage("Link the import"),
        "importSessionDetail_help": MessageLookupByLibrary.simpleMessage(
            "This screen displays the status of an import received in Companion. The main message indicates whether the import was successful, requires linking to a patient, or has encountered a problem.\n\nWhen a link is required, click “Link to a Patient” to select the medical record to which the results should be attached.\n\nThe report and the list of files allow you to view the details of the processing and any warnings.\n\nIf the received file is incomplete or corrupted, request that ABAK Mobile resend it.\n\nDepending on the situation, the “Delete this import” button may appear. Review the confirmation message before confirming the deletion."),
        "importSessionDetail_title":
            MessageLookupByLibrary.simpleMessage("Import Tracking"),
        "information_backupCount": m27,
        "information_backups": MessageLookupByLibrary.simpleMessage("Backups"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Configured"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "This screen displays general, technical, and legal information about Companion."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Information"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Database"),
        "information_help": MessageLookupByLibrary.simpleMessage(
            "This page displays general information about your Companion installation: the application version, the configured practice, whether the logo is displayed, the operating system, and the language.\n\nThe section on local storage shows the database size as well as the number and total size of the saved backups.\n\nThe buttons allow you to view what’s new, the license, and warnings regarding the use of the app.\n\nWhen contacting support, the Companion version and operating system displayed here can help identify your configuration."),
        "information_language":
            MessageLookupByLibrary.simpleMessage("Language"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Legal Notice"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Loading..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Local storage"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_new": MessageLookupByLibrary.simpleMessage(
            "Version 1.1.0 build 3\nVoice dictation support for assessments and reports; requires the free module.\nAutomatic saving of assessments and reports.\nButton to duplicate assessments and reports.\nEditable notes.\nButton to view all of a patient’s tests for a specific episode.\nAssessment templates.\nAutomatic graph generation if there are multiple results for a test.\nCreation of a document in docx format.\nDisplay of the help used for E72 and E76"),
        "information_newHelp": MessageLookupByLibrary.simpleMessage(
            "This page outlines the new features and updates for Companion.\n\nScroll down to view all the information. You can select and copy a section if needed.\n\nUse the back arrow to return to the “About” page."),
        "information_newTitle":
            MessageLookupByLibrary.simpleMessage("What\'s New in This Version"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Not configured"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Not specified"),
        "information_office": MessageLookupByLibrary.simpleMessage("Office"),
        "information_size": m28,
        "information_system": MessageLookupByLibrary.simpleMessage("System"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Information"),
        "information_totalSize": m29,
        "information_version": m30,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Version..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("View the license"),
        "initialReportDocumentService_associate":
            MessageLookupByLibrary.simpleMessage(
                "Attach an Initial Assessment in Word"),
        "initialReportDocumentService_unsupported":
            MessageLookupByLibrary.simpleMessage("Unsupported platform"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Language saved."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Application Language"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Disclaimer"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion is software designed to help organize, import, and view clinical results from the ABAK ecosystem.\n\nIt is not a certified medical device and is not a substitute for a healthcare professional’s judgment.\n\nThe results, scores, reports, and indicators displayed must always be interpreted by a qualified professional, taking into account the clinical examination, the patient’s context, and current recommendations.\n\nThe user remains solely responsible for their clinical decisions, for verifying imported data, and for ensuring that its use complies with applicable professional, regulatory, and ethical standards.\n\nABAK Desktop Companion does not make independent diagnoses, prescribe any treatment, or in any way replace a medical or paramedical consultation."),
        "legalNotice_help": MessageLookupByLibrary.simpleMessage(
            "This page provides warnings and information regarding the use of Companion.\n\nScroll down to read the full text.\n\nUse the back arrow to return to the \"About\" page."),
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
        "localDatabaseRestoreService_anomaly": m31,
        "localDatabaseRestoreService_failure": m32,
        "localDatabaseRestoreService_integrity": m33,
        "localDatabaseRestoreService_missing":
            MessageLookupByLibrary.simpleMessage(
                "The backup file cannot be found."),
        "localDatabaseRestoreService_success":
            MessageLookupByLibrary.simpleMessage(
                "Restoration completed successfully."),
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
        "organization_help": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to enter your practice’s name and contact information: address, ZIP code, city, phone number, and email address.\n\nClick “Save Contact Information” to save your changes before leaving the screen.\n\nYou can also select an image from your computer to set as your practice’s logo. The logo selection is saved immediately, regardless of the contact information.\n\nThe “Delete Logo” button allows you to remove the logo currently in use in Companion."),
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
        "pairPhone_help": MessageLookupByLibrary.simpleMessage(
            "This window displays the information that allows ABAK Mobile to find Companion on the local network.\n\nConnect the phone or tablet and the computer to the same local network, then scan this QR code using the Companion pairing feature in ABAK Mobile.\n\nThe QR code contains this computer’s network address and communication port. This information is also displayed below the code.\n\nKeep Companion open on the computer during data exchanges. If the computer’s network address changes, open this window again and scan the new code.\n\nDisplaying this QR code alone does not trigger the sending of results."),
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
        "patientClinicalDataEdit_help": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to complete the patient’s administrative information and profile.\n\nYou can enter the patient’s health ID, the source of their identity, their phone number, their email address, and their mailing address.\n\nThe profile includes dominant side, occupation, sports activities, height in centimeters, and weight in kilograms.\n\nClick “Save” to save your changes and return to the patient’s record. Clicking “Back” without saving will discard your changes."),
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
        "patientDetail_editCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "This window allows you to edit the patient’s treatment information.\n\nYou can correct the medical condition or reason for treatment, add to the original text, and select the referring practitioner and the prescribing physician.\n\nThe medical condition must be entered for the changes to be saved.\n\nClick “Save” to confirm the changes. “Cancel” closes the window without applying them.\n\nOpening and closing this help window preserves your entries in the form."),
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
        "patientDetail_newCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "This window allows you to create a new care episode for the selected patient.\n\nEnter the medical condition or reason for the care episode. This information is required to create the episode.\n\nYou can add to the initial text and select a referring practitioner. This information is optional.\n\nClick “Create” to save the episode. “Cancel” closes the window without creating it.\n\nOpening and closing this help window preserves your entries in the form."),
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
        "patientForm_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to enter or correct the patient’s information.\n\nThe last name and first name are required. You can select the date of birth from the calendar and enter the gender, or leave the field as “Not specified.”\n\nClick “Save” to confirm the changes. If the form is open in creation mode, the “Create” button allows you to create the record.\n\n“Cancel” closes the window without applying the changes. Opening and closing this help window preserves your entries in the form."),
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
        "patientList_archiveConfirmation": m34,
        "patientList_archiveSuccess": m35,
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
        "patientList_error": m36,
        "patientList_help": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to find your patients and access their records.\n\nThe “Active” and “Archived” buttons let you choose which list to display. The number shown corresponds to the total number of patients in each category.\n\nTo search for a patient in the displayed list, enter all or part of their last name or first name in the search field. Click on their row to open their file.\n\nThe “New Patient” button opens the screen for creating a patient.\n\nFor an active patient, the pencil icon allows you to edit their information. The archive icon allows you to remove them from the list of active patients after confirmation.\n\nIn the list of archived patients, the restore icon allows you to return a patient to the list of active patients. A specific help note, accessible next to the archiving date, explains the retention policy."),
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
        "patientList_restoreSuccess": m37,
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
        "patientNew_attachVitaleSuccess": m38,
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
        "patientNew_help": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to create a patient in ABAK Companion.\n\nEnter the patient’s first and last name: both fields are required. You can enter the patient’s date of birth using the calendar and specify the patient’s gender.\n\nThe Vitale card reader button retrieves the patient’s identity when the card reader and reading module are available. If multiple beneficiaries are suggested, select the correct person, then verify the displayed information. Manual entry is still possible.\n\nIf Companion detects a patient already in the system, verify the suggested information before proceeding to avoid a duplicate entry. An archived patient may be suggested for restoration.\n\nClick “Create Patient” to save the record, or “Cancel” to exit without creating a patient."),
        "patientNew_identificationCountriesHelp":
            MessageLookupByLibrary.simpleMessage(
                "The Vitale card reading feature offered in Companion is currently available only in France. It retrieves identity information to facilitate the creation of a patient record.\n\nABAK Companion aims to extend this functionality to identification methods used in other countries. Health cards, identifiers, and healthcare services operate differently in other countries: support for them has not yet been integrated into Companion. Manual entry remains an option.\n\nWe would like to explore these possibilities with physical therapists who use ABAK. Would you like to help us in your country? Your knowledge of local practices and your participation in the trials will help us develop a useful and tailored solution.\n\nUpdates will be developed gradually with volunteer practitioners, based on expressed needs, technical feasibility, and the necessary authorizations."),
        "patientNew_identificationCountriesTitle":
            MessageLookupByLibrary.simpleMessage(
                "Patient Identification by Country"),
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
            MessageLookupByLibrary.simpleMessage("Read health card"),
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
        "patientNew_restoreSuccess": m39,
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
        "practitionerList_archiveConfirmation": m40,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "The physical therapists\' trash can is empty right now."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage(
                "File away the physical therapist"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archived"),
        "practitionerList_archivedOn": m41,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Create a practitioner"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "This screen displays a list of registered practitioners."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("List of Practitioners"),
        "practitionerList_edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "practitionerList_error": m42,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "No physical therapists on file"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "No physical therapists listed"),
        "practitionerList_professionalId": m43,
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
        "practitionerNew_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to create or edit a practitioner’s profile.\n\nThe displayed name is required: it identifies the practitioner in Companion. You can also enter their first name, last name, professional ID, email address, and phone number.\n\nClick “Create” to add a practitioner or “Save” to save changes to an existing record.\n\n“Cancel” closes the window without saving your changes. Opening and closing this help window preserves your entries in the form."),
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
        "practitionerQr_help": MessageLookupByLibrary.simpleMessage(
            "This window displays the QR code for the practitioner’s professional profile, along with their name and the name of the practice.\n\nScan this QR code using ABAK Mobile to identify the practitioner at this facility. Verify that the name displayed matches the practitioner in question.\n\nThis QR code is used to transmit the professional profile’s identification information; displaying it does not trigger the transfer of results.\n\nClose this window to return to the list of practitioners."),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("ABAK Professional Profile"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Scan this QR code using ABAK Mobile to automatically add this professional profile."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("archived"),
        "practitionerSelector_error": m44,
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
        "referringPractitionerHistoryDialog_archivedPractitioner": m45,
        "referringPractitionerHistoryDialog_close":
            MessageLookupByLibrary.simpleMessage("Close"),
        "referringPractitionerHistoryDialog_currentPractitioner":
            MessageLookupByLibrary.simpleMessage("Current Contact Person"),
        "referringPractitionerHistoryDialog_fromTo": m46,
        "referringPractitionerHistoryDialog_loadHistoryError": m47,
        "referringPractitionerHistoryDialog_noHistory":
            MessageLookupByLibrary.simpleMessage(
                "No referring physical therapist has been registered for this episode yet."),
        "referringPractitionerHistoryDialog_since": m48,
        "referringPractitionerHistory_help": MessageLookupByLibrary.simpleMessage(
            "This window displays the practitioners who have been designated as primary care providers for this care episode.\n\nEach row shows the practitioner’s name and their assignment period. The label “Current Primary Care Provider” identifies the practitioner currently associated with the episode.\n\nThe label “Archived” means that the practitioner’s record has been archived; their name remains visible in the history.\n\nThis window is for viewing the history only. Close it to return to the care episode."),
        "referringPractitionerHistory_title":
            MessageLookupByLibrary.simpleMessage(
                "History of Referring Physical Therapists"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Refresh the dashboard"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Report Archives"),
        "reportDraft_help": MessageLookupByLibrary.simpleMessage(
            "The text displayed is a work-in-progress that has been automatically saved. You can keep it, edit it, or delete it before saving your report."),
        "reportDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Understanding the Draft Report"),
        "reportHistory_help": MessageLookupByLibrary.simpleMessage(
            "This view displays the reports saved for the case, along with their titles and dates.\n\nThe actions in each row allow you to edit a report, duplicate it, or move it to the archived documents.\n\nWhen a report is open for editing, use the \"Update\" action to save your changes. The available commands also allow you to undo changes or revert to the draft.\n\nMoving a report to the archived documents does not permanently delete it.\n\nClick the X to close the expanded view and return to the Reports/Statements area."),
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
        "resultDetail_help": MessageLookupByLibrary.simpleMessage(
            "This screen displays information about a result imported from ABAK Mobile: patient, date of test, score, and—when available—the aid used, the practitioner’s identity, and the device of origin.\n\nYou can view the detailed report and any additional measurements submitted by the practice.\n\nThe “Clinical Comment” field allows you to add or edit your observations. Click “Save” to save them before exiting the screen.\n\nThe import section shows the synchronization status and the date the result was last modified.\n\nThe archive icon allows you to archive this result after confirmation."),
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
        "settings_databaseResetError": m49,
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
        "settings_help": MessageLookupByLibrary.simpleMessage(
            "This screen groups together Companion’s installation, diagnostic, and maintenance functions. Use them as instructed in the ABAK documentation or by a technician.\n\nThe “Configuration” section allows you to view, open, or modify the folder used for file transfers.\n\nThe “Diagnostics” section provides access to checks for the Vitale card reader.\n\nThe “Maintenance” section allows you to open the import troubleshooting wizard, manually import an ABAK file, and access backup management.\n\nResetting the database deletes local data. This operation is reserved for technical support situations: read the confirmation messages carefully before proceeding."),
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
        "speechDictationButton_audio": MessageLookupByLibrary.simpleMessage(
            "No audio recording is available."),
        "speechDictationButton_close":
            MessageLookupByLibrary.simpleMessage("Close"),
        "speechDictationButton_dictate":
            MessageLookupByLibrary.simpleMessage("Anger"),
        "speechDictationButton_download":
            MessageLookupByLibrary.simpleMessage("Download the module"),
        "speechDictationButton_failure": m50,
        "speechDictationButton_information": MessageLookupByLibrary.simpleMessage(
            "Voice dictation requires the installation of the optional ABAK Voice Dictation module.\n\nThis module is free and runs locally on your computer, without sending voice recordings over the Internet.\n\nThe download is approximately 1.5 GB."),
        "speechDictationButton_stop":
            MessageLookupByLibrary.simpleMessage("Stop the dictation"),
        "speechDictationButton_title":
            MessageLookupByLibrary.simpleMessage("Voice Dictation"),
        "speechRecordingService_permission":
            MessageLookupByLibrary.simpleMessage(
                "Access to the microphone is not permitted."),
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
        "vitaleBeneficiarySelector_help": MessageLookupByLibrary.simpleMessage(
            "This window allows you to select the appropriate person when multiple beneficiaries are suggested after the Vitale card is scanned.\n\nVerify the last name, first name, and date of birth (if available), then click on the line corresponding to the desired beneficiary.\n\nSelecting a beneficiary closes this window and passes the selected information to the next step.\n\n“Cancel” closes the window without selecting a beneficiary."),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage("Select a beneficiary"),
        "vitaleDiagnostic_help": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to verify that the Vitale card reader is functioning properly.\n\nIn Windows, the section dedicated to the module displays its status and allows you to refresh this information.\n\nInitiate a read operation with the reader connected and the card inserted. If multiple beneficiaries are listed, select the relevant person to view the retrieved information.\n\nThe displayed messages help you understand the cause of any failure and can be communicated to technical support.\n\nThe “Advanced Diagnostics” section offers a technical test to verify communication with the card. Use it according to the instructions in the ABAK documentation or as directed by a technician.\n\nThis screen is for diagnostic purposes only: reading an identity does not create a patient record."),
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
        "vitaleIdentity_help": MessageLookupByLibrary.simpleMessage(
            "This screen allows you to read a beneficiary’s information from a Vitale card, provided the card reader and reading module are available.\n\nReading begins when the screen opens. You can restart the process using the read button. If there are multiple beneficiaries on the card, select the appropriate person.\n\nVerify the last name, first name, date of birth, and other displayed information. The identification number is indicated as “detected” or “unavailable” without being displayed in full.\n\nWhen the identity is valid, the “Create Patient” button allows you to transfer this information to the patient creation form.\n\nIf no identity is available, review the displayed message and check the card reader before trying again. You can return to the previous screen to enter the information manually."),
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
            MessageLookupByLibrary.simpleMessage("Not available"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Use this to create a patient"),
        "walkingAid_cane": MessageLookupByLibrary.simpleMessage("Cane"),
        "walkingAid_label": MessageLookupByLibrary.simpleMessage("Help Used"),
        "walkingAid_none": MessageLookupByLibrary.simpleMessage("None"),
        "walkingAid_other": MessageLookupByLibrary.simpleMessage("Other"),
        "walkingAid_rollatorFourWheels":
            MessageLookupByLibrary.simpleMessage("4-Wheel Rollator"),
        "walkingAid_walkerTwoWheels":
            MessageLookupByLibrary.simpleMessage("2-Wheel Walker")
      };
}
