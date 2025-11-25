import "dart:io";

import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:yaml/yaml.dart";

class MobileApiConfig extends ApiServerConfig with JwtConfig, StorageConfig, SecretConfig, WhatsappConfig {
  late final String cronApiHost;
  late final String mobileApiHost;

  MobileApiConfig(YamlConfig yamlConfig) {
    // Mobile API konfigurácia
    mobileApiHost = normalizeUrl(yamlConfig.getString("mobile_api_host"));
    cronApiHost = normalizeUrl(yamlConfig.getString("cron_api_host"));

    // Host konfigurácia
    host = yamlConfig.getString("host");
    port = yamlConfig.getInt("port");
    environment = FlavorCode.fromCode(yamlConfig.getString("environment"));
    build = yamlConfig.getInt("build");
    localPath = yamlConfig.getString("local_path");

    // LogLevel konfigurácia

    logLevelConfiguration = LogLevelConfiguration(
      error: yamlConfig.getNestedBool("log", "error"),
      warning: yamlConfig.getNestedBool("log", "warning"),
      debug: yamlConfig.getNestedBool("log", "debug"),
      verbose: yamlConfig.getNestedBool("log", "verbose"),
    );

    // Redis konfigurácia
    redisHost = yamlConfig.getNestedString("redis", "host");
    redisPort = yamlConfig.getNestedInt("redis", "port");
    redisUseSsl = yamlConfig.getNestedBoolOr("redis", "use_ssl", false);
    if (redisUseSsl) {
      redisUsername = yamlConfig.getNestedString("redis", "username");
      redisPassword = yamlConfig.getNestedString("redis", "password");
    }
    redisDatabase = yamlConfig.getNestedInt("redis", "database");

    // Postgres konfigurácia
    postgresHost = yamlConfig.getNestedString("postgres", "host");
    postgresPort = yamlConfig.getNestedInt("postgres", "port");
    postgresSslMode = yamlConfig.getNestedStringOr("postgres", "ssl_mode", "disabled");
    postgresUsername = yamlConfig.getNestedString("postgres", "username");
    postgresPassword = yamlConfig.getNestedString("postgres", "password");
    postgresDatabase = yamlConfig.getNestedString("postgres", "database");

    // JWT konfigurácia
    secretJwt = yamlConfig.getNestedString("security", "jwt_secret");
    jwtAccessTokenExpirationMinutes = yamlConfig.getNestedInt("security", "jwt_access_token_expiration_minutes");
    jwtRefreshTokenExpirationDays = yamlConfig.getNestedInt("security", "jwt_refresh_token_expiration_days");

    // Secret konfigurácia
    secretReceiptKey = yamlConfig.getNestedString("security", "receipt_password");
    secretQrCodeKey = yamlConfig.getNestedString("security", "qr_code_key");
    secretQrCodeEnv = yamlConfig.getNestedString("security", "qr_code_env");

    // Key konfigurácia
    keyV1 = yamlConfig.getNestedString("keys", "v1");
    //keyV2 = yamlConfig.getNestedString("keys", "v2");

    // Storage konfigurácia
    storagePath = yamlConfig.getNestedString("storage", "path");
    storageUrl = yamlConfig.getNestedString("storage", "url");
    storageDev2Local = yamlConfig.getNestedStringOr("storage", "dev2local", "");

    // Whatsapp konfigurácia
    whatsappClientId = yamlConfig.getNestedString("whatsapp", "client_id");
    whatsappClientSecret = yamlConfig.getNestedString("whatsapp", "client_secret");
    whatsappConfigId = yamlConfig.getNestedString("whatsapp", "config_id");
  }
}

class YamlConfiguration extends Configuration {
  static YamlConfiguration? _singleton;

  @override
  late String host;
  @override
  late int port;
  @override
  late Flavor environment;
  @override
  late int build;
  @override
  late String localPath;

  @override
  late String cronApiHost; // for mobile api

  @override
  late String mobileApiHost; // for cron api

  @override
  late String redisHost;
  @override
  late int redisPort;
  @override
  late String redisUsername;
  @override
  late String redisPassword;
  @override
  late bool redisUseSsl;
  @override
  late int redisDatabase;

  @override
  late String postgresHost;
  @override
  late int postgresPort;
  @override
  late String postgresSslMode;
  @override
  late String postgresUsername;
  @override
  late String postgresPassword;
  @override
  late String postgresDatabase;

  @override
  late String storagePath;
  @override
  late String storageUrl;
  @override
  late String storageDev2Local;

  @override
  late String secretReceiptKey;
  @override
  late String secretQrCodeKey;
  @override
  late String secretQrCodeEnv;

  @override
  late bool logDebug;
  @override
  late bool logError;
  @override
  late bool logVerbose;
  @override
  late bool logWarning;

  @override
  late String keyV1;
  @override
  late String keyV2;

  @override
  late String trdJesoftKey;
  @override
  late List<String> trdJesoftAddresses;

  @override
  late String secretJwt;
  @override
  late int jwtAccessTokenExpirationMinutes;
  @override
  late int jwtRefreshTokenExpirationDays;

  @override
  late String whatsappClientId;
  @override
  late String whatsappClientSecret;
  @override
  late String whatsappConfigId;

  YamlConfiguration._();

  factory YamlConfiguration() {
    assert(_singleton != null);
    return _singleton!;
  }

  static Future<YamlConfiguration> fromFile(String fileName) async {
    assert(_singleton == null);

    final content = await File(fileName).readAsString();
    final yaml = loadYaml(content);

    String s1(String key, String def) => cast<String>(yaml[key]) ?? def;
    String s2(String key1, String key2, String def) => cast<String>(yaml[key1]?[key2]) ?? def;
    int i1(String key, int def) => cast<int>(yaml[key]) ?? def;
    int i2(String key1, String key2, int def) => cast<int>(yaml[key1]?[key2]) ?? def;
    bool b1(String key, bool def) => cast<bool>(yaml[key]) ?? def;
    bool b2(String key1, String key2, bool def) => cast<bool>(yaml[key1]?[key2]) ?? def;

    final instance = YamlConfiguration._();
    //
    instance.host = s1("host", "localhost");
    instance.port = i1("port", 8080);
    instance.environment = FlavorCode.fromCode(s1("environment", Flavor.dev.code));
    instance.build = i1("build", 0);
    instance.localPath = s1("local_path", "/app/");

    //

    instance.mobileApiHost = normalizeUrl(s1("mobile_api_host", "http://localhost:8080/"));
    instance.cronApiHost = normalizeUrl(s1("cron_api_host", "http://localhost:8041/"));

    //
    instance.redisHost = s2("redis", "host", "localhost");
    instance.redisPort = i2("redis", "port", 8080);
    instance.redisUseSsl = b2("redis", "use_ssl", false);
    instance.redisUsername = s2("redis", "username", "redis");
    instance.redisPassword = s2("redis", "password", "redis");
    instance.redisDatabase = i2("redis", "database", 0);
    //
    instance.postgresHost = s2("postgres", "host", "localhost");
    instance.postgresPort = i2("postgres", "port", 5432);
    instance.postgresUsername = s2("postgres", "username", "postgres");
    instance.postgresPassword = s2("postgres", "password", "postgres");
    instance.postgresDatabase = s2("postgres", "database", "postgres");
    // allow prefer, disable, require, verify-ca, verify-full
    instance.postgresSslMode = s2("postgres", "ssl_mode", "prefer");
    //
    instance.storagePath = s2("storage", "path", "");
    instance.storageUrl = s2("storage", "url", "");
    instance.storageDev2Local = s2("storage", "dev2local", "");

    //
    instance.secretReceiptKey = s2("security", "receipt_password", "");
    instance.secretQrCodeKey = s2("security", "qr_code_key", "");
    instance.secretQrCodeEnv = s2("security", "qr_code_env", "");
    instance.secretJwt = s2("security", "jwt_secret", "");
    instance.jwtAccessTokenExpirationMinutes = i2("security", "jwt_access_token_expiration_minutes", 120);
    instance.jwtRefreshTokenExpirationDays = i2("security", "jwt_refresh_token_expiration_days", 365);
    //
    instance.logError = b2("log", "error", false);
    instance.logWarning = b2("log", "warning", false);
    instance.logDebug = b2("log", "debug", false);
    instance.logVerbose = b2("log", "verbose", false);
    //
    instance.keyV1 = s2("keys", "v1", "undefined");
    instance.keyV2 = s2("keys", "v2", "undefined");
    //
    instance.trdJesoftKey = s2("3rd", "jesoft_key", "undefined");
    instance.trdJesoftAddresses = s2("3rd", "addresses", "").split(",").map((e) => e.trim()).toList();

    instance.whatsappClientId = s2("whatsapp", "client_id", "");
    instance.whatsappClientSecret = s2("whatsapp", "client_secret", "");
    instance.whatsappConfigId = s2("whatsapp", "config_id", "");

    _singleton = instance;
    return instance;
  }

  // Cron API

  @override
  String get pushServiceApiKey => throw UnimplementedError();

  @override
  String get pushServiceUrl => throw UnimplementedError();

  @override
  String get smtpFrom => throw UnimplementedError();

  @override
  String get smtpHost => throw UnimplementedError();

  @override
  String get smtpPassword => throw UnimplementedError();

  @override
  int get smtpPort => throw UnimplementedError();

  @override
  bool get smtpUseSsl => throw UnimplementedError();

  @override
  String get smtpUsername => throw UnimplementedError();

  @override
  String get apnKeyId => throw UnimplementedError();

  @override
  String get apnPrivateKey => throw UnimplementedError();

  @override
  String get apnTeamId => throw UnimplementedError();
}

// eof
