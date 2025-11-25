import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../caches.dart";

class UserCardLogo extends ConsumerWidget {
  final UserCard userCard;
  final bool shadow;

  const UserCardLogo(this.userCard, {this.shadow = true, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MoleculusCardGrid1(
      backgroundColor: userCard.color?.toMaterial() ?? ref.scheme.paperCard,
      shadow: shadow,
      imageUrl: userCard.logo ?? "",
      imageCache: Caches.cardLogo, // $cardLogoCacheManager(),
    );
  }
}

// eof
