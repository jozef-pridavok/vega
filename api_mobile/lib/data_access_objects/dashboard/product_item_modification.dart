import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ProductItemModificationDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ProductItemModificationDAO(this.session, this.context) : super(context.api);

  Future<List<ProductItemModification>> listForItem({required String productItemId}) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT product_item_modification_id AS modification_id, product_item_id AS item_id, client_id, 
          name, type, mandatory, max, rank, blocked, meta
          FROM product_item_modifications
          WHERE product_item_id = @product_item_id AND client_id = @client_id AND deleted_at IS NULL
          ORDER BY rank
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "product_item_id": productItemId,
          "client_id": session.clientId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows
            .map<ProductItemModification>((row) => ProductItemModification.fromMap(row, Convention.snake))
            .toList();
      });

  Future<int> insert(ProductItemModification modification) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO product_item_modifications (
            product_item_modification_id, product_item_id, client_id, name, type, mandatory,
            ${modification.max != null ? "max, " : ""}
            ${modification.meta != null ? "meta, " : ""}
            created_at
          ) VALUES (
            @modification_id, @item_id, @client_id, @name, @type, @mandatory,
            ${modification.max != null ? "@max, " : ""}
            ${modification.meta != null ? "@meta, " : ""}
            NOW()
          )
        """
            .tidyCode();

        final sqlParams = modification.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int> update(ProductItemModification modification) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_item_modifications
          SET 
            name = @name, type = @type, mandatory = @mandatory,
            ${modification.max != null ? 'max = @max, ' : ''}
            ${modification.meta != null ? 'meta = @meta, ' : ''}
            updated_at = NOW()
          WHERE product_item_modification_id = @modification_id AND client_id = @client_id
        """
            .tidyCode();

        final sqlParams = modification.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patch(String modificationId, {bool? archived, bool? blocked}) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_item_modifications SET
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE product_item_modification_id = @modification_id AND client_id = @client_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "product_item_modification_id": modificationId,
          "client_id": session.clientId,
          if (blocked != null) "blocked": blocked,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> reorder(List<String> modificationIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_item_modifications 
          SET rank = array_position(@modification_ids, product_item_modification_id),
              updated_at = NOW()
          WHERE product_item_modification_id = ANY(@modification_ids) 
          AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = {
          "client_id": session.clientId,
          "modification_ids": modificationIds,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
