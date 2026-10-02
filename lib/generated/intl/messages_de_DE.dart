// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de_DE locale. All the
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
  String get localeName => 'de_DE';

  static String m0(careEpisodeId) =>
      "Für die Behandlungsphase ${careEpisodeId} wurde kein Patient gefunden.";

  static String m1(height) => "${height} cm";

  static String m2(weight) => "${weight} kg";

  static String m3(age) => "${age} Jahre";

  static String m4(path) => "Zugriff auf den Ordner gewähren: ${path}";

  static String m5(path) =>
      "Wählen Sie den Ordner aus, in den die Dokumente aus ${path} wiederhergestellt werden sollen:";

  static String m6(size) => "${size}";

  static String m7(date) => "Archiviert am ${date}";

  static String m8(monthYear) => "Offene Betreuung im ${monthYear}";

  static String m9(title) =>
      "Der Bericht „${title}“ wird im Verlauf nicht mehr angezeigt.";

  static String m10(title) =>
      "Der Bericht „${title}“ wird in den Papierkorb verschoben. Er kann später wiederhergestellt werden.";

  static String m11(patientName, title) => "Bilan_${patientName}_${title}";

  static String m12(title) => "Kopie von ${title}";

  static String m13(title) =>
      "Der Bericht „${title}“ wird endgültig gelöscht. Dieser Vorgang kann nicht rückgängig gemacht werden.";

  static String m14(title) =>
      "Der Bericht „${title}“ wird endgültig gelöscht. Dieser Vorgang kann nicht rückgängig gemacht werden.";

  static String m15(path) =>
      "\"careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": \"Le dossier configuré n’est pas accessible ou son autorisation doit être renouvelée.\n\n${path}\n\nReconnectez son volume si nécessaire, puis sélectionnez ce dossier pour autoriser son accès. Le dossier sélectionné sera enregistré dans vos préférences.\",\n\"@careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": {\n  \"placeholders\": {\n    \"path\": {\n      \"type\": \"String\"\n    }\n  }\n}";

  static String m16(documentLabel) =>
      "Für diese Vorlage von ${documentLabel} gibt es bereits einen Entwurf.";

  static String m17(documentLabel) =>
      "Möchten Sie den generierten Inhalt an das aktuelle ${documentLabel} anhängen oder den bestehenden Inhalt ersetzen?";

  static String m18(documentLabel) => "Neues ${documentLabel}";

  static String m19(patientName, title) => "Bericht_${patientName}_${title}";

  static String m20(path) => "Erstelltes Word-Dokument: ${path}";

  static String m21(error) =>
      "Fehler beim Erstellen des Word-Dokuments: ${error}";

  static String m22(patientName) =>
      "${patientName} – Untersuchungsberichte und Befunde";

  static String m23(deviceName) =>
      "Möchten Sie ${deviceName} wirklich archivieren?";

  static String m24(fieldName) =>
      "Das Feld „${fieldName}“ ist ein Pflichtfeld.";

  static String m25(noteTitle) =>
      "Die Notiz „${noteTitle}“ wird nicht mehr angezeigt.";

  static String m26(error) => "Fehler beim Speichern: ${error}";

  static String m27(count) => "${count} andere Geschäftsjahre";

  static String m28(count) => "${count} Verein(e) in der Warteschlange";

  static String m29(count) => "${count} Sicherungen";

  static String m30(size) => "Größe: ${size}";

  static String m31(size) => "Gesamtgröße: ${size}";

  static String m32(version) => "Version ${version}";

  static String m33(integrityStatus) =>
      "Die wiederhergestellte Datenbank weist eine Anomalie auf: ${integrityStatus}";

  static String m34(error) => "Wiederherstellung fehlgeschlagen: ${error}";

  static String m35(integrityStatus) =>
      "Die Wiederherstellung wurde durchgeführt, aber „integrity_check“ hat Folgendes zurückgegeben: ${integrityStatus}";

  static String m36(patientName) =>
      "Möchten Sie ${patientName} wirklich archivieren? Er wird dann nicht mehr in der aktiven Liste angezeigt.";

  static String m37(patientName) => "${patientName} wurde archiviert.";

  static String m38(error) => "Fehler: ${error}";

  static String m39(patientName) =>
      "${patientName} wurde wieder in die aktive Liste aufgenommen.";

  static String m40(patientName) =>
      "Dem Patienten ${patientName} zugeordnete Krankenversicherungskarte.";

  static String m41(patientName) =>
      "Der Patient ${patientName} wurde wiederhergestellt.";

  static String m42(practitionerName) =>
      "Möchten Sie ${practitionerName} wirklich archivieren?";

  static String m43(date) => "Archiviert am ${date}";

  static String m44(error) => "Fehler: ${error}";

  static String m45(professionalId) => "ID pro: ${professionalId}";

  static String m46(error) => "Fehler: ${error}";

  static String m47(name) => "${name} – archiviert";

  static String m48(start, end) => "Du ${start} bis ${end}";

  static String m49(error) => "Fehler beim Laden des Verlaufs: ${error}";

  static String m50(start) => "Seit dem ${start}";

  static String m51(error) => "Fehler beim Zurücksetzen: ${error}";

  static String m52(patientCount, fileCount) =>
      "Export abgeschlossen: ${patientCount} Patient(en), ${fileCount} Datei(en).";

  static String m53(errorCount, patientCount, fileCount) =>
      "Der Export wurde mit ${errorCount} Fehlern abgeschlossen: ${patientCount} Patienten, ${fileCount} Dateien wurden exportiert.";

  static String m54(error) =>
      "Die Sprachsteuerung ist fehlgeschlagen: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "abakWhisperSpeechProvider_name":
            MessageLookupByLibrary.simpleMessage("ABAK Sprachdiktat"),
        "archivedDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Diese Ansicht fasst die archivierten Berichte und Zusammenfassungen der Betreuung zusammen. Jede Zeile enthält die Art des Dokuments, dessen Titel und das Archivierungsdatum.\n\nMit der Wiederherstellungsfunktion können Sie das Dokument wieder in den Verlauf der Berichte oder Zusammenfassungen aufnehmen.\n\nMit der Aktion „Endgültig löschen“ wird das Dokument aus Companion entfernt. Lesen Sie die Bestätigungsmeldung sorgfältig durch, bevor Sie bestätigen: Das Dokument kann aus dieser Liste nicht mehr wiederhergestellt werden.\n\nKlicken Sie auf das Kreuz, um die vergrößerte Ansicht zu schließen und zum Bereich „Bilanz/Berichte“ zurückzukehren."),
        "assessmentChartImageService_insufficientPoints":
            MessageLookupByLibrary.simpleMessage(
                "Eine grafische Reihe muss mindestens zwei Punkte enthalten."),
        "assessmentChartImageService_pngConversionError":
            MessageLookupByLibrary.simpleMessage(
                "Die Grafik kann nicht in ein PNG-Bild konvertiert werden."),
        "assessmentDocumentDataBuilder_female":
            MessageLookupByLibrary.simpleMessage("Weiblich"),
        "assessmentDocumentDataBuilder_male":
            MessageLookupByLibrary.simpleMessage("Männlich"),
        "assessmentDocumentDataBuilder_patient": m0,
        "assessmentDocxService_age":
            MessageLookupByLibrary.simpleMessage("Alter"),
        "assessmentDocxService_assessment":
            MessageLookupByLibrary.simpleMessage("mit"),
        "assessmentDocxService_attachment":
            MessageLookupByLibrary.simpleMessage("Pathologie beim Anschluss"),
        "assessmentDocxService_author":
            MessageLookupByLibrary.simpleMessage("Redakteur"),
        "assessmentDocxService_centimetres": m1,
        "assessmentDocxService_chart":
            MessageLookupByLibrary.simpleMessage("Grafik"),
        "assessmentDocxService_declared":
            MessageLookupByLibrary.simpleMessage("Beim Test angegebenes Alter"),
        "assessmentDocxService_diagnosis":
            MessageLookupByLibrary.simpleMessage("Pathologie beim Test"),
        "assessmentDocxService_dominance":
            MessageLookupByLibrary.simpleMessage("Dominante Seite"),
        "assessmentDocxService_establishment":
            MessageLookupByLibrary.simpleMessage("Einrichtung"),
        "assessmentDocxService_firstname":
            MessageLookupByLibrary.simpleMessage("Vorname"),
        "assessmentDocxService_height":
            MessageLookupByLibrary.simpleMessage("Größe"),
        "assessmentDocxService_information":
            MessageLookupByLibrary.simpleMessage("Angaben zum Patienten"),
        "assessmentDocxService_kilograms": m2,
        "assessmentDocxService_notes": MessageLookupByLibrary.simpleMessage(
            "Ausgewählte Nachverfolgungsnotizen"),
        "assessmentDocxService_opened":
            MessageLookupByLibrary.simpleMessage("Betreuung ab dem"),
        "assessmentDocxService_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "assessmentDocxService_patient":
            MessageLookupByLibrary.simpleMessage("Patient"),
        "assessmentDocxService_performed":
            MessageLookupByLibrary.simpleMessage("Erstellt am"),
        "assessmentDocxService_practitioner":
            MessageLookupByLibrary.simpleMessage(
                "Behandelnder Physiotherapeut"),
        "assessmentDocxService_printed":
            MessageLookupByLibrary.simpleMessage("Gedruckt am"),
        "assessmentDocxService_profession":
            MessageLookupByLibrary.simpleMessage("Beruf"),
        "assessmentDocxService_recipients":
            MessageLookupByLibrary.simpleMessage("Empfänger"),
        "assessmentDocxService_results": MessageLookupByLibrary.simpleMessage(
            "Ergebnisse der ausgewählten Tests"),
        "assessmentDocxService_sex":
            MessageLookupByLibrary.simpleMessage("Sex"),
        "assessmentDocxService_sport":
            MessageLookupByLibrary.simpleMessage("Sportliche Aktivität"),
        "assessmentDocxService_surname":
            MessageLookupByLibrary.simpleMessage("Name"),
        "assessmentDocxService_title":
            MessageLookupByLibrary.simpleMessage("mit"),
        "assessmentDocxService_weight":
            MessageLookupByLibrary.simpleMessage("Gewicht"),
        "assessmentDocxService_years": m3,
        "assessmentDraft_help": MessageLookupByLibrary.simpleMessage(
            "Der angezeigte Text entspricht einem automatisch gespeicherten Entwurf. Sie können ihn beibehalten, bearbeiten oder löschen, bevor Sie Ihren Abschluss speichern."),
        "assessmentDraft_helpTitle":
            MessageLookupByLibrary.simpleMessage("Den Bilanzentwurf verstehen"),
        "assessmentHistory_help": MessageLookupByLibrary.simpleMessage(
            "Diese Ansicht zeigt die für die Betreuung gespeicherten Berichte mit deren Titel und Datum an.\n\nÜber die Aktionen in jeder Zeile können Sie einen Bericht bearbeiten, duplizieren oder in die archivierten Dokumente verschieben.\n\nWenn ein Bericht zur Bearbeitung geöffnet ist, verwenden Sie die Aktion „Aktualisieren“, um Ihre Änderungen zu speichern. Mit den verfügbaren Befehlen können Sie außerdem die Änderungen rückgängig machen oder zum Entwurf zurückkehren.\n\nDas Verschieben in die archivierten Dokumente ist keine endgültige Löschung.\n\nKlicken Sie auf das Kreuz, um die vergrößerte Ansicht zu schließen und zum Bereich „Bilanzen/Berichte“ zurückzukehren."),
        "backupArchive_authorizeFolder": m4,
        "backupArchive_busy": MessageLookupByLibrary.simpleMessage(
            "„Eine Sicherung oder Wiederherstellung ist bereits im Gange.“"),
        "backupArchive_chooseFile":
            MessageLookupByLibrary.simpleMessage("Ein Backup öffnen…"),
        "backupArchive_legacy": MessageLookupByLibrary.simpleMessage(
            "Diese alte Sicherung enthält nur die Datenbank. Die Dateien aus den Patientenordnern wurden nicht wiederhergestellt."),
        "backupArchive_restoreFolder": m5,
        "backupArchive_resultTitle":
            MessageLookupByLibrary.simpleMessage("Ergebnis der Restaurierung"),
        "backupArchive_safetyCopies": MessageLookupByLibrary.simpleMessage(
            "Aufbewahrte Sicherungskopien:"),
        "backupArchive_working": MessageLookupByLibrary.simpleMessage(
            "Sicherung oder Wiederherstellung läuft… Bitte haben Sie einen Moment Geduld."),
        "backupHistory_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "Es wurde kein Backup gespeichert."),
        "backupHistory_fileSize": m6,
        "backupHistory_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm werden die in Companion gespeicherten Sicherungen angezeigt. In jeder Zeile sind der Dateiname, das Erstellungsdatum, die Dateigröße und der Speicherort angegeben.\n\nMit der Schaltfläche „Wiederherstellen“ können Sie die aktuelle Datenbank durch die aus der ausgewählten Sicherung ersetzen. Daten, die nach dieser Sicherung hinzugefügt oder geändert wurden, sind daher in der wiederhergestellten Datenbank nicht enthalten.\n\nÜberprüfen Sie das Datum der Sicherung und lesen Sie die Bestätigungsmeldung, bevor Sie fortfahren. Vor dem Ersetzen wird eine Sicherungskopie der aktuellen Datenbank erstellt.\n\nDie Sicherungsdatei muss immer am angegebenen Speicherort verfügbar sein. Wurde sie verschoben oder gelöscht, kann die Wiederherstellung nicht durchgeführt werden.\n\nUm eine neue Sicherung zu erstellen, verwenden Sie die Aktion „Sicherung erstellen“ auf der Startseite."),
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
        "backupHistory_restoreTitle": MessageLookupByLibrary.simpleMessage(
            "Diese Sicherung wiederherstellen?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Dieser Vorgang wird die aktuelle Datenbank vollständig ersetzen.\n\nVor der Wiederherstellung wird automatisch eine Sicherheitskopie erstellt.\n\nWeiter?"),
        "backupHistory_title":
            MessageLookupByLibrary.simpleMessage("Sicherungshistorie"),
        "bodymap_help": MessageLookupByLibrary.simpleMessage(
            "Mithilfe der Schmerzkarte lassen sich die schmerzhaften Bereiche des Patienten für die aktuelle Behandlungsphase lokalisieren.\n\nWählen Sie eine Ansicht aus und klicken Sie dann auf einen Bereich der Silhouette oder wählen Sie ihn aus der Liste aus. Sie können einen Vermerk hinzufügen und bei Bedarf eine Intensität von 0 bis 10 angeben. Verwenden Sie den Papierkorb, um einen Bereich aus dem Protokoll zu entfernen.\n\nKlicken Sie auf „Speichern“, um Ihren Befund in Companion zu speichern. Wenn Sie den Bildschirm mit ungespeicherten Änderungen verlassen, können Sie wählen, ob Sie diese speichern oder verwerfen möchten.\n\n„Beide Karten exportieren“ erstellt ein PNG-Bild an dem von Ihnen gewählten Speicherort auf Ihrem Computer. Dieser Export ersetzt nicht das Speichern der Erfassung.\n\nDieses Modul ist ein erster Entwurf, der entsprechend Ihrem Feedback weiterentwickelt werden soll. Testen Sie es in der Praxis und teilen Sie uns mit, welche Funktionen Sie gerne hinzugefügt oder verbessert sehen würden."),
        "bodymap_title": MessageLookupByLibrary.simpleMessage("Schmerzkarte"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Herkunft von ABAK"),
        "careEpisodeDetail_detail_de_la_prise_en_charge":
            MessageLookupByLibrary.simpleMessage(
                "Einzelheiten zur Kostenübernahme"),
        "careEpisodeDetail_evolution":
            MessageLookupByLibrary.simpleMessage("Entwicklung"),
        "careEpisodeDetail_noResult": MessageLookupByLibrary.simpleMessage(
            "Derzeit liegen keine Ergebnisse vor."),
        "careEpisodeDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "careEpisodeDetail_reportsWorkspaceTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Neue Benutzeroberfläche für Bilanzen und Berichte"),
        "careEpisodeDetail_results":
            MessageLookupByLibrary.simpleMessage("ABAK-Ergebnisse"),
        "careEpisodeDetail_score":
            MessageLookupByLibrary.simpleMessage("Ergebnis"),
        "careEpisodePanel_archive":
            MessageLookupByLibrary.simpleMessage("Archivieren"),
        "careEpisodePanel_archiveCareEpisode":
            MessageLookupByLibrary.simpleMessage("Die Behandlung archivieren"),
        "careEpisodePanel_archiveCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Die Übernahme konnte nicht archiviert werden. Bitte versuchen Sie es erneut."),
        "careEpisodePanel_archiveCareEpisodeMessage":
            MessageLookupByLibrary.simpleMessage(
                "Dieser Fall wird aus der Liste gestrichen. Die zugehörigen Daten werden archiviert."),
        "careEpisodePanel_archiveCareEpisodeTitle":
            MessageLookupByLibrary.simpleMessage(
                "Diese Behandlung archivieren?"),
        "careEpisodePanel_archivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage("Archivierte Fälle"),
        "careEpisodePanel_archivedCareEpisodesHelp":
            MessageLookupByLibrary.simpleMessage(
                "Hier finden Sie Ihre archivierten Behandlungsdaten."),
        "careEpisodePanel_archivedOn": m7,
        "careEpisodePanel_careEpisodeArchived":
            MessageLookupByLibrary.simpleMessage("Archivierter Fall."),
        "careEpisodePanel_careEpisodeOpenedIn": m8,
        "careEpisodePanel_careEpisodeRestored":
            MessageLookupByLibrary.simpleMessage(
                "Die Unterstützung wurde wiederhergestellt."),
        "careEpisodePanel_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Leistungen"),
        "careEpisodePanel_choose":
            MessageLookupByLibrary.simpleMessage("Auswählen"),
        "careEpisodePanel_edit":
            MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "careEpisodePanel_loadCareEpisodesError":
            MessageLookupByLibrary.simpleMessage(
                "Die Unterstützungen können nicht geladen werden."),
        "careEpisodePanel_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Neue Kostenübernahme"),
        "careEpisodePanel_noArchivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage(
                "Für diesen Patienten liegen keine archivierten Behandlungsdaten vor."),
        "careEpisodePanel_noCareEpisodes": MessageLookupByLibrary.simpleMessage(
            "Für diesen Patienten wurde keine Behandlung angelegt."),
        "careEpisodePanel_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("verschreibender Arzt"),
        "careEpisodePanel_restore":
            MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
        "careEpisodePanel_restoreCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Die Unterstützung konnte nicht wiederhergestellt werden. Bitte versuchen Sie es erneut."),
        "careEpisodeReportsWorkspaceScreen_add":
            MessageLookupByLibrary.simpleMessage("Hinzufügen"),
        "careEpisodeReportsWorkspaceScreen_append":
            MessageLookupByLibrary.simpleMessage("Zur Liste hinzufügen"),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Die Bilanz lässt sich nicht in den Papierkorb verschieben."),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentMessage": m9,
        "careEpisodeReportsWorkspaceScreen_archiveReportError":
            MessageLookupByLibrary.simpleMessage(
                "Der Bericht kann nicht in den Papierkorb verschoben werden."),
        "careEpisodeReportsWorkspaceScreen_archiveReportMessage": m10,
        "careEpisodeReportsWorkspaceScreen_assessmentFileName": m11,
        "careEpisodeReportsWorkspaceScreen_assessmentLabel":
            MessageLookupByLibrary.simpleMessage("mit"),
        "careEpisodeReportsWorkspaceScreen_assessmentNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Die Bilanz ist nicht auffindbar."),
        "careEpisodeReportsWorkspaceScreen_assessmentReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Ihr Bericht ist fertig. Die DOCX-Datei enthält die eingegebenen Informationen und die ausgewählten Elemente."),
        "careEpisodeReportsWorkspaceScreen_assessmentTitle":
            MessageLookupByLibrary.simpleMessage("Titel der Bilanz"),
        "careEpisodeReportsWorkspaceScreen_assessmentsAndReports":
            MessageLookupByLibrary.simpleMessage("Bilanzen und Berichte"),
        "careEpisodeReportsWorkspaceScreen_author":
            MessageLookupByLibrary.simpleMessage("Redakteur"),
        "careEpisodeReportsWorkspaceScreen_authorizeDirectory":
            MessageLookupByLibrary.simpleMessage("Einen Ordner freigeben"),
        "careEpisodeReportsWorkspaceScreen_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "careEpisodeReportsWorkspaceScreen_cancelChangesError":
            MessageLookupByLibrary.simpleMessage(
                "Die Änderungen können nicht rückgängig gemacht werden."),
        "careEpisodeReportsWorkspaceScreen_cancelReportChangesError":
            MessageLookupByLibrary.simpleMessage(
                "Die Änderungen am Bericht können nicht rückgängig gemacht werden."),
        "careEpisodeReportsWorkspaceScreen_close":
            MessageLookupByLibrary.simpleMessage("Schließen"),
        "careEpisodeReportsWorkspaceScreen_confirm":
            MessageLookupByLibrary.simpleMessage("Bestätigen"),
        "careEpisodeReportsWorkspaceScreen_copyTitle": m12,
        "careEpisodeReportsWorkspaceScreen_createNew":
            MessageLookupByLibrary.simpleMessage("Neu erstellen"),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Die Bilanz kann nicht endgültig gelöscht werden."),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentMessage": m13,
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "Die Bilanz endgültig löschen?"),
        "careEpisodeReportsWorkspaceScreen_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Endgültig löschen"),
        "careEpisodeReportsWorkspaceScreen_deleteReportError":
            MessageLookupByLibrary.simpleMessage(
                "Der Bericht kann nicht endgültig gelöscht werden."),
        "careEpisodeReportsWorkspaceScreen_deleteReportMessage": m14,
        "careEpisodeReportsWorkspaceScreen_deleteReportTitle":
            MessageLookupByLibrary.simpleMessage(
                "Den Bericht endgültig löschen?"),
        "careEpisodeReportsWorkspaceScreen_directoryAccessMessage": m15,
        "careEpisodeReportsWorkspaceScreen_duplicate":
            MessageLookupByLibrary.simpleMessage("Duplizieren"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessment":
            MessageLookupByLibrary.simpleMessage("Bilanz duplizieren"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Die Bilanz kann nicht dupliziert werden."),
        "careEpisodeReportsWorkspaceScreen_duplicateReport":
            MessageLookupByLibrary.simpleMessage("Bericht duplizieren"),
        "careEpisodeReportsWorkspaceScreen_duplicateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Der Bericht kann nicht dupliziert werden."),
        "careEpisodeReportsWorkspaceScreen_existingAssessmentDocx":
            MessageLookupByLibrary.simpleMessage(
                "Dieser Bilanz ist bereits eine DOCX-Datei zugeordnet. Möchten Sie die vorhandene Datei ersetzen oder eine neue Datei erstellen?"),
        "careEpisodeReportsWorkspaceScreen_existingReportDocx":
            MessageLookupByLibrary.simpleMessage(
                "Diesem Bericht ist bereits eine DOCX-Datei zugeordnet. Möchten Sie die vorhandene Datei ersetzen oder eine neue Datei erstellen?"),
        "careEpisodeReportsWorkspaceScreen_existingTemplateDraftMessage": m16,
        "careEpisodeReportsWorkspaceScreen_generate":
            MessageLookupByLibrary.simpleMessage("Generieren"),
        "careEpisodeReportsWorkspaceScreen_generateDocx":
            MessageLookupByLibrary.simpleMessage("DOCX-Datei erstellen"),
        "careEpisodeReportsWorkspaceScreen_insertTextMessage": m17,
        "careEpisodeReportsWorkspaceScreen_managePractitioners":
            MessageLookupByLibrary.simpleMessage("Physiotherapeuten verwalten"),
        "careEpisodeReportsWorkspaceScreen_managePrescribingDoctors":
            MessageLookupByLibrary.simpleMessage(
                "Verschreibende Ärzte verwalten"),
        "careEpisodeReportsWorkspaceScreen_moveToTrash":
            MessageLookupByLibrary.simpleMessage(
                "In den Papierkorb verschieben"),
        "careEpisodeReportsWorkspaceScreen_newAssessment":
            MessageLookupByLibrary.simpleMessage("Neue Bilanz"),
        "careEpisodeReportsWorkspaceScreen_newAssessmentTitle":
            MessageLookupByLibrary.simpleMessage("Titel der neuen Bilanz"),
        "careEpisodeReportsWorkspaceScreen_newDocument": m18,
        "careEpisodeReportsWorkspaceScreen_newReport":
            MessageLookupByLibrary.simpleMessage("Neuer Bericht"),
        "careEpisodeReportsWorkspaceScreen_newReportTitle":
            MessageLookupByLibrary.simpleMessage("Titel des neuen Berichts"),
        "careEpisodeReportsWorkspaceScreen_note":
            MessageLookupByLibrary.simpleMessage("Anmerkung"),
        "careEpisodeReportsWorkspaceScreen_openReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Der Berichtsentwurf lässt sich nicht öffnen."),
        "careEpisodeReportsWorkspaceScreen_openReportError":
            MessageLookupByLibrary.simpleMessage(
                "Der Bericht lässt sich nicht öffnen."),
        "careEpisodeReportsWorkspaceScreen_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("verschreibender Arzt"),
        "careEpisodeReportsWorkspaceScreen_recipients":
            MessageLookupByLibrary.simpleMessage("Empfänger"),
        "careEpisodeReportsWorkspaceScreen_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Behandelnder Physiotherapeut"),
        "careEpisodeReportsWorkspaceScreen_replace":
            MessageLookupByLibrary.simpleMessage("Ersetzen"),
        "careEpisodeReportsWorkspaceScreen_reportFileName": m19,
        "careEpisodeReportsWorkspaceScreen_reportLabel":
            MessageLookupByLibrary.simpleMessage("Bericht"),
        "careEpisodeReportsWorkspaceScreen_reportNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Der Bericht ist nicht auffindbar."),
        "careEpisodeReportsWorkspaceScreen_reportOptionsTitle":
            MessageLookupByLibrary.simpleMessage("Berichtsoptionen"),
        "careEpisodeReportsWorkspaceScreen_reportReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Ihr Bericht ist fertig. Die DOCX-Datei enthält die Angaben zum Patienten, zum Verfasser und zum Empfänger."),
        "careEpisodeReportsWorkspaceScreen_reportTitle":
            MessageLookupByLibrary.simpleMessage("Titel des Berichts"),
        "careEpisodeReportsWorkspaceScreen_restoreAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Die Bilanz kann nicht wiederhergestellt werden"),
        "careEpisodeReportsWorkspaceScreen_restoreReportError":
            MessageLookupByLibrary.simpleMessage(
                "Der Bericht kann nicht wiederhergestellt werden."),
        "careEpisodeReportsWorkspaceScreen_resumeAssessmentDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Ein laufendes Dokument wurde bereits automatisch gespeichert.<br><br>Möchten Sie diesen Entwurf fortsetzen oder eine neue Bilanz erstellen?"),
        "careEpisodeReportsWorkspaceScreen_resumeDraft":
            MessageLookupByLibrary.simpleMessage(
                "Den Entwurf wieder aufnehmen"),
        "careEpisodeReportsWorkspaceScreen_resumeReportDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Ein laufender Entwurf wurde bereits automatisch gespeichert.<br><br>Möchten Sie diesen Entwurf fortsetzen oder einen neuen Bericht erstellen?"),
        "careEpisodeReportsWorkspaceScreen_returnToDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Es ist nicht möglich, zum Entwurf zurückzukehren."),
        "careEpisodeReportsWorkspaceScreen_returnToReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Es ist nicht möglich, zum Entwurf des Berichts zurückzukehren."),
        "careEpisodeReportsWorkspaceScreen_save":
            MessageLookupByLibrary.simpleMessage("Speichern"),
        "careEpisodeReportsWorkspaceScreen_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Bilanz speichern"),
        "careEpisodeReportsWorkspaceScreen_saveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Die Bilanz kann nicht gespeichert werden."),
        "careEpisodeReportsWorkspaceScreen_saveNoteSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Die Auswahl der Note kann nicht gespeichert werden."),
        "careEpisodeReportsWorkspaceScreen_saveReport":
            MessageLookupByLibrary.simpleMessage("Bericht speichern"),
        "careEpisodeReportsWorkspaceScreen_saveReportError":
            MessageLookupByLibrary.simpleMessage(
                "Der Bericht kann nicht gespeichert werden."),
        "careEpisodeReportsWorkspaceScreen_saveTestSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Die Testauswahl kann nicht gespeichert werden."),
        "careEpisodeReportsWorkspaceScreen_showPrescriber":
            MessageLookupByLibrary.simpleMessage("Verschreibenden anzeigen"),
        "careEpisodeReportsWorkspaceScreen_showReferringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Den zuständigen Physiotherapeuten anzeigen"),
        "careEpisodeReportsWorkspaceScreen_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Bereich zur Erstellung der SOAP-Bilanz.<br><br>S – Subjektiv<br><br>O – Objektiv<br><br>A – Analyse<br><br>P – Plan"),
        "careEpisodeReportsWorkspaceScreen_title":
            MessageLookupByLibrary.simpleMessage("Titel"),
        "careEpisodeReportsWorkspaceScreen_update":
            MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "careEpisodeReportsWorkspaceScreen_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Bilanz aktualisieren"),
        "careEpisodeReportsWorkspaceScreen_updateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Die Bilanz kann nicht aktualisiert werden."),
        "careEpisodeReportsWorkspaceScreen_updateReport":
            MessageLookupByLibrary.simpleMessage("Den Bericht aktualisieren"),
        "careEpisodeReportsWorkspaceScreen_updateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Der Bericht kann nicht aktualisiert werden."),
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreated": m20,
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreationError": m21,
        "careEpisodeReportsWorkspaceScreen_workspaceTitle": m22,
        "careEpisodeReportsWorkspace_addFollowUpNote":
            MessageLookupByLibrary.simpleMessage(
                "Eine Folgeanmerkung hinzufügen"),
        "careEpisodeReportsWorkspace_archived":
            MessageLookupByLibrary.simpleMessage("archiviert"),
        "careEpisodeReportsWorkspace_archivedDocuments":
            MessageLookupByLibrary.simpleMessage("Archivierte Dokumente"),
        "careEpisodeReportsWorkspace_archivedDocumentsCount":
            MessageLookupByLibrary.simpleMessage("Archivierte Dokumente"),
        "careEpisodeReportsWorkspace_assessment":
            MessageLookupByLibrary.simpleMessage("mit"),
        "careEpisodeReportsWorkspace_assessmentCount":
            MessageLookupByLibrary.simpleMessage("Anzahl der Bilanzen"),
        "careEpisodeReportsWorkspace_assessmentHistory":
            MessageLookupByLibrary.simpleMessage("Bilanzentwicklung"),
        "careEpisodeReportsWorkspace_assessmentsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Die Bilanzen können nicht geladen werden."),
        "careEpisodeReportsWorkspace_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "careEpisodeReportsWorkspace_cancelChanges":
            MessageLookupByLibrary.simpleMessage("Änderungen verwerfen"),
        "careEpisodeReportsWorkspace_createOrResumeAssessment":
            MessageLookupByLibrary.simpleMessage(
                "Eine Bilanz erstellen oder übernehmen"),
        "careEpisodeReportsWorkspace_createOrResumeReport":
            MessageLookupByLibrary.simpleMessage(
                "Einen Bericht erstellen oder übernehmen"),
        "careEpisodeReportsWorkspace_date":
            MessageLookupByLibrary.simpleMessage("Daten"),
        "careEpisodeReportsWorkspace_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Endgültig löschen"),
        "careEpisodeReportsWorkspace_duplicate":
            MessageLookupByLibrary.simpleMessage("Duplizieren"),
        "careEpisodeReportsWorkspace_edit":
            MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "careEpisodeReportsWorkspace_editReferringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Den zuständigen Physiotherapeuten ändern"),
        "careEpisodeReportsWorkspace_episodeDocuments":
            MessageLookupByLibrary.simpleMessage("Unterlagen zur Betreuung"),
        "careEpisodeReportsWorkspace_episodeSummary":
            MessageLookupByLibrary.simpleMessage("Zusammenfassung der Folge"),
        "careEpisodeReportsWorkspace_expand":
            MessageLookupByLibrary.simpleMessage("Vergrößern"),
        "careEpisodeReportsWorkspace_expandEditor":
            MessageLookupByLibrary.simpleMessage(
                "Den Bearbeitungsbereich vergrößern"),
        "careEpisodeReportsWorkspace_followUpNoteDefaultTitle":
            MessageLookupByLibrary.simpleMessage("Folgebericht"),
        "careEpisodeReportsWorkspace_followUpNotes":
            MessageLookupByLibrary.simpleMessage("Folgeanmerkungen"),
        "careEpisodeReportsWorkspace_followUpNotesLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Die Nachverfolgungsnotizen können nicht geladen werden."),
        "careEpisodeReportsWorkspace_include":
            MessageLookupByLibrary.simpleMessage("Einfügen"),
        "careEpisodeReportsWorkspace_latestTests":
            MessageLookupByLibrary.simpleMessage(
                "Durchgeführte Tests (letzter Befund)"),
        "careEpisodeReportsWorkspace_loading":
            MessageLookupByLibrary.simpleMessage("Wird geladen…"),
        "careEpisodeReportsWorkspace_moveToTrash":
            MessageLookupByLibrary.simpleMessage(
                "In den Papierkorb verschieben"),
        "careEpisodeReportsWorkspace_name":
            MessageLookupByLibrary.simpleMessage("Name"),
        "careEpisodeReportsWorkspace_newAssessment":
            MessageLookupByLibrary.simpleMessage("Bilanz (neu)"),
        "careEpisodeReportsWorkspace_noAssessments":
            MessageLookupByLibrary.simpleMessage(
                "Es wurde kein Ergebnis erfasst."),
        "careEpisodeReportsWorkspace_noDocument":
            MessageLookupByLibrary.simpleMessage("Keine Dokumente"),
        "careEpisodeReportsWorkspace_noFollowUpNotes":
            MessageLookupByLibrary.simpleMessage("Keine Folgeanmerkung."),
        "careEpisodeReportsWorkspace_noReports":
            MessageLookupByLibrary.simpleMessage(
                "Es wurde kein Bericht erfasst."),
        "careEpisodeReportsWorkspace_noTests":
            MessageLookupByLibrary.simpleMessage(
                "Für diese Folge wurden keine Tests durchgeführt."),
        "careEpisodeReportsWorkspace_notProvided":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "careEpisodeReportsWorkspace_note":
            MessageLookupByLibrary.simpleMessage("Anmerkung"),
        "careEpisodeReportsWorkspace_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "careEpisodeReportsWorkspace_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Behandelnder Physiotherapeut"),
        "careEpisodeReportsWorkspace_referringPractitionerHistory":
            MessageLookupByLibrary.simpleMessage(
                "Übersicht über die zuständigen Physiotherapeuten"),
        "careEpisodeReportsWorkspace_report":
            MessageLookupByLibrary.simpleMessage("Bericht"),
        "careEpisodeReportsWorkspace_reportCount":
            MessageLookupByLibrary.simpleMessage("Anzahl der Berichte"),
        "careEpisodeReportsWorkspace_reportHistory":
            MessageLookupByLibrary.simpleMessage("Berichtsverlauf"),
        "careEpisodeReportsWorkspace_reportsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Die Berichte können nicht geladen werden."),
        "careEpisodeReportsWorkspace_restore":
            MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
        "careEpisodeReportsWorkspace_result":
            MessageLookupByLibrary.simpleMessage("Ergebnis"),
        "careEpisodeReportsWorkspace_returnToDraft":
            MessageLookupByLibrary.simpleMessage("Zurück zum Entwurf"),
        "careEpisodeReportsWorkspace_returnToReportDraft":
            MessageLookupByLibrary.simpleMessage("Zurück zum Berichtsentwurf"),
        "careEpisodeReportsWorkspace_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Bilanz speichern"),
        "careEpisodeReportsWorkspace_saveReport":
            MessageLookupByLibrary.simpleMessage("Bericht speichern"),
        "careEpisodeReportsWorkspace_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Bereich zur Erstellung des SOAP-Berichts.\n\nS – Subjektiv\n\nO – Objektiv\n\nA – Analyse\n\nP – Plan"),
        "careEpisodeReportsWorkspace_test":
            MessageLookupByLibrary.simpleMessage("Test"),
        "careEpisodeReportsWorkspace_testCount":
            MessageLookupByLibrary.simpleMessage("Anzahl der Tests"),
        "careEpisodeReportsWorkspace_testsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Die Tests können nicht geladen werden."),
        "careEpisodeReportsWorkspace_title":
            MessageLookupByLibrary.simpleMessage("Titel"),
        "careEpisodeReportsWorkspace_trashLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Der Papierkorb kann nicht geladen werden."),
        "careEpisodeReportsWorkspace_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Bilanz aktualisieren"),
        "careEpisodeReportsWorkspace_updateReport":
            MessageLookupByLibrary.simpleMessage("Den Bericht aktualisieren"),
        "careEpisode_assessment": MessageLookupByLibrary.simpleMessage(
            "Keine klinische Untersuchung."),
        "careEpisode_evaluation":
            MessageLookupByLibrary.simpleMessage("Keine klinische Bewertung."),
        "careEpisode_report": MessageLookupByLibrary.simpleMessage(
            "Es liegt noch kein erster Bericht vor."),
        "careEpisode_title": MessageLookupByLibrary.simpleMessage("Betreuung"),
        "careEpisode_treatment":
            MessageLookupByLibrary.simpleMessage("Kein Behandlungsplan."),
        "clinicalDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm können Sie die zu einer Behandlung gehörenden Befunde und Berichte erstellen und speichern.\n\nFür einen Befund können Sie den Haupttext verfassen, die einzufügenden Testergebnisse und Nachsorgehinweise auswählen und nach dem Speichern des Befunds ein DOCX-Dokument erstellen.\n\nEntwürfe werden automatisch gespeichert, solange sie nicht als Bilanz oder Bericht gespeichert werden.\n\nÜber den Verlauf können Sie bereits gespeicherte Bilanzen und Berichte abrufen."),
        "clinicalDocuments_title":
            MessageLookupByLibrary.simpleMessage("Bilanzen und Berichte"),
        "close": MessageLookupByLibrary.simpleMessage("Schließen"),
        "contactFormTemplateDiagnostic_category":
            MessageLookupByLibrary.simpleMessage("Kategorie"),
        "contactFormTemplateDiagnostic_defaultTemplate":
            MessageLookupByLibrary.simpleMessage("Standardvorlage"),
        "contactFormTemplateDiagnostic_error":
            MessageLookupByLibrary.simpleMessage("Fehler"),
        "contactFormTemplateDiagnostic_fields":
            MessageLookupByLibrary.simpleMessage("Felder"),
        "contactFormTemplateDiagnostic_no":
            MessageLookupByLibrary.simpleMessage("Nicht"),
        "contactFormTemplateDiagnostic_noData":
            MessageLookupByLibrary.simpleMessage(
                "Es sind keine Daten vorhanden."),
        "contactFormTemplateDiagnostic_noTemplate":
            MessageLookupByLibrary.simpleMessage(
                "Es wurde keine Vorlage für ein Erstgesprächsformular gefunden."),
        "contactFormTemplateDiagnostic_notDefined":
            MessageLookupByLibrary.simpleMessage("Nicht definiert"),
        "contactFormTemplateDiagnostic_order":
            MessageLookupByLibrary.simpleMessage("Reihenfolge"),
        "contactFormTemplateDiagnostic_practitioner":
            MessageLookupByLibrary.simpleMessage("Praktiker"),
        "contactFormTemplateDiagnostic_refresh":
            MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "contactFormTemplateDiagnostic_required":
            MessageLookupByLibrary.simpleMessage("Erforderlich"),
        "contactFormTemplateDiagnostic_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Systemmodell"),
        "contactFormTemplateDiagnostic_templateId":
            MessageLookupByLibrary.simpleMessage("Modell-ID"),
        "contactFormTemplateDiagnostic_title":
            MessageLookupByLibrary.simpleMessage("Diagnose – Wartungsblatt"),
        "contactFormTemplateDiagnostic_type":
            MessageLookupByLibrary.simpleMessage("Typ"),
        "contactFormTemplateDiagnostic_yes":
            MessageLookupByLibrary.simpleMessage("Ja"),
        "dashboardTitle":
            MessageLookupByLibrary.simpleMessage("Lokale ABAK-Klinikstation"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Adresse"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Hafen"),
        "deviceForm_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Assoziierter Arzt"),
        "deviceForm_cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "deviceForm_contextName":
            MessageLookupByLibrary.simpleMessage("Neues Gerät"),
        "deviceForm_create": MessageLookupByLibrary.simpleMessage("Erstellen"),
        "deviceForm_deviceName":
            MessageLookupByLibrary.simpleMessage("Gerätename"),
        "deviceForm_deviceNameHint":
            MessageLookupByLibrary.simpleMessage("iPhone Claire, Pixel Marc…"),
        "deviceForm_deviceNameRequired": MessageLookupByLibrary.simpleMessage(
            "Der Name des Geräts ist ein Pflichtfeld."),
        "deviceForm_editDevice":
            MessageLookupByLibrary.simpleMessage("Gerät ändern"),
        "deviceForm_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie einen Geräteeintrag in Companion erstellen oder bearbeiten.\n\nGeben Sie einen Namen ein, anhand dessen das Smartphone oder Tablet leicht zu erkennen ist. Die Angabe dieses Namens ist obligatorisch.\n\nWählen Sie die Plattform des Geräts aus: iOS oder Android.\n\nSie können das Gerät einem Arzt aus der Liste zuordnen oder die Option „Gemeinsam genutztes Gerät“ wählen, um es keinem bestimmten Arzt zuzuweisen.\n\nKlicken Sie auf „Erstellen“, um das Gerät hinzuzufügen, oder auf „Speichern“, um die Änderungen zu übernehmen. Mit „Abbrechen“ schließen Sie das Fenster, ohne die Änderungen zu übernehmen.\n\nBeim Öffnen und Schließen dieser Hilfe bleiben Ihre Eingaben im Formular erhalten."),
        "deviceForm_loadingPractitionersError":
            MessageLookupByLibrary.simpleMessage("Fehler beim Laden der Ärzte"),
        "deviceForm_newDevice":
            MessageLookupByLibrary.simpleMessage("Neues Gerät"),
        "deviceForm_platform":
            MessageLookupByLibrary.simpleMessage("Plattform"),
        "deviceForm_save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "deviceForm_sharedDevice": MessageLookupByLibrary.simpleMessage(
            "Keine / gemeinsam genutztes Gerät"),
        "deviceList_active":
            MessageLookupByLibrary.simpleMessage("Vermögenswerte"),
        "deviceList_archive":
            MessageLookupByLibrary.simpleMessage("Archivieren"),
        "deviceList_archiveConfirmation": m23,
        "deviceList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Gerät archivieren"),
        "deviceList_archived":
            MessageLookupByLibrary.simpleMessage("Archiviert"),
        "deviceList_archivedDevicesEmpty": MessageLookupByLibrary.simpleMessage(
            "Der Warenkorb ist derzeit leer."),
        "deviceList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archiviert am"),
        "deviceList_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Assoziierter Arzt"),
        "deviceList_cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "deviceList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Dieser Bildschirm zeigt die Liste der mit der Einrichtung verbundenen Geräte an"),
        "deviceList_contextName":
            MessageLookupByLibrary.simpleMessage("Geräteliste"),
        "deviceList_edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "deviceList_error": MessageLookupByLibrary.simpleMessage("Fehler"),
        "deviceList_newDevice":
            MessageLookupByLibrary.simpleMessage("Neues Gerät"),
        "deviceList_noArchivedDevices": MessageLookupByLibrary.simpleMessage(
            "Es sind keine Geräte archiviert."),
        "deviceList_noPairedDevices":
            MessageLookupByLibrary.simpleMessage("Keine zugehörigen Geräte"),
        "deviceList_pairedDevicesExplanation": MessageLookupByLibrary.simpleMessage(
            "Die mit der Einrichtung verknüpften ABAK-Geräte werden hier angezeigt."),
        "deviceList_platform":
            MessageLookupByLibrary.simpleMessage("Plattform"),
        "deviceList_restore":
            MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
        "deviceList_showQrCode":
            MessageLookupByLibrary.simpleMessage("QR-Code anzeigen"),
        "deviceList_title": MessageLookupByLibrary.simpleMessage("Geräteliste"),
        "deviceQr_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster wird der QR-Code zur Identifizierung des Geräts angezeigt, zusammen mit dessen Namen, dem Namen der Praxis und der Plattform.\n\nScannen Sie diesen QR-Code mit ABAK Mobile, um dieses Gerät in dieser Einrichtung zu identifizieren. Vergewissern Sie sich, dass der angezeigte Name tatsächlich dem betreffenden Smartphone oder Tablet entspricht.\n\nDieser QR-Code dient zur Identifizierung des Geräts; seine Anzeige löst keine Übertragung von Ergebnissen aus.\n\nSchließen Sie dieses Fenster, um zur Geräteliste zurückzukehren."),
        "deviceQr_title": MessageLookupByLibrary.simpleMessage("ABAK-Gerät"),
        "documentArchiveConfirm_help": MessageLookupByLibrary.simpleMessage(
            "Durch das Verschieben in den Papierkorb wird die Bilanz oder der Bericht aus dem üblichen Verlauf entfernt.\n\nDas Dokument bleibt in Companion gespeichert. Sie können es in den archivierten Dokumenten wiederfinden und wiederherstellen, damit es erneut im Verlauf erscheint.\n\nDOCX-Dateien, die bereits auf Ihren Computer exportiert wurden, werden durch diesen Vorgang nicht gelöscht.\n\nKlicken Sie auf „In den Papierkorb“, um den Vorgang zu bestätigen, oder auf „Abbrechen“, um das Dokument im Verlauf zu behalten."),
        "documentArchiveConfirm_title": MessageLookupByLibrary.simpleMessage(
            "Das Dokument in den Papierkorb verschieben?"),
        "documentAuthor_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie den Arzt auswählen, der als Verfasser der aktuellen Beurteilung oder des aktuellen Berichts festgelegt werden soll.\n\nWählen Sie den Arzt aus der Liste aus und klicken Sie anschließend auf „Bestätigen“, um diese Zuordnung zum Dokument zu speichern.\n\nDiese Auswahl betrifft den Verfasser des Dokuments; sie ändert nichts an der Zuständigkeit des behandelnden Arztes für den Behandlungsfall.\n\nMit „Abbrechen“ wird das Fenster geschlossen, ohne den Verfasser zu ändern."),
        "documentAuthor_title":
            MessageLookupByLibrary.simpleMessage("Den Verfasser auswählen"),
        "documentDirectoryAccess_help": MessageLookupByLibrary.simpleMessage(
            "Companion kann nicht auf den Ordner zugreifen, der zum Speichern der Dokumente vorgesehen ist, oder seine Zugriffsberechtigung muss erneuert werden.\n\nBefindet sich dieser Ordner auf einem externen Laufwerk oder einem Netzwerkspeicherort, überprüfen Sie zunächst, ob dieser angeschlossen und zugänglich ist.\n\nKlicken Sie auf „Ordner autorisieren“ und wählen Sie anschließend den Ordner im sich öffnenden Fenster aus. Sie können den üblichen Ordner auswählen oder ein anderes Ziel festlegen.\n\nDer ausgewählte Ordner wird für zukünftige Exporte in Ihren Einstellungen gespeichert. Dateien, die sich bereits im alten Ordner befinden, werden nicht verschoben.\n\n„Abbrechen“ bricht den laufenden Export ab, ohne Ihre Bilanz oder Ihren Bericht zu ändern."),
        "documentDirectoryAccess_title": MessageLookupByLibrary.simpleMessage(
            "Den Dokumentordner freigeben"),
        "documentDocxExisting_help": MessageLookupByLibrary.simpleMessage(
            "Dieser Bilanz oder diesem Bericht ist bereits eine DOCX-Datei zugeordnet.\n\n„Neu erstellen“ erzeugt eine neue Datei mit dem aktuellen Inhalt des Dokuments. Falls der Dateiname im Zielordner bereits vorhanden ist, wird eine Nummer hinzugefügt, um die vorherige Datei beizubehalten. Die neue Datei wird dann dem Dokument in Companion zugeordnet.\n\n„Ersetzen“ überschreibt die Datei mit dem dem Dokument zugeordneten Namen im Zielordner. Eventuelle Änderungen, die direkt in dieser Datei in Word oder LibreOffice vorgenommen wurden, werden überschrieben.\n\n„Abbrechen“ bricht den Export ab, ohne die Dateien zu ändern."),
        "documentDocxExisting_title": MessageLookupByLibrary.simpleMessage(
            "Es gibt bereits eine DOCX-Datei"),
        "documentDraftChoice_help": MessageLookupByLibrary.simpleMessage(
            "Ein Text, der gerade erstellt wird, wurde für diesen Dokumenttyp bereits automatisch gespeichert.\n\nMit „Entwurf wiederherstellen“ können Sie diesen Text wiederfinden und mit dem Schreiben fortfahren.\n\n„Neue Bilanz“ oder „Neuer Bericht“ löscht den Titel und den Text dieses Entwurfs, damit Sie von vorne beginnen können. Der vorherige Entwurf wird nicht als separates Dokument gespeichert. Wenn Sie Ihre Arbeit behalten möchten, rufen Sie den Entwurf auf und speichern Sie ihn, bevor Sie ein neues Dokument anlegen.\n\nMit „Abbrechen“ schließen Sie dieses Fenster, ohne den Entwurf zu ändern."),
        "documentDraftChoice_title":
            MessageLookupByLibrary.simpleMessage("Es gibt einen Entwurf"),
        "documentExpandedEditor_help": MessageLookupByLibrary.simpleMessage(
            "Dieses Fenster bietet mehr Platz zum Verfassen oder Bearbeiten des Textes der aktuellen Bilanz oder des Berichts.\n\nIhre Änderungen werden fortlaufend in den Hauptbearbeitungsbereich übernommen. Durch das Schließen des Fensters werden sie nicht verworfen.\n\nKlicken Sie auf das Kreuz, um zum Bereich „Bilanzen/Berichte“ zurückzukehren, und fahren Sie dann mit der Erstellung und dem Speichern Ihres Dokuments fort.\n\nBeim Öffnen und Schließen dieser Hilfe bleibt der eingegebene Text erhalten."),
        "documentExpandedEditor_helpTitle":
            MessageLookupByLibrary.simpleMessage(
                "In der vergrößerten Ansicht schreiben"),
        "documentRecipient_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie die Empfänger des aktuellen Berichts oder der aktuellen Bilanz eingeben.\n\nGeben Sie den Namen des Empfängers oder die Namen der verschiedenen Empfänger frei ein und klicken Sie anschließend auf „Bestätigen“, um diese Angaben im Dokument zu speichern.\n\nUm einen bestehenden Eintrag zu löschen, löschen Sie den Inhalt des Feldes und bestätigen Sie anschließend.\n\nDiese Eingabe dient zur Angabe der Empfänger des Dokuments; sie löst keinen Versand aus.\n\n„Abbrechen“ schließt das Fenster, ohne die Änderungen zu übernehmen. Beim Öffnen und Schließen dieser Hilfe bleiben Ihre Eingaben erhalten."),
        "documentRecipient_title":
            MessageLookupByLibrary.simpleMessage("Empfänger"),
        "documentTemplateDraft_help": MessageLookupByLibrary.simpleMessage(
            "Für diese Leitfadenvorlage wurden in der aktuellen Versorgungsphase bereits Antworten erfasst.\n\n„Entwurf wieder aufnehmen“ öffnet den Leitfaden mit diesen Antworten, damit Sie Ihre Eingabe fortsetzen oder ändern können.\n\n„Neue Bilanz“ oder „Neuer Bericht“ löscht die für diese Vorlage gespeicherten Antworten und öffnet den Leitfaden, ohne diese Antworten zu übernehmen. Diese Auswahl löscht den bereits im Bearbeitungsfeld des Dokuments vorhandenen Text nicht.\n\n„Abbrechen“ behält die gespeicherten Antworten bei und kehrt zum vorherigen Bildschirm zurück, ohne den Leitfaden zu öffnen."),
        "documentTemplateDraft_title":
            MessageLookupByLibrary.simpleMessage("Vorhandener Entwurf"),
        "documentTemplateGuide_help": MessageLookupByLibrary.simpleMessage(
            "Dieser Leitfaden hilft Ihnen dabei, den Inhalt einer Bilanz oder eines Berichts anhand der ausgewählten Vorlage zu erstellen.\n\nNutzen Sie die Themenliste auf der linken Seite, um zu den verschiedenen Abschnitten zu gelangen. Geben Sie je nach den angebotenen Feldern Text ein, wählen Sie Antworten aus oder füllen Sie die Tabellen aus.\n\nÜber die Vorschau-Schaltfläche am unteren Rand des Formulars können Sie den anhand Ihrer Antworten erstellten Text einsehen.\n\nVon der Vorschau aus können Sie zur Anleitung zurückkehren, um die Eingabe fortzusetzen, oder die Einfügung des Textes in die Bilanz oder den Bericht anfordern. Befolgen Sie gegebenenfalls die von Companion angezeigten Vorschläge zum Hinzufügen oder Ersetzen.\n\nDas Einfügen des Textes ersetzt nicht die endgültige Speicherung der Bilanz oder des Berichts.\n\nBeim Öffnen und Schließen dieser Hilfe bleiben Ihre Eingaben erhalten."),
        "documentTemplateGuide_helpTitle":
            MessageLookupByLibrary.simpleMessage("Die Eingabehilfe verwenden"),
        "documentTemplatePreview_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie den Text lesen, der anhand der im Leitfaden eingegebenen Antworten generiert wurde.\n\nDer Text kann angezeigt und markiert werden. Um Ihre Antworten zu ändern, klicken Sie auf „Schließen“, um zum Leitfaden zurückzukehren, und rufen Sie die Vorschau anschließend erneut auf.\n\nKlicken Sie auf „In die Bilanz einfügen“ oder „In den Bericht einfügen“, um den Text in das aktuelle Dokument zu übernehmen. Befolgen Sie gegebenenfalls die von Companion angezeigten Vorschläge zum Hinzufügen oder Ersetzen.\n\nWenn kein Text generiert wurde, bleibt die Schaltfläche zum Einfügen deaktiviert.\n\nÜberprüfen Sie nach dem Einfügen den Inhalt des Dokuments und speichern Sie Ihre Bilanz oder Ihren Bericht."),
        "documentTemplatePreview_title": MessageLookupByLibrary.simpleMessage(
            "Vorschau des generierten Textes"),
        "documentTemplate_assessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "Eine Bilanzvorlage auswählen"),
        "documentTemplate_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster werden die für den aktuellen Dokumenttyp verfügbaren Vorlagen angezeigt: Bilanz oder Bericht.\n\nKlicken Sie auf eine Vorlage, um die entsprechende Eingabeanleitung zu öffnen. Durch die Auswahl der Vorlage wird nicht sofort ein Dokument erstellt.\n\nWenn für diese Vorlage bereits ein Entwurf in der Behandlungsepisode vorhanden ist, bietet Companion Ihnen an, diesen zu übernehmen oder eine neue Eingabe zu beginnen."),
        "documentTemplate_reportTitle": MessageLookupByLibrary.simpleMessage(
            "Eine Berichtsvorlage auswählen"),
        "documentTests_help": MessageLookupByLibrary.simpleMessage(
            "In dieser vergrößerten Ansicht können Sie die im Rahmen der Behandlung durchgeführten Tests einsehen und auswählen, welche davon in die aktuelle Bilanz oder den aktuellen Bericht aufgenommen werden sollen.\n\nVerwenden Sie die Auswahlfelder, um einen Test in das Dokument aufzunehmen oder daraus zu entfernen. Durch diese Auswahl werden die in Companion gespeicherten Ergebnisse nicht gelöscht.\n\nÜber die in der Liste angebotenen Aktionen können Sie die Details der Ergebnisse einsehen. Die Auswahl ist verfügbar, sobald ein Befundbericht oder ein Bericht geöffnet ist und der Ladevorgang abgeschlossen ist.\n\nKlicken Sie auf das Kreuz, um zum Bereich „Befundberichte/Berichte“ zurückzukehren."),
        "documentTextInsertion_help": MessageLookupByLibrary.simpleMessage(
            "Ihr Bericht oder Ihre Bilanz enthält bereits Text. Wählen Sie aus, wie der vom Eingabeassistenten generierte Inhalt darin integriert werden soll.\n\n„An das Ende anhängen“ behält den bestehenden Text bei und fügt den generierten Inhalt am Ende hinzu.\n\n„Ersetzen“ ersetzt den gesamten Text im Bearbeitungsfeld durch den generierten Inhalt. Die Passagen, die Sie in dieses Feld eingegeben haben, werden somit ebenfalls ersetzt.\n\n„Abbrechen“ bricht diesen Einfügevorgang ab und behält den aktuellen Text bei.\n\nSie können diese Hilfe lesen und anschließend schließen, bevor Sie Ihre Wahl treffen."),
        "documentTextInsertion_title": MessageLookupByLibrary.simpleMessage(
            "Den generierten Text einfügen"),
        "documentTitle_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie den Titel der Bilanz oder des Berichts eingeben.\n\nBehalten Sie den vorgeschlagenen Titel bei oder ersetzen Sie ihn durch eine Bezeichnung, anhand derer das Dokument leicht zu erkennen ist. Das Feld „Titel“ darf nicht leer bleiben.\n\nKlicken Sie auf die Bestätigungsschaltfläche oder drücken Sie die Eingabetaste, um die Eingabe zu bestätigen. Mit „Abbrechen“ wird das Fenster geschlossen, ohne den Titel zu speichern.\n\nBeim Öffnen und Schließen dieser Hilfe bleibt der eingegebene Text erhalten."),
        "episodeDashboard_documents":
            MessageLookupByLibrary.simpleMessage("Dokumente"),
        "episodeDashboard_documentsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Zu dieser Folge gehörende Dokumente"),
        "episodeDashboard_forms":
            MessageLookupByLibrary.simpleMessage("Formulare"),
        "episodeDashboard_formsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Fragebögen speziell zu dieser Folge"),
        "episodeDashboard_notes":
            MessageLookupByLibrary.simpleMessage("Anmerkungen"),
        "episodeDashboard_notesDescription":
            MessageLookupByLibrary.simpleMessage(
                "Anmerkungen und Kommentare des Physiotherapeuten"),
        "episodeDashboard_report":
            MessageLookupByLibrary.simpleMessage("Bericht"),
        "episodeDashboard_reportDescription":
            MessageLookupByLibrary.simpleMessage("Zusammenfassung der Folge"),
        "episodeDocuments_addDocument":
            MessageLookupByLibrary.simpleMessage("Dokument hinzufügen"),
        "episodeDocuments_addError": MessageLookupByLibrary.simpleMessage(
            "Das Dokument kann nicht hinzugefügt werden"),
        "episodeDocuments_addedOn":
            MessageLookupByLibrary.simpleMessage("Hinzugefügt am"),
        "episodeDocuments_document":
            MessageLookupByLibrary.simpleMessage("Dokument"),
        "episodeDocuments_documentAdded": MessageLookupByLibrary.simpleMessage(
            "Das Dokument wurde in die Unterstützung aufgenommen."),
        "episodeDocuments_emptyDescription": MessageLookupByLibrary.simpleMessage(
            "Sie können ein Textdokument, eine Tabellenkalkulation, eine PDF-Datei, ein Bild oder jede andere nützliche Datei hinzufügen."),
        "episodeDocuments_fileNotFound": MessageLookupByLibrary.simpleMessage(
            "Die zugehörige Datei wurde nicht gefunden."),
        "episodeDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Sie können mit dieser Funktion Dokumente verknüpfen, die Sie mit Ihren üblichen Anwendungen erstellt haben: Textverarbeitungsprogramm, Tabellenkalkulation, PDF-Reader oder Bildbearbeitungssoftware.\n\nDie hinzugefügten Dateien werden in den Speicherbereich von Companion kopiert. Ein Klick auf ein Dokument öffnet es mit der entsprechenden Anwendung, die auf diesem Computer installiert ist."),
        "episodeDocuments_image": MessageLookupByLibrary.simpleMessage("Bild"),
        "episodeDocuments_loadError": MessageLookupByLibrary.simpleMessage(
            "Die zugehörigen Dokumente können nicht geladen werden."),
        "episodeDocuments_noDocument": MessageLookupByLibrary.simpleMessage(
            "Zu dieser Leistung liegen keine Unterlagen vor."),
        "episodeDocuments_openDocument":
            MessageLookupByLibrary.simpleMessage("Dokument öffnen"),
        "episodeDocuments_openError": MessageLookupByLibrary.simpleMessage(
            "Die Datei lässt sich nicht öffnen"),
        "episodeDocuments_pdfDocument":
            MessageLookupByLibrary.simpleMessage("PDF-Dokument"),
        "episodeDocuments_platformNotSupported":
            MessageLookupByLibrary.simpleMessage(
                "Diese Funktion wird auf dieser Plattform nicht unterstützt."),
        "episodeDocuments_refresh":
            MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "episodeDocuments_spreadsheet":
            MessageLookupByLibrary.simpleMessage("Tabelle"),
        "episodeDocuments_textDocument":
            MessageLookupByLibrary.simpleMessage("Textdokument"),
        "episodeDocuments_title":
            MessageLookupByLibrary.simpleMessage("Unterlagen zur Betreuung"),
        "episodeEvolution_evaluation":
            MessageLookupByLibrary.simpleMessage("Bewertung"),
        "episodeEvolution_evaluations":
            MessageLookupByLibrary.simpleMessage("Bewertungen"),
        "episodeEvolution_first":
            MessageLookupByLibrary.simpleMessage("Premiere"),
        "episodeEvolution_followedExercises":
            MessageLookupByLibrary.simpleMessage("Absolvierte Übungen"),
        "episodeEvolution_last": MessageLookupByLibrary.simpleMessage("Letzte"),
        "episodeEvolution_noResults": MessageLookupByLibrary.simpleMessage(
            "Für diese Folge sind keine Ergebnisse verfügbar."),
        "episodeEvolution_singleNumericValue":
            MessageLookupByLibrary.simpleMessage(
                "Nur ein Zahlenwert verfügbar"),
        "episodeEvolution_title":
            MessageLookupByLibrary.simpleMessage("Verlauf der Episode"),
        "episodeEvolution_viewEvolution":
            MessageLookupByLibrary.simpleMessage("Entwicklung anzeigen"),
        "episodeFormEditor_error":
            MessageLookupByLibrary.simpleMessage("Fehler"),
        "episodeFormEditor_noField": MessageLookupByLibrary.simpleMessage(
            "Es sind keine Felder anzuzeigen."),
        "episodeFormEditor_requiredField": m24,
        "episodeFormEditor_save":
            MessageLookupByLibrary.simpleMessage("Speichern"),
        "episodeFormEditor_title":
            MessageLookupByLibrary.simpleMessage("Formular bearbeiten"),
        "episodeForms_availableTemplates":
            MessageLookupByLibrary.simpleMessage("Verfügbare Modelle"),
        "episodeForms_category":
            MessageLookupByLibrary.simpleMessage("Kategorie"),
        "episodeForms_completed":
            MessageLookupByLibrary.simpleMessage("ergänzt"),
        "episodeForms_create":
            MessageLookupByLibrary.simpleMessage("Erstellen"),
        "episodeForms_createdForms":
            MessageLookupByLibrary.simpleMessage("Erstellte Formulare"),
        "episodeForms_createdOn":
            MessageLookupByLibrary.simpleMessage("Erstellt am"),
        "episodeForms_customTemplate":
            MessageLookupByLibrary.simpleMessage("Individuelles Modell"),
        "episodeForms_error": MessageLookupByLibrary.simpleMessage("Fehler"),
        "episodeForms_form": MessageLookupByLibrary.simpleMessage("Formular"),
        "episodeForms_inProgress":
            MessageLookupByLibrary.simpleMessage("laufend"),
        "episodeForms_noAvailableTemplate":
            MessageLookupByLibrary.simpleMessage(
                "Es ist keine Formularvorlage verfügbar."),
        "episodeForms_noCreatedForm": MessageLookupByLibrary.simpleMessage(
            "Für diese Folge wurde kein Formular erstellt."),
        "episodeForms_noData": MessageLookupByLibrary.simpleMessage(
            "Es sind keine Daten vorhanden."),
        "episodeForms_refresh":
            MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "episodeForms_state": MessageLookupByLibrary.simpleMessage("Status"),
        "episodeForms_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Systemmodell"),
        "episodeForms_title": MessageLookupByLibrary.simpleMessage("Formulare"),
        "episodeNotes_archive":
            MessageLookupByLibrary.simpleMessage("Archivieren"),
        "episodeNotes_archiveConfirmation": m25,
        "episodeNotes_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Die Notiz archivieren?"),
        "episodeNotes_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "episodeNotes_content": MessageLookupByLibrary.simpleMessage("Inhalt"),
        "episodeNotes_editNote":
            MessageLookupByLibrary.simpleMessage("Bewertung bearbeiten"),
        "episodeNotes_error": MessageLookupByLibrary.simpleMessage("Fehler"),
        "episodeNotes_modifiedOn":
            MessageLookupByLibrary.simpleMessage("Geändert am"),
        "episodeNotes_newNote":
            MessageLookupByLibrary.simpleMessage("Neuer Vermerk"),
        "episodeNotes_noNote": MessageLookupByLibrary.simpleMessage(
            "Zu dieser Folge gibt es keine Notizen."),
        "episodeNotes_noteTitle": MessageLookupByLibrary.simpleMessage("Titel"),
        "episodeNotes_refresh":
            MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "episodeNotes_save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "episodeNotes_title":
            MessageLookupByLibrary.simpleMessage("Anmerkungen"),
        "episodeNotes_titleRequired": MessageLookupByLibrary.simpleMessage(
            "Der Titel ist obligatorisch."),
        "episodeReferents_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie den zuständigen Physiotherapeuten und den überweisenden Arzt für die Behandlung auswählen.\n\nWählen Sie die Fachkräfte aus den Listen aus. Sie können eine Zuordnung auch aufheben, indem Sie die Option „Ohne Fachkraft“ auswählen.\n\nÜber die Verwaltungsschaltflächen rechts neben den Listen können Sie auf die Profile der Fachkräfte und externen Ansprechpartner zugreifen, insbesondere um eine fehlende Fachkraft hinzuzufügen.\n\nKlicken Sie auf „Speichern“, um die ausgewählten Zuordnungen zu übernehmen. Änderungen des zuständigen Physiotherapeuten werden im Verlauf der Behandlung gespeichert.\n\nMit „Abbrechen“ werden die Änderungen der Zuordnungen in diesem Fenster verworfen. Eventuell über die Verwaltungsbildschirme angelegte Profile bleiben gespeichert."),
        "episodeReferents_title":
            MessageLookupByLibrary.simpleMessage("Referenzen bearbeiten"),
        "episodeReport_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Herkunft von ABAK"),
        "episodeReport_addConclusion": MessageLookupByLibrary.simpleMessage(
            "Eine Schlussfolgerung hinzufügen"),
        "episodeReport_clinicalConclusion":
            MessageLookupByLibrary.simpleMessage("Klinisches Fazit"),
        "episodeReport_conclusionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Die Schlussfolgerung darf nicht leer sein."),
        "episodeReport_documents":
            MessageLookupByLibrary.simpleMessage("Dokumente"),
        "episodeReport_dominantSide":
            MessageLookupByLibrary.simpleMessage("Dominante Seite"),
        "episodeReport_editConclusion":
            MessageLookupByLibrary.simpleMessage("Den Schluss ändern"),
        "episodeReport_email": MessageLookupByLibrary.simpleMessage("E-Mail"),
        "episodeReport_error": MessageLookupByLibrary.simpleMessage("Fehler"),
        "episodeReport_forms":
            MessageLookupByLibrary.simpleMessage("Formulare"),
        "episodeReport_generatedPreview": MessageLookupByLibrary.simpleMessage(
            "Übersicht über den erstellten Bericht"),
        "episodeReport_generatingPreview": MessageLookupByLibrary.simpleMessage(
            "Textvorschau wird erstellt..."),
        "episodeReport_name": MessageLookupByLibrary.simpleMessage("Name"),
        "episodeReport_noConclusion": MessageLookupByLibrary.simpleMessage(
            "Es wurde keine Schlussfolgerung angegeben."),
        "episodeReport_noData": MessageLookupByLibrary.simpleMessage(
            "Es sind keine Daten vorhanden."),
        "episodeReport_noDocument":
            MessageLookupByLibrary.simpleMessage("Keine zugehörigen Dokumente"),
        "episodeReport_noForm":
            MessageLookupByLibrary.simpleMessage("Keine zugehörigen Formulare"),
        "episodeReport_noNote":
            MessageLookupByLibrary.simpleMessage("Keine zugehörigen Notizen"),
        "episodeReport_noResult": MessageLookupByLibrary.simpleMessage(
            "Keine entsprechenden Ergebnisse"),
        "episodeReport_notProvided":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "episodeReport_notes":
            MessageLookupByLibrary.simpleMessage("Anmerkungen"),
        "episodeReport_patient":
            MessageLookupByLibrary.simpleMessage("Patient"),
        "episodeReport_phone": MessageLookupByLibrary.simpleMessage("Telefon"),
        "episodeReport_profession":
            MessageLookupByLibrary.simpleMessage("Beruf"),
        "episodeReport_refresh":
            MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "episodeReport_results":
            MessageLookupByLibrary.simpleMessage("ABAK-Ergebnisse"),
        "episodeReport_save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "episodeReport_score": MessageLookupByLibrary.simpleMessage("Ergebnis"),
        "episodeReport_sportActivity":
            MessageLookupByLibrary.simpleMessage("Sportliche Aktivität"),
        "episodeReport_title": MessageLookupByLibrary.simpleMessage("Bericht"),
        "episodeReport_unknownType":
            MessageLookupByLibrary.simpleMessage("Typ unbekannt"),
        "exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Austauschordner zurückgesetzt"),
        "exchangeDirectoryService_choose": MessageLookupByLibrary.simpleMessage(
            "Den ABAK-Austauschordner auswählen"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Aktualisierte ABAK-Austauschdatei"),
        "externalCorrespondentForm_addTitle":
            MessageLookupByLibrary.simpleMessage("Kontakt hinzufügen"),
        "externalCorrespondentForm_editTitle":
            MessageLookupByLibrary.simpleMessage("Kontakt bearbeiten"),
        "externalCorrespondentForm_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie die Daten eines externen Ansprechpartners eingeben.\n\nDie Angabe des Nachnamens ist obligatorisch. Sie können den Vornamen, den Beruf, das Fachgebiet, die Adresse, die Postleitzahl, den Ort, die E-Mail-Adresse und die Telefonnummer ergänzen.\n\nKlicken Sie auf „Speichern“, um den Datensatz zu bestätigen. Mit „Abbrechen“ schließen Sie das Fenster, ohne die Änderungen zu übernehmen.\n\nBeim Öffnen und Schließen dieser Hilfe bleiben Ihre Eingaben im Formular erhalten."),
        "externalCorrespondents_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm werden die in Companion gespeicherten externen Ansprechpartner angezeigt. In jeder Zeile sind der Name des Ansprechpartners sowie – sofern angegeben – dessen Beruf, Fachgebiet und Wohnort aufgeführt.\n\nKlicken Sie auf „Hinzufügen“, um einen Ansprechpartner anzulegen. Geben Sie die persönlichen Daten und die relevanten Kontaktdaten ein und klicken Sie dann auf „Speichern“, um den Ansprechpartner zur Liste hinzuzufügen. Mit „Abbrechen“ schließen Sie das Formular, ohne einen Ansprechpartner anzulegen.\n\nDiese Ansprechpartner können insbesondere in Behandlungsverläufen als überweisende Ärzte ausgewählt werden."),
        "externalCorrespondents_title":
            MessageLookupByLibrary.simpleMessage("Externe Korrespondenten"),
        "externalSpeechToTextProvider_empty":
            MessageLookupByLibrary.simpleMessage(
                "Das Add-on hat keine Antwort zurückgegeben."),
        "externalSpeechToTextProvider_failure":
            MessageLookupByLibrary.simpleMessage(
                "Fehler beim Add-on für die Spracherkennung."),
        "externalSpeechToTextProvider_invalid":
            MessageLookupByLibrary.simpleMessage(
                "Ungültige Antwort des Spracherkennungs-Add-ons."),
        "externalSpeechToTextProvider_noText":
            MessageLookupByLibrary.simpleMessage(
                "Das Add-on hat keinen Text zurückgegeben."),
        "externalSpeechToTextProvider_transcription":
            MessageLookupByLibrary.simpleMessage(
                "Die Transkription ist fehlgeschlagen."),
        "followUpNoteForm_createTitle":
            MessageLookupByLibrary.simpleMessage("Neuer Follow-up-Bericht"),
        "followUpNoteForm_editTitle": MessageLookupByLibrary.simpleMessage(
            "Die Follow-up-Notiz bearbeiten"),
        "followUpNoteForm_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie eine zur Behandlungssitzung gehörende Nachverfolgungsnotiz erstellen oder bearbeiten.\n\nGeben Sie einen Titel und den Inhalt der Notiz ein. Beide Felder müssen Text enthalten, damit die Notiz gespeichert wird.\n\nKlicken Sie beim Anlegen auf „Hinzufügen“. Klicken Sie bei einer Bearbeitung auf „Speichern“, um Ihre Änderungen zu übernehmen.\n\n„Abbrechen“ schließt das Fenster, ohne Ihre Eingaben zu speichern. Sie können diese Hilfe öffnen und wieder schließen, ohne den gerade verfassten Text zu verlieren."),
        "followUpNotes_help": MessageLookupByLibrary.simpleMessage(
            "Diese Ansicht zeigt die Notizen zur Nachsorge mit Datum, Titel und einer Vorschau auf den Inhalt an.\n\nÜber die Schaltfläche „Hinzufügen“ können Sie einen Vermerk erstellen. Über das Bearbeitungssymbol können Sie einen bestehenden Vermerk öffnen, um ihn anzusehen oder zu bearbeiten.\n\nVerwenden Sie die Auswahlfelder, um die Vermerke auszuwählen, die in den aktuellen Bericht oder die aktuelle Bilanz aufgenommen werden sollen. Wenn Sie das Häkchen bei einem Vermerk entfernen, wird dieser aus der Auswahl entfernt, ohne dass der Vermerk gelöscht wird.\n\nDie Auswahl ist verfügbar, sobald ein Bericht geöffnet ist und der Ladevorgang abgeschlossen ist.\n\nKlicken Sie auf das Kreuz, um die vergrößerte Ansicht zu schließen und zum Bereich „Berichte“ zurückzukehren."),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Vorwahl ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Schließen"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Kommentar"),
        "g_context": MessageLookupByLibrary.simpleMessage("Hintergrund"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Kopieren"),
        "g_file": MessageLookupByLibrary.simpleMessage("Datei"),
        "g_helpTooltip": MessageLookupByLibrary.simpleMessage("Hilfe anzeigen"),
        "g_learn_more": MessageLookupByLibrary.simpleMessage("Mehr erfahren"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Technische Informationen"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Technische Informationen kopiert"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Archivierte Patienten können bis zu dem angegebenen Datum wiederhergestellt werden.\nNach diesem Datum werden sie automatisch gelöscht, damit nicht ungenutzte Datensätze auf unbestimmte Zeit gespeichert bleiben.\nDie Aufbewahrungsdauer kann in den Einstellungen von Companion geändert werden."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "Es handelt sich um die Geräte (Smartphone, Tablet), die zur Durchführung der Tests verwendet werden.\n- Ein Gerät kann von verschiedenen Personen genutzt werden.\n- Eine Person kann mehrere Geräte besitzen.\n\nAnhand dieser Informationen lässt sich feststellen, von welchem Gerät die an Companion übermittelten Informationen stammen.\nSie können ein Gerät anlegen, bearbeiten oder archivieren.\n\nAus Gründen der Rückverfolgbarkeit ist es nicht möglich, ein Gerät zu löschen.\nBei Bedarf können Sie ein archiviertes Gerät wiederherstellen.\n\nZum Koppeln eines Smartphones oder Tablets wird ein QR-Code verwendet. Zeigen Sie den QR-Code auf dem Festgerät an (Gerät > entsprechendes Gerätesymbol) und rufen Sie auf dem Smartphone (oder Tablet) die Einstellungen > Unternehmensorganisation > Registrierte Geräte > Gerät hinzufügen auf.\n\nHalten Sie das Gerät nahe an den Bildschirm, um den QR-Code zu scannen.Eine Meldung informiert Sie über den erfolgreichen Abschluss des Vorgangs."),
        "help_device_list_title":
            MessageLookupByLibrary.simpleMessage("Geräteliste"),
        "help_donnees_cliniques_patient": MessageLookupByLibrary.simpleMessage(
            "Hier finden Sie weitere Informationen zu Ihrem Patienten"),
        "help_home": MessageLookupByLibrary.simpleMessage(
            "Dieser Bildschirm ist der Hauptbildschirm von ABAK Companion.\n\nEr besteht aus:\n\n1) einem Kopfbereich, der Sie über Folgendes informiert: \n - die Anzahl der aktiven und archivierten Patienten.\n  - die Anzahl der aktuellen Warnmeldungen.\n\nIn den Einstellungen können Sie den Namen Ihrer Einrichtung angeben und Ihr Logo hinzufügen.\n\n2) „Letzte Importe“ zeigt Ihnen die zuletzt aus ABAK Mobile importierten Ergebnisdateien an.\n\n3) „Systemstatus“ zeigt Ihnen eventuelle Probleme sowie das Datum der letzten Sicherung an.\n\n4) „Neue ABAK-Befunde zum Zuordnen“ zeigt Ihnen die Befunde an, die von ABAK Mobile gesendet wurden, aber in ABAK Companion noch keinem Patienten zugeordnet sind.\n\n5) „Systemwarnung“ informiert Sie über die Art eines Problems.\n\n6) „Schnellaktion“ ermöglicht es Ihnen, auf den Verlauf all Ihrer Importe zuzugreifen und eine neue Sicherung zu erstellen."),
        "help_home_active_archived_patients_content":
            MessageLookupByLibrary.simpleMessage("Aktive Patienten"),
        "help_home_active_archived_patients_title":
            MessageLookupByLibrary.simpleMessage(
                "Aktive und archivierte Patienten"),
        "help_home_import_assignment_content":
            MessageLookupByLibrary.simpleMessage(
                "Sobald Sie Ihre Übung in ABAK Mobile abgeschlossen haben..."),
        "help_home_import_assignment_title":
            MessageLookupByLibrary.simpleMessage(
                "Abruf eines Befunds und Zuordnung zu einem Patienten"),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Hier finden Sie die Identifikationsdaten Ihres Patienten"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm können Sie:\n - die Sprache auswählen,\n - die Aufbewahrungsdauer für archivierte Patientenakten festlegen,\n - den Expertenmodus aktivieren,\n - den Bildschirm „Einrichtung“ aufrufen, um den Namen Ihrer Einrichtung und deren Logo einzugeben"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm können Sie einen neuen Behandler hinzufügen oder dessen Daten bearbeiten.\n\nDas Verschieben in den Papierkorb löscht den Behandler nicht. Aus Gründen der Nachverfolgbarkeit ist es nicht möglich, einen Behandler zu löschen.\n\nDurch das Anzeigen des QR-Codes können Sie das Profil des Behandlers für Ihre Einrichtung automatisch auf dessen Smartphone oder Tablet erstellen."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Eine Behandlung entspricht einem Behandlungsverlauf.\nHier finden Sie die verschiedenen aktiven Behandlungen Ihres Patienten.\nUm ein Ergebnis zuzuordnen, können Sie einen bestehenden Behandlungsverlauf verwenden oder einen neuen anlegen.\nSobald der Behandlungsverlauf abgeschlossen ist, können Sie ihn archivieren."),
        "homeImportSummary_conflicts":
            MessageLookupByLibrary.simpleMessage("Konflikte"),
        "homeImportSummary_failedFiles":
            MessageLookupByLibrary.simpleMessage("Fehlerhafte Dateien"),
        "homeImportSummary_importDate":
            MessageLookupByLibrary.simpleMessage("Daten importieren"),
        "homeImportSummary_importedMetrics":
            MessageLookupByLibrary.simpleMessage("Importierte Kennzahlen"),
        "homeImportSummary_importedResults":
            MessageLookupByLibrary.simpleMessage("Importierte Ergebnisse"),
        "homeImportSummary_open":
            MessageLookupByLibrary.simpleMessage("Öffnen"),
        "homeImportSummary_patients":
            MessageLookupByLibrary.simpleMessage("Betroffene Patienten"),
        "homeImportSummary_processedFiles":
            MessageLookupByLibrary.simpleMessage("Verarbeitete Dateien"),
        "homeImportSummary_skippedResults":
            MessageLookupByLibrary.simpleMessage("Ergebnisse wurden ignoriert"),
        "homeImportSummary_title":
            MessageLookupByLibrary.simpleMessage("Letzter ABAK-Import"),
        "home_abak_exercice":
            MessageLookupByLibrary.simpleMessage("ABAK-Übung"),
        "home_abak_file": MessageLookupByLibrary.simpleMessage("ABAK-Datei"),
        "home_accueil": MessageLookupByLibrary.simpleMessage("Startseite"),
        "home_action_required": MessageLookupByLibrary.simpleMessage(
            "Erforderliche Maßnahme: Diese Akte einem Patienten zuordnen."),
        "home_already_imported":
            MessageLookupByLibrary.simpleMessage("Bereits importiert"),
        "home_an_intervention_is_necessary":
            MessageLookupByLibrary.simpleMessage(
                "Es sind Maßnahmen erforderlich"),
        "home_archives": MessageLookupByLibrary.simpleMessage("Archiv"),
        "home_attention": MessageLookupByLibrary.simpleMessage("Achtung"),
        "home_backup_successfully_created":
            MessageLookupByLibrary.simpleMessage(
                "Sicherung erfolgreich erstellt."),
        "home_balance_sheet_date":
            MessageLookupByLibrary.simpleMessage("Bilanzstichtag"),
        "home_conflict_detected":
            MessageLookupByLibrary.simpleMessage("Konflikt erkannt"),
        "home_correspondents":
            MessageLookupByLibrary.simpleMessage("Korrespondenten"),
        "home_create_a_backup":
            MessageLookupByLibrary.simpleMessage("Sicherung erstellen"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Datum nicht angegeben"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Geräte"),
        "home_error_while_saving": m26,
        "home_everything_is_working_normally":
            MessageLookupByLibrary.simpleMessage("Alles läuft normal."),
        "home_expert_comment": MessageLookupByLibrary.simpleMessage(
            "Dieser Bildschirm ist der Hauptbildschirm von Companion."),
        "home_failure": MessageLookupByLibrary.simpleMessage("Fehlschlag"),
        "home_fermer": MessageLookupByLibrary.simpleMessage("Schließen"),
        "home_file": MessageLookupByLibrary.simpleMessage("Datei"),
        "home_historique": MessageLookupByLibrary.simpleMessage("Geschichte"),
        "home_home": MessageLookupByLibrary.simpleMessage("Startseite"),
        "home_import_history":
            MessageLookupByLibrary.simpleMessage("Importverlauf"),
        "home_imports_interrupted_or_in_progress":
            MessageLookupByLibrary.simpleMessage(
                "Unterbrochene oder laufende Importe"),
        "home_imports_with_errors":
            MessageLookupByLibrary.simpleMessage("Fehler beim Import"),
        "home_information": MessageLookupByLibrary.simpleMessage("Über uns"),
        "home_invalid_file_path":
            MessageLookupByLibrary.simpleMessage("Ungültiger Dateipfad:"),
        "home_ipAddressNotFound":
            MessageLookupByLibrary.simpleMessage("IP-Adresse nicht gefunden"),
        "home_ipAddressNotFoundMessage": MessageLookupByLibrary.simpleMessage(
            "Die lokale IP-Adresse des Desktops kann nicht ermittelt werden.\n\nStellen Sie sicher, dass der Computer mit dem lokalen Netzwerk verbunden ist."),
        "home_large_number_of_archived_patients":
            MessageLookupByLibrary.simpleMessage(
                "Große Anzahl archivierter Patienten"),
        "home_large_sqlite_database": MessageLookupByLibrary.simpleMessage(
            "Umfangreiche SQLite-Datenbank"),
        "home_last_backup":
            MessageLookupByLibrary.simpleMessage("Letzte Sicherung"),
        "home_last_old_backup":
            MessageLookupByLibrary.simpleMessage("Letzte ältere Sicherung"),
        "home_link_to_a_care_plan": MessageLookupByLibrary.simpleMessage(
            "In die Behandlung einbeziehen"),
        "home_more_7_days":
            MessageLookupByLibrary.simpleMessage("Mehr als 7 Tage"),
        "home_new_abak_results_to_be_linked": MessageLookupByLibrary.simpleMessage(
            "Neue ABAK-Ergebnisse, die einem Patienten zugeordnet werden sollen"),
        "home_no_abak_result_to_associate":
            MessageLookupByLibrary.simpleMessage(
                "Es wurden keine passenden ABAK-Ergebnisse gefunden."),
        "home_no_alert_detected": MessageLookupByLibrary.simpleMessage(
            "Es wurden keine Warnmeldungen erkannt"),
        "home_no_imports_recorded": MessageLookupByLibrary.simpleMessage(
            "Es wurden keine Importe erfasst."),
        "home_no_pending_imports":
            MessageLookupByLibrary.simpleMessage("Keine ausstehenden Importe"),
        "home_no_saved_backup": MessageLookupByLibrary.simpleMessage(
            "Es wurde kein Backup gespeichert"),
        "home_not_specified":
            MessageLookupByLibrary.simpleMessage("ausgefragt"),
        "home_octets": MessageLookupByLibrary.simpleMessage("Oktette"),
        "home_other_exercises": m27,
        "home_parameters":
            MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Pfad"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patient ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patienten"),
        "home_pending_association": m28,
        "home_practitioners": MessageLookupByLibrary.simpleMessage("Praktiker"),
        "home_quick_actions":
            MessageLookupByLibrary.simpleMessage("Schnellmaßnahmen"),
        "home_receents_imports":
            MessageLookupByLibrary.simpleMessage("Neueste Importe"),
        "home_recent_restoration_detected":
            MessageLookupByLibrary.simpleMessage(
                "Kürzlich durchgeführte Restaurierung erkannt"),
        "home_results": MessageLookupByLibrary.simpleMessage("Ergebnisse"),
        "home_select_qr_code": MessageLookupByLibrary.simpleMessage(
            "Scannen Sie diesen QR-Code mit ABAK Mobile, um die Verbindung zum Desktop automatisch einzurichten."),
        "home_settings": MessageLookupByLibrary.simpleMessage("Hilfe"),
        "home_size": MessageLookupByLibrary.simpleMessage("Größe"),
        "home_solve": MessageLookupByLibrary.simpleMessage("Lösen"),
        "home_success": MessageLookupByLibrary.simpleMessage("Erfolg"),
        "home_system_alert":
            MessageLookupByLibrary.simpleMessage("Systemwarnung"),
        "home_system_status":
            MessageLookupByLibrary.simpleMessage("Systemstatus"),
        "home_technical_information":
            MessageLookupByLibrary.simpleMessage("Technische Informationen"),
        "home_this_file_had_already_been_imported":
            MessageLookupByLibrary.simpleMessage(
                "Diese Datei wurde bereits importiert. Es wurden keine Daten hinzugefügt."),
        "home_to_be_verified":
            MessageLookupByLibrary.simpleMessage("zu überprüfen"),
        "home_to_do_list": MessageLookupByLibrary.simpleMessage("Zu erledigen"),
        "home_unable_to_load_recent_imports":
            MessageLookupByLibrary.simpleMessage(
                "Die zuletzt importierten Dateien können nicht geladen werden."),
        "home_unreadable_abak_import":
            MessageLookupByLibrary.simpleMessage("Unlesbarer ABAK-Import."),
        "home_unsuccessful": MessageLookupByLibrary.simpleMessage("Schachmatt"),
        "home_verify": MessageLookupByLibrary.simpleMessage("Überprüfen"),
        "home_very_large_backups": MessageLookupByLibrary.simpleMessage(
            "Sehr umfangreiche Sicherungen"),
        "importHistory_help": MessageLookupByLibrary.simpleMessage(
            "Dieser Bildschirm zeigt den Verlauf der in Companion gespeicherten Importvorgänge an.\n\nJede Zeile enthält das Datum des Vorgangs, dessen Status, die Anzahl der verarbeiteten Dateien sowie die Anzahl der importierten, ignorierten oder in Konflikt stehenden Ergebnisse.\n\nDas Symbol weist insbesondere auf einen laufenden Import, einen Fehlschlag, Fehler oder Konflikte hin, die Ihre Aufmerksamkeit erfordern.\n\nKlicken Sie auf eine Sitzung, um deren Details anzuzeigen und die Verarbeitung der Ergebnisse besser nachzuvollziehen."),
        "importPatientForm_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie einen Patienten anlegen, um ihm die aus ABAK Mobile importierten Ergebnisse zuzuordnen.\n\nGeben Sie seinen Vor- und Nachnamen ein. Sie können sein Geburtsdatum im Format JJJJ-MM-TT ergänzen und sein Geschlecht angeben oder „Nicht angegeben“ belassen.\n\nWenn Sie die Vitale-Karte eingelesen haben, überprüfen Sie die vorausgefüllten Angaben und korrigieren Sie diese gegebenenfalls.\n\nKlicken Sie auf „Erstellen“, um den Patienten zu speichern und auszuwählen. Wählen Sie anschließend die Behandlung aus, der die Ergebnisse zugeordnet werden sollen: Die Erstellung des Patienten allein reicht nicht aus, um die Zuordnung des Imports abzuschließen.\n\nMit „Abbrechen“ schließen Sie dieses Fenster, ohne einen Patienten anzulegen. Wenn Sie diese Hilfe öffnen und anschließend wieder schließen, bleiben Ihre Eingaben erhalten."),
        "importPatientForm_title":
            MessageLookupByLibrary.simpleMessage("Neuer Patient"),
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("Datei"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("Dateien"),
        "importResolutionAssistant_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm werden die Importe zusammengefasst, die Ihre Aufmerksamkeit erfordern: noch zu vervollständigende Patientenzuordnung, fehlgeschlagener Import, Fehler, ignorierte Ergebnisse oder zu prüfende Konflikte.\n\nJede Zeile enthält das Datum des Imports sowie die verfügbaren Informationen zur Identifizierung der betreffenden Akte.\n\nKlicken Sie auf einen Import, um dessen Nachverfolgung zu öffnen, die Erläuterungen einzusehen und auf die je nach Situation vorgeschlagenen Maßnahmen zuzugreifen.\n\nDie Liste wird aktualisiert, sobald Sie aus der Nachverfolgung des Imports zurückkehren. Wenn kein Import diese Kriterien erfüllt, wird eine Meldung angezeigt, dass kein Problem festgestellt wurde."),
        "importResolutionAssistant_import":
            MessageLookupByLibrary.simpleMessage("Importieren"),
        "importResolutionAssistant_importFailed":
            MessageLookupByLibrary.simpleMessage("Import fehlgeschlagen"),
        "importResolutionAssistant_importToComplete":
            MessageLookupByLibrary.simpleMessage(
                "Import noch nicht abgeschlossen"),
        "importResolutionAssistant_importToReview":
            MessageLookupByLibrary.simpleMessage(
                "Import muss überprüft werden"),
        "importResolutionAssistant_inError":
            MessageLookupByLibrary.simpleMessage("versehentlich"),
        "importResolutionAssistant_interventionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Um diesen Import abzuschließen, ist ein Eingriff erforderlich."),
        "importResolutionAssistant_loadingError":
            MessageLookupByLibrary.simpleMessage(
                "Die Importe können nicht geladen werden"),
        "importResolutionAssistant_noProblem":
            MessageLookupByLibrary.simpleMessage(
                "Es wurden keine Importprobleme festgestellt."),
        "importResolutionAssistant_result":
            MessageLookupByLibrary.simpleMessage("Ergebnis"),
        "importResolutionAssistant_results":
            MessageLookupByLibrary.simpleMessage("Ergebnisse"),
        "importResolutionAssistant_selectImportInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Wählen Sie einen Import aus, um dessen Details anzuzeigen, und befolgen Sie die angegebenen Schritte."),
        "importResolutionAssistant_title": MessageLookupByLibrary.simpleMessage(
            "Behebung von Importproblemen"),
        "importResolutionAssistant_toReview":
            MessageLookupByLibrary.simpleMessage("zu überprüfen"),
        "importResolution_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm können Sie die von ABAK Mobile empfangenen Ergebnisse dem richtigen Patienten und der richtigen Behandlung in Companion zuordnen.\n\nSehen Sie sich die Informationen des importierten Datensatzes an und wählen Sie dann den betreffenden Patienten aus der Liste aus. Erstellen Sie bei Bedarf einen Patientenstamm mit „Neuer Patient“ oder „Über Carte Vitale“, sofern das Lesegerät verfügbar ist.\n\nNachdem Sie den Patienten ausgewählt haben, wählen Sie eine aktive Behandlung aus oder legen Sie eine neue an. Eine archivierte Behandlung muss zunächst wiederhergestellt werden, bevor sie ausgewählt werden kann.\n\nÜberprüfen Sie den Patienten und die Behandlung, bevor Sie letztere auswählen: Durch die Auswahl wird die Zuordnung bestätigt und der Import fortgesetzt."),
        "importResolution_title":
            MessageLookupByLibrary.simpleMessage("Import zuordnen"),
        "importSessionDetail_help": MessageLookupByLibrary.simpleMessage(
            "Dieser Bildschirm zeigt den Verlauf eines in Companion eingegangenen Imports an. Die Hauptmeldung gibt an, ob der Import erfolgreich war, eine Zuordnung zu einem Patienten erforderlich ist oder ein Problem vorliegt.\n\nWenn eine Zuordnung erforderlich ist, klicken Sie auf „Einem Patienten zuordnen“, um die Akte auszuwählen, der die Ergebnisse zugeordnet werden sollen.\n\nÜber den Bericht und die Dateiliste können Sie die Details der Verarbeitung sowie eventuelle Warnmeldungen einsehen.\n\nSollte die empfangene Datei unvollständig oder beschädigt sein, fordern Sie über ABAK Mobile eine erneute Übermittlung an.\n\nJe nach Situation wird die Schaltfläche „Diesen Import löschen“ angezeigt. Lesen Sie die Bestätigungsmeldung, bevor Sie den Löschvorgang bestätigen."),
        "importSessionDetail_title":
            MessageLookupByLibrary.simpleMessage("Verfolgung des Imports"),
        "information_backupCount": m29,
        "information_backups":
            MessageLookupByLibrary.simpleMessage("Sicherungen"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Konfiguriert"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm werden allgemeine, technische und rechtliche Informationen zu Companion angezeigt."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Informationen"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Datenbank"),
        "information_help": MessageLookupByLibrary.simpleMessage(
            "Auf dieser Seite finden Sie allgemeine Informationen zu Ihrer Companion-Installation: Anwendungsversion, konfigurierte Praxis, Vorhandensein des Logos, verwendetes Betriebssystem und Sprache.\n\nIm Abschnitt „Lokaler Speicher“ werden die Größe der Datenbank sowie die Anzahl und die Gesamtgröße der gespeicherten Sicherungen angezeigt.\n\nÜber die Schaltflächen können Sie die Neuigkeiten, die Lizenz und die Hinweise zur Nutzung der App einsehen.\n\nBei der Kontaktaufnahme mit dem Support können die hier angezeigte Companion-Version und das Betriebssystem dabei helfen, Ihre Konfiguration zu identifizieren."),
        "information_language": MessageLookupByLibrary.simpleMessage("Sprache"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Rechtlicher Hinweis"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Wird geladen..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Lokale Speicherung"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_new": MessageLookupByLibrary.simpleMessage(
            "Version 1.1.0 Build 3\nSprachsteuerung für Befunde und Berichte möglich, erfordert das kostenlose Modul.\nAutomatische Speicherung von Befunden und Berichten.\nSchaltfläche zum Duplizieren von Befunden und Berichten.\nBearbeitbare Notizen.\nSchaltfläche zum Anzeigen aller Tests eines Patienten für eine Episode.\nVorlagen für Befunde.\nAutomatische Grafik, wenn mehrere Ergebnisse für einen Test vorliegen.\nErstellung eines Dokuments im DOCX-Format.\nAnzeige der für E72 und E76 verwendeten Hilfe"),
        "information_newHelp": MessageLookupByLibrary.simpleMessage(
            "Auf dieser Seite werden die für Companion beschriebenen Neuerungen und Weiterentwicklungen vorgestellt.\n\nScrollen Sie durch den Text, um alle Informationen zu lesen. Bei Bedarf können Sie einen Abschnitt auswählen und kopieren.\n\nVerwenden Sie den Zurück-Pfeil, um zur Seite „Über“ zurückzukehren."),
        "information_newTitle": MessageLookupByLibrary.simpleMessage(
            "Neuerungen in dieser Version"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Nicht konfiguriert"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "information_office": MessageLookupByLibrary.simpleMessage("Kanzlei"),
        "information_size": m30,
        "information_system": MessageLookupByLibrary.simpleMessage("System"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Informationen"),
        "information_totalSize": m31,
        "information_version": m32,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Version..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("Lizenz einsehen"),
        "initialReportDocumentService_associate":
            MessageLookupByLibrary.simpleMessage(
                "Eine Word-Eröffnungsbilanz anhängen"),
        "initialReportDocumentService_unsupported":
            MessageLookupByLibrary.simpleMessage(
                "Plattform wird nicht unterstützt"),
        "kobus_archived":
            MessageLookupByLibrary.simpleMessage("Companion – archiviert"),
        "kobus_archives":
            MessageLookupByLibrary.simpleMessage("Importierte Archive"),
        "kobus_attach": MessageLookupByLibrary.simpleMessage(
            "Dem ausgewählten Patienten zuordnen"),
        "kobus_backupNotice": MessageLookupByLibrary.simpleMessage(
            "Bei der aktuellen Datensicherung der Datenbank werden die KOBUS-Dateien nicht gesichert."),
        "kobus_cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "kobus_candidate":
            MessageLookupByLibrary.simpleMessage("Vorgeschlagener Patient"),
        "kobus_chooseCandidate": MessageLookupByLibrary.simpleMessage(
            "Wählen Sie eine der folgenden Zeilen aus"),
        "kobus_confirm": MessageLookupByLibrary.simpleMessage(
            "Import prüfen und bestätigen"),
        "kobus_confirmBody": MessageLookupByLibrary.simpleMessage(
            "Die gemäß Ihren Entscheidungen vorbereiteten Datensätze importieren? Ungelöste Abgleiche und ausgeschlossene Datensätze bleiben unberücksichtigt. Bestehende Datensätze werden nicht geändert."),
        "kobus_consult":
            MessageLookupByLibrary.simpleMessage("KOBUS-Daten einsehen"),
        "kobus_create":
            MessageLookupByLibrary.simpleMessage("Ein Datensatz anlegen"),
        "kobus_creations": MessageLookupByLibrary.simpleMessage(
            "Erstellte / noch zu erstellende Datenblätter"),
        "kobus_distinct": MessageLookupByLibrary.simpleMessage(
            "Eine andere Person bestätigen"),
        "kobus_editRejected": MessageLookupByLibrary.simpleMessage(
            "Liste der abgelehnten Anträge bearbeiten"),
        "kobus_existing": MessageLookupByLibrary.simpleMessage(
            "Betroffene bestehende Patienten"),
        "kobus_failed":
            MessageLookupByLibrary.simpleMessage("Technische Probleme"),
        "kobus_history":
            MessageLookupByLibrary.simpleMessage("KOBUS-Protokoll"),
        "kobus_imported": MessageLookupByLibrary.simpleMessage("Importiert"),
        "kobus_interrupted": MessageLookupByLibrary.simpleMessage(
            "Nach Unterbrechung unbehandelt"),
        "kobus_intro": MessageLookupByLibrary.simpleMessage(
            "Die Akten werden unverändert beibehalten. Es werden weder Episoden noch native klinische Dokumente angelegt."),
        "kobus_matches": MessageLookupByLibrary.simpleMessage(
            "Zu überprüfende Abstimmungen"),
        "kobus_noShared": MessageLookupByLibrary.simpleMessage(
            "In diesem Export sind keine freigegebenen Ordner enthalten"),
        "kobus_ownOrigin":
            MessageLookupByLibrary.simpleMessage("Meine Patienten"),
        "kobus_print": MessageLookupByLibrary.simpleMessage("Drucken"),
        "kobus_provenance":
            MessageLookupByLibrary.simpleMessage("Herkunft / Status"),
        "kobus_reason": MessageLookupByLibrary.simpleMessage("Begründung"),
        "kobus_rejected": MessageLookupByLibrary.simpleMessage("Abgelehnt"),
        "kobus_savePdf": MessageLookupByLibrary.simpleMessage("PDF speichern"),
        "kobus_scopeReset": MessageLookupByLibrary.simpleMessage(
            "Durch Ändern dieser Option werden die Abstimmungsentscheidungen zurückgesetzt."),
        "kobus_select":
            MessageLookupByLibrary.simpleMessage("Wählen Sie den ZIP KOBUS"),
        "kobus_shared": MessageLookupByLibrary.simpleMessage(
            "Falls vorhanden, auch freigegebene Ordner wiederherstellen"),
        "kobus_sharedOrigin":
            MessageLookupByLibrary.simpleMessage("Geteilte Patienten"),
        "kobus_skip": MessageLookupByLibrary.simpleMessage("Ausgegrenzt"),
        "kobus_source": MessageLookupByLibrary.simpleMessage("KOBUS-Identität"),
        "kobus_start": MessageLookupByLibrary.simpleMessage("Import starten"),
        "kobus_stop": MessageLookupByLibrary.simpleMessage(
            "Nach dem aktuellen Ordner anhalten"),
        "kobus_stopping":
            MessageLookupByLibrary.simpleMessage("Halt gewünscht…"),
        "kobus_title":
            MessageLookupByLibrary.simpleMessage("KOBUS importieren"),
        "kobus_unavailable": MessageLookupByLibrary.simpleMessage(
            "Die KOBUS-Daten sind nicht verfügbar oder die Datei kann nicht gefunden werden."),
        "kobus_unresolved":
            MessageLookupByLibrary.simpleMessage("Noch zu entscheiden"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Gespeicherte Sprache."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Sprache der Anwendung"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Hinweis"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion ist eine Software, die bei der Organisation, dem Import und der Einsichtnahme in klinische Ergebnisse aus dem ABAK-Ökosystem unterstützt.\n\nSie stellt kein zertifiziertes Medizinprodukt dar und ersetzt nicht die Beurteilung durch medizinisches Fachpersonal.\n\nDie angezeigten Ergebnisse, Werte, Berichte und Indikatoren müssen stets von einer qualifizierten Fachkraft unter Berücksichtigung der klinischen Untersuchung, der Situation des Patienten und der geltenden Empfehlungen interpretiert werden.\n\nDer Nutzer bleibt allein verantwortlich für seine klinischen Entscheidungen, die Überprüfung der importierten Daten und die Übereinstimmung ihrer Verwendung mit den geltenden beruflichen, behördlichen und ethischen Vorschriften.\n\nABAK Desktop Companion stellt keine eigenständige Diagnose, verschreibt keine Behandlung und ersetzt in keinem Fall eine ärztliche oder paramedizinische Konsultation."),
        "legalNotice_help": MessageLookupByLibrary.simpleMessage(
            "Auf dieser Seite finden Sie Hinweise und Informationen zur Nutzung von Companion.\n\nScrollen Sie nach unten, um den gesamten Text zu lesen.\n\nVerwenden Sie den Zurück-Pfeil, um zur Seite „Über“ zurückzukehren."),
        "legalNotice_title":
            MessageLookupByLibrary.simpleMessage("Rechtlicher Hinweis"),
        "loading": MessageLookupByLibrary.simpleMessage("Wird geladen..."),
        "localDatabaseBackup_cancelled":
            MessageLookupByLibrary.simpleMessage("Sicherung abgebrochen."),
        "localDatabaseBackup_chooseBackupFolder":
            MessageLookupByLibrary.simpleMessage(
                "ABAK-Sicherungsordner auswählen"),
        "localDatabaseBackup_databaseNotFound":
            MessageLookupByLibrary.simpleMessage(
                "SQLite-Datenbank nicht gefunden."),
        "localDatabaseReset_backupFailed": MessageLookupByLibrary.simpleMessage(
            "Vorgängige Sicherung nicht möglich"),
        "localDatabaseRestoreService_anomaly": m33,
        "localDatabaseRestoreService_failure": m34,
        "localDatabaseRestoreService_integrity": m35,
        "localDatabaseRestoreService_missing":
            MessageLookupByLibrary.simpleMessage(
                "Die Sicherungsdatei kann nicht gefunden werden."),
        "localDatabaseRestoreService_success":
            MessageLookupByLibrary.simpleMessage(
                "Die Wiederherstellung wurde erfolgreich durchgeführt."),
        "main_alreadyRunningMessage": MessageLookupByLibrary.simpleMessage(
            "Es kann jeweils nur eine Instanz geöffnet sein.\n\nVerwenden Sie das bereits geöffnete Companion-Fenster."),
        "main_alreadyRunningTitle": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion ist bereits geöffnet"),
        "main_close": MessageLookupByLibrary.simpleMessage(""),
        "modify": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "noDirectoryDefined": MessageLookupByLibrary.simpleMessage(
            "Es wurde kein Ordner festgelegt"),
        "ok": MessageLookupByLibrary.simpleMessage("Na gut"),
        "open": MessageLookupByLibrary.simpleMessage("Öffnen"),
        "organization_chooseLogo":
            MessageLookupByLibrary.simpleMessage("Ein Logo auswählen"),
        "organization_chooseReportHeader": MessageLookupByLibrary.simpleMessage(
            "Eine benutzerdefinierte Kopfzeile auswählen"),
        "organization_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm können Sie den Namen und die Kontaktdaten Ihrer Praxis eingeben: Adresse, Postleitzahl, Ort, Telefonnummer und E-Mail-Adresse.\n\nKlicken Sie auf „Kontaktdaten speichern“, um Ihre Änderungen zu speichern, bevor Sie den Bildschirm verlassen.\n\nSie können außerdem ein Bild auf Ihrem Computer auswählen, um das Logo Ihrer Praxis festzulegen. Die Auswahl des Logos wird sofort gespeichert, unabhängig von den Kontaktdaten.\n\nMit der Schaltfläche zum Löschen des Logos können Sie das in Companion verwendete Logo entfernen."),
        "organization_identityTitle":
            MessageLookupByLibrary.simpleMessage("Identität der Einrichtung"),
        "organization_logoRecommendation": MessageLookupByLibrary.simpleMessage(
            "Empfohlene Größe: quadratisches Bild mit mindestens 300 × 300 px. Empfohlenes Format: PNG."),
        "organization_logoRemoved": MessageLookupByLibrary.simpleMessage(
            "Das Logo der Einrichtung wurde entfernt."),
        "organization_logoSaved": MessageLookupByLibrary.simpleMessage(
            "Eingetragenes Logo der Einrichtung."),
        "organization_nameLabel":
            MessageLookupByLibrary.simpleMessage("Name der Einrichtung"),
        "organization_nameSaved": MessageLookupByLibrary.simpleMessage(
            "Name der eingetragenen Einrichtung."),
        "organization_removeLogo":
            MessageLookupByLibrary.simpleMessage("Logo entfernen"),
        "organization_removeReportHeader":
            MessageLookupByLibrary.simpleMessage("Kopfzeile löschen"),
        "organization_reportHeaderHelpAi": MessageLookupByLibrary.simpleMessage(
            "Sie können auch ein KI-Tool bitten, anhand Ihrer Vorgaben das Bild für Ihre Kopfzeile zu erstellen."),
        "organization_reportHeaderHelpClose":
            MessageLookupByLibrary.simpleMessage("Schließen"),
        "organization_reportHeaderHelpContent":
            MessageLookupByLibrary.simpleMessage(
                "Das Bild kann nach Belieben Ihr Logo, den Namen Ihrer Einrichtung, Ihre Kontaktdaten und alle weiteren grafischen Elemente enthalten, die Sie in Ihren Berichten anzeigen möchten."),
        "organization_reportHeaderHelpFormat": MessageLookupByLibrary.simpleMessage(
            "Um ein optimales Ergebnis in den ABAK-Berichten zu erzielen, verwenden Sie bitte ein Bild im Format 200 × 30 mm, was etwa 2362 × 354 px bei 300 dpi entspricht. Das PNG-Format wird empfohlen."),
        "organization_reportHeaderHelpIntro": MessageLookupByLibrary.simpleMessage(
            "Sie können Ihre Kopfzeile mit einem Tool Ihrer Wahl frei gestalten und anschließend als Bild speichern."),
        "organization_reportHeaderHelpReplacement":
            MessageLookupByLibrary.simpleMessage(
                "Die im Bild enthaltenen Informationen ersetzen die von ABAK generierte Standardkopfzeile (Logo und Kontaktdaten der Einrichtung)."),
        "organization_reportHeaderHelpTitle":
            MessageLookupByLibrary.simpleMessage(
                "Eine benutzerdefinierte Kopfzeile erstellen"),
        "organization_reportHeaderHelpTools": MessageLookupByLibrary.simpleMessage(
            "Wenn Sie mit Grafikprogrammen noch nicht vertraut sind, können Sie beispielsweise LibreOffice Draw, Microsoft PowerPoint, Apple Keynote oder Canva verwenden. Diese Liste dient lediglich als Beispiel und erhebt keinen Anspruch auf Vollständigkeit."),
        "organization_reportHeaderHelpTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Hilfe zum Erstellen einer benutzerdefinierten Kopfzeile"),
        "organization_reportHeaderRecommendation":
            MessageLookupByLibrary.simpleMessage(
                "Empfohlene Größe: 200 × 30 mm (ca. 2362 × 354 px bei 300 dpi). Empfohlenes Format: PNG."),
        "organization_reportHeaderRemoved":
            MessageLookupByLibrary.simpleMessage(
                "Benutzerdefinierte Kopfzeile entfernt."),
        "organization_reportHeaderSaved": MessageLookupByLibrary.simpleMessage(
            "Benutzerdefinierte Kopfzeile gespeichert."),
        "organization_reportHeaderTitle": MessageLookupByLibrary.simpleMessage(
            "Individuelle Kopfzeile für Berichte"),
        "organization_reportIntroductionHelp": MessageLookupByLibrary.simpleMessage(
            "Freitext, der am Anfang der Berichte verwendet wird. Ist dieses Feld leer, wird „Herr Doktor“ verwendet."),
        "organization_reportIntroductionHint":
            MessageLookupByLibrary.simpleMessage("Doktor"),
        "organization_reportIntroductionLabel":
            MessageLookupByLibrary.simpleMessage(
                "Einleitende Formulierung der Berichte"),
        "organization_saveName":
            MessageLookupByLibrary.simpleMessage("Namen speichern"),
        "organization_title":
            MessageLookupByLibrary.simpleMessage("Einrichtung"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Ein Telefon koppeln"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Ein Telefon koppeln"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scannen Sie diesen QR-Code mit ABAK Mobile, um die Verbindung zum Desktop automatisch einzurichten."),
        "pairPhone_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster werden die Informationen angezeigt, anhand derer ABAK Mobile Companion im lokalen Netzwerk finden kann.\n\nVerbinden Sie das Smartphone oder Tablet und den Computer mit demselben lokalen Netzwerk und scannen Sie anschließend diesen QR-Code über die Funktion zur Kopplung mit Companion in ABAK Mobile.\n\nDer QR-Code enthält die Netzwerkadresse und den Kommunikationsport dieses Computers. Diese Informationen werden ebenfalls unter dem Code angezeigt.\n\nLassen Sie Companion während des Datenaustauschs auf dem Computer geöffnet. Sollte sich die Netzwerkadresse des Computers ändern, öffnen Sie dieses Fenster erneut und scannen Sie den neuen Code.\n\nDas Anzeigen dieses QR-Codes allein löst noch nicht das Senden von Ergebnissen aus."),
        "patientClinicalDataEdit_address":
            MessageLookupByLibrary.simpleMessage("Adresse"),
        "patientClinicalDataEdit_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Verwaltungsidentität"),
        "patientClinicalDataEdit_ambidextrous":
            MessageLookupByLibrary.simpleMessage("Beidhändig"),
        "patientClinicalDataEdit_centimeters":
            MessageLookupByLibrary.simpleMessage("In Zentimetern"),
        "patientClinicalDataEdit_dominantSide":
            MessageLookupByLibrary.simpleMessage("Dominante Seite"),
        "patientClinicalDataEdit_email":
            MessageLookupByLibrary.simpleMessage("E-Mail"),
        "patientClinicalDataEdit_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage(
                "Länder mit diesem Gesundheitssystem"),
        "patientClinicalDataEdit_height":
            MessageLookupByLibrary.simpleMessage("Größe"),
        "patientClinicalDataEdit_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm können Sie die administrativen Angaben und das Profil des Patienten vervollständigen.\n\nSie können die Gesundheits-ID des Patienten, die Quelle seiner Identität, seine Telefonnummer, seine E-Mail-Adresse und seine Postanschrift eingeben.\n\nDas Profil umfasst die dominante Seite, den Beruf, sportliche Aktivitäten, die Körpergröße in Zentimetern und das Gewicht in Kilogramm.\n\nKlicken Sie auf „Speichern“, um Ihre Änderungen zu speichern und zur Patientenkarte zurückzukehren. Wenn Sie ohne Speichern zurückgehen, gehen die Änderungen verloren."),
        "patientClinicalDataEdit_identitySource":
            MessageLookupByLibrary.simpleMessage("Quelle der Identität"),
        "patientClinicalDataEdit_kilograms":
            MessageLookupByLibrary.simpleMessage("In Kilogramm"),
        "patientClinicalDataEdit_left":
            MessageLookupByLibrary.simpleMessage("Links"),
        "patientClinicalDataEdit_manualEntry":
            MessageLookupByLibrary.simpleMessage("Manuelle Eingabe"),
        "patientClinicalDataEdit_nationalHealthId":
            MessageLookupByLibrary.simpleMessage("Nationale Gesundheits-ID"),
        "patientClinicalDataEdit_nationalHealthIdHelper":
            MessageLookupByLibrary.simpleMessage(
                "Beispiel Frankreich: Sozialversicherungsnummer"),
        "patientClinicalDataEdit_patientProfile":
            MessageLookupByLibrary.simpleMessage("Patientenprofil"),
        "patientClinicalDataEdit_phone":
            MessageLookupByLibrary.simpleMessage("Telefon"),
        "patientClinicalDataEdit_profession":
            MessageLookupByLibrary.simpleMessage("Beruf"),
        "patientClinicalDataEdit_right":
            MessageLookupByLibrary.simpleMessage("Rechts"),
        "patientClinicalDataEdit_save":
            MessageLookupByLibrary.simpleMessage("Speichern"),
        "patientClinicalDataEdit_sportActivity":
            MessageLookupByLibrary.simpleMessage(
                "Übliche sportliche Betätigung"),
        "patientClinicalDataEdit_title":
            MessageLookupByLibrary.simpleMessage("Klinische Daten bearbeiten"),
        "patientClinicalDataEdit_unspecified":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "patientClinicalDataEdit_vitaleCard":
            MessageLookupByLibrary.simpleMessage("Gesundheitskarte"),
        "patientClinicalDataEdit_weight":
            MessageLookupByLibrary.simpleMessage("Gewicht"),
        "patientDetail_address":
            MessageLookupByLibrary.simpleMessage("Adresse"),
        "patientDetail_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Verwaltungsidentität"),
        "patientDetail_archived":
            MessageLookupByLibrary.simpleMessage("archiviert"),
        "patientDetail_bornOn":
            MessageLookupByLibrary.simpleMessage("Weder (noch) die"),
        "patientDetail_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "patientDetail_careEpisodeOpenedIn":
            MessageLookupByLibrary.simpleMessage("Offene Betreuung in"),
        "patientDetail_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Leistungen"),
        "patientDetail_create":
            MessageLookupByLibrary.simpleMessage("Erstellen"),
        "patientDetail_dominantSide":
            MessageLookupByLibrary.simpleMessage("Dominante Seite"),
        "patientDetail_edit":
            MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "patientDetail_editCareEpisode":
            MessageLookupByLibrary.simpleMessage("Die Betreuung ändern"),
        "patientDetail_editCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie die Angaben zur Patientenbetreuung bearbeiten.\n\nSie können die Erkrankung oder den Grund für die Betreuung korrigieren, den ursprünglichen Text ergänzen und den behandelnden Arzt sowie den verschreibenden Arzt auswählen.\n\nDie Erkrankung muss angegeben werden, damit die Änderungen gespeichert werden.\n\nKlicken Sie auf „Speichern“, um die Änderungen zu bestätigen. Mit „Abbrechen“ wird das Fenster geschlossen, ohne die Änderungen zu übernehmen.\n\nBeim Öffnen und Schließen dieser Hilfe bleiben Ihre Eingaben im Formular erhalten."),
        "patientDetail_editClinicalData":
            MessageLookupByLibrary.simpleMessage("Klinische Daten bearbeiten"),
        "patientDetail_email": MessageLookupByLibrary.simpleMessage("E-Mail"),
        "patientDetail_error": MessageLookupByLibrary.simpleMessage("Fehler"),
        "patientDetail_frHealthIdentity": MessageLookupByLibrary.simpleMessage(
            "Gesundheitsausweis – Frankreich"),
        "patientDetail_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage("Land – Gesundheitssystem"),
        "patientDetail_height": MessageLookupByLibrary.simpleMessage("Größe"),
        "patientDetail_identitySource":
            MessageLookupByLibrary.simpleMessage("Quelle: Identität"),
        "patientDetail_initialReport":
            MessageLookupByLibrary.simpleMessage("Erster Bericht"),
        "patientDetail_nationalIdentifier":
            MessageLookupByLibrary.simpleMessage(
                "Nationale Identifikationsnummer"),
        "patientDetail_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Neue Kostenübernahme"),
        "patientDetail_newCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie eine neue Behandlung für den ausgewählten Patienten anlegen.\n\nGeben Sie die Erkrankung oder den Grund für die Behandlung ein. Diese Angabe ist erforderlich, um die Behandlungsphase anzulegen.\n\nSie können den Anfangstext ergänzen und einen behandelnden Arzt auswählen. Diese Angaben sind optional.\n\nKlicken Sie auf „Erstellen“, um die Behandlungsphase zu speichern. Mit „Abbrechen“ schließen Sie das Fenster, ohne die Behandlungsphase zu erstellen.\n\nBeim Öffnen und Schließen dieser Hilfe bleiben Ihre Eingaben im Formular erhalten."),
        "patientDetail_noBirthdate":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "patientDetail_noCareEpisode": MessageLookupByLibrary.simpleMessage(
            "Für diesen Patienten wurde keine Behandlung angelegt."),
        "patientDetail_notProvided":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "patientDetail_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "patientDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "patientDetail_patientInformation":
            MessageLookupByLibrary.simpleMessage("Informationen für Patienten"),
        "patientDetail_patientProfile":
            MessageLookupByLibrary.simpleMessage("Patientenprofil"),
        "patientDetail_phone": MessageLookupByLibrary.simpleMessage("Telefon"),
        "patientDetail_profession":
            MessageLookupByLibrary.simpleMessage("Beruf"),
        "patientDetail_provisional":
            MessageLookupByLibrary.simpleMessage("Vorläufig"),
        "patientDetail_provisionalDescription":
            MessageLookupByLibrary.simpleMessage(
                "Angaben zur Identität bitte vervollständigen"),
        "patientDetail_qualified":
            MessageLookupByLibrary.simpleMessage("Qualifiziert"),
        "patientDetail_qualifiedDescription":
            MessageLookupByLibrary.simpleMessage("Übereinstimmende Identität"),
        "patientDetail_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Behandelnder Physiotherapeut"),
        "patientDetail_retrieved":
            MessageLookupByLibrary.simpleMessage("Abgerufen"),
        "patientDetail_retrievedDescription":
            MessageLookupByLibrary.simpleMessage(
                "INS erhalten, Identität zu überprüfen"),
        "patientDetail_save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "patientDetail_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "patientDetail_sportActivity":
            MessageLookupByLibrary.simpleMessage("Sportliche Aktivität"),
        "patientDetail_state": MessageLookupByLibrary.simpleMessage("Status"),
        "patientDetail_status": MessageLookupByLibrary.simpleMessage("Status"),
        "patientDetail_validated":
            MessageLookupByLibrary.simpleMessage("Bestätigt"),
        "patientDetail_validatedDescription":
            MessageLookupByLibrary.simpleMessage(
                "Identität überprüft, INS noch zu ermitteln"),
        "patientDetail_weight": MessageLookupByLibrary.simpleMessage("Gewicht"),
        "patientDetail_years": MessageLookupByLibrary.simpleMessage("Jahre"),
        "patientDocuments_authorization": MessageLookupByLibrary.simpleMessage(
            "Der Ordner muss erneut autorisiert werden. Wählen Sie den in den Einstellungen festgelegten gemeinsamen Ordner aus."),
        "patientDocuments_chooseRoot": MessageLookupByLibrary.simpleMessage(
            "Gemeinsamen Ordner auswählen"),
        "patientDocuments_error": MessageLookupByLibrary.simpleMessage(
            "Der Ordner kann nicht vorbereitet oder geöffnet werden. Überprüfen Sie, ob der Ordner verfügbar ist und ob Sie über die entsprechenden Zugriffsrechte verfügen, und versuchen Sie es dann erneut."),
        "patientDocuments_open":
            MessageLookupByLibrary.simpleMessage("„Patientenakte öffnen“"),
        "patientDocuments_retry":
            MessageLookupByLibrary.simpleMessage("Es noch einmal versuchen"),
        "patientDocuments_settingsHelp": MessageLookupByLibrary.simpleMessage(
            "Eine Akte pro Patient, bestehend aus „Befund“, „Bericht“ und „Sonstiges“. Wird beim Anlegen der Patientenakte erstellt; bereits vorhandene Dateien werden nicht verschoben."),
        "patientDocuments_structure": MessageLookupByLibrary.simpleMessage(
            "Bilanz / Bericht / Sonstiges"),
        "patientDocuments_title":
            MessageLookupByLibrary.simpleMessage("Patientenunterlagen"),
        "patientDocuments_unconfigured": MessageLookupByLibrary.simpleMessage(
            "Es wurde kein Speicherordner festgelegt. Wählen Sie den Ordner aus, der für alle Patienten gilt."),
        "patientForm_birthDate":
            MessageLookupByLibrary.simpleMessage("Geburtsdatum"),
        "patientForm_cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "patientForm_create": MessageLookupByLibrary.simpleMessage("Erstellen"),
        "patientForm_editPatient":
            MessageLookupByLibrary.simpleMessage("Patienten bearbeiten"),
        "patientForm_female": MessageLookupByLibrary.simpleMessage("Frau"),
        "patientForm_firstName":
            MessageLookupByLibrary.simpleMessage("Vorname"),
        "patientForm_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("Der Vorname ist Pflicht"),
        "patientForm_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie die Patientendaten eingeben oder korrigieren.\n\nVorname und Nachname sind Pflichtangaben. Sie können das Geburtsdatum im Kalender auswählen und das Geschlecht angeben oder den Wert „Nicht angegeben“ beibehalten.\n\nKlicken Sie auf „Speichern“, um die Änderungen zu bestätigen. Wenn das Formular im Erstellungsmodus geöffnet ist, können Sie über die Schaltfläche „Erstellen“ den Datensatz anlegen.\n\n„Abbrechen“ schließt das Fenster, ohne die Änderungen zu übernehmen. Beim Öffnen und Schließen dieser Hilfe bleiben Ihre Eingaben im Formular erhalten."),
        "patientForm_lastName": MessageLookupByLibrary.simpleMessage("Name"),
        "patientForm_lastNameRequired": MessageLookupByLibrary.simpleMessage(
            "Der Name ist ein Pflichtfeld"),
        "patientForm_male": MessageLookupByLibrary.simpleMessage("Mann"),
        "patientForm_newPatient":
            MessageLookupByLibrary.simpleMessage("Neuer Patient"),
        "patientForm_other": MessageLookupByLibrary.simpleMessage("Sonstiges"),
        "patientForm_save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "patientForm_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "patientForm_unspecified":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "patientList_active":
            MessageLookupByLibrary.simpleMessage("Vermögenswerte"),
        "patientList_archive":
            MessageLookupByLibrary.simpleMessage("Archivieren"),
        "patientList_archiveConfirmation": m36,
        "patientList_archiveSuccess": m37,
        "patientList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Den Patienten archivieren"),
        "patientList_archived":
            MessageLookupByLibrary.simpleMessage("Archiviert"),
        "patientList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archiviert am"),
        "patientList_archivedPatient":
            MessageLookupByLibrary.simpleMessage("Archivierter Patient"),
        "patientList_archivedPatientsEmpty":
            MessageLookupByLibrary.simpleMessage(
                "Der Warenkorb der Patienten ist derzeit leer."),
        "patientList_bornOn":
            MessageLookupByLibrary.simpleMessage("Weder (noch) die"),
        "patientList_cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "patientList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Sie können die Liste der aktiven und der archivierten Patienten anzeigen"),
        "patientList_contextName":
            MessageLookupByLibrary.simpleMessage("Patientenliste"),
        "patientList_edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "patientList_error": m38,
        "patientList_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm können Sie Ihre Patienten suchen und auf deren Akten zugreifen.\n\nMit den Schaltflächen „Aktiv“ und „Archiviert“ können Sie auswählen, welche Liste angezeigt werden soll. Die angezeigte Zahl entspricht der Gesamtzahl der Patienten in der jeweiligen Kategorie.\n\nUm einen Patienten in der angezeigten Liste zu suchen, geben Sie seinen Nachnamen oder Vornamen ganz oder teilweise in das Suchfeld ein. Klicken Sie auf die entsprechende Zeile, um die Patientenakte zu öffnen.\n\nDie Schaltfläche „Neuer Patient“ öffnet den Bildschirm zur Anlage eines Patienten.\n\nBei einem aktiven Patienten können Sie über das Stiftsymbol seine Daten bearbeiten. Über das Archivierungssymbol können Sie ihn nach Bestätigung aus der Liste der aktiven Patienten entfernen.\n\nIn der Liste der archivierten Patienten können Sie einen Patienten über das Symbol „Wiederherstellen“ wieder in die Liste der aktiven Patienten aufnehmen. Eine spezielle Hilfe, die neben dem Archivierungsdatum zugänglich ist, erläutert die Aufbewahrungsmodalitäten."),
        "patientList_newPatient":
            MessageLookupByLibrary.simpleMessage("Neuer Patient"),
        "patientList_noArchivedPatients": MessageLookupByLibrary.simpleMessage(
            "Keine archivierten Patienten"),
        "patientList_noPatientFound": MessageLookupByLibrary.simpleMessage(
            "Es wurden keine Patienten gefunden"),
        "patientList_noRegisteredPatients":
            MessageLookupByLibrary.simpleMessage(
                "Es sind keine Patienten registriert"),
        "patientList_patientFileEmpty": MessageLookupByLibrary.simpleMessage(
            "Die lokale Patientendatei ist derzeit leer."),
        "patientList_restorableUntil":
            MessageLookupByLibrary.simpleMessage("Wiederherstellbar bis zum"),
        "patientList_restore":
            MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
        "patientList_restoreSuccess": m39,
        "patientList_searchPatient":
            MessageLookupByLibrary.simpleMessage("Einen Patienten suchen"),
        "patientList_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "patientList_title":
            MessageLookupByLibrary.simpleMessage("Patientenliste"),
        "patientNew_archivedMatchToReview":
            MessageLookupByLibrary.simpleMessage(
                "Zu überprüfende archivierte Korrespondenz"),
        "patientNew_archivedMatchToReviewMessage":
            MessageLookupByLibrary.simpleMessage(
                "Es gibt bereits einen archivierten Patienten mit demselben Nachnamen, Vornamen und Geburtsdatum, dessen administrative Angaben jedoch abweichen.\n\nEs erfolgt keine automatische Wiederherstellung. Überprüfen Sie die Datensätze, bevor Sie fortfahren."),
        "patientNew_archivedPatientFound":
            MessageLookupByLibrary.simpleMessage("Patient im Archiv gefunden"),
        "patientNew_archivedPatientMatch": MessageLookupByLibrary.simpleMessage(
            "Diese Carte Vitale gehört zu dem archivierten Patienten:"),
        "patientNew_attach": MessageLookupByLibrary.simpleMessage("Zuordnen"),
        "patientNew_attachVitaleError": MessageLookupByLibrary.simpleMessage(
            "Die Carte Vitale kann nicht verknüpft werden"),
        "patientNew_attachVitaleQuestion": MessageLookupByLibrary.simpleMessage(
            "Möchten Sie die Daten der Carte Vitale diesem Patienten zuordnen?"),
        "patientNew_attachVitaleSuccess": m40,
        "patientNew_backToList":
            MessageLookupByLibrary.simpleMessage("Zurück zur Liste"),
        "patientNew_birthDate":
            MessageLookupByLibrary.simpleMessage("Geburtsdatum"),
        "patientNew_cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "patientNew_choosePatient":
            MessageLookupByLibrary.simpleMessage("Patienten auswählen"),
        "patientNew_close": MessageLookupByLibrary.simpleMessage("Schließen"),
        "patientNew_contextComment": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm kann ein neuer Patient durch manuelle Eingabe oder durch Einlesen der Carte Vitale angelegt werden."),
        "patientNew_contextName":
            MessageLookupByLibrary.simpleMessage("Neuer Patient"),
        "patientNew_createError": MessageLookupByLibrary.simpleMessage(
            "Fehler beim Anlegen des Patienten"),
        "patientNew_createPatient":
            MessageLookupByLibrary.simpleMessage("Patienten anlegen"),
        "patientNew_creating":
            MessageLookupByLibrary.simpleMessage("Erstellung..."),
        "patientNew_download":
            MessageLookupByLibrary.simpleMessage("Herunterladen"),
        "patientNew_existingPatientTitle": MessageLookupByLibrary.simpleMessage(
            "Sind Sie bereits Patient bei uns?"),
        "patientNew_female": MessageLookupByLibrary.simpleMessage("Weiblich"),
        "patientNew_firstName": MessageLookupByLibrary.simpleMessage("Vorname"),
        "patientNew_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("Der Vorname ist Pflicht"),
        "patientNew_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm können Sie einen Patienten in ABAK Companion anlegen.\n\nGeben Sie den Vor- und Nachnamen ein: Diese beiden Angaben sind Pflichtfelder. Sie können das Geburtsdatum mithilfe des Kalenders ergänzen und das Geschlecht angeben.\n\nÜber die Schaltfläche zum Einlesen der Vitale-Karte können Sie die Identität des Patienten abrufen, sofern das Lesegerät und das Lesemodul verfügbar sind. Wenn mehrere Versicherte vorgeschlagen werden, wählen Sie die betreffende Person aus und überprüfen Sie anschließend die angezeigten Angaben. Eine manuelle Eingabe ist weiterhin möglich.\n\nWenn Companion einen bereits vorhandenen Patienten erkennt, überprüfen Sie die vorgeschlagenen Angaben, bevor Sie fortfahren, um einen Doppeleintrag zu vermeiden. Ein archivierter Patient kann zur Wiederherstellung vorgeschlagen werden.\n\nKlicken Sie auf „Patienten anlegen“, um den Datensatz zu speichern, oder auf „Abbrechen“, um den Vorgang zu beenden, ohne einen Patienten anzulegen."),
        "patientNew_identificationCountriesHelp":
            MessageLookupByLibrary.simpleMessage(
                "Das in Companion angebotene Einlesen der „Carte Vitale“ gilt derzeit für Frankreich. Damit lassen sich Identitätsdaten abrufen, um die Erstellung der Patientenakte zu erleichtern.\n\nABAK Companion möchte diesen Ansatz auf die in anderen Ländern verwendeten Identifikationsmittel ausweiten. Karten, Identifikationsdaten und Gesundheitsdienste funktionieren dort anders: Die Unterstützung hierfür ist noch nicht in Companion integriert. Die manuelle Eingabe bleibt weiterhin möglich.\n\nWir möchten diese Möglichkeiten gemeinsam mit den Physiotherapeuten, die ABAK nutzen, ausloten. Möchten Sie uns in Ihrem Land dabei unterstützen? Ihre Kenntnisse der lokalen Gegebenheiten und Ihre Teilnahme an den Tests werden uns helfen, eine nützliche und passende Lösung zu entwickeln.\n\nDie Weiterentwicklungen werden schrittweise gemeinsam mit freiwilligen Fachkräften erarbeitet, entsprechend den geäußerten Bedürfnissen, den technischen Möglichkeiten und den erforderlichen Genehmigungen."),
        "patientNew_identificationCountriesTitle":
            MessageLookupByLibrary.simpleMessage(
                "Identifizierung der Patienten nach Ländern"),
        "patientNew_lastName": MessageLookupByLibrary.simpleMessage("Name"),
        "patientNew_lastNameRequired": MessageLookupByLibrary.simpleMessage(
            "Der Name ist ein Pflichtfeld"),
        "patientNew_male": MessageLookupByLibrary.simpleMessage("Männlich"),
        "patientNew_matchToReview": MessageLookupByLibrary.simpleMessage(
            "Zu überprüfende Korrespondenz"),
        "patientNew_matchToReviewMessage": MessageLookupByLibrary.simpleMessage(
            "Es gibt bereits einen Patienten mit demselben Nachnamen, Vornamen und Geburtsdatum.\n\nDie Verwaltungsdaten stimmen nicht vollständig überein. Überprüfen Sie die Akte, bevor Sie fortfahren."),
        "patientNew_matchingPatientFound": MessageLookupByLibrary.simpleMessage(
            "Es wurde ein passender Patient gefunden:"),
        "patientNew_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "patientNew_nirDetectedProtected":
            MessageLookupByLibrary.simpleMessage("erkannt und geschützt"),
        "patientNew_nirUnavailable":
            MessageLookupByLibrary.simpleMessage("nicht verfügbar"),
        "patientNew_no": MessageLookupByLibrary.simpleMessage("Nicht"),
        "patientNew_noNewPatientCreated": MessageLookupByLibrary.simpleMessage(
            "Es wird kein neuer Patient angelegt."),
        "patientNew_notProvided":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "patientNew_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("keine Angabe"),
        "patientNew_other": MessageLookupByLibrary.simpleMessage("Sonstiges"),
        "patientNew_patientAlreadyRegistered":
            MessageLookupByLibrary.simpleMessage(
                "Bereits registrierter Patient"),
        "patientNew_patientIdentity":
            MessageLookupByLibrary.simpleMessage("Angaben zum Patienten"),
        "patientNew_readOn":
            MessageLookupByLibrary.simpleMessage("Abgelesen am"),
        "patientNew_readVitale":
            MessageLookupByLibrary.simpleMessage("Gesundheitskarte lesen"),
        "patientNew_readerNotDetected": MessageLookupByLibrary.simpleMessage(
            "Kartenlesegerät für die „Carte Vitale“ wurde nicht erkannt"),
        "patientNew_readerNotDetectedMessage": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion hat kein Carte-Vitale-Lesegerät erkannt.\n\nUm diese Funktion nutzen zu können, benötigen Sie:\n\n• ein PC/SC-kompatibles Carte-Vitale-Lesegerät, das in der Regel über USB angeschlossen wird;\n• das ABAK-Carte-Vitale-Modul, das kostenlos zur Verfügung gestellt wird. Siehe die Website abak.care.\n\nSobald das Lesegerät angeschlossen ist, klicken Sie erneut auf „Carte Vitale lesen“."),
        "patientNew_reading":
            MessageLookupByLibrary.simpleMessage("Wird gerade gelesen..."),
        "patientNew_restore":
            MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
        "patientNew_restoreError": MessageLookupByLibrary.simpleMessage(
            "Der Patient konnte nicht wiederbelebt werden"),
        "patientNew_restoreInsteadOfCreate": MessageLookupByLibrary.simpleMessage(
            "Möchten Sie diesen Ordner wiederherstellen, anstatt einen neuen Patienten anzulegen?"),
        "patientNew_restoreSuccess": m41,
        "patientNew_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "patientNew_vitaleIdentityRead": MessageLookupByLibrary.simpleMessage(
            "Identitätsdaten, die von der Carte Vitale ausgelesen wurden"),
        "patientNew_vitaleMatchesPatient": MessageLookupByLibrary.simpleMessage(
            "Diese Carte Vitale gehört zu folgendem Patienten:"),
        "patientNew_vitaleModuleConfigurationError":
            MessageLookupByLibrary.simpleMessage(
                "Die Konfiguration des Moduls „Carte Vitale“ fehlt oder ist fehlerhaft. Installieren Sie das Modul neu und versuchen Sie es erneut."),
        "patientNew_vitaleModuleNotInstalled":
            MessageLookupByLibrary.simpleMessage(
                "Das „Carte Vitale“-Modul ist nicht installiert"),
        "patientNew_vitaleModuleNotInstalledMessage":
            MessageLookupByLibrary.simpleMessage(
                "Das ABAK-Modul „Carte Vitale“ ist auf diesem Computer nicht installiert.\n\nSie können es kostenlos von der ABAK-Website herunterladen."),
        "patientNew_vitalePrefilled": MessageLookupByLibrary.simpleMessage(
            "Aus der „Carte Vitale“ vorab ausgefüllte Patientendaten."),
        "patientNew_vitaleReadFailed": MessageLookupByLibrary.simpleMessage(
            "Das Einlesen der Carte Vitale ist fehlgeschlagen."),
        "practitionerList_active":
            MessageLookupByLibrary.simpleMessage("Vermögenswerte"),
        "practitionerList_addPractitionersHint":
            MessageLookupByLibrary.simpleMessage(
                "Fügen Sie die Physiotherapeuten der Praxis hinzu, um die importierten Tests zu identifizieren."),
        "practitionerList_archive":
            MessageLookupByLibrary.simpleMessage("Archivieren"),
        "practitionerList_archiveConfirmation": m42,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "Der Papierkorb der Physiotherapeuten ist derzeit leer."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Den Physiotherapeuten archivieren"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archiviert"),
        "practitionerList_archivedOn": m43,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Einen Behandler anlegen"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm wird die Liste der registrierten Ärzte angezeigt."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("Liste der Ärzte"),
        "practitionerList_edit":
            MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "practitionerList_error": m44,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Es sind keine Physiotherapeuten archiviert"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "Es ist kein Physiotherapeut registriert"),
        "practitionerList_professionalId": m45,
        "practitionerList_restore":
            MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
        "practitionerList_showQrCode":
            MessageLookupByLibrary.simpleMessage("QR-Code anzeigen"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Liste der Ärzte"),
        "practitionerNew_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "practitionerNew_cet_ecran_permet":
            MessageLookupByLibrary.simpleMessage(
                "Auf diesem Bildschirm können Sie einen Behandler anlegen."),
        "practitionerNew_create":
            MessageLookupByLibrary.simpleMessage("Erstellen"),
        "practitionerNew_displayName":
            MessageLookupByLibrary.simpleMessage("Angezeigter Name"),
        "practitionerNew_displayNameRequired":
            MessageLookupByLibrary.simpleMessage(
                "Die Angabe des Namens ist erforderlich"),
        "practitionerNew_editPractitioner":
            MessageLookupByLibrary.simpleMessage("Behandler ändern"),
        "practitionerNew_email": MessageLookupByLibrary.simpleMessage("E-Mail"),
        "practitionerNew_firstName":
            MessageLookupByLibrary.simpleMessage("Vorname"),
        "practitionerNew_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie den Eintrag eines Behandlers anlegen oder bearbeiten.\n\nDie Angabe des Namens ist obligatorisch: Er dient zur Identifizierung des Behandlers in Companion. Sie können außerdem den Vornamen, den Nachnamen, die berufliche Kennnummer, die E-Mail-Adresse und die Telefonnummer eingeben.\n\nKlicken Sie auf „Erstellen“, um einen Arzt hinzuzufügen, oder auf „Speichern“, um die Änderungen an einem bestehenden Datensatz zu übernehmen.\n\n„Abbrechen“ schließt das Fenster, ohne die Änderungen zu übernehmen. Beim Öffnen und Schließen dieser Hilfe bleiben Ihre Eingaben im Formular erhalten."),
        "practitionerNew_lastName":
            MessageLookupByLibrary.simpleMessage("Name"),
        "practitionerNew_newPractitioner":
            MessageLookupByLibrary.simpleMessage("Neuer Behandler"),
        "practitionerNew_phone":
            MessageLookupByLibrary.simpleMessage("Telefon"),
        "practitionerNew_professionalId":
            MessageLookupByLibrary.simpleMessage("Berufliche Kennung"),
        "practitionerNew_professionalIdHint":
            MessageLookupByLibrary.simpleMessage("RPPS, ADELI…"),
        "practitionerNew_save":
            MessageLookupByLibrary.simpleMessage("Speichern"),
        "practitionerQr_close":
            MessageLookupByLibrary.simpleMessage("Schließen"),
        "practitionerQr_defaultOrganizationName":
            MessageLookupByLibrary.simpleMessage("Kanzlei"),
        "practitionerQr_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster wird der QR-Code des Berufsprofils des Behandlers zusammen mit dessen Namen und dem Namen der Praxis angezeigt.\n\nScannen Sie diesen QR-Code mit ABAK Mobile, um den Behandler in dieser Einrichtung zu identifizieren. Vergewissern Sie sich, dass der angezeigte Name mit dem betreffenden Behandler übereinstimmt.\n\nDieser QR-Code dient zur Übermittlung der Identifikationsdaten des Berufsprofils; seine Anzeige löst keine Übertragung von Ergebnissen aus.\n\nSchließen Sie dieses Fenster, um zur Liste der Ärzte zurückzukehren."),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("ABAK-Berufsprofil"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Scannen Sie diesen QR-Code mit ABAK Mobile, um dieses Berufsprofil automatisch hinzuzufügen."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("archiviert"),
        "practitionerSelector_error": m46,
        "practitionerSelector_noSelection":
            MessageLookupByLibrary.simpleMessage("Keine Auswahl"),
        "preferences_archivedPatients":
            MessageLookupByLibrary.simpleMessage("Archivierte Patienten"),
        "preferences_contextComment": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm werden die allgemeinen Einstellungen von Companion zusammengefasst."),
        "preferences_contextName":
            MessageLookupByLibrary.simpleMessage("Benutzereinstellungen"),
        "preferences_days": MessageLookupByLibrary.simpleMessage("Tage"),
        "preferences_expertMode":
            MessageLookupByLibrary.simpleMessage("Mode-Experte"),
        "preferences_expertModeDescription": MessageLookupByLibrary.simpleMessage(
            "Zeigt technische Informationen für Entwickler und Mitwirkende an."),
        "preferences_expertModeSaved": MessageLookupByLibrary.simpleMessage(
            "Einstellung des Expertenmodus gespeichert."),
        "preferences_languageSaved":
            MessageLookupByLibrary.simpleMessage("Gespeicherte Sprache."),
        "preferences_organization":
            MessageLookupByLibrary.simpleMessage("Einrichtung"),
        "preferences_organizationDescription":
            MessageLookupByLibrary.simpleMessage(
                "Name, Logo und allgemeine Informationen."),
        "preferences_retentionDuration":
            MessageLookupByLibrary.simpleMessage("Haltbarkeit"),
        "preferences_retentionExplanation": MessageLookupByLibrary.simpleMessage(
            "Archivierte Patienten können während dieses Zeitraums wiederhergestellt werden. Danach werden sie automatisch gelöscht."),
        "preferences_retentionSaved": MessageLookupByLibrary.simpleMessage(
            "Angegebene Haltbarkeitsdauer."),
        "recentImportCard_conflict":
            MessageLookupByLibrary.simpleMessage("Konflikt"),
        "recentImportCard_error":
            MessageLookupByLibrary.simpleMessage("Fehler"),
        "recentImportCard_fichier":
            MessageLookupByLibrary.simpleMessage("Datei"),
        "recentImportCard_file": MessageLookupByLibrary.simpleMessage("Datei"),
        "recentImportCard_ignored":
            MessageLookupByLibrary.simpleMessage("ignoriert"),
        "recentImportCard_no_result_imported":
            MessageLookupByLibrary.simpleMessage(
                "Es wurden keine Ergebnisse importiert"),
        "recentImportCard_result":
            MessageLookupByLibrary.simpleMessage("Ergebnis"),
        "referringPractitionerHistoryDialog_archivedPractitioner": m47,
        "referringPractitionerHistoryDialog_close":
            MessageLookupByLibrary.simpleMessage("Schließen"),
        "referringPractitionerHistoryDialog_currentPractitioner":
            MessageLookupByLibrary.simpleMessage("Derzeitiger Ansprechpartner"),
        "referringPractitionerHistoryDialog_fromTo": m48,
        "referringPractitionerHistoryDialog_loadHistoryError": m49,
        "referringPractitionerHistoryDialog_noHistory":
            MessageLookupByLibrary.simpleMessage(
                "Für diesen Fall wurde noch kein zuständiger Physiotherapeut registriert."),
        "referringPractitionerHistoryDialog_since": m50,
        "referringPractitionerHistory_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster werden die Ärzte angezeigt, die als Ansprechpartner für diesen Behandlungsverlauf benannt wurden.\n\nJede Zeile enthält den Namen des Arztes und seinen Einsatzzeitraum. Der Vermerk „Aktueller Ansprechpartner“ kennzeichnet den Arzt, der derzeit diesem Behandlungsverlauf zugeordnet ist.\n\nDer Vermerk „Archiviert“ bedeutet, dass der Datensatz des Arztes archiviert wurde; sein Name bleibt im Verlauf sichtbar.\n\nIn diesem Fenster können Sie ausschließlich den Verlauf einsehen. Schließen Sie es, um zur Behandlungsphase zurückzukehren."),
        "referringPractitionerHistory_title":
            MessageLookupByLibrary.simpleMessage(
                "Übersicht über die zuständigen Physiotherapeuten"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Dashboard aktualisieren"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Berichtsarchiv"),
        "reportDraft_help": MessageLookupByLibrary.simpleMessage(
            "Der angezeigte Text entspricht einem automatisch gespeicherten Entwurf. Sie können ihn beibehalten, bearbeiten oder löschen, bevor Sie Ihren Bericht speichern."),
        "reportDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Den Berichtsentwurf verstehen"),
        "reportHistory_help": MessageLookupByLibrary.simpleMessage(
            "Diese Ansicht zeigt die für die Betreuung gespeicherten Berichte mit ihrem Titel und ihrem Datum an.\n\nÜber die Aktionen in jeder Zeile können Sie einen Bericht bearbeiten, duplizieren oder in die archivierten Dokumente verschieben.\n\nWenn ein Bericht zur Bearbeitung geöffnet ist, verwenden Sie die Aktion „Aktualisieren“, um Ihre Änderungen zu speichern. Mit den verfügbaren Befehlen können Sie außerdem die Änderungen rückgängig machen oder zum Entwurf zurückkehren.\n\nDas Verschieben in die archivierten Dokumente ist keine endgültige Löschung.\n\nKlicken Sie auf das Kreuz, um die vergrößerte Ansicht zu schließen und zum Bereich „Bilanzen/Berichte“ zurückzukehren."),
        "reset": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
        "resultDetail_addCommentHint":
            MessageLookupByLibrary.simpleMessage("Kommentar hinzufügen..."),
        "resultDetail_archiveConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Möchten Sie dieses Ergebnis wirklich archivieren?"),
        "resultDetail_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Ergebnis archivieren"),
        "resultDetail_birthDate":
            MessageLookupByLibrary.simpleMessage("Geburt"),
        "resultDetail_cancel": MessageLookupByLibrary.simpleMessage("Gerät"),
        "resultDetail_clinicalComment":
            MessageLookupByLibrary.simpleMessage("Klinischer Kommentar"),
        "resultDetail_commentSaved":
            MessageLookupByLibrary.simpleMessage("Kommentar gespeichert"),
        "resultDetail_detailedResult":
            MessageLookupByLibrary.simpleMessage("Detailliertes Ergebnis"),
        "resultDetail_device":
            MessageLookupByLibrary.simpleMessage("Gerätedetails"),
        "resultDetail_exerciseDate":
            MessageLookupByLibrary.simpleMessage("Datum des Geschäftsjahres"),
        "resultDetail_generalInformation":
            MessageLookupByLibrary.simpleMessage("Allgemeine Informationen"),
        "resultDetail_help": MessageLookupByLibrary.simpleMessage(
            "Dieser Bildschirm zeigt die Informationen zu einem aus ABAK Mobile importierten Ergebnis an: Patient, Durchführungsdatum, Wert sowie – sofern verfügbar – verwendete Hilfsmittel, Identität des Behandlers und Ursprungsgerät.\n\nSie können den detaillierten Bericht und die zusätzlichen Messwerte einsehen, die im Rahmen der Untersuchung übermittelt wurden.\n\nIm Feld „Klinischer Kommentar“ können Sie Ihre Anmerkungen hinzufügen oder bearbeiten. Klicken Sie auf „Speichern“, um diese zu sichern, bevor Sie den Bildschirm verlassen.\n\nDer Bereich „Import“ zeigt den Synchronisationsstatus und das Datum der letzten Änderung des Ergebnisses an.\n\nÜber das Archivierungssymbol können Sie dieses Ergebnis nach der Bestätigung archivieren."),
        "resultDetail_identityUnverified":
            MessageLookupByLibrary.simpleMessage("Identität nicht verifiziert"),
        "resultDetail_identityVerified":
            MessageLookupByLibrary.simpleMessage("Identität überprüft"),
        "resultDetail_import":
            MessageLookupByLibrary.simpleMessage("Importieren"),
        "resultDetail_lastModified":
            MessageLookupByLibrary.simpleMessage("Letzte Änderung"),
        "resultDetail_metrics":
            MessageLookupByLibrary.simpleMessage("Metriken"),
        "resultDetail_noMetrics": MessageLookupByLibrary.simpleMessage(
            "Es wurden keine Kennzahlen erfasst."),
        "resultDetail_patient": MessageLookupByLibrary.simpleMessage("Patient"),
        "resultDetail_performedBy":
            MessageLookupByLibrary.simpleMessage("Regie:"),
        "resultDetail_save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "resultDetail_score": MessageLookupByLibrary.simpleMessage("Ergebnis"),
        "resultDetail_syncState":
            MessageLookupByLibrary.simpleMessage("Synchronisationsstatus"),
        "settings_assistanceWarning": MessageLookupByLibrary.simpleMessage(
            "Diese Funktionen sind für die Installation, die Fehlerdiagnose und den technischen Support vorgesehen.\n\nVerwenden Sie sie nur, wenn Sie von einem Techniker oder gemäß der ABAK-Dokumentation dazu aufgefordert werden."),
        "settings_cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "settings_configuration":
            MessageLookupByLibrary.simpleMessage("Konfiguration"),
        "settings_confirmationRequired":
            MessageLookupByLibrary.simpleMessage("Bestätigung erforderlich"),
        "settings_contextComment": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm sind die Funktionen für Installation, Diagnose und Wartung von Companion zusammengefasst."),
        "settings_contextName": MessageLookupByLibrary.simpleMessage("Hilfe"),
        "settings_continue": MessageLookupByLibrary.simpleMessage("Weiter"),
        "settings_databaseResetError": m51,
        "settings_databaseResetSuccess": MessageLookupByLibrary.simpleMessage(
            "Datenbank zurückgesetzt. Automatisches Backup erstellt."),
        "settings_diagnostic": MessageLookupByLibrary.simpleMessage("Diagnose"),
        "settings_edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "settings_exchangeDirectory":
            MessageLookupByLibrary.simpleMessage("ABAK-Austauschmappe"),
        "settings_exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Austauschordner zurückgesetzt"),
        "settings_exchangeDirectoryUpdated":
            MessageLookupByLibrary.simpleMessage(
                "Aktualisierte ABAK-Austauschdatei"),
        "settings_exportAction":
            MessageLookupByLibrary.simpleMessage("Exportieren"),
        "settings_exportCancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "settings_exportCancelled":
            MessageLookupByLibrary.simpleMessage("Export abgebrochen"),
        "settings_exportChooseDestination":
            MessageLookupByLibrary.simpleMessage("Zielordner auswählen"),
        "settings_exportCompleted": m52,
        "settings_exportCompletedWithErrors": m53,
        "settings_exportDataDescription": MessageLookupByLibrary.simpleMessage(
            "Es wird ein Archiv angelegt, das die Daten Ihrer Patienten sowie deren Befunde und Berichte enthält."),
        "settings_exportFailed": MessageLookupByLibrary.simpleMessage(
            "Die Daten können nicht exportiert werden"),
        "settings_exportIncludeArchivedPatients":
            MessageLookupByLibrary.simpleMessage(
                "Archivierte Patienten einbeziehen"),
        "settings_exportMyData":
            MessageLookupByLibrary.simpleMessage("Meine Daten exportieren"),
        "settings_exportPatientBirthDate":
            MessageLookupByLibrary.simpleMessage("Geburtsdatum"),
        "settings_exportPatientFemale":
            MessageLookupByLibrary.simpleMessage("Weiblich"),
        "settings_exportPatientFirstName":
            MessageLookupByLibrary.simpleMessage("Vorname"),
        "settings_exportPatientLastName":
            MessageLookupByLibrary.simpleMessage("Name"),
        "settings_exportPatientMale":
            MessageLookupByLibrary.simpleMessage("Männlich"),
        "settings_exportPatientSex":
            MessageLookupByLibrary.simpleMessage("Sex"),
        "settings_exportPatientUnknown":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "settings_exportPatientUnknownFemale":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "settings_help": MessageLookupByLibrary.simpleMessage(
            "Dieser Bildschirm fasst die Funktionen für Installation, Diagnose und Wartung von Companion zusammen. Verwenden Sie diese gemäß den Anweisungen in der ABAK-Dokumentation oder den Anweisungen eines Technikers.\n\nÜber den Menüpunkt „Konfiguration“ können Sie den für den Dateiaustausch verwendeten Ordner anzeigen, öffnen oder ändern.\n\nÜber den Bereich „Diagnose“ können Sie Überprüfungen des Lesegeräts für die Vitale-Karte durchführen.\n\nIm Bereich „Wartung“ können Sie den Assistenten zur Behebung von Importproblemen öffnen, eine ABAK-Datei manuell importieren und auf die Verwaltung der Sicherungskopien zugreifen.\n\nDurch das Zurücksetzen der Datenbank werden die lokalen Daten gelöscht. Dieser Vorgang ist ausschließlich für den technischen Support vorgesehen: Lesen Sie die Bestätigungsmeldungen sorgfältig durch, bevor Sie fortfahren."),
        "settings_importAbakFile": MessageLookupByLibrary.simpleMessage(
            "Eine .abak-Datei manuell importieren"),
        "settings_invalidConfirmation":
            MessageLookupByLibrary.simpleMessage("Ungültige Bestätigung."),
        "settings_loading":
            MessageLookupByLibrary.simpleMessage("Wird geladen..."),
        "settings_maintenance": MessageLookupByLibrary.simpleMessage("Wartung"),
        "settings_manageBackups":
            MessageLookupByLibrary.simpleMessage("Backups verwalten"),
        "settings_noDirectoryDefined": MessageLookupByLibrary.simpleMessage(
            "Es wurde kein Ordner festgelegt"),
        "settings_open": MessageLookupByLibrary.simpleMessage("Öffnen"),
        "settings_openingExchangeDirectory":
            MessageLookupByLibrary.simpleMessage(
                "Eröffnung des Austauschverfahrens"),
        "settings_reset": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
        "settings_resetDatabase": MessageLookupByLibrary.simpleMessage(
            "Die Basisstation zurücksetzen"),
        "settings_resetDatabaseTitle": MessageLookupByLibrary.simpleMessage(
            "Lokale Datenbank zurücksetzen?"),
        "settings_resetDatabaseWarning": MessageLookupByLibrary.simpleMessage(
            "Durch diesen Vorgang werden alle lokalen Daten (Patienten, Ergebnisse, Importe und Verlaufsdaten) gelöscht.\n\nVor dem Zurücksetzen wird automatisch eine Sicherungskopie erstellt.\n\nVerwenden Sie diese Funktion ausschließlich im Rahmen eines technischen Supportvorgangs."),
        "settings_resetKeyword": MessageLookupByLibrary.simpleMessage("RESET"),
        "settings_resetTooltip":
            MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
        "settings_resolveImportProblem":
            MessageLookupByLibrary.simpleMessage("Ein Importproblem beheben"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Hilfe"),
        "settings_typeResetConfirmation": MessageLookupByLibrary.simpleMessage(
            "Geben Sie „RESET“ ein, um den Vorgang endgültig zu bestätigen."),
        "settings_vitaleDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnose „Carte Vitale“"),
        "smartCardDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnose „Carte Vitale“"),
        "speechDictationButton_audio": MessageLookupByLibrary.simpleMessage(
            "Es ist keine Audioaufnahme verfügbar."),
        "speechDictationButton_close":
            MessageLookupByLibrary.simpleMessage("Schließen"),
        "speechDictationButton_dictate":
            MessageLookupByLibrary.simpleMessage("Wut"),
        "speechDictationButton_download":
            MessageLookupByLibrary.simpleMessage("Modul herunterladen"),
        "speechDictationButton_failure": m54,
        "speechDictationButton_information": MessageLookupByLibrary.simpleMessage(
            "Für die Sprachsteuerung muss das optionale Modul „ABAK Sprachsteuerung“ installiert werden.\n\nDieses Modul ist kostenlos und läuft lokal auf Ihrem Computer, ohne dass die Sprachaufnahmen ins Internet gesendet werden.\n\nDie Downloadgröße beträgt etwa 1,5 GB."),
        "speechDictationButton_stop":
            MessageLookupByLibrary.simpleMessage("Diktat beenden"),
        "speechDictationButton_title":
            MessageLookupByLibrary.simpleMessage("Sprachdiktat"),
        "speechRecordingService_permission":
            MessageLookupByLibrary.simpleMessage(
                "Der Zugriff auf das Mikrofon ist nicht gestattet."),
        "systemOverviewBar_active_patients":
            MessageLookupByLibrary.simpleMessage("Aktive Patienten"),
        "systemOverviewBar_alert":
            MessageLookupByLibrary.simpleMessage("Benachrichtigungen"),
        "systemOverviewBar_archived_patients":
            MessageLookupByLibrary.simpleMessage("Archivierte Patienten"),
        "systemOverviewBar_loading_system_summary":
            MessageLookupByLibrary.simpleMessage(
                "Systemzusammenfassung wird geladen..."),
        "systemOverviewBar_supervision_error":
            MessageLookupByLibrary.simpleMessage("Fehler bei der Überwachung"),
        "systemOverviewBar_supervision_unavailable":
            MessageLookupByLibrary.simpleMessage("Überwachung nicht verfügbar"),
        "systemStatusCard_nome": MessageLookupByLibrary.simpleMessage("Keine"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Benutzereinstellungen"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Benutzereinstellungen"),
        "vitaleBeneficiarySelector_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "vitaleBeneficiarySelector_help": MessageLookupByLibrary.simpleMessage(
            "In diesem Fenster können Sie die betreffende Person auswählen, wenn nach dem Einlesen der Vitale-Karte mehrere Leistungsempfänger vorgeschlagen werden.\n\nÜberprüfen Sie den Nachnamen, den Vornamen und das Geburtsdatum, sofern verfügbar, und klicken Sie anschließend auf die Zeile des gewünschten Leistungsempfängers.\n\nDurch die Auswahl wird dieses Fenster geschlossen und die ausgewählte Person wird an den nächsten Schritt weitergeleitet.\n\nMit „Abbrechen“ wird das Fenster geschlossen, ohne dass ein Begünstigter ausgewählt wird."),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage(
                "Wählen Sie einen Begünstigten aus"),
        "vitaleDiagnostic_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm können Sie die Funktionsfähigkeit des Lesegeräts für die Vitale-Karte überprüfen.\n\nUnter Windows zeigt der Abschnitt zum Modul dessen Status an und ermöglicht es, diese Informationen zu aktualisieren.\n\nStarten Sie einen Lesevorgang, wenn das Lesegerät angeschlossen und die Karte eingelegt ist. Wenn mehrere Begünstigte vorgeschlagen werden, wählen Sie die betreffende Person aus, um die ausgelesenen Informationen einzusehen.\n\nDie angezeigten Meldungen helfen dabei, einen eventuellen Fehler zu verstehen, und können dem Support mitgeteilt werden.\n\nDer Abschnitt „Erweiterte Diagnose“ bietet einen technischen Test zur Kommunikation mit der Karte an. Verwenden Sie diesen gemäß den Anweisungen in der ABAK-Dokumentation oder nach Anleitung eines Technikers.\n\nDieser Bildschirm dient der Diagnose: Durch das Einlesen einer Identität wird kein Patientenstammdatensatz angelegt."),
        "vitaleIdentity_birthDate":
            MessageLookupByLibrary.simpleMessage("Geburtsdatum"),
        "vitaleIdentity_dataMasked":
            MessageLookupByLibrary.simpleMessage("Daten maskiert"),
        "vitaleIdentity_detected":
            MessageLookupByLibrary.simpleMessage("erkannt"),
        "vitaleIdentity_female":
            MessageLookupByLibrary.simpleMessage("Weiblich"),
        "vitaleIdentity_firstName":
            MessageLookupByLibrary.simpleMessage("Vorname"),
        "vitaleIdentity_help": MessageLookupByLibrary.simpleMessage(
            "Auf diesem Bildschirm können Sie die Daten eines Leistungsempfängers von einer Vitale-Karte auslesen, sofern das Lesegerät und das Lesemodul verfügbar sind.\n\nDer Lesevorgang beginnt beim Öffnen des Bildschirms. Sie können ihn über die Lesetaste erneut starten. Sind mehrere Leistungsempfänger auf der Karte gespeichert, wählen Sie die betreffende Person aus.\n\nÜberprüfen Sie den Nachnamen, den Vornamen, das Geburtsdatum und die weiteren angezeigten Informationen. Die Identifikationsnummer wird als „erkannt“ oder „nicht verfügbar“ angezeigt, ohne dass sie vollständig dargestellt wird.\n\nWenn die Identität verwendbar ist, können Sie diese Informationen über die Schaltfläche „Patient anlegen“ an das Anlegeformular übermitteln.\n\nWenn keine Identität verfügbar ist, lesen Sie die angezeigte Meldung und überprüfen Sie das Lesegerät, bevor Sie es erneut versuchen. Sie können zum vorherigen Bildschirm zurückkehren, um eine manuelle Eingabe vorzunehmen."),
        "vitaleIdentity_identityRead":
            MessageLookupByLibrary.simpleMessage("Identität gelesen"),
        "vitaleIdentity_identityReceivedMasked":
            MessageLookupByLibrary.simpleMessage(
                "übermittelte Identitätsdaten (persönliche Daten unkenntlich gemacht)"),
        "vitaleIdentity_identityUnavailable":
            MessageLookupByLibrary.simpleMessage("Identität nicht verfügbar"),
        "vitaleIdentity_lastName": MessageLookupByLibrary.simpleMessage("Name"),
        "vitaleIdentity_male": MessageLookupByLibrary.simpleMessage("Männlich"),
        "vitaleIdentity_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "vitaleIdentity_noIdentityAvailable":
            MessageLookupByLibrary.simpleMessage(
                "Es ist keine „Carte Vitale“-Identität verfügbar"),
        "vitaleIdentity_notProvided":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "vitaleIdentity_other":
            MessageLookupByLibrary.simpleMessage("Sonstiges"),
        "vitaleIdentity_reading":
            MessageLookupByLibrary.simpleMessage("Wird gerade gelesen..."),
        "vitaleIdentity_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "vitaleIdentity_source": MessageLookupByLibrary.simpleMessage("Quelle"),
        "vitaleIdentity_title": MessageLookupByLibrary.simpleMessage(
            "Identität der Carte Vitale auslesen"),
        "vitaleIdentity_unavailable":
            MessageLookupByLibrary.simpleMessage("Nicht verfügbar"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Zum Anlegen eines Patienten verwenden"),
        "walkingAid_cane": MessageLookupByLibrary.simpleMessage("Stock"),
        "walkingAid_label":
            MessageLookupByLibrary.simpleMessage("Verwendete Hilfe"),
        "walkingAid_none": MessageLookupByLibrary.simpleMessage("Keine"),
        "walkingAid_other": MessageLookupByLibrary.simpleMessage("Sonstiges"),
        "walkingAid_rollatorFourWheels":
            MessageLookupByLibrary.simpleMessage("4-Rad-Rollator"),
        "walkingAid_walkerTwoWheels":
            MessageLookupByLibrary.simpleMessage("Zweirädriger Rollator")
      };
}
