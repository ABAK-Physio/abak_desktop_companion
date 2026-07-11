import '../../../core/database/database_service.dart';
import '../models/paired_device.dart';

class DeviceRepository {
  Future<List<PairedDevice>> getActiveDevices() async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'paired_devices',
      where: 'archived_at IS NULL',
      orderBy: 'device_label COLLATE NOCASE ASC',
    );

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

    final rows = await db.query(
      'paired_devices',
      where: 'archived_at IS NOT NULL',
      orderBy: 'archived_at DESC',
    );

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
}
