import 'dart:async';

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

    _timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => _refresh(),
    );
  }

  Future<void> _refresh() async {
    try {
      final newHealth =
      await const SystemHealthService().loadSnapshot();

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
      health.importsCount,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _OverviewItem(
              icon: Icons.storage_outlined,
              label: 'Base locale',
              value: _formatFileSize(health.databaseSizeBytes),
              color: Colors.green,
            ),
            _OverviewItem(
              icon: Icons.warning_amber_outlined,
              label: 'Alertes',
              value: alertCount.toString(),
              color: alertCount > 0 ? Colors.orange : Colors.green,
            ),
            _OverviewItem(
              icon: Icons.history_outlined,
              label: 'Imports',
              value: health.importsCount.toString(),
            ),
            _OverviewItem(
              icon: Icons.people_outline,
              label: 'Patients actifs',
              value: health.activePatientsCount.toString(),
            ),
            _OverviewItem(
              icon: Icons.archive_outlined,
              label: 'Archivés',
              value: health.archivedPatientsCount.toString(),
            ),
            _OverviewItem(
              icon: Icons.backup_outlined,
              label: 'Sauvegardes',
              value:
              '${health.backupsCount} · ${_formatFileSize(health.backupsTotalSizeBytes)}',
            ),
          ],
        ),
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
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.primary;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 190,
        maxWidth: 280,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: effectiveColor,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label : ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: effectiveColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}