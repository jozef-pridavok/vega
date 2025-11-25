import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

class ClientPaymentDAO extends ApiServerDAO {
  final ApiServerContext context;

  ClientPaymentDAO(this.context) : super(context.api);

  Future<JsonObject> recalculate() async => withSqlLog(context, () async {
        /*
          UPDATE user_cards SET touched_at = NOW() WHERE deleted_at IS NULL
        */
        var sql = """
          SELECT cs.client_seller_id, cs.seller_id, cs.client_id,
            (c.meta#>'{license,base}')::INT AS base, 
            (c.meta#>'{license,pricing}')::INT AS pricing, 
            (c.meta#>>'{license,currency}') AS currency,
            (
              SELECT COUNT(*)
              FROM user_cards uc
              WHERE uc.client_id = c.client_id AND uc.deleted_at IS NULL AND uc.active = TRUE AND
                    uc.touched_at >= NOW() - MAKE_INTERVAL(days => COALESCE((c.meta#>'{license,activityPeriod}')::INT, 30))
            ) as active_cards
          FROM client_sellers cs
          INNER JOIN users u ON cs.seller_id = u.user_id 
          INNER JOIN clients c ON cs.client_id = c.client_id
          WHERE u.blocked = FALSE AND cs.deleted_at IS NULL AND cs.blocked = FALSE AND c.meta IS NOT NULL AND c.deleted_at IS NULL AND
            c.meta#>'{license,base}' IS NOT NULL AND c.meta#>'{license,pricing}' IS NOT NULL AND c.meta#>>'{license,currency}' IS NOT NULL AND
            (
                (c.meta#>'{cron,clientPayments}' IS NULL)
                OR
                (                
                    (c.meta#>>'{cron,clientPayments}')::TIMESTAMP WITH TIME ZONE 
                    <= 
                    (DATE_TRUNC('month', NOW() - INTERVAL '1 month') + INTERVAL '1 month - 1 day')::DATE                          
                )
            )
        """;

        log.logSql(context, sql);

        final rowsToCalc = await api.select(sql);
        if (rowsToCalc.isEmpty) {
          return {"total": 0, "updated": 0, "result": [], "message": "No clients to recalculate"};
        }

        log.verbose("Recalculating client payments for ${rowsToCalc.length} clients");

        final now = DateTime.now();
        final previousMonth = DateTime(now.year, now.month - 1, now.day);
        final period = previousMonth.yyyymm;
        final periodFrom = previousMonth.startOfMonth.yyyymmdd;
        final periodTo = previousMonth.endOfMonth.endOfDay.yyyymmdd;
        final dueDate = now.startOfMonth.addDays(21); // DateTimeExtensions.endOfThisMonth.yyyymmdd;

        sql = """
              DELETE FROM client_payments
              WHERE period_from = @period_from AND period_to = @period_to AND status = @status AND
                client_id = ANY(@client_ids)
            """;

        var sqlParams = <String, dynamic>{
          "period_from": periodFrom,
          "period_to": periodTo,
          "client_ids": rowsToCalc.map((row) => row["client_id"]).toList(),
          "status": ClientPaymentStatus.pending.code,
        };

        log.logSql(context, sql, sqlParams);

        int deleted = await api.delete(sql, params: sqlParams);
        api.log.verbose("Deleted $deleted rows");

        sql = """
          UPDATE clients
          SET 
            meta = JSONB_SET(COALESCE(meta, '{}'::jsonb), '{cron}', '{}'::jsonb, TRUE)
          WHERE
            client_id = ANY(@client_ids) AND meta#>'{cron}' IS NULL
        """;

        log.logSql(context, sql, sqlParams);

        int updated = await api.update(sql, params: sqlParams);
        api.log.verbose("Updated $deleted rows - Creating meta");

        // loop

        sql = """
            INSERT INTO client_payments (
              client_payment_id, client_id, seller_id, status, period, active_cards, base, pricing, currency, period_from, period_to, due_date, meta
            ) VALUES (
              @client_payment_id, @client_id, @seller_id, @status, @period, @active_cards, @base, @pricing, @currency, @period_from, @period_to, @due_date, @meta
            )
          """;

        final res = await Future.wait<(String, int)>(rowsToCalc.map((row) async {
          final clientId = row["client_id"] as String;

          final clientPaymentId = uuid();
          final sellerId = row["seller_id"];
          final activeCards = row["active_cards"] as int;
          final currency = CurrencyCode.fromCode(row["currency"] as String);
          final base = row["base"] as int;
          final pricing = row["pricing"] as int;
          final cardsPrice = activeCards * pricing;
          final price = base + cardsPrice;

          final sqlParams = <String, dynamic>{
            "client_payment_id": clientPaymentId,
            "client_id": clientId,
            "seller_id": sellerId,
            "status": ClientPaymentStatus.pending.code,
            "active_cards": activeCards,
            "base": base,
            "pricing": pricing,
            "currency": currency.code,
            "period": period,
            "period_from": periodFrom,
            "period_to": periodTo,
            "due_date": IntDate.fromDate(dueDate).value,
            "meta": {
              "items": {
                "client_payment_item_basic_price": Price(base, currency).toMap(),
                "client_payment_item_cards_price": Price(cardsPrice, currency).toMap(),
                "client_payment_item_total_price": Price(price, currency).toMap(),
              }
            }
          };

          log.logSql(context, sql, sqlParams);

          final inserted = await api.insert(sql, params: sqlParams);
          api.log.verbose("Inserted $inserted rows");

          return (clientId, inserted);
        }));

        final clientIds = res.where((e) => e.$2 == 1).map((e) => e.$1).toList();

        sql = """
              UPDATE clients
                SET meta = JSONB_SET(meta, '{cron,clientPayments}', TO_JSON(NOW())::JSONB, TRUE)
              WHERE client_id = ANY(@client_id) AND deleted_at IS NULL
            """;

        sqlParams = <String, dynamic>{
          "client_id": clientIds,
        };

        log.logSql(context, sql, sqlParams);

        updated = await api.update(sql, params: sqlParams);
        api.log.verbose("Updated $updated rows");

        return {
          "total": rowsToCalc.length,
          "updated": updated,
          "result": res.map((e) => {"clientId": e.$1, "updated": e.$2}).toList()
        };
      });
}

// eof
