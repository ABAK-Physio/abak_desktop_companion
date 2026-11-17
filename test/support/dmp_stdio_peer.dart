import 'dart:convert';
import 'dart:io';

/// Resolve the Dart CLI shipped with the SDK running this test. Flutter tests
/// run in flutter_tester, which is below bin/cache/artifacts/engine.
String dartTestExecutable() {
  final executable = File(Platform.resolvedExecutable).absolute;
  final name = Platform.isWindows ? 'dart.exe' : 'dart';
  if (executable.uri.pathSegments.last == name) return executable.path;
  var directory = executable.parent;
  while (true) {
    final candidate = File.fromUri(directory.uri.resolve('dart-sdk/bin/$name'));
    if (candidate.existsSync()) return candidate.path;
    final parent = directory.parent;
    if (parent.path == directory.path) break;
    directory = parent;
  }
  throw StateError('Dart du SDK Flutter introuvable pour le test stdio.');
}

/// Synthetic framed peer only: no CPS, certificate, network or application data.
void main() async {
  await for (final line
      in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    final parts = line.split('\t');
    if (parts.length < 2) throw const FormatException('Synthetic frame');
    final operation = parts[1];
    stdout.writeln(
      '${parts[0]}\tOK\toperation=${base64Encode(utf8.encode(operation))}',
    );
    await stdout.flush();
    if (operation == 'close') break;
  }
}
