import "dart:async";

///
/// A connection to a RESP server. It has to provide an
/// [outputSink] and an [inputStream]. The [outputSink]
/// is used by [RespClient] to write requests to the
/// server. The [inputStream] is used by [RespClient]
/// to read responses from the server.
///
abstract class RedisConnection {
  StreamSink<List<int>> get outputSink;

  Stream<List<int>> get inputStream;

  Future<void> close();
}
