import '../../../core/database/database_service.dart';
import '../models/paired_device.dart';

class DeviceRepository {
  Future<List<PairedDevice>> getActiveDevices() async {
    final db = await DatabaseService.database;

    final rows = await db.rawQuery('''
      SELECT d.*, p.display_name AS practitioner_display_name
      FROM paired_devices d
      LEFT JOIN practitioners p ON p.practitioner_id = d.practitioner_id
      WHERE d.archived_at IS NULL
      ORDER BY d.device_label COLLATE NOCASE ASC
    ''');

    return rows.map(PairedDevice.fromMap).toList();
  }

  Future<void> insertDevice(PairedDevice device) async {
    final db = await DatabaseService.database;

    await db.insert('paired_devices', device.toMap());
  }

  Future<void> archiveDevice(String deviceId) async {
    final db = await DatabaseService.database;

    await db.update(
      'paired_devices',
      {'archived_at': DateTime.now().millisecondsSinceEpoch},
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  Future<List<PairedDevice>> getArchivedDevices() async {
    final db = await DatabaseService.database;

    final rows = await db.rawQuery('''
      SELECT d.*, p.display_name AS practitioner_display_name
      FROM paired_devices d
      LEFT JOIN practitioners p ON p.practitioner_id = d.practitioner_id
      WHERE d.archived_at IS NOT NULL
      ORDER BY d.archived_at DESC
    ''');

    return rows.map(PairedDevice.fromMap).toList();
  }

  Future<void> restoreDevice(String deviceId) async {
    final db = await DatabaseService.database;

    await db.update(
      'paired_devices',
      {'archived_at': null},
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  Future<void> updateDevice(PairedDevice device) async {
    final db = await DatabaseService.database;

    await db.update(
      'paired_devices',
      device.toMap(),
      where: 'device_id = ?',
      whereArgs: [device.deviceId],
    );
  }
}
