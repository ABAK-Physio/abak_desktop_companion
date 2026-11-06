import 'package:flutter/foundation.dart';

/// Isolate optional maintenance without concealing mandatory startup failures.
Future<void> runOptionalMaintenance(
  String name,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (error, stack) {
    debugPrint('$name indisponible : $error');
    debugPrintStack(stackTrace: stack);
  }
}

/// Attempt every shutdown even when one service cannot stop cleanly.
Future<void> stopStartupServices(
  Iterable<Future<void> Function()> stops,
) async {
  for (final stop in stops) {
    await runOptionalMaintenance('Arrêt du service', stop);
  }
}
