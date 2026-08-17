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

  static String m0(error) => "Fehler beim Speichern: ${error}";

  static String m1(count) => "${count} andere Geschäftsjahre";

  static String m2(count) => "${count} Verein(e) in der Warteschlange";

  static String m3(error) => "Fehler: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "close": MessageLookupByLibrary.simpleMessage("Schließen"),
        "dashboardTitle":
            MessageLookupByLibrary.simpleMessage("Lokale ABAK-Klinikstation"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Adresse"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Hafen"),
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
        "home_error_while_saving": m0,
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
        "home_other_exercises": m1,
        "home_parameters":
            MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Pfad"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patient ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patienten"),
        "home_pending_association": m2,
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
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Gespeicherte Sprache."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Sprache der Anwendung"),
        "loading": MessageLookupByLibrary.simpleMessage("Wird geladen..."),
        "modify": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "noDirectoryDefined": MessageLookupByLibrary.simpleMessage(
            "Es wurde kein Ordner festgelegt"),
        "ok": MessageLookupByLibrary.simpleMessage("Na gut"),
        "open": MessageLookupByLibrary.simpleMessage("Öffnen"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Ein Telefon koppeln"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Ein Telefon koppeln"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scannen Sie diesen QR-Code mit ABAK Mobile, um die Verbindung zum Desktop automatisch einzurichten."),
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Einen Behandler anlegen"),
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
        "practitionerSelector_error": m3,
        "practitionerSelector_noSelection":
            MessageLookupByLibrary.simpleMessage("Keine Auswahl"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Dashboard aktualisieren"),
        "reset": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
        "smartCardDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnose „Carte Vitale“"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Benutzereinstellungen"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Benutzereinstellungen")
      };
}
