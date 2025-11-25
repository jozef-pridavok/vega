import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

mixin SmtpConfig {
  late String smtpHost;
  late String smtpFrom;
  late String smtpUsername;
  late String smtpPassword;
  late int smtpPort;
  late bool smtpUseSsl;
}

mixin CronConfig {
  late String updateCurrencyRatesCron;
  late String deliveryMessagesCron;
  late String clientPaymentsCron;
  late String notifyReservationsCron;
}

mixin ApnConfig {
  late String apnKeyId;
  late String apnTeamId;
  late String apnPrivateKey;
}

mixin FcmConfig {
  late String pushServiceUrl;
  late String pushServiceApiKey;
}

class CronApiConfig extends ApiServerConfig with SmtpConfig, CronConfig, ApnConfig, FcmConfig {
  late final String mobileApiHost;
  late final String storageHost;

  CronApiConfig(YamlConfig yamlConfig) {
    // Cron API konfigurácia

    mobileApiHost = normalizeUrl(yamlConfig.getString("mobile_api_host"));
    storageHost = normalizeUrl(yamlConfig.getString("storage_host"));

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

    // Cron konfigurácia
    updateCurrencyRatesCron = yamlConfig.getNestedString("cron", "update_currency_rates");
    deliveryMessagesCron = yamlConfig.getNestedString("cron", "delivery_messages");
    clientPaymentsCron = yamlConfig.getNestedString("cron", "client_payments");
    notifyReservationsCron = yamlConfig.getNestedString("cron", "notify_reservations");

    // Key konfigurácia
    keyV1 = yamlConfig.getNestedString("keys", "v1");
    //keyV2 = yamlConfig.getNestedString("keys", "v2");

    // SMTP konfigurácia
    smtpHost = yamlConfig.getNestedString("smtp", "host");
    smtpFrom = yamlConfig.getNestedString("smtp", "from");
    smtpUsername = yamlConfig.getNestedString("smtp", "username");
    smtpPassword = yamlConfig.getNestedString("smtp", "password");
    smtpPort = yamlConfig.getNestedInt("smtp", "port");
    smtpUseSsl = yamlConfig.getNestedBool("smtp", "use_ssl");

    // APN konfigurácia
    apnKeyId = yamlConfig.getNestedString("apn", "key_id");
    apnTeamId = yamlConfig.getNestedString("apn", "team_id");
    apnPrivateKey = yamlConfig.getNestedString("apn", "private_key");

    // FCM konfigurácia
    pushServiceUrl = yamlConfig.getNestedString("push", "url");
    pushServiceApiKey = yamlConfig.getNestedString("push", "api_key");
  }
}

// eof
