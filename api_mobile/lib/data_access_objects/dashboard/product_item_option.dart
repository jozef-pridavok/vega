import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ProductItemOptionDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ProductItemOptionDAO(this.session, this.context) : super(context.api);

  Future<List<ProductItemOption>> list({required String itemId}) async => withSqlLog(context, () async {
        final sql = """
          SELECT pio.product_item_option_id AS option_id, pio.product_item_modification_id AS modification_id, 
          pio.name, pio.price, pio.pricing, pio.unit, pio.rank, pio.blocked, pio.meta
          FROM product_item_options pio
          INNER JOIN product_item_modifications pim ON pim.product_item_modification_id = pio.product_item_modification_id
          WHERE pim.product_item_id = @product_item_id AND pim.client_id = @client_id AND pio.deleted_at IS NULL
          ORDER BY rank
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "product_item_id": itemId,
          "client_id": session.clientId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map<ProductItemOption>((row) => ProductItemOption.fromMap(row, Convention.snake)).toList();
      });

  Future<int> insert(ProductItemOption option) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO product_item_options (
            client_id, product_item_option_id, product_item_modification_id, name, pricing, price, unit,
            ${option.meta != null ? "meta, " : ""}
            created_at
          ) VALUES (
            @client_id, @option_id, @modification_id, @name, @pricing, @price, @unit,
            ${option.meta != null ? "@meta, " : ""}
            NOW()
          )
        """
            .tidyCode();

        final sqlParams = (option..clientId = session.clientId).toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int> update(ProductItemOption option) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_item_options
          SET 
            name = @name, pricing = @pricing, price = @price, unit = @unit,
            ${option.meta != null ? 'meta = @meta, ' : ''}
            updated_at = NOW()
          WHERE product_item_option_id = @option_id
        """
            .tidyCode();

        final sqlParams = option.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patch(String optionId, {bool? archived, bool? blocked}) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_item_options SET
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE product_item_option_id = @option_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "product_item_option_id": optionId,
          "client_id": session.clientId,
          if (blocked != null) "blocked": blocked,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
