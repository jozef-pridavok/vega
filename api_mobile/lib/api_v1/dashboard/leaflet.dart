import "dart:io";
import "dart:typed_data";

import "package:collection/collection.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../api_v1/session.dart";
import "../../data_access_objects/leaflet.dart";
import "../../extensions/request_body.dart";
import "../../implementations/api_shelf_v1.dart";
import "../../utils/blur_hash.dart";
import "../../utils/storage.dart";
import "../check_role.dart";

class LeafletHandler extends ApiServerHandler {
  LeafletHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);

        if (!checkRoles(session, [UserRole.admin, UserRole.marketing])) return api.forbidden(errorUserRoleMissing);

        final query = request.url.queryParameters;
        final filter = int.tryParse(query["filter"] ?? "") ?? 1;

        final leaflets = await LeafletDAO(session, context).select(filter);
        if (leaflets.isEmpty) return api.noContent();

        final json = leaflets.map((leaflet) {
          leaflet.pages.forEachIndexed(
            (index, page) {
              leaflet.pages[index] = api.storageUrl(page, StorageObject.leaflet, timeStamp: leaflet.updatedAt)!;
            },
          );
          leaflet.thumbnail = api.storageUrl(leaflet.thumbnail, StorageObject.leaflet, timeStamp: leaflet.updatedAt);
          return leaflet.toMap(Leaflet.camel);
        }).toList();
        return api.json({
          "length": json.length,
          "leaflets": json,
        });
      });

  Future<(String, String)> _saveImage(String leafletId, int index, List<int> bytes) async {
    String leafletPage = "leaflet_${leafletId}_$index.jpg";
    final filePath = api.storagePath(leafletPage, StorageObject.leaflet);
    log.debug("Saving leaflet page to $filePath");
    final file = File(filePath);
    await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
    String leafletPageBh = await getImageBhFromFile(filePath) ?? "";
    return (leafletPage, leafletPageBh);
  }

  Future<Response> _create(Request request, String leafletId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.marketing])) return api.forbidden(errorUserRoleMissing);

        JsonObject body = {};
        body = (await request.body.asJson) as JsonObject;
        final pages = body["pages"] as List<dynamic>;
        final pagesBh = body["pagesBh"] as List<dynamic>;
        if (pagesBh.length < pages.length) pagesBh.addAll(List.filled(pages.length - pagesBh.length, ""));
        final thumbnail = body["thumbnail"] as String?;
        final thumbnailBh = body["thumbnailBh"] as String?;
        for (final (index, image) in pages.indexed) {
          try {
            final (page, pageBh) = await _saveImage(leafletId, index, image.cast<int>().toList());
            pages[index] = page;
            pagesBh[index] = pageBh;
          } catch (ex, st) {
            // TODO: to by som si mal pozna, stčiť index a na konci vymazať všetky fail-nuté indexy z poľa preč
            log.error(ex.toString());
            log.error(st.toString());
            pages[index] = "";
            pagesBh[index] = "";
          }
        }

        body[Leaflet.camel[LeafletKeys.pages]!] = pages;
        body[Leaflet.camel[LeafletKeys.pagesBh]!] = pagesBh;
        body[Leaflet.camel[LeafletKeys.thumbnail]!] = thumbnail;
        body[Leaflet.camel[LeafletKeys.thumbnailBh]!] = thumbnailBh;

        final leaflet = Leaflet.fromMap(body, Leaflet.camel);
        final inserted = await LeafletDAO(session, context).insert(leaflet);
        return api.created({"affected": inserted});
      });

  Future<Response> _update(Request request, String leafletId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.marketing])) return api.forbidden(errorUserRoleMissing);

        JsonObject body = {};
        body = (await request.body.asJson) as JsonObject;
        final pages = body["pages"] as List<dynamic>;
        final pagesBh = body["pagesBh"] as List<dynamic>;
        // ensure that pagesBh is at least as long as pages
        if (pagesBh.length < pages.length) pagesBh.addAll(List.filled(pages.length - pagesBh.length, ""));
        final thumbnail = body["thumbnail"] as String?;
        final thumbnailBh = body["thumbnailBh"] as String?;
        for (final (index, image) in pages.indexed) {
          if (image is String) {
            pages[index] = api.stripStorageUrl(pages[index], StorageObject.leaflet);
          } else if (image is List<dynamic>) {
            try {
              final (page, pageBh) = await _saveImage(leafletId, index, image.cast<int>().toList());
              pages[index] = page;
              pagesBh[index] = pageBh;
            } catch (ex, st) {
              // TODO: to by som si mal pozna, stčiť index a na konci vymazať všetky fail-nuté indexy z poľa preč
              log.error(ex.toString());
              log.error(st.toString());
              pages[index] = "";
              pagesBh[index] = "";
            }
          }
        }

        body[Leaflet.camel[LeafletKeys.pages]!] = pages;
        body[Leaflet.camel[LeafletKeys.pagesBh]!] = pagesBh;
        body[Leaflet.camel[LeafletKeys.thumbnail]!] = thumbnail;
        body[Leaflet.camel[LeafletKeys.thumbnailBh]!] = thumbnailBh;

        final leaflet = Leaflet.fromMap(body, Leaflet.camel);
        final updated = await LeafletDAO(session, context).update(leaflet);
        return api.accepted({"affected": updated});
      });

  Future<Response> _patch(Request request, String leafletId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.admin, UserRole.marketing])) return api.forbidden(errorUserRoleMissing);
        final body = (await request.body.asJson) as JsonObject;
        final start = tryParseBool(body["start"]);
        final finish = tryParseBool(body["finish"]);
        final blocked = tryParseBool(body["blocked"]);
        final archived = tryParseBool(body["archived"]);
        if (start == null && finish == null && blocked == null && archived == null)
          return api.badRequest(errorBrokenLogicEx("start, finish, blocked or archived"));
        final patched = await LeafletDAO(session, context).patch(
          leafletId,
          start: start,
          finish: finish,
          blocked: blocked,
          archived: archived,
        );
        return api.accepted({"affected": patched});
      });

  Future<Response> _reorder(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.marketing])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject?;
        final leaflets = (body?["reorder"] as List<dynamic>?)?.cast<String>();
        if (leaflets?.isEmpty ?? true) return api.badRequest(errorInvalidParameterType("[]", "list of strings"));
        final reordered = await LeafletDAO(session, context).reorder(leaflets!);
        return api.accepted({"affected": reordered});
      });

  // /v1/dashboard/leaflet
  Router get router {
    final router = Router();

    router.put("/reorder", _reorder);

    router.post("/<id|$idRegExp>", _create);
    router.put("/<id|$idRegExp>", _update);
    router.patch("/<id|$idRegExp>", _patch);

    router.get("/", _list);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
