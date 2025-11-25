import "../../../core_dart.dart";

class Authenticated {
  final String userId;
  final String accessToken;
  final String refreshToken;
  Authenticated(this.userId, this.accessToken, this.refreshToken);

  factory Authenticated.fromJson(JsonObject json) => Authenticated(
        json["userId"] as String,
        json["accessToken"] as String,
        json["refreshToken"] as String,
      );
}

abstract class UserRepository {
  Future<User?> read(String userId, {bool ignoreCache});
  Future<bool> update(User user);
  Future<Authenticated> startup(String refreshToken, {String? deviceToken, JsonObject? deviceInfo});
  Future<bool> updateDeviceToken(String deviceToken);
  Future<Authenticated> anonymous(
    String installationId, {
    String? deviceToken,
    JsonObject? deviceInfo,
    required String language,
    required String country,
  });
  Future<Authenticated> login(String installationId, String? email, String? login, String password);
  Future<Authenticated> register(String installationId, String? email, String? login, String password);
  Future<Authenticated> logout();
  Future<bool> delete();
  Future<bool> changePassword(String email, String password);
  Future<Authenticated> refreshAccessToken(String refreshToken, String installationId, String userId);
}

// eof
