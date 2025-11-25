import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";
import "../strings.dart";
import "user.dart";

class ClientPaymentDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ClientPaymentDAO(this.session, this.context) : super(context.api);

  Future<List<ClientPayment>> readAll({bool onlyUnpaid = false, IntDate? dateFrom, IntDate? dateTo}) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT 
            ARRAY(SELECT JSONB_ARRAY_ELEMENTS_TEXT((c.meta->'license'->>'providers')::JSONB)) AS providers,
            (c.meta->'license'->>'base')::INT AS base,
            (c.meta->'license'->>'pricing')::INT AS pricing,
            c.meta->'license'->>'currency' AS currency,
            cp.client_payment_id, cp.client_id, cp.seller_id, cp.status, cp.period, cp.client_payment_provider_id, 
            cp.active_cards, cp.pricing, cp.currency, cp.period_from, cp.period_to, cp.due_date, cp.seller_payment_id,
            cp.meta->'items' AS items,
            ((u.meta->'seller'->>'firstName')::TEXT || ' ' || (u.meta->'seller'->>'lastName')::TEXT) AS seller_info
          FROM client_payments cp
          INNER JOIN clients c ON c.client_id = cp.client_id
          INNER JOIN users u ON u.user_id = cp.seller_id
          WHERE cp.client_id = @client_id
            ${dateFrom != null ? 'AND cp.period_from >= @date_from' : ''} 
            ${dateTo != null ? 'AND cp.period_to <= @date_to' : ''} 
            ${onlyUnpaid ? 'AND cp.paid_at IS NULL' : ''} 
          ORDER BY cp.period DESC
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": session.clientId};
        if (dateFrom != null) sqlParams["date_from"] = dateFrom.value;
        if (dateTo != null) sqlParams["date_to"] = dateTo.value;

        log.logSql(context, sql, sqlParams);

        //final language = session.language ?? "en";
        final user = await UserDAO(session, context).selectById(session.userId);
        final language = user?.language ?? session.language ?? "en";

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) {
          final pricing = row["pricing"];
          final currency = CurrencyCode.fromCode(row["currency"] as String?);
          final translatedItems = {};
          (row["items"] as JsonObject?)?.keys.forEach((key) {
            // ignore: unused_local_variable
            final k1 = LangKeys.clientPaymentItemBasicPrice.tr();
            // ignore: unused_local_variable
            final k2 = LangKeys.clientPaymentItemCardsPrice.tr();
            // ignore: unused_local_variable
            final k3 = LangKeys.clientPaymentItemTotalPrice.tr();
            translatedItems[api.tr(language, key)] = row["items"][key];
          });

          final mapper = ClientPayment.snake;
          row[mapper[ClientPaymentKeys.priceInfo]!] = currency.formatSymbol(pricing, language);
          row[mapper[ClientPaymentKeys.items]!] = translatedItems.asStringMap;

          return ClientPayment.fromMap(row, ClientPayment.snake);
        }).toList();
      });

  Future<List<ClientPayment>> forSeller(String sellerId,
          {bool onlyReadyForRequest = false,
          bool onlyWaitingForClient = false,
          IntDate? dateFrom,
          IntDate? dateTo}) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT 
            cp.base,
            cp.pricing,
            cp.currency,
            c.name as client_name,
            cp.client_payment_id, cp.client_id, cp.seller_id, cp.status, cp.period, cp.client_payment_provider_id, 
            cp.active_cards, cp.pricing, cp.currency, cp.period_from, cp.period_to, cp.due_date, cp.seller_payment_id,        
            cs.share AS seller_share
          FROM client_sellers cs
          INNER JOIN clients c ON c.client_id = cs.client_id      
          INNER JOIN client_payments cp ON cp.client_id = c.client_id AND cp.seller_id = cs.seller_id
          INNER JOIN users u ON u.user_id = cp.seller_id
          WHERE 
            cs.seller_id = @seller_id
            ${onlyReadyForRequest ? 'AND cp.status = ${ClientPaymentStatus.paid.code} AND cp.seller_payment_id IS NULL ' : ''} 
            ${onlyWaitingForClient ? 'AND cp.status != ${ClientPaymentStatus.paid.code} ' : ''} 
            ${dateFrom != null ? 'AND cp.period_from >= @date_from ' : ''} 
            ${dateTo != null ? 'AND cp.period_to <= @date_to ' : ''}         
          ORDER BY cp.period DESC
        """;

        final sqlParams = <String, dynamic>{"seller_id": sellerId};
        if (dateFrom != null) sqlParams["date_from"] = dateFrom.value;
        if (dateTo != null) sqlParams["date_to"] = dateTo.value;

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => ClientPayment.fromMap(row, ClientPayment.snake)).toList();
      });

  Future<(int, int)> updatePayment(
    String providerId,
    String clientId,
    List<String> payments,
    JsonObject? payload,
    ClientPaymentStatus status,
  ) async =>
      withSqlLog(context, () async {
        String sql = """
          UPDATE client_payments SET
            client_payment_provider_id = @client_payment_provider_id,
            status = ${status.code},
            updated_at = NOW(),
            ${status == ClientPaymentStatus.paid ? "paid_at = NOW(), " : ""}
            meta = JSONB_SET(COALESCE(meta,'{}'), '{providerPayload_${status.name}}', @payload::JSONB, TRUE)
          WHERE 
            client_id=@client_id AND client_payment_id IN (${payments.map((e) => "'$e'").join(",")});
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_payment_provider_id": providerId,
          "client_id": clientId,
          "payload": payload,
        };

        log.logSql(context, sql, sqlParams);

        final affectedPayments = await api.update(sql, params: sqlParams);
        int affectedClient = 0;

        if (affectedPayments > 0 && status == ClientPaymentStatus.paid) {
          IntDate validTo;

          final firstUnpaid = await firstUnpaidPeriod(clientId);
          if (firstUnpaid != null) {
            final period = firstUnpaid.toDate().startOfMonth;
            final previousMonth = DateTime(period.year, period.month - 1, period.day);
            validTo = IntDate.fromDate(previousMonth.endOfMonth);
          } else {
            final lastPaid = await lastPaidPeriod(clientId) ?? IntDate.fromInt(20221232);
            final period = lastPaid.toDate().startOfMonth;
            final nextMonth = DateTime(period.year, period.month + 1, period.day);
            // za obdobie 6/2024 musí zaplatiť do 31.7.2024... prepočet mu môže zbehnúť 1.8.2024 takže má málo času
            //validTo = IntDate.fromDate(nextMonth.endOfMonth);
            validTo = IntDate.fromDate(nextMonth.endOfMonth.addDays(14));
          }

          sql = """
            UPDATE clients SET
              meta=JSONB_SET(meta, '{license,validTo}', @valid_to::JSONB, TRUE),
              updated_at = NOW()
            WHERE client_id= @client_id;
          """
              .tidyCode();

          sqlParams["valid_to"] = validTo.value;

          log.logSql(context, sql, sqlParams);

          affectedClient = await api.update(sql, params: sqlParams);
        }

        return (affectedPayments, affectedClient);
      });

  Future<IntDate?> firstUnpaidPeriod(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT period_to FROM client_payments 
          WHERE client_id = @client_id AND status != 4
          ORDER BY period ASC
          LIMIT 1
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": clientId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return null;

        return IntDate.parseInt(rows.first["period_to"] as int?);
      });

  Future<IntDate?> lastPaidPeriod(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT period_to FROM client_payments 
          WHERE client_id = @client_id AND status = 4
          ORDER BY period DESC
          LIMIT 1
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": clientId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return null;

        return IntDate.parseInt(rows.first["period_to"] as int?);
      });
}

// eof
