import 'package:flutter/material.dart';
import '../practitioners/data/practitioner_repository.dart';
import '../practitioners/models/practitioner.dart';
import '../practitioners/widgets/practitioner_form_dialog.dart';
import 'companion_access_service.dart';
import 'companion_session.dart';

class PatientReferrerPicker extends StatefulWidget {
  const PatientReferrerPicker({
    super.key,
    required this.onChanged,
    this.initialId,
    this.enabled = true,
  });
  final ValueChanged<String?> onChanged;
  final String? initialId;
  final bool enabled;
  @override
  State<PatientReferrerPicker> createState() => _PatientReferrerPickerState();
}

class _PatientReferrerPickerState extends State<PatientReferrerPicker> {
  List<AccessPractitioner>? people;
  String? selected, error;
  @override
  void initState() {
    super.initState();
    selected = widget.initialId;
    load();
  }

  Future<void> load({String? created}) async {
    try {
      final values = await CompanionAccessService().practitioners();
      if (!mounted) return;
      final suggested =
          created ?? selected ?? CompanionSession.current.practitionerId;
      setState(() {
        people = values;
        error = null;
        selected = values.any((p) => p.id == suggested)
            ? suggested
            : values.length == 1
            ? values.single.id
            : null;
      });
      widget.onChanged(selected);
    } catch (_) {
      if (mounted) setState(() => error = 'Impossible de charger les kinés.');
    }
  }

  Future<void> create() async {
    final practitioner = await showDialog<Practitioner>(
      context: context,
      builder: (_) => const PractitionerFormDialog(),
    );
    if (practitioner == null || !mounted) return;
    try {
      await PractitionerRepository().insertPractitioner(practitioner);
      await load(created: practitioner.practitionerId);
    } catch (_) {
      if (mounted) setState(() => error = 'Impossible d’enregistrer le kiné.');
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (error != null) ...[
        Text(error!),
        TextButton(onPressed: () => load(), child: const Text('Réessayer')),
      ],
      if (people == null && error == null) const LinearProgressIndicator(),
      if (people != null)
        DropdownButtonFormField<String>(
          key: ValueKey((selected, people!.length)),
          initialValue: selected,
          decoration: const InputDecoration(labelText: 'Kiné référent'),
          isExpanded: true,
          items: people!
              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
              .toList(),
          validator: (value) =>
              value == null ? 'Sélectionnez un kiné référent.' : null,
          onChanged: widget.enabled
              ? (value) {
                  setState(() => selected = value);
                  widget.onChanged(value);
                }
              : null,
        ),
      TextButton.icon(
        onPressed: widget.enabled ? create : null,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Créer un kiné'),
      ),
    ],
  );
}

Future<String?> choosePatientReferrer(BuildContext context) {
  String? selected;
  final form = GlobalKey<FormState>();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Kiné référent'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: PatientReferrerPicker(onChanged: (id) => selected = id),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (form.currentState!.validate() && selected != null) {
              Navigator.pop(context, selected);
            }
          },
          child: const Text('Valider'),
        ),
      ],
    ),
  );
}
