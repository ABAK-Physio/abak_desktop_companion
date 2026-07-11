import 'package:flutter/material.dart';

import '../../core/utils/date_format_utils.dart';
import 'data/device_repository.dart';
import 'models/paired_device.dart';
import 'widgets/device_form_dialog.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final DeviceRepository _repository = DeviceRepository();

  late Future<List<PairedDevice>> _devicesFuture;

  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _reloadDevices();
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
      children: [
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
                            : 'Les téléphones ABAK associés au cabinet apparaîtront ici.',
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
                                  'Kiné associé : ${device.practitionerId}',
                              ].join(' · '),
                      ),
                      trailing: _showArchived
                          ? IconButton(
                              tooltip: 'Restaurer',
                              icon: const Icon(Icons.restore),
                              onPressed: () => _restoreDevice(device),
                            )
                          : IconButton(
                              tooltip: 'Archiver',
                              icon: const Icon(Icons.archive_outlined),
                              onPressed: () => _archiveDevice(device),
                            ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
