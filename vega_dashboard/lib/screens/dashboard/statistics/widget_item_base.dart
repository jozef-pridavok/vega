import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class ItemBaseWidget extends ConsumerWidget {
  final Widget child;

  const ItemBaseWidget({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 12),
      child: Container(
        decoration: moleculeShadowDecoration(ref.scheme.paperCard),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }
}

// eof
