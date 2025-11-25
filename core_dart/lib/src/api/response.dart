import "dart:async";
import "dart:io";

import "package:core_dart/core_dart.dart";
import "package:dio/dio.dart";

class ApiResponse {
  final ApiRequest request;
  final int statusCode;
  final String? message;
  final dynamic data;
  final JsonObject? json;

  int get appCode => cast<int>(json?["code"]) ?? 0;

  ApiResponse(
    this.request, {
    required this.statusCode,
    this.message,
    this.data,
    this.json,
  });

  FutureOr<JsonObject?> _handleOtherStatusCodes() {
    if (statusCode == HttpStatus.noContent) {
      return JsonObjectExtensions.empty();
    } else if (statusCode == HttpStatus.alreadyReported) {
      return null;
    } else if (statusCode == HttpStatus.networkConnectTimeoutError) {
      return Future.error(errorConnectionTimeout);
    } else if (statusCode == HttpStatus.serviceUnavailable) {
      return Future.error(errorServiceUnavailable);
    } else {
      return Future.error(CoreError(code: appCode, message: message ?? toString(), innerException: this));
    }
  }

  /// Returns json if status code is [status], otherwise throws [CoreError].
  ///    - if status code is [HttpStatus.ok], returns [json]
  ///    - if status code is [HttpStatus.noContent], returns {}
  //P    - if status code is [HttpStatus.alreadyReported], returns null
  FutureOr<JsonObject?> handleStatusCodeWithJson([int status = HttpStatus.ok]) {
    if (statusCode == status) return json!;
    return _handleOtherStatusCodes();
  }

  // handle with more status codes
  FutureOr<JsonObject?> handleStatusesCodeWithJson(List<int> statuses) {
    if (statuses.contains(statusCode)) return json!;
    return _handleOtherStatusCodes();
  }

  @override
  String toString() {
    if (kProduct) return "$message [$statusCode/$appCode]";
    final res = StringBuffer();
    res.writeln("${request.method} ${request.url}");
    res.writeln("$statusCode, $message");
    res.writeln("$appCode, ${json?["message"]}");
    return res.toString();
  }
}

extension DioApiResponseExtension on Response {
  ApiResponse toApi(ApiRequest request) => ApiResponse(
        request,
        statusCode: statusCode ?? 0,
        message: statusMessage,
        data: data,
        json: cast<JsonObject>(data),
      );
}

// eof
