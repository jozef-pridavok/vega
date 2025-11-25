import "package:core_dart/core_dart.dart";

enum SellerPaymentKeys {
  sellerPaymentId,
  clientId,
  sellerId,
  sellerInvoice,
  status,
  totalPrice,
  totalCurrency,
  dueDate,
  paidAt,
  //
  clientName,
  sellerShare,
}

class SellerPayment {
  final String sellerPaymentId;
  final String clientId;
  final String sellerId;
  final String? sellerInvoice;
  final SellerPaymentStatus status;
  final int totalPrice;
  final Currency totalCurrency;
  final IntDate? dueDate;
  final DateTime? paidAt;
  final String clientName;
  final int sellerShare;

  const SellerPayment({
    required this.sellerPaymentId,
    required this.clientId,
    required this.sellerId,
    this.sellerInvoice,
    required this.status,
    required this.totalPrice,
    required this.totalCurrency,
    this.dueDate,
    this.paidAt,
    required this.clientName,
    required this.sellerShare,
  });

  bool get isPaymentEligible =>
      status == SellerPaymentStatus.pending ||
      status == SellerPaymentStatus.canceled ||
      status == SellerPaymentStatus.failed;

  bool get isNotPaymentEligible => !isPaymentEligible;

  static const camel = {
    SellerPaymentKeys.sellerPaymentId: "sellerPaymentId",
    SellerPaymentKeys.clientId: "clientId",
    SellerPaymentKeys.sellerId: "sellerId",
    SellerPaymentKeys.sellerInvoice: "sellerInvoice",
    SellerPaymentKeys.status: "status",
    SellerPaymentKeys.totalPrice: "totalPrice",
    SellerPaymentKeys.totalCurrency: "totalCurrency",
    SellerPaymentKeys.dueDate: "dueDate",
    SellerPaymentKeys.paidAt: "paidAt",
    //
    SellerPaymentKeys.clientName: "clientName",
    SellerPaymentKeys.sellerShare: "sellerShare",
  };

  static const snake = {
    SellerPaymentKeys.sellerPaymentId: "seller_payment_id",
    SellerPaymentKeys.clientId: "client_id",
    SellerPaymentKeys.sellerId: "seller_id",
    SellerPaymentKeys.sellerInvoice: "seller_invoice",
    SellerPaymentKeys.status: "status",
    SellerPaymentKeys.totalPrice: "total_price",
    SellerPaymentKeys.totalCurrency: "total_currency",
    SellerPaymentKeys.dueDate: "due_date",
    SellerPaymentKeys.paidAt: "paid_at",
    //
    SellerPaymentKeys.clientName: "client_name",
    SellerPaymentKeys.sellerShare: "seller_share",
  };

  factory SellerPayment.fromMap(Map<String, dynamic> map, Map<SellerPaymentKeys, String> mapper) {
    return SellerPayment(
      sellerPaymentId: map[mapper[SellerPaymentKeys.sellerPaymentId]] as String,
      clientId: map[mapper[SellerPaymentKeys.clientId]] as String,
      sellerId: map[mapper[SellerPaymentKeys.sellerId]] as String,
      sellerInvoice: map[mapper[SellerPaymentKeys.sellerInvoice]] as String?,
      status: SellerPaymentStatusCode.fromCode(map[mapper[SellerPaymentKeys.status]] as int),
      totalPrice: map[mapper[SellerPaymentKeys.totalPrice]] as int,
      totalCurrency: CurrencyCode.fromCode(map[mapper[SellerPaymentKeys.totalCurrency]] as String),
      dueDate: IntDate.parseInt(map[mapper[SellerPaymentKeys.dueDate]] as int?),
      paidAt: tryParseDateTime(map[mapper[SellerPaymentKeys.paidAt]]),
      clientName: map[mapper[SellerPaymentKeys.clientName]] as String,
      sellerShare: map[mapper[SellerPaymentKeys.sellerShare]] as int,
    );
  }

  Map<String, dynamic> toMap(Map<SellerPaymentKeys, String> mapper) {
    return <String, dynamic>{
      mapper[SellerPaymentKeys.sellerPaymentId]!: sellerPaymentId,
      mapper[SellerPaymentKeys.clientId]!: clientId,
      mapper[SellerPaymentKeys.sellerId]!: sellerId,
      mapper[SellerPaymentKeys.sellerInvoice]!: sellerInvoice,
      mapper[SellerPaymentKeys.status]!: status.code,
      mapper[SellerPaymentKeys.totalPrice]!: totalPrice,
      mapper[SellerPaymentKeys.totalCurrency]!: totalCurrency.code,
      if (dueDate != null) mapper[SellerPaymentKeys.dueDate]!: dueDate?.value,
      mapper[SellerPaymentKeys.paidAt]!: paidAt?.toUtc().toIso8601String(),
      mapper[SellerPaymentKeys.clientName]!: clientName,
      mapper[SellerPaymentKeys.sellerShare]!: sellerShare,
    };
  }
}

// eof
