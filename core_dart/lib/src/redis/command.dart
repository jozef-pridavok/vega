import "client.dart";
import "types.dart";

///
/// The most basic form of a RESP command.
///
class RedisCommand {
  final RedisClient client;

  RedisCommand(this.client);

  ///
  /// Writes an array of bulk strings to the [outputSink]
  /// of the underlying server connection and reads back
  /// the Redis type of the response.
  ///
  /// All elements of [elements] are converted to bulk
  /// strings by using to Object.toString().
  ///
  Future<RedisType> execute(List<Object?> elements) async {
    return client.writeType(RedisArray(elements.map((e) => RedisBulkString(e?.toString())).toList(growable: false)));
  }
}

// eof
