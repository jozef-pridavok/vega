import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/client_payment_provider.dart";
import "../check_role.dart";
import "../session.dart";

class PaymentProviderHandler extends ApiServerHandler {
  PaymentProviderHandler(super.api);

  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);

        if (!checkRoles(session, [UserRole.admin, UserRole.pos, UserRole.seller]))
          return api.forbidden(errorUserRoleMissing);

        final providers = await ClientPaymentProviderDAO(context).select();
        if (providers.isEmpty) return api.noContent();

        return api.json({
          "length": providers.length,
          "providers": providers.map((e) => e.toMap(ClientPaymentProvider.camel)).toList(),
        });
      });

  // /v1/dashboard/payment-provider/
  Router get router {
    final router = Router();

    router.get("/", _list);

    return router;
  }
}

// eof
