import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

@immutable
abstract class ScanQrCodeState {}

class ScanCodeInitial extends ScanQrCodeState {}

class ScanCodeParsing extends ScanQrCodeState {}

abstract class ScanCodeSucceed extends ScanQrCodeState {
  ScanCodeSucceed();
}

class ScanCodeSucceedWithCoupon implements ScanQrCodeState {
  final UserCoupon userCoupon;
  ScanCodeSucceedWithCoupon(this.userCoupon);
}

class ScanCodePickCard extends ScanQrCodeState {
  final CodeType type;
  final String value;

  ScanCodePickCard(this.type, this.value);
}

class ScanCodeFailed extends ScanQrCodeState {
  final CoreError? error;
  final String message;
  ScanCodeFailed(this.message, {this.error});
}

class ScanCodeNotifier extends StateNotifier<ScanQrCodeState> with LoggerMixin {
  //final UserCardsRepository remoteUserCardsRepository;
  ScanCodeNotifier(/*{required this.remoteUserCardsRepository}*/) : super(ScanCodeInitial());

  Future<void> parse(CodeType type, String value) async {
    try {
      state = ScanCodeParsing();

      final coupon = _isCoupon(type, value);
      if (coupon != null) {
        final userCoupon = await _redeemCoupon(coupon);
        if (userCoupon != null) {
          state = ScanCodeSucceedWithCoupon(userCoupon);
          return;
        }
      }

      state = ScanCodePickCard(type, value);
    } catch (ex) {
      state = ScanCodeFailed("Scanning failed", error: errorUnexpectedException(ex));
    }
  }

  /// Zistí, či je kupón používateľa
  String? _isCoupon(CodeType type, String number) {
    if (type != CodeType.qr) return null;
    try {
      return F().qrBuilder.parseUserCouponIdentity(number);
    } catch (e) {
      //$debug("This is not user coupon. $e");
      return null;
    }
  }

  Future<UserCoupon?> _redeemCoupon(String coupon) async {
    return null;
  }
}

// eof
