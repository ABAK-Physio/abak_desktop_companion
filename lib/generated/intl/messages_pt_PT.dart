// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt_PT locale. All the
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
  String get localeName => 'pt_PT';

  static String m0(error) => "Erro ao guardar: ${error}";

  static String m1(count) => "${count} outro(s) exercício(s)";

  static String m2(count) => "${count} associação(ões) pendentes";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "close": MessageLookupByLibrary.simpleMessage("Fechar"),
        "dashboardTitle":
            MessageLookupByLibrary.simpleMessage("Centro clínico local ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Morada"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Porto"),
        "exchangeDirectoryReset":
            MessageLookupByLibrary.simpleMessage("Pasta de troca reiniciada"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Dossiê de intercâmbio ABAK atualizado"),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Prefixo ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Fechar"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Comentário"),
        "g_context": MessageLookupByLibrary.simpleMessage("Contexto"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Copiar"),
        "g_file": MessageLookupByLibrary.simpleMessage("Ficheiro"),
        "g_learn_more": MessageLookupByLibrary.simpleMessage("Saiba mais"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Informações técnicas"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Informações técnicas copiadas"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Os doentes arquivados podem ser recuperados até à data indicada.\nApós essa data, são eliminados automaticamente, para que os registos não utilizados não sejam conservados indefinidamente.\nO período de conservação pode ser alterado nas definições do Companion."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "Pode criar, alterar ou arquivar um dispositivo.\n\nPor motivos de rastreabilidade, não é possível eliminar um dispositivo.\nSe necessário, pode restaurá-lo.\n\nO código QR é utilizado para emparelhar um telemóvel ou um tablet."),
        "help_device_list_title":
            MessageLookupByLibrary.simpleMessage("Lista de aparelhos"),
        "help_donnees_cliniques_patient": MessageLookupByLibrary.simpleMessage(
            "Aqui encontrará informações adicionais sobre o seu doente"),
        "help_home": MessageLookupByLibrary.simpleMessage(
            "Este ecrã é o ecrã principal do ABAK Companion.\n\nÉ composto por:\n\n1) uma barra superior que lhe fornece informações sobre: \n - o número de doentes ativos e arquivados.\n  - o número de alertas em curso.\n\nNas definições, pode indicar o nome da sua instituição e adicionar o seu logótipo.\n\n2) «Importações recentes» indica-lhe os últimos ficheiros de resultados importados a partir do ABAK Mobile.\n\n3) «Estado do sistema» indica-lhe um eventual problema e a data do último backup.\n\n4) «Novos resultados do ABAK a associar» mostra-lhe os resultados que foram enviados a partir do ABAK Mobile, mas que ainda não foram atribuídos a um doente no ABAK Companion.\n\n5) «Alerta do sistema» informa-o sobre a natureza de um problema.\n\n6) «Ação rápida» permite-lhe aceder ao histórico de todas as suas importações e criar um novo registo."),
        "help_home_active_archived_patients_content":
            MessageLookupByLibrary.simpleMessage("Os doentes ativos"),
        "help_home_active_archived_patients_title":
            MessageLookupByLibrary.simpleMessage(
                "Pacientes ativos e arquivados"),
        "help_home_import_assignment_content":
            MessageLookupByLibrary.simpleMessage(
                "Assim que terminar o seu exercício no ABAK Mobile..."),
        "help_home_import_assignment_title":
            MessageLookupByLibrary.simpleMessage(
                "Recuperação de um resultado e atribuição a um doente"),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Aqui encontra os dados de identificação do seu doente"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite: \n - A seleção do idioma. \n - A definição do período de conservação dos registos médicos arquivados. \n - A ativação do modo especialista. \n - O acesso ao ecrã «Instituição» para introduzir o nome da sua instituição e o respetivo logótipo"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite-lhe adicionar um novo profissional de saúde e alterar as informações que lhe dizem respeito.\n\nColocar na lixeira não elimina o profissional de saúde. Por motivos de rastreabilidade, não é possível eliminar um profissional de saúde.\n\nAo visualizar o código QR, pode criar automaticamente o perfil do profissional de saúde para o seu estabelecimento no telemóvel ou tablet deste."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Aqui encontrará os diferentes tratamentos do seu doente. Pode utilizar um episódio já existente ou criar um novo."),
        "home_abak_exercice":
            MessageLookupByLibrary.simpleMessage("Exercício ABAK"),
        "home_abak_file": MessageLookupByLibrary.simpleMessage("Ficheiro ABAK"),
        "home_accueil": MessageLookupByLibrary.simpleMessage("Página inicial"),
        "home_action_required": MessageLookupByLibrary.simpleMessage(
            "Ação necessária: associar este processo a um doente."),
        "home_already_imported":
            MessageLookupByLibrary.simpleMessage("Já importado"),
        "home_an_intervention_is_necessary":
            MessageLookupByLibrary.simpleMessage(
                "É necessária uma intervenção"),
        "home_archives": MessageLookupByLibrary.simpleMessage("Arquivos"),
        "home_attention": MessageLookupByLibrary.simpleMessage("Atenção"),
        "home_backup_successfully_created":
            MessageLookupByLibrary.simpleMessage(
                "A cópia de segurança foi criada com sucesso."),
        "home_balance_sheet_date":
            MessageLookupByLibrary.simpleMessage("Data do balanço"),
        "home_conflict_detected":
            MessageLookupByLibrary.simpleMessage("Detetado um conflito"),
        "home_create_a_backup": MessageLookupByLibrary.simpleMessage(
            "Criar uma cópia de segurança"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Data não indicada"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Aparelhos"),
        "home_error_while_saving": m0,
        "home_everything_is_working_normally":
            MessageLookupByLibrary.simpleMessage(
                "Tudo está a funcionar normalmente"),
        "home_expert_comment": MessageLookupByLibrary.simpleMessage(
            "Este ecrã é o ecrã principal do Companion."),
        "home_failure": MessageLookupByLibrary.simpleMessage("Fracasso"),
        "home_fermer": MessageLookupByLibrary.simpleMessage("Fechar"),
        "home_file": MessageLookupByLibrary.simpleMessage("Ficheiro"),
        "home_historique": MessageLookupByLibrary.simpleMessage("Histórico"),
        "home_home": MessageLookupByLibrary.simpleMessage("Início"),
        "home_import_history":
            MessageLookupByLibrary.simpleMessage("Histórico de importações"),
        "home_imports_interrupted_or_in_progress":
            MessageLookupByLibrary.simpleMessage(
                "Importações interrompidas ou em curso"),
        "home_imports_with_errors":
            MessageLookupByLibrary.simpleMessage("Importações com erros"),
        "home_information": MessageLookupByLibrary.simpleMessage("Sobre"),
        "home_invalid_file_path": MessageLookupByLibrary.simpleMessage(
            "Caminho do ficheiro inválido:"),
        "home_ipAddressNotFound":
            MessageLookupByLibrary.simpleMessage("Endereço IP não encontrado"),
        "home_ipAddressNotFoundMessage": MessageLookupByLibrary.simpleMessage(
            "Não é possível determinar o endereço IP local do computador.\n\nVerifique se o computador está ligado à rede local."),
        "home_large_number_of_archived_patients":
            MessageLookupByLibrary.simpleMessage(
                "Número significativo de doentes arquivados"),
        "home_large_sqlite_database": MessageLookupByLibrary.simpleMessage(
            "Base de dados SQLite de grande volume"),
        "home_last_backup":
            MessageLookupByLibrary.simpleMessage("Último backup"),
        "home_last_old_backup":
            MessageLookupByLibrary.simpleMessage("Último backup anterior"),
        "home_link_to_a_care_plan":
            MessageLookupByLibrary.simpleMessage("Associar a um tratamento"),
        "home_more_7_days":
            MessageLookupByLibrary.simpleMessage("Mais de 7 dias"),
        "home_new_abak_results_to_be_linked":
            MessageLookupByLibrary.simpleMessage(
                "Novos resultados do ABAK a associar a um doente"),
        "home_no_abak_result_to_associate":
            MessageLookupByLibrary.simpleMessage(
                "Não há resultados ABAK para associar."),
        "home_no_alert_detected":
            MessageLookupByLibrary.simpleMessage("Não foram detetados alertas"),
        "home_no_imports_recorded": MessageLookupByLibrary.simpleMessage(
            "Não há importações registadas."),
        "home_no_pending_imports": MessageLookupByLibrary.simpleMessage(
            "Não há importações pendentes"),
        "home_no_saved_backup": MessageLookupByLibrary.simpleMessage(
            "Não há nenhuma cópia de segurança registada"),
        "home_not_specified": MessageLookupByLibrary.simpleMessage("informada"),
        "home_octets": MessageLookupByLibrary.simpleMessage("Oitetos"),
        "home_other_exercises": m1,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Parâmetros"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Caminho"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Paciente ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Pacientes"),
        "home_pending_association": m2,
        "home_practitioners":
            MessageLookupByLibrary.simpleMessage("profissionais"),
        "home_quick_actions":
            MessageLookupByLibrary.simpleMessage("Ações rápidas"),
        "home_receents_imports":
            MessageLookupByLibrary.simpleMessage("Importações recentes"),
        "home_recent_restoration_detected":
            MessageLookupByLibrary.simpleMessage(
                "Foi detetada uma restauração recente"),
        "home_results": MessageLookupByLibrary.simpleMessage("Resultados"),
        "home_select_qr_code": MessageLookupByLibrary.simpleMessage(
            "Digitalize este código QR a partir da aplicação ABAK Mobile para configurar automaticamente a ligação ao Desktop."),
        "home_settings": MessageLookupByLibrary.simpleMessage("Assistência"),
        "home_size": MessageLookupByLibrary.simpleMessage("Tamanho"),
        "home_solve": MessageLookupByLibrary.simpleMessage("Resolver"),
        "home_success": MessageLookupByLibrary.simpleMessage("Sucesso"),
        "home_system_alert":
            MessageLookupByLibrary.simpleMessage("Alerta do sistema"),
        "home_system_status":
            MessageLookupByLibrary.simpleMessage("Estado do sistema"),
        "home_technical_information":
            MessageLookupByLibrary.simpleMessage("Informações técnicas"),
        "home_this_file_had_already_been_imported":
            MessageLookupByLibrary.simpleMessage(
                "Este ficheiro já tinha sido importado. Não foram adicionados dados."),
        "home_to_be_verified":
            MessageLookupByLibrary.simpleMessage("a verificar"),
        "home_to_do_list": MessageLookupByLibrary.simpleMessage("A fazer"),
        "home_unable_to_load_recent_imports":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível carregar as importações recentes."),
        "home_unreadable_abak_import":
            MessageLookupByLibrary.simpleMessage("Importação ABAK ilegível."),
        "home_unsuccessful": MessageLookupByLibrary.simpleMessage("Em impasse"),
        "home_verify": MessageLookupByLibrary.simpleMessage("Verificar"),
        "home_very_large_backups": MessageLookupByLibrary.simpleMessage(
            "Cópias de segurança muito volumosas"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Língua registada."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Idioma da aplicação"),
        "loading": MessageLookupByLibrary.simpleMessage("A carregar..."),
        "modify": MessageLookupByLibrary.simpleMessage("Editar"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Nenhuma pasta definida"),
        "ok": MessageLookupByLibrary.simpleMessage("Tudo bem"),
        "open": MessageLookupByLibrary.simpleMessage("Abrir"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Associar um telemóvel"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Associar um telemóvel"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Digitalize este código QR a partir da aplicação ABAK Mobile para configurar automaticamente a ligação ao Desktop."),
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Criar um profissional"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Lista de profissionais"),
        "refreshDashboard": MessageLookupByLibrary.simpleMessage(
            "Atualizar o painel de controlo"),
        "reset": MessageLookupByLibrary.simpleMessage("Reiniciar"),
        "smartCardDiagnostic": MessageLookupByLibrary.simpleMessage(
            "Diagnóstico do Cartão de Saúde"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Definições do utilizador"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Definições do utilizador")
      };
}
