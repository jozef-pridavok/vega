import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../data_access_objects/item.dart";
import "../implementations/api_shelf2.dart";
import "session.dart";

class ItemHandler extends ApiServerHandler {
  final MobileApi _api;
  ItemHandler(this._api) : super(_api);

  Future<Response> _listModifications(Request request, String itemId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final modifications = await ItemDAO(session, context).listModifications(itemId);
        if (modifications.isEmpty) return _api.noContent();
        return _api.json({
          "length": modifications.length,
          "modifications": modifications.map((e) => e.toMap(Convention.camel)).toList(),
        });
      });

  Future<Response> _listOptions(Request request, String itemId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final options = await ItemDAO(session, context).listOptions(itemId);
        if (options.isEmpty) return _api.noContent();
        return _api.json({
          "length": options.length,
          "options": options.map((e) => e.toMap(Convention.camel)).toList(),
        });
      });

  // /v1/item
  Router get router {
    final router = Router();
    router.get("/modifications/<itemId|${_api.idRegExp}>", _listModifications);
    router.get("/options/<itemId|${_api.idRegExp}>", _listOptions);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
