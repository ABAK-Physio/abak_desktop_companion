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

  static String m0(careEpisodeId) =>
      "Não foi possível encontrar o doente para o episódio de cuidados ${careEpisodeId}.";

  static String m1(height) => "${height} cm";

  static String m2(weight) => "${weight} kg";

  static String m3(age) => "${age} anos";

  static String m4(size) => "${size}";

  static String m5(date) => "Arquivado em ${date}";

  static String m6(monthYear) => "Acolhimento aberto em ${monthYear}";

  static String m7(title) =>
      "O extrato «${title}» deixará de ser apresentado no histórico.";

  static String m8(title) =>
      "O relatório «${title}» será colocado na lixeira. Poderá ser recuperado posteriormente.";

  static String m9(patientName, title) => "Bilan_${patientName}_{títle}";

  static String m10(title) => "Cópia de ${title}";

  static String m11(title) =>
      "O balanço «${title}» será definitivamente eliminado. Esta ação é irreversível.";

  static String m12(title) =>
      "O relatório «${title}» será eliminado definitivamente. Esta ação é irreversível.";

  static String m13(path) =>
      "\"careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": \"Le dossier configuré n’est pas accessible ou son autorisation doit être renouvelée.\n\n${path}\n\nReconnectez son volume si nécessaire, puis sélectionnez ce dossier pour autoriser son accès. Le dossier sélectionné sera enregistré dans vos préférences.\",\n\"@careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": {\n  \"placeholders\": {\n    \"path\": {\n      \"type\": \"String\"\n    }\n  }\n}";

  static String m14(documentLabel) =>
      "Já existe um rascunho para este modelo de ${documentLabel}.";

  static String m15(documentLabel) =>
      "Deseja adicionar o conteúdo gerado na sequência do atual ${documentLabel} ou substituir o conteúdo existente?";

  static String m16(documentLabel) => "Novo ${documentLabel}";

  static String m17(patientName, title) => "Relatório_${patientName}_${title}";

  static String m18(path) => "Documento do Word criado: ${path}";

  static String m19(error) => "Erro ao criar o documento do Word: ${error}";

  static String m20(patientName) => "${patientName} — Exames e relatórios";

  static String m21(deviceName) => "Quer mesmo arquivar o ${deviceName}?";

  static String m22(fieldName) => "O campo «${fieldName}» é obrigatório.";

  static String m23(noteTitle) =>
      "A nota «${noteTitle}» deixará de ser apresentada.";

  static String m24(error) => "Erro ao guardar: ${error}";

  static String m25(count) => "${count} outro(s) exercício(s)";

  static String m26(count) => "${count} associação(ões) pendentes";

  static String m27(count) => "${count} cópias de segurança";

  static String m28(size) => "Tamanho: ${size}";

  static String m29(size) => "Dimensão total: ${size}";

  static String m30(version) => "Versão ${version}";

  static String m31(integrityStatus) =>
      "A base de dados restaurada apresenta uma anomalia: ${integrityStatus}";

  static String m32(error) => "Falha na restauração: ${error}";

  static String m33(integrityStatus) =>
      "A restauração foi concluída, mas o integrity_check devolveu: ${integrityStatus}";

  static String m34(patientName) =>
      "Quer mesmo arquivar ${patientName}? Este já não será apresentado na lista ativa.";

  static String m35(patientName) => "${patientName} arquivado.";

  static String m36(error) => "Erro: ${error}";

  static String m37(patientName) =>
      "${patientName} foi reposto na lista ativa.";

  static String m38(patientName) =>
      "Cartão Vitale associado ao doente ${patientName}.";

  static String m39(patientName) => "O doente ${patientName} foi recuperado.";

  static String m40(practitionerName) =>
      "Quer mesmo arquivar ${practitionerName}?";

  static String m41(date) => "Arquivado em ${date}";

  static String m42(error) => "Erro: ${error}";

  static String m43(professionalId) => "ID profissional: ${professionalId}";

  static String m44(error) => "Erro: ${error}";

  static String m45(name) => "${name} — arquivado";

  static String m46(start, end) => "Tu ${start} ao ${end}";

  static String m47(error) => "Erro ao carregar o histórico: ${error}";

  static String m48(start) => "Desde o ${start}";

  static String m49(error) => "Erro durante a reinicialização: ${error}";

  static String m50(error) => "A ditado por voz falhou: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "abakWhisperSpeechProvider_name":
            MessageLookupByLibrary.simpleMessage("ABAK Dictado por voz"),
        "archivedDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Esta vista reúne os balanços e os relatórios arquivados do processo de acompanhamento. Cada linha indica o tipo de documento, o seu título e a data de arquivo.\n\nA ação de restauração permite reposicionar o documento no histórico dos balanços ou dos relatórios.\n\nA ação de eliminação definitiva remove o documento do Companion. Leia atentamente a mensagem de confirmação antes de confirmar: o documento já não poderá ser restaurado a partir desta lista.\n\nClique na cruz para fechar a vista ampliada e regressar à área de Balanços/Relatórios."),
        "assessmentChartImageService_insufficientPoints":
            MessageLookupByLibrary.simpleMessage(
                "Uma série gráfica deve conter, pelo menos, dois pontos."),
        "assessmentChartImageService_pngConversionError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível converter o gráfico numa imagem PNG."),
        "assessmentDocumentDataBuilder_female":
            MessageLookupByLibrary.simpleMessage("Feminino"),
        "assessmentDocumentDataBuilder_male":
            MessageLookupByLibrary.simpleMessage("Masculino"),
        "assessmentDocumentDataBuilder_patient": m0,
        "assessmentDocxService_age":
            MessageLookupByLibrary.simpleMessage("Idade"),
        "assessmentDocxService_assessment":
            MessageLookupByLibrary.simpleMessage("com"),
        "assessmentDocxService_attachment":
            MessageLookupByLibrary.simpleMessage(
                "Patologia durante a integração"),
        "assessmentDocxService_author":
            MessageLookupByLibrary.simpleMessage("Redator"),
        "assessmentDocxService_centimetres": m1,
        "assessmentDocxService_chart":
            MessageLookupByLibrary.simpleMessage("Gráfico"),
        "assessmentDocxService_declared": MessageLookupByLibrary.simpleMessage(
            "Idade declarada no momento do teste"),
        "assessmentDocxService_diagnosis": MessageLookupByLibrary.simpleMessage(
            "Anomalia observada durante o teste"),
        "assessmentDocxService_dominance":
            MessageLookupByLibrary.simpleMessage("Lado dominante"),
        "assessmentDocxService_establishment":
            MessageLookupByLibrary.simpleMessage("Estabelecimento"),
        "assessmentDocxService_firstname":
            MessageLookupByLibrary.simpleMessage("Nome próprio"),
        "assessmentDocxService_height":
            MessageLookupByLibrary.simpleMessage("Tamanho"),
        "assessmentDocxService_information":
            MessageLookupByLibrary.simpleMessage("Informações sobre o doente"),
        "assessmentDocxService_kilograms": m2,
        "assessmentDocxService_notes": MessageLookupByLibrary.simpleMessage(
            "Notas de acompanhamento selecionadas"),
        "assessmentDocxService_opened": MessageLookupByLibrary.simpleMessage(
            "Serviço disponível a partir de"),
        "assessmentDocxService_pathology":
            MessageLookupByLibrary.simpleMessage("Patologia"),
        "assessmentDocxService_patient":
            MessageLookupByLibrary.simpleMessage("Doente"),
        "assessmentDocxService_performed":
            MessageLookupByLibrary.simpleMessage("Realizado em"),
        "assessmentDocxService_practitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapeuta de referência"),
        "assessmentDocxService_printed":
            MessageLookupByLibrary.simpleMessage("Impresso em"),
        "assessmentDocxService_profession":
            MessageLookupByLibrary.simpleMessage("Profissão"),
        "assessmentDocxService_recipients":
            MessageLookupByLibrary.simpleMessage("Destinatário(s)"),
        "assessmentDocxService_results": MessageLookupByLibrary.simpleMessage(
            "Resultados dos testes selecionados"),
        "assessmentDocxService_sex":
            MessageLookupByLibrary.simpleMessage("Sexo"),
        "assessmentDocxService_sport":
            MessageLookupByLibrary.simpleMessage("Atividade desportiva"),
        "assessmentDocxService_surname":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "assessmentDocxService_title":
            MessageLookupByLibrary.simpleMessage("com"),
        "assessmentDocxService_weight":
            MessageLookupByLibrary.simpleMessage("Peso"),
        "assessmentDocxService_years": m3,
        "assessmentDraft_help": MessageLookupByLibrary.simpleMessage(
            "O texto apresentado corresponde a um trabalho em curso que foi guardado automaticamente. Pode mantê-lo, alterá-lo ou eliminá-lo antes de registar o seu balanço."),
        "assessmentDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Compreender o rascunho do balanço"),
        "assessmentHistory_help": MessageLookupByLibrary.simpleMessage(
            "Esta vista apresenta os balanços registados para o acompanhamento, com o respetivo título e data.\n\nAs ações em cada linha permitem alterar um balanço, duplicá-lo ou movê-lo para os documentos arquivados.\n\nQuando um balanço estiver aberto para edição, utilize a ação de atualização para guardar as suas alterações. Os comandos disponíveis permitem também anular as alterações ou voltar ao rascunho.\n\nA transferência para os documentos arquivados não constitui uma eliminação definitiva.\n\nClique na cruz para fechar a vista ampliada e regressar à área Balanços/Relatórios."),
        "backupHistory_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "Não há nenhuma cópia de segurança registada."),
        "backupHistory_fileSize": m4,
        "backupHistory_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã apresenta as cópias de segurança guardadas no Companion. Cada linha indica o nome do ficheiro, a data de criação, o tamanho e a localização.\n\nO botão «Restaurar» permite substituir a base de dados atual pela da cópia de segurança selecionada. Os dados adicionados ou alterados após este backup não estarão, portanto, presentes na base de dados restaurada.\n\nVerifique a data do backup e leia a mensagem de confirmação antes de continuar. É criada uma cópia de segurança da base de dados atual antes da sua substituição.\n\nO ficheiro de cópia de segurança deve estar sempre acessível no local indicado. Se tiver sido movido ou eliminado, a restauração não poderá ser efetuada.\n\nPara criar uma nova cópia de segurança, utilize a ação «Criar uma cópia de segurança» na página inicial."),
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "backupHistory_restoreTitle": MessageLookupByLibrary.simpleMessage(
            "Restaurar esta cópia de segurança?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Esta operação substituirá totalmente a base de dados atual.\n\nSerá criada uma cópia de segurança automática antes da restauração.\n\nDeseja continuar?"),
        "backupHistory_title": MessageLookupByLibrary.simpleMessage(
            "Histórico de cópias de segurança"),
        "bodymap_help": MessageLookupByLibrary.simpleMessage(
            "O mapa de dor permite identificar as zonas dolorosas do doente para o episódio de cuidados em curso.\n\nEscolha uma vista e, em seguida, clique numa zona da silhueta ou selecione-a na lista. Pode adicionar uma observação e, se necessário, indicar uma intensidade de 0 a 10. Utilize o cesto de lixo para remover uma zona do registo.\n\nClique em «Guardar» para guardar o seu registo no Companion. Ao sair do ecrã com alterações não guardadas, será apresentada uma opção que lhe permite guardá-las ou descartá-las.\n\n«Exportar os dois mapas» cria uma imagem PNG no local escolhido no seu computador. Esta exportação não substitui o registo do levantamento.\n\nEste módulo é uma primeira proposta, destinada a evoluir de acordo com os vossos comentários. Testem-no na vossa prática e indiquem as funcionalidades que gostariam de ver adicionadas ou melhoradas."),
        "bodymap_title": MessageLookupByLibrary.simpleMessage("Mapa das dores"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origem ABAK"),
        "careEpisodeDetail_detail_de_la_prise_en_charge":
            MessageLookupByLibrary.simpleMessage("Detalhes da cobertura"),
        "careEpisodeDetail_evolution":
            MessageLookupByLibrary.simpleMessage("Evolução"),
        "careEpisodeDetail_noResult": MessageLookupByLibrary.simpleMessage(
            "De momento, não há resultados associados."),
        "careEpisodeDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Patologia"),
        "careEpisodeDetail_reportsWorkspaceTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Nova interface de balanços e relatórios"),
        "careEpisodeDetail_results":
            MessageLookupByLibrary.simpleMessage("Resultados da ABAK"),
        "careEpisodeDetail_score":
            MessageLookupByLibrary.simpleMessage("Resultado"),
        "careEpisodePanel_archive":
            MessageLookupByLibrary.simpleMessage("Arquivar"),
        "careEpisodePanel_archiveCareEpisode":
            MessageLookupByLibrary.simpleMessage("Arquivar o tratamento"),
        "careEpisodePanel_archiveCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível arquivar o registo. Por favor, tente novamente."),
        "careEpisodePanel_archiveCareEpisodeMessage":
            MessageLookupByLibrary.simpleMessage(
                "Este caso será retirado da lista. Os seus dados serão conservados em arquivo."),
        "careEpisodePanel_archiveCareEpisodeTitle":
            MessageLookupByLibrary.simpleMessage("Arquivar este atendimento?"),
        "careEpisodePanel_archivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage("Casos arquivados"),
        "careEpisodePanel_archivedCareEpisodesHelp":
            MessageLookupByLibrary.simpleMessage(
                "Aqui pode encontrar os seus registos de cuidados de saúde arquivados."),
        "careEpisodePanel_archivedOn": m5,
        "careEpisodePanel_careEpisodeArchived":
            MessageLookupByLibrary.simpleMessage("Tratamento arquivado."),
        "careEpisodePanel_careEpisodeOpenedIn": m6,
        "careEpisodePanel_careEpisodeRestored":
            MessageLookupByLibrary.simpleMessage(
                "O serviço foi restabelecido."),
        "careEpisodePanel_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Coberturas"),
        "careEpisodePanel_choose":
            MessageLookupByLibrary.simpleMessage("Escolher"),
        "careEpisodePanel_edit": MessageLookupByLibrary.simpleMessage("Editar"),
        "careEpisodePanel_loadCareEpisodesError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível carregar as coberturas."),
        "careEpisodePanel_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Nova cobertura"),
        "careEpisodePanel_noArchivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage(
                "Não há qualquer registo de tratamento arquivado para este doente."),
        "careEpisodePanel_noCareEpisodes": MessageLookupByLibrary.simpleMessage(
            "Não foi criado qualquer plano de cuidados para este doente."),
        "careEpisodePanel_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Médico prescritor"),
        "careEpisodePanel_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "careEpisodePanel_restoreCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível restabelecer o apoio. Por favor, tente novamente."),
        "careEpisodeReportsWorkspaceScreen_add":
            MessageLookupByLibrary.simpleMessage("Adicionar"),
        "careEpisodeReportsWorkspaceScreen_append":
            MessageLookupByLibrary.simpleMessage("Adicionar à lista"),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível enviar o balanço para a lixeira."),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentMessage": m7,
        "careEpisodeReportsWorkspaceScreen_archiveReportError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível enviar o relatório para a lixeira."),
        "careEpisodeReportsWorkspaceScreen_archiveReportMessage": m8,
        "careEpisodeReportsWorkspaceScreen_assessmentFileName": m9,
        "careEpisodeReportsWorkspaceScreen_assessmentLabel":
            MessageLookupByLibrary.simpleMessage("com"),
        "careEpisodeReportsWorkspaceScreen_assessmentNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível encontrar o balanço."),
        "careEpisodeReportsWorkspaceScreen_assessmentReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "O seu relatório está pronto. O ficheiro DOCX irá reunir as informações introduzidas e os elementos selecionados."),
        "careEpisodeReportsWorkspaceScreen_assessmentTitle":
            MessageLookupByLibrary.simpleMessage("Título do balanço"),
        "careEpisodeReportsWorkspaceScreen_assessmentsAndReports":
            MessageLookupByLibrary.simpleMessage("Relatórios e balanços"),
        "careEpisodeReportsWorkspaceScreen_author":
            MessageLookupByLibrary.simpleMessage("Redator"),
        "careEpisodeReportsWorkspaceScreen_authorizeDirectory":
            MessageLookupByLibrary.simpleMessage("Autorizar uma pasta"),
        "careEpisodeReportsWorkspaceScreen_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "careEpisodeReportsWorkspaceScreen_cancelChangesError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível anular as alterações."),
        "careEpisodeReportsWorkspaceScreen_cancelReportChangesError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível anular as alterações feitas no relatório."),
        "careEpisodeReportsWorkspaceScreen_close":
            MessageLookupByLibrary.simpleMessage("Fechar"),
        "careEpisodeReportsWorkspaceScreen_confirm":
            MessageLookupByLibrary.simpleMessage("Confirmar"),
        "careEpisodeReportsWorkspaceScreen_copyTitle": m10,
        "careEpisodeReportsWorkspaceScreen_createNew":
            MessageLookupByLibrary.simpleMessage("Criar um novo"),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível eliminar definitivamente o balanço."),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentMessage": m11,
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "Apagar definitivamente o balanço?"),
        "careEpisodeReportsWorkspaceScreen_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Eliminar definitivamente"),
        "careEpisodeReportsWorkspaceScreen_deleteReportError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível eliminar definitivamente o relatório."),
        "careEpisodeReportsWorkspaceScreen_deleteReportMessage": m12,
        "careEpisodeReportsWorkspaceScreen_deleteReportTitle":
            MessageLookupByLibrary.simpleMessage(
                "Apagar definitivamente o relatório?"),
        "careEpisodeReportsWorkspaceScreen_directoryAccessMessage": m13,
        "careEpisodeReportsWorkspaceScreen_duplicate":
            MessageLookupByLibrary.simpleMessage("Duplicar"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessment":
            MessageLookupByLibrary.simpleMessage("Duplicar o balanço"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível duplicar o balanço."),
        "careEpisodeReportsWorkspaceScreen_duplicateReport":
            MessageLookupByLibrary.simpleMessage("Duplicar o relatório"),
        "careEpisodeReportsWorkspaceScreen_duplicateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível duplicar o relatório."),
        "careEpisodeReportsWorkspaceScreen_existingAssessmentDocx":
            MessageLookupByLibrary.simpleMessage(
                "Já existe um ficheiro DOCX associado a este balanço. Pretende substituir o ficheiro existente ou criar um novo ficheiro?"),
        "careEpisodeReportsWorkspaceScreen_existingReportDocx":
            MessageLookupByLibrary.simpleMessage(
                "Já existe um ficheiro DOCX associado a este relatório. Pretende substituir o ficheiro existente ou criar um novo ficheiro?"),
        "careEpisodeReportsWorkspaceScreen_existingTemplateDraftMessage": m14,
        "careEpisodeReportsWorkspaceScreen_generateDocx":
            MessageLookupByLibrary.simpleMessage("Gerar o ficheiro DOCX"),
        "careEpisodeReportsWorkspaceScreen_insertTextMessage": m15,
        "careEpisodeReportsWorkspaceScreen_managePractitioners":
            MessageLookupByLibrary.simpleMessage("Gerir os fisioterapeutas"),
        "careEpisodeReportsWorkspaceScreen_managePrescribingDoctors":
            MessageLookupByLibrary.simpleMessage(
                "Gerir os médicos prescritores"),
        "careEpisodeReportsWorkspaceScreen_moveToTrash":
            MessageLookupByLibrary.simpleMessage("Enviar para a lixeira"),
        "careEpisodeReportsWorkspaceScreen_newAssessment":
            MessageLookupByLibrary.simpleMessage("Novo balanço"),
        "careEpisodeReportsWorkspaceScreen_newAssessmentTitle":
            MessageLookupByLibrary.simpleMessage("Título do novo balanço"),
        "careEpisodeReportsWorkspaceScreen_newDocument": m16,
        "careEpisodeReportsWorkspaceScreen_newReport":
            MessageLookupByLibrary.simpleMessage("Novo relatório"),
        "careEpisodeReportsWorkspaceScreen_newReportTitle":
            MessageLookupByLibrary.simpleMessage("Título do novo relatório"),
        "careEpisodeReportsWorkspaceScreen_note":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "careEpisodeReportsWorkspaceScreen_openReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível abrir o rascunho do relatório."),
        "careEpisodeReportsWorkspaceScreen_openReportError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível abrir o relatório."),
        "careEpisodeReportsWorkspaceScreen_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Médico prescritor"),
        "careEpisodeReportsWorkspaceScreen_recipients":
            MessageLookupByLibrary.simpleMessage("Destinatário(s)"),
        "careEpisodeReportsWorkspaceScreen_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapeuta de referência"),
        "careEpisodeReportsWorkspaceScreen_replace":
            MessageLookupByLibrary.simpleMessage("Substituir"),
        "careEpisodeReportsWorkspaceScreen_reportFileName": m17,
        "careEpisodeReportsWorkspaceScreen_reportLabel":
            MessageLookupByLibrary.simpleMessage("relatório"),
        "careEpisodeReportsWorkspaceScreen_reportNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível encontrar o relatório."),
        "careEpisodeReportsWorkspaceScreen_reportReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "O seu relatório está pronto. O ficheiro DOCX irá reunir as informações do doente, do redator e do destinatário."),
        "careEpisodeReportsWorkspaceScreen_reportTitle":
            MessageLookupByLibrary.simpleMessage("Título do relatório"),
        "careEpisodeReportsWorkspaceScreen_restoreAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível restaurar o balanço"),
        "careEpisodeReportsWorkspaceScreen_restoreReportError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível recuperar o relatório."),
        "careEpisodeReportsWorkspaceScreen_resumeAssessmentDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Um trabalho em curso já foi guardado automaticamente.<br><br>Deseja retomar este rascunho ou começar um novo balanço?"),
        "careEpisodeReportsWorkspaceScreen_resumeDraft":
            MessageLookupByLibrary.simpleMessage("Retomar o rascunho"),
        "careEpisodeReportsWorkspaceScreen_resumeReportDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Um trabalho em curso já foi guardado automaticamente.<br><br>Deseja retomar este rascunho ou iniciar um novo relatório?"),
        "careEpisodeReportsWorkspaceScreen_returnToDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível voltar ao rascunho."),
        "careEpisodeReportsWorkspaceScreen_returnToReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível voltar ao rascunho do relatório."),
        "careEpisodeReportsWorkspaceScreen_save":
            MessageLookupByLibrary.simpleMessage("Guardar"),
        "careEpisodeReportsWorkspaceScreen_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Registar o balanço"),
        "careEpisodeReportsWorkspaceScreen_saveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível gravar o balanço."),
        "careEpisodeReportsWorkspaceScreen_saveNoteSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível guardar a seleção da nota."),
        "careEpisodeReportsWorkspaceScreen_saveReport":
            MessageLookupByLibrary.simpleMessage("Guardar o relatório"),
        "careEpisodeReportsWorkspaceScreen_saveReportError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível guardar o relatório."),
        "careEpisodeReportsWorkspaceScreen_saveTestSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível guardar a seleção do teste."),
        "careEpisodeReportsWorkspaceScreen_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Área de preenchimento do balanço SOAP.<br><br>S — Subjetivo<br><br>O — Objetivo<br><br>A — Análise<br><br>P — Plano"),
        "careEpisodeReportsWorkspaceScreen_title":
            MessageLookupByLibrary.simpleMessage("Título"),
        "careEpisodeReportsWorkspaceScreen_update":
            MessageLookupByLibrary.simpleMessage("Atualizar"),
        "careEpisodeReportsWorkspaceScreen_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Atualizar o balanço"),
        "careEpisodeReportsWorkspaceScreen_updateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível atualizar o balanço."),
        "careEpisodeReportsWorkspaceScreen_updateReport":
            MessageLookupByLibrary.simpleMessage("Atualizar o relatório"),
        "careEpisodeReportsWorkspaceScreen_updateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível atualizar o relatório."),
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreated": m18,
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreationError": m19,
        "careEpisodeReportsWorkspaceScreen_workspaceTitle": m20,
        "careEpisodeReportsWorkspace_addFollowUpNote":
            MessageLookupByLibrary.simpleMessage(
                "Adicionar uma nota de acompanhamento"),
        "careEpisodeReportsWorkspace_archived":
            MessageLookupByLibrary.simpleMessage("arquivado"),
        "careEpisodeReportsWorkspace_archivedDocuments":
            MessageLookupByLibrary.simpleMessage("Documentos arquivados"),
        "careEpisodeReportsWorkspace_archivedDocumentsCount":
            MessageLookupByLibrary.simpleMessage("Documentos arquivados"),
        "careEpisodeReportsWorkspace_assessment":
            MessageLookupByLibrary.simpleMessage("com"),
        "careEpisodeReportsWorkspace_assessmentCount":
            MessageLookupByLibrary.simpleMessage("Número de balanços"),
        "careEpisodeReportsWorkspace_assessmentHistory":
            MessageLookupByLibrary.simpleMessage("Histórico dos balanços"),
        "careEpisodeReportsWorkspace_assessmentsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível carregar os balanços."),
        "careEpisodeReportsWorkspace_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "careEpisodeReportsWorkspace_cancelChanges":
            MessageLookupByLibrary.simpleMessage("Anular as alterações"),
        "careEpisodeReportsWorkspace_createOrResumeAssessment":
            MessageLookupByLibrary.simpleMessage("Criar ou retomar um balanço"),
        "careEpisodeReportsWorkspace_createOrResumeReport":
            MessageLookupByLibrary.simpleMessage(
                "Criar ou retomar um relatório"),
        "careEpisodeReportsWorkspace_date":
            MessageLookupByLibrary.simpleMessage("Dados"),
        "careEpisodeReportsWorkspace_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Eliminar definitivamente"),
        "careEpisodeReportsWorkspace_duplicate":
            MessageLookupByLibrary.simpleMessage("Duplicar"),
        "careEpisodeReportsWorkspace_edit":
            MessageLookupByLibrary.simpleMessage("Editar"),
        "careEpisodeReportsWorkspace_editReferringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Alterar o fisioterapeuta de referência"),
        "careEpisodeReportsWorkspace_episodeDocuments":
            MessageLookupByLibrary.simpleMessage(
                "Documentos relativos ao tratamento"),
        "careEpisodeReportsWorkspace_episodeSummary":
            MessageLookupByLibrary.simpleMessage("Resumo do episódio"),
        "careEpisodeReportsWorkspace_expand":
            MessageLookupByLibrary.simpleMessage("Ampliar"),
        "careEpisodeReportsWorkspace_expandEditor":
            MessageLookupByLibrary.simpleMessage("Alargar a área de escrita"),
        "careEpisodeReportsWorkspace_followUpNoteDefaultTitle":
            MessageLookupByLibrary.simpleMessage("Nota de acompanhamento"),
        "careEpisodeReportsWorkspace_followUpNotes":
            MessageLookupByLibrary.simpleMessage("Notas de acompanhamento"),
        "careEpisodeReportsWorkspace_followUpNotesLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível carregar as notas de acompanhamento."),
        "careEpisodeReportsWorkspace_include":
            MessageLookupByLibrary.simpleMessage("Incluir"),
        "careEpisodeReportsWorkspace_latestTests":
            MessageLookupByLibrary.simpleMessage(
                "Testes realizados (último resultado)"),
        "careEpisodeReportsWorkspace_loading":
            MessageLookupByLibrary.simpleMessage("A carregar…"),
        "careEpisodeReportsWorkspace_moveToTrash":
            MessageLookupByLibrary.simpleMessage("Enviar para o cesto de lixo"),
        "careEpisodeReportsWorkspace_name":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "careEpisodeReportsWorkspace_newAssessment":
            MessageLookupByLibrary.simpleMessage("Balanço (novo)"),
        "careEpisodeReportsWorkspace_noAssessments":
            MessageLookupByLibrary.simpleMessage("Não há registos de vítimas."),
        "careEpisodeReportsWorkspace_noDocument":
            MessageLookupByLibrary.simpleMessage("Nenhum documento"),
        "careEpisodeReportsWorkspace_noFollowUpNotes":
            MessageLookupByLibrary.simpleMessage(
                "Não há notas de acompanhamento."),
        "careEpisodeReportsWorkspace_noReports":
            MessageLookupByLibrary.simpleMessage(
                "Não foi registado nenhum relatório."),
        "careEpisodeReportsWorkspace_noTests":
            MessageLookupByLibrary.simpleMessage(
                "Não foram realizados testes para este episódio."),
        "careEpisodeReportsWorkspace_notProvided":
            MessageLookupByLibrary.simpleMessage("Não indicado"),
        "careEpisodeReportsWorkspace_note":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "careEpisodeReportsWorkspace_pathology":
            MessageLookupByLibrary.simpleMessage("Patologia"),
        "careEpisodeReportsWorkspace_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapeuta de referência"),
        "careEpisodeReportsWorkspace_referringPractitionerHistory":
            MessageLookupByLibrary.simpleMessage(
                "Histórico dos fisioterapeutas de referência"),
        "careEpisodeReportsWorkspace_report":
            MessageLookupByLibrary.simpleMessage("Relatório"),
        "careEpisodeReportsWorkspace_reportCount":
            MessageLookupByLibrary.simpleMessage("Número de relatórios"),
        "careEpisodeReportsWorkspace_reportHistory":
            MessageLookupByLibrary.simpleMessage("Histórico de relatórios"),
        "careEpisodeReportsWorkspace_reportsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível carregar os relatórios."),
        "careEpisodeReportsWorkspace_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "careEpisodeReportsWorkspace_result":
            MessageLookupByLibrary.simpleMessage("Resultado"),
        "careEpisodeReportsWorkspace_returnToDraft":
            MessageLookupByLibrary.simpleMessage("Voltar ao rascunho"),
        "careEpisodeReportsWorkspace_returnToReportDraft":
            MessageLookupByLibrary.simpleMessage(
                "Voltar ao rascunho do relatório"),
        "careEpisodeReportsWorkspace_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Registar o balanço"),
        "careEpisodeReportsWorkspace_saveReport":
            MessageLookupByLibrary.simpleMessage("Guardar o relatório"),
        "careEpisodeReportsWorkspace_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Área de redação do relatório SOAP.\n\nS — Subjetivo\n\nO — Objetivo\n\nA — Análise\n\nP — Plano"),
        "careEpisodeReportsWorkspace_test":
            MessageLookupByLibrary.simpleMessage("Teste"),
        "careEpisodeReportsWorkspace_testCount":
            MessageLookupByLibrary.simpleMessage("Número de testes"),
        "careEpisodeReportsWorkspace_testsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível carregar os testes."),
        "careEpisodeReportsWorkspace_title":
            MessageLookupByLibrary.simpleMessage("Título"),
        "careEpisodeReportsWorkspace_trashLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível carregar a lixeira."),
        "careEpisodeReportsWorkspace_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Atualizar o balanço"),
        "careEpisodeReportsWorkspace_updateReport":
            MessageLookupByLibrary.simpleMessage("Atualizar o relatório"),
        "careEpisode_assessment":
            MessageLookupByLibrary.simpleMessage("Não há análises clínicas."),
        "careEpisode_evaluation":
            MessageLookupByLibrary.simpleMessage("Não há avaliação clínica."),
        "careEpisode_report":
            MessageLookupByLibrary.simpleMessage("Não há relatório inicial."),
        "careEpisode_title":
            MessageLookupByLibrary.simpleMessage("Assistência"),
        "careEpisode_treatment": MessageLookupByLibrary.simpleMessage(
            "Não existe qualquer plano de tratamento."),
        "clinicalDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite preparar e guardar os relatórios e balanços relacionados com o acompanhamento.\n\nNo caso de um relatório, pode redigir o texto principal, selecionar os resultados dos exames e as notas de acompanhamento a incluir e, em seguida, gerar um documento DOCX assim que o relatório for guardado.\n\nOs rascunhos são guardados automaticamente enquanto não forem guardados como relatório ou avaliação.\n\nO histórico permite recuperar os relatórios e avaliações já guardados."),
        "clinicalDocuments_title":
            MessageLookupByLibrary.simpleMessage("Relatórios e balanços"),
        "close": MessageLookupByLibrary.simpleMessage("Fechar"),
        "contactFormTemplateDiagnostic_category":
            MessageLookupByLibrary.simpleMessage("Categoria"),
        "contactFormTemplateDiagnostic_defaultTemplate":
            MessageLookupByLibrary.simpleMessage("Modelo predefinido"),
        "contactFormTemplateDiagnostic_error":
            MessageLookupByLibrary.simpleMessage("Erro"),
        "contactFormTemplateDiagnostic_fields":
            MessageLookupByLibrary.simpleMessage("Campos"),
        "contactFormTemplateDiagnostic_no":
            MessageLookupByLibrary.simpleMessage("Não"),
        "contactFormTemplateDiagnostic_noData":
            MessageLookupByLibrary.simpleMessage(
                "Não há dados para apresentar."),
        "contactFormTemplateDiagnostic_noTemplate":
            MessageLookupByLibrary.simpleMessage(
                "Não foi encontrado nenhum modelo de ficha de entrevista inicial."),
        "contactFormTemplateDiagnostic_notDefined":
            MessageLookupByLibrary.simpleMessage("Não definida"),
        "contactFormTemplateDiagnostic_order":
            MessageLookupByLibrary.simpleMessage("Ordem"),
        "contactFormTemplateDiagnostic_practitioner":
            MessageLookupByLibrary.simpleMessage("Profissional"),
        "contactFormTemplateDiagnostic_refresh":
            MessageLookupByLibrary.simpleMessage("Atualizar"),
        "contactFormTemplateDiagnostic_required":
            MessageLookupByLibrary.simpleMessage("Obrigatório"),
        "contactFormTemplateDiagnostic_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Modelo do sistema"),
        "contactFormTemplateDiagnostic_templateId":
            MessageLookupByLibrary.simpleMessage("ID do modelo"),
        "contactFormTemplateDiagnostic_title":
            MessageLookupByLibrary.simpleMessage(
                "Ficha de diagnóstico e manutenção"),
        "contactFormTemplateDiagnostic_type":
            MessageLookupByLibrary.simpleMessage("Tipo"),
        "contactFormTemplateDiagnostic_yes":
            MessageLookupByLibrary.simpleMessage("Sim"),
        "dashboardTitle":
            MessageLookupByLibrary.simpleMessage("Centro clínico local ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Morada"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Porto"),
        "deviceForm_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Médico associado"),
        "deviceForm_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "deviceForm_contextName":
            MessageLookupByLibrary.simpleMessage("Novo aparelho"),
        "deviceForm_create": MessageLookupByLibrary.simpleMessage("Criar"),
        "deviceForm_deviceName":
            MessageLookupByLibrary.simpleMessage("Nome do aparelho"),
        "deviceForm_deviceNameHint": MessageLookupByLibrary.simpleMessage(
            "iPhone da Claire, Pixel do Marc…"),
        "deviceForm_deviceNameRequired": MessageLookupByLibrary.simpleMessage(
            "O nome do aparelho é obrigatório"),
        "deviceForm_editDevice":
            MessageLookupByLibrary.simpleMessage("Alterar o aparelho"),
        "deviceForm_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite criar ou alterar a ficha de um dispositivo no Companion.\n\nIntroduza um nome que permita reconhecer facilmente o telemóvel ou o tablet. Este nome é obrigatório.\n\nSelecione a plataforma do dispositivo: iOS ou Android.\n\nPode associar o dispositivo a um profissional da lista ou escolher a opção de dispositivo partilhado para não o atribuir a nenhum profissional em particular.\n\nClique em «Criar» para adicionar o dispositivo ou em «Guardar» para confirmar as alterações. «Anular» fecha a janela sem aplicar as alterações.\n\nAo abrir e fechar esta ajuda, os dados introduzidos no formulário são mantidos."),
        "deviceForm_loadingPractitionersError":
            MessageLookupByLibrary.simpleMessage(
                "Erro ao carregar os profissionais de saúde"),
        "deviceForm_newDevice":
            MessageLookupByLibrary.simpleMessage("Novo aparelho"),
        "deviceForm_platform":
            MessageLookupByLibrary.simpleMessage("Plataforma"),
        "deviceForm_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "deviceForm_sharedDevice": MessageLookupByLibrary.simpleMessage(
            "Nenhum / dispositivo partilhado"),
        "deviceList_active": MessageLookupByLibrary.simpleMessage("Ativos"),
        "deviceList_archive": MessageLookupByLibrary.simpleMessage("Arquivar"),
        "deviceList_archiveConfirmation": m21,
        "deviceList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Arquivar o aparelho"),
        "deviceList_archived":
            MessageLookupByLibrary.simpleMessage("Arquivados"),
        "deviceList_archivedDevicesEmpty": MessageLookupByLibrary.simpleMessage(
            "O cesto dos aparelhos está vazio neste momento."),
        "deviceList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Arquivado em"),
        "deviceList_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Médico associado"),
        "deviceList_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "deviceList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Este ecrã apresenta a lista dos dispositivos ligados ao estabelecimento"),
        "deviceList_contextName":
            MessageLookupByLibrary.simpleMessage("Lista de aparelhos"),
        "deviceList_edit": MessageLookupByLibrary.simpleMessage("Editar"),
        "deviceList_error": MessageLookupByLibrary.simpleMessage("Erro"),
        "deviceList_newDevice":
            MessageLookupByLibrary.simpleMessage("Novo aparelho"),
        "deviceList_noArchivedDevices": MessageLookupByLibrary.simpleMessage(
            "Não há dispositivos arquivados"),
        "deviceList_noPairedDevices": MessageLookupByLibrary.simpleMessage(
            "Não há dispositivos associados"),
        "deviceList_pairedDevicesExplanation":
            MessageLookupByLibrary.simpleMessage(
                "Os dispositivos ABAK associados à instituição aparecerão aqui."),
        "deviceList_platform":
            MessageLookupByLibrary.simpleMessage("Plataforma"),
        "deviceList_restore": MessageLookupByLibrary.simpleMessage("Restaurar"),
        "deviceList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Mostrar o código QR"),
        "deviceList_title":
            MessageLookupByLibrary.simpleMessage("Lista de aparelhos"),
        "deviceQr_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela apresenta o código QR de identificação do dispositivo, juntamente com o seu nome, o nome do consultório e a respetiva plataforma.\n\nDigitalize este código QR a partir da aplicação ABAK Mobile para identificar este dispositivo neste estabelecimento. Verifique se o nome apresentado corresponde efetivamente ao telemóvel ou tablet em questão.\n\nEste código QR serve para identificar o dispositivo; a sua exibição não desencadeia qualquer transferência de resultados.\n\nFeche esta janela para voltar à lista de dispositivos."),
        "deviceQr_title": MessageLookupByLibrary.simpleMessage("Aparelho ABAK"),
        "documentArchiveConfirm_help": MessageLookupByLibrary.simpleMessage(
            "Ao enviar para a lixeira, o balanço ou o relatório é removido do seu histórico habitual.\n\nO documento permanece guardado no Companion. Pode encontrá-lo nos documentos arquivados e restaurá-lo para que volte a aparecer no histórico.\n\nOs ficheiros DOCX já exportados para o seu computador não são eliminados por esta ação.\n\nClique em «Enviar para a lixeira» para confirmar ou em «Anular» para manter o documento no histórico."),
        "documentArchiveConfirm_title": MessageLookupByLibrary.simpleMessage(
            "Colocar o documento no cesto de lixo?"),
        "documentAuthor_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite escolher o profissional designado como redator do balanço ou do relatório em curso.\n\nSelecione o profissional na lista e, em seguida, clique em «Validar» para registar esta associação no documento.\n\nEsta escolha diz respeito ao redator do documento; não altera o profissional de saúde responsável pelo episódio de cuidados.\n\n«Anular» fecha a janela sem alterar o redator."),
        "documentAuthor_title":
            MessageLookupByLibrary.simpleMessage("Escolher o redator"),
        "documentDirectoryAccess_help": MessageLookupByLibrary.simpleMessage(
            "O Companion não consegue aceder à pasta destinada ao armazenamento dos documentos, ou a sua autorização de acesso tem de ser renovada.\n\nSe essa pasta se encontrar num disco externo ou num local de rede, verifique primeiro se está ligada e acessível.\n\nClique em «Autorizar uma pasta» e, em seguida, selecione a pasta na janela que se abre. Pode selecionar a pasta habitual ou escolher outro destino.\n\nA pasta selecionada é guardada nas suas preferências para futuras exportações. Os ficheiros já presentes na pasta anterior não são movidos.\n\n«Cancelar» interrompe a exportação em curso sem alterar o seu balanço ou o seu relatório."),
        "documentDirectoryAccess_title": MessageLookupByLibrary.simpleMessage(
            "Autorizar a pasta de documentos"),
        "documentDocxExisting_help": MessageLookupByLibrary.simpleMessage(
            "Já existe um ficheiro DOCX associado a este balanço ou relatório.\n\n«Criar um novo» gera um novo ficheiro com o conteúdo atual do documento. Se o nome já existir na pasta de destino, é adicionado um número para preservar o ficheiro anterior. O novo ficheiro passa a ser o associado ao documento no Companion.\n\n«Substituir» sobrescreve o ficheiro com o nome associado ao documento na pasta de destino. Quaisquer alterações feitas diretamente nesse ficheiro no Word ou no LibreOffice serão substituídas.\n\n«Cancelar» interrompe a exportação sem alterar os ficheiros."),
        "documentDocxExisting_title":
            MessageLookupByLibrary.simpleMessage("Já existe um ficheiro DOCX"),
        "documentDraftChoice_help": MessageLookupByLibrary.simpleMessage(
            "Um texto em fase de redação já foi guardado automaticamente para este tipo de documento.\n\n«Retomar o rascunho» permite-lhe recuperar esse texto e continuar a sua redação.\n\n«Novo balanço» ou «Novo relatório» apaga o título e o texto deste rascunho para recomeçar. O rascunho anterior não é guardado como um documento separado. Se pretender manter o seu trabalho, retome-o e guarde-o antes de iniciar um novo documento.\n\n«Anular» fecha esta janela sem alterar o rascunho."),
        "documentDraftChoice_title":
            MessageLookupByLibrary.simpleMessage("Existe um rascunho"),
        "documentExpandedEditor_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela oferece mais espaço para redigir ou alterar o texto do balanço ou do relatório em curso.\n\nAs suas alterações são refletidas em tempo real na área de edição principal. Fechar a janela não as anula.\n\nClique na cruz para regressar à área «Balanços/Relatórios» e, em seguida, continue a preparar e a guardar o seu documento.\n\nAo abrir e fechar esta ajuda, o texto introduzido é mantido."),
        "documentExpandedEditor_helpTitle":
            MessageLookupByLibrary.simpleMessage("Escrever na vista ampliada"),
        "documentRecipient_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite introduzir os destinatários do balanço ou do relatório em curso.\n\nIntroduza livremente o nome do destinatário ou os nomes dos diferentes destinatários e, em seguida, clique em «Validar» para guardar esta informação no documento.\n\nPara eliminar uma menção existente, apague o conteúdo do campo e, em seguida, confirme.\n\nEsta introdução de dados preenche os destinatários do documento; não desencadeia qualquer envio.\n\n«Anular» fecha a janela sem aplicar as alterações. Ao abrir e fechar esta ajuda, os dados introduzidos são mantidos."),
        "documentRecipient_title":
            MessageLookupByLibrary.simpleMessage("Destinatário(s)"),
        "documentTemplateDraft_help": MessageLookupByLibrary.simpleMessage(
            "Já foram registadas respostas para este modelo de guia no episódio de cuidados em curso.\n\n«Retomar o rascunho» abre o guia com essas respostas para que possa continuar ou alterar o que introduziu.\n\n«Nova avaliação» ou «Novo relatório» apaga as respostas registadas para este modelo e abre o guia sem retomar essas respostas. Esta opção não elimina o texto já presente na área de edição do documento.\n\n«Anular» mantém as respostas registadas e regressa ao ecrã anterior sem abrir o guia."),
        "documentTemplateDraft_title":
            MessageLookupByLibrary.simpleMessage("Rascunho existente"),
        "documentTemplateGuide_help": MessageLookupByLibrary.simpleMessage(
            "Este guia ajuda-o a preparar o conteúdo de um balanço ou de um relatório a partir do modelo selecionado.\n\nUtilize a lista de tópicos à esquerda para aceder às diferentes secções. De acordo com os campos apresentados, introduza texto, selecione respostas ou preencha as tabelas.\n\nO botão de pré-visualização, localizado na parte inferior do formulário, permite consultar o texto gerado a partir das suas respostas.\n\nA partir da pré-visualização, pode regressar ao guia para continuar a introduzir dados ou solicitar a inserção do texto no balanço ou no relatório. Siga as eventuais sugestões de adição ou substituição apresentadas pelo Companion.\n\nA inserção do texto não substitui o registo final do balanço ou do relatório.\n\nAo abrir e fechar este guia, as suas entradas são guardadas."),
        "documentTemplateGuide_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Utilizar o guia de introdução de dados"),
        "documentTemplatePreview_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite rever o texto gerado a partir das respostas introduzidas no guia.\n\nO texto pode ser consultado e selecionado. Para alterar as suas respostas, clique em «Fechar» para regressar ao guia e, em seguida, volte a iniciar a pré-visualização.\n\nClique em «Inserir no balanço» ou «Inserir no relatório» para transferir o texto para o documento em curso. Siga as eventuais sugestões de adição ou substituição apresentadas pelo Companion.\n\nSe não tiver sido gerado qualquer texto, o botão de inserção permanece desativado.\n\nApós a inserção, verifique o conteúdo do documento e guarde o seu balanço ou relatório."),
        "documentTemplatePreview_title":
            MessageLookupByLibrary.simpleMessage("Visão geral do texto gerado"),
        "documentTemplate_assessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "Escolher um modelo de balanço"),
        "documentTemplate_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela apresenta os modelos disponíveis para o tipo de documento atual: balanço ou relatório.\n\nClique num modelo para abrir o guia de preenchimento correspondente. A escolha do modelo não cria imediatamente um documento guardado.\n\nSe já existir um rascunho para este modelo no episódio de cuidados, o Companion sugere que o retome ou que inicie um novo preenchimento."),
        "documentTemplate_reportTitle": MessageLookupByLibrary.simpleMessage(
            "Escolher um modelo de relatório"),
        "documentTests_help": MessageLookupByLibrary.simpleMessage(
            "Esta vista ampliada permite consultar os exames realizados durante o acompanhamento e escolher aqueles a incluir no balanço ou no relatório em curso.\n\nUtilize as caixas de seleção para incluir ou retirar um exame do documento. Esta seleção não elimina os resultados registados no Companion.\n\nAs ações apresentadas na lista permitem consultar os detalhes dos resultados. A seleção está disponível quando um balanço ou um relatório está aberto e o carregamento estiver concluído.\n\nClique na cruz para regressar à área Balanços/Relatórios."),
        "documentTextInsertion_help": MessageLookupByLibrary.simpleMessage(
            "O seu relatório ou balanço já contém texto. Escolha como integrar o conteúdo gerado pelo guia de preenchimento.\n\n«Adicionar a seguir» mantém o texto existente e adiciona o conteúdo gerado no final.\n\n«Substituir» substitui todo o texto da área de edição pelo conteúdo gerado. As passagens que tinha introduzido nessa área serão, portanto, também substituídas.\n\n«Cancelar» anula esta inserção e mantém o texto atual.\n\nPode consultar e, em seguida, fechar esta ajuda antes de fazer a sua escolha."),
        "documentTextInsertion_title":
            MessageLookupByLibrary.simpleMessage("Inserir o texto gerado"),
        "documentTitle_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite introduzir o título do balanço ou do relatório.\n\nMantenha o título sugerido ou substitua-o por um título que permita reconhecer facilmente o documento. O título não pode ficar em branco.\n\nClique no botão de validação ou prima a tecla Enter para confirmar. «Anular» fecha a janela sem validar o título.\n\nAo abrir e fechar esta ajuda, o texto introduzido é mantido."),
        "episodeDashboard_documents":
            MessageLookupByLibrary.simpleMessage("Documentos"),
        "episodeDashboard_documentsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Documentos relacionados com este episódio"),
        "episodeDashboard_forms":
            MessageLookupByLibrary.simpleMessage("Formulários"),
        "episodeDashboard_formsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Questionários específicos sobre este episódio"),
        "episodeDashboard_notes": MessageLookupByLibrary.simpleMessage("Notas"),
        "episodeDashboard_notesDescription":
            MessageLookupByLibrary.simpleMessage(
                "Observações e comentários do fisioterapeuta"),
        "episodeDashboard_report":
            MessageLookupByLibrary.simpleMessage("Relatório"),
        "episodeDashboard_reportDescription":
            MessageLookupByLibrary.simpleMessage("Resumo do episódio"),
        "episodeDocuments_addDocument":
            MessageLookupByLibrary.simpleMessage("Adicionar um documento"),
        "episodeDocuments_addError": MessageLookupByLibrary.simpleMessage(
            "Não é possível adicionar o documento"),
        "episodeDocuments_addedOn":
            MessageLookupByLibrary.simpleMessage("Adicionado em"),
        "episodeDocuments_document":
            MessageLookupByLibrary.simpleMessage("Documento"),
        "episodeDocuments_documentAdded": MessageLookupByLibrary.simpleMessage(
            "O documento foi adicionado à lista de suportados."),
        "episodeDocuments_emptyDescription": MessageLookupByLibrary.simpleMessage(
            "Pode adicionar um documento de texto, uma folha de cálculo, um PDF, uma imagem ou qualquer outro ficheiro útil."),
        "episodeDocuments_fileNotFound": MessageLookupByLibrary.simpleMessage(
            "Não foi possível encontrar o ficheiro associado."),
        "episodeDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Pode associar a esta funcionalidade documentos criados com as suas aplicações habituais: processador de texto, folha de cálculo, leitor de PDF ou software de edição de imagens.\n\nOs ficheiros adicionados são copiados para o espaço de armazenamento do Companion. Ao clicar num documento, este é aberto com a aplicação correspondente instalada neste computador."),
        "episodeDocuments_image":
            MessageLookupByLibrary.simpleMessage("Imagem"),
        "episodeDocuments_loadError": MessageLookupByLibrary.simpleMessage(
            "Não foi possível carregar os documentos associados."),
        "episodeDocuments_noDocument": MessageLookupByLibrary.simpleMessage(
            "Não há nenhum documento associado a este tratamento."),
        "episodeDocuments_openDocument":
            MessageLookupByLibrary.simpleMessage("Abrir o documento"),
        "episodeDocuments_openError": MessageLookupByLibrary.simpleMessage(
            "Não é possível abrir o ficheiro"),
        "episodeDocuments_pdfDocument":
            MessageLookupByLibrary.simpleMessage("Documento em PDF"),
        "episodeDocuments_platformNotSupported":
            MessageLookupByLibrary.simpleMessage(
                "A abertura não é suportada nesta plataforma."),
        "episodeDocuments_refresh":
            MessageLookupByLibrary.simpleMessage("Atualizar"),
        "episodeDocuments_spreadsheet":
            MessageLookupByLibrary.simpleMessage("Folha de cálculo"),
        "episodeDocuments_textDocument":
            MessageLookupByLibrary.simpleMessage("Documento de texto"),
        "episodeDocuments_title": MessageLookupByLibrary.simpleMessage(
            "Documentos relativos à admissão"),
        "episodeEvolution_evaluation":
            MessageLookupByLibrary.simpleMessage("avaliação"),
        "episodeEvolution_evaluations":
            MessageLookupByLibrary.simpleMessage("avaliações"),
        "episodeEvolution_first":
            MessageLookupByLibrary.simpleMessage("Estreia"),
        "episodeEvolution_followedExercises":
            MessageLookupByLibrary.simpleMessage("Exercícios realizados"),
        "episodeEvolution_last": MessageLookupByLibrary.simpleMessage("Última"),
        "episodeEvolution_noResults": MessageLookupByLibrary.simpleMessage(
            "Não há resultados disponíveis para este episódio."),
        "episodeEvolution_singleNumericValue":
            MessageLookupByLibrary.simpleMessage(
                "Apenas um valor numérico disponível"),
        "episodeEvolution_title":
            MessageLookupByLibrary.simpleMessage("Desenvolvimento do episódio"),
        "episodeEvolution_viewEvolution":
            MessageLookupByLibrary.simpleMessage("Ver a evolução"),
        "episodeFormEditor_error": MessageLookupByLibrary.simpleMessage("Erro"),
        "episodeFormEditor_noField": MessageLookupByLibrary.simpleMessage(
            "Não há campos para apresentar."),
        "episodeFormEditor_requiredField": m22,
        "episodeFormEditor_save":
            MessageLookupByLibrary.simpleMessage("Guardar"),
        "episodeFormEditor_title":
            MessageLookupByLibrary.simpleMessage("Editar o formulário"),
        "episodeForms_availableTemplates":
            MessageLookupByLibrary.simpleMessage("Modelos disponíveis"),
        "episodeForms_category":
            MessageLookupByLibrary.simpleMessage("Categoria"),
        "episodeForms_completed":
            MessageLookupByLibrary.simpleMessage("concluído"),
        "episodeForms_create": MessageLookupByLibrary.simpleMessage("Criar"),
        "episodeForms_createdForms":
            MessageLookupByLibrary.simpleMessage("Formulários criados"),
        "episodeForms_createdOn":
            MessageLookupByLibrary.simpleMessage("Criado em"),
        "episodeForms_customTemplate":
            MessageLookupByLibrary.simpleMessage("Modelo personalizado"),
        "episodeForms_error": MessageLookupByLibrary.simpleMessage("Erro"),
        "episodeForms_form": MessageLookupByLibrary.simpleMessage("Formulário"),
        "episodeForms_inProgress":
            MessageLookupByLibrary.simpleMessage("em curso"),
        "episodeForms_noAvailableTemplate":
            MessageLookupByLibrary.simpleMessage(
                "Não há nenhum modelo de formulário disponível."),
        "episodeForms_noCreatedForm": MessageLookupByLibrary.simpleMessage(
            "Não foi criado nenhum formulário para este episódio."),
        "episodeForms_noData": MessageLookupByLibrary.simpleMessage(
            "Não há dados para apresentar."),
        "episodeForms_refresh":
            MessageLookupByLibrary.simpleMessage("Atualizar"),
        "episodeForms_state": MessageLookupByLibrary.simpleMessage("Estado"),
        "episodeForms_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Modelo do sistema"),
        "episodeForms_title":
            MessageLookupByLibrary.simpleMessage("Formulários"),
        "episodeNotes_archive":
            MessageLookupByLibrary.simpleMessage("Arquivar"),
        "episodeNotes_archiveConfirmation": m23,
        "episodeNotes_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Arquivar a nota?"),
        "episodeNotes_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "episodeNotes_content":
            MessageLookupByLibrary.simpleMessage("Conteúdo"),
        "episodeNotes_editNote":
            MessageLookupByLibrary.simpleMessage("Alterar a nota"),
        "episodeNotes_error": MessageLookupByLibrary.simpleMessage("Erro"),
        "episodeNotes_modifiedOn":
            MessageLookupByLibrary.simpleMessage("Alterado em"),
        "episodeNotes_newNote":
            MessageLookupByLibrary.simpleMessage("Nova nota"),
        "episodeNotes_noNote": MessageLookupByLibrary.simpleMessage(
            "Não há nenhuma nota associada a este episódio."),
        "episodeNotes_noteTitle":
            MessageLookupByLibrary.simpleMessage("Título"),
        "episodeNotes_refresh":
            MessageLookupByLibrary.simpleMessage("Atualizar"),
        "episodeNotes_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "episodeNotes_title": MessageLookupByLibrary.simpleMessage("Notas"),
        "episodeNotes_titleRequired":
            MessageLookupByLibrary.simpleMessage("O título é obrigatório."),
        "episodeReferents_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite selecionar o fisioterapeuta responsável e o médico prescritor associados ao tratamento.\n\nSelecione os profissionais nas listas. Também pode remover uma associação, escolhendo a opção «sem profissional».\n\nOs botões de gestão situados à direita das listas permitem aceder aos ficheiros dos profissionais de saúde e dos contactos externos, nomeadamente para adicionar um profissional em falta.\n\nClique em «Guardar» para aplicar as associações selecionadas. As alterações relativas ao fisioterapeuta de referência são guardadas no histórico do tratamento.\n\n«Anular» descarta as alterações de associação nesta janela. Os registos eventualmente criados a partir dos ecrãs de gestão permanecem guardados."),
        "episodeReferents_title":
            MessageLookupByLibrary.simpleMessage("Alterar as referências"),
        "episodeReport_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origem ABAK"),
        "episodeReport_addConclusion":
            MessageLookupByLibrary.simpleMessage("Adicionar uma conclusão"),
        "episodeReport_clinicalConclusion":
            MessageLookupByLibrary.simpleMessage("Conclusão clínica"),
        "episodeReport_conclusionRequired":
            MessageLookupByLibrary.simpleMessage(
                "A conclusão não pode ficar em branco."),
        "episodeReport_documents":
            MessageLookupByLibrary.simpleMessage("Documentos"),
        "episodeReport_dominantSide":
            MessageLookupByLibrary.simpleMessage("Lado dominante"),
        "episodeReport_editConclusion":
            MessageLookupByLibrary.simpleMessage("Alterar a conclusão"),
        "episodeReport_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "episodeReport_error": MessageLookupByLibrary.simpleMessage("Erro"),
        "episodeReport_forms":
            MessageLookupByLibrary.simpleMessage("Formulários"),
        "episodeReport_generatedPreview": MessageLookupByLibrary.simpleMessage(
            "Visão geral do relatório gerado"),
        "episodeReport_generatingPreview": MessageLookupByLibrary.simpleMessage(
            "A gerar a pré-visualização do texto..."),
        "episodeReport_name": MessageLookupByLibrary.simpleMessage("Nome"),
        "episodeReport_noConclusion": MessageLookupByLibrary.simpleMessage(
            "Não foram indicadas quaisquer conclusões."),
        "episodeReport_noData": MessageLookupByLibrary.simpleMessage(
            "Não há dados para apresentar."),
        "episodeReport_noDocument": MessageLookupByLibrary.simpleMessage(
            "Não há documentos associados"),
        "episodeReport_noForm": MessageLookupByLibrary.simpleMessage(
            "Não há formulários associados"),
        "episodeReport_noNote":
            MessageLookupByLibrary.simpleMessage("Não há notas associadas"),
        "episodeReport_noResult": MessageLookupByLibrary.simpleMessage(
            "Não foram encontrados resultados relacionados"),
        "episodeReport_notProvided":
            MessageLookupByLibrary.simpleMessage("Não indicado"),
        "episodeReport_notes": MessageLookupByLibrary.simpleMessage("Notas"),
        "episodeReport_patient": MessageLookupByLibrary.simpleMessage("Doente"),
        "episodeReport_phone": MessageLookupByLibrary.simpleMessage("Telefone"),
        "episodeReport_profession":
            MessageLookupByLibrary.simpleMessage("Profissão"),
        "episodeReport_refresh":
            MessageLookupByLibrary.simpleMessage("Atualizar"),
        "episodeReport_results":
            MessageLookupByLibrary.simpleMessage("Resultados da ABAK"),
        "episodeReport_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "episodeReport_score":
            MessageLookupByLibrary.simpleMessage("Resultado"),
        "episodeReport_sportActivity":
            MessageLookupByLibrary.simpleMessage("Atividade desportiva"),
        "episodeReport_title":
            MessageLookupByLibrary.simpleMessage("Relatório"),
        "episodeReport_unknownType":
            MessageLookupByLibrary.simpleMessage("Tipo desconhecido"),
        "exchangeDirectoryReset":
            MessageLookupByLibrary.simpleMessage("Pasta de troca reiniciada"),
        "exchangeDirectoryService_choose": MessageLookupByLibrary.simpleMessage(
            "Escolher a pasta de intercâmbio ABAK"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Dossiê de intercâmbio ABAK atualizado"),
        "externalCorrespondentForm_addTitle":
            MessageLookupByLibrary.simpleMessage("Adicionar um contacto"),
        "externalCorrespondentForm_editTitle":
            MessageLookupByLibrary.simpleMessage("Alterar o contacto"),
        "externalCorrespondentForm_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite preencher o registo de um contacto externo.\n\nO nome é obrigatório. Pode preencher o nome próprio, a profissão, a especialidade, a morada, o código postal, a cidade, o endereço de e-mail e o número de telefone.\n\nClique em «Guardar» para validar o registo. «Anular» fecha a janela sem aplicar as alterações.\n\nAo abrir e fechar esta ajuda, os dados introduzidos no formulário são mantidos."),
        "externalCorrespondents_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã apresenta os contactos externos registados no Companion. Cada linha indica o nome do contacto e, quando preenchidos, a sua profissão, especialidade e cidade.\n\nClique em «Adicionar» para criar um contacto. Preencha os dados de identificação e os contactos relevantes e, em seguida, clique em «Guardar» para o adicionar à lista. «Cancelar» fecha o formulário sem criar nenhum contacto.\n\nEstes contactos podem, nomeadamente, ser selecionados como profissionais de referência nos percursos de cuidados."),
        "externalCorrespondents_title":
            MessageLookupByLibrary.simpleMessage("Correspondentes externos"),
        "externalSpeechToTextProvider_empty":
            MessageLookupByLibrary.simpleMessage(
                "O complemento não devolveu qualquer resposta."),
        "externalSpeechToTextProvider_failure":
            MessageLookupByLibrary.simpleMessage(
                "Falha no complemento de reconhecimento de voz."),
        "externalSpeechToTextProvider_invalid":
            MessageLookupByLibrary.simpleMessage(
                "Resposta inválida do complemento de reconhecimento de voz."),
        "externalSpeechToTextProvider_noText":
            MessageLookupByLibrary.simpleMessage(
                "O add-on não devolveu nenhum texto."),
        "externalSpeechToTextProvider_transcription":
            MessageLookupByLibrary.simpleMessage(
                "A transcrição não foi bem-sucedida."),
        "followUpNoteForm_createTitle":
            MessageLookupByLibrary.simpleMessage("Nova nota de acompanhamento"),
        "followUpNoteForm_editTitle": MessageLookupByLibrary.simpleMessage(
            "Alterar a nota de acompanhamento"),
        "followUpNoteForm_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite criar ou alterar uma nota de acompanhamento associada ao episódio de cuidados.\n\nPreencha o título e o conteúdo da nota. Estes dois campos têm de conter texto para que a nota seja guardada.\n\nAo criar a nota, clique em «Adicionar». Ao alterá-la, clique em «Guardar» para guardar as alterações.\n\n«Anular» fecha a janela sem guardar o que introduziu. Pode abrir e fechar esta ajuda sem perder o texto que está a redigir."),
        "followUpNotes_help": MessageLookupByLibrary.simpleMessage(
            "Esta vista apresenta as notas de acompanhamento do tratamento, com a respetiva data, título e um resumo do seu conteúdo.\n\nO botão «Adicionar» permite criar uma nota. O ícone de edição permite abrir uma nota existente para a consultar ou alterar.\n\nUtilize as caixas de seleção para escolher as notas a incluir no balanço ou no relatório em curso. Desmarcar uma nota retira-a desta seleção sem eliminar a nota de acompanhamento.\n\nA seleção está disponível quando um balanço ou um relatório está aberto e o carregamento estiver concluído.\n\nClique na cruz para fechar a vista ampliada e regressar à área Balanços/Relatórios."),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Prefixo ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Fechar"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Comentário"),
        "g_context": MessageLookupByLibrary.simpleMessage("Contexto"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Copiar"),
        "g_file": MessageLookupByLibrary.simpleMessage("Ficheiro"),
        "g_helpTooltip":
            MessageLookupByLibrary.simpleMessage("Mostrar a ajuda"),
        "g_learn_more": MessageLookupByLibrary.simpleMessage("Saiba mais"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Informações técnicas"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Informações técnicas copiadas"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Os doentes arquivados podem ser recuperados até à data indicada.\nApós essa data, são eliminados automaticamente, para que os registos não utilizados não sejam conservados indefinidamente.\nO período de conservação pode ser alterado nas definições do Companion."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "Trata-se dos dispositivos (telemóvel, tablet) utilizados para realizar os testes.\n- Um dispositivo pode ser utilizado por diferentes pessoas.\n- Uma pessoa pode possuir vários dispositivos.\n\nEsta informação permite identificar qual é a origem física da informação que é transferida para o Companion.\nPode criar, alterar ou arquivar um dispositivo.\n\nPor razões de rastreabilidade, não é possível eliminar um dispositivo\nSe necessário, pode restaurar um dispositivo arquivado.\n\nÉ utilizado um código QR para emparelhar um telemóvel ou um tablet. É necessário exibir o código QR no telefone fixo (Dispositivo > ícone correspondente ao dispositivo) e, no telemóvel (ou tablet), aceder a Definições > Organização profissional > Dispositivos registados > Adicionar um dispositivo.\n\nAproxime o dispositivo do ecrã para ler o código QR.Uma mensagem informa-o de que a operação foi bem-sucedida."),
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
            "Um tratamento corresponde a um episódio de cuidados de saúde.\nAqui pode consultar os diferentes tratamentos ativos do seu doente.\nPara associar um resultado, pode utilizar um episódio existente ou criar um novo.\nAssim que o episódio estiver concluído, pode arquivá-lo."),
        "homeImportSummary_conflicts":
            MessageLookupByLibrary.simpleMessage("Conflitos"),
        "homeImportSummary_failedFiles":
            MessageLookupByLibrary.simpleMessage("Ficheiros com erros"),
        "homeImportSummary_importDate":
            MessageLookupByLibrary.simpleMessage("Importação de dados"),
        "homeImportSummary_importedMetrics":
            MessageLookupByLibrary.simpleMessage("Métricas importadas"),
        "homeImportSummary_importedResults":
            MessageLookupByLibrary.simpleMessage("Resultados importados"),
        "homeImportSummary_open": MessageLookupByLibrary.simpleMessage("Abrir"),
        "homeImportSummary_patients":
            MessageLookupByLibrary.simpleMessage("Doentes abrangidos"),
        "homeImportSummary_processedFiles":
            MessageLookupByLibrary.simpleMessage("Ficheiros processados"),
        "homeImportSummary_skippedResults":
            MessageLookupByLibrary.simpleMessage("Resultados ignorados"),
        "homeImportSummary_title":
            MessageLookupByLibrary.simpleMessage("Última importação ABAK"),
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
        "home_correspondents":
            MessageLookupByLibrary.simpleMessage("Correspondentes"),
        "home_create_a_backup": MessageLookupByLibrary.simpleMessage(
            "Criar uma cópia de segurança"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Data não indicada"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Aparelhos"),
        "home_error_while_saving": m24,
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
        "home_other_exercises": m25,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Parâmetros"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Caminho"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Paciente ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Pacientes"),
        "home_pending_association": m26,
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
        "importHistory_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã apresenta o histórico das sessões de importação registadas no Companion.\n\nCada linha indica a data da sessão, o seu estado, o número de ficheiros processados e o número de resultados importados, ignorados ou em conflito.\n\nO ícone indica, nomeadamente, uma importação em curso, uma falha, erros ou conflitos que requerem a sua atenção.\n\nClique numa sessão para consultar os seus detalhes e compreender melhor o processamento dos resultados."),
        "importPatientForm_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite criar um doente para lhe associar os resultados importados do ABAK Mobile.\n\nIntroduza o nome e o apelido. Pode preencher a data de nascimento no formato AAAA-MM-DD e indicar o sexo, ou manter «Não preenchido».\n\nSe tiver utilizado a leitura do cartão Vitale, verifique as informações pré-preenchidas e corrija-as, se necessário.\n\nClique em «Criar» para registar o doente e selecioná-lo. Em seguida, escolha o atendimento ao qual associar os resultados: a criação do paciente, por si só, não conclui a associação da importação.\n\n«Anular» fecha esta janela sem criar nenhum paciente. Abrir e fechar esta ajuda guarda os dados introduzidos."),
        "importPatientForm_title":
            MessageLookupByLibrary.simpleMessage("Novo doente"),
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("ficheiro"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("ficheiros"),
        "importResolutionAssistant_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã reúne as importações que requerem a sua atenção: associação a um doente a completar, falha na importação, erros, resultados ignorados ou conflitos a analisar.\n\nCada linha indica a data da importação e as informações disponíveis para identificar o processo em questão.\n\nClique numa importação para abrir o seu registo de acompanhamento, consultar as explicações e aceder às ações sugeridas de acordo com a sua situação.\n\nA lista é atualizada quando regressar do registo de acompanhamento da importação. Se nenhuma importação corresponder a estes critérios, uma mensagem indica que não foi detetado qualquer problema."),
        "importResolutionAssistant_import":
            MessageLookupByLibrary.simpleMessage("Importar"),
        "importResolutionAssistant_importFailed":
            MessageLookupByLibrary.simpleMessage("Importação falhada"),
        "importResolutionAssistant_importToComplete":
            MessageLookupByLibrary.simpleMessage("Importação a concluir"),
        "importResolutionAssistant_importToReview":
            MessageLookupByLibrary.simpleMessage("Importação a verificar"),
        "importResolutionAssistant_inError":
            MessageLookupByLibrary.simpleMessage("por engano"),
        "importResolutionAssistant_interventionRequired":
            MessageLookupByLibrary.simpleMessage(
                "É necessária uma intervenção para concluir esta importação."),
        "importResolutionAssistant_loadingError":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível carregar as importações"),
        "importResolutionAssistant_noProblem":
            MessageLookupByLibrary.simpleMessage(
                "Não foi detetado qualquer problema de importação."),
        "importResolutionAssistant_result":
            MessageLookupByLibrary.simpleMessage("resultado"),
        "importResolutionAssistant_results":
            MessageLookupByLibrary.simpleMessage("resultados"),
        "importResolutionAssistant_selectImportInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Selecione uma importação para visualizar os seus detalhes e seguir os passos indicados."),
        "importResolutionAssistant_title": MessageLookupByLibrary.simpleMessage(
            "Resolução de problemas de importação"),
        "importResolutionAssistant_toReview":
            MessageLookupByLibrary.simpleMessage("a verificar"),
        "importResolution_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite associar os resultados recebidos do ABAK Mobile ao paciente correto e ao tratamento adequado no Companion.\n\nConsulte as informações da importação recebida e, em seguida, selecione o doente em questão na lista. Se necessário, crie o seu registo com «Novo doente» ou «A partir do Cartão Vitale», quando o dispositivo de leitura estiver disponível.\n\nDepois de selecionar o doente, escolha um tratamento ativo ou crie um. Um tratamento arquivado tem de ser restaurado antes de poder ser selecionado.\n\nVerifique o doente e o tratamento antes de escolher este último: a sua seleção valida a associação e permite prosseguir com a importação."),
        "importResolution_title":
            MessageLookupByLibrary.simpleMessage("Associar a importação"),
        "importSessionDetail_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã apresenta o acompanhamento de uma importação recebida no Companion. A mensagem principal indica se a importação foi bem-sucedida, se é necessária uma associação a um doente ou se existe algum problema.\n\nQuando for necessária uma associação, clique em «Associar a um doente» para escolher o processo ao qual associar os resultados.\n\nO relatório e a lista de ficheiros permitem consultar os detalhes do processamento e eventuais avisos.\n\nSe o ficheiro recebido estiver incompleto ou danificado, solicite um novo envio a partir do ABAK Mobile.\n\nDependendo da situação, é apresentado o botão «Eliminar esta importação». Consulte a mensagem de confirmação antes de confirmar a eliminação."),
        "importSessionDetail_title": MessageLookupByLibrary.simpleMessage(
            "Acompanhamento da importação"),
        "information_backupCount": m27,
        "information_backups":
            MessageLookupByLibrary.simpleMessage("Cópias de segurança"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Configurado"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "Este ecrã apresenta as informações gerais, técnicas e legais do Companion."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Informações"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Base de dados"),
        "information_help": MessageLookupByLibrary.simpleMessage(
            "Esta página apresenta informações gerais sobre a sua instalação do Companion: versão da aplicação, consultório configurado, presença do logótipo, sistema utilizado e idioma.\n\nA secção dedicada ao armazenamento local indica o tamanho da base de dados, bem como o número e o tamanho total das cópias de segurança guardadas.\n\nOs botões permitem consultar as novidades, a licença e os avisos relativos à utilização da aplicação.\n\nDurante um contacto com o apoio técnico, a versão do Companion e o sistema aqui apresentados podem ajudar a identificar a sua configuração."),
        "information_language": MessageLookupByLibrary.simpleMessage("Língua"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Aviso legal"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("A carregar..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Armazenamento local"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_new": MessageLookupByLibrary.simpleMessage(
            "Versão 1.1.0 compilação 3\nPossibilidade de ditado vocal para balanços e relatórios; requer o módulo gratuito.\nGravação automática de balanços e relatórios.\nBotão para duplicar balanços e relatórios.\nNotas editáveis.\nBotão para visualizar todos os exames de um doente relativos a um episódio.\nModelos de relatórios.\nGráfico automático caso existam vários resultados para um exame.\nCriação de um documento no formato docx.\nExibição da ajuda utilizada para E72 e E76"),
        "information_newHelp": MessageLookupByLibrary.simpleMessage(
            "Esta página apresenta as novidades e as atualizações descritas para o Companion.\n\nDeslize o texto para consultar todas as informações. Pode selecionar e copiar um trecho, se necessário.\n\nUtilize a seta de retorno para voltar à página «Sobre»."),
        "information_newTitle":
            MessageLookupByLibrary.simpleMessage("Novidades desta versão"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Não configurado"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Não indicado"),
        "information_office": MessageLookupByLibrary.simpleMessage("Gabinete"),
        "information_size": m28,
        "information_system": MessageLookupByLibrary.simpleMessage("Sistema"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Informações"),
        "information_totalSize": m29,
        "information_version": m30,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Versão..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("Consultar a licença"),
        "initialReportDocumentService_associate":
            MessageLookupByLibrary.simpleMessage(
                "Anexar um balanço inicial em Word"),
        "initialReportDocumentService_unsupported":
            MessageLookupByLibrary.simpleMessage("Plataforma não suportada"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Língua registada."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Idioma da aplicação"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Aviso"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "O ABAK Desktop Companion é um software que auxilia na organização, importação e consulta de resultados clínicos provenientes do ecossistema ABAK.\n\nNão se trata de um dispositivo médico certificado e não substitui o parecer do profissional de saúde.\n\nOs resultados, pontuações, relatórios e indicadores apresentados devem ser sempre interpretados por um profissional qualificado, tendo em conta o exame clínico, o contexto do doente e as recomendações em vigor.\n\nO utilizador é o único responsável pelas suas decisões clínicas, pela verificação dos dados importados e pela conformidade da sua utilização com as regras profissionais, regulamentares e deontológicas aplicáveis.\n\nO ABAK Desktop Companion não efetua diagnósticos autónomos, não prescreve qualquer tratamento e não substitui, em caso algum, uma consulta médica ou paramédica."),
        "legalNotice_help": MessageLookupByLibrary.simpleMessage(
            "Esta página apresenta os avisos e as informações relativos à utilização do Companion.\n\nDeslize a página para ler o texto na íntegra.\n\nUtilize a seta de retorno para voltar à página «Sobre»."),
        "legalNotice_title":
            MessageLookupByLibrary.simpleMessage("Aviso Legal"),
        "loading": MessageLookupByLibrary.simpleMessage("A carregar..."),
        "localDatabaseBackup_cancelled":
            MessageLookupByLibrary.simpleMessage("A gravação foi cancelada."),
        "localDatabaseBackup_chooseBackupFolder":
            MessageLookupByLibrary.simpleMessage(
                "Escolher a pasta de cópia de segurança do ABAK"),
        "localDatabaseBackup_databaseNotFound":
            MessageLookupByLibrary.simpleMessage(
                "Não foi encontrada a base de dados SQLite."),
        "localDatabaseReset_backupFailed": MessageLookupByLibrary.simpleMessage(
            "Não foi possível efetuar uma cópia de segurança prévia"),
        "localDatabaseRestoreService_anomaly": m31,
        "localDatabaseRestoreService_failure": m32,
        "localDatabaseRestoreService_integrity": m33,
        "localDatabaseRestoreService_missing":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível encontrar o ficheiro de cópia de segurança."),
        "localDatabaseRestoreService_success":
            MessageLookupByLibrary.simpleMessage(
                "A restauração foi concluída com sucesso."),
        "main_alreadyRunningMessage": MessageLookupByLibrary.simpleMessage(
            "Só pode estar aberta uma instância de cada vez.\n\nUtilize a janela Companion que já se encontra aberta."),
        "main_alreadyRunningTitle": MessageLookupByLibrary.simpleMessage(
            "O ABAK Desktop Companion já está aberto"),
        "main_close": MessageLookupByLibrary.simpleMessage(""),
        "modify": MessageLookupByLibrary.simpleMessage("Editar"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Nenhuma pasta definida"),
        "ok": MessageLookupByLibrary.simpleMessage("Tudo bem"),
        "open": MessageLookupByLibrary.simpleMessage("Abrir"),
        "organization_chooseLogo":
            MessageLookupByLibrary.simpleMessage("Escolher um logótipo"),
        "organization_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite introduzir o nome e os dados de contacto do seu escritório: morada, código postal, cidade, telefone e endereço de e-mail.\n\nClique em «Guardar dados de contacto» para guardar as suas alterações antes de sair do ecrã.\n\nTambém pode escolher uma imagem no seu computador para definir o logótipo do consultório. A escolha do logótipo é guardada imediatamente, independentemente dos dados de contacto.\n\nO botão para eliminar o logótipo permite remover o logótipo utilizado no Companion."),
        "organization_identityTitle":
            MessageLookupByLibrary.simpleMessage("Identidade da instituição"),
        "organization_logoRemoved": MessageLookupByLibrary.simpleMessage(
            "Logótipo do estabelecimento removido."),
        "organization_logoSaved": MessageLookupByLibrary.simpleMessage(
            "Logótipo do estabelecimento registado."),
        "organization_nameLabel":
            MessageLookupByLibrary.simpleMessage("Nome do estabelecimento"),
        "organization_nameSaved": MessageLookupByLibrary.simpleMessage(
            "Nome do estabelecimento registado."),
        "organization_removeLogo":
            MessageLookupByLibrary.simpleMessage("Remover o logótipo"),
        "organization_saveName":
            MessageLookupByLibrary.simpleMessage("Registar o nome"),
        "organization_title":
            MessageLookupByLibrary.simpleMessage("Estabelecimento"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Associar um telemóvel"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Associar um telemóvel"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Digitalize este código QR a partir da aplicação ABAK Mobile para configurar automaticamente a ligação ao Desktop."),
        "pairPhone_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela apresenta as informações que permitem ao ABAK Mobile localizar o Companion na rede local.\n\nLigue o telemóvel ou o tablet e o computador à mesma rede local e, em seguida, digitalize este código QR a partir da função de emparelhamento com o Companion no ABAK Mobile.\n\nO código QR contém o endereço de rede e a porta de comunicação deste computador. Estas informações também são apresentadas por baixo do código.\n\nMantenha o Companion aberto no computador durante a troca de dados. Se o endereço de rede do computador mudar, volte a abrir esta janela e digitalize o novo código.\n\nA exibição deste código QR, por si só, não aciona o envio de resultados."),
        "patientClinicalDataEdit_address":
            MessageLookupByLibrary.simpleMessage("Morada"),
        "patientClinicalDataEdit_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Identidade administrativa"),
        "patientClinicalDataEdit_ambidextrous":
            MessageLookupByLibrary.simpleMessage("Ambidestro"),
        "patientClinicalDataEdit_centimeters":
            MessageLookupByLibrary.simpleMessage("Em centímetros"),
        "patientClinicalDataEdit_dominantSide":
            MessageLookupByLibrary.simpleMessage("Lado dominante"),
        "patientClinicalDataEdit_email":
            MessageLookupByLibrary.simpleMessage("E-mail"),
        "patientClinicalDataEdit_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage(
                "Países com este sistema de saúde"),
        "patientClinicalDataEdit_height":
            MessageLookupByLibrary.simpleMessage("Tamanho"),
        "patientClinicalDataEdit_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite preencher os dados administrativos e o perfil do doente.\n\nPode introduzir o seu número de identificação de saúde, a fonte da sua identidade, o seu número de telefone, o seu endereço de e-mail e a sua morada postal.\n\nO perfil inclui o lado dominante, a profissão, a atividade desportiva, a altura em centímetros e o peso em quilogramas.\n\nClique em «Guardar» para guardar as suas alterações e regressar à ficha do doente. Se voltar atrás sem guardar, as alterações serão descartadas."),
        "patientClinicalDataEdit_identitySource":
            MessageLookupByLibrary.simpleMessage("Fonte da identidade"),
        "patientClinicalDataEdit_kilograms":
            MessageLookupByLibrary.simpleMessage("Em quilogramas"),
        "patientClinicalDataEdit_left":
            MessageLookupByLibrary.simpleMessage("Esquerda"),
        "patientClinicalDataEdit_manualEntry":
            MessageLookupByLibrary.simpleMessage("Introdução manual"),
        "patientClinicalDataEdit_nationalHealthId":
            MessageLookupByLibrary.simpleMessage(
                "Identificador Nacional de Saúde"),
        "patientClinicalDataEdit_nationalHealthIdHelper":
            MessageLookupByLibrary.simpleMessage(
                "Exemplo da França: número da segurança social"),
        "patientClinicalDataEdit_patientProfile":
            MessageLookupByLibrary.simpleMessage("Perfil do doente"),
        "patientClinicalDataEdit_phone":
            MessageLookupByLibrary.simpleMessage("Telefone"),
        "patientClinicalDataEdit_profession":
            MessageLookupByLibrary.simpleMessage("Profissão"),
        "patientClinicalDataEdit_right":
            MessageLookupByLibrary.simpleMessage("Direita"),
        "patientClinicalDataEdit_save":
            MessageLookupByLibrary.simpleMessage("Guardar"),
        "patientClinicalDataEdit_sportActivity":
            MessageLookupByLibrary.simpleMessage(
                "Atividade desportiva habitual"),
        "patientClinicalDataEdit_title":
            MessageLookupByLibrary.simpleMessage("Alterar os dados clínicos"),
        "patientClinicalDataEdit_unspecified":
            MessageLookupByLibrary.simpleMessage("Não especificado"),
        "patientClinicalDataEdit_vitaleCard":
            MessageLookupByLibrary.simpleMessage("Cartão de Saúde"),
        "patientClinicalDataEdit_weight":
            MessageLookupByLibrary.simpleMessage("Peso"),
        "patientDetail_address": MessageLookupByLibrary.simpleMessage("Morada"),
        "patientDetail_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Identidade administrativa"),
        "patientDetail_archived":
            MessageLookupByLibrary.simpleMessage("arquivado"),
        "patientDetail_bornOn":
            MessageLookupByLibrary.simpleMessage("Nem (nem) a"),
        "patientDetail_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "patientDetail_careEpisodeOpenedIn":
            MessageLookupByLibrary.simpleMessage("Apoio aberto em"),
        "patientDetail_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Coberturas"),
        "patientDetail_create": MessageLookupByLibrary.simpleMessage("Criar"),
        "patientDetail_dominantSide":
            MessageLookupByLibrary.simpleMessage("Lado dominante"),
        "patientDetail_edit": MessageLookupByLibrary.simpleMessage("Editar"),
        "patientDetail_editCareEpisode":
            MessageLookupByLibrary.simpleMessage("Alterar a cobertura"),
        "patientDetail_editCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite alterar as informações relativas ao atendimento do doente.\n\nPode corrigir a patologia ou o motivo do atendimento, completar o texto inicial e escolher o médico de referência, bem como o médico prescritor.\n\nA patologia deve ser preenchida para que as alterações sejam guardadas.\n\nClique em «Guardar» para confirmar as alterações. «Anular» fecha a janela sem as aplicar.\n\nAo abrir e fechar esta ajuda, os dados introduzidos no formulário são mantidos."),
        "patientDetail_editClinicalData":
            MessageLookupByLibrary.simpleMessage("Alterar os dados clínicos"),
        "patientDetail_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "patientDetail_error": MessageLookupByLibrary.simpleMessage("Erro"),
        "patientDetail_frHealthIdentity": MessageLookupByLibrary.simpleMessage(
            "Identidade de saúde — França"),
        "patientDetail_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage(
                "Países com sistemas de saúde"),
        "patientDetail_height": MessageLookupByLibrary.simpleMessage("Tamanho"),
        "patientDetail_identitySource":
            MessageLookupByLibrary.simpleMessage("Fonte de identidade"),
        "patientDetail_initialReport":
            MessageLookupByLibrary.simpleMessage("Relatório inicial"),
        "patientDetail_nationalIdentifier":
            MessageLookupByLibrary.simpleMessage(
                "Número de identificação nacional"),
        "patientDetail_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Nova cobertura"),
        "patientDetail_newCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite criar um novo registo de atendimento para o doente selecionado.\n\nIndique a patologia ou o motivo do atendimento. Esta informação é necessária para criar o episódio.\n\nPode completar o texto inicial e selecionar um médico de referência. Estas informações são opcionais.\n\nClique em «Criar» para registar o episódio. «Anular» fecha a janela sem o criar.\n\nAo abrir e fechar esta ajuda, os dados introduzidos no formulário são mantidos."),
        "patientDetail_noBirthdate":
            MessageLookupByLibrary.simpleMessage("Não preenchido"),
        "patientDetail_noCareEpisode": MessageLookupByLibrary.simpleMessage(
            "Não foi criado qualquer plano de cuidados para este doente."),
        "patientDetail_notProvided":
            MessageLookupByLibrary.simpleMessage("Não indicado"),
        "patientDetail_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("Não preenchido"),
        "patientDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Patologia"),
        "patientDetail_patientInformation":
            MessageLookupByLibrary.simpleMessage("Informações sobre o doente"),
        "patientDetail_patientProfile":
            MessageLookupByLibrary.simpleMessage("Perfil do doente"),
        "patientDetail_phone": MessageLookupByLibrary.simpleMessage("Telefone"),
        "patientDetail_profession":
            MessageLookupByLibrary.simpleMessage("Profissão"),
        "patientDetail_provisional":
            MessageLookupByLibrary.simpleMessage("Provisório"),
        "patientDetail_provisionalDescription":
            MessageLookupByLibrary.simpleMessage("Dados pessoais a preencher"),
        "patientDetail_qualified":
            MessageLookupByLibrary.simpleMessage("Qualificada"),
        "patientDetail_qualifiedDescription":
            MessageLookupByLibrary.simpleMessage("Identidade em conformidade"),
        "patientDetail_referringPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Fisioterapeuta de referência"),
        "patientDetail_retrieved":
            MessageLookupByLibrary.simpleMessage("Recuperada"),
        "patientDetail_retrievedDescription":
            MessageLookupByLibrary.simpleMessage(
                "N.º de identificação nacional obtido, identidade a verificar"),
        "patientDetail_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "patientDetail_sex": MessageLookupByLibrary.simpleMessage("Sexo"),
        "patientDetail_sportActivity":
            MessageLookupByLibrary.simpleMessage("Atividade desportiva"),
        "patientDetail_state": MessageLookupByLibrary.simpleMessage("Estado"),
        "patientDetail_status":
            MessageLookupByLibrary.simpleMessage("Estatuto"),
        "patientDetail_validated":
            MessageLookupByLibrary.simpleMessage("Validada"),
        "patientDetail_validatedDescription":
            MessageLookupByLibrary.simpleMessage(
                "Identidade verificada, INS a determinar"),
        "patientDetail_weight": MessageLookupByLibrary.simpleMessage("Peso"),
        "patientDetail_years": MessageLookupByLibrary.simpleMessage("anos"),
        "patientForm_birthDate":
            MessageLookupByLibrary.simpleMessage("Data de nascimento"),
        "patientForm_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "patientForm_create": MessageLookupByLibrary.simpleMessage("Criar"),
        "patientForm_editPatient":
            MessageLookupByLibrary.simpleMessage("Editar o doente"),
        "patientForm_female": MessageLookupByLibrary.simpleMessage("Mulher"),
        "patientForm_firstName":
            MessageLookupByLibrary.simpleMessage("Nome próprio"),
        "patientForm_firstNameRequired": MessageLookupByLibrary.simpleMessage(
            "O nome próprio é obrigatório"),
        "patientForm_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite introduzir ou corrigir os dados de identificação do doente.\n\nO apelido e o nome próprio são obrigatórios. Pode selecionar a data de nascimento no calendário e indicar o sexo, ou manter o valor «Não especificado».\n\nClique em «Guardar» para validar as alterações. Se o formulário estiver aberto no modo de criação, o botão «Criar» permite criar o registo.\n\n«Anular» fecha a janela sem aplicar as alterações. Ao abrir e fechar esta ajuda, os dados introduzidos no formulário são mantidos."),
        "patientForm_lastName": MessageLookupByLibrary.simpleMessage("Nome"),
        "patientForm_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("O nome é obrigatório"),
        "patientForm_male": MessageLookupByLibrary.simpleMessage("Homem"),
        "patientForm_newPatient":
            MessageLookupByLibrary.simpleMessage("Novo doente"),
        "patientForm_other": MessageLookupByLibrary.simpleMessage("Outros"),
        "patientForm_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "patientForm_sex": MessageLookupByLibrary.simpleMessage("Sexo"),
        "patientForm_unspecified":
            MessageLookupByLibrary.simpleMessage("Não especificado"),
        "patientList_active": MessageLookupByLibrary.simpleMessage("Ativos"),
        "patientList_archive": MessageLookupByLibrary.simpleMessage("Arquivar"),
        "patientList_archiveConfirmation": m34,
        "patientList_archiveSuccess": m35,
        "patientList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Arquivar o doente"),
        "patientList_archived":
            MessageLookupByLibrary.simpleMessage("Arquivados"),
        "patientList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Arquivado em"),
        "patientList_archivedPatient":
            MessageLookupByLibrary.simpleMessage("Paciente arquivado"),
        "patientList_archivedPatientsEmpty":
            MessageLookupByLibrary.simpleMessage(
                "O cesto dos doentes está vazio neste momento."),
        "patientList_bornOn":
            MessageLookupByLibrary.simpleMessage("Nem (nem) as"),
        "patientList_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "patientList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Pode visualizar a lista de doentes ativos e dos arquivados"),
        "patientList_contextName":
            MessageLookupByLibrary.simpleMessage("Lista de doentes"),
        "patientList_edit": MessageLookupByLibrary.simpleMessage("Editar"),
        "patientList_error": m36,
        "patientList_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite localizar os seus doentes e aceder aos seus processos clínicos.\n\nOs botões «Ativos» e «Arquivados» permitem selecionar a lista a apresentar. O número indicado corresponde ao total de doentes de cada categoria.\n\nPara procurar um doente na lista apresentada, introduza o nome ou o apelido completo ou parcial no campo de pesquisa. Clique na linha correspondente para abrir o seu processo.\n\nO botão «Novo paciente» abre o ecrã de criação de um paciente.\n\nPara um paciente ativo, o ícone do lápis permite alterar os seus dados pessoais. O ícone de arquivo permite removê-lo da lista de pacientes ativos após confirmação.\n\nNa lista de doentes arquivados, o ícone de restauração permite reposicionar um doente na lista de doentes ativos. Uma ajuda específica, acessível junto à data de arquivamento, especifica as modalidades de conservação."),
        "patientList_newPatient":
            MessageLookupByLibrary.simpleMessage("Novo doente"),
        "patientList_noArchivedPatients":
            MessageLookupByLibrary.simpleMessage("Não há doentes arquivados"),
        "patientList_noPatientFound": MessageLookupByLibrary.simpleMessage(
            "Não foram encontrados doentes"),
        "patientList_noRegisteredPatients":
            MessageLookupByLibrary.simpleMessage("Não há doentes registados"),
        "patientList_patientFileEmpty": MessageLookupByLibrary.simpleMessage(
            "O ficheiro local do doente está vazio neste momento."),
        "patientList_restorableUntil":
            MessageLookupByLibrary.simpleMessage("Pode ser restaurado até"),
        "patientList_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "patientList_restoreSuccess": m37,
        "patientList_searchPatient":
            MessageLookupByLibrary.simpleMessage("Pesquisar um doente"),
        "patientList_sex": MessageLookupByLibrary.simpleMessage("Sexo"),
        "patientList_title":
            MessageLookupByLibrary.simpleMessage("Lista de doentes"),
        "patientNew_archivedMatchToReview":
            MessageLookupByLibrary.simpleMessage(
                "Correspondência arquivada a verificar"),
        "patientNew_archivedMatchToReviewMessage":
            MessageLookupByLibrary.simpleMessage(
                "Já existe um doente arquivado com o mesmo apelido, nome próprio e data de nascimento, mas os seus dados administrativos são diferentes.\n\nNão será efetuada qualquer recuperação automática. Verifique os registos antes de continuar."),
        "patientNew_archivedPatientFound": MessageLookupByLibrary.simpleMessage(
            "Paciente encontrado nos arquivos"),
        "patientNew_archivedPatientMatch": MessageLookupByLibrary.simpleMessage(
            "Este Cartão Vitale corresponde ao doente arquivado:"),
        "patientNew_attach": MessageLookupByLibrary.simpleMessage("Associar"),
        "patientNew_attachVitaleError": MessageLookupByLibrary.simpleMessage(
            "Não foi possível associar o Cartão de Saúde"),
        "patientNew_attachVitaleQuestion": MessageLookupByLibrary.simpleMessage(
            "Deseja associar os dados do Cartão de Saúde a este doente?"),
        "patientNew_attachVitaleSuccess": m38,
        "patientNew_backToList":
            MessageLookupByLibrary.simpleMessage("Voltar à lista"),
        "patientNew_birthDate":
            MessageLookupByLibrary.simpleMessage("Data de nascimento"),
        "patientNew_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "patientNew_choosePatient":
            MessageLookupByLibrary.simpleMessage("Escolher o doente"),
        "patientNew_close": MessageLookupByLibrary.simpleMessage("Fechar"),
        "patientNew_contextComment": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite criar um novo doente através da introdução manual dos dados ou da leitura do Cartão Vitale."),
        "patientNew_contextName":
            MessageLookupByLibrary.simpleMessage("Novo doente"),
        "patientNew_createError":
            MessageLookupByLibrary.simpleMessage("Erro ao criar o paciente"),
        "patientNew_createPatient":
            MessageLookupByLibrary.simpleMessage("Criar o doente"),
        "patientNew_creating":
            MessageLookupByLibrary.simpleMessage("Criação..."),
        "patientNew_download":
            MessageLookupByLibrary.simpleMessage("Descarregar"),
        "patientNew_existingPatientTitle":
            MessageLookupByLibrary.simpleMessage("Já é paciente?"),
        "patientNew_female": MessageLookupByLibrary.simpleMessage("Feminino"),
        "patientNew_firstName":
            MessageLookupByLibrary.simpleMessage("Nome próprio"),
        "patientNew_firstNameRequired": MessageLookupByLibrary.simpleMessage(
            "O nome próprio é obrigatório"),
        "patientNew_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite criar um doente no ABAK Companion.\n\nIntroduza o nome e o apelido: estas duas informações são obrigatórias. Pode preencher a data de nascimento com a ajuda do calendário e indicar o sexo.\n\nO botão de leitura do cartão Vitale permite recuperar a identidade do doente quando o leitor e o módulo de leitura estiverem disponíveis. Se forem apresentados vários beneficiários, selecione a pessoa em questão e, em seguida, verifique as informações apresentadas. A introdução manual continua a ser possível.\n\nSe o Companion detetar um doente já existente, verifique as informações sugeridas antes de continuar, para evitar uma duplicação. Um doente arquivado pode ser sugerido para recuperação.\n\nClique em «Criar o doente» para guardar o registo, ou em «Anular» para sair sem criar o doente."),
        "patientNew_identificationCountriesHelp":
            MessageLookupByLibrary.simpleMessage(
                "A leitura do cartão Vitale disponibilizada no Companion diz respeito, atualmente, à França. Permite obter dados de identificação para facilitar a criação do ficheiro do doente.\n\nA ABAK Companion pretende alargar este processo aos meios de identificação utilizados noutros países. Os cartões, identificadores e serviços de saúde funcionam de forma diferente nesses países: o seu suporte ainda não está integrado no Companion. A introdução manual de dados continua disponível.\n\nPretendemos explorar estas possibilidades com os fisioterapeutas que utilizam o ABAK. Gostaria de nos ajudar no seu país? O seu conhecimento das práticas locais e a sua participação nos testes ajudar-nos-ão a definir uma solução útil e adequada.\n\nAs melhorias serão desenvolvidas progressivamente com os profissionais voluntários, de acordo com as necessidades expressas, as possibilidades técnicas e as autorizações necessárias."),
        "patientNew_identificationCountriesTitle":
            MessageLookupByLibrary.simpleMessage(
                "Identificação dos doentes por país"),
        "patientNew_lastName": MessageLookupByLibrary.simpleMessage("Nome"),
        "patientNew_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("O nome é obrigatório"),
        "patientNew_male": MessageLookupByLibrary.simpleMessage("Masculino"),
        "patientNew_matchToReview":
            MessageLookupByLibrary.simpleMessage("Correspondência a verificar"),
        "patientNew_matchToReviewMessage": MessageLookupByLibrary.simpleMessage(
            "Já existe um doente com o mesmo nome, apelido e data de nascimento.\n\nOs dados administrativos não correspondem totalmente. Verifique o processo antes de continuar."),
        "patientNew_matchingPatientFound": MessageLookupByLibrary.simpleMessage(
            "Foi encontrado um doente correspondente:"),
        "patientNew_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "patientNew_nirDetectedProtected":
            MessageLookupByLibrary.simpleMessage("detetado e protegido"),
        "patientNew_nirUnavailable":
            MessageLookupByLibrary.simpleMessage("indisponível"),
        "patientNew_no": MessageLookupByLibrary.simpleMessage("Não"),
        "patientNew_noNewPatientCreated": MessageLookupByLibrary.simpleMessage(
            "Não será criado nenhum novo doente."),
        "patientNew_notProvided":
            MessageLookupByLibrary.simpleMessage("Não indicado"),
        "patientNew_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("não preenchido"),
        "patientNew_other": MessageLookupByLibrary.simpleMessage("Outros"),
        "patientNew_patientAlreadyRegistered":
            MessageLookupByLibrary.simpleMessage("Paciente já registado"),
        "patientNew_patientIdentity":
            MessageLookupByLibrary.simpleMessage("Identidade do doente"),
        "patientNew_readOn":
            MessageLookupByLibrary.simpleMessage("Leitura realizada em"),
        "patientNew_readVitale":
            MessageLookupByLibrary.simpleMessage("Leia o cartão de saúde"),
        "patientNew_readerNotDetected": MessageLookupByLibrary.simpleMessage(
            "Leitor do Cartão Vitale não detetado"),
        "patientNew_readerNotDetectedMessage": MessageLookupByLibrary.simpleMessage(
            "O ABAK Desktop Companion não detetou nenhum leitor de Cartão Vitale.\n\nPara utilizar esta função, é necessário dispor de:\n\n• um leitor de Cartão Vitale compatível com PC/SC, normalmente ligado por USB;\n• o módulo ABAK Cartão Vitale, fornecido gratuitamente. Consulte o site abak.care.\n\nAssim que o leitor estiver ligado, clique novamente em «Ler Cartão Vitale»."),
        "patientNew_reading": MessageLookupByLibrary.simpleMessage("A ler..."),
        "patientNew_restore": MessageLookupByLibrary.simpleMessage("Restaurar"),
        "patientNew_restoreError": MessageLookupByLibrary.simpleMessage(
            "Não foi possível reanimar o doente"),
        "patientNew_restoreInsteadOfCreate": MessageLookupByLibrary.simpleMessage(
            "Prefere recuperar este ficheiro em vez de criar um novo paciente?"),
        "patientNew_restoreSuccess": m39,
        "patientNew_sex": MessageLookupByLibrary.simpleMessage("Sexo"),
        "patientNew_vitaleIdentityRead": MessageLookupByLibrary.simpleMessage(
            "Identidade lida a partir do Cartão Vitale"),
        "patientNew_vitaleMatchesPatient": MessageLookupByLibrary.simpleMessage(
            "Este Cartão de Saúde pertence ao doente:"),
        "patientNew_vitaleModuleConfigurationError":
            MessageLookupByLibrary.simpleMessage(
                "A configuração do módulo Carte Vitale está em falta ou está incorreta. Reinstale o módulo e tente novamente."),
        "patientNew_vitaleModuleNotInstalled":
            MessageLookupByLibrary.simpleMessage(
                "Módulo da Cartão Vitale não instalado"),
        "patientNew_vitaleModuleNotInstalledMessage":
            MessageLookupByLibrary.simpleMessage(
                "O módulo ABAK Carte Vitale não está instalado neste computador.\n\nPode descarregá-lo gratuitamente a partir do site da ABAK."),
        "patientNew_vitalePrefilled": MessageLookupByLibrary.simpleMessage(
            "Informações do doente pré-preenchidas a partir do Cartão Vitale."),
        "patientNew_vitaleReadFailed": MessageLookupByLibrary.simpleMessage(
            "A leitura do Cartão de Saúde falhou."),
        "practitionerList_active":
            MessageLookupByLibrary.simpleMessage("Ativos"),
        "practitionerList_addPractitionersHint":
            MessageLookupByLibrary.simpleMessage(
                "Adicione os fisioterapeutas do consultório para identificar os testes importados."),
        "practitionerList_archive":
            MessageLookupByLibrary.simpleMessage("Arquivar"),
        "practitionerList_archiveConfirmation": m40,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "O cesto dos fisioterapeutas está vazio, por enquanto."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage("Arquivar o fisioterapeuta"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Arquivados"),
        "practitionerList_archivedOn": m41,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Criar um profissional"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Este ecrã apresenta a lista dos profissionais de saúde registados."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("Lista de profissionais"),
        "practitionerList_edit": MessageLookupByLibrary.simpleMessage("Editar"),
        "practitionerList_error": m42,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Não há fisioterapeutas arquivados"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "Não há fisioterapeutas registados"),
        "practitionerList_professionalId": m43,
        "practitionerList_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "practitionerList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Mostrar o código QR"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Lista de profissionais"),
        "practitionerNew_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "practitionerNew_cet_ecran_permet":
            MessageLookupByLibrary.simpleMessage(
                "Este ecrã permite criar um profissional de saúde."),
        "practitionerNew_create": MessageLookupByLibrary.simpleMessage("Criar"),
        "practitionerNew_displayName":
            MessageLookupByLibrary.simpleMessage("Nome apresentado"),
        "practitionerNew_displayNameRequired":
            MessageLookupByLibrary.simpleMessage(
                "O nome apresentado é obrigatório"),
        "practitionerNew_editPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Alterar o profissional de saúde"),
        "practitionerNew_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "practitionerNew_firstName":
            MessageLookupByLibrary.simpleMessage("Nome próprio"),
        "practitionerNew_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite criar ou alterar o registo de um profissional de saúde.\n\nO nome apresentado é obrigatório: permite identificar o profissional de saúde no Companion. Também pode indicar o seu nome próprio, apelido, identificação profissional, endereço de e-mail e número de telefone.\n\nClique em «Criar» para adicionar um profissional de saúde ou em «Guardar» para confirmar as alterações num registo existente.\n\n«Anular» fecha a janela sem aplicar as alterações. Ao abrir e fechar esta ajuda, os dados introduzidos no formulário são mantidos."),
        "practitionerNew_lastName":
            MessageLookupByLibrary.simpleMessage("Nome"),
        "practitionerNew_newPractitioner":
            MessageLookupByLibrary.simpleMessage("Novo profissional"),
        "practitionerNew_phone":
            MessageLookupByLibrary.simpleMessage("Telefone"),
        "practitionerNew_professionalId":
            MessageLookupByLibrary.simpleMessage("Identificação profissional"),
        "practitionerNew_professionalIdHint":
            MessageLookupByLibrary.simpleMessage("RPPS, ADELI…"),
        "practitionerNew_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "practitionerQr_close": MessageLookupByLibrary.simpleMessage("Fechar"),
        "practitionerQr_defaultOrganizationName":
            MessageLookupByLibrary.simpleMessage("Gabinete"),
        "practitionerQr_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela apresenta o código QR do perfil profissional do profissional de saúde, acompanhado do seu nome e do nome do consultório.\n\nDigitalize este código QR a partir da aplicação ABAK Mobile para identificar o profissional de saúde neste estabelecimento. Verifique se o nome apresentado corresponde ao profissional em questão.\n\nEste código QR serve para transmitir as informações de identificação do perfil profissional; a sua visualização não desencadeia a transferência de resultados.\n\nFeche esta janela para regressar à lista de profissionais de saúde."),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("Perfil profissional da ABAK"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Digitalize este código QR a partir da aplicação ABAK Mobile para adicionar automaticamente este perfil profissional."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("arquivado"),
        "practitionerSelector_error": m44,
        "practitionerSelector_noSelection":
            MessageLookupByLibrary.simpleMessage("Nenhuma seleção"),
        "preferences_archivedPatients":
            MessageLookupByLibrary.simpleMessage("Pacientes arquivados"),
        "preferences_contextComment": MessageLookupByLibrary.simpleMessage(
            "Este ecrã centraliza as definições gerais do Companion."),
        "preferences_contextName":
            MessageLookupByLibrary.simpleMessage("Definições do utilizador"),
        "preferences_days": MessageLookupByLibrary.simpleMessage("dias"),
        "preferences_expertMode":
            MessageLookupByLibrary.simpleMessage("Especialista em Moda"),
        "preferences_expertModeDescription": MessageLookupByLibrary.simpleMessage(
            "Apresenta informações técnicas destinadas a programadores e colaboradores."),
        "preferences_expertModeSaved": MessageLookupByLibrary.simpleMessage(
            "Parâmetro do modo «Expert» guardado."),
        "preferences_languageSaved":
            MessageLookupByLibrary.simpleMessage("Língua registada."),
        "preferences_organization":
            MessageLookupByLibrary.simpleMessage("Estabelecimento"),
        "preferences_organizationDescription":
            MessageLookupByLibrary.simpleMessage(
                "Nome, logótipo e informações gerais."),
        "preferences_retentionDuration":
            MessageLookupByLibrary.simpleMessage("Prazo de validade"),
        "preferences_retentionExplanation": MessageLookupByLibrary.simpleMessage(
            "Os doentes arquivados podem ser recuperados durante este período. Posteriormente, serão eliminados automaticamente."),
        "preferences_retentionSaved": MessageLookupByLibrary.simpleMessage(
            "Prazo de validade registado."),
        "recentImportCard_conflict":
            MessageLookupByLibrary.simpleMessage("conflito"),
        "recentImportCard_error": MessageLookupByLibrary.simpleMessage("erro"),
        "recentImportCard_fichier":
            MessageLookupByLibrary.simpleMessage("ficheiro"),
        "recentImportCard_file":
            MessageLookupByLibrary.simpleMessage("ficheiro"),
        "recentImportCard_ignored":
            MessageLookupByLibrary.simpleMessage("ignorado"),
        "recentImportCard_no_result_imported":
            MessageLookupByLibrary.simpleMessage(
                "Não foram importados resultados"),
        "recentImportCard_result":
            MessageLookupByLibrary.simpleMessage("resultado"),
        "referringPractitionerHistoryDialog_archivedPractitioner": m45,
        "referringPractitionerHistoryDialog_close":
            MessageLookupByLibrary.simpleMessage("Fechar"),
        "referringPractitionerHistoryDialog_currentPractitioner":
            MessageLookupByLibrary.simpleMessage("Responsável atual"),
        "referringPractitionerHistoryDialog_fromTo": m46,
        "referringPractitionerHistoryDialog_loadHistoryError": m47,
        "referringPractitionerHistoryDialog_noHistory":
            MessageLookupByLibrary.simpleMessage(
                "Ainda não foi registado nenhum fisioterapeuta de referência para este caso."),
        "referringPractitionerHistoryDialog_since": m48,
        "referringPractitionerHistory_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela apresenta os profissionais de saúde que foram designados como responsáveis por este episódio de cuidados.\n\nCada linha indica o nome do profissional e o seu período de atribuição. A menção «Responsável atual» identifica o profissional atualmente associado ao episódio.\n\nA menção «arquivado» significa que o registo do profissional de saúde está arquivado; o seu nome permanece visível no histórico.\n\nEsta janela permite apenas consultar o histórico. Feche-a para regressar ao episódio de cuidados."),
        "referringPractitionerHistory_title":
            MessageLookupByLibrary.simpleMessage(
                "Histórico dos fisioterapeutas de referência"),
        "refreshDashboard": MessageLookupByLibrary.simpleMessage(
            "Atualizar o painel de controlo"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Arquivo de relatórios"),
        "reportDraft_help": MessageLookupByLibrary.simpleMessage(
            "O texto apresentado corresponde a um trabalho em curso guardado automaticamente. Pode mantê-lo, alterá-lo ou eliminá-lo antes de guardar o seu relatório."),
        "reportDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Compreender o rascunho do relatório"),
        "reportHistory_help": MessageLookupByLibrary.simpleMessage(
            "Esta vista apresenta os relatórios guardados relativos ao atendimento, com o respetivo título e data.\n\nAs ações em cada linha permitem editar um relatório, duplicá-lo ou movê-lo para os documentos arquivados.\n\nQuando um relatório estiver aberto para edição, utilize a ação de atualização para guardar as suas alterações. Os comandos disponíveis permitem também anular as alterações ou voltar ao rascunho.\n\nA transferência para os documentos arquivados não constitui uma eliminação definitiva.\n\nClique na cruz para fechar a vista ampliada e regressar à área Balanços/Relatórios."),
        "reset": MessageLookupByLibrary.simpleMessage("Reiniciar"),
        "resultDetail_addCommentHint":
            MessageLookupByLibrary.simpleMessage("Adicionar um comentário..."),
        "resultDetail_archiveConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Quer mesmo arquivar este resultado?"),
        "resultDetail_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Arquivar o resultado"),
        "resultDetail_birthDate":
            MessageLookupByLibrary.simpleMessage("Nascimento"),
        "resultDetail_cancel": MessageLookupByLibrary.simpleMessage("Aparelho"),
        "resultDetail_clinicalComment":
            MessageLookupByLibrary.simpleMessage("Comentário clínico"),
        "resultDetail_commentSaved":
            MessageLookupByLibrary.simpleMessage("Comentário guardado"),
        "resultDetail_detailedResult":
            MessageLookupByLibrary.simpleMessage("Resultado detalhado"),
        "resultDetail_device":
            MessageLookupByLibrary.simpleMessage("Detalhes do aparelho"),
        "resultDetail_exerciseDate":
            MessageLookupByLibrary.simpleMessage("Data do exercício"),
        "resultDetail_generalInformation":
            MessageLookupByLibrary.simpleMessage("Informações gerais"),
        "resultDetail_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã apresenta as informações de um resultado importado do ABAK Mobile: doente, data da realização, pontuação e, quando disponíveis, o auxílio utilizado, a identidade do profissional de saúde e o aparelho de origem.\n\nPode consultar o relatório detalhado e as medições complementares transmitidas pelo exercício.\n\nA secção «Comentário clínico» permite adicionar ou alterar as suas observações. Clique em «Guardar» para as guardar antes de sair do ecrã.\n\nA secção dedicada à importação indica o estado da sincronização e a data da última alteração do resultado.\n\nO ícone de arquivo permite arquivar este resultado após confirmação."),
        "resultDetail_identityUnverified":
            MessageLookupByLibrary.simpleMessage("Identidade não verificada"),
        "resultDetail_identityVerified":
            MessageLookupByLibrary.simpleMessage("Identidade verificada"),
        "resultDetail_import": MessageLookupByLibrary.simpleMessage("Importar"),
        "resultDetail_lastModified":
            MessageLookupByLibrary.simpleMessage("Última alteração"),
        "resultDetail_metrics":
            MessageLookupByLibrary.simpleMessage("Métricas"),
        "resultDetail_noMetrics":
            MessageLookupByLibrary.simpleMessage("Não há métricas registadas."),
        "resultDetail_patient": MessageLookupByLibrary.simpleMessage("Doente"),
        "resultDetail_performedBy":
            MessageLookupByLibrary.simpleMessage("Realizado por"),
        "resultDetail_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "resultDetail_score": MessageLookupByLibrary.simpleMessage("Resultado"),
        "resultDetail_syncState":
            MessageLookupByLibrary.simpleMessage("Estado de sincronização"),
        "settings_assistanceWarning": MessageLookupByLibrary.simpleMessage(
            "Estas funções destinam-se à instalação, ao diagnóstico e às operações de assistência técnica.\n\nUtilize-as apenas quando um técnico ou a documentação da ABAK o solicitar."),
        "settings_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "settings_configuration":
            MessageLookupByLibrary.simpleMessage("Configuração"),
        "settings_confirmationRequired":
            MessageLookupByLibrary.simpleMessage("Confirmação obrigatória"),
        "settings_contextComment": MessageLookupByLibrary.simpleMessage(
            "Este ecrã reúne as funções de instalação, diagnóstico e manutenção do Companion."),
        "settings_contextName":
            MessageLookupByLibrary.simpleMessage("Assistência"),
        "settings_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
        "settings_databaseResetError": m49,
        "settings_databaseResetSuccess": MessageLookupByLibrary.simpleMessage(
            "Base reiniciada. Cópia de segurança automática criada."),
        "settings_diagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnóstico"),
        "settings_edit": MessageLookupByLibrary.simpleMessage("Editar"),
        "settings_exchangeDirectory":
            MessageLookupByLibrary.simpleMessage("Dossiê de intercâmbio ABAK"),
        "settings_exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Pasta de partilha reiniciada"),
        "settings_exchangeDirectoryUpdated":
            MessageLookupByLibrary.simpleMessage(
                "Dossier de intercâmbio ABAK atualizado"),
        "settings_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã reúne as funções de instalação, diagnóstico e manutenção do Companion. Utilize-as de acordo com as indicações da documentação da ABAK ou de um técnico.\n\nA secção «Configuração» permite consultar, abrir ou alterar a pasta utilizada para a troca de ficheiros.\n\nA secção «Diagnóstico» dá acesso às verificações do dispositivo de leitura do cartão Vitale.\n\nA secção «Manutenção» permite abrir o assistente de resolução de problemas de importação, importar manualmente um ficheiro ABAK e aceder à gestão das cópias de segurança.\n\nA reinicialização da base de dados elimina os dados locais. Esta operação está reservada a situações de assistência técnica: leia atentamente as mensagens de confirmação antes de prosseguir."),
        "settings_importAbakFile": MessageLookupByLibrary.simpleMessage(
            "Importar manualmente um ficheiro .abak"),
        "settings_invalidConfirmation":
            MessageLookupByLibrary.simpleMessage("Confirmação inválida."),
        "settings_loading":
            MessageLookupByLibrary.simpleMessage("A carregar..."),
        "settings_maintenance":
            MessageLookupByLibrary.simpleMessage("Manutenção"),
        "settings_manageBackups": MessageLookupByLibrary.simpleMessage(
            "Gerir as cópias de segurança"),
        "settings_noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Nenhum ficheiro definido"),
        "settings_open": MessageLookupByLibrary.simpleMessage("Abrir"),
        "settings_openingExchangeDirectory":
            MessageLookupByLibrary.simpleMessage(
                "Abertura do processo de intercâmbio"),
        "settings_reset": MessageLookupByLibrary.simpleMessage("Reiniciar"),
        "settings_resetDatabase":
            MessageLookupByLibrary.simpleMessage("Reiniciar a base"),
        "settings_resetDatabaseTitle": MessageLookupByLibrary.simpleMessage(
            "Reiniciar a base de dados local?"),
        "settings_resetDatabaseWarning": MessageLookupByLibrary.simpleMessage(
            "Esta operação irá eliminar todos os dados locais (pacientes, resultados, importações e históricos).\n\nSerá criada uma cópia de segurança automática antes da reinicialização.\n\nUtilize esta função apenas no âmbito de uma intervenção de assistência técnica."),
        "settings_resetKeyword":
            MessageLookupByLibrary.simpleMessage("REINÍCIAR"),
        "settings_resetTooltip":
            MessageLookupByLibrary.simpleMessage("Reiniciar"),
        "settings_resolveImportProblem": MessageLookupByLibrary.simpleMessage(
            "Resolver um problema de importação"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Assistência"),
        "settings_typeResetConfirmation": MessageLookupByLibrary.simpleMessage(
            "Digite RESET para confirmar definitivamente."),
        "settings_vitaleDiagnostic": MessageLookupByLibrary.simpleMessage(
            "Diagnóstico do Cartão de Saúde"),
        "smartCardDiagnostic": MessageLookupByLibrary.simpleMessage(
            "Diagnóstico do Cartão de Saúde"),
        "speechDictationButton_audio": MessageLookupByLibrary.simpleMessage(
            "Não há nenhuma gravação de áudio disponível."),
        "speechDictationButton_close":
            MessageLookupByLibrary.simpleMessage("Fechar"),
        "speechDictationButton_dictate":
            MessageLookupByLibrary.simpleMessage("Raiva"),
        "speechDictationButton_download":
            MessageLookupByLibrary.simpleMessage("Descarregar o módulo"),
        "speechDictationButton_failure": m50,
        "speechDictationButton_information": MessageLookupByLibrary.simpleMessage(
            "A ditado por voz requer a instalação do módulo opcional ABAK Ditado por voz.\n\nEste módulo é gratuito e funciona localmente no seu computador, sem enviar as gravações de voz para a Internet.\n\nO download tem cerca de 1,5 GB."),
        "speechDictationButton_stop":
            MessageLookupByLibrary.simpleMessage("Parar o ditado"),
        "speechDictationButton_title":
            MessageLookupByLibrary.simpleMessage("Dictado por voz"),
        "speechRecordingService_permission":
            MessageLookupByLibrary.simpleMessage(
                "Não é permitido o acesso ao microfone."),
        "systemOverviewBar_active_patients":
            MessageLookupByLibrary.simpleMessage("Doentes ativos"),
        "systemOverviewBar_alert":
            MessageLookupByLibrary.simpleMessage("Alertas"),
        "systemOverviewBar_archived_patients":
            MessageLookupByLibrary.simpleMessage("Pacientes arquivados"),
        "systemOverviewBar_loading_system_summary":
            MessageLookupByLibrary.simpleMessage(
                "A carregar o resumo do sistema..."),
        "systemOverviewBar_supervision_error":
            MessageLookupByLibrary.simpleMessage("Erro de supervisão"),
        "systemOverviewBar_supervision_unavailable":
            MessageLookupByLibrary.simpleMessage("Supervisão indisponível"),
        "systemStatusCard_nome":
            MessageLookupByLibrary.simpleMessage("Nenhuma"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Definições do utilizador"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Definições do utilizador"),
        "vitaleBeneficiarySelector_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "vitaleBeneficiarySelector_help": MessageLookupByLibrary.simpleMessage(
            "Esta janela permite selecionar a pessoa em questão quando são apresentados vários beneficiários após a leitura do cartão Vitale.\n\nVerifique o apelido, o nome próprio e a data de nascimento, quando disponível, e, em seguida, clique na linha do beneficiário pretendido.\n\nA seleção fecha esta janela e transmite a identidade escolhida para a etapa seguinte.\n\n«Anular» fecha a janela sem selecionar nenhum beneficiário."),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage("Selecione um beneficiário"),
        "vitaleDiagnostic_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite verificar o funcionamento do dispositivo de leitura do cartão Vitale.\n\nNo Windows, a secção dedicada ao módulo indica o seu estado e permite atualizar essa informação.\n\nInicie uma leitura com o leitor ligado e o cartão inserido. Se forem apresentados vários beneficiários, selecione a pessoa em questão para consultar as informações lidas.\n\nAs mensagens apresentadas permitem compreender uma eventual falha e podem ser comunicadas ao serviço de assistência.\n\nA secção «Diagnóstico avançado» oferece um teste técnico de comunicação com o cartão. Utilize-a de acordo com as instruções da documentação da ABAK ou de um técnico.\n\nEste ecrã destina-se ao diagnóstico: a leitura de uma identidade não cria um registo de paciente."),
        "vitaleIdentity_birthDate":
            MessageLookupByLibrary.simpleMessage("Data de nascimento"),
        "vitaleIdentity_dataMasked":
            MessageLookupByLibrary.simpleMessage("dado ocultado"),
        "vitaleIdentity_detected":
            MessageLookupByLibrary.simpleMessage("detetado"),
        "vitaleIdentity_female":
            MessageLookupByLibrary.simpleMessage("Feminino"),
        "vitaleIdentity_firstName":
            MessageLookupByLibrary.simpleMessage("Nome próprio"),
        "vitaleIdentity_help": MessageLookupByLibrary.simpleMessage(
            "Este ecrã permite ler os dados de identificação de um beneficiário a partir de um cartão Vitale, desde que o leitor e o módulo de leitura estejam disponíveis.\n\nA leitura inicia-se assim que o ecrã é aberto. Pode reiniciá-la através do botão de leitura. Se houver vários beneficiários no cartão, selecione a pessoa em questão.\n\nVerifique o apelido, o nome próprio, a data de nascimento e as restantes informações apresentadas. O número de identificação é indicado como detetado ou indisponível, sem ser apresentado na íntegra.\n\nQuando a identidade estiver disponível, o botão de criação do doente permite transferir estas informações para o formulário de criação.\n\nSe não houver nenhuma identidade disponível, consulte a mensagem apresentada e verifique o dispositivo de leitura antes de tentar novamente. Pode regressar ao ecrã anterior para efetuar uma introdução manual."),
        "vitaleIdentity_identityRead":
            MessageLookupByLibrary.simpleMessage("Identidade lida"),
        "vitaleIdentity_identityReceivedMasked":
            MessageLookupByLibrary.simpleMessage(
                "identidade recebida (dados pessoais ocultados)"),
        "vitaleIdentity_identityUnavailable":
            MessageLookupByLibrary.simpleMessage("identidade indisponível"),
        "vitaleIdentity_lastName": MessageLookupByLibrary.simpleMessage("Nome"),
        "vitaleIdentity_male":
            MessageLookupByLibrary.simpleMessage("Masculino"),
        "vitaleIdentity_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "vitaleIdentity_noIdentityAvailable":
            MessageLookupByLibrary.simpleMessage(
                "Não existe nenhuma identificação da Carte Vitale disponível"),
        "vitaleIdentity_notProvided":
            MessageLookupByLibrary.simpleMessage("Não indicado"),
        "vitaleIdentity_other": MessageLookupByLibrary.simpleMessage("Outros"),
        "vitaleIdentity_reading":
            MessageLookupByLibrary.simpleMessage("A ler..."),
        "vitaleIdentity_sex": MessageLookupByLibrary.simpleMessage("Sexo"),
        "vitaleIdentity_source": MessageLookupByLibrary.simpleMessage("Fonte"),
        "vitaleIdentity_title": MessageLookupByLibrary.simpleMessage(
            "Ler os dados da Cartão de Saúde"),
        "vitaleIdentity_unavailable":
            MessageLookupByLibrary.simpleMessage("Indisponível"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Utilizar para criar um doente"),
        "walkingAid_cane": MessageLookupByLibrary.simpleMessage("Bengala"),
        "walkingAid_label":
            MessageLookupByLibrary.simpleMessage("Ajuda utilizada"),
        "walkingAid_none": MessageLookupByLibrary.simpleMessage("Nenhuma"),
        "walkingAid_other": MessageLookupByLibrary.simpleMessage("Outros"),
        "walkingAid_rollatorFourWheels":
            MessageLookupByLibrary.simpleMessage("Andador de 4 rodas"),
        "walkingAid_walkerTwoWheels":
            MessageLookupByLibrary.simpleMessage("Andador de duas rodas")
      };
}
