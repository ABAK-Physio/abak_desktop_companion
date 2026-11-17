import 'dart:convert';
import 'dart:io';

// Fake framed worker: no package, native library, card or network.
Future<void> main(List<String> args) async {
  final mode = args.single;
  await for (final line
      in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    final parts = line.split('\t');
    final id = parts.first;
    final operation = parts[1];
    if (operation == 'close') {
      stdout.write('$id\tOK${mode == 'lf' ? '\n' : '\r\n'}');
      await stdout.flush();
      return;
    }
    stderr.writeln('SYNTHETIC_DIAGNOSTIC_DISCARDED');
    final cwd = base64Encode(utf8.encode(Directory.current.path));
    final value = parts.skip(2).single.split('=').skip(1).join('=');
    final response = mode == 'bad-cr'
        ? '$id\tO\rK'
        : '$id\tOK\tcwd=$cwd\techo=$value';
    stdout.write('$response${mode == 'lf' ? '\n' : '\r\n'}');
    await stdout.flush();
    if (mode == 'bad-cr') return;
  }
}
