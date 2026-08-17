import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/settings/cabinet_identity_service.dart';
import '../../../core/settings/practitioner_qr_data.dart';
import '../../../generated/l10n.dart';
import '../models/practitioner.dart';

class PractitionerQrDialog extends StatelessWidget {
  final Practitioner practitioner;

  const PractitionerQrDialog({
    super.key,
    required this.practitioner,
  });

  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return FutureBuilder<_QrViewModel>(
      future: _loadData(s.practitionerQr_defaultOrganizationName),
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
          title:  Text(s.practitionerQr_professionalProfile),
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
                Text(
                  s.practitionerQr_scanQrCodeInstruction,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.practitionerQr_close),
            ),
          ],
        );
      },
    );
  }

  Future<_QrViewModel> _loadData(String defaultOrganizationName) async {
    const cabinetService = CabinetIdentityService();

    final organizationId = await cabinetService.getOrganizationId();
    final organizationName =
        await cabinetService.getCabinetName() ?? defaultOrganizationName;

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