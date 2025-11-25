enum DeviceKey {
  installationId,
  user,
  accessToken,
  refreshToken,
  deviceToken,
  userSyncedRemotely,
  isWizardShowed,
  client,
}

extension DeviceKeyExtension on DeviceKey {
  String get value => toString().split(".").last;
}

abstract class DeviceRepository {
  dynamic get(DeviceKey key);
  void put(DeviceKey key, dynamic value);

  dynamic getCacheKey(String key);
  void putCacheKey(String key, dynamic value);

  void clearDevice();
  void clearCacheKeys();
  void clearAll();
}

// eof
