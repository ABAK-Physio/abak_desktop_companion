/// One owner of the card, including an idle authenticated native worker.
/// An idle owner must finish closing before another component can use the card.
class CpsOperationLease {
  CpsOperationLease._();
  static CpsOperationLease? _owner;
  static Future<void>? _closing;
  Future<void> Function()? _closeIdle;
  static bool get inUse => _owner != null && _owner!._closeIdle == null;
  bool get active => identical(_owner, this);
  static CpsOperationLease acquire() {
    if (_owner != null) {
      throw StateError('Une opération CPS est déjà en cours.');
    }
    return _owner = CpsOperationLease._();
  }

  static Future<CpsOperationLease> acquireAvailable() async {
    await closeIdle();
    return acquire();
  }

  /// Close failures retain ownership: never guess that the card is free.
  static Future<void> closeIdle() async {
    if (_closing != null) return _closing!;
    final close = _owner?._closeIdle;
    if (close == null) return;
    _owner!._closeIdle = null;
    final future = Future<void>.sync(close);
    _closing = future;
    try {
      await future;
    } finally {
      _closing = null;
    }
  }

  void park(Future<void> Function() close) {
    if (!active) throw StateError('Session CPS non disponible.');
    _closeIdle = close;
  }

  void resume() {
    if (!active || _closeIdle == null || _closing != null) {
      throw StateError('Session CPS non disponible.');
    }
    _closeIdle = null;
  }

  void release() {
    if (active) _owner = null;
    _closeIdle = null;
  }
}
