import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_session/inactivity_lock.dart';

void main() {
  testWidgets('real activity resets delay; stop cancels expiry', (
    tester,
  ) async {
    int locks = 0;
    final timer = InactivityLock(
      onExpired: () => locks++,
      now: tester.binding.clock.now,
    );
    timer.start(const Duration(minutes: 15));
    await tester.pump(const Duration(minutes: 14));
    timer.activity();
    await tester.pump(const Duration(minutes: 14));
    expect(locks, 0);
    await tester.pump(const Duration(minutes: 1));
    expect(locks, 1);
    timer.start(const Duration(minutes: 5));
    timer.stop();
    await tester.pump(const Duration(hours: 1));
    expect(locks, 1);
  });

  testWidgets('resume checks elapsed time even before a timer is delivered', (
    tester,
  ) async {
    var now = DateTime.utc(2026);
    int locks = 0;
    final timer = InactivityLock(onExpired: () => locks++, now: () => now);
    timer.start(const Duration(minutes: 15));
    now = now.add(const Duration(hours: 2));
    timer.check();
    expect(locks, 1);
    timer.check();
    expect(locks, 1);
    timer.stop();
  });
}
