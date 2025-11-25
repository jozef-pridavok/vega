import "dart:async";
import "dart:io";

import "package:core_flutter/core_app.dart";
import "package:flutter/foundation.dart";

Future<bool> isApiAvailable({String? host, int? port, Duration timeout = const Duration(seconds: 3)}) async {
  // TODO: issue on Web
  // https://github.com/RounakTadvi/internet_connection_checker/issues/15
  if (kIsWeb) return true;
  host ??= F().apiHost;
  port ??= F().apiPort;
  final completer = Completer<bool>();
  try {
    final lookup = await InternetAddress.lookup(host, type: InternetAddressType.IPv4).timeout(
      const Duration(seconds: 1),
    );
    final futures = lookup.map((addr) {
      return Socket.connect(addr, port ?? 80, timeout: timeout).then((socket) {
        socket.destroy();
        return true;
      }).catchError((ex) {
        if (kDebugMode) print("isApiAvailable: $ex");
        return false;
      });
    });
    final result = await Future.any(futures);
    completer.complete(result);
  } catch (ex) {
    if (kDebugMode) print("isApiAvailable: $ex");
    completer.complete(false);
  }
  return completer.future;
}

// eof
