import 'package:shared_preferences/shared_preferences.dart';

class PatientArchiveSettingsService {
  static const int defaultRetentionDays = 30;

  static const String _retentionDaysKey =
      'patient_archive_retention_days';

  static const List<int> retentionOptions = [
    30,
    60,
    90,
    120,
    180,
    365,
  ];

  Future<int> getRetentionDays() async {
    final preferences = await SharedPreferences.getInstance();

    final savedValue = preferences.getInt(_retentionDaysKey);

    if (savedValue == null ||
        !retentionOptions.contains(savedValue)) {
      return defaultRetentionDays;
    }

    return savedValue;
  }

  Future<void> setRetentionDays(int days) async {
    if (!retentionOptions.contains(days)) {
      throw ArgumentError.value(
        days,
        'days',
        'Durée de conservation non autorisée.',
      );
    }

    final preferences = await SharedPreferences.getInstance();

    await preferences.setInt(
      _retentionDaysKey,
      days,
    );
  }
}