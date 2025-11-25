import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

final _rootKey = CacheKey.shared("currencyRates");
CacheKey _latestKey(String pair) => _rootKey.join("latest").join(pair);

class CurrencyHandler extends ApiServerHandler {
  CurrencyHandler(super.api);

  Future<Response> _latest(Request request, String pair) async => withRequestLog((context) async {
        //final key = "currencyRates:latest:$pair";
        final rKey = _latestKey(pair).toString();
        final value = await api.redis(["GET", rKey]); // sharedCache
        if (value == null) return api.notFound(errorObjectNotFound);
        final rate = double.tryParse(value);
        if (rate == null) return api.internalError(errorBrokenLogic);
        return api.json({"rate": rate});
      });

  // /v1/dashboard/currency
  Router get router {
    final router = Router();

    router.get("/latest/<pair>", _latest);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
