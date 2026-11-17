import 'package:flutter/services.dart';
import 'startup_maintenance.dart';

/// Coalesce repeated Quit requests and drain application-owned resources.
class ApplicationShutdown {
  ApplicationShutdown({
    required this.steps,
    required this.isBusy,
    required this.ready,
    required this.onBusy,
  });
  static const channel = MethodChannel('abak/application_lifecycle');
  final List<Future<void> Function()> steps;
  final bool Function() isBusy;
  final Future<void> ready;
  final void Function() onBusy;
  Future<bool>? _pending;

  void register() {
    channel.setMethodCallHandler((call) async {
      if (call.method != 'prepareToQuit') throw MissingPluginException();
      return prepareToQuit();
    });
  }

  Future<bool> prepareToQuit() => _pending ??= _prepare().whenComplete(() {
    _pending = null;
  });
  Future<bool> _prepare() async {
    await ready;
    // A backup/restore must not be interrupted halfway through replacement.
    if (isBusy()) {
      onBusy();
      return false;
    }
    await stopStartupServices(steps);
    return true;
  }
}
