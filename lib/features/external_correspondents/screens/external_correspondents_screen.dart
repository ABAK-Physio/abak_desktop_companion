import 'package:flutter/material.dart';

import '../data/external_correspondent_repository.dart';
import '../models/external_correspondent.dart';
import '../widgets/external_correspondent_dialog.dart';

class ExternalCorrespondentsScreen extends StatefulWidget {
  const ExternalCorrespondentsScreen({super.key});

  @override
  State<ExternalCorrespondentsScreen> createState() =>
      _ExternalCorrespondentsScreenState();
}

class _ExternalCorrespondentsScreenState
    extends State<ExternalCorrespondentsScreen> {
  final ExternalCorrespondentRepository _repository =
  ExternalCorrespondentRepository();

  late Future<List<ExternalCorrespondent>> _correspondentsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _correspondentsFuture = _repository.getActiveCorrespondents();
  }

  Future<void> _addCorrespondent() async {
    final correspondent = await showDialog<ExternalCorrespondent>(
      context: context,
      builder: (context) {
        return const ExternalCorrespondentDialog();
      },
    );

    if (correspondent == null) {
      return;
    }

    await _repository.insert(correspondent);

    if (!mounted) return;

    setState(() {
      _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Correspondants externes'),
      ),
      body: FutureBuilder<List<ExternalCorrespondent>>(
        future: _correspondentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final correspondents =
              snapshot.data ?? const <ExternalCorrespondent>[];

          if (correspondents.isEmpty) {
            return const Center(
              child: Text(
                'Aucun correspondant externe enregistré.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: correspondents.length,
            separatorBuilder: (context, index) =>
            const Divider(height: 1),
            itemBuilder: (context, index) {
              final correspondent = correspondents[index];

              final details = <String>[
                if (correspondent.profession?.trim().isNotEmpty == true)
                  correspondent.profession!.trim(),
                if (correspondent.specialty?.trim().isNotEmpty == true)
                  correspondent.specialty!.trim(),
                if (correspondent.city?.trim().isNotEmpty == true)
                  correspondent.city!.trim(),
              ];

              return ListTile(
                leading: const Icon(Icons.contact_page_outlined),
                title: Text(correspondent.displayName),
                subtitle: details.isEmpty
                    ? null
                    : Text(details.join(' — ')),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCorrespondent,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}