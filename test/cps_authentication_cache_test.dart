import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/cps/cps_operation_lease.dart';
import 'package:abak_desktop_companion/features/cps/cps_profile.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/authentication_cache.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/bridge.dart';

class Worker implements DmpNativeBridge {
  bool closed = false, absent = false, closeFails = false;
  final calls = <String>[];
  Completer<void>? closing, probe;
  @override
  Future<Map<String, String>> call(
    String operation,
    Map<String, String> fields,
  ) async {
    calls.add(operation);
    expectSync(fields, isEmpty); // probes must contain neither PIN nor patient data
    await probe?.future;
    if (absent) throw DmpNativeFailure('CPS_ABSENT');
    return {'professional': 'michel'};
  }

  @override
  Future<void> close() async {
    await closing?.future;
    if (closeFails) throw StateError('close failed');
    closed = true;
  }
}

void main() {
  const profile = CpsProfile(
    nationalId: 'michel',
    familyName: 'TEST',
    givenName: 'MICHEL',
    professionCode: 70,
    cardType: 0,
    situations: [],
  );
  final date = DateTime.utc(2026, 10, 27);
  RetainedCpsAuthentication entry(
    Worker worker, {
    void Function()? checkContext,
  }) => RetainedCpsAuthentication(
    key: 'config:worker',
    profile: profile,
    bridge: worker,
    lease: CpsOperationLease.acquire(),
    expires: date.add(const Duration(hours: 1)),
    checkContext: checkContext ?? () {},
  );
  tearDown(() async => CpsOperationLease.closeIdle());

  test(
    'reuse transfers exclusive ownership without reading card or PIN',
    () async {
      final cache = CpsAuthenticationCache(now: () => date);
      final worker = Worker();
      cache.retain(entry(worker));
      expect(CpsOperationLease.inUse, isFalse);
      expect(cache.canReuse('config:worker', 'michel'), isTrue);
      expect(cache.canReuse('config:worker', 'marie'), isFalse);
      expect(() => CpsOperationLease.acquire(), throwsStateError);
      final retained = (await cache.take('config:worker'))!;
      expect(CpsOperationLease.inUse, isTrue);
      expect(cache.canReuse('config:worker', 'michel'), isFalse);
      expect(worker.calls, isEmpty);
      expect(worker.closed, isFalse);
      await retained.bridge.close();
      retained.lease.release();
    },
  );

  test(
    'another card feature awaits full closure before acquiring card',
    () async {
      final cache = CpsAuthenticationCache(now: () => date);
      final worker = Worker()..closing = Completer<void>();
      cache.retain(entry(worker));
      var acquired = false;
      final acquisition = CpsOperationLease.acquireAvailable().then((lease) {
        acquired = true;
        return lease;
      });
      await Future<void>.delayed(Duration.zero);
      expect(acquired, isFalse);
      expect(CpsOperationLease.inUse, isTrue);
      worker.closing!.complete();
      final lease = await acquisition;
      expect(worker.closed, isTrue);
      expect(acquired, isTrue);
      lease.release();
    },
  );

  test('changed configuration discards authentication', () async {
    final cache = CpsAuthenticationCache(now: () => date);
    final worker = Worker();
    cache.retain(entry(worker));
    expect(await cache.take('different'), isNull);
    expect(worker.closed, isTrue);
    expect(CpsOperationLease.inUse, isFalse);
  });

  test('expiry or backward clock never extends authentication', () async {
    for (final delta in [
      const Duration(hours: 1),
      const Duration(seconds: -1),
    ]) {
      var clock = date;
      final cache = CpsAuthenticationCache(now: () => clock);
      final worker = Worker();
      cache.retain(entry(worker));
      clock = date.add(delta);
      expect(cache.canReuse('config:worker', 'michel'), isFalse);
      expect(await cache.take('config:worker'), isNull);
      expect(worker.closed, isTrue);
    }
  });

  test(
    'lock immediately invalidates and closes the retained authentication',
    () async {
      final context = DmpWorkContext.current
        ..setEnabled(true)
        ..select('michel');
      final worker = Worker();
      final cache = CpsAuthenticationCache(now: () => date);
      cache.retain(entry(worker, checkContext: context.bind('michel')));
      context.lock();
      expect(cache.canReuse('config:worker', 'michel'), isFalse);
      await CpsOperationLease.closeIdle();
      expect(worker.closed, isTrue);
      context.setEnabled(false);
    },
  );

  for (final disable in [false, true]) {
    test(
      disable
          ? 'DMP off closes authentication'
          : 'practitioner switch closes authentication',
      () async {
        final context = DmpWorkContext.current
          ..setEnabled(true)
          ..select('michel');
        final worker = Worker();
        final cache = CpsAuthenticationCache(now: () => date);
        cache.retain(entry(worker, checkContext: context.bind('michel')));
        if (disable) {
          context.setEnabled(false);
        } else {
          context.select('marie');
        }
        expect(cache.canReuse('config:worker', 'michel'), isFalse);
        await CpsOperationLease.closeIdle();
        expect(worker.closed, isTrue);
        context.setEnabled(false);
      },
    );
  }

  testWidgets(
    'another feature waits for a pending local card probe and closure',
    (tester) async {
      final cache = CpsAuthenticationCache(now: () => date);
      final worker = Worker()..probe = Completer<void>();
      cache.retain(entry(worker));
      await tester.pump(const Duration(seconds: 5));
      expect(worker.calls, ['authenticationcheck']);
      var acquired = false;
      final pending = CpsOperationLease.acquireAvailable().then((lease) {
        acquired = true;
        return lease;
      });
      await tester.pump();
      expect(acquired, isFalse);
      worker.probe!.complete();
      await tester.pump();
      final lease = await pending;
      expect(worker.closed, isTrue);
      lease.release();
    },
  );

  testWidgets('withdrawal detected by local probe closes authentication', (
    tester,
  ) async {
    final cache = CpsAuthenticationCache(now: () => date);
    final worker = Worker()..absent = true;
    cache.retain(entry(worker));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(worker.calls, ['authenticationcheck']);
    expect(worker.closed, isTrue);
    expect(cache.canReuse('config:worker', 'michel'), isFalse);
  });

  test('failed worker closure prevents another owner taking card', () async {
    final cache = CpsAuthenticationCache(now: () => date);
    final worker = Worker()..closeFails = true;
    final retained = entry(worker);
    cache.retain(retained);
    await expectLater(CpsOperationLease.closeIdle(), throwsStateError);
    expect(cache.canReuse('config:worker', 'michel'), isFalse);
    expect(CpsOperationLease.inUse, isTrue);
    await expectLater(CpsOperationLease.acquireAvailable(), throwsStateError);
    // Test-only recovery; product deliberately requires restarting Companion.
    worker.closeFails = false;
    await worker.close();
    retained.lease.release();
  });
}
