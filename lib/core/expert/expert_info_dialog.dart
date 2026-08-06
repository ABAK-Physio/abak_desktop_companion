import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'expert_context_info.dart';

class ExpertInfoDialog extends StatelessWidget {
  final ExpertContextInfo info;

  const ExpertInfoDialog({
    super.key,
    required this.info,
  });

  Future<void> _copyInfo(BuildContext context) async {
    final buffer = StringBuffer()
      ..writeln('Contexte : ${info.contextName}')
      ..writeln('Fichier : ${info.sourceFile}');

    final arbPrefix = info.arbPrefix?.trim();
    if (arbPrefix != null && arbPrefix.isNotEmpty) {
      buffer.writeln('Préfixe ARB : $arbPrefix');
    }

    final comment = info.comment?.trim();
    if (comment != null && comment.isNotEmpty) {
      buffer.writeln('Commentaire : $comment');
    }

    await Clipboard.setData(
      ClipboardData(text: buffer.toString().trim()),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informations techniques copiées.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arbPrefix = info.arbPrefix?.trim();
    final comment = info.comment?.trim();

    return AlertDialog(
      title: const Text('Informations techniques'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contexte',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SelectableText(info.contextName),
            const SizedBox(height: 16),
            const Text(
              'Fichier',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SelectableText(info.sourceFile),
            if (arbPrefix != null && arbPrefix.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Préfixe ARB',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(arbPrefix),
            ],
            if (comment != null && comment.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Commentaire',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(comment),
            ],
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _copyInfo(context),
          icon: const Icon(Icons.copy_outlined),
          label: const Text('Copier'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}