import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../patients/models/patient.dart';

class PlanningPatientPicker extends StatefulWidget {
  const PlanningPatientPicker({super.key, required this.search});
  final Future<List<Patient>> Function(String) search;

  @override
  State<PlanningPatientPicker> createState() => _PlanningPatientPickerState();
}

class _PlanningPatientPickerState extends State<PlanningPatientPicker> {
  final _query = TextEditingController();
  Timer? _timer;
  int _generation = 0;
  bool _loading = true;
  bool _failed = false;
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final patients = await widget.search(_query.text);
      if (mounted && generation == _generation) {
        setState(() {
          _patients = patients;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _query.dispose();
    super.dispose();
  }

  String _birth(Patient patient) {
    final date = DateTime.tryParse(patient.birthDate ?? '');
    return date == null
        ? 'Date de naissance non renseignée'
        : 'Né(e) le ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Choisir un patient'),
    content: SizedBox(
      width: 460,
      height: 360,
      child: Column(
        children: [
          TextField(
            controller: _query,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Rechercher un patient',
              hintText: 'Nom, prénom ou date (AAAA-MM-JJ)',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) {
              _timer?.cancel();
              ++_generation; // Invalidate earlier results immediately, before debounce.
              setState(() => _loading = true);
              _timer = Timer(const Duration(milliseconds: 250), _search);
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _failed
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Impossible de charger les patients.'),
                        TextButton(
                          onPressed: _search,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : _patients.isEmpty
                ? const Center(child: Text('Aucun patient trouvé.'))
                : ListView.builder(
                    itemCount: _patients.length,
                    itemBuilder: (_, index) {
                      final patient = _patients[index];
                      return ListTile(
                        title: Text(patient.displayName),
                        subtitle: Text(_birth(patient)),
                        onTap: () => Navigator.pop(context, patient),
                      );
                    },
                  ),
          ),
          if (_patients.length == 30 && !_loading && !_failed)
            const Text(
              '30 résultats affichés. Précisez votre recherche.',
              style: TextStyle(fontSize: 12),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
    ],
  );
}
