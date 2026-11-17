import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:abak_desktop_companion/core/maintenance/application_shutdown.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Quit waits for startup, drains every resource, and coalesces requests',
    () async {
      final ready = Completer<void>();
      final order = <String>[];
      final shutdown = ApplicationShutdown(
        ready: ready.future,
        isBusy: () => false,
        onBusy: () => fail('not busy'),
        steps: [
          () async {
            order.add('server');
            throw StateError('stop failed');
          },
          () async {
            order.add('watcher');
          },
          () async {
            order.add('database');
          },
          () async {
            order.add('lock');
          },
        ],
      );
      final first = shutdown.prepareToQuit();
      final second = shutdown.prepareToQuit();
      expect(identical(first, second), isTrue);
      expect(order, isEmpty);
      ready.complete();
      expect(await first, isTrue);
      expect(order, ['server', 'watcher', 'database', 'lock']);
    },
  );
  test(
    'active backup cancels quit without closing data; retry succeeds',
    () async {
      var busy = true, notified = false, closed = false;
      final shutdown = ApplicationShutdown(
        ready: Future.value(),
        isBusy: () => busy,
        onBusy: () {
          notified = true;
        },
        steps: [
          () async {
            closed = true;
          },
        ],
      );
      expect(await shutdown.prepareToQuit(), isFalse);
      expect(notified, isTrue);
      expect(closed, isFalse);
      busy = false;
      expect(await shutdown.prepareToQuit(), isTrue);
      expect(closed, isTrue);
    },
  );
  test(
    'native prepareToQuit message receives an explicit allowed reply',
    () async {
      var closed = false;
      ApplicationShutdown(
        ready: Future.value(),
        isBusy: () => false,
        onBusy: () {},
        steps: [
          () async {
            closed = true;
          },
        ],
      ).register();
      final reply = Completer<Object?>();
      const codec = StandardMethodCodec();
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'abak/application_lifecycle',
            codec.encodeMethodCall(const MethodCall('prepareToQuit')),
            (data) {
              reply.complete(codec.decodeEnvelope(data!));
            },
          );
      expect(await reply.future, isTrue);
      expect(closed, isTrue);
      ApplicationShutdown.channel.setMethodCallHandler(null);
    },
  );
}
