import "package:core_dart/core_algorithm.dart";
import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/dashboard/client.dart";
import "../../data_access_objects/dashboard/user_card.dart";
import "../../data_access_objects/user.dart";
import "../../implementations/api_shelf_v1.dart";
import "../../implementations/configuration_yaml.dart";
import "../../strings.dart";
import "../../utils/send_message.dart";
import "../check_role.dart";
import "../session.dart";

class ClientUserCardHandler extends ApiServerHandler {
  ClientUserCardHandler(super.api);

  /// Checks if QR code represents user identity. If so, returns userId, otherwise null.
  String? _isUserIdentity(CodeType type, String number) {
    if (type != CodeType.qr) return null;
    final qrBuilder = QrBuilder(
        (api.config as MobileApiConfig).secretQrCodeKey, "a", (api.config as MobileApiConfig).secretQrCodeEnv);
    return qrBuilder.parseUserIdentity(number);
  }

  /// Issues a new card to the user.
  /// Required roles: pos or admin
  /// Response status codes:  200, 204, 400, 401, 403, 404
  /// Error codes: 146, 150, 151, 152, 153, 200, 201, 202, 250, 251, 252, 300
  Future<Response> _issue(Request request, String cardId, String type, String value) async =>
      withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);

        final hasPosRole = session.userRoles.contains(UserRole.pos);
        final hasAdminRole = session.userRoles.contains(UserRole.admin);
        final allowedRoles = hasPosRole || hasAdminRole;
        if (!allowedRoles) return api.forbidden(errorUserRoleMissing);

        final codeType = CodeTypeCode.fromCodeOrNull(tryParseInt(type));
        if (codeType == null) return api.badRequest(errorInvalidParameterRange("codeType", "Enum"));

        final userDAO = UserDAO(session, context);
        final userCardDAO = UserCardDAO(context);

        String? userId = _isUserIdentity(codeType, value);
        String userLanguage = "en";
        if (userId == null) {
          final user = await userDAO.selectByUserCardNumber(value);
          userId = user?.userId;
          userLanguage = user?.language ?? "en";
          if (userId == null) return api.notFound(errorObjectNotFound);
        }

        final userCardId = await userCardDAO.issue(cardId, userId, session.clientId!);
        UserCard? userCard;
        if (userCardId != null) userCard = (await userCardDAO.select(userCardId));

        await Cache().clear(api.redis, CacheKeys.userUserCards(userId));
        await Cache().clearAll(api.redis, CacheKeys.userUserCard(userId, userCardId ?? "*"));

        await sendMessageToUser(api, session,
            messageTypes: [MessageType.pushNotification, MessageType.inApp],
            userId: userId,
            subject: userCard?.name ?? "Vega Cards",
            body: api.tr(userLanguage, LangKeys.messageYourCardHasBeenIssued.tr()),
            payload: {
              "action": ActionType.userCardCreated.code,
              "clientId": session.clientId,
              "cardId": cardId,
              "userCardId": userCardId,
            });

        return api.json({
          "affected": (userCardId?.isNotEmpty ?? false) ? 1 : 0,
          "userCard": userCard?.toMap(Convention.camel),
        });
      });

  /// Returns list of user cards. Url parameters:
  /// - filter: filter by card name, user card name or user card number (optional)
  /// - period: number of days to consider a user card activity/inactivity (optional, default: 7)
  ///     positive number: active cards (activity in the last period days)
  ///     zero: all cards
  ///     negative number: all inactive cards
  Future<Response> _list(Request request) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin])) return api.forbidden(errorUserRoleMissing);
        final query = request.url.queryParameters;
        final cardId = query["cardId"];
        final programId = query["programId"];
        final filter = query["filter"];
        final period = tryParseInt(query["period"]);
        final userCards = await ClientDAO(session, context)
            .selectUserCards(programId: programId, cardId: cardId, period: period, filter: filter);
        if (userCards == null) return api.noContent();
        final json = {
          "length": userCards.length,
          "userCards": userCards.map((userCard) => userCard.toMap(Convention.camel)).toList(),
        };
        return api.json(json);
      });

  Future<Response> _transactions(Request request, String userCardId) async => withRequestLog((context) async {
        final installationId = request.context["iid"] as String;
        final session = await api.getSession(installationId);
        if (session.clientId == null) return api.forbidden(errorNoClientId);
        if (!checkRoles(session, [UserRole.admin, UserRole.pos, UserRole.marketing]))
          return api.forbidden(errorUserRoleMissing);
        final transactions = await UserCardDAO(context).transactions(userCardId);
        final json = {
          "length": transactions.length,
          "transactions": transactions.map((transaction) => transaction.toMap(LoyaltyTransaction.camel)).toList(),
        };
        return api.json(json);
      });

  // /v1/dashboard/client_user_card
  Router get router {
    final router = Router();

    router.get("/", _list);
    router.post("/issue/<cardId|$idRegExp>/<type|[0-9]{1,3}>/<value|.{1,2048}>", _issue);
    router.get("/transactions/<userCardId|$idRegExp>", _transactions);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
