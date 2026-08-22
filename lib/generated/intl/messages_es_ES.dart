// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es_ES locale. All the
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
  String get localeName => 'es_ES';

  static String m0(size) => "${size}";

  static String m1(deviceName) => "¿De verdad quieres archivar ${deviceName}?";

  static String m2(fieldName) => "El campo «${fieldName}» es obligatorio.";

  static String m3(noteTitle) => "La nota «${noteTitle}» ya no se mostrará.";

  static String m4(error) => "Error al guardar: ${error}";

  static String m5(count) => "${count} otro(s) ejercicio(s)";

  static String m6(count) => "${count} asociación(es) pendientes";

  static String m7(count) => "${count} copias de seguridad";

  static String m8(size) => "Talla: ${size}";

  static String m9(size) => "Tamaño total: ${size}";

  static String m10(version) => "Versión ${version}";

  static String m11(patientName) =>
      "¿De verdad quieres archivar a ${patientName}? Ya no aparecerá en la lista activa.";

  static String m12(patientName) => "${patientName} archivado.";

  static String m13(error) => "Error: ${error}";

  static String m14(patientName) =>
      "${patientName} se ha vuelto a incluir en la lista activa.";

  static String m15(patientName) =>
      "Tarjeta Vitale asociada al paciente ${patientName}.";

  static String m16(patientName) =>
      "El paciente ${patientName} se ha recuperado.";

  static String m17(practitionerName) =>
      "¿De verdad quieres archivar a ${practitionerName}?";

  static String m18(date) => "Archivado el ${date}";

  static String m19(error) => "Error: ${error}";

  static String m20(professionalId) => "ID pro: ${professionalId}";

  static String m21(error) => "Error: ${error}";

  static String m22(error) => "Error al reiniciar: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "backupHistory_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "No hay ninguna copia de seguridad guardada."),
        "backupHistory_fileSize": m0,
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "backupHistory_restoreTitle": MessageLookupByLibrary.simpleMessage(
            "¿Quieres restaurar esta copia de seguridad?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Esta operación sustituirá por completo la base de datos actual.\n\nSe creará una copia de seguridad automática antes de la restauración.\n\n¿Deseas continuar?"),
        "backupHistory_title": MessageLookupByLibrary.simpleMessage(
            "Historial de copias de seguridad"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origen: ABAK"),
        "careEpisodeDetail_evolution":
            MessageLookupByLibrary.simpleMessage("Evolución"),
        "careEpisodeDetail_noResult": MessageLookupByLibrary.simpleMessage(
            "De momento no hay ningún resultado relacionado."),
        "careEpisodeDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Patología"),
        "careEpisodeDetail_reportsWorkspaceTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Nueva interfaz de balances e informes"),
        "careEpisodeDetail_results":
            MessageLookupByLibrary.simpleMessage("Resultados de ABAK"),
        "careEpisodeDetail_score":
            MessageLookupByLibrary.simpleMessage("Puntuación"),
        "careEpisodeReportsWorkspace_addFollowUpNote":
            MessageLookupByLibrary.simpleMessage(
                "Añadir una nota de seguimiento"),
        "careEpisodeReportsWorkspace_archived":
            MessageLookupByLibrary.simpleMessage("archivado"),
        "careEpisodeReportsWorkspace_archivedDocuments":
            MessageLookupByLibrary.simpleMessage("Documentos archivados"),
        "careEpisodeReportsWorkspace_archivedDocumentsCount":
            MessageLookupByLibrary.simpleMessage("Documentos archivados"),
        "careEpisodeReportsWorkspace_assessment":
            MessageLookupByLibrary.simpleMessage("con"),
        "careEpisodeReportsWorkspace_assessmentCount":
            MessageLookupByLibrary.simpleMessage("Número de balances"),
        "careEpisodeReportsWorkspace_assessmentHistory":
            MessageLookupByLibrary.simpleMessage("Historial de balances"),
        "careEpisodeReportsWorkspace_assessmentsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "No se pueden cargar los balances."),
        "careEpisodeReportsWorkspace_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "careEpisodeReportsWorkspace_cancelChanges":
            MessageLookupByLibrary.simpleMessage("Deshacer los cambios"),
        "careEpisodeReportsWorkspace_createOrResumeAssessment":
            MessageLookupByLibrary.simpleMessage(
                "Crear o recuperar un balance"),
        "careEpisodeReportsWorkspace_createOrResumeReport":
            MessageLookupByLibrary.simpleMessage("Crear o reanudar un informe"),
        "careEpisodeReportsWorkspace_date":
            MessageLookupByLibrary.simpleMessage("Datos"),
        "careEpisodeReportsWorkspace_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Eliminar definitivamente"),
        "careEpisodeReportsWorkspace_duplicate":
            MessageLookupByLibrary.simpleMessage("Duplicar"),
        "careEpisodeReportsWorkspace_edit":
            MessageLookupByLibrary.simpleMessage("Modificar"),
        "careEpisodeReportsWorkspace_editReferringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Cambiar de fisioterapeuta de referencia"),
        "careEpisodeReportsWorkspace_episodeDocuments":
            MessageLookupByLibrary.simpleMessage(
                "Documentación de la admisión"),
        "careEpisodeReportsWorkspace_episodeSummary":
            MessageLookupByLibrary.simpleMessage("Resumen del episodio"),
        "careEpisodeReportsWorkspace_expand":
            MessageLookupByLibrary.simpleMessage("Ampliar"),
        "careEpisodeReportsWorkspace_expandEditor":
            MessageLookupByLibrary.simpleMessage(
                "Ampliar el área de redacción"),
        "careEpisodeReportsWorkspace_followUpNoteDefaultTitle":
            MessageLookupByLibrary.simpleMessage("Nota de seguimiento"),
        "careEpisodeReportsWorkspace_followUpNotes":
            MessageLookupByLibrary.simpleMessage("Notas de seguimiento"),
        "careEpisodeReportsWorkspace_followUpNotesLoadError":
            MessageLookupByLibrary.simpleMessage(
                "No se pueden cargar las notas de seguimiento."),
        "careEpisodeReportsWorkspace_include":
            MessageLookupByLibrary.simpleMessage("Incluir"),
        "careEpisodeReportsWorkspace_latestTests":
            MessageLookupByLibrary.simpleMessage(
                "Pruebas realizadas (último resultado)"),
        "careEpisodeReportsWorkspace_loading":
            MessageLookupByLibrary.simpleMessage("Cargando…"),
        "careEpisodeReportsWorkspace_moveToTrash":
            MessageLookupByLibrary.simpleMessage("Enviar a la papelera"),
        "careEpisodeReportsWorkspace_name":
            MessageLookupByLibrary.simpleMessage("Nombre"),
        "careEpisodeReportsWorkspace_newAssessment":
            MessageLookupByLibrary.simpleMessage("Balance (nuevo)"),
        "careEpisodeReportsWorkspace_noAssessments":
            MessageLookupByLibrary.simpleMessage(
                "No se ha registrado ningún balance."),
        "careEpisodeReportsWorkspace_noDocument":
            MessageLookupByLibrary.simpleMessage("No hay ningún documento"),
        "careEpisodeReportsWorkspace_noFollowUpNotes":
            MessageLookupByLibrary.simpleMessage(
                "No hay notas de seguimiento."),
        "careEpisodeReportsWorkspace_noReports":
            MessageLookupByLibrary.simpleMessage(
                "No hay informes registrados."),
        "careEpisodeReportsWorkspace_noTests":
            MessageLookupByLibrary.simpleMessage(
                "No se han realizado pruebas para este episodio."),
        "careEpisodeReportsWorkspace_notProvided":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "careEpisodeReportsWorkspace_note":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "careEpisodeReportsWorkspace_pathology":
            MessageLookupByLibrary.simpleMessage("Patología"),
        "careEpisodeReportsWorkspace_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapeuta de referencia"),
        "careEpisodeReportsWorkspace_referringPractitionerHistory":
            MessageLookupByLibrary.simpleMessage(
                "Historial de los fisioterapeutas de referencia"),
        "careEpisodeReportsWorkspace_report":
            MessageLookupByLibrary.simpleMessage("Informe"),
        "careEpisodeReportsWorkspace_reportCount":
            MessageLookupByLibrary.simpleMessage("Número de informes"),
        "careEpisodeReportsWorkspace_reportHistory":
            MessageLookupByLibrary.simpleMessage("Historial de informes"),
        "careEpisodeReportsWorkspace_reportsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "No se pueden cargar los informes."),
        "careEpisodeReportsWorkspace_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "careEpisodeReportsWorkspace_result":
            MessageLookupByLibrary.simpleMessage("Resultado"),
        "careEpisodeReportsWorkspace_returnToDraft":
            MessageLookupByLibrary.simpleMessage("Volver al borrador"),
        "careEpisodeReportsWorkspace_returnToReportDraft":
            MessageLookupByLibrary.simpleMessage(
                "Volver al borrador del informe"),
        "careEpisodeReportsWorkspace_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Guardar el balance"),
        "careEpisodeReportsWorkspace_saveReport":
            MessageLookupByLibrary.simpleMessage("Guardar el informe"),
        "careEpisodeReportsWorkspace_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Área de redacción del informe SOAP.\n\nS — Subjetivo\n\nO — Objetivo\n\nA — Análisis\n\nP — Plan"),
        "careEpisodeReportsWorkspace_test":
            MessageLookupByLibrary.simpleMessage("Prueba"),
        "careEpisodeReportsWorkspace_testCount":
            MessageLookupByLibrary.simpleMessage("Número de pruebas"),
        "careEpisodeReportsWorkspace_testsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "No se pueden cargar las pruebas."),
        "careEpisodeReportsWorkspace_title":
            MessageLookupByLibrary.simpleMessage("Título"),
        "careEpisodeReportsWorkspace_trashLoadError":
            MessageLookupByLibrary.simpleMessage(
                "No se puede cargar la papelera."),
        "careEpisodeReportsWorkspace_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Actualizar el balance"),
        "careEpisodeReportsWorkspace_updateReport":
            MessageLookupByLibrary.simpleMessage("Actualizar el informe"),
        "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "contactFormTemplateDiagnostic_category":
            MessageLookupByLibrary.simpleMessage("Categoría"),
        "contactFormTemplateDiagnostic_defaultTemplate":
            MessageLookupByLibrary.simpleMessage("Plantilla predeterminada"),
        "contactFormTemplateDiagnostic_error":
            MessageLookupByLibrary.simpleMessage("Error"),
        "contactFormTemplateDiagnostic_fields":
            MessageLookupByLibrary.simpleMessage("Campos"),
        "contactFormTemplateDiagnostic_no":
            MessageLookupByLibrary.simpleMessage("No"),
        "contactFormTemplateDiagnostic_noData":
            MessageLookupByLibrary.simpleMessage("No hay datos que mostrar."),
        "contactFormTemplateDiagnostic_noTemplate":
            MessageLookupByLibrary.simpleMessage(
                "No se ha encontrado ninguna plantilla de ficha de entrevista inicial."),
        "contactFormTemplateDiagnostic_notDefined":
            MessageLookupByLibrary.simpleMessage("Sin definir"),
        "contactFormTemplateDiagnostic_order":
            MessageLookupByLibrary.simpleMessage("Pedido"),
        "contactFormTemplateDiagnostic_practitioner":
            MessageLookupByLibrary.simpleMessage("Profesional"),
        "contactFormTemplateDiagnostic_refresh":
            MessageLookupByLibrary.simpleMessage("Actualizar"),
        "contactFormTemplateDiagnostic_required":
            MessageLookupByLibrary.simpleMessage("Obligatorio"),
        "contactFormTemplateDiagnostic_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Modelo de sistema"),
        "contactFormTemplateDiagnostic_templateId":
            MessageLookupByLibrary.simpleMessage("ID del modelo"),
        "contactFormTemplateDiagnostic_title":
            MessageLookupByLibrary.simpleMessage(
                "Ficha de diagnóstico y mantenimiento"),
        "contactFormTemplateDiagnostic_type":
            MessageLookupByLibrary.simpleMessage("Tipo"),
        "contactFormTemplateDiagnostic_yes":
            MessageLookupByLibrary.simpleMessage("Sí"),
        "dashboardTitle":
            MessageLookupByLibrary.simpleMessage("Centro clínico local ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Dirección"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Puerto"),
        "deviceForm_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Profesional asociado"),
        "deviceForm_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "deviceForm_contextName":
            MessageLookupByLibrary.simpleMessage("Nuevo dispositivo"),
        "deviceForm_create": MessageLookupByLibrary.simpleMessage("Crear"),
        "deviceForm_deviceName":
            MessageLookupByLibrary.simpleMessage("Nombre del dispositivo"),
        "deviceForm_deviceNameHint": MessageLookupByLibrary.simpleMessage(
            "El iPhone de Claire, el Pixel de Marc…"),
        "deviceForm_deviceNameRequired": MessageLookupByLibrary.simpleMessage(
            "Es obligatorio indicar el nombre del dispositivo"),
        "deviceForm_editDevice":
            MessageLookupByLibrary.simpleMessage("Cambiar el dispositivo"),
        "deviceForm_loadingPractitionersError":
            MessageLookupByLibrary.simpleMessage(
                "Error al cargar los profesionales"),
        "deviceForm_newDevice":
            MessageLookupByLibrary.simpleMessage("Nuevo aparato"),
        "deviceForm_platform":
            MessageLookupByLibrary.simpleMessage("Plataforma"),
        "deviceForm_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "deviceForm_sharedDevice": MessageLookupByLibrary.simpleMessage(
            "Ninguno / dispositivo compartido"),
        "deviceList_active": MessageLookupByLibrary.simpleMessage("Activos"),
        "deviceList_archive": MessageLookupByLibrary.simpleMessage("Archivar"),
        "deviceList_archiveConfirmation": m1,
        "deviceList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archivar el dispositivo"),
        "deviceList_archived":
            MessageLookupByLibrary.simpleMessage("Archivados"),
        "deviceList_archivedDevicesEmpty": MessageLookupByLibrary.simpleMessage(
            "La cesta de la compra está vacía por el momento."),
        "deviceList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archivado el"),
        "deviceList_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Profesional asociado"),
        "deviceList_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "deviceList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla muestra la lista de dispositivos conectados al centro"),
        "deviceList_contextName":
            MessageLookupByLibrary.simpleMessage("Lista de aparatos"),
        "deviceList_edit": MessageLookupByLibrary.simpleMessage("Modificar"),
        "deviceList_error": MessageLookupByLibrary.simpleMessage("Error"),
        "deviceList_newDevice":
            MessageLookupByLibrary.simpleMessage("Nuevo dispositivo"),
        "deviceList_noArchivedDevices": MessageLookupByLibrary.simpleMessage(
            "No hay dispositivos archivados"),
        "deviceList_noPairedDevices": MessageLookupByLibrary.simpleMessage(
            "No hay dispositivos asociados"),
        "deviceList_pairedDevicesExplanation":
            MessageLookupByLibrary.simpleMessage(
                "Aquí aparecerán los dispositivos ABAK asociados al centro."),
        "deviceList_platform":
            MessageLookupByLibrary.simpleMessage("Plataforma"),
        "deviceList_restore": MessageLookupByLibrary.simpleMessage("Restaurar"),
        "deviceList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Mostrar el código QR"),
        "deviceList_title":
            MessageLookupByLibrary.simpleMessage("Lista de aparatos"),
        "episodeDashboard_documents":
            MessageLookupByLibrary.simpleMessage("Documentos"),
        "episodeDashboard_documentsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Documentos relacionados con este episodio"),
        "episodeDashboard_forms":
            MessageLookupByLibrary.simpleMessage("Formularios"),
        "episodeDashboard_formsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Cuestionarios específicos de este episodio"),
        "episodeDashboard_notes": MessageLookupByLibrary.simpleMessage("Notas"),
        "episodeDashboard_notesDescription":
            MessageLookupByLibrary.simpleMessage(
                "Observaciones y comentarios del fisioterapeuta"),
        "episodeDashboard_report":
            MessageLookupByLibrary.simpleMessage("Informe"),
        "episodeDashboard_reportDescription":
            MessageLookupByLibrary.simpleMessage("Resumen del episodio"),
        "episodeDocuments_addDocument":
            MessageLookupByLibrary.simpleMessage("Añadir un documento"),
        "episodeDocuments_addError": MessageLookupByLibrary.simpleMessage(
            "No se puede añadir el documento"),
        "episodeDocuments_addedOn":
            MessageLookupByLibrary.simpleMessage("Añadido el"),
        "episodeDocuments_document":
            MessageLookupByLibrary.simpleMessage("Documento"),
        "episodeDocuments_documentAdded": MessageLookupByLibrary.simpleMessage(
            "El documento se ha añadido a la lista de documentos admitidos."),
        "episodeDocuments_emptyDescription": MessageLookupByLibrary.simpleMessage(
            "Puedes añadir un documento de texto, una hoja de cálculo, un PDF, una imagen o cualquier otro archivo que te resulte útil."),
        "episodeDocuments_fileNotFound": MessageLookupByLibrary.simpleMessage(
            "No se ha encontrado el archivo asociado."),
        "episodeDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Puedes asociar a esta función documentos creados con tus aplicaciones habituales: procesador de textos, hoja de cálculo, lector de PDF o programa de edición de imágenes.\n\nLos archivos añadidos se copian en el espacio de almacenamiento de Companion. Al hacer clic en un documento, este se abre con la aplicación correspondiente instalada en ese ordenador."),
        "episodeDocuments_image":
            MessageLookupByLibrary.simpleMessage("Imagen"),
        "episodeDocuments_loadError": MessageLookupByLibrary.simpleMessage(
            "No se pueden cargar los documentos relacionados."),
        "episodeDocuments_noDocument": MessageLookupByLibrary.simpleMessage(
            "No hay ningún documento asociado a esta gestión."),
        "episodeDocuments_openDocument":
            MessageLookupByLibrary.simpleMessage("Abrir el documento"),
        "episodeDocuments_openError": MessageLookupByLibrary.simpleMessage(
            "No se puede abrir el archivo"),
        "episodeDocuments_pdfDocument":
            MessageLookupByLibrary.simpleMessage("Documento PDF"),
        "episodeDocuments_platformNotSupported":
            MessageLookupByLibrary.simpleMessage(
                "Esta plataforma no admite la apertura."),
        "episodeDocuments_refresh":
            MessageLookupByLibrary.simpleMessage("Actualizar"),
        "episodeDocuments_spreadsheet":
            MessageLookupByLibrary.simpleMessage("Hoja de cálculo"),
        "episodeDocuments_textDocument":
            MessageLookupByLibrary.simpleMessage("Documento de texto"),
        "episodeDocuments_title": MessageLookupByLibrary.simpleMessage(
            "Documentación de la admisión"),
        "episodeEvolution_evaluation":
            MessageLookupByLibrary.simpleMessage("evaluación"),
        "episodeEvolution_evaluations":
            MessageLookupByLibrary.simpleMessage("valoraciones"),
        "episodeEvolution_first":
            MessageLookupByLibrary.simpleMessage("Estreno"),
        "episodeEvolution_followedExercises":
            MessageLookupByLibrary.simpleMessage("Ejercicios realizados"),
        "episodeEvolution_last": MessageLookupByLibrary.simpleMessage("Última"),
        "episodeEvolution_noResults": MessageLookupByLibrary.simpleMessage(
            "No hay resultados disponibles para este episodio."),
        "episodeEvolution_singleNumericValue":
            MessageLookupByLibrary.simpleMessage(
                "Solo hay un dato numérico disponible"),
        "episodeEvolution_title":
            MessageLookupByLibrary.simpleMessage("Desarrollo del episodio"),
        "episodeEvolution_viewEvolution":
            MessageLookupByLibrary.simpleMessage("Ver la evolución"),
        "episodeFormEditor_error":
            MessageLookupByLibrary.simpleMessage("Error"),
        "episodeFormEditor_noField":
            MessageLookupByLibrary.simpleMessage("No hay campos que mostrar."),
        "episodeFormEditor_requiredField": m2,
        "episodeFormEditor_save":
            MessageLookupByLibrary.simpleMessage("Guardar"),
        "episodeFormEditor_title":
            MessageLookupByLibrary.simpleMessage("Modificar el formulario"),
        "episodeForms_availableTemplates":
            MessageLookupByLibrary.simpleMessage("Modelos disponibles"),
        "episodeForms_category":
            MessageLookupByLibrary.simpleMessage("Categoría"),
        "episodeForms_completed":
            MessageLookupByLibrary.simpleMessage("completado"),
        "episodeForms_create": MessageLookupByLibrary.simpleMessage("Crear"),
        "episodeForms_createdForms":
            MessageLookupByLibrary.simpleMessage("Formularios creados"),
        "episodeForms_createdOn":
            MessageLookupByLibrary.simpleMessage("Creado el"),
        "episodeForms_customTemplate":
            MessageLookupByLibrary.simpleMessage("Modelo personalizado"),
        "episodeForms_error": MessageLookupByLibrary.simpleMessage("Error"),
        "episodeForms_form": MessageLookupByLibrary.simpleMessage("Formulario"),
        "episodeForms_inProgress":
            MessageLookupByLibrary.simpleMessage("en curso"),
        "episodeForms_noAvailableTemplate":
            MessageLookupByLibrary.simpleMessage(
                "No hay ningún modelo de formulario disponible."),
        "episodeForms_noCreatedForm": MessageLookupByLibrary.simpleMessage(
            "No se ha creado ningún formulario para este episodio."),
        "episodeForms_noData":
            MessageLookupByLibrary.simpleMessage("No hay datos que mostrar."),
        "episodeForms_refresh":
            MessageLookupByLibrary.simpleMessage("Actualizar"),
        "episodeForms_state": MessageLookupByLibrary.simpleMessage("Estado"),
        "episodeForms_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Modelo del sistema"),
        "episodeForms_title":
            MessageLookupByLibrary.simpleMessage("Formularios"),
        "episodeNotes_archive":
            MessageLookupByLibrary.simpleMessage("Archivar"),
        "episodeNotes_archiveConfirmation": m3,
        "episodeNotes_archiveTitle":
            MessageLookupByLibrary.simpleMessage("¿Archivar la nota?"),
        "episodeNotes_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "episodeNotes_content":
            MessageLookupByLibrary.simpleMessage("Contenido"),
        "episodeNotes_editNote":
            MessageLookupByLibrary.simpleMessage("Modificar la nota"),
        "episodeNotes_error": MessageLookupByLibrary.simpleMessage("Error"),
        "episodeNotes_modifiedOn":
            MessageLookupByLibrary.simpleMessage("Modificado el"),
        "episodeNotes_newNote":
            MessageLookupByLibrary.simpleMessage("Nueva nota"),
        "episodeNotes_noNote": MessageLookupByLibrary.simpleMessage(
            "No hay ninguna nota relacionada con este episodio."),
        "episodeNotes_noteTitle":
            MessageLookupByLibrary.simpleMessage("Título"),
        "episodeNotes_refresh":
            MessageLookupByLibrary.simpleMessage("Actualizar"),
        "episodeNotes_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "episodeNotes_title": MessageLookupByLibrary.simpleMessage("Notas"),
        "episodeNotes_titleRequired":
            MessageLookupByLibrary.simpleMessage("El título es obligatorio."),
        "episodeReport_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origen: ABAK"),
        "episodeReport_addConclusion":
            MessageLookupByLibrary.simpleMessage("Añadir una conclusión"),
        "episodeReport_clinicalConclusion":
            MessageLookupByLibrary.simpleMessage("Conclusión clínica"),
        "episodeReport_conclusionRequired":
            MessageLookupByLibrary.simpleMessage(
                "La conclusión no puede quedar en blanco."),
        "episodeReport_documents":
            MessageLookupByLibrary.simpleMessage("Documentos"),
        "episodeReport_dominantSide":
            MessageLookupByLibrary.simpleMessage("Lado dominante"),
        "episodeReport_editConclusion":
            MessageLookupByLibrary.simpleMessage("Modificar la conclusión"),
        "episodeReport_email":
            MessageLookupByLibrary.simpleMessage("Correo electrónico"),
        "episodeReport_error": MessageLookupByLibrary.simpleMessage("Error"),
        "episodeReport_forms":
            MessageLookupByLibrary.simpleMessage("Formularios"),
        "episodeReport_generatedPreview": MessageLookupByLibrary.simpleMessage(
            "Resumen del informe generado"),
        "episodeReport_generatingPreview": MessageLookupByLibrary.simpleMessage(
            "Generación de la vista previa del texto..."),
        "episodeReport_name": MessageLookupByLibrary.simpleMessage("Nombre"),
        "episodeReport_noConclusion": MessageLookupByLibrary.simpleMessage(
            "No se ha introducido ninguna conclusión."),
        "episodeReport_noData":
            MessageLookupByLibrary.simpleMessage("No hay datos que mostrar."),
        "episodeReport_noDocument": MessageLookupByLibrary.simpleMessage(
            "No hay documentos relacionados"),
        "episodeReport_noForm": MessageLookupByLibrary.simpleMessage(
            "No hay ningún formulario asociado"),
        "episodeReport_noNote":
            MessageLookupByLibrary.simpleMessage("No hay notas asociadas"),
        "episodeReport_noResult": MessageLookupByLibrary.simpleMessage(
            "No hay resultados relacionados"),
        "episodeReport_notProvided":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "episodeReport_notes": MessageLookupByLibrary.simpleMessage("Notas"),
        "episodeReport_patient":
            MessageLookupByLibrary.simpleMessage("Paciente"),
        "episodeReport_phone": MessageLookupByLibrary.simpleMessage("Teléfono"),
        "episodeReport_profession":
            MessageLookupByLibrary.simpleMessage("Profesión"),
        "episodeReport_refresh":
            MessageLookupByLibrary.simpleMessage("Actualizar"),
        "episodeReport_results":
            MessageLookupByLibrary.simpleMessage("Resultados de ABAK"),
        "episodeReport_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "episodeReport_score":
            MessageLookupByLibrary.simpleMessage("Puntuación"),
        "episodeReport_sportActivity":
            MessageLookupByLibrary.simpleMessage("Actividad deportiva"),
        "episodeReport_title": MessageLookupByLibrary.simpleMessage("Informe"),
        "episodeReport_unknownType":
            MessageLookupByLibrary.simpleMessage("Tipo desconocido"),
        "exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Carpeta de intercambio restablecida"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Expediente de intercambio de ABAK actualizado"),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Prefijo ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Comentario"),
        "g_context": MessageLookupByLibrary.simpleMessage("Contexto"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Copiar"),
        "g_file": MessageLookupByLibrary.simpleMessage("Archivo"),
        "g_learn_more": MessageLookupByLibrary.simpleMessage("Más información"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Información técnica"),
        "g_technical_informations_copied":
            MessageLookupByLibrary.simpleMessage("Información técnica copiada"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Los pacientes archivados pueden recuperarse hasta la fecha indicada.\nPasada esa fecha, se eliminan automáticamente para no conservar indefinidamente los expedientes que ya no se utilizan.\nEl periodo de conservación puede modificarse en la configuración de Companion."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "Puedes crear, modificar y archivar un dispositivo.\n\nPor motivos de trazabilidad, no es posible eliminar un dispositivo.\nSi es necesario, puedes restaurarlo.\n\nEl código QR se utiliza para emparejar un teléfono o una tableta."),
        "help_device_list_title":
            MessageLookupByLibrary.simpleMessage("Lista de dispositivos"),
        "help_donnees_cliniques_patient": MessageLookupByLibrary.simpleMessage(
            "Aquí encontrarás información adicional sobre tu paciente"),
        "help_home": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla es la pantalla principal de ABAK Companion.\n\nConsta de:\n\n1) una barra superior que te informa:\n - del número de pacientes activos y archivados.\n  - del número de alertas activas.\n\nEn los ajustes, puede introducir el nombre de su centro y añadir su logotipo.\n\n2) «Importaciones recientes» le muestra los últimos expedientes de resultados importados desde ABAK Mobile.\n\n3) «Estado del sistema» le indica si hay algún problema y la fecha de la última copia de seguridad.\n\n4) «Nuevos resultados de ABAK para asociar» te muestra los resultados que se han enviado desde ABAK Mobile pero que aún no se han asignado a ningún paciente en ABAK Companion.\n\n5) «Alerta del sistema» te informa sobre la naturaleza de un posible problema.\n\n6) «Acción rápida» le permite acceder al historial de todas sus importaciones y crear una nueva copia de seguridad."),
        "help_home_active_archived_patients_content":
            MessageLookupByLibrary.simpleMessage("Los pacientes activos"),
        "help_home_active_archived_patients_title":
            MessageLookupByLibrary.simpleMessage(
                "Pacientes activos y archivados"),
        "help_home_import_assignment_content":
            MessageLookupByLibrary.simpleMessage(
                "Una vez que hayas terminado el ejercicio en ABAK Mobile..."),
        "help_home_import_assignment_title":
            MessageLookupByLibrary.simpleMessage(
                "Recuperación de un resultado y su asignación a un paciente"),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Aquí encontrarás los datos de identificación de tu paciente"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla permite:\n - Seleccionar el idioma.\n - Definir el plazo de conservación de los historiales clínicos archivados.\n - Activar el modo experto.\n - Acceder a la pantalla «Centro» para introducir el nombre de su centro y su logotipo"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla te permite añadir un nuevo profesional sanitario y modificar sus datos.\n\nAl enviarlo a la papelera no se elimina al profesional sanitario. Por motivos de trazabilidad, no es posible eliminar a un profesional sanitario.\n\nAl mostrar el código QR, podrás crear automáticamente el perfil del profesional sanitario para tu centro en su teléfono o tableta."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Aquí encontrará los distintos tratamientos de su paciente. Puede utilizar un episodio ya existente o crear uno nuevo."),
        "homeImportSummary_conflicts":
            MessageLookupByLibrary.simpleMessage("Conflictos"),
        "homeImportSummary_failedFiles":
            MessageLookupByLibrary.simpleMessage("Archivos con errores"),
        "homeImportSummary_importDate":
            MessageLookupByLibrary.simpleMessage("Importación de datos"),
        "homeImportSummary_importedMetrics":
            MessageLookupByLibrary.simpleMessage("Métricas importadas"),
        "homeImportSummary_importedResults":
            MessageLookupByLibrary.simpleMessage("Resultados importados"),
        "homeImportSummary_open": MessageLookupByLibrary.simpleMessage("Abrir"),
        "homeImportSummary_patients":
            MessageLookupByLibrary.simpleMessage("Pacientes afectados"),
        "homeImportSummary_processedFiles":
            MessageLookupByLibrary.simpleMessage("Archivos procesados"),
        "homeImportSummary_skippedResults":
            MessageLookupByLibrary.simpleMessage("Resultados ignorados"),
        "homeImportSummary_title":
            MessageLookupByLibrary.simpleMessage("Última importación de ABAK"),
        "home_abak_exercice":
            MessageLookupByLibrary.simpleMessage("Ejercicio ABAK"),
        "home_abak_file": MessageLookupByLibrary.simpleMessage("Archivo ABAK"),
        "home_accueil": MessageLookupByLibrary.simpleMessage("Inicio"),
        "home_action_required": MessageLookupByLibrary.simpleMessage(
            "Acción necesaria: asociar este expediente a un paciente."),
        "home_already_imported":
            MessageLookupByLibrary.simpleMessage("Ya importado"),
        "home_an_intervention_is_necessary":
            MessageLookupByLibrary.simpleMessage("Es necesario intervenir"),
        "home_archives": MessageLookupByLibrary.simpleMessage("Archivos"),
        "home_attention": MessageLookupByLibrary.simpleMessage("Atención"),
        "home_backup_successfully_created":
            MessageLookupByLibrary.simpleMessage(
                "La copia de seguridad se ha creado correctamente."),
        "home_balance_sheet_date":
            MessageLookupByLibrary.simpleMessage("Fecha del balance"),
        "home_conflict_detected": MessageLookupByLibrary.simpleMessage(
            "Se ha detectado un conflicto"),
        "home_create_a_backup": MessageLookupByLibrary.simpleMessage(
            "Crear una copia de seguridad"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Fecha no indicada"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Aparatos"),
        "home_error_while_saving": m4,
        "home_everything_is_working_normally":
            MessageLookupByLibrary.simpleMessage(
                "Todo funciona con normalidad"),
        "home_expert_comment": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla es la pantalla principal de Companion."),
        "home_failure": MessageLookupByLibrary.simpleMessage("Fracaso"),
        "home_fermer": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "home_file": MessageLookupByLibrary.simpleMessage("Archivo"),
        "home_historique": MessageLookupByLibrary.simpleMessage("Historia"),
        "home_home": MessageLookupByLibrary.simpleMessage("Inicio"),
        "home_import_history":
            MessageLookupByLibrary.simpleMessage("Historial de importaciones"),
        "home_imports_interrupted_or_in_progress":
            MessageLookupByLibrary.simpleMessage(
                "Importaciones interrumpidas o en curso"),
        "home_imports_with_errors":
            MessageLookupByLibrary.simpleMessage("Importaciones erróneas"),
        "home_information": MessageLookupByLibrary.simpleMessage("Acerca de"),
        "home_invalid_file_path":
            MessageLookupByLibrary.simpleMessage("Ruta del archivo no válida:"),
        "home_ipAddressNotFound": MessageLookupByLibrary.simpleMessage(
            "No se ha encontrado la dirección IP"),
        "home_ipAddressNotFoundMessage": MessageLookupByLibrary.simpleMessage(
            "No se puede determinar la dirección IP local del ordenador de sobremesa.\n\nComprueba que el ordenador esté conectado a la red local."),
        "home_large_number_of_archived_patients":
            MessageLookupByLibrary.simpleMessage(
                "Un número considerable de pacientes archivados"),
        "home_large_sqlite_database": MessageLookupByLibrary.simpleMessage(
            "Base de datos SQLite de gran tamaño"),
        "home_last_backup":
            MessageLookupByLibrary.simpleMessage("Última copia de seguridad"),
        "home_last_old_backup": MessageLookupByLibrary.simpleMessage(
            "Última copia de seguridad anterior"),
        "home_link_to_a_care_plan": MessageLookupByLibrary.simpleMessage(
            "Incorporar a un plan de tratamiento"),
        "home_more_7_days":
            MessageLookupByLibrary.simpleMessage("Más de 7 días"),
        "home_new_abak_results_to_be_linked":
            MessageLookupByLibrary.simpleMessage(
                "Nuevos resultados de ABAK que hay que asociar a un paciente"),
        "home_no_abak_result_to_associate":
            MessageLookupByLibrary.simpleMessage(
                "No hay resultados de ABAK que se puedan asociar."),
        "home_no_alert_detected": MessageLookupByLibrary.simpleMessage(
            "No se ha detectado ninguna alerta"),
        "home_no_imports_recorded": MessageLookupByLibrary.simpleMessage(
            "No hay importaciones registradas."),
        "home_no_pending_imports": MessageLookupByLibrary.simpleMessage(
            "No hay importaciones pendientes"),
        "home_no_saved_backup": MessageLookupByLibrary.simpleMessage(
            "No hay ninguna copia de seguridad guardada"),
        "home_not_specified": MessageLookupByLibrary.simpleMessage("informada"),
        "home_octets": MessageLookupByLibrary.simpleMessage("Octetos"),
        "home_other_exercises": m5,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Parámetros"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Camino"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Paciente ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Pacientes"),
        "home_pending_association": m6,
        "home_practitioners":
            MessageLookupByLibrary.simpleMessage("profesionales"),
        "home_quick_actions":
            MessageLookupByLibrary.simpleMessage("Acciones rápidas"),
        "home_receents_imports":
            MessageLookupByLibrary.simpleMessage("Importaciones recientes"),
        "home_recent_restoration_detected":
            MessageLookupByLibrary.simpleMessage(
                "Se ha detectado una restauración reciente"),
        "home_results": MessageLookupByLibrary.simpleMessage("Resultados"),
        "home_select_qr_code": MessageLookupByLibrary.simpleMessage(
            "Escanea este código QR desde ABAK Mobile para configurar automáticamente la conexión con Desktop."),
        "home_settings": MessageLookupByLibrary.simpleMessage("Asistencia"),
        "home_size": MessageLookupByLibrary.simpleMessage("Talla"),
        "home_solve": MessageLookupByLibrary.simpleMessage("Resolver"),
        "home_success": MessageLookupByLibrary.simpleMessage("Éxito"),
        "home_system_alert":
            MessageLookupByLibrary.simpleMessage("Alerta del sistema"),
        "home_system_status":
            MessageLookupByLibrary.simpleMessage("Estado del sistema"),
        "home_technical_information":
            MessageLookupByLibrary.simpleMessage("Información técnica"),
        "home_this_file_had_already_been_imported":
            MessageLookupByLibrary.simpleMessage(
                "Este archivo ya se había importado. No se han añadido datos."),
        "home_to_be_verified":
            MessageLookupByLibrary.simpleMessage("por verificar"),
        "home_to_do_list":
            MessageLookupByLibrary.simpleMessage("Tareas pendientes"),
        "home_unable_to_load_recent_imports":
            MessageLookupByLibrary.simpleMessage(
                "No se pueden cargar las importaciones recientes."),
        "home_unreadable_abak_import":
            MessageLookupByLibrary.simpleMessage("Importación ABAK ilegible."),
        "home_unsuccessful": MessageLookupByLibrary.simpleMessage("En jaque"),
        "home_verify": MessageLookupByLibrary.simpleMessage("Comprobar"),
        "home_very_large_backups": MessageLookupByLibrary.simpleMessage(
            "Copias de seguridad de gran tamaño"),
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("archivo"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("archivos"),
        "importResolutionAssistant_import":
            MessageLookupByLibrary.simpleMessage("Importar"),
        "importResolutionAssistant_importFailed":
            MessageLookupByLibrary.simpleMessage("Importación fallida"),
        "importResolutionAssistant_importToComplete":
            MessageLookupByLibrary.simpleMessage(
                "Importación pendiente de finalizar"),
        "importResolutionAssistant_importToReview":
            MessageLookupByLibrary.simpleMessage(
                "Importación pendiente de verificación"),
        "importResolutionAssistant_inError":
            MessageLookupByLibrary.simpleMessage("por error"),
        "importResolutionAssistant_interventionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Es necesaria una intervención para finalizar esta importación."),
        "importResolutionAssistant_loadingError":
            MessageLookupByLibrary.simpleMessage(
                "No se pueden cargar las importaciones"),
        "importResolutionAssistant_noProblem":
            MessageLookupByLibrary.simpleMessage(
                "No se ha detectado ningún problema con la importación."),
        "importResolutionAssistant_result":
            MessageLookupByLibrary.simpleMessage("resultado"),
        "importResolutionAssistant_results":
            MessageLookupByLibrary.simpleMessage("resultados"),
        "importResolutionAssistant_selectImportInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Selecciona una importación para ver sus detalles y sigue los pasos indicados."),
        "importResolutionAssistant_title": MessageLookupByLibrary.simpleMessage(
            "Resolución de problemas de importación"),
        "importResolutionAssistant_toReview":
            MessageLookupByLibrary.simpleMessage("por verificar"),
        "information_backupCount": m7,
        "information_backups":
            MessageLookupByLibrary.simpleMessage("Copias de seguridad"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Configurado"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "En esta pantalla se muestra la información general, técnica y legal de Companion."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Información"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Base de datos"),
        "information_language": MessageLookupByLibrary.simpleMessage("Idioma"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Aviso legal"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Cargando..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Almacenamiento local"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("No configurado"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "information_office": MessageLookupByLibrary.simpleMessage("Despacho"),
        "information_size": m8,
        "information_system": MessageLookupByLibrary.simpleMessage("Sistema"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Información"),
        "information_totalSize": m9,
        "information_version": m10,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Versión..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("Consultar la licencia"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Idioma guardado."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Idioma de la aplicación"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Advertencia"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion es un programa informático diseñado para facilitar la organización, la importación y la consulta de resultados clínicos procedentes del ecosistema ABAK.\n\nNo es un producto sanitario certificado y no sustituye al criterio del profesional sanitario.\n\nLos resultados, puntuaciones, informes e indicadores mostrados deben ser interpretados siempre por un profesional cualificado, teniendo en cuenta la exploración clínica, el contexto del paciente y las recomendaciones vigentes.\n\nEl usuario es el único responsable de sus decisiones clínicas, de la verificación de los datos importados y de que su uso se ajuste a las normas profesionales, reglamentarias y deontológicas aplicables.\n\nABAK Desktop Companion no realiza diagnósticos de forma autónoma, no prescribe ningún tratamiento y no sustituye en ningún caso a una consulta médica o paramédica."),
        "legalNotice_title":
            MessageLookupByLibrary.simpleMessage("Aviso legal"),
        "loading": MessageLookupByLibrary.simpleMessage("Cargando..."),
        "localDatabaseBackup_cancelled": MessageLookupByLibrary.simpleMessage(
            "Copia de seguridad cancelada."),
        "localDatabaseBackup_chooseBackupFolder":
            MessageLookupByLibrary.simpleMessage(
                "Seleccionar la carpeta de copia de seguridad de ABAK"),
        "localDatabaseBackup_databaseNotFound":
            MessageLookupByLibrary.simpleMessage(
                "No se ha encontrado la base de datos SQLite."),
        "localDatabaseReset_backupFailed": MessageLookupByLibrary.simpleMessage(
            "No es posible realizar una copia de seguridad previa"),
        "main_alreadyRunningMessage": MessageLookupByLibrary.simpleMessage(
            "Solo se puede tener una instancia abierta a la vez.\n\nUtiliza la ventana Companion que ya tengas abierta."),
        "main_alreadyRunningTitle": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion ya está abierto"),
        "main_close": MessageLookupByLibrary.simpleMessage(""),
        "modify": MessageLookupByLibrary.simpleMessage("Editar"),
        "noDirectoryDefined": MessageLookupByLibrary.simpleMessage(
            "No se ha definido ninguna carpeta"),
        "ok": MessageLookupByLibrary.simpleMessage("De acuerdo"),
        "open": MessageLookupByLibrary.simpleMessage("Abrir"),
        "organization_chooseLogo":
            MessageLookupByLibrary.simpleMessage("Elegir un logotipo"),
        "organization_identityTitle":
            MessageLookupByLibrary.simpleMessage("Identidad del centro"),
        "organization_logoRemoved": MessageLookupByLibrary.simpleMessage(
            "Se ha eliminado el logotipo del centro."),
        "organization_logoSaved": MessageLookupByLibrary.simpleMessage(
            "Logotipo del centro registrado."),
        "organization_nameLabel":
            MessageLookupByLibrary.simpleMessage("Nombre del centro"),
        "organization_nameSaved": MessageLookupByLibrary.simpleMessage(
            "Nombre del centro registrado."),
        "organization_removeLogo":
            MessageLookupByLibrary.simpleMessage("Eliminar el logotipo"),
        "organization_saveName":
            MessageLookupByLibrary.simpleMessage("Guardar el nombre"),
        "organization_title":
            MessageLookupByLibrary.simpleMessage("Establecimiento"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Vincular un teléfono"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Vincular un teléfono"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Escanea este código QR desde ABAK Mobile para configurar automáticamente la conexión con Desktop."),
        "patientClinicalDataEdit_address":
            MessageLookupByLibrary.simpleMessage("Dirección"),
        "patientClinicalDataEdit_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Identidad administrativa"),
        "patientClinicalDataEdit_ambidextrous":
            MessageLookupByLibrary.simpleMessage("Ambidiestro"),
        "patientClinicalDataEdit_centimeters":
            MessageLookupByLibrary.simpleMessage("En centímetros"),
        "patientClinicalDataEdit_dominantSide":
            MessageLookupByLibrary.simpleMessage("Lado dominante"),
        "patientClinicalDataEdit_email":
            MessageLookupByLibrary.simpleMessage("Correo electrónico"),
        "patientClinicalDataEdit_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage(
                "Países con este sistema sanitario"),
        "patientClinicalDataEdit_height":
            MessageLookupByLibrary.simpleMessage("Talla"),
        "patientClinicalDataEdit_identitySource":
            MessageLookupByLibrary.simpleMessage("Fuente de la identidad"),
        "patientClinicalDataEdit_kilograms":
            MessageLookupByLibrary.simpleMessage("En kilogramos"),
        "patientClinicalDataEdit_left":
            MessageLookupByLibrary.simpleMessage("Izquierda"),
        "patientClinicalDataEdit_manualEntry":
            MessageLookupByLibrary.simpleMessage("Introducción manual"),
        "patientClinicalDataEdit_nationalHealthId":
            MessageLookupByLibrary.simpleMessage(
                "Identificador nacional de salud"),
        "patientClinicalDataEdit_nationalHealthIdHelper":
            MessageLookupByLibrary.simpleMessage(
                "Ejemplo de Francia: número de la Seguridad Social"),
        "patientClinicalDataEdit_patientProfile":
            MessageLookupByLibrary.simpleMessage("Perfil del paciente"),
        "patientClinicalDataEdit_phone":
            MessageLookupByLibrary.simpleMessage("Teléfono"),
        "patientClinicalDataEdit_profession":
            MessageLookupByLibrary.simpleMessage("Profesión"),
        "patientClinicalDataEdit_right":
            MessageLookupByLibrary.simpleMessage("Derecha"),
        "patientClinicalDataEdit_save":
            MessageLookupByLibrary.simpleMessage("Guardar"),
        "patientClinicalDataEdit_sportActivity":
            MessageLookupByLibrary.simpleMessage(
                "Actividad deportiva habitual"),
        "patientClinicalDataEdit_title": MessageLookupByLibrary.simpleMessage(
            "Modificar los datos clínicos"),
        "patientClinicalDataEdit_unspecified":
            MessageLookupByLibrary.simpleMessage("Sin especificar"),
        "patientClinicalDataEdit_vitaleCard":
            MessageLookupByLibrary.simpleMessage("Tarjeta sanitaria"),
        "patientClinicalDataEdit_weight":
            MessageLookupByLibrary.simpleMessage("Peso"),
        "patientDetail_address":
            MessageLookupByLibrary.simpleMessage("Dirección"),
        "patientDetail_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Identidad administrativa"),
        "patientDetail_archived":
            MessageLookupByLibrary.simpleMessage("archivado"),
        "patientDetail_bornOn":
            MessageLookupByLibrary.simpleMessage("Ni(a) las"),
        "patientDetail_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "patientDetail_careEpisodeOpenedIn":
            MessageLookupByLibrary.simpleMessage("Atención abierta en"),
        "patientDetail_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Coberturas"),
        "patientDetail_create": MessageLookupByLibrary.simpleMessage("Crear"),
        "patientDetail_dominantSide":
            MessageLookupByLibrary.simpleMessage("Lado dominante"),
        "patientDetail_edit": MessageLookupByLibrary.simpleMessage("Modificar"),
        "patientDetail_editCareEpisode":
            MessageLookupByLibrary.simpleMessage("Modificar la cobertura"),
        "patientDetail_editClinicalData": MessageLookupByLibrary.simpleMessage(
            "Modificar los datos clínicos"),
        "patientDetail_email":
            MessageLookupByLibrary.simpleMessage("Correo electrónico"),
        "patientDetail_error": MessageLookupByLibrary.simpleMessage("Error"),
        "patientDetail_frHealthIdentity": MessageLookupByLibrary.simpleMessage(
            "Identidad sanitaria — Francia"),
        "patientDetail_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage(
                "Países con sistema sanitario"),
        "patientDetail_height": MessageLookupByLibrary.simpleMessage("Talla"),
        "patientDetail_identitySource":
            MessageLookupByLibrary.simpleMessage("Fuente de identidad"),
        "patientDetail_initialReport":
            MessageLookupByLibrary.simpleMessage("Informe inicial"),
        "patientDetail_nationalIdentifier":
            MessageLookupByLibrary.simpleMessage(
                "Número de identificación nacional"),
        "patientDetail_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Nueva cobertura"),
        "patientDetail_noBirthdate":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "patientDetail_noCareEpisode": MessageLookupByLibrary.simpleMessage(
            "No se ha creado ningún caso clínico para este paciente."),
        "patientDetail_notProvided":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "patientDetail_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "patientDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Patología"),
        "patientDetail_patientInformation":
            MessageLookupByLibrary.simpleMessage(
                "Información para el paciente"),
        "patientDetail_patientProfile":
            MessageLookupByLibrary.simpleMessage("Perfil del paciente"),
        "patientDetail_phone": MessageLookupByLibrary.simpleMessage("Teléfono"),
        "patientDetail_profession":
            MessageLookupByLibrary.simpleMessage("Profesión"),
        "patientDetail_provisional":
            MessageLookupByLibrary.simpleMessage("Provisional"),
        "patientDetail_provisionalDescription":
            MessageLookupByLibrary.simpleMessage(
                "Datos personales por completar"),
        "patientDetail_qualified":
            MessageLookupByLibrary.simpleMessage("Clasificada"),
        "patientDetail_qualifiedDescription":
            MessageLookupByLibrary.simpleMessage("Identidad válida"),
        "patientDetail_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapeuta de referencia"),
        "patientDetail_retrieved":
            MessageLookupByLibrary.simpleMessage("Recuperada"),
        "patientDetail_retrievedDescription": MessageLookupByLibrary.simpleMessage(
            "Número de identificación fiscal obtenido, hay que comprobar la identidad"),
        "patientDetail_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "patientDetail_sex": MessageLookupByLibrary.simpleMessage("Sexo"),
        "patientDetail_sportActivity":
            MessageLookupByLibrary.simpleMessage("Actividad deportiva"),
        "patientDetail_state": MessageLookupByLibrary.simpleMessage("Estado"),
        "patientDetail_status":
            MessageLookupByLibrary.simpleMessage("Estatuto"),
        "patientDetail_validated":
            MessageLookupByLibrary.simpleMessage("Validada"),
        "patientDetail_validatedDescription":
            MessageLookupByLibrary.simpleMessage(
                "Identidad comprobada, hay que buscar el INS"),
        "patientDetail_weight": MessageLookupByLibrary.simpleMessage("Peso"),
        "patientDetail_years": MessageLookupByLibrary.simpleMessage("años"),
        "patientForm_birthDate":
            MessageLookupByLibrary.simpleMessage("Fecha de nacimiento"),
        "patientForm_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "patientForm_create": MessageLookupByLibrary.simpleMessage("Crear"),
        "patientForm_editPatient":
            MessageLookupByLibrary.simpleMessage("Modificar el paciente"),
        "patientForm_female": MessageLookupByLibrary.simpleMessage("Mujer"),
        "patientForm_firstName": MessageLookupByLibrary.simpleMessage("Nombre"),
        "patientForm_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("El nombre es obligatorio"),
        "patientForm_lastName": MessageLookupByLibrary.simpleMessage("Nombre"),
        "patientForm_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("El nombre es obligatorio"),
        "patientForm_male": MessageLookupByLibrary.simpleMessage("Hombre"),
        "patientForm_newPatient":
            MessageLookupByLibrary.simpleMessage("Paciente nuevo"),
        "patientForm_other": MessageLookupByLibrary.simpleMessage("Otros"),
        "patientForm_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "patientForm_sex": MessageLookupByLibrary.simpleMessage("Sexo"),
        "patientForm_unspecified":
            MessageLookupByLibrary.simpleMessage("Sin especificar"),
        "patientList_active": MessageLookupByLibrary.simpleMessage("Activos"),
        "patientList_archive": MessageLookupByLibrary.simpleMessage("Archivar"),
        "patientList_archiveConfirmation": m11,
        "patientList_archiveSuccess": m12,
        "patientList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archivar al paciente"),
        "patientList_archived":
            MessageLookupByLibrary.simpleMessage("Archivados"),
        "patientList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archivado el"),
        "patientList_archivedPatient":
            MessageLookupByLibrary.simpleMessage("Paciente dado de baja"),
        "patientList_archivedPatientsEmpty":
            MessageLookupByLibrary.simpleMessage(
                "La papelera de los pacientes está vacía por el momento."),
        "patientList_bornOn": MessageLookupByLibrary.simpleMessage("Ni(a) las"),
        "patientList_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "patientList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Puedes ver la lista de pacientes activos y los archivados"),
        "patientList_contextName":
            MessageLookupByLibrary.simpleMessage("Lista de pacientes"),
        "patientList_edit": MessageLookupByLibrary.simpleMessage("Modificar"),
        "patientList_error": m13,
        "patientList_newPatient":
            MessageLookupByLibrary.simpleMessage("Paciente nuevo"),
        "patientList_noArchivedPatients":
            MessageLookupByLibrary.simpleMessage("No hay pacientes archivados"),
        "patientList_noPatientFound": MessageLookupByLibrary.simpleMessage(
            "No se ha encontrado ningún paciente"),
        "patientList_noRegisteredPatients":
            MessageLookupByLibrary.simpleMessage(
                "No hay ningún paciente registrado"),
        "patientList_patientFileEmpty": MessageLookupByLibrary.simpleMessage(
            "El archivo local del paciente está vacío por el momento."),
        "patientList_restorableUntil":
            MessageLookupByLibrary.simpleMessage("Se puede restaurar hasta el"),
        "patientList_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "patientList_restoreSuccess": m14,
        "patientList_searchPatient":
            MessageLookupByLibrary.simpleMessage("Buscar un paciente"),
        "patientList_sex": MessageLookupByLibrary.simpleMessage("Sexo"),
        "patientList_title":
            MessageLookupByLibrary.simpleMessage("Lista de pacientes"),
        "patientNew_archivedMatchToReview":
            MessageLookupByLibrary.simpleMessage(
                "Correo archivado pendiente de revisión"),
        "patientNew_archivedMatchToReviewMessage":
            MessageLookupByLibrary.simpleMessage(
                "Ya existe un paciente archivado con el mismo nombre, apellidos y fecha de nacimiento, pero sus datos administrativos son diferentes.\n\nNo se llevará a cabo ninguna recuperación automática. Comprueba los expedientes antes de continuar."),
        "patientNew_archivedPatientFound": MessageLookupByLibrary.simpleMessage(
            "Paciente encontrado en los archivos"),
        "patientNew_archivedPatientMatch": MessageLookupByLibrary.simpleMessage(
            "Esta Tarjeta Vitale corresponde al paciente dado de baja:"),
        "patientNew_attach": MessageLookupByLibrary.simpleMessage("Vincular"),
        "patientNew_attachVitaleError": MessageLookupByLibrary.simpleMessage(
            "No se puede vincular la Tarjeta Vitale"),
        "patientNew_attachVitaleQuestion": MessageLookupByLibrary.simpleMessage(
            "¿Desea vincular los datos de la Tarjeta Sanitaria a este paciente?"),
        "patientNew_attachVitaleSuccess": m15,
        "patientNew_backToList":
            MessageLookupByLibrary.simpleMessage("Volver a la lista"),
        "patientNew_birthDate":
            MessageLookupByLibrary.simpleMessage("Fecha de nacimiento"),
        "patientNew_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "patientNew_choosePatient":
            MessageLookupByLibrary.simpleMessage("Elegir al paciente"),
        "patientNew_close": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "patientNew_contextComment": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla permite crear un nuevo paciente introduciendo los datos manualmente o leyendo la tarjeta sanitaria."),
        "patientNew_contextName":
            MessageLookupByLibrary.simpleMessage("Paciente nuevo"),
        "patientNew_createError":
            MessageLookupByLibrary.simpleMessage("Error al crear el paciente"),
        "patientNew_createPatient":
            MessageLookupByLibrary.simpleMessage("Crear el paciente"),
        "patientNew_creating":
            MessageLookupByLibrary.simpleMessage("Creación..."),
        "patientNew_download":
            MessageLookupByLibrary.simpleMessage("Descargar"),
        "patientNew_existingPatientTitle":
            MessageLookupByLibrary.simpleMessage("¿Ya eres paciente nuestro?"),
        "patientNew_female": MessageLookupByLibrary.simpleMessage("Femenino"),
        "patientNew_firstName": MessageLookupByLibrary.simpleMessage("Nombre"),
        "patientNew_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("El nombre es obligatorio"),
        "patientNew_lastName": MessageLookupByLibrary.simpleMessage("Nombre"),
        "patientNew_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("El nombre es obligatorio"),
        "patientNew_male": MessageLookupByLibrary.simpleMessage("Masculino"),
        "patientNew_matchToReview": MessageLookupByLibrary.simpleMessage(
            "Correspondencia que hay que comprobar"),
        "patientNew_matchToReviewMessage": MessageLookupByLibrary.simpleMessage(
            "Ya existe un paciente con el mismo nombre, apellidos y fecha de nacimiento.\n\nLos datos administrativos no coinciden del todo. Comprueba el expediente antes de continuar."),
        "patientNew_matchingPatientFound": MessageLookupByLibrary.simpleMessage(
            "Se ha encontrado un paciente que coincide:"),
        "patientNew_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "patientNew_nirDetectedProtected":
            MessageLookupByLibrary.simpleMessage("detectado y protegido"),
        "patientNew_nirUnavailable":
            MessageLookupByLibrary.simpleMessage("no disponible"),
        "patientNew_no": MessageLookupByLibrary.simpleMessage("No"),
        "patientNew_noNewPatientCreated": MessageLookupByLibrary.simpleMessage(
            "No se creará ningún paciente nuevo."),
        "patientNew_notProvided":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "patientNew_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("sin datos"),
        "patientNew_other": MessageLookupByLibrary.simpleMessage("Otros"),
        "patientNew_patientAlreadyRegistered":
            MessageLookupByLibrary.simpleMessage("Paciente ya registrado"),
        "patientNew_patientIdentity":
            MessageLookupByLibrary.simpleMessage("Datos del paciente"),
        "patientNew_readOn":
            MessageLookupByLibrary.simpleMessage("Lectura realizada el"),
        "patientNew_readVitale":
            MessageLookupByLibrary.simpleMessage("Leer la Tarjeta Vitale"),
        "patientNew_readerNotDetected": MessageLookupByLibrary.simpleMessage(
            "No se ha detectado el lector de la tarjeta sanitaria"),
        "patientNew_readerNotDetectedMessage": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion no ha detectado ningún lector de Carte Vitale.\n\nPara utilizar esta función, debes disponer de:\n\n• un lector de Carte Vitale compatible con PC/SC, normalmente conectado por USB;\n• el módulo ABAK Carte Vitale, que se proporciona de forma gratuita. Consulte la página web abak.care.\n\nUna vez conectado el lector, vuelva a hacer clic en «Leer Tarjeta Vitale»."),
        "patientNew_reading":
            MessageLookupByLibrary.simpleMessage("Se está leyendo..."),
        "patientNew_restore": MessageLookupByLibrary.simpleMessage("Restaurar"),
        "patientNew_restoreError": MessageLookupByLibrary.simpleMessage(
            "No es posible reanimar al paciente"),
        "patientNew_restoreInsteadOfCreate": MessageLookupByLibrary.simpleMessage(
            "¿Prefieres recuperar este expediente en lugar de crear uno nuevo para este paciente?"),
        "patientNew_restoreSuccess": m16,
        "patientNew_sex": MessageLookupByLibrary.simpleMessage("Sexo"),
        "patientNew_vitaleIdentityRead": MessageLookupByLibrary.simpleMessage(
            "Identidad leída desde la Tarjeta Sanitaria"),
        "patientNew_vitaleMatchesPatient": MessageLookupByLibrary.simpleMessage(
            "Esta Tarjeta Vitale corresponde al paciente:"),
        "patientNew_vitaleModuleConfigurationError":
            MessageLookupByLibrary.simpleMessage(
                "La configuración del módulo «Carte Vitale» no está presente o es incorrecta. Vuelve a instalar el módulo y vuelve a intentarlo."),
        "patientNew_vitaleModuleNotInstalled":
            MessageLookupByLibrary.simpleMessage(
                "El módulo de la Tarjeta Sanitaria no está instalado"),
        "patientNew_vitaleModuleNotInstalledMessage":
            MessageLookupByLibrary.simpleMessage(
                "El módulo ABAK Carte Vitale no está instalado en este ordenador.\n\nPuede descargarlo de forma gratuita desde la página web de ABAK."),
        "patientNew_vitalePrefilled": MessageLookupByLibrary.simpleMessage(
            "Datos del paciente prellenados a partir de la Tarjeta Vitale."),
        "patientNew_vitaleReadFailed": MessageLookupByLibrary.simpleMessage(
            "No se ha podido leer la Tarjeta Sanitaria."),
        "practitionerList_active":
            MessageLookupByLibrary.simpleMessage("Activos"),
        "practitionerList_addPractitionersHint":
            MessageLookupByLibrary.simpleMessage(
                "Añade a los fisioterapeutas de la consulta para identificar las pruebas importadas."),
        "practitionerList_archive":
            MessageLookupByLibrary.simpleMessage("Archivar"),
        "practitionerList_archiveConfirmation": m17,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "La papelera de los fisioterapeutas está vacía por el momento."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage("Archivar al fisioterapeuta"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archivados"),
        "practitionerList_archivedOn": m18,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Crear un profesional"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla muestra la lista de profesionales sanitarios registrados."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("Lista de profesionales"),
        "practitionerList_edit":
            MessageLookupByLibrary.simpleMessage("Modificar"),
        "practitionerList_error": m19,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "No hay fisioterapeutas archivados"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "No hay fisioterapeutas registrados"),
        "practitionerList_professionalId": m20,
        "practitionerList_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "practitionerList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Mostrar el código QR"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Lista de profesionales"),
        "practitionerNew_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "practitionerNew_cet_ecran_permet":
            MessageLookupByLibrary.simpleMessage(
                "Esta pantalla permite crear un profesional sanitario."),
        "practitionerNew_create": MessageLookupByLibrary.simpleMessage("Crear"),
        "practitionerNew_displayName":
            MessageLookupByLibrary.simpleMessage("Nombre que se muestra"),
        "practitionerNew_displayNameRequired":
            MessageLookupByLibrary.simpleMessage(
                "El nombre que aparece es obligatorio"),
        "practitionerNew_editPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Cambiar de profesional sanitario"),
        "practitionerNew_email":
            MessageLookupByLibrary.simpleMessage("Correo electrónico"),
        "practitionerNew_firstName":
            MessageLookupByLibrary.simpleMessage("Nombre"),
        "practitionerNew_lastName":
            MessageLookupByLibrary.simpleMessage("Nombre"),
        "practitionerNew_newPractitioner":
            MessageLookupByLibrary.simpleMessage("Nuevo profesional"),
        "practitionerNew_phone":
            MessageLookupByLibrary.simpleMessage("Teléfono"),
        "practitionerNew_professionalId":
            MessageLookupByLibrary.simpleMessage("Identificador profesional"),
        "practitionerNew_professionalIdHint":
            MessageLookupByLibrary.simpleMessage("RPPS, ADELI…"),
        "practitionerNew_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "practitionerQr_close": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "practitionerQr_defaultOrganizationName":
            MessageLookupByLibrary.simpleMessage("Despacho"),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("Perfil profesional de ABAK"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Escanea este código QR desde ABAK Mobile para añadir automáticamente este perfil profesional."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("archivado"),
        "practitionerSelector_error": m21,
        "practitionerSelector_noSelection":
            MessageLookupByLibrary.simpleMessage("Sin selección"),
        "preferences_archivedPatients":
            MessageLookupByLibrary.simpleMessage("Pacientes archivados"),
        "preferences_contextComment": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla centraliza los ajustes generales de Companion."),
        "preferences_contextName":
            MessageLookupByLibrary.simpleMessage("Configuración de usuario"),
        "preferences_days": MessageLookupByLibrary.simpleMessage("días"),
        "preferences_expertMode":
            MessageLookupByLibrary.simpleMessage("Experto en moda"),
        "preferences_expertModeDescription": MessageLookupByLibrary.simpleMessage(
            "Muestra información técnica dirigida a desarrolladores y colaboradores."),
        "preferences_expertModeSaved": MessageLookupByLibrary.simpleMessage(
            "Se ha guardado la configuración del modo Experto."),
        "preferences_languageSaved":
            MessageLookupByLibrary.simpleMessage("Idioma guardado."),
        "preferences_organization":
            MessageLookupByLibrary.simpleMessage("Establecimiento"),
        "preferences_organizationDescription":
            MessageLookupByLibrary.simpleMessage(
                "Nombre, logotipo e información general."),
        "preferences_retentionDuration":
            MessageLookupByLibrary.simpleMessage("Plazo de conservación"),
        "preferences_retentionExplanation": MessageLookupByLibrary.simpleMessage(
            "Los pacientes archivados pueden recuperarse durante este periodo. Posteriormente, se eliminarán automáticamente."),
        "preferences_retentionSaved": MessageLookupByLibrary.simpleMessage(
            "Plazo de conservación registrado."),
        "recentImportCard_conflict":
            MessageLookupByLibrary.simpleMessage("conflicto"),
        "recentImportCard_error": MessageLookupByLibrary.simpleMessage("error"),
        "recentImportCard_fichier":
            MessageLookupByLibrary.simpleMessage("archivo"),
        "recentImportCard_file":
            MessageLookupByLibrary.simpleMessage("archivo"),
        "recentImportCard_ignored":
            MessageLookupByLibrary.simpleMessage("ignorado"),
        "recentImportCard_no_result_imported":
            MessageLookupByLibrary.simpleMessage(
                "No se han importado resultados"),
        "recentImportCard_result":
            MessageLookupByLibrary.simpleMessage("resultado"),
        "refreshDashboard": MessageLookupByLibrary.simpleMessage(
            "Actualizar el panel de control"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Archivo de informes"),
        "reset": MessageLookupByLibrary.simpleMessage("Restablecer"),
        "resultDetail_addCommentHint":
            MessageLookupByLibrary.simpleMessage("Añadir un comentario..."),
        "resultDetail_archiveConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "¿De verdad quieres archivar este resultado?"),
        "resultDetail_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archivar el resultado"),
        "resultDetail_birthDate":
            MessageLookupByLibrary.simpleMessage("Nacimiento"),
        "resultDetail_cancel": MessageLookupByLibrary.simpleMessage("Aparato"),
        "resultDetail_clinicalComment":
            MessageLookupByLibrary.simpleMessage("Comentario clínico"),
        "resultDetail_commentSaved":
            MessageLookupByLibrary.simpleMessage("Comentario guardado"),
        "resultDetail_detailedResult":
            MessageLookupByLibrary.simpleMessage("Resultado detallado"),
        "resultDetail_device":
            MessageLookupByLibrary.simpleMessage("Detalles del dispositivo"),
        "resultDetail_exerciseDate":
            MessageLookupByLibrary.simpleMessage("Fecha del ejercicio"),
        "resultDetail_generalInformation":
            MessageLookupByLibrary.simpleMessage("Información general"),
        "resultDetail_identityUnverified":
            MessageLookupByLibrary.simpleMessage("Identidad no verificada"),
        "resultDetail_identityVerified":
            MessageLookupByLibrary.simpleMessage("Identidad verificada"),
        "resultDetail_import": MessageLookupByLibrary.simpleMessage("Importar"),
        "resultDetail_lastModified":
            MessageLookupByLibrary.simpleMessage("Última modificación"),
        "resultDetail_metrics":
            MessageLookupByLibrary.simpleMessage("Métricas"),
        "resultDetail_noMetrics": MessageLookupByLibrary.simpleMessage(
            "No hay métricas registradas."),
        "resultDetail_patient":
            MessageLookupByLibrary.simpleMessage("Paciente"),
        "resultDetail_performedBy":
            MessageLookupByLibrary.simpleMessage("Dirigida por"),
        "resultDetail_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "resultDetail_score":
            MessageLookupByLibrary.simpleMessage("Puntuación"),
        "resultDetail_syncState":
            MessageLookupByLibrary.simpleMessage("Estado de sincronización"),
        "settings_assistanceWarning": MessageLookupByLibrary.simpleMessage(
            "Estas funciones están destinadas a la instalación, el diagnóstico y las operaciones de asistencia técnica.\n\nUtilícelas únicamente cuando se lo indique un técnico o la documentación de ABAK."),
        "settings_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "settings_configuration":
            MessageLookupByLibrary.simpleMessage("Configuración"),
        "settings_confirmationRequired":
            MessageLookupByLibrary.simpleMessage("Confirmación obligatoria"),
        "settings_contextComment": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla reúne las funciones de instalación, diagnóstico y mantenimiento de Companion."),
        "settings_contextName":
            MessageLookupByLibrary.simpleMessage("Asistencia"),
        "settings_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
        "settings_databaseResetError": m22,
        "settings_databaseResetSuccess": MessageLookupByLibrary.simpleMessage(
            "Base de datos restablecida. Se ha creado una copia de seguridad automática."),
        "settings_diagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnóstico"),
        "settings_edit": MessageLookupByLibrary.simpleMessage("Modificar"),
        "settings_exchangeDirectory": MessageLookupByLibrary.simpleMessage(
            "Expediente de intercambio ABAK"),
        "settings_exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Carpeta de intercambio restablecida"),
        "settings_exchangeDirectoryUpdated":
            MessageLookupByLibrary.simpleMessage(
                "Expediente de intercambio ABAK actualizado"),
        "settings_importAbakFile": MessageLookupByLibrary.simpleMessage(
            "Importar manualmente un archivo .abak"),
        "settings_invalidConfirmation":
            MessageLookupByLibrary.simpleMessage("Confirmación no válida."),
        "settings_loading": MessageLookupByLibrary.simpleMessage("Cargando..."),
        "settings_maintenance":
            MessageLookupByLibrary.simpleMessage("Mantenimiento"),
        "settings_manageBackups": MessageLookupByLibrary.simpleMessage(
            "Gestionar las copias de seguridad"),
        "settings_noDirectoryDefined": MessageLookupByLibrary.simpleMessage(
            "No se ha definido ninguna carpeta"),
        "settings_open": MessageLookupByLibrary.simpleMessage("Abrir"),
        "settings_openingExchangeDirectory":
            MessageLookupByLibrary.simpleMessage(
                "Apertura del expediente de intercambio"),
        "settings_reset": MessageLookupByLibrary.simpleMessage("Restablecer"),
        "settings_resetDatabase":
            MessageLookupByLibrary.simpleMessage("Restablecer la base"),
        "settings_resetDatabaseTitle":
            MessageLookupByLibrary.simpleMessage("¿Restablecer la base local?"),
        "settings_resetDatabaseWarning": MessageLookupByLibrary.simpleMessage(
            "Esta operación eliminará todos los datos locales (pacientes, resultados, importaciones e historiales).\n\nSe creará una copia de seguridad automática antes del restablecimiento.\n\nUtiliza esta función únicamente en el marco de una intervención de asistencia técnica."),
        "settings_resetKeyword":
            MessageLookupByLibrary.simpleMessage("REINICIAR"),
        "settings_resetTooltip":
            MessageLookupByLibrary.simpleMessage("Restablecer"),
        "settings_resolveImportProblem": MessageLookupByLibrary.simpleMessage(
            "Resolver un problema de importación"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Asistencia"),
        "settings_typeResetConfirmation": MessageLookupByLibrary.simpleMessage(
            "Escribe RESET para confirmar definitivamente."),
        "settings_vitaleDiagnostic": MessageLookupByLibrary.simpleMessage(
            "Diagnóstico de la Tarjeta Sanitaria"),
        "smartCardDiagnostic": MessageLookupByLibrary.simpleMessage(
            "Diagnóstico de la Tarjeta Sanitaria"),
        "systemOverviewBar_active_patients":
            MessageLookupByLibrary.simpleMessage("Pacientes activos"),
        "systemOverviewBar_alert":
            MessageLookupByLibrary.simpleMessage("Alertas"),
        "systemOverviewBar_archived_patients":
            MessageLookupByLibrary.simpleMessage("Pacientes archivados"),
        "systemOverviewBar_loading_system_summary":
            MessageLookupByLibrary.simpleMessage(
                "Cargando el resumen del sistema..."),
        "systemOverviewBar_supervision_error":
            MessageLookupByLibrary.simpleMessage("Error de supervisión"),
        "systemOverviewBar_supervision_unavailable":
            MessageLookupByLibrary.simpleMessage("Supervisión no disponible"),
        "systemStatusCard_nome":
            MessageLookupByLibrary.simpleMessage("Ninguna"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Configuración del usuario"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Configuración de usuario"),
        "vitaleBeneficiarySelector_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage("Selecciona un beneficiario"),
        "vitaleIdentity_birthDate":
            MessageLookupByLibrary.simpleMessage("Fecha de nacimiento"),
        "vitaleIdentity_dataMasked":
            MessageLookupByLibrary.simpleMessage("dato oculto"),
        "vitaleIdentity_detected":
            MessageLookupByLibrary.simpleMessage("detectado"),
        "vitaleIdentity_female":
            MessageLookupByLibrary.simpleMessage("Femenino"),
        "vitaleIdentity_firstName":
            MessageLookupByLibrary.simpleMessage("Nombre"),
        "vitaleIdentity_identityRead":
            MessageLookupByLibrary.simpleMessage("Identidad leída"),
        "vitaleIdentity_identityReceivedMasked":
            MessageLookupByLibrary.simpleMessage(
                "identidad facilitada (datos personales ocultos)"),
        "vitaleIdentity_identityUnavailable":
            MessageLookupByLibrary.simpleMessage("identidad no disponible"),
        "vitaleIdentity_lastName":
            MessageLookupByLibrary.simpleMessage("Nombre"),
        "vitaleIdentity_male":
            MessageLookupByLibrary.simpleMessage("Masculino"),
        "vitaleIdentity_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "vitaleIdentity_noIdentityAvailable":
            MessageLookupByLibrary.simpleMessage(
                "No hay ninguna tarjeta sanitaria disponible"),
        "vitaleIdentity_notProvided":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "vitaleIdentity_other": MessageLookupByLibrary.simpleMessage("Otros"),
        "vitaleIdentity_reading":
            MessageLookupByLibrary.simpleMessage("Se está leyendo..."),
        "vitaleIdentity_sex": MessageLookupByLibrary.simpleMessage("Sexo"),
        "vitaleIdentity_source": MessageLookupByLibrary.simpleMessage("Fuente"),
        "vitaleIdentity_title": MessageLookupByLibrary.simpleMessage(
            "Leer los datos de la tarjeta sanitaria «Carte Vitale»"),
        "vitaleIdentity_unavailable":
            MessageLookupByLibrary.simpleMessage("no disponible"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Utilizar para crear un paciente")
      };
}
