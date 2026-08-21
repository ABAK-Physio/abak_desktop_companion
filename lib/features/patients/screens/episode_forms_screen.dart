import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';

import '../data/contact_form_template_repository.dart';
import '../data/episode_form_repository.dart';
import '../models/contact_form_template.dart';
import '../models/episode_form.dart';
import 'episode_form_editor_screen.dart';
import '../../../core/utils/date_format_utils.dart';

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
      completionByFormId[form.formId] = await _formRepository.isFormComplete(
        form.formId,
      );
    }

    return _EpisodeFormsData(
      forms: forms,
      templates: templates,
      templatesById: {
        for (final template in templates) template.templateId: template,
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

  Widget _buildTemplateTile(ContactFormTemplate template,
      S s,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.playlist_add_outlined),
      title: Text(template.name),
      subtitle: Text(
        [
          if (template.category != null)
            '${s.episodeForms_category} : ${template.category}',
          template.isDefault
              ? s.episodeForms_systemTemplate
              : s.episodeForms_customTemplate,
        ].join(' · '),
      ),
      trailing: OutlinedButton.icon(
        onPressed: () => _createForm(template),
        icon: const Icon(Icons.add),
        label: Text(s.episodeForms_create),
      ),
    );
  }

  Widget _buildFormTile(
      EpisodeForm form,
      ContactFormTemplate? template,
      bool completed,
      S s,
      ) {
    final formattedDate = DateFormatUtils.formatTimestamp(
      context,
      form.createdAt,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.assignment_outlined),
      title: Text(
        '${s.episodeForms_title} — ${widget.caseLabel}',
      ),
      subtitle: Text(
        [
          if (template?.category != null)
            '${s.episodeForms_category} : ${template!.category}',
          '${s.episodeForms_createdOn} : $formattedDate',
          '${s.episodeForms_state} : '
              '${completed
              ? s.episodeForms_completed
              : s.episodeForms_inProgress}',
        ].join('\n'),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => EpisodeFormEditorScreen(formId: form.formId),
          ),
        );

        if (changed == true) {
          await _refresh();
        }
      },
    );
  }

  Widget _buildContent(_EpisodeFormsData data,
      S s,
      ) {
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
                  s.episodeForms_createdForms,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 28),
                if (data.forms.isEmpty)
                  Text(
                    s.episodeForms_noCreatedForm,
                  )
                else
                  ...data.forms.map(
                        (form) => _buildFormTile(
                      form,
                      data.templatesById[form.templateId],
                      data.completionByFormId[form.formId] ?? false,
                      s,
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
                  s.episodeForms_availableTemplates,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 28),
                if (data.templates.isEmpty)
                  Text(
                    s.episodeForms_noAvailableTemplate,
                  )
                else
                  ...data.templates.map(
                        (template) => _buildTemplateTile(template, s),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${s.episodeForms_title} — ${widget.caseLabel}',
        ),
        actions: [
          IconButton(
            tooltip: s.episodeForms_refresh,
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
                  '${s.episodeForms_error} : ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data;

          if (data == null) {
            return Center(
              child: Text(s.episodeForms_noData),
            );
          }

          return _buildContent(data, s);
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
