import "dart:math";

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";

import "../api_v1/session.dart" as s;
import "../data_access_objects/dashboard/client.dart";
import "api_shelf2.dart";
import "api_shelf_http_server.dart";

extension MobileApiCheckLicense on MobileApi {
  Middleware get checkLicense {
    return (innerHandler) {
      return (request) async {
        if (request.method == "OPTIONS") return innerHandler(request);

        // GET requests are not required to have a license
        if (request.method == "GET") return innerHandler(request);

        final url = request.url.path;
        if (accessWithoutToken(url)) return innerHandler(request);

        // All requests to the dashboard are required to have a license
        if (!url.startsWith("v1/dashboard")) return innerHandler(request);

        // Allow payments to the dashboard
        if (!url.startsWith("/v1/dashboard/stripe")) return innerHandler(request);

        final installationId = request.context["iid"] as String;
        final session = await getSession(installationId);

        // Only clients are required to have a license
        if (session.userType != UserType.client) return innerHandler(request);

        /*
        final hasSellerRole = session.userRoles.contains(UserRole.seller);
        // Seller role is not required to have a license
        if (hasSellerRole && session.userRoles.length == 1) return innerHandler(request);
        */

        final clientId = session.clientId;
        if (clientId == null) return forbidden(errorNoClientId);

        // expiration when no license is found, 1 hour
        final expirationForNoLicense = config.environment == Flavor.dev ? 15 : 1 * 60 * 60;
        final now = DateTime.now().toUtc();
        // the day before yesterday
        final origin = IntDate.fromDate(now.subtract(Duration(days: 2)));
        final redisKey = "licenses:$clientId";

        try {
          IntDate? license = IntDate.parseString(await redis(["GET", redisKey]));
          int days = license?.toDate().toUtc().endOfDay.difference(now.endOfDay).inDays ?? 0;
          if (license == null) {
            final context = ApiServerContext(this);
            final clientDAO = ClientDAO(session, context);
            license = await clientDAO.getClientLicense(clientId);
            if (license == null) {
              await redis(["SET", redisKey, origin.value]);
              await redis(["EXPIRE", redisKey, expirationForNoLicense]);
              return forbidden(errorInvalidLicense);
            }
            await redis(["SET", redisKey, license.value]);
            days = license.toDate().toUtc().endOfDay.difference(now.endOfDay).inDays;
            if (days > 0) {
              final expiration = max(expirationForNoLicense, (days - 1) * 24 * 60 * 60);
              await redis(["EXPIRE", redisKey, expiration]);
            }
          }
          if (days <= 0) {
            await redis(["EXPIRE", redisKey, expirationForNoLicense, "NX"]);
            if (days < 0) return forbidden(errorInvalidLicense);
          }
        } catch (ex) {
          this.log.error(ex.toString());
          return badRequest(errorUnexpectedException(ex));
        }

        return innerHandler(request);
      };
    };
  }
}

// eof
