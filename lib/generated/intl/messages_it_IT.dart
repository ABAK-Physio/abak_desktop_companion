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

  static String m0(careEpisodeId) =>
      "Impossibile individuare il paziente associato all\'episodio di cura ${careEpisodeId}.";

  static String m1(height) => "${height} cm";

  static String m2(weight) => "${weight} kg";

  static String m3(age) => "${age} anni";

  static String m4(size) => "${size}";

  static String m5(deviceName) => "Vuoi davvero archiviare ${deviceName}?";

  static String m6(fieldName) => "Il campo \"${fieldName}\" è obbligatorio.";

  static String m7(noteTitle) =>
      "La nota \"${noteTitle}\" non verrà più visualizzata.";

  static String m8(error) => "Errore durante il salvataggio: ${error}";

  static String m9(count) => "${count} altro/i esercizio/i";

  static String m10(count) => "${count} associazione/i in attesa";

  static String m11(count) => "${count} salvataggi";

  static String m12(size) => "Taglia: ${size}";

  static String m13(size) => "Dimensioni totali: ${size}";

  static String m14(version) => "Versione ${version}";

  static String m15(integrityStatus) =>
      "La base restaurata presenta un\'anomalia: ${integrityStatus}";

  static String m16(error) => "Ripristino non riuscito: ${error}";

  static String m17(integrityStatus) =>
      "Il ripristino è stato completato, ma integrity_check ha restituito: ${integrityStatus}";

  static String m18(patientName) =>
      "Vuoi davvero archiviare ${patientName}? Non apparirà più nell\'elenco attivo.";

  static String m19(patientName) => "${patientName} archiviato.";

  static String m20(error) => "Errore: ${error}";

  static String m21(patientName) =>
      "${patientName} reinserito nell\'elenco attivo.";

  static String m22(patientName) =>
      "Tessera sanitaria associata al paziente ${patientName}.";

  static String m23(patientName) =>
      "Il paziente ${patientName} è stato rianimato.";

  static String m24(practitionerName) =>
      "Vuoi davvero archiviare ${practitionerName}?";

  static String m25(date) => "Archiviato il ${date}";

  static String m26(error) => "Errore: ${error}";

  static String m27(professionalId) => "ID pro: ${professionalId}";

  static String m28(error) => "Errore: ${error}";

  static String m29(error) => "Errore durante il ripristino: ${error}";

  static String m30(error) =>
      "Il dettato vocale non è andato a buon fine: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "abakWhisperSpeechProvider_name":
            MessageLookupByLibrary.simpleMessage("ABAK Dettatura vocale"),
        "assessmentDocumentDataBuilder_female":
            MessageLookupByLibrary.simpleMessage("Femminile"),
        "assessmentDocumentDataBuilder_male":
            MessageLookupByLibrary.simpleMessage("Maschile"),
        "assessmentDocumentDataBuilder_patient": m0,
        "assessmentDocxService_age":
            MessageLookupByLibrary.simpleMessage("Età"),
        "assessmentDocxService_assessment":
            MessageLookupByLibrary.simpleMessage("con"),
        "assessmentDocxService_attachment":
            MessageLookupByLibrary.simpleMessage(
                "Patologia durante il ricongiungimento"),
        "assessmentDocxService_author":
            MessageLookupByLibrary.simpleMessage("Redattore"),
        "assessmentDocxService_centimetres": m1,
        "assessmentDocxService_chart":
            MessageLookupByLibrary.simpleMessage("Grafico"),
        "assessmentDocxService_declared": MessageLookupByLibrary.simpleMessage(
            "Età dichiarata al momento del test"),
        "assessmentDocxService_diagnosis": MessageLookupByLibrary.simpleMessage(
            "Patologia riscontrata durante il test"),
        "assessmentDocxService_dominance":
            MessageLookupByLibrary.simpleMessage("Lato dominante"),
        "assessmentDocxService_establishment":
            MessageLookupByLibrary.simpleMessage("Struttura"),
        "assessmentDocxService_firstname":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "assessmentDocxService_height":
            MessageLookupByLibrary.simpleMessage("Dimensioni"),
        "assessmentDocxService_information":
            MessageLookupByLibrary.simpleMessage("Informazioni sul paziente"),
        "assessmentDocxService_kilograms": m2,
        "assessmentDocxService_notes": MessageLookupByLibrary.simpleMessage(
            "Note di monitoraggio selezionate"),
        "assessmentDocxService_opened": MessageLookupByLibrary.simpleMessage(
            "Servizio disponibile a partire dal"),
        "assessmentDocxService_pathology":
            MessageLookupByLibrary.simpleMessage("Patologia"),
        "assessmentDocxService_patient":
            MessageLookupByLibrary.simpleMessage("Paziente"),
        "assessmentDocxService_performed":
            MessageLookupByLibrary.simpleMessage("Realizzato il"),
        "assessmentDocxService_practitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapista di riferimento"),
        "assessmentDocxService_printed":
            MessageLookupByLibrary.simpleMessage("Stampato il"),
        "assessmentDocxService_profession":
            MessageLookupByLibrary.simpleMessage("Professione"),
        "assessmentDocxService_recipients":
            MessageLookupByLibrary.simpleMessage("Destinatario/i"),
        "assessmentDocxService_results": MessageLookupByLibrary.simpleMessage(
            "Risultati dei test selezionati"),
        "assessmentDocxService_sex":
            MessageLookupByLibrary.simpleMessage("Sesso"),
        "assessmentDocxService_sport":
            MessageLookupByLibrary.simpleMessage("Attività sportiva"),
        "assessmentDocxService_surname":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "assessmentDocxService_title":
            MessageLookupByLibrary.simpleMessage("con"),
        "assessmentDocxService_weight":
            MessageLookupByLibrary.simpleMessage("Peso"),
        "assessmentDocxService_years": m3,
        "backupHistory_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "Non è stato salvato alcun backup."),
        "backupHistory_fileSize": m4,
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Ripristina"),
        "backupHistory_restoreTitle":
            MessageLookupByLibrary.simpleMessage("Ripristinare questo backup?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Questa operazione sostituirà completamente il database attuale.\n\nPrima del ripristino verrà creato un backup di sicurezza automatico.\n\nVuoi continuare?"),
        "backupHistory_title":
            MessageLookupByLibrary.simpleMessage("Cronologia dei backup"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origine ABAK"),
        "careEpisodeDetail_evolution":
            MessageLookupByLibrary.simpleMessage("Evoluzione"),
        "careEpisodeDetail_noResult": MessageLookupByLibrary.simpleMessage(
            "Al momento non ci sono risultati corrispondenti."),
        "careEpisodeDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Patologia"),
        "careEpisodeDetail_reportsWorkspaceTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Nuova interfaccia per bilanci e report"),
        "careEpisodeDetail_results":
            MessageLookupByLibrary.simpleMessage("Risultati ABAK"),
        "careEpisodeDetail_score":
            MessageLookupByLibrary.simpleMessage("Punteggio"),
        "careEpisodeReportsWorkspace_addFollowUpNote":
            MessageLookupByLibrary.simpleMessage(
                "Aggiungi una nota di follow-up"),
        "careEpisodeReportsWorkspace_archived":
            MessageLookupByLibrary.simpleMessage("archiviato"),
        "careEpisodeReportsWorkspace_archivedDocuments":
            MessageLookupByLibrary.simpleMessage("Documenti archiviati"),
        "careEpisodeReportsWorkspace_archivedDocumentsCount":
            MessageLookupByLibrary.simpleMessage("Documenti archiviati"),
        "careEpisodeReportsWorkspace_assessment":
            MessageLookupByLibrary.simpleMessage("con"),
        "careEpisodeReportsWorkspace_assessmentCount":
            MessageLookupByLibrary.simpleMessage("Numero di bilanci"),
        "careEpisodeReportsWorkspace_assessmentHistory":
            MessageLookupByLibrary.simpleMessage("Cronologia dei bilanci"),
        "careEpisodeReportsWorkspace_assessmentsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile caricare i bilanci."),
        "careEpisodeReportsWorkspace_cancel":
            MessageLookupByLibrary.simpleMessage("Annulla"),
        "careEpisodeReportsWorkspace_cancelChanges":
            MessageLookupByLibrary.simpleMessage("Annulla le modifiche"),
        "careEpisodeReportsWorkspace_createOrResumeAssessment":
            MessageLookupByLibrary.simpleMessage(
                "Creare o riprendere un bilancio"),
        "careEpisodeReportsWorkspace_createOrResumeReport":
            MessageLookupByLibrary.simpleMessage(
                "Creare o riprendere un rapporto"),
        "careEpisodeReportsWorkspace_date":
            MessageLookupByLibrary.simpleMessage("Dati"),
        "careEpisodeReportsWorkspace_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Elimina definitivamente"),
        "careEpisodeReportsWorkspace_duplicate":
            MessageLookupByLibrary.simpleMessage("Duplica"),
        "careEpisodeReportsWorkspace_edit":
            MessageLookupByLibrary.simpleMessage("Modifica"),
        "careEpisodeReportsWorkspace_editReferringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Modifica il fisioterapista di riferimento"),
        "careEpisodeReportsWorkspace_episodeDocuments":
            MessageLookupByLibrary.simpleMessage(
                "Documenti relativi all\'assistenza"),
        "careEpisodeReportsWorkspace_episodeSummary":
            MessageLookupByLibrary.simpleMessage("Sintesi dell’episodio"),
        "careEpisodeReportsWorkspace_expand":
            MessageLookupByLibrary.simpleMessage("Ingrandisci"),
        "careEpisodeReportsWorkspace_expandEditor":
            MessageLookupByLibrary.simpleMessage(
                "Ingrandisci l\'area di scrittura"),
        "careEpisodeReportsWorkspace_followUpNoteDefaultTitle":
            MessageLookupByLibrary.simpleMessage("Nota di aggiornamento"),
        "careEpisodeReportsWorkspace_followUpNotes":
            MessageLookupByLibrary.simpleMessage("Note di monitoraggio"),
        "careEpisodeReportsWorkspace_followUpNotesLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile caricare le note di follow-up."),
        "careEpisodeReportsWorkspace_include":
            MessageLookupByLibrary.simpleMessage("Includere"),
        "careEpisodeReportsWorkspace_latestTests":
            MessageLookupByLibrary.simpleMessage(
                "Test effettuati (ultimo risultato)"),
        "careEpisodeReportsWorkspace_loading":
            MessageLookupByLibrary.simpleMessage("Caricamento in corso…"),
        "careEpisodeReportsWorkspace_moveToTrash":
            MessageLookupByLibrary.simpleMessage("Spostare nel cestino"),
        "careEpisodeReportsWorkspace_name":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "careEpisodeReportsWorkspace_newAssessment":
            MessageLookupByLibrary.simpleMessage("Bilancio (nuovo)"),
        "careEpisodeReportsWorkspace_noAssessments":
            MessageLookupByLibrary.simpleMessage(
                "Non è stato registrato alcun bilancio."),
        "careEpisodeReportsWorkspace_noDocument":
            MessageLookupByLibrary.simpleMessage("Nessun documento"),
        "careEpisodeReportsWorkspace_noFollowUpNotes":
            MessageLookupByLibrary.simpleMessage("Nessuna nota di follow-up."),
        "careEpisodeReportsWorkspace_noReports":
            MessageLookupByLibrary.simpleMessage(
                "Non sono stati registrati rapporti."),
        "careEpisodeReportsWorkspace_noTests":
            MessageLookupByLibrary.simpleMessage(
                "Per questo episodio non è stato effettuato alcun test."),
        "careEpisodeReportsWorkspace_notProvided":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "careEpisodeReportsWorkspace_note":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "careEpisodeReportsWorkspace_pathology":
            MessageLookupByLibrary.simpleMessage("Patologia"),
        "careEpisodeReportsWorkspace_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapista di riferimento"),
        "careEpisodeReportsWorkspace_referringPractitionerHistory":
            MessageLookupByLibrary.simpleMessage(
                "Cronologia dei fisioterapisti di riferimento"),
        "careEpisodeReportsWorkspace_report":
            MessageLookupByLibrary.simpleMessage("Relazione"),
        "careEpisodeReportsWorkspace_reportCount":
            MessageLookupByLibrary.simpleMessage("Numero di rapporti"),
        "careEpisodeReportsWorkspace_reportHistory":
            MessageLookupByLibrary.simpleMessage("Cronologia dei rapporti"),
        "careEpisodeReportsWorkspace_reportsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile caricare i rapporti."),
        "careEpisodeReportsWorkspace_restore":
            MessageLookupByLibrary.simpleMessage("Ripristina"),
        "careEpisodeReportsWorkspace_result":
            MessageLookupByLibrary.simpleMessage("Risultato"),
        "careEpisodeReportsWorkspace_returnToDraft":
            MessageLookupByLibrary.simpleMessage("Torna alla bozza"),
        "careEpisodeReportsWorkspace_returnToReportDraft":
            MessageLookupByLibrary.simpleMessage(
                "Torna alla bozza della relazione"),
        "careEpisodeReportsWorkspace_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Salva il bilancio"),
        "careEpisodeReportsWorkspace_saveReport":
            MessageLookupByLibrary.simpleMessage("Salva il rapporto"),
        "careEpisodeReportsWorkspace_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Area di redazione del resoconto SOAP.\n\nS — Soggettivo\n\nO — Oggettivo\n\nA — Analisi\n\nP — Piano"),
        "careEpisodeReportsWorkspace_test":
            MessageLookupByLibrary.simpleMessage("Test"),
        "careEpisodeReportsWorkspace_testCount":
            MessageLookupByLibrary.simpleMessage("Numero di test"),
        "careEpisodeReportsWorkspace_testsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile caricare i test."),
        "careEpisodeReportsWorkspace_title":
            MessageLookupByLibrary.simpleMessage("Titolo"),
        "careEpisodeReportsWorkspace_trashLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile caricare il cestino."),
        "careEpisodeReportsWorkspace_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Aggiornare il bilancio"),
        "careEpisodeReportsWorkspace_updateReport":
            MessageLookupByLibrary.simpleMessage("Aggiornare il rapporto"),
        "careEpisode_assessment":
            MessageLookupByLibrary.simpleMessage("Nessuna analisi clinica."),
        "careEpisode_evaluation": MessageLookupByLibrary.simpleMessage(
            "Nessuna valutazione clinica."),
        "careEpisode_report":
            MessageLookupByLibrary.simpleMessage("Nessun resoconto iniziale."),
        "careEpisode_title": MessageLookupByLibrary.simpleMessage("Assistenza"),
        "careEpisode_treatment":
            MessageLookupByLibrary.simpleMessage("Nessun piano terapeutico."),
        "close": MessageLookupByLibrary.simpleMessage("Chiudi"),
        "contactFormTemplateDiagnostic_category":
            MessageLookupByLibrary.simpleMessage("Categoria"),
        "contactFormTemplateDiagnostic_defaultTemplate":
            MessageLookupByLibrary.simpleMessage("Modello predefinito"),
        "contactFormTemplateDiagnostic_error":
            MessageLookupByLibrary.simpleMessage("Errore"),
        "contactFormTemplateDiagnostic_fields":
            MessageLookupByLibrary.simpleMessage("Campi"),
        "contactFormTemplateDiagnostic_no":
            MessageLookupByLibrary.simpleMessage("Non"),
        "contactFormTemplateDiagnostic_noData":
            MessageLookupByLibrary.simpleMessage(
                "Nessun dato da visualizzare."),
        "contactFormTemplateDiagnostic_noTemplate":
            MessageLookupByLibrary.simpleMessage(
                "Non è stato trovato alcun modello di scheda di colloquio iniziale."),
        "contactFormTemplateDiagnostic_notDefined":
            MessageLookupByLibrary.simpleMessage("Non definita"),
        "contactFormTemplateDiagnostic_order":
            MessageLookupByLibrary.simpleMessage("Ordine"),
        "contactFormTemplateDiagnostic_practitioner":
            MessageLookupByLibrary.simpleMessage("Professionista"),
        "contactFormTemplateDiagnostic_refresh":
            MessageLookupByLibrary.simpleMessage("Aggiorna"),
        "contactFormTemplateDiagnostic_required":
            MessageLookupByLibrary.simpleMessage("Obbligatorio"),
        "contactFormTemplateDiagnostic_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Modello di sistema"),
        "contactFormTemplateDiagnostic_templateId":
            MessageLookupByLibrary.simpleMessage("ID modello"),
        "contactFormTemplateDiagnostic_title":
            MessageLookupByLibrary.simpleMessage(
                "Scheda di manutenzione e diagnosi"),
        "contactFormTemplateDiagnostic_type":
            MessageLookupByLibrary.simpleMessage("Tipo"),
        "contactFormTemplateDiagnostic_yes":
            MessageLookupByLibrary.simpleMessage("Sì"),
        "dashboardTitle":
            MessageLookupByLibrary.simpleMessage("Centro clinico locale ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Indirizzo"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Porto"),
        "deviceForm_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Professionista associato"),
        "deviceForm_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "deviceForm_contextName":
            MessageLookupByLibrary.simpleMessage("Nuovo dispositivo"),
        "deviceForm_create": MessageLookupByLibrary.simpleMessage("Crea"),
        "deviceForm_deviceName":
            MessageLookupByLibrary.simpleMessage("Nome del dispositivo"),
        "deviceForm_deviceNameHint": MessageLookupByLibrary.simpleMessage(
            "iPhone di Claire, Pixel di Marc…"),
        "deviceForm_deviceNameRequired": MessageLookupByLibrary.simpleMessage(
            "Il nome del dispositivo è obbligatorio"),
        "deviceForm_editDevice":
            MessageLookupByLibrary.simpleMessage("Modifica il dispositivo"),
        "deviceForm_loadingPractitionersError":
            MessageLookupByLibrary.simpleMessage(
                "Errore durante il caricamento dei professionisti"),
        "deviceForm_newDevice":
            MessageLookupByLibrary.simpleMessage("Nuovo dispositivo"),
        "deviceForm_platform":
            MessageLookupByLibrary.simpleMessage("Piattaforma"),
        "deviceForm_save": MessageLookupByLibrary.simpleMessage("Salva"),
        "deviceForm_sharedDevice": MessageLookupByLibrary.simpleMessage(
            "Nessuno / dispositivo condiviso"),
        "deviceList_active": MessageLookupByLibrary.simpleMessage("Attività"),
        "deviceList_archive": MessageLookupByLibrary.simpleMessage("Archivia"),
        "deviceList_archiveConfirmation": m5,
        "deviceList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archiviare il dispositivo"),
        "deviceList_archived":
            MessageLookupByLibrary.simpleMessage("Archiviati"),
        "deviceList_archivedDevicesEmpty": MessageLookupByLibrary.simpleMessage(
            "Il carrello dei dispositivi è vuoto al momento."),
        "deviceList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archiviato il"),
        "deviceList_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Professionista associato"),
        "deviceList_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "deviceList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra l\'elenco dei dispositivi collegati alla struttura"),
        "deviceList_contextName":
            MessageLookupByLibrary.simpleMessage("Elenco dei dispositivi"),
        "deviceList_edit": MessageLookupByLibrary.simpleMessage("Modifica"),
        "deviceList_error": MessageLookupByLibrary.simpleMessage("Errore"),
        "deviceList_newDevice":
            MessageLookupByLibrary.simpleMessage("Nuovo dispositivo"),
        "deviceList_noArchivedDevices": MessageLookupByLibrary.simpleMessage(
            "Nessun dispositivo archiviato"),
        "deviceList_noPairedDevices": MessageLookupByLibrary.simpleMessage(
            "Nessun dispositivo associato"),
        "deviceList_pairedDevicesExplanation": MessageLookupByLibrary.simpleMessage(
            "Qui verranno visualizzati i dispositivi ABAK associati alla struttura."),
        "deviceList_platform":
            MessageLookupByLibrary.simpleMessage("Piattaforma"),
        "deviceList_restore":
            MessageLookupByLibrary.simpleMessage("Ripristina"),
        "deviceList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Visualizza il codice QR"),
        "deviceList_title":
            MessageLookupByLibrary.simpleMessage("Elenco dei dispositivi"),
        "episodeDashboard_documents":
            MessageLookupByLibrary.simpleMessage("Documenti"),
        "episodeDashboard_documentsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Documenti relativi a questo episodio"),
        "episodeDashboard_forms":
            MessageLookupByLibrary.simpleMessage("Moduli"),
        "episodeDashboard_formsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Questionari specifici relativi a questa puntata"),
        "episodeDashboard_notes": MessageLookupByLibrary.simpleMessage("Note"),
        "episodeDashboard_notesDescription":
            MessageLookupByLibrary.simpleMessage(
                "Osservazioni e commenti del fisioterapista"),
        "episodeDashboard_report":
            MessageLookupByLibrary.simpleMessage("Relazione"),
        "episodeDashboard_reportDescription":
            MessageLookupByLibrary.simpleMessage("Sintesi dell\'episodio"),
        "episodeDocuments_addDocument":
            MessageLookupByLibrary.simpleMessage("Aggiungi un documento"),
        "episodeDocuments_addError": MessageLookupByLibrary.simpleMessage(
            "Impossibile aggiungere il documento"),
        "episodeDocuments_addedOn":
            MessageLookupByLibrary.simpleMessage("Aggiunto il"),
        "episodeDocuments_document":
            MessageLookupByLibrary.simpleMessage("Documento"),
        "episodeDocuments_documentAdded": MessageLookupByLibrary.simpleMessage(
            "Il documento è stato aggiunto alla documentazione."),
        "episodeDocuments_emptyDescription": MessageLookupByLibrary.simpleMessage(
            "È possibile aggiungere un documento di testo, un foglio di calcolo, un PDF, un\'immagine o qualsiasi altro file utile."),
        "episodeDocuments_fileNotFound": MessageLookupByLibrary.simpleMessage(
            "Il file associato non è stato trovato."),
        "episodeDocuments_help": MessageLookupByLibrary.simpleMessage(
            "È possibile associare a questa funzionalità documenti creati con le applicazioni di uso comune: elaboratori di testi, fogli di calcolo, lettori PDF o programmi di elaborazione immagini.\n\nI file aggiunti vengono copiati nello spazio di archiviazione di Companion. Cliccando su un documento, questo viene aperto con l\'applicazione corrispondente installata su quel computer."),
        "episodeDocuments_image":
            MessageLookupByLibrary.simpleMessage("Immagine"),
        "episodeDocuments_loadError": MessageLookupByLibrary.simpleMessage(
            "Impossibile caricare i documenti correlati."),
        "episodeDocuments_noDocument": MessageLookupByLibrary.simpleMessage(
            "Non ci sono documenti associati a questa prestazione."),
        "episodeDocuments_openDocument":
            MessageLookupByLibrary.simpleMessage("Apri il documento"),
        "episodeDocuments_openError":
            MessageLookupByLibrary.simpleMessage("Impossibile aprire il file"),
        "episodeDocuments_pdfDocument":
            MessageLookupByLibrary.simpleMessage("Documento PDF"),
        "episodeDocuments_platformNotSupported":
            MessageLookupByLibrary.simpleMessage(
                "L\'apertura non è supportata su questa piattaforma."),
        "episodeDocuments_refresh":
            MessageLookupByLibrary.simpleMessage("Aggiorna"),
        "episodeDocuments_spreadsheet":
            MessageLookupByLibrary.simpleMessage("Foglio di calcolo"),
        "episodeDocuments_textDocument":
            MessageLookupByLibrary.simpleMessage("Documento di testo"),
        "episodeDocuments_title": MessageLookupByLibrary.simpleMessage(
            "Documenti relativi all\'assistenza"),
        "episodeEvolution_evaluation":
            MessageLookupByLibrary.simpleMessage("valutazione"),
        "episodeEvolution_evaluations":
            MessageLookupByLibrary.simpleMessage("valutazioni"),
        "episodeEvolution_first": MessageLookupByLibrary.simpleMessage("Prima"),
        "episodeEvolution_followedExercises":
            MessageLookupByLibrary.simpleMessage("Esercizi svolti"),
        "episodeEvolution_last": MessageLookupByLibrary.simpleMessage("Ultima"),
        "episodeEvolution_noResults": MessageLookupByLibrary.simpleMessage(
            "Nessun risultato disponibile per questo episodio."),
        "episodeEvolution_singleNumericValue":
            MessageLookupByLibrary.simpleMessage(
                "È disponibile un solo dato numerico"),
        "episodeEvolution_title":
            MessageLookupByLibrary.simpleMessage("Svolgimento dell\'episodio"),
        "episodeEvolution_viewEvolution":
            MessageLookupByLibrary.simpleMessage("Visualizza l\'andamento"),
        "episodeFormEditor_error":
            MessageLookupByLibrary.simpleMessage("Errore"),
        "episodeFormEditor_noField": MessageLookupByLibrary.simpleMessage(
            "Nessun campo da visualizzare."),
        "episodeFormEditor_requiredField": m6,
        "episodeFormEditor_save": MessageLookupByLibrary.simpleMessage("Salva"),
        "episodeFormEditor_title":
            MessageLookupByLibrary.simpleMessage("Modifica il modulo"),
        "episodeForms_availableTemplates":
            MessageLookupByLibrary.simpleMessage("Modelli disponibili"),
        "episodeForms_category":
            MessageLookupByLibrary.simpleMessage("Categoria"),
        "episodeForms_completed":
            MessageLookupByLibrary.simpleMessage("completato"),
        "episodeForms_create": MessageLookupByLibrary.simpleMessage("Crea"),
        "episodeForms_createdForms":
            MessageLookupByLibrary.simpleMessage("Moduli creati"),
        "episodeForms_createdOn":
            MessageLookupByLibrary.simpleMessage("Creato il"),
        "episodeForms_customTemplate":
            MessageLookupByLibrary.simpleMessage("Modello personalizzato"),
        "episodeForms_error": MessageLookupByLibrary.simpleMessage("Errore"),
        "episodeForms_form": MessageLookupByLibrary.simpleMessage("Modulo"),
        "episodeForms_inProgress":
            MessageLookupByLibrary.simpleMessage("in corso"),
        "episodeForms_noAvailableTemplate":
            MessageLookupByLibrary.simpleMessage(
                "Non è disponibile alcun modello di modulo."),
        "episodeForms_noCreatedForm": MessageLookupByLibrary.simpleMessage(
            "Non è stato creato alcun modulo per questo episodio."),
        "episodeForms_noData": MessageLookupByLibrary.simpleMessage(
            "Nessun dato da visualizzare."),
        "episodeForms_refresh":
            MessageLookupByLibrary.simpleMessage("Aggiorna"),
        "episodeForms_state": MessageLookupByLibrary.simpleMessage("Stato"),
        "episodeForms_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Modello di sistema"),
        "episodeForms_title": MessageLookupByLibrary.simpleMessage("Moduli"),
        "episodeNotes_archive":
            MessageLookupByLibrary.simpleMessage("Archivia"),
        "episodeNotes_archiveConfirmation": m7,
        "episodeNotes_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archiviare la nota?"),
        "episodeNotes_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "episodeNotes_content":
            MessageLookupByLibrary.simpleMessage("Contenuto"),
        "episodeNotes_editNote":
            MessageLookupByLibrary.simpleMessage("Modifica il voto"),
        "episodeNotes_error": MessageLookupByLibrary.simpleMessage("Errore"),
        "episodeNotes_modifiedOn":
            MessageLookupByLibrary.simpleMessage("Modificato il"),
        "episodeNotes_newNote":
            MessageLookupByLibrary.simpleMessage("Nuova nota"),
        "episodeNotes_noNote": MessageLookupByLibrary.simpleMessage(
            "Non ci sono note relative a questo episodio."),
        "episodeNotes_noteTitle":
            MessageLookupByLibrary.simpleMessage("Titolo"),
        "episodeNotes_refresh":
            MessageLookupByLibrary.simpleMessage("Aggiorna"),
        "episodeNotes_save": MessageLookupByLibrary.simpleMessage("Salva"),
        "episodeNotes_title": MessageLookupByLibrary.simpleMessage("Note"),
        "episodeNotes_titleRequired":
            MessageLookupByLibrary.simpleMessage("Il titolo è obbligatorio."),
        "episodeReport_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origine ABAK"),
        "episodeReport_addConclusion":
            MessageLookupByLibrary.simpleMessage("Aggiungere una conclusione"),
        "episodeReport_clinicalConclusion":
            MessageLookupByLibrary.simpleMessage("Conclusione clinica"),
        "episodeReport_conclusionRequired":
            MessageLookupByLibrary.simpleMessage(
                "La conclusione non può essere vuota."),
        "episodeReport_documents":
            MessageLookupByLibrary.simpleMessage("Documenti"),
        "episodeReport_dominantSide":
            MessageLookupByLibrary.simpleMessage("Lato dominante"),
        "episodeReport_editConclusion":
            MessageLookupByLibrary.simpleMessage("Modifica la conclusione"),
        "episodeReport_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "episodeReport_error": MessageLookupByLibrary.simpleMessage("Errore"),
        "episodeReport_forms": MessageLookupByLibrary.simpleMessage("Moduli"),
        "episodeReport_generatedPreview": MessageLookupByLibrary.simpleMessage(
            "Panoramica del rapporto generato"),
        "episodeReport_generatingPreview": MessageLookupByLibrary.simpleMessage(
            "Generazione dell\'anteprima del testo..."),
        "episodeReport_name": MessageLookupByLibrary.simpleMessage("Nome"),
        "episodeReport_noConclusion": MessageLookupByLibrary.simpleMessage(
            "Nessuna conclusione riportata."),
        "episodeReport_noData": MessageLookupByLibrary.simpleMessage(
            "Nessun dato da visualizzare."),
        "episodeReport_noDocument":
            MessageLookupByLibrary.simpleMessage("Nessun documento associato"),
        "episodeReport_noForm":
            MessageLookupByLibrary.simpleMessage("Nessun modulo associato"),
        "episodeReport_noNote":
            MessageLookupByLibrary.simpleMessage("Nessuna nota associata"),
        "episodeReport_noResult": MessageLookupByLibrary.simpleMessage(
            "Nessun risultato corrispondente"),
        "episodeReport_notProvided":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "episodeReport_notes": MessageLookupByLibrary.simpleMessage("Note"),
        "episodeReport_patient":
            MessageLookupByLibrary.simpleMessage("Paziente"),
        "episodeReport_phone": MessageLookupByLibrary.simpleMessage("Telefono"),
        "episodeReport_profession":
            MessageLookupByLibrary.simpleMessage("Professione"),
        "episodeReport_refresh":
            MessageLookupByLibrary.simpleMessage("Aggiorna"),
        "episodeReport_results":
            MessageLookupByLibrary.simpleMessage("Risultati ABAK"),
        "episodeReport_save": MessageLookupByLibrary.simpleMessage("Salva"),
        "episodeReport_score":
            MessageLookupByLibrary.simpleMessage("Punteggio"),
        "episodeReport_sportActivity":
            MessageLookupByLibrary.simpleMessage("Attività sportiva"),
        "episodeReport_title":
            MessageLookupByLibrary.simpleMessage("Relazione"),
        "episodeReport_unknownType":
            MessageLookupByLibrary.simpleMessage("Tipo sconosciuto"),
        "exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Cartella di scambio ripristinata"),
        "exchangeDirectoryService_choose": MessageLookupByLibrary.simpleMessage(
            "Selezionare la cartella di scambio ABAK"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Documentazione di scambio ABAK aggiornata"),
        "externalSpeechToTextProvider_empty":
            MessageLookupByLibrary.simpleMessage(
                "L\'add-on non ha restituito alcuna risposta."),
        "externalSpeechToTextProvider_failure":
            MessageLookupByLibrary.simpleMessage(
                "Errore nell\'add-on di riconoscimento vocale."),
        "externalSpeechToTextProvider_invalid":
            MessageLookupByLibrary.simpleMessage(
                "Risposta non valida da parte del componente aggiuntivo di riconoscimento vocale."),
        "externalSpeechToTextProvider_noText":
            MessageLookupByLibrary.simpleMessage(
                "L\'add-on non ha restituito alcun testo."),
        "externalSpeechToTextProvider_transcription":
            MessageLookupByLibrary.simpleMessage(
                "La trascrizione non è andata a buon fine."),
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
        "homeImportSummary_conflicts":
            MessageLookupByLibrary.simpleMessage("Conflitti"),
        "homeImportSummary_failedFiles":
            MessageLookupByLibrary.simpleMessage("File con errori"),
        "homeImportSummary_importDate":
            MessageLookupByLibrary.simpleMessage("Importazione dati"),
        "homeImportSummary_importedMetrics":
            MessageLookupByLibrary.simpleMessage("Metriche importate"),
        "homeImportSummary_importedResults":
            MessageLookupByLibrary.simpleMessage("Risultati importati"),
        "homeImportSummary_open": MessageLookupByLibrary.simpleMessage("Apri"),
        "homeImportSummary_patients":
            MessageLookupByLibrary.simpleMessage("Pazienti interessati"),
        "homeImportSummary_processedFiles":
            MessageLookupByLibrary.simpleMessage("File elaborati"),
        "homeImportSummary_skippedResults":
            MessageLookupByLibrary.simpleMessage("Risultati ignorati"),
        "homeImportSummary_title":
            MessageLookupByLibrary.simpleMessage("Ultima importazione ABAK"),
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
        "home_error_while_saving": m8,
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
        "home_other_exercises": m9,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Impostazioni"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Percorso"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Paziente ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Pazienti"),
        "home_pending_association": m10,
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
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("file"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("file"),
        "importResolutionAssistant_import":
            MessageLookupByLibrary.simpleMessage("Importa"),
        "importResolutionAssistant_importFailed":
            MessageLookupByLibrary.simpleMessage("Importazione non riuscita"),
        "importResolutionAssistant_importToComplete":
            MessageLookupByLibrary.simpleMessage("Importazione da completare"),
        "importResolutionAssistant_importToReview":
            MessageLookupByLibrary.simpleMessage("Importazione da verificare"),
        "importResolutionAssistant_inError":
            MessageLookupByLibrary.simpleMessage("per errore"),
        "importResolutionAssistant_interventionRequired":
            MessageLookupByLibrary.simpleMessage(
                "È necessario un intervento per completare questa importazione."),
        "importResolutionAssistant_loadingError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile caricare le importazioni"),
        "importResolutionAssistant_noProblem":
            MessageLookupByLibrary.simpleMessage(
                "Non è stato rilevato alcun problema di importazione."),
        "importResolutionAssistant_result":
            MessageLookupByLibrary.simpleMessage("risultato"),
        "importResolutionAssistant_results":
            MessageLookupByLibrary.simpleMessage("risultati"),
        "importResolutionAssistant_selectImportInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Seleziona un’importazione per visualizzarne i dettagli e seguire i passaggi indicati."),
        "importResolutionAssistant_title": MessageLookupByLibrary.simpleMessage(
            "Risoluzione dei problemi relativi all\'importazione"),
        "importResolutionAssistant_toReview":
            MessageLookupByLibrary.simpleMessage("da verificare"),
        "information_backupCount": m11,
        "information_backups": MessageLookupByLibrary.simpleMessage("Backup"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Configurato"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra le informazioni generali, tecniche e legali relative a Companion."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Informazioni"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Banca dati"),
        "information_language": MessageLookupByLibrary.simpleMessage("Lingua"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Avviso legale"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Caricamento in corso..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Archiviazione locale"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Non configurato"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "information_office": MessageLookupByLibrary.simpleMessage("Studio"),
        "information_size": m12,
        "information_system": MessageLookupByLibrary.simpleMessage("Sistema"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Informazioni"),
        "information_totalSize": m13,
        "information_version": m14,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Versione..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("Consulta la licenza"),
        "initialReportDocumentService_associate":
            MessageLookupByLibrary.simpleMessage(
                "Allegare un bilancio iniziale in formato Word"),
        "initialReportDocumentService_unsupported":
            MessageLookupByLibrary.simpleMessage("Piattaforma non supportata"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Lingua registrata."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Lingua dell\'applicazione"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Avviso"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion è un software che facilita l’organizzazione, l’importazione e la consultazione dei risultati clinici provenienti dall’ecosistema ABAK.\n\nNon costituisce un dispositivo medico certificato e non sostituisce il giudizio del professionista sanitario.\n\nI risultati, i punteggi, i referti e gli indicatori visualizzati devono sempre essere interpretati da un professionista qualificato, tenendo conto dell’esame clinico, del contesto del paziente e delle raccomandazioni in vigore.\n\nL’utente rimane l’unico responsabile delle proprie decisioni cliniche, della verifica dei dati importati e della conformità del loro utilizzo alle norme professionali, regolamentari e deontologiche applicabili.\n\nABAK Desktop Companion non effettua diagnosi autonome, non prescrive alcun trattamento e non sostituisce in alcun caso una visita medica o paramedica."),
        "legalNotice_title":
            MessageLookupByLibrary.simpleMessage("Avviso legale"),
        "loading":
            MessageLookupByLibrary.simpleMessage("Caricamento in corso..."),
        "localDatabaseBackup_cancelled":
            MessageLookupByLibrary.simpleMessage("Backup annullato."),
        "localDatabaseBackup_chooseBackupFolder":
            MessageLookupByLibrary.simpleMessage(
                "Scegliere la cartella di salvataggio ABAK"),
        "localDatabaseBackup_databaseNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile trovare il database SQLite."),
        "localDatabaseReset_backupFailed": MessageLookupByLibrary.simpleMessage(
            "Impossibile eseguire il backup preliminare"),
        "localDatabaseRestoreService_anomaly": m15,
        "localDatabaseRestoreService_failure": m16,
        "localDatabaseRestoreService_integrity": m17,
        "localDatabaseRestoreService_missing":
            MessageLookupByLibrary.simpleMessage(
                "Il file di backup non è stato trovato."),
        "localDatabaseRestoreService_success":
            MessageLookupByLibrary.simpleMessage(
                "Il ripristino è stato effettuato con successo."),
        "main_alreadyRunningMessage": MessageLookupByLibrary.simpleMessage(
            "È possibile aprire una sola istanza alla volta.\n\nUtilizza la finestra Companion già aperta."),
        "main_alreadyRunningTitle": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion è già aperto"),
        "main_close": MessageLookupByLibrary.simpleMessage(""),
        "modify": MessageLookupByLibrary.simpleMessage("Modifica"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Nessun file specificato"),
        "ok": MessageLookupByLibrary.simpleMessage("Va bene"),
        "open": MessageLookupByLibrary.simpleMessage("Apri"),
        "organization_chooseLogo":
            MessageLookupByLibrary.simpleMessage("Scegliere un logo"),
        "organization_identityTitle":
            MessageLookupByLibrary.simpleMessage("Identità dell\'istituto"),
        "organization_logoRemoved": MessageLookupByLibrary.simpleMessage(
            "Logo della struttura rimosso."),
        "organization_logoSaved": MessageLookupByLibrary.simpleMessage(
            "Logo dell\'istituto registrato."),
        "organization_nameLabel":
            MessageLookupByLibrary.simpleMessage("Nome dell\'istituto"),
        "organization_nameSaved": MessageLookupByLibrary.simpleMessage(
            "Nome dell\'istituto registrato."),
        "organization_removeLogo":
            MessageLookupByLibrary.simpleMessage("Elimina il logo"),
        "organization_saveName":
            MessageLookupByLibrary.simpleMessage("Salva il nome"),
        "organization_title": MessageLookupByLibrary.simpleMessage("Struttura"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Associare un telefono"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Associare un telefono"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scansiona questo codice QR da ABAK Mobile per configurare automaticamente la connessione al Desktop."),
        "patientClinicalDataEdit_address":
            MessageLookupByLibrary.simpleMessage("Indirizzo"),
        "patientClinicalDataEdit_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Identità amministrativa"),
        "patientClinicalDataEdit_ambidextrous":
            MessageLookupByLibrary.simpleMessage("Ambidestro"),
        "patientClinicalDataEdit_centimeters":
            MessageLookupByLibrary.simpleMessage("In centimetri"),
        "patientClinicalDataEdit_dominantSide":
            MessageLookupByLibrary.simpleMessage("Lato dominante"),
        "patientClinicalDataEdit_email":
            MessageLookupByLibrary.simpleMessage("E-mail"),
        "patientClinicalDataEdit_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage(
                "Paesi con il sistema sanitario"),
        "patientClinicalDataEdit_height":
            MessageLookupByLibrary.simpleMessage("Dimensioni"),
        "patientClinicalDataEdit_identitySource":
            MessageLookupByLibrary.simpleMessage("Fonte dell\'identità"),
        "patientClinicalDataEdit_kilograms":
            MessageLookupByLibrary.simpleMessage("In chilogrammi"),
        "patientClinicalDataEdit_left":
            MessageLookupByLibrary.simpleMessage("Sinistra"),
        "patientClinicalDataEdit_manualEntry":
            MessageLookupByLibrary.simpleMessage("Inserimento manuale"),
        "patientClinicalDataEdit_nationalHealthId":
            MessageLookupByLibrary.simpleMessage("Codice sanitario nazionale"),
        "patientClinicalDataEdit_nationalHealthIdHelper":
            MessageLookupByLibrary.simpleMessage(
                "Esempio Francia: numero di previdenza sociale"),
        "patientClinicalDataEdit_patientProfile":
            MessageLookupByLibrary.simpleMessage("Profilo del paziente"),
        "patientClinicalDataEdit_phone":
            MessageLookupByLibrary.simpleMessage("Telefono"),
        "patientClinicalDataEdit_profession":
            MessageLookupByLibrary.simpleMessage("Professione"),
        "patientClinicalDataEdit_right":
            MessageLookupByLibrary.simpleMessage("Destra"),
        "patientClinicalDataEdit_save":
            MessageLookupByLibrary.simpleMessage("Salva"),
        "patientClinicalDataEdit_sportActivity":
            MessageLookupByLibrary.simpleMessage("Attività sportiva abituale"),
        "patientClinicalDataEdit_title":
            MessageLookupByLibrary.simpleMessage("Modifica dei dati clinici"),
        "patientClinicalDataEdit_unspecified":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "patientClinicalDataEdit_vitaleCard":
            MessageLookupByLibrary.simpleMessage("Carta Vitale"),
        "patientClinicalDataEdit_weight":
            MessageLookupByLibrary.simpleMessage("Peso"),
        "patientDetail_address":
            MessageLookupByLibrary.simpleMessage("Indirizzo"),
        "patientDetail_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Identità amministrativa"),
        "patientDetail_archived":
            MessageLookupByLibrary.simpleMessage("archiviato"),
        "patientDetail_bornOn":
            MessageLookupByLibrary.simpleMessage("Né(e) le"),
        "patientDetail_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "patientDetail_careEpisodeOpenedIn":
            MessageLookupByLibrary.simpleMessage("Assistenza aperta in"),
        "patientDetail_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Coperture"),
        "patientDetail_create": MessageLookupByLibrary.simpleMessage("Crea"),
        "patientDetail_dominantSide":
            MessageLookupByLibrary.simpleMessage("Lato dominante"),
        "patientDetail_edit": MessageLookupByLibrary.simpleMessage("Modifica"),
        "patientDetail_editCareEpisode":
            MessageLookupByLibrary.simpleMessage("Modifica della copertura"),
        "patientDetail_editClinicalData":
            MessageLookupByLibrary.simpleMessage("Modifica dei dati clinici"),
        "patientDetail_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "patientDetail_error": MessageLookupByLibrary.simpleMessage("Errore"),
        "patientDetail_frHealthIdentity": MessageLookupByLibrary.simpleMessage(
            "Identità sanitaria — Francia"),
        "patientDetail_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage("Paese con sistema sanitario"),
        "patientDetail_height":
            MessageLookupByLibrary.simpleMessage("Dimensioni"),
        "patientDetail_identitySource":
            MessageLookupByLibrary.simpleMessage("Fonte: identità"),
        "patientDetail_initialReport":
            MessageLookupByLibrary.simpleMessage("Resoconto iniziale"),
        "patientDetail_nationalIdentifier":
            MessageLookupByLibrary.simpleMessage(
                "Codice identificativo nazionale"),
        "patientDetail_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Nuova copertura"),
        "patientDetail_noBirthdate":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "patientDetail_noCareEpisode": MessageLookupByLibrary.simpleMessage(
            "Non è stata creata alcuna pratica per questo paziente."),
        "patientDetail_notProvided":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "patientDetail_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "patientDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Patologia"),
        "patientDetail_patientInformation":
            MessageLookupByLibrary.simpleMessage("Informazioni sul paziente"),
        "patientDetail_patientProfile":
            MessageLookupByLibrary.simpleMessage("Profilo del paziente"),
        "patientDetail_phone": MessageLookupByLibrary.simpleMessage("Telefono"),
        "patientDetail_profession":
            MessageLookupByLibrary.simpleMessage("Professione"),
        "patientDetail_provisional":
            MessageLookupByLibrary.simpleMessage("Provvisorio"),
        "patientDetail_provisionalDescription":
            MessageLookupByLibrary.simpleMessage("Dati da completare"),
        "patientDetail_qualified":
            MessageLookupByLibrary.simpleMessage("Qualificata"),
        "patientDetail_qualifiedDescription":
            MessageLookupByLibrary.simpleMessage("Identità conforme"),
        "patientDetail_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapista di riferimento"),
        "patientDetail_retrieved":
            MessageLookupByLibrary.simpleMessage("Recuperata"),
        "patientDetail_retrievedDescription":
            MessageLookupByLibrary.simpleMessage(
                "INS ottenuto, identità da verificare"),
        "patientDetail_save": MessageLookupByLibrary.simpleMessage("Salva"),
        "patientDetail_sex": MessageLookupByLibrary.simpleMessage("Sesso"),
        "patientDetail_sportActivity":
            MessageLookupByLibrary.simpleMessage("Attività sportiva"),
        "patientDetail_state": MessageLookupByLibrary.simpleMessage("Stato"),
        "patientDetail_status": MessageLookupByLibrary.simpleMessage("Stato"),
        "patientDetail_validated":
            MessageLookupByLibrary.simpleMessage("Confermata"),
        "patientDetail_validatedDescription":
            MessageLookupByLibrary.simpleMessage(
                "Identità verificata, INS da ricercare"),
        "patientDetail_weight": MessageLookupByLibrary.simpleMessage("Peso"),
        "patientDetail_years": MessageLookupByLibrary.simpleMessage("anni"),
        "patientForm_birthDate":
            MessageLookupByLibrary.simpleMessage("Data di nascita"),
        "patientForm_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "patientForm_create": MessageLookupByLibrary.simpleMessage("Crea"),
        "patientForm_editPatient":
            MessageLookupByLibrary.simpleMessage("Modifica il paziente"),
        "patientForm_female": MessageLookupByLibrary.simpleMessage("Donna"),
        "patientForm_firstName": MessageLookupByLibrary.simpleMessage("Nome"),
        "patientForm_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("Il nome è obbligatorio"),
        "patientForm_lastName": MessageLookupByLibrary.simpleMessage("Nome"),
        "patientForm_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("Il nome è obbligatorio"),
        "patientForm_male": MessageLookupByLibrary.simpleMessage("Uomo"),
        "patientForm_newPatient":
            MessageLookupByLibrary.simpleMessage("Nuovo paziente"),
        "patientForm_other": MessageLookupByLibrary.simpleMessage("Altro"),
        "patientForm_save": MessageLookupByLibrary.simpleMessage("Salva"),
        "patientForm_sex": MessageLookupByLibrary.simpleMessage("Sesso"),
        "patientForm_unspecified":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "patientList_active": MessageLookupByLibrary.simpleMessage("Attività"),
        "patientList_archive": MessageLookupByLibrary.simpleMessage("Archivia"),
        "patientList_archiveConfirmation": m18,
        "patientList_archiveSuccess": m19,
        "patientList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archiviare il paziente"),
        "patientList_archived":
            MessageLookupByLibrary.simpleMessage("Archiviati"),
        "patientList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archiviato il"),
        "patientList_archivedPatient":
            MessageLookupByLibrary.simpleMessage("Paziente archiviato"),
        "patientList_archivedPatientsEmpty":
            MessageLookupByLibrary.simpleMessage(
                "Il cestino dei pazienti è vuoto al momento."),
        "patientList_bornOn": MessageLookupByLibrary.simpleMessage("Né(e) le"),
        "patientList_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "patientList_contextComment": MessageLookupByLibrary.simpleMessage(
            "È possibile visualizzare l\'elenco dei pazienti attivi e di quelli archiviati"),
        "patientList_contextName":
            MessageLookupByLibrary.simpleMessage("Elenco dei pazienti"),
        "patientList_edit": MessageLookupByLibrary.simpleMessage("Modifica"),
        "patientList_error": m20,
        "patientList_newPatient":
            MessageLookupByLibrary.simpleMessage("Nuovo paziente"),
        "patientList_noArchivedPatients":
            MessageLookupByLibrary.simpleMessage("Nessun paziente archiviato"),
        "patientList_noPatientFound":
            MessageLookupByLibrary.simpleMessage("Nessun paziente trovato"),
        "patientList_noRegisteredPatients":
            MessageLookupByLibrary.simpleMessage("Nessun paziente registrato"),
        "patientList_patientFileEmpty": MessageLookupByLibrary.simpleMessage(
            "Il file locale del paziente è vuoto al momento."),
        "patientList_restorableUntil":
            MessageLookupByLibrary.simpleMessage("Riparabile fino al"),
        "patientList_restore":
            MessageLookupByLibrary.simpleMessage("Ripristina"),
        "patientList_restoreSuccess": m21,
        "patientList_searchPatient":
            MessageLookupByLibrary.simpleMessage("Cerca un paziente"),
        "patientList_sex": MessageLookupByLibrary.simpleMessage("Sesso"),
        "patientList_title":
            MessageLookupByLibrary.simpleMessage("Elenco dei pazienti"),
        "patientNew_archivedMatchToReview":
            MessageLookupByLibrary.simpleMessage(
                "Corrispondenza archiviata da verificare"),
        "patientNew_archivedMatchToReviewMessage":
            MessageLookupByLibrary.simpleMessage(
                "Esiste già un paziente archiviato con lo stesso cognome, nome e data di nascita, ma i suoi dati amministrativi sono diversi.\n\nNon verrà effettuato alcun ripristino automatico. Verificare le cartelle cliniche prima di proseguire."),
        "patientNew_archivedPatientFound": MessageLookupByLibrary.simpleMessage(
            "Paziente trovato nell\'archivio"),
        "patientNew_archivedPatientMatch": MessageLookupByLibrary.simpleMessage(
            "Questa tessera sanitaria corrisponde al paziente archiviato:"),
        "patientNew_attach": MessageLookupByLibrary.simpleMessage("Collegare"),
        "patientNew_attachVitaleError": MessageLookupByLibrary.simpleMessage(
            "Impossibile collegare la Carte Vitale"),
        "patientNew_attachVitaleQuestion": MessageLookupByLibrary.simpleMessage(
            "Desidera associare i dati della Carte Vitale a questo paziente?"),
        "patientNew_attachVitaleSuccess": m22,
        "patientNew_backToList":
            MessageLookupByLibrary.simpleMessage("Torna all\'elenco"),
        "patientNew_birthDate":
            MessageLookupByLibrary.simpleMessage("Data di nascita"),
        "patientNew_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "patientNew_choosePatient":
            MessageLookupByLibrary.simpleMessage("Scegliere il paziente"),
        "patientNew_close": MessageLookupByLibrary.simpleMessage("Chiudi"),
        "patientNew_contextComment": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di creare un nuovo paziente inserendo i dati manualmente o leggendo la Carta Vitale."),
        "patientNew_contextName":
            MessageLookupByLibrary.simpleMessage("Nuovo paziente"),
        "patientNew_createError": MessageLookupByLibrary.simpleMessage(
            "Errore durante la creazione del paziente"),
        "patientNew_createPatient":
            MessageLookupByLibrary.simpleMessage("Crea il paziente"),
        "patientNew_creating":
            MessageLookupByLibrary.simpleMessage("Creazione..."),
        "patientNew_download": MessageLookupByLibrary.simpleMessage("Scarica"),
        "patientNew_existingPatientTitle": MessageLookupByLibrary.simpleMessage(
            "Sei già un paziente registrato?"),
        "patientNew_female": MessageLookupByLibrary.simpleMessage("Femminile"),
        "patientNew_firstName": MessageLookupByLibrary.simpleMessage("Nome"),
        "patientNew_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("Il nome è obbligatorio"),
        "patientNew_lastName": MessageLookupByLibrary.simpleMessage("Nome"),
        "patientNew_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("Il nome è obbligatorio"),
        "patientNew_male": MessageLookupByLibrary.simpleMessage("Maschile"),
        "patientNew_matchToReview": MessageLookupByLibrary.simpleMessage(
            "Corrispondenza da verificare"),
        "patientNew_matchToReviewMessage": MessageLookupByLibrary.simpleMessage(
            "Esiste già un paziente con lo stesso cognome, nome e data di nascita.\n\nI dati anagrafici non corrispondono del tutto. Verificare la cartella clinica prima di procedere."),
        "patientNew_matchingPatientFound": MessageLookupByLibrary.simpleMessage(
            "È stato trovato un paziente corrispondente:"),
        "patientNew_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "patientNew_nirDetectedProtected":
            MessageLookupByLibrary.simpleMessage("rilevato e protetto"),
        "patientNew_nirUnavailable":
            MessageLookupByLibrary.simpleMessage("non disponibile"),
        "patientNew_no": MessageLookupByLibrary.simpleMessage("Non"),
        "patientNew_noNewPatientCreated": MessageLookupByLibrary.simpleMessage(
            "Non verrà creato alcun nuovo paziente."),
        "patientNew_notProvided":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "patientNew_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("non specificata"),
        "patientNew_other": MessageLookupByLibrary.simpleMessage("Altro"),
        "patientNew_patientAlreadyRegistered":
            MessageLookupByLibrary.simpleMessage("Paziente già registrato"),
        "patientNew_patientIdentity": MessageLookupByLibrary.simpleMessage(
            "Dati identificativi del paziente"),
        "patientNew_readOn":
            MessageLookupByLibrary.simpleMessage("Lettura effettuata il"),
        "patientNew_readVitale":
            MessageLookupByLibrary.simpleMessage("Leggi la Carta Vitale"),
        "patientNew_readerNotDetected": MessageLookupByLibrary.simpleMessage(
            "Lettore della tessera sanitaria non rilevato"),
        "patientNew_readerNotDetectedMessage": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion non ha rilevato alcun lettore di Carte Vitale.\n\nPer utilizzare questa funzione, è necessario disporre di:\n\n• un lettore di Carte Vitale compatibile con lo standard PC/SC, solitamente collegato tramite USB;\n• il modulo ABAK Carte Vitale, fornito gratuitamente. Visita il sito abak.care.\n\nUna volta collegato il lettore, clicca nuovamente su «Leggi la Carte Vitale»."),
        "patientNew_reading":
            MessageLookupByLibrary.simpleMessage("Lettura in corso..."),
        "patientNew_restore":
            MessageLookupByLibrary.simpleMessage("Ripristina"),
        "patientNew_restoreError": MessageLookupByLibrary.simpleMessage(
            "Impossibile rianimare il paziente"),
        "patientNew_restoreInsteadOfCreate": MessageLookupByLibrary.simpleMessage(
            "Preferisce ripristinare questa cartella clinica anziché creare un nuovo paziente?"),
        "patientNew_restoreSuccess": m23,
        "patientNew_sex": MessageLookupByLibrary.simpleMessage("Sesso"),
        "patientNew_vitaleIdentityRead": MessageLookupByLibrary.simpleMessage(
            "Identità rilevata dalla Carta Vitale"),
        "patientNew_vitaleMatchesPatient": MessageLookupByLibrary.simpleMessage(
            "Questa tessera sanitaria appartiene al paziente:"),
        "patientNew_vitaleModuleConfigurationError":
            MessageLookupByLibrary.simpleMessage(
                "La configurazione del modulo Carte Vitale è assente o errata. Reinstallare il modulo e riprovare."),
        "patientNew_vitaleModuleNotInstalled":
            MessageLookupByLibrary.simpleMessage(
                "Modulo Carte Vitale non installato"),
        "patientNew_vitaleModuleNotInstalledMessage":
            MessageLookupByLibrary.simpleMessage(
                "Il modulo ABAK Carte Vitale non è installato su questo computer.\n\nÈ possibile scaricarlo gratuitamente dal sito ABAK."),
        "patientNew_vitalePrefilled": MessageLookupByLibrary.simpleMessage(
            "Informazioni sul paziente precompilate dalla Carta Vitale."),
        "patientNew_vitaleReadFailed": MessageLookupByLibrary.simpleMessage(
            "La lettura della Carta Vitale non è andata a buon fine."),
        "practitionerList_active":
            MessageLookupByLibrary.simpleMessage("Attività"),
        "practitionerList_addPractitionersHint":
            MessageLookupByLibrary.simpleMessage(
                "Aggiungere i fisioterapisti dello studio per identificare i test importati."),
        "practitionerList_archive":
            MessageLookupByLibrary.simpleMessage("Archivia"),
        "practitionerList_archiveConfirmation": m24,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "Il cestino dei fisioterapisti è vuoto al momento."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Archiviare il fisioterapista"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archiviati"),
        "practitionerList_archivedOn": m25,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Crea un professionista"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Annulla"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra l\'elenco dei professionisti registrati."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("Elenco dei professionisti"),
        "practitionerList_edit":
            MessageLookupByLibrary.simpleMessage("Modifica"),
        "practitionerList_error": m26,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Nessun fisioterapista archiviato"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "Nessun fisioterapista registrato"),
        "practitionerList_professionalId": m27,
        "practitionerList_restore":
            MessageLookupByLibrary.simpleMessage("Ripristina"),
        "practitionerList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Visualizza il codice QR"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Elenco dei professionisti"),
        "practitionerNew_cancel":
            MessageLookupByLibrary.simpleMessage("Annulla"),
        "practitionerNew_cet_ecran_permet":
            MessageLookupByLibrary.simpleMessage(
                "Questa schermata consente di creare un professionista."),
        "practitionerNew_create": MessageLookupByLibrary.simpleMessage("Crea"),
        "practitionerNew_displayName":
            MessageLookupByLibrary.simpleMessage("Nome visualizzato"),
        "practitionerNew_displayNameRequired":
            MessageLookupByLibrary.simpleMessage(
                "Il nome visualizzato è obbligatorio"),
        "practitionerNew_editPractitioner":
            MessageLookupByLibrary.simpleMessage("Modifica il medico"),
        "practitionerNew_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "practitionerNew_firstName":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "practitionerNew_lastName":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "practitionerNew_newPractitioner":
            MessageLookupByLibrary.simpleMessage("Nuovo professionista"),
        "practitionerNew_phone":
            MessageLookupByLibrary.simpleMessage("Telefono"),
        "practitionerNew_professionalId": MessageLookupByLibrary.simpleMessage(
            "Codice identificativo professionale"),
        "practitionerNew_professionalIdHint":
            MessageLookupByLibrary.simpleMessage("RPPS, ADELI…"),
        "practitionerNew_save": MessageLookupByLibrary.simpleMessage("Salva"),
        "practitionerQr_close": MessageLookupByLibrary.simpleMessage("Chiudi"),
        "practitionerQr_defaultOrganizationName":
            MessageLookupByLibrary.simpleMessage("Studio"),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("Profilo professionale ABAK"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Scansiona questo codice QR da ABAK Mobile per aggiungere automaticamente questo profilo professionale."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("archiviato"),
        "practitionerSelector_error": m28,
        "practitionerSelector_noSelection":
            MessageLookupByLibrary.simpleMessage("Nessuna selezione"),
        "preferences_archivedPatients":
            MessageLookupByLibrary.simpleMessage("Pazienti archiviati"),
        "preferences_contextComment": MessageLookupByLibrary.simpleMessage(
            "Questa schermata raggruppa le impostazioni generali di Companion."),
        "preferences_contextName":
            MessageLookupByLibrary.simpleMessage("Impostazioni utente"),
        "preferences_days": MessageLookupByLibrary.simpleMessage("giorni"),
        "preferences_expertMode":
            MessageLookupByLibrary.simpleMessage("Esperto di moda"),
        "preferences_expertModeDescription": MessageLookupByLibrary.simpleMessage(
            "Mostra le informazioni tecniche destinate agli sviluppatori e ai collaboratori."),
        "preferences_expertModeSaved": MessageLookupByLibrary.simpleMessage(
            "Impostazione della modalità Esperto salvata."),
        "preferences_languageSaved":
            MessageLookupByLibrary.simpleMessage("Lingua registrata."),
        "preferences_organization":
            MessageLookupByLibrary.simpleMessage("Struttura"),
        "preferences_organizationDescription":
            MessageLookupByLibrary.simpleMessage(
                "Nome, logo e informazioni generali."),
        "preferences_retentionDuration":
            MessageLookupByLibrary.simpleMessage("Periodo di conservazione"),
        "preferences_retentionExplanation": MessageLookupByLibrary.simpleMessage(
            "I pazienti archiviati possono essere ripristinati entro tale periodo. Successivamente verranno eliminati automaticamente."),
        "preferences_retentionSaved": MessageLookupByLibrary.simpleMessage(
            "Data di scadenza registrata."),
        "recentImportCard_conflict":
            MessageLookupByLibrary.simpleMessage("conflitto"),
        "recentImportCard_error":
            MessageLookupByLibrary.simpleMessage("errore"),
        "recentImportCard_fichier":
            MessageLookupByLibrary.simpleMessage("file"),
        "recentImportCard_file": MessageLookupByLibrary.simpleMessage("file"),
        "recentImportCard_ignored":
            MessageLookupByLibrary.simpleMessage("ignorato"),
        "recentImportCard_no_result_imported":
            MessageLookupByLibrary.simpleMessage("Nessun risultato importato"),
        "recentImportCard_result":
            MessageLookupByLibrary.simpleMessage("risultato"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Aggiornare il cruscotto"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Archivio dei rapporti"),
        "reset": MessageLookupByLibrary.simpleMessage("Reimposta"),
        "resultDetail_addCommentHint":
            MessageLookupByLibrary.simpleMessage("Aggiungi un commento..."),
        "resultDetail_archiveConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Vuoi davvero archiviare questo risultato?"),
        "resultDetail_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archivia il risultato"),
        "resultDetail_birthDate":
            MessageLookupByLibrary.simpleMessage("Nascita"),
        "resultDetail_cancel":
            MessageLookupByLibrary.simpleMessage("Apparecchio"),
        "resultDetail_clinicalComment":
            MessageLookupByLibrary.simpleMessage("Commento clinico"),
        "resultDetail_commentSaved":
            MessageLookupByLibrary.simpleMessage("Commento salvato"),
        "resultDetail_detailedResult":
            MessageLookupByLibrary.simpleMessage("Risultato dettagliato"),
        "resultDetail_device":
            MessageLookupByLibrary.simpleMessage("Dettagli del dispositivo"),
        "resultDetail_exerciseDate":
            MessageLookupByLibrary.simpleMessage("Data dell\'esercizio"),
        "resultDetail_generalInformation":
            MessageLookupByLibrary.simpleMessage("Informazioni generali"),
        "resultDetail_identityUnverified":
            MessageLookupByLibrary.simpleMessage("Identità non verificata"),
        "resultDetail_identityVerified":
            MessageLookupByLibrary.simpleMessage("Identità verificata"),
        "resultDetail_import": MessageLookupByLibrary.simpleMessage("Importa"),
        "resultDetail_lastModified":
            MessageLookupByLibrary.simpleMessage("Ultima modifica"),
        "resultDetail_metrics":
            MessageLookupByLibrary.simpleMessage("Metriche"),
        "resultDetail_noMetrics":
            MessageLookupByLibrary.simpleMessage("Nessuna metrica registrata."),
        "resultDetail_patient":
            MessageLookupByLibrary.simpleMessage("Paziente"),
        "resultDetail_performedBy":
            MessageLookupByLibrary.simpleMessage("Regia di"),
        "resultDetail_save": MessageLookupByLibrary.simpleMessage("Salva"),
        "resultDetail_score": MessageLookupByLibrary.simpleMessage("Punteggio"),
        "resultDetail_syncState":
            MessageLookupByLibrary.simpleMessage("Stato sincronizzazione"),
        "settings_assistanceWarning": MessageLookupByLibrary.simpleMessage(
            "Queste funzioni sono destinate all\'installazione, alla diagnostica e alle operazioni di assistenza tecnica.\n\nUtilizzarle solo quando richiesto da un tecnico o dalla documentazione ABAK."),
        "settings_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "settings_configuration":
            MessageLookupByLibrary.simpleMessage("Configurazione"),
        "settings_confirmationRequired":
            MessageLookupByLibrary.simpleMessage("Conferma obbligatoria"),
        "settings_contextComment": MessageLookupByLibrary.simpleMessage(
            "Questa schermata raggruppa le funzioni di installazione, diagnostica e manutenzione di Companion."),
        "settings_contextName":
            MessageLookupByLibrary.simpleMessage("Assistenza"),
        "settings_continue": MessageLookupByLibrary.simpleMessage("Continua"),
        "settings_databaseResetError": m29,
        "settings_databaseResetSuccess": MessageLookupByLibrary.simpleMessage(
            "Base ripristinata. Backup automatico creato."),
        "settings_diagnostic": MessageLookupByLibrary.simpleMessage("Diagnosi"),
        "settings_edit": MessageLookupByLibrary.simpleMessage("Modifica"),
        "settings_exchangeDirectory": MessageLookupByLibrary.simpleMessage(
            "Documentazione per lo scambio ABAK"),
        "settings_exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Cartella di scambio ripristinata"),
        "settings_exchangeDirectoryUpdated":
            MessageLookupByLibrary.simpleMessage(
                "Documentazione di scambio ABAK aggiornata"),
        "settings_importAbakFile": MessageLookupByLibrary.simpleMessage(
            "Importare manualmente un file .abak"),
        "settings_invalidConfirmation":
            MessageLookupByLibrary.simpleMessage("Conferma non valida."),
        "settings_loading":
            MessageLookupByLibrary.simpleMessage("Caricamento in corso..."),
        "settings_maintenance":
            MessageLookupByLibrary.simpleMessage("Manutenzione"),
        "settings_manageBackups":
            MessageLookupByLibrary.simpleMessage("Gestire i backup"),
        "settings_noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Nessun file specificato"),
        "settings_open": MessageLookupByLibrary.simpleMessage("Apri"),
        "settings_openingExchangeDirectory":
            MessageLookupByLibrary.simpleMessage(
                "Apertura della pratica di scambio"),
        "settings_reset": MessageLookupByLibrary.simpleMessage("Reimposta"),
        "settings_resetDatabase":
            MessageLookupByLibrary.simpleMessage("Ripristina la base"),
        "settings_resetDatabaseTitle":
            MessageLookupByLibrary.simpleMessage("Reimpostare la base locale?"),
        "settings_resetDatabaseWarning": MessageLookupByLibrary.simpleMessage(
            "Questa operazione cancellerà tutti i dati locali (pazienti, risultati, importazioni e cronologie).\n\nPrima del ripristino verrà creato un backup automatico.\n\nUtilizzare questa funzione solo nell\'ambito di un intervento di assistenza tecnica."),
        "settings_resetKeyword": MessageLookupByLibrary.simpleMessage("RESET"),
        "settings_resetTooltip":
            MessageLookupByLibrary.simpleMessage("Reimposta"),
        "settings_resolveImportProblem": MessageLookupByLibrary.simpleMessage(
            "Risolvere un problema di importazione"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Assistenza"),
        "settings_typeResetConfirmation": MessageLookupByLibrary.simpleMessage(
            "Digitare RESET per confermare definitivamente."),
        "settings_vitaleDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnosi della Carta Vitale"),
        "smartCardDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnosi della Carta Vitale"),
        "speechDictationButton_audio": MessageLookupByLibrary.simpleMessage(
            "Non è disponibile alcuna registrazione audio."),
        "speechDictationButton_close":
            MessageLookupByLibrary.simpleMessage("Chiudi"),
        "speechDictationButton_dictate":
            MessageLookupByLibrary.simpleMessage("Rabbia"),
        "speechDictationButton_download":
            MessageLookupByLibrary.simpleMessage("Scarica il modulo"),
        "speechDictationButton_failure": m30,
        "speechDictationButton_information": MessageLookupByLibrary.simpleMessage(
            "La dettatura vocale richiede l\'installazione del modulo opzionale ABAK Dettatura vocale.\n\nQuesto modulo è gratuito e funziona localmente sul proprio computer, senza inviare le registrazioni vocali su Internet.\n\nIl download occupa circa 1,5 GB."),
        "speechDictationButton_stop":
            MessageLookupByLibrary.simpleMessage("Interrompere la dettatura"),
        "speechDictationButton_title":
            MessageLookupByLibrary.simpleMessage("Dettatura vocale"),
        "speechRecordingService_permission":
            MessageLookupByLibrary.simpleMessage(
                "Non è consentito l\'accesso al microfono."),
        "systemOverviewBar_active_patients":
            MessageLookupByLibrary.simpleMessage("Pazienti attivi"),
        "systemOverviewBar_alert":
            MessageLookupByLibrary.simpleMessage("Avvisi"),
        "systemOverviewBar_archived_patients":
            MessageLookupByLibrary.simpleMessage("Pazienti archiviati"),
        "systemOverviewBar_loading_system_summary":
            MessageLookupByLibrary.simpleMessage(
                "Caricamento del riepilogo di sistema in corso..."),
        "systemOverviewBar_supervision_error":
            MessageLookupByLibrary.simpleMessage("Errore di supervisione"),
        "systemOverviewBar_supervision_unavailable":
            MessageLookupByLibrary.simpleMessage(
                "Supervisione non disponibile"),
        "systemStatusCard_nome":
            MessageLookupByLibrary.simpleMessage("Nessuna"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Impostazioni utente"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Impostazioni utente"),
        "vitaleBeneficiarySelector_cancel":
            MessageLookupByLibrary.simpleMessage("Annulla"),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage("Selezionare un beneficiario"),
        "vitaleIdentity_birthDate":
            MessageLookupByLibrary.simpleMessage("Data di nascita"),
        "vitaleIdentity_dataMasked":
            MessageLookupByLibrary.simpleMessage("dato nascosto"),
        "vitaleIdentity_detected":
            MessageLookupByLibrary.simpleMessage("rilevato"),
        "vitaleIdentity_female":
            MessageLookupByLibrary.simpleMessage("Femminile"),
        "vitaleIdentity_firstName":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "vitaleIdentity_identityRead":
            MessageLookupByLibrary.simpleMessage("Identità rilevata"),
        "vitaleIdentity_identityReceivedMasked":
            MessageLookupByLibrary.simpleMessage(
                "identità fornita (dati personali oscurati)"),
        "vitaleIdentity_identityUnavailable":
            MessageLookupByLibrary.simpleMessage("identità non disponibile"),
        "vitaleIdentity_lastName": MessageLookupByLibrary.simpleMessage("Nome"),
        "vitaleIdentity_male": MessageLookupByLibrary.simpleMessage("Maschile"),
        "vitaleIdentity_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "vitaleIdentity_noIdentityAvailable":
            MessageLookupByLibrary.simpleMessage(
                "Non è disponibile alcuna identità associata alla Carta Vitale"),
        "vitaleIdentity_notProvided":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "vitaleIdentity_other": MessageLookupByLibrary.simpleMessage("Altro"),
        "vitaleIdentity_reading":
            MessageLookupByLibrary.simpleMessage("Lettura in corso..."),
        "vitaleIdentity_sex": MessageLookupByLibrary.simpleMessage("Sesso"),
        "vitaleIdentity_source": MessageLookupByLibrary.simpleMessage("Fonte"),
        "vitaleIdentity_title": MessageLookupByLibrary.simpleMessage(
            "Leggi i dati della Carta Vitale"),
        "vitaleIdentity_unavailable":
            MessageLookupByLibrary.simpleMessage("Non disponibile"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Da utilizzare per creare un paziente")
      };
}
