// https://ekuatia.set.gov.py/consultas/qr?nVersion=150&Id=01800160967099006002467022023040812610764875&dFeEmiDE=323032332d30342d30385431333a30303a3434&dRucRec=80124528&dTotGralOpe=296962.00000000&dTotIVA=19113.39740261&cItems=24&DigestValue=72414a4d77764274574639436a4b7166784c785676754f525642503732325263693545524b496a766941513d&IdCSC=0001&cHashQR=44c9551f83fa3bb1a201176c2ded03d61d8d47ed9dfe403a9a6e443cad80e86a

/*
https://ekuatia.set.gov.py/consultas/qr
  ?nVersion=150
  &Id=01800160967099006002467022023040812610764875
  &dFeEmiDE=323032332d30342d30385431333a30303a3434
  &dRucRec=80124528
  &dTotGralOpe=296962.00000000
  &dTotIVA=19113.39740261
  &cItems=24
  &DigestValue=72414a4d77764274574639436a4b7166784c785676754f525642503732325263693545524b496a766941513d
  &IdCSC=0001
  &cHashQR=44c9551f83fa3bb1a201176c2ded03d61d8d47ed9dfe403a9a6e443cad80e86a
*/

import "package:core_dart/core_enums.dart";

import "../../../api_v1/mobile/receipts/receipt.dart";

class ReceiptPy extends ReceiptImplementation {
  ReceiptPy(super.api, super.session, super.context);

  static const provider = ReceiptProvider.pyEkuatia;

  @override
  Future<ProcessResult?> process(String qrCode, String payload) async {
    final uri = Uri.parse(qrCode);
    final receiptId = uri.queryParameters["Id"];
    if (receiptId == null) return null;
    final price = double.tryParse(uri.queryParameters["dTotGralOpe"] ?? "0");
    final companyId = uri.queryParameters["dRucRec"];
    if (companyId == null) return null;
    final externalReceiptId = getExternalReceiptId(provider, receiptId);
    return defaultProcessLogic(provider, companyId, externalReceiptId, payload, Currency.pyg, price, null);
  }
}

// eof
