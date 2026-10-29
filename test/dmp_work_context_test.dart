import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';

void main() {
  test('selection is required and another practitioner cannot start DMP', () {
    final context = DmpWorkContext();
    expect(() => context.bind('michel'), throwsStateError);
    context.setEnabled(true);
    expect(() => context.bind('michel'), throwsStateError);
    context.select(null);
    expect(() => context.bind('michel'), throwsStateError);
    context.select('michel');
    expect(() => context.bind('marie'), throwsStateError);
    context.bind('michel')();
  });

  test(
    'lock and unlock cannot revive an operation prepared before locking',
    () {
      final context = DmpWorkContext()
        ..setEnabled(true)
        ..select('michel');
      final operation = context.bind('michel');
      context.lock();
      expect(operation, throwsStateError);
      expect(() => context.unlock('marie'), throwsStateError);
      expect(operation, throwsStateError);
      context.unlock('michel');
      expect(operation, throwsStateError);
      context.bind('michel')();
    },
  );

  test('switch and disabling invalidate pending operations permanently', () {
    final context = DmpWorkContext()
      ..setEnabled(true)
      ..select('michel');
    final operation = context.bind('michel');
    context.select('marie');
    expect(operation, throwsStateError);
    context.select('michel');
    expect(operation, throwsStateError);
    final next = context.bind('michel');
    context.setEnabled(false);
    expect(next, throwsStateError);
    context.setEnabled(true);
    expect(() => context.bind('michel'), throwsStateError);
  });
}
