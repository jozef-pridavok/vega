import "package:core_dart/core_dart.dart";

enum UserCardByReceiptKeys {
  userCard,
  receipt,
  points,
}

class UserCardByReceipt {
  final UserCard? userCard;
  final Receipt? receipt;
  final int? points;

  UserCardByReceipt({this.userCard, this.receipt, this.points});

  static const camel = {
    UserCardByReceiptKeys.userCard: "detail",
    UserCardByReceiptKeys.receipt: "receipt",
    UserCardByReceiptKeys.points: "points",
  };

  static const snake = {
    UserCardByReceiptKeys.userCard: "detail",
    UserCardByReceiptKeys.receipt: "receipt",
    UserCardByReceiptKeys.points: "points",
  };

  static UserCardByReceipt fromMap(Map<String, dynamic> map, Convention convention) {
    return UserCardByReceipt(
      userCard: map["detail"] == null ? null : UserCard.fromMap(map["detail"], convention),
      receipt: map["receipt"] == null ? null : Receipt.fromMap(map["receipt"], convention),
      points: jsonIntOrNull(map, "points"),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? UserCardByReceipt.camel : UserCardByReceipt.snake;
    return {
      mapper[UserCardByReceiptKeys.userCard]!: userCard?.toMap(convention),
      mapper[UserCardByReceiptKeys.receipt]!: receipt?.toMap(convention),
      mapper[UserCardByReceiptKeys.points]!: points,
    };
  }
}

// eof
