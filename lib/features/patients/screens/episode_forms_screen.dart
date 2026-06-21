import 'package:flutter/material.dart';

import '../data/contact_form_template_repository.dart';
import '../data/episode_form_repository.dart';
import '../models/contact_form_template.dart';
import '../models/episode_form.dart';
import 'episode_form_editor_screen.dart';

class EpisodeFormsScreen extends StatefulWidget {
  final String caseId;
  final String caseLabel;

  const EpisodeFormsScreen({
    super.key,
    required this.caseId,
    required this.caseLabel,
  });

  @override
  State<EpisodeFormsScreen> createState() => _EpisodeFormsScreenState();
}

class _EpisodeFormsScreenState extends State<EpisodeFormsScreen> {
  final EpisodeFormRepository _formRepository = EpisodeFormRepository();
  final ContactFormTemplateRepository _templateRepository =
  ContactFormTemplateRepository();

  late Future<_EpisodeFormsData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<_EpisodeFormsData> _loadData() async {
    final forms = await _formRepository.getFormsByCaseId(widget.caseId);
    final templates = await _templateRepository.getActiveTemplates();

    final completionByFormId = <String, bool>{};

    for (final form in forms) {
      completionByFormId[form.formId] =
      await _formRepository.isFormComplete(
        form.formId,
      );
    }

    return _EpisodeFormsData(
      forms: forms,
      templates: templates,
      templatesById: {
        for (final template in templates)
          template.templateId: template,
      },
      completionByFormId: completionByFormId,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _futureData = _loadData();
    });
  }

  Future<void> _createForm(ContactFormTemplate template) async {
    await _formRepository.createForm(
      caseId: widget.caseId,
      templateId: template.templateId,
    );

    await _refresh();
  }

  Widget _buildTemplateTile(ContactFormTemplate template) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.playlist_add_outlined),
      title: Text(template.name),
      subtitle: Text(
        [
          if (template.category != null) 'Catégorie : ${template.category}',
          template.isDefault ? 'Modèle système' : 'Modèle personnalisé',
        ].join(' · '),
      ),
      trailing: OutlinedButton.icon(
        onPressed: () => _createForm(template),
        icon: const Icon(Icons.add),
        label: const Text('Créer'),
      ),
    );
  }

  Widget _buildFormTile(
      EpisodeForm form,
      ContactFormTemplate? template,
      bool completed,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.assignment_outlined),
      title: Text(
        template?.name ?? 'Formulaire',
      ),
      subtitle: Text(
        [
          if (template?.category != null)
            'Catégorie : ${template!.category}',
          'Créé le : ${DateTime.fromMillisecondsSinceEpoch(form.createdAt).toLocal()}',
          'État : ${completed ? 'complété' : 'en cours'}',
        ].join('\n'),
      ),
      trailing: const Icon(Icons.chevron_right),onTap: () async {
      final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => EpisodeFormEditorScreen(
            formId: form.formId,
          ),
        ),
      );

      if (changed == true) {
        await _refresh();
      }
    },
    );
  }

  Widget _buildContent(_EpisodeFormsData data) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formulaires créés',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 28),
                if (data.forms.isEmpty)
                  const Text(
                    'Aucun formulaire créé pour cet épisode.',
                  )
                else
                  ...data.forms.map(
                        (form) => _buildFormTile(
                      form,
                      data.templatesById[form.templateId],
                      data.completionByFormId[form.formId] ?? false,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modèles disponibles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 28),
                if (data.templates.isEmpty)
                  const Text(
                    'Aucun modèle de formulaire disponible.',
                  )
                else
                  ...data.templates.map(_buildTemplateTile),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaires — ${widget.caseLabel}'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<_EpisodeFormsData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erreur : ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data;

          if (data == null) {
            return const Center(
              child: Text('Aucune donnée à afficher.'),
            );
          }

          return _buildContent(data);
        },
      ),
    );
  }
}

class _EpisodeFormsData {
  final List<EpisodeForm> forms;
  final List<ContactFormTemplate> templates;
  final Map<String, ContactFormTemplate> templatesById;
  final Map<String, bool> completionByFormId;

  const _EpisodeFormsData({
    required this.forms,
    required this.templates,
    required this.templatesById,
    required this.completionByFormId,
  });
}