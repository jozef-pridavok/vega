import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../widgets/user_card_code.dart";
import "../screen_app.dart";

class CardCodeScreen extends AppScreen {
  final UserCard userCard;

  const CardCodeScreen(this.userCard, {super.key});

  @override
  createState() => _CardCodeState();
}

class _CardCodeState extends AppScreenState<CardCodeScreen> {
  UserCard get _userCard => widget.userCard;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: _userCard.number ?? _userCard.name,
        cancel: true,
      );

  @override
  Widget buildBody(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: UserCardCode(
          _userCard,
          rotateBarcode: true,
          width: constraints.maxWidth * 0.33,
          height: constraints.maxHeight * 0.33,
        ),
      );
    });
  }
}

// eof
