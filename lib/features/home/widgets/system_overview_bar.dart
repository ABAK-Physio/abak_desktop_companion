import 'dart:async';
import 'dart:io';

import 'package:abak_desktop_companion/core/settings/cabinet_identity_service.dart';

import 'package:flutter/material.dart';

import '../../maintenance/models/system_health_snapshot.dart';
import '../../maintenance/services/system_health_service.dart';

class SystemOverviewBar extends StatefulWidget {
  const SystemOverviewBar({super.key});

  @override
  State<SystemOverviewBar> createState() => _SystemOverviewBarState();
}

class _SystemOverviewBarState extends State<SystemOverviewBar> {
  SystemHealthSnapshot? _health;
  Object? _error;
  bool _isLoading = true;
  Timer? _timer;

  final CabinetIdentityService _cabinetIdentityService =
      const CabinetIdentityService();

  String? _cabinetName;
  String? _cabinetLogoPath;

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes o';

    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} Ko';

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} Mo';
  }

  @override
  void initState() {
    super.initState();
    _refresh();
    _loadCabinetIdentity();

    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  Future<void> _loadCabinetIdentity() async {
    final cabinetName = await _cabinetIdentityService.getCabinetName();
    final cabinetLogoPath = await _cabinetIdentityService.getCabinetLogoPath();

    if (!mounted) return;

    setState(() {
      _cabinetName = cabinetName;
      _cabinetLogoPath = cabinetLogoPath;
    });
  }

  Future<void> _refresh() async {
    try {
      final newHealth = await const SystemHealthService().loadSnapshot();

      if (!mounted) return;

      if (_healthSignature(_health) == _healthSignature(newHealth) &&
          _error == null &&
          !_isLoading) {
        return;
      }

      setState(() {
        _health = newHealth;
        _error = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      if (_error?.toString() == error.toString() && !_isLoading) {
        return;
      }

      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  String _healthSignature(SystemHealthSnapshot? health) {
    if (health == null) return '';

    final alertCount =
        health.failedImportsCount +
        (health.hasNoBackup || health.hasOldBackup ? 1 : 0) +
        (health.hasRunningImports ? 1 : 0);

    return [
      health.databaseSizeBytes,
      alertCount,
      health.activePatientsCount,
      health.archivedPatientsCount,
      health.backupsCount,
      health.backupsTotalSizeBytes,
    ].join('|');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Chargement du résumé système...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Erreur supervision : $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final health = _health;

    if (health == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Supervision indisponible.'),
        ),
      );
    }

    final alertCount =
        health.failedImportsCount +
        (health.hasNoBackup || health.hasOldBackup ? 1 : 0) +
        (health.hasRunningImports ? 1 : 0);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 18,
                runSpacing: 14,
                children: [
                  _OverviewItem(
                    icon: Icons.storage_outlined,
                    label: 'Base locale',
                    value: _formatFileSize(health.databaseSizeBytes),
                  ),
                  _OverviewItem(
                    icon: Icons.people_outline,
                    label: 'Patients actifs',
                    value: health.activePatientsCount.toString(),
                  ),
                  _OverviewItem(
                    icon: Icons.archive_outlined,
                    label: 'Patients archivés',
                    value: health.archivedPatientsCount.toString(),
                  ),
                  _OverviewItem(
                    icon: Icons.backup_outlined,
                    label: 'Sauvegardes',
                    value:
                        '${health.backupsCount} · ${_formatFileSize(health.backupsTotalSizeBytes)}',
                  ),
                  _OverviewItem(
                    icon: Icons.warning_amber_outlined,
                    label: 'Alertes',
                    value: alertCount.toString(),
                    color: alertCount > 0 ? Colors.orange : Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            _CabinetIdentityPanel(
              cabinetName: _cabinetName,
              logoPath: _cabinetLogoPath,
            ),
          ],
        ),
      ),
    );
  }
}

class _CabinetIdentityPanel extends StatelessWidget {
  final String? cabinetName;
  final String? logoPath;

  const _CabinetIdentityPanel({
    required this.cabinetName,
    required this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    final logoFile = logoPath == null ? null : File(logoPath!);
    final hasLogo = logoFile != null && logoFile.existsSync();

    return Container(
      width: 300,
      padding: const EdgeInsets.only(left: 24),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: hasLogo
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(logoFile, fit: BoxFit.contain),
                  )
                : Icon(
                    Icons.image_outlined,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              cabinetName?.trim().isNotEmpty == true
                  ? cabinetName!.trim()
                  : 'Nom du cabinet',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _OverviewItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 210),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: effectiveColor),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: effectiveColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
