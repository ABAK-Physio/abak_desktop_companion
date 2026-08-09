import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

import '../../core/utils/date_format_utils.dart';
import 'data/device_repository.dart';
import 'models/paired_device.dart';
import 'widgets/device_form_dialog.dart';
import 'widgets/device_qr_dialog.dart';
import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';
import '../../core/settings/application_settings_service.dart';
import 'package:abak_shared/abak_shared.dart';


class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  static const ExpertContextInfo _expertInfo = ExpertContextInfo(
    contextName: 'Liste des appareils',
    sourceFile: 'lib/features/devices/device_list_screen.dart',
    arbPrefix: 'deviceList',
    comment: 'Cet écran montre la liste des appareils connectés à l’établissement',
  );

  final ApplicationSettingsService _applicationSettingsService =
  const ApplicationSettingsService();

  bool _expertModeEnabled = false;

  final DeviceRepository _repository = DeviceRepository();

  late Future<List<PairedDevice>> _devicesFuture;

  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _reloadDevices();
    _loadExpertMode();
  }

  Future<void> _loadExpertMode() async {
    final expertModeEnabled =
    await _applicationSettingsService.isExpertModeEnabled();

    if (!mounted) return;

    setState(() {
      _expertModeEnabled = expertModeEnabled;
    });
  }

  Future<void> _reloadDevices() async {
    setState(() {
      _devicesFuture = _showArchived
          ? _repository.getArchivedDevices()
          : _repository.getActiveDevices();
    });
  }

  Future<void> _createDevice() async {
    final device = await showDialog<PairedDevice>(
      context: context,
      builder: (_) => const DeviceFormDialog(),
    );

    if (device == null) return;

    await _repository.insertDevice(device);
    await _reloadDevices();
  }

  Future<void> _editDevice(PairedDevice device) async {
    final updatedDevice = await showDialog<PairedDevice>(
      context: context,
      builder: (_) => DeviceFormDialog(
        initialDevice: device,
      ),
    );

    if (updatedDevice == null) return;

    await _repository.updateDevice(updatedDevice);
    await _reloadDevices();
  }

  Future<void> _archiveDevice(PairedDevice device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archiver l’appareil'),
          content: Text(
            'Voulez-vous vraiment archiver ${device.deviceLabel} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archiver'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _repository.archiveDevice(device.deviceId);
    await _reloadDevices();
  }

  Future<void> _restoreDevice(PairedDevice device) async {
    await _repository.restoreDevice(device.deviceId);

    setState(() {
      _showArchived = false;
      _devicesFuture = _repository.getActiveDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PairedDevice>>(
      future: _devicesFuture,
      builder: (context, snapshot) {
        final devices = snapshot.data ?? [];

        return Scaffold(
          body: _buildBody(snapshot, devices),
          floatingActionButton: _showArchived
              ? null
              : FloatingActionButton.extended(
                  onPressed: _createDevice,
                  icon: const Icon(Icons.devices),
                  label: const Text('Nouvel appareil'),
                ),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<List<PairedDevice>> snapshot,
    List<PairedDevice> devices,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Erreur : ${snapshot.error}'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Liste des appareils',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ContextHelpButton(
                title: S.of(context).help_device_list_title,
                content: S.of(context).help_device_list_content,
              ),

              if (_expertModeEnabled)
                const ExpertInfoButton(
                  info: _expertInfo,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Actifs'),
                icon: Icon(Icons.devices_other_outlined),
              ),
              ButtonSegment(
                value: true,
                label: Text('Archivés'),
                icon: Icon(Icons.archive_outlined),
              ),
            ],
            selected: {_showArchived},
            onSelectionChanged: (selection) {
              setState(() {
                _showArchived = selection.first;
                _devicesFuture = _showArchived
                    ? _repository.getArchivedDevices()
                    : _repository.getActiveDevices();
              });
            },
          ),
        ),
        Expanded(
          child: devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.devices_other_outlined, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        _showArchived
                            ? 'Aucun appareil archivé'
                            : 'Aucun appareil associé',
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _showArchived
                            ? 'La corbeille des appareils est vide pour le moment.'
                            : "'Les appareils ABAK associés à l'établissement apparaîtront ici.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final device = devices[index];

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.phone_android),
                      ),
                      title: Text(device.deviceLabel),
                      subtitle: Text(
                        _showArchived
                            ? 'Archivé le ${DateFormatUtils.formatTimestampForDisplay(context, device.archivedAt)}'
                            : [
                                if (device.platform != null)
                                  'Plateforme : ${device.platform}',
                                if (device.practitionerId != null)
                                  'Praticien associé : ${device.practitionerId}',
                              ].join(' · '),
                      ),
                      trailing: _showArchived
                          ? IconButton(
                        tooltip: 'Restaurer',
                        icon: const Icon(Icons.restore),
                        onPressed: () => _restoreDevice(device),
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Afficher le QR Code',
                            icon: const Icon(Icons.qr_code),
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (_) => DeviceQrDialog(
                                  device: device,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Modifier',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editDevice(device),
                          ),
                          IconButton(
                            tooltip: 'Archiver',
                            icon: const Icon(Icons.archive_outlined),
                            onPressed: () => _archiveDevice(device),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
