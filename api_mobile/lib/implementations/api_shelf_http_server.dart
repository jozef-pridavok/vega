import "dart:convert";
import "dart:io";

import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as shelf_io;
import "package:shelf_router/shelf_router.dart";
import "package:shelf_static/shelf_static.dart";

import "api_shelf2.dart";
import "api_shelf_check_access_token.dart";
import "api_shelf_check_ip.dart";
import "api_shelf_check_keys.dart";
import "api_shelf_check_license.dart";
import "api_shelf_cors.dart";
import "api_shelf_redis.dart";

extension MobileApiHttpServer on MobileApi {
  static final _noApiKey = ["ping", "public", "v1/user/password/confirm", "v1/user/email/confirm"];
  static final _noAccessToken = ["v1/auth", "v1/user/anonymous"];

  bool _checkPaths(String path, {required List<String> paths}) {
    for (final item in paths) {
      if (path.startsWith(item)) return true;
    }
    return false;
  }

  bool accessWithoutApiKey(String path) => _checkPaths(path, paths: _noApiKey);

  bool accessWithoutToken(String path) => _checkPaths(path, paths: _noAccessToken + _noApiKey);

  void _printRequest(String msg, bool isError) {
    if (isError)
      log.print("ERROR: $msg");
    else
      log.print(msg);
  }

  Middleware get verboseResponse {
    return (innerHandler) {
      return (request) async {
        final path = request.url.path;
        // Don't log ping requests, don't spam the logs
        if (path == "ping" && !config.isDev) return innerHandler(request);
        final params = request.url.queryParameters;
        final headers = request.headers;
        final method = request.method;
        log.verbose("┌──────────────────────────────────────────────────");
        log.verbose("│ $method /$path");
        if (params.isNotEmpty) params.forEach((key, value) => log.verbose("│ & $key = $value"));
        headers.forEach((key, value) => log.verbose("│ > $key: $value"));
        log.verbose("│");

        final response = await innerHandler(request);
        log.verbose("│ $method /$path");
        log.verbose("│ < ${response.statusCode}");
        response.headers.forEach((key, value) => log.verbose("│ < $key: $value"));

        if (response.mimeType == "application/json") {
          final body = await response.readAsString();
          //if (config.isDev) {
          //  inspect(jsonDecode(body));
          //} else {
          String pretty = body;
          try {
            final json = jsonDecode(body);
            pretty = JsonEncoder.withIndent("  ").convert(json);
          } catch (_) {}
          if (pretty.isNotEmpty) {
            log.verbose("│");
            //log.verbose(pretty);
            log.verbose(pretty.split("\n").map((line) => "| $line").join("\n"));
            log.verbose("│");
          }
          //}
          log.verbose("└────────────────────────────────────────────────── $method /$path");
          return response.change(body: body);
        }
        if (response.mimeType == "text/plain") {
          final body = await response.readAsString();
          log.verbose("│");
          log.verbose("│ $body");
          log.verbose("│");
          log.verbose("└────────────────────────────────────────────────── $method /$path");
          return response.change(body: body);
        }

        if (response.mimeType != null) log.verbose("│ Unsupported content type: ${response.mimeType}");
        log.verbose("│");
        log.verbose("└────────────────────────────────────────────────── $method /$path");

        return response;
      };
    };
  }

  Handler get handler {
    final router = Router();

    router.options(
      "/<ignored|.*>",
      (request) => Response.ok(null, headers: {
        "Access-Control-Allow-Headers": "Content-Type, Access-Control-Allow-Origin, X-Api-Key",
        "Access-Control-Allow-Origin": "*"
      }),
    );

    router.get(
      "/ping",
      (req) async => Response.ok(
        jsonEncode({
          "environment": config.environment.code,
          "build": config.build,
          "sql": (await select("SELECT true AS sql"))[0]["sql"],
          "cache": (await redisVersion()),
          //"translation": _translator.tr("en", LangKeys.translationVersion.tr()),
        }),
        headers: {"Content-Type": "application/json"},
      ),
    );

    router.all("/<ignored|.*>", (req) {
      log.verbose("Router does not have a handler for ${req.method} ${req.url}");
      return notFound(errorRouteNotFound);
    });

    return router.call;
  }

  Future<void> httpServer() async {
    var pipeline = Pipeline()
        .addMiddleware(corsHeaders(corsHeaders: {
          accessControlAllowHeaders: [
            "accept",
            "accept-encoding",
            "authorization",
            "content-type",
            "dnt",
            "origin",
            "user-agent",
            "x-api-key",
            "x-session",
            "x-frame-options",
            "content-security-policy",
            "access-control-allow-methods",
            "access-control-allow-origin",
            "access-control-allow-headers",
          ].join(","),
          accessControlAllowOrigin: "*",
        }))
        .addMiddleware(checkApiKeys)
        .addMiddleware(checkIpAddresses)
        .addMiddleware(checkAccessToken)
        .addMiddleware(checkLicense);

    pipeline = pipeline.addMiddleware(logRequests(logger: _printRequest));
    //if (config.logVerbose) pipeline = pipeline.addMiddleware(verboseResponse);

    // Cascade na spracovanie statických súborov aj ostatných požiadaviek ako /public
    final staticLocalPath = joinPath([config.localPath, "static"]); //root;
    final staticHandler = createStaticHandler(staticLocalPath);
    final cascade = Cascade().add((Request request) async {
      // Ak požiadavka smeruje na cestu začínajúcu 'public', obslúži statické súbory
      if (request.url.path.startsWith("public")) {
        var updatedRequest = request.change(path: "public");
        //return staticHandler(updatedRequest);
        // apply cors
        var response = await staticHandler(updatedRequest);
        response = response.change(headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET,HEAD,OPTIONS",
          "Access-Control-Allow-Headers": "*",
          "X-Frame-Options": "",
        });
        return response;
      }
      return Response.notFound("Not Found");
    }).add(
      pipeline.addHandler(handler),
    );

    await shelf_io.serve(cascade.handler, config.host, config.port, poweredByHeader: "Vega Backend");

    for (final interface in await NetworkInterface.list()) {
      log.print("┌──────────────────────────────────────────────────");
      log.print("│ Interface: ${interface.name}");
      for (final addr in interface.addresses) {
        log.print("│ ${addr.address} '${addr.host}' ${addr.type.name}");
      }
      log.print("└──────────────────────────────────────────────────");
    }

    log.print("Running on ${config.host}:${config.port}");
  }
}

// eof
