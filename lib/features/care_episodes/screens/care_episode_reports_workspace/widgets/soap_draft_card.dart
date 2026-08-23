import 'package:flutter/material.dart';
import '../../../../../generated/l10n.dart';
import 'package:abak_desktop_companion/core/speech/speech_dictation_button.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/clinical_document_type.dart';
import 'package:abak_shared/abak_shared.dart';

class SoapDraftCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool loading;
  final String? loadError;
  final bool draftReady;
  final bool isEditing;
  final ClinicalDocumentType documentType;
  final VoidCallback onExpand;
  final Future<void> Function(ClinicalDocumentType documentType)
      onDocumentTypeChanged;
  final String? documentTitle;
  final bool documentTypeSelected;
  final VoidCallback? onOpenTemplateGuide;

  const SoapDraftCard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.loading,
    required this.loadError,
    required this.draftReady,
    required this.isEditing,
    required this.documentType,
    required this.onExpand,
    required this.onDocumentTypeChanged,
    required this.documentTitle,
    required this.documentTypeSelected,
    required this.onOpenTemplateGuide,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<ClinicalDocumentType>(
                segments: [
                  ButtonSegment<ClinicalDocumentType>(
                    value: ClinicalDocumentType.assessment,
                    label: const Text('Bilan'),
                    icon: const Icon(Icons.assignment_outlined),
                  ),
                  ButtonSegment<ClinicalDocumentType>(
                    value: ClinicalDocumentType.report,
                    label: const Text('Rapport'),
                    icon: const Icon(Icons.description_outlined),
                  ),
                ],
                selected: documentTypeSelected
                    ? <ClinicalDocumentType>{documentType}
                    : <ClinicalDocumentType>{},
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                onSelectionChanged: (selection) async {
                  if (selection.isEmpty) {
                    return;
                  }

                  final selectedType = selection.first;

                  if (documentTypeSelected && selectedType == documentType) {
                    return;
                  }

                  await onDocumentTypeChanged(selectedType);
                },
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        !documentTypeSelected
                            ? 'Choisissez Bilan ou Rapport pour commencer'
                            : isEditing
                            ? documentType.editorTitle
                            : documentType == ClinicalDocumentType.assessment
                            ? 'Brouillon du bilan'
                            : 'Brouillon du rapport',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (documentTypeSelected) ...[
                        const SizedBox(width: 24),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isEditing
                                      ? documentType ==
                                      ClinicalDocumentType.assessment
                                      ? 'Bilan en cours de modification : ${documentTitle ?? ''}'
                                      : 'Rapport en cours de modification : ${documentTitle ?? ''}'
                                      : documentType ==
                                      ClinicalDocumentType.assessment
                                      ? 'Vous créez un nouveau bilan'
                                      : 'Vous créez un nouveau rapport',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              if (!isEditing)
                                ContextHelpButton(
                                  title: documentType ==
                                      ClinicalDocumentType.assessment
                                      ? 'Comprendre le brouillon du bilan'
                                      : 'Comprendre le brouillon du rapport',
                                  content: documentType ==
                                      ClinicalDocumentType.assessment
                                      ? 'Le texte affiché correspond à un travail en cours sauvegardé automatiquement. Vous pouvez le conserver, le modifier ou le supprimer avant d’enregistrer votre bilan.'
                                      : 'Le texte affiché correspond à un travail en cours sauvegardé automatiquement. Vous pouvez le conserver, le modifier ou le supprimer avant d’enregistrer votre rapport.',
                                  technicalInformationLabel: 'Comprendre l’écran',
                                  iconSize: 20,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SpeechDictationButton(
                  controller: controller,
                  focusNode: focusNode,
                ),
                IconButton(
                  onPressed: draftReady ? onExpand : null,
                  tooltip: s.careEpisodeReportsWorkspace_expandEditor,
                  icon: const Icon(Icons.zoom_out_map),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 240,
                  child: OutlinedButton.icon(
                    onPressed:
                    documentType == ClinicalDocumentType.assessment &&
                        draftReady
                        ? onOpenTemplateGuide
                        : null,
                    icon: const Icon(Icons.description_outlined),
                    label: Text(documentType.templateLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : loadError != null
                  ? Center(
                child: Text(loadError!),
              )
                  : TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: draftReady,
                decoration: InputDecoration(
                  hintText: s.careEpisodeReportsWorkspace_soapEditorHint,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                expands: true,
                minLines: null,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}