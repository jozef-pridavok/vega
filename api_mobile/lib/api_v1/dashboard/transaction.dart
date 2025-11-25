import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../../cache.dart";
import "../../data_access_objects/user.dart";
import "../../data_models/session.dart";
import "../../extensions/request_body.dart";
import "../../strings.dart";
import "../../utils/send_message.dart";
import "../../utils/storage.dart";
import "../check_role.dart";
import "../session.dart";

class TransactionHandler extends ApiServerHandler {
  TransactionHandler(super.api);

  Future<void> _sendMessage(
    Request request,
    ApiServerContext context,
    Session session,
    ActionType action,
    Map<String, dynamic> dbData,
    String trKey,
    int points, {
    String? rewardName,
  }) async {
    final clientLogo = api.storageUrl(dbData["client_logo"], StorageObject.client);
    final programImage = api.storageUrl(dbData["program_image"], StorageObject.program);

    final userId = dbData["user_id"] as String;
    final user = await UserDAO(session, context).selectById(userId);
    final userLanguage = user?.language ?? "en";
    final plural = (dbData["program_plural"] as Map).asStringMap;
    final digits = (dbData["digits"] as int?) ?? 0;

    await sendMessageToUser(api, session,
        messageTypes: [MessageType.pushNotification, MessageType.inApp],
        userId: userId,
        subject: dbData["program_name"],
        body: api.tr(userLanguage, trKey, namedArgs: {
          "userCardNumber": dbData["number"],
          "points":
              api.formatAmount(userLanguage, Plural.fromMap(plural, Convention.snake), points, digits: digits) ?? "?",
          if (rewardName != null) "rewardName": rewardName,
        }),
        payload: {
          "action": action.code.toString(),
          "clientId": session.clientId,
          "clientLogo": clientLogo,
          "clientLogoBh": dbData["client_logo_bh"],
          "cardId": dbData["card_id"],
          "userCardId": dbData["user_card_id"],
          "programId": dbData["program_id"],
          "programImage": programImage,
          "programImageBh": dbData["program_image_bh"],
        });
  }

  Future<dynamic> _transactionCheck(Request request, JsonObject body, {bool checkPoints = true}) async {
    final installationId = request.context["iid"] as String;
    final session = await api.getSession(installationId);
    if (!checkRoles(session, [UserRole.admin, UserRole.pos])) return api.forbidden(errorUserRoleMissing);

    if (checkPoints && (body["points"] is! int || body["points"] <= 0))
      return api.unauthorized(errorInvalidParameterRange("points", "int, > 0"));

    final userCardId = body["userCardId"];
    final programId = body["programId"];

    final sql = """
      SELECT uc.user_card_id, uc.user_id, uc.card_id, uc.client_id, uc.code_type, 
        uc.number, uc.active, cl.blocked AS client_blocked, cl.logo AS client_logo, 
        cl.logo_bh AS client_logo_bh, c.blocked AS card_blocked,
        p.program_id, p.name AS program_name, p.digits, p.valid_from, p.valid_to, 
        p.image AS program_image, p.image_bh AS program_image_bh, 
        COALESCE((p.meta->>'plural')::JSONB, '{}'::JSONB) AS program_plural
      FROM user_cards uc
      INNER JOIN cards AS c ON uc.card_id = c.card_id AND c.deleted_at IS NULL AND c.blocked = FALSE
      INNER JOIN clients AS cl ON uc.client_id = cl.client_id AND cl.deleted_at IS NULL AND cl.blocked = FALSE
      ${programId != null ? "INNER JOIN programs AS p ON p.client_id = cl.client_id AND p.card_id = uc.card_id AND p.program_id = @program_id AND p.deleted_at IS NULL AND p.blocked = FALSE " : ""}
      ${programId == null ? "INNER JOIN program_rewards AS pr ON pr.program_reward_id = @reward_id AND pr.deleted_at IS NULL AND pr.blocked = FALSE" : ""}
      ${programId == null ? "INNER JOIN programs AS p ON p.program_id = pr.program_id AND p.client_id = @client_id AND p.card_id = uc.card_id AND p.deleted_at IS NULL AND p.blocked = FALSE" : ""}
      WHERE ${userCardId != null ? "uc.user_card_id = @user_card_id AND uc.client_id = @client_id" : "uc.number = @number"}
    """
        .tidyCode();

    final sqlParams = <String, dynamic>{};

    if (programId != null)
      sqlParams["program_id"] = programId as String;
    else
      sqlParams["reward_id"] = body["rewardId"] as String;

    if (userCardId != null) {
      sqlParams["user_card_id"] = userCardId as String?;
      sqlParams["client_id"] = session.clientId;
    } else {
      sqlParams["number"] = body["number"] as String?;
    }

    log.verbose(sql);
    log.verbose(sqlParams.toString());

    final rows = await api.select(sql, params: sqlParams);
    if (rows.isEmpty) return api.notFound(errorObjectNotFound);

    final JsonObject checkData = rows.first;

    final clientId = checkData["client_id"];
    if (clientId != null && clientId != session.clientId) return api.unauthorized(errorUserRoleMissing);

    if (!checkData["active"]) return api.notAllowed(errorUserCardNotActive);

    if (checkData["card_blocked"]) return api.notAllowed(errorCardIsBlocked);

    final clientBlocked = checkData["client_blocked"];
    if (clientBlocked == null || clientBlocked) return api.notAllowed(errorClientIsBlocked);

    if (checkData["program_id"] == null) return api.notFound(errorObjectNotFound);

    final now = IntDate.now().value;

    final validFrom = IntDate.parseInt(checkData["valid_from"] as int?)?.value;
    final validTo = IntDate.parseInt(checkData["valid_to"] as int?)?.value;
    if ((validFrom != null && validFrom > now) || (validTo != null && validTo < now))
      return api.notAllowed(errorProgramIsNotActive);

    //if ((validFrom != null && (validFrom as DateTime).isAfter(now)) ||
    //    (validTo != null && (validTo as DateTime).isBefore(now))) return _api.notAllowed(errorProgramIsNotActive);

    return <String, dynamic>{"session": session, "checkData": checkData};
  }

  Future<Response> _addPoints(Request request) async => withRequestLog((context) async {
        final body = (await request.body.asJson) as JsonObject;
        final checkResponse = await _transactionCheck(request, body);
        if (checkResponse is Response) return checkResponse;

        final {"session": session as Session, "checkData": dbData as JsonObject} = checkResponse;

        final sql = """
          INSERT INTO loyalty_transactions
            (loyalty_transaction_id, client_id, card_id, program_id, user_id, user_card_id, 
              points, transaction_object_type, transaction_object_id, created_at, updated_at)
          VALUES 
            (@loyalty_transaction_id, @client_id, @card_id, @program_id, @user_id, @user_card_id, 
              @points, @object_type, @object_id, NOW(), NOW())
        """
            .tidyCode();

        final points = body["points"] as int;
        final userId = dbData["user_id"];
        final userCardId = dbData["user_card_id"];
        final sqlParams = <String, dynamic>{
          "loyalty_transaction_id": uuid(),
          "client_id": session.clientId,
          "card_id": dbData["card_id"],
          "program_id": dbData["program_id"],
          "user_id": userId,
          "user_card_id": userCardId,
          "points": points,
          "object_type": LoyaltyTransactionObjectType.pos.code,
          "object_id": session.userId,
        };

        log.verbose(sql);
        log.verbose(sqlParams.toString());

        final inserted = await api.insert(sql, params: sqlParams);
        if (inserted != 1) return api.internalError(errorBrokenLogicEx("Couldn't add points"));

        await Cache().clear(api.redis, CacheKeys.userUserCards(userId));
        await Cache().clear(api.redis, CacheKeys.userUserCard(userId, userCardId));

        await _sendMessage(
          request,
          context,
          session,
          ActionType.pointsReceived,
          dbData,
          LangKeys.messagePointsHasBeenAdded.tr(),
          points,
        );

        return api.json({"affected": inserted});
      });

  Future<Response> _spendPoints(Request request) async => withRequestLog((context) async {
        final body = (await request.body.asJson) as JsonObject;
        final checkResponse = await _transactionCheck(request, body);
        if (checkResponse is Response) return checkResponse;

        final {"session": session as Session, "checkData": dbData as JsonObject} = checkResponse;

        final sqlUserPoints = """
          SELECT points
          FROM view_loyalty_transaction_status
          WHERE user_id = @user_id AND program_id = @program_id
        """
            .tidyCode();

        final sqlParamsUserPoints = <String, dynamic>{
          "program_id": body["programId"] as String,
          "user_id": dbData["user_id"]
        };

        log.verbose(sqlUserPoints);
        log.verbose(sqlParamsUserPoints.toString());

        final rows = await api.select(sqlUserPoints, params: sqlParamsUserPoints);
        if (rows.isEmpty) return api.notAllowed(errorNotEnoughPoints);
        final JsonObject userPointsData = rows.first;
        if (userPointsData["points"] < body["points"]) return api.notAllowed(errorNotEnoughPoints);

        final sqlInsert = """
          INSERT INTO loyalty_transactions
            (loyalty_transaction_id, client_id, card_id, program_id, user_id, user_card_id, 
              points, transaction_object_type, transaction_object_id, created_at, updated_at)
          VALUES 
            (@loyalty_transaction_id, @client_id, @card_id, @program_id, @user_id, @user_card_id, 
              @points, @object_type, @object_id, NOW(), NOW())
        """
            .tidyCode();

        final points = body["points"] as int;
        final userId = dbData["user_id"];
        final userCardId = dbData["user_card_id"];
        final sqlParamsInsert = <String, dynamic>{
          "loyalty_transaction_id": uuid(),
          "client_id": session.clientId,
          "card_id": dbData["card_id"],
          "program_id": dbData["program_id"],
          "user_id": userId,
          "user_card_id": userCardId,
          "points": -points,
          "object_type": LoyaltyTransactionObjectType.pos.code,
          "object_id": session.userId,
        };

        log.verbose(sqlInsert);
        log.verbose(sqlParamsInsert.toString());

        final inserted = await api.insert(sqlInsert, params: sqlParamsInsert);
        if (inserted != 1) return api.internalError(errorBrokenLogicEx("Couldn't add points"));

        await Cache().clear(api.redis, CacheKeys.userUserCards(userId));
        await Cache().clear(api.redis, CacheKeys.userUserCard(userId, userCardId));

        await _sendMessage(
          request,
          context,
          session,
          ActionType.pointsSpent,
          dbData,
          LangKeys.messagePointsHasBeenSpent.tr(),
          points,
        );

        return api.json({"affected": inserted});
      });

  Future<Response> _requestReward(Request request) async => withRequestLog((context) async {
        final body = (await request.body.asJson) as JsonObject;
        final checkResponse = await _transactionCheck(request, body, checkPoints: false);
        if (checkResponse is Response) {
          return checkResponse;
        }

        final {"session": session as Session, "checkData": dbData as JsonObject} = checkResponse;

        final sqlProgram = """
          SELECT pr.program_reward_id, pr.points AS reward_points, pr.name,
            pr.valid_from, pr.valid_to, vlts.points as user_points
          FROM program_rewards pr
          LEFT JOIN view_loyalty_transaction_status vlts ON vlts.program_id = pr.program_id AND vlts.user_id = @user_id
          WHERE pr.program_reward_id = @program_reward_id AND pr.program_id = @program_id
        """
            .tidyCode();

        final sqlProgramParams = <String, dynamic>{
          "program_reward_id": body["rewardId"] as String?,
          "program_id": dbData["program_id"] as String,
          "user_id": dbData["user_id"],
        };

        log.verbose(sqlProgram);
        log.verbose(sqlProgramParams.toString());

        final rows = await api.select(sqlProgram, params: sqlProgramParams);
        if (rows.isEmpty) return api.notFound(errorObjectNotFound);

        final rewardData = rows.first;

        if (rewardData["user_points"] == null || rewardData["user_points"] < rewardData["reward_points"])
          return api.notAllowed(errorNotEnoughPoints);

        final now = IntDate.now().value;

        final validFrom = IntDate.parseInt(rewardData["valid_from"] as int?)?.value;
        final validTo = IntDate.parseInt(rewardData["valid_to"] as int?)?.value;

        if ((validFrom != null && validFrom > now) || (validTo != null && validTo < now)) {
          return api.notAllowed(errorProgramRewardIsNotActive);
        }

        //if ((rewardData["valid_from"] != null && (rewardData["valid_from"] as DateTime).isAfter(now)) ||
        //    (rewardData["valid_to"] != null && (rewardData["valid_to"] as DateTime).isBefore(now))) {
        //  return _api.notAllowed(errorProgramRewardIsNotActive);
        //}

        final sqlInsert = """
          INSERT INTO loyalty_transactions
            (loyalty_transaction_id, client_id, card_id, program_id, user_id, user_card_id, 
              points, transaction_object_type, transaction_object_id, created_at, updated_at)
          VALUES 
            (@loyalty_transaction_id, @client_id, @card_id, @program_id, @user_id, @user_card_id,
              @points, @object_type, @object_id, NOW(), NOW())
        """
            .tidyCode();

        final points = rewardData["reward_points"] as int;
        final userId = dbData["user_id"];
        final userCardId = dbData["user_card_id"];
        final sqlInsertParams = <String, dynamic>{
          "loyalty_transaction_id": uuid(),
          "client_id": session.clientId,
          "card_id": dbData["card_id"] as String,
          "program_id": dbData["program_id"] as String,
          "user_id": userId,
          "user_card_id": userCardId,
          "points": -points,
          "object_type": LoyaltyTransactionObjectType.programReward.code,
          "object_id": body["rewardId"] as String,
        };

        log.verbose(sqlInsert);
        log.verbose(sqlInsert.toString());

        final inserted = await api.insert(sqlInsert, params: sqlInsertParams);
        if (inserted != 1) return api.internalError(errorBrokenLogicEx("Couldn't redeem reward"));

        await Cache().clear(api.redis, CacheKeys.userUserCards(userId));
        await Cache().clear(api.redis, CacheKeys.userUserCard(userId, userCardId));

        await _sendMessage(
          request,
          context,
          session,
          ActionType.rewardsReceived,
          dbData,
          LangKeys.messagePointsHasBeenSpentBecauseReward.tr(),
          points,
          rewardName: rewardData["name"] as String?,
        );

        return api.json({"affected": inserted});
      });

  // /v1/dashboard/pos_transaction
  Router get router {
    final router = Router();
    router.post("/add", _addPoints);
    router.post("/spend", _spendPoints);
    router.post("/request_reward", _requestReward);

    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
