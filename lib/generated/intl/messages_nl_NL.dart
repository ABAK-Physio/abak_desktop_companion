// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a nl_NL locale. All the
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
  String get localeName => 'nl_NL';

  static String m0(error) => "Fout bij het opslaan: ${error}";

  static String m1(count) => "${count} andere oefening(en)";

  static String m2(count) => "${count} vereniging(en) in afwachting";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "close": MessageLookupByLibrary.simpleMessage("Sluiten"),
        "dashboardTitle": MessageLookupByLibrary.simpleMessage(
            "Lokaal klinisch centrum ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Adres"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Haven"),
        "exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Uitwisselingsdossier gereset"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Bijgewerkt ABAK-uitwisselingsdossier"),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Voorvoegsel ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Sluiten"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Commentaar"),
        "g_context": MessageLookupByLibrary.simpleMessage("Achtergrond"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Kopiëren"),
        "g_file": MessageLookupByLibrary.simpleMessage("Bestand"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Technische informatie"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Gekopieerde technische gegevens"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Gearchiveerde patiënten kunnen tot de aangegeven datum worden hersteld.\nNa deze datum worden ze automatisch verwijderd, zodat ongebruikte dossiers niet voor onbepaalde tijd worden bewaard.\nDe bewaartermijn kan worden aangepast in de instellingen van Companion."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "U kunt een apparaat aanmaken, wijzigen of archiveren.\n\nOmwille van de traceerbaarheid is het niet mogelijk om een apparaat te verwijderen.\nIndien nodig kunt u het herstellen.\n\nDe QR-code wordt gebruikt om een telefoon of tablet te koppelen."),
        "help_device_list_title":
            MessageLookupByLibrary.simpleMessage("Lijst met apparaten"),
        "help_donnees_cliniques_patient": MessageLookupByLibrary.simpleMessage(
            "Hier vindt u aanvullende gegevens over uw patiënt"),
        "help_home": MessageLookupByLibrary.simpleMessage(
            "Dit scherm is het hoofdscherm van ABAK Companion.\nHet bestaat uit:\n- een balk die u informeert over het aantal actieve en gearchiveerde patiënten.\n- het aantal lopende meldingen.\nIn de instellingen kunt u de naam van uw instelling invoeren en uw logo toevoegen.\n\nHet gedeelte ‘Recente imports’ toont u de meest recente resultatendossiers die vanuit ABAL Mobile zijn geïmporteerd.\n‘Systeemstatus’ geeft aan of er een eventueel probleem is en de datum van de laatste back-up.\n‘Nieuwe ABAK-resultaten om te koppelen’ toont u de resultaten die zijn verzonden maar nog niet aan een patiënt zijn toegewezen.\n\'Systeemwaarschuwing\' geeft informatie over de aard van een probleem.\nMet \'Snelle actie\' kunt u de geschiedenis van al uw importen bekijken en een nieuwe back-up maken."),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Hier vindt u de identificatiegegevens van uw patiënt"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm kunt u:\n - De taal selecteren.\n - De bewaartermijn van gearchiveerde patiëntendossiers instellen.\n - De expertmodus activeren.\n - Naar het scherm „Instelling” gaan om de naam en het logo van uw instelling in te voeren"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm kunt u een nieuwe zorgverlener toevoegen of diens gegevens wijzigen.\n\nAls u de zorgverlener naar de prullenbak verplaatst, wordt deze niet verwijderd. Omwille van de traceerbaarheid is het niet mogelijk om een zorgverlener te verwijderen.\n\nDoor de QR-code te scannen kunt u automatisch het profiel van de zorgverlener voor uw instelling aanmaken op diens telefoon of tablet."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Hier vindt u de verschillende behandelingen van uw patiënt. U kunt een bestaande behandelingsperiode gebruiken of een nieuwe aanmaken."),
        "home_abak_exercice":
            MessageLookupByLibrary.simpleMessage("ABAK-oefening"),
        "home_abak_file": MessageLookupByLibrary.simpleMessage("ABAK-bestand"),
        "home_accueil": MessageLookupByLibrary.simpleMessage("Home"),
        "home_action_required": MessageLookupByLibrary.simpleMessage(
            "Te ondernemen actie: dit dossier aan een patiënt koppelen."),
        "home_already_imported":
            MessageLookupByLibrary.simpleMessage("Reeds geïmporteerd"),
        "home_an_intervention_is_necessary":
            MessageLookupByLibrary.simpleMessage("Er moet worden ingegrepen"),
        "home_archives": MessageLookupByLibrary.simpleMessage("Archief"),
        "home_attention": MessageLookupByLibrary.simpleMessage("Let op"),
        "home_backup_successfully_created":
            MessageLookupByLibrary.simpleMessage(
                "De back-up is succesvol aangemaakt."),
        "home_balance_sheet_date":
            MessageLookupByLibrary.simpleMessage("Datum van de balans"),
        "home_conflict_detected":
            MessageLookupByLibrary.simpleMessage("Conflict gedetecteerd"),
        "home_create_a_backup":
            MessageLookupByLibrary.simpleMessage("Een back-up maken"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Datum niet opgegeven"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Apparaten"),
        "home_error_while_saving": m0,
        "home_everything_is_working_normally":
            MessageLookupByLibrary.simpleMessage("Alles werkt normaal"),
        "home_expert_comment": MessageLookupByLibrary.simpleMessage(
            "Dit scherm is het hoofdscherm van Companion."),
        "home_failure": MessageLookupByLibrary.simpleMessage("Mislukking"),
        "home_fermer": MessageLookupByLibrary.simpleMessage("Sluiten"),
        "home_file": MessageLookupByLibrary.simpleMessage("Bestand"),
        "home_historique": MessageLookupByLibrary.simpleMessage("Geschiedenis"),
        "home_home": MessageLookupByLibrary.simpleMessage("Start"),
        "home_import_history":
            MessageLookupByLibrary.simpleMessage("Overzicht van importen"),
        "home_imports_interrupted_or_in_progress":
            MessageLookupByLibrary.simpleMessage(
                "Onderbroken of lopende importen"),
        "home_imports_with_errors":
            MessageLookupByLibrary.simpleMessage("Foutieve invoer"),
        "home_information": MessageLookupByLibrary.simpleMessage("Over ons"),
        "home_invalid_file_path":
            MessageLookupByLibrary.simpleMessage("Ongeldig bestandspad:"),
        "home_ipAddressNotFound":
            MessageLookupByLibrary.simpleMessage("IP-adres niet gevonden"),
        "home_ipAddressNotFoundMessage": MessageLookupByLibrary.simpleMessage(
            "Het is niet mogelijk om het lokale IP-adres van de desktop te bepalen.\n\nControleer of de computer is aangesloten op het lokale netwerk."),
        "home_large_number_of_archived_patients":
            MessageLookupByLibrary.simpleMessage(
                "Groot aantal gearchiveerde patiënten"),
        "home_large_sqlite_database":
            MessageLookupByLibrary.simpleMessage("Omvangrijke SQLite-database"),
        "home_last_backup":
            MessageLookupByLibrary.simpleMessage("Laatste back-up"),
        "home_last_old_backup":
            MessageLookupByLibrary.simpleMessage("Laatste oude back-up"),
        "home_link_to_a_care_plan": MessageLookupByLibrary.simpleMessage(
            "Koppelen aan een behandeling"),
        "home_more_7_days":
            MessageLookupByLibrary.simpleMessage("Meer dan 7 dagen"),
        "home_new_abak_results_to_be_linked": MessageLookupByLibrary.simpleMessage(
            "Nieuwe ABAK-uitslagen die aan een patiënt moeten worden gekoppeld"),
        "home_no_abak_result_to_associate":
            MessageLookupByLibrary.simpleMessage(
                "Er zijn geen ABAK-resultaten om te koppelen."),
        "home_no_alert_detected": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen waarschuwingen gedetecteerd"),
        "home_no_imports_recorded": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen importen geregistreerd."),
        "home_no_pending_imports": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen importen in behandeling"),
        "home_no_saved_backup": MessageLookupByLibrary.simpleMessage(
            "Er is geen back-up opgeslagen"),
        "home_not_specified":
            MessageLookupByLibrary.simpleMessage("geïnformeerd"),
        "home_octets": MessageLookupByLibrary.simpleMessage("Octetten"),
        "home_other_exercises": m1,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Instellingen"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Pad"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patiënt ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patiënten"),
        "home_pending_association": m2,
        "home_practitioners":
            MessageLookupByLibrary.simpleMessage("beoefenaars"),
        "home_quick_actions":
            MessageLookupByLibrary.simpleMessage("Snelle acties"),
        "home_receents_imports":
            MessageLookupByLibrary.simpleMessage("Recente importen"),
        "home_recent_restoration_detected":
            MessageLookupByLibrary.simpleMessage(
                "Onlangs uitgevoerde restauratie gedetecteerd"),
        "home_results": MessageLookupByLibrary.simpleMessage("Resultaten"),
        "home_select_qr_code": MessageLookupByLibrary.simpleMessage(
            "Scan deze QR-code via ABAK Mobile om de verbinding met Desktop automatisch in te stellen."),
        "home_settings": MessageLookupByLibrary.simpleMessage("Hulp"),
        "home_size": MessageLookupByLibrary.simpleMessage("Grootte"),
        "home_solve": MessageLookupByLibrary.simpleMessage("Oplossen"),
        "home_success": MessageLookupByLibrary.simpleMessage("Succes"),
        "home_system_alert":
            MessageLookupByLibrary.simpleMessage("Systeemwaarschuwing"),
        "home_system_status":
            MessageLookupByLibrary.simpleMessage("Systeemstatus"),
        "home_technical_information":
            MessageLookupByLibrary.simpleMessage("Technische informatie"),
        "home_this_file_had_already_been_imported":
            MessageLookupByLibrary.simpleMessage(
                "Dit bestand was al geïmporteerd. Er zijn geen gegevens toegevoegd."),
        "home_to_be_verified":
            MessageLookupByLibrary.simpleMessage("te controleren"),
        "home_to_do_list": MessageLookupByLibrary.simpleMessage("Te doen"),
        "home_unable_to_load_recent_imports":
            MessageLookupByLibrary.simpleMessage(
                "De recente imports kunnen niet worden geladen."),
        "home_unreadable_abak_import":
            MessageLookupByLibrary.simpleMessage("ABAK-import onleesbaar."),
        "home_unsuccessful": MessageLookupByLibrary.simpleMessage("Mislukt"),
        "home_verify": MessageLookupByLibrary.simpleMessage("Controleren"),
        "home_very_large_backups":
            MessageLookupByLibrary.simpleMessage("Zeer omvangrijke back-ups"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Taal opgeslagen."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Taal van de applicatie"),
        "loading": MessageLookupByLibrary.simpleMessage("Bezig met laden..."),
        "modify": MessageLookupByLibrary.simpleMessage("Wijzigen"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Er is geen map gedefinieerd"),
        "ok": MessageLookupByLibrary.simpleMessage("Oké"),
        "open": MessageLookupByLibrary.simpleMessage("Openen"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Een telefoon koppelen"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Een telefoon koppelen"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scan deze QR-code via ABAK Mobile om de verbinding met Desktop automatisch in te stellen."),
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Een behandelaar aanmaken"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Lijst van behandelaars"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Het dashboard vernieuwen"),
        "reset": MessageLookupByLibrary.simpleMessage("Resetten"),
        "smartCardDiagnostic": MessageLookupByLibrary.simpleMessage(
            "Diagnose van de Carte Vitale"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Gebruikersinstellingen"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Gebruikersinstellingen")
      };
}
