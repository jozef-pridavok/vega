import "dart:convert";

import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:dio/dio.dart" hide Response;
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../implementations/api_shelf.dart";
import "cron_handler.dart";

final _rootKey = CacheKey.shared("currencyRates");

class UpdateCurrencyRatesHandler extends CronHandler<void> {
  UpdateCurrencyRatesHandler(ApiServer2 api) : super("UpdateCurrencyRates", api);

  // https://apilayer.com/marketplace/exchangerates_data-api#pricing
  static final _apiLayerComUrl = "api.apilayer.com";
  static final expiration = Duration(days: 30).inSeconds;

  @override
  Future<JsonObject> process(ApiServerContext context, void param) async {
    final res = await Future.wait(Currency.values.map((currency) async {
      final base = currency.code;
      final others = Currency.values.where((other) => other != currency).map((other) => other.code);
      final info = "$base => ${others.join(',')}";
      final url = "https://$_apiLayerComUrl/exchangerates_data/latest?base=$base&symbols=${others.join(',')}";
      //final url = "https://google.csdsdom/";
      //log.verbose("Requesting $url for $info");
      JsonObject? json;
      try {
        final res = await Dio().get(
          url,
          options: Options(
            headers: <String, String>{"apikey": "9aXfM0GUeU9iDYZlCXQnzJZlKk31jges"},
          ),
        );
        json = cast<JsonObject>(res.data);
        if (json?["success"] != true) throw "Response not successful.";
      } on DioException catch (e) {
        log.error("Dio error for $info: ${e.message ?? e.error?.toString() ?? e.toString()}");
        return false;
      } catch (e) {
        log.error("Unexpected error for $info: $e");
        return false;
      }
      if (json == null) {
        log.error("No json for $info");
        return false;
      }
      final date = IntDate.parseString(json["date"].toString().replaceAll("-", "")).toString();
      final rates = json["rates"];
      for (final other in others) {
        final rate = cast<double>(rates[other])?.toStringAsExponential();
        if (rate == null) {
          return false;
        }

        final dateKey = _rootKey.join(date).join(base);
        await api.redis(["SET", dateKey.join(other).toString(), rate, "EX", expiration]);
        await api.redis(["SET", dateKey.join("payload").toString(), jsonEncode(json), "EX", expiration]);

        final latestKey = _rootKey.join("latest").join(base).join(other).toString();
        await api.redis(["SET", latestKey, rate]);
      }
      return true;
    }));

    final currencyCount = Currency.values.length;
    final successCount = res.where((success) => success).length;

    final json = {"success": successCount, "total": currencyCount};
    await recordLastRun(json);
    return json;
  }

  Future<Response> _apiLayerCom(Request req) async => withRequestLog((context) async {
        log.logRequest(context, req.toLogRequest());
        final json = await execute(context, null);
        log.verbose(json, jsonEncode);
        return api.json(json);
      });

  // /v1/cron/currencyRates
  Router get router {
    final router = Router();

    router.get("/update", _apiLayerCom);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
