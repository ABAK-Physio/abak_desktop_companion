// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it_IT locale. All the
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
  String get localeName => 'it_IT';

  static String m0(error) => "Errore durante il salvataggio: ${error}";

  static String m1(count) => "${count} altro/i esercizio/i";

  static String m2(count) => "${count} associazione/i in attesa";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "close": MessageLookupByLibrary.simpleMessage("Chiudi"),
        "dashboardTitle":
            MessageLookupByLibrary.simpleMessage("Centro clinico locale ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Indirizzo"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Porto"),
        "exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Cartella di scambio ripristinata"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Documentazione di scambio ABAK aggiornata"),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Prefisso ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Chiudi"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Commento"),
        "g_context": MessageLookupByLibrary.simpleMessage("Contesto"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Copia"),
        "g_file": MessageLookupByLibrary.simpleMessage("File"),
        "g_learn_more":
            MessageLookupByLibrary.simpleMessage("Per saperne di più"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Informazioni tecniche"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Informazioni tecniche copiate"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "I pazienti archiviati possono essere ripristinati fino alla data indicata.\nDopo tale data, vengono eliminati automaticamente per evitare di conservare indefinitamente cartelle cliniche inutilizzate.\nIl periodo di conservazione può essere modificato nelle impostazioni di Companion."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "È possibile creare, modificare e archiviare un dispositivo.\n\nPer motivi di tracciabilità non è possibile eliminare un dispositivo\nSe necessario, è possibile ripristinarlo.\n\nIl codice QR viene utilizzato per accoppiare un telefono o un tablet."),
        "help_device_list_title":
            MessageLookupByLibrary.simpleMessage("Elenco dei dispositivi"),
        "help_donnees_cliniques_patient": MessageLookupByLibrary.simpleMessage(
            "Qui troverete ulteriori informazioni relative al vostro paziente"),
        "help_home": MessageLookupByLibrary.simpleMessage(
            "Questa schermata è la schermata principale di ABAK Companion.\n\nÈ composta da:\n\n1) una barra superiore che fornisce informazioni su:\n - il numero di pazienti attivi e archiviati.\n  - il numero di avvisi in corso.\n\nNelle impostazioni è possibile inserire il nome della propria struttura e aggiungere il proprio logo.\n\n2) \"Importazioni recenti\" mostra le ultime cartelle dei risultati importate da ABAK Mobile.\n\n3) \"Stato del sistema\" segnala eventuali problemi e la data dell\'ultimo salvataggio.\n\n4) \"Nuovi risultati ABAK da associare\" mostra i risultati inviati da ABAK Mobile ma non ancora assegnati a un paziente in ABAK Companion.\n\n5) \"Avviso di sistema\" fornisce informazioni sulla natura di un eventuale problema.\n\n6) \"Azione rapida\" consente di accedere alla cronologia di tutte le importazioni effettuate e di creare un nuovo salvataggio."),
        "help_home_active_archived_patients_content":
            MessageLookupByLibrary.simpleMessage("I pazienti attivi"),
        "help_home_active_archived_patients_title":
            MessageLookupByLibrary.simpleMessage(
                "Pazienti attivi e archiviati"),
        "help_home_import_assignment_content":
            MessageLookupByLibrary.simpleMessage(
                "Una volta completato l\'esercizio su ABAK Mobile..."),
        "help_home_import_assignment_title":
            MessageLookupByLibrary.simpleMessage(
                "Recupero di un risultato e attribuzione a un paziente"),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Qui trovate i dati identificativi del vostro paziente"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di:\n - Selezionare la lingua.\n - Impostare il periodo di conservazione delle cartelle cliniche archiviate.\n - Attivare la modalità esperto.\n - Accedere alla schermata \"Struttura\" per inserire il nome della propria struttura e il relativo logo"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di aggiungere un nuovo operatore sanitario e di modificare le informazioni che lo riguardano.\n\nSpostando l\'operatore nel cestino non lo si elimina. Per motivi di tracciabilità non è possibile eliminare un operatore sanitario.\n\nLa visualizzazione del codice QR consente di creare automaticamente il profilo dell\'operatore sanitario per la vostra struttura sul suo telefono o tablet."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Qui troverete le diverse cure del vostro paziente\\Potete utilizzare un episodio esistente\\Potete crearne uno nuovo"),
        "home_abak_exercice":
            MessageLookupByLibrary.simpleMessage("Esercizio ABAK"),
        "home_abak_file": MessageLookupByLibrary.simpleMessage("File ABAK"),
        "home_accueil": MessageLookupByLibrary.simpleMessage("Home"),
        "home_action_required": MessageLookupByLibrary.simpleMessage(
            "Azione richiesta: associare questa cartella clinica a un paziente."),
        "home_already_imported":
            MessageLookupByLibrary.simpleMessage("Già importato"),
        "home_an_intervention_is_necessary":
            MessageLookupByLibrary.simpleMessage("È necessario un intervento"),
        "home_archives": MessageLookupByLibrary.simpleMessage("Archivi"),
        "home_attention": MessageLookupByLibrary.simpleMessage("Attenzione"),
        "home_backup_successfully_created":
            MessageLookupByLibrary.simpleMessage(
                "Il backup è stato creato con successo."),
        "home_balance_sheet_date":
            MessageLookupByLibrary.simpleMessage("Data del bilancio"),
        "home_conflict_detected":
            MessageLookupByLibrary.simpleMessage("Conflitto rilevato"),
        "home_create_a_backup":
            MessageLookupByLibrary.simpleMessage("Creare un backup"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Data non specificata"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Apparecchi"),
        "home_error_while_saving": m0,
        "home_everything_is_working_normally":
            MessageLookupByLibrary.simpleMessage("Tutto funziona normalmente"),
        "home_expert_comment": MessageLookupByLibrary.simpleMessage(
            "Questa schermata è la schermata principale di Companion."),
        "home_failure": MessageLookupByLibrary.simpleMessage("Fallimento"),
        "home_fermer": MessageLookupByLibrary.simpleMessage("Chiudi"),
        "home_file": MessageLookupByLibrary.simpleMessage("File"),
        "home_historique": MessageLookupByLibrary.simpleMessage("Cronologia"),
        "home_home": MessageLookupByLibrary.simpleMessage("Home"),
        "home_import_history": MessageLookupByLibrary.simpleMessage(
            "Cronologia delle importazioni"),
        "home_imports_interrupted_or_in_progress":
            MessageLookupByLibrary.simpleMessage(
                "Importazioni interrotte o in corso"),
        "home_imports_with_errors":
            MessageLookupByLibrary.simpleMessage("Importazioni errate"),
        "home_information":
            MessageLookupByLibrary.simpleMessage("Informazioni"),
        "home_invalid_file_path": MessageLookupByLibrary.simpleMessage(
            "Percorso del file non valido:"),
        "home_ipAddressNotFound":
            MessageLookupByLibrary.simpleMessage("Indirizzo IP non trovato"),
        "home_ipAddressNotFoundMessage": MessageLookupByLibrary.simpleMessage(
            "Impossibile determinare l\'indirizzo IP locale del Desktop.\n\nVerificare che il computer sia connesso alla rete locale."),
        "home_large_number_of_archived_patients":
            MessageLookupByLibrary.simpleMessage(
                "Numero elevato di pazienti archiviati"),
        "home_large_sqlite_database": MessageLookupByLibrary.simpleMessage(
            "Database SQLite di grandi dimensioni"),
        "home_last_backup":
            MessageLookupByLibrary.simpleMessage("Ultimo salvataggio"),
        "home_last_old_backup":
            MessageLookupByLibrary.simpleMessage("Ultimo backup precedente"),
        "home_link_to_a_care_plan": MessageLookupByLibrary.simpleMessage(
            "Associare a un percorso di cura"),
        "home_more_7_days":
            MessageLookupByLibrary.simpleMessage("Più di 7 giorni"),
        "home_new_abak_results_to_be_linked":
            MessageLookupByLibrary.simpleMessage(
                "Nuovi risultati ABAK da associare a un paziente"),
        "home_no_abak_result_to_associate":
            MessageLookupByLibrary.simpleMessage(
                "Nessun risultato ABAK da associare."),
        "home_no_alert_detected":
            MessageLookupByLibrary.simpleMessage("Nessun allarme rilevato"),
        "home_no_imports_recorded": MessageLookupByLibrary.simpleMessage(
            "Nessuna importazione registrata."),
        "home_no_pending_imports": MessageLookupByLibrary.simpleMessage(
            "Nessuna importazione in sospeso"),
        "home_no_saved_backup":
            MessageLookupByLibrary.simpleMessage("Nessun backup salvato"),
        "home_not_specified": MessageLookupByLibrary.simpleMessage("informata"),
        "home_octets": MessageLookupByLibrary.simpleMessage("Ottetti"),
        "home_other_exercises": m1,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Impostazioni"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Percorso"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Paziente ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Pazienti"),
        "home_pending_association": m2,
        "home_practitioners":
            MessageLookupByLibrary.simpleMessage("professionisti"),
        "home_quick_actions":
            MessageLookupByLibrary.simpleMessage("Azioni rapide"),
        "home_receents_imports":
            MessageLookupByLibrary.simpleMessage("Importazioni recenti"),
        "home_recent_restoration_detected":
            MessageLookupByLibrary.simpleMessage(
                "È stato rilevato un recente intervento di restauro"),
        "home_results": MessageLookupByLibrary.simpleMessage("Risultati"),
        "home_select_qr_code": MessageLookupByLibrary.simpleMessage(
            "Scansiona questo codice QR da ABAK Mobile per configurare automaticamente la connessione al Desktop."),
        "home_settings": MessageLookupByLibrary.simpleMessage("Assistenza"),
        "home_size": MessageLookupByLibrary.simpleMessage("Dimensioni"),
        "home_solve": MessageLookupByLibrary.simpleMessage("Risolvere"),
        "home_success": MessageLookupByLibrary.simpleMessage("Successo"),
        "home_system_alert":
            MessageLookupByLibrary.simpleMessage("Avviso di sistema"),
        "home_system_status":
            MessageLookupByLibrary.simpleMessage("Stato del sistema"),
        "home_technical_information":
            MessageLookupByLibrary.simpleMessage("Informazioni tecniche"),
        "home_this_file_had_already_been_imported":
            MessageLookupByLibrary.simpleMessage(
                "Questo file era già stato importato. Non sono stati aggiunti dati."),
        "home_to_be_verified":
            MessageLookupByLibrary.simpleMessage("da verificare"),
        "home_to_do_list": MessageLookupByLibrary.simpleMessage("Da fare"),
        "home_unable_to_load_recent_imports":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile caricare le importazioni recenti."),
        "home_unreadable_abak_import": MessageLookupByLibrary.simpleMessage(
            "Importazione ABAK illeggibile."),
        "home_unsuccessful": MessageLookupByLibrary.simpleMessage("In stallo"),
        "home_verify": MessageLookupByLibrary.simpleMessage("Verifica"),
        "home_very_large_backups":
            MessageLookupByLibrary.simpleMessage("Backup di grandi dimensioni"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Lingua registrata."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Lingua dell\'applicazione"),
        "loading":
            MessageLookupByLibrary.simpleMessage("Caricamento in corso..."),
        "modify": MessageLookupByLibrary.simpleMessage("Modifica"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Nessun file specificato"),
        "ok": MessageLookupByLibrary.simpleMessage("Va bene"),
        "open": MessageLookupByLibrary.simpleMessage("Apri"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Associare un telefono"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Associare un telefono"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scansiona questo codice QR da ABAK Mobile per configurare automaticamente la connessione al Desktop."),
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Crea un professionista"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Elenco dei professionisti"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Aggiornare il cruscotto"),
        "reset": MessageLookupByLibrary.simpleMessage("Reimposta"),
        "smartCardDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnosi della Carta Vitale"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Impostazioni utente"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Impostazioni utente")
      };
}
