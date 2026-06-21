import 'package:flutter/material.dart';

import '../data/contact_form_template_repository.dart';
import '../models/contact_form_field.dart';
import '../models/contact_form_template.dart';
import '../services/default_contact_form_template_service.dart';

class ContactFormTemplateDiagnosticScreen extends StatefulWidget {
  const ContactFormTemplateDiagnosticScreen({super.key});

  @override
  State<ContactFormTemplateDiagnosticScreen> createState() =>
      _ContactFormTemplateDiagnosticScreenState();
}

class _ContactFormTemplateDiagnosticScreenState
    extends State<ContactFormTemplateDiagnosticScreen> {
  final ContactFormTemplateRepository _repository =
  ContactFormTemplateRepository();

  late Future<_TemplateDiagnosticData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<_TemplateDiagnosticData> _loadData() async {
    final template = await _repository.getById(
      DefaultContactFormTemplateService.defaultTemplateId,
    );

    final fields = template == null
        ? <ContactFormField>[]
        : await _repository.getFields(template.templateId);

    return _TemplateDiagnosticData(
      template: template,
      fields: fields,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _futureData = _loadData();
    });
  }

  Color _scopeColor(String scope) {
    switch (scope) {
      case 'identity':
        return Colors.blue;
      case 'patient':
        return Colors.green;
      case 'episode':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildScopeChip(String scope) {
    final color = _scopeColor(scope);

    return Chip(
      label: Text(scope),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(
        color: color.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text('$label : $value'),
    );
  }

  Widget _buildTemplateCard(ContactFormTemplate template) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodyMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (template.description != null &&
                  template.description!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(template.description!),
                ),
              const Divider(height: 24),
              _buildInfoLine('ID modèle', template.templateId),
              _buildInfoLine(
                'Praticien',
                template.practitionerId ?? 'Modèle système',
              ),
              _buildInfoLine(
                'Catégorie',
                template.category ?? 'Non définie',
              ),
              _buildInfoLine(
                'Modèle par défaut',
                template.isDefault ? 'Oui' : 'Non',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTile(ContactFormField field) {
    return Card(
      child: ListTile(
        title: Text(field.label),
        subtitle: Text(
          'Type : ${field.fieldType} • Ordre : ${field.sortOrder}'
              '${field.required ? ' • Obligatoire' : ''}',
        ),
        trailing: _buildScopeChip(field.targetScope),
      ),
    );
  }

  Widget _buildContent(_TemplateDiagnosticData data) {
    final template = data.template;

    if (template == null) {
      return const Center(
        child: Text(
          'Aucun modèle de fiche d’entretien initial trouvé.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTemplateCard(template),
        const SizedBox(height: 16),
        Text(
          'Champs (${data.fields.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final field in data.fields) _buildFieldTile(field),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic fiche d’entretien'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<_TemplateDiagnosticData>(
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

class _TemplateDiagnosticData {
  final ContactFormTemplate? template;
  final List<ContactFormField> fields;

  const _TemplateDiagnosticData({
    required this.template,
    required this.fields,
  });
}