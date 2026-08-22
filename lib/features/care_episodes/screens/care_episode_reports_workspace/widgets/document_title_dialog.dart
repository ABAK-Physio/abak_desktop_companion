import 'package:flutter/material.dart';
import '../../../../../generated/l10n.dart';

class DocumentTitleDialog extends StatefulWidget {
  final String dialogTitle;
  final String fieldLabel;
  final String actionLabel;
  final String initialTitle;

  const DocumentTitleDialog({
    super.key,
    required this.dialogTitle,
    required this.fieldLabel,
    required this.actionLabel,
    required this.initialTitle,
  });

  @override
  State<DocumentTitleDialog> createState() =>
      _DocumentTitleDialogState();
}

class _DocumentTitleDialogState extends State<DocumentTitleDialog> {
  late final TextEditingController _controller;

  bool get _canSave => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.initialTitle,
    );
  }

  void _submit() {
    if (!_canSave) {
      return;
    }

    Navigator.of(context).pop(
      _controller.text.trim(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SizedBox(
        width: 480,
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: widget.fieldLabel,
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            setState(() {});
          },
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            s.careEpisodeReportsWorkspace_cancel,
          ),
        ),
        FilledButton(
          onPressed: _canSave ? _submit : null,
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}