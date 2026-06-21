import 'package:uuid/uuid.dart';

import '../data/contact_form_template_repository.dart';
import '../models/contact_form_field.dart';
import '../models/contact_form_template.dart';

class DefaultContactFormTemplateService {
  DefaultContactFormTemplateService({
    ContactFormTemplateRepository? repository,
  }) : _repository = repository ?? ContactFormTemplateRepository();

  final ContactFormTemplateRepository _repository;
  final Uuid _uuid = const Uuid();

  static const String defaultTemplateId = 'default_initial_contact';

  Future<void> ensureDefaultTemplateExists() async {
    final existing = await _repository.getById(defaultTemplateId);

    if (existing != null) {
      await _repository.upsertTemplate(
        ContactFormTemplate(
          templateId: existing.templateId,
          practitionerId: existing.practitionerId,
          name: existing.name,
          description: existing.description,
          category: existing.category ?? 'general',
          isDefault: true,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          archivedAt: existing.archivedAt,
        ),
      );

      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final template = ContactFormTemplate(
      templateId: defaultTemplateId,
      practitionerId: null,
      name: 'Entretien initial',
      description: 'Fiche standard de premier contact patient',
      category: 'general',
      isDefault: true,
      createdAt: now,
    );

    await _repository.upsertTemplate(template);

    final fields = <ContactFormField>[
      _field(
        now: now,
        label: 'Numéro national de santé',
        fieldType: 'text',
        targetScope: 'identity',
        sortOrder: 10,
      ),
      _field(
        now: now,
        label: 'Côté dominant',
        fieldType: 'single_choice',
        targetScope: 'patient',
        sortOrder: 20,
        optionsJson: '["droite","gauche","ambidextre","non précisé"]',
      ),
      _field(
        now: now,
        label: 'Profession',
        fieldType: 'text',
        targetScope: 'patient',
        sortOrder: 30,
      ),
      _field(
        now: now,
        label: 'Activité sportive habituelle',
        fieldType: 'text',
        targetScope: 'patient',
        sortOrder: 40,
      ),
      _field(
        now: now,
        label: 'Motif de consultation',
        fieldType: 'multiline_text',
        targetScope: 'episode',
        sortOrder: 50,
        required: true,
      ),
      _field(
        now: now,
        label: 'Date de début des symptômes',
        fieldType: 'date',
        targetScope: 'episode',
        sortOrder: 60,
      ),
      _field(
        now: now,
        label: 'Côté atteint',
        fieldType: 'single_choice',
        targetScope: 'episode',
        sortOrder: 70,
        optionsJson: '["droit","gauche","bilatéral","non concerné"]',
      ),
      _field(
        now: now,
        label: 'Objectifs du patient',
        fieldType: 'multiline_text',
        targetScope: 'episode',
        sortOrder: 80,
      ),
      _field(
        now: now,
        label: 'Documents utiles à demander',
        fieldType: 'multiline_text',
        targetScope: 'episode',
        sortOrder: 90,
      ),
    ];

    for (final field in fields) {
      await _repository.upsertField(field);
    }
  }

  ContactFormField _field({
    required int now,
    required String label,
    required String fieldType,
    required String targetScope,
    required int sortOrder,
    bool required = false,
    String? optionsJson,
  }) {
    return ContactFormField(
      fieldId: _uuid.v4(),
      templateId: defaultTemplateId,
      label: label,
      fieldType: fieldType,
      targetScope: targetScope,
      sortOrder: sortOrder,
      required: required,
      optionsJson: optionsJson,
      createdAt: now,
    );
  }
}