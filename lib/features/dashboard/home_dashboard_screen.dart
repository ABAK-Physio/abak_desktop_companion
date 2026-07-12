import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../../generated/l10n.dart';

import 'package:qr_flutter/qr_flutter.dart';
import '../local_exchange/services/local_exchange_server.dart';

import '../patients/patient_list_screen.dart';
import '../reports/report_archive_screen.dart';
import '../settings/settings_screen.dart';
import '../informations/about.dart';
import '../practitioners/practitioner_list_screen.dart';
import '../devices/device_list_screen.dart';
import '../import_export/abak_import_launcher.dart';
import 'package:abak_desktop_companion/features/home/widgets/recent_imports_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/system_status_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/system_alerts_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/quick_actions_card.dart';
import 'package:abak_desktop_companion/features/home/widgets/system_overview_bar.dart';
import 'package:abak_desktop_companion/features/home/widgets/pending_resolution_card.dart';
import '../preferences/preferences_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback onLocaleChanged;

  const HomeDashboardScreen({super.key, required this.onLocaleChanged});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int selectedIndex = 0;
  int _refreshToken = 0;
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
      _refreshToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text(S.of(context).home),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text(S.of(context).patients),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(Icons.medical_services),
                label: Text(S.of(context).practitioners),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.devices_other_outlined),
                selectedIcon: Icon(Icons.devices_other),
                label: Text(S.of(context).devices),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: Text(S.of(context).archives),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: Text('Paramètres'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text(S.of(context).settings),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text(S.of(context).information),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildContent()),
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
            title: Text(S.of(context).ipAddressNotFound),
            content: Text(S.of(context).ipAddressNotFoundMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(S.of(context).ok),
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
          title: Text(S.of(context).pairPhoneDialogTitle),
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
                  '${S.of(context).desktopAddress} : $host\n'
                  '${S.of(context).desktopPort} : $port',
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
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DashboardHeader(
                    title: _titles(context)[selectedIndex],
                    onPairPhone: _showDesktopPairingQr,
                    onRefresh: _refreshDashboard,
                  ),
                  const SizedBox(height: 8),
                  SystemOverviewBar(
                    key: ValueKey('overview-$_refreshToken'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: RecentImportsCard(
                          key: ValueKey('imports-$_refreshToken'),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SystemStatusCard(),
                            const SizedBox(height: 24),
                            PendingResolutionCard(
                              key: ValueKey('pending-$_refreshToken'),
                              onImportCompleted: _refreshDashboard,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SystemAlertsCard(),
                            const SizedBox(height: 24),
                            QuickActionsCard(
                              onImportCompleted: (result) {
                                setState(() {
                                  lastImportResult = result;
                                });
                                _refreshDashboard();
                              },
                              onMaintenanceCompleted: _refreshDashboard,
                            ),
                          ],
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
        return PreferencesScreen(onLanguageChanged: widget.onLocaleChanged);
      case 6:
        return const SettingsScreen();
      case 7:
        return const AboutScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _DashboardHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPairPhone;
  final VoidCallback onRefresh;

  const _DashboardHeader({
    required this.title,
    required this.onPairPhone,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          IconButton(
            tooltip: S.of(context).pairPhone,
            onPressed: onPairPhone,
            icon: const Icon(Icons.qr_code_2_outlined),
          ),
          IconButton(
            tooltip: S.of(context).refreshDashboard,
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
    );
  }
}
