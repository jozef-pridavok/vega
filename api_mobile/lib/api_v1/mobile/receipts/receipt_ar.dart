import "../../../api_v1/mobile/receipts/receipt.dart";

class ReceiptAr extends ReceiptImplementation {
  ReceiptAr(super.api, super.session, super.context);

  @override
  Future<ProcessResult?> process(String qrCode, String payload) => throw UnimplementedError();
}

// eof
