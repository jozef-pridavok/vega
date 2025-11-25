// debug://receipt?ico=12345&id=1&price=9.99

import "package:core_dart/core_dart.dart";

import "receipt.dart";

class ReceiptDebug extends ReceiptImplementation {
  final ReceiptProvider provider;
  final String companyId;
  final Currency currency;

  ReceiptDebug(
    super.api,
    super.session,
    super.context, {
    required this.provider,
    required this.companyId,
    required this.currency,
  });

  @override
  Future<ProcessResult?> process(String qrCode, String payload) async {
    final uri = Uri.parse(qrCode);
    final receiptId = uri.queryParameters["id"];
    final price = double.tryParse(uri.queryParameters["price"] ?? "0") ?? 0.42;
    if (receiptId == null) return null;
    final externalReceiptId = getExternalReceiptId(provider, receiptId, true);
    final receipt = Receipt(
      receiptId: uuid(),
      clientId: "clientId",
      userId: session.userId,
      userCardId: "userCardId",
      purchasedAtTime: DateTime.now().toUtc(),
      totalItems: 5,
      totalPrice: Currency.eur.collapse(0.42),
      totalPriceCurrency: Currency.eur,
      items: [],
      externalId: externalReceiptId,
    );
    return defaultProcessLogic(provider, companyId, externalReceiptId, payload, currency, price, receipt);
  }
}

// eof
