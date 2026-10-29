import 'dart:async';

/// Tracks user activity, independently of TLS timeouts and background tasks.
class InactivityLock {
  InactivityLock({required this.onExpired, DateTime Function()? now})
    : now = now ?? DateTime.now;
  final void Function() onExpired;
  final DateTime Function() now;
  Timer? _timer;
  DateTime? _lastActivity;
  Duration delay = const Duration(minutes: 15);
  bool get active => _lastActivity != null;

  void start(Duration value) {
    delay = value;
    _lastActivity = now();
    check();
  }

  void activity() {
    if (!active) return;
    _lastActivity = now();
    check();
  }

  /// Re-evaluate on resume too: a sleeping process may not deliver its timers.
  void check() {
    _timer?.cancel();
    final last = _lastActivity;
    if (last == null) return;
    final elapsed = now().difference(last);
    if (elapsed.isNegative || elapsed >= delay) {
      stop();
      onExpired();
    } else {
      _timer = Timer(delay - elapsed, check);
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _lastActivity = null;
  }
}
