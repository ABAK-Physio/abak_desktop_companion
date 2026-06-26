import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:qr_flutter/qr_flutter.dart';
import '../local_exchange/services/local_exchange_server.dart';

import '../patients/patient_list_screen.dart';
import '../reports/report_archive_screen.dart';
import '../settings/settings_screen.dart';
import '../informations/about.dart';
import '../practitioners/practitioner_list_screen.dart';
import '../devices/device_list_screen.dart';
import '../import_export/abak_import_launcher.dart';
import '../../generated/l10n.dart';
import 'package:abak_desktop_companion/features/home/widgets/home_import_summary_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/recent_imports_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/system_status_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/system_alerts_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/quick_actions_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/system_overview_bar.dart';
import 'package:abak_desktop_companion/features/home/widgets/pending_resolution_card.dart';
import '../preferences/preferences_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback onLocaleChanged;

  const HomeDashboardScreen({
    super.key,
    required this.onLocaleChanged,
  });


  @override
  State<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState
    extends State<HomeDashboardScreen> {
  int selectedIndex = 0;

  List<String> _titles(BuildContext context) {
    return [
      S.of(context).home,
      S.of(context).patients,
      'Kinés',
      'Appareils',
      'Archives',
      'Paramètres',
      'Réglages',
      'Informations',
    ];
  }

  AbakImportLauncherResult? lastImportResult;

  void _refreshDashboard() {
    setState(() {
      // Reconstruction volontaire du tableau de bord.
      // Les cards qui ont leur propre logique interne
      // décident ensuite si elles doivent vraiment se rafraîchir.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles(context)[selectedIndex]),
        actions: [
          if (selectedIndex == 0)
            IconButton(
              tooltip: 'Associer un téléphone',
              onPressed: _showDesktopPairingQr,
              icon: const Icon(Icons.qr_code_2_outlined),
            ),
          IconButton(
            tooltip: 'Actualiser le tableau de bord',
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh_outlined),
          ),
          const SizedBox(width: 12),
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
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: Text('Paramètres'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Réglages'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text('Informations'),
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

  Future<void> _showDesktopPairingQr() async {
    final host = await _findLocalIPv4Address();
    const port = LocalExchangeServer.defaultPort;

    if (!mounted) return;

    if (host == null) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Adresse IP introuvable'),
            content: const Text(
              'Impossible de déterminer l’adresse IP locale du Desktop.\n\n'
                  'Vérifiez que l’ordinateur est connecté au réseau local.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final payload = jsonEncode({
      'type': 'abak_desktop_companion',
      'version': 1,
      'host': host,
      'port': port,
    });

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Associer un téléphone'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: payload,
                  version: QrVersions.auto,
                  size: 260,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                SelectableText(
                  'Adresse : $host\nPort : $port',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scannez ce QR code depuis ABAK Mobile pour configurer '
                      'automatiquement la connexion au Desktop.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _findLocalIPv4Address() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        final ip = address.address;

        if (ip.startsWith('127.')) continue;
        if (ip.startsWith('169.254.')) continue;

        return ip;
      }
    }

    return null;
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
                  SystemOverviewBar(),

                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      if (lastImportResult != null)
                        SizedBox(
                          width: 520,
                          child: HomeImportSummaryCard(
                            result: lastImportResult!,
                          ),
                        ),
                      const SizedBox(
                        width: 520,
                        child: RecentImportsCard(),
                      ),
                      const SizedBox(
                        width: 520,
                        child: SystemStatusCard(),
                      ),
                      const SizedBox(
                        width: 520,
                        child: SystemAlertsCard(),
                      ),
                      const SizedBox(
                        width: 520,
                        child: PendingResolutionCard(),
                      ),
                      SizedBox(
                        width: 520,
                        child: QuickActionsCard(
                          onImportCompleted: (result) {
                            setState(() {
                              lastImportResult = result;
                            });
                          },
                          onMaintenanceCompleted: () {
                            setState(() {});
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
        return PreferencesScreen(
          onLanguageChanged: widget.onLocaleChanged,
        );
      case 6:
        return const SettingsScreen();
      case 7:
        return const AboutScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}