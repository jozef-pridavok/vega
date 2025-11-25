import "dart:async";
import "dart:collection";

import "connection.dart";
import "stream_reader.dart";
import "types.dart";

///
/// The client for a RESP server.
///
class RedisClient {
  final RedisConnection _connection;
  final RedisStreamReader _streamReader;
  final Queue<Completer> _pendingResponses = Queue();
  bool _isProccessingResponse = false;

  RedisClient(this._connection) : _streamReader = RedisStreamReader(_connection.inputStream);

  ///
  /// Writes a RESP type to the server using the
  /// [outputSink] of the underlying server connection and
  /// reads back the RESP type of the response using the
  /// [inputStream] of the underlying server connection.
  ///
  Future<RedisType> writeType(RedisType data) {
    final completer = Completer<RedisType>();
    _pendingResponses.add(completer);
    _connection.outputSink.add(data.serialize());
    _processResponse(false);
    return completer.future;
  }

  Stream<RedisType> subscribe() {
    final controller = StreamController<RedisType>();
    deserializeRespType(_streamReader).then((response) {
      controller.add(response);
    });
    return controller.stream;
  }

  void _processResponse(bool selfCall) {
    if (_isProccessingResponse == false || selfCall) {
      if (_pendingResponses.isNotEmpty) {
        _isProccessingResponse = true;
        final c = _pendingResponses.removeFirst();
        deserializeRespType(_streamReader).then((response) {
          c.complete(response);
          _processResponse(true);
        });
      } else {
        _isProccessingResponse = false;
      }
    }
  }
}
