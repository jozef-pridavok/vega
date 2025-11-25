import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";

class OfferDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  OfferDAO(this.session, this.context) : super(context.api);

  Future<List<ProductOffer>> list(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT product_offer_id AS offer_id, client_id, program_id, location_id, name, description, 
          loyalty_mode, type, date
          FROM product_offers
          WHERE client_id = @client_id AND deleted_at IS NULL AND blocked = FALSE
            AND (
                  (type = @regular)
                  OR (type = @daily AND date >= intDateNow())
                  OR (type = @weekly AND EXTRACT(WEEK FROM TO_DATE(date::TEXT, 'YYYYMMDD')) = EXTRACT(WEEK FROM TO_DATE(intDateNow()::TEXT, 'YYYYMMDD')))
                  OR (type = @monthly AND EXTRACT(MONTH FROM TO_DATE(date::TEXT, 'YYYYMMDD')) = EXTRACT(MONTH FROM TO_DATE(intDateNow()::TEXT, 'YYYYMMDD')))
                  OR (type = @yearly AND EXTRACT(YEAR FROM TO_DATE(date::TEXT, 'YYYYMMDD')) = EXTRACT(YEAR FROM TO_DATE(intDateNow()::TEXT, 'YYYYMMDD')))
                )
          ORDER BY rank, date DESC
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": clientId,
          "regular": ProductOfferType.regular.code,
          "daily": ProductOfferType.daily.code,
          "weekly": ProductOfferType.weekly.code,
          "monthly": ProductOfferType.monthly.code,
          "yearly": ProductOfferType.yearly.code,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((data) => ProductOffer.fromMap(data, Convention.snake)).toList();
      });

  Future<ProductOffer?> detail(String offerId) async => withSqlLog(context, () async {
        //AND ps.product_offer_id = po.product_offer_id
        final sql = """
          SELECT 
              po.client_id, po.product_offer_id AS offer_id, po.name, po.description, po.loyalty_mode, po.type, po.date, po.updated_at,
              TO_JSON(ARRAY(
                SELECT json_build_object(
                  'section_id', ps.product_section_id, 
                  'name', ps.name, 'description', ps.description
                )
                FROM product_sections ps
                WHERE ps.client_id = po.client_id AND ps.product_offer_id = po.product_offer_id AND ps.deleted_at IS NULL AND ps.blocked = FALSE
                ORDER BY rank
              )) AS sections,
              TO_JSON(ARRAY(
                SELECT json_build_object(
                  'client_id', pi.client_id,
                  'item_id', pi.product_item_id, 'section_id', pi.product_section_id, 
                  'name', pi.name, 'description', pi.description,
                  'photo', pi.photo, 'photo_bh', pi.photo_bh,
                  'price', pi.price, 'currency', pi.currency, 'qty_precision', pi.qty_precision, 'unit', pi.unit
                )
                FROM product_items pi
                WHERE pi.client_id = po.client_id AND pi.deleted_at IS NULL AND pi.blocked = FALSE
                ORDER BY rank
              )) AS items,
              TO_JSON(ARRAY(
                SELECT json_build_object(
                  'modification_id', pim.product_item_modification_id, 'item_id', pim.product_item_id, 
                  'name', pim.name, 'type', pim.type, 'mandatory', pim.mandatory, 'max', pim.max
                )
                FROM product_item_modifications pim
                WHERE pim.client_id = po.client_id AND pim.deleted_at IS NULL AND pim.blocked = FALSE
                ORDER BY rank
              )) AS modifications,
              TO_JSON(ARRAY(
                SELECT json_build_object(
                  'option_id', pio.product_item_option_id, 'modification_id', pio.product_item_modification_id, 
                  'name', pio.name, 'price', pio.price, 'pricing', pio.pricing, 'unit', pio.unit
                )
                FROM product_item_options pio
                WHERE pio.client_id = po.client_id AND pio.deleted_at IS NULL AND pio.blocked = FALSE
                ORDER BY rank
              )) AS options
          FROM product_offers po 
          WHERE po.product_offer_id = @offer_id AND po.deleted_at IS NULL AND po.blocked = FALSE
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"offer_id": offerId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return null;

        return ProductOffer.fromMap(rows.first, Convention.snake);
      });
}

// eof
