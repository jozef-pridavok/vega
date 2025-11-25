import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/user_card.dart";

@immutable
abstract class IssueUserCardState {}

class IssueUserCardInitial extends IssueUserCardState {}

class IssueUserCardInProcess extends IssueUserCardState {}

class IssueUserCardSucceed extends IssueUserCardState {
  final UserCard userCard;
  IssueUserCardSucceed(this.userCard);
}

class IssueUserCardFailed extends IssueUserCardState {
  final CoreError? error;
  final String message;
  IssueUserCardFailed(this.message, {this.error});
}

class IssueUserCardNotifier extends StateNotifier<IssueUserCardState> with LoggerMixin {
  final UserCardRepository userCardRepository;

  IssueUserCardNotifier({required this.userCardRepository}) : super(IssueUserCardInitial());

  void reset() => state = IssueUserCardInitial();

  Future<void> issue(Card card, CodeType type, String value) async {
    try {
      state = IssueUserCardInProcess();
      final userCard = await userCardRepository.issue(card, type, value);
      state = IssueUserCardSucceed(userCard);
    } on CoreError catch (err) {
      error("Unexpected error: $err");
      state = IssueUserCardFailed(err.toString(), error: err);
    } catch (ex) {
      error("Unexpected exception: $ex");
      state = IssueUserCardFailed(ex.toString());
    }
  }
}

// eof
