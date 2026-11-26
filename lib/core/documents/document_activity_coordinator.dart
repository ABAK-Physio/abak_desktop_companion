import 'dart:async';

/// One process-wide barrier, independent of UI and of the DMP enable flag.
/// Refuse rather than cancel or interrupt an already running operation.
class DocumentActivityCoordinator {
  static final shared = DocumentActivityCoordinator();
  final Object _zoneKey = Object();
  int _activities = 0;
  bool _exclusive = false;
  bool recoveryRequired = false;
  bool get migrationPending => _exclusive || recoveryRequired;
  bool get active => _exclusive || _activities != 0;
  bool get busy => active || recoveryRequired;

  void checkAvailable() {
    if (_exclusive || recoveryRequired) {
      throw StateError('document_activity_blocked');
    }
  }

  Future<T> activity<T>(Future<T> Function() action) async {
    final inherited = Zone.current[_zoneKey];
    if (inherited is _DocumentActivity && inherited.active) return action();
    if (_exclusive || recoveryRequired) {
      throw StateError('document_activity_blocked');
    }
    final token = _DocumentActivity();
    _activities++;
    try {
      return await runZoned(action, zoneValues: {_zoneKey: token});
    } finally {
      token.active = false;
      _activities--;
    }
  }

  Future<T> exclusive<T>(
    Future<T> Function() action, {
    bool recovery = false,
  }) async {
    if (_exclusive || _activities != 0 || (!recovery && recoveryRequired)) {
      throw StateError('document_activity_busy');
    }
    _exclusive = true;
    try {
      return await action();
    } finally {
      _exclusive = false;
    }
  }
}

class _DocumentActivity {
  bool active = true;
}
