import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/settings/cabinet_identity_service.dart';
import '../../../core/settings/practitioner_qr_data.dart';
import '../models/practitioner.dart';

class PractitionerQrDialog extends StatelessWidget {
  final Practitioner practitioner;

  const PractitionerQrDialog({
    super.key,
    required this.practitioner,
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
          title: const Text('Profil professionnel ABAK'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  practitioner.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  data.organizationName,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                QrImageView(
                  data: data.qrValue,
                  version: QrVersions.auto,
                  size: 260,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Scannez ce QR Code depuis ABAK Mobile afin d'ajouter automatiquement ce profil professionnel.",
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

    final qrData = PractitionerQrData(
      organizationId: organizationId,
      organizationName: organizationName,
      practitionerId: practitioner.practitionerId,
      displayName: practitioner.displayName,
    );

    return _QrViewModel(
      organizationName: organizationName,
      qrValue: qrData.toQrValue(),
    );
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