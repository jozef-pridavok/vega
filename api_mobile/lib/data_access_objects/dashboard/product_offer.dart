import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ProductOfferDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ProductOfferDAO(this.session, this.context) : super(context.api);

  Future<List<ProductOffer>> list({required int filter}) async => withSqlLog(context, () async {
        final sql = """
          SELECT product_offer_id AS offer_id, client_id, program_id, location_id, name, description, 
          loyalty_mode, type, date, rank, blocked, meta
          FROM product_offers
          WHERE client_id = @client_id 
          ${filter == 1 ? "AND deleted_at IS NULL " : "AND deleted_at IS NOT NULL "}
          ORDER BY rank
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": session.clientId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((data) => ProductOffer.fromMap(data, Convention.snake)).toList();
      });

  Future<int> insert(ProductOffer productOffer) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO product_offers (
            product_offer_id, client_id, name, loyalty_mode, type, date, rank,
            ${productOffer.programId != null ? "program_id, " : ""}
            ${productOffer.locationId != null ? "location_id, " : ""}
            ${productOffer.description != null ? "description, " : ""}
            ${productOffer.meta != null ? "meta, " : ""}
            created_at
          ) VALUES (
            @offer_id, @client_id, @name, @loyalty_mode, @type, @date, @rank,
            ${productOffer.programId != null ? "@program_id, " : ""}
            ${productOffer.locationId != null ? "@location_id, " : ""}
            ${productOffer.description != null ? "@description, " : ""}
            ${productOffer.meta != null ? "@meta, " : ""}
            NOW()
          )
        """
            .tidyCode();

        final sqlParams = productOffer.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int> update(ProductOffer productOffer) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_offers
          SET 
            name = @name, loyalty_mode = @loyalty_mode, type = @type, date = @date,
            ${productOffer.programId != null ? 'program_id = @program_id, ' : ''}
            ${productOffer.locationId != null ? 'location_id = @location_id, ' : ''}
            ${productOffer.description != null ? 'description = @description, ' : ''}
            ${productOffer.meta != null ? 'meta = @meta, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND product_offer_id = @offer_id
        """
            .tidyCode();

        final sqlParams = productOffer.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patch(String productOfferId, {bool? archived, bool? blocked}) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_offers SET
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND product_offer_id = @product_offer_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "product_offer_id": productOfferId,
          "client_id": session.clientId,
          if (blocked != null) "blocked": blocked,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> reorder(List<String> productOfferIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE product_offers
          SET rank = array_position(@product_offer_ids, product_offer_id), 
          updated_at = NOW()
          WHERE product_offer_id = ANY(@product_offer_ids)
          AND client_id = @client_id AND deleted_at IS NULL;
        """
            .tidyCode();
        final sqlParams = {
          "client_id": session.clientId,
          "product_offer_ids": productOfferIds,
        };

        log.logSql(context, sql, sqlParams);

        final updated = await api.update(sql, params: sqlParams);
        return updated;
      });
}

// eof
