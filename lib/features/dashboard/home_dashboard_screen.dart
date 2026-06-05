import 'package:flutter/material.dart';

import '../patients/patient_list_screen.dart';
import '../reports/report_archive_screen.dart';
import '../settings/settings_screen.dart';
import '../practitioners/practitioner_list_screen.dart';
import '../devices/device_list_screen.dart';
import '../import_export/abak_import_launcher.dart';
import 'package:abak_desktop_companion/features/home/widgets/home_import_summary_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/recent_imports_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/system_status_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/system_alerts_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/quick_actions_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/system_overview_bar.dart';
import 'package:abak_desktop_companion/features/home/widgets/pending_resolution_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});


  @override
  State<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState
    extends State<HomeDashboardScreen> {
  int selectedIndex = 0;

  final List<String> titles = const [
    'Accueil',
    'Patients',
    'Kinés',
    'Appareils',
    'Archives',
    'Réglages',
  ];

  AbakImportLauncherResult? lastImportResult;
  int refreshToken = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () {
              setState(() {
                refreshToken++;
              });
            },
            icon: const Icon(Icons.refresh_outlined),
          ),
          const SizedBox(height: 20),
        ],

      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Accueil'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Patients'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(Icons.medical_services),
                label: Text('Kinés'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.devices_other_outlined),
                selectedIcon: Icon(Icons.devices_other),
                label: Text('Appareils'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: Text('Archives'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Réglages'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Station clinique locale ABAK',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 24),
                  SystemOverviewBar(
                    key: ValueKey('overview-$refreshToken'),
                  ),

                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      if (lastImportResult != null)
                        SizedBox(
                          width: 520,
                          child: HomeImportSummaryCard(
                            key: ValueKey('summary-$refreshToken'),
                            result: lastImportResult!,
                          ),
                        ),
                      SizedBox(
                        width: 520,
                        child: RecentImportsCard(
                          key: ValueKey('recent-$refreshToken'),
                        ),
                      ),
                      SizedBox(
                        width: 520,
                        child: SystemStatusCard(
                          key: ValueKey('status-$refreshToken'),
                        ),
                      ),
                      SizedBox(
                        width: 520,
                        child: SystemAlertsCard(
                          key: ValueKey('alerts-$refreshToken'),
                        ),
                      ),
                      SizedBox(
                        width: 520,
                        child: PendingResolutionCard(
                          key: ValueKey('pending-resolution-$refreshToken'),
                        ),
                      ),
                      SizedBox(
                        width: 520,
                        child: QuickActionsCard(
                          key: ValueKey('quick-$refreshToken'),
                          onImportCompleted: (result) {
                            setState(() {
                              lastImportResult = result;
                              refreshToken++;
                            });
                          },
                          onMaintenanceCompleted: () {
                            setState(() {
                              refreshToken++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      case 1:
        return const PatientListScreen();
      case 2:
        return const PractitionerListScreen();
      case 3:
        return const DeviceListScreen();
      case 4:
        return const ReportArchiveScreen();
      case 5:
        return const SettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}