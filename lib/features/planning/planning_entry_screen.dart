import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../core/database/database_service.dart';
import 'data/planning_repository.dart';
import 'prototype/planning_prototype_screen.dart';

/// Initializes the calendar when opened from the regular Companion entry point.
class PlanningEntryScreen extends StatefulWidget {
  const PlanningEntryScreen({super.key});
  @override
  State<PlanningEntryScreen> createState() => _PlanningEntryScreenState();
}

class _PlanningEntryScreenState extends State<PlanningEntryScreen> {
  late Future<void> _ready = _initialize();
  final _repository = PlanningRepository(
    database: () => DatabaseService.database,
  );

  Future<void> _initialize() async {
    await initializeDateFormatting('fr_FR');
    PackageStrings.setLocale('fr');
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _ready,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Impossible d’ouvrir le planning.'),
              TextButton(
                onPressed: () => setState(() => _ready = _initialize()),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      return PlanningPrototypeScreen(repository: _repository);
    },
  );
}
