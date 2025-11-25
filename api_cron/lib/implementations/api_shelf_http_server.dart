import "dart:convert";
import "dart:io";

import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as shelf_io;
import "package:shelf_router/shelf_router.dart";

import "api_shelf.dart";
import "api_shelf_check_keys.dart";
import "api_shelf_cors.dart";
import "api_shelf_redis.dart";

extension CronApiHttpServer on CronApi {
  static final _noApiKey = ["ping"];

  bool _checkPaths(String path, {required List<String> paths}) {
    for (final item in paths) {
      if (path.startsWith(item)) return true;
    }
    return false;
  }

  bool accessWithoutApiKey(String path) => _checkPaths(path, paths: _noApiKey);

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

    installV1(this, router);

    router.get(
      "/ping",
      (req) async => Response.ok(
        jsonEncode({
          "environment": config.environment.code,
          "build": config.build,
          "sql": (await select("SELECT true AS sql"))[0]["sql"],
          "cache": (await redisVersion()),
        }),
        headers: {"Content-Type": "application/json"},
      ),
    );

    router.all("/<ignored|.*>", (request) => notFound(errorRouteNotFound));

    return router.call;
  }

  Future<void> httpServer() async {
    var pipeline = Pipeline()
        .addMiddleware(corsHeaders(corsHeaders: {
          accessControlAllowHeaders:
              "accept, accept-encoding, authorization, content-type, dnt, origin, user-agent, x-api-key, x-session",
          accessControlAllowOrigin: "*",
        }))
        .addMiddleware(checkApiKeys);

    pipeline = pipeline.addMiddleware(logRequests(logger: _printRequest));

    await shelf_io.serve(pipeline.addHandler(handler), config.host, config.port, poweredByHeader: "Vega Cron");

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
