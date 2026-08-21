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

  static String m0(size) => "${size}";

  static String m1(deviceName) => "Wilt u ${deviceName} echt archiveren?";

  static String m2(fieldName) => "Het veld \"${fieldName}\" is verplicht.";

  static String m3(noteTitle) =>
      "De notitie \"${noteTitle}\" wordt niet meer weergegeven.";

  static String m4(error) => "Fout bij het opslaan: ${error}";

  static String m5(count) => "${count} andere oefening(en)";

  static String m6(count) => "${count} vereniging(en) in afwachting";

  static String m7(count) => "${count} back-ups";

  static String m8(size) => "Maat: ${size}";

  static String m9(size) => "Totale afmeting: ${size}";

  static String m10(version) => "Versie ${version}";

  static String m11(patientName) =>
      "Wilt u ${patientName} echt archiveren? Hij/zij wordt dan niet meer in de actieve lijst weergegeven.";

  static String m12(patientName) => "${patientName} gearchiveerd.";

  static String m13(error) => "Fout: ${error}";

  static String m14(patientName) =>
      "${patientName} is weer toegevoegd aan de actieve lijst.";

  static String m15(patientName) =>
      "Vitale-kaart gekoppeld aan de patiënt ${patientName}.";

  static String m16(patientName) => "De patiënt ${patientName} is hersteld.";

  static String m17(practitionerName) =>
      "Wilt u ${practitionerName} echt archiveren?";

  static String m18(date) => "Gearchiveerd op ${date}";

  static String m19(error) => "Fout: ${error}";

  static String m20(professionalId) => "ID pro: ${professionalId}";

  static String m21(error) => "Fout: ${error}";

  static String m22(error) => "Fout bij het resetten: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "backupHistory_cancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "Er is geen back-up opgeslagen."),
        "backupHistory_fileSize": m0,
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Herstellen"),
        "backupHistory_restoreTitle":
            MessageLookupByLibrary.simpleMessage("Deze back-up herstellen?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Deze bewerking zal de huidige database volledig vervangen.\n\nEr wordt een automatische back-up gemaakt voordat het herstel wordt uitgevoerd.\n\nDoorgaan?"),
        "backupHistory_title":
            MessageLookupByLibrary.simpleMessage("Overzicht van back-ups"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Oorsprong ABAK"),
        "careEpisodeDetail_evolution":
            MessageLookupByLibrary.simpleMessage("Ontwikkeling"),
        "careEpisodeDetail_noResult": MessageLookupByLibrary.simpleMessage(
            "Er zijn momenteel geen resultaten gevonden."),
        "careEpisodeDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "careEpisodeDetail_reportsWorkspaceTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Nieuwe interface voor balansen en rapporten"),
        "careEpisodeDetail_results":
            MessageLookupByLibrary.simpleMessage("ABAK-resultaten"),
        "careEpisodeDetail_score":
            MessageLookupByLibrary.simpleMessage("Score"),
        "close": MessageLookupByLibrary.simpleMessage("Sluiten"),
        "contactFormTemplateDiagnostic_category":
            MessageLookupByLibrary.simpleMessage("Categorie"),
        "contactFormTemplateDiagnostic_defaultTemplate":
            MessageLookupByLibrary.simpleMessage("Standaardmodel"),
        "contactFormTemplateDiagnostic_error":
            MessageLookupByLibrary.simpleMessage("Fout"),
        "contactFormTemplateDiagnostic_fields":
            MessageLookupByLibrary.simpleMessage("Velden"),
        "contactFormTemplateDiagnostic_no":
            MessageLookupByLibrary.simpleMessage("Niet"),
        "contactFormTemplateDiagnostic_noData":
            MessageLookupByLibrary.simpleMessage(
                "Er zijn geen gegevens om weer te geven."),
        "contactFormTemplateDiagnostic_noTemplate":
            MessageLookupByLibrary.simpleMessage(
                "Er is geen sjabloon voor een eerste onderhoudsformulier gevonden."),
        "contactFormTemplateDiagnostic_notDefined":
            MessageLookupByLibrary.simpleMessage("Niet gedefinieerd"),
        "contactFormTemplateDiagnostic_order":
            MessageLookupByLibrary.simpleMessage("Bestelling"),
        "contactFormTemplateDiagnostic_practitioner":
            MessageLookupByLibrary.simpleMessage("Behandelaar"),
        "contactFormTemplateDiagnostic_refresh":
            MessageLookupByLibrary.simpleMessage("Vernieuwen"),
        "contactFormTemplateDiagnostic_required":
            MessageLookupByLibrary.simpleMessage("Verplicht"),
        "contactFormTemplateDiagnostic_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Systeemmodel"),
        "contactFormTemplateDiagnostic_templateId":
            MessageLookupByLibrary.simpleMessage("Model-ID"),
        "contactFormTemplateDiagnostic_title":
            MessageLookupByLibrary.simpleMessage(
                "Diagnose- en onderhoudsformulier"),
        "contactFormTemplateDiagnostic_type":
            MessageLookupByLibrary.simpleMessage("Type"),
        "contactFormTemplateDiagnostic_yes":
            MessageLookupByLibrary.simpleMessage("Ja"),
        "dashboardTitle": MessageLookupByLibrary.simpleMessage(
            "Lokaal klinisch centrum ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Adres"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Haven"),
        "deviceForm_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Geassocieerd arts"),
        "deviceForm_cancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
        "deviceForm_contextName":
            MessageLookupByLibrary.simpleMessage("Nieuw apparaat"),
        "deviceForm_create": MessageLookupByLibrary.simpleMessage("Aanmaken"),
        "deviceForm_deviceName":
            MessageLookupByLibrary.simpleMessage("Naam van het apparaat"),
        "deviceForm_deviceNameHint":
            MessageLookupByLibrary.simpleMessage("iPhone Claire, Pixel Marc…"),
        "deviceForm_deviceNameRequired": MessageLookupByLibrary.simpleMessage(
            "De naam van het apparaat is verplicht"),
        "deviceForm_editDevice":
            MessageLookupByLibrary.simpleMessage("Het apparaat wijzigen"),
        "deviceForm_loadingPractitionersError":
            MessageLookupByLibrary.simpleMessage(
                "Fout bij het laden van de zorgverleners"),
        "deviceForm_newDevice":
            MessageLookupByLibrary.simpleMessage("Nieuw apparaat"),
        "deviceForm_platform": MessageLookupByLibrary.simpleMessage("Platform"),
        "deviceForm_save": MessageLookupByLibrary.simpleMessage("Opslaan"),
        "deviceForm_sharedDevice":
            MessageLookupByLibrary.simpleMessage("Geen / gedeeld apparaat"),
        "deviceList_active": MessageLookupByLibrary.simpleMessage("Activa"),
        "deviceList_archive":
            MessageLookupByLibrary.simpleMessage("Archiveren"),
        "deviceList_archiveConfirmation": m1,
        "deviceList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Het apparaat archiveren"),
        "deviceList_archived":
            MessageLookupByLibrary.simpleMessage("Gearchiveerd"),
        "deviceList_archivedDevicesEmpty": MessageLookupByLibrary.simpleMessage(
            "Het winkelmandje voor apparaten is momenteel leeg."),
        "deviceList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Gearchiveerd op"),
        "deviceList_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Geassocieerd behandelaar"),
        "deviceList_cancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
        "deviceList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm wordt de lijst weergegeven van de apparaten die met de instelling zijn verbonden"),
        "deviceList_contextName":
            MessageLookupByLibrary.simpleMessage("Lijst met apparaten"),
        "deviceList_edit": MessageLookupByLibrary.simpleMessage("Wijzigen"),
        "deviceList_error": MessageLookupByLibrary.simpleMessage("Fout"),
        "deviceList_newDevice":
            MessageLookupByLibrary.simpleMessage("Nieuw apparaat"),
        "deviceList_noArchivedDevices": MessageLookupByLibrary.simpleMessage(
            "Geen gearchiveerde apparaten"),
        "deviceList_noPairedDevices":
            MessageLookupByLibrary.simpleMessage("Geen gekoppelde apparaten"),
        "deviceList_pairedDevicesExplanation": MessageLookupByLibrary.simpleMessage(
            "De ABAK-apparaten die aan de instelling zijn gekoppeld, worden hier weergegeven."),
        "deviceList_platform": MessageLookupByLibrary.simpleMessage("Platform"),
        "deviceList_restore":
            MessageLookupByLibrary.simpleMessage("Herstellen"),
        "deviceList_showQrCode":
            MessageLookupByLibrary.simpleMessage("QR-code weergeven"),
        "deviceList_title":
            MessageLookupByLibrary.simpleMessage("Lijst met apparaten"),
        "episodeDashboard_documents":
            MessageLookupByLibrary.simpleMessage("Documenten"),
        "episodeDashboard_documentsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Documenten die bij deze aflevering horen"),
        "episodeDashboard_forms":
            MessageLookupByLibrary.simpleMessage("Formulieren"),
        "episodeDashboard_formsDescription": MessageLookupByLibrary.simpleMessage(
            "Vragenlijsten die specifiek betrekking hebben op deze aflevering"),
        "episodeDashboard_notes":
            MessageLookupByLibrary.simpleMessage("Opmerkingen"),
        "episodeDashboard_notesDescription":
            MessageLookupByLibrary.simpleMessage(
                "Opmerkingen en commentaar van de fysiotherapeut"),
        "episodeDashboard_report":
            MessageLookupByLibrary.simpleMessage("Rapport"),
        "episodeDashboard_reportDescription":
            MessageLookupByLibrary.simpleMessage(
                "Samenvatting van de aflevering"),
        "episodeDocuments_addDocument":
            MessageLookupByLibrary.simpleMessage("Een document toevoegen"),
        "episodeDocuments_addError": MessageLookupByLibrary.simpleMessage(
            "Het document kan niet worden toegevoegd"),
        "episodeDocuments_addedOn":
            MessageLookupByLibrary.simpleMessage("Toegevoegd op"),
        "episodeDocuments_document":
            MessageLookupByLibrary.simpleMessage("Document"),
        "episodeDocuments_documentAdded": MessageLookupByLibrary.simpleMessage(
            "Het document is toegevoegd aan de ondersteuning."),
        "episodeDocuments_emptyDescription": MessageLookupByLibrary.simpleMessage(
            "U kunt een tekstdocument, een spreadsheet, een PDF, een afbeelding of een ander nuttig bestand toevoegen."),
        "episodeDocuments_fileNotFound": MessageLookupByLibrary.simpleMessage(
            "Het bijbehorende bestand kan niet worden gevonden."),
        "episodeDocuments_help": MessageLookupByLibrary.simpleMessage(
            "U kunt aan deze functie documenten koppelen die u met uw gebruikelijke programma’s hebt gemaakt: tekstverwerker, spreadsheetprogramma, PDF-reader of beeldbewerkingssoftware.\n\nDe toegevoegde bestanden worden naar de opslagruimte van Companion gekopieerd. Als u op een document klikt, wordt het geopend met het bijbehorende programma dat op deze computer is geïnstalleerd."),
        "episodeDocuments_image":
            MessageLookupByLibrary.simpleMessage("Afbeelding"),
        "episodeDocuments_loadError": MessageLookupByLibrary.simpleMessage(
            "De bijbehorende documenten kunnen niet worden geladen."),
        "episodeDocuments_noDocument": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen documenten gekoppeld aan deze behandeling."),
        "episodeDocuments_openDocument":
            MessageLookupByLibrary.simpleMessage("Het document openen"),
        "episodeDocuments_openError": MessageLookupByLibrary.simpleMessage(
            "Het bestand kan niet worden geopend"),
        "episodeDocuments_pdfDocument":
            MessageLookupByLibrary.simpleMessage("PDF-document"),
        "episodeDocuments_platformNotSupported":
            MessageLookupByLibrary.simpleMessage(
                "Openen wordt op dit platform niet ondersteund."),
        "episodeDocuments_refresh":
            MessageLookupByLibrary.simpleMessage("Vernieuwen"),
        "episodeDocuments_spreadsheet":
            MessageLookupByLibrary.simpleMessage("Spreadsheet"),
        "episodeDocuments_textDocument":
            MessageLookupByLibrary.simpleMessage("Tekstdocument"),
        "episodeDocuments_title": MessageLookupByLibrary.simpleMessage(
            "Documenten met betrekking tot de behandeling"),
        "episodeEvolution_evaluation":
            MessageLookupByLibrary.simpleMessage("beoordeling"),
        "episodeEvolution_evaluations":
            MessageLookupByLibrary.simpleMessage("beoordelingen"),
        "episodeEvolution_first":
            MessageLookupByLibrary.simpleMessage("Première"),
        "episodeEvolution_followedExercises":
            MessageLookupByLibrary.simpleMessage("Gedane oefeningen"),
        "episodeEvolution_last":
            MessageLookupByLibrary.simpleMessage("Laatste"),
        "episodeEvolution_noResults": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen resultaten beschikbaar voor deze aflevering."),
        "episodeEvolution_singleNumericValue":
            MessageLookupByLibrary.simpleMessage(
                "Er is slechts één cijferwaarde beschikbaar"),
        "episodeEvolution_title":
            MessageLookupByLibrary.simpleMessage("Verloop van de aflevering"),
        "episodeEvolution_viewEvolution":
            MessageLookupByLibrary.simpleMessage("Bekijk de ontwikkeling"),
        "episodeFormEditor_error": MessageLookupByLibrary.simpleMessage("Fout"),
        "episodeFormEditor_noField": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen velden om weer te geven."),
        "episodeFormEditor_requiredField": m2,
        "episodeFormEditor_save":
            MessageLookupByLibrary.simpleMessage("Opslaan"),
        "episodeFormEditor_title":
            MessageLookupByLibrary.simpleMessage("Het formulier bewerken"),
        "episodeForms_availableTemplates":
            MessageLookupByLibrary.simpleMessage("Beschikbare modellen"),
        "episodeForms_category":
            MessageLookupByLibrary.simpleMessage("Categorie"),
        "episodeForms_completed":
            MessageLookupByLibrary.simpleMessage("aangevuld"),
        "episodeForms_create": MessageLookupByLibrary.simpleMessage("Aanmaken"),
        "episodeForms_createdForms":
            MessageLookupByLibrary.simpleMessage("Aangemaakte formulieren"),
        "episodeForms_createdOn":
            MessageLookupByLibrary.simpleMessage("Aangemaakt op"),
        "episodeForms_customTemplate":
            MessageLookupByLibrary.simpleMessage("Op maat gemaakt model"),
        "episodeForms_error": MessageLookupByLibrary.simpleMessage("Fout"),
        "episodeForms_form": MessageLookupByLibrary.simpleMessage("Formulier"),
        "episodeForms_inProgress":
            MessageLookupByLibrary.simpleMessage("in uitvoering"),
        "episodeForms_noAvailableTemplate":
            MessageLookupByLibrary.simpleMessage(
                "Er is geen formulier sjabloon beschikbaar."),
        "episodeForms_noCreatedForm": MessageLookupByLibrary.simpleMessage(
            "Er is geen formulier aangemaakt voor deze aflevering."),
        "episodeForms_noData": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen gegevens om weer te geven."),
        "episodeForms_refresh":
            MessageLookupByLibrary.simpleMessage("Vernieuwen"),
        "episodeForms_state": MessageLookupByLibrary.simpleMessage("Status"),
        "episodeForms_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Systeemmodel"),
        "episodeForms_title":
            MessageLookupByLibrary.simpleMessage("Formulieren"),
        "episodeNotes_archive":
            MessageLookupByLibrary.simpleMessage("Archiveren"),
        "episodeNotes_archiveConfirmation": m3,
        "episodeNotes_archiveTitle":
            MessageLookupByLibrary.simpleMessage("De notitie archiveren?"),
        "episodeNotes_cancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "episodeNotes_content": MessageLookupByLibrary.simpleMessage("Inhoud"),
        "episodeNotes_editNote":
            MessageLookupByLibrary.simpleMessage("De beoordeling wijzigen"),
        "episodeNotes_error": MessageLookupByLibrary.simpleMessage("Fout"),
        "episodeNotes_modifiedOn":
            MessageLookupByLibrary.simpleMessage("Gewijzigd op"),
        "episodeNotes_newNote":
            MessageLookupByLibrary.simpleMessage("Nieuw bericht"),
        "episodeNotes_noNote": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen aantekeningen bij deze aflevering."),
        "episodeNotes_noteTitle": MessageLookupByLibrary.simpleMessage("Titel"),
        "episodeNotes_refresh":
            MessageLookupByLibrary.simpleMessage("Vernieuwen"),
        "episodeNotes_save": MessageLookupByLibrary.simpleMessage("Opslaan"),
        "episodeNotes_title":
            MessageLookupByLibrary.simpleMessage("Opmerkingen"),
        "episodeNotes_titleRequired":
            MessageLookupByLibrary.simpleMessage("De titel is verplicht."),
        "episodeReport_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Oorsprong ABAK"),
        "episodeReport_addConclusion":
            MessageLookupByLibrary.simpleMessage("Een conclusie toevoegen"),
        "episodeReport_clinicalConclusion":
            MessageLookupByLibrary.simpleMessage("Klinische conclusie"),
        "episodeReport_conclusionRequired":
            MessageLookupByLibrary.simpleMessage(
                "De conclusie mag niet inhoudsloos zijn."),
        "episodeReport_documents":
            MessageLookupByLibrary.simpleMessage("Documenten"),
        "episodeReport_dominantSide":
            MessageLookupByLibrary.simpleMessage("Dominante kant"),
        "episodeReport_editConclusion":
            MessageLookupByLibrary.simpleMessage("De conclusie wijzigen"),
        "episodeReport_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "episodeReport_error": MessageLookupByLibrary.simpleMessage("Fout"),
        "episodeReport_forms":
            MessageLookupByLibrary.simpleMessage("Formulieren"),
        "episodeReport_generatedPreview": MessageLookupByLibrary.simpleMessage(
            "Overzicht van het gegenereerde rapport"),
        "episodeReport_generatingPreview": MessageLookupByLibrary.simpleMessage(
            "Tekstoverzicht wordt gegenereerd..."),
        "episodeReport_name": MessageLookupByLibrary.simpleMessage("Naam"),
        "episodeReport_noConclusion": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen conclusies opgegeven."),
        "episodeReport_noData": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen gegevens om weer te geven."),
        "episodeReport_noDocument": MessageLookupByLibrary.simpleMessage(
            "Geen bijbehorende documenten"),
        "episodeReport_noForm": MessageLookupByLibrary.simpleMessage(
            "Geen bijbehorende formulieren"),
        "episodeReport_noNote":
            MessageLookupByLibrary.simpleMessage("Geen bijbehorende notities"),
        "episodeReport_noResult": MessageLookupByLibrary.simpleMessage(
            "Geen gerelateerde resultaten"),
        "episodeReport_notProvided":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "episodeReport_notes":
            MessageLookupByLibrary.simpleMessage("Opmerkingen"),
        "episodeReport_patient":
            MessageLookupByLibrary.simpleMessage("Patiënt"),
        "episodeReport_phone": MessageLookupByLibrary.simpleMessage("Telefoon"),
        "episodeReport_profession":
            MessageLookupByLibrary.simpleMessage("Beroep"),
        "episodeReport_refresh":
            MessageLookupByLibrary.simpleMessage("Vernieuwen"),
        "episodeReport_results":
            MessageLookupByLibrary.simpleMessage("ABAK-resultaten"),
        "episodeReport_save": MessageLookupByLibrary.simpleMessage("Opslaan"),
        "episodeReport_score": MessageLookupByLibrary.simpleMessage("Score"),
        "episodeReport_sportActivity":
            MessageLookupByLibrary.simpleMessage("Sportactiviteit"),
        "episodeReport_title": MessageLookupByLibrary.simpleMessage("Rapport"),
        "episodeReport_unknownType":
            MessageLookupByLibrary.simpleMessage("Onbekend type"),
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
        "g_learn_more": MessageLookupByLibrary.simpleMessage("Meer informatie"),
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
            "Dit scherm is het hoofdscherm van ABAK Companion.\n\nHet bestaat uit:\n\n1) een balk die u informeert over:\n - het aantal actieve en gearchiveerde patiënten.\n  - het aantal lopende waarschuwingen.\n\nIn de instellingen kunt u de naam van uw instelling invoeren en uw logo toevoegen.\n\n2) \"Recente imports\" toont u de laatste dossiers met resultaten die vanuit ABAK Mobile zijn geïmporteerd.\n\n3) \"Systeemstatus\" geeft aan of er een eventueel probleem is en de datum van de laatste back-up.\n\n4) \"Nieuwe ABAK-resultaten om te koppelen\" toont u de resultaten die vanuit ABAK Mobile zijn verzonden, maar die nog niet aan een patiënt in ABAK Companion zijn toegewezen.\n\n5) \"Systeemwaarschuwing\" informeert u over de aard van een probleem.\n\n6) Met „Snelle actie“ kunt u de geschiedenis van al uw importen bekijken en een nieuwe back-up maken."),
        "help_home_active_archived_patients_content":
            MessageLookupByLibrary.simpleMessage(
                "De actieve patiënten zijn te vinden in de lijst..."),
        "help_home_active_archived_patients_title":
            MessageLookupByLibrary.simpleMessage(
                "Actieve en gearchiveerde patiënten"),
        "help_home_import_assignment_content":
            MessageLookupByLibrary.simpleMessage(
                "Zodra u uw oefening in ABAK Mobile hebt voltooid..."),
        "help_home_import_assignment_title":
            MessageLookupByLibrary.simpleMessage(
                "Het import- en toewijzingsproces"),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Hier vindt u de identificatiegegevens van uw patiënt"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm kunt u:\n - De taal selecteren.\n - De bewaartermijn van gearchiveerde patiëntendossiers instellen.\n - De expertmodus activeren.\n - Naar het scherm „Instelling” gaan om de naam en het logo van uw instelling in te voeren"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm kunt u een nieuwe zorgverlener toevoegen of diens gegevens wijzigen.\n\nAls u de zorgverlener naar de prullenbak verplaatst, wordt deze niet verwijderd. Omwille van de traceerbaarheid is het niet mogelijk om een zorgverlener te verwijderen.\n\nDoor de QR-code te scannen kunt u automatisch het profiel van de zorgverlener voor uw instelling aanmaken op diens telefoon of tablet."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Hier vindt u de verschillende behandelingen van uw patiënt. U kunt een bestaande behandelingsperiode gebruiken of een nieuwe aanmaken."),
        "homeImportSummary_conflicts":
            MessageLookupByLibrary.simpleMessage("Conflicten"),
        "homeImportSummary_failedFiles":
            MessageLookupByLibrary.simpleMessage("Bestanden met fouten"),
        "homeImportSummary_importDate":
            MessageLookupByLibrary.simpleMessage("Gegevens importeren"),
        "homeImportSummary_importedMetrics":
            MessageLookupByLibrary.simpleMessage("Geïmporteerde statistieken"),
        "homeImportSummary_importedResults":
            MessageLookupByLibrary.simpleMessage("Geïmporteerde resultaten"),
        "homeImportSummary_open":
            MessageLookupByLibrary.simpleMessage("Openen"),
        "homeImportSummary_patients":
            MessageLookupByLibrary.simpleMessage("Betrokken patiënten"),
        "homeImportSummary_processedFiles":
            MessageLookupByLibrary.simpleMessage("Verwerkte bestanden"),
        "homeImportSummary_skippedResults":
            MessageLookupByLibrary.simpleMessage("Resultaten genegeerd"),
        "homeImportSummary_title":
            MessageLookupByLibrary.simpleMessage("Laatste ABAK-import"),
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
        "home_error_while_saving": m4,
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
        "home_other_exercises": m5,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Instellingen"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Pad"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patiënt ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patiënten"),
        "home_pending_association": m6,
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
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("bestand"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("bestanden"),
        "importResolutionAssistant_import":
            MessageLookupByLibrary.simpleMessage("Importeren"),
        "importResolutionAssistant_importFailed":
            MessageLookupByLibrary.simpleMessage("Import mislukt"),
        "importResolutionAssistant_importToComplete":
            MessageLookupByLibrary.simpleMessage("Import nog voltooien"),
        "importResolutionAssistant_importToReview":
            MessageLookupByLibrary.simpleMessage(
                "Import moet worden gecontroleerd"),
        "importResolutionAssistant_inError":
            MessageLookupByLibrary.simpleMessage("per ongeluk"),
        "importResolutionAssistant_interventionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Er is een handmatige ingreep nodig om deze import te voltooien."),
        "importResolutionAssistant_loadingError":
            MessageLookupByLibrary.simpleMessage(
                "De imports kunnen niet worden geladen"),
        "importResolutionAssistant_noProblem":
            MessageLookupByLibrary.simpleMessage(
                "Er zijn geen importproblemen vastgesteld."),
        "importResolutionAssistant_result":
            MessageLookupByLibrary.simpleMessage("resultaat"),
        "importResolutionAssistant_results":
            MessageLookupByLibrary.simpleMessage("resultaten"),
        "importResolutionAssistant_selectImportInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Selecteer een import om de details ervan te bekijken en volg de voorgestelde stappen."),
        "importResolutionAssistant_title": MessageLookupByLibrary.simpleMessage(
            "Oplossen van importproblemen"),
        "importResolutionAssistant_toReview":
            MessageLookupByLibrary.simpleMessage("te controleren"),
        "information_backupCount": m7,
        "information_backups": MessageLookupByLibrary.simpleMessage("Back-ups"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Geconfigureerd"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm wordt algemene, technische en juridische informatie over Companion weergegeven."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Informatie"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Database"),
        "information_language": MessageLookupByLibrary.simpleMessage("Taal"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Wettelijke kennisgeving"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Bezig met laden..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Lokale opslag"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Niet geconfigureerd"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "information_office": MessageLookupByLibrary.simpleMessage("Kantoor"),
        "information_size": m8,
        "information_system": MessageLookupByLibrary.simpleMessage("Systeem"),
        "information_title": MessageLookupByLibrary.simpleMessage("Informatie"),
        "information_totalSize": m9,
        "information_version": m10,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Versie..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("De licentie raadplegen"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Taal opgeslagen."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Taal van de applicatie"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Waarschuwing"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion is software die helpt bij het organiseren, importeren en raadplegen van klinische resultaten uit het ABAK-ecosysteem.\n\nHet is geen gecertificeerd medisch hulpmiddel en vervangt niet het oordeel van de zorgverlener.\n\nDe weergegeven resultaten, scores, rapporten en indicatoren moeten altijd worden geïnterpreteerd door een gekwalificeerde zorgverlener, waarbij rekening moet worden gehouden met het klinisch onderzoek, de context van de patiënt en de geldende aanbevelingen.\n\nDe gebruiker blijft als enige verantwoordelijk voor zijn klinische beslissingen, voor de controle van de geïmporteerde gegevens en voor de naleving van de toepasselijke beroeps-, wettelijke en deontologische regels bij het gebruik ervan.\n\nABAK Desktop Companion stelt geen zelfstandige diagnose, schrijft geen behandeling voor en is in geen geval een vervanging voor een medisch of paramedisch consult."),
        "legalNotice_title":
            MessageLookupByLibrary.simpleMessage("Juridische kennisgeving"),
        "loading": MessageLookupByLibrary.simpleMessage("Bezig met laden..."),
        "localDatabaseBackup_cancelled":
            MessageLookupByLibrary.simpleMessage("Back-up geannuleerd."),
        "localDatabaseBackup_chooseBackupFolder":
            MessageLookupByLibrary.simpleMessage(
                "De ABAK-back-upmap selecteren"),
        "localDatabaseBackup_databaseNotFound":
            MessageLookupByLibrary.simpleMessage(
                "SQLite-database niet gevonden."),
        "localDatabaseReset_backupFailed": MessageLookupByLibrary.simpleMessage(
            "Back-up vooraf niet mogelijk"),
        "main_alreadyRunningMessage": MessageLookupByLibrary.simpleMessage(
            "Er kan slechts één venster tegelijk worden geopend.\n\nGebruik het reeds geopende Companion-venster."),
        "main_alreadyRunningTitle": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion is al geopend"),
        "main_close": MessageLookupByLibrary.simpleMessage(""),
        "modify": MessageLookupByLibrary.simpleMessage("Wijzigen"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Er is geen map gedefinieerd"),
        "ok": MessageLookupByLibrary.simpleMessage("Oké"),
        "open": MessageLookupByLibrary.simpleMessage("Openen"),
        "organization_chooseLogo":
            MessageLookupByLibrary.simpleMessage("Een logo kiezen"),
        "organization_identityTitle": MessageLookupByLibrary.simpleMessage(
            "Identiteit van de instelling"),
        "organization_logoRemoved": MessageLookupByLibrary.simpleMessage(
            "Het logo van de instelling is verwijderd."),
        "organization_logoSaved": MessageLookupByLibrary.simpleMessage(
            "Logo van de geregistreerde instelling."),
        "organization_nameLabel":
            MessageLookupByLibrary.simpleMessage("Naam van de instelling"),
        "organization_nameSaved": MessageLookupByLibrary.simpleMessage(
            "Geregistreerde naam van de instelling."),
        "organization_removeLogo":
            MessageLookupByLibrary.simpleMessage("Het logo verwijderen"),
        "organization_saveName":
            MessageLookupByLibrary.simpleMessage("De naam opslaan"),
        "organization_title": MessageLookupByLibrary.simpleMessage("Vestiging"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Een telefoon koppelen"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Een telefoon koppelen"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scan deze QR-code via ABAK Mobile om de verbinding met Desktop automatisch in te stellen."),
        "patientClinicalDataEdit_address":
            MessageLookupByLibrary.simpleMessage("Adres"),
        "patientClinicalDataEdit_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Administratieve identiteit"),
        "patientClinicalDataEdit_ambidextrous":
            MessageLookupByLibrary.simpleMessage("Tweezijdig"),
        "patientClinicalDataEdit_centimeters":
            MessageLookupByLibrary.simpleMessage("In centimeters"),
        "patientClinicalDataEdit_dominantSide":
            MessageLookupByLibrary.simpleMessage("Dominante zijde"),
        "patientClinicalDataEdit_email":
            MessageLookupByLibrary.simpleMessage("E-mail"),
        "patientClinicalDataEdit_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage(
                "Land met een gezondheidszorgstelsel"),
        "patientClinicalDataEdit_height":
            MessageLookupByLibrary.simpleMessage("Grootte"),
        "patientClinicalDataEdit_identitySource":
            MessageLookupByLibrary.simpleMessage("Bron van identiteit"),
        "patientClinicalDataEdit_kilograms":
            MessageLookupByLibrary.simpleMessage("In kilogram"),
        "patientClinicalDataEdit_left":
            MessageLookupByLibrary.simpleMessage("Links"),
        "patientClinicalDataEdit_manualEntry":
            MessageLookupByLibrary.simpleMessage("Handmatige invoer"),
        "patientClinicalDataEdit_nationalHealthId":
            MessageLookupByLibrary.simpleMessage("Nationaal gezondheidsnummer"),
        "patientClinicalDataEdit_nationalHealthIdHelper":
            MessageLookupByLibrary.simpleMessage(
                "Voorbeeld Frankrijk: sofinummer"),
        "patientClinicalDataEdit_patientProfile":
            MessageLookupByLibrary.simpleMessage("Patiëntenprofiel"),
        "patientClinicalDataEdit_phone":
            MessageLookupByLibrary.simpleMessage("Telefoon"),
        "patientClinicalDataEdit_profession":
            MessageLookupByLibrary.simpleMessage("Beroep"),
        "patientClinicalDataEdit_right":
            MessageLookupByLibrary.simpleMessage("Rechts"),
        "patientClinicalDataEdit_save":
            MessageLookupByLibrary.simpleMessage("Opslaan"),
        "patientClinicalDataEdit_sportActivity":
            MessageLookupByLibrary.simpleMessage(
                "Gebruikelijke sportactiviteit"),
        "patientClinicalDataEdit_title":
            MessageLookupByLibrary.simpleMessage("Klinische gegevens wijzigen"),
        "patientClinicalDataEdit_unspecified":
            MessageLookupByLibrary.simpleMessage("Niet gespecificeerd"),
        "patientClinicalDataEdit_vitaleCard":
            MessageLookupByLibrary.simpleMessage("Vitale-kaart"),
        "patientClinicalDataEdit_weight":
            MessageLookupByLibrary.simpleMessage("Gewicht"),
        "patientDetail_address": MessageLookupByLibrary.simpleMessage("Adres"),
        "patientDetail_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Administratieve identiteit"),
        "patientDetail_archived":
            MessageLookupByLibrary.simpleMessage("gearchiveerd"),
        "patientDetail_bornOn": MessageLookupByLibrary.simpleMessage("Noch de"),
        "patientDetail_cancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "patientDetail_careEpisodeOpenedIn":
            MessageLookupByLibrary.simpleMessage("Open zorg in"),
        "patientDetail_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Vergoedingen"),
        "patientDetail_create":
            MessageLookupByLibrary.simpleMessage("Aanmaken"),
        "patientDetail_dominantSide":
            MessageLookupByLibrary.simpleMessage("Dominante kant"),
        "patientDetail_edit": MessageLookupByLibrary.simpleMessage("Wijzigen"),
        "patientDetail_editCareEpisode":
            MessageLookupByLibrary.simpleMessage("De ondersteuning aanpassen"),
        "patientDetail_editClinicalData":
            MessageLookupByLibrary.simpleMessage("Klinische gegevens wijzigen"),
        "patientDetail_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "patientDetail_error": MessageLookupByLibrary.simpleMessage("Fout"),
        "patientDetail_frHealthIdentity": MessageLookupByLibrary.simpleMessage(
            "Gezondheidsidentiteit — Frankrijk"),
        "patientDetail_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage(
                "Land met een gezondheidszorgstelsel"),
        "patientDetail_height": MessageLookupByLibrary.simpleMessage("Grootte"),
        "patientDetail_identitySource":
            MessageLookupByLibrary.simpleMessage("Bron: identiteit"),
        "patientDetail_initialReport":
            MessageLookupByLibrary.simpleMessage("Eerste verslag"),
        "patientDetail_nationalIdentifier":
            MessageLookupByLibrary.simpleMessage(
                "Nationaal identificatienummer"),
        "patientDetail_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Nieuwe dekking"),
        "patientDetail_noBirthdate":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "patientDetail_noCareEpisode": MessageLookupByLibrary.simpleMessage(
            "Er is geen zorgplan aangemaakt voor deze patiënt."),
        "patientDetail_notProvided":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "patientDetail_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "patientDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "patientDetail_patientInformation":
            MessageLookupByLibrary.simpleMessage("Informatie voor de patiënt"),
        "patientDetail_patientProfile":
            MessageLookupByLibrary.simpleMessage("Patiëntenprofiel"),
        "patientDetail_phone": MessageLookupByLibrary.simpleMessage("Telefoon"),
        "patientDetail_profession":
            MessageLookupByLibrary.simpleMessage("Beroep"),
        "patientDetail_provisional":
            MessageLookupByLibrary.simpleMessage("Voorlopig"),
        "patientDetail_provisionalDescription":
            MessageLookupByLibrary.simpleMessage("Gegevens aanvullen"),
        "patientDetail_qualified":
            MessageLookupByLibrary.simpleMessage("Gekwalificeerd"),
        "patientDetail_qualifiedDescription":
            MessageLookupByLibrary.simpleMessage("Identiteit overeenkomend"),
        "patientDetail_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Verantwoordelijke fysiotherapeut"),
        "patientDetail_retrieved":
            MessageLookupByLibrary.simpleMessage("Opgehaald"),
        "patientDetail_retrievedDescription":
            MessageLookupByLibrary.simpleMessage(
                "INS verkregen, identiteit te controleren"),
        "patientDetail_save": MessageLookupByLibrary.simpleMessage("Opslaan"),
        "patientDetail_sex": MessageLookupByLibrary.simpleMessage("Seks"),
        "patientDetail_sportActivity":
            MessageLookupByLibrary.simpleMessage("Sportactiviteit"),
        "patientDetail_state": MessageLookupByLibrary.simpleMessage("Status"),
        "patientDetail_status": MessageLookupByLibrary.simpleMessage("Status"),
        "patientDetail_validated":
            MessageLookupByLibrary.simpleMessage("Goedgekeurd"),
        "patientDetail_validatedDescription":
            MessageLookupByLibrary.simpleMessage(
                "Identiteit gecontroleerd, INS nog te achterhalen"),
        "patientDetail_weight": MessageLookupByLibrary.simpleMessage("Gewicht"),
        "patientDetail_years": MessageLookupByLibrary.simpleMessage("jaar"),
        "patientForm_birthDate":
            MessageLookupByLibrary.simpleMessage("Geboortedatum"),
        "patientForm_cancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
        "patientForm_create": MessageLookupByLibrary.simpleMessage("Aanmaken"),
        "patientForm_editPatient":
            MessageLookupByLibrary.simpleMessage("Patiënt bewerken"),
        "patientForm_female": MessageLookupByLibrary.simpleMessage("Vrouw"),
        "patientForm_firstName":
            MessageLookupByLibrary.simpleMessage("Voornaam"),
        "patientForm_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("De voornaam is verplicht"),
        "patientForm_lastName": MessageLookupByLibrary.simpleMessage("Naam"),
        "patientForm_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("De naam is verplicht"),
        "patientForm_male": MessageLookupByLibrary.simpleMessage("Man"),
        "patientForm_newPatient":
            MessageLookupByLibrary.simpleMessage("Nieuwe patiënt"),
        "patientForm_other": MessageLookupByLibrary.simpleMessage("Overig"),
        "patientForm_save": MessageLookupByLibrary.simpleMessage("Opslaan"),
        "patientForm_sex": MessageLookupByLibrary.simpleMessage("Seks"),
        "patientForm_unspecified":
            MessageLookupByLibrary.simpleMessage("Niet gespecificeerd"),
        "patientList_active": MessageLookupByLibrary.simpleMessage("Activa"),
        "patientList_archive":
            MessageLookupByLibrary.simpleMessage("Archiveren"),
        "patientList_archiveConfirmation": m11,
        "patientList_archiveSuccess": m12,
        "patientList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("De patiënt archiveren"),
        "patientList_archived":
            MessageLookupByLibrary.simpleMessage("Gearchiveerd"),
        "patientList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Gearchiveerd op"),
        "patientList_archivedPatient":
            MessageLookupByLibrary.simpleMessage("Gearchiveerde patiënt"),
        "patientList_archivedPatientsEmpty":
            MessageLookupByLibrary.simpleMessage(
                "De prullenbak van de patiënten is op dit moment leeg."),
        "patientList_bornOn": MessageLookupByLibrary.simpleMessage("Noch de"),
        "patientList_cancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
        "patientList_contextComment": MessageLookupByLibrary.simpleMessage(
            "U kunt de lijst met actieve en gearchiveerde patiënten bekijken"),
        "patientList_contextName":
            MessageLookupByLibrary.simpleMessage("Lijst van patiënten"),
        "patientList_edit": MessageLookupByLibrary.simpleMessage("Wijzigen"),
        "patientList_error": m13,
        "patientList_newPatient":
            MessageLookupByLibrary.simpleMessage("Nieuwe patiënt"),
        "patientList_noArchivedPatients": MessageLookupByLibrary.simpleMessage(
            "Geen gearchiveerde patiënten"),
        "patientList_noPatientFound": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen patiënten gevonden"),
        "patientList_noRegisteredPatients":
            MessageLookupByLibrary.simpleMessage(
                "Er zijn geen geregistreerde patiënten"),
        "patientList_patientFileEmpty": MessageLookupByLibrary.simpleMessage(
            "Het lokale patiëntendossier is momenteel leeg."),
        "patientList_restorableUntil":
            MessageLookupByLibrary.simpleMessage("Kan worden hersteld tot"),
        "patientList_restore":
            MessageLookupByLibrary.simpleMessage("Herstellen"),
        "patientList_restoreSuccess": m14,
        "patientList_searchPatient":
            MessageLookupByLibrary.simpleMessage("Een patiënt zoeken"),
        "patientList_sex": MessageLookupByLibrary.simpleMessage("Seks"),
        "patientList_title":
            MessageLookupByLibrary.simpleMessage("Lijst van patiënten"),
        "patientNew_archivedMatchToReview":
            MessageLookupByLibrary.simpleMessage(
                "Te controleren gearchiveerde correspondentie"),
        "patientNew_archivedMatchToReviewMessage":
            MessageLookupByLibrary.simpleMessage(
                "Er bestaat al een gearchiveerde patiënt met dezelfde voor- en achternaam en geboortedatum, maar de administratieve gegevens verschillen.\n\nEr vindt geen automatische herstelbewerking plaats. Controleer de dossiers voordat u verdergaat."),
        "patientNew_archivedPatientFound": MessageLookupByLibrary.simpleMessage(
            "Patiënt gevonden in het archief"),
        "patientNew_archivedPatientMatch": MessageLookupByLibrary.simpleMessage(
            "Deze Carte Vitale hoort bij de gearchiveerde patiënt:"),
        "patientNew_attach": MessageLookupByLibrary.simpleMessage("Koppelen"),
        "patientNew_attachVitaleError": MessageLookupByLibrary.simpleMessage(
            "De Carte Vitale kan niet worden gekoppeld"),
        "patientNew_attachVitaleQuestion": MessageLookupByLibrary.simpleMessage(
            "Wilt u de gegevens van de Carte Vitale aan deze patiënt koppelen?"),
        "patientNew_attachVitaleSuccess": m15,
        "patientNew_backToList":
            MessageLookupByLibrary.simpleMessage("Terug naar de lijst"),
        "patientNew_birthDate":
            MessageLookupByLibrary.simpleMessage("Geboortedatum"),
        "patientNew_cancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
        "patientNew_choosePatient":
            MessageLookupByLibrary.simpleMessage("De patiënt kiezen"),
        "patientNew_close": MessageLookupByLibrary.simpleMessage("Sluiten"),
        "patientNew_contextComment": MessageLookupByLibrary.simpleMessage(
            "Via dit scherm kunt u een nieuwe patiënt aanmaken door de gegevens handmatig in te voeren of door de Carte Vitale te scannen."),
        "patientNew_contextName":
            MessageLookupByLibrary.simpleMessage("Nieuwe patiënt"),
        "patientNew_createError": MessageLookupByLibrary.simpleMessage(
            "Fout bij het aanmaken van de patiënt"),
        "patientNew_createPatient":
            MessageLookupByLibrary.simpleMessage("De patiënt aanmaken"),
        "patientNew_creating":
            MessageLookupByLibrary.simpleMessage("Aan het laden..."),
        "patientNew_download":
            MessageLookupByLibrary.simpleMessage("Downloaden"),
        "patientNew_existingPatientTitle":
            MessageLookupByLibrary.simpleMessage("Bent u al patiënt bij ons?"),
        "patientNew_female": MessageLookupByLibrary.simpleMessage("Vrouwelijk"),
        "patientNew_firstName":
            MessageLookupByLibrary.simpleMessage("Voornaam"),
        "patientNew_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("De voornaam is verplicht"),
        "patientNew_lastName": MessageLookupByLibrary.simpleMessage("Naam"),
        "patientNew_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("De naam is verplicht"),
        "patientNew_male": MessageLookupByLibrary.simpleMessage("Mannelijk"),
        "patientNew_matchToReview": MessageLookupByLibrary.simpleMessage(
            "Te controleren correspondentie"),
        "patientNew_matchToReviewMessage": MessageLookupByLibrary.simpleMessage(
            "Er bestaat al een patiënt met dezelfde voor- en achternaam en geboortedatum.\n\nDe administratieve gegevens komen niet volledig overeen. Controleer het dossier voordat u verdergaat."),
        "patientNew_matchingPatientFound": MessageLookupByLibrary.simpleMessage(
            "Er is een overeenkomende patiënt gevonden:"),
        "patientNew_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "patientNew_nirDetectedProtected":
            MessageLookupByLibrary.simpleMessage("gedetecteerd en beveiligd"),
        "patientNew_nirUnavailable":
            MessageLookupByLibrary.simpleMessage("niet beschikbaar"),
        "patientNew_no": MessageLookupByLibrary.simpleMessage("Nee"),
        "patientNew_noNewPatientCreated": MessageLookupByLibrary.simpleMessage(
            "Er worden geen nieuwe patiënten aangemaakt."),
        "patientNew_notProvided":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "patientNew_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("niet ingevuld"),
        "patientNew_other": MessageLookupByLibrary.simpleMessage("Overig"),
        "patientNew_patientAlreadyRegistered":
            MessageLookupByLibrary.simpleMessage("Patiënt is al geregistreerd"),
        "patientNew_patientIdentity":
            MessageLookupByLibrary.simpleMessage("Identiteit van de patiënt"),
        "patientNew_readOn": MessageLookupByLibrary.simpleMessage("Gelezen op"),
        "patientNew_readVitale":
            MessageLookupByLibrary.simpleMessage("Carte Vitale lezen"),
        "patientNew_readerNotDetected": MessageLookupByLibrary.simpleMessage(
            "Vitale-kaartlezer niet gedetecteerd"),
        "patientNew_readerNotDetectedMessage": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion heeft geen Carte Vitale-lezer gedetecteerd.\n\nOm deze functie te kunnen gebruiken, hebt u het volgende nodig:\n\n• een PC/SC-compatibele Carte Vitale-lezer, die doorgaans via USB wordt aangesloten;\n• de ABAK Carte Vitale-module, die gratis wordt meegeleverd. Zie de website abak.care.\n\nZodra de lezer is aangesloten, klikt u opnieuw op ‘Carte Vitale lezen’."),
        "patientNew_reading":
            MessageLookupByLibrary.simpleMessage("Wordt geladen..."),
        "patientNew_restore":
            MessageLookupByLibrary.simpleMessage("Herstellen"),
        "patientNew_restoreError": MessageLookupByLibrary.simpleMessage(
            "De patiënt kan niet worden gereanimeerd"),
        "patientNew_restoreInsteadOfCreate": MessageLookupByLibrary.simpleMessage(
            "Wilt u deze map herstellen in plaats van een nieuwe patiënt aan te maken?"),
        "patientNew_restoreSuccess": m16,
        "patientNew_sex": MessageLookupByLibrary.simpleMessage("Seks"),
        "patientNew_vitaleIdentityRead": MessageLookupByLibrary.simpleMessage(
            "Identiteitsgegevens afgelezen van de Carte Vitale"),
        "patientNew_vitaleMatchesPatient": MessageLookupByLibrary.simpleMessage(
            "Deze Carte Vitale hoort bij de patiënt:"),
        "patientNew_vitaleModuleConfigurationError":
            MessageLookupByLibrary.simpleMessage(
                "De configuratie van de Carte Vitale-module ontbreekt of is onjuist. Installeer de module opnieuw en probeer het nogmaals."),
        "patientNew_vitaleModuleNotInstalled":
            MessageLookupByLibrary.simpleMessage(
                "De Carte Vitale-module is niet geïnstalleerd"),
        "patientNew_vitaleModuleNotInstalledMessage":
            MessageLookupByLibrary.simpleMessage(
                "De ABAK Carte Vitale-module is niet op deze computer geïnstalleerd.\n\nU kunt deze gratis downloaden van de ABAK-website."),
        "patientNew_vitalePrefilled": MessageLookupByLibrary.simpleMessage(
            "Patiëntgegevens die automatisch zijn ingevuld op basis van de Carte Vitale."),
        "patientNew_vitaleReadFailed": MessageLookupByLibrary.simpleMessage(
            "Het uitlezen van de Carte Vitale is mislukt."),
        "practitionerList_active":
            MessageLookupByLibrary.simpleMessage("Activa"),
        "practitionerList_addPractitionersHint":
            MessageLookupByLibrary.simpleMessage(
                "Voeg de fysiotherapeuten van de praktijk toe om de geïmporteerde tests te identificeren."),
        "practitionerList_archive":
            MessageLookupByLibrary.simpleMessage("Archiveren"),
        "practitionerList_archiveConfirmation": m17,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "De prullenbak van de fysiotherapeuten is op dit moment leeg."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage(
                "De fysiotherapeut archiveren"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Gearchiveerd"),
        "practitionerList_archivedOn": m18,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Een behandelaar aanmaken"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm wordt de lijst met geregistreerde zorgverleners weergegeven."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("Lijst van behandelaars"),
        "practitionerList_edit":
            MessageLookupByLibrary.simpleMessage("Wijzigen"),
        "practitionerList_error": m19,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Geen fysiotherapeuten in het archief"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen fysiotherapeuten geregistreerd"),
        "practitionerList_professionalId": m20,
        "practitionerList_restore":
            MessageLookupByLibrary.simpleMessage("Herstellen"),
        "practitionerList_showQrCode":
            MessageLookupByLibrary.simpleMessage("QR-code weergeven"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Lijst van behandelaars"),
        "practitionerNew_cancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "practitionerNew_cet_ecran_permet":
            MessageLookupByLibrary.simpleMessage(
                "Via dit scherm kunt u een behandelaar aanmaken."),
        "practitionerNew_create":
            MessageLookupByLibrary.simpleMessage("Aanmaken"),
        "practitionerNew_displayName":
            MessageLookupByLibrary.simpleMessage("Weergegeven naam"),
        "practitionerNew_displayNameRequired":
            MessageLookupByLibrary.simpleMessage(
                "Het weergegeven naamveld is verplicht"),
        "practitionerNew_editPractitioner":
            MessageLookupByLibrary.simpleMessage("De behandelaar wijzigen"),
        "practitionerNew_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "practitionerNew_firstName":
            MessageLookupByLibrary.simpleMessage("Voornaam"),
        "practitionerNew_lastName":
            MessageLookupByLibrary.simpleMessage("Naam"),
        "practitionerNew_newPractitioner":
            MessageLookupByLibrary.simpleMessage("Nieuwe behandelaar"),
        "practitionerNew_phone":
            MessageLookupByLibrary.simpleMessage("Telefoon"),
        "practitionerNew_professionalId": MessageLookupByLibrary.simpleMessage(
            "Professionele gebruikersnaam"),
        "practitionerNew_professionalIdHint":
            MessageLookupByLibrary.simpleMessage("RPPS, ADELI…"),
        "practitionerNew_save": MessageLookupByLibrary.simpleMessage("Opslaan"),
        "practitionerQr_close": MessageLookupByLibrary.simpleMessage("Sluiten"),
        "practitionerQr_defaultOrganizationName":
            MessageLookupByLibrary.simpleMessage("Kantoor"),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("ABAK-beroepsprofiel"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Scan deze QR-code via ABAK Mobile om dit professionele profiel automatisch toe te voegen."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("gearchiveerd"),
        "practitionerSelector_error": m21,
        "practitionerSelector_noSelection":
            MessageLookupByLibrary.simpleMessage("Geen selectie"),
        "preferences_archivedPatients":
            MessageLookupByLibrary.simpleMessage("Gearchiveerde patiënten"),
        "preferences_contextComment": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm worden de algemene instellingen van Companion weergegeven."),
        "preferences_contextName":
            MessageLookupByLibrary.simpleMessage("Gebruikersinstellingen"),
        "preferences_days": MessageLookupByLibrary.simpleMessage("dagen"),
        "preferences_expertMode":
            MessageLookupByLibrary.simpleMessage("Mode-expert"),
        "preferences_expertModeDescription":
            MessageLookupByLibrary.simpleMessage(
                "Toont technische informatie voor ontwikkelaars en bijdragers."),
        "preferences_expertModeSaved": MessageLookupByLibrary.simpleMessage(
            "Instelling van de Expert-modus opgeslagen."),
        "preferences_languageSaved":
            MessageLookupByLibrary.simpleMessage("Taal opgeslagen."),
        "preferences_organization":
            MessageLookupByLibrary.simpleMessage("Vestiging"),
        "preferences_organizationDescription":
            MessageLookupByLibrary.simpleMessage(
                "Naam, logo en algemene informatie."),
        "preferences_retentionDuration":
            MessageLookupByLibrary.simpleMessage("Houdbaarheid"),
        "preferences_retentionExplanation": MessageLookupByLibrary.simpleMessage(
            "Gearchiveerde patiënten kunnen gedurende deze periode worden hersteld. Daarna worden ze automatisch verwijderd."),
        "preferences_retentionSaved": MessageLookupByLibrary.simpleMessage(
            "Geregistreerde houdbaarheid."),
        "recentImportCard_conflict":
            MessageLookupByLibrary.simpleMessage("conflict"),
        "recentImportCard_error": MessageLookupByLibrary.simpleMessage("fout"),
        "recentImportCard_fichier":
            MessageLookupByLibrary.simpleMessage("bestand"),
        "recentImportCard_file":
            MessageLookupByLibrary.simpleMessage("bestand"),
        "recentImportCard_ignored":
            MessageLookupByLibrary.simpleMessage("genegeerd"),
        "recentImportCard_no_result_imported":
            MessageLookupByLibrary.simpleMessage(
                "Er zijn geen resultaten geïmporteerd"),
        "recentImportCard_result":
            MessageLookupByLibrary.simpleMessage("resultaat"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Het dashboard vernieuwen"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Archief van de verslagen"),
        "reset": MessageLookupByLibrary.simpleMessage("Resetten"),
        "resultDetail_addCommentHint":
            MessageLookupByLibrary.simpleMessage("Een opmerking toevoegen..."),
        "resultDetail_archiveConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Wilt u dit resultaat echt archiveren?"),
        "resultDetail_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Het resultaat archiveren"),
        "resultDetail_birthDate":
            MessageLookupByLibrary.simpleMessage("Geboorte"),
        "resultDetail_cancel": MessageLookupByLibrary.simpleMessage("Apparaat"),
        "resultDetail_clinicalComment":
            MessageLookupByLibrary.simpleMessage("Klinische opmerking"),
        "resultDetail_commentSaved":
            MessageLookupByLibrary.simpleMessage("Opmerking opgeslagen"),
        "resultDetail_detailedResult":
            MessageLookupByLibrary.simpleMessage("Gedetailleerd resultaat"),
        "resultDetail_device": MessageLookupByLibrary.simpleMessage(
            "Specificaties van het apparaat"),
        "resultDetail_exerciseDate":
            MessageLookupByLibrary.simpleMessage("Boekjaar"),
        "resultDetail_generalInformation":
            MessageLookupByLibrary.simpleMessage("Algemene informatie"),
        "resultDetail_identityUnverified": MessageLookupByLibrary.simpleMessage(
            "Identiteit niet geverifieerd"),
        "resultDetail_identityVerified":
            MessageLookupByLibrary.simpleMessage("Identiteit geverifieerd"),
        "resultDetail_import":
            MessageLookupByLibrary.simpleMessage("Importeren"),
        "resultDetail_lastModified":
            MessageLookupByLibrary.simpleMessage("Laatste wijziging"),
        "resultDetail_metrics": MessageLookupByLibrary.simpleMessage("Metriek"),
        "resultDetail_noMetrics": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen statistieken geregistreerd."),
        "resultDetail_patient": MessageLookupByLibrary.simpleMessage("Patiënt"),
        "resultDetail_performedBy":
            MessageLookupByLibrary.simpleMessage("Geregisseerd door"),
        "resultDetail_save": MessageLookupByLibrary.simpleMessage("Opslaan"),
        "resultDetail_score": MessageLookupByLibrary.simpleMessage("Score"),
        "resultDetail_syncState":
            MessageLookupByLibrary.simpleMessage("Synchronisatiestatus"),
        "settings_assistanceWarning": MessageLookupByLibrary.simpleMessage(
            "Deze functies zijn bedoeld voor installatie, diagnose en technische ondersteuning.\n\nGebruik ze alleen wanneer een technicus of de ABAK-documentatie u hierom vraagt."),
        "settings_cancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
        "settings_configuration":
            MessageLookupByLibrary.simpleMessage("Configuratie"),
        "settings_confirmationRequired":
            MessageLookupByLibrary.simpleMessage("Bevestiging verplicht"),
        "settings_contextComment": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm zijn de installatie-, diagnose- en onderhoudsfuncties van Companion gebundeld."),
        "settings_contextName": MessageLookupByLibrary.simpleMessage("Hulp"),
        "settings_continue": MessageLookupByLibrary.simpleMessage("Doorgaan"),
        "settings_databaseResetError": m22,
        "settings_databaseResetSuccess": MessageLookupByLibrary.simpleMessage(
            "Database gereset. Automatische back-up aangemaakt."),
        "settings_diagnostic": MessageLookupByLibrary.simpleMessage("Diagnose"),
        "settings_edit": MessageLookupByLibrary.simpleMessage("Wijzigen"),
        "settings_exchangeDirectory":
            MessageLookupByLibrary.simpleMessage("ABAK-uitwisselingsdossier"),
        "settings_exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Uitwisselingsdossier gereset"),
        "settings_exchangeDirectoryUpdated":
            MessageLookupByLibrary.simpleMessage(
                "Bijgewerkt ABAK-uitwisselingsdossier"),
        "settings_importAbakFile": MessageLookupByLibrary.simpleMessage(
            "Een .abak-bestand handmatig importeren"),
        "settings_invalidConfirmation":
            MessageLookupByLibrary.simpleMessage("Ongeldige bevestiging."),
        "settings_loading":
            MessageLookupByLibrary.simpleMessage("Bezig met laden..."),
        "settings_maintenance":
            MessageLookupByLibrary.simpleMessage("Onderhoud"),
        "settings_manageBackups":
            MessageLookupByLibrary.simpleMessage("Back-ups beheren"),
        "settings_noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Er is geen map gedefinieerd"),
        "settings_open": MessageLookupByLibrary.simpleMessage("Openen"),
        "settings_openingExchangeDirectory":
            MessageLookupByLibrary.simpleMessage(
                "Het uitwisselingsdossier wordt geopend"),
        "settings_reset": MessageLookupByLibrary.simpleMessage("Resetten"),
        "settings_resetDatabase":
            MessageLookupByLibrary.simpleMessage("Het basisstation resetten"),
        "settings_resetDatabaseTitle": MessageLookupByLibrary.simpleMessage(
            "Het lokale basisstation resetten?"),
        "settings_resetDatabaseWarning": MessageLookupByLibrary.simpleMessage(
            "Hierdoor worden alle lokale gegevens (patiënten, resultaten, geïmporteerde gegevens en geschiedenis) gewist.\n\nVóór het resetten wordt er automatisch een back-up gemaakt.\n\nGebruik deze functie uitsluitend in het kader van technische ondersteuning."),
        "settings_resetKeyword": MessageLookupByLibrary.simpleMessage("RESET"),
        "settings_resetTooltip":
            MessageLookupByLibrary.simpleMessage("Resetten"),
        "settings_resolveImportProblem":
            MessageLookupByLibrary.simpleMessage("Een importprobleem oplossen"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Hulp"),
        "settings_typeResetConfirmation": MessageLookupByLibrary.simpleMessage(
            "Typ RESET om definitief te bevestigen."),
        "settings_vitaleDiagnostic": MessageLookupByLibrary.simpleMessage(
            "Diagnose van de Carte Vitale"),
        "smartCardDiagnostic": MessageLookupByLibrary.simpleMessage(
            "Diagnose van de Carte Vitale"),
        "systemOverviewBar_active_patients":
            MessageLookupByLibrary.simpleMessage("Actieve patiënten"),
        "systemOverviewBar_alert":
            MessageLookupByLibrary.simpleMessage("Waarschuwingen"),
        "systemOverviewBar_archived_patients":
            MessageLookupByLibrary.simpleMessage("Gearchiveerde patiënten"),
        "systemOverviewBar_loading_system_summary":
            MessageLookupByLibrary.simpleMessage(
                "Systeemoverzicht wordt geladen..."),
        "systemOverviewBar_supervision_error":
            MessageLookupByLibrary.simpleMessage("Fout in het toezicht"),
        "systemOverviewBar_supervision_unavailable":
            MessageLookupByLibrary.simpleMessage("Toezicht niet beschikbaar"),
        "systemStatusCard_nome": MessageLookupByLibrary.simpleMessage("Geen"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Gebruikersinstellingen"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Gebruikersinstellingen"),
        "vitaleBeneficiarySelector_cancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage("Kies een begunstigde"),
        "vitaleIdentity_birthDate":
            MessageLookupByLibrary.simpleMessage("Geboortedatum"),
        "vitaleIdentity_dataMasked":
            MessageLookupByLibrary.simpleMessage("verborgen gegevens"),
        "vitaleIdentity_detected":
            MessageLookupByLibrary.simpleMessage("gedetecteerd"),
        "vitaleIdentity_female":
            MessageLookupByLibrary.simpleMessage("Vrouwelijk"),
        "vitaleIdentity_firstName":
            MessageLookupByLibrary.simpleMessage("Voornaam"),
        "vitaleIdentity_identityRead":
            MessageLookupByLibrary.simpleMessage("Identiteit gelezen"),
        "vitaleIdentity_identityReceivedMasked":
            MessageLookupByLibrary.simpleMessage(
                "ontvangen identiteitsgegevens (persoonsgegevens verborgen)"),
        "vitaleIdentity_identityUnavailable":
            MessageLookupByLibrary.simpleMessage("identiteit niet beschikbaar"),
        "vitaleIdentity_lastName": MessageLookupByLibrary.simpleMessage("Naam"),
        "vitaleIdentity_male":
            MessageLookupByLibrary.simpleMessage("Mannelijk"),
        "vitaleIdentity_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "vitaleIdentity_noIdentityAvailable":
            MessageLookupByLibrary.simpleMessage(
                "Er is geen Carte Vitale-identiteitsnummer beschikbaar"),
        "vitaleIdentity_notProvided":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "vitaleIdentity_other": MessageLookupByLibrary.simpleMessage("Overig"),
        "vitaleIdentity_reading":
            MessageLookupByLibrary.simpleMessage("Wordt geladen..."),
        "vitaleIdentity_sex": MessageLookupByLibrary.simpleMessage("Seks"),
        "vitaleIdentity_source": MessageLookupByLibrary.simpleMessage("Bron"),
        "vitaleIdentity_title": MessageLookupByLibrary.simpleMessage(
            "Identiteit van de Carte Vitale lezen"),
        "vitaleIdentity_unavailable":
            MessageLookupByLibrary.simpleMessage("niet beschikbaar"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Gebruik dit om een patiënt aan te maken")
      };
}
