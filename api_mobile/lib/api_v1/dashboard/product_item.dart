import "dart:convert";
import "dart:io";

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:http_parser/http_parser.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/session.dart";
import "../../data_access_objects/dashboard/product_item.dart";
import "../../extensions/request_body.dart";
import "../../extensions/request_multipart.dart";
import "../../implementations/api_shelf_v1.dart";
import "../../utils/blur_hash.dart";
import "../../utils/storage.dart";
import "../check_role.dart";

class ProductItemHandler extends ApiServerHandler {
  ProductItemHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, UserRoles.client)) return api.forbidden(errorUserRoleMissing);

        final items = await ProductItemDAO(session, context).list();
        for (final item in items) {
          item.photo = api.storageUrl(item.photo, StorageObject.productItem, timeStamp: item.updatedAt);
        }
        final rows = items.map((row) => row.toMap(Convention.snake)).toList();
        return api.json({
          "length": rows.length,
          "productItems": rows,
        });
      });

  /// Creates new product_item.
  /// Required roles: pos or admin
  /// Response status codes: 201, 400, 401, 403, 500
  Future<Response> _createOrUpdate(Request request, String productItemId, bool create) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        JsonObject body = {};
        String? productItemPhoto;
        String? productItemPhotoBh;

        Future<void> processPart(Multipart part) async {
          final mediaType = MediaType.parse(part.headers["Content-Type"] ?? "");
          print(mediaType);
          if (mediaType.type == "application" && mediaType.subtype == "json") {
            body = jsonDecode(await part.readString());
          } else if (mediaType.type == "image") {
            if (productItemPhoto != null) api.log.warning("ProductItem image already set");
            productItemPhoto = "product_item_$productItemId.${mediaType.subtype}";
            final filePath = api.storagePath(productItemPhoto!, StorageObject.productItem);
            log.debug("Saving productItem photo to $filePath");
            final file = File(filePath);
            IOSink fileSink = file.openWrite();
            await part.pipe(fileSink);
            await fileSink.close();

            productItemPhotoBh = await getImageBhFromFile(filePath) ?? "";
          }
        }

        final contentType = request.headers["Content-Type"];
        var mediaType = MediaType.parse(contentType ?? "");
        if (mediaType.type == "application" && mediaType.subtype == "json") {
          body = (await request.body.asJson) as JsonObject;
        } else {
          if (request.isMultipart) {
            await for (final part in request.parts) {
              await processPart(part);
            }
          }
        }

        body[ProductItem.camel[ProductItemKeys.photo]!] = null;
        body[ProductItem.camel[ProductItemKeys.photoBh]!] = null;

        if (productItemPhoto != null) body[ProductItem.camel[ProductItemKeys.photo]!] = productItemPhoto;
        if (productItemPhotoBh != null) body[ProductItem.camel[ProductItemKeys.photoBh]!] = productItemPhotoBh;

        final dao = ProductItemDAO(session, context);
        final productItem = ProductItem.fromMap(body, Convention.camel);
        final affected = create ? await dao.insert(productItem) : await dao.update(productItem);
        return create ? api.created({"affected": affected}) : api.accepted({"affected": affected});
      });

  Future<Response> _create(Request request, String productItemId) => _createOrUpdate(request, productItemId, true);

  Future<Response> _update(Request request, String productItemId) => _createOrUpdate(request, productItemId, false);

  Future<Response> _patch(Request request, String productItemId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final archived = tryParseBool(body["archived"]);
        final blocked = tryParseBool(body["blocked"]);
        if (archived == null && blocked == null)
          return api.badRequest(errorBrokenLogicEx("archived and blocked are both null"));
        final patched = await ProductItemDAO(session, context).patch(
          productItemId,
          archived: archived,
          blocked: blocked,
        );
        return api.accepted({"affected": patched});
      });

  /// Changes ranks of one or multiple ProductItem(s).
  /// Required roles: pos or admin
  /// Response status codes: 202, 400, 401, 403, 404, 500
  /// Notes:
  ///  Body should look like this:
  /// { "reorder": ["productItem5", "productItem1", "productItem3" ... ] }
  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final productItems = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (productItems?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));
        final reordered = await ProductItemDAO(session, context).reorder(productItems!);
        return api.accepted({"affected": reordered});
      });

  // /v1/dashboard/product_item
  Router get router {
    final router = Router();

    router.get("/", _list);
    router.post("/<id|$idRegExp>", _create);
    router.put("/reorder", _reorder);
    router.put("/<id|$idRegExp>", _update);
    router.patch("/<id|$idRegExp>", _patch);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
