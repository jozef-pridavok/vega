import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/repositories/program/programs.dart";

import "../../repositories/user/user_cards.dart";

@immutable
abstract class ScanQrCodeState {}

class ScanCodeInitial extends ScanQrCodeState {}

class ScanCodeParsing extends ScanQrCodeState {}

class ScanCodeSucceed extends ScanQrCodeState {
  final UserCard userCard;
  final num? points;

  ScanCodeSucceed({required this.userCard, this.points});
}

class ScanCodeTagSucceed extends ScanQrCodeState {
  final String? userCardId;
  final List<String>? userCardIds;
  ScanCodeTagSucceed({this.userCardId, this.userCardIds});
}

class ScanCodePickCard extends ScanQrCodeState {
  final CodeType type;
  final String value;

  ScanCodePickCard(this.type, this.value);
}

class ScanCodeFailed extends ScanQrCodeState implements FailedState {
  @override
  final CoreError error;
  ScanCodeFailed(this.error);
}

class ScanCodeNotifier extends StateNotifier<ScanQrCodeState> with LoggerMixin {
  final UserCardsRepository userCards;
  final ProgramsRepository programs;
  ScanCodeNotifier({required this.userCards, required this.programs}) : super(ScanCodeInitial());

  Future<void> parse(CodeType type, String value) async {
    if (state is ScanCodeParsing) return debug(() => "Already parsing...");

    try {
      state = ScanCodeParsing();

      final clientId = _isClientIdentity(type, value);
      if (clientId != null) {
        final userCard = await userCards.createByClient(clientId);
        state = ScanCodeSucceed(userCard: userCard);
        return;
      }

      final cardId = _isCardIdentity(type, value);
      if (cardId != null) {
        final userCard = await userCards.createByCard(cardId);
        state = ScanCodeSucceed(userCard: userCard);
        return;
      }

      final tagId = _isTagIdentity(type, value);
      if (tagId != null) {
        final (userCardId, userCardIds) = await programs.applyTag(tagId);
        state = (userCardId != null || userCardIds != null)
            ? ScanCodeTagSucceed(userCardId: userCardId, userCardIds: userCardIds)
            : ScanCodeFailed(errorUnexpectedException("Failed to apply tag"));
        return;
      }

      if (type == CodeType.qr) {
        final userCardByReceipt = await _checkReceipt(value);
        final userCard = userCardByReceipt?.userCard;
        if (userCard != null) {
          state = ScanCodeSucceed(userCard: userCard, points: userCardByReceipt?.points);
          return;
        }
      }

      state = ScanCodePickCard(type, value);
    } on CoreError catch (err) {
      debug(() => "Core error: $err");
      state = ScanCodeFailed(err);
    } catch (ex) {
      debug(() => "Failed to parse code: $ex");
      state = ScanCodeFailed(errorUnexpectedException(ex));
    }
  }

  /// Zistí, či je to identita klienta, ak áno vráti cardId, number
  /// pozri [QrBuilder.parseNewUserCard]
  String? _isClientIdentity(CodeType type, String number) {
    try {
      if (type != CodeType.qr) return null;
      return F().qrBuilder.parseClientIdentity(number);
    } catch (ex) {
      debug(() => "Failed to parse client identity: $ex");
    }
    return null;
  }

  /// Zistí, či je to identita karty klienta, ak áno vráti cardId
  /// pozri [QrBuilder.parseCardIdentity]
  String? _isCardIdentity(CodeType type, String number) {
    try {
      if (type != CodeType.qr) return null;
      return F().qrBuilder.parseCardIdentity(number);
    } catch (ex) {
      debug(() => "Failed to parse card identity: $ex");
    }
    return null;
  }

  /// Zistí, či je to identita tagu, ak áno vráti tagId
  /// pozri [QrBuilder.parseCardIdentity]
  String? _isTagIdentity(CodeType type, String number) {
    try {
      if (type != CodeType.qr) return null;
      return F().qrBuilder.parseQrTagWithPoints(number);
    } catch (ex) {
      debug(() => "Failed to parse tag identity: $ex");
    }
    return null;
  }

  Future<UserCardByReceipt?> _checkReceipt(String value) async {
    try {
      return await userCards.fromReceipt(value, F().receiptPassword);
    } on CoreError catch (ex) {
      debug(() => "Failed to check receipt $ex");
    }
    return null;
  }
}

// eof
