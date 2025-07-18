// lib/services/local_storage_service.dart
import 'package:hive/hive.dart';

class LocalStorageService {
  static Future<void> saveData(
    String boxName,
    String key,
    dynamic value,
  ) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, value);
  }

  static Future<dynamic> getData(String boxName, String key) async {
    final box = await Hive.openBox(boxName);
    return box.get(key);
  }

  static Future<void> deleteData(String boxName, String key) async {
    final box = await Hive.openBox(boxName);
    await box.delete(key);
  }
}
