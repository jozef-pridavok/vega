import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../data_access_objects/offer.dart";
import "../implementations/api_shelf2.dart";
import "../utils/storage.dart";
import "session.dart";

class OfferHandler extends ApiServerHandler {
  final MobileApi _api;
  OfferHandler(this._api) : super(_api);

  Future<Response> _listClient(Request request, String clientId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final orders = await OfferDAO(session, context).list(clientId);
        if (orders.isEmpty) return _api.noContent();
        return _api.json({
          "length": orders.length,
          "offers": orders.map((e) => e.toMap(Convention.camel)).toList(),
        });
      });

  Future<Response> _detail(Request request, String offerId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await _api.getSession(installationId);
        final offer = await OfferDAO(session, context).detail(offerId);
        if (offer == null) return _api.notFound(errorObjectNotFound);

        offer.items?.forEach((item) {
          item.photo = _api.storageUrl(item.photo, StorageObject.productItem, timeStamp: item.updatedAt);
        });

        return _api.json(offer.toMap(Convention.camel));
      });

  // /v1/offer
  Router get router {
    final router = Router();
    router.get("/client/<clientId|${_api.idRegExp}>", _listClient);
    router.get("/<offerId|${_api.idRegExp}>", _detail);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
