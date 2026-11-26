import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import 'generated_documents_directory_service.dart';

Future<void> showInitialDocumentsSetup(
  BuildContext context, {
  GeneratedDocumentsDirectoryService service =
      const GeneratedDocumentsDirectoryService(),
}) async {
  try {
    if (!await service.needsInitialConfiguration() || !context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DocumentsSetupDialog(service: service),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(S.of(context).documentsSetup_error)),
    );
  }
}

class DocumentsSetupDialog extends StatefulWidget {
  const DocumentsSetupDialog({
    super.key,
    this.service = const GeneratedDocumentsDirectoryService(),
  });
  final GeneratedDocumentsDirectoryService service;
  @override
  State<DocumentsSetupDialog> createState() => _DocumentsSetupDialogState();
}

class _DocumentsSetupDialogState extends State<DocumentsSetupDialog> {
  String? _path;
  bool _busy = false, _error = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final path = await widget.service.recommendedPath();
      if (mounted) setState(() => _path = path);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  Future<void> _choose(bool recommended) async {
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      final path = recommended
          ? await widget.service.useRecommended()
          : await widget.service.chooseAndSave();
      if (mounted && path != null) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(s.documentsSetup_title),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.documentsSetup_message),
                const SizedBox(height: 16),
                Text(
                  s.documentsSetup_recommended,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_path != null) SelectableText(_path!),
                const SizedBox(height: 16),
                Text(s.documentsSetup_laterInfo),
                if (_error)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      s.documentsSetup_error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(s.documentsSetup_later),
          ),
          OutlinedButton(
            onPressed: _busy ? null : () => _choose(false),
            child: Text(s.documentsSetup_choose),
          ),
          FilledButton(
            onPressed: _busy || _path == null ? null : () => _choose(true),
            child: Text(s.documentsSetup_use),
          ),
        ],
      ),
    );
  }
}
