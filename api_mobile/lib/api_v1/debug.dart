import "package:core_dart/core_api_server2.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../implementations/api_shelf2.dart";
import "../utils/template_generator.dart";

class DebugHandler extends ApiServerHandler {
  final MobileApi _api;
  DebugHandler(this._api) : super(_api);

  Future<Response> _redisGetString(Request request) async => withRequestLog((context) async {
        //final ret = await _api.redis(["GET", "log:apiMobile:index"]);
        final ret = await _api.redis(["GET", "dev"]);
        return Response.ok(ret);
      });

  Future<Response> _redisGetBulkString(Request request) async => withRequestLog((context) async {
        //final ret = await _api.redis(["GET", "app:installations:installation1"]);
        final ret = await _api.redis(["GET", "dev"]);
        return Response.ok(ret);
      });

  Future<Response> _template(Request request) async => withRequestLog((context) async {
        final html = await TemplateGenerator(_api).emailConfirmed("en");
        return _api.html(html);
      });

  // /v1/debug
  Router get router {
    final router = Router();

    router.get("/template", _template);
    router.get("/redis/get_string", _redisGetString);
    router.get("/redis/get_bulk_string", _redisGetBulkString);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
