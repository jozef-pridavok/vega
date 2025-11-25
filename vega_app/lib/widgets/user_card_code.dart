import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class UserCardCode extends ConsumerWidget {
  final UserCard userCard;
  final bool rotateBarcode;
  final double? width;
  final double? height;

  const UserCardCode(this.userCard, {this.rotateBarcode = false, super.key, this.width, this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.scheme.mode;
    final rotated = rotateBarcode && userCard.codeType.isRectangular;
    final codeWidget = CodeWidget(
      type: userCard.codeType,
      code: userCard.number ?? "",
      width: rotated ? height : width,
      height: rotated ? width : height,
    );
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(brightness == ThemeMode.light ? 0 : moleculeScreenPadding),
      child: rotated ? RotatedBox(quarterTurns: 1, child: codeWidget) : codeWidget,
    );
  }
}

// eof
