import "simple_cipher.dart";

/// Builder for QR codes. This class is used to generate and parse QR codes.
/// Wiki: // https://gitlab.vega.com/vega/vega/-/wikis/qr-codes
class QrBuilder {
  final String _version;
  final String _env;

  static final separator = ";";
  static final clientIdentity = "ci";
  static final cardIdentity = "ec";
  static final userIdentityCode = "ui";
  static final userCardIdentityCode = "di";
  static final reachRequestRewardCode = "rr";
  static final redeemUserCoupon = "rc";
  static final qrTagWithProgramPoints = "qt";

  //static final noData = <String>[];

  late SimpleCipher _crypton;

  QrBuilder(String key, this._version, this._env) {
    _crypton = SimpleCipher(key);
  }

  //

  String _buildHeader(String action) => [_version, _env, action].join("");

  List<String>? _parsePayload(String string, String req) {
    final version = string.substring(0, 1);
    final env = string.substring(1, 2);
    final action = string.substring(2, 4);
    if (version != _version || env != _env || action != req) return null;
    return string.substring(5).split(separator);
  }

  ////////////////////////////////////////////////////////////////////////////////
  // ci

  /// Generates a QR code payload to a client identity.
  /// Returns a string based on the clientId in the following format: `1;d;ci;clientId`
  String generateClientIdentity(String clientId) =>
      _crypton.encrypt(_buildHeader(clientIdentity) + separator + clientId);

  /// Parses a QR code payload to a client identity.
  /// Returns the clientId or null if the payload is invalid.
  String? parseClientIdentity(String data) {
    final string = _crypton.decrypt(data);
    if (string.length < 5) return null;
    final payload = _parsePayload(string, clientIdentity);
    if (payload?.length != 1) return null;
    return payload!.first;
  }

  ////////////////////////////////////////////////////////////////////////////////
  // ui

  /// Generates a QR code payload to identify a user.
  /// Returns a string based on the userId in the following format: `1;d;ui;userId`
  String generateUserIdentity(String userId) =>
      _crypton.encrypt(_buildHeader(userIdentityCode) + separator + userId);

  /// Parses a QR code payload to identify a user.
  /// Returns the userId or null if the payload is invalid.
  String? parseUserIdentity(String data) {
    try {
      final string = _crypton.decrypt(data);
      if (string.length < 5) return null;
      final payload = _parsePayload(string, userIdentityCode);
      if (payload?.length != 1) return null;
      return payload!.first;
    } catch (e) {
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  // di

  /// Generates a QR code payload to identify a user card.
  /// Returns a string based on the userCardId in the following format: `1;d;di;userCardId`
  String generateUserCardIdentity(String userCardId) =>
      _crypton.encrypt(_buildHeader(userIdentityCode) + separator + userCardId);

  /// Parses a QR code payload to identify a user card.
  /// Returns the userCardId or null if the payload is invalid.
  String? parseUserCardIdentity(String data) {
    try {
      final string = _crypton.decrypt(data);
      if (string.length < 5) return null;
      final payload = _parsePayload(string, userCardIdentityCode);
      if (payload?.length != 1) return null;
      return payload!.first;
    } catch (e) {
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  // ec

  /// Generates a QR code payload to issue a new user card.
  /// Returns a string based on the cardId and number in the following format: `1;d;ec;cardId`
  String generateCardIdentity(String cardId) =>
      _crypton.encrypt(_buildHeader(cardIdentity) + separator + cardId);

  /// Parses a QR code payload to issue a new user card.
  /// Returns record of the cardId and number or null if the payload is invalid.
  String? parseCardIdentity(String data) {
    try {
      final string = _crypton.decrypt(data);
      if (string.length < 3) return null;
      final payload = _parsePayload(string, cardIdentity);
      if (payload?.length != 1) return null;
      return payload!.first;
    } catch (e) {
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  // rr

  /// Generates a QR code payload to request a reward.
  /// Returns a string based on the userCardId and rewardId in the following format: `1;d;rr;userCardId;rewardId`
  String generateReachRequestReward(String userCardId, String rewardId) =>
      _crypton.encrypt(
        _buildHeader(reachRequestRewardCode) +
            separator +
            [userCardId, rewardId].join(separator),
      );

  /// Parses a QR code payload to request a reward.
  /// Returns a record of the userCardId and rewardId or null if the payload is invalid.
  (String, String)? parseReachRequestReward(String data) {
    try {
      final string = _crypton.decrypt(data);
      if (string.length < 5) return null;
      final payload = _parsePayload(string, reachRequestRewardCode);
      if (payload == null || payload.length != 2) return null;
      return (payload.first, payload.last);
    } catch (e) {
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  // rc

  /// Generates a QR code payload to a user coupon identity.
  /// Returns a string based on the userCouponId in the following format: `1;d;rc;userCardId;couponId`
  String generateUserCouponIdentity(String userCouponId) => _crypton.encrypt(
    _buildHeader(redeemUserCoupon) + separator + userCouponId,
  );

  /// Parses a QR code payload to a user coupon identity.
  /// Returns the userCouponId or null if the payload is invalid.
  String? parseUserCouponIdentity(String data) {
    try {
      final string = _crypton.decrypt(data);
      if (string.length < 5) return null;
      final payload = _parsePayload(string, redeemUserCoupon);
      if (payload?.length != 1) return null;
      return payload!.first;
    } catch (e) {
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  // qt

  /// Generates a QR code payload to a qr tag with program points.
  /// Returns a string based on the qrTagId in the following format: `1;d;qt;qrTagId`
  String generateQrTagWithPoints(String qrTagId) => _crypton.encrypt(
    _buildHeader(qrTagWithProgramPoints) + separator + qrTagId,
  );

  /// Parses a QR code payload to a qr tag with program points.
  /// Returns the qrTagId or null if the payload is invalid.
  String? parseQrTagWithPoints(String data) {
    try {
      final string = _crypton.decrypt(data);
      if (string.length < 5) return null;
      final payload = _parsePayload(string, qrTagWithProgramPoints);
      if (payload?.length != 1) return null;
      return payload!.first;
    } catch (e) {
      return null;
    }
  }
}

// eof
