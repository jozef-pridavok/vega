import "dart:convert";

import "../lang.dart";
import "api_client.dart";

class ApiRequest {
  final String method;
  final String url;
  JsonObject? params;
  dynamic data;
  ApiHeaders? headers;

  ApiRequest(this.method, this.url, {this.params, this.data, this.headers});

  @override
  String toString() {
    if (kProduct) return "$method $url";
    final res = StringBuffer();
    res.writeln("$method $url HTTP/1.1");
    headers?.forEach((key, value) => res.writeln("$key: $value"));
    if (data is JsonObject) {
      res.writeln();
      res.writeln(jsonEncode(data));
    } else {
      res.writeln();
      res.writeln(data.runtimeType);
    }
    res.writeln();
    return res.toString();
  }
}

// eof
