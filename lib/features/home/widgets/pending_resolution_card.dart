import 'dart:async';

import 'package:flutter/material.dart';

import '../../import_export/abak_import_launcher.dart';
import '../../import_export/data/import_session_repository.dart';

class PendingResolutionCard extends StatefulWidget {
  const PendingResolutionCard({super.key});

  @override
  State<PendingResolutionCard> createState() =>
      _PendingResolutionCardState();
}

class _PendingResolutionCardState extends State<PendingResolutionCard> {
  final repository = ImportSessionRepository();

  List<Map<String, dynamic>> _files = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _refresh();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => _refresh(),
    );
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    final newFiles = await repository.getFilesNeedingResolution();

    if (_filesSignature(_files) == _filesSignature(newFiles)) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _files = newFiles;
    });
  }

  String _filesSignature(List<Map<String, dynamic>> files) {
    final paths = files
        .map((file) => file['file_path']?.toString() ?? '')
        .where((path) => path.isNotEmpty)
        .toList()
      ..sort();

    return paths.join('|');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final files = _files;

    return Card(
      child: ExpansionTile(
        key: const PageStorageKey<String>(
          'pending_resolution_card',
        ),
        maintainState: true,
        initiallyExpanded: files.isNotEmpty,
        leading: Icon(
          files.isNotEmpty
              ? Icons.account_tree_outlined
              : Icons.check_circle_outline,
          color: files.isNotEmpty ? Colors.orange : Colors.green,
        ),
        title: Text(
          'Imports à rattacher',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          files.isEmpty
              ? 'Aucun fichier en attente'
              : '${files.length} fichier(s) nécessitent un choix patient',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20,
        ),
        children: [
          if (files.isEmpty)
            const Text(
              'Aucun rattachement manuel requis.',
            )
          else
            ...files.map((file) {
              final fileName =
                  file['file_name']?.toString() ??
                      'Fichier inconnu';

              final filePath =
                  file['file_path']?.toString() ??
                      file['error_message']?.toString() ??
                      '';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.insert_drive_file_outlined,
                ),
                title: Text(fileName),
                subtitle: filePath.isEmpty
                    ? null
                    : Text(filePath),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () async {
                  final selectedFilePath =
                      file['file_path']?.toString() ??
                          file['error_message']?.toString();

                  debugPrint(
                    '📦 import à rattacher sélectionné',
                  );
                  debugPrint('📦 file row = $file');
                  debugPrint(
                    '📦 filePath = $selectedFilePath',
                  );

                  if (selectedFilePath == null ||
                      selectedFilePath.isEmpty ||
                      !selectedFilePath
                          .toLowerCase()
                          .endsWith('.abak')) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Chemin du fichier invalide : '
                              '${selectedFilePath ?? "absent"}',
                        ),
                      ),
                    );
                    return;
                  }

                  await AbakImportLauncher
                      .importArchiveFromPathWithResolution(
                    context,
                    selectedFilePath,
                  );

                  await _refresh();
                },
              );
            }),
        ],
      ),
    );
  }
}