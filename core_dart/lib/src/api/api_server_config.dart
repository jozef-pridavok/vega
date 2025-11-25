import "dart:io";

import "package:yaml/yaml.dart";

import "../../core_dart.dart";

mixin HostConfig {
  late final String host;
  late final int port;
  late final Flavor environment;
  late final int build;
  late final String localPath;
}

mixin LogLevelConfig {
  late final LogLevelConfiguration logLevelConfiguration;
}

mixin RedisConfig {
  late final String redisHost;
  late final int redisPort;
  late final String redisUsername;
  late final String redisPassword;
  late final bool redisUseSsl;
  late final int redisDatabase;
}

mixin PostgresConfig {
  late final String postgresHost;
  late final int postgresPort;
  late final String postgresSslMode;
  late final String postgresUsername;
  late final String postgresPassword;
  late final String postgresDatabase;
}

mixin KeyConfig {
  late final String keyV1;
  late final String keyV2;
}

mixin SecretConfig {
  late final String secretReceiptKey;
  late final String secretQrCodeKey;
  late final String secretQrCodeEnv;
}

mixin JwtConfig {
  late final String secretJwt;
  late final int jwtAccessTokenExpirationMinutes;
  late final int jwtRefreshTokenExpirationDays;
}

mixin StorageConfig {
  late final String storagePath;
  late final String storageUrl;
  late final String storageDev2Local;
}

mixin WhatsappConfig {
  late final String whatsappClientId;
  late final String whatsappClientSecret;
  late final String whatsappConfigId;
}

abstract class ApiServerConfig with HostConfig, LogLevelConfig, PostgresConfig, RedisConfig, KeyConfig, WhatsappConfig {
  bool get isDev => environment == Flavor.dev;
  bool get isQa => environment == Flavor.qa;
  bool get isDemo => environment == Flavor.demo;
  bool get isProd => environment == Flavor.prod;
  bool get isProduction => isProd || isDemo;
  bool get isNotProduction => !isProduction;
}

class YamlConfig {
  final YamlMap yaml;

  YamlConfig._(this.yaml);

  static Future<YamlConfig> fromFile(String fileName) async {
    final content = await File(fileName).readAsString();
    final yaml = loadYaml(content);
    return YamlConfig._(yaml as YamlMap);
  }

  String getString(String key) => yaml[key] is String ? yaml[key]! : throw ArgumentError.notNull("$key: String");
  String getNestedString(String key1, String key2) =>
      yaml[key1][key2] is String ? yaml[key1][key2]! : throw ArgumentError.notNull("$key1.$key2: String");
  String getNestedStringOr(String key1, String key2, String def) => yaml[key1]?[key2] ?? def;
  int getInt(String key) => yaml[key] is int ? yaml[key]! : throw ArgumentError.notNull("$key: int");
  int getNestedInt(String key1, String key2) =>
      yaml[key1]?[key2] is int ? yaml[key1][key2]! : throw ArgumentError.notNull("$key1.$key2: int");
  bool getBool(String key) => yaml[key] is bool ? yaml[key]! : throw ArgumentError.notNull("$key: bool");
  bool getNestedBool(String key1, String key2) =>
      yaml[key1]?[key2] is bool ? yaml[key1][key2]! : throw ArgumentError.notNull("$key1.$key2: bool");
  bool getNestedBoolOr(String key1, String key2, bool def) => yaml[key1]?[key2] ?? def;
}

// eof
