import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatUtils {
  static String formatIsoDateForDisplay(BuildContext context, String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) {
      return '';
    }

    try {
      final locale = Localizations.localeOf(context);
      final formatter = DateFormat.yMd(locale.toLanguageTag());

      final date = DateTime.parse(isoDate);

      return formatter.format(date);
    } catch (_) {
      return isoDate;
    }
  }

  static String formatTimestampForDisplay(
    BuildContext context,
    int? timestamp,
  ) {
    if (timestamp == null) return '';

    try {
      final locale = Localizations.localeOf(context);

      final formatter = DateFormat.yMd(locale.toLanguageTag());

      return formatter.format(DateTime.fromMillisecondsSinceEpoch(timestamp));
    } catch (_) {
      return timestamp.toString();
    }
  }

  static String formatTimestamp(BuildContext context, int? timestamp) {
    if (timestamp == null) return 'Non renseigné';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final locale = Localizations.localeOf(context);

    return DateFormat.yMd(locale.toLanguageTag()).add_Hm().format(date);
  }
}
