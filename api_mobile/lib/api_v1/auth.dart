import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../api_v1/token.dart";
import "../extensions/request_body.dart";
import "../implementations/api_shelf2.dart";

class AuthHandler extends ApiServerHandler {
  final MobileApi _api;
  AuthHandler(this._api) : super(_api);

  /// Issues new access and refresh token.
  /// Required roles: none
  /// Response status codes: 201, 400, 401, 403, 500
  Future<Response> _issueTokens(Request request) async => withRequestLog((context) async {
        final body = cast<JsonObject>(await request.body.asJson);
        final currentRefreshToken = body?["refreshToken"] as String?;
        final userId = body?["userId"] as String?;
        final installationId = body?["installationId"] as String?;
        if (currentRefreshToken == null) return _api.badRequest(errorInvalidRefreshToken);
        if (userId == null) return _api.badRequest(errorInvalidRefreshToken);
        if (installationId == null) return _api.badRequest(errorInvalidRefreshToken);
        try {
          final (_, family) = await verifyRefreshToken(_api, currentRefreshToken, userId: userId);
          final newRefreshToken = await issueRefreshToken(_api, userId: userId, fromFamily: family);
          final accessToken = issueAccessToken(_api, payload: {"uid": userId, "iid": installationId});
          return _api.created({"userId": userId, "refreshToken": newRefreshToken, "accessToken": accessToken});
        } on CoreError catch (ex, st) {
          _api.log.error(ex.toString());
          _api.log.error(st.toString());
          if (ex.code == errorRefreshTokenReuseDetected.code) {
            return _api.forbidden(ex);
          } else if (ex.code == errorBrokenLogic.code) {
            return _api.internalError(ex);
          }
          return _api.badRequest(ex);
        }
      });

  // /v1/auth
  Router get router {
    final router = Router();

    router.post("/refresh_token", _issueTokens);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
