import 'package:flutter/material.dart';
import '../../practitioners/models/practitioner.dart';

class PlanningPractitionerSelector extends StatefulWidget {
  const PlanningPractitionerSelector({
    super.key,
    required this.load,
    required this.onChanged,
    this.selectedId,
  });
  final String? selectedId;
  final Future<List<Practitioner>> Function() load;
  final ValueChanged<Practitioner?> onChanged;

  @override
  State<PlanningPractitionerSelector> createState() =>
      _PlanningPractitionerSelectorState();
}

class _PlanningPractitionerSelectorState
    extends State<PlanningPractitionerSelector> {
  List<Practitioner> _items = [];
  String? _selected;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedId;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final items = await widget.load();
      if (!mounted) return;
      final selected = items
          .where((p) => p.practitionerId == _selected)
          .firstOrNull;
      final next = selected ?? (items.length == 1 ? items.single : null);
      setState(() {
        _items = items;
        _selected = next?.practitionerId;
        _loading = false;
      });
      widget.onChanged(next);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();
    if (_failed) {
      return Row(
        children: [
          const Expanded(child: Text('Praticiens indisponibles.')),
          IconButton(
            onPressed: _load,
            tooltip: 'Recharger les praticiens',
            icon: const Icon(Icons.refresh),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return Row(
        children: [
          const Expanded(
            child: Text('Aucun praticien actif. Ajoutez-le dans Praticiens.'),
          ),
          IconButton(
            onPressed: _load,
            tooltip: 'Recharger les praticiens',
            icon: const Icon(Icons.refresh),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            key: ValueKey(_selected),
            initialValue: _selected,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Praticien',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            hint: const Text('Choisir un praticien'),
            items: [
              for (final item in _items)
                DropdownMenuItem(
                  value: item.practitionerId,
                  child: Text(
                    item.displayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (id) {
              setState(() => _selected = id);
              widget.onChanged(
                _items.where((item) => item.practitionerId == id).firstOrNull,
              );
            },
          ),
        ),
        IconButton(
          onPressed: _load,
          tooltip: 'Recharger les praticiens',
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
