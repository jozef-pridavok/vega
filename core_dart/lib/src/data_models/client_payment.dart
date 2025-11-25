import "package:core_dart/core_dart.dart";

enum ClientPaymentKeys {
  clientPaymentId,
  clientId,
  clientName,
  providers,
  sellerId,
  sellerInfo,
  sellerShare,
  status,
  period,
  clientPaymentProvider,
  activeCards,
  base,
  pricing,
  currency,
  priceInfo,
  items,
  periodFrom,
  periodTo,
  dueDate,
  sellerPaymentId,
}

class ClientPayment {
  String clientPaymentId;
  List<String>? providers;
  String clientId;
  String? clientName;
  String sellerId;
  String? sellerInfo;
  int? sellerShare;
  ClientPaymentStatus status;
  IntMonth period;
  String? clientPaymentProvider;
  int activeCards;
  int base;
  int pricing;
  Currency currency;
  String? priceInfo;
  JsonObject? items;
  IntDate periodFrom;
  IntDate periodTo;
  IntDate dueDate;
  String? sellerPaymentId;

  int get totalPrice => base + activeCards * pricing;

  ClientPayment({
    required this.clientPaymentId,
    this.providers,
    required this.clientId,
    this.clientName,
    required this.sellerId,
    this.sellerInfo,
    this.sellerShare,
    required this.status,
    required this.period,
    this.clientPaymentProvider,
    required this.activeCards,
    required this.base,
    required this.pricing,
    required this.currency,
    this.priceInfo,
    required this.items,
    required this.periodFrom,
    required this.periodTo,
    required this.dueDate,
    this.sellerPaymentId,
  });

  bool get isPaymentEligible =>
      status == ClientPaymentStatus.pending ||
      status == ClientPaymentStatus.canceled ||
      status == ClientPaymentStatus.failed;

  bool get isNotPaymentEligible => !isPaymentEligible;

  static const camel = {
    ClientPaymentKeys.clientPaymentId: "clientPaymentId",
    ClientPaymentKeys.providers: "providers",
    ClientPaymentKeys.clientId: "clientId",
    ClientPaymentKeys.clientName: "clientName",
    ClientPaymentKeys.sellerId: "sellerId",
    ClientPaymentKeys.sellerInfo: "sellerInfo",
    ClientPaymentKeys.sellerShare: "sellerShare",
    ClientPaymentKeys.status: "status",
    ClientPaymentKeys.period: "period",
    ClientPaymentKeys.clientPaymentProvider: "clientPaymentProvider",
    ClientPaymentKeys.activeCards: "activeCards",
    ClientPaymentKeys.base: "base",
    ClientPaymentKeys.pricing: "pricing",
    ClientPaymentKeys.currency: "currency",
    ClientPaymentKeys.priceInfo: "priceInfo",
    ClientPaymentKeys.items: "items",
    ClientPaymentKeys.periodFrom: "periodFrom",
    ClientPaymentKeys.periodTo: "periodTo",
    ClientPaymentKeys.dueDate: "dueDate",
    ClientPaymentKeys.sellerPaymentId: "sellerPaymentId",
  };

  static const snake = {
    ClientPaymentKeys.clientPaymentId: "client_payment_id",
    ClientPaymentKeys.providers: "providers",
    ClientPaymentKeys.clientId: "client_id",
    ClientPaymentKeys.clientName: "client_name",
    ClientPaymentKeys.sellerId: "seller_id",
    ClientPaymentKeys.sellerInfo: "seller_info",
    ClientPaymentKeys.sellerShare: "seller_share",
    ClientPaymentKeys.status: "status",
    ClientPaymentKeys.period: "period",
    ClientPaymentKeys.clientPaymentProvider: "client_payment_provider",
    ClientPaymentKeys.activeCards: "active_cards",
    ClientPaymentKeys.base: "base",
    ClientPaymentKeys.pricing: "pricing",
    ClientPaymentKeys.currency: "currency",
    ClientPaymentKeys.priceInfo: "price_info",
    ClientPaymentKeys.items: "items",
    ClientPaymentKeys.periodFrom: "period_from",
    ClientPaymentKeys.periodTo: "period_to",
    ClientPaymentKeys.dueDate: "due_date",
    ClientPaymentKeys.sellerPaymentId: "seller_payment_id",
  };

  factory ClientPayment.fromMap(Map<String, dynamic> map, Map<ClientPaymentKeys, String> mapper) {
    return ClientPayment(
      clientPaymentId: map[mapper[ClientPaymentKeys.clientPaymentId]] as String,
      providers: (map[mapper[ClientPaymentKeys.providers]] as List<dynamic>?)?.cast<String>(),
      clientId: map[mapper[ClientPaymentKeys.clientId]] as String,
      clientName: map[mapper[ClientPaymentKeys.clientName]] as String?,
      sellerId: map[mapper[ClientPaymentKeys.sellerId]] as String,
      sellerInfo: map[mapper[ClientPaymentKeys.sellerInfo]] as String?,
      sellerShare: map[mapper[ClientPaymentKeys.sellerShare]] as int?,
      status: ClientPaymentStatusCode.fromCode(map[mapper[ClientPaymentKeys.status]] as int),
      period: IntMonth.fromInt(map[mapper[ClientPaymentKeys.period]] as int),
      clientPaymentProvider: map[mapper[ClientPaymentKeys.clientPaymentProvider]] as String?,
      activeCards: map[mapper[ClientPaymentKeys.activeCards]] as int,
      base: map[mapper[ClientPaymentKeys.base]] as int,
      pricing: map[mapper[ClientPaymentKeys.pricing]] as int,
      currency: CurrencyCode.fromCode(map[mapper[ClientPaymentKeys.currency]] as String),
      priceInfo: map[mapper[ClientPaymentKeys.priceInfo]] as String?,
      items: map[mapper[ClientPaymentKeys.items]] as JsonObject?,
      periodFrom: IntDate.fromInt(map[mapper[ClientPaymentKeys.periodFrom]] as int),
      periodTo: IntDate.fromInt(map[mapper[ClientPaymentKeys.periodTo]] as int),
      dueDate: IntDate.fromInt(map[mapper[ClientPaymentKeys.dueDate]] as int),
      sellerPaymentId: map[mapper[ClientPaymentKeys.sellerPaymentId]] as String?,
    );
  }

  Map<String, dynamic> toMap(Map<ClientPaymentKeys, String> mapper) => {
        mapper[ClientPaymentKeys.clientPaymentId]!: clientPaymentId,
        if (providers != null) mapper[ClientPaymentKeys.providers]!: providers,
        mapper[ClientPaymentKeys.clientId]!: clientId,
        if (clientName != null) mapper[ClientPaymentKeys.clientName]!: clientName,
        mapper[ClientPaymentKeys.sellerId]!: sellerId,
        if (sellerInfo != null) mapper[ClientPaymentKeys.sellerInfo]!: sellerInfo,
        if (sellerShare != null) mapper[ClientPaymentKeys.sellerShare]!: sellerShare,
        mapper[ClientPaymentKeys.status]!: status.code,
        mapper[ClientPaymentKeys.period]!: period.value,
        if (clientPaymentProvider != null) mapper[ClientPaymentKeys.clientPaymentProvider]!: clientPaymentProvider,
        mapper[ClientPaymentKeys.activeCards]!: activeCards,
        mapper[ClientPaymentKeys.base]!: base,
        mapper[ClientPaymentKeys.pricing]!: pricing,
        mapper[ClientPaymentKeys.currency]!: currency.code,
        if (priceInfo != null) mapper[ClientPaymentKeys.priceInfo]!: priceInfo,
        if (items != null) mapper[ClientPaymentKeys.items]!: items,
        mapper[ClientPaymentKeys.periodFrom]!: periodFrom.value,
        mapper[ClientPaymentKeys.periodTo]!: periodTo.value,
        mapper[ClientPaymentKeys.dueDate]!: dueDate.value,
        if (sellerPaymentId != null) mapper[ClientPaymentKeys.sellerPaymentId]!: sellerPaymentId,
      };
}


// eof
