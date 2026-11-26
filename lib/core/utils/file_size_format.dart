import 'package:intl/intl.dart';

/// Presentation only. Unit thresholds use the original integer byte count.
/// Callers supply localized labels for bytes, KiB, MiB, GiB and TiB.
String formatBinaryFileSize(
  int bytes, {
  required String locale,
  required List<String> units,
}) {
  if (bytes < 0) throw ArgumentError.value(bytes, 'bytes');
  if (units.length != 5) throw ArgumentError.value(units, 'units');
  var unit = 0, divisor = 1;
  while (unit < 4 && bytes >= divisor * 1024) {
    unit++;
    divisor *= 1024;
  }
  final value = unit == 0 ? bytes : bytes / divisor;
  return '${NumberFormat('#,##0.#', locale).format(value)} ${units[unit]}';
}
