import "package:hive/hive.dart";

import "device.dart";

class HiveDeviceRepository implements DeviceRepository {
  static const String _deviceBoxKey = "0dbbf9ec-7241-49d3-9b71-38f218dc542d";
  static const String _cacheKeysBoxKey = "f09aea14-0f0d-452a-bd28-792049538aae";

  static late Box _deviceBox;
  static late Box _cacheKeysBox;

  static late HiveDeviceRepository _instance;

  HiveDeviceRepository._();

  static Future<void> init() async {
    _deviceBox = await Hive.openBox(_deviceBoxKey);
    _cacheKeysBox = await Hive.openBox(_cacheKeysBoxKey);
    _instance = HiveDeviceRepository._();
  }

  static Future<void> reset() async {
    await Hive.deleteBoxFromDisk(_deviceBoxKey);
    await Hive.deleteBoxFromDisk(_cacheKeysBoxKey);
  }

  factory HiveDeviceRepository() => _instance;

  @override
  dynamic get(DeviceKey key) => _deviceBox.get(key.value);

  @override
  void put(DeviceKey key, dynamic value) => _deviceBox.put(key.value, value);

  @override
  void clearDevice() {
    _deviceBox.clear();
    _deviceBox.flush();
  }

  @override
  void clearCacheKeys() {
    _cacheKeysBox.clear();
    _cacheKeysBox.flush();
  }

  @override
  void clearAll() {
    _deviceBox.clear();
    _deviceBox.flush();
    _cacheKeysBox.clear();
    _cacheKeysBox.flush();
  }

  @override
  getCacheKey(String key) => _cacheKeysBox.get(key);

  @override
  void putCacheKey(String key, value) => _cacheKeysBox.put(key, value);
}

// eof
