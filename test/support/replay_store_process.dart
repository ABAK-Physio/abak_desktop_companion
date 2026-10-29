import 'dart:convert';
import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_transfer/simulated_lot_store.dart';

void main(List<String> args) {
  final store = SimulatedLotStore(Directory(args[0]));
  stdout.writeln(
    jsonEncode({
      'state': store.read(args[1]),
      'detail': store.readDetail(args[1]),
      'canReserve': store.begin(args[1]),
    }),
  );
}
