import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/episode_report_text_document.dart';
import '../services/episode_report_text_export_service.dart';

class EpisodeReportPreviewCard extends StatelessWidget {
  final EpisodeReportTextDocument document;

  const EpisodeReportPreviewCard({
    super.key,
    required this.document,
  });

  Future<void> _exportTextFile(BuildContext context) async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    final exportService = const EpisodeReportTextExportService();

    final file = await exportService.exportToTextFile(
      document: document,
      directory: Directory(selectedDirectory),
      fileName: document.title,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rapport exporté : ${file.path}'),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text: document.toPlainText(),
      ),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapport copié dans le presse-papiers.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = document.toPlainText();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copier le texte'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _exportTextFile(context),
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Exporter en texte'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SelectableText(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}