import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ProductItemDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ProductItemDAO(this.session, this.context) : super(context.api);

  Future<List<ProductItem>> list() async => withSqlLog(context, () async {
        final sql = """
          SELECT pi.product_item_id AS item_id, pi.product_section_id AS section_id, pi.client_id, 
            pi.name, pi.description, pi.photo, pi.photo_bh, pi.rank, pi.price, pi.currency, 
            pi.qty_precision, pi.unit, pi.blocked, pi.meta
          FROM product_items pi
          WHERE pi.client_id = @client_id AND pi.deleted_at IS NULL
          ORDER BY pi.rank
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map<ProductItem>((row) => ProductItem.fromMap(row, Convention.snake)).toList();
      });

  Future<int> insert(ProductItem item) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO product_items (
            product_item_id, client_id, name, qty_precision, currency,
            ${item.sectionId != null ? "product_section_id, " : ""}
            ${item.description != null ? "description, " : ""}
            ${item.photo != null ? "photo, " : ""}
            ${item.photoBh != null ? "photo_bh, " : ""}
            ${item.price != null ? "price, " : ""}
            ${item.unit != null ? "unit, " : ""}
            ${item.meta != null ? "meta, " : ""}
            created_at
          ) VALUES (
            @item_id, @client_id, @name, @qty_precision, @currency,
            ${item.sectionId != null ? "@section_id, " : ""}
            ${item.description != null ? "@description, " : ""}
            ${item.photo != null ? "@photo, " : ""}
            ${item.photoBh != null ? "@photo_bh, " : ""}
            ${item.price != null ? "@price, " : ""}
            ${item.unit != null ? "@unit, " : ""}
            ${item.meta != null ? "@meta, " : ""}
            NOW()
          )
        """
            .tidyCode();

        final sqlParams = item.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int> update(ProductItem item) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_items
          SET 
            name = @name, qty_precision = @qty_precision, currency = @currency,
            ${item.sectionId != null ? 'product_section_id = @section_id, ' : ''}
            ${item.description != null ? 'description = @description, ' : ''}
            ${item.photo != null ? 'photo = @photo, ' : ''}
            ${item.photoBh != null ? 'photo_bh = @photo_bh, ' : ''}
            ${item.price != null ? 'price = @price, ' : ''}
            ${item.unit != null ? 'unit = @unit, ' : ''}
            ${item.meta != null ? 'meta = @meta, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND product_item_id = @item_id
        """
            .tidyCode();

        final sqlParams = item.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patch(String itemId, {bool? archived, bool? blocked}) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_items SET
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND product_item_id = @item_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "product_item_id": itemId,
          "client_id": session.clientId,
          if (blocked != null) "blocked": blocked,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> reorder(List<String> itemIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_items
          SET rank = array_position(@item_ids, product_item_id), updated_at = NOW()
          WHERE product_item_id = ANY(@item_ids) AND client_id = @client_id AND deleted_at IS NULL;
        """
            .tidyCode();
        final sqlParams = {
          "client_id": session.clientId,
          "item_ids": itemIds,
        };

        log.logSql(context, sql, sqlParams);

        final updated = await api.update(sql, params: sqlParams);
        return updated;
      });
}

// eof
