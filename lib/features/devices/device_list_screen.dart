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
  ExpertContextInfo _expertInfo(S s) {
    return ExpertContextInfo(
      contextName: s.deviceList_contextName,
      sourceFile: 'lib/features/devices/device_list_screen.dart',
      arbPrefix: 'deviceList',
      comment: s.deviceList_contextComment,
    );
  }

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
    final s=S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(s.deviceList_archiveTitle),
          content: Text(
            s.deviceList_archiveConfirmation(device.deviceLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(s.deviceList_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(s.deviceList_archive),
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
    final s = S.of(context);

    return FutureBuilder<List<PairedDevice>>(
      future: _devicesFuture,
      builder: (context, snapshot) {
        final devices = snapshot.data ?? [];

        return Scaffold(
          body: _buildBody(snapshot, devices, s),
          floatingActionButton: _showArchived
              ? null
              : FloatingActionButton.extended(
            onPressed: _createDevice,
            icon: const Icon(Icons.devices),
            label: Text(s.deviceList_newDevice),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<List<PairedDevice>> snapshot,
    List<PairedDevice> devices, S s
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('${s.deviceList_error} : ${snapshot.error}'));
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
                  s.deviceList_contextName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ContextHelpButton(
                title: S.of(context).help_device_list_title,
                content: S.of(context).help_device_list_content,
              ),

              if (_expertModeEnabled)
                ExpertInfoButton(
                  info: _expertInfo(s),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(s.deviceList_active),
                icon: Icon(Icons.devices_other_outlined),
              ),
              ButtonSegment(
                value: true,
                label: Text(s.deviceList_archived),
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
                            ? s.deviceList_noArchivedDevices
                            : s.deviceList_noPairedDevices,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _showArchived
                            ? s.deviceList_archivedDevicesEmpty
                            : s.deviceList_pairedDevicesExplanation,
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
                              ? '${s.deviceList_archivedOn} '
                              '${DateFormatUtils.formatTimestampForDisplay(
                            context,
                            device.archivedAt,
                          )}'
                              : [
                            if (device.platform != null)
                              '${s.deviceList_platform} : ${device.platform}',
                            if (device.practitionerId != null)
                              '${s.deviceList_associatedPractitioner} : ${device.practitionerId}',
                          ].join(' · '),
                        ),
                      trailing: _showArchived
                          ? IconButton(
                        tooltip: s.deviceList_restore,
                        icon: const Icon(Icons.restore),
                        onPressed: () => _restoreDevice(device),
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: s.deviceList_showQrCode,
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
                            tooltip: s.deviceList_edit,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editDevice(device),
                          ),
                          IconButton(
                            tooltip: s.deviceList_archive,
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
