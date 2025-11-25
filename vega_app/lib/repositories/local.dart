import "package:vega_app/repositories/leaflet/leaflet_detail_hive.dart";
import "package:vega_app/repositories/leaflet/leaflet_overview_hive.dart";
import "package:vega_app/repositories/location/location_hive.dart";
import "package:vega_app/repositories/program/programs_hive.dart";
import "package:vega_app/repositories/user/user_cards_hive.dart";

import "coupon/coupons_hive.dart";

void clearLocalData() {
  // TODO: remove HiveCardsRepository
  //HiveCardsRepository.clear();
  //HiveUserCardRepository.clear();
  HiveUserCardsRepository.clear();
  HiveCouponsRepository.clear();
  HiveLeafletDetailRepository.clear();
  HiveLeafletOverviewRepository.clear();
  HiveLocationRepository.clear();
  HiveProgramsRepository.clear();
}

// eof
