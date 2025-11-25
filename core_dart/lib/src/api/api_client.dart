import "dart:async";
import "dart:convert";
import "dart:io";

import "package:core_dart/core_dart.dart";
import "package:dio/dio.dart";
import "package:http_parser/http_parser.dart";

import "../../core_repositories.dart";

typedef ApiHeaders = Map<String, String>;
typedef ApiHeaderFactory = ApiHeaders Function();
typedef ApiRefreshAccessTokenHandler = Future<void> Function();

class ApiClient {
  static ApiClient? _instance;
  static late Dio _dio;
  final String endPoint;
  final String apiKey;
  final ApiHeaderFactory? dynamicHeaders;
  final Duration? timeout;
  final ApiRefreshAccessTokenHandler refreshAccessToken;
  static bool _accessTokenRefreshInProgress = false;

  ApiClient._({
    required this.endPoint,
    required this.apiKey,
    required this.refreshAccessToken,
    this.dynamicHeaders,
    this.timeout,
  });

  factory ApiClient.configure({
    required String endPoint,
    required String apiKey,
    required ApiRefreshAccessTokenHandler refreshAccessToken,
    ApiHeaderFactory? dynamicHeaders,
    Duration? connectionTimeout,
    Duration? timeout,
  }) {
    if (_instance == null) {
      _instance ??= ApiClient._(
        endPoint: endPoint,
        apiKey: apiKey,
        refreshAccessToken: refreshAccessToken,
        dynamicHeaders: dynamicHeaders,
        timeout: timeout,
      );
      _dio = Dio(
        BaseOptions(
          connectTimeout: connectionTimeout,
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );
    }
    return _instance!;
  }

  factory ApiClient() => _instance!;

  String _url(String path) => endPoint + path;

  String basicAuth(String username, String password) => "Basic ${base64.encode(utf8.encode("$username:$password"))}";

  Future<ApiHeaders> defaultHeaders({String contentType = "application/json"}) async {
    final headers = {
      // Default agent
      "User-Agent": "Vega Frontend",
      "Keep-Alive": "timeout=30, max=100",
      "Content-Type": contentType,
      "X-API-Key": apiKey,
    };
    if (dynamicHeaders != null) {
      final additionHeaders = dynamicHeaders!();
      headers.addAll(additionHeaders);
    }
    return headers;
  }

  Future<bool> _accessTokenRefreshed(ApiRequest req, ApiResponse res) async {
    if (res.appCode != errorInvalidAccessToken.code) return false;

    final deviceRepository = HiveDeviceRepository();
    final refreshToken = deviceRepository.get(DeviceKey.refreshToken);
    if (refreshToken == null) throw errorInvalidRefreshToken;

    if (_accessTokenRefreshInProgress) {
      return Future.delayed(
        const Duration(milliseconds: 100),
        () => _accessTokenRefreshed(req, res),
      );
    }

    _accessTokenRefreshInProgress = true;
    try {
      await refreshAccessToken();
    } finally {
      _accessTokenRefreshInProgress = false;
    }

    return true;
  }

  /// RestAPI get object
  Future<ApiResponse> get(
    String path, {
    JsonObject? params,
    ApiHeaders? headers,
    Duration? timeout,
    bool retry = true,
  }) async {
    final req = ApiRequest("GET", _url(path), params: params, headers: headers ?? await defaultHeaders());
    try {
      final response = await _dio.get(
        req.url,
        queryParameters: req.params,
        options: Options(
          headers: req.headers,
          sendTimeout: timeout ?? this.timeout,
          receiveTimeout: timeout ?? this.timeout,
        ),
      );
      return Future<ApiResponse>.value(response.toApi(req));
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout)
        return ApiResponse(req, statusCode: HttpStatus.networkConnectTimeoutError, message: ex.message);

      if (ex.error is SocketException)
        return ApiResponse(req, statusCode: HttpStatus.serviceUnavailable, message: ex.message);

      final response = ex.response;
      if (response != null) {
        final res = response.toApi(req);
        if (retry && await _accessTokenRefreshed(req, res))
          return await get(path, params: params, headers: headers, timeout: timeout, retry: false);
        return Future<ApiResponse>.value(res);
      }

      return ApiResponse(req, statusCode: 0, message: ex.message ?? ex.error?.toString());
    }
  }

  /// RestAPI post body
  Future<ApiResponse> post(
    String path, {
    JsonObject? data,
    ApiHeaders? headers,
    Duration? timeout,
    bool retry = true,
  }) async {
    final req = ApiRequest("POST", _url(path), data: data, headers: headers ?? await defaultHeaders());
    try {
      final response = await _dio.post(
        req.url,
        data: req.data,
        options: Options(
          headers: req.headers,
          sendTimeout: timeout ?? this.timeout,
          receiveTimeout: timeout ?? this.timeout,
        ),
      );
      return Future<ApiResponse>.value(response.toApi(req));
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout)
        return ApiResponse(req, statusCode: HttpStatus.networkConnectTimeoutError, message: ex.message);

      if (ex.error is SocketException)
        return ApiResponse(req, statusCode: HttpStatus.serviceUnavailable, message: ex.message);

      final response = ex.response;
      if (response != null) {
        final res = response.toApi(req);
        if (retry && await _accessTokenRefreshed(req, res))
          return await post(path, data: data, headers: headers, timeout: timeout, retry: false);
        return Future<ApiResponse>.value(res);
      }

      return ApiResponse(req, statusCode: 0, message: ex.message ?? ex.error?.toString());
    }
  }

  /// RestAPI post body
  Future<ApiResponse> postFile(
    String path,
    File file, {
    ApiHeaders? headers,
    Duration? timeout,
    bool retry = true,
  }) async {
    String fileName = file.path.split("/").last;
    final data = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final req = ApiRequest("POST", _url(path), data: data, headers: headers ?? await defaultHeaders());
    try {
      final response = await _dio.post(
        req.url,
        data: req.data,
        options: Options(
          headers: req.headers,
          sendTimeout: timeout ?? this.timeout,
          receiveTimeout: timeout ?? this.timeout,
        ),
      );
      return Future<ApiResponse>.value(response.toApi(req));
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout)
        return ApiResponse(req, statusCode: HttpStatus.networkConnectTimeoutError, message: ex.message);

      if (ex.error is SocketException)
        return ApiResponse(req, statusCode: HttpStatus.serviceUnavailable, message: ex.message);

      final response = ex.response;
      if (response != null) {
        final res = response.toApi(req);
        if (retry && await _accessTokenRefreshed(req, res))
          return await postFile(path, file, headers: headers, timeout: timeout, retry: false);
        return Future<ApiResponse>.value(res);
      }

      return ApiResponse(req, statusCode: 0, message: ex.message ?? ex.error?.toString());
    }
  }

  Future<Map<String, dynamic>> _getMultipartData(List<dynamic> objects) async {
    final Map<String, dynamic> data = {};

    int keyIndex = 0;
    for (final dynamic obj in objects) {
      final value = obj;
      final key = "part${keyIndex++}";
      if (value is File) {
        String name = value.path.split("/").last;
        String ext = name.split(".").last;
        data[key] = await MultipartFile.fromFile(value.path, filename: name, contentType: MediaType("image", ext));
      } else if (value is String)
        data[key] = MultipartFile.fromString(value, contentType: MediaType("text", "plain"));
      else if (value is Map<String, dynamic>)
        data[key] = MultipartFile.fromString(jsonEncode(value), contentType: MediaType("application", "json"));
      else if (value is List<int>) {
        var contentType = MediaType("application", "octet-stream");
        if (value[0] == 0xFF && value[1] == 0xD8) {
          contentType = MediaType("image", "jpeg");
        } else if (value[0] == 0x89 && value[1] == 0x50) {
          contentType = MediaType("image", "png");
        } else if (value[8] == 0x57 && value[9] == 0x45 && value[10] == 0x42 && value[11] == 0x50) {
          contentType = MediaType("image", "webp");
        }
        data[key] = MultipartFile.fromBytes(value, contentType: contentType);
      }
    }

    return data;
  }

  Future<ApiResponse> postMultipart(
    String path,
    List<dynamic> objects, {
    ApiHeaders? headers,
    Duration? timeout,
    bool retry = true,
  }) async {
    final data = await _getMultipartData(objects);
    final req =
        ApiRequest("POST", _url(path), data: FormData.fromMap(data), headers: headers ?? await defaultHeaders());
    try {
      final response = await _dio.post(
        req.url,
        data: req.data,
        options: Options(
          headers: req.headers,
          sendTimeout: timeout ?? this.timeout,
          receiveTimeout: timeout ?? this.timeout,
        ),
      );
      return Future<ApiResponse>.value(response.toApi(req));
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout)
        return ApiResponse(req, statusCode: HttpStatus.networkConnectTimeoutError, message: ex.message);

      if (ex.error is SocketException)
        return ApiResponse(req, statusCode: HttpStatus.serviceUnavailable, message: ex.message);

      final response = ex.response;
      if (response != null) {
        final res = response.toApi(req);
        if (retry && await _accessTokenRefreshed(req, res))
          return await postMultipart(path, objects, headers: headers, timeout: timeout, retry: false);
        return Future<ApiResponse>.value(res);
      }

      return ApiResponse(req, statusCode: 0, message: ex.message ?? ex.error?.toString());
    }
  }

  Future<ApiResponse> putMultipart(
    String path,
    List<dynamic> objects, {
    ApiHeaders? headers,
    Duration? timeout,
    bool retry = true,
  }) async {
    final data = await _getMultipartData(objects);
    final req = ApiRequest("PUT", _url(path), data: FormData.fromMap(data), headers: headers ?? await defaultHeaders());
    try {
      final response = await _dio.put(
        req.url,
        data: req.data,
        options: Options(
          headers: req.headers,
          sendTimeout: timeout ?? this.timeout,
          receiveTimeout: timeout ?? this.timeout,
        ),
      );
      return Future<ApiResponse>.value(response.toApi(req));
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout)
        return ApiResponse(req, statusCode: HttpStatus.networkConnectTimeoutError, message: ex.message);

      if (ex.error is SocketException)
        return ApiResponse(req, statusCode: HttpStatus.serviceUnavailable, message: ex.message);

      final response = ex.response;
      if (response != null) {
        final res = response.toApi(req);
        if (retry && await _accessTokenRefreshed(req, res))
          return await postMultipart(path, objects, headers: headers, timeout: timeout, retry: false);
        return Future<ApiResponse>.value(res);
      }

      return ApiResponse(req, statusCode: 0, message: ex.message ?? ex.error?.toString());
    }
  }

  /// RestAPI put data
  Future<ApiResponse> put(
    String path, {
    JsonObject? data,
    ApiHeaders? headers,
    Duration? timeout,
    bool retry = true,
  }) async {
    final req = ApiRequest("PUT", _url(path), data: data, headers: headers ?? await defaultHeaders());
    try {
      final response = await _dio.put(
        req.url,
        data: req.data,
        options: Options(
          headers: req.headers,
          sendTimeout: timeout ?? this.timeout,
          receiveTimeout: timeout ?? this.timeout,
        ),
      );
      return Future<ApiResponse>.value(response.toApi(req));
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout)
        return ApiResponse(req, statusCode: HttpStatus.networkConnectTimeoutError, message: ex.message);

      if (ex.error is SocketException)
        return ApiResponse(req, statusCode: HttpStatus.serviceUnavailable, message: ex.message);

      final response = ex.response;

      if (response != null) {
        final res = response.toApi(req);
        if (retry && await _accessTokenRefreshed(req, res))
          return await put(path, data: data, headers: headers, timeout: timeout, retry: false);
        return Future<ApiResponse>.value(res);
      }

      return ApiResponse(req, statusCode: 0, message: ex.message ?? ex.error?.toString());
    }
  }

  /// RestAPI patch (modify) object
  Future<ApiResponse> patch(
    String path, {
    JsonObject? data,
    ApiHeaders? headers,
    Duration? timeout,
    bool retry = true,
  }) async {
    final req = ApiRequest("PATH", _url(path), data: data, headers: headers ?? await defaultHeaders());
    try {
      final response = await _dio.patch(
        req.url,
        data: req.data,
        options: Options(
          headers: req.headers,
          sendTimeout: timeout ?? this.timeout,
          receiveTimeout: timeout ?? this.timeout,
        ),
      );
      return Future<ApiResponse>.value(response.toApi(req));
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout)
        return ApiResponse(req, statusCode: HttpStatus.networkConnectTimeoutError, message: ex.message);

      if (ex.error is SocketException)
        return ApiResponse(req, statusCode: HttpStatus.serviceUnavailable, message: ex.message);

      final response = ex.response;
      if (response != null) {
        final res = response.toApi(req);
        if (retry && await _accessTokenRefreshed(req, res))
          return await patch(path, data: data, headers: headers, timeout: timeout, retry: false);
        return Future<ApiResponse>.value(res);
      }

      return ApiResponse(req, statusCode: 0, message: ex.message ?? ex.error.toString());
    }
  }

  /// RestAPI delete object
  Future<ApiResponse> delete(
    String path, {
    JsonObject? data,
    ApiHeaders? headers,
    Duration? timeout,
    bool retry = true,
  }) async {
    final req = ApiRequest("DELETE", _url(path), data: data, headers: headers ?? await defaultHeaders());
    try {
      final response = await _dio.delete(
        req.url,
        data: req.data,
        options: Options(
          headers: req.headers,
          sendTimeout: timeout ?? this.timeout,
          receiveTimeout: timeout ?? this.timeout,
        ),
      );
      return Future<ApiResponse>.value(response.toApi(req));
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout)
        return ApiResponse(req, statusCode: HttpStatus.networkConnectTimeoutError, message: ex.message);

      if (ex.error is SocketException)
        return ApiResponse(req, statusCode: HttpStatus.serviceUnavailable, message: ex.message);

      final response = ex.response;
      if (response != null) {
        final res = response.toApi(req);
        if (retry && await _accessTokenRefreshed(req, res))
          return await delete(path, data: data, headers: headers, timeout: timeout, retry: false);
        return Future<ApiResponse>.value(res);
      }

      return ApiResponse(req, statusCode: 0, message: ex.message ?? ex.error.toString());
    }
  }
}

// eof
