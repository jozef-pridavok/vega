/// Get and Set json values by key path
class JsonByPath {
  String splitChar;

  JsonByPath([this.splitChar = "."]);

  /// get value from an existing key by path
  /// returns null if some key does not exists
  T? getValue<T>(Map<String, dynamic> target, String? keyPath, [T? defValue]) {
    if (keyPath == null || keyPath.isEmpty) {
      return target as T;
    }
    List<String> keys = _split(keyPath);

    for (var i = 0; i < keys.length; i++) {
      final String key = keys[i];

      if (!target.containsKey(key)) {
        break;
      }

      if (i == keys.length - 1) {
        try {
          return target[key] as T;
        } on Exception catch (e) {
          print(e);
          return defValue;
        }
      }
      target = target[key];
    }

    return defValue;
  }

  Map<String, dynamic> delete(Map<String, dynamic> target, String keyPath) {
    return setValue(target, keyPath, null);
  }

  /// write value inside a key
  /// if key does not exists, it will be created
  Map<String, dynamic> setValue(Map<String, dynamic> target, String keyPath, dynamic value) {
    List<String> keys = _split(keyPath);

    Map<String, dynamic> origin = target;

    for (var i = 0; i < keys.length; i++) {
      String key = keys[i];
      bool end = (i == keys.length - 1);

      if (!target.containsKey(key)) {
        target[key] = end ? value : <String, dynamic>{};
        if (end) {
          break;
        }
      }

      if (end) {
        target[key] = value;
        break;
      }

      if (target[key] is! Map<String, dynamic>) {
        // to continue iterating, the key MUST be a map, not a value
        // change the key to a map, losing its value
        target[key] = <String, dynamic>{};
      }
      target = target[key];
    }

    return origin;
  }

  List<String> _split(String path) {
    return path.split(splitChar);
  }
}

// eof
