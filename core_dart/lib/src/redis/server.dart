import "dart:io";

import "connection.dart";

// https://pub.dev/packages/resp_client

class _SocketRedisServer implements RedisConnection {
  final Socket socket;

  _SocketRedisServer(this.socket);

  @override
  IOSink get outputSink {
    return socket;
  }

  @override
  Stream<List<int>> get inputStream {
    return socket;
  }

  @override
  Future<void> close() async {
    await socket.flush();
    return socket.close();
  }
}

class RedisServer {
  final String host;
  final int port;
  final Duration? timeout;

  RedisServer(this.host, {this.port = 6379, this.timeout});

  Future<RedisConnection> connect() async {
    final socket = await Socket.connect(host, port, timeout: timeout);
    return _SocketRedisServer(socket);
  }

  Future<RedisConnection> connectSecure() async {
    final socket = await SecureSocket.connect(host, port, timeout: timeout);
    return _SocketRedisServer(socket);
  }
}

// eof
