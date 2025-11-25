import "package:collection/collection.dart";

enum LocationType {
  mainBranch,
  regionalBranch,
  localBranch,
  distributionCenter,
  store,
  serviceCenter,
  callCenter,
  onlineStore,
  franchiseBranch,
  researchAndDevelopmentCenter,
  expansionBranch,
  marketingBranch,
  logisticsCenter,
  trainingCenter,
  laboratory,
  issuancePoint,
  wholesaleWarehouse,
}

extension LocationTypeCode on LocationType {
  static final _codeMap = {
    LocationType.mainBranch: 1,
    LocationType.regionalBranch: 2,
    LocationType.localBranch: 3,
    LocationType.distributionCenter: 4,
    LocationType.store: 5,
    LocationType.serviceCenter: 6,
    LocationType.callCenter: 7,
    LocationType.onlineStore: 8,
    LocationType.franchiseBranch: 9,
    LocationType.researchAndDevelopmentCenter: 10,
    LocationType.expansionBranch: 11,
    LocationType.marketingBranch: 12,
    LocationType.logisticsCenter: 13,
    LocationType.trainingCenter: 14,
    LocationType.laboratory: 15,
    LocationType.issuancePoint: 16,
    LocationType.wholesaleWarehouse: 17,
  };

  int get code => _codeMap[this]!;

  static final _translationKeyMap = {
    LocationType.mainBranch: "main_branch",
    LocationType.regionalBranch: "regional_branch",
    LocationType.localBranch: "local_branch",
    LocationType.distributionCenter: "distribution_center",
    LocationType.store: "store",
    LocationType.serviceCenter: "service_center",
    LocationType.callCenter: "call_center",
    LocationType.onlineStore: "online_store",
    LocationType.franchiseBranch: "franchise_branch",
    LocationType.researchAndDevelopmentCenter: "research_and_development_center",
    LocationType.expansionBranch: "expansion_branch",
    LocationType.marketingBranch: "marketing_branch",
    LocationType.logisticsCenter: "logistics_center",
    LocationType.trainingCenter: "training_center",
    LocationType.laboratory: "laboratory",
    LocationType.issuancePoint: "issuance_point",
    LocationType.wholesaleWarehouse: "wholesale_warehouse",
  };

  String get translationKey => _translationKeyMap[this]!;

  static LocationType fromCode(int? code, {LocationType def = LocationType.mainBranch}) =>
      LocationType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static LocationType? fromCodeOrNull(int? code) => LocationType.values.firstWhereOrNull((r) => r.code == code);
}

// eof
