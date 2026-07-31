import 'dart:convert';

class DeviceQrData {
  static const int currentVersion = 1;

  final String organizationId;
  final String organizationName;
  final String deviceId;
  final String deviceLabel;
  final String? platform;

  const DeviceQrData({
    required this.organizationId,
    required this.organizationName,
    required this.deviceId,
    required this.deviceLabel,
    this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'abak_device',
      'version': currentVersion,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'deviceId': deviceId,
      'deviceLabel': deviceLabel,
      'platform': platform,
    };
  }

  String toQrValue() => jsonEncode(toJson());

  factory DeviceQrData.fromJson(Map<String, dynamic> json) {
    return DeviceQrData(
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String,
      deviceId: json['deviceId'] as String,
      deviceLabel: json['deviceLabel'] as String,
      platform: json['platform'] as String?,
    );
  }

  factory DeviceQrData.fromQrValue(String value) {
    return DeviceQrData.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}