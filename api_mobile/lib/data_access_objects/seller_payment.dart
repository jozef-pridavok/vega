import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";

class SellerPaymentDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  SellerPaymentDAO(this.session, this.context) : super(context.api);

  Future<List<SellerPayment>> readAll({
    required bool onlyUnpaid,
    IntDate? dateFrom,
    IntDate? dateTo,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT 
            sp.seller_payment_id, sp.client_id, sp.seller_id, sp.seller_invoice, sp.status, sp.total_price, sp.total_currency, sp.due_date, sp.paid_at, sp.seller_invoice,
            c.name as client_name,
            cs.share AS seller_share
          FROM seller_payments sp
          INNER JOIN clients c ON c.client_id = sp.client_id
          INNER JOIN client_sellers cs ON cs.client_id = sp.client_id AND cs.seller_id = sp.seller_id
          WHERE 
            sp.seller_id = @seller_id
            ${onlyUnpaid ? 'AND sp.paid_at IS NULL' : ''}         
            ${dateFrom != null ? "AND sp.created_at >= @from" : ""}
            ${dateTo != null ? "AND sp.created_at <= @to" : ""}
          ORDER BY sp.seller_invoice DESC
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"seller_id": session.userId};
        if (dateFrom != null) sqlParams["from"] = dateFrom.value;
        if (dateTo != null) sqlParams["to"] = dateTo.value;

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => SellerPayment.fromMap(row, SellerPayment.snake)).toList();
      });

  Future<SellerPayment> request(List<String> clientPaymentIds, String sellerInvoiceNumber, IntDate? dueDate) async =>
      withSqlLog(context, () async {
        String sql = """
          SELECT cp.*, cs.share AS seller_share
          FROM client_payments cp 
          INNER JOIN client_sellers cs ON cp.client_id = cs.client_id AND cp.seller_id = cs.seller_id 
          WHERE 
              cp.seller_payment_id IS NULL AND cs.seller_id = @seller_id AND cp.status = 4 AND cp.paid_at IS NOT NULL
              AND cp.client_payment_id = ANY(@client_payment_ids)
        """
            .tidyCode();

        Map<String, dynamic> sqlParams = {
          "seller_id": session.userId,
          "client_payment_ids": clientPaymentIds,
        };

        log.logSql(context, sql, sqlParams);

        var rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) throw errorBrokenLogicEx("No client payments");

        if (clientPaymentIds.length != rows.length) throw errorBrokenLogicEx("Client payments does not match");

        final clientPayments = rows.map((row) => ClientPayment.fromMap(row, ClientPayment.snake)).toList();

        final sellerId = session.userId;
        final clientId = clientPayments.first.clientId;
        final currency = clientPayments.first.currency;
        int totalPrice = 0;

        for (final clientPayment in clientPayments) {
          if (clientPayment.currency != currency) {
            throw errorBrokenLogicEx("Client payments must have the same currency");
          }
          // FLOOR(((cp.base + (cp.active_cards * cp.pricing)) * cs.share) / 10000.0),
          final base = clientPayment.base;
          final activeCards = clientPayment.activeCards;
          final pricing = clientPayment.pricing;
          final sellerShare = clientPayment.sellerShare ?? 0;
          final clientPrice = ((base + (activeCards * pricing)) * sellerShare / 10000.0).floor();
          totalPrice += clientPrice;
        }

        sql = """
          INSERT INTO seller_payments (seller_payment_id, client_id, seller_id, seller_invoice, status, total_price, total_currency, due_date)
          VALUES (@seller_payment_id, @client_id, @seller_id, @seller_invoice, @status, @total_price, @total_currency, @due_date)
        """
            .tidyCode();

        final sellerPaymentId = uuid();

        sqlParams = <String, dynamic>{
          "seller_payment_id": sellerPaymentId,
          "seller_id": sellerId,
          "client_id": clientId,
          "seller_invoice": sellerInvoiceNumber,
          "status": SellerPaymentStatus.pending.code,
          "total_price": totalPrice,
          "total_currency": currency.code,
          "due_date": dueDate?.value,
        };

        log.logSql(context, sql, sqlParams);

        final inserted = await api.insert(sql, params: sqlParams);
        if (inserted != 1) throw errorBrokenLogicEx("Seller payment not created");

        sql = """
          UPDATE client_payments
            SET seller_payment_id = @seller_payment_id
          WHERE         
            seller_id = @seller_id AND client_id = @client_id
            AND client_payment_id = ANY(@client_payment_ids)
        """;

        sqlParams = <String, dynamic>{
          "seller_payment_id": sellerPaymentId,
          "seller_id": sellerId,
          "client_id": clientId,
          "client_payment_ids": clientPaymentIds,
        };

        log.logSql(context, sql, sqlParams);

        final updated = await api.update(sql, params: sqlParams);
        if (updated != clientPaymentIds.length) throw errorBrokenLogicEx("Client payments not updated");

        sql = """
          SELECT sp.*, c.name as client_name, cs.share AS seller_share 
          FROM seller_payments sp
          INNER JOIN clients c ON c.client_id = sp.client_id
          INNER JOIN client_sellers cs ON cs.client_id = sp.client_id AND cs.seller_id = sp.seller_id
          WHERE sp.seller_payment_id = @seller_payment_id AND sp.seller_id = @seller_id AND sp.client_id = @client_id
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) throw errorBrokenLogicEx("Seller payment not found");
        return SellerPayment.fromMap(rows.first, SellerPayment.snake);
      });
}

// eof
