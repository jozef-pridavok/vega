import "dart:io";

import "package:api_mobile/implementations/api_shelf2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";

extension MobileApiCheckIpAddresses on MobileApi {
  Middleware get checkIpAddresses {
    return (innerHandler) {
      return (request) {
        if (request.method == "OPTIONS") {
          return innerHandler(request);
        }

        final headers = request.headers;
        final url = request.url;
        final is3rd = url.path.startsWith("3rd/");
        if (is3rd) {
          final connectionInfo = cast<HttpConnectionInfo>(
            request.context["shelf.io.connection_info"],
          );
          log.verbose("remoteAddress=${connectionInfo?.remoteAddress.address}");
          log.verbose("remoteHost=${connectionInfo?.remoteAddress.host}");

          final remoteAddress = connectionInfo?.remoteAddress.address;
          final forwardedAddress = cast<String>(headers["x-forwarded-for"]);
          log.verbose("x-forwarded-for=$forwardedAddress");

          final toCheck = <String>[];
          if (remoteAddress != null) toCheck.add(remoteAddress);
          if (forwardedAddress != null) toCheck.add(forwardedAddress);

          //final isJesoft = url.path.startsWith("3rd/jesoft/");
          //if (isJesoft) {
          //  if (!isAllowedAddress(toCheck, config.trdJesoftAddresses)) return forbidden(errorInvalidApiIpAddress);
          //}
        }

        return innerHandler(request);
      };
    };
  }
}

// eof
