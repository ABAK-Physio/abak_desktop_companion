import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/settings/cabinet_identity_service.dart';
import '../../../core/settings/device_qr_data.dart';
import '../models/paired_device.dart';

class DeviceQrDialog extends StatelessWidget {
  final PairedDevice device;

  const DeviceQrDialog({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_QrViewModel>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AlertDialog(
            content: SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final data = snapshot.data!;

        return AlertDialog(
          title: const Text('Appareil ABAK'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  device.deviceLabel,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  data.organizationName,
                  textAlign: TextAlign.center,
                ),
                if (device.platform != null &&
                    device.platform!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _platformLabel(device.platform!),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                QrImageView(
                  data: data.qrValue,
                  version: QrVersions.auto,
                  size: 260,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Scannez ce QR Code depuis ABAK Mobile afin '
                      'd’identifier cet appareil dans cet établissement.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Future<_QrViewModel> _loadData() async {
    const cabinetService = CabinetIdentityService();

    final organizationId = await cabinetService.getOrganizationId();
    final organizationName =
        await cabinetService.getCabinetName() ?? 'Cabinet';

    final qrData = DeviceQrData(
      organizationId: organizationId,
      organizationName: organizationName,
      deviceId: device.deviceId,
      deviceLabel: device.deviceLabel,
      platform: device.platform,
    );

    return _QrViewModel(
      organizationName: organizationName,
      qrValue: qrData.toQrValue(),
    );
  }

  String _platformLabel(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return 'iOS';
      case 'android':
        return 'Android';
      default:
        return platform;
    }
  }
}

class _QrViewModel {
  final String organizationName;
  final String qrValue;

  const _QrViewModel({
    required this.organizationName,
    required this.qrValue,
  });
}