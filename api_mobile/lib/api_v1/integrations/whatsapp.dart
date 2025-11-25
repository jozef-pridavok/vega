import "dart:convert";

import "package:api_mobile/extensions/request_body.dart";
import "package:api_mobile/implementations/api_shelf2.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:core_dart/core_expression.dart";
import "package:http/http.dart" as http;
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../session.dart";

Future<_WhatsappAccessToken> _fetchAccessToken(
  String clientId,
  String clientSecret,
  String exchangeToken,
) async {
  final response = await http.get(
    Uri.parse(
      """https://graph.facebook.com/v20.0/oauth/access_token?client_id=$clientId&client_secret=$clientSecret&grant_type=authorization_code&code=$exchangeToken""",
    ),
  );

  if (response.statusCode == 200) {
    return _WhatsappAccessToken.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else {
    throw Exception("Failed to load whatsapp token");
  }
}

class _WhatsappAccessToken {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  const _WhatsappAccessToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory _WhatsappAccessToken.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "access_token": String accessToken,
        "token_type": String tokenType,
        "expires_in": int expiresIn,
      } =>
        _WhatsappAccessToken(
          accessToken: accessToken,
          tokenType: tokenType,
          expiresIn: expiresIn,
        ),
      _ => throw const FormatException("Failed to load whatsapp token."),
    };
  }
}

class WhatsappHandler extends ApiServerHandler {
  final MobileApi _api;
  WhatsappHandler(this._api) : super(_api);

  Future<Response> _getHtml(Request request) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final clientId = session.clientId;

        if (clientId == null)
          return _api.badRequest(errorMissingParameter("clientId"));

        final headers = request.headers;
        final hasAccessToken = headers.containsKey(MobileApi.headerAccessToken);
        if (!hasAccessToken) return _api.forbidden(errorNoAccessToken);

        final authHeader = headers[MobileApi.headerAccessToken];
        if (authHeader == null ||
            authHeader.isEmpty ||
            !MobileApi.bearerRegExp.hasMatch(authHeader))
          return _api.badRequest(errorInvalidAccessToken);

        final accessToken = authHeader.split(" ")[1];
        final context = {
          "mobileApiHost": _api.config.mobileApiHost,
          "apiKey": _api.config.keyV1,
          if (_api.config.isDev || _api.config.isQa)
            "apiKeyDisplay": _api.config.keyV1.shorten(),
          "accessToken": accessToken,
          if (_api.config.isDev || _api.config.isQa)
            "accessTokenDisplay": accessToken.shorten(),
          "clientId": _api.config.whatsappClientId,
          if (_api.config.isDev || _api.config.isQa)
            "clientIdDisplay": _api.config.whatsappClientId.shorten(),
          "configId": _api.config.whatsappConfigId,
          if (_api.config.isDev || _api.config.isQa)
            "configIdDisplay": _api.config.whatsappConfigId.shorten(),
        };

        const evaluator = ExpressionEvaluator();

        final templateProcessor = TemplateProcessor((expr) {
          final expression = Expression.parse(expr);
          String? result;
          try {
            result = evaluator.eval(expression, context) as String;
          } catch (ex, st) {
            _api.log.error(ex.toString());
            _api.log.error(st.toString());
            result = ex.toString();
          }
          return result;
        });

        final source = joinPath([
          _api.config.localPath,
          "static",
          "integrations",
          "whatsapp.html",
        ]);
        final html = await templateProcessor.processFile(source);

        // hide secret data in logs
        _api.log.verbose(
          html
              .replaceAll(_api.config.keyV1, _api.config.keyV1.shorten())
              .replaceAll(accessToken, accessToken.shorten())
              .replaceAll(
                _api.config.whatsappClientId,
                _api.config.whatsappClientId.shorten(),
              )
              .replaceAll(
                _api.config.whatsappConfigId,
                _api.config.whatsappConfigId.shorten(),
              ),
        );

        //return _api.html(html);
        return _api.response(
          200,
          body: html,
          headers: {
            "Content-Type": "text/html",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,HEAD,OPTIONS",
            "Access-Control-Allow-Headers": "*",
            "X-Frame-Options": "",
            "Content-Security-Policy":
                "frame-ancestors 'self' https://*.vega.com https://*.vega.com;",
          },
        );
      });

  Future<Response> _setInfo(Request request) async => withRequestLog((
    context,
  ) async {
    final body = (await request.body.asJson) as JsonObject;

    final installationId = request.context["iid"] as String;
    final session = await _api.getSession(installationId);
    final clientId = session.clientId;

    final wabaId = body["wabaId"] as String?;
    final phoneNumberId = body["phoneNumberId"] as String?;
    final exchangeToken = body["exchangeToken"] as String?;

    if (wabaId == null) return _api.badRequest(errorMissingParameter("wabaId"));
    if (phoneNumberId == null)
      return _api.badRequest(errorMissingParameter("phoneNumberId"));
    if (exchangeToken == null)
      return _api.badRequest(errorMissingParameter("exchangeToken"));

    final whatsappClientId = _api.config.whatsappClientId;
    final whatsappClientSecret = _api.config.whatsappClientSecret;

    _WhatsappAccessToken result;

    try {
      result = await _fetchAccessToken(
        whatsappClientId,
        whatsappClientSecret,
        exchangeToken,
      );
    } catch (ex) {
      return _api.internalError(errorUnexpectedException(ex));
    }
    final accessToken = result.accessToken;
    final expiresIn = result.expiresIn;

    String sql =
        """
          UPDATE clients 
          SET meta = COALESCE(meta, '{}')::jsonb || 
                '{  "whatsapp": {
                      wabaId: "$wabaId", 
                      phoneNumberId: "$phoneNumberId",
                      accessToken: "$accessToken"
                      expiresIn: $expiresIn
                    }
                 }'::jsonb,
              updated_at = NOW() 
          WHERE client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();
    Map<String, dynamic> sqlParams = {"client_id": clientId};

    _api.log.verbose(sql);
    _api.log.verbose(sqlParams.toString());

    final updated = await _api.update(sql, params: sqlParams);
    if (updated != 1)
      return _api.internalError(errorBrokenLogicEx("Request not updated"));

    return _api.json({"affected": updated});
  });

  Future<Response> _sendMessage(Request request) async =>
      withRequestLog((context) async {
        final body = (await request.body.asJson) as JsonObject;

        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final clientId = session.clientId;

        final phoneNumber = body["phoneNumber"] as String?;
        final templateName = body["templateName"] as String?;
        final messageBody = body["messageBody"] as String?;

        if (phoneNumber == null)
          return _api.badRequest(errorMissingParameter("phoneNumber"));
        if (templateName == null && messageBody == null) {
          return _api.badRequest(
            errorMissingParameter(
              "Either templateName or messageBody must be provided",
            ),
          );
        }

        // Get client's WhatsApp credentials from meta
        final sql = """
          SELECT meta->'whatsapp' as whatsapp
          FROM clients 
          WHERE client_id = @client_id AND deleted_at IS NULL
        """;
        final results = await _api.select(sql, params: {"client_id": clientId});

        if (results.isEmpty)
          return _api.badRequest(
            errorBrokenLogicEx("Client WhatsApp configuration not found"),
          );

        final whatsappConfig = results.first["whatsapp"] as JsonObject?;
        if (whatsappConfig == null)
          return _api.badRequest(
            errorBrokenLogicEx("Client WhatsApp configuration not found"),
          );

        final accessToken = whatsappConfig["accessToken"] as String?;
        final phoneNumberId = whatsappConfig["phoneNumberId"] as String?;

        if (accessToken == null || phoneNumberId == null) {
          return _api.badRequest(
            errorBrokenLogicEx("Invalid WhatsApp configuration"),
          );
        }

        final response = await http.post(
          Uri.parse("https://graph.facebook.com/v21.0/$phoneNumberId/messages"),
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
          body: jsonEncode(
            templateName != null
                ? {
                    "messaging_product": "whatsapp",
                    "to": phoneNumber,
                    "type": "template",
                    "template": {
                      "name": templateName,
                      "language": {"code": "en"},
                    },
                  }
                : {
                    "messaging_product": "whatsapp",
                    "to": phoneNumber,
                    "type": "text",
                    "text": {"body": messageBody},
                  },
          ),
        );

        if (response.statusCode != 200) {
          _api.log.error("WhatsApp API error: ${response.body}");
          return _api.internalError(
            errorUnexpectedException("Failed to send WhatsApp message"),
          );
        }

        return _api.json(jsonDecode(response.body) as JsonObject);
      });

  // /v1/integrations/whatsapp
  Router get router {
    final router = Router();

    router.get("/", _getHtml);
    router.patch("/", _setInfo);
    router.post("/send", _sendMessage);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
