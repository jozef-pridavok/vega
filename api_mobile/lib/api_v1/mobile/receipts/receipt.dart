import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../../data_access_objects/emit_card.dart";
import "../../../data_access_objects/mobile/client.dart";
import "../../../data_access_objects/mobile/user_card.dart";
import "../../../data_models/session.dart";
import "debug.dart";
import "receipt_ar.dart";
import "receipt_py_ekuatia.dart";
import "receipt_sk_ekasa.dart";
import "receipt_uy.dart";

class ProcessResult {
  final String cardId;
  final String? userCardId;
  final num? points;
  final Receipt? receipt;

  ProcessResult({required this.cardId, this.userCardId, this.points, this.receipt});
}

abstract class ReceiptImplementation {
  final ApiServer2 api;
  final Session session;
  final ApiServerContext context;

  ReceiptImplementation(this.api, this.session, this.context);

  void debug(String message) => api.log.debug(message);
  void verbose(String message) => api.log.verbose(message);
  void warning(String message) => api.log.warning(message);
  void error(String message) => api.log.error(message);

  Future<ProcessResult?> process(String qrCode, String payload);

  Future<ProcessResult?> defaultProcessLogic(
    ReceiptProvider provider,
    String companyId,
    String externalReceiptId,
    String payload,
    Currency currency,
    num? price,
    Receipt? receipt,
  ) async {
    final userCardDao = UserCardDAO(session, context);
    debug("Fake data: $receipt");
    var userCard = await userCardDao.userCardByMeta(provider, companyId);
    if (userCard != null) {
      final cardId = userCard.cardId!;
      final userCardId = userCard.userCardId;
      receipt?.clientId = userCard.clientId!;
      receipt?.userCardId = userCardId;
      final addedReceipt = await userCardDao.addReceipt(userCardId, receipt);
      final addedPoints = await userCardDao.addPoints(userCardId, LoyaltyTransactionObjectType.externalReceipt,
          externalReceiptId, {"payload": payload}, currency, price);
      //await userCardDao.addPoints(userCardId, addedReceipt?.receiptId, externalReceiptId, payload, currency, price);
      return ProcessResult(cardId: cardId, userCardId: userCardId, points: addedPoints, receipt: addedReceipt);
    }
    //final client = await userCardDao.clientByMeta(provider, companyId);
    final client = await ClientDAO(context).clientByMeta(provider, companyId);
    if (client == null) return null;
    final emitCard = EmitCardDAO(context);
    final clientId = client["clients"]?["client_id"];
    final clientMeta = (client["clients"]?["meta"] as Map<String, dynamic>?) ?? {};
    //final provider = clientMeta[provider.code];
    final autoCreateNewCard = clientMeta["qrCodeScanning"]["createNewUserCard"] ?? false;
    if (!autoCreateNewCard) return null;
    verbose("client = ${client["clients"]?["name"]}, $clientId");
    userCard = await userCardDao.userCardByClient(clientId);
    if (userCard == null) {
      verbose("No userCard for ${client["clients"]?["name"]} found");
      final cardId = await emitCard.getDefaultCard(clientId);
      if (cardId != null) {
        final userId = userCard?.userId;
        final userCardId = await emitCard.emitNewUserCard(clientId, cardId, userId!);
        receipt?.clientId = clientId;
        if (userCardId?.isNotEmpty ?? false) receipt?.userCardId = userCardId!;
        final addedReceipt =
            (userCardId?.isNotEmpty ?? false) ? await userCardDao.addReceipt(userCardId!, receipt) : null;
        final addedPoints = (userCardId?.isNotEmpty ?? false)
            ? await userCardDao.addPoints(userCardId!, LoyaltyTransactionObjectType.externalReceipt, externalReceiptId,
                {"payload": payload}, currency, price)
            //await userCardDao.addPoints(userCardId!, addedReceipt?.receiptId, externalReceiptId, payload, currency, price)
            : null;
        return ProcessResult(cardId: cardId, userCardId: userCardId, points: addedPoints, receipt: addedReceipt);
      }
      return null;
    } else {
      final cardId = userCard.cardId!;
      final userCardId = userCard.userCardId;
      receipt?.clientId = clientId;
      receipt?.userCardId = userCardId;
      final addedReceipt = await userCardDao.addReceipt(userCardId, receipt);
      final addedPoints = await userCardDao.addPoints(userCardId, LoyaltyTransactionObjectType.externalReceipt,
          externalReceiptId, {"payload": payload}, currency, price);
      //await userCardDao.addPoints(userCardId, addedReceipt?.receiptId, externalReceiptId, payload, currency, price);
      return ProcessResult(cardId: cardId, userCardId: userCardId, points: addedPoints, receipt: addedReceipt);
    }
  }

  String getExternalReceiptId(ReceiptProvider provider, String value, [bool debug = false]) {
    return "${debug ? "0" : provider.code}.$value";
  }

  Future<bool> selfAddPoints(UserCard userCard, JsonObject normalized, JsonObject payload) async {
    return Future<bool>.value(false);
  }
}

class ReceiptHandler {
  static ReceiptImplementation? determine(ApiServer2 api, Session session, ApiServerContext context, String qrCode) {
    ReceiptImplementation? result = _isDebugReceipt(api, session, context, qrCode);
    if (result != null) return result;

    final lcQrCode = qrCode.toLowerCase();

    final isUy = lcQrCode.startsWith(
          "https://www.efactura.dgi.gub.uy/consultaqr/cfe?",
        ) ||
        lcQrCode.startsWith(
          "www.efactura.dgi.gub.uy/consultaqr/cfe?",
        );

    final isAr =
        // http://qr.afip.gob.ar/?qr=cCjNDfcdizwQbaGi_ErUrg,,
        // -> https://serviciosweb.afip.gob.ar/clavefiscal/qr/response.aspx?qr=cCjNDfcdizwQbaGi_ErUrg,,
        //
        lcQrCode.startsWith("https://www.afip.gob.ar/fe/qr/?p=") ||
            // toto platí...
            lcQrCode.startsWith(
              "https://serviciosweb.afip.gob.ar/genericos/comprobantes/cae.aspx?p=",
            );

    final isPy = lcQrCode.startsWith("https://ekuatia.set.gov.py/consultas/qr?nversion=150");

    if (isPy) {
      return ReceiptPy(api, session, context);
    } else if (isUy) {
      return ReceiptUy(api, session, context);
    } else if (isAr) {
      return ReceiptAr(api, session, context);
    }

    //
    // SK
    // O-B0C46C9613234629846C961323562963
    else if (qrCode.startsWith("O-") && qrCode.length == 34) {
      //$hint("QR receipt: SK eKasa, variant starts with O-");
      return ReceiptSk(api, session, context, qrCode, true);
    } else if (qrCode.split(":").length == 5) {
      //$hint("QR receipt: SK eKasa, variant with 5 segments");
      return ReceiptSk(api, session, context, qrCode, false);
    }
    return null;
  }

  static ReceiptImplementation? _isDebugReceipt(
      ApiServer2 api, Session session, ApiServerContext context, String receipt) {
    final isValidEnv = api.config.isDev || api.config.isQa || api.config.isDemo;
    if (!isValidEnv) return null;
    if (!receipt.startsWith("debug://receipt")) return null;

    final uri = Uri.tryParse(receipt);
    if (uri == null) return null;

    ReceiptProvider? provider;
    Currency? currency;
    String companyId = "";
    String key;

    key = "skEkasa";
    if (uri.queryParameters.containsKey(key)) {
      companyId = uri.queryParameters[key] ?? "";
      provider = ReceiptProvider.skEkasa;
      currency = Currency.eur;
    }

    key = "uyEfactura";
    if (uri.queryParameters.containsKey(key)) {
      companyId = uri.queryParameters[key] ?? "";
      provider = ReceiptProvider.uyEfactura;
      currency = Currency.uyu;
    }

    key = "arAfip";
    if (uri.queryParameters.containsKey(key)) {
      companyId = uri.queryParameters[key] ?? "";
      provider = ReceiptProvider.arAfip;
      currency = Currency.ars;
    }

    key = "pyEkuatia";
    if (uri.queryParameters.containsKey(key)) {
      companyId = uri.queryParameters[key] ?? "";
      provider = ReceiptProvider.pyEkuatia;
      currency = Currency.pyg;
    }

    if (provider != null && currency != null) {
      return ReceiptDebug(api, session, context, companyId: companyId, provider: provider, currency: currency);
    }

    return null;
  }
}

// eof
