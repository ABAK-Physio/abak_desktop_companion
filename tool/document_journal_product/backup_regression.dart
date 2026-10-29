// ignore_for_file: depend_on_referenced_packages, implementation_imports
import 'dart:io';
import 'dart:convert';
import 'package:test_api/src/backend/declarer.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/test.dart';
import 'package:test_api/src/backend/suite.dart';
import 'package:test_api/src/backend/suite_platform.dart';
import 'package:test_api/src/backend/runtime.dart';
import 'package:test_api/src/backend/operating_system.dart';
import 'package:test_api/src/backend/state.dart';
import '../../test/patient_backup_restore_test.dart' as tests;

Future<void> main() async {
  final results = <Map<String, Object?>>[];
  final declarer = Declarer();
  declarer.declare(tests.main);
  final suite = Suite(
    declarer.build(),
    SuitePlatform(Runtime.vm, os: OperatingSystem.macOS),
  );
  Future<void> run(Test test, List<Group> groups) async {
    final live = test.load(suite, groups: groups);
    live.onError.listen((e) => stderr.writeln(e));
    await live.run();
    final ok = live.state.result == Result.success;
    results.add({
      'name': test.name,
      'ok': ok,
      'errors': live.errors.map((e) => e.toString()).toList(),
    });
    stdout.writeln('${ok ? 'PASS' : 'FAIL'} ${test.name}');
    await live.close();
  }

  Future<void> group(Group g, List<Group> parents) async {
    final groups = [...parents, g];
    if (g.setUpAll != null) await run(g.setUpAll!, groups);
    for (final e in g.entries) {
      if (e is Group) {
        await group(e, groups);
      } else {
        await run(e as Test, groups);
      }
    }
    if (g.tearDownAll != null) await run(g.tearDownAll!, groups);
  }

  await group(suite.group, []);
  File(
    '${Platform.environment['JOURNAL_TEST_OUTPUT']}/result.json',
  ).writeAsStringSync(
    const JsonEncoder.withIndent(
      '  ',
    ).convert({'count': results.length, 'results': results}),
  );
  exit(results.every((r) => r['ok'] == true) ? 0 : 1);
}
