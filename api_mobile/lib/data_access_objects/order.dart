import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";
import "../utils/storage.dart";

class OrderDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  OrderDAO(this.session, this.context) : super(context.api);

  Future<List<OrderForDashboard>> _listForAction({
    required int limit,
    required List<ProductOrderStatus> status,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT 
              o.product_order_id AS order_id, o.status AS order_status, 
              f.product_offer_id AS offer_id, f.name AS offer_name, f.type AS offer_type,
              u.user_id, COALESCE(u.meta->'clients'->'${session.clientId}'->>'displayName', u.nick) AS user_name,
              o.cancelled_reason, o.cancelled_by_user_id, o.total_price, o.total_price_currency,
              o.delivery_type, o.deliver_price, o.deliver_currency,
              o.meta->'deliveryAddress'->>'addressLine1' AS delivery_address_line1,
              o.meta->'deliveryAddress'->>'addressLine2' AS delivery_address_line2,
              o.meta->'deliveryAddress'->>'city' AS delivery_city,
              o.meta->'deliveryAddress'->>'zip' AS delivery_zip,
              o.meta->'deliveryAddress'->>'state' AS delivery_state,
              o.meta->'deliveryAddress'->>'country' AS delivery_country,
              o.created_at 
          FROM product_orders o
          INNER JOIN product_offers f ON o.product_offer_id = f.product_offer_id
          INNER JOIN users u ON o.user_id = u.user_id 
          WHERE o.client_id = @client_id AND o.deleted_at IS NULL AND o.status = ANY(@order_status)
          ORDER BY o.updated_at DESC
          LIMIT $limit
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
          "order_status": status.map((e) => e.code).toList(),
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => OrderForDashboard.fromMap(row, Convention.snake)).toList();
      });

  Future<List<OrderForDashboard>> listForAcceptance({required int limit}) async => withSqlLog(context, () async {
        return await _listForAction(
          limit: limit,
          status: [ProductOrderStatus.created],
        );
      });

  Future<List<OrderForDashboard>> listForFinalization({required int limit}) async => withSqlLog(context, () async {
        return await _listForAction(
          limit: limit,
          status: [ProductOrderStatus.delivered, ProductOrderStatus.returned],
        );
      });

  Future<List<UserOrder>> list(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT po.product_order_id AS order_id, po.product_offer_id AS offer_id, po.client_id, po.location_id, po.user_id,
            po.user_card_id, po.notes, po.status, po.cancelled_reason, po.cancelled_by_user_id, po.cancelled_at,
            po.total_price, po.total_price_currency, po.delivery_type, po.delivery_date, po.deliver_price,
            po.deliver_currency, po.delivery_address_id, po.meta, po.created_at,
            u.nick AS user_nickname,
            ua.address_line_1 AS delivery_address_line_1, ua.address_line_2 AS delivery_address_line_2, 
            ua.city AS delivery_city,
            TO_JSON(ARRAY(
                    SELECT json_build_object(
                           'order_id', poi.product_order_id,
                           'offer_id', po.product_offer_id,
                           'item_id', pi.product_item_id,
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
                INNER JOIN product_items pi ON poi.product_item_id = poi.product_item_id
                WHERE poi.product_order_id = po.product_order_id
          )) AS items              
          FROM product_orders po
          INNER JOIN users u ON u.user_id = po.user_id
          LEFT JOIN user_addresses ua ON ua.user_address_id = po.delivery_address_id
          WHERE po.client_id = @client_id AND po.user_id = @user_id AND po.deleted_at IS NULL
          ORDER BY po.created_at DESC
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": clientId, "user_id": session.userId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map<UserOrder>((row) {
          final order = UserOrder.fromMap(row, Convention.snake);
          order.items?.forEach((item) {
            item.photo = api.storageUrl(item.photo, StorageObject.productItem, timeStamp: item.updatedAt);
          });
          return order;
        }).toList();
      });

  Future<int> insert(UserOrder order) async => withSqlLog(context, () async {
        final items = order.items;

        if (items == null || items.isEmpty) throw Exception("Order must have at least one item");

        String sql = """
          INSERT INTO product_orders
          (
            product_order_id, product_offer_id, client_id, location_id, user_id, user_card_id, notes, status,
            total_price, total_price_currency, delivery_type, delivery_date, deliver_price, deliver_currency, delivery_address_id,
            meta
          ) VALUES (
            @product_order_id, @product_offer_id, @client_id, @location_id, @user_id, @user_card_id, @notes, 1,
            @total_price, @total_price_currency, @delivery_type, @delivery_date, @deliver_price, @deliver_currency, @delivery_address_id,
            @meta
          )
        """
            .tidyCode();

        Map<String, dynamic> sqlParams = {
          "product_order_id": order.orderId,
          "product_offer_id": order.offerId,
          "client_id": order.clientId,
          "location_id": order.locationId,
          "user_id": session.userId,
          "user_card_id": order.userCardId,
          "notes": order.notes,
          "total_price": order.totalPrice,
          "total_price_currency": order.totalPriceCurrency?.code,
          "delivery_type": order.deliveryType.code,
          "delivery_date": order.deliveryDate,
          "deliver_price": order.deliverPrice,
          "deliver_currency": order.deliverCurrency?.code,
          "delivery_address_id": order.deliveryAddressId,
          "meta": order.meta,
        };

        log.logSql(context, sql, sqlParams);

        final ordersInserted = await api.insert(sql, params: sqlParams);

        if (ordersInserted == 0) throw Exception("Failed to insert order");

        sql = """
          INSERT INTO product_order_items
          (
            product_order_item_id, product_order_id, product_item_id, qty
          ) VALUES (
            @product_order_item_id, @product_order_id, @product_item_id, @qty
          )
        """
            .tidyCode();

        for (final UserOrderItem item in items) {
          final productOrderItemId = uuid();

          sqlParams = {
            "product_order_item_id": productOrderItemId,
            "product_order_id": order.orderId,
            "product_item_id": item.itemId,
            "qty": item.qty,
          };

          log.logSql(context, sql, sqlParams);

          final itemsInserted = await api.insert(sql, params: sqlParams);

          if (itemsInserted == 0) throw Exception("Failed to insert order items");

          final modifications = item.modifications;
          if (modifications != null && modifications.isNotEmpty) {
            sql = """
              INSERT INTO product_order_item_modifications
              (
                product_order_item_modification_id, product_order_item_id, product_item_modification_id, product_item_option_id, product_order_id
              ) VALUES (
                @product_order_item_modification_id, @product_order_item_id, @product_item_modification_id, @product_item_option_id, @product_order_id
              )
            """
                .tidyCode();

            final futureModifications = modifications.map((modification) async {
              final orderModificationId = uuid();
              final options = modification.options;

              if (options == null || options.isEmpty) {
                //throw Exception("Modification must have at least one option");
                return 0;
              }

              final futureOptions = options.map((option) async {
                final sqlParams = {
                  "product_order_item_modification_id": orderModificationId,
                  "product_order_item_id": productOrderItemId,
                  "product_item_modification_id": modification.modificationId,
                  "product_item_option_id": option.optionId,
                  "product_order_id": order.orderId,
                };

                log.logSql(context, sql, sqlParams);

                return await api.insert(sql, params: sqlParams);
              });

              final results = await Future.wait(futureOptions);
              return results.fold(0, (acc, current) => acc + current);
            }).toList();

            await Future.wait(futureModifications);
          }
        }

        return ordersInserted;
      });
}

// eof
