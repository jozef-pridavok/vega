enum CacheScope { shared, app, sql, log }

class CacheKey {
  final CacheScope scope;
  final String key;

  const CacheKey(this.scope, this.key);

  factory CacheKey.fromString(String key) {
    final parts = key.split(":");
    if (parts.isEmpty) return CacheKey(CacheScope.app, key);
    final scope =
        CacheScope.values.firstWhere((e) => e.toString().split(".").last == parts.first, orElse: () => CacheScope.app);
    return CacheKey(scope, parts.skip(1).join(":"));
  }

  //! CacheKey join(String key) => CacheKey(scope, "$this:$key", expiration: expiration);

  // join key in format: "scope:key1:key2:key3", don't duplicated head.
  // E.g:
  //  CacheKey.shared("key1").join("key2").join("key3") => CacheKey.shared("key1:key2:key3")

  CacheKey join(String key) {
    final keys = this.key.split(":");
    if (keys.isEmpty) return CacheKey(scope, key);
    return CacheKey(scope, "${keys.join(":")}:$key");
  }

  CacheKey all() => CacheKey(scope, "*");

  String get fullKey => "${scope.toString().split('.').last}:$key";

  factory CacheKey.shared(String key) => CacheKey(CacheScope.shared, key);
  factory CacheKey.app(String key) => CacheKey(CacheScope.app, key);
  factory CacheKey.sql(String key) => CacheKey(CacheScope.sql, key);
  factory CacheKey.log(String key) => CacheKey(CacheScope.log, key);

  @override
  String toString() => fullKey;
}

// eof
