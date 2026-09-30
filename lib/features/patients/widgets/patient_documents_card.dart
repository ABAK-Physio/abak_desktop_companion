import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/settings/generated_documents_directory_service.dart';
import '../../../core/settings/macos_directory_access_service.dart';
import '../../../generated/l10n.dart';
import '../services/patient_documents_service.dart';

class PatientDocumentsCard extends StatefulWidget {
  const PatientDocumentsCard({super.key, required this.patientId});
  final String patientId;

  @override
  State<PatientDocumentsCard> createState() => _PatientDocumentsCardState();
}

class _PatientDocumentsCardState extends State<PatientDocumentsCard> {
  PatientDocumentFolders? _folders;
  bool _busy = true;
  bool _failed = false;
  bool _authorizationRequired = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant PatientDocumentsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) _prepare();
  }

  Future<void> _prepare({bool choose = false, bool open = false}) async {
    final patientId = widget.patientId;
    setState(() => _busy = true);
    try {
      const directories = GeneratedDocumentsDirectoryService();
      if (choose && await directories.chooseAndSave() == null) return;
      final access = await directories.acquireConfigured();
      PatientDocumentFolders? folders;
      try {
        if (access != null) {
          folders = await const PatientDocumentsService().ensureInRoot(
            patientId: patientId,
            rootPath: access.path,
          );
          if (open && !await launchUrl(Uri.directory(folders.path))) {
            throw StateError('Impossible d’ouvrir le dossier');
          }
        }
      } finally {
        await access?.release();
      }
      if (!mounted || patientId != widget.patientId) return;
      setState(() {
        _folders = folders;
        _failed = false;
        _authorizationRequired = false;
      });
    } catch (error) {
      if (!mounted || patientId != widget.patientId) return;
      setState(() {
        _failed = true;
        _authorizationRequired = error is DirectoryAuthorizationRequired;
      });
    } finally {
      if (mounted && patientId == widget.patientId) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.patientDocuments_title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_busy)
              const LinearProgressIndicator()
            else ...[
              if (_failed)
                Text(
                  _authorizationRequired
                      ? s.patientDocuments_authorization
                      : s.patientDocuments_error,
                )
              else if (_folders == null)
                Text(s.patientDocuments_unconfigured)
              else ...[
                SelectableText(_folders!.path),
                const SizedBox(height: 8),
                Text(s.patientDocuments_structure),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (_failed && !_authorizationRequired)
                    OutlinedButton(
                      onPressed: () => _prepare(),
                      child: Text(s.patientDocuments_retry),
                    ),
                  if (_authorizationRequired || (!_failed && _folders == null))
                    OutlinedButton.icon(
                      onPressed: () => _prepare(choose: true),
                      icon: const Icon(Icons.folder_open),
                      label: Text(s.patientDocuments_chooseRoot),
                    ),
                  if (!_failed && _folders != null)
                    OutlinedButton.icon(
                      onPressed: () => _prepare(open: true),
                      icon: const Icon(Icons.folder_open),
                      label: Text(s.patientDocuments_open),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
