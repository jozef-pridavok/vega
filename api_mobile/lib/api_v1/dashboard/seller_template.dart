import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../data_access_objects/card.dart";
import "../../data_access_objects/dashboard/program.dart";
import "../../data_access_objects/dashboard/program_reward.dart";
import "../../extensions/request_body.dart";
import "../check_role.dart";
import "../session.dart";

class SellerTemplateHandler extends ApiServerHandler {
  SellerTemplateHandler(super.api);

  Future<Response> _barber(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (!checkRoles(session, [UserRole.seller])) return api.forbidden(errorUserRoleMissing);

        final body = (await request.body.asJson) as JsonObject;
        if (body["clientId"] == null) return api.badRequest(errorMissingParameter("clientId"));

        final cardDao = CardDAO(session, context);
        final card = Card.fromMap({
          "cardId": uuid(),
          "clientId": body["clientId"],
          "name": "Cliente VIP",
        }, Convention.camel);
        final insertedCard = await cardDao.insert(card);
        if (insertedCard != 1) throw errorBrokenLogicEx("Client card not created");

        final programDao = ProgramDAO(session, context);
        final program = Program.fromMap({
          "programId": uuid(),
          "clientId": body["clientId"],
          "cardId": card.cardId,
          "type": ProgramType.reach.code,
          "validFrom": IntDate.now().value,
          "name": "Programa de descuentos",
          "description":
              "Visítanos regularmente, este programa te permitirá obtener descuentos en todos nuestros servicios de hasta el 7%.",
          "meta": {
            "orders": {"ratio": 1},
            "plural": {
              "few": "",
              "one": "Una visita",
              "two": "Dos visitas",
              "many": "",
              "zero": "Ninguna visita",
              "other": "{} visitas"
            },
            "actions": {"addition": "Añadir visita", "subtraction": "Restar visita"},
            "reservations": {"ratio": 1},
            "qrCodeScanning": {"ratio": 1}
          }
        }, Convention.camel);
        final insertedProgram = await programDao.insert(program);
        if (insertedProgram != 1) throw errorBrokenLogicEx("Client program not created");

        final rewardDao = RewardDAO(session, context);
        final reward1 = Reward.fromMap({
          "programRewardId": uuid(),
          "programId": program.programId,
          "name": "3% de descuento",
          "description": "Después de 3 visitas obtendrás un 3% de descuento en nuestros servicios.",
          "points": 3,
          "validFrom": IntDate.now().value,
        }, Convention.camel);
        final insertedReward1 = await rewardDao.insert(reward1);
        if (insertedReward1 != 1) throw errorBrokenLogicEx("Client reward 1 not created");

        final reward2 = Reward.fromMap({
          "programRewardId": uuid(),
          "programId": program.programId,
          "name": "5% de descuento",
          "description": "Después de 5 visitas obtendrás un 5% de descuento en nuestros servicios.",
          "points": 5,
          "validFrom": IntDate.now().value,
        }, Convention.camel);
        final insertedReward2 = await rewardDao.insert(reward2);
        if (insertedReward2 != 1) throw errorBrokenLogicEx("Client reward 2 not created");

        final reward3 = Reward.fromMap({
          "programRewardId": uuid(),
          "programId": program.programId,
          "name": "7% de descuento",
          "description": "Después de 7 visitas obtendrás un 7% de descuento en nuestros servicios.",
          "points": 7,
          "validFrom": IntDate.now().value,
        }, Convention.camel);
        final insertedReward3 = await rewardDao.insert(reward3);
        if (insertedReward3 != 1) throw errorBrokenLogicEx("Client reward 3 not created");

        return api.created({"affected": 1});
      });

  // /v1/dashboard/seller/template
  Router get router {
    final router = Router();

    router.post("/es-py.barber.01", _barber);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
