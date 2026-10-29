import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_transfer/simulated_lot_store.dart';

void main(List<String> args) {
  final store = SimulatedLotStore(Directory(args[0]));
  const id = 'simulation-process';
  if (args[1] == 'attempt') {
    stdout.writeln(
      store.begin(id),
    ); // Exit without a receipt: simulated abrupt stop.
  } else if (args[1] == 'finish') {
    store.finish(id, args[2]);
  } else {
    stdout.writeln(store.read(id));
    stdout.writeln(store.begin(id));
  }
}
