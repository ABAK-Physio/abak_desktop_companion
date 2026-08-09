import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../generated/l10n.dart';
import 'expert_context_info.dart';

class ExpertInfoDialog extends StatelessWidget {
  final ExpertContextInfo info;

  const ExpertInfoDialog({
    super.key,
    required this.info,
  });

  Future<void> _copyInfo(BuildContext context) async {
    final s = S.of(context);

    final buffer = StringBuffer()
      ..writeln('${s.g_context} : ${info.contextName}')
      ..writeln('${s.g_file} : ${info.sourceFile}');

    final arbPrefix = info.arbPrefix?.trim();
    if (arbPrefix != null && arbPrefix.isNotEmpty) {
      buffer.writeln('${s.g_arb_prefix} : $arbPrefix');
    }

    final comment = info.comment?.trim();
    if (comment != null && comment.isNotEmpty) {
      buffer.writeln('${s.g_comment} : $comment');
    }

    await Clipboard.setData(
      ClipboardData(text: buffer.toString().trim()),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.g_technical_informations_copied),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final arbPrefix = info.arbPrefix?.trim();
    final comment = info.comment?.trim();

    return AlertDialog(
      title: Text(s.g_technical_informations),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.g_context,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SelectableText(info.contextName),
            const SizedBox(height: 16),
            Text(
              s.g_file,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SelectableText(info.sourceFile),
            if (arbPrefix != null && arbPrefix.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                s.g_arb_prefix,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(arbPrefix),
            ],
            if (comment != null && comment.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                s.g_comment,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
          label: Text(s.g_copy),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.g_close),
        ),
      ],
    );
  }
}