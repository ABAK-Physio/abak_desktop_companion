import 'package:flutter/material.dart';

import 'package:abak_desktop_companion/core/speech/speech_dictation_button.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/clinical_document_type.dart';

class SoapDraftCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool loading;
  final String? loadError;
  final bool draftReady;
  final bool isEditing;
  final ClinicalDocumentType documentType;
  final VoidCallback onExpand;

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
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing
                        ? documentType.editorTitle
                        : documentType == ClinicalDocumentType.assessment
                        ? 'Bilan (nouveau)'
                        : documentType.editorTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SpeechDictationButton(
                  controller: controller,
                  focusNode: focusNode,
                ),
                IconButton(
                  onPressed: draftReady ? onExpand : null,
                  tooltip: 'Agrandir la zone de rédaction',
                  icon: const Icon(Icons.zoom_out_map),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    initialValue: null,
                    decoration: InputDecoration(
                      labelText: documentType.templateLabel,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [],
                    onChanged: null,
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
                decoration: const InputDecoration(
                  hintText:
                  'Zone de rédaction du bilan SOAP.\n\n'
                      'S — Subjectif\n\n'
                      'O — Objectif\n\n'
                      'A — Analyse\n\n'
                      'P — Plan',
                  border: OutlineInputBorder(),
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