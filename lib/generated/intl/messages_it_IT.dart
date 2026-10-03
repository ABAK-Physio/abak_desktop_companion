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

  static String m4(path) => "Autorizza l\'accesso alla cartella: ${path}";

  static String m5(path) =>
      "Scegli la cartella in cui ripristinare i documenti da: ${path}";

  static String m6(size) => "${size}";

  static String m7(date) => "Archiviato il ${date}";

  static String m8(monthYear) =>
      "Supporto disponibile a partire da ${monthYear}";

  static String m9(title) =>
      "Il riepilogo “${title}” non verrà più visualizzato nella cronologia.";

  static String m10(title) =>
      "Il rapporto «${title}» verrà spostato nel cestino. Potrà essere ripristinato in un secondo momento.";

  static String m11(patientName, title) => "Bilan_${patientName}_${title}";

  static String m12(title) => "Copia di ${title}";

  static String m13(title) =>
      "Il bilancio «${title}» verrà eliminato definitivamente. Questa operazione è irreversibile.";

  static String m14(title) =>
      "Il rapporto «${title}» verrà eliminato definitivamente. Questa operazione è irreversibile.";

  static String m15(path) =>
      "\"careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": \"Le dossier configuré n’est pas accessible ou son autorisation doit être renouvelée.\n\n${path}\n\nReconnectez son volume si nécessaire, puis sélectionnez ce dossier pour autoriser son accès. Le dossier sélectionné sera enregistré dans vos préférences.\",\n\"@careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": {\n  \"placeholders\": {\n    \"path\": {\n      \"type\": \"String\"\n    }\n  }\n}";

  static String m16(documentLabel) =>
      "Esiste già una bozza per questo modello di ${documentLabel}.";

  static String m17(documentLabel) =>
      "Desidera aggiungere il contenuto generato alla fine dell\'attuale ${documentLabel} o sostituire il contenuto esistente?";

  static String m18(documentLabel) => "Nuovo ${documentLabel}";

  static String m19(patientName, title) => "Rapporto_${patientName}_${title}";

  static String m20(path) => "Documento Word creato: ${path}";

  static String m21(error) =>
      "Errore durante la creazione del documento Word: ${error}";

  static String m22(patientName) => "${patientName} — Esami e referti";

  static String m23(deviceName) => "Vuoi davvero archiviare ${deviceName}?";

  static String m24(fieldName) => "Il campo \"${fieldName}\" è obbligatorio.";

  static String m25(noteTitle) =>
      "La nota \"${noteTitle}\" non verrà più visualizzata.";

  static String m26(error) => "Errore durante il salvataggio: ${error}";

  static String m27(count) => "${count} altro/i esercizio/i";

  static String m28(count) => "${count} associazione/i in attesa";

  static String m29(count) => "${count} salvataggi";

  static String m30(size) => "Taglia: ${size}";

  static String m31(size) => "Dimensioni totali: ${size}";

  static String m32(version) => "Versione ${version}";

  static String m33(integrityStatus) =>
      "La base restaurata presenta un\'anomalia: ${integrityStatus}";

  static String m34(error) => "Ripristino non riuscito: ${error}";

  static String m35(integrityStatus) =>
      "Il ripristino è stato completato, ma integrity_check ha restituito: ${integrityStatus}";

  static String m36(patientName) =>
      "Vuoi davvero archiviare ${patientName}? Non apparirà più nell\'elenco attivo.";

  static String m37(patientName) => "${patientName} archiviato.";

  static String m38(error) => "Errore: ${error}";

  static String m39(patientName) =>
      "${patientName} reinserito nell\'elenco attivo.";

  static String m40(patientName) =>
      "Tessera sanitaria associata al paziente ${patientName}.";

  static String m41(patientName) =>
      "Il paziente ${patientName} è stato rianimato.";

  static String m42(practitionerName) =>
      "Vuoi davvero archiviare ${practitionerName}?";

  static String m43(date) => "Archiviato il ${date}";

  static String m44(error) => "Errore: ${error}";

  static String m45(professionalId) => "ID pro: ${professionalId}";

  static String m46(error) => "Errore: ${error}";

  static String m47(name) => "${name} — archiviato";

  static String m48(start, end) => "Tu ${start} au ${end}";

  static String m49(error) =>
      "Errore durante il caricamento della cronologia: ${error}";

  static String m50(start) => "Da ${start}";

  static String m51(error) => "Errore durante il ripristino: ${error}";

  static String m52(patientCount, fileCount) =>
      "Esportazione completata: ${patientCount} paziente/i, ${fileCount} file.";

  static String m53(errorCount, patientCount, fileCount) =>
      "Esportazione completata con ${errorCount} errore/i: ${patientCount} paziente/i, ${fileCount} file esportato/i.";

  static String m54(error) =>
      "Il dettato vocale non è andato a buon fine: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "abakWhisperSpeechProvider_name":
            MessageLookupByLibrary.simpleMessage("ABAK Dettatura vocale"),
        "archivedDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata raggruppa i bilanci e i rapporti archiviati relativi alla presa in carico. Ogni riga indica il tipo di documento, il titolo e la data di archiviazione.\n\nL’azione di ripristino consente di reinserire il documento nella cronologia dei bilanci o dei rapporti.\n\nL\'azione di eliminazione definitiva rimuove il documento da Companion. Leggere attentamente il messaggio di conferma prima di confermare: il documento non potrà più essere ripristinato da questo elenco.\n\nFare clic sulla croce per chiudere la vista ingrandita e tornare all\'area Bilanci/Rapporti."),
        "assessmentChartImageService_insufficientPoints":
            MessageLookupByLibrary.simpleMessage(
                "Una serie grafica deve contenere almeno due punti."),
        "assessmentChartImageService_pngConversionError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile convertire il grafico in un\'immagine PNG."),
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
        "assessmentDocxService_results":
            MessageLookupByLibrary.simpleMessage("Risultati dei test"),
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
        "assessmentDraft_help": MessageLookupByLibrary.simpleMessage(
            "Il testo visualizzato corrisponde a un lavoro in corso salvato automaticamente. È possibile mantenerlo, modificarlo o eliminarlo prima di salvare il proprio bilancio."),
        "assessmentDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Comprendere la bozza del bilancio"),
        "assessmentHistory_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra i bilanci registrati per la gestione, con il titolo e la data.\n\nLe azioni disponibili in ciascuna riga consentono di modificare un bilancio, duplicarlo o spostarlo tra i documenti archiviati.\n\nQuando un bilancio è aperto in modalità modifica, utilizzare l’azione di aggiornamento per salvare le modifiche. I comandi disponibili consentono inoltre di annullare le modifiche o di tornare alla bozza.\n\nLo spostamento verso i documenti archiviati non costituisce una cancellazione definitiva.\n\nFare clic sulla croce per chiudere la vista ingrandita e tornare all’area Bilanci/Rapporti."),
        "backupArchive_authorizeFolder": m4,
        "backupArchive_busy": MessageLookupByLibrary.simpleMessage(
            "\"È già in corso un\'operazione di backup o di ripristino.\""),
        "backupArchive_chooseFile":
            MessageLookupByLibrary.simpleMessage("Aprire un backup…"),
        "backupArchive_legacy": MessageLookupByLibrary.simpleMessage(
            "Questo vecchio backup contiene solo il database. I file delle cartelle cliniche non sono stati ripristinati."),
        "backupArchive_restoreFolder": m5,
        "backupArchive_resultTitle":
            MessageLookupByLibrary.simpleMessage("Risultato del restauro"),
        "backupArchive_safetyCopies": MessageLookupByLibrary.simpleMessage(
            "Copie di sicurezza conservate:"),
        "backupArchive_working": MessageLookupByLibrary.simpleMessage(
            "Backup o ripristino in corso… Attendere, per favore."),
        "backupHistory_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "Non è stato salvato alcun backup."),
        "backupHistory_fileSize": m6,
        "backupHistory_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra i backup salvati in Companion. Ogni riga riporta il nome del file, la data di creazione, la dimensione e il percorso.\n\nIl pulsante «Ripristina» consente di sostituire il database attuale con quello del backup selezionato. I dati aggiunti o modificati dopo questo backup non saranno quindi presenti nel database ripristinato.\n\nVerificate la data del backup e leggete il messaggio di conferma prima di procedere. Prima della sostituzione viene creata una copia di sicurezza del database attuale.\n\nIl file di backup deve essere sempre accessibile nel percorso indicato. Se è stato spostato o eliminato, il ripristino non potrà essere effettuato.\n\nPer creare un nuovo backup, utilizzare l’azione «Crea un backup» nella pagina iniziale."),
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Ripristina"),
        "backupHistory_restoreTitle":
            MessageLookupByLibrary.simpleMessage("Ripristinare questo backup?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Questa operazione sostituirà completamente il database attuale.\n\nPrima del ripristino verrà creato un backup di sicurezza automatico.\n\nVuoi continuare?"),
        "backupHistory_title":
            MessageLookupByLibrary.simpleMessage("Cronologia dei backup"),
        "bodymap_help": MessageLookupByLibrary.simpleMessage(
            "La mappa del dolore consente di individuare le zone dolorose del paziente per la seduta terapeutica in corso.\n\nScegli una vista, quindi clicca su una zona della sagoma o selezionala dall\'elenco. Puoi aggiungere un\'osservazione e, se necessario, un\'intensità da 0 a 10. Utilizza il cestino per rimuovere una zona dalla registrazione.\n\nClicca su «Salva» per conservare il tuo rapporto in Companion. Quando esci dalla schermata con modifiche non salvate, ti verrà chiesto se desideri salvarle o ignorarle.\n\n«Esporta entrambe le mappe» crea un’immagine PNG nella posizione scelta sul tuo computer. Questa esportazione non sostituisce il salvataggio del rilevamento.\n\nQuesto modulo è una prima proposta, destinata a evolversi in base ai vostri feedback. Provatelo nella vostra pratica e segnalateci le funzionalità che vorreste vedere aggiunte o migliorate."),
        "bodymap_title":
            MessageLookupByLibrary.simpleMessage("Mappa del dolore"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origine ABAK"),
        "careEpisodeDetail_detail_de_la_prise_en_charge":
            MessageLookupByLibrary.simpleMessage("Dettagli sulla copertura"),
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
        "careEpisodePanel_archive":
            MessageLookupByLibrary.simpleMessage("Archivia"),
        "careEpisodePanel_archiveCareEpisode":
            MessageLookupByLibrary.simpleMessage(
                "Archiviare la presa in carico"),
        "careEpisodePanel_archiveCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile archiviare la richiesta di assistenza. Riprovare."),
        "careEpisodePanel_archiveCareEpisodeMessage":
            MessageLookupByLibrary.simpleMessage(
                "Questo servizio verrà rimosso dall\'elenco. I relativi dati saranno conservati in archivio."),
        "careEpisodePanel_archiveCareEpisodeTitle":
            MessageLookupByLibrary.simpleMessage("Archiviare questa pratica?"),
        "careEpisodePanel_archivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage("Casi archiviati"),
        "careEpisodePanel_archivedCareEpisodesHelp":
            MessageLookupByLibrary.simpleMessage(
                "Qui potete trovare le vostre sedute di trattamento archiviate."),
        "careEpisodePanel_archivedOn": m7,
        "careEpisodePanel_careEpisodeArchived":
            MessageLookupByLibrary.simpleMessage("Richiesta archiviata."),
        "careEpisodePanel_careEpisodeOpenedIn": m8,
        "careEpisodePanel_careEpisodeRestored":
            MessageLookupByLibrary.simpleMessage("Funzionalità ripristinata."),
        "careEpisodePanel_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Coperture"),
        "careEpisodePanel_choose":
            MessageLookupByLibrary.simpleMessage("Scegliere"),
        "careEpisodePanel_edit":
            MessageLookupByLibrary.simpleMessage("Modifica"),
        "careEpisodePanel_loadCareEpisodesError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile caricare i dati relativi alle coperture assicurative."),
        "careEpisodePanel_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Nuova copertura"),
        "careEpisodePanel_noArchivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage(
                "Non sono state registrate cure per questo paziente."),
        "careEpisodePanel_noCareEpisodes": MessageLookupByLibrary.simpleMessage(
            "Non è stata creata alcuna richiesta di copertura per questo paziente."),
        "careEpisodePanel_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Medico prescrittore"),
        "careEpisodePanel_restore":
            MessageLookupByLibrary.simpleMessage("Ripristina"),
        "careEpisodePanel_restoreCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile ripristinare la connettività. Riprovare."),
        "careEpisodeReportsWorkspaceScreen_add":
            MessageLookupByLibrary.simpleMessage("Aggiungi"),
        "careEpisodeReportsWorkspaceScreen_append":
            MessageLookupByLibrary.simpleMessage("Aggiungi alla lista"),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Non è possibile spostare il bilancio nel cestino."),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentMessage": m9,
        "careEpisodeReportsWorkspaceScreen_archiveReportError":
            MessageLookupByLibrary.simpleMessage(
                "Non è possibile spostare il rapporto nel cestino."),
        "careEpisodeReportsWorkspaceScreen_archiveReportMessage": m10,
        "careEpisodeReportsWorkspaceScreen_assessmentFileName": m11,
        "careEpisodeReportsWorkspaceScreen_assessmentLabel":
            MessageLookupByLibrary.simpleMessage("con"),
        "careEpisodeReportsWorkspaceScreen_assessmentNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Non si riesce a trovare il bilancio."),
        "careEpisodeReportsWorkspaceScreen_assessmentReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Il vostro bilancio è pronto. Il file DOCX conterrà le informazioni inserite e gli elementi selezionati."),
        "careEpisodeReportsWorkspaceScreen_assessmentTitle":
            MessageLookupByLibrary.simpleMessage("Titolo del bilancio"),
        "careEpisodeReportsWorkspaceScreen_assessmentsAndReports":
            MessageLookupByLibrary.simpleMessage("Bilanci e relazioni"),
        "careEpisodeReportsWorkspaceScreen_author":
            MessageLookupByLibrary.simpleMessage("Redattore"),
        "careEpisodeReportsWorkspaceScreen_authorizeDirectory":
            MessageLookupByLibrary.simpleMessage("Autorizzare una cartella"),
        "careEpisodeReportsWorkspaceScreen_cancel":
            MessageLookupByLibrary.simpleMessage("Annulla"),
        "careEpisodeReportsWorkspaceScreen_cancelChangesError":
            MessageLookupByLibrary.simpleMessage(
                "Non è possibile annullare le modifiche."),
        "careEpisodeReportsWorkspaceScreen_cancelReportChangesError":
            MessageLookupByLibrary.simpleMessage(
                "Non è possibile annullare le modifiche apportate al rapporto."),
        "careEpisodeReportsWorkspaceScreen_close":
            MessageLookupByLibrary.simpleMessage("Chiudi"),
        "careEpisodeReportsWorkspaceScreen_confirm":
            MessageLookupByLibrary.simpleMessage("Conferma"),
        "careEpisodeReportsWorkspaceScreen_copyTitle": m12,
        "careEpisodeReportsWorkspaceScreen_createNew":
            MessageLookupByLibrary.simpleMessage("Crea un nuovo"),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Non è possibile eliminare definitivamente il bilancio."),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentMessage": m13,
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "Eliminare definitivamente il bilancio?"),
        "careEpisodeReportsWorkspaceScreen_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Elimina definitivamente"),
        "careEpisodeReportsWorkspaceScreen_deleteReportError":
            MessageLookupByLibrary.simpleMessage(
                "Non è possibile eliminare definitivamente il rapporto."),
        "careEpisodeReportsWorkspaceScreen_deleteReportMessage": m14,
        "careEpisodeReportsWorkspaceScreen_deleteReportTitle":
            MessageLookupByLibrary.simpleMessage(
                "Eliminare definitivamente il rapporto?"),
        "careEpisodeReportsWorkspaceScreen_directoryAccessMessage": m15,
        "careEpisodeReportsWorkspaceScreen_duplicate":
            MessageLookupByLibrary.simpleMessage("Duplica"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessment":
            MessageLookupByLibrary.simpleMessage("Duplicare il bilancio"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile duplicare il bilancio."),
        "careEpisodeReportsWorkspaceScreen_duplicateReport":
            MessageLookupByLibrary.simpleMessage("Duplicare il rapporto"),
        "careEpisodeReportsWorkspaceScreen_duplicateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile duplicare il rapporto."),
        "careEpisodeReportsWorkspaceScreen_existingAssessmentDocx":
            MessageLookupByLibrary.simpleMessage(
                "A questo bilancio è già associato un file DOCX. Desidera sostituire il file esistente o crearne uno nuovo?"),
        "careEpisodeReportsWorkspaceScreen_existingReportDocx":
            MessageLookupByLibrary.simpleMessage(
                "A questo rapporto è già associato un file DOCX. Desidera sostituire il file esistente o crearne uno nuovo?"),
        "careEpisodeReportsWorkspaceScreen_existingTemplateDraftMessage": m16,
        "careEpisodeReportsWorkspaceScreen_generate":
            MessageLookupByLibrary.simpleMessage("Genera"),
        "careEpisodeReportsWorkspaceScreen_generateDocx":
            MessageLookupByLibrary.simpleMessage("Genera il file DOCX"),
        "careEpisodeReportsWorkspaceScreen_insertTextMessage": m17,
        "careEpisodeReportsWorkspaceScreen_managePractitioners":
            MessageLookupByLibrary.simpleMessage("Gestire i fisioterapisti"),
        "careEpisodeReportsWorkspaceScreen_managePrescribingDoctors":
            MessageLookupByLibrary.simpleMessage(
                "Gestire i medici prescrittori"),
        "careEpisodeReportsWorkspaceScreen_moveToTrash":
            MessageLookupByLibrary.simpleMessage("Spostare nel cestino"),
        "careEpisodeReportsWorkspaceScreen_newAssessment":
            MessageLookupByLibrary.simpleMessage("Nuovo bilancio"),
        "careEpisodeReportsWorkspaceScreen_newAssessmentTitle":
            MessageLookupByLibrary.simpleMessage("Titolo del nuovo bilancio"),
        "careEpisodeReportsWorkspaceScreen_newDocument": m18,
        "careEpisodeReportsWorkspaceScreen_newReport":
            MessageLookupByLibrary.simpleMessage("Nuovo rapporto"),
        "careEpisodeReportsWorkspaceScreen_newReportTitle":
            MessageLookupByLibrary.simpleMessage("Titolo del nuovo rapporto"),
        "careEpisodeReportsWorkspaceScreen_note":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "careEpisodeReportsWorkspaceScreen_openReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Non è possibile aprire la bozza del rapporto."),
        "careEpisodeReportsWorkspaceScreen_openReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile aprire il rapporto."),
        "careEpisodeReportsWorkspaceScreen_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Medico prescrittore"),
        "careEpisodeReportsWorkspaceScreen_recipients":
            MessageLookupByLibrary.simpleMessage("Destinatario/i"),
        "careEpisodeReportsWorkspaceScreen_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapista di riferimento"),
        "careEpisodeReportsWorkspaceScreen_replace":
            MessageLookupByLibrary.simpleMessage("Sostituire"),
        "careEpisodeReportsWorkspaceScreen_reportFileName": m19,
        "careEpisodeReportsWorkspaceScreen_reportLabel":
            MessageLookupByLibrary.simpleMessage("relazione"),
        "careEpisodeReportsWorkspaceScreen_reportNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Il rapporto non è disponibile."),
        "careEpisodeReportsWorkspaceScreen_reportOptionsTitle":
            MessageLookupByLibrary.simpleMessage("Opzioni del report"),
        "careEpisodeReportsWorkspaceScreen_reportReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Il vostro rapporto è pronto. Il file DOCX conterrà le informazioni relative al paziente, all\'autore e al destinatario."),
        "careEpisodeReportsWorkspaceScreen_reportTitle":
            MessageLookupByLibrary.simpleMessage("Titolo della relazione"),
        "careEpisodeReportsWorkspaceScreen_restoreAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile ripristinare il bilancio"),
        "careEpisodeReportsWorkspaceScreen_restoreReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile ripristinare il rapporto."),
        "careEpisodeReportsWorkspaceScreen_resumeAssessmentDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Un lavoro in corso è già stato salvato automaticamente.<br><br>Desidera riprendere questa bozza o iniziare un nuovo bilancio?"),
        "careEpisodeReportsWorkspaceScreen_resumeDraft":
            MessageLookupByLibrary.simpleMessage("Riprendere la bozza"),
        "careEpisodeReportsWorkspaceScreen_resumeReportDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Un lavoro in corso è già stato salvato automaticamente.<br><br>Desidera riprendere questa bozza o iniziare un nuovo rapporto?"),
        "careEpisodeReportsWorkspaceScreen_returnToDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Non è possibile tornare alla bozza."),
        "careEpisodeReportsWorkspaceScreen_returnToReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Non è possibile tornare alla bozza del rapporto."),
        "careEpisodeReportsWorkspaceScreen_save":
            MessageLookupByLibrary.simpleMessage("Salva"),
        "careEpisodeReportsWorkspaceScreen_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Salva il bilancio"),
        "careEpisodeReportsWorkspaceScreen_saveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile salvare il bilancio."),
        "careEpisodeReportsWorkspaceScreen_saveNoteSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile salvare la selezione della nota."),
        "careEpisodeReportsWorkspaceScreen_saveReport":
            MessageLookupByLibrary.simpleMessage("Salva il rapporto"),
        "careEpisodeReportsWorkspaceScreen_saveReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile salvare il rapporto."),
        "careEpisodeReportsWorkspaceScreen_saveTestSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile salvare la selezione del test."),
        "careEpisodeReportsWorkspaceScreen_showPrescriber":
            MessageLookupByLibrary.simpleMessage("Visualizza il prescrittore"),
        "careEpisodeReportsWorkspaceScreen_showReferringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Visualizza il fisioterapista di riferimento"),
        "careEpisodeReportsWorkspaceScreen_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Area di compilazione del bilancio SOAP.<br><br>S — Soggettivo<br><br>O — Oggettivo<br><br>A — Analisi<br><br>P — Piano"),
        "careEpisodeReportsWorkspaceScreen_title":
            MessageLookupByLibrary.simpleMessage("Titolo"),
        "careEpisodeReportsWorkspaceScreen_update":
            MessageLookupByLibrary.simpleMessage("Aggiorna"),
        "careEpisodeReportsWorkspaceScreen_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Aggiornare il bilancio"),
        "careEpisodeReportsWorkspaceScreen_updateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile aggiornare il bilancio."),
        "careEpisodeReportsWorkspaceScreen_updateReport":
            MessageLookupByLibrary.simpleMessage("Aggiornare il rapporto"),
        "careEpisodeReportsWorkspaceScreen_updateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossibile aggiornare il rapporto."),
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreated": m20,
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreationError": m21,
        "careEpisodeReportsWorkspaceScreen_workspaceTitle": m22,
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
        "clinicalDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di preparare e salvare le valutazioni e i rapporti relativi all’assistenza.\n\nPer una valutazione, è possibile redigere il testo principale, selezionare i risultati dei test e le note di follow-up da includere, quindi generare un documento DOCX una volta salvata la valutazione.\n\nLe bozze vengono salvate automaticamente finché non vengono salvate come bilancio o rapporto.\n\nLa cronologia consente di recuperare i bilanci e i rapporti già salvati."),
        "clinicalDocuments_title":
            MessageLookupByLibrary.simpleMessage("Bilanci e relazioni"),
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
        "deviceForm_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di creare o modificare la scheda di un dispositivo in Companion.\n\nInserisci un nome che consenta di riconoscere facilmente il telefono o il tablet. Questo nome è obbligatorio.\n\nSeleziona la piattaforma del dispositivo: iOS o Android.\n\nÈ possibile associare il dispositivo a un professionista presente nell’elenco oppure scegliere l’opzione «dispositivo condiviso» per non assegnarlo a un professionista specifico.\n\nFare clic su «Crea» per aggiungere il dispositivo o su «Salva» per confermare le modifiche. «Annulla» chiude la finestra senza applicare le modifiche.\n\nL’apertura e la chiusura di questa guida conservano i dati inseriti nel modulo."),
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
        "deviceList_archiveConfirmation": m23,
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
        "deviceQr_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra mostra il codice QR di identificazione del dispositivo, insieme al suo nome, al nome dello studio e alla piattaforma di appartenenza.\n\nScansiona questo codice QR da ABAK Mobile per identificare questo dispositivo all’interno di questa struttura. Verifica che il nome visualizzato corrisponda effettivamente al telefono o al tablet in questione.\n\nQuesto codice QR serve a identificare il dispositivo; la sua visualizzazione non attiva il trasferimento dei risultati.\n\nChiudete questa finestra per tornare all’elenco dei dispositivi."),
        "deviceQr_title":
            MessageLookupByLibrary.simpleMessage("Apparecchio ABAK"),
        "documentArchiveConfirm_help": MessageLookupByLibrary.simpleMessage(
            "Spostando il documento nel cestino, il bilancio o il rapporto viene rimosso dalla cronologia abituale.\n\nIl documento rimane conservato in Companion. È possibile ritrovarlo tra i documenti archiviati e ripristinarlo per farlo riapparire nella cronologia.\n\nI file DOCX già esportati sul computer non vengono eliminati da questa operazione.\n\nFare clic su «Sposta nel cestino» per confermare, oppure su «Annulla» per conservare il documento nella cronologia."),
        "documentArchiveConfirm_title": MessageLookupByLibrary.simpleMessage(
            "Spostare il documento nel cestino?"),
        "documentAuthor_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di scegliere il medico designato come redattore della valutazione o della relazione in corso.\n\nSelezionare il medico dall\'elenco, quindi fare clic su «Conferma» per registrare tale associazione al documento.\n\nQuesta scelta riguarda il redattore del documento; non modifica il medico di riferimento del ciclo di cure.\n\n«Annulla» chiude la finestra senza modificare il redattore."),
        "documentAuthor_title":
            MessageLookupByLibrary.simpleMessage("Scegliere il redattore"),
        "documentDirectoryAccess_help": MessageLookupByLibrary.simpleMessage(
            "Companion non riesce ad accedere alla cartella prevista per il salvataggio dei documenti, oppure è necessario rinnovare la sua autorizzazione di accesso.\n\nSe questa cartella si trova su un disco esterno o in una posizione di rete, verificare innanzitutto che sia collegata e accessibile.\n\nFare clic su «Autorizza una cartella», quindi selezionare la cartella nella finestra che si apre. È possibile selezionare la cartella abituale o scegliere un’altra destinazione.\n\nLa cartella selezionata viene salvata nelle preferenze per le prossime esportazioni. I file già presenti nella vecchia cartella non vengono spostati.\n\n«Annulla» interrompe l’esportazione in corso senza modificare il bilancio o il rapporto."),
        "documentDirectoryAccess_title": MessageLookupByLibrary.simpleMessage(
            "Autorizzare la cartella dei documenti"),
        "documentDocxExisting_help": MessageLookupByLibrary.simpleMessage(
            "A questo bilancio o a questo rapporto è già stato associato un file DOCX.\n\n«Crea nuovo» genera un nuovo file con il contenuto attuale del documento. Se il nome del file esiste già nella cartella di destinazione, viene aggiunto un numero per conservare il file precedente. Il nuovo file diventa quello associato al documento in Companion.\n\n«Sostituisci» sovrascrive il file con il nome associato al documento nella cartella di destinazione. Eventuali modifiche apportate direttamente a questo file in Word o LibreOffice verranno sovrascritte.\n\n«Annulla» interrompe l’esportazione senza modificare i file."),
        "documentDocxExisting_title":
            MessageLookupByLibrary.simpleMessage("Esiste già un file DOCX"),
        "documentDraftChoice_help": MessageLookupByLibrary.simpleMessage(
            "Per questo tipo di documento, un testo in fase di redazione è già stato salvato automaticamente.\n\n«Riprendi la bozza» ti permette di recuperare quel testo e di continuare a scrivere.\n\n«Nuovo bilancio» o «Nuovo rapporto» cancella il titolo e il testo di questa bozza per ricominciare da capo. La bozza precedente non viene conservata come documento separato. Se desideri conservare il tuo lavoro, riprendilo e salvalo prima di iniziare un nuovo documento.\n\n«Annulla» chiude questa finestra senza modificare la bozza."),
        "documentDraftChoice_title":
            MessageLookupByLibrary.simpleMessage("Esiste una bozza"),
        "documentExpandedEditor_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra offre più spazio per scrivere o modificare il testo del bilancio o della relazione in corso.\n\nLe modifiche vengono aggiornate in tempo reale nell\'area di scrittura principale. Chiudendo la finestra, le modifiche non vengono annullate.\n\nFare clic sulla croce per tornare all’area Bilanci/Relazioni, quindi proseguire con la preparazione e il salvataggio del documento.\n\nAll’apertura e alla chiusura di questa guida, il testo inserito viene conservato."),
        "documentExpandedEditor_helpTitle":
            MessageLookupByLibrary.simpleMessage(
                "Scrivere nella vista ingrandita"),
        "documentRecipient_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di inserire i destinatari del bilancio o del rapporto in corso.\n\nInserire liberamente il nome del destinatario o i nomi dei diversi destinatari, quindi fare clic su «Conferma» per salvare queste informazioni nel documento.\n\nPer eliminare una voce esistente, cancellare il contenuto del campo e confermare.\n\nQuesto inserimento indica i destinatari del documento; non attiva alcun invio.\n\n«Annulla» chiude la finestra senza applicare le modifiche. L’apertura e la chiusura di questa guida conservano i dati inseriti."),
        "documentRecipient_title":
            MessageLookupByLibrary.simpleMessage("Destinatario/i"),
        "documentTemplateDraft_help": MessageLookupByLibrary.simpleMessage(
            "Per questo modello di guida sono già state registrate delle risposte nell\'episodio di cura in corso.\n\n«Riprendi la bozza» apre la guida con queste risposte per consentirti di proseguire o modificare quanto inserito.\n\n«Nuova valutazione» o «Nuovo referto» cancella le risposte salvate per questo modello e apre la guida senza riprendere tali risposte. Questa opzione non elimina il testo già presente nell’area di scrittura del documento.\n\n«Annulla» conserva le risposte salvate e torna alla schermata precedente senza aprire la guida."),
        "documentTemplateDraft_title":
            MessageLookupByLibrary.simpleMessage("Bozza esistente"),
        "documentTemplateGuide_help": MessageLookupByLibrary.simpleMessage(
            "Questa guida ti aiuta a preparare il contenuto di un bilancio o di una relazione sulla base del modello selezionato.\n\nUtilizza l\'elenco delle voci a sinistra per accedere alle diverse sezioni. A seconda dei campi proposti, inserisci il testo, seleziona le risposte o compila le tabelle.\n\nIl pulsante di anteprima, situato nella parte inferiore del modulo, consente di visualizzare il testo generato in base alle vostre risposte.\n\nDall’anteprima, potete tornare alla guida per continuare l’inserimento dei dati o richiedere l’inserimento del testo nel bilancio o nella relazione. Seguite eventuali suggerimenti di aggiunta o sostituzione visualizzati da Companion.\n\nL’inserimento del testo non sostituisce il salvataggio finale del bilancio o del rapporto.\n\nL’apertura e la chiusura di questa guida conservano i dati inseriti."),
        "documentTemplateGuide_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Utilizzare la guida alla digitazione"),
        "documentTemplatePreview_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di rileggere il testo generato sulla base delle risposte inserite nella guida.\n\nIl testo è consultabile e selezionabile. Per modificare le risposte, cliccare su «Chiudi» per tornare alla guida, quindi riavviare l’anteprima.\n\nFare clic su «Inserisci nel bilancio» o «Inserisci nel rapporto» per trasferire il testo nel documento in corso. Seguire eventuali suggerimenti di aggiunta o sostituzione visualizzati da Companion.\n\nSe non è stato generato alcun testo, il pulsante di inserimento rimane disattivato.\n\nDopo l’inserimento, controllate il contenuto del documento e salvate il vostro resoconto o la vostra relazione."),
        "documentTemplatePreview_title": MessageLookupByLibrary.simpleMessage(
            "Anteprima del testo generato"),
        "documentTemplate_assessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "Scegliere un modello di bilancio"),
        "documentTemplate_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra mostra i modelli disponibili per il tipo di documento corrente: bilancio o relazione.\n\nClicca su un modello per aprire la guida alla compilazione corrispondente. La scelta del modello non comporta la creazione immediata di un documento salvato.\n\nSe esiste già una bozza per quel modello nell’episodio di cura, Companion ti propone di riprenderla o di iniziare una nuova compilazione."),
        "documentTemplate_reportTitle": MessageLookupByLibrary.simpleMessage(
            "Scegliere un modello di rapporto"),
        "documentTests_help": MessageLookupByLibrary.simpleMessage(
            "Questa vista ingrandita consente di visualizzare i test effettuati durante il percorso terapeutico e di scegliere quelli da includere nella valutazione o nel referto in corso.\n\nUtilizzate le caselle di selezione per includere o escludere un test dal documento. Questa selezione non elimina i risultati salvati in Companion.\n\nLe azioni proposte nell’elenco consentono di visualizzare i dettagli dei risultati. La selezione è disponibile quando un bilancio o un rapporto è aperto e il caricamento è terminato.\n\nFare clic sulla croce per tornare all’area Bilanci/Rapporti."),
        "documentTextInsertion_help": MessageLookupByLibrary.simpleMessage(
            "Il vostro bilancio o la vostra relazione contiene già del testo. Scegliete come integrare il contenuto generato dalla guida alla compilazione.\n\n«Aggiungi alla fine» mantiene il testo esistente e aggiunge il contenuto generato alla fine.\n\n«Sostituisci» sostituisce tutto il testo nell’area di scrittura con il contenuto generato. Anche i passaggi che avevate digitato in quest’area verranno quindi sostituiti.\n\n«Annulla» interrompe l’inserimento e mantiene il testo attuale.\n\nPotete consultare e poi chiudere questa guida prima di effettuare la vostra scelta."),
        "documentTextInsertion_title":
            MessageLookupByLibrary.simpleMessage("Inserire il testo generato"),
        "documentTitle_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di inserire il titolo del bilancio o della relazione.\n\nMantenete il titolo proposto oppure sostituitelo con un titolo che consenta di riconoscere facilmente il documento. Il titolo non può essere vuoto.\n\nFare clic sul pulsante di conferma o premere Invio per confermare. «Annulla» chiude la finestra senza salvare il titolo.\n\nAll’apertura e alla chiusura di questa guida, il testo digitato viene conservato."),
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
        "episodeFormEditor_requiredField": m24,
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
        "episodeNotes_archiveConfirmation": m25,
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
        "episodeReferents_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di scegliere il fisioterapista di riferimento e il medico prescrittore associati al percorso terapeutico.\n\nSelezionate i professionisti dagli elenchi. È inoltre possibile rimuovere un’associazione scegliendo l’opzione “senza professionista”.\n\nI pulsanti di gestione situati a destra degli elenchi consentono di accedere alle schede dei professionisti e dei referenti esterni, in particolare per aggiungere un professionista mancante.\n\nFare clic su «Salva» per applicare le associazioni selezionate. Le modifiche relative al fisioterapista di riferimento vengono conservate nella cronologia del percorso terapeutico.\n\n«Annulla» cancella le modifiche alle associazioni effettuate in questa finestra. Le schede eventualmente create dalle schermate di gestione rimangono salvate."),
        "episodeReferents_title":
            MessageLookupByLibrary.simpleMessage("Modifica i riferimenti"),
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
        "externalCorrespondentForm_addTitle":
            MessageLookupByLibrary.simpleMessage("Aggiungi un contatto"),
        "externalCorrespondentForm_editTitle":
            MessageLookupByLibrary.simpleMessage("Modifica il contatto"),
        "externalCorrespondentForm_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di compilare la scheda di un corrispondente esterno.\n\nIl cognome è obbligatorio. È possibile inserire il nome, la professione, la specializzazione, l’indirizzo, il codice postale, la città, l’indirizzo e-mail e il numero di telefono.\n\nFare clic su «Salva» per confermare la scheda. «Annulla» chiude la finestra senza applicare le modifiche.\n\nL\'apertura e la chiusura di questa guida conservano i dati inseriti nel modulo."),
        "externalCorrespondents_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra i contatti esterni registrati in Companion. Ogni riga riporta il nome del contatto e, se disponibili, la professione, la specializzazione e la città.\n\nClicca su «Aggiungi» per creare un contatto. Inserisci i dati anagrafici e i recapiti, quindi clicca su «Salva» per aggiungerlo all’elenco. «Annulla» chiude il modulo senza creare alcun contatto.\n\nQuesti contatti possono essere selezionati, in particolare, come prescrittori nei percorsi di cura."),
        "externalCorrespondents_title":
            MessageLookupByLibrary.simpleMessage("Corrispondenti esterni"),
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
        "followUpNoteForm_createTitle":
            MessageLookupByLibrary.simpleMessage("Nuova nota di aggiornamento"),
        "followUpNoteForm_editTitle": MessageLookupByLibrary.simpleMessage(
            "Modifica la nota di follow-up"),
        "followUpNoteForm_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di creare o modificare una nota di follow-up associata all’episodio di cura.\n\nInserite un titolo e il contenuto della nota. Entrambi i campi devono contenere del testo affinché la nota venga salvata.\n\nAl momento della creazione, fare clic su «Aggiungi». In caso di modifica, fare clic su «Salva» per conservare le modifiche apportate.\n\n«Annulla» chiude la finestra senza salvare i dati inseriti. È possibile aprire e chiudere questa guida senza perdere il testo che si sta scrivendo."),
        "followUpNotes_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra le note di monitoraggio della gestione, con la data, il titolo e una panoramica del contenuto.\n\nIl pulsante \"Aggiungi\" consente di creare una nota. L\'icona \"Modifica\" consente di aprire una nota esistente per visualizzarla o modificarla.\n\nUtilizza le caselle di selezione per scegliere le note da includere nel bilancio o nel rapporto corrente. Deselezionando una nota, questa viene rimossa dalla selezione senza che la nota di follow-up venga eliminata.\n\nLa selezione è disponibile quando un resoconto o un rapporto è aperto e il caricamento è completato.\n\nFare clic sulla croce per chiudere la vista ingrandita e tornare all’area Resoconti/Rapporti."),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Prefisso ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Chiudi"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Commento"),
        "g_context": MessageLookupByLibrary.simpleMessage("Contesto"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Copia"),
        "g_file": MessageLookupByLibrary.simpleMessage("File"),
        "g_helpTooltip":
            MessageLookupByLibrary.simpleMessage("Visualizza la guida"),
        "g_learn_more":
            MessageLookupByLibrary.simpleMessage("Per saperne di più"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Informazioni tecniche"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Informazioni tecniche copiate"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "I pazienti archiviati possono essere ripristinati fino alla data indicata.\nDopo tale data, vengono eliminati automaticamente per evitare di conservare indefinitamente cartelle cliniche inutilizzate.\nIl periodo di conservazione può essere modificato nelle impostazioni di Companion."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "Si tratta dei dispositivi (telefono, tablet) utilizzati per eseguire i test.\n- Un dispositivo può essere utilizzato da persone diverse.\n- Una persona può possedere più dispositivi.\n\nQueste informazioni consentono di identificare la fonte fisica dei dati trasferiti a Companion.\nÈ possibile creare, modificare o archiviare un dispositivo.\n\nPer motivi di tracciabilità non è possibile eliminare un dispositivo\nSe necessario, è possibile ripristinare un dispositivo archiviato.\n\nPer associare un telefono o un tablet si utilizza un codice QR. È necessario visualizzare il codice QR sul telefono fisso (Dispositivo > icona corrispondente al dispositivo) e sul telefono (o tablet) accedere a Impostazioni > Organizzazione aziendale > Dispositivi registrati > Aggiungi un dispositivo.\n\nAvvicinare il dispositivo allo schermo per leggere il codice QR.Un messaggio vi informerà che l\'operazione è stata eseguita con successo."),
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
            "Un percorso di cura corrisponde a un episodio di cura.\nQui potete trovare i diversi percorsi di cura attivi relativi al vostro paziente.\nPer associare un risultato, potete utilizzare un episodio esistente oppure crearne uno nuovo.\nUna volta terminato l\'episodio, potete archiviarlo."),
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
        "home_correspondents":
            MessageLookupByLibrary.simpleMessage("Corrispondenti"),
        "home_create_a_backup":
            MessageLookupByLibrary.simpleMessage("Creare un backup"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Data non specificata"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Apparecchi"),
        "home_error_while_saving": m26,
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
        "home_other_exercises": m27,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Impostazioni"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Percorso"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Paziente ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Pazienti"),
        "home_pending_association": m28,
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
        "importHistory_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra la cronologia delle sessioni di importazione registrate in Companion.\n\nOgni riga indica la data della sessione, il suo stato, il numero di file elaborati e il numero di risultati importati, ignorati o in conflitto.\n\nL\'icona segnala, in particolare, un\'importazione in corso, un errore o conflitti che richiedono la vostra attenzione.\n\nCliccate su una sessione per visualizzarne i dettagli e comprendere meglio l\'elaborazione dei risultati."),
        "importPatientForm_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di creare una scheda paziente per associarvi i risultati importati da ABAK Mobile.\n\nInserisci il nome e il cognome. Puoi inserire la data di nascita nel formato AAAA-MM-GG e specificare il sesso, oppure lasciare il campo «Non specificato».\n\nSe è stata effettuata la lettura della tessera Vitale, verificare le informazioni precompilate e correggerle se necessario.\n\nFare clic su «Crea» per registrare il paziente e selezionarlo. Scegli quindi la prestazione a cui associare i risultati: la creazione del paziente, di per sé, non completa l’associazione dell’importazione.\n\n«Annulla» chiude questa finestra senza creare alcun paziente. L’apertura e la successiva chiusura di questa guida conservano i dati inseriti."),
        "importPatientForm_title":
            MessageLookupByLibrary.simpleMessage("Nuovo paziente"),
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("file"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("file"),
        "importResolutionAssistant_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata raggruppa le importazioni che richiedono la vostra attenzione: associazione a un paziente da completare, importazione non riuscita, errori, risultati ignorati o conflitti da esaminare.\n\nOgni riga indica la data dell’importazione e le informazioni disponibili per identificare la cartella clinica in questione.\n\nClicca su un\'importazione per aprirne la scheda di monitoraggio, consultare le spiegazioni e accedere alle azioni proposte in base alla situazione.\n\nL\'elenco viene aggiornato al tuo ritorno dalla scheda di monitoraggio dell\'importazione. Se nessuna importazione soddisfa questi criteri, un messaggio indica che non è stato rilevato alcun problema."),
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
        "importResolution_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di associare i risultati ricevuti da ABAK Mobile al paziente corretto e alla prestazione corrispondente in Companion.\n\nConsultate le informazioni relative all’importazione ricevuta, quindi selezionate il paziente in questione dall’elenco. Se necessario, create la sua scheda con «Nuovo paziente» o «Da Carte Vitale», quando il dispositivo di lettura è disponibile.\n\nDopo aver selezionato il paziente, scegliete un percorso di cura attivo o createne uno. Un percorso di cura archiviato deve essere ripristinato prima di poter essere selezionato.\n\nVerificate il paziente e il percorso di cura prima di scegliere quest\'ultimo: la sua selezione convalida l\'associazione e consente di proseguire con l\'importazione."),
        "importResolution_title":
            MessageLookupByLibrary.simpleMessage("Collegare l\'importazione"),
        "importSessionDetail_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra lo stato di un’importazione ricevuta in Companion. Il messaggio principale indica se l’importazione è andata a buon fine, se richiede l’associazione a un paziente o se presenta un problema.\n\nQuando è necessaria un’associazione, fare clic su «Associa a un paziente» per scegliere la cartella a cui collegare i risultati.\n\nIl resoconto e l’elenco dei file consentono di consultare i dettagli dell’elaborazione e gli eventuali avvisi.\n\nSe il file ricevuto è incompleto o danneggiato, richiedete un nuovo invio da ABAK Mobile.\n\nA seconda della situazione, viene visualizzato il pulsante «Elimina questa importazione». Consultate il messaggio di conferma prima di confermare l’eliminazione."),
        "importSessionDetail_title": MessageLookupByLibrary.simpleMessage(
            "Monitoraggio dell\'importazione"),
        "information_backupCount": m29,
        "information_backups": MessageLookupByLibrary.simpleMessage("Backup"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Configurato"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra le informazioni generali, tecniche e legali relative a Companion."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Informazioni"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Banca dati"),
        "information_help": MessageLookupByLibrary.simpleMessage(
            "Questa pagina presenta le informazioni generali relative alla tua installazione di Companion: versione dell’applicazione, studio configurato, presenza del logo, sistema utilizzato e lingua.\n\nLa sezione dedicata all’archiviazione locale indica la dimensione del database, nonché il numero e la dimensione totale dei backup salvati.\n\nI pulsanti consentono di consultare le novità, la licenza e le avvertenze relative all’utilizzo dell’applicazione.\n\nIn caso di contatto con l’assistenza, la versione di Companion e il sistema qui visualizzati possono aiutare a identificare la configurazione in uso."),
        "information_language": MessageLookupByLibrary.simpleMessage("Lingua"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Avviso legale"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Caricamento in corso..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Archiviazione locale"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_new": MessageLookupByLibrary.simpleMessage(
            "Versione 1.1.0 build 3\nPossibilità di dettatura vocale per i referti e le relazioni; richiede il modulo gratuito.\nSalvataggio automatico di referti e relazioni.\nPulsante per duplicare referti e relazioni.\nNote modificabili.\nPulsante per visualizzare tutti gli esami di un paziente relativi a un episodio clinico.\nModelli di referti.\nGrafico automatico in caso di più risultati per un esame.\nCreazione di un documento in formato docx.\nVisualizzazione della guida utilizzata per E72 e E76"),
        "information_newHelp": MessageLookupByLibrary.simpleMessage(
            "Questa pagina presenta le novità e gli aggiornamenti relativi a Companion.\n\nScorri il testo per visualizzare tutte le informazioni. Se necessario, puoi selezionare e copiare un passaggio.\n\nUsa la freccia indietro per tornare alla pagina “Informazioni”."),
        "information_newTitle":
            MessageLookupByLibrary.simpleMessage("Novità di questa versione"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Non configurato"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "information_office": MessageLookupByLibrary.simpleMessage("Studio"),
        "information_size": m30,
        "information_system": MessageLookupByLibrary.simpleMessage("Sistema"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Informazioni"),
        "information_totalSize": m31,
        "information_version": m32,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Versione..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("Consulta la licenza"),
        "initialReportDocumentService_associate":
            MessageLookupByLibrary.simpleMessage(
                "Allegare un bilancio iniziale in formato Word"),
        "initialReportDocumentService_unsupported":
            MessageLookupByLibrary.simpleMessage("Piattaforma non supportata"),
        "kobus_archived":
            MessageLookupByLibrary.simpleMessage("Companion — archiviato"),
        "kobus_archives":
            MessageLookupByLibrary.simpleMessage("Archivi importati"),
        "kobus_attach": MessageLookupByLibrary.simpleMessage(
            "Associare al paziente selezionato"),
        "kobus_backupNotice": MessageLookupByLibrary.simpleMessage(
            "L\'attuale procedura di backup del database non esegue il backup dei file KOBUS."),
        "kobus_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "kobus_candidate":
            MessageLookupByLibrary.simpleMessage("Paziente proposto"),
        "kobus_chooseCandidate": MessageLookupByLibrary.simpleMessage(
            "Seleziona una riga qui sotto"),
        "kobus_confirm": MessageLookupByLibrary.simpleMessage(
            "Verificare e confermare l\'importazione"),
        "kobus_confirmBody": MessageLookupByLibrary.simpleMessage(
            "Importare i fascicoli pronti in base alle vostre decisioni? I raffronti non risolti e i fascicoli esclusi verranno messi da parte. Le schede esistenti non verranno modificate."),
        "kobus_consult":
            MessageLookupByLibrary.simpleMessage("Consulta i dati KOBUS"),
        "kobus_create": MessageLookupByLibrary.simpleMessage("Crea una scheda"),
        "kobus_creations":
            MessageLookupByLibrary.simpleMessage("Schede create / da creare"),
        "kobus_distinct": MessageLookupByLibrary.simpleMessage(
            "Confermare una persona diversa"),
        "kobus_editRejected": MessageLookupByLibrary.simpleMessage(
            "Modifica l\'elenco delle cartelle rifiutate"),
        "kobus_existing": MessageLookupByLibrary.simpleMessage(
            "Pazienti già in cura interessati"),
        "kobus_failed":
            MessageLookupByLibrary.simpleMessage("Problemi tecnici"),
        "kobus_history":
            MessageLookupByLibrary.simpleMessage("Resoconto KOBUS"),
        "kobus_imported": MessageLookupByLibrary.simpleMessage("Importati"),
        "kobus_interrupted": MessageLookupByLibrary.simpleMessage(
            "Non trattati dopo l\'interruzione"),
        "kobus_intro": MessageLookupByLibrary.simpleMessage(
            "Le cartelle cliniche vengono conservate così come sono. Non vengono creati né episodi clinici né documenti clinici originali."),
        "kobus_matches":
            MessageLookupByLibrary.simpleMessage("Confronti da verificare"),
        "kobus_noShared": MessageLookupByLibrary.simpleMessage(
            "In questa esportazione non sono presenti cartelle condivise"),
        "kobus_ownOrigin":
            MessageLookupByLibrary.simpleMessage("I miei pazienti"),
        "kobus_print": MessageLookupByLibrary.simpleMessage("Stampa"),
        "kobus_provenance":
            MessageLookupByLibrary.simpleMessage("Provenienza / stato"),
        "kobus_reason": MessageLookupByLibrary.simpleMessage("Motivo"),
        "kobus_rejected": MessageLookupByLibrary.simpleMessage("Rifiutati"),
        "kobus_savePdf": MessageLookupByLibrary.simpleMessage("Salva il PDF"),
        "kobus_scopeReset": MessageLookupByLibrary.simpleMessage(
            "Modificando questa opzione, le decisioni di riconciliazione vengono azzerate."),
        "kobus_select":
            MessageLookupByLibrary.simpleMessage("Scegliere lo ZIP KOBUS"),
        "kobus_shared": MessageLookupByLibrary.simpleMessage(
            "Recuperare anche le cartelle condivise, se presenti"),
        "kobus_sharedOrigin": MessageLookupByLibrary.simpleMessage(
            "Pazienti in cura presso più strutture"),
        "kobus_skip": MessageLookupByLibrary.simpleMessage("Lasciati da parte"),
        "kobus_source": MessageLookupByLibrary.simpleMessage("Identità KOBUS"),
        "kobus_start":
            MessageLookupByLibrary.simpleMessage("Avvia l\'importazione"),
        "kobus_stop": MessageLookupByLibrary.simpleMessage(
            "Interrompere dopo il file corrente"),
        "kobus_stopping":
            MessageLookupByLibrary.simpleMessage("Richiesta di sospensione…"),
        "kobus_title": MessageLookupByLibrary.simpleMessage("Importa KOBUS"),
        "kobus_unavailable": MessageLookupByLibrary.simpleMessage(
            "I dati KOBUS non sono disponibili oppure il file non è stato trovato."),
        "kobus_unresolved": MessageLookupByLibrary.simpleMessage("Da decidere"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Lingua registrata."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Lingua dell\'applicazione"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Avviso"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion è un software che facilita l’organizzazione, l’importazione e la consultazione dei risultati clinici provenienti dall’ecosistema ABAK.\n\nNon costituisce un dispositivo medico certificato e non sostituisce il giudizio del professionista sanitario.\n\nI risultati, i punteggi, i referti e gli indicatori visualizzati devono sempre essere interpretati da un professionista qualificato, tenendo conto dell’esame clinico, del contesto del paziente e delle raccomandazioni in vigore.\n\nL’utente rimane l’unico responsabile delle proprie decisioni cliniche, della verifica dei dati importati e della conformità del loro utilizzo alle norme professionali, regolamentari e deontologiche applicabili.\n\nABAK Desktop Companion non effettua diagnosi autonome, non prescrive alcun trattamento e non sostituisce in alcun caso una visita medica o paramedica."),
        "legalNotice_help": MessageLookupByLibrary.simpleMessage(
            "Questa pagina riporta le avvertenze e le informazioni relative all’utilizzo di Companion.\n\nScorri la pagina per leggere il testo completo.\n\nUsa la freccia indietro per tornare alla pagina “Informazioni”."),
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
        "localDatabaseRestoreService_anomaly": m33,
        "localDatabaseRestoreService_failure": m34,
        "localDatabaseRestoreService_integrity": m35,
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
        "organization_chooseReportHeader": MessageLookupByLibrary.simpleMessage(
            "Scegliere un\'intestazione personalizzata"),
        "organization_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di inserire il nome e i dati di contatto del proprio studio: indirizzo, codice postale, città, numero di telefono e indirizzo e-mail.\n\nFare clic su «Salva dati» per salvare le modifiche prima di uscire dalla schermata.\n\nÈ inoltre possibile selezionare un\'immagine dal proprio computer per impostare il logo dello studio. La scelta del logo viene salvata immediatamente, indipendentemente dai dati di contatto.\n\nIl pulsante di eliminazione del logo consente di rimuovere il logo utilizzato in Companion."),
        "organization_identityTitle":
            MessageLookupByLibrary.simpleMessage("Identità dell\'istituto"),
        "organization_logoRecommendation": MessageLookupByLibrary.simpleMessage(
            "Dimensioni consigliate: immagine quadrata di almeno 300 × 300 px. Formato consigliato: PNG."),
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
        "organization_removeReportHeader":
            MessageLookupByLibrary.simpleMessage("Elimina l\'intestazione"),
        "organization_reportHeaderHelpAi": MessageLookupByLibrary.simpleMessage(
            "Puoi anche chiedere a uno strumento di intelligenza artificiale di generare l\'immagine dell\'intestazione in base alle tue indicazioni."),
        "organization_reportHeaderHelpClose":
            MessageLookupByLibrary.simpleMessage("Chiudi"),
        "organization_reportHeaderHelpContent":
            MessageLookupByLibrary.simpleMessage(
                "L\'immagine può contenere a vostra discrezione il vostro logo, il nome della struttura, i vostri recapiti e qualsiasi altro elemento grafico che desideriate includere nei vostri rapporti."),
        "organization_reportHeaderHelpFormat": MessageLookupByLibrary.simpleMessage(
            "Per ottenere un risultato ottimale nei report ABAK, utilizzare un\'immagine in formato 200 × 30 mm, ovvero circa 2362 × 354 px a 300 dpi. Si consiglia il formato PNG."),
        "organization_reportHeaderHelpIntro": MessageLookupByLibrary.simpleMessage(
            "Potete creare liberamente la vostra intestazione con lo strumento che preferite, per poi salvarla come immagine."),
        "organization_reportHeaderHelpReplacement":
            MessageLookupByLibrary.simpleMessage(
                "Le informazioni presenti nell\'immagine sostituiscono l\'intestazione standard generata da ABAK (logo e recapiti dell\'istituto)."),
        "organization_reportHeaderHelpTitle":
            MessageLookupByLibrary.simpleMessage(
                "Creare un\'intestazione personalizzata"),
        "organization_reportHeaderHelpTools": MessageLookupByLibrary.simpleMessage(
            "Se non avete familiarità con i programmi di grafica, potete ad esempio utilizzare LibreOffice Draw, Microsoft PowerPoint, Apple Keynote o Canva. Questo elenco è puramente indicativo e non è esaustivo."),
        "organization_reportHeaderHelpTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Guida alla creazione di un\'intestazione personalizzata"),
        "organization_reportHeaderRecommendation":
            MessageLookupByLibrary.simpleMessage(
                "Dimensioni consigliate: 200 × 30 mm (circa 2362 × 354 px a 300 dpi). Formato consigliato: PNG."),
        "organization_reportHeaderRemoved":
            MessageLookupByLibrary.simpleMessage(
                "Intestazione personalizzata rimossa."),
        "organization_reportHeaderSaved": MessageLookupByLibrary.simpleMessage(
            "Intestazione personalizzata salvata."),
        "organization_reportHeaderTitle": MessageLookupByLibrary.simpleMessage(
            "Intestazione personalizzata dei report"),
        "organization_reportIntroductionHelp": MessageLookupByLibrary.simpleMessage(
            "Testo libero utilizzato all\'inizio dei rapporti. Se questo campo è vuoto, verrà utilizzato \"Dottore\"."),
        "organization_reportIntroductionHint":
            MessageLookupByLibrary.simpleMessage("Dottore"),
        "organization_reportIntroductionLabel":
            MessageLookupByLibrary.simpleMessage(
                "Formula introduttiva delle relazioni"),
        "organization_saveName":
            MessageLookupByLibrary.simpleMessage("Salva il nome"),
        "organization_title": MessageLookupByLibrary.simpleMessage("Struttura"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Associare un telefono"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Associare un telefono"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scansiona questo codice QR da ABAK Mobile per configurare automaticamente la connessione al Desktop."),
        "pairPhone_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra mostra le informazioni che consentono ad ABAK Mobile di individuare Companion sulla rete locale.\n\nCollegate il telefono o il tablet e il computer alla stessa rete locale, quindi scansionate questo codice QR dalla funzione di associazione a Companion in ABAK Mobile.\n\nIl codice QR contiene l\'indirizzo di rete e la porta di comunicazione di questo computer. Queste informazioni sono visualizzate anche sotto il codice.\n\nTenere Companion aperto sul computer durante gli scambi. Se l\'indirizzo di rete del computer cambia, riaprire questa finestra e scansionare il nuovo codice.\n\nLa visualizzazione di questo codice QR non attiva di per sé l’invio dei risultati."),
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
        "patientClinicalDataEdit_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di compilare i dati amministrativi e il profilo del paziente.\n\nÈ possibile inserire il suo codice sanitario, la fonte della sua identità, il numero di telefono, l\'indirizzo e-mail e l\'indirizzo postale.\n\nIl profilo comprende il lato dominante, la professione, l’attività sportiva, l’altezza in centimetri e il peso in chilogrammi.\n\nCliccare su «Salva» per salvare le modifiche e tornare alla scheda del paziente. Tornando indietro senza salvare, le modifiche verranno perse."),
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
        "patientDetail_editCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di modificare le informazioni relative alla presa in carico del paziente.\n\nÈ possibile correggere la patologia o il motivo della presa in carico, integrare il testo iniziale e scegliere il medico di riferimento e il medico prescrittore.\n\nPer salvare le modifiche è necessario inserire la patologia.\n\nFare clic su «Salva» per confermare le modifiche. «Annulla» chiude la finestra senza applicarle.\n\nL’apertura e la chiusura di questa guida conservano i dati inseriti nel modulo."),
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
        "patientDetail_newCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di creare una nuova presa in carico per il paziente selezionato.\n\nInserisci la patologia o il motivo della presa in carico. Queste informazioni sono necessarie per creare l’episodio.\n\nÈ possibile integrare il testo iniziale e selezionare un medico di riferimento. Queste informazioni sono facoltative.\n\nFare clic su «Crea» per salvare l’episodio. «Annulla» chiude la finestra senza crearlo.\n\nL’apertura e la chiusura di questa guida conservano i dati inseriti nel modulo."),
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
        "patientDocuments_authorization": MessageLookupByLibrary.simpleMessage(
            "La cartella deve essere autorizzata nuovamente. Selezionare la cartella condivisa definita nelle impostazioni."),
        "patientDocuments_chooseRoot": MessageLookupByLibrary.simpleMessage(
            "Selezionare la cartella condivisa"),
        "patientDocuments_error": MessageLookupByLibrary.simpleMessage(
            "Impossibile preparare o aprire la cartella. Verificare la sua disponibilità e i propri diritti di accesso, quindi riprovare.\""),
        "patientDocuments_open": MessageLookupByLibrary.simpleMessage(
            "\"Aprire la cartella clinica\""),
        "patientDocuments_retry":
            MessageLookupByLibrary.simpleMessage("Riprovare"),
        "patientDocuments_settingsHelp": MessageLookupByLibrary.simpleMessage(
            "Una cartella per paziente, contenente “Bilancio”, “Relazione” e “Altro”. Creazione all’apertura della scheda; i file esistenti non vengono spostati."),
        "patientDocuments_structure": MessageLookupByLibrary.simpleMessage(
            "Bilancio / Relazione / Altro"),
        "patientDocuments_title":
            MessageLookupByLibrary.simpleMessage("Documentazione del paziente"),
        "patientDocuments_unconfigured": MessageLookupByLibrary.simpleMessage(
            "Non è stata definita alcuna cartella di archiviazione. Scegliere la cartella comune a tutti i pazienti."),
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
        "patientForm_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di inserire o correggere i dati anagrafici del paziente.\n\nIl cognome e il nome sono campi obbligatori. È possibile selezionare la data di nascita dal calendario e inserire il sesso, oppure mantenere il valore «Non specificato».\n\nFare clic su «Salva» per confermare le modifiche. Se il modulo è aperto in modalità creazione, il pulsante «Crea» consente di creare la scheda.\n\n«Annulla» chiude la finestra senza applicare le modifiche. L\'apertura e la chiusura di questa guida mantengono i dati inseriti nel modulo."),
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
        "patientList_archiveConfirmation": m36,
        "patientList_archiveSuccess": m37,
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
        "patientList_error": m38,
        "patientList_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di individuare i propri pazienti e di accedere alle loro cartelle cliniche.\n\nI pulsanti «Attivi» e «Archiviati» consentono di selezionare l\'elenco da visualizzare. Il numero indicato corrisponde al totale dei pazienti di ciascuna categoria.\n\nPer cercare un paziente nell\'elenco visualizzato, inserisci tutto o parte del suo cognome o nome nel campo di ricerca. Clicca sulla sua riga per aprire la sua cartella clinica.\n\nIl pulsante «Nuovo paziente» apre la schermata di creazione di un paziente.\n\nPer un paziente attivo, l’icona a forma di matita consente di modificare i suoi dati anagrafici. L’icona di archiviazione consente di rimuoverlo dall’elenco dei pazienti attivi dopo la conferma.\n\nNell’elenco dei pazienti archiviati, l’icona di ripristino consente di reinserire un paziente nell’elenco dei pazienti attivi. Una guida specifica, accessibile accanto alla data di archiviazione, illustra le modalità di conservazione."),
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
        "patientList_restoreSuccess": m39,
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
        "patientNew_attachVitaleSuccess": m40,
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
        "patientNew_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di creare un paziente in ABAK Companion.\n\nInserisci il cognome e il nome: questi due dati sono obbligatori. Puoi inserire la data di nascita utilizzando il calendario e specificare il sesso.\n\nIl pulsante di lettura della tessera Vitale consente di recuperare l’identità del paziente quando il lettore e il modulo di lettura sono disponibili. Se vengono proposti più beneficiari, selezionare la persona interessata, quindi verificare le informazioni visualizzate. È comunque possibile effettuare l’inserimento manuale.\n\nSe Companion rileva un paziente già presente, verificare le informazioni proposte prima di proseguire per evitare un doppione. Un paziente archiviato può essere proposto per il ripristino.\n\nFare clic su «Crea paziente» per salvare la scheda, oppure su «Annulla» per uscire senza creare alcun paziente."),
        "patientNew_identificationCountriesHelp":
            MessageLookupByLibrary.simpleMessage(
                "La lettura della tessera Vitale offerta da Companion riguarda attualmente la Francia. Consente di recuperare i dati identificativi per facilitare la creazione della scheda paziente.\n\nABAK Companion intende estendere questa procedura ai mezzi di identificazione utilizzati in altri paesi. Le tessere, le credenziali e i servizi sanitari funzionano in modo diverso in questi paesi: la loro gestione non è ancora integrata in Companion. Rimane comunque disponibile l’inserimento manuale dei dati.\n\nDesideriamo esplorare queste possibilità insieme ai fisioterapisti che utilizzano ABAK. Volete collaborare con noi nel vostro paese? La vostra conoscenza delle pratiche locali e la vostra partecipazione ai test ci aiuteranno a definire una soluzione utile e adeguata.\n\nGli sviluppi saranno realizzati gradualmente insieme ai professionisti che si offriranno volontari, in base alle esigenze espresse, alle possibilità tecniche e alle autorizzazioni necessarie."),
        "patientNew_identificationCountriesTitle":
            MessageLookupByLibrary.simpleMessage(
                "Identificazione dei pazienti per paese"),
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
        "patientNew_readVitale": MessageLookupByLibrary.simpleMessage(
            "Leggere la tessera sanitaria"),
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
        "patientNew_restoreSuccess": m41,
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
        "practitionerList_archiveConfirmation": m42,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "Il cestino dei fisioterapisti è vuoto al momento."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Archiviare il fisioterapista"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archiviati"),
        "practitionerList_archivedOn": m43,
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
        "practitionerList_error": m44,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Nessun fisioterapista archiviato"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "Nessun fisioterapista registrato"),
        "practitionerList_professionalId": m45,
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
        "practitionerNew_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di creare o modificare la scheda di un professionista.\n\nIl nome visualizzato è obbligatorio: permette di identificare il professionista in Companion. È inoltre possibile inserire il suo nome, il cognome, il codice professionale, l’indirizzo e-mail e il numero di telefono.\n\nFare clic su «Crea» per aggiungere un professionista o su «Salva» per confermare le modifiche apportate a una scheda esistente.\n\n«Annulla» chiude la finestra senza applicare le modifiche. L’apertura e la chiusura di questa guida conservano i dati inseriti nel modulo."),
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
        "practitionerQr_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra mostra il codice QR del profilo professionale del medico, insieme al suo nome e al nome dello studio.\n\nScansiona questo codice QR tramite ABAK Mobile per identificare il medico in questa struttura. Verifica che il nome visualizzato corrisponda al professionista in questione.\n\nQuesto codice QR serve a trasmettere le informazioni di identificazione del profilo professionale; la sua visualizzazione non comporta il trasferimento di risultati.\n\nChiudete questa finestra per tornare all’elenco dei professionisti."),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("Profilo professionale ABAK"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Scansiona questo codice QR da ABAK Mobile per aggiungere automaticamente questo profilo professionale."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("archiviato"),
        "practitionerSelector_error": m46,
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
        "referringPractitionerHistoryDialog_archivedPractitioner": m47,
        "referringPractitionerHistoryDialog_close":
            MessageLookupByLibrary.simpleMessage("Chiudi"),
        "referringPractitionerHistoryDialog_currentPractitioner":
            MessageLookupByLibrary.simpleMessage("Referente attuale"),
        "referringPractitionerHistoryDialog_fromTo": m48,
        "referringPractitionerHistoryDialog_loadHistoryError": m49,
        "referringPractitionerHistoryDialog_noHistory":
            MessageLookupByLibrary.simpleMessage(
                "Per questo episodio non è stato ancora registrato alcun fisioterapista di riferimento."),
        "referringPractitionerHistoryDialog_since": m50,
        "referringPractitionerHistory_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra mostra i professionisti che sono stati designati come referenti per questo ciclo di cure.\n\nOgni riga riporta il nome del professionista e il periodo di assegnazione. La dicitura «Referente attuale» indica il professionista attualmente associato al ciclo di cure.\n\nLa dicitura «Archiviato» indica che la scheda del medico è stata archiviata; il suo nome rimane visibile nella cronologia.\n\nQuesta finestra consente esclusivamente di consultare la cronologia. Chiudila per tornare al ciclo di cure."),
        "referringPractitionerHistory_title":
            MessageLookupByLibrary.simpleMessage(
                "Cronologia dei fisioterapisti di riferimento"),
        "refreshDashboard":
            MessageLookupByLibrary.simpleMessage("Aggiornare il cruscotto"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Archivio dei rapporti"),
        "reportDraft_help": MessageLookupByLibrary.simpleMessage(
            "Il testo visualizzato corrisponde a un lavoro in corso salvato automaticamente. È possibile mantenerlo, modificarlo o eliminarlo prima di salvare il rapporto."),
        "reportDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Comprendere la bozza della relazione"),
        "reportHistory_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra i rapporti salvati relativi all’assistenza, con il titolo e la data.\n\nLe azioni disponibili in ogni riga consentono di modificare un rapporto, duplicarlo o spostarlo nei documenti archiviati.\n\nQuando un rapporto è aperto in modalità di modifica, utilizzare l’azione di aggiornamento per salvare le modifiche. I comandi disponibili consentono inoltre di annullare le modifiche o di tornare alla bozza.\n\nLo spostamento nei documenti archiviati non comporta l\'eliminazione definitiva.\n\nClicchi sulla croce per chiudere la vista ingrandita e tornare all\'area Bilanci/Rapporti."),
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
        "resultDetail_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata mostra le informazioni relative a un risultato importato da ABAK Mobile: paziente, data di esecuzione, punteggio e, se disponibili, ausilio utilizzato, identità del medico e dispositivo di origine.\n\nÈ possibile consultare il referto dettagliato e le misurazioni aggiuntive trasmesse dalla struttura.\n\nL’area «Commento clinico» consente di aggiungere o modificare le proprie osservazioni. Fare clic su «Salva» per salvarle prima di uscire dalla schermata.\n\nLa sezione dedicata all’importazione indica lo stato di sincronizzazione e la data dell’ultima modifica del risultato.\n\nL’icona di archiviazione consente di archiviare questo risultato dopo la conferma."),
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
        "settings_databaseResetError": m51,
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
        "settings_exportAction":
            MessageLookupByLibrary.simpleMessage("Esporta"),
        "settings_exportCancel":
            MessageLookupByLibrary.simpleMessage("Annulla"),
        "settings_exportCancelled":
            MessageLookupByLibrary.simpleMessage("Esportazione annullata"),
        "settings_exportChooseDestination":
            MessageLookupByLibrary.simpleMessage(
                "Scegliere la cartella di destinazione"),
        "settings_exportCompleted": m52,
        "settings_exportCompletedWithErrors": m53,
        "settings_exportDataDescription": MessageLookupByLibrary.simpleMessage(
            "Verrà creato un archivio contenente le informazioni relative ai vostri pazienti, nonché i loro referti e le loro relazioni."),
        "settings_exportFailed": MessageLookupByLibrary.simpleMessage(
            "Impossibile esportare i dati"),
        "settings_exportIncludeArchivedPatients":
            MessageLookupByLibrary.simpleMessage(
                "Includere i pazienti archiviati"),
        "settings_exportMyData":
            MessageLookupByLibrary.simpleMessage("Esporta i miei dati"),
        "settings_exportPatientBirthDate":
            MessageLookupByLibrary.simpleMessage("Data di nascita"),
        "settings_exportPatientFemale":
            MessageLookupByLibrary.simpleMessage("Femminile"),
        "settings_exportPatientFirstName":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "settings_exportPatientLastName":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "settings_exportPatientMale":
            MessageLookupByLibrary.simpleMessage("Maschile"),
        "settings_exportPatientSex":
            MessageLookupByLibrary.simpleMessage("Sesso"),
        "settings_exportPatientUnknown":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "settings_exportPatientUnknownFemale":
            MessageLookupByLibrary.simpleMessage("Non specificato"),
        "settings_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata raggruppa le funzioni di installazione, diagnostica e manutenzione di Companion. Utilizzarle secondo le indicazioni della documentazione ABAK o di un tecnico.\n\nLa sezione «Configurazione» consente di visualizzare, aprire o modificare la cartella utilizzata per lo scambio di file.\n\nLa sezione «Diagnostica» consente di accedere alle verifiche del dispositivo di lettura della tessera Vitale.\n\nLa sezione «Manutenzione» consente di aprire la procedura guidata per la risoluzione dei problemi di importazione, di importare manualmente un file ABAK e di accedere alla gestione dei backup.\n\nIl ripristino del database elimina i dati locali. Questa operazione è riservata alle situazioni di assistenza tecnica: leggere attentamente i messaggi di conferma prima di procedere."),
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
        "speechDictationButton_failure": m54,
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
        "vitaleBeneficiarySelector_help": MessageLookupByLibrary.simpleMessage(
            "Questa finestra consente di selezionare la persona interessata quando, dopo la lettura della tessera Vitale, vengono proposti più beneficiari.\n\nVerificate il cognome, il nome e la data di nascita, se disponibile, quindi cliccate sulla riga del beneficiario desiderato.\n\nLa selezione chiude questa finestra e trasmette l’identità scelta alla fase successiva.\n\n«Annulla» chiude la finestra senza selezionare alcun beneficiario."),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage("Selezionare un beneficiario"),
        "vitaleDiagnostic_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di verificare il funzionamento del dispositivo di lettura della tessera Vitale.\n\nIn Windows, la sezione dedicata al modulo ne indica lo stato e permette di aggiornare tali informazioni.\n\nAvviare una lettura con il lettore collegato e la tessera inserita. Se vengono proposti più beneficiari, selezionare la persona interessata per consultare le informazioni lette.\n\nI messaggi visualizzati consentono di comprendere l\'eventuale causa di un errore e possono essere comunicati all\'assistenza.\n\nLa sezione «Diagnostica avanzata» offre un test tecnico di comunicazione con la tessera. Utilizzatela seguendo le indicazioni della documentazione ABAK o di un tecnico.\n\nQuesta schermata serve a fini diagnostici: la lettura di un’identità non crea una scheda paziente."),
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
        "vitaleIdentity_help": MessageLookupByLibrary.simpleMessage(
            "Questa schermata consente di leggere i dati identificativi di un beneficiario da una tessera Vitale, quando il lettore e il modulo di lettura sono disponibili.\n\nLa lettura ha inizio all’apertura della schermata. È possibile riavviarla tramite il pulsante di lettura. Se sulla tessera sono presenti più beneficiari, selezionare la persona interessata.\n\nVerificare il cognome, il nome, la data di nascita e le altre informazioni visualizzate. Il numero di identificazione viene segnalato come rilevato o non disponibile, senza essere visualizzato per intero.\n\nQuando l’identità è utilizzabile, il pulsante di creazione del paziente consente di trasmettere queste informazioni al modulo di creazione.\n\nSe non è disponibile alcuna identità, consultare il messaggio visualizzato e verificare il dispositivo di lettura prima di riprovare. È possibile tornare alla schermata precedente per effettuare un inserimento manuale."),
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
                "Da utilizzare per creare un paziente"),
        "walkingAid_cane": MessageLookupByLibrary.simpleMessage("Bastone"),
        "walkingAid_label":
            MessageLookupByLibrary.simpleMessage("Aiuto utilizzato"),
        "walkingAid_none": MessageLookupByLibrary.simpleMessage("Nessuna"),
        "walkingAid_other": MessageLookupByLibrary.simpleMessage("Altro"),
        "walkingAid_rollatorFourWheels":
            MessageLookupByLibrary.simpleMessage("Deambulatore a 4 ruote"),
        "walkingAid_walkerTwoWheels":
            MessageLookupByLibrary.simpleMessage("Deambulatore a 2 ruote")
      };
}
