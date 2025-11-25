import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ProductSectionDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ProductSectionDAO(this.session, this.context) : super(context.api);

  Future<List<ProductSection>> list() async => withSqlLog(context, () async {
        final sql = """
          SELECT product_section_id AS section_id, client_id, product_offer_id AS offer_id, 
            name, description, rank, blocked, meta
          FROM product_sections
          WHERE client_id = @client_id AND deleted_at IS NULL
          ORDER BY rank, created_at
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => ProductSection.fromMap(row, Convention.snake)).toList();
      });

  Future<int> insert(ProductSection productSection) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO product_sections (
            product_section_id, client_id, product_offer_id, name,
            ${productSection.description != null ? "description, " : ""}
            ${productSection.meta != null ? "meta, " : ""}
            created_at
          ) VALUES (
            @section_id, @client_id, @offer_id, @name,
            ${productSection.description != null ? "@description, " : ""}
            ${productSection.meta != null ? "@meta, " : ""}
            NOW()
          )
        """
            .tidyCode();

        final sqlParams = productSection.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        final inserted = await api.insert(sql, params: sqlParams);

        final sqlProducts = """
          UPDATE product_items
          SET product_section_id = @section_id
          WHERE client_id = @client_id AND product_section_id IS NULL
        """
            .tidyCode();
        final sqlParamsProducts = {
          "client_id": session.clientId,
          "section_id": productSection.sectionId,
        };
        await api.update(sqlProducts, params: sqlParamsProducts);

        return inserted;
      });

  Future<int> update(ProductSection productSection) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_sections
          SET 
            product_offer_id = @product_offer_id, name = @name, rank = @rank,
            ${productSection.description != null ? "description = @description, " : ""}
            ${productSection.meta != null ? "meta = @meta, " : ""}
            updated_at = NOW()
          WHERE client_id = @client_id AND product_section_id = @section_id
        """
            .tidyCode();

        final sqlParams = productSection.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patch(String productSectionId, {bool? archived, bool? blocked}) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_sections SET
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE product_section_id = @product_section_id AND client_id = @client_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "product_section_id": productSectionId,
          "client_id": session.clientId,
          if (blocked != null) "blocked": blocked,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> reorder(List<String> productSectionIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_sections
          SET rank = array_position(@product_section_ids, product_section_id),
              updated_at = NOW()
          WHERE product_section_id = ANY(@product_section_ids)
              AND client_id = @client_id AND deleted_at IS NULL;
        """
            .tidyCode();
        final sqlParams = {
          "client_id": session.clientId,
          "product_section_ids": productSectionIds,
        };

        log.logSql(context, sql, sqlParams);

        final updated = await api.update(sql, params: sqlParams);
        return updated;
      });
}

// eof
