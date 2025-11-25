import "package:api_mobile/implementations/api_shelf2.dart";
import "package:core_dart/core_redis.dart";

extension MobileApiRedis on MobileApi {
  Future<RedisCommand> connectRedis() async {
    final timeout = Duration(seconds: config.isDev ? 5 : 30);
    final server = RedisServer(config.redisHost, port: config.redisPort, timeout: timeout);
    final connection = config.redisUseSsl ? await server.connectSecure() : await server.connect();

    final client = RedisClient(connection);
    final redisCommand = RedisCommand(client);

    if (config.redisUseSsl) await redisCommand.execute(["AUTH", config.redisUsername, config.redisPassword]);

    await redisCommand.execute(["SELECT", config.redisDatabase]);

    return redisCommand;
  }

  Future<dynamic> executeRedisCommand(RedisCommand command, List<Object?> commands) async {
    /*
    if (config.environment == Flavor.dev || config.environment == Flavor.qa) {
      if (object is! List) {
        log.error("Redis object must be a List");
        return null;
      }
      if (object.isNotEmpty) {
        final first = object.first;
        if (first is! String) {
          log.error("Redis object must start with a String");
          return null;
        }
        if (object.any((item) => item is! String && item is! int)) {
          log.error("Redis object must contain only Strings and Integers");
          return null;
        }
      }
    }
    */
    try {
      //if (config.environment == Flavor.dev) print("Redis: $object");
      final result = await command.execute(commands);
      //if (config.environment == Flavor.dev) print("  $result");
      return result.toDart();
    } catch (ex, _) {
      log.error(ex.toString());
      rethrow;
    }
  }

  Future<bool> redisVersion({bool debug = false}) async {
    try {
      final info = (await redis(["INFO", "SERVER"])) as String;
      final lines = info.split("\n");
      final line = lines.firstWhere((line) => line.startsWith("redis_version:"));
      final version = line.split(":")[1].trim(); // e.g. 7.0.10
      if (debug) log.verbose("Redis version: $version");
      return version.isNotEmpty;
    } catch (ex) {
      log.warning("Failed to get Redis version: $ex");
      return false;
    }
  }
}
