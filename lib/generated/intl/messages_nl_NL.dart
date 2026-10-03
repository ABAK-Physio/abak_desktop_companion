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

  static String m0(careEpisodeId) =>
      "Patiënt niet gevonden voor de zorgafhandeling ${careEpisodeId}.";

  static String m1(height) => "${height} cm";

  static String m2(weight) => "${weight} kg";

  static String m3(age) => "${age} jaar";

  static String m4(path) => "Toegang tot het dossier verlenen: ${path}";

  static String m5(path) =>
      "Kies de map waarin de documenten uit ${path} moeten worden hersteld:";

  static String m6(size) => "${size}";

  static String m7(date) => "Gearchiveerd op ${date}";

  static String m8(monthYear) => "Opname in de open zorg in ${monthYear}";

  static String m9(title) =>
      "Het overzicht „${title}“ wordt niet meer weergegeven in de geschiedenis.";

  static String m10(title) =>
      "Het rapport „${title}“ wordt naar de prullenbak verplaatst. Het kan later worden hersteld.";

  static String m11(patientName, title) => "Bilan_${patientName}_${title}";

  static String m12(title) => "Kopie van ${title}";

  static String m13(title) =>
      "Het overzicht „${title}“ wordt definitief verwijderd. Deze handeling kan niet ongedaan worden gemaakt.";

  static String m14(title) =>
      "Het rapport „${title}“ wordt definitief verwijderd. Deze handeling kan niet ongedaan worden gemaakt.";

  static String m15(path) =>
      "\"careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": \"Le dossier configuré n’est pas accessible ou son autorisation doit être renouvelée.\n\n${path}\n\nReconnectez son volume si nécessaire, puis sélectionnez ce dossier pour autoriser son accès. Le dossier sélectionné sera enregistré dans vos préférences.\",\n\"@careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": {\n  \"placeholders\": {\n    \"path\": {\n      \"type\": \"String\"\n    }\n  }\n}";

  static String m16(documentLabel) =>
      "Er bestaat al een conceptversie van dit ${documentLabel}-sjabloon.";

  static String m17(documentLabel) =>
      "Wilt u de gegenereerde inhoud toevoegen aan het huidige ${documentLabel} of de bestaande inhoud vervangen?";

  static String m18(documentLabel) => "Nieuw ${documentLabel}";

  static String m19(patientName, title) => "Rapport_${patientName}_${title}";

  static String m20(path) => "Aangemaakt Word-document: ${path}";

  static String m21(error) =>
      "Fout bij het aanmaken van het Word-document: ${error}";

  static String m22(patientName) =>
      "${patientName} — Beoordelingen en rapporten";

  static String m23(deviceName) => "Wilt u ${deviceName} echt archiveren?";

  static String m24(fieldName) => "Het veld \"${fieldName}\" is verplicht.";

  static String m25(noteTitle) =>
      "De notitie \"${noteTitle}\" wordt niet meer weergegeven.";

  static String m26(error) => "Fout bij het opslaan: ${error}";

  static String m27(count) => "${count} andere oefening(en)";

  static String m28(count) => "${count} vereniging(en) in afwachting";

  static String m29(count) => "${count} back-ups";

  static String m30(size) => "Maat: ${size}";

  static String m31(size) => "Totale afmeting: ${size}";

  static String m32(version) => "Versie ${version}";

  static String m33(integrityStatus) =>
      "De gerestaureerde database vertoont een afwijking: ${integrityStatus}";

  static String m34(error) => "Herstel mislukt: ${error}";

  static String m35(integrityStatus) =>
      "Het herstel is voltooid, maar integrity_check heeft het volgende geretourneerd: ${integrityStatus}";

  static String m36(patientName) =>
      "Wilt u ${patientName} echt archiveren? Hij/zij wordt dan niet meer in de actieve lijst weergegeven.";

  static String m37(patientName) => "${patientName} gearchiveerd.";

  static String m38(error) => "Fout: ${error}";

  static String m39(patientName) =>
      "${patientName} is weer toegevoegd aan de actieve lijst.";

  static String m40(patientName) =>
      "Vitale-kaart gekoppeld aan de patiënt ${patientName}.";

  static String m41(patientName) => "De patiënt ${patientName} is hersteld.";

  static String m42(practitionerName) =>
      "Wilt u ${practitionerName} echt archiveren?";

  static String m43(date) => "Gearchiveerd op ${date}";

  static String m44(error) => "Fout: ${error}";

  static String m45(professionalId) => "ID pro: ${professionalId}";

  static String m46(error) => "Fout: ${error}";

  static String m47(name) => "${name} — gearchiveerd";

  static String m48(start, end) => "Je ${start} tot ${end}";

  static String m49(error) =>
      "Fout bij het laden van de geschiedenis: ${error}";

  static String m50(start) => "Vanaf ${start}";

  static String m51(error) => "Fout bij het resetten: ${error}";

  static String m52(patientCount, fileCount) =>
      "Export voltooid: ${patientCount} patiënt(en), ${fileCount} bestand(en).";

  static String m53(errorCount, patientCount, fileCount) =>
      "Export voltooid met ${errorCount} fout(en): ${patientCount} patiënt(en), ${fileCount} bestand(en) geëxporteerd.";

  static String m54(error) => "Het spraakdictee is mislukt: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "abakWhisperSpeechProvider_name":
            MessageLookupByLibrary.simpleMessage("ABAK Spraakgestuurd dictee"),
        "archivedDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Dit overzicht bevat de gearchiveerde balansen en rapporten van de behandeling. Elke regel geeft het type document, de titel en de archiveringsdatum weer.\n\nMet de actie ‘Terugzetten’ kunt u het document weer toevoegen aan de geschiedenis van de balansen of rapporten.\n\nMet de actie ‘Definitief verwijderen’ wordt het document uit Companion verwijderd. Lees het bevestigingsbericht aandachtig door voordat u bevestigt: het document kan vanuit deze lijst niet meer worden hersteld.\n\nKlik op het kruisje om het vergrote scherm te sluiten en terug te keren naar het gedeelte Balansen/Rapporten."),
        "assessmentChartImageService_insufficientPoints":
            MessageLookupByLibrary.simpleMessage(
                "Een grafische reeks moet uit ten minste twee punten bestaan."),
        "assessmentChartImageService_pngConversionError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om de grafiek om te zetten naar een PNG-afbeelding."),
        "assessmentDocumentDataBuilder_female":
            MessageLookupByLibrary.simpleMessage("Vrouwelijk"),
        "assessmentDocumentDataBuilder_male":
            MessageLookupByLibrary.simpleMessage("Mannelijk"),
        "assessmentDocumentDataBuilder_patient": m0,
        "assessmentDocxService_age":
            MessageLookupByLibrary.simpleMessage("Leeftijd"),
        "assessmentDocxService_assessment":
            MessageLookupByLibrary.simpleMessage("met"),
        "assessmentDocxService_attachment":
            MessageLookupByLibrary.simpleMessage(
                "Pathologie bij de aansluiting"),
        "assessmentDocxService_author":
            MessageLookupByLibrary.simpleMessage("Redacteur"),
        "assessmentDocxService_centimetres": m1,
        "assessmentDocxService_chart":
            MessageLookupByLibrary.simpleMessage("Grafiek"),
        "assessmentDocxService_declared": MessageLookupByLibrary.simpleMessage(
            "Leeftijd opgegeven bij de test"),
        "assessmentDocxService_diagnosis":
            MessageLookupByLibrary.simpleMessage("Afwijkingen tijdens de test"),
        "assessmentDocxService_dominance":
            MessageLookupByLibrary.simpleMessage("Dominante kant"),
        "assessmentDocxService_establishment":
            MessageLookupByLibrary.simpleMessage("Vestiging"),
        "assessmentDocxService_firstname":
            MessageLookupByLibrary.simpleMessage("Voornaam"),
        "assessmentDocxService_height":
            MessageLookupByLibrary.simpleMessage("Grootte"),
        "assessmentDocxService_information":
            MessageLookupByLibrary.simpleMessage("Informatie over de patiënt"),
        "assessmentDocxService_kilograms": m2,
        "assessmentDocxService_notes": MessageLookupByLibrary.simpleMessage(
            "Geselecteerde opvolgingsnotities"),
        "assessmentDocxService_opened": MessageLookupByLibrary.simpleMessage(
            "Ondersteuning beschikbaar vanaf"),
        "assessmentDocxService_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "assessmentDocxService_patient":
            MessageLookupByLibrary.simpleMessage("Patiënt"),
        "assessmentDocxService_performed":
            MessageLookupByLibrary.simpleMessage("Gemaakt op"),
        "assessmentDocxService_practitioner":
            MessageLookupByLibrary.simpleMessage(
                "Verantwoordelijke fysiotherapeut"),
        "assessmentDocxService_printed":
            MessageLookupByLibrary.simpleMessage("Afgedrukt op"),
        "assessmentDocxService_profession":
            MessageLookupByLibrary.simpleMessage("Beroep"),
        "assessmentDocxService_recipients":
            MessageLookupByLibrary.simpleMessage("Ontvanger(s)"),
        "assessmentDocxService_results":
            MessageLookupByLibrary.simpleMessage("Testresultaten"),
        "assessmentDocxService_sex":
            MessageLookupByLibrary.simpleMessage("Seks"),
        "assessmentDocxService_sport":
            MessageLookupByLibrary.simpleMessage("Sportactiviteit"),
        "assessmentDocxService_surname":
            MessageLookupByLibrary.simpleMessage("Naam"),
        "assessmentDocxService_title":
            MessageLookupByLibrary.simpleMessage("met"),
        "assessmentDocxService_weight":
            MessageLookupByLibrary.simpleMessage("Gewicht"),
        "assessmentDocxService_years": m3,
        "assessmentDraft_help": MessageLookupByLibrary.simpleMessage(
            "De weergegeven tekst is een automatisch opgeslagen concept. U kunt deze behouden, wijzigen of verwijderen voordat u uw balans opslaat."),
        "assessmentDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Inzicht krijgen in het concept van de balans"),
        "assessmentHistory_help": MessageLookupByLibrary.simpleMessage(
            "Dit overzicht toont de geregistreerde balansen voor de zorgverlening, met hun titel en datum.\n\nMet de acties in elke rij kunt u een balans wijzigen, dupliceren of verplaatsen naar de gearchiveerde documenten.\n\nWanneer een balans is geopend om te worden gewijzigd, gebruikt u de actie ‘Bijwerken’ om uw wijzigingen op te slaan. Met de beschikbare knoppen kunt u ook de wijzigingen ongedaan maken of terugkeren naar het concept.\n\nHet verplaatsen naar de gearchiveerde documenten is geen definitieve verwijdering.\n\nKlik op het kruisje om het vergrote scherm te sluiten en terug te keren naar het gedeelte Balansen/Rapporten."),
        "backupArchive_authorizeFolder": m4,
        "backupArchive_busy": MessageLookupByLibrary.simpleMessage(
            "\"Er is al een back-up of herstelbewerking aan de gang.\""),
        "backupArchive_chooseFile":
            MessageLookupByLibrary.simpleMessage("Een back-up openen…"),
        "backupArchive_legacy": MessageLookupByLibrary.simpleMessage(
            "Deze oude back-up bevat alleen de database. De bestanden uit de patiëntendossiers zijn niet hersteld."),
        "backupArchive_restoreFolder": m5,
        "backupArchive_resultTitle": MessageLookupByLibrary.simpleMessage(
            "Resultaat van de restauratie"),
        "backupArchive_safetyCopies":
            MessageLookupByLibrary.simpleMessage("Bewaarde back-ups:"),
        "backupArchive_working": MessageLookupByLibrary.simpleMessage(
            "Er wordt een back-up gemaakt of een herstel uitgevoerd… Even geduld a.u.b."),
        "backupHistory_cancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "Er is geen back-up opgeslagen."),
        "backupHistory_fileSize": m6,
        "backupHistory_help": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm worden de back-ups weergegeven die in Companion zijn opgeslagen. Elke regel geeft de bestandsnaam, de aanmaakdatum, de bestandsgrootte en de locatie weer.\n\nMet de knop ‘Herstellen’ kunt u de huidige database vervangen door die uit de geselecteerde back-up. Gegevens die na deze back-up zijn toegevoegd of gewijzigd, zullen dus niet in de herstelde database aanwezig zijn.\n\nControleer de datum van de back-up en lees het bevestigingsbericht voordat u doorgaat. Er wordt een back-up van de huidige database gemaakt voordat deze wordt vervangen.\n\nHet back-upbestand moet altijd toegankelijk zijn op de aangegeven locatie. Als het is verplaatst of verwijderd, kan het herstel niet worden uitgevoerd.\n\nGebruik de actie ‘Back-up maken’ op de startpagina om een nieuwe back-up te maken."),
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Herstellen"),
        "backupHistory_restoreTitle":
            MessageLookupByLibrary.simpleMessage("Deze back-up herstellen?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Deze bewerking zal de huidige database volledig vervangen.\n\nEr wordt een automatische back-up gemaakt voordat het herstel wordt uitgevoerd.\n\nDoorgaan?"),
        "backupHistory_title":
            MessageLookupByLibrary.simpleMessage("Overzicht van back-ups"),
        "bodymap_help": MessageLookupByLibrary.simpleMessage(
            "Met de pijnkaart kunt u de pijnlijke zones van de patiënt in kaart brengen voor de lopende zorgperiode.\n\nKies een weergave, klik vervolgens op een gebied van het silhouet of selecteer het in de lijst. U kunt een opmerking toevoegen en, indien nodig, een intensiteit van 0 tot 10 aangeven. Gebruik de prullenbak om een gebied uit het rapport te verwijderen.\n\nKlik op ‘Opslaan’ om uw rapport in Companion op te slaan. Wanneer u het scherm verlaat met niet-opgeslagen wijzigingen, kunt u kiezen of u deze wilt opslaan of negeren.\n\nMet ‘Beide kaarten exporteren’ wordt een PNG-afbeelding aangemaakt op de door u gekozen locatie op uw computer. Deze export vervangt het opslaan van de meting niet.\n\nDeze module is een eerste voorstel, dat op basis van uw feedback verder zal worden ontwikkeld. Test het in de praktijk en geef aan welke mogelijkheden u graag toegevoegd of verbeterd zou willen zien."),
        "bodymap_title": MessageLookupByLibrary.simpleMessage("Pijnkaart"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Oorsprong ABAK"),
        "careEpisodeDetail_detail_de_la_prise_en_charge":
            MessageLookupByLibrary.simpleMessage("Overzicht van de vergoeding"),
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
        "careEpisodePanel_archive":
            MessageLookupByLibrary.simpleMessage("Archiveren"),
        "careEpisodePanel_archiveCareEpisode":
            MessageLookupByLibrary.simpleMessage("De behandeling archiveren"),
        "careEpisodePanel_archiveCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om de behandeling te archiveren. Probeer het nog eens."),
        "careEpisodePanel_archiveCareEpisodeMessage":
            MessageLookupByLibrary.simpleMessage(
                "Deze zorgregeling wordt uit de lijst geschrapt. De gegevens ervan worden gearchiveerd."),
        "careEpisodePanel_archiveCareEpisodeTitle":
            MessageLookupByLibrary.simpleMessage(
                "Deze behandeling archiveren?"),
        "careEpisodePanel_archivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage("Gearchiveerde vergoedingen"),
        "careEpisodePanel_archivedCareEpisodesHelp":
            MessageLookupByLibrary.simpleMessage(
                "Hier vindt u uw gearchiveerde zorgbehandelingen."),
        "careEpisodePanel_archivedOn": m7,
        "careEpisodePanel_careEpisodeArchived":
            MessageLookupByLibrary.simpleMessage("Verwerking voltooid."),
        "careEpisodePanel_careEpisodeOpenedIn": m8,
        "careEpisodePanel_careEpisodeRestored":
            MessageLookupByLibrary.simpleMessage(
                "De ondersteuning is hersteld."),
        "careEpisodePanel_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Vergoedingen"),
        "careEpisodePanel_choose":
            MessageLookupByLibrary.simpleMessage("Kiezen"),
        "careEpisodePanel_edit":
            MessageLookupByLibrary.simpleMessage("Wijzigen"),
        "careEpisodePanel_loadCareEpisodesError":
            MessageLookupByLibrary.simpleMessage(
                "De vergoedingen kunnen niet worden geladen."),
        "careEpisodePanel_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Nieuwe dekking"),
        "careEpisodePanel_noArchivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage(
                "Er zijn geen gearchiveerde behandelingen voor deze patiënt."),
        "careEpisodePanel_noCareEpisodes": MessageLookupByLibrary.simpleMessage(
            "Er is geen zorgplan aangemaakt voor deze patiënt."),
        "careEpisodePanel_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Voorschrijvende arts"),
        "careEpisodePanel_restore":
            MessageLookupByLibrary.simpleMessage("Herstellen"),
        "careEpisodePanel_restoreCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "De ondersteuning kan niet worden hersteld. Probeer het nogmaals."),
        "careEpisodeReportsWorkspaceScreen_add":
            MessageLookupByLibrary.simpleMessage("Toevoegen"),
        "careEpisodeReportsWorkspaceScreen_append":
            MessageLookupByLibrary.simpleMessage("Toevoegen aan de lijst"),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Het lukt niet om het jaarverslag naar de prullenbak te verplaatsen."),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentMessage": m9,
        "careEpisodeReportsWorkspaceScreen_archiveReportError":
            MessageLookupByLibrary.simpleMessage(
                "Het lukt niet om het rapport naar de prullenbak te verplaatsen."),
        "careEpisodeReportsWorkspaceScreen_archiveReportMessage": m10,
        "careEpisodeReportsWorkspaceScreen_assessmentFileName": m11,
        "careEpisodeReportsWorkspaceScreen_assessmentLabel":
            MessageLookupByLibrary.simpleMessage("met"),
        "careEpisodeReportsWorkspaceScreen_assessmentNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Het overzicht is nergens te vinden."),
        "careEpisodeReportsWorkspaceScreen_assessmentReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Uw overzicht is klaar. Het DOCX-bestand bevat alle ingevoerde gegevens en de geselecteerde items."),
        "careEpisodeReportsWorkspaceScreen_assessmentTitle":
            MessageLookupByLibrary.simpleMessage("Titel van de balans"),
        "careEpisodeReportsWorkspaceScreen_assessmentsAndReports":
            MessageLookupByLibrary.simpleMessage("Verslagen en rapporten"),
        "careEpisodeReportsWorkspaceScreen_author":
            MessageLookupByLibrary.simpleMessage("Redacteur"),
        "careEpisodeReportsWorkspaceScreen_authorizeDirectory":
            MessageLookupByLibrary.simpleMessage("Een map toestaan"),
        "careEpisodeReportsWorkspaceScreen_cancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "careEpisodeReportsWorkspaceScreen_cancelChangesError":
            MessageLookupByLibrary.simpleMessage(
                "De wijzigingen kunnen niet ongedaan worden gemaakt."),
        "careEpisodeReportsWorkspaceScreen_cancelReportChangesError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om de wijzigingen in het rapport ongedaan te maken."),
        "careEpisodeReportsWorkspaceScreen_close":
            MessageLookupByLibrary.simpleMessage("Sluiten"),
        "careEpisodeReportsWorkspaceScreen_confirm":
            MessageLookupByLibrary.simpleMessage("Bevestigen"),
        "careEpisodeReportsWorkspaceScreen_copyTitle": m12,
        "careEpisodeReportsWorkspaceScreen_createNew":
            MessageLookupByLibrary.simpleMessage("Een nieuwe aanmaken"),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om de balans definitief te verwijderen."),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentMessage": m13,
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "De balans definitief verwijderen?"),
        "careEpisodeReportsWorkspaceScreen_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Definitief verwijderen"),
        "careEpisodeReportsWorkspaceScreen_deleteReportError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om het rapport definitief te verwijderen."),
        "careEpisodeReportsWorkspaceScreen_deleteReportMessage": m14,
        "careEpisodeReportsWorkspaceScreen_deleteReportTitle":
            MessageLookupByLibrary.simpleMessage(
                "Het rapport definitief verwijderen?"),
        "careEpisodeReportsWorkspaceScreen_directoryAccessMessage": m15,
        "careEpisodeReportsWorkspaceScreen_duplicate":
            MessageLookupByLibrary.simpleMessage("Dupliceren"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessment":
            MessageLookupByLibrary.simpleMessage("De balans dupliceren"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om de balans te dupliceren."),
        "careEpisodeReportsWorkspaceScreen_duplicateReport":
            MessageLookupByLibrary.simpleMessage("Het rapport dupliceren"),
        "careEpisodeReportsWorkspaceScreen_duplicateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Het rapport kan niet worden gekopieerd."),
        "careEpisodeReportsWorkspaceScreen_existingAssessmentDocx":
            MessageLookupByLibrary.simpleMessage(
                "Aan dit verslag is al een DOCX-bestand gekoppeld. Wilt u het bestaande bestand vervangen of een nieuw bestand aanmaken?"),
        "careEpisodeReportsWorkspaceScreen_existingReportDocx":
            MessageLookupByLibrary.simpleMessage(
                "Aan dit rapport is al een DOCX-bestand gekoppeld. Wilt u het bestaande bestand vervangen of een nieuw bestand aanmaken?"),
        "careEpisodeReportsWorkspaceScreen_existingTemplateDraftMessage": m16,
        "careEpisodeReportsWorkspaceScreen_generate":
            MessageLookupByLibrary.simpleMessage("Genereren"),
        "careEpisodeReportsWorkspaceScreen_generateDocx":
            MessageLookupByLibrary.simpleMessage("DOCX-bestand genereren"),
        "careEpisodeReportsWorkspaceScreen_insertTextMessage": m17,
        "careEpisodeReportsWorkspaceScreen_managePractitioners":
            MessageLookupByLibrary.simpleMessage("Fysiotherapeuten beheren"),
        "careEpisodeReportsWorkspaceScreen_managePrescribingDoctors":
            MessageLookupByLibrary.simpleMessage(
                "De voorschrijvende artsen beheren"),
        "careEpisodeReportsWorkspaceScreen_moveToTrash":
            MessageLookupByLibrary.simpleMessage(
                "Naar de prullenbak verplaatsen"),
        "careEpisodeReportsWorkspaceScreen_newAssessment":
            MessageLookupByLibrary.simpleMessage("Nieuwe balans"),
        "careEpisodeReportsWorkspaceScreen_newAssessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "Titel van het nieuwe overzicht"),
        "careEpisodeReportsWorkspaceScreen_newDocument": m18,
        "careEpisodeReportsWorkspaceScreen_newReport":
            MessageLookupByLibrary.simpleMessage("Nieuw rapport"),
        "careEpisodeReportsWorkspaceScreen_newReportTitle":
            MessageLookupByLibrary.simpleMessage(
                "Titel van het nieuwe rapport"),
        "careEpisodeReportsWorkspaceScreen_note":
            MessageLookupByLibrary.simpleMessage("Opmerking"),
        "careEpisodeReportsWorkspaceScreen_openReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Het lukt niet om het concept van het rapport te openen."),
        "careEpisodeReportsWorkspaceScreen_openReportError":
            MessageLookupByLibrary.simpleMessage(
                "Het rapport kan niet worden geopend."),
        "careEpisodeReportsWorkspaceScreen_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Voorschrijvende arts"),
        "careEpisodeReportsWorkspaceScreen_recipients":
            MessageLookupByLibrary.simpleMessage("Ontvanger(s)"),
        "careEpisodeReportsWorkspaceScreen_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Verantwoordelijke fysiotherapeut"),
        "careEpisodeReportsWorkspaceScreen_replace":
            MessageLookupByLibrary.simpleMessage("Vervangen"),
        "careEpisodeReportsWorkspaceScreen_reportFileName": m19,
        "careEpisodeReportsWorkspaceScreen_reportLabel":
            MessageLookupByLibrary.simpleMessage("rapport"),
        "careEpisodeReportsWorkspaceScreen_reportNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Het rapport is nergens te vinden."),
        "careEpisodeReportsWorkspaceScreen_reportOptionsTitle":
            MessageLookupByLibrary.simpleMessage("Rapportopties"),
        "careEpisodeReportsWorkspaceScreen_reportReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Uw rapport is klaar. Het DOCX-bestand bevat de gegevens van de patiënt, de opsteller en de contactpersoon."),
        "careEpisodeReportsWorkspaceScreen_reportTitle":
            MessageLookupByLibrary.simpleMessage("Titel van het rapport"),
        "careEpisodeReportsWorkspaceScreen_restoreAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om de balans te herstellen"),
        "careEpisodeReportsWorkspaceScreen_restoreReportError":
            MessageLookupByLibrary.simpleMessage(
                "Het rapport kan niet worden hersteld."),
        "careEpisodeReportsWorkspaceScreen_resumeAssessmentDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Een werk in uitvoering is al automatisch opgeslagen.<br><br>Wilt u dit concept hervatten of een nieuwe balans beginnen?"),
        "careEpisodeReportsWorkspaceScreen_resumeDraft":
            MessageLookupByLibrary.simpleMessage("Het concept hervatten"),
        "careEpisodeReportsWorkspaceScreen_resumeReportDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Een werk in uitvoering is al automatisch opgeslagen.<br><br>Wilt u dit concept hervatten of een nieuw rapport beginnen?"),
        "careEpisodeReportsWorkspaceScreen_returnToDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om terug te gaan naar het concept."),
        "careEpisodeReportsWorkspaceScreen_returnToReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om terug te gaan naar het concept van het rapport."),
        "careEpisodeReportsWorkspaceScreen_save":
            MessageLookupByLibrary.simpleMessage("Opslaan"),
        "careEpisodeReportsWorkspaceScreen_saveAssessment":
            MessageLookupByLibrary.simpleMessage("De balans opslaan"),
        "careEpisodeReportsWorkspaceScreen_saveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om de balans op te slaan."),
        "careEpisodeReportsWorkspaceScreen_saveNoteSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om de geselecteerde noot op te nemen."),
        "careEpisodeReportsWorkspaceScreen_saveReport":
            MessageLookupByLibrary.simpleMessage("Het rapport opslaan"),
        "careEpisodeReportsWorkspaceScreen_saveReportError":
            MessageLookupByLibrary.simpleMessage(
                "Het rapport kan niet worden opgeslagen."),
        "careEpisodeReportsWorkspaceScreen_saveTestSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "De testselectie kan niet worden opgeslagen."),
        "careEpisodeReportsWorkspaceScreen_showPrescriber":
            MessageLookupByLibrary.simpleMessage("De voorschrijver weergeven"),
        "careEpisodeReportsWorkspaceScreen_showReferringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "De behandelend fysiotherapeut weergeven"),
        "careEpisodeReportsWorkspaceScreen_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Vulveld voor het SOAP-verslag.<br><br>S — Subjectief<br><br>O — Objectief<br><br>A — Analyse<br><br>P — Plan"),
        "careEpisodeReportsWorkspaceScreen_title":
            MessageLookupByLibrary.simpleMessage("Titel"),
        "careEpisodeReportsWorkspaceScreen_update":
            MessageLookupByLibrary.simpleMessage("Bijwerken"),
        "careEpisodeReportsWorkspaceScreen_updateAssessment":
            MessageLookupByLibrary.simpleMessage("De balans bijwerken"),
        "careEpisodeReportsWorkspaceScreen_updateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Het is niet mogelijk om de balans bij te werken."),
        "careEpisodeReportsWorkspaceScreen_updateReport":
            MessageLookupByLibrary.simpleMessage("Het rapport bijwerken"),
        "careEpisodeReportsWorkspaceScreen_updateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Het rapport kan niet worden bijgewerkt."),
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreated": m20,
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreationError": m21,
        "careEpisodeReportsWorkspaceScreen_workspaceTitle": m22,
        "careEpisodeReportsWorkspace_addFollowUpNote":
            MessageLookupByLibrary.simpleMessage(
                "Een opvolgingsnotitie toevoegen"),
        "careEpisodeReportsWorkspace_archived":
            MessageLookupByLibrary.simpleMessage("gearchiveerd"),
        "careEpisodeReportsWorkspace_archivedDocuments":
            MessageLookupByLibrary.simpleMessage("Gearchiveerde documenten"),
        "careEpisodeReportsWorkspace_archivedDocumentsCount":
            MessageLookupByLibrary.simpleMessage("Gearchiveerde documenten"),
        "careEpisodeReportsWorkspace_assessment":
            MessageLookupByLibrary.simpleMessage("met"),
        "careEpisodeReportsWorkspace_assessmentCount":
            MessageLookupByLibrary.simpleMessage("Aantal balansen"),
        "careEpisodeReportsWorkspace_assessmentHistory":
            MessageLookupByLibrary.simpleMessage("Overzicht van de balansen"),
        "careEpisodeReportsWorkspace_assessmentsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "De balansen kunnen niet worden geladen."),
        "careEpisodeReportsWorkspace_cancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "careEpisodeReportsWorkspace_cancelChanges":
            MessageLookupByLibrary.simpleMessage("Wijzigingen ongedaan maken"),
        "careEpisodeReportsWorkspace_createOrResumeAssessment":
            MessageLookupByLibrary.simpleMessage(
                "Een balans aanmaken of overnemen"),
        "careEpisodeReportsWorkspace_createOrResumeReport":
            MessageLookupByLibrary.simpleMessage(
                "Een rapport aanmaken of openen"),
        "careEpisodeReportsWorkspace_date":
            MessageLookupByLibrary.simpleMessage("Gegevens"),
        "careEpisodeReportsWorkspace_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Definitief verwijderen"),
        "careEpisodeReportsWorkspace_duplicate":
            MessageLookupByLibrary.simpleMessage("Dupliceren"),
        "careEpisodeReportsWorkspace_edit":
            MessageLookupByLibrary.simpleMessage("Wijzigen"),
        "careEpisodeReportsWorkspace_editReferringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "De behandelende fysiotherapeut wijzigen"),
        "careEpisodeReportsWorkspace_episodeDocuments":
            MessageLookupByLibrary.simpleMessage(
                "Documenten met betrekking tot de behandeling"),
        "careEpisodeReportsWorkspace_episodeSummary":
            MessageLookupByLibrary.simpleMessage(
                "Samenvatting van de aflevering"),
        "careEpisodeReportsWorkspace_expand":
            MessageLookupByLibrary.simpleMessage("Vergroten"),
        "careEpisodeReportsWorkspace_expandEditor":
            MessageLookupByLibrary.simpleMessage("Het schrijfgebied vergroten"),
        "careEpisodeReportsWorkspace_followUpNoteDefaultTitle":
            MessageLookupByLibrary.simpleMessage("Volgnota"),
        "careEpisodeReportsWorkspace_followUpNotes":
            MessageLookupByLibrary.simpleMessage("Opvolgnota’s"),
        "careEpisodeReportsWorkspace_followUpNotesLoadError":
            MessageLookupByLibrary.simpleMessage(
                "De follow-upnotities kunnen niet worden geladen."),
        "careEpisodeReportsWorkspace_include":
            MessageLookupByLibrary.simpleMessage("Opnemen"),
        "careEpisodeReportsWorkspace_latestTests":
            MessageLookupByLibrary.simpleMessage(
                "Uitgevoerde tests (laatste resultaat)"),
        "careEpisodeReportsWorkspace_loading":
            MessageLookupByLibrary.simpleMessage("Bezig met laden…"),
        "careEpisodeReportsWorkspace_moveToTrash":
            MessageLookupByLibrary.simpleMessage(
                "Naar de prullenbak verplaatsen"),
        "careEpisodeReportsWorkspace_name":
            MessageLookupByLibrary.simpleMessage("Naam"),
        "careEpisodeReportsWorkspace_newAssessment":
            MessageLookupByLibrary.simpleMessage("Overzicht (nieuw)"),
        "careEpisodeReportsWorkspace_noAssessments":
            MessageLookupByLibrary.simpleMessage(
                "Er zijn geen resultaten geregistreerd."),
        "careEpisodeReportsWorkspace_noDocument":
            MessageLookupByLibrary.simpleMessage("Geen documenten"),
        "careEpisodeReportsWorkspace_noFollowUpNotes":
            MessageLookupByLibrary.simpleMessage("Geen vervolgopmerking."),
        "careEpisodeReportsWorkspace_noReports":
            MessageLookupByLibrary.simpleMessage(
                "Er zijn geen rapporten geregistreerd."),
        "careEpisodeReportsWorkspace_noTests":
            MessageLookupByLibrary.simpleMessage(
                "Voor deze aflevering zijn geen tests uitgevoerd."),
        "careEpisodeReportsWorkspace_notProvided":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "careEpisodeReportsWorkspace_note":
            MessageLookupByLibrary.simpleMessage("Opmerking"),
        "careEpisodeReportsWorkspace_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "careEpisodeReportsWorkspace_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Verantwoordelijke fysiotherapeut"),
        "careEpisodeReportsWorkspace_referringPractitionerHistory":
            MessageLookupByLibrary.simpleMessage(
                "Overzicht van de verwijzende kinesisten"),
        "careEpisodeReportsWorkspace_report":
            MessageLookupByLibrary.simpleMessage("Rapport"),
        "careEpisodeReportsWorkspace_reportCount":
            MessageLookupByLibrary.simpleMessage("Aantal rapporten"),
        "careEpisodeReportsWorkspace_reportHistory":
            MessageLookupByLibrary.simpleMessage("Rapportgeschiedenis"),
        "careEpisodeReportsWorkspace_reportsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "De rapporten kunnen niet worden geladen."),
        "careEpisodeReportsWorkspace_restore":
            MessageLookupByLibrary.simpleMessage("Herstellen"),
        "careEpisodeReportsWorkspace_result":
            MessageLookupByLibrary.simpleMessage("Resultaat"),
        "careEpisodeReportsWorkspace_returnToDraft":
            MessageLookupByLibrary.simpleMessage("Terug naar het concept"),
        "careEpisodeReportsWorkspace_returnToReportDraft":
            MessageLookupByLibrary.simpleMessage(
                "Terug naar het conceptverslag"),
        "careEpisodeReportsWorkspace_saveAssessment":
            MessageLookupByLibrary.simpleMessage("De balans opslaan"),
        "careEpisodeReportsWorkspace_saveReport":
            MessageLookupByLibrary.simpleMessage("Het rapport opslaan"),
        "careEpisodeReportsWorkspace_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Vulveld voor het opstellen van het SOAP-verslag.\n\nS — Subjectief\n\nO — Objectief\n\nA — Analyse\n\nP — Plan"),
        "careEpisodeReportsWorkspace_test":
            MessageLookupByLibrary.simpleMessage("Test"),
        "careEpisodeReportsWorkspace_testCount":
            MessageLookupByLibrary.simpleMessage("Aantal tests"),
        "careEpisodeReportsWorkspace_testsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "De tests kunnen niet worden geladen."),
        "careEpisodeReportsWorkspace_title":
            MessageLookupByLibrary.simpleMessage("Titel"),
        "careEpisodeReportsWorkspace_trashLoadError":
            MessageLookupByLibrary.simpleMessage(
                "De prullenbak kan niet worden geladen."),
        "careEpisodeReportsWorkspace_updateAssessment":
            MessageLookupByLibrary.simpleMessage("De balans bijwerken"),
        "careEpisodeReportsWorkspace_updateReport":
            MessageLookupByLibrary.simpleMessage("Het rapport bijwerken"),
        "careEpisode_assessment":
            MessageLookupByLibrary.simpleMessage("Geen klinische analyse."),
        "careEpisode_evaluation":
            MessageLookupByLibrary.simpleMessage("Geen klinische evaluatie."),
        "careEpisode_report":
            MessageLookupByLibrary.simpleMessage("Geen eerste verslag."),
        "careEpisode_title":
            MessageLookupByLibrary.simpleMessage("Ondersteuning"),
        "careEpisode_treatment":
            MessageLookupByLibrary.simpleMessage("Geen behandelplan."),
        "clinicalDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm kunt u de evaluaties en rapporten met betrekking tot de behandeling opstellen en opslaan.\n\nVoor een evaluatie kunt u de hoofdtekst opstellen, de testresultaten en opmerkingen voor de follow-up selecteren die u wilt opnemen, en vervolgens een DOCX-document genereren zodra de evaluatie is opgeslagen.\n\nConceptversies worden automatisch opgeslagen zolang ze niet als evaluatie of rapport zijn opgeslagen.\n\nVia de geschiedenis kunt u reeds opgeslagen evaluaties en rapporten terugvinden."),
        "clinicalDocuments_title":
            MessageLookupByLibrary.simpleMessage("Verslagen en rapporten"),
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
        "deviceForm_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u de gegevens van een apparaat in Companion aanmaken of wijzigen.\n\nVoer een naam in waarmee u de telefoon of tablet gemakkelijk kunt herkennen. Deze naam is verplicht.\n\nSelecteer het platform van het apparaat: iOS of Android.\n\nU kunt het apparaat koppelen aan een zorgverlener uit de lijst of de optie ‘gedeeld apparaat’ kiezen om het niet aan een specifieke zorgverlener toe te wijzen.\n\nKlik op ‘Aanmaken’ om het apparaat toe te voegen of op ‘Opslaan’ om de wijzigingen te bevestigen. Met ‘Annuleren’ sluit u het venster zonder de wijzigingen toe te passen.\n\nAls u deze helptekst opent en weer sluit, blijven uw invoergegevens in het formulier behouden."),
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
        "deviceList_archiveConfirmation": m23,
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
        "deviceQr_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster wordt de QR-code voor de identificatie van het apparaat weergegeven, samen met de naam van het apparaat, de naam van de praktijk en het platform.\n\nScan deze QR-code met ABAK Mobile om dit apparaat in deze praktijk te identificeren. Controleer of de weergegeven naam overeenkomt met de betreffende telefoon of tablet.\n\nDeze QR-code dient om het apparaat te identificeren; het weergeven ervan leidt niet tot het doorsturen van resultaten.\n\nSluit dit venster om terug te keren naar de lijst met apparaten."),
        "deviceQr_title": MessageLookupByLibrary.simpleMessage("ABAK-apparaat"),
        "documentArchiveConfirm_help": MessageLookupByLibrary.simpleMessage(
            "Door het document naar de prullenbak te verplaatsen, wordt de balans of het rapport uit de gebruikelijke geschiedenis verwijderd.\n\nHet document blijft bewaard in Companion. U kunt het terugvinden in de gearchiveerde documenten en het herstellen om het weer in de geschiedenis te laten verschijnen.\n\nDOCX-bestanden die al naar uw computer zijn geëxporteerd, worden door deze actie niet verwijderd.\n\nKlik op ‘Naar prullenbak’ om te bevestigen, of op ‘Annuleren’ om het document in de geschiedenis te behouden."),
        "documentArchiveConfirm_title": MessageLookupByLibrary.simpleMessage(
            "Het document naar de prullenbak verplaatsen?"),
        "documentAuthor_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u de zorgverlener selecteren die is aangewezen als opsteller van het huidige verslag of rapport.\n\nSelecteer de zorgverlener in de lijst en klik vervolgens op ‘Bevestigen’ om deze koppeling aan het document op te slaan.\n\nDeze keuze heeft betrekking op de opsteller van het document; de verwijzende zorgverlener van de zorgperiode blijft ongewijzigd.\n\nMet ‘Annuleren’ sluit u het venster zonder de opsteller te wijzigen."),
        "documentAuthor_title":
            MessageLookupByLibrary.simpleMessage("Een redacteur kiezen"),
        "documentDirectoryAccess_help": MessageLookupByLibrary.simpleMessage(
            "Companion heeft geen toegang tot de map die is aangewezen voor het opslaan van documenten, of de toegangsrechten moeten worden vernieuwd.\n\nAls deze map zich op een externe schijf of een netwerklocatie bevindt, controleer dan eerst of deze is aangesloten en toegankelijk is.\n\nKlik op ‘Een map toestaan’ en selecteer vervolgens de map in het venster dat wordt geopend. U kunt de gebruikelijke map selecteren of een andere bestemming kiezen.\n\nDe geselecteerde map wordt opgeslagen in uw voorkeuren voor toekomstige exporten. Bestanden die al in de oude map staan, worden niet verplaatst.\n\nMet „Annuleren“ wordt de lopende export onderbroken zonder dat uw balans of rapport wordt gewijzigd."),
        "documentDirectoryAccess_title": MessageLookupByLibrary.simpleMessage(
            "Toegang verlenen tot de documentenmap"),
        "documentDocxExisting_help": MessageLookupByLibrary.simpleMessage(
            "Er is al een DOCX-bestand gekoppeld aan dit overzicht of dit rapport.\n\nMet ‘Nieuw aanmaken’ wordt een nieuw bestand aangemaakt met de huidige inhoud van het document. Als de bestandsnaam al bestaat in de doelmap, wordt er een nummer aan toegevoegd om het vorige bestand te behouden. Het nieuwe bestand wordt het bestand dat in Companion aan het document is gekoppeld.\n\nMet ‘Vervangen’ wordt het bestand met de aan het document gekoppelde naam in de doelmap overschreven. Eventuele wijzigingen die rechtstreeks in dit bestand in Word of LibreOffice zijn aangebracht, worden overschreven.\n\nMet ‘Annuleren’ wordt het exporteren afgebroken zonder de bestanden te wijzigen."),
        "documentDocxExisting_title": MessageLookupByLibrary.simpleMessage(
            "Er bestaat al een DOCX-bestand"),
        "documentDraftChoice_help": MessageLookupByLibrary.simpleMessage(
            "Een tekst waaraan u momenteel werkt, is voor dit documenttype al automatisch opgeslagen.\n\nMet ‘Concept hervatten’ kunt u deze tekst terugvinden en verdergaan met schrijven.\n\nMet ‘Nieuw overzicht’ of ‘Nieuw rapport’ worden de titel en de tekst van dit concept gewist, zodat u opnieuw kunt beginnen. Het vorige concept wordt niet als apart document bewaard. Als u uw werk wilt bewaren, open het dan opnieuw en sla het op voordat u aan een nieuw document begint.\n\nMet ‘Annuleren’ sluit u dit venster zonder het concept te wijzigen."),
        "documentDraftChoice_title": MessageLookupByLibrary.simpleMessage(
            "Er bestaat een conceptversie"),
        "documentExpandedEditor_help": MessageLookupByLibrary.simpleMessage(
            "Dit venster biedt meer ruimte om de tekst van de balans of het rapport dat u aan het opstellen bent, te schrijven of te wijzigen.\n\nUw wijzigingen worden direct doorgevoerd in het hoofdschrijfvenster. Als u het venster sluit, gaan deze wijzigingen niet verloren.\n\nKlik op het kruisje om terug te keren naar het gedeelte Balansen/Verslagen en ga vervolgens verder met het opstellen en opslaan van uw document.\n\nBij het openen en sluiten van deze helpfunctie blijft de ingevoerde tekst behouden."),
        "documentExpandedEditor_helpTitle":
            MessageLookupByLibrary.simpleMessage(
                "Schrijven in de vergrote weergave"),
        "documentRecipient_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u de ontvangers van het huidige overzicht of rapport invoeren.\n\nVoer de naam van de ontvanger of de namen van de verschillende ontvangers in en klik vervolgens op ‘Bevestigen’ om deze informatie in het document op te slaan.\n\nOm een bestaande vermelding te verwijderen, wist u de inhoud van het veld en klikt u vervolgens op ‘Bevestigen’.\n\nDeze invoer vult de ontvangers van het document in; er wordt hierdoor geen verzending in gang gezet.\n\nMet ‘Annuleren’ sluit u het venster zonder de wijzigingen toe te passen. Bij het openen en sluiten van deze helppagina blijft uw invoer behouden."),
        "documentRecipient_title":
            MessageLookupByLibrary.simpleMessage("Ontvanger(s)"),
        "documentTemplateDraft_help": MessageLookupByLibrary.simpleMessage(
            "Er zijn al antwoorden opgeslagen voor dit sjabloon in de lopende zorgfase.\n\nMet ‘Concept hervatten’ opent u het sjabloon met deze antwoorden, zodat u verder kunt gaan met het invullen of uw invoer kunt wijzigen.\n\n\"Nieuwe balans\" of \"Nieuw rapport\" wist de opgeslagen antwoorden voor dit sjabloon en opent de gids zonder deze antwoorden over te nemen. Deze keuze verwijdert de tekst die al in het tekstveld van het document staat niet.\n\n\"Annuleren\" behoudt de opgeslagen antwoorden en keert terug naar het vorige scherm zonder de gids te openen."),
        "documentTemplateDraft_title":
            MessageLookupByLibrary.simpleMessage("Bestaand concept"),
        "documentTemplateGuide_help": MessageLookupByLibrary.simpleMessage(
            "Deze handleiding helpt u bij het opstellen van de inhoud van een balans of een verslag aan de hand van het geselecteerde sjabloon.\n\nGebruik de lijst met rubrieken aan de linkerkant om naar de verschillende onderdelen te gaan. Voer, afhankelijk van de aangeboden velden, tekst in, selecteer antwoorden of vul de tabellen in.\n\nMet de knop ‘Voorbeeld’ onderaan het formulier kunt u de tekst bekijken die op basis van uw antwoorden is gegenereerd.\n\nVanuit het voorbeeld kunt u terugkeren naar de handleiding om verder te gaan met invoeren of om te vragen dat de tekst in het verslag of rapport wordt opgenomen. Volg eventuele voorstellen voor toevoegingen of vervangingen die door Companion worden weergegeven.\n\nHet invoegen van de tekst vervangt niet het definitief opslaan van het overzicht of het rapport.\n\nBij het openen en sluiten van deze handleiding blijft uw invoer bewaard."),
        "documentTemplateGuide_helpTitle":
            MessageLookupByLibrary.simpleMessage("De invoergids gebruiken"),
        "documentTemplatePreview_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u de tekst bekijken die is gegenereerd op basis van de antwoorden die u in de gids hebt ingevoerd.\n\nDe tekst kan worden bekeken en geselecteerd. Als u uw antwoorden wilt wijzigen, klikt u op ‘Sluiten’ om terug te keren naar de gids en start u het voorbeeld vervolgens opnieuw.\n\nKlik op ‘In het overzicht invoegen’ of ‘In het rapport invoegen’ om de tekst naar het huidige document over te brengen. Volg eventuele suggesties voor toevoegingen of vervangingen die door Companion worden weergegeven.\n\nAls er geen tekst is gegenereerd, blijft de invoegknop uitgeschakeld.\n\nControleer na het invoegen de inhoud van het document en sla uw balans of rapport op."),
        "documentTemplatePreview_title": MessageLookupByLibrary.simpleMessage(
            "Overzicht van de gegenereerde tekst"),
        "documentTemplate_assessmentTitle":
            MessageLookupByLibrary.simpleMessage("Een balansmodel kiezen"),
        "documentTemplate_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster worden de beschikbare sjablonen voor het huidige documenttype weergegeven: balans of verslag.\n\nKlik op een sjabloon om de bijbehorende invoergids te openen. De keuze van het sjabloon leidt niet onmiddellijk tot het aanmaken van een opgeslagen document.\n\nAls er voor dit sjabloon al een concept bestaat in de zorgperiode, biedt Companion u de mogelijkheid om dit over te nemen of een nieuwe invoer te starten."),
        "documentTemplate_reportTitle":
            MessageLookupByLibrary.simpleMessage("Een rapportmodel kiezen"),
        "documentTests_help": MessageLookupByLibrary.simpleMessage(
            "In dit uitvergrote overzicht kunt u de tests bekijken die tijdens de behandeling zijn uitgevoerd en kiezen welke u wilt opnemen in het huidige verslag of rapport.\n\nGebruik de selectievakjes om een test toe te voegen aan of te verwijderen uit het document. Deze selectie verwijdert de resultaten niet die in Companion zijn opgeslagen.\n\nMet de acties in de lijst kunt u de details van de resultaten bekijken. De selectie is beschikbaar wanneer een overzicht of rapport is geopend en het laden is voltooid.\n\nKlik op het kruisje om terug te keren naar het gedeelte Overzichten/Rapporten."),
        "documentTextInsertion_help": MessageLookupByLibrary.simpleMessage(
            "Uw verslag of rapport bevat al tekst. Kies hoe u de door de invoergids gegenereerde inhoud hierin wilt opnemen.\n\nMet ‘Toevoegen aan het einde’ blijft de bestaande tekst behouden en wordt de gegenereerde inhoud aan het einde toegevoegd.\n\nMet ‘Vervangen’ wordt de volledige tekst in het bewerkingsveld vervangen door de gegenereerde inhoud. De passages die u in dit veld had ingevoerd, worden dus ook vervangen.\n\nMet ‘Annuleren’ wordt deze invoegactie geannuleerd en blijft de huidige tekst behouden.\n\nU kunt deze helptekst raadplegen en vervolgens sluiten voordat u uw keuze maakt."),
        "documentTextInsertion_title": MessageLookupByLibrary.simpleMessage(
            "De gegenereerde tekst invoegen"),
        "documentTitle_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u de titel van de balans of het rapport invoeren.\n\nBehoud de voorgestelde titel of vervang deze door een titel waarmee het document gemakkelijk te herkennen is. De titel mag niet leeg zijn.\n\nKlik op de bevestigingsknop of druk op Enter om te bevestigen. Met ‘Annuleren’ sluit u het venster zonder de titel te bevestigen.\n\nBij het openen en sluiten van deze helpfunctie blijft de ingevoerde tekst behouden."),
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
        "episodeFormEditor_requiredField": m24,
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
        "episodeNotes_archiveConfirmation": m25,
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
        "episodeReferents_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u de behandelend fysiotherapeut en de voorschrijvende arts selecteren die bij de behandeling betrokken zijn.\n\nSelecteer de zorgverleners uit de lijsten. U kunt een koppeling ook verwijderen door de optie ‘zonder zorgverlener’ te kiezen.\n\nMet de beheer-knoppen rechts van de lijsten kunt u de profielen van de zorgverleners en externe contactpersonen openen, bijvoorbeeld om een ontbrekende zorgverlener toe te voegen.\n\nKlik op ‘Opslaan’ om de gekozen koppelingen toe te passen. Wijzigingen in de verwijzende fysiotherapeut worden bewaard in de behandelgeschiedenis.\n\nMet ‘Annuleren’ worden de wijzigingen in de koppelingen in dit venster ongedaan gemaakt. Eventuele profielen die vanuit de beheer schermen zijn aangemaakt, blijven opgeslagen."),
        "episodeReferents_title":
            MessageLookupByLibrary.simpleMessage("De referenties wijzigen"),
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
        "exchangeDirectoryService_choose": MessageLookupByLibrary.simpleMessage(
            "Kies het ABAK-uitwisselingsdossier"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Bijgewerkt ABAK-uitwisselingsdossier"),
        "externalCorrespondentForm_addTitle":
            MessageLookupByLibrary.simpleMessage(
                "Een contactpersoon toevoegen"),
        "externalCorrespondentForm_editTitle":
            MessageLookupByLibrary.simpleMessage("De contactpersoon wijzigen"),
        "externalCorrespondentForm_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u de gegevens van een externe contactpersoon invoeren.\n\nDe achternaam is verplicht. U kunt de voornaam, het beroep, het specialisme, het adres, de postcode, de plaats, het e-mailadres en het telefoonnummer invullen.\n\nKlik op ‘Opslaan’ om de gegevens te bevestigen. Met ‘Annuleren’ sluit u het venster zonder de wijzigingen op te slaan.\n\nWanneer u deze helptekst opent en weer sluit, blijven de gegevens die u in het formulier hebt ingevoerd behouden."),
        "externalCorrespondents_help": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm worden de externe contactpersonen weergegeven die in Companion zijn opgeslagen. Elke regel bevat de naam van de contactpersoon en, indien ingevuld, zijn of haar beroep, specialisme en woonplaats.\n\nKlik op ‘Toevoegen’ om een contactpersoon aan te maken. Vul de identiteitsgegevens en de relevante contactgegevens in en klik vervolgens op ‘Opslaan’ om de contactpersoon aan de lijst toe te voegen. Met ‘Annuleren’ sluit u het formulier zonder een contactpersoon aan te maken.\n\nDeze contactpersonen kunnen onder andere worden geselecteerd als voorschrijvers in zorgtrajecten."),
        "externalCorrespondents_title":
            MessageLookupByLibrary.simpleMessage("Externe correspondenten"),
        "externalSpeechToTextProvider_empty":
            MessageLookupByLibrary.simpleMessage(
                "De add-on heeft geen reactie gegeven."),
        "externalSpeechToTextProvider_failure":
            MessageLookupByLibrary.simpleMessage(
                "De spraakherkennings-add-on werkt niet."),
        "externalSpeechToTextProvider_invalid":
            MessageLookupByLibrary.simpleMessage(
                "Ongeldig antwoord van de add-on voor spraakherkenning."),
        "externalSpeechToTextProvider_noText":
            MessageLookupByLibrary.simpleMessage(
                "De add-on heeft geen tekst teruggegeven."),
        "externalSpeechToTextProvider_transcription":
            MessageLookupByLibrary.simpleMessage("De transcriptie is mislukt."),
        "followUpNoteForm_createTitle":
            MessageLookupByLibrary.simpleMessage("Nieuwe voortgangsnotitie"),
        "followUpNoteForm_editTitle": MessageLookupByLibrary.simpleMessage(
            "De opvolgingsnotitie wijzigen"),
        "followUpNoteForm_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u een opvolgingsnotitie aanmaken of wijzigen die aan de zorgaflevering is gekoppeld.\n\nVul een titel en de inhoud van de notitie in. Beide velden moeten tekst bevatten om de notitie op te slaan.\n\nKlik bij het aanmaken op ‘Toevoegen’. Klik bij het wijzigen op ‘Opslaan’ om uw wijzigingen op te slaan.\n\nMet ‘Annuleren’ sluit u het venster zonder uw invoer op te slaan. U kunt deze helptekst openen en vervolgens sluiten zonder de tekst die u aan het schrijven bent te verliezen."),
        "followUpNotes_help": MessageLookupByLibrary.simpleMessage(
            "In dit overzicht worden de opvolgnota’s van de behandeling weergegeven, met de datum, de titel en een samenvatting van de inhoud.\n\nMet de knop ‘Toevoegen’ kunt u een notitie aanmaken. Met het pictogram ‘Bewerken’ kunt u een bestaande notitie openen om deze te bekijken of te wijzigen.\n\nGebruik de selectievakjes om de notities te kiezen die u in het huidige overzicht of rapport wilt opnemen. Als u het vinkje bij een notitie verwijdert, wordt deze uit de selectie verwijderd zonder dat de follow-upnotitie zelf wordt verwijderd.\n\nDe selectie is beschikbaar wanneer een overzicht of rapport is geopend en het laden is voltooid.\n\nKlik op het kruisje om het vergrote scherm te sluiten en terug te keren naar het gedeelte Overzichten/Rapporten."),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Voorvoegsel ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Sluiten"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Commentaar"),
        "g_context": MessageLookupByLibrary.simpleMessage("Achtergrond"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Kopiëren"),
        "g_file": MessageLookupByLibrary.simpleMessage("Bestand"),
        "g_helpTooltip": MessageLookupByLibrary.simpleMessage("Help weergeven"),
        "g_learn_more": MessageLookupByLibrary.simpleMessage("Meer informatie"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Technische informatie"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Gekopieerde technische gegevens"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Gearchiveerde patiënten kunnen tot de aangegeven datum worden hersteld.\nNa deze datum worden ze automatisch verwijderd, zodat ongebruikte dossiers niet voor onbepaalde tijd worden bewaard.\nDe bewaartermijn kan worden aangepast in de instellingen van Companion."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "Het gaat om de apparaten (telefoon, tablet) die worden gebruikt om de tests uit te voeren.\n- Een apparaat kan door verschillende personen worden gebruikt.\n- Eén persoon kan meerdere apparaten bezitten.\n\nAan de hand van deze informatie kan worden vastgesteld wat de materiële bron is van de informatie die naar Companion wordt overgedragen.\nU kunt een apparaat aanmaken, wijzigen of archiveren.\n\nOmwille van de traceerbaarheid is het niet mogelijk om een apparaat te verwijderen.\nIndien nodig kunt u een gearchiveerd apparaat herstellen.\n\nEr wordt een QR-code gebruikt om een telefoon of tablet te koppelen. U moet de QR-code weergeven op de vaste telefoon (Apparaat > het bijbehorende pictogram van het apparaat) en op de telefoon (of tablet) naar Instellingen > Bedrijfsorganisatie > Geregistreerde apparaten > Apparaat toevoegen gaan.\n\nHoud het apparaat dicht bij het scherm om de QR-code te scannen.Er verschijnt een bericht dat de handeling is geslaagd."),
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
            "Een behandeling komt overeen met een zorgtraject.\nHier vindt u de verschillende lopende behandelingen van uw patiënt.\nOm een uitslag aan een behandeling te koppelen, kunt u een bestaand zorgtraject gebruiken of een nieuw zorgtraject aanmaken.\nZodra het zorgtraject is afgerond, kunt u het archiveren."),
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
        "home_correspondents":
            MessageLookupByLibrary.simpleMessage("Correspondenten"),
        "home_create_a_backup":
            MessageLookupByLibrary.simpleMessage("Een back-up maken"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Datum niet opgegeven"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Apparaten"),
        "home_error_while_saving": m26,
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
        "home_other_exercises": m27,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Instellingen"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Pad"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patiënt ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patiënten"),
        "home_pending_association": m28,
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
        "importHistory_help": MessageLookupByLibrary.simpleMessage(
            "Dit scherm toont de geschiedenis van de importsessies die in Companion zijn opgeslagen.\n\nElke regel geeft de datum van de sessie weer, de status ervan, het aantal verwerkte bestanden en het aantal geïmporteerde, genegeerde of conflicterende resultaten.\n\nHet pictogram geeft onder andere aan of er een import gaande is, of deze is mislukt, of er fouten zijn opgetreden of conflicten zijn die uw aandacht vereisen.\n\nKlik op een sessie om de details te bekijken en meer inzicht te krijgen in de verwerking van de resultaten."),
        "importPatientForm_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u een patiënt aanmaken om de vanuit ABAK Mobile geïmporteerde resultaten aan hem of haar te koppelen.\n\nVoer de voor- en achternaam in. U kunt de geboortedatum invullen in het formaat JJJJ-MM-DD en het geslacht opgeven, of ‘Niet opgegeven’ laten staan.\n\nAls u de Vitale-kaart hebt gescand, controleer dan de vooraf ingevulde gegevens en corrigeer deze indien nodig.\n\nKlik op ‘Aanmaken’ om de patiënt op te slaan en te selecteren. Kies vervolgens de behandeling waaraan de resultaten moeten worden gekoppeld: het aanmaken van de patiënt is op zich nog niet voldoende om de koppeling van de geïmporteerde gegevens te voltooien.\n\nMet ‘Annuleren’ sluit u dit venster zonder een patiënt aan te maken. Als u deze helptekst opent en vervolgens weer sluit, blijven uw invoergegevens bewaard."),
        "importPatientForm_title":
            MessageLookupByLibrary.simpleMessage("Nieuwe patiënt"),
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("bestand"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("bestanden"),
        "importResolutionAssistant_help": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm worden de imports weergegeven die uw aandacht vereisen: koppeling aan een patiënt die nog moet worden voltooid, mislukte import, fouten, genegeerde resultaten of conflicten die moeten worden onderzocht.\n\nElke regel geeft de datum van de import weer en de beschikbare informatie om het betreffende dossier te identificeren.\n\nKlik op een import om de statuspagina te openen, de uitleg te bekijken en de voorgestelde acties te bekijken, afhankelijk van de situatie.\n\nDe lijst wordt bijgewerkt zodra u terugkeert van de statuspagina van de import. Als geen enkele import aan deze criteria voldoet, verschijnt er een bericht dat er geen problemen zijn gedetecteerd."),
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
        "importResolution_help": MessageLookupByLibrary.simpleMessage(
            "Via dit scherm kunt u de resultaten die u via ABAK Mobile hebt ontvangen, koppelen aan de juiste patiënt en de juiste behandeling in Companion.\n\nBekijk de informatie van de ontvangen import en selecteer vervolgens de betreffende patiënt in de lijst. Maak indien nodig een patiëntendossier aan via ‘Nieuwe patiënt’ of ‘Via Carte Vitale’, wanneer het leesapparaat beschikbaar is.\n\nNadat u de patiënt hebt geselecteerd, kiest u een actieve behandeling of maakt u er een aan. Een gearchiveerde behandeling moet eerst worden hersteld voordat deze kan worden geselecteerd.\n\nControleer de patiënt en de behandeling voordat u deze selecteert: door deze te selecteren wordt de koppeling bevestigd en kunt u doorgaan met het importeren."),
        "importResolution_title":
            MessageLookupByLibrary.simpleMessage("De import koppelen"),
        "importSessionDetail_help": MessageLookupByLibrary.simpleMessage(
            "Dit scherm toont het verloop van een import die in Companion is ontvangen. Het hoofdbericht geeft aan of de import is geslaagd, aan een patiënt moet worden gekoppeld of een probleem vertoont.\n\nWanneer een koppeling nodig is, klikt u op ‘Koppelen aan een patiënt’ om het dossier te kiezen waaraan de resultaten moeten worden gekoppeld.\n\nVia het rapport en de lijst met bestanden kunt u de details van de verwerking en eventuele waarschuwingen bekijken.\n\nAls het ontvangen bestand onvolledig of beschadigd is, vraag dan via ABAK Mobile om een nieuwe verzending.\n\nAfhankelijk van de situatie wordt de knop ‘Deze import verwijderen’ weergegeven. Bekijk het bevestigingsbericht voordat u het verwijderen bevestigt."),
        "importSessionDetail_title":
            MessageLookupByLibrary.simpleMessage("Volg de import"),
        "information_backupCount": m29,
        "information_backups": MessageLookupByLibrary.simpleMessage("Back-ups"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Geconfigureerd"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm wordt algemene, technische en juridische informatie over Companion weergegeven."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Informatie"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Database"),
        "information_help": MessageLookupByLibrary.simpleMessage(
            "Op deze pagina vindt u algemene informatie over uw Companion-installatie: de versie van de app, de geconfigureerde praktijk, de aanwezigheid van het logo, het gebruikte besturingssysteem en de taal.\n\nIn het gedeelte over lokale opslag worden de grootte van de database en het aantal en de totale grootte van de opgeslagen back-ups weergegeven.\n\nMet de knoppen kunt u de nieuwigheden, de licentie en de waarschuwingen met betrekking tot het gebruik van de app bekijken.\n\nTijdens een gesprek met de helpdesk kunnen de hier weergegeven Companion-versie en het besturingssysteem helpen om uw configuratie te identificeren."),
        "information_language": MessageLookupByLibrary.simpleMessage("Taal"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Wettelijke kennisgeving"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Bezig met laden..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Lokale opslag"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_new": MessageLookupByLibrary.simpleMessage(
            "Versie 1.1.0 build 3\nMogelijkheid tot spraakdicteer voor overzichten en rapporten; hiervoor is de gratis module vereist.\nAutomatische opslag van overzichten en rapporten.\nKnop voor het dupliceren van overzichten en rapporten.\nBewerkbare notities.\nKnop om alle tests van een patiënt voor een bepaalde episode te bekijken.\nSjablonen voor beoordelingen.\nAutomatische grafiek bij meerdere resultaten voor één test.\nEen document aanmaken in docx-formaat.\nWeergave van de helptekst voor E72 en E76"),
        "information_newHelp": MessageLookupByLibrary.simpleMessage(
            "Op deze pagina worden de nieuwigheden en wijzigingen beschreven die voor Companion gelden.\n\nScroll door de tekst om alle informatie te bekijken. U kunt indien nodig een fragment selecteren en kopiëren.\n\nGebruik de pijl ‘Terug’ om terug te keren naar de pagina ‘Over’."),
        "information_newTitle":
            MessageLookupByLibrary.simpleMessage("Nieuwigheden in deze versie"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Niet geconfigureerd"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "information_office": MessageLookupByLibrary.simpleMessage("Kantoor"),
        "information_size": m30,
        "information_system": MessageLookupByLibrary.simpleMessage("Systeem"),
        "information_title": MessageLookupByLibrary.simpleMessage("Informatie"),
        "information_totalSize": m31,
        "information_version": m32,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Versie..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("De licentie raadplegen"),
        "initialReportDocumentService_associate":
            MessageLookupByLibrary.simpleMessage(
                "Een eerste balans in Word toevoegen"),
        "initialReportDocumentService_unsupported":
            MessageLookupByLibrary.simpleMessage(
                "Platform wordt niet ondersteund"),
        "kobus_archived":
            MessageLookupByLibrary.simpleMessage("Companion — gearchiveerd"),
        "kobus_archives":
            MessageLookupByLibrary.simpleMessage("Geïmporteerde archieven"),
        "kobus_attach": MessageLookupByLibrary.simpleMessage(
            "Koppelen aan de geselecteerde patiënt"),
        "kobus_backupNotice": MessageLookupByLibrary.simpleMessage(
            "Bij de huidige back-up van de database worden de KOBUS-bestanden niet meegenomen."),
        "kobus_cancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
        "kobus_candidate":
            MessageLookupByLibrary.simpleMessage("Voorgestelde patiënt"),
        "kobus_chooseCandidate": MessageLookupByLibrary.simpleMessage(
            "Selecteer hieronder een regel"),
        "kobus_confirm": MessageLookupByLibrary.simpleMessage(
            "De import controleren en bevestigen"),
        "kobus_confirmBody": MessageLookupByLibrary.simpleMessage(
            "De dossiers importeren die volgens uw beslissingen klaar zijn? De onopgeloste afstemmingen en de uitgesloten dossiers blijven buiten beschouwing. De bestaande fiches worden niet gewijzigd."),
        "kobus_consult": MessageLookupByLibrary.simpleMessage(
            "De KOBUS-gegevens raadplegen"),
        "kobus_create":
            MessageLookupByLibrary.simpleMessage("Een kaart aanmaken"),
        "kobus_creations": MessageLookupByLibrary.simpleMessage(
            "Aangemaakte / nog aan te maken fiches"),
        "kobus_distinct": MessageLookupByLibrary.simpleMessage(
            "Een afzonderlijke persoon bevestigen"),
        "kobus_editRejected": MessageLookupByLibrary.simpleMessage(
            "De lijst met afgewezen dossiers bewerken"),
        "kobus_existing": MessageLookupByLibrary.simpleMessage(
            "Betrokken bestaande patiënten"),
        "kobus_failed":
            MessageLookupByLibrary.simpleMessage("Technische storingen"),
        "kobus_history": MessageLookupByLibrary.simpleMessage("Verslag KOBUS"),
        "kobus_imported": MessageLookupByLibrary.simpleMessage("Geïmporteerd"),
        "kobus_interrupted": MessageLookupByLibrary.simpleMessage(
            "Niet behandeld na onderbreking"),
        "kobus_intro": MessageLookupByLibrary.simpleMessage(
            "De dossiers worden ongewijzigd bewaard. Er worden geen afleveringen of originele klinische documenten aangemaakt."),
        "kobus_matches":
            MessageLookupByLibrary.simpleMessage("Te controleren afstemmingen"),
        "kobus_noShared": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen gedeelde mappen in deze export"),
        "kobus_ownOrigin":
            MessageLookupByLibrary.simpleMessage("Mijn patiënten"),
        "kobus_print": MessageLookupByLibrary.simpleMessage("Afdrukken"),
        "kobus_provenance":
            MessageLookupByLibrary.simpleMessage("Herkomst / status"),
        "kobus_reason": MessageLookupByLibrary.simpleMessage("Motief"),
        "kobus_rejected": MessageLookupByLibrary.simpleMessage("Afgewezen"),
        "kobus_savePdf": MessageLookupByLibrary.simpleMessage("De PDF opslaan"),
        "kobus_scopeReset": MessageLookupByLibrary.simpleMessage(
            "Als je deze optie wijzigt, worden de afstemmingsbeslissingen gereset."),
        "kobus_select":
            MessageLookupByLibrary.simpleMessage("Kies de ZIP KOBUS"),
        "kobus_shared": MessageLookupByLibrary.simpleMessage(
            "Haal ook de gedeelde mappen op, indien aanwezig"),
        "kobus_sharedOrigin": MessageLookupByLibrary.simpleMessage(
            "Patiënten die bij meerdere artsen onder behandeling zijn"),
        "kobus_skip":
            MessageLookupByLibrary.simpleMessage("In de steek gelaten"),
        "kobus_source":
            MessageLookupByLibrary.simpleMessage("KOBUS-identiteit"),
        "kobus_start":
            MessageLookupByLibrary.simpleMessage("De import starten"),
        "kobus_stop": MessageLookupByLibrary.simpleMessage(
            "Stoppen na het huidige dossier"),
        "kobus_stopping":
            MessageLookupByLibrary.simpleMessage("Verzoek om stopzetting…"),
        "kobus_title": MessageLookupByLibrary.simpleMessage("KOBUS importeren"),
        "kobus_unavailable": MessageLookupByLibrary.simpleMessage(
            "De KOBUS-gegevens zijn niet beschikbaar of het bestand kan niet worden gevonden."),
        "kobus_unresolved":
            MessageLookupByLibrary.simpleMessage("Nog te beslissen"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Taal opgeslagen."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Taal van de applicatie"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Waarschuwing"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion is software die helpt bij het organiseren, importeren en raadplegen van klinische resultaten uit het ABAK-ecosysteem.\n\nHet is geen gecertificeerd medisch hulpmiddel en vervangt niet het oordeel van de zorgverlener.\n\nDe weergegeven resultaten, scores, rapporten en indicatoren moeten altijd worden geïnterpreteerd door een gekwalificeerde zorgverlener, waarbij rekening moet worden gehouden met het klinisch onderzoek, de context van de patiënt en de geldende aanbevelingen.\n\nDe gebruiker blijft als enige verantwoordelijk voor zijn klinische beslissingen, voor de controle van de geïmporteerde gegevens en voor de naleving van de toepasselijke beroeps-, wettelijke en deontologische regels bij het gebruik ervan.\n\nABAK Desktop Companion stelt geen zelfstandige diagnose, schrijft geen behandeling voor en is in geen geval een vervanging voor een medisch of paramedisch consult."),
        "legalNotice_help": MessageLookupByLibrary.simpleMessage(
            "Op deze pagina vind je de waarschuwingen en informatie over het gebruik van Companion.\n\nScroll naar beneden om de volledige tekst te lezen.\n\nGebruik de pijl ‘Terug’ om terug te gaan naar de pagina ‘Over’."),
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
        "localDatabaseRestoreService_anomaly": m33,
        "localDatabaseRestoreService_failure": m34,
        "localDatabaseRestoreService_integrity": m35,
        "localDatabaseRestoreService_missing":
            MessageLookupByLibrary.simpleMessage(
                "Het back-upbestand kan niet worden gevonden."),
        "localDatabaseRestoreService_success":
            MessageLookupByLibrary.simpleMessage("Herstel succesvol voltooid."),
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
        "organization_chooseReportHeader": MessageLookupByLibrary.simpleMessage(
            "Een aangepaste koptekst kiezen"),
        "organization_help": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm kunt u de naam en contactgegevens van uw praktijk invoeren: adres, postcode, plaats, telefoonnummer en e-mailadres.\n\nKlik op ‘Contactgegevens opslaan’ om uw wijzigingen op te slaan voordat u het scherm verlaat.\n\nU kunt ook een afbeelding op uw computer selecteren om het logo van uw praktijk in te stellen. De keuze van het logo wordt onmiddellijk opgeslagen, ongeacht de contactgegevens.\n\nMet de knop ‘Logo verwijderen’ kunt u het logo dat in Companion wordt gebruikt, verwijderen."),
        "organization_identityTitle": MessageLookupByLibrary.simpleMessage(
            "Identiteit van de instelling"),
        "organization_logoRecommendation": MessageLookupByLibrary.simpleMessage(
            "Aanbevolen afmetingen: vierkante afbeelding van minimaal 300 × 300 px. Aanbevolen bestandsformaat: PNG."),
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
        "organization_removeReportHeader":
            MessageLookupByLibrary.simpleMessage("De koptekst verwijderen"),
        "organization_reportHeaderHelpAi": MessageLookupByLibrary.simpleMessage(
            "U kunt ook een AI-tool vragen om op basis van uw aanwijzingen de afbeelding voor uw koptekst te genereren."),
        "organization_reportHeaderHelpClose":
            MessageLookupByLibrary.simpleMessage("Sluiten"),
        "organization_reportHeaderHelpContent":
            MessageLookupByLibrary.simpleMessage(
                "Op de afbeelding kunt u naar eigen inzicht uw logo, de naam van de instelling, uw contactgegevens en alle andere grafische elementen plaatsen die u op uw rapporten wilt laten verschijnen."),
        "organization_reportHeaderHelpFormat": MessageLookupByLibrary.simpleMessage(
            "Voor een optimaal resultaat in de ABAK-rapporten gebruikt u een afbeelding van 200 × 30 mm, oftewel ongeveer 2362 × 354 px bij 300 dpi. Het PNG-formaat wordt aanbevolen."),
        "organization_reportHeaderHelpIntro": MessageLookupByLibrary.simpleMessage(
            "U kunt uw koptekst naar eigen inzicht ontwerpen met een programma naar keuze en deze vervolgens als afbeelding opslaan."),
        "organization_reportHeaderHelpReplacement":
            MessageLookupByLibrary.simpleMessage(
                "De informatie in de afbeelding vervangt de standaardkoptekst die door ABAK wordt gegenereerd (logo en contactgegevens van de instelling)."),
        "organization_reportHeaderHelpTitle":
            MessageLookupByLibrary.simpleMessage(
                "Een aangepaste koptekst maken"),
        "organization_reportHeaderHelpTools": MessageLookupByLibrary.simpleMessage(
            "Als u niet gewend bent aan grafische programma\'s, kunt u bijvoorbeeld LibreOffice Draw, Microsoft PowerPoint, Apple Keynote of Canva gebruiken. Deze lijst dient uitsluitend ter illustratie en is niet volledig."),
        "organization_reportHeaderHelpTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Hulp bij het maken van een aangepaste koptekst"),
        "organization_reportHeaderRecommendation":
            MessageLookupByLibrary.simpleMessage(
                "Aanbevolen afmetingen: 200 × 30 mm (ongeveer 2362 × 354 px bij 300 dpi). Aanbevolen bestandsformaat: PNG."),
        "organization_reportHeaderRemoved":
            MessageLookupByLibrary.simpleMessage(
                "Aangepaste koptekst verwijderd."),
        "organization_reportHeaderSaved": MessageLookupByLibrary.simpleMessage(
            "Aangepaste koptekst opgeslagen."),
        "organization_reportHeaderTitle": MessageLookupByLibrary.simpleMessage(
            "Aangepaste koptekst voor rapporten"),
        "organization_reportIntroductionHelp": MessageLookupByLibrary.simpleMessage(
            "Vrije tekst die aan het begin van de rapporten wordt gebruikt. Als dit veld leeg is, wordt ‘Dokter’ gebruikt."),
        "organization_reportIntroductionHint":
            MessageLookupByLibrary.simpleMessage("Dokter"),
        "organization_reportIntroductionLabel":
            MessageLookupByLibrary.simpleMessage(
                "Inleidende zin van de verslagen"),
        "organization_saveName":
            MessageLookupByLibrary.simpleMessage("De naam opslaan"),
        "organization_title": MessageLookupByLibrary.simpleMessage("Vestiging"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Een telefoon koppelen"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Een telefoon koppelen"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scan deze QR-code via ABAK Mobile om de verbinding met Desktop automatisch in te stellen."),
        "pairPhone_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster wordt de informatie weergegeven waarmee ABAK Mobile Companion op het lokale netwerk kan vinden.\n\nSluit de telefoon of tablet en de computer aan op hetzelfde lokale netwerk en scan vervolgens deze QR-code via de koppelingsfunctie met Companion in ABAK Mobile.\n\nDe QR-code bevat het netwerkadres en de communicatiepoort van deze computer. Deze gegevens worden ook onder de code weergegeven.\n\nHoud Companion op de computer geopend tijdens de gegevensuitwisseling. Als het netwerkadres van de computer verandert, open dan dit venster opnieuw en scan de nieuwe code.\n\nHet weergeven van deze QR-code leidt op zichzelf niet tot het verzenden van resultaten."),
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
        "patientClinicalDataEdit_help": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm kunt u de administratieve gegevens en het profiel van de patiënt invullen.\n\nU kunt zijn gezondheidsnummer, de bron van zijn identiteit, zijn telefoonnummer, zijn e-mailadres en zijn postadres invullen.\n\nHet profiel omvat de dominante hand, het beroep, de sportactiviteit, de lengte in centimeters en het gewicht in kilogram.\n\nKlik op „Opslaan“ om uw wijzigingen op te slaan en terug te keren naar het patiëntendossier. Als u teruggaat zonder op te slaan, gaan de wijzigingen verloren."),
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
        "patientDetail_editCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u de gegevens van de patiëntbehandeling wijzigen.\n\nU kunt de aandoening of de reden voor de behandeling corrigeren, de oorspronkelijke tekst aanvullen en de verwijzende arts en de voorschrijvende arts selecteren.\n\nDe aandoening moet worden ingevuld om de wijzigingen op te slaan.\n\nKlik op ‘Opslaan’ om de wijzigingen te bevestigen. Met ‘Annuleren’ sluit u het venster zonder de wijzigingen toe te passen.\n\nWanneer u deze helptekst opent en sluit, blijven uw invoergegevens in het formulier bewaard."),
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
        "patientDetail_newCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u een nieuwe behandeling aanmaken voor de geselecteerde patiënt.\n\nVul de aandoening of de reden voor de behandeling in. Deze informatie is nodig om de behandelingsperiode aan te maken.\n\nU kunt de eerste tekst aanvullen en een verwijzende arts selecteren. Deze gegevens zijn optioneel.\n\nKlik op ‘Aanmaken’ om de behandelingsperiode op te slaan. Met ‘Annuleren’ sluit u het venster zonder de behandelingsperiode aan te maken.\n\nWanneer u deze hulp opent en sluit, blijven uw gegevens in het formulier bewaard."),
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
        "patientDocuments_authorization": MessageLookupByLibrary.simpleMessage(
            "De map moet opnieuw worden geautoriseerd. Selecteer de gedeelde map die in de instellingen is gedefinieerd."),
        "patientDocuments_chooseRoot": MessageLookupByLibrary.simpleMessage(
            "De gemeenschappelijke map selecteren"),
        "patientDocuments_error": MessageLookupByLibrary.simpleMessage(
            "Het is niet mogelijk om het bestand voor te bereiden of te openen. Controleer of het bestand beschikbaar is en of u de juiste toegangsrechten hebt, en probeer het vervolgens opnieuw.\""),
        "patientDocuments_open":
            MessageLookupByLibrary.simpleMessage("De patiëntendossier openen"),
        "patientDocuments_retry":
            MessageLookupByLibrary.simpleMessage("Opnieuw proberen"),
        "patientDocuments_settingsHelp": MessageLookupByLibrary.simpleMessage(
            "Eén dossier per patiënt, met daarin ‘Overzicht’, ‘Verslag’ en ‘Overige’. Wordt aangemaakt bij het openen van het dossier; bestaande bestanden worden niet verplaatst."),
        "patientDocuments_structure": MessageLookupByLibrary.simpleMessage(
            "Overzicht / Verslag / Overig"),
        "patientDocuments_title":
            MessageLookupByLibrary.simpleMessage("Patiëntendocumenten"),
        "patientDocuments_unconfigured": MessageLookupByLibrary.simpleMessage(
            "Er is geen opslagmap gedefinieerd. Kies de map die voor alle patiënten geldt."),
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
        "patientForm_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u de gegevens van de patiënt invoeren of corrigeren.\n\nDe voor- en achternaam zijn verplicht. U kunt de geboortedatum in de kalender selecteren en het geslacht invullen, of de waarde „Niet opgegeven” behouden.\n\nKlik op „Opslaan“ om de wijzigingen te bevestigen. Als het formulier in de aanmaakmodus is geopend, kunt u met de knop „Aanmaken“ het dossier aanmaken.\n\nMet „Annuleren“ sluit u het venster zonder de wijzigingen toe te passen. Bij het openen en sluiten van deze helpfunctie blijven uw invoergegevens in het formulier behouden."),
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
        "patientList_archiveConfirmation": m36,
        "patientList_archiveSuccess": m37,
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
        "patientList_error": m38,
        "patientList_help": MessageLookupByLibrary.simpleMessage(
            "Via dit scherm kunt u uw patiënten opzoeken en hun dossier openen.\n\nMet de knoppen ‘Actief’ en ‘Gearchiveerd’ kunt u kiezen welke lijst wordt weergegeven. Het weergegeven aantal komt overeen met het totale aantal patiënten in elke categorie.\n\nOm een patiënt in de weergegeven lijst te zoeken, voert u de volledige of een deel van zijn achternaam of voornaam in het zoekveld in. Klik op de betreffende regel om het dossier te openen.\n\nMet de knop ‘Nieuwe patiënt’ opent u het scherm voor het aanmaken van een patiënt.\n\nBij een actieve patiënt kunt u met het potloodpictogram de gegevens wijzigen. Met het archiveringspictogram kunt u de patiënt na bevestiging uit de lijst met actieve patiënten verwijderen.\n\nIn de lijst met gearchiveerde patiënten kunt u met het pictogram ‘Herstellen’ een patiënt weer in de lijst met actieve patiënten plaatsen. Een specifieke helptekst, die naast de archiveringsdatum te vinden is, geeft uitleg over de bewaartermijnen."),
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
        "patientList_restoreSuccess": m39,
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
        "patientNew_attachVitaleSuccess": m40,
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
        "patientNew_help": MessageLookupByLibrary.simpleMessage(
            "Via dit scherm kunt u een patiënt aanmaken in ABAK Companion.\n\nVoer de voor- en achternaam in: deze twee gegevens zijn verplicht. U kunt de geboortedatum invullen met behulp van de kalender en het geslacht opgeven.\n\nMet de knop voor het lezen van de Vitale-kaart kunt u de identiteit van de patiënt ophalen wanneer de lezer en de leesmodule beschikbaar zijn. Als er meerdere begunstigden worden voorgesteld, selecteer dan de betreffende persoon en controleer vervolgens de weergegeven gegevens. Handmatige invoer blijft mogelijk.\n\nAls Companion een reeds bestaande patiënt detecteert, controleer dan de voorgestelde gegevens voordat u verdergaat om een dubbele registratie te voorkomen. Een gearchiveerde patiënt kan worden voorgesteld om te worden hersteld.\n\nKlik op ‘Patiënt aanmaken’ om het dossier op te slaan, of op ‘Annuleren’ om af te sluiten zonder een patiënt aan te maken."),
        "patientNew_identificationCountriesHelp":
            MessageLookupByLibrary.simpleMessage(
                "Het inlezen van de Vitale-kaart in Companion is momenteel beperkt tot Frankrijk. Hiermee kunnen identiteitsgegevens worden opgehaald om het aanmaken van het patiëntendossier te vergemakkelijken.\n\nABAK Companion wil deze werkwijze uitbreiden naar identificatiemiddelen die in andere landen worden gebruikt. Kaarten, identificatiegegevens en gezondheidsdiensten werken daar anders: de ondersteuning hiervoor is nog niet geïntegreerd in Companion. Handmatige invoer blijft mogelijk.\n\nWe willen deze mogelijkheden graag verkennen samen met de fysiotherapeuten die ABAK gebruiken. Wilt u ons hierin ondersteunen in uw land? Uw kennis van de lokale praktijken en uw deelname aan de proeven zullen ons helpen een nuttige en passende oplossing te ontwikkelen.\n\nDe ontwikkelingen zullen geleidelijk worden doorgevoerd in samenwerking met vrijwillige zorgverleners, op basis van de aangegeven behoeften, de technische mogelijkheden en de benodigde vergunningen."),
        "patientNew_identificationCountriesTitle":
            MessageLookupByLibrary.simpleMessage(
                "Identificatie van patiënten per land"),
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
            MessageLookupByLibrary.simpleMessage("Lees de gezondheidskaart"),
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
        "patientNew_restoreSuccess": m41,
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
        "practitionerList_archiveConfirmation": m42,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "De prullenbak van de fysiotherapeuten is op dit moment leeg."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage(
                "De fysiotherapeut archiveren"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Gearchiveerd"),
        "practitionerList_archivedOn": m43,
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
        "practitionerList_error": m44,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Geen fysiotherapeuten in het archief"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "Er zijn geen fysiotherapeuten geregistreerd"),
        "practitionerList_professionalId": m45,
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
        "practitionerNew_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u het profiel van een zorgverlener aanmaken of wijzigen.\n\nDe weergegeven naam is verplicht: hiermee kan de zorgverlener in Companion worden geïdentificeerd. U kunt ook zijn voornaam, achternaam, beroepsidentificatienummer, e-mailadres en telefoonnummer invullen.\n\nKlik op ‘Aanmaken’ om een zorgverlener toe te voegen of op ‘Opslaan’ om de wijzigingen in een bestaand profiel te bevestigen.\n\nMet ‘Annuleren’ sluit u het venster zonder de wijzigingen toe te passen. Wanneer u deze helptekst opent en sluit, blijven uw invoergegevens in het formulier bewaard."),
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
        "practitionerQr_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster wordt de QR-code van het beroepsprofiel van de zorgverlener weergegeven, samen met zijn of haar naam en de naam van de praktijk.\n\nScan deze QR-code met ABAK Mobile om de zorgverlener in deze instelling te identificeren. Controleer of de weergegeven naam overeenkomt met die van de betreffende zorgverlener.\n\nDeze QR-code dient om de identificatiegegevens van het professionele profiel door te geven; het weergeven ervan leidt niet tot het doorsturen van resultaten.\n\nSluit dit venster om terug te keren naar de lijst met zorgverleners."),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("ABAK-beroepsprofiel"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Scan deze QR-code via ABAK Mobile om dit professionele profiel automatisch toe te voegen."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("gearchiveerd"),
        "practitionerSelector_error": m46,
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
        "referringPractitionerHistoryDialog_archivedPractitioner": m47,
        "referringPractitionerHistoryDialog_close":
            MessageLookupByLibrary.simpleMessage("Sluiten"),
        "referringPractitionerHistoryDialog_currentPractitioner":
            MessageLookupByLibrary.simpleMessage("Huidige contactpersoon"),
        "referringPractitionerHistoryDialog_fromTo": m48,
        "referringPractitionerHistoryDialog_loadHistoryError": m49,
        "referringPractitionerHistoryDialog_noHistory":
            MessageLookupByLibrary.simpleMessage(
                "Er is voor deze aflevering nog geen fysiotherapeut geregistreerd."),
        "referringPractitionerHistoryDialog_since": m50,
        "referringPractitionerHistory_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster worden de zorgverleners weergegeven die als contactpersoon voor dit zorgtraject zijn aangewezen.\n\nElke regel vermeldt de naam van de zorgverlener en de periode waarin hij of zij is aangewezen. De vermelding „Huidige contactpersoon” geeft aan welke zorgverlener momenteel aan het zorgtraject is gekoppeld.\n\nDe vermelding „Gearchiveerd“ betekent dat het dossier van de zorgverlener is gearchiveerd; zijn of haar naam blijft zichtbaar in de geschiedenis.\n\nIn dit venster kunt u alleen de geschiedenis raadplegen. Sluit het venster om terug te keren naar het zorgtraject."),
        "referringPractitionerHistory_title":
            MessageLookupByLibrary.simpleMessage(
                "Overzicht van de verwijzende kinesisten"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Het dashboard vernieuwen"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Archief van de verslagen"),
        "reportDraft_help": MessageLookupByLibrary.simpleMessage(
            "De weergegeven tekst is een automatisch opgeslagen concept. U kunt deze behouden, wijzigen of verwijderen voordat u uw rapport opslaat."),
        "reportDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Inzicht krijgen in het conceptverslag"),
        "reportHistory_help": MessageLookupByLibrary.simpleMessage(
            "In dit overzicht worden de opgeslagen rapporten voor de zorgverlening weergegeven, met hun titel en datum.\n\nMet de acties in elke rij kunt u een rapport bewerken, dupliceren of verplaatsen naar de gearchiveerde documenten.\n\nWanneer een rapport is geopend om te bewerken, gebruikt u de actie ‘Bijwerken’ om uw wijzigingen op te slaan. Met de beschikbare knoppen kunt u ook de wijzigingen ongedaan maken of terugkeren naar het concept.\n\nHet verplaatsen naar de gearchiveerde documenten is geen definitieve verwijdering.\n\nKlik op het kruisje om de vergrote weergave te sluiten en terug te keren naar het gedeelte Balansen/Rapporten."),
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
        "resultDetail_help": MessageLookupByLibrary.simpleMessage(
            "Dit scherm toont de gegevens van een resultaat dat is geïmporteerd vanuit ABAK Mobile: patiënt, datum van uitvoering, score en, indien beschikbaar, gebruikte hulpmiddelen, identiteit van de behandelaar en het apparaat van herkomst.\n\nU kunt het gedetailleerde rapport en de aanvullende metingen die bij de test zijn verstrekt, raadplegen.\n\nIn het veld ‘Klinische opmerking’ kunt u uw opmerkingen toevoegen of wijzigen. Klik op ‘Opslaan’ om deze op te slaan voordat u het scherm verlaat.\n\nIn het gedeelte over het importeren wordt de synchronisatiestatus en de datum van de laatste wijziging van het resultaat weergegeven.\n\nMet het archiveringspictogram kunt u dit resultaat na bevestiging archiveren."),
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
        "settings_databaseResetError": m51,
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
        "settings_exportAction":
            MessageLookupByLibrary.simpleMessage("Exporteren"),
        "settings_exportCancel":
            MessageLookupByLibrary.simpleMessage("Annuleren"),
        "settings_exportCancelled":
            MessageLookupByLibrary.simpleMessage("Export geannuleerd"),
        "settings_exportChooseDestination":
            MessageLookupByLibrary.simpleMessage("De bestemmingsmap kiezen"),
        "settings_exportCompleted": m52,
        "settings_exportCompletedWithErrors": m53,
        "settings_exportDataDescription": MessageLookupByLibrary.simpleMessage(
            "Er wordt een archief aangemaakt met de gegevens van uw patiënten, evenals hun onderzoeksresultaten en rapporten."),
        "settings_exportFailed": MessageLookupByLibrary.simpleMessage(
            "Het is niet mogelijk om de gegevens te exporteren"),
        "settings_exportIncludeArchivedPatients":
            MessageLookupByLibrary.simpleMessage(
                "Gearchiveerde patiënten meenemen"),
        "settings_exportMyData":
            MessageLookupByLibrary.simpleMessage("Mijn gegevens exporteren"),
        "settings_exportPatientBirthDate":
            MessageLookupByLibrary.simpleMessage("Geboortedatum"),
        "settings_exportPatientFemale":
            MessageLookupByLibrary.simpleMessage("Vrouwelijk"),
        "settings_exportPatientFirstName":
            MessageLookupByLibrary.simpleMessage("Voornaam"),
        "settings_exportPatientLastName":
            MessageLookupByLibrary.simpleMessage("Naam"),
        "settings_exportPatientMale":
            MessageLookupByLibrary.simpleMessage("Mannelijk"),
        "settings_exportPatientSex":
            MessageLookupByLibrary.simpleMessage("Seks"),
        "settings_exportPatientUnknown":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "settings_exportPatientUnknownFemale":
            MessageLookupByLibrary.simpleMessage("Niet opgegeven"),
        "settings_help": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm zijn de installatie-, diagnose- en onderhoudsfuncties van Companion gebundeld. Gebruik deze functies volgens de aanwijzingen in de ABAK-documentatie of op advies van een technicus.\n\nVia het tabblad ‘Configuratie’ kunt u de map raadplegen, openen of wijzigen die wordt gebruikt voor de uitwisseling van bestanden.\n\nVia het tabblad ‘Diagnose’ kunt u controles uitvoeren op het leesapparaat voor de Vitale-kaart.\n\nVia het tabblad ‘Onderhoud’ kunt u de wizard voor het oplossen van importproblemen openen, handmatig een ABAK-bestand importeren en het beheer van back-ups openen.\n\nHet resetten van de database verwijdert de lokale gegevens. Deze handeling is uitsluitend bedoeld voor technische ondersteuning: lees de bevestigingsberichten aandachtig door voordat u doorgaat."),
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
        "speechDictationButton_audio": MessageLookupByLibrary.simpleMessage(
            "Er is geen geluidsopname beschikbaar."),
        "speechDictationButton_close":
            MessageLookupByLibrary.simpleMessage("Sluiten"),
        "speechDictationButton_dictate":
            MessageLookupByLibrary.simpleMessage("Woede"),
        "speechDictationButton_download":
            MessageLookupByLibrary.simpleMessage("De module downloaden"),
        "speechDictationButton_failure": m54,
        "speechDictationButton_information": MessageLookupByLibrary.simpleMessage(
            "Voor spraakdictee moet de optionele module ABAK Spraakdictee worden geïnstalleerd.\n\nDeze module is gratis en werkt lokaal op uw computer, zonder dat de spraakopnames via internet worden verzonden.\n\nDe download is ongeveer 1,5 GB groot."),
        "speechDictationButton_stop":
            MessageLookupByLibrary.simpleMessage("Het dictee stoppen"),
        "speechDictationButton_title":
            MessageLookupByLibrary.simpleMessage("Spraakdictee"),
        "speechRecordingService_permission":
            MessageLookupByLibrary.simpleMessage(
                "Toegang tot de microfoon is niet toegestaan."),
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
        "vitaleBeneficiarySelector_help": MessageLookupByLibrary.simpleMessage(
            "In dit venster kunt u de betreffende persoon selecteren wanneer er na het inlezen van de Vitale-kaart meerdere begunstigden worden voorgesteld.\n\nControleer de achternaam, de voornaam en de geboortedatum (indien beschikbaar) en klik vervolgens op de regel van de gewenste begunstigde.\n\nDoor deze keuze te maken, wordt dit venster gesloten en wordt de gekozen identiteit doorgegeven naar de volgende stap.\n\nMet ‘Annuleren’ sluit u het venster zonder een begunstigde te selecteren."),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage("Kies een begunstigde"),
        "vitaleDiagnostic_help": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm kunt u controleren of de Vitale-kaartlezer goed werkt.\n\nIn Windows geeft het gedeelte over de module de status weer en kunt u deze informatie vernieuwen.\n\nStart een leessessie met de aangesloten lezer en de kaart erin. Als er meerdere begunstigden worden voorgesteld, selecteer dan de betreffende persoon om de gelezen gegevens te bekijken.\n\nDe weergegeven meldingen geven inzicht in een eventuele fout en kunnen aan de helpdesk worden doorgegeven.\n\nHet onderdeel „Geavanceerde diagnose“ biedt een technische test voor de communicatie met de kaart. Gebruik deze volgens de aanwijzingen in de ABAK-documentatie of van een technicus.\n\nDit scherm dient voor diagnostische doeleinden: het uitlezen van een identiteit leidt niet tot het aanmaken van een patiëntendossier."),
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
        "vitaleIdentity_help": MessageLookupByLibrary.simpleMessage(
            "Op dit scherm kunt u de gegevens van een verzekerde van een Vitale-kaart uitlezen, mits de lezer en de leesmodule beschikbaar zijn.\n\nHet uitlezen begint zodra het scherm wordt geopend. U kunt het proces opnieuw starten met de uitleesknop. Als er meerdere verzekerden op de kaart staan, selecteer dan de betreffende persoon.\n\nControleer de achternaam, de voornaam, de geboortedatum en de overige weergegeven gegevens. Het identificatienummer wordt aangeduid als ‘gedetecteerd’ of ‘niet beschikbaar’, zonder dat het volledig wordt weergegeven.\n\nWanneer de identiteit bruikbaar is, kunt u met de knop ‘Patiënt aanmaken’ deze gegevens doorsturen naar het aanmaakformulier.\n\nAls er geen identiteit beschikbaar is, raadpleeg dan het weergegeven bericht en controleer het leesapparaat voordat u het opnieuw probeert. U kunt terugkeren naar het vorige scherm om de gegevens handmatig in te voeren."),
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
            MessageLookupByLibrary.simpleMessage("Niet beschikbaar"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Gebruik dit om een patiënt aan te maken"),
        "walkingAid_cane": MessageLookupByLibrary.simpleMessage("Wandelstok"),
        "walkingAid_label":
            MessageLookupByLibrary.simpleMessage("Gebruikte hulpbronnen"),
        "walkingAid_none": MessageLookupByLibrary.simpleMessage("Geen"),
        "walkingAid_other": MessageLookupByLibrary.simpleMessage("Overig"),
        "walkingAid_rollatorFourWheels":
            MessageLookupByLibrary.simpleMessage("Rollator met 4 wielen"),
        "walkingAid_walkerTwoWheels":
            MessageLookupByLibrary.simpleMessage("Looprek met 2 wielen")
      };
}
