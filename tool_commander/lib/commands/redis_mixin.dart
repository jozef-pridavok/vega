import "package:args/args.dart";
import "package:core_dart/core_redis.dart";

import "../dot_env.dart";

mixin Redis {
  late RedisConnection _connection;
  late RedisCommand _command;

  String getHost(ArgResults? args) => dotenv?.env["translation_redis_host"] ?? args?["translation_redis_host"] ?? "";
  int getPort(ArgResults? args) =>
      int.tryParse(dotenv?.env["translation_redis_port"] ?? args?["translation_redis_port"] ?? "5432") ?? 5432;
  int getDatabase(ArgResults? args) =>
      int.tryParse(dotenv?.env["translation_redis_database"] ?? args?["translation_redis_database"]) ?? 0;

  addRedisOptions(ArgParser parser) {
    parser.addOption("translation_redis_host", help: "Redis host with translations, if .env file is not present");
    parser.addOption("translation_redis_port", help: "Redis port with translations, if .env file is not present");
    parser.addOption("translation_redis_database",
        help: "Redis database with translations, if .env file is not present");
  }

  Future<void> connect(ArgResults? argResults) async {
    final server = RedisServer(getHost(argResults), port: getPort(argResults), timeout: Duration(seconds: 5));
    _connection = await server.connect();
    _command = RedisCommand(RedisClient(_connection));
    await _command.execute(["SELECT", getDatabase(argResults)]);
  }

  Future<void> close() async => _connection.close();

  Future<dynamic> execute(List<Object?> elements) async {
    final res = await _command.execute(elements);
    return res.toDart();
  }
}

// eof
