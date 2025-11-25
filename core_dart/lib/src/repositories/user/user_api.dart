import "dart:io";

import "../../../core_dart.dart";
import "../../../core_repositories.dart";

class ApiUserRepository implements UserRepository {
  final DeviceRepository deviceRepository;

  ApiUserRepository({required this.deviceRepository});

  @override
  Future<User?> read(String userId, {bool ignoreCache = false}) async {
    final cacheKey = "4ade6cdf-333d-4ec4-bda6-6ac25aa32f65";
    final cached = deviceRepository.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/user", params: <String, dynamic>{
      "userId": userId,
      if (!ignoreCache && cached != null) "cache": cached,
    });

    final json = await res.handleStatusCodeWithJson();
    if (json == null) return null;

    final userJson = json["user"];

    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository.putCacheKey(cacheKey, timestamp);

    return User.fromMap(userJson, User.camel);
  }

  @override
  Future<bool> update(User user) async {
    final res = await ApiClient().put("/v1/user", data: user.toMap(User.camel));
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<Authenticated> startup(
    String refreshToken, {
    String? deviceToken,
    JsonObject? deviceInfo,
  }) async {
    final res = await ApiClient().post(
      "/v1/user/startup",
      data: <String, dynamic>{
        "refreshToken": refreshToken,
        if (deviceToken != null) "deviceToken": deviceToken,
        if (deviceInfo != null) "deviceInfo": deviceInfo,
      },
      // Don't try to refresh access token during startup!
      retry: false,
    );
    final json = await res.handleStatusCodeWithJson();
    if (json == null) return throw res;
    return Authenticated.fromJson(json);
  }

  @override
  Future<bool> updateDeviceToken(String deviceToken) async {
    final res = await ApiClient().put("/v1/user/device_token", data: <String, dynamic>{
      "deviceToken": deviceToken,
    });
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<Authenticated> anonymous(
    String installationId, {
    String? deviceToken,
    JsonObject? deviceInfo,
    required String language,
    required String country,
  }) async {
    final res = await ApiClient().post("/v1/user/anonymous", data: <String, dynamic>{
      "installationId": installationId,
      "deviceToken": deviceToken,
      "deviceInfo": deviceInfo,
      "language": language,
      "country": country,
    });
    final json = await res.handleStatusCodeWithJson();
    if (json == null) return throw res;
    return Authenticated.fromJson(json);
  }

  @override
  Future<Authenticated> login(String installationId, String? email, String? login, String password) async {
    final res = await ApiClient().post("/v1/user/login", data: <String, dynamic>{
      "installationId": installationId,
      "login": login,
      "email": email,
      "password": password,
    });
    final json = await res.handleStatusCodeWithJson();
    if (json == null) return throw res;
    return Authenticated.fromJson(json);
  }

  @override
  Future<Authenticated> register(String installationId, String? email, String? login, String password) async {
    final res = await ApiClient().post("/v1/user/register", data: <String, dynamic>{
      "installationId": installationId,
      "login": login,
      "email": email,
      "password": password,
    });
    final json = await res.handleStatusCodeWithJson();
    if (json == null) return throw res;
    return Authenticated.fromJson(json);
  }

  @override
  Future<Authenticated> logout() async {
    final res = await ApiClient().post("/v1/user/logout");
    final json = await res.handleStatusCodeWithJson();
    if (json == null) return throw res;
    return Authenticated.fromJson(json);
  }

  @override
  Future<bool> delete() async {
    final res = await ApiClient().delete("/v1/user");
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> changePassword(String email, String password) async {
    final res = await ApiClient().patch("/v1/user/password", data: {"email": email, "password": password});
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<Authenticated> refreshAccessToken(String refreshToken, String installationId, String userId) async {
    final res = await ApiClient().post("/v1/auth/refresh_token", data: <String, dynamic>{
      "refreshToken": refreshToken,
      "installationId": installationId,
      "userId": userId,
    });
    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    if (json == null) return throw res;
    return Authenticated.fromJson(json);
  }
}

// eof
