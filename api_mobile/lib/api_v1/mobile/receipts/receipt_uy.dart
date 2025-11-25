import "../../../api_v1/mobile/receipts/receipt.dart";

class ReceiptUy extends ReceiptImplementation {
  ReceiptUy(super.api, super.session, super.context);

  @override
  Future<ProcessResult?> process(String qrCode, String payload) {
    // !!!!!!!! final uri = Uri.tryParse(qrCode.ensureHead("https://"));
    // TODO: implement process
    throw UnimplementedError();
  }
}

// eof
