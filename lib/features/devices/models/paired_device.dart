class PairedDevice {
  final String deviceId;
  final String? practitionerId;
  final String deviceLabel;
  final String? platform;
  final String? publicKey;
  final int pairedAt;
  final int? lastSeenAt;
  final int? archivedAt;

  const PairedDevice({
    required this.deviceId,
    this.practitionerId,
    required this.deviceLabel,
    this.platform,
    this.publicKey,
    required this.pairedAt,
    this.lastSeenAt,
    this.archivedAt,
  });

  factory PairedDevice.fromMap(Map<String, dynamic> map) {
    return PairedDevice(
      deviceId: map['device_id'] as String,
      practitionerId: map['practitioner_id'] as String?,
      deviceLabel: map['device_label'] as String,
      platform: map['platform'] as String?,
      publicKey: map['public_key'] as String?,
      pairedAt: map['paired_at'] as int,
      lastSeenAt: map['last_seen_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
      'practitioner_id': practitionerId,
      'device_label': deviceLabel,
      'platform': platform,
      'public_key': publicKey,
      'paired_at': pairedAt,
      'last_seen_at': lastSeenAt,
      'archived_at': archivedAt,
    };
  }

  bool get isArchived => archivedAt != null;
}