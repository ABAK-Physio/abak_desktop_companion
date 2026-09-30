import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';

Future<T> withMaintenanceProgress<T>(
  BuildContext context,
  Future<T> Function() action,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Expanded(child: Text(S.of(context).backupArchive_working)),
          ],
        ),
      ),
    ),
  );
  try {
    return await action();
  } finally {
    navigator.pop();
  }
}
