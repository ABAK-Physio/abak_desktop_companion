import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/core/maintenance/maintenance_session.dart';

class Binding extends WidgetsFlutterBinding with TestDefaultBinaryMessengerBinding {}

Future<void> main() async {
  final binding = Binding();
  final root = Platform.environment['COORDINATED_GUARD_ROOT']!;
  final checks = <String>[];
  Future<void> refuses(Future<void> Function() operation, String label) async {
    bool blocked = false;
    try { await operation(); } catch (_) { blocked = true; }
    if (!blocked) throw StateError(label);
    checks.add(label);
  }
  final base = ['--abak-maintenance', '--abak-maintenance-root=$root', '--abak-maintenance-authorize'];
  try {
    for (final args in [
      ['--abak-coordinated-phase=seed'],
      [...base, '--abak-coordinated-phase=inconnu'],
      [...base, '--abak-coordinated-phase=seed', '--abak-coordinated-phase=seed'],
      [...base, '--abak-coordinated-phase=recover'],
      [...base, '--abak-coordinated-phase=recover', '--abak-rollback-plan=incorrect'],
      [...base, '--abak-coordinated-phase=seed', '--abak-bundle-resources'],
    ]) {
      await refuses(() async { StartupRequest.parse(args); }, 'Options isolées refusées : ${args.last}');
    }
    binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('abak/maintenance_access'), (call) async {
      if (call.method == 'authorize') return root;
      return null;
    });
    // No database exists: rejection must occur specifically at the pending gate.
    for (final phase in [null, 'seed', 'upgrade', 'verify']) {
      final request = StartupRequest.parse([...base, if (phase != null) '--abak-coordinated-phase=$phase']);
      bool blocked = false;
      try { await MaintenanceSession.open(request); } catch (e) {
        blocked = e.toString().contains('Retour arrière incomplet');
      }
      if (!blocked) throw StateError('Le marqueur doit bloquer avant ouverture SQLite');
      checks.add('Retour incomplet bloque avant SQLite : $phase');
      final lock = await CompanionInstanceLock.acquire(File('$root/.companion-instance.lock'));
      await lock.close();
      checks.add('Verrou libéré après refus : $phase');
    }
    File('$root/result.json').writeAsStringSync(jsonEncode({'passed': true, 'checks': checks}));
    exit(0);
  } catch (e) {
    File('$root/result.json').writeAsStringSync(jsonEncode({'passed': false, 'checks': checks, 'error': '$e'}));
    exit(1);
  }
}
