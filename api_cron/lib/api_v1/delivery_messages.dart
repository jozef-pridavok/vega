import "dart:convert";

//import "dart:math";

import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../implementations/api_shelf.dart";
import "cron_handler.dart";
import "data_access_objects/message.dart";
import "messages/message.dart";

class DeliveryMessageHandler extends CronHandler<int> {
  final ProcessMessageHandler _implementation;

  DeliveryMessageHandler(CronApi api)
      : _implementation = ProcessMessageHandler(api: api),
        super("DeliveryMessages", api);

  @override
  Future<JsonObject> process(ApiServerContext context, int param /*batchSize*/) async {
    // zoberiem najstaršie správy zo zoznamu čakajúcich správ, správy už nebudú v zozname
    final queue = await api.redis(["LPOP", CacheKey.shared("messages:waiting_queue"), param]) as List<dynamic>?;
    if (queue == null || queue.isEmpty) {
      return {"total": 0, "message": "No messages to process."};
    }

    int totalCount = queue.length;
    int expiredCount = 0;
    int deliveredCount = 0;
    int failedCount = 0;

    final messageDAO = MessageDAO(context);

    /*
          // vymažem spracovávané správy z mnnožiny čakajúcich správ, správy už nebudú v množine
          await _api.redis(["SREM", CacheKey.shared("messages:waiting_set"), ...queue]);
          */

    for (final deliveryMessageId in queue) {
      // poznačím si či expirovala
      final expired = (await api.redis(["GET", CacheKey.shared("messages:data:$deliveryMessageId")])) == null;
      // každopádne ju spracovávam, takže vymažem ostatné z cache (jej dáta neskôr, nižšie, ref na db id teraz)
      // zapamätám si ale databázové id, aby som nastavil potom status
      final messageId = await api.redis(["HGET", CacheKey.shared("messages:db"), deliveryMessageId]);
      // vymažem referenciu na dáta
      await api.redis(["HDEL", CacheKey.shared("messages:db"), deliveryMessageId]);

      if (expired) {
        // ak expirovala, označím ju v db za expirovanú
        if (messageId != null) {
          expiredCount += await messageDAO.setMessageStatus(messageId, MessageStatus.expired) ? 1 : 0;
        }
        continue;
      }

      // vezmen si dáta správy
      final deliveryMessageData = await api.redis(
        ["HGETALL", CacheKey.shared("messages:data:$deliveryMessageId")],
      ) as List<dynamic>;

      DeliveryMessage? deliveryMessage;
      try {
        final deliveryMessageJson = Map.fromIterables(
          deliveryMessageData.where((element) => deliveryMessageData.indexOf(element).isEven).cast<String>(),
          deliveryMessageData.where((element) => deliveryMessageData.indexOf(element).isOdd),
        );
        deliveryMessage = DeliveryMessage.fromJsonForRedis(deliveryMessageJson);
      } catch (ex) {
        log.error("Error while parsing delivery message data: $deliveryMessageData");
      }

      // vymažem dáta správy
      await api.redis(
        ["DEL", CacheKey.shared("messages:data:$deliveryMessageId")],
      );

      // odošlem správu
      final sent = deliveryMessage != null ? await _sendMessage(messageDAO, deliveryMessage) : false;

      deliveredCount += sent ? 1 : 0;
      failedCount += sent ? 0 : 1;
    }

    final json = {
      "total": totalCount,
      "expired": expiredCount,
      "delivered": deliveredCount,
      "failed": failedCount,
    };
    await recordLastRun(json);
    return json;
  }

  Future<Response> _deliverMessages(Request req) async => withRequestLog((context) async {
        log.logRequest(context, req.toLogRequest());
        final query = req.url.queryParameters;
        final batchSize = tryParseInt(query["batch"]) ?? 1000;
        final json = await execute(context, batchSize);
        api.log.verbose(json, jsonEncode);
        return api.json(json);
      });

  Future<bool> _sendMessage(MessageDAO messageDAO, DeliveryMessage deliveryMessage) async {
    final implementation = _implementation.determine(deliveryMessage);
    if (implementation == null) {
      api.log.warning(
        "Unexpected message type: ${deliveryMessage.messageType} for message id: ${deliveryMessage.messageId}",
      );
      return false;
    }
    final (sent, response) = await implementation.process(deliveryMessage);
    return await messageDAO.setMessageStatus(
      deliveryMessage,
      sent ? MessageStatus.sent : MessageStatus.failed,
      response: response,
    );
  }

  // /v1/delivery_message/
  Router get router {
    final router = Router();

    router.get("/", _deliverMessages);
    router.all("/<ignored|.*>", (Request request) => Response.notFound("404"));

    return router;
  }
}

// eof
