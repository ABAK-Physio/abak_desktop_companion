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

  static String m0(size) => "${size}";

  static String m1(deviceName) =>
      "Möchten Sie ${deviceName} wirklich archivieren?";

  static String m2(error) => "Fehler beim Speichern: ${error}";

  static String m3(count) => "${count} andere Geschäftsjahre";

  static String m4(count) => "${count} Verein(e) in der Warteschlange";

  static String m5(count) => "${count} Sicherungen";

  static String m6(size) => "Größe: ${size}";

  static String m7(size) => "Gesamtgröße: ${size}";

  static String m8(version) => "Version ${version}";

  static String m9(patientName) =>
      "Möchten Sie ${patientName} wirklich archivieren? Er wird dann nicht mehr in der aktiven Liste angezeigt.";

  static String m10(patientName) => "${patientName} wurde archiviert.";

  static String m11(error) => "Fehler: ${error}";

  static String m12(patientName) =>
      "${patientName} wurde wieder in die aktive Liste aufgenommen.";

  static String m13(practitionerName) =>
      "Möchten Sie ${practitionerName} wirklich archivieren?";

  static String m14(date) => "Archiviert am ${date}";

  static String m15(error) => "Fehler: ${error}";

  static String m16(professionalId) => "ID pro: ${professionalId}";

  static String m17(error) => "Fehler: ${error}";

  static String m18(error) => "Fehler beim Zurücksetzen: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "backupHistory_cancel":
            MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "Es wurde kein Backup gespeichert."),
        "backupHistory_fileSize": m0,
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
        "backupHistory_restoreTitle": MessageLookupByLibrary.simpleMessage(
            "Diese Sicherung wiederherstellen?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Dieser Vorgang wird die aktuelle Datenbank vollständig ersetzen.\n\nVor der Wiederherstellung wird automatisch eine Sicherheitskopie erstellt.\n\nWeiter?"),
        "backupHistory_title":
            MessageLookupByLibrary.simpleMessage("Sicherungshistorie"),
        "close": MessageLookupByLibrary.simpleMessage("Schließen"),
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
        "deviceList_archiveConfirmation": m1,
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
        "exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Austauschordner zurückgesetzt"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Aktualisierte ABAK-Austauschdatei"),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Vorwahl ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Schließen"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Kommentar"),
        "g_context": MessageLookupByLibrary.simpleMessage("Hintergrund"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Kopieren"),
        "g_file": MessageLookupByLibrary.simpleMessage("Datei"),
        "g_learn_more": MessageLookupByLibrary.simpleMessage("Mehr erfahren"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Technische Informationen"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Technische Informationen kopiert"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Archivierte Patienten können bis zu dem angegebenen Datum wiederhergestellt werden.\nNach diesem Datum werden sie automatisch gelöscht, damit nicht ungenutzte Datensätze auf unbestimmte Zeit gespeichert bleiben.\nDie Aufbewahrungsdauer kann in den Einstellungen von Companion geändert werden."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "Sie können ein Gerät anlegen, bearbeiten oder archivieren.\n\nAus Gründen der Nachverfolgbarkeit ist es nicht möglich, ein Gerät zu löschen.\nBei Bedarf können Sie es wiederherstellen.\n\nDer QR-Code dient dazu, ein Smartphone oder Tablet zu koppeln."),
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
            "Hier finden Sie die verschiedenen Behandlungen Ihres Patienten. Sie können eine bereits vorhandene Behandlung verwenden oder eine neue anlegen."),
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
        "home_create_a_backup":
            MessageLookupByLibrary.simpleMessage("Sicherung erstellen"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Datum nicht angegeben"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Geräte"),
        "home_error_while_saving": m2,
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
        "home_other_exercises": m3,
        "home_parameters":
            MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Pfad"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patient ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patienten"),
        "home_pending_association": m4,
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
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("Datei"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("Dateien"),
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
        "information_backupCount": m5,
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
        "information_language": MessageLookupByLibrary.simpleMessage("Sprache"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Rechtlicher Hinweis"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Wird geladen..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Lokale Speicherung"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Nicht konfiguriert"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Keine Angabe"),
        "information_office": MessageLookupByLibrary.simpleMessage("Kanzlei"),
        "information_size": m6,
        "information_system": MessageLookupByLibrary.simpleMessage("System"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Informationen"),
        "information_totalSize": m7,
        "information_version": m8,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Version..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("Lizenz einsehen"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Gespeicherte Sprache."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Sprache der Anwendung"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Hinweis"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion ist eine Software, die bei der Organisation, dem Import und der Einsichtnahme in klinische Ergebnisse aus dem ABAK-Ökosystem unterstützt.\n\nSie stellt kein zertifiziertes Medizinprodukt dar und ersetzt nicht die Beurteilung durch medizinisches Fachpersonal.\n\nDie angezeigten Ergebnisse, Werte, Berichte und Indikatoren müssen stets von einer qualifizierten Fachkraft unter Berücksichtigung der klinischen Untersuchung, der Situation des Patienten und der geltenden Empfehlungen interpretiert werden.\n\nDer Nutzer bleibt allein verantwortlich für seine klinischen Entscheidungen, die Überprüfung der importierten Daten und die Übereinstimmung ihrer Verwendung mit den geltenden beruflichen, behördlichen und ethischen Vorschriften.\n\nABAK Desktop Companion stellt keine eigenständige Diagnose, verschreibt keine Behandlung und ersetzt in keinem Fall eine ärztliche oder paramedizinische Konsultation."),
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
        "organization_identityTitle":
            MessageLookupByLibrary.simpleMessage("Identität der Einrichtung"),
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
        "patientList_active":
            MessageLookupByLibrary.simpleMessage("Vermögenswerte"),
        "patientList_archive":
            MessageLookupByLibrary.simpleMessage("Archivieren"),
        "patientList_archiveConfirmation": m9,
        "patientList_archiveSuccess": m10,
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
        "patientList_error": m11,
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
        "patientList_restoreSuccess": m12,
        "patientList_searchPatient":
            MessageLookupByLibrary.simpleMessage("Einen Patienten suchen"),
        "patientList_sex": MessageLookupByLibrary.simpleMessage("Sex"),
        "patientList_title":
            MessageLookupByLibrary.simpleMessage("Patientenliste"),
        "practitionerList_active":
            MessageLookupByLibrary.simpleMessage("Vermögenswerte"),
        "practitionerList_addPractitionersHint":
            MessageLookupByLibrary.simpleMessage(
                "Fügen Sie die Physiotherapeuten der Praxis hinzu, um die importierten Tests zu identifizieren."),
        "practitionerList_archive":
            MessageLookupByLibrary.simpleMessage("Archivieren"),
        "practitionerList_archiveConfirmation": m13,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "Der Papierkorb der Physiotherapeuten ist derzeit leer."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Den Physiotherapeuten archivieren"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archiviert"),
        "practitionerList_archivedOn": m14,
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
        "practitionerList_error": m15,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Es sind keine Physiotherapeuten archiviert"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "Es ist kein Physiotherapeut registriert"),
        "practitionerList_professionalId": m16,
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
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("ABAK-Berufsprofil"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Scannen Sie diesen QR-Code mit ABAK Mobile, um dieses Berufsprofil automatisch hinzuzufügen."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("archiviert"),
        "practitionerSelector_error": m17,
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
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Dashboard aktualisieren"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Berichtsarchiv"),
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
        "settings_databaseResetError": m18,
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
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage(
                "Wählen Sie einen Begünstigten aus"),
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
            MessageLookupByLibrary.simpleMessage("nicht verfügbar"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Zum Anlegen eines Patienten verwenden")
      };
}
