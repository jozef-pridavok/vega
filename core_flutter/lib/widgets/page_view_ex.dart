import "package:flutter/material.dart";

import "expandable_page_view.dart";

class PageViewEx extends StatelessWidget {
  final PageController controller;
  final List<Widget> children;
  final ScrollPhysics? physics;
  final bool padEnds;
  final void Function(int)? onPageChanged;

  const PageViewEx({
    super.key,
    required this.controller,
    required this.children,
    this.physics,
    this.padEnds = true,
    this.onPageChanged,
  }) : assert(children.length > 0, "children must not be empty");

  @override
  Widget build(BuildContext context) {
    return ExpandablePageView(
      controller: controller,
      physics: physics,
      padEnds: padEnds,
      onPageChanged: onPageChanged,
      children: children,
    );
  }
}

// eof
