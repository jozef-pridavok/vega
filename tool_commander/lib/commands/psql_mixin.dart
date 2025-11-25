import "package:args/args.dart";
import "package:postgres_pool/postgres_pool.dart";

import "../dot_env.dart";

mixin Psql {
  late PgPool _pgPool;

  String getHost(ArgResults? args) => dotenv?.env["postgres_host"] ?? args?["postgres_host"] ?? "";
  int getPort(ArgResults? args) =>
      int.tryParse(dotenv?.env["postgres_port"] ?? args?["postgres_port"] ?? "5432") ?? 5432;
  String getDatabase(ArgResults? args) => dotenv?.env["postgres_database"] ?? args?["postgres_database"] ?? "";
  String? getUsername(ArgResults? args) => dotenv?.env["postgres_username"] ?? args?["postgres_username"];
  String? getPassword(ArgResults? args) => dotenv?.env["postgres_password"] ?? args?["postgres_password"];
  String? getSslMode(ArgResults? args) => dotenv?.env["postgres_ssl_mode"] ?? args?["postgres_ssl_mode"];

  addPostgresOptions(ArgParser parser) {
    parser.addOption("postgres_host", help: "Postgres host, if .env file is not present");
    parser.addOption("postgres_port", help: "Postgres port, if .env file is not present");
    parser.addOption("postgres_database", help: "Postgres database, if .env file is not present");
    parser.addOption("postgres_username", help: "Postgres username, if .env file is not present");
    parser.addOption("postgres_password", help: "Postgres password, if .env file is not present");
    parser.addOption("postgres_ssl_mode", help: "Postgres ssl mode, if .env file is not present", defaultsTo: "prefer");
  }

  Future<void> connect(ArgResults? argResults, {String? url}) async {
    final endPoint = url != null
        ? PgEndpoint.parse(url)
        : PgEndpoint(
            host: getHost(argResults),
            port: getPort(argResults),
            database: getDatabase(argResults),
            username: getUsername(argResults),
            password: getPassword(argResults),
            requireSsl: getSslMode(argResults) == "require",
          );
    _pgPool = PgPool(
      endPoint,
      settings: PgPoolSettings()
        ..maxConnectionAge = Duration(hours: 1)
        ..concurrency = 4,
    );
  }

  Future<void> close() async => _pgPool.close();

  Future<List<Map<String, Map<String, dynamic>>>> select(
    dynamic sql, {
    Map<String, dynamic>? params,
  }) {
    final res = _pgPool.run(
      (c) => c.mappedResultsQuery(sql, substitutionValues: params),
    );
    return res;
  }
}

// eof
