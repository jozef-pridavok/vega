import "dart:math";

import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class GeneratedCouponCodes {
  final int order;
  final String code;

  static String _pickCodeSymbols(CouponCodeMaskType maskType) {
    final String allowedSymbols;
    switch (maskType) {
      case CouponCodeMaskType.onlyUpperCase:
        allowedSymbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        break;
      case CouponCodeMaskType.onlyLetters:
        allowedSymbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxy";
        break;
      case CouponCodeMaskType.onlyDigits:
        allowedSymbols = "0123456789";
        break;
      case CouponCodeMaskType.lettersAndDigits:
        allowedSymbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        break;
    }
    return allowedSymbols;
  }

  static String _generateCode(String maskShape, CouponCodeMaskType maskType) {
    final allowedSymbols = _pickCodeSymbols(maskType);
    String result = "";
    final random = Random();

    for (final char in maskShape.runes) {
      if (String.fromCharCode(char) == "*") {
        result += allowedSymbols[random.nextInt(allowedSymbols.length)];
      } else {
        result += String.fromCharCode(char);
      }
    }
    return result;
  }

  GeneratedCouponCodes._internal({required this.order, required this.code});

  factory GeneratedCouponCodes({
    required int order,
    required String maskShape,
    required CouponCodeMaskType maskType,
    String? code,
  }) {
    return GeneratedCouponCodes._internal(order: order, code: _generateCode(maskShape, maskType));
  }

  factory GeneratedCouponCodes.fromExisting({
    required int order,
    required String code,
  }) {
    return GeneratedCouponCodes._internal(
      order: order,
      code: code,
    );
  }
}

@immutable
abstract class CouponCodesGeneratorState {}

class CouponCodesGeneratorInitial extends CouponCodesGeneratorState {}

class CouponCodesEditing extends CouponCodesGeneratorState {
  final List<GeneratedCouponCodes> codes;
  final CouponCodeMaskType codeMaskType;
  CouponCodesEditing({this.codeMaskType = CouponCodeMaskType.onlyUpperCase, this.codes = const []});
}

class CouponCodesGenerated extends CouponCodesEditing {
  CouponCodesGenerated({super.codes, super.codeMaskType});
}

class CouponCodesGeneratorNotifier extends StateNotifier<CouponCodesGeneratorState> with LoggerMixin {
  CouponCodesGeneratorNotifier() : super(CouponCodesGeneratorInitial());

  Future<void> reset() async => state = CouponCodesGeneratorInitial();

  void beginEdit(List<String> codes) {
    List<GeneratedCouponCodes> couponCodes = [];
    for (int i = 0; i < codes.length; i++) {
      couponCodes.add(GeneratedCouponCodes.fromExisting(order: i + 1, code: codes[i]));
    }
    state = CouponCodesEditing(codes: couponCodes);
  }

  void set({CouponCodeMaskType? codeMaskType}) {
    final currentState = cast<CouponCodesEditing>(state);
    if (currentState == null) return debug(() => errorUnexpectedState.toString());

    state = CouponCodesEditing(codeMaskType: codeMaskType ?? currentState.codeMaskType, codes: currentState.codes);
  }

  void generateCodes(int count, String maskShape) {
    final currentState = cast<CouponCodesEditing>(state);
    if (currentState == null) return debug(() => errorUnexpectedState.toString());

    final List<GeneratedCouponCodes> codes = [];
    for (var i = 0; i < count; i++) {
      codes.add(GeneratedCouponCodes(order: i + 1, maskShape: maskShape, maskType: currentState.codeMaskType));
    }

    state = CouponCodesGenerated(codes: codes, codeMaskType: currentState.codeMaskType);
  }
}

// eof
