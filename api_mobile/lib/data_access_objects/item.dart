import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";

class ItemDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ItemDAO(this.session, this.context) : super(context.api);

  Future<List<ProductItemModification>> listModifications(String itemId) async => withSqlLog(context, () async {
        final sql = """
          SELECT 
            product_item_modification_id AS modification_id, product_item_id AS item_id, client_id,
            name, type, mandatory, max, rank
          FROM product_item_modifications
          WHERE product_item_id = @product_item_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"product_item_id": itemId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => ProductItemModification.fromMap(row, Convention.snake)).toList();
      });

  Future<List<ProductItemOption>> listOptions(String itemId) async => withSqlLog(context, () async {
        final sql = """
          SELECT 
            product_item_option_id AS option_id, product_item_modification_id AS modification_id,
            name, price, pricing, unit, rank
          FROM product_item_options
          WHERE product_item_modification_id IN (
            SELECT product_item_modification_id 
            FROM product_item_modifications 
            WHERE product_item_id = @product_item_id
          )
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"product_item_id": itemId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => ProductItemOption.fromMap(row, Convention.snake)).toList();
      });
}

// eof
