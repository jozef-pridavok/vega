import "package:flutter/material.dart";

class NoAnimationPageRouteTransition extends PageRouteBuilder {
  final Widget widget;
  NoAnimationPageRouteTransition(this.widget)
      : super(
          pageBuilder: (context, anim, secondaryAnim) => widget,
        );
}

// eof
