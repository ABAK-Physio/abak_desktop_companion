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

  static String m0(careEpisodeId) =>
      "No se ha encontrado al paciente para la atención ${careEpisodeId}.";

  static String m1(height) => "${height} cm";

  static String m2(weight) => "${weight} kg";

  static String m3(age) => "${age} años";

  static String m4(path) => "Autorizar el acceso a la carpeta: ${path}";

  static String m5(path) =>
      "Selecciona la carpeta en la que restaurar los documentos de: ${path}";

  static String m6(size) => "${size}";

  static String m7(date) => "Archivado el ${date}";

  static String m8(monthYear) => "Inicio de la cobertura en ${monthYear}";

  static String m9(title) =>
      "El extracto «${title}» ya no aparecerá en el historial.";

  static String m10(title) =>
      "El informe «${title}» se moverá a la papelera. Se podrá recuperar más adelante.";

  static String m11(patientName, title) => "Bilan_${patientName}_{títle}";

  static String m12(title) => "Copia de ${title}";

  static String m13(title) =>
      "El balance «${title}» se eliminará definitivamente. Esta acción es irreversible.";

  static String m14(title) =>
      "El informe «${title}» se eliminará definitivamente. Esta acción es irreversible.";

  static String m15(path) =>
      "\"careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": \"Le dossier configuré n’est pas accessible ou son autorisation doit être renouvelée.\n\n${path}\n\nReconnectez son volume si nécessaire, puis sélectionnez ce dossier pour autoriser son accès. Le dossier sélectionné sera enregistré dans vos préférences.\",\n\"@careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": {\n  \"placeholders\": {\n    \"path\": {\n      \"type\": \"String\"\n    }\n  }\n}";

  static String m16(documentLabel) =>
      "Ya existe un borrador de este modelo de ${documentLabel}.";

  static String m17(documentLabel) =>
      "¿Desea añadir el contenido generado a continuación del ${documentLabel} actual o sustituir el contenido existente?";

  static String m18(documentLabel) => "Nuevo ${documentLabel}";

  static String m19(patientName, title) => "Informe_${patientName}_${title}";

  static String m20(path) => "Documento de Word creado: ${path}";

  static String m21(error) => "Error al crear el documento de Word: ${error}";

  static String m22(patientName) => "${patientName} — Informes y evaluaciones";

  static String m23(deviceName) => "¿De verdad quieres archivar ${deviceName}?";

  static String m24(fieldName) => "El campo «${fieldName}» es obligatorio.";

  static String m25(noteTitle) => "La nota «${noteTitle}» ya no se mostrará.";

  static String m26(error) => "Error al guardar: ${error}";

  static String m27(count) => "${count} otro(s) ejercicio(s)";

  static String m28(count) => "${count} asociación(es) pendientes";

  static String m29(count) => "${count} copias de seguridad";

  static String m30(size) => "Talla: ${size}";

  static String m31(size) => "Tamaño total: ${size}";

  static String m32(version) => "Versión ${version}";

  static String m33(integrityStatus) =>
      "La base de datos restaurada presenta una anomalía: ${integrityStatus}";

  static String m34(error) => "Error en la restauración: ${error}";

  static String m35(integrityStatus) =>
      "Se ha llevado a cabo la restauración, pero integrity_check ha devuelto: ${integrityStatus}";

  static String m36(patientName) =>
      "¿De verdad quieres archivar a ${patientName}? Ya no aparecerá en la lista activa.";

  static String m37(patientName) => "${patientName} archivado.";

  static String m38(error) => "Error: ${error}";

  static String m39(patientName) =>
      "${patientName} se ha vuelto a incluir en la lista activa.";

  static String m40(patientName) =>
      "Tarjeta Vitale asociada al paciente ${patientName}.";

  static String m41(patientName) =>
      "El paciente ${patientName} se ha recuperado.";

  static String m42(practitionerName) =>
      "¿De verdad quieres archivar a ${practitionerName}?";

  static String m43(date) => "Archivado el ${date}";

  static String m44(error) => "Error: ${error}";

  static String m45(professionalId) => "ID pro: ${professionalId}";

  static String m46(error) => "Error: ${error}";

  static String m47(name) => "${name} — archivado";

  static String m48(start, end) => "Tú ${start} a ${end}";

  static String m49(error) => "Error al cargar el historial: ${error}";

  static String m50(start) => "Desde el ${start}";

  static String m51(error) => "Error al reiniciar: ${error}";

  static String m52(patientCount, fileCount) =>
      "Exportación completada: ${patientCount} paciente(s), ${fileCount} archivo(s).";

  static String m53(errorCount, patientCount, fileCount) =>
      "Exportación completada con ${errorCount} error(es): ${patientCount} paciente(s), ${fileCount} archivo(s) exportado(s).";

  static String m54(error) => "El dictado por voz ha fallado: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "abakWhisperSpeechProvider_name":
            MessageLookupByLibrary.simpleMessage("ABAK Dictado por voz"),
        "archivedDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Esta vista agrupa los informes y los informes archivados de la gestión del caso. Cada línea indica el tipo de documento, su título y su fecha de archivo.\n\nLa acción de restauración permite volver a incluir el documento en el historial de informes.\n\nLa acción de eliminación definitiva elimina el documento de Companion. Lea atentamente el mensaje de confirmación antes de validar: el documento ya no se podrá restaurar desde esta lista.\n\nHaga clic en la cruz para cerrar la vista ampliada y volver al espacio «Balances/Informes»."),
        "assessmentChartImageService_insufficientPoints":
            MessageLookupByLibrary.simpleMessage(
                "Una serie gráfica debe contener al menos dos puntos."),
        "assessmentChartImageService_pngConversionError":
            MessageLookupByLibrary.simpleMessage(
                "No es posible convertir el gráfico en una imagen PNG."),
        "assessmentDocumentDataBuilder_female":
            MessageLookupByLibrary.simpleMessage("Femenino"),
        "assessmentDocumentDataBuilder_male":
            MessageLookupByLibrary.simpleMessage("Masculino"),
        "assessmentDocumentDataBuilder_patient": m0,
        "assessmentDocxService_age":
            MessageLookupByLibrary.simpleMessage("Edad"),
        "assessmentDocxService_assessment":
            MessageLookupByLibrary.simpleMessage("con"),
        "assessmentDocxService_attachment":
            MessageLookupByLibrary.simpleMessage(
                "Patología durante la reincorporación"),
        "assessmentDocxService_author":
            MessageLookupByLibrary.simpleMessage("Redactor"),
        "assessmentDocxService_centimetres": m1,
        "assessmentDocxService_chart":
            MessageLookupByLibrary.simpleMessage("Gráfico"),
        "assessmentDocxService_declared":
            MessageLookupByLibrary.simpleMessage("Edad declarada en la prueba"),
        "assessmentDocxService_diagnosis": MessageLookupByLibrary.simpleMessage(
            "Anomalías observadas durante la prueba"),
        "assessmentDocxService_dominance":
            MessageLookupByLibrary.simpleMessage("Lado dominante"),
        "assessmentDocxService_establishment":
            MessageLookupByLibrary.simpleMessage("Establecimiento"),
        "assessmentDocxService_firstname":
            MessageLookupByLibrary.simpleMessage("Nombre"),
        "assessmentDocxService_height":
            MessageLookupByLibrary.simpleMessage("Tamaño"),
        "assessmentDocxService_information":
            MessageLookupByLibrary.simpleMessage("Datos del paciente"),
        "assessmentDocxService_kilograms": m2,
        "assessmentDocxService_notes": MessageLookupByLibrary.simpleMessage(
            "Notas de seguimiento seleccionadas"),
        "assessmentDocxService_opened": MessageLookupByLibrary.simpleMessage(
            "Servicio disponible a partir del"),
        "assessmentDocxService_pathology":
            MessageLookupByLibrary.simpleMessage("Patología"),
        "assessmentDocxService_patient":
            MessageLookupByLibrary.simpleMessage("Paciente"),
        "assessmentDocxService_performed":
            MessageLookupByLibrary.simpleMessage("Realizado el"),
        "assessmentDocxService_practitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapeuta de referencia"),
        "assessmentDocxService_printed":
            MessageLookupByLibrary.simpleMessage("Impreso el"),
        "assessmentDocxService_profession":
            MessageLookupByLibrary.simpleMessage("Profesión"),
        "assessmentDocxService_recipients":
            MessageLookupByLibrary.simpleMessage("Destinatario(s)"),
        "assessmentDocxService_results":
            MessageLookupByLibrary.simpleMessage("Resultados de las pruebas"),
        "assessmentDocxService_sex":
            MessageLookupByLibrary.simpleMessage("Sexo"),
        "assessmentDocxService_sport":
            MessageLookupByLibrary.simpleMessage("Actividad deportiva"),
        "assessmentDocxService_surname":
            MessageLookupByLibrary.simpleMessage("Nombre"),
        "assessmentDocxService_title":
            MessageLookupByLibrary.simpleMessage("con"),
        "assessmentDocxService_weight":
            MessageLookupByLibrary.simpleMessage("Peso"),
        "assessmentDocxService_years": m3,
        "assessmentDraft_help": MessageLookupByLibrary.simpleMessage(
            "El texto que se muestra corresponde a un trabajo en curso que se ha guardado automáticamente. Puedes conservarlo, modificarlo o eliminarlo antes de guardar tu balance."),
        "assessmentDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Entender el borrador del balance"),
        "assessmentHistory_help": MessageLookupByLibrary.simpleMessage(
            "Esta vista muestra los balances registrados para la gestión, con su título y su fecha.\n\nLas acciones de cada línea permiten modificar un balance, duplicarlo o moverlo a los documentos archivados.\n\nCuando se abre un balance para modificarlo, utiliza la acción de actualización para guardar los cambios. Los comandos disponibles también permiten deshacer los cambios o volver al borrador.\n\nEl traslado a los documentos archivados no supone una eliminación definitiva.\n\nHaga clic en la cruz para cerrar la vista ampliada y volver al espacio «Balances/Informes»."),
        "backupArchive_authorizeFolder": m4,
        "backupArchive_busy": MessageLookupByLibrary.simpleMessage(
            "«Ya se está realizando una copia de seguridad o una restauración»."),
        "backupArchive_chooseFile": MessageLookupByLibrary.simpleMessage(
            "Abrir una copia de seguridad…"),
        "backupArchive_legacy": MessageLookupByLibrary.simpleMessage(
            "Esta copia de seguridad antigua solo contiene la base de datos. Los archivos de los expedientes de los pacientes no se han restaurado."),
        "backupArchive_restoreFolder": m5,
        "backupArchive_resultTitle": MessageLookupByLibrary.simpleMessage(
            "Resultado de la restauración"),
        "backupArchive_safetyCopies": MessageLookupByLibrary.simpleMessage(
            "Copias de seguridad conservadas:"),
        "backupArchive_working": MessageLookupByLibrary.simpleMessage(
            "Se está realizando una copia de seguridad o una restauración… Por favor, espera un momento."),
        "backupHistory_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "No hay ninguna copia de seguridad guardada."),
        "backupHistory_fileSize": m6,
        "backupHistory_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla muestra las copias de seguridad guardadas en Companion. Cada línea indica el nombre del archivo, su fecha de creación, su tamaño y su ubicación.\n\nEl botón «Restaurar» permite sustituir la base de datos actual por la de la copia de seguridad seleccionada. Por lo tanto, los datos añadidos o modificados después de esta copia de seguridad no aparecerán en la base de datos restaurada.\n\nComprueba la fecha de la copia de seguridad y lee el mensaje de confirmación antes de continuar. Se crea una copia de seguridad de la base de datos actual antes de sustituirla.\n\nEl archivo de copia de seguridad debe estar siempre accesible en la ubicación indicada. Si se ha movido o eliminado, no se podrá llevar a cabo la restauración.\n\nPara crear una nueva copia de seguridad, utiliza la acción «Crear una copia de seguridad» en la página de inicio."),
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "backupHistory_restoreTitle": MessageLookupByLibrary.simpleMessage(
            "¿Quieres restaurar esta copia de seguridad?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Esta operación sustituirá por completo la base de datos actual.\n\nSe creará una copia de seguridad automática antes de la restauración.\n\n¿Deseas continuar?"),
        "backupHistory_title": MessageLookupByLibrary.simpleMessage(
            "Historial de copias de seguridad"),
        "bodymap_help": MessageLookupByLibrary.simpleMessage(
            "El mapa de dolor permite localizar las zonas dolorosas del paciente para la sesión de cuidados en curso.\n\nElige una vista y, a continuación, haz clic en una zona de la silueta o selecciónala de la lista. Puedes añadir una observación y, si es necesario, una intensidad del 0 al 10. Utiliza la papelera para eliminar una zona del registro.\n\nHaga clic en «Guardar» para guardar su registro en Companion. Al salir de la pantalla con cambios sin guardar, aparecerá una ventana emergente que le permitirá guardarlos o descartarlos.\n\n«Exportar ambos mapas» crea una imagen PNG en la ubicación elegida de su ordenador. Esta exportación no sustituye al guardado del registro.\n\nEste módulo es una primera propuesta, destinada a evolucionar en función de vuestros comentarios. Probadlo en vuestra práctica e indicad las funciones que os gustaría que se añadieran o mejoraran."),
        "bodymap_title":
            MessageLookupByLibrary.simpleMessage("Mapa de dolores"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origen: ABAK"),
        "careEpisodeDetail_detail_de_la_prise_en_charge":
            MessageLookupByLibrary.simpleMessage("Detalles de la cobertura"),
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
        "careEpisodePanel_archive":
            MessageLookupByLibrary.simpleMessage("Archivar"),
        "careEpisodePanel_archiveCareEpisode":
            MessageLookupByLibrary.simpleMessage("Archivar la gestión"),
        "careEpisodePanel_archiveCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "No se ha podido archivar la gestión. Inténtalo de nuevo."),
        "careEpisodePanel_archiveCareEpisodeMessage":
            MessageLookupByLibrary.simpleMessage(
                "Este caso se eliminará de la lista. Sus datos se conservarán en el archivo."),
        "careEpisodePanel_archiveCareEpisodeTitle":
            MessageLookupByLibrary.simpleMessage("¿Archivar esta gestión?"),
        "careEpisodePanel_archivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage("Casos archivados"),
        "careEpisodePanel_archivedCareEpisodesHelp":
            MessageLookupByLibrary.simpleMessage(
                "Aquí encontrarás tus historiales médicos archivados."),
        "careEpisodePanel_archivedOn": m7,
        "careEpisodePanel_careEpisodeArchived":
            MessageLookupByLibrary.simpleMessage("Solicitud archivada."),
        "careEpisodePanel_careEpisodeOpenedIn": m8,
        "careEpisodePanel_careEpisodeRestored":
            MessageLookupByLibrary.simpleMessage(
                "Se ha restablecido el servicio."),
        "careEpisodePanel_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Coberturas"),
        "careEpisodePanel_choose":
            MessageLookupByLibrary.simpleMessage("Elegir"),
        "careEpisodePanel_edit":
            MessageLookupByLibrary.simpleMessage("Modificar"),
        "careEpisodePanel_loadCareEpisodesError":
            MessageLookupByLibrary.simpleMessage(
                "No se han podido cargar las coberturas."),
        "careEpisodePanel_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Nueva cobertura"),
        "careEpisodePanel_noArchivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage(
                "No hay ningún historial médico archivado para este paciente."),
        "careEpisodePanel_noCareEpisodes": MessageLookupByLibrary.simpleMessage(
            "No se ha creado ningún caso clínico para este paciente."),
        "careEpisodePanel_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Médico prescriptor"),
        "careEpisodePanel_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "careEpisodePanel_restoreCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "No se ha podido restablecer la conexión. Inténtalo de nuevo."),
        "careEpisodeReportsWorkspaceScreen_add":
            MessageLookupByLibrary.simpleMessage("Añadir"),
        "careEpisodeReportsWorkspaceScreen_append":
            MessageLookupByLibrary.simpleMessage("Añadir a la lista"),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "No se puede enviar el balance a la papelera."),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentMessage": m9,
        "careEpisodeReportsWorkspaceScreen_archiveReportError":
            MessageLookupByLibrary.simpleMessage(
                "No se puede enviar el informe a la papelera."),
        "careEpisodeReportsWorkspaceScreen_archiveReportMessage": m10,
        "careEpisodeReportsWorkspaceScreen_assessmentFileName": m11,
        "careEpisodeReportsWorkspaceScreen_assessmentLabel":
            MessageLookupByLibrary.simpleMessage("con"),
        "careEpisodeReportsWorkspaceScreen_assessmentNotFound":
            MessageLookupByLibrary.simpleMessage("No se encuentra el balance."),
        "careEpisodeReportsWorkspaceScreen_assessmentReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Tu informe ya está listo. El archivo DOCX incluirá la información introducida y los elementos seleccionados."),
        "careEpisodeReportsWorkspaceScreen_assessmentTitle":
            MessageLookupByLibrary.simpleMessage("Título del balance"),
        "careEpisodeReportsWorkspaceScreen_assessmentsAndReports":
            MessageLookupByLibrary.simpleMessage("Balances e informes"),
        "careEpisodeReportsWorkspaceScreen_author":
            MessageLookupByLibrary.simpleMessage("Redactor"),
        "careEpisodeReportsWorkspaceScreen_authorizeDirectory":
            MessageLookupByLibrary.simpleMessage("Autorizar una carpeta"),
        "careEpisodeReportsWorkspaceScreen_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "careEpisodeReportsWorkspaceScreen_cancelChangesError":
            MessageLookupByLibrary.simpleMessage(
                "No es posible deshacer los cambios."),
        "careEpisodeReportsWorkspaceScreen_cancelReportChangesError":
            MessageLookupByLibrary.simpleMessage(
                "No es posible deshacer los cambios realizados en el informe."),
        "careEpisodeReportsWorkspaceScreen_close":
            MessageLookupByLibrary.simpleMessage("Cerrar"),
        "careEpisodeReportsWorkspaceScreen_confirm":
            MessageLookupByLibrary.simpleMessage("Confirmar"),
        "careEpisodeReportsWorkspaceScreen_copyTitle": m12,
        "careEpisodeReportsWorkspaceScreen_createNew":
            MessageLookupByLibrary.simpleMessage("Crear uno nuevo"),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "No es posible eliminar definitivamente el balance."),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentMessage": m13,
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "¿Eliminar el balance de forma definitiva?"),
        "careEpisodeReportsWorkspaceScreen_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Eliminar definitivamente"),
        "careEpisodeReportsWorkspaceScreen_deleteReportError":
            MessageLookupByLibrary.simpleMessage(
                "No es posible eliminar el informe de forma definitiva."),
        "careEpisodeReportsWorkspaceScreen_deleteReportMessage": m14,
        "careEpisodeReportsWorkspaceScreen_deleteReportTitle":
            MessageLookupByLibrary.simpleMessage(
                "¿Deseas eliminar definitivamente el informe?"),
        "careEpisodeReportsWorkspaceScreen_directoryAccessMessage": m15,
        "careEpisodeReportsWorkspaceScreen_duplicate":
            MessageLookupByLibrary.simpleMessage("Duplicar"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessment":
            MessageLookupByLibrary.simpleMessage("Duplicar el balance"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "No es posible duplicar el balance."),
        "careEpisodeReportsWorkspaceScreen_duplicateReport":
            MessageLookupByLibrary.simpleMessage("Duplicar el informe"),
        "careEpisodeReportsWorkspaceScreen_duplicateReportError":
            MessageLookupByLibrary.simpleMessage(
                "No se puede duplicar el informe."),
        "careEpisodeReportsWorkspaceScreen_existingAssessmentDocx":
            MessageLookupByLibrary.simpleMessage(
                "Ya hay un archivo DOCX asociado a este balance. ¿Desea sustituir el archivo existente o crear uno nuevo?"),
        "careEpisodeReportsWorkspaceScreen_existingReportDocx":
            MessageLookupByLibrary.simpleMessage(
                "Ya hay un archivo DOCX asociado a este informe. ¿Deseas sustituir el archivo existente o crear uno nuevo?"),
        "careEpisodeReportsWorkspaceScreen_existingTemplateDraftMessage": m16,
        "careEpisodeReportsWorkspaceScreen_generate":
            MessageLookupByLibrary.simpleMessage("Generar"),
        "careEpisodeReportsWorkspaceScreen_generateDocx":
            MessageLookupByLibrary.simpleMessage("Generar el archivo DOCX"),
        "careEpisodeReportsWorkspaceScreen_insertTextMessage": m17,
        "careEpisodeReportsWorkspaceScreen_managePractitioners":
            MessageLookupByLibrary.simpleMessage(
                "Gestionar a los fisioterapeutas"),
        "careEpisodeReportsWorkspaceScreen_managePrescribingDoctors":
            MessageLookupByLibrary.simpleMessage(
                "Gestionar a los médicos que prescriben"),
        "careEpisodeReportsWorkspaceScreen_moveToTrash":
            MessageLookupByLibrary.simpleMessage("Enviar a la papelera"),
        "careEpisodeReportsWorkspaceScreen_newAssessment":
            MessageLookupByLibrary.simpleMessage("Nuevo balance"),
        "careEpisodeReportsWorkspaceScreen_newAssessmentTitle":
            MessageLookupByLibrary.simpleMessage("Título del nuevo balance"),
        "careEpisodeReportsWorkspaceScreen_newDocument": m18,
        "careEpisodeReportsWorkspaceScreen_newReport":
            MessageLookupByLibrary.simpleMessage("Nuevo informe"),
        "careEpisodeReportsWorkspaceScreen_newReportTitle":
            MessageLookupByLibrary.simpleMessage("Título del nuevo informe"),
        "careEpisodeReportsWorkspaceScreen_note":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "careEpisodeReportsWorkspaceScreen_openReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "No se puede abrir el borrador del informe."),
        "careEpisodeReportsWorkspaceScreen_openReportError":
            MessageLookupByLibrary.simpleMessage(
                "No se puede abrir el informe."),
        "careEpisodeReportsWorkspaceScreen_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Médico prescriptor"),
        "careEpisodeReportsWorkspaceScreen_recipients":
            MessageLookupByLibrary.simpleMessage("Destinatario(s)"),
        "careEpisodeReportsWorkspaceScreen_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapeuta de referencia"),
        "careEpisodeReportsWorkspaceScreen_replace":
            MessageLookupByLibrary.simpleMessage("Sustituir"),
        "careEpisodeReportsWorkspaceScreen_reportFileName": m19,
        "careEpisodeReportsWorkspaceScreen_reportLabel":
            MessageLookupByLibrary.simpleMessage("informe"),
        "careEpisodeReportsWorkspaceScreen_reportNotFound":
            MessageLookupByLibrary.simpleMessage("No se encuentra el informe."),
        "careEpisodeReportsWorkspaceScreen_reportOptionsTitle":
            MessageLookupByLibrary.simpleMessage("Opciones del informe"),
        "careEpisodeReportsWorkspaceScreen_reportReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Tu informe ya está listo. El archivo DOCX incluirá los datos del paciente, del redactor y del destinatario."),
        "careEpisodeReportsWorkspaceScreen_reportTitle":
            MessageLookupByLibrary.simpleMessage("Título del informe"),
        "careEpisodeReportsWorkspaceScreen_restoreAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "No es posible restaurar el balance"),
        "careEpisodeReportsWorkspaceScreen_restoreReportError":
            MessageLookupByLibrary.simpleMessage(
                "No es posible recuperar el informe."),
        "careEpisodeReportsWorkspaceScreen_resumeAssessmentDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Ya se ha guardado automáticamente un trabajo en curso.<br><br>¿Deseas retomar este borrador o empezar un nuevo balance?"),
        "careEpisodeReportsWorkspaceScreen_resumeDraft":
            MessageLookupByLibrary.simpleMessage("Retomar el borrador"),
        "careEpisodeReportsWorkspaceScreen_resumeReportDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Ya se ha guardado automáticamente un trabajo en curso.<br><br>¿Desea retomar este borrador o empezar un nuevo informe?"),
        "careEpisodeReportsWorkspaceScreen_returnToDraftError":
            MessageLookupByLibrary.simpleMessage(
                "No es posible volver al borrador."),
        "careEpisodeReportsWorkspaceScreen_returnToReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "No es posible volver al borrador del informe."),
        "careEpisodeReportsWorkspaceScreen_save":
            MessageLookupByLibrary.simpleMessage("Guardar"),
        "careEpisodeReportsWorkspaceScreen_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Guardar el balance"),
        "careEpisodeReportsWorkspaceScreen_saveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "No se ha podido guardar el balance."),
        "careEpisodeReportsWorkspaceScreen_saveNoteSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "No se ha podido guardar la nota seleccionada."),
        "careEpisodeReportsWorkspaceScreen_saveReport":
            MessageLookupByLibrary.simpleMessage("Guardar el informe"),
        "careEpisodeReportsWorkspaceScreen_saveReportError":
            MessageLookupByLibrary.simpleMessage(
                "No se puede guardar el informe."),
        "careEpisodeReportsWorkspaceScreen_saveTestSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "No se ha podido guardar la selección de la prueba."),
        "careEpisodeReportsWorkspaceScreen_showPrescriber":
            MessageLookupByLibrary.simpleMessage("Mostrar al prescriptor"),
        "careEpisodeReportsWorkspaceScreen_showReferringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Mostrar al fisioterapeuta de referencia"),
        "careEpisodeReportsWorkspaceScreen_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Área de redacción del informe SOAP.<br><br>S — Subjetivo<br><br>O — Objetivo<br><br>A — Análisis<br><br>P — Plan"),
        "careEpisodeReportsWorkspaceScreen_title":
            MessageLookupByLibrary.simpleMessage("Título"),
        "careEpisodeReportsWorkspaceScreen_update":
            MessageLookupByLibrary.simpleMessage("Actualizar"),
        "careEpisodeReportsWorkspaceScreen_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Actualizar el balance"),
        "careEpisodeReportsWorkspaceScreen_updateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "No se puede actualizar el balance."),
        "careEpisodeReportsWorkspaceScreen_updateReport":
            MessageLookupByLibrary.simpleMessage("Actualizar el informe"),
        "careEpisodeReportsWorkspaceScreen_updateReportError":
            MessageLookupByLibrary.simpleMessage(
                "No se puede actualizar el informe."),
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreated": m20,
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreationError": m21,
        "careEpisodeReportsWorkspaceScreen_workspaceTitle": m22,
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
        "careEpisode_assessment": MessageLookupByLibrary.simpleMessage(
            "No se ha realizado ningún análisis clínico."),
        "careEpisode_evaluation": MessageLookupByLibrary.simpleMessage(
            "No se ha realizado ninguna evaluación clínica."),
        "careEpisode_report":
            MessageLookupByLibrary.simpleMessage("No hay informe inicial."),
        "careEpisode_title": MessageLookupByLibrary.simpleMessage("Cobertura"),
        "careEpisode_treatment": MessageLookupByLibrary.simpleMessage(
            "No hay ningún plan de tratamiento."),
        "clinicalDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla permite preparar y guardar los informes y los informes de seguimiento relacionados con la atención médica.\n\nEn el caso de un informe, puede redactar el texto principal, seleccionar los resultados de las pruebas y las notas de seguimiento que se vayan a incluir y, a continuación, generar un documento DOCX una vez guardado el informe.\n\nLos borradores se guardan automáticamente mientras no se guarden como informe o informe de seguimiento.\n\nEl historial permite recuperar los informes y los informes de seguimiento ya guardados."),
        "clinicalDocuments_title":
            MessageLookupByLibrary.simpleMessage("Balances e informes"),
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
        "deviceForm_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite crear o modificar la ficha de un dispositivo en Companion.\n\nIntroduce un nombre que permita reconocer fácilmente el teléfono o la tableta. Este nombre es obligatorio.\n\nSelecciona la plataforma del dispositivo: iOS o Android.\n\nPuede asociar el dispositivo a un profesional de la lista o elegir la opción de dispositivo compartido para no asignarlo a ningún profesional en concreto.\n\nHaz clic en «Crear» para añadir el dispositivo o en «Guardar» para confirmar los cambios. «Cancelar» cierra la ventana sin aplicar los cambios.\n\nAl abrir y cerrar esta ayuda, se conserva lo que hayas introducido en el formulario."),
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
        "deviceList_archiveConfirmation": m23,
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
        "deviceQr_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana muestra el código QR de identificación del dispositivo, junto con su nombre, el nombre de la consulta y su plataforma.\n\nEscanea este código QR desde ABAK Mobile para identificar este dispositivo en este centro. Comprueba que el nombre que aparece se corresponde con el teléfono o la tableta en cuestión.\n\nEste código QR sirve para identificar el dispositivo; su visualización no activa la transferencia de resultados.\n\nCierra esta ventana para volver a la lista de dispositivos."),
        "deviceQr_title": MessageLookupByLibrary.simpleMessage("Aparato ABAK"),
        "documentArchiveConfirm_help": MessageLookupByLibrary.simpleMessage(
            "Al enviarlo a la papelera, el balance o el informe se elimina de su historial habitual.\n\nEl documento permanece guardado en Companion. Puedes encontrarlo en los documentos archivados y restaurarlo para que vuelva a aparecer en el historial.\n\nLos archivos DOCX que ya se hayan exportado a tu ordenador no se eliminan con esta acción.\n\nHaz clic en «Mover a la papelera» para confirmar, o en «Cancelar» para conservar el documento en el historial."),
        "documentArchiveConfirm_title": MessageLookupByLibrary.simpleMessage(
            "¿Desea enviar el documento a la papelera?"),
        "documentAuthor_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite seleccionar al profesional designado como redactor del informe o del informe en curso.\n\nSelecciona al profesional de la lista y, a continuación, haz clic en «Validar» para guardar esta asignación en el documento.\n\nEsta selección se refiere al redactor del documento; no modifica al profesional de referencia del episodio asistencial.\n\n«Cancelar» cierra la ventana sin cambiar al redactor."),
        "documentAuthor_title":
            MessageLookupByLibrary.simpleMessage("Elegir al redactor"),
        "documentDirectoryAccess_help": MessageLookupByLibrary.simpleMessage(
            "Companion no puede acceder a la carpeta prevista para guardar los documentos, o bien es necesario renovar su permiso de acceso.\n\nSi esta carpeta se encuentra en un disco externo o en una ubicación de red, comprueba primero que esté conectada y sea accesible.\n\nHaga clic en «Autorizar una carpeta» y, a continuación, seleccione la carpeta en la ventana que se abre. Puede seleccionar la carpeta habitual o elegir otra ubicación.\n\nLa carpeta seleccionada se guarda en sus preferencias para futuras exportaciones. Los archivos que ya se encuentran en la carpeta anterior no se trasladan.\n\n«Cancelar» interrumpe la exportación en curso sin modificar tu balance ni tu informe."),
        "documentDirectoryAccess_title": MessageLookupByLibrary.simpleMessage(
            "Autorizar la carpeta de documentos"),
        "documentDocxExisting_help": MessageLookupByLibrary.simpleMessage(
            "Ya hay un archivo DOCX asociado a este balance o informe.\n\n«Crear uno nuevo» genera un nuevo archivo con el contenido actual del documento. Si ese nombre ya existe en la carpeta de destino, se añade un número para conservar el archivo anterior. El nuevo archivo pasa a ser el asociado al documento en Companion.\n\n«Reemplazar» sobrescribe el archivo con el nombre asociado al documento en la carpeta de destino. Los posibles cambios realizados directamente en este archivo en Word o LibreOffice se sobrescribirán.\n\n«Cancelar» cancela la exportación sin modificar los archivos."),
        "documentDocxExisting_title":
            MessageLookupByLibrary.simpleMessage("Ya existe un archivo DOCX"),
        "documentDraftChoice_help": MessageLookupByLibrary.simpleMessage(
            "Ya se ha guardado automáticamente un texto en curso de redacción para este tipo de documento.\n\n«Recuperar el borrador» te permite recuperar ese texto y continuar con la redacción.\n\n«Nuevo balance» o «Nuevo informe» borra el título y el texto de este borrador para empezar de nuevo. El borrador anterior no se guarda como un documento independiente. Si desea conservar su trabajo, retome el borrador y guárdelo antes de empezar un nuevo documento.\n\n«Cancelar» cierra esta ventana sin modificar el borrador."),
        "documentDraftChoice_title":
            MessageLookupByLibrary.simpleMessage("Hay un borrador"),
        "documentExpandedEditor_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana ofrece más espacio para redactar o modificar el texto del balance o del informe en el que se está trabajando.\n\nLos cambios que realices se van reflejando sobre la marcha en el área de redacción principal. Cerrar la ventana no los anula.\n\nHaz clic en la cruz para volver al espacio «Balances/Informes» y, a continuación, continúa con la preparación y el guardado de tu documento.\n\nAl abrir y cerrar esta ayuda, se conserva el texto introducido."),
        "documentExpandedEditor_helpTitle":
            MessageLookupByLibrary.simpleMessage(
                "Escribir en la vista ampliada"),
        "documentRecipient_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite introducir los destinatarios del balance o del informe en curso.\n\nIntroduce libremente el nombre del destinatario o los nombres de los distintos destinatarios y, a continuación, haz clic en «Validar» para guardar esta información en el documento.\n\nPara eliminar una entrada existente, borra el contenido del campo y, a continuación, valida.\n\nEsta entrada indica los destinatarios del documento; no activa ningún envío.\n\n«Cancelar» cierra la ventana sin aplicar los cambios. Al abrir y cerrar esta ayuda, se conserva lo que hayas introducido."),
        "documentRecipient_title":
            MessageLookupByLibrary.simpleMessage("Destinatario(s)"),
        "documentTemplateDraft_help": MessageLookupByLibrary.simpleMessage(
            "Ya se han guardado respuestas para esta plantilla de guía en el episodio de atención en curso.\n\n«Retomar el borrador» abre la guía con esas respuestas para que puedas continuar o modificar lo que has introducido.\n\n«Nuevo informe» o «Nuevo informe médico» borra las respuestas guardadas para esta plantilla y abre la guía sin recuperar dichas respuestas. Esta opción no elimina el texto que ya se encuentra en el campo de redacción del documento.\n\n«Cancelar» conserva las respuestas guardadas y vuelve a la pantalla anterior sin abrir la guía."),
        "documentTemplateDraft_title":
            MessageLookupByLibrary.simpleMessage("Borrador existente"),
        "documentTemplateGuide_help": MessageLookupByLibrary.simpleMessage(
            "Esta guía te ayuda a preparar el contenido de un balance o un informe a partir de la plantilla seleccionada.\n\nUtiliza la lista de apartados de la izquierda para acceder a las distintas secciones. Según los campos que se te propongan, introduce texto, selecciona respuestas o rellena las tablas.\n\nEl botón de vista previa, situado en la parte inferior del formulario, te permite consultar el texto generado a partir de tus respuestas.\n\nDesde la vista previa, puedes volver a la guía para continuar con la introducción de datos o solicitar que se inserte el texto en el informe o el resumen. Sigue las posibles propuestas de añadir o sustituir que muestre Companion.\n\nLa inserción del texto no sustituye al guardado definitivo del informe o del resumen.\n\nAl abrir y cerrar esta ayuda, se conserva lo que hayas introducido."),
        "documentTemplateGuide_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Utilizar la guía de introducción de datos"),
        "documentTemplatePreview_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite revisar el texto generado a partir de las respuestas introducidas en la guía.\n\nEl texto se puede consultar y seleccionar. Para modificar tus respuestas, haz clic en «Cerrar» para volver a la guía y, a continuación, vuelve a iniciar la vista previa.\n\nHaz clic en «Insertar en el informe» o «Insertar en el informe» para transferir el texto al documento actual. Sigue las posibles sugerencias de añadir o sustituir texto que muestre Companion.\n\nSi no se ha generado ningún texto, el botón de inserción permanecerá desactivado.\n\nTras la inserción, comprueba el contenido del documento y guarda tu balance o tu informe."),
        "documentTemplatePreview_title":
            MessageLookupByLibrary.simpleMessage("Resumen del texto generado"),
        "documentTemplate_assessmentTitle":
            MessageLookupByLibrary.simpleMessage("Elegir un modelo de balance"),
        "documentTemplate_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana muestra las plantillas disponibles para el tipo de documento actual: balance o informe.\n\nHaz clic en una plantilla para abrir la guía de introducción de datos correspondiente. La elección de la plantilla no crea inmediatamente un documento guardado.\n\nSi ya existe un borrador para esta plantilla en el episodio de atención, Companion te ofrece la posibilidad de retomarlo o de empezar una nueva entrada de datos."),
        "documentTemplate_reportTitle": MessageLookupByLibrary.simpleMessage(
            "Elegir una plantilla de informe"),
        "documentTests_help": MessageLookupByLibrary.simpleMessage(
            "Esta vista ampliada permite consultar las pruebas realizadas durante la atención médica y seleccionar aquellas que se incluirán en el informe o el informe en curso.\n\nUtiliza las casillas de selección para incluir o eliminar una prueba del documento. Esta selección no elimina los resultados guardados en Companion.\n\nLas acciones que aparecen en la lista permiten consultar los detalles de los resultados. La selección está disponible cuando se abre un informe o un resumen y la carga ha finalizado.\n\nHaz clic en la cruz para volver al espacio Informes/Resúmenes."),
        "documentTextInsertion_help": MessageLookupByLibrary.simpleMessage(
            "Tu informe o tu informe ya contiene texto. Elige cómo integrar el contenido generado por la guía de introducción de datos.\n\n«Añadir a continuación» conserva el texto existente y añade el contenido generado al final.\n\n«Reemplazar» sustituye todo el texto del área de redacción por el contenido generado. Por lo tanto, los fragmentos que haya introducido en esta área también se sustituirán.\n\n«Cancelar» descarta esta inserción y conserva el texto actual.\n\nPuede consultar y cerrar esta ayuda antes de tomar una decisión."),
        "documentTextInsertion_title":
            MessageLookupByLibrary.simpleMessage("Insertar el texto generado"),
        "documentTitle_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite introducir el título del balance o del informe.\n\nMantén el título propuesto o sustitúyelo por uno que permita identificar fácilmente el documento. El título no puede quedar en blanco.\n\nHaz clic en el botón de validación o pulsa Intro para confirmar. «Cancelar» cierra la ventana sin validar el título.\n\nAl abrir y cerrar esta ayuda, se conserva el texto introducido."),
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
        "episodeFormEditor_requiredField": m24,
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
        "episodeNotes_archiveConfirmation": m25,
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
        "episodeReferents_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite seleccionar al fisioterapeuta de referencia y al médico prescriptor asociados al tratamiento.\n\nSelecciona a los profesionales de las listas. También puedes eliminar una asociación seleccionando la opción «sin profesional».\n\nLos botones de gestión situados a la derecha de las listas permiten acceder a las fichas de los profesionales y de los colaboradores externos, en particular para añadir un profesional que falte.\n\nHaga clic en «Guardar» para aplicar las asignaciones seleccionadas. Los cambios en el fisioterapeuta de referencia se guardan en el historial del tratamiento.\n\n«Cancelar» descarta los cambios de asignación realizados en esta ventana. Las fichas que se hayan creado desde las pantallas de gestión permanecen guardadas."),
        "episodeReferents_title":
            MessageLookupByLibrary.simpleMessage("Modificar los referencias"),
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
        "exchangeDirectoryService_choose": MessageLookupByLibrary.simpleMessage(
            "Seleccionar la carpeta de intercambio ABAK"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Expediente de intercambio de ABAK actualizado"),
        "externalCorrespondentForm_addTitle":
            MessageLookupByLibrary.simpleMessage("Añadir un contacto"),
        "externalCorrespondentForm_editTitle":
            MessageLookupByLibrary.simpleMessage("Modificar el contacto"),
        "externalCorrespondentForm_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite rellenar la ficha de un contacto externo.\n\nEl apellido es obligatorio. Puedes completar el nombre, la profesión, la especialidad, la dirección, el código postal, la ciudad, la dirección de correo electrónico y el número de teléfono.\n\nHaga clic en «Guardar» para validar la ficha. «Cancelar» cierra la ventana sin aplicar los cambios.\n\nAl abrir y cerrar esta ayuda, se conserva lo que haya introducido en el formulario."),
        "externalCorrespondents_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla muestra los contactos externos registrados en Companion. Cada línea indica el nombre del contacto y, cuando se han rellenado, su profesión, su especialidad y su ciudad.\n\nHaz clic en «Añadir» para crear un contacto. Introduce sus datos personales y los datos de contacto pertinentes y, a continuación, haz clic en «Guardar» para añadirlo a la lista. «Cancelar» cierra el formulario sin crear ningún contacto.\n\nEstos contactos pueden seleccionarse, entre otras cosas, como prescriptores en los procesos asistenciales."),
        "externalCorrespondents_title":
            MessageLookupByLibrary.simpleMessage("Corresponsales externos"),
        "externalSpeechToTextProvider_empty":
            MessageLookupByLibrary.simpleMessage(
                "El complemento no ha devuelto ninguna respuesta."),
        "externalSpeechToTextProvider_failure":
            MessageLookupByLibrary.simpleMessage(
                "Error en el complemento de reconocimiento de voz."),
        "externalSpeechToTextProvider_invalid":
            MessageLookupByLibrary.simpleMessage(
                "Respuesta no válida del complemento de reconocimiento de voz."),
        "externalSpeechToTextProvider_noText":
            MessageLookupByLibrary.simpleMessage(
                "El complemento no ha devuelto ningún texto."),
        "externalSpeechToTextProvider_transcription":
            MessageLookupByLibrary.simpleMessage(
                "La transcripción ha fallado."),
        "followUpNoteForm_createTitle":
            MessageLookupByLibrary.simpleMessage("Nueva nota de seguimiento"),
        "followUpNoteForm_editTitle": MessageLookupByLibrary.simpleMessage(
            "Modificar la nota de seguimiento"),
        "followUpNoteForm_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite crear o modificar una nota de seguimiento vinculada al episodio asistencial.\n\nIntroduce un título y el contenido de la nota. Estos dos campos deben contener texto para que la nota se guarde.\n\nAl crearla, haz clic en «Añadir». Al modificarla, haz clic en «Guardar» para conservar los cambios.\n\n«Cancelar» cierra la ventana sin guardar lo que hayas introducido. Puedes abrir y cerrar esta ayuda sin perder el texto que estés redactando."),
        "followUpNotes_help": MessageLookupByLibrary.simpleMessage(
            "Esta vista muestra las notas de seguimiento de la atención, con su fecha, título y un resumen de su contenido.\n\nEl botón «Añadir» permite crear una nota. El icono de edición permite abrir una nota existente para consultarla o modificarla.\n\nUtiliza las casillas de selección para elegir las notas que deseas incluir en el informe o el resumen actual. Al desmarcar una nota, esta se elimina de la selección sin que se borre la nota de seguimiento.\n\nLa selección está disponible cuando se abre un balance o un informe y la carga ha finalizado.\n\nHaz clic en la cruz para cerrar la vista ampliada y volver al espacio Balances/Informes."),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Prefijo ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Comentario"),
        "g_context": MessageLookupByLibrary.simpleMessage("Contexto"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Copiar"),
        "g_file": MessageLookupByLibrary.simpleMessage("Archivo"),
        "g_helpTooltip": MessageLookupByLibrary.simpleMessage("Ver la ayuda"),
        "g_learn_more": MessageLookupByLibrary.simpleMessage("Más información"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Información técnica"),
        "g_technical_informations_copied":
            MessageLookupByLibrary.simpleMessage("Información técnica copiada"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Los pacientes archivados pueden recuperarse hasta la fecha indicada.\nPasada esa fecha, se eliminan automáticamente para no conservar indefinidamente los expedientes que ya no se utilizan.\nEl periodo de conservación puede modificarse en la configuración de Companion."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "Se trata de los dispositivos (teléfono, tableta) que se utilizan para realizar las pruebas.\n- Un dispositivo puede ser utilizado por diferentes personas.\n- Una persona puede tener varios dispositivos.\n\nEsta información permite saber cuál es el origen físico de la información que se transfiere a Companion.\nPuedes crear, modificar o archivar un dispositivo.\n\nPor motivos de trazabilidad, no es posible eliminar un dispositivo.\nSi es necesario, puede restaurar un dispositivo archivado.\n\nSe utiliza un código QR para emparejar un teléfono o una tableta. Debe mostrarse el código QR en el teléfono fijo (Dispositivo > icono correspondiente del dispositivo) y, en el teléfono (o la tableta), acceder a Ajustes > Organización profesional > Dispositivos registrados > Añadir un dispositivo.\n\nAcerca el dispositivo a la pantalla para leer el código QR.Aparecerá un mensaje informándole de que la operación se ha realizado correctamente."),
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
            "Una atención médica corresponde a un episodio de atención.\nAquí encontrarás las diferentes atenciones médicas activas de tu paciente.\nPara asociar un resultado, puedes utilizar un episodio existente o crear uno nuevo.\nUna vez finalizado el episodio, puedes archivarlo."),
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
        "home_correspondents":
            MessageLookupByLibrary.simpleMessage("Corresponsales"),
        "home_create_a_backup": MessageLookupByLibrary.simpleMessage(
            "Crear una copia de seguridad"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Fecha no indicada"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Aparatos"),
        "home_error_while_saving": m26,
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
        "home_other_exercises": m27,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Parámetros"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Camino"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Paciente ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Pacientes"),
        "home_pending_association": m28,
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
        "importHistory_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla muestra el historial de las sesiones de importación registradas en Companion.\n\nCada línea indica la fecha de la sesión, su estado, el número de archivos procesados y el número de resultados importados, ignorados o en conflicto.\n\nEl icono indica, entre otras cosas, una importación en curso, un fallo, errores o conflictos que requieren su atención.\n\nHaga clic en una sesión para consultar sus detalles y comprender mejor el procesamiento de los resultados."),
        "importPatientForm_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite crear un paciente para asociarle los resultados importados desde ABAK Mobile.\n\nIntroduce su nombre y apellidos. Puedes completar su fecha de nacimiento en el formato AAAA-MM-DD e indicar su sexo, o dejar «Sin datos».\n\nSi ha utilizado la lectura de la tarjeta Vitale, compruebe la información prellenada y corríjala si es necesario.\n\nHaga clic en «Crear» para registrar al paciente y seleccionarlo. A continuación, elige la consulta a la que vincular los resultados: la creación del paciente, por sí sola, no completa la vinculación de la importación.\n\n«Cancelar» cierra esta ventana sin crear ningún paciente. Al abrir y cerrar esta ayuda, se conserva lo que hayas introducido."),
        "importPatientForm_title":
            MessageLookupByLibrary.simpleMessage("Paciente nuevo"),
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("archivo"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("archivos"),
        "importResolutionAssistant_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla recoge las importaciones que requieren tu atención: asignación a un paciente pendiente de completar, importación fallida, errores, resultados ignorados o conflictos que deben revisarse.\n\nCada línea indica la fecha de la importación y la información disponible para identificar el expediente en cuestión.\n\nHaga clic en una importación para abrir su seguimiento, consultar las explicaciones y acceder a las acciones propuestas en función de su situación.\n\nLa lista se actualiza al volver del seguimiento de la importación. Si ninguna importación cumple estos criterios, aparecerá un mensaje indicando que no se ha detectado ningún problema."),
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
        "importResolution_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla permite asociar los resultados recibidos desde ABAK Mobile al paciente y al tratamiento correctos en Companion.\n\nConsulta la información de la importación recibida y, a continuación, selecciona al paciente correspondiente de la lista. Si es necesario, crea su ficha con «Nuevo paciente» o «Desde la Tarjeta Sanitaria», cuando el lector esté disponible.\n\nUna vez seleccionado el paciente, elija un tratamiento activo o cree uno nuevo. Un tratamiento archivado debe recuperarse antes de poder seleccionarlo.\n\nCompruebe el paciente y el tratamiento antes de seleccionar este último: su selección valida la asignación y permite continuar con la importación."),
        "importResolution_title":
            MessageLookupByLibrary.simpleMessage("Vincular la importación"),
        "importSessionDetail_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla muestra el seguimiento de una importación recibida en Companion. El mensaje principal indica si la importación se ha realizado correctamente, si es necesario asociarla a un paciente o si presenta algún problema.\n\nCuando sea necesario realizar una asociación, haz clic en «Asociar a un paciente» para seleccionar el expediente al que se van a vincular los resultados.\n\nEl informe y la lista de archivos permiten consultar los detalles del procesamiento y las posibles advertencias.\n\nSi el archivo recibido está incompleto o dañado, solicita un nuevo envío desde ABAK Mobile.\n\nDependiendo de la situación, aparecerá el botón «Eliminar esta importación». Consulta el mensaje de confirmación antes de confirmar la eliminación."),
        "importSessionDetail_title": MessageLookupByLibrary.simpleMessage(
            "Seguimiento de la importación"),
        "information_backupCount": m29,
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
        "information_help": MessageLookupByLibrary.simpleMessage(
            "Esta página muestra la información general de tu instalación de Companion: versión de la aplicación, consulta configurada, presencia del logotipo, sistema utilizado e idioma.\n\nLa sección dedicada al almacenamiento local indica el tamaño de la base de datos, así como el número y el tamaño total de las copias de seguridad guardadas.\n\nLos botones permiten consultar las novedades, la licencia y las advertencias relativas al uso de la aplicación.\n\nEn caso de contactar con el servicio de asistencia, la versión de Companion y el sistema que se muestran aquí pueden ayudar a identificar tu configuración."),
        "information_language": MessageLookupByLibrary.simpleMessage("Idioma"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Aviso legal"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Cargando..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Almacenamiento local"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_new": MessageLookupByLibrary.simpleMessage(
            "Versión 1.1.0, compilación 3\nPosibilidad de dictado de voz para los informes y resúmenes; requiere el módulo gratuito.\nGuardado automático de informes y resúmenes.\nBotón para duplicar informes y resúmenes.\nNotas editables.\nBotón para ver todas las pruebas de un paciente correspondientes a un episodio.\nPlantillas de informes.\nGráfico automático si hay varios resultados para una prueba.\nCreación de un documento en formato docx.\nVisualización de la ayuda utilizada para E72 y E76."),
        "information_newHelp": MessageLookupByLibrary.simpleMessage(
            "En esta página se presentan las novedades y los cambios descritos para Companion.\n\nDesplázate por el texto para consultar toda la información. Puedes seleccionar y copiar un fragmento si es necesario.\n\nUtiliza la flecha de retroceso para volver a la página «Acerca de»."),
        "information_newTitle":
            MessageLookupByLibrary.simpleMessage("Novedades de esta versión"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("No configurado"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "information_office": MessageLookupByLibrary.simpleMessage("Despacho"),
        "information_size": m30,
        "information_system": MessageLookupByLibrary.simpleMessage("Sistema"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Información"),
        "information_totalSize": m31,
        "information_version": m32,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Versión..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("Consultar la licencia"),
        "initialReportDocumentService_associate":
            MessageLookupByLibrary.simpleMessage(
                "Adjuntar un informe inicial en Word"),
        "initialReportDocumentService_unsupported":
            MessageLookupByLibrary.simpleMessage("Plataforma no compatible"),
        "kobus_archived":
            MessageLookupByLibrary.simpleMessage("Companion — archivado"),
        "kobus_archives":
            MessageLookupByLibrary.simpleMessage("Archivos importados"),
        "kobus_attach": MessageLookupByLibrary.simpleMessage(
            "Asignar al paciente seleccionado"),
        "kobus_backupNotice": MessageLookupByLibrary.simpleMessage(
            "La copia de seguridad actual de la base de datos no incluye los archivos KOBUS."),
        "kobus_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "kobus_candidate":
            MessageLookupByLibrary.simpleMessage("Paciente propuesto"),
        "kobus_chooseCandidate": MessageLookupByLibrary.simpleMessage(
            "Selecciona una de las siguientes líneas"),
        "kobus_confirm": MessageLookupByLibrary.simpleMessage(
            "Comprobar y confirmar la importación"),
        "kobus_confirmBody": MessageLookupByLibrary.simpleMessage(
            "¿Importar los expedientes preparados según tus decisiones? Las conciliaciones no resueltas y los expedientes excluidos quedarán al margen. Las fichas existentes no se modificarán."),
        "kobus_consult": MessageLookupByLibrary.simpleMessage(
            "Consultar los datos de KOBUS"),
        "kobus_create": MessageLookupByLibrary.simpleMessage("Crear una ficha"),
        "kobus_creations":
            MessageLookupByLibrary.simpleMessage("Fichas creadas / por crear"),
        "kobus_distinct": MessageLookupByLibrary.simpleMessage(
            "Confirmar a una persona distinta"),
        "kobus_editRejected": MessageLookupByLibrary.simpleMessage(
            "Editar la lista de expedientes rechazados"),
        "kobus_existing": MessageLookupByLibrary.simpleMessage(
            "Pacientes actuales afectados"),
        "kobus_failed": MessageLookupByLibrary.simpleMessage("Fallos técnicos"),
        "kobus_history":
            MessageLookupByLibrary.simpleMessage("Informe de KOBUS"),
        "kobus_imported": MessageLookupByLibrary.simpleMessage("Importados"),
        "kobus_interrupted": MessageLookupByLibrary.simpleMessage(
            "Sin tratar tras la interrupción"),
        "kobus_intro": MessageLookupByLibrary.simpleMessage(
            "Los expedientes se conservan tal y como están. No se crea ningún episodio ni documento clínico original."),
        "kobus_matches": MessageLookupByLibrary.simpleMessage(
            "Conciliaciones que hay que comprobar"),
        "kobus_noShared": MessageLookupByLibrary.simpleMessage(
            "No hay ninguna carpeta compartida en esta exportación"),
        "kobus_ownOrigin":
            MessageLookupByLibrary.simpleMessage("Mis pacientes"),
        "kobus_print": MessageLookupByLibrary.simpleMessage("Imprimir"),
        "kobus_provenance":
            MessageLookupByLibrary.simpleMessage("Procedencia / situación"),
        "kobus_reason": MessageLookupByLibrary.simpleMessage("Motivo"),
        "kobus_rejected": MessageLookupByLibrary.simpleMessage("Rechazados"),
        "kobus_savePdf": MessageLookupByLibrary.simpleMessage("Guardar el PDF"),
        "kobus_scopeReset": MessageLookupByLibrary.simpleMessage(
            "Al cambiar esta opción, se restablecen las decisiones de conciliación."),
        "kobus_select":
            MessageLookupByLibrary.simpleMessage("Elegir el ZIP KOBUS"),
        "kobus_shared": MessageLookupByLibrary.simpleMessage(
            "Recuperar también las carpetas compartidas, si las hay"),
        "kobus_sharedOrigin":
            MessageLookupByLibrary.simpleMessage("Pacientes compartidos"),
        "kobus_skip": MessageLookupByLibrary.simpleMessage("Dejados de lado"),
        "kobus_source":
            MessageLookupByLibrary.simpleMessage("Identidad de KOBUS"),
        "kobus_start":
            MessageLookupByLibrary.simpleMessage("Iniciar la importación"),
        "kobus_stop": MessageLookupByLibrary.simpleMessage(
            "Detener tras el expediente en curso"),
        "kobus_stopping":
            MessageLookupByLibrary.simpleMessage("Se solicita una parada…"),
        "kobus_title": MessageLookupByLibrary.simpleMessage("Importar KOBUS"),
        "kobus_unavailable": MessageLookupByLibrary.simpleMessage(
            "Los datos de KOBUS no están disponibles o no se ha encontrado el archivo."),
        "kobus_unresolved": MessageLookupByLibrary.simpleMessage("Por decidir"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Idioma guardado."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Idioma de la aplicación"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Advertencia"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion es un programa informático diseñado para facilitar la organización, la importación y la consulta de resultados clínicos procedentes del ecosistema ABAK.\n\nNo es un producto sanitario certificado y no sustituye al criterio del profesional sanitario.\n\nLos resultados, puntuaciones, informes e indicadores mostrados deben ser interpretados siempre por un profesional cualificado, teniendo en cuenta la exploración clínica, el contexto del paciente y las recomendaciones vigentes.\n\nEl usuario es el único responsable de sus decisiones clínicas, de la verificación de los datos importados y de que su uso se ajuste a las normas profesionales, reglamentarias y deontológicas aplicables.\n\nABAK Desktop Companion no realiza diagnósticos de forma autónoma, no prescribe ningún tratamiento y no sustituye en ningún caso a una consulta médica o paramédica."),
        "legalNotice_help": MessageLookupByLibrary.simpleMessage(
            "En esta página se recogen las advertencias y la información relativa al uso de Companion.\n\nDesplázate por la página para leer el texto completo.\n\nUtiliza la flecha de retroceso para volver a la página «Acerca de»."),
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
        "localDatabaseRestoreService_anomaly": m33,
        "localDatabaseRestoreService_failure": m34,
        "localDatabaseRestoreService_integrity": m35,
        "localDatabaseRestoreService_missing":
            MessageLookupByLibrary.simpleMessage(
                "No se encuentra el archivo de copia de seguridad."),
        "localDatabaseRestoreService_success":
            MessageLookupByLibrary.simpleMessage(
                "La restauración se ha realizado con éxito."),
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
        "organization_chooseReportHeader": MessageLookupByLibrary.simpleMessage(
            "Elegir un encabezado personalizado"),
        "organization_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla te permite introducir el nombre y los datos de contacto de tu despacho: dirección, código postal, ciudad, teléfono y correo electrónico.\n\nHaz clic en «Guardar datos de contacto» para guardar los cambios antes de salir de la pantalla.\n\nTambién puede elegir una imagen de su ordenador para establecer el logotipo de la consulta. La elección del logotipo se guarda inmediatamente, independientemente de los datos de contacto.\n\nEl botón para eliminar el logotipo le permite eliminar el logotipo utilizado en Companion."),
        "organization_identityTitle":
            MessageLookupByLibrary.simpleMessage("Identidad del centro"),
        "organization_logoRecommendation": MessageLookupByLibrary.simpleMessage(
            "Tamaño recomendado: imagen cuadrada de al menos 300 × 300 píxeles. Formato recomendado: PNG."),
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
        "organization_removeReportHeader":
            MessageLookupByLibrary.simpleMessage("Eliminar el encabezado"),
        "organization_reportHeaderHelpAi": MessageLookupByLibrary.simpleMessage(
            "También puedes pedirle a una herramienta de inteligencia artificial que genere la imagen de tu cabecera siguiendo tus indicaciones."),
        "organization_reportHeaderHelpClose":
            MessageLookupByLibrary.simpleMessage("Cerrar"),
        "organization_reportHeaderHelpContent":
            MessageLookupByLibrary.simpleMessage(
                "La imagen puede incluir, según tu elección, tu logotipo, el nombre del centro, tus datos de contacto y cualquier otro elemento gráfico que desees que aparezca en tus informes."),
        "organization_reportHeaderHelpFormat": MessageLookupByLibrary.simpleMessage(
            "Para obtener un resultado óptimo en los informes de ABAK, utiliza una imagen con un tamaño de 200 × 30 mm, es decir, aproximadamente 2362 × 354 píxeles a 300 ppp. Se recomienda el formato PNG."),
        "organization_reportHeaderHelpIntro": MessageLookupByLibrary.simpleMessage(
            "Puedes diseñar libremente tu encabezado con la herramienta que prefieras y, a continuación, guardarlo como imagen."),
        "organization_reportHeaderHelpReplacement":
            MessageLookupByLibrary.simpleMessage(
                "La información que aparece en la imagen sustituye al encabezado estándar generado por ABAK (logotipo y datos de contacto del centro)."),
        "organization_reportHeaderHelpTitle":
            MessageLookupByLibrary.simpleMessage(
                "Crear un encabezado personalizado"),
        "organization_reportHeaderHelpTools": MessageLookupByLibrary.simpleMessage(
            "Si no estás acostumbrado a utilizar herramientas gráficas, puedes recurrir, por ejemplo, a LibreOffice Draw, Microsoft PowerPoint, Apple Keynote o Canva. Esta lista se ofrece únicamente a modo de ejemplo y no es exhaustiva."),
        "organization_reportHeaderHelpTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Ayuda para crear un encabezado personalizado"),
        "organization_reportHeaderRecommendation":
            MessageLookupByLibrary.simpleMessage(
                "Tamaño recomendado: 200 × 30 mm (aproximadamente 2362 × 354 píxeles a 300 ppp). Formato recomendado: PNG."),
        "organization_reportHeaderRemoved":
            MessageLookupByLibrary.simpleMessage(
                "Se ha eliminado el encabezado personalizado."),
        "organization_reportHeaderSaved": MessageLookupByLibrary.simpleMessage(
            "Encabezado personalizado guardado."),
        "organization_reportHeaderTitle": MessageLookupByLibrary.simpleMessage(
            "Encabezado personalizado de los informes"),
        "organization_reportIntroductionHelp": MessageLookupByLibrary.simpleMessage(
            "Texto libre que se utiliza al principio de los informes. Si este campo está vacío, se utilizará «Doctor»."),
        "organization_reportIntroductionHint":
            MessageLookupByLibrary.simpleMessage("Doctor"),
        "organization_reportIntroductionLabel":
            MessageLookupByLibrary.simpleMessage(
                "Fórmula introductoria de los informes"),
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
        "pairPhone_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana muestra la información que permite a ABAK Mobile encontrar Companion en la red local.\n\nConecta el teléfono o la tableta y el ordenador a la misma red local y, a continuación, escanea este código QR desde la función de emparejamiento con Companion en ABAK Mobile.\n\nEl código QR contiene la dirección de red y el puerto de comunicación de este ordenador. Esta información también aparece debajo del código.\n\nMantenga Companion abierto en el ordenador durante los intercambios. Si cambia la dirección de red del ordenador, vuelva a abrir esta ventana y escanee el nuevo código.\n\nLa visualización de este código QR no activa por sí sola el envío de resultados."),
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
        "patientClinicalDataEdit_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla permite completar los datos administrativos y el perfil del paciente.\n\nPuedes introducir su identificador sanitario, la fuente de su identidad, su número de teléfono, su dirección de correo electrónico y su dirección postal.\n\nEl perfil incluye el lado dominante, la profesión, la actividad deportiva, la estatura en centímetros y el peso en kilogramos.\n\nHaz clic en «Guardar» para guardar los cambios y volver a la ficha del paciente. Si vuelves atrás sin guardar, se perderán los cambios."),
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
        "patientDetail_editCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite modificar la información relativa a la atención del paciente.\n\nPuede corregir la patología o el motivo de la atención, completar el texto inicial y seleccionar el profesional de referencia, así como el médico prescriptor.\n\nEs necesario introducir la patología para que se guarden los cambios.\n\nHaga clic en «Guardar» para validar los cambios. «Cancelar» cierra la ventana sin aplicarlos.\n\nAl abrir y cerrar esta ayuda, se conserva lo que haya introducido en el formulario."),
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
        "patientDetail_newCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite crear una nueva atención para el paciente seleccionado.\n\nIntroduce la patología o el motivo de la atención. Esta información es necesaria para crear el episodio.\n\nPuede completar el texto inicial y seleccionar un médico de referencia. Estos datos son opcionales.\n\nHaga clic en «Crear» para guardar el episodio. «Cancelar» cierra la ventana sin crearlo.\n\nAl abrir y cerrar esta ayuda, se conserva lo que haya introducido en el formulario."),
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
        "patientDocuments_authorization": MessageLookupByLibrary.simpleMessage(
            "Hay que volver a autorizar la carpeta. Selecciona la carpeta compartida definida en la configuración."),
        "patientDocuments_chooseRoot": MessageLookupByLibrary.simpleMessage(
            "Seleccionar la carpeta compartida"),
        "patientDocuments_error": MessageLookupByLibrary.simpleMessage(
            "No se puede preparar ni abrir el archivo. Comprueba si está disponible y cuáles son tus derechos de acceso, y vuelve a intentarlo."),
        "patientDocuments_open": MessageLookupByLibrary.simpleMessage(
            "Abrir el expediente del paciente ABAK"),
        "patientDocuments_retry":
            MessageLookupByLibrary.simpleMessage("Inténtalo de nuevo"),
        "patientDocuments_settingsHelp": MessageLookupByLibrary.simpleMessage(
            "Un expediente por paciente, que contiene «Balance», «Informe» y «Otros». Se crea al abrir la ficha; los archivos existentes no se trasladan."),
        "patientDocuments_structure":
            MessageLookupByLibrary.simpleMessage("Balance / Informe / Otro"),
        "patientDocuments_title":
            MessageLookupByLibrary.simpleMessage("Documentación del paciente"),
        "patientDocuments_unconfigured": MessageLookupByLibrary.simpleMessage(
            "No hay ninguna carpeta de almacenamiento definida. Elige la carpeta común para todos los pacientes."),
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
        "patientForm_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite introducir o corregir los datos del paciente.\n\nEl apellido y el nombre son campos obligatorios. Puedes seleccionar la fecha de nacimiento en el calendario e introducir el sexo, o dejar el valor «Sin especificar».\n\nHaga clic en «Guardar» para validar los cambios. Si el formulario está abierto en modo de creación, el botón «Crear» permite crear la ficha.\n\n«Cancelar» cierra la ventana sin aplicar los cambios. Al abrir y cerrar esta ayuda, se conserva lo introducido en el formulario."),
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
        "patientList_archiveConfirmation": m36,
        "patientList_archiveSuccess": m37,
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
        "patientList_error": m38,
        "patientList_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla te permite localizar a tus pacientes y acceder a su expediente.\n\nLos botones «Activos» y «Archivados» te permiten seleccionar la lista que se muestra. El número indicado corresponde al total de pacientes de cada categoría.\n\nPara buscar a un paciente en la lista mostrada, introduce todo o parte de su apellido o nombre en el campo de búsqueda. Haz clic en su línea para abrir su expediente.\n\nEl botón «Nuevo paciente» abre la pantalla de creación de un paciente.\n\nEn el caso de un paciente activo, el icono del lápiz permite modificar sus datos personales. El icono de archivo permite eliminarlo de la lista de pacientes activos tras la confirmación.\n\nEn la lista de pacientes archivados, el icono de restauración permite volver a incluir a un paciente en la lista de pacientes activos. Una ayuda específica, accesible junto a la fecha de archivo, detalla las condiciones de conservación."),
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
        "patientList_restoreSuccess": m39,
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
        "patientNew_attachVitaleSuccess": m40,
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
        "patientNew_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla permite crear un paciente en ABAK Companion.\n\nIntroduce su nombre y apellidos: estos dos datos son obligatorios. Puedes completar su fecha de nacimiento con ayuda del calendario e indicar su sexo.\n\nEl botón de lectura de la tarjeta Vitale permite recuperar la identidad del paciente cuando el lector y el módulo de lectura están disponibles. Si aparecen varios beneficiarios, seleccione a la persona en cuestión y, a continuación, compruebe los datos que se muestran. También es posible introducir los datos manualmente.\n\nSi Companion detecta que ya existe un paciente, comprueba la información propuesta antes de continuar para evitar duplicados. Es posible que se proponga la recuperación de un paciente archivado.\n\nHaz clic en «Crear paciente» para guardar la ficha, o en «Cancelar» para salir sin crear ningún paciente."),
        "patientNew_identificationCountriesHelp":
            MessageLookupByLibrary.simpleMessage(
                "La lectura de la tarjeta Vitale que ofrece Companion se aplica actualmente en Francia. Permite obtener datos de identidad para facilitar la creación de la ficha del paciente.\n\nABAK Companion desea ampliar este proceso a los medios de identificación utilizados en otros países. Las tarjetas, los identificadores y los servicios sanitarios funcionan de forma diferente en otros países: su gestión aún no está integrada en Companion. Sigue estando disponible la introducción manual de datos.\n\nQueremos explorar estas posibilidades con los fisioterapeutas que utilizan ABAK. ¿Te gustaría colaborar con nosotros en tu país? Su conocimiento de las prácticas locales y su participación en las pruebas nos ayudarán a definir una solución útil y adaptada.\n\nLas mejoras se desarrollarán progresivamente con los profesionales voluntarios, en función de las necesidades expresadas, las posibilidades técnicas y las autorizaciones necesarias."),
        "patientNew_identificationCountriesTitle":
            MessageLookupByLibrary.simpleMessage(
                "Identificación de los pacientes por países"),
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
            MessageLookupByLibrary.simpleMessage("Lea la tarjeta sanitaria"),
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
        "patientNew_restoreSuccess": m41,
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
        "practitionerList_archiveConfirmation": m42,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "La papelera de los fisioterapeutas está vacía por el momento."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage("Archivar al fisioterapeuta"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archivados"),
        "practitionerList_archivedOn": m43,
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
        "practitionerList_error": m44,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "No hay fisioterapeutas archivados"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "No hay fisioterapeutas registrados"),
        "practitionerList_professionalId": m45,
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
        "practitionerNew_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite crear o modificar la ficha de un profesional sanitario.\n\nEl nombre que aparece es obligatorio: permite identificar al profesional sanitario en Companion. También puedes introducir su nombre, apellidos, número de identificación profesional, dirección de correo electrónico y número de teléfono.\n\nHaga clic en «Crear» para añadir un profesional sanitario o en «Guardar» para confirmar los cambios en una ficha ya existente.\n\n«Cancelar» cierra la ventana sin aplicar los cambios. Al abrir y cerrar esta ayuda, se conserva lo que haya introducido en el formulario."),
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
        "practitionerQr_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana muestra el código QR del perfil profesional del profesional sanitario, junto con su nombre y el nombre de la consulta.\n\nEscanea este código QR desde ABAK Mobile para identificar al profesional sanitario de este centro. Comprueba que el nombre que aparece coincide con el del profesional en cuestión.\n\nEste código QR sirve para transmitir la información de identificación del perfil profesional; su visualización no activa ninguna transferencia de resultados.\n\nCierra esta ventana para volver a la lista de profesionales."),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("Perfil profesional de ABAK"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Escanea este código QR desde ABAK Mobile para añadir automáticamente este perfil profesional."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("archivado"),
        "practitionerSelector_error": m46,
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
        "referringPractitionerHistoryDialog_archivedPractitioner": m47,
        "referringPractitionerHistoryDialog_close":
            MessageLookupByLibrary.simpleMessage("Cerrar"),
        "referringPractitionerHistoryDialog_currentPractitioner":
            MessageLookupByLibrary.simpleMessage("Responsable actual"),
        "referringPractitionerHistoryDialog_fromTo": m48,
        "referringPractitionerHistoryDialog_loadHistoryError": m49,
        "referringPractitionerHistoryDialog_noHistory":
            MessageLookupByLibrary.simpleMessage(
                "Aún no se ha registrado ningún fisioterapeuta de referencia para este episodio."),
        "referringPractitionerHistoryDialog_since": m50,
        "referringPractitionerHistory_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana muestra a los profesionales que han sido designados como responsables de este episodio asistencial.\n\nCada línea indica el nombre del profesional y su periodo de asignación. La indicación «Responsable actual» identifica al profesional asociado actualmente al episodio.\n\nLa indicación «archivado» significa que la ficha del profesional está archivada; su nombre sigue siendo visible en el historial.\n\nEsta ventana solo permite consultar el historial. Ciérrela para volver al episodio de atención."),
        "referringPractitionerHistory_title":
            MessageLookupByLibrary.simpleMessage(
                "Historial de los fisioterapeutas de referencia"),
        "refreshDashboard": MessageLookupByLibrary.simpleMessage(
            "Actualizar el panel de control"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Archivo de informes"),
        "reportDraft_help": MessageLookupByLibrary.simpleMessage(
            "El texto que se muestra corresponde a un trabajo en curso que se ha guardado automáticamente. Puedes conservarlo, modificarlo o eliminarlo antes de guardar tu informe."),
        "reportDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Comprender el borrador del informe"),
        "reportHistory_help": MessageLookupByLibrary.simpleMessage(
            "Esta vista muestra los informes guardados para la gestión de casos, con su título y fecha.\n\nLas acciones de cada línea permiten modificar un informe, duplicarlo o moverlo a los documentos archivados.\n\nCuando se abre un informe para modificarlo, utiliza la acción de actualización para guardar los cambios. Los comandos disponibles también permiten deshacer los cambios o volver al borrador.\n\nEl traslado a los documentos archivados no supone una eliminación definitiva.\n\nHaz clic en la cruz para cerrar la vista ampliada y volver al espacio «Balances/Informes»."),
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
        "resultDetail_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla muestra la información de un resultado importado desde ABAK Mobile: paciente, fecha de realización, puntuación y, cuando estén disponibles, la ayuda utilizada, la identidad del profesional y el dispositivo de origen.\n\nPuedes consultar el informe detallado y las mediciones complementarias enviadas por el centro.\n\nEl campo «Comentario clínico» permite añadir o modificar sus observaciones. Haga clic en «Guardar» para conservarlas antes de salir de la pantalla.\n\nLa sección dedicada a la importación indica el estado de sincronización y la fecha de la última modificación del resultado.\n\nEl icono de archivo permite archivar este resultado tras su confirmación."),
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
        "settings_databaseResetError": m51,
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
        "settings_exportAction":
            MessageLookupByLibrary.simpleMessage("Exportar"),
        "settings_exportCancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "settings_exportCancelled":
            MessageLookupByLibrary.simpleMessage("Exportación cancelada"),
        "settings_exportChooseDestination":
            MessageLookupByLibrary.simpleMessage(
                "Seleccionar la carpeta de destino"),
        "settings_exportCompleted": m52,
        "settings_exportCompletedWithErrors": m53,
        "settings_exportDataDescription": MessageLookupByLibrary.simpleMessage(
            "Se creará un archivo que contendrá la información de tus pacientes, así como sus informes y evaluaciones."),
        "settings_exportFailed": MessageLookupByLibrary.simpleMessage(
            "No es posible exportar los datos"),
        "settings_exportIncludeArchivedPatients":
            MessageLookupByLibrary.simpleMessage(
                "Incluir a los pacientes archivados"),
        "settings_exportMyData":
            MessageLookupByLibrary.simpleMessage("Exportar mis datos"),
        "settings_exportPatientBirthDate":
            MessageLookupByLibrary.simpleMessage("Fecha de nacimiento"),
        "settings_exportPatientFemale":
            MessageLookupByLibrary.simpleMessage("Femenino"),
        "settings_exportPatientFirstName":
            MessageLookupByLibrary.simpleMessage("Nombre"),
        "settings_exportPatientLastName":
            MessageLookupByLibrary.simpleMessage("Nombre"),
        "settings_exportPatientMale":
            MessageLookupByLibrary.simpleMessage("Masculino"),
        "settings_exportPatientSex":
            MessageLookupByLibrary.simpleMessage("Sexo"),
        "settings_exportPatientUnknown":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "settings_exportPatientUnknownFemale":
            MessageLookupByLibrary.simpleMessage("Sin datos"),
        "settings_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla agrupa las funciones de instalación, diagnóstico y mantenimiento de Companion. Utilícelas siguiendo las instrucciones de la documentación de ABAK o de un técnico.\n\nLa sección «Configuración» permite consultar, abrir o modificar la carpeta utilizada para el intercambio de archivos.\n\nLa sección «Diagnóstico» permite acceder a las comprobaciones del dispositivo de lectura de la tarjeta Vitale.\n\nLa sección «Mantenimiento» permite abrir el asistente de resolución de problemas de importación, importar manualmente un archivo ABAK y acceder a la gestión de copias de seguridad.\n\nEl restablecimiento de la base de datos elimina los datos locales. Esta operación está reservada a situaciones de asistencia técnica: lee atentamente los mensajes de confirmación antes de continuar."),
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
        "speechDictationButton_audio": MessageLookupByLibrary.simpleMessage(
            "No hay ninguna grabación de audio disponible."),
        "speechDictationButton_close":
            MessageLookupByLibrary.simpleMessage("Cerrar"),
        "speechDictationButton_dictate":
            MessageLookupByLibrary.simpleMessage("Ira"),
        "speechDictationButton_download":
            MessageLookupByLibrary.simpleMessage("Descargar el módulo"),
        "speechDictationButton_failure": m54,
        "speechDictationButton_information": MessageLookupByLibrary.simpleMessage(
            "El dictado por voz requiere la instalación del módulo opcional ABAK Dictado por voz.\n\nEste módulo es gratuito y funciona de forma local en tu ordenador, sin enviar las grabaciones de voz a Internet.\n\nLa descarga ocupa aproximadamente 1,5 GB."),
        "speechDictationButton_stop":
            MessageLookupByLibrary.simpleMessage("Detener el dictado"),
        "speechDictationButton_title":
            MessageLookupByLibrary.simpleMessage("Dictado por voz"),
        "speechRecordingService_permission":
            MessageLookupByLibrary.simpleMessage(
                "No está permitido el acceso al micrófono."),
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
        "vitaleBeneficiarySelector_help": MessageLookupByLibrary.simpleMessage(
            "Esta ventana permite seleccionar a la persona en cuestión cuando se proponen varios beneficiarios tras la lectura de la tarjeta Vitale.\n\nComprueba el apellido, el nombre y la fecha de nacimiento, si está disponible, y, a continuación, haz clic en la línea del beneficiario deseado.\n\nAl seleccionar un beneficiario, se cierra esta ventana y se transmite la identidad elegida al siguiente paso.\n\n«Cancelar» cierra la ventana sin seleccionar ningún beneficiario."),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage("Selecciona un beneficiario"),
        "vitaleDiagnostic_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla permite comprobar el funcionamiento del dispositivo de lectura de la tarjeta Vitale.\n\nEn Windows, la sección dedicada al módulo indica su estado y permite actualizar esta información.\n\nInicie una lectura con el lector conectado y la tarjeta insertada. Si aparecen varios beneficiarios, seleccione a la persona en cuestión para consultar la información leída.\n\nLos mensajes que se muestran permiten comprender un posible fallo y pueden comunicarse al servicio de asistencia.\n\nLa sección «Diagnóstico avanzado» ofrece una prueba técnica de comunicación con la tarjeta. Utilícela siguiendo las instrucciones de la documentación de ABAK o de un técnico.\n\nEsta pantalla sirve para el diagnóstico: la lectura de una identidad no crea una ficha de paciente."),
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
        "vitaleIdentity_help": MessageLookupByLibrary.simpleMessage(
            "Esta pantalla permite leer los datos de un beneficiario a partir de una tarjeta Vitale, siempre que el lector y el módulo de lectura estén disponibles.\n\nLa lectura comienza al abrir la pantalla. Puede reiniciarla con el botón de lectura. Si hay varios beneficiarios en la tarjeta, seleccione a la persona en cuestión.\n\nCompruebe el apellido, el nombre, la fecha de nacimiento y el resto de datos que se muestran. El número de identificación aparece como «detectado» o «no disponible», sin que se muestre íntegramente.\n\nCuando la identidad sea válida, el botón de creación del paciente permite enviar esta información al formulario de creación.\n\nSi no hay ninguna identidad disponible, consulte el mensaje que aparece y compruebe el dispositivo de lectura antes de volver a intentarlo. Puede volver a la pantalla anterior para realizar una introducción manual."),
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
            MessageLookupByLibrary.simpleMessage("No disponible"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Utilizar para crear un paciente"),
        "walkingAid_cane": MessageLookupByLibrary.simpleMessage("Bastón"),
        "walkingAid_label":
            MessageLookupByLibrary.simpleMessage("Ayuda utilizada"),
        "walkingAid_none": MessageLookupByLibrary.simpleMessage("Ninguna"),
        "walkingAid_other": MessageLookupByLibrary.simpleMessage("Otros"),
        "walkingAid_rollatorFourWheels":
            MessageLookupByLibrary.simpleMessage("Andador de 4 ruedas"),
        "walkingAid_walkerTwoWheels":
            MessageLookupByLibrary.simpleMessage("Andador de dos ruedas")
      };
}
