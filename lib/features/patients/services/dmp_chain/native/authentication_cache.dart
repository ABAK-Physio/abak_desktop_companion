import 'dart:async';
import '../../../../cps/cps_operation_lease.dart';
import '../../../../cps/cps_profile.dart';
import 'bridge.dart';

/// Only CPS authentication is retained. No PIN, patient, consent, SOAP request,
/// document, transaction ID or live TLS connection is stored in this cache.
class RetainedCpsAuthentication {
  RetainedCpsAuthentication({
    required this.key,
    required this.profile,
    required this.bridge,
    required this.lease,
    required this.expires,
    required this.checkContext,
    this.releaseResources,
  });
  final String key;
  final CpsProfile profile;
  final DmpNativeBridge bridge;
  final CpsOperationLease lease;
  final DateTime expires;
  final void Function() checkContext;
  final Future<void> Function()? releaseResources;
}

class CpsAuthenticationCache {
  CpsAuthenticationCache({DateTime Function()? now})
    : now = now ?? DateTime.now;
  static final shared = CpsAuthenticationCache();
  final DateTime Function() now;
  RetainedCpsAuthentication? _entry;
  DateTime? _storedAt;
  Timer? _timer;
  Future<void>? _checking;
  bool _probeFailed = false;

  bool canReuse(String key, String professional) {
    final e = _entry;
    if (_probeFailed ||
        e == null ||
        e.key != key ||
        e.profile.nationalId != professional ||
        !e.lease.active ||
        !now().isBefore(e.expires) ||
        (_storedAt != null && now().isBefore(_storedAt!))) {
      return false;
    }
    try {
      e.checkContext();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<RetainedCpsAuthentication?> take(String key) async {
    _timer?.cancel();
    await _checking;
    final e = _entry;
    if (e == null) return null;
    if (!canReuse(key, e.profile.nationalId)) {
      await CpsOperationLease.closeIdle();
      return null;
    }
    // No await between ownership transfer and removing the cached entry.
    e.lease.resume();
    _entry = null;
    _storedAt = null;
    return e;
  }

  void retain(RetainedCpsAuthentication entry) {
    if (_entry != null) {
      throw StateError('Authentification CPS déjà conservée.');
    }
    entry.checkContext();
    if (!now().isBefore(entry.expires)) throw DmpNativeFailure('SESSION');
    _probeFailed = false;
    _entry = entry;
    _storedAt = now();
    entry.lease.park(() => _close(entry));
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (_entry != null) {
      _timer = Timer(const Duration(seconds: 5), () async {
        var failed = false;
        final e = _entry;
        if (e == null) return;
        final check = Future<void>(() async {
          if (!canReuse(e.key, e.profile.nationalId)) {
            throw DmpNativeFailure('SESSION');
          }
          // Local cryptographic card-presence check; never a network exchange.
          final result = await e.bridge.call('authenticationcheck', {});
          if (result['professional'] != e.profile.nationalId) {
            throw DmpNativeFailure('CPS_IDENTITY');
          }
        });
        _checking = check.catchError((Object _) {
          failed = true;
          _probeFailed = true;
        });
        await _checking;
        _checking = null;
        if (failed) {
          try {
            await CpsOperationLease.closeIdle();
          } catch (_) {}
        } else {
          _schedule();
        }
      });
    }
  }

  Future<void> _close(RetainedCpsAuthentication e) async {
    // Immediately stop advertising reuse, including while a probe is finishing.
    if (identical(_entry, e)) _entry = null;
    _storedAt = null;
    _timer?.cancel();
    await _checking;
    await e.bridge.close();
    await e.releaseResources?.call();
    e.lease.release();
  }
}
