import '../dmp_setup/dmp_setup_service.dart';
import 'companion_session.dart';
import 'package:flutter/material.dart';
import 'companion_access_service.dart';
import 'patient_access_boundary.dart';

Future<bool> allowDatabaseReplacement(BuildContext context) async {
  try {
    await PatientAccessBoundary.administrativeServiceOf(
      context,
    ).requireDatabaseReplacementAccess();
    return context.mounted;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is CompanionAccessException
                ? error.message
                : 'Impossible de vérifier les droits. Réessayez.',
          ),
        ),
      );
    }
    return false;
  }
}

/// A restored database may contain other identities, codes and DMP settings.
/// Never carry live grants over to it; the banner reloads its durable setting.
void endSessionAfterDatabaseReplacement() {
  CompanionSession.current.setEnabled(false);
  DmpSetupService.changes.value++;
}
