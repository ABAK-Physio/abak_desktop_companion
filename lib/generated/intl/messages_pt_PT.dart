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

  static String m5(deviceName) => "Quer mesmo arquivar o ${deviceName}?";

  static String m6(fieldName) => "O campo «${fieldName}» é obrigatório.";

  static String m7(noteTitle) =>
      "A nota «${noteTitle}» deixará de ser apresentada.";

  static String m8(error) => "Erro ao guardar: ${error}";

  static String m9(count) => "${count} outro(s) exercício(s)";

  static String m10(count) => "${count} associação(ões) pendentes";

  static String m11(count) => "${count} cópias de segurança";

  static String m12(size) => "Tamanho: ${size}";

  static String m13(size) => "Dimensão total: ${size}";

  static String m14(version) => "Versão ${version}";

  static String m15(integrityStatus) =>
      "A base de dados restaurada apresenta uma anomalia: ${integrityStatus}";

  static String m16(error) => "Falha na restauração: ${error}";

  static String m17(integrityStatus) =>
      "A restauração foi concluída, mas o integrity_check devolveu: ${integrityStatus}";

  static String m18(patientName) =>
      "Quer mesmo arquivar ${patientName}? Este já não será apresentado na lista ativa.";

  static String m19(patientName) => "${patientName} arquivado.";

  static String m20(error) => "Erro: ${error}";

  static String m21(patientName) =>
      "${patientName} foi reposto na lista ativa.";

  static String m22(patientName) =>
      "Cartão Vitale associado ao doente ${patientName}.";

  static String m23(patientName) => "O doente ${patientName} foi recuperado.";

  static String m24(practitionerName) =>
      "Quer mesmo arquivar ${practitionerName}?";

  static String m25(date) => "Arquivado em ${date}";

  static String m26(error) => "Erro: ${error}";

  static String m27(professionalId) => "ID profissional: ${professionalId}";

  static String m28(error) => "Erro: ${error}";

  static String m29(error) => "Erro durante a reinicialização: ${error}";

  static String m30(error) => "A ditado por voz falhou: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "abakWhisperSpeechProvider_name":
            MessageLookupByLibrary.simpleMessage("ABAK Dictado por voz"),
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
        "backupHistory_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "Não há nenhuma cópia de segurança registada."),
        "backupHistory_fileSize": m4,
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "backupHistory_restoreTitle": MessageLookupByLibrary.simpleMessage(
            "Restaurar esta cópia de segurança?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Esta operação substituirá totalmente a base de dados atual.\n\nSerá criada uma cópia de segurança automática antes da restauração.\n\nDeseja continuar?"),
        "backupHistory_title": MessageLookupByLibrary.simpleMessage(
            "Histórico de cópias de segurança"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origem ABAK"),
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
        "deviceList_archiveConfirmation": m5,
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
        "episodeFormEditor_requiredField": m6,
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
        "episodeNotes_archiveConfirmation": m7,
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
        "home_create_a_backup": MessageLookupByLibrary.simpleMessage(
            "Criar uma cópia de segurança"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Data não indicada"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Aparelhos"),
        "home_error_while_saving": m8,
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
        "home_other_exercises": m9,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Parâmetros"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Caminho"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Paciente ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Pacientes"),
        "home_pending_association": m10,
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
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("ficheiro"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("ficheiros"),
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
        "information_backupCount": m11,
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
        "information_language": MessageLookupByLibrary.simpleMessage("Língua"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Aviso legal"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("A carregar..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Armazenamento local"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Não configurado"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Não indicado"),
        "information_office": MessageLookupByLibrary.simpleMessage("Gabinete"),
        "information_size": m12,
        "information_system": MessageLookupByLibrary.simpleMessage("Sistema"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Informações"),
        "information_totalSize": m13,
        "information_version": m14,
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
        "localDatabaseRestoreService_anomaly": m15,
        "localDatabaseRestoreService_failure": m16,
        "localDatabaseRestoreService_integrity": m17,
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
        "patientList_archiveConfirmation": m18,
        "patientList_archiveSuccess": m19,
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
        "patientList_error": m20,
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
        "patientList_restoreSuccess": m21,
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
        "patientNew_attachVitaleSuccess": m22,
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
            MessageLookupByLibrary.simpleMessage("Ler o Cartão Vitale"),
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
        "patientNew_restoreSuccess": m23,
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
        "practitionerList_archiveConfirmation": m24,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "O cesto dos fisioterapeutas está vazio, por enquanto."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage("Arquivar o fisioterapeuta"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Arquivados"),
        "practitionerList_archivedOn": m25,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Criar um profissional"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Este ecrã apresenta a lista dos profissionais de saúde registados."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("Lista de profissionais"),
        "practitionerList_edit": MessageLookupByLibrary.simpleMessage("Editar"),
        "practitionerList_error": m26,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage(
                "Não há fisioterapeutas arquivados"),
        "practitionerList_noPractitioner": MessageLookupByLibrary.simpleMessage(
            "Não há fisioterapeutas registados"),
        "practitionerList_professionalId": m27,
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
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("Perfil profissional da ABAK"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Digitalize este código QR a partir da aplicação ABAK Mobile para adicionar automaticamente este perfil profissional."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("arquivado"),
        "practitionerSelector_error": m28,
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
        "refreshDashboard": MessageLookupByLibrary.simpleMessage(
            "Atualizar o painel de controlo"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Arquivo de relatórios"),
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
        "settings_databaseResetError": m29,
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
        "speechDictationButton_failure": m30,
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
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage("Selecione um beneficiário"),
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
                "Utilizar para criar um doente")
      };
}
