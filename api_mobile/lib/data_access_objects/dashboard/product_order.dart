import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ProductOrderDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ProductOrderDAO(this.session, this.context) : super(context.api);

  Future<List<UserOrder>> list({required int filter, int? limit}) async => withSqlLog(context, () async {
        final sql = """
          SELECT po.product_order_id AS order_id, po.product_offer_id AS offer_id, po.client_id, po.location_id, po.user_id,
          po.user_card_id, po.notes, po.status, po.cancelled_reason, po.cancelled_by_user_id, po.cancelled_at,
          po.total_price, po.total_price_currency, po.delivery_type, po.delivery_date, po.deliver_price,
          po.deliver_currency, po.delivery_address_id, po.meta, po.created_at,
          COALESCE(u.meta->'clients'->'${session.clientId}'->>'displayName', u.nick) AS user_nickname,
          ua.address_line_1 AS delivery_address_line_1, ua.address_line_2 AS delivery_address_line_2, 
          ua.city AS delivery_city,
                  TO_JSON(ARRAY(
                    SELECT json_build_object(
                           'item_id', poi.product_order_item_id,
                           'order_id', poi.product_order_id,
                           'offer_id', po.product_offer_id,
                           'qty', poi.qty,
                           'name', pi.name,
                           'price', pi.price,
                           'currency', pi.currency,
                           'qty_precision', pi.qty_precision,
                           'unit', pi.unit,
                           'photo', pi.photo,
                           'photo_bh', pi.photo_bh,
                           'modifications', TO_JSON(ARRAY(
                                SELECT json_build_object(
                                    'modification_id', pim.product_item_modification_id,
                                    'name', pim.name,
                                    'options', TO_JSON(ARRAY(
                                                    SELECT json_build_object(
                                                        'option_id', pio.product_item_option_id,
                                                        'modification_id', pio.product_item_modification_id,
                                                        'name', pio.name,
                                                        'price', pio.price,
                                                        'pricing', pio.pricing,
                                                        'unit', pio.unit
                                                    )
                                                    FROM product_item_options pio
                                                    WHERE pio.product_item_option_id = poim.product_item_option_id
                                            ))
                                )
                                FROM product_order_item_modifications AS poim
                                INNER JOIN product_item_modifications pim ON poim.product_item_modification_id = pim.product_item_modification_id
                                INNER JOIN product_item_options pio ON pio.product_item_option_id = poim.product_item_option_id
                                WHERE poim.product_order_id = po.product_order_id AND poim.product_order_item_id = poi.product_order_item_id
                                ORDER BY poim.created_at ASC
                            ))
                        )
                FROM product_order_items AS poi
                INNER JOIN product_items pi ON pi.product_item_id = poi.product_item_id
                WHERE poi.product_order_id = po.product_order_id
          )) AS items
          FROM product_orders po
          INNER JOIN users u ON u.user_id = po.user_id
          LEFT JOIN user_addresses ua ON ua.user_address_id = po.delivery_address_id
          WHERE po.client_id = @client_id AND po.deleted_at IS NULL
          ${filter == 1 ? "AND po.status IN (1, 2, 3, 4, 5, 6) " : "AND po.status IN (7, 8, 9) "}
          ORDER BY po.created_at DESC
          ${limit != null ? "LIMIT $limit" : ""}
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": session.clientId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => UserOrder.fromMap(row, Convention.snake)).toList();
      });

  Future<List<UserOrderItem>> listOrderItems(String productOrderId) async => withSqlLog(context, () async {
        final sql = """
          SELECT poi.qty, pi.item_name, pi.price AS item_price,
            TO_JSON(ARRAY(
              SELECT json_build_object(
                    -- 'modification_name', pim.name,
                    'name', pio.name, 'price', pio.price, 'pricing', pio.pricing, 'unit', pio.unit          )
              FROM product_order_item_modifications poim
              WHERE poim.product_order_item_id = poi.product_order_item_id
              INNER JOIN product_item_modifications pim ON pim.product_item_modification_id = poim.product_item_modification_id
              INNER JOIN product_item_options pio ON pio.product_item_option_id = poim.product_item_option_id
              ORDER BY poim.product_item_modification_id
            )) AS modifications
          FROM product_order_items poi
          INNER JOIN product_items pi ON pi.product_item_id = poi.product_item_id
          WHERE poi.product_order_id = @product_order_id AND pi.client_id = @client_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
          "product_order_id": productOrderId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => UserOrderItem.fromMap(row, Convention.snake)).cast<UserOrderItem>().toList();
      });

  Future<int> patch(
    String productOrderId, {
    required int status,
    String? cancelledReason,
    String? deliveryEstimate,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          UPDATE product_orders SET
            status = @status,
            ${cancelledReason != null ? "cancelled_reason = @cancelled_reason, " : ""}
            ${deliveryEstimate != null ? "meta = meta || @meta, " : ""}
            updated_at = NOW()
          WHERE client_id = @client_id AND product_order_id = @product_order_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "product_order_id": productOrderId,
          "client_id": session.clientId,
          "status": status,
          if (cancelledReason != null) "cancelled_reason": cancelledReason,
          if (deliveryEstimate != null) "meta": {"deliveryEstimate": deliveryEstimate},
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
