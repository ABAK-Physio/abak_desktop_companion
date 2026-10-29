import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../database/database_service.dart';
import 'maintenance_session.dart';
import 'bundle_resources_recipe.dart';
import 'coordinated_recipe.dart';

class CompanionMaintenanceApp extends StatelessWidget {
  const CompanionMaintenanceApp({
    super.key,
    required this.session,
    this.bundleRecipeRoot,
    this.coordinatedRequest,
  });
  final MaintenanceSession session;
  final String? bundleRecipeRoot;
  final StartupRequest? coordinatedRequest;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.teal),
    home: Scaffold(
      appBar: AppBar(title: const Text('ABAK Companion — Maintenance')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(28),
            children: [
              Text(
                session.synthetic
                    ? 'Base synthétique — lecture seule'
                    : 'Maintenance — lecture seule',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Les échanges, imports, purges et fonctions CPS, INSi et DMP ne sont pas démarrés. '
                'Aucune migration automatique. '
                '${bundleRecipeRoot == null ? 'Aucun accès aux dossiers depuis cet écran.' : 'Seules les ressources synthétiques autorisées sont examinées.'}',
              ),
              const SizedBox(height: 20),
              Text(
                'Version de la base : ${session.version}. Version attendue : ${DatabaseService.schemaVersion}.',
              ),
              Text(
                session.integrity
                    ? 'Intégrité SQLite : correcte.'
                    : 'Intégrité SQLite : anomalie. Conserver la base et examiner une copie.',
              ),
              if (session.version != DatabaseService.schemaVersion)
                const Text(
                  'Migration nécessaire : préparer une copie et un retour arrière avant toute modification.',
                ),
              const SizedBox(height: 12),
              SelectableText(session.path),
              const SizedBox(height: 24),
              const Text(
                'Fermer cet écran ne relance pas les fonctions habituelles.',
              ),
              const SizedBox(height: 12),
              if (bundleRecipeRoot != null)
                BundleResourcesRecipePanel(root: bundleRecipeRoot!),
              if (coordinatedRequest != null)
                CoordinatedRecipePanel(request: coordinatedRequest!),
              FilledButton(
                onPressed: () async {
                  await session.close();
                  await windowManager.close();
                },
                child: const Text('Fermer Companion'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
