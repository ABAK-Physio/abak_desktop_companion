import 'package:flutter/material.dart';
import 'dart:async';

import '../../import_export/data/import_session_repository.dart';
import '../../import_export/abak_import_launcher.dart';

class PendingResolutionCard extends StatefulWidget {
  const PendingResolutionCard({super.key});

  @override
  State<PendingResolutionCard> createState() =>
      _PendingResolutionCardState();
}

class _PendingResolutionCardState extends State<PendingResolutionCard> {
  final repository = ImportSessionRepository();

  late Future<List<Map<String, dynamic>>> _futureFiles;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refresh();

    _timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => _refresh(),
    );
  }

  void _refresh() {
    if (!mounted) return;

    setState(() {
      _futureFiles = repository.getFilesNeedingResolution();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Card(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureFiles,
        builder: (context, snapshot) {
          final files = snapshot.data ?? [];

          return ExpansionTile(
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
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else if (files.isEmpty)
                const Text('Aucun rattachement manuel requis.')
              else
                ...files.map((file) {
                  final fileName =
                      file['file_name']?.toString() ?? 'Fichier inconnu';

                  final filePath =
                      file['file_path']?.toString() ??
                          file['error_message']?.toString() ??
                          '';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.insert_drive_file_outlined),
                    title: Text(fileName),
                    subtitle: filePath.isEmpty ? null : Text(filePath),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final filePath =
                          file['file_path']?.toString() ??
                              file['error_message']?.toString();

                      debugPrint('📦 import à rattacher sélectionné');
                      debugPrint('📦 file row = $file');
                      debugPrint('📦 filePath = $filePath');

                      if (filePath == null ||
                          filePath.isEmpty ||
                          !filePath.toLowerCase().endsWith('.abak')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Chemin du fichier invalide : ${filePath ?? "absent"}',
                            ),
                          ),
                        );
                        return;
                      }

                      await AbakImportLauncher.importArchiveFromPathWithResolution(
                        context,
                        filePath,
                      );

                      _refresh();
                    },
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}