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

  static String m0(error) => "Error al guardar: ${error}";

  static String m1(count) => "${count} otro(s) ejercicio(s)";

  static String m2(count) => "${count} asociación(es) pendientes";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "dashboardTitle":
            MessageLookupByLibrary.simpleMessage("Centro clínico local ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Dirección"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Puerto"),
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
        "home_error_while_saving": m0,
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
        "home_other_exercises": m1,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Parámetros"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Camino"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Paciente ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Pacientes"),
        "home_pending_association": m2,
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
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Idioma guardado."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Idioma de la aplicación"),
        "loading": MessageLookupByLibrary.simpleMessage("Cargando..."),
        "modify": MessageLookupByLibrary.simpleMessage("Editar"),
        "noDirectoryDefined": MessageLookupByLibrary.simpleMessage(
            "No se ha definido ninguna carpeta"),
        "ok": MessageLookupByLibrary.simpleMessage("De acuerdo"),
        "open": MessageLookupByLibrary.simpleMessage("Abrir"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Vincular un teléfono"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Vincular un teléfono"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Escanea este código QR desde ABAK Mobile para configurar automáticamente la conexión con Desktop."),
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Crear un profesional"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Lista de profesionales"),
        "refreshDashboard": MessageLookupByLibrary.simpleMessage(
            "Actualizar el panel de control"),
        "reset": MessageLookupByLibrary.simpleMessage("Restablecer"),
        "smartCardDiagnostic": MessageLookupByLibrary.simpleMessage(
            "Diagnóstico de la Tarjeta Sanitaria"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Configuración del usuario"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Configuración de usuario")
      };
}
