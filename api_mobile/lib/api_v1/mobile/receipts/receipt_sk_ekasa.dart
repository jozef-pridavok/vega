import "package:core_dart/core_dart.dart";
import "package:dio/dio.dart";
import "package:intl/intl.dart";

import "../../../api_v1/mobile/receipts/receipt.dart";

class ReceiptSk extends ReceiptImplementation {
  final String qrCode;
  final bool useReceiptId;

  ReceiptSk(super.api, super.session, super.context, this.qrCode, this.useReceiptId);

  @override
  Future<ProcessResult?> process(String qrCode, String payload) async {
    const host = "ekasa.financnasprava.sk";
    final dio = Dio(
      BaseOptions(headers: {
        "Host": host,
        "Connection": "keep-alive",
        "Accept": "application/json, text/plain, */*",
        "Content-Type": "application/json;charset=UTF-8",
        "User-Agent": "Mozilla/5.0",
        "Content-type": "application/json"
      }),
    );
    const url = "https://$host/mdu/api/v1/opd/receipt/find";
    try {
      final userReceiptId = qrCode.startsWith("O-") && qrCode.length == 34;
      final data = userReceiptId ? _dataForReceiptId(qrCode) : _dataForOkp(qrCode);
      final res = await dio.post(url, data: data); // {"receiptId": number}
      if (res.statusCode != 200) return null;
      final json = res.data as JsonObject;
      final ico = json["receipt"]["ico"];
      final externalReceiptId = getExternalReceiptId(ReceiptProvider.skEkasa, json["receipt"]["receiptId"]);
      final price = json["receipt"]["totalPrice"] as num;
      final receipt = _toReceipt(json["receipt"]);
      return defaultProcessLogic(
          ReceiptProvider.skEkasa, ico, externalReceiptId, payload, Currency.eur, price, receipt);
    } catch (ex, st) {
      api.log.error(ex.toString());
      api.log.error(st.toString());
      return Future.error(ex);
    }
  }

  // O-B0C46C9613234629846C961323562963
  static JsonObject _dataForReceiptId(String number) {
    return {"receiptId": number};
  }

  // 54CBE152-8A8F00E4-40A25A22-D670DF2A-748247E4:88820204739500108:210425144911:5257:10.21
  static JsonObject _dataForOkp(String number) {
    final parts = number.split(":");
    if (parts.length != 5) return {};
    String date(String str) {
      return "${str.substring(4, 6)}.${str.substring(2, 4)}.20${str.substring(0, 2)} ${str.substring(6, 8)}:${str.substring(8, 10)}:${str.substring(10, 12)}";
    }

    return {
      "okp": parts[0],
      "cashRegisterCode": parts[1],
      "issueDateFormatted": date(parts[2]),
      "receiptNumber": int.tryParse(parts[3]) ?? 0,
      "totalAmount": parts[4],
      //"totalAmount": ((double.tryParse(parts[4]) ?? 0) * 100).round(),
    };
  }

  static DateTime? _parseKasaDate(String? date) {
    try {
      return DateFormat("dd.MM.yyy HH:mm:ss").parse(date!);
    } catch (_) {
      return null;
    }
  }

  /// {name, unitPrice, quantity, total_price, currency}
  static List<JsonObject> _parseKasaItems(JsonArray? items) {
    if (items == null) return [];
    return items
        .map((x) => {
              "name": (x["name"] as String?)?.trim(),
              "unitPrice": x["price"],
              "quantity": x["quantity"],
              "totalPrice": x["price"],
              "currency": Currency.eur.code,
            })
        .toList();
  }

  static _parseKasaPlace(JsonObject original) {
    if (original["unit"] is JsonObject) {
      final unit = original["unit"] as JsonObject;
      return "${unit["streetName"]} "
          "${unit["propertyRegistrationNumber"]}, "
          "${unit["municipality"]}";
    }
    return "";
  }

  /*
  static JsonObject _eKasaToGeneral(JsonObject original) {
    return {
      "date": _parseKasaDate(original["issueDate"])?.toIso8601String(),
      "totalPrice": original["totalPrice"],
      "currency": "EUR",
      "id": original["receiptId"],
      "items": _parseKasaItems(original["items"]),
      "place": _parseKasaPlace(original),
    };
  }
  */

  Receipt _toReceipt(JsonObject json) {
    final items = _parseKasaItems(json["items"]);
    return Receipt(
      receiptId: uuid(),
      clientId: "",
      userCardId: "",
      userId: session.userId,
      purchasedAtTime: _parseKasaDate(json["issueDate"])?.toUtc() ?? DateTime.now().toUtc(),
      purchasedAtPlace: _parseKasaPlace(json),
      totalPrice: Currency.eur.collapse(json["totalPrice"] as num),
      totalPriceCurrency: Currency.eur,
      items: items,
      externalId: json["receiptId"],
      totalItems: items.length,
    );
  }
}

// eof
