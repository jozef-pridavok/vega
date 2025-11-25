import "package:api_cron/implementations/api_shelf.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";

import "api_shelf_http_server.dart";

extension CronApiCheckKeys on CronApi {
  Middleware get checkApiKeys {
    return (innerHandler) {
      return (request) {
        if (request.method == "OPTIONS") return innerHandler(request);

        final headers = request.headers;

        final url = request.url.path;

        if (accessWithoutApiKey(url)) return innerHandler(request);

        final isV1 = url.startsWith("v1/");
        final isV2 = url.startsWith("v2/");
        final is3rd = url.startsWith("3rd/");
        final hasApiKey = headers.containsKey(CronApi.headerApiKey);
        final apiKey = headers[CronApi.headerApiKey];
        if (isV1) {
          if (!hasApiKey) return unauthorized(errorNoApiKey);
          if (apiKey != config.keyV1) return unauthorized(errorInvalidApiKey);
        } else if (isV2) {
          if (!hasApiKey) return unauthorized(errorNoApiKey);
          if (apiKey != config.keyV2) return unauthorized(errorInvalidApiKey);
        } else if (is3rd) {
          if (!hasApiKey) return unauthorized(errorNoApiKey);
          //final isJesoft = url.startsWith("3rd/jesoft/");
          //if (isJesoft) {
          //  if (apiKey != config.trdJesoftKey) return unauthorized(errorInvalidApiKey);
          //}
        } else {
          return unauthorized(errorBrokenSecurityEx("Unknown API version"));
        }

        return innerHandler(request);
      };
    };
  }
}

// eof
